#!/bin/bash

# ============================================================
# Task 3 - Firewall Session Analysis
# Project: 4x05 Attack Reconstruction
# Host: WS-RECV-03
#
# Purpose:
#   Analyze 14 days of firewall session logs to identify:
#   - Total sessions
#   - Internal vs external communication
#   - Top external destinations
#   - Top internal destinations
#   - Unknown external IP activity
#   - Off-hours communication
#   - Large outbound transfers
#   - Possible C2 activity
#   - Possible data exfiltration
#
# Required tools:
#   jq, grep, sort, uniq, wc, date
# ============================================================

set -u

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

FIREWALL_FILE="$PROJECT_DIR/ir_evidence/firewall_sessions_ws_recv_03.json"
IOC_FILE="$PROJECT_DIR/reference/healthbane_ioc_master.json"
NETWORK_FILE="$PROJECT_DIR/previous_findings/4x01_network_timeline.txt"
DISK_REPORT="$PROJECT_DIR/task2_output/disk_analysis_report.txt"

OUTPUT_DIR="$PROJECT_DIR/task3_output"
REPORT="$OUTPUT_DIR/firewall_analysis_report.txt"

mkdir -p "$OUTPUT_DIR"

# Large outbound transfer threshold.
# 5 MB is used as an investigation threshold, not as proof of exfiltration.
LARGE_TRANSFER=$((5 * 1024 * 1024))

# ------------------------------------------------------------
# Check required files
# ------------------------------------------------------------

echo "[+] Checking firewall evidence..."

if [ ! -f "$FIREWALL_FILE" ]; then
    echo "[ERROR] Firewall session file not found:"
    echo "        $FIREWALL_FILE"
    exit 1
fi

if [ ! -f "$IOC_FILE" ]; then
    echo "[WARNING] IOC database not found."
    echo "          IOC correlation will be limited."
fi

if [ ! -f "$NETWORK_FILE" ]; then
    echo "[WARNING] 4x01 network timeline not found."
    echo "          Previous network correlation will be limited."
fi

if [ ! -f "$DISK_REPORT" ]; then
    echo "[WARNING] Task 2 disk analysis report not found."
    echo "          Staging-size correlation will be limited."
fi

echo

# ------------------------------------------------------------
# Validate JSON
# ------------------------------------------------------------

echo "[+] Validating firewall JSON..."

if ! jq empty "$FIREWALL_FILE" >/dev/null 2>&1; then
    echo "[ERROR] Firewall file is not valid JSON."
    exit 1
fi

echo "[+] JSON is valid."
echo

# ------------------------------------------------------------
# Discover JSON structure
# ------------------------------------------------------------

echo "[+] Inspecting JSON structure..."

{
    echo "================================================================"
    echo "   FIREWALL SESSION ANALYSIS - WS-RECV-03"
    echo "   Source: ir_evidence/firewall_sessions_ws_recv_03.json"
    echo "   Analysis Date: $(date)"
    echo "================================================================"
    echo
    echo "JSON structure preview:"
    jq -r 'if type == "array" then "Root type: array" elif type == "object" then "Root type: object" else "Root type: " + type end' \
        "$FIREWALL_FILE"
    echo
} > "$REPORT"

# ------------------------------------------------------------
# Detect where sessions are stored.
#
# Common possibilities:
#   JSON root = array
#   {"sessions":[...]}
# ------------------------------------------------------------

ROOT_TYPE=$(jq -r 'type' "$FIREWALL_FILE")

if [ "$ROOT_TYPE" = "array" ]; then
    SESSION_FILTER='.[]'
elif jq -e '.sessions and (.sessions | type == "array")' "$FIREWALL_FILE" >/dev/null 2>&1; then
    SESSION_FILTER='.sessions[]'
else
    echo "[ERROR] Could not identify a session array in the JSON."
    echo "        Expected either a root array or an object containing .sessions[]"
    exit 1
fi

# ------------------------------------------------------------
# Helper function:
# Extract a field from each session while supporting common
# field-name variations.
# ------------------------------------------------------------

get_field() {
    local field="$1"

    case "$field" in

        src_ip)
            jq -r "$SESSION_FILTER |
                (.src_ip // .source_ip // .src // .local_ip // .client_ip // \"\")"
            ;;

        dst_ip)
            jq -r "$SESSION_FILTER |
                (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\")"
            ;;

        port)
            jq -r "$SESSION_FILTER |
                (.dst_port // .destination_port // .port // .remote_port // \"\")"
            ;;

        protocol)
            jq -r "$SESSION_FILTER |
                (.protocol // .proto // \"\")"
            ;;

        bytes_out)
            jq -r "$SESSION_FILTER |
                (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0)"
            ;;

        bytes_in)
            jq -r "$SESSION_FILTER |
                (.bytes_in // .in_bytes // .bytes_received // .received_bytes // 0)"
            ;;

        timestamp)
            jq -r "$SESSION_FILTER |
                (.timestamp // .start_time // .start // .datetime // .time // \"\")"
            ;;

        *)
            echo ""
            ;;
    esac
}

# ------------------------------------------------------------
# 1. SESSION OVERVIEW
# ------------------------------------------------------------

echo "[+] Calculating total session count..."

TOTAL_SESSIONS=$(jq "$SESSION_FILTER" "$FIREWALL_FILE" | wc -l)

{
    echo "================================================================"
    echo "1. SESSION OVERVIEW"
    echo "================================================================"
    echo
    echo "Total sessions: $TOTAL_SESSIONS"
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 2. INTERNAL / EXTERNAL BREAKDOWN
# ------------------------------------------------------------

echo "[+] Calculating internal/external traffic..."

INTERNAL_SESSIONS=0
EXTERNAL_SESSIONS=0
INTERNAL_BYTES=0
EXTERNAL_BYTES=0

while IFS='|' read -r IP BYTES; do

    if [ -z "$IP" ]; then
        continue
    fi

    # Internal MedDefense network is represented by 10.0.0.0/8.
    if [[ "$IP" =~ ^10\. ]]; then

        INTERNAL_SESSIONS=$((INTERNAL_SESSIONS + 1))

        if [[ "$BYTES" =~ ^[0-9]+$ ]]; then
            INTERNAL_BYTES=$((INTERNAL_BYTES + BYTES))
        fi

    else

        EXTERNAL_SESSIONS=$((EXTERNAL_SESSIONS + 1))

        if [[ "$BYTES" =~ ^[0-9]+$ ]]; then
            EXTERNAL_BYTES=$((EXTERNAL_BYTES + BYTES))
        fi

    fi

done < <(
    jq -r "$SESSION_FILTER |
        [
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\"),
            (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0)
        ] | @tsv" "$FIREWALL_FILE" |
    tr '\t' '|'
)

# ------------------------------------------------------------
# Convert bytes to MB for easier reading.
# ------------------------------------------------------------

INTERNAL_MB=$(awk "BEGIN {printf \"%.2f\", $INTERNAL_BYTES / 1024 / 1024}")
EXTERNAL_MB=$(awk "BEGIN {printf \"%.2f\", $EXTERNAL_BYTES / 1024 / 1024}")

{
    echo "Internal sessions: $INTERNAL_SESSIONS"
    echo "Internal outbound bytes: $INTERNAL_BYTES ($INTERNAL_MB MB)"
    echo
    echo "External sessions: $EXTERNAL_SESSIONS"
    echo "External outbound bytes: $EXTERNAL_BYTES ($EXTERNAL_MB MB)"
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 3. TOP 10 EXTERNAL DESTINATIONS
# ------------------------------------------------------------

echo "[+] Finding top external destinations..."

{
    echo "================================================================"
    echo "2. TOP 10 EXTERNAL DESTINATIONS BY BYTES OUT"
    echo "================================================================"
    echo
    printf "%-5s %-18s %-8s %-8s %-10s %-15s %-15s\n" \
        "Rank" "IP" "Port" "Proto" "Sessions" "Bytes Out" "Bytes In"
    echo
} >> "$REPORT"

TEMP_EXTERNAL="$OUTPUT_DIR/.external_sessions.tmp"

jq -r "$SESSION_FILTER |
    [
        (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\"),
        (.dst_port // .destination_port // .port // .remote_port // \"\"),
        (.protocol // .proto // \"\"),
        (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0),
        (.bytes_in // .in_bytes // .bytes_received // .received_bytes // 0)
    ] | @tsv" "$FIREWALL_FILE" |
while IFS=$'\t' read -r IP PORT PROTO OUT IN; do

    if [[ ! "$IP" =~ ^10\. ]]; then
        printf "%s\t%s\t%s\t%s\t%s\n" "$IP" "$PORT" "$PROTO" "$OUT" "$IN"
    fi

done > "$TEMP_EXTERNAL"

# Aggregate by IP.
sort "$TEMP_EXTERNAL" |
awk -F'\t' '
{
    sessions[$1]++
    bytesout[$1] += $4
    bytesin[$1] += $5
    ports[$1] = $2
    proto[$1] = $3
}
END {
    for (ip in sessions)
        printf "%s\t%s\t%s\t%d\t%d\t%d\n",
        ip, ports[ip], proto[ip], sessions[ip], bytesout[ip], bytesin[ip]
}' |
sort -t$'\t' -k5,5nr |
head -10 |
awk -F'\t' '{
    printf "%-5d %-18s %-8s %-8s %-10d %-15d %-15d\n",
    NR, $1, $2, $3, $4, $5, $6
}' >> "$REPORT"

echo >> "$REPORT"

# ------------------------------------------------------------
# 4. TOP 10 INTERNAL DESTINATIONS
# ------------------------------------------------------------

echo "[+] Finding top internal destinations..."

{
    echo "================================================================"
    echo "3. TOP 10 INTERNAL DESTINATIONS BY SESSION COUNT"
    echo "================================================================"
    echo
    printf "%-5s %-18s %-12s %-15s\n" \
        "Rank" "IP" "Sessions" "Bytes Out"
    echo
} >> "$REPORT"

jq -r "$SESSION_FILTER |
    [
        (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\"),
        (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0)
    ] | @tsv" "$FIREWALL_FILE" |
while IFS=$'\t' read -r IP OUT; do

    if [[ "$IP" =~ ^10\. ]]; then
        printf "%s\t%s\n" "$IP" "$OUT"
    fi

done |
awk -F'\t' '
{
    sessions[$1]++
    bytes[$1] += $2
}
END {
    for (ip in sessions)
        printf "%s\t%d\t%d\n", ip, sessions[ip], bytes[ip]
}' |
sort -t$'\t' -k2,2nr |
head -10 |
awk -F'\t' '{
    printf "%-5d %-18s %-12d %-15d\n",
    NR, $1, $2, $3
}' >> "$REPORT"

echo >> "$REPORT"

# ------------------------------------------------------------
# 5. IDENTIFY UNKNOWN IP
# ------------------------------------------------------------

echo "[+] Investigating external IPs..."

{
    echo "================================================================"
    echo "4. EXTERNAL IP INVESTIGATION"
    echo "================================================================"
    echo
} >> "$REPORT"

# Extract external IPs and check whether they appear in IOC DB.
EXTERNAL_IPS=$(get_field dst_ip |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' |
    grep -v '^10\.' |
    sort -u)

while IFS= read -r IP; do

    [ -z "$IP" ] && continue

    COUNT=$(get_field dst_ip | grep -Fx "$IP" | wc -l)

    OUT_BYTES=$(jq -r "$SESSION_FILTER |
        select(
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\") == \"$IP\"
        ) |
        (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0)" \
        "$FIREWALL_FILE" |
        awk '{sum += $1} END {print sum+0}')

    IN_BYTES=$(jq -r "$SESSION_FILTER |
        select(
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\") == \"$IP\"
        ) |
        (.bytes_in // .in_bytes // .bytes_received // .received_bytes // 0)" \
        "$FIREWALL_FILE" |
        awk '{sum += $1} END {print sum+0}')

    FIRST_TIME=$(jq -r "$SESSION_FILTER |
        select(
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\") == \"$IP\"
        ) |
        (.timestamp // .start_time // .start // .datetime // .time // \"\")" \
        "$FIREWALL_FILE" |
        sort |
        head -1)

    LAST_TIME=$(jq -r "$SESSION_FILTER |
        select(
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\") == \"$IP\"
        ) |
        (.timestamp // .start_time // .start // .datetime // .time // \"\")" \
        "$FIREWALL_FILE" |
        sort |
        tail -1)

    PORTS=$(jq -r "$SESSION_FILTER |
        select(
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\") == \"$IP\"
        ) |
        (.dst_port // .destination_port // .port // .remote_port // \"\")" \
        "$FIREWALL_FILE" |
        sort -n |
        uniq |
        tr '\n' ' ')

    PROTOCOLS=$(jq -r "$SESSION_FILTER |
        select(
            (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\") == \"$IP\"
        ) |
        (.protocol // .proto // \"\")" \
        "$FIREWALL_FILE" |
        sort -u |
        tr '\n' ' ')

    if [ -f "$IOC_FILE" ] && grep -Fqi "$IP" "$IOC_FILE"; then
        STATUS="KNOWN IOC"
    else
        STATUS="NEW / NOT IN IOC DB"
    fi

    {
        echo "IP: $IP"
        echo "  Status: $STATUS"
        echo "  Sessions: $COUNT"
        echo "  First seen: $FIRST_TIME"
        echo "  Last seen: $LAST_TIME"
        echo "  Ports: $PORTS"
        echo "  Protocols: $PROTOCOLS"
        echo "  Bytes out: $OUT_BYTES"
        echo "  Bytes in: $IN_BYTES"
        echo
    } >> "$REPORT"

done <<< "$EXTERNAL_IPS"

# ------------------------------------------------------------
# 6. UNKNOWN IP / POSSIBLE SECONDARY C2
# ------------------------------------------------------------

{
    echo "================================================================"
    echo "5. UNKNOWN IP / POSSIBLE SECONDARY C2 ANALYSIS"
    echo "================================================================"
    echo
    echo "IPs marked 'NEW / NOT IN IOC DB' above require investigation."
    echo
    echo "Indicators that would support a secondary C2 hypothesis:"
    echo "  - Repeated connections"
    echo "  - Fixed or regular communication intervals"
    echo "  - Off-hours activity"
    echo "  - Same destination port/protocol"
    echo "  - Communication beginning around persistence creation"
    echo "  - Similar behavior to known HEALTHBANE C2"
    echo
    echo "Important:"
    echo "  A NEW IP is not automatically malicious."
    echo "  C2 classification requires correlation with other evidence."
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 7. OFF-HOURS ANALYSIS
# ------------------------------------------------------------

echo "[+] Analyzing off-hours communication..."

{
    echo "================================================================"
    echo "6. TEMPORAL / OFF-HOURS ANALYSIS"
    echo "================================================================"
    echo
    echo "Off-hours definition: 18:00-08:00"
    echo
} >> "$REPORT"

OFF_HOURS_FILE="$OUTPUT_DIR/.offhours.tmp"

jq -r "$SESSION_FILTER |
    [
        (.timestamp // .start_time // .start // .datetime // .time // \"\"),
        (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\"),
        (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0)
    ] | @tsv" "$FIREWALL_FILE" |
while IFS=$'\t' read -r TIME IP OUT; do

    # Extract hour from common timestamp formats.
    HOUR=$(echo "$TIME" | grep -Eo '([01][0-9]|2[0-3]):[0-5][0-9]' | head -1 | cut -d: -f1)

    if [ -n "$HOUR" ]; then

        HOUR_NUM=$((10#$HOUR))

        if [ "$HOUR_NUM" -ge 18 ] || [ "$HOUR_NUM" -lt 8 ]; then
            echo -e "$HOUR\t$IP\t$OUT"
        fi

    fi

done > "$OFF_HOURS_FILE"

OFF_HOURS_COUNT=$(wc -l < "$OFF_HOURS_FILE")

OFF_HOURS_EXTERNAL=$(grep -v $'\t10\.' "$OFF_HOURS_FILE" | wc -l)

{
    echo "Total off-hours sessions: $OFF_HOURS_COUNT"
    echo "Off-hours external sessions: $OFF_HOURS_EXTERNAL"
    echo
    echo "Sessions by hour:"
    echo
} >> "$REPORT"

cut -f1 "$OFF_HOURS_FILE" |
sort |
uniq -c |
sort -k2n >> "$REPORT"

echo >> "$REPORT"

# ------------------------------------------------------------
# 8. LARGE OUTBOUND TRANSFERS
# ------------------------------------------------------------

echo "[+] Searching for large outbound transfers..."

{
    echo "================================================================"
    echo "7. LARGE OUTBOUND TRANSFERS"
    echo "================================================================"
    echo
    echo "Investigation threshold: 5 MB per session"
    echo
} >> "$REPORT"

LARGE_TRANSFERS=$(jq -r "$SESSION_FILTER |
    [
        (.timestamp // .start_time // .start // .datetime // .time // \"\"),
        (.dst_ip // .dest_ip // .destination_ip // .dst // .destination // .remote_ip // \"\"),
        (.dst_port // .destination_port // .port // .remote_port // \"\"),
        (.protocol // .proto // \"\"),
        (.bytes_out // .out_bytes // .bytes_sent // .sent_bytes // 0),
        (.bytes_in // .in_bytes // .bytes_received // .received_bytes // 0)
    ] | @tsv" "$FIREWALL_FILE" |
while IFS=$'\t' read -r TIME IP PORT PROTO OUT IN; do

    if [[ "$OUT" =~ ^[0-9]+$ ]] && [ "$OUT" -ge "$LARGE_TRANSFER" ]; then
        echo -e "$TIME\t$IP\t$PORT\t$PROTO\t$OUT\t$IN"
    fi

done)

if [ -n "$LARGE_TRANSFERS" ]; then
    echo -e "Time\tDestination\tPort\tProtocol\tBytes Out\tBytes In" >> "$REPORT"
    echo "$LARGE_TRANSFERS" >> "$REPORT"
else
    echo "No individual session exceeded the 5 MB threshold." >> "$REPORT"
fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 9. TOTAL OUTBOUND TO EXTERNAL DESTINATIONS
# ------------------------------------------------------------

echo "[+] Calculating external outbound volume..."

{
    echo "================================================================"
    echo "8. EXTERNAL OUTBOUND VOLUME"
    echo "================================================================"
    echo
    echo "Total outbound bytes to all external destinations:"
    echo "$EXTERNAL_BYTES bytes ($EXTERNAL_MB MB)"
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 10. CORRELATE WITH IOC DATABASE
# ------------------------------------------------------------

echo "[+] Comparing external destinations with IOC database..."

{
    echo "================================================================"
    echo "9. HEALTHBANE IOC CORRELATION"
    echo "================================================================"
    echo
} >> "$REPORT"

if [ -f "$IOC_FILE" ]; then

    IOC_MATCHES=0

    while IFS= read -r IP; do

        [ -z "$IP" ] && continue

        if grep -Fqi "$IP" "$IOC_FILE"; then
            IOC_MATCHES=$((IOC_MATCHES + 1))
            echo "[KNOWN IOC] $IP" >> "$REPORT"
        fi

    done <<< "$EXTERNAL_IPS"

    if [ "$IOC_MATCHES" -eq 0 ]; then
        echo "No external destination IPs directly matched the IOC database." >> "$REPORT"
    fi

else

    echo "IOC database unavailable." >> "$REPORT"

fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 11. 4x01 CORRELATION
# ------------------------------------------------------------

echo "[+] Correlating with 4x01 network findings..."

{
    echo "================================================================"
    echo "10. CORRELATION WITH 4x01 NETWORK TIMELINE"
    echo "================================================================"
    echo
} >> "$REPORT"

if [ -f "$NETWORK_FILE" ]; then

    grep -Ein \
        'C2|command.?and.?control|exfil|external|IP|443|8443|DNS|beacon|interval|bytes' \
        "$NETWORK_FILE" \
        >> "$REPORT" 2>/dev/null || \
        echo "No matching 4x01 network indicators found."

else

    echo "4x01 network timeline unavailable." >> "$REPORT"

fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 12. STAGING SIZE FROM TASK 2
# ------------------------------------------------------------

echo "[+] Looking for staging sizes from Task 2..."

{
    echo "================================================================"
    echo "11. STAGING / EXFILTRATION CORRELATION"
    echo "================================================================"
    echo
} >> "$REPORT"

if [ -f "$DISK_REPORT" ]; then

    grep -Ein \
        'staging|query.?results|\.zip|\.csv|MB|bytes|patient|archive' \
        "$DISK_REPORT" \
        >> "$REPORT" 2>/dev/null || \
        echo "No staging-size information found in Task 2 report."

else

    echo "Task 2 report unavailable." >> "$REPORT"

fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 13. EXFILTRATION ASSESSMENT
# ------------------------------------------------------------

{
    echo "================================================================"
    echo "12. EXFILTRATION ASSESSMENT"
    echo "================================================================"
    echo
    echo "Total external outbound traffic:"
    echo "  $EXTERNAL_BYTES bytes ($EXTERNAL_MB MB)"
    echo
    echo "Largest suspicious transfers should be compared with:"
    echo "  - Recovered staging file sizes"
    echo "  - Creation/deletion timestamps"
    echo "  - Destination IP"
    echo "  - Destination port"
    echo "  - Known HEALTHBANE C2"
    echo "  - Unknown IP activity"
    echo
    echo "IMPORTANT:"
    echo "  Firewall bytes show that data moved."
    echo "  They do NOT identify the exact contents of the data."
    echo
    echo "Therefore:"
    echo "  Large outbound traffic alone does not prove patient-data exfiltration."
    echo "  Strong exfiltration evidence requires temporal and destination"
    echo "  correlation with the staged data identified in Task 2."
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 14. FINAL INVESTIGATION QUESTIONS
# ------------------------------------------------------------

{
    echo "================================================================"
    echo "13. QUESTIONS TO ANSWER IN FINAL RECONSTRUCTION"
    echo "================================================================"
    echo
    echo "1. Which external IPs did WS-RECV-03 communicate with?"
    echo
    echo "2. Which external destination transferred the most bytes?"
    echo
    echo "3. What is the unknown IP identified by James Chen?"
    echo
    echo "4. Is the unknown IP present in the HEALTHBANE IOC database?"
    echo
    echo "5. Does the unknown IP communicate at regular intervals?"
    echo
    echo "6. Does the unknown IP communicate primarily during off-hours?"
    echo
    echo "7. Does its behavior resemble the known HEALTHBANE C2?"
    echo
    echo "8. Did large outbound transfers occur after the staging files"
    echo "   were created?"
    echo
    echo "9. Do outbound transfer volumes correspond to the staged file sizes?"
    echo
    echo "10. Is there sufficient evidence to say data was actually exfiltrated?"
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 15. LIMITATIONS
# ------------------------------------------------------------

{
    echo "================================================================"
    echo "14. ANALYSIS LIMITATIONS"
    echo "================================================================"
    echo
    echo "- Firewall sessions provide metadata, not packet contents."
    echo "- Bytes transferred do not identify the data contents."
    echo "- A NEW IP is not automatically malicious."
    echo "- Repeated connections do not automatically prove C2."
    echo "- Large outbound traffic does not automatically prove exfiltration."
    echo "- Exfiltration conclusions must be correlated with disk evidence,"
    echo "  memory evidence and previous network findings."
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

{
    echo "================================================================"
    echo "END OF FIREWALL SESSION ANALYSIS"
    echo "================================================================"
} >> "$REPORT"

rm -f "$TEMP_EXTERNAL" "$OFF_HOURS_FILE"

echo
echo "[+] Firewall analysis completed."
echo "[+] Report created:"
echo "    $REPORT"
echo
echo "[+] Preview:"
echo

head -120 "$REPORT"
