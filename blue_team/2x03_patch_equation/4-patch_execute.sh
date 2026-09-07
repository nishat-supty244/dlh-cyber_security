#!/bin/bash

set -euo pipefail

PLAN_FILE="patch_plan.json"
LOG_FILE="patch_execution_log.json"
LOCK_FILE="/var/lock/meddefense-patch.lock"

if [ ! -f "$PLAN_FILE" ]; then
    echo "Error: $PLAN_FILE not found." >&2
    exit 1
fi

# 1. Acquire an advisory lock in /var/lock/meddefense-patch.lock with backoff
echo -n "[*] Acquiring lock $LOCK_FILE... "
exec 200>"$LOCK_FILE"

lock_acquired=0
elapsed=0
backoff=1

while [ $elapsed -lt 120 ]; do
    if flock -n 200; then
        lock_acquired=1
        break
    fi
    sleep "$backoff"
    elapsed=$((elapsed + backoff))
    backoff=$((backoff * 2))
    [ $backoff -gt 15 ] && backoff=15
done

if [ $lock_acquired -eq 0 ]; then
    echo "FAILED (Lock busy)"
    exit 2
fi
echo "OK"

# Ensure lock is released via trap
cleanup() {
    flock -u 200 || true
}
trap cleanup EXIT

# 2. Consume patch_plan.json
PLAN_HASH=$(sha256sum "$PLAN_FILE" | awk '{print $1}')
STARTED_AT=$(date +%s)
HOSTNAME_VAL=$(hostname)

TOTAL_ENTRIES=$(jq '.plan | length' "$PLAN_FILE" 2>/dev/null || echo "0")
echo "[*] Loading plan: $PLAN_FILE ($TOTAL_ENTRIES entries)"

# Initialize execution log JSON file
jq -n \
    --argjson started "$STARTED_AT" \
    --arg host "$HOSTNAME_VAL" \
    --arg phash "$PLAN_HASH" \
    '{started_at: $started, finished_at: 0, hostname: $host, plan_source_hash: $phash, entries: []}' > "$LOG_FILE"

SUCCEEDED=0
FAILED=0
ANY_FAILED=0

# Iterate through plan entries
index=1
while [ $index -le "$TOTAL_ENTRIES" ]; do
    # Extract entry data using jq
    PKG=$(jq -r --argjson i $((index - 1)) '.plan[$i].package' "$PLAN_FILE")
    BUCKET=$(jq -r --argjson i $((index - 1)) '.plan[$i].bucket' "$PLAN_FILE")
    REQ_RESTART=$(jq -r --argjson i $((index - 1)) '.plan[$i].requires_restart' "$PLAN_FILE")
    
    # Record pre-block package version
    PRE_VERSION=$(dpkg-query -W -f='${Version}' "$PKG" 2>/dev/null || echo "unknown")
    
    # Record pre-block service states for affected services
    PRE_SERVICES_JSON="{}"
    AFFECTED_SVCS=$(jq -r --argjson i $((index - 1)) '.plan[$i].affected_services[]?' "$PLAN_FILE" 2>/dev/null || true)
    for svc in $AFFECTED_SVCS; do
        [ "$svc" = "(kernel-wide)" ] && continue
        act=$(systemctl show -p ActiveState --value "$svc" 2>/dev/null || echo "unknown")
        sub=$(systemctl show -p SubState --value "$svc" 2>/dev/null || echo "unknown")
        pid=$(systemctl show -p MainPID --value "$svc" 2>/dev/null || echo "0")
        s_json=$(jq -n --arg a "$act" --arg s "$sub" --arg p "$pid" '{ActiveState: $a, SubState: $s, MainPID: $p}')
        PRE_SERVICES_JSON=$(jq -n --argjson obj "$PRE_SERVICES_JSON" --arg sv "$svc" --argjson val "$s_json" '$obj + {($sv): $val}')
    done

    echo -n "[$index/$TOTAL_ENTRIES] $PKG   $BUCKET   apt-get ... "
    
    START_TIME=$(date +%s.%N)
    
    # Run apt-get install --only-upgrade -y with dpkg lock backoff handling
    APT_EXIT=1
    APT_STDOUT=""
    APT_STDERR=""
    apt_elapsed=0
    apt_backoff=2
    
    while [ $apt_elapsed -lt 120 ]; do
        export DEBIAN_FRONTEND=noninteractive
        APT_OUT=$(mktemp)
        APT_ERR=$(mktemp)
        
        set +e
        apt-get install --only-upgrade -y "$PKG" > "$APT_OUT" 2> "$APT_ERR"
        APT_EXIT=$?
        set -e
        
        APT_STDOUT=$(cat "$APT_OUT")
        APT_STDERR=$(cat "$APT_ERR")
        rm -f "$APT_OUT" "$APT_ERR"
        
        if [ $APT_EXIT -eq 0 ]; then
            break
        elif echo "$APT_STDERR" | grep -qE "Could not get lock|Resource temporarily unavailable"; then
            sleep "$apt_backoff"
            apt_elapsed=$((apt_elapsed + apt_backoff))
            apt_backoff=$((apt_backoff * 2))
            [ $apt_backoff -gt 30 ] && apt_backoff=30
        else
            break
        fi
    done

    END_TIME=$(date +%s.%N)
    DURATION=$(awk "BEGIN {print $END_TIME - $START_TIME}")

    STATUS="success"
    if [ $APT_EXIT -ne 0 ]; then
        STATUS="failed"
        FAILED=$((FAILED + 1))
        ANY_FAILED=1
    else
        SUCCEEDED=$((SUCCEEDED + 1))
    fi

    if [ "$STATUS" = "success" ]; then
        echo "OK (${DURATION}s)"
    else
        echo "FAILED (Exit: $APT_EXIT)"
    fi

    # Handle restarts if required
    RESTART_RESULTS="{}"
    if [ "$STATUS" = "success" ] && [ "$REQ_RESTART" = "true" ]; then
        for svc in $AFFECTED_SVCS; do
            [ "$svc" = "(kernel-wide)" ] && continue
            echo -n "      try-restart $svc         "
            if systemctl try-restart "$svc" 2>/dev/null; then
                echo "OK"
                RESTART_RESULTS=$(jq -n --argjson obj "$RESTART_RESULTS" --arg s "$svc" --arg r "OK" '$obj + {($s): $r}')
            else
                echo "FAILED"
                RESTART_RESULTS=$(jq -n --argjson obj "$RESTART_RESULTS" --arg s "$svc" --arg r "FAILED" '$obj + {($s): $r}')
            fi
        done
    fi

    # Record post-block version and service states
    POST_VERSION=$(dpkg-query -W -f='${Version}' "$PKG" 2>/dev/null || echo "unknown")
    POST_SERVICES_JSON="{}"
    for svc in $AFFECTED_SVCS; do
        [ "$svc" = "(kernel-wide)" ] && continue
        act=$(systemctl show -p ActiveState --value "$svc" 2>/dev/null || echo "unknown")
        sub=$(systemctl show -p SubState --value "$svc" 2>/dev/null || echo "unknown")
        pid=$(systemctl show -p MainPID --value "$svc" 2>/dev/null || echo "0")
        s_json=$(jq -n --arg a "$act" --arg s "$sub" --arg p "$pid" '{ActiveState: $a, SubState: $s, MainPID: $p}')
        POST_SERVICES_JSON=$(jq -n --argjson obj "$POST_SERVICES_JSON" --arg sv "$svc" --argjson val "$s_json" '$obj + {($sv): $val}')
    done

    STDOUT_TAIL=$(echo "$APT_STDOUT" | tail -n 10)
    STDERR_TAIL=$(echo "$APT_STDERR" | tail -n 10)

    # Append entry to patch_execution_log.json using jq
    ENTRY_JSON=$(jq -n \
        --arg pkg "$PKG" \
        --arg pre_v "$PRE_VERSION" \
        --argjson pre_s "$PRE_SERVICES_JSON" \
        --arg post_v "$POST_VERSION" \
        --argjson post_s "$POST_SERVICES_JSON" \
        --arg status "$STATUS" \
        --argjson exit_code "$APT_EXIT" \
        --argjson dur "$DURATION" \
        --arg stout "$STDOUT_TAIL" \
        --arg sterr "$STDERR_TAIL" \
        '{
            package: $pkg,
            pre: {installed_version: $pre_v, service_states: $pre_s},
            post: {installed_version: $post_v, service_states: $post_s},
            status: $status,
            exit_status: $exit_code,
            duration_seconds: $dur,
            stdout_tail: $stout,
            stderr_tail: $sterr
        }')

    # Update log file with new entry
    TEMP_LOG=$(mktemp)
    jq --argjson entry "$ENTRY_JSON" '.entries += [$entry]' "$LOG_FILE" > "$TEMP_LOG" && mv "$TEMP_LOG" "$LOG_FILE"

    # Stop loop if package update failed
    if [ "$STATUS" = "failed" ]; then
        break
    fi

    index=$((index + 1))
done

FINISHED_AT=$(date +%s)
TEMP_LOG=$(mktemp)
jq --argjson fin "$FINISHED_AT" '.finished_at = $fin' "$LOG_FILE" > "$TEMP_LOG" && mv "$TEMP_LOG" "$LOG_FILE"

echo "Succeeded: $SUCCEEDED  Failed: $FAILED"
echo "Log saved to: $LOG_FILE"

if [ $ANY_FAILED -ne 0 ]; then
    exit 1
else
    exit 0
fi
