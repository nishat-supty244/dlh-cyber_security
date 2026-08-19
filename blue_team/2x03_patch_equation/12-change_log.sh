#!/bin/bash
# ==============================================================================
# Script Name: 12-change_log.sh
# Goal: Produce a canonical, structured change log for all patching activity.
# ==============================================================================

set -euo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

readonly OUTPUT_FILE="${BASE_DIR}/patch_change_log.json"
readonly WINDOW_REPORT="${BASE_DIR}/maintenance_window.json"
readonly EXECUTION_LOG="${BASE_DIR}/patch_execution_log.json"
readonly VULN_INVENTORY="${BASE_DIR}/vulnerability_inventory.json"

log() {
    echo "[*] $*"
}

warn() {
    echo "[!] $*" >&2
}

# ==============================================================================
# PREREQUISITES CHECK
# ==============================================================================
validate_prerequisites() {
    if ! command -v jq &>/dev/null; then
        warn "Error: 'jq' is required but not installed."
        exit 1
    fi
}

# ==============================================================================
# PARSE APT HISTORY LOGS
# ==============================================================================
parse_apt_history() {
    local tmp_dir
    tmp_dir=$(mktemp -d)
    local raw_transactions="${tmp_dir}/transactions.json"

    echo "[]" > "$raw_transactions"

    local log_files=()
    while IFS= read -r -d '' file; do
        log_files+=("$file")
    done < <(find /var/log/apt -name "history.log*" -print0 2>/dev/null | sort -z)

    for log_file in "${log_files[@]}"; do
        local cat_cmd="cat"
        if [[ "$log_file" == *.gz ]]; then
            cat_cmd="zcat"
        fi

        $cat_cmd "$log_file" 2>/dev/null | awk '
            BEGIN {
                start = ""; cmd = ""; user = "unknown"; pkgs = 0;
            }
            /^Start-Date:/ {
                if (start != "") print_record();
                start = substr($0, 13);
                gsub(/^[ \t]+|[ \t]+$/, "", start);
                cmd = ""; user = "unknown"; pkgs = 0;
            }
            /^Commandline:/ {
                cmd = substr($0, 13);
                gsub(/^[ \t]+|[ \t]+$/, "", cmd);
            }
            /^Requested-By:/ {
                user = substr($0, 14);
                gsub(/^[ \t]+|[ \t]+$/, "", user);
                sub(/ \([0-9]+\)$/, "", user);
            }
            /^(Upgrade|Install|Remove):/ {
                line = substr($0, index($0, ":") + 1);
                n = split(line, arr, ",");
                pkgs += n;
            }
            END {
                if (start != "") print_record();
            }
            function print_record() {
                if (start == "") return;
                print start "|" cmd "|" user "|" pkgs;
            }
        ' | while IFS='|' read -r t_start t_cmd t_user t_pkgs; do
            [[ -z "$t_start" ]] && continue
            
            local iso_time
            iso_time=$(date -d "$t_start" --iso-8601=seconds 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$t_start" '+%Y-%m-%dT%H:%M:%S%:z' 2>/dev/null || echo "$t_start")
            local epoch_time
            epoch_time=$(date -d "$t_start" +%s 2>/dev/null || date -j -f "%Y-%m-%d %H:%M:%S" "$t_start" '+%s' 2>/dev/null || echo "0")

            local current_json
            current_json=$(cat "$raw_transactions")
            jq --arg s "$iso_time" \
               --argjson e "$epoch_time" \
               --arg c "$t_cmd" \
               --arg u "$t_user" \
               --argjson p "$t_pkgs" \
               '. + [{start: $s, epoch: $e, command: $c, user: $u, packages: $p}]' \
               <<< "$current_json" > "$raw_transactions"
        done
    done

    cat "$raw_transactions"
    rm -rf "$tmp_dir"
}

# ==============================================================================
# GROUP TRANSACTIONS INTO CHANGE EVENTS (15-minute proximity rule)
# ==============================================================================
group_transactions() {
    local raw_json="$1"
    
    local sorted_json
    sorted_json=$(jq 'sort_by(.epoch)' <<< "$raw_json")

    local count
    count=$(jq length <<< "$sorted_json")

    if [[ "$count" -eq 0 ]]; then
        echo "[]"
        return
    fi

    local events_json="[]"
    local current_group_start=""
    local current_group_epoch=0
    local current_user="unknown"
    local total_pkgs=0

    for ((i=0; i<count; i++)); do
        local item
        item=$(jq --argjson idx "$i" '.[$idx]' <<< "$sorted_json")
        local t_start
        t_start=$(jq -r '.start' <<< "$item")
        local t_epoch
        t_epoch=$(jq -r '.epoch' <<< "$item")
        local t_user
        t_user=$(jq -r '.user' <<< "$item")
        local t_pkgs
        t_pkgs=$(jq -r '.packages' <<< "$item")

        if [[ -z "$current_group_start" ]]; then
            current_group_start="$t_start"
            current_group_epoch="$t_epoch"
            current_user="$t_user"
            total_pkgs="$t_pkgs"
        else
            local diff=$(( t_epoch - current_group_epoch ))
            if [[ "$diff" -le 900 ]]; then
                total_pkgs=$(( total_pkgs + t_pkgs ))
                if [[ "$t_user" != "unknown" ]]; then
                    current_user="$t_user"
                fi
            else
                events_json=$(process_and_append_event "$events_json" "$current_group_start" "$current_user" "$total_pkgs")
                current_group_start="$t_start"
                current_group_epoch="$t_epoch"
                current_user="$t_user"
                total_pkgs="$t_pkgs"
            fi
        fi
    done

    if [[ -n "$current_group_start" ]]; then
        events_json=$(process_and_append_event "$events_json" "$current_group_start" "$current_user" "$total_pkgs")
    fi

    echo "$events_json"
}

# ==============================================================================
# ENRICH SINGLE EVENT
# ==============================================================================
process_and_append_event() {
    local events_array="$1"
    local started="$2"
    local user="$3"
    local packages="$4"

    local within_window="outside"
    if [[ -f "$WINDOW_REPORT" ]]; then
        local decision
        decision=$(jq -r '.decision // "defer"' "$WINDOW_REPORT")
        if [[ "$decision" == "proceed" ]]; then
            within_window="inside"
        fi
    fi

    local linked_log="null"
    if [[ -f "$EXECUTION_LOG" ]]; then
        linked_log="$EXECUTION_LOG"
    fi

    local new_event
    new_event=$(jq -n \
        --arg started "$started" \
        --arg user "$user" \
        --arg within_window "$within_window" \
        --argjson packages "$packages" \
        --arg linked "$linked_log" \
        '{
            started: $started,
            user: $user,
            within_window: $within_window,
            packages: $packages,
            linked_execution_log: (if $linked == "null" then null else $linked end)
        }')

    jq --argjson ev "$new_event" '. + [$ev]' <<< "$events_array"
}

# ==============================================================================
# MAIN GENERATION LOGIC
# ==============================================
generate_changelog() {
    validate_prerequisites
    log "Parsing apt history logs..."
    local raw_logs
    raw_logs=$(parse_apt_history)

    log "Grouping transactions into change events..."
    local events
    events=$(group_transactions "$raw_logs")

    local total_events inside_count outside_count cves_resolved_count=0
    total_events=$(jq length <<< "$events")
    inside_count=$(jq '[.[] | select(.within_window == "inside")] | length' <<< "$events")
    outside_count=$(jq '[.[] | select(.within_window == "outside")] | length' <<< "$events")

    if [[ -f "$VULN_INVENTORY" ]]; then
        cves_resolved_count=$(jq '[.vulnerabilities[]? | select(.resolved == true)] | length' "$VULN_INVENTORY" 2>/dev/null || echo "0")
    fi

    local period_start period_end
    period_start=$(jq -r '.[0].start // "2026-03-21T00:00:00+01:00"' <<< "$events")
    period_end=$(jq -r '.[-1].start // "2026-03-28T23:59:59+01:00"' <<< "$events")

    jq -n \
        --arg start "$period_start" \
        --arg end "$period_end" \
        --argjson events "$events" \
        --argjson total "$total_events" \
        --argjson inside "$inside_count" \
        --argjson outside "$outside_count" \
        --argjson cves "$cves_resolved_count" \
        '{
            period_start: $start,
            period_end: $end,
            events: $events,
            summary: {
                total_events: $total,
                inside_window: $inside,
                outside_window: $outside,
                cves_resolved: $cves
            }
        }' > "$OUTPUT_FILE"

    log "Change log successfully written to $OUTPUT_FILE"
    jq -c '.events[]' "$OUTPUT_FILE"
}

generate_changelog "$@"
