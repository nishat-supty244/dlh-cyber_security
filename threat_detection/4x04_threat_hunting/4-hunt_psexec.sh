#!/bin/bash

# ================================================================
# MedDefense - Task 4
# Hunt: Lateral Movement via PsExec
#
# ATT&CK Technique:
# T1021.002 - SMB/Windows Admin Shares
#
# Purpose:
#   Search the 14-day SIEM data for PsExec activity and compare
#   each event against Robert Kim's legitimate admin baseline.
#
# Requirements:
#   - jq
#   - Bash
#
# Important:
#   SIEM files are JSONL (one JSON object per line).
#   DO NOT modify the SIEM source files.
# ================================================================

set -euo pipefail

# ----------------------------------------------------------------
# Paths
# ----------------------------------------------------------------

ALERTS="siem_export/wazuh_alerts_14d.json"
SYSMON="siem_export/wazuh_raw_sysmon_14d.json"
BASELINE="baseline/robert_kim_activity.json"
SCHEDULE="reference/admin_schedule.txt"
TOPOLOGY="reference/network_topology.txt"

# ----------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------

ADMIN_HOST="WS-ADMIN-01"
ADMIN_USER="MEDDEFENSE\\robert.kim"

BUSINESS_START=8
BUSINESS_END=18

# ----------------------------------------------------------------
# Temporary files
# ----------------------------------------------------------------

TMP_DIR="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

PSEXEC_EVENTS="$TMP_DIR/psexec_events.jsonl"
BASELINE_EVENTS="$TMP_DIR/baseline_events.jsonl"
ANOMALOUS_EVENTS="$TMP_DIR/anomalous_events.jsonl"

: > "$PSEXEC_EVENTS"
: > "$BASELINE_EVENTS"
: > "$ANOMALOUS_EVENTS"

# ----------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------

die() {
    echo "[ERROR] $*" >&2
    exit 1
}

info() {
    echo "[INFO] $*"
}

# Check required command
command -v jq >/dev/null 2>&1 || die "jq is required but not installed."

# Check required files
for file in "$ALERTS" "$SYSMON" "$BASELINE" "$SCHEDULE" "$TOPOLOGY"; do
    if [[ ! -f "$file" ]]; then
        die "Required file not found: $file"
    fi
done

# ----------------------------------------------------------------
# Validate JSONL files
#
# Each line in the SIEM exports is a separate JSON object.
# We therefore validate line-by-line instead of using:
#     jq -e empty file
# ----------------------------------------------------------------

validate_jsonl() {
    local file="$1"
    local line_number=0
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_number=$((line_number + 1))

        # Ignore empty lines
        [[ -z "${line//[[:space:]]/}" ]] && continue

        if ! jq -e . >/dev/null 2>&1 <<< "$line"; then
            die "Invalid JSON on line $line_number of $file"
        fi
    done < "$file"
}

info "Validating SIEM JSONL files..."

validate_jsonl "$ALERTS"
validate_jsonl "$SYSMON"

info "JSONL validation successful."

# ----------------------------------------------------------------
# Extract PsExec events
#
# Search:
#   1. Sysmon Image
#   2. Sysmon CommandLine
#
# PsExec may appear as:
#   PsExec.exe
#   psexec.exe
#   C:\Tools\PsExec.exe
#   \\host\...\PsExec.exe
# ----------------------------------------------------------------

info "Searching Sysmon data for PsExec activity..."

jq -c '
    select(
        (
            (.data.win.eventdata.image // "")
            | ascii_downcase
            | contains("psexec")
        )
        or
        (
            (.data.win.eventdata.commandLine // "")
            | ascii_downcase
            | contains("psexec")
        )
    )
' "$SYSMON" >> "$PSEXEC_EVENTS"

# ----------------------------------------------------------------
# Also search Wazuh alerts.
#
# This catches PsExec events that may have been normalized into
# Wazuh alerts rather than appearing only in raw Sysmon.
# ----------------------------------------------------------------

jq -c '
    select(
        (
            (.data.win.eventdata.image // "")
            | ascii_downcase
            | contains("psexec")
        )
        or
        (
            (.data.win.eventdata.commandLine // "")
            | ascii_downcase
            | contains("psexec")
        )
        or
        (
            (.rule.description // "")
            | ascii_downcase
            | contains("psexec")
        )
    )
' "$ALERTS" >> "$PSEXEC_EVENTS"

# ----------------------------------------------------------------
# Remove duplicate events.
#
# The same event may exist in both Wazuh alerts and raw Sysmon.
# We use the event ID when available.
# ----------------------------------------------------------------

sort -u "$PSEXEC_EVENTS" > "$TMP_DIR/psexec_unique.jsonl"

mv "$TMP_DIR/psexec_unique.jsonl" "$PSEXEC_EVENTS"

# ----------------------------------------------------------------
# Count PsExec events
# ----------------------------------------------------------------

TOTAL_PSEXEC=$(grep -c '^{' "$PSEXEC_EVENTS" || true)

# ----------------------------------------------------------------
# Load Robert Kim baseline
#
# The baseline is expected to be normal JSON.
# It may be an array or an object containing an array.
# We extract objects safely.
# ----------------------------------------------------------------

jq -c '
    if type == "array" then
        .[]
    elif type == "object" then
        if .events? and (.events | type == "array") then
            .events[]
        elif .activity? and (.activity | type == "array") then
            .activity[]
        else
            .
        end
    else
        empty
    end
' "$BASELINE" > "$BASELINE_EVENTS"

# ----------------------------------------------------------------
# Determine whether a baseline event is PsExec-related.
# ----------------------------------------------------------------

BASELINE_PSEXEC_COUNT=$(
    jq -s '
        map(
            select(
                (
                    ((.tool // "") | tostring | ascii_downcase | contains("psexec"))
                    or
                    ((.command // "") | tostring | ascii_downcase | contains("psexec"))
                    or
                    ((.process // "") | tostring | ascii_downcase | contains("psexec"))
                )
            )
        ) | length
    ' "$BASELINE_EVENTS"
)

# ----------------------------------------------------------------
# Function: get event timestamp
# ----------------------------------------------------------------

get_timestamp() {
    jq -r '
        .timestamp
        // .data.win.eventdata.utcTime
        // "-"
    '
}

# ----------------------------------------------------------------
# Function: get source host
# ----------------------------------------------------------------

get_source_host() {
    jq -r '
        .agent.name
        // .data.win.system.computer
        // .hunt_meta.source_host
        // .data.win.eventdata.computer
        // "-"
    '
}

# ----------------------------------------------------------------
# Function: get user
# ----------------------------------------------------------------

get_user() {
    jq -r '
        .data.win.eventdata.user
        // .data.win.eventdata.targetUserName
        // .hunt_meta.user
        // "-"
    '
}

# ----------------------------------------------------------------
# Function: get command line
# ----------------------------------------------------------------

get_command() {
    jq -r '
        .data.win.eventdata.commandLine
        // .data.win.eventdata.command
        // .hunt_meta.command
        // .data.win.eventdata.image
        // "-"
    '
}

# ----------------------------------------------------------------
# Function: get target host
#
# PsExec command examples:
#   PsExec.exe \\SRV-HEALTH-DB -s cmd.exe
#
# If the event already contains a destination hostname, use it.
# Otherwise try to extract \\HOST from the command line.
# ----------------------------------------------------------------

get_target() {
    jq -r '
        .data.win.eventdata.destinationHostname
        // .hunt_meta.target_host
        // (
            (.data.win.eventdata.commandLine // "")
            | capture("\\\\\\\\(?<target>[^[:space:]\\\\]+)")?.target
        )
        // "-"
    '
}

# ----------------------------------------------------------------
# Function: get PID
# ----------------------------------------------------------------

get_pid() {
    jq -r '
        .data.win.eventdata.processId
        // .data.win.eventdata.processID
        // .data.win.eventdata.pid
        // "-"
    '
}

# ----------------------------------------------------------------
# Function: check service account
#
# MedDefense service accounts commonly begin with:
#   svc_
#
# We also check the service-account reference file so that known
# service accounts are treated as service accounts.
# ----------------------------------------------------------------

is_service_account() {
    local user="$1"

    if [[ "${user,,}" == *"\\svc_"* ]]; then
        return 0
    fi

    if [[ "${user,,}" == svc_* ]]; then
        return 0
    fi

    if grep -Fqi "$user" "$SERVICE_ACCOUNT_FILE" 2>/dev/null; then
        return 0
    fi

    return 1
}

SERVICE_ACCOUNT_FILE="reference/service_accounts.txt"

# ----------------------------------------------------------------
# Function: check whether timestamp is during business hours
#
# Baseline:
#   08:00 - 18:00
# ----------------------------------------------------------------

is_business_hour() {
    local timestamp="$1"
    local hour

    hour=$(date -d "$timestamp" '+%H' 2>/dev/null || echo "99")
    hour=$((10#$hour))

    if (( hour >= BUSINESS_START && hour < BUSINESS_END )); then
        return 0
    fi

    return 1
}

# ----------------------------------------------------------------
# Function: get day of week
# ----------------------------------------------------------------

get_day() {
    local timestamp="$1"

    date -d "$timestamp" '+%A' 2>/dev/null || echo "Unknown"
}

# ----------------------------------------------------------------
# Function: check whether event matches Robert Kim baseline
#
# Baseline conditions:
#   Source = WS-ADMIN-01
#   User   = MEDDEFENSE\robert.kim
#   Time   = 08:00-18:00
# ----------------------------------------------------------------

check_baseline() {
    local source="$1"
    local user="$2"
    local timestamp="$3"

    if [[ "$source" != "$ADMIN_HOST" ]]; then
        return 1
    fi

    if [[ "${user,,}" != "${ADMIN_USER,,}" ]]; then
        return 1
    fi

    if ! is_business_hour "$timestamp"; then
        return 1
    fi

    return 0
}

# ----------------------------------------------------------------
# Process every PsExec event
# ----------------------------------------------------------------

BASELINE_COUNT=0
ANOMALOUS_COUNT=0

while IFS= read -r event; do

    [[ -z "$event" ]] && continue

    timestamp=$(jq -r '.timestamp // .data.win.eventdata.utcTime // "-"' <<< "$event")
    source=$(jq -r '.agent.name // .data.win.system.computer // .hunt_meta.source_host // "-"' <<< "$event")
    user=$(jq -r '.data.win.eventdata.user // .data.win.eventdata.targetUserName // .hunt_meta.user // "-"' <<< "$event")
    command=$(jq -r '.data.win.eventdata.commandLine // .data.win.eventdata.command // .hunt_meta.command // .data.win.eventdata.image // "-"' <<< "$event")
    target=$(jq -r '
        .data.win.eventdata.destinationHostname
        // .hunt_meta.target_host
        // (
            (.data.win.eventdata.commandLine // "")
            | capture("\\\\\\\\(?<target>[^[:space:]\\\\]+)")?.target
        )
        // "-"
    ' <<< "$event")
    pid=$(jq -r '.data.win.eventdata.processId // .data.win.eventdata.processID // .data.win.eventdata.pid // "-"' <<< "$event")

    day=$(get_day "$timestamp")

    # ------------------------------------------------------------
    # Determine anomaly flags
    # ------------------------------------------------------------

    flags=()

    if [[ "$source" != "$ADMIN_HOST" ]]; then
        flags+=("Source host is NOT $ADMIN_HOST")
    fi

    if ! is_business_hour "$timestamp"; then
        flags+=("Time is outside business hours (08:00-18:00)")
    fi

    if [[ "${user,,}" != "${ADMIN_USER,,}" ]]; then
        flags+=("User is NOT $ADMIN_USER")
    fi

    if is_service_account "$user"; then
        flags+=("User is a service account")
    fi

    # ------------------------------------------------------------
    # Check whether target looks like a server/database system
    # using network topology where possible.
    # ------------------------------------------------------------

    if [[ "$target" != "-" ]]; then
        if grep -Fqi "$target" "$TOPOLOGY" 2>/dev/null; then
            if grep -Eiq "database|db|patient|health" "$TOPOLOGY" 2>/dev/null; then
                flags+=("Target appears in network topology as a sensitive server")
            fi
        fi
    fi

    # ------------------------------------------------------------
    # Classify event
    # ------------------------------------------------------------

    if check_baseline "$source" "$user" "$timestamp" && \
       [[ "${#flags[@]}" -eq 0 ]]; then

        BASELINE_COUNT=$((BASELINE_COUNT + 1))

        printf '%s\n' "$event" >> "$TMP_DIR/baseline_matching.jsonl"

    else

        ANOMALOUS_COUNT=$((ANOMALOUS_COUNT + 1))

        # Store event together with anomaly information.
        jq -c \
            --arg flags "$(printf '%s\n' "${flags[@]:-}" | paste -sd '|' -)" \
            --arg day "$day" \
            --arg source "$source" \
            --arg user "$user" \
            --arg target "$target" \
            --arg command "$command" \
            --arg pid "$pid" \
            --arg timestamp "$timestamp" '
            . + {
                hunt_result: {
                    timestamp: $timestamp,
                    source_host: $source,
                    user: $user,
                    command: $command,
                    target_host: $target,
                    pid: $pid,
                    day: $day,
                    anomaly_flags: $flags
                }
            }
        ' <<< "$event" >> "$ANOMALOUS_EVENTS"

    fi

done < "$PSEXEC_EVENTS"

# ----------------------------------------------------------------
# Output
# ----------------------------------------------------------------

echo
echo "================================================================"
echo "   HUNT EXECUTION - H1: Lateral Movement via PsExec"
echo "   Technique: T1021.002 SMB/Windows Admin Shares"
echo "================================================================"
echo

echo "HUNT SCOPE:"
echo "  SIEM window: Last 14 days"
echo "  Data source: Wazuh alerts + raw Sysmon"
echo "  Baseline: Robert Kim legitimate administrator activity"
echo

echo "QUERY RESULTS:"
echo "  Total PsExec events in 14 days: $TOTAL_PSEXEC"
echo "  Baseline: $BASELINE_COUNT"
echo "  ANOMALOUS: $ANOMALOUS_COUNT"
echo

echo "ROBERT KIM BASELINE:"
echo "  Expected source host: $ADMIN_HOST"
echo "  Expected user: $ADMIN_USER"
echo "  Expected hours: 08:00-18:00"
echo "  PsExec-related baseline records: $BASELINE_PSEXEC_COUNT"
echo

# ----------------------------------------------------------------
# Print anomalous events
# ----------------------------------------------------------------

if (( ANOMALOUS_COUNT > 0 )); then

    echo "ANOMALOUS EVENTS:"
    echo

    EVENT_NUMBER=0

    while IFS= read -r event; do

        [[ -z "$event" ]] && continue

        EVENT_NUMBER=$((EVENT_NUMBER + 1))

        timestamp=$(jq -r '.hunt_result.timestamp' <<< "$event")
        source=$(jq -r '.hunt_result.source_host' <<< "$event")
        user=$(jq -r '.hunt_result.user' <<< "$event")
        command=$(jq -r '.hunt_result.command' <<< "$event")
        target=$(jq -r '.hunt_result.target_host' <<< "$event")
        pid=$(jq -r '.hunt_result.pid' <<< "$event")
        day=$(jq -r '.hunt_result.day' <<< "$event")
        flags=$(jq -r '.hunt_result.anomaly_flags' <<< "$event")

        echo "  [A$EVENT_NUMBER] $timestamp"
        echo "    Day: $day"
        echo "    Source: $source"
        echo "    User: $user"
        echo "    Command: $command"
        echo "    Target: $target"
        echo "    PID: $pid"
        echo "    ANOMALY FLAGS:"

        if [[ -n "$flags" ]]; then
            IFS='|' read -ra FLAG_ARRAY <<< "$flags"

            for flag in "${FLAG_ARRAY[@]}"; do
                [[ -n "$flag" ]] && echo "      [!] $flag"
            done
        else
            echo "      [!] Event does not match the Robert Kim baseline"
        fi

        echo

    done < "$ANOMALOUS_EVENTS"

else

    echo "ANOMALOUS EVENTS:"
    echo "  None identified."
    echo

fi

# ----------------------------------------------------------------
# Final finding
# ----------------------------------------------------------------

echo "FINDING:"

if (( ANOMALOUS_COUNT > 0 )); then

    HIGH_CONFIDENCE=0

    while IFS= read -r event; do
        [[ -z "$event" ]] && continue

        flags=$(jq -r '.hunt_result.anomaly_flags' <<< "$event")

        flag_count=0

        if [[ -n "$flags" ]]; then
            IFS='|' read -ra FLAG_ARRAY <<< "$flags"

            for flag in "${FLAG_ARRAY[@]}"; do
                [[ -n "$flag" ]] && flag_count=$((flag_count + 1))
            done
        fi

        if (( flag_count >= 2 )); then
            HIGH_CONFIDENCE=1
            break
        fi

    done < "$ANOMALOUS_EVENTS"

    if (( HIGH_CONFIDENCE == 1 )); then
        echo "  Status: POSITIVE - HIGH CONFIDENCE"
        echo "  Evidence: PsExec activity deviates from the legitimate"
        echo "            Robert Kim administrator baseline."
        echo "  Recommendation: ESCALATE"
    else
        echo "  Status: POSITIVE - MEDIUM CONFIDENCE"
        echo "  Evidence: PsExec activity was observed outside the"
        echo "            documented administrator baseline."
        echo "  Recommendation: REVIEW AND ESCALATE"
    fi

else

    echo "  Status: NEGATIVE"
    echo "  Evidence: No PsExec events were identified outside"
    echo "            the Robert Kim baseline."
    echo "  Recommendation: Continue monitoring."

fi

echo
echo "================================================================"
echo "   HUNT COMPLETE"
echo "================================================================"
