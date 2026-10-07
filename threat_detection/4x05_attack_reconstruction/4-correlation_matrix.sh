#!/bin/bash
#
# 4-correlation_matrix.sh
#
# Purpose:
#   Cross-reference evidence from T0-T3, previous findings,
#   and IR evidence to build:
#     1. IOC correlation matrix
#     2. Timeline correlation matrix
#     3. ATT&CK technique correlation matrix
#     4. Contradiction and evidence-gap summary
#
# Project:
#   4x05 Attack Reconstruction
#
# Requirements:
#   jq, grep, sort, uniq, wc, date, awk, cut, tr
#
# Run from:
#   threat_detection/4x05_attack_reconstruction/
#

set -uo pipefail

# ================================================================
# CONFIGURATION
# ================================================================

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

IR_DIR="$BASE_DIR/ir_evidence"
PREV_DIR="$BASE_DIR/previous_findings"
REF_DIR="$BASE_DIR/reference"

OUTPUT_DIR="$BASE_DIR/task4_output"
REPORT="$OUTPUT_DIR/correlation_matrix_report.txt"

mkdir -p "$OUTPUT_DIR"

# ================================================================
# HELPER FUNCTIONS
# ================================================================

section() {
    echo
    echo "================================================================"
    echo "   $1"
    echo "================================================================"
}

subsection() {
    echo
    echo "----------------------------------------------------------------"
    echo " $1"
    echo "----------------------------------------------------------------"
}

file_exists() {
    [[ -f "$1" ]]
}

# Print file contents safely
print_file_if_exists() {
    local file="$1"

    if [[ -f "$file" ]]; then
        cat "$file"
    else
        echo "[MISSING] $file"
    fi
}

# ================================================================
# START REPORT
# ================================================================

{
echo "================================================================"
echo "   CROSS-EVIDENCE CORRELATION MATRIX"
echo "================================================================"
echo
echo "Project: 4x05 Attack Reconstruction"
echo "Generated: $(date)"
echo
echo "Purpose:"
echo "Correlate findings from previous analysis, IR memory, disk,"
echo "firewall, and other available evidence sources."
echo
echo "Important:"
echo "This report only uses evidence actually present in the files."
echo "Example values from the task instructions are NOT treated as"
echo "actual findings."
echo
} > "$REPORT"

# ================================================================
# 1. DISCOVER AVAILABLE EVIDENCE
# ================================================================

{
section "EVIDENCE INVENTORY"

echo
echo "Previous findings:"
if [[ -d "$PREV_DIR" ]]; then
    find "$PREV_DIR" -type f -maxdepth 1 -print | sort
else
    echo "[MISSING] $PREV_DIR"
fi

echo
echo "IR evidence:"
if [[ -d "$IR_DIR" ]]; then
    find "$IR_DIR" -type f -maxdepth 1 -print | sort
else
    echo "[MISSING] $IR_DIR"
fi

echo
echo "Task outputs:"
for dir in \
    "$BASE_DIR/task0_output" \
    "$BASE_DIR/task1_output" \
    "$BASE_DIR/task2_output" \
    "$BASE_DIR/task3_output"
do
    if [[ -d "$dir" ]]; then
        echo
        echo "[$dir]"
        find "$dir" -type f -maxdepth 1 -print | sort
    fi
done

} >> "$REPORT"

# ================================================================
# 2. BUILD SOURCE LIST
# ================================================================

# We collect the files that actually exist.
# This prevents the script from treating missing files as evidence.

SOURCE_FILES=()

for file in \
    "$PREV_DIR/4x00_phishing_summary.txt" \
    "$PREV_DIR/4x01_network_timeline.txt" \
    "$PREV_DIR/4x02_attack_mapping.json" \
    "$PREV_DIR/4x03_malware_summary.txt" \
    "$PREV_DIR/4x04_hunting_report.txt" \
    "$IR_DIR/memory_artifacts.txt" \
    "$IR_DIR/disk_forensics_report.txt" \
    "$IR_DIR/firewall_sessions_ws_recv_03.json" \
    "$IR_DIR/ir_team_notes.txt" \
    "$BASE_DIR/task0_output/evidence_inventory_report.txt" \
    "$BASE_DIR/task1_output/memory_analysis_report.txt" \
    "$BASE_DIR/task2_output/disk_analysis_report.txt" \
    "$BASE_DIR/task3_output/firewall_analysis_report.txt"
do
    if [[ -f "$file" ]]; then
        SOURCE_FILES+=("$file")
    fi
done

# ================================================================
# 3. IOC CORRELATION
# ================================================================

{
section "IOC CORRELATION"

echo
echo "The script searches the available evidence for:"
echo "  - IPv4 addresses"
echo "  - domains"
echo "  - process/file names"
echo "  - account names"
echo "  - hashes"
echo
echo "Classification:"
echo "  CONVERGED     = IOC appears in 2 or more independent sources"
echo "  SINGLE-SOURCE = IOC appears in only one source"
echo "  CONFLICTED    = IOC has evidence suggesting disagreement/context conflict"
echo

# Temporary files
IOC_ALL="/tmp/4x05_ioc_all_$$.txt"
IOC_SOURCE="/tmp/4x05_ioc_source_$$.txt"

: > "$IOC_ALL"
: > "$IOC_SOURCE"

# ------------------------------------------------
# Extract IPv4 addresses
# ------------------------------------------------

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    grep -Eo \
        '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
        "$file" 2>/dev/null |
        sort -u |
        while read -r ioc; do
            echo "$ioc|$source_name" >> "$IOC_SOURCE"
            echo "$ioc" >> "$IOC_ALL"
        done

done

# ------------------------------------------------
# Extract domains
# ------------------------------------------------

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    grep -Eio \
        '\b[a-z0-9][a-z0-9.-]+\.(com|net|org|io|xyz|info|biz|ru|top|site|online)\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r ioc; do
            echo "$ioc|$source_name" >> "$IOC_SOURCE"
            echo "$ioc" >> "$IOC_ALL"
        done

done

# ------------------------------------------------
# Extract hashes
# ------------------------------------------------

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    grep -Eio \
        '\b[a-f0-9]{32}\b|\b[a-f0-9]{40}\b|\b[a-f0-9]{64}\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r ioc; do
            echo "$ioc|$source_name" >> "$IOC_SOURCE"
            echo "$ioc" >> "$IOC_ALL"
        done

done

# ------------------------------------------------
# Extract common suspicious process/file names
# ------------------------------------------------

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    grep -Eio \
        '\b[a-zA-Z0-9_-]+\.(exe|dll|ps1|bat|cmd|vbs|js)\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r ioc; do
            echo "$ioc|$source_name" >> "$IOC_SOURCE"
            echo "$ioc" >> "$IOC_ALL"
        done

done

# ------------------------------------------------
# Extract common account names
# ------------------------------------------------

ACCOUNT_NAMES="administrator|admin|system|svc_healthsync|healthsync|james.chen|diane.marsh"

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    grep -Eio \
        "\b($ACCOUNT_NAMES)\b" \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r ioc; do
            echo "$ioc|$source_name" >> "$IOC_SOURCE"
            echo "$ioc" >> "$IOC_ALL"
        done

done

# ------------------------------------------------
# Remove empty values
# ------------------------------------------------

sed -i '/^[[:space:]]*$/d' "$IOC_ALL" "$IOC_SOURCE" 2>/dev/null

# ------------------------------------------------
# Print matrix
# ------------------------------------------------

printf "%-35s %-6s %-6s %-6s %-6s %-6s %-6s %s\n" \
    "IOC" "4x00" "4x01" "4x02" "4x03" "4x04" "IR" "STATUS"

echo "-------------------------------------------------------------------------------------------------------------"

CONVERGED=0
SINGLE=0
CONFLICTED=0

sort -u "$IOC_ALL" |
while read -r ioc; do

    [[ -z "$ioc" ]] && continue

    sources="$(grep -F "^$ioc|" "$IOC_SOURCE" 2>/dev/null |
        cut -d'|' -f2 |
        sort -u)"

    count="$(echo "$sources" | grep -c . || true)"

    mark_source() {
        local pattern="$1"

        if echo "$sources" | grep -qi "$pattern"; then
            echo "YES"
        else
            echo "---"
        fi
    }

    s00="$(mark_source "4x00")"
    s01="$(mark_source "4x01")"
    s02="$(mark_source "4x02")"
    s03="$(mark_source "4x03")"
    s04="$(mark_source "4x04")"

    if echo "$sources" | grep -Eqi "memory_artifacts|disk_forensics|firewall_sessions|ir_team_notes|task[0-3]"; then
        ir="YES"
    else
        ir="---"
    fi

    if [[ "$count" -ge 2 ]]; then
        status="CONVERGED"
    else
        status="SINGLE-SOURCE"
    fi

    printf "%-35s %-6s %-6s %-6s %-6s %-6s %-6s %s\n" \
        "$ioc" "$s00" "$s01" "$s02" "$s03" "$s04" "$ir" "$status"

done

echo
echo "Note:"
echo "A SINGLE-SOURCE IOC is not automatically false."
echo "It may reflect a visibility limitation in other evidence sources."

# ================================================================
# 4. NEW IOC DETECTION
# ================================================================

subsection "NEW IOCs FROM IR EVIDENCE"

echo "IR IOCs that do not appear in the previous findings:"
echo

NEW_COUNT=0

IR_IOCS="/tmp/4x05_ir_iocs_$$.txt"
PREV_IOCS="/tmp/4x05_prev_iocs_$$.txt"

: > "$IR_IOCS"
: > "$PREV_IOCS"

for file in "$IR_DIR"/*; do

    [[ -f "$file" ]] || continue

    grep -Eo \
        '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
        "$file" 2>/dev/null >> "$IR_IOCS"

    grep -Eio \
        '\b[a-z0-9][a-z0-9.-]+\.(com|net|org|io|xyz|info|biz|ru|top|site|online)\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' >> "$IR_IOCS"

done

for file in "$PREV_DIR"/*; do

    [[ -f "$file" ]] || continue

    grep -Eo \
        '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
        "$file" 2>/dev/null >> "$PREV_IOCS"

    grep -Eio \
        '\b[a-z0-9][a-z0-9.-]+\.(com|net|org|io|xyz|info|biz|ru|top|site|online)\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' >> "$PREV_IOCS"

done

sort -u "$IR_IOCS" -o "$IR_IOCS"
sort -u "$PREV_IOCS" -o "$PREV_IOCS"

while read -r ioc; do

    [[ -z "$ioc" ]] && continue

    if ! grep -Fxqi "$ioc" "$PREV_IOCS"; then
        echo "  NEW: $ioc"
        NEW_COUNT=$((NEW_COUNT + 1))
    fi

done < "$IR_IOCS"

echo
echo "New IOC count: $NEW_COUNT"

} >> "$REPORT"

# ================================================================
# 5. TIMELINE CORRELATION
# ================================================================

{
section "TIMELINE CORRELATION"

echo
echo "The following section extracts timestamped evidence from"
echo "available sources."
echo
echo "Interpretation:"
echo "  CONVERGED = same event supported by multiple sources"
echo "  LOWER CONFIDENCE = event appears in only one source"
echo "  CONFLICT = same event appears with materially different times"
echo

TIMELINE_TEMP="/tmp/4x05_timeline_$$.txt"
: > "$TIMELINE_TEMP"

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    # ISO timestamps
    grep -Eo \
        '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})?' \
        "$file" 2>/dev/null |
        sort -u |
        while read -r timestamp; do
            echo "$timestamp|$source_name" >> "$TIMELINE_TEMP"
        done

    # Common date/time format
    grep -Eo \
        '[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]][0-9]{2}:[0-9]{2}:[0-9]{2}' \
        "$file" 2>/dev/null |
        sort -u |
        while read -r timestamp; do
            echo "$timestamp|$source_name" >> "$TIMELINE_TEMP"
        done

done

echo
echo "TIMESTAMP / SOURCE SUMMARY"
echo

if [[ -s "$TIMELINE_TEMP" ]]; then

    sort -u "$TIMELINE_TEMP" |
    awk -F'|' '
    {
        print "  " $1 " -> " $2
    }'

else
    echo "  No recognizable timestamps found."
fi

echo
subsection "KEY ATTACK-STAGE EVIDENCE"

# Instead of inventing exact events, search for actual evidence
# describing common attack stages.

declare -A STAGES

STAGES["Phishing delivery"]="phishing|email|attachment|malicious document|macro"
STAGES["Credential theft"]="credential|password|credential dumping|lsass|ntlm|hash"
STAGES["C2 establishment"]="c2|command.and.control|beacon|callback|connection"
STAGES["Malware execution"]="execute|executed|process|payload|malware|svchost"
STAGES["Persistence"]="scheduled task|scheduled task|run key|runonce|service"
STAGES["Lateral movement"]="psexec|lateral movement|remote service|wmic|admin share"
STAGES["Data staging"]="staging|staged|collected|archive|zip|rar|7z|csv"
STAGES["Exfiltration"]="exfil|outbound|bytes_out|data transfer|upload"
STAGES["Anti-forensics"]="log clear|log deletion|timestamp|artifact removal|wevtutil"

for stage in "${!STAGES[@]}"; do

    pattern="${STAGES[$stage]}"

    echo
    echo "[$stage]"

    FOUND=0

    for file in "${SOURCE_FILES[@]}"; do

        if grep -Eiq "$pattern" "$file" 2>/dev/null; then
            echo "  $(basename "$file")"
            FOUND=$((FOUND + 1))
        fi

    done

    if [[ "$FOUND" -ge 2 ]]; then
        echo "  Confidence: CONVERGED"
    elif [[ "$FOUND" -eq 1 ]]; then
        echo "  Confidence: LOWER CONFIDENCE / SINGLE-SOURCE"
    else
        echo "  No supporting evidence found in available files."
    fi

done

subsection "TIMELINE CONTRADICTIONS"

echo "Potential contradictions must be reviewed manually."
echo
echo "Check for:"
echo "  1. Same event with different timestamps"
echo "  2. UTC vs local time"
echo "  3. Firewall connection-start vs PCAP capture time"
echo "  4. Endpoint collection time vs actual event time"
echo "  5. Host clock skew"
echo "  6. Evidence collection gaps"
echo
echo "Resolution rule:"
echo "Prefer the source that directly records the event being"
echo "reconstructed, and document why that source is authoritative."

} >> "$REPORT"

# ================================================================
# 6. ATT&CK TECHNIQUE CORRELATION
# ================================================================

{
section "TECHNIQUE CORRELATION"

echo
echo "ATT&CK techniques found across available evidence:"
echo

TECHNIQUE_TEMP="/tmp/4x05_techniques_$$.txt"
: > "$TECHNIQUE_TEMP"

for file in "${SOURCE_FILES[@]}"; do

    source_name="$(basename "$file")"

    grep -Eo \
        'T[0-9]{4}([.][0-9]{3})?' \
        "$file" 2>/dev/null |
        sort -u |
        while read -r technique; do
            echo "$technique|$source_name" >> "$TECHNIQUE_TEMP"
        done

done

if [[ -s "$TECHNIQUE_TEMP" ]]; then

    printf "%-20s %-6s %-6s %-6s %-6s %-6s %-30s\n" \
        "TECHNIQUE" "4x00" "4x01" "4x02" "4x04" "IR" "UPDATE"

    echo "---------------------------------------------------------------------------------------------------------"

    sort -u "$TECHNIQUE_TEMP" |
    cut -d'|' -f1 |
    sort -u |
    while read -r technique; do

        sources="$(grep -F "^$technique|" "$TECHNIQUE_TEMP" |
            cut -d'|' -f2 |
            sort -u)"

        mark() {
            local pattern="$1"

            if echo "$sources" | grep -qi "$pattern"; then
                echo "YES"
            else
                echo "---"
            fi
        }

        s00="$(mark "4x00")"
        s01="$(mark "4x01")"
        s02="$(mark "4x02")"
        s04="$(mark "4x04")"

        if echo "$sources" |
            grep -Eqi "memory_artifacts|disk_forensics|firewall_sessions|ir_team_notes|task[0-3]"; then
            ir="YES"
        else
            ir="---"
        fi

        # Determine update
        if [[ "$s02" == "YES" &&
              "$s04" == "YES" &&
              "$ir" == "YES" ]]; then
            update="UPGRADED / CONVERGED"

        elif [[ "$s02" == "YES" &&
                "$ir" == "YES" ]]; then
            update="4x02 + IR"

        elif [[ "$s02" != "YES" &&
                "$ir" == "YES" ]]; then
            update="NEW FROM IR"

        elif [[ "$s02" == "YES" ]]; then
            update="FROM 4x02"

        else
            update="SUPPORTED"
        fi

        printf "%-20s %-6s %-6s %-6s %-6s %-30s\n" \
            "$technique" "$s00" "$s01" "$s02" "$s04" "$ir" "$update"

    done

else
    echo "No ATT&CK technique IDs were found."
fi

echo
subsection "TECHNIQUE STATUS"

echo "UPGRADED FROM INFERRED:"
echo "  Review techniques appearing in 4x02 as INFERRED and"
echo "  supported by independent evidence in 4x04 or IR."

if [[ -f "$PREV_DIR/4x02_attack_mapping.json" ]]; then

    echo
    echo "Techniques explicitly marked INFERRED in 4x02:"

    grep -Ein \
        'inferred|infer|possible|hypothes' \
        "$PREV_DIR/4x02_attack_mapping.json" 2>/dev/null |
        head -50

else
    echo
    echo "[MISSING] 4x02_attack_mapping.json"
fi

echo
echo "NEW TECHNIQUES FROM IR:"
grep -Eio \
    'T[0-9]{4}([.][0-9]{3})?' \
    "$IR_DIR"/* 2>/dev/null |
    sort -u |
    head -100

} >> "$REPORT"

# ================================================================
# 7. CONTRADICTION ANALYSIS
# ================================================================

{
section "CRITICAL CONTRADICTIONS AND RESOLUTION"

echo
echo "This section searches for explicit contradiction language."
echo

CONTRADICTION_PATTERNS="contradict|conflict|inconsistent|discrep|mismatch|different timestamp|does not match|not match|however|but"

FOUND_CONTRADICTIONS=0

for file in "${SOURCE_FILES[@]}"; do

    matches="$(grep -Ein "$CONTRADICTION_PATTERNS" "$file" 2>/dev/null |
        head -30)"

    if [[ -n "$matches" ]]; then

        echo
        echo "SOURCE: $(basename "$file")"
        echo "$matches"

        FOUND_CONTRADICTIONS=$((FOUND_CONTRADICTIONS + 1))
    fi

done

if [[ "$FOUND_CONTRADICTIONS" -eq 0 ]]; then

    echo "No explicit contradiction language was found."
    echo
    echo "This does NOT prove that no contradiction exists."
    echo "Analysts should still compare timestamps and event descriptions."

fi

echo
subsection "RECOMMENDED CONTRADICTION RESOLUTION PROCESS"

echo "For each contradiction:"
echo
echo "1. Identify the exact event."
echo "2. Record the timestamp from each source."
echo "3. Normalize timestamps to UTC."
echo "4. Check timezone differences."
echo "5. Check endpoint clock skew."
echo "6. Check whether one source records:"
echo "     - event creation"
echo "     - connection initiation"
echo "     - packet capture"
echo "     - evidence collection"
echo "7. Prefer the source closest to the actual event."
echo "8. Document the reason for choosing the authoritative timestamp."
echo "9. If unresolved, keep the event as CONFLICTED."
echo

} >> "$REPORT"

# ================================================================
# 8. OVERALL SUMMARY
# ================================================================

{
section "CORRELATION SUMMARY"

echo
echo "Evidence files analyzed: ${#SOURCE_FILES[@]}"
echo
echo "IOC classification:"
echo "  CONVERGED     = supported by multiple independent sources"
echo "  SINGLE-SOURCE = supported by one source"
echo "  CONFLICTED    = requires manual contradiction analysis"
echo
echo "New IR IOCs: $NEW_COUNT"
echo
echo "Important interpretation:"
echo "  CONVERGED evidence generally provides stronger confidence."
echo "  SINGLE-SOURCE evidence may still be valid if other sources"
echo "  lacked visibility."
echo "  Absence of evidence is NOT automatically evidence of absence."
echo
echo "Attack reconstruction should therefore combine:"
echo
echo "  4x00  -> Initial access / phishing evidence"
echo "  4x01  -> Network activity"
echo "  4x02  -> ATT&CK mapping"
echo "  4x03  -> Malware behavior"
echo "  4x04  -> Threat hunting / lateral movement"
echo "  IR    -> Memory + disk + firewall + incident response evidence"
echo
echo "Final confidence should be assigned to the reconstructed attack"
echo "chain only after reviewing convergences, contradictions, and gaps."

section "END OF CORRELATION REPORT"

} >> "$REPORT"

# ================================================================
# CLEAN TEMP FILES
# ================================================================

rm -f \
    "$IOC_ALL" \
    "$IOC_SOURCE" \
    "$IR_IOCS" \
    "$PREV_IOCS" \
    "$TIMELINE_TEMP" \
    "$TECHNIQUE_TEMP" \
    2>/dev/null

# ================================================================
# DISPLAY REPORT
# ================================================================

cat "$REPORT"

echo
echo "================================================================"
echo "Report saved to:"
echo "$REPORT"
echo "================================================================"
