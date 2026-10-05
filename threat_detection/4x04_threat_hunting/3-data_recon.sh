#!/bin/bash

set -euo pipefail

# ================================================================
# 3-data_recon.sh
#
# Purpose:
#   Profile the complete 14-day MedDefense SIEM export before
#   executing threat-hunting queries.
#
# Data sources:
#   siem_export/wazuh_alerts_14d.json
#   siem_export/wazuh_raw_sysmon_14d.json
#
# Requirements:
#   jq
#   awk
#   sort
#   uniq
#   date
# ================================================================

ALERTS="siem_export/wazuh_alerts_14d.json"
SYSMON="siem_export/wazuh_raw_sysmon_14d.json"

# ----------------------------------------------------------------
# Basic checks
# ----------------------------------------------------------------

if [[ ! -f "$ALERTS" ]]; then
    echo "[ERROR] Missing file: $ALERTS" >&2
    exit 1
fi

if [[ ! -f "$SYSMON" ]]; then
    echo "[ERROR] Missing file: $SYSMON" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq is required but was not found." >&2
    exit 1
fi

# ----------------------------------------------------------------
# Convert either:
#   1. JSON array
#   2. JSON object containing events
#   3. JSON Lines
#
# into one JSON object per line.
# ----------------------------------------------------------------

json_records() {
    local file="$1"

    # First try normal JSON.
    if jq -e empty "$file" >/dev/null 2>&1; then
        jq -c '
            if type == "array" then
                .[]
            elif type == "object" and (.events? | type) == "array" then
                .events[]
            elif type == "object" and (.data? | type) == "array" then
                .data[]
            elif type == "object" then
                .
            else
                empty
            end
        ' "$file"
    else
        # Otherwise treat it as JSON Lines.
        while IFS= read -r line; do
            if [[ -n "$line" ]] && jq -e . >/dev/null 2>&1 <<< "$line"; then
                jq -c . <<< "$line"
            fi
        done < "$file"
    fi
}

# ----------------------------------------------------------------
# Build a temporary combined dataset.
# It is removed automatically when the script exits.
# ----------------------------------------------------------------

TMP_DATA=$(mktemp)

cleanup() {
    rm -f "$TMP_DATA"
}

trap cleanup EXIT

json_records "$ALERTS" >> "$TMP_DATA"
json_records "$SYSMON" >> "$TMP_DATA"

TOTAL_EVENTS=$(wc -l < "$TMP_DATA" | tr -d ' ')

# ----------------------------------------------------------------
# Helper functions for extracting common fields.
# The different fallbacks make the script tolerant of common
# Wazuh/Sysmon JSON structures.
# ----------------------------------------------------------------

get_timestamp() {
    jq -r '
        .timestamp //
        .["@timestamp"] //
        .event.created //
        .event.ingested //
        .data.timestamp //
        .win.system.timeCreated //
        .event_time //
        .time //
        empty
    ' 2>/dev/null
}

get_agent() {
    jq -r '
        .agent.name //
        .agent // 
        .host.name //
        .hostname //
        .host //
        .source_host //
        .src_host //
        empty
    ' 2>/dev/null
}

get_rule_level() {
    jq -r '
        .rule.level //
        .rule_level //
        .severity //
        empty
    ' 2>/dev/null
}

get_event_type() {
    jq -r '
        .rule.description //
        .rule.groups[0] //
        .event.action //
        .event_type //
        .event_type_name //
        .win.system.providerName //
        .data.EventType //
        .sysmon.EventType //
        .event.name //
        empty
    ' 2>/dev/null
}

# ----------------------------------------------------------------
# Extract all timestamps.
# ----------------------------------------------------------------

TMP_TIMESTAMPS=$(mktemp)
trap 'rm -f "$TMP_DATA" "$TMP_TIMESTAMPS"' EXIT

while IFS= read -r record; do
    timestamp=$(printf '%s\n' "$record" | get_timestamp || true)

    if [[ -n "$timestamp" && "$timestamp" != "null" ]]; then
        printf '%s\n' "$timestamp" >> "$TMP_TIMESTAMPS"
    fi
done < "$TMP_DATA"

# ----------------------------------------------------------------
# Determine first and last timestamps.
# ISO timestamps sort correctly lexicographically when normalized.
# ----------------------------------------------------------------

FIRST_TIMESTAMP="N/A"
LAST_TIMESTAMP="N/A"

if [[ -s "$TMP_TIMESTAMPS" ]]; then
    FIRST_TIMESTAMP=$(sort "$TMP_TIMESTAMPS" | head -n 1)
    LAST_TIMESTAMP=$(sort "$TMP_TIMESTAMPS" | tail -n 1)
fi

# ----------------------------------------------------------------
# Calculate duration from timestamps when possible.
# ----------------------------------------------------------------

DURATION="Unable to calculate"

if [[ "$FIRST_TIMESTAMP" != "N/A" && "$LAST_TIMESTAMP" != "N/A" ]]; then

    FIRST_EPOCH=$(date -d "$FIRST_TIMESTAMP" +%s 2>/dev/null || echo "")
    LAST_EPOCH=$(date -d "$LAST_TIMESTAMP" +%s 2>/dev/null || echo "")

    if [[ -n "$FIRST_EPOCH" && -n "$LAST_EPOCH" ]]; then

        DIFF=$((LAST_EPOCH - FIRST_EPOCH))

        if (( DIFF < 0 )); then
            DIFF=$((FIRST_EPOCH - LAST_EPOCH))
        fi

        DAYS=$((DIFF / 86400))
        HOURS=$(((DIFF % 86400) / 3600))
        MINUTES=$(((DIFF % 3600) / 60))

        DURATION="${DAYS} days, ${HOURS} hours, ${MINUTES} minutes"
    fi
fi

# ----------------------------------------------------------------
# Detect format.
# ----------------------------------------------------------------

detect_format() {
    local file="$1"

    if jq -e empty "$file" >/dev/null 2>&1; then
        local type
        type=$(jq -r 'type' "$file")

        if [[ "$type" == "array" ]]; then
            echo "JSON array"
        else
            echo "JSON"
        fi
    else
        echo "JSON Lines"
    fi
}

ALERT_FORMAT=$(detect_format "$ALERTS")
SYSMON_FORMAT=$(detect_format "$SYSMON")

if [[ "$ALERT_FORMAT" == "$SYSMON_FORMAT" ]]; then
    FORMAT="$ALERT_FORMAT"
else
    FORMAT="Mixed: $ALERT_FORMAT + $SYSMON_FORMAT"
fi

# ================================================================
# OUTPUT
# ================================================================

echo
echo "================================================================"
echo "   DATA RECONNAISSANCE - MedDefense SIEM Export"
echo "================================================================"
echo

# ----------------------------------------------------------------
# 1. DATASET METADATA
# ----------------------------------------------------------------

echo "DATASET METADATA:"
printf "  Total events:   %s\n" "$TOTAL_EVENTS"
printf "  Time range:     %s to %s\n" "$FIRST_TIMESTAMP" "$LAST_TIMESTAMP"
printf "  Duration:       %s\n" "$DURATION"
printf "  Format:         %s\n" "$FORMAT"
echo

echo "  Input files:"
echo "    - $ALERTS"
echo "    - $SYSMON"
echo

# ----------------------------------------------------------------
# 2. TOP 10 EVENT TYPES
# ----------------------------------------------------------------

echo "TOP 10 EVENT TYPES:"

EVENT_TYPES=$(
    while IFS= read -r record; do
        value=$(printf '%s\n' "$record" | get_event_type || true)

        if [[ -n "$value" && "$value" != "null" ]]; then
            printf '%s\n' "$value"
        fi
    done < "$TMP_DATA"
)

if [[ -n "$EVENT_TYPES" ]]; then
    printf '%s\n' "$EVENT_TYPES" |
        sort |
        uniq -c |
        sort -nr |
        head -n 10 |
        awk '{
            count=$1
            $1=""
            sub(/^ /,"")
            printf "  %-6s %s\n", count, $0
        }'
else
    echo "  No event type fields detected."
fi

echo

# ----------------------------------------------------------------
# 3. SOURCE HOST DISTRIBUTION
# ----------------------------------------------------------------

echo "SOURCE HOST DISTRIBUTION:"

HOSTS=$(
    while IFS= read -r record; do
        value=$(printf '%s\n' "$record" | get_agent || true)

        if [[ -n "$value" && "$value" != "null" ]]; then
            printf '%s\n' "$value"
        fi
    done < "$TMP_DATA"
)

if [[ -n "$HOSTS" ]]; then
    printf '%s\n' "$HOSTS" |
        sort |
        uniq -c |
        sort -nr |
        awk '{
            count=$1
            $1=""
            sub(/^ /,"")
            printf "  %-20s %s\n", $0 ":", count
        }'
else
    echo "  No agent/source-host fields detected."
fi

echo

# ----------------------------------------------------------------
# 4. SEVERITY DISTRIBUTION
# ----------------------------------------------------------------

echo "SEVERITY DISTRIBUTION (rule.level):"

SEVERITIES=$(
    while IFS= read -r record; do
        value=$(printf '%s\n' "$record" | get_rule_level || true)

        if [[ -n "$value" && "$value" != "null" ]]; then
            printf '%s\n' "$value"
        fi
    done < "$TMP_DATA"
)

if [[ -n "$SEVERITIES" ]]; then
    printf '%s\n' "$SEVERITIES" |
        sort -n |
        uniq -c |
        awk '{
            printf "  Level %-3s: %s\n", $2, $1
        }'
else
    echo "  No rule.level fields detected."
fi

echo

# ----------------------------------------------------------------
# 5. HOURLY DISTRIBUTION
# ----------------------------------------------------------------

echo "HOURLY DISTRIBUTION:"

declare -a HOUR_COUNTS

for hour in {0..23}; do
    HOUR_COUNTS[$hour]=0
done

while IFS= read -r timestamp; do

    [[ -z "$timestamp" ]] && continue

    hour=$(date -d "$timestamp" "+%H" 2>/dev/null || true)

    if [[ "$hour" =~ ^[0-9]{2}$ ]]; then
        hour_number=$((10#$hour))
        HOUR_COUNTS[$hour_number]=$((HOUR_COUNTS[$hour_number] + 1))
    fi

done < "$TMP_TIMESTAMPS"

for hour in {0..23}; do

    printf -v hour_label "%02d:00" "$hour"

    count=${HOUR_COUNTS[$hour]}

    # Small visual histogram.
    if (( count > 0 )); then
        bars=$((count / 1000))

        if (( bars < 1 )); then
            bars=1
        fi

        histogram=$(printf '%*s' "$bars" '' | tr ' ' '#')
    else
        histogram=""
    fi

    printf "  %s  %-20s %s\n" "$hour_label" "$histogram" "$count"

done

echo
echo "  Note: # represents approximately 1,000 events."
echo

# ----------------------------------------------------------------
# 6. HYPOTHESIS COVERAGE MATRIX
# ----------------------------------------------------------------

echo "HYPOTHESIS COVERAGE MATRIX:"

# Convert each event to one searchable lowercase text string.
# This lets us detect whether relevant evidence exists anywhere
# in the SIEM export.

SEARCH_TEXT=$(
    while IFS= read -r record; do
        printf '%s\n' "$record" |
            tr '[:upper:]' '[:lower:]'
    done < "$TMP_DATA"
)

# H1 - PsExec
H1_COUNT=$(printf '%s\n' "$SEARCH_TEXT" |
    grep -Ei 'psexec|psexesvc' |
    wc -l)

# H2 - LSASS
H2_COUNT=$(printf '%s\n' "$SEARCH_TEXT" |
    grep -Ei 'lsass|lsass\.exe|credential.?dump|credential.?access' |
    wc -l)

# H3 - WMI
H3_COUNT=$(printf '%s\n' "$SEARCH_TEXT" |
    grep -Ei '\bwmi\b|wmic|win32_process|wmiprvse|winmgmt' |
    wc -l)

# H4 - PowerShell Remoting
H4_COUNT=$(printf '%s\n' "$SEARCH_TEXT" |
    grep -Ei 'psremoting|powershell.?remoting|winrm|wsman|enter-pssession|invoke-command' |
    wc -l)

# H5 - Service accounts
H5_COUNT=$(printf '%s\n' "$SEARCH_TEXT" |
    grep -Ei 'svc[_-]|service[_-]|service account|svc_' |
    wc -l)

print_hypothesis() {
    local label="$1"
    local count="$2"

    if (( count > 0 )); then
        printf "  %-20s [OK]       Evidence matches: %s\n" "$label" "$count"
    else
        printf "  %-20s [NO DATA]  No matching evidence found\n" "$label"
    fi
}

print_hypothesis "H1 (PsExec):" "$H1_COUNT"
print_hypothesis "H2 (LSASS):" "$H2_COUNT"
print_hypothesis "H3 (WMI):" "$H3_COUNT"
print_hypothesis "H4 (PSRemoting):" "$H4_COUNT"
print_hypothesis "H5 (Svc Accounts):" "$H5_COUNT"

echo

# ----------------------------------------------------------------
# Explain what the coverage result means.
# ----------------------------------------------------------------

echo "HUNTABILITY SUMMARY:"

if (( H1_COUNT > 0 )); then
    echo "  H1 PsExec:       Testable from available SIEM evidence."
else
    echo "  H1 PsExec:       No direct PsExec evidence found."
fi

if (( H2_COUNT > 0 )); then
    echo "  H2 LSASS:        Testable from available SIEM evidence."
else
    echo "  H2 LSASS:        No direct LSASS evidence found."
fi

if (( H3_COUNT > 0 )); then
    echo "  H3 WMI:          Testable from available SIEM evidence."
else
    echo "  H3 WMI:          No direct WMI evidence found."
fi

if (( H4_COUNT > 0 )); then
    echo "  H4 PSRemoting:   Testable from available SIEM evidence."
else
    echo "  H4 PSRemoting:   No direct PSRemoting evidence found."
fi

if (( H5_COUNT > 0 )); then
    echo "  H5 Svc Accounts: Testable from available SIEM evidence."
else
    echo "  H5 Svc Accounts: No direct service-account evidence found."
fi

echo

# ----------------------------------------------------------------
# Final interpretation
# ----------------------------------------------------------------

echo "RECONNAISSANCE NOTES:"
echo "  - This task profiles the data before threat hunting."
echo "  - [OK] means matching evidence exists in the export."
echo "  - [NO DATA] means the relevant evidence was not found."
echo "  - Absence of evidence does NOT automatically prove absence"
echo "    of the technique."
echo "  - Later hunts should correlate timestamp, host, account,"
echo "    process/tool and target information."
echo

echo "================================================================"
echo "   END OF DATA RECONNAISSANCE"
echo "================================================================"
echo
