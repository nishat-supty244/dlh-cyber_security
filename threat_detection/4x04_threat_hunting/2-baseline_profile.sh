#!/bin/bash

set -euo pipefail

# ================================================================
# TASK 2 - BASELINE PROFILE
# Robert Kim - IT Administrator
# ================================================================

BASELINE="baseline/robert_kim_activity.json"
SCHEDULE="reference/admin_schedule.txt"

# ------------------------------------------------
# Check required files
# ------------------------------------------------

if [[ ! -f "$BASELINE" ]]; then
    echo "[ERROR] Missing file: $BASELINE" >&2
    exit 1
fi

if [[ ! -f "$SCHEDULE" ]]; then
    echo "[ERROR] Missing file: $SCHEDULE" >&2
    exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "[ERROR] jq is required but was not found." >&2
    exit 1
fi

# Make sure the JSON is valid.
if ! jq empty "$BASELINE" >/dev/null 2>&1; then
    echo "[ERROR] Invalid JSON: $BASELINE" >&2
    exit 1
fi

# ------------------------------------------------
# Helper:
# Convert different possible JSON layouts into
# one stream of event objects.
# ------------------------------------------------

events() {
    jq -c '
        if type == "array" then
            .[]
        elif type == "object" and (.events? | type) == "array" then
            .events[]
        elif type == "object" and (.data? | type) == "array" then
            .data[]
        else
            empty
        end
    ' "$BASELINE"
}

# ------------------------------------------------
# Header
# ------------------------------------------------

echo
echo "================================================================"
echo "   BASELINE PROFILE - Robert Kim (IT Administrator)"
echo "   Source: $BASELINE"
echo "================================================================"
echo

# ------------------------------------------------
# 1. TOOL USAGE SUMMARY
# ------------------------------------------------

echo "TOOL USAGE SUMMARY:"

psexec_count=$(
    events |
    jq -r '
        (.tool // .command // .process // .event_type // "") |
        tostring |
        select(test("psexec"; "i"))
    ' |
    wc -l
)

wmi_count=$(
    events |
    jq -r '
        (.tool // .command // .process // .event_type // "") |
        tostring |
        select(test("wmi"; "i"))
    ' |
    wc -l
)

psremote_count=$(
    events |
    jq -r '
        (.tool // .command // .process // .event_type // "") |
        tostring |
        select(test("powershell.?remoting|psremoting|winrm"; "i"))
    ' |
    wc -l
)

total_events=$(
    events | wc -l
)

printf "  PsExec events:          %s\n" "$psexec_count"
printf "  WMI events:             %s\n" "$wmi_count"
printf "  PSRemoting events:      %s\n" "$psremote_count"
printf "  Total admin events:     %s\n" "$total_events"

echo

# ------------------------------------------------
# 2. SOURCE HOST ANALYSIS
# ------------------------------------------------

echo "SOURCE HOST ANALYSIS:"

events |
jq -r '
    (.source_host // .src_host // .source // .src // .hostname // "") |
    tostring
' |
sort |
uniq -c |
sort -k1,1nr |
while read -r count host; do
    [[ -z "$host" ]] && continue
    printf "  %-20s %s\n" "$host:" "$count"
done

other_hosts=$(
    events |
    jq -r '
        (.source_host // .src_host // .source // .src // .hostname // "") |
        tostring
    ' |
    awk '$0 != "" && $0 != "WS-ADMIN-01"' |
    wc -l
)

echo "  Other hosts: $other_hosts"

if [[ "$other_hosts" -eq 0 ]]; then
    echo "  -> BASELINE: All admin activity originates from WS-ADMIN-01"
else
    echo "  -> WARNING: Baseline contains activity from other hosts"
fi

echo

# ------------------------------------------------
# 3. TIME-OF-DAY DISTRIBUTION
# ------------------------------------------------

echo "TIME DISTRIBUTION:"

business_hours=$(
    events |
    jq -r '
        (.timestamp // .time // .datetime // .event_time // "") |
        tostring |
        capture("(?<hour>[0-9]{2}):[0-9]{2}") |
        .hour
    ' 2>/dev/null |
    awk '$1 >= 8 && $1 < 18' |
    wc -l
)

off_hours=$(
    events |
    jq -r '
        (.timestamp // .time // .datetime // .event_time // "") |
        tostring |
        capture("(?<hour>[0-9]{2}):[0-9]{2}") |
        .hour
    ' 2>/dev/null |
    awk '$1 < 8 || $1 >= 18' |
    wc -l
)

printf "  08:00-18:00: %s\n" "$business_hours"
printf "  18:00-08:00: %s\n" "$off_hours"

if [[ "$off_hours" -eq 0 ]]; then
    echo "  -> BASELINE: Zero admin activity outside business hours"
else
    echo "  -> WARNING: Baseline contains off-hours activity"
fi

echo

# ------------------------------------------------
# 4. DAY-OF-WEEK DISTRIBUTION
# ------------------------------------------------

echo "DAY-OF-WEEK DISTRIBUTION:"

events |
jq -r '
    (.timestamp // .time // .datetime // .event_time // "") |
    tostring
' |
while read -r timestamp; do
    [[ -z "$timestamp" ]] && continue

    # GNU date is used to determine the weekday.
    if date -d "$timestamp" "+%A" 2>/dev/null; then
        :
    fi
done |
sort |
uniq -c |
sort -k1,1nr |
while read -r count day; do
    printf "  %-12s %s\n" "$day:" "$count"
done

echo

# ------------------------------------------------
# 5. TARGET HOST ANALYSIS
# ------------------------------------------------

echo "TARGET HOST ANALYSIS:"

events |
jq -r '
    (.target_host // .dst_host // .target // .destination // .dest // "") |
    tostring
' |
sort |
uniq -c |
sort -k1,1nr |
while read -r count host; do
    [[ -z "$host" ]] && continue
    printf "  %-25s %s\n" "$host:" "$count"
done

echo

# ------------------------------------------------
# 6. USER ACCOUNT ANALYSIS
# ------------------------------------------------

echo "USER ACCOUNT ANALYSIS:"

events |
jq -r '
    (.user // .username // .account // .user_account // .principal // "") |
    tostring
' |
sort |
uniq -c |
sort -k1,1nr |
while read -r count account; do
    [[ -z "$account" ]] && continue
    printf "  %-30s %s\n" "$account:" "$count"
done

service_accounts=$(
    events |
    jq -r '
        (.user // .username // .account // .user_account // .principal // "") |
        tostring
    ' |
    grep -Ei '^(svc_|service_|.*\\svc_|.*\\service_)' |
    wc -l
)

echo "  Service account events: $service_accounts"

if [[ "$service_accounts" -eq 0 ]]; then
    echo "  -> BASELINE: Never uses service accounts interactively"
else
    echo "  -> WARNING: Service-account activity exists in baseline"
fi

echo

# ------------------------------------------------
# 7. ADMIN SCHEDULE REFERENCE
# ------------------------------------------------

echo "AUTHORIZED MAINTENANCE SCHEDULE:"
echo "  Source: $SCHEDULE"

sed 's/^/  /' "$SCHEDULE"

echo

# ------------------------------------------------
# 8. BASELINE SUMMARY
# ------------------------------------------------

echo "BASELINE SUMMARY:"

echo "  Normal source host:"
echo "    WS-ADMIN-01"

echo "  Normal time window:"
echo "    08:00-18:00"

echo "  Normal administrator account:"
echo "    MEDDEFENSE\robert.kim"

echo "  Normal administrative tools:"
echo "    PsExec"
echo "    WMI"
echo "    PowerShell Remoting"

echo "  Normal target hosts:"
events |
jq -r '
    (.target_host // .dst_host // .target // .destination // .dest // "") |
    tostring
' |
sort -u |
while read -r host; do
    [[ -z "$host" ]] && continue
    echo "    - $host"
done

echo

# ------------------------------------------------
# 9. ANOMALY DETECTION CRITERIA
# ------------------------------------------------

echo "ANOMALY DETECTION CRITERIA:"

echo "  [!] Admin tool from any host other than WS-ADMIN-01"
echo "  [!] Admin tool usage outside business hours (08:00-18:00)"
echo "  [!] Service account used interactively from a workstation"
echo "  [!] WMI targeting unusual hosts"
echo "  [!] PsExec targeting an unusual server"
echo "  [!] PowerShell Remoting from an unusual source"
echo "  [!] Robert Kim account authenticating from an unusual host"
echo "  [!] Administrative activity outside the authorized maintenance schedule"
echo

# ------------------------------------------------
# 10. FALSE-POSITIVE FILTER
# ------------------------------------------------

echo "FALSE-POSITIVE FILTER FOR FUTURE HUNTS:"

echo "  A tool should NOT automatically be considered malicious."

echo "  Treat activity as baseline when it matches:"
echo "    - Source host: WS-ADMIN-01"
echo "    - User: MEDDEFENSE\robert.kim"
echo "    - Time: 08:00-18:00"
echo "    - Tool: approved administrative tool"
echo "    - Target: authorized maintenance target"
echo "    - Schedule: documented maintenance window"

echo

echo "  Activity becomes suspicious when it deviates from multiple"
echo "  baseline characteristics, especially source + account + time"
echo "  + target context."

echo

# ------------------------------------------------
# End
# ------------------------------------------------

echo "================================================================"
echo "   END OF BASELINE PROFILE"
echo "================================================================"
echo
