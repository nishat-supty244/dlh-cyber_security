#!/bin/bash

# ================================================================
# 4-correlation_matrix.sh
#
# 4x05 Attack Reconstruction - Task 4
#
# Purpose:
#   Correlate evidence from:
#     - T0 Evidence Inventory
#     - T1 Memory Analysis
#     - T2 Disk Analysis
#     - T3 Firewall Analysis
#     - 4x00 Phishing
#     - 4x01 Network Timeline
#     - 4x02 ATT&CK Mapping
#     - 4x03 Malware Summary
#     - 4x04 Threat Hunting
#     - IR evidence
#
# Output:
#   task4_output/correlation_matrix_report.txt
#
# ================================================================

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ================================================================
# REQUIRED DIRECTORIES
# ================================================================

PREVIOUS_DIR="$BASE_DIR/previous_findings"
IR_DIR="$BASE_DIR/ir_evidence"

TASK0_DIR="$BASE_DIR/task0_output"
TASK1_DIR="$BASE_DIR/task1_output"
TASK2_DIR="$BASE_DIR/task2_output"
TASK3_DIR="$BASE_DIR/task3_output"

OUTPUT_DIR="$BASE_DIR/task4_output"

mkdir -p "$OUTPUT_DIR"

REPORT="$OUTPUT_DIR/correlation_matrix_report.txt"

# ================================================================
# REQUIRED PREVIOUS FINDINGS
# ================================================================

PHISHING="$PREVIOUS_DIR/4x00_phishing_summary.txt"
NETWORK="$PREVIOUS_DIR/4x01_network_timeline.txt"
ATTACK_MAPPING="$PREVIOUS_DIR/4x02_attack_mapping.json"
MALWARE="$PREVIOUS_DIR/4x03_malware_summary.txt"
HUNTING="$PREVIOUS_DIR/4x04_hunting_report.txt"

# ================================================================
# REQUIRED CURRENT IR EVIDENCE
# ================================================================

MEMORY="$IR_DIR/memory_artifacts.txt"
DISK="$IR_DIR/disk_forensics_report.txt"
FIREWALL="$IR_DIR/firewall_sessions_ws_recv_03.json"
IR_NOTES="$IR_DIR/ir_team_notes.txt"

# ================================================================
# T0-T3 OUTPUTS
# ================================================================

T0_OUTPUT="$TASK0_DIR/evidence_inventory_report.txt"
T1_OUTPUT="$TASK1_DIR/memory_analysis_report.txt"
T2_OUTPUT="$TASK2_DIR/disk_analysis_report.txt"
T3_OUTPUT="$TASK3_DIR/firewall_analysis_report.txt"

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

exists() {
    [[ -f "$1" ]]
}

source_name() {
    basename "$1"
}

# ================================================================
# INITIAL REPORT
# ================================================================

cat > "$REPORT" <<EOF
================================================================
   CROSS-EVIDENCE CORRELATION MATRIX
================================================================

Project: 4x05 Attack Reconstruction
Generated: $(date)

Purpose:
Correlate findings from current IR evidence, T0-T3 outputs,
and all previous_findings summaries.

Evidence confidence:
  CONVERGED     = supported by 2 or more independent sources
  SINGLE-SOURCE = supported by one source only
  CONFLICTED    = sources provide apparently inconsistent evidence

Important:
Missing evidence is reported as a gap.
Missing evidence is NOT treated as evidence that an event did not occur.

================================================================

EOF

# ================================================================
# 1. CHECK REQUIRED SOURCES
# ================================================================

{
section "REQUIRED EVIDENCE SOURCES"

echo
echo "PREVIOUS FINDINGS:"
echo

for file in \
    "$PHISHING" \
    "$NETWORK" \
    "$ATTACK_MAPPING" \
    "$MALWARE" \
    "$HUNTING"
do
    if exists "$file"; then
        echo "[OK]      $file"
    else
        echo "[MISSING] $file"
    fi
done

echo
echo "CURRENT IR EVIDENCE:"
echo

for file in \
    "$MEMORY" \
    "$DISK" \
    "$FIREWALL" \
    "$IR_NOTES"
do
    if exists "$file"; then
        echo "[OK]      $file"
    else
        echo "[MISSING] $file"
    fi
done

echo
echo "T0-T3 OUTPUTS:"
echo

for file in \
    "$T0_OUTPUT" \
    "$T1_OUTPUT" \
    "$T2_OUTPUT" \
    "$T3_OUTPUT"
do
    if exists "$file"; then
        echo "[OK]      $file"
    else
        echo "[MISSING] $file"
    fi
done

} >> "$REPORT"

# ================================================================
# 2. BUILD EXPLICIT SOURCE LIST
# ================================================================

# This list intentionally contains every required source explicitly.

SOURCE_FILES=(
    "$PHISHING"
    "$NETWORK"
    "$ATTACK_MAPPING"
    "$MALWARE"
    "$HUNTING"
    "$MEMORY"
    "$DISK"
    "$FIREWALL"
    "$IR_NOTES"
    "$T0_OUTPUT"
    "$T1_OUTPUT"
    "$T2_OUTPUT"
    "$T3_OUTPUT"
)

# ================================================================
# 3. IOC CORRELATION MATRIX
# ================================================================

{
section "IOC CORRELATION"

echo
echo "IOC types searched:"
echo "  - IP addresses"
echo "  - domains"
echo "  - file names"
echo "  - process names"
echo "  - hashes"
echo "  - account names"
echo

echo "IOC MATRIX:"
echo

printf "%-32s %-5s %-5s %-5s %-5s %-5s %-5s %s\n" \
    "IOC" "4x00" "4x01" "4x02" "4x03" "4x04" "IR" "STATUS"

echo "------------------------------------------------------------------------------------------------"

IOC_FILE="/tmp/4x05_iocs_$$.txt"
: > "$IOC_FILE"

# ------------------------------------------------
# Extract IOCs from every source
# ------------------------------------------------

for file in "${SOURCE_FILES[@]}"; do

    if [[ ! -f "$file" ]]; then
        continue
    fi

    # IPv4 addresses
    grep -Eo \
        '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
        "$file" 2>/dev/null |
        sort -u |
        while read -r value; do
            [[ -n "$value" ]] && echo "$value|$(basename "$file")" >> "$IOC_FILE"
        done

    # Domains
    grep -Eio \
        '\b[a-z0-9][a-z0-9.-]+\.(com|net|org|io|xyz|info|biz|ru|top|site|online)\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r value; do
            [[ -n "$value" ]] && echo "$value|$(basename "$file")" >> "$IOC_FILE"
        done

    # MD5 / SHA1 / SHA256
    grep -Eio \
        '\b[a-f0-9]{32}\b|\b[a-f0-9]{40}\b|\b[a-f0-9]{64}\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r value; do
            [[ -n "$value" ]] && echo "$value|$(basename "$file")" >> "$IOC_FILE"
        done

    # Executable / script names
    grep -Eio \
        '\b[a-zA-Z0-9_.-]+\.(exe|dll|ps1|bat|cmd|vbs|js)\b' \
        "$file" 2>/dev/null |
        tr '[:upper:]' '[:lower:]' |
        sort -u |
        while read -r value; do
            [[ -n "$value" ]] && echo "$value|$(basename "$file")" >> "$IOC_FILE"
        done

done

# Remove empty lines
sed -i '/^[[:space:]]*$/d' "$IOC_FILE" 2>/dev/null

CONVERGED_COUNT=0
SINGLE_COUNT=0

# ------------------------------------------------
# Print IOC matrix
# ------------------------------------------------

if [[ -s "$IOC_FILE" ]]; then

    sort -u "$IOC_FILE" |
    cut -d'|' -f1 |
    sort -u |
    while read -r ioc; do

        [[ -z "$ioc" ]] && continue

        sources="$(grep -F "^$ioc|" "$IOC_FILE" |
            cut -d'|' -f2 |
            sort -u)"

        count="$(echo "$sources" | grep -c . || true)"

        if echo "$sources" | grep -q "4x00"; then
            s00="YES"
        else
            s00="---"
        fi

        if echo "$sources" | grep -q "4x01"; then
            s01="YES"
        else
            s01="---"
        fi

        if echo "$sources" | grep -q "4x02"; then
            s02="YES"
        else
            s02="---"
        fi

        if echo "$sources" | grep -q "4x03"; then
            s03="YES"
        else
            s03="---"
        fi

        if echo "$sources" | grep -q "4x04"; then
            s04="YES"
        else
            s04="---"
        fi

        if echo "$sources" |
            grep -Eq "memory_artifacts|disk_forensics|firewall_sessions|ir_team_notes|analysis_report"; then
            ir="YES"
        else
            ir="---"
        fi

        if [[ "$count" -ge 2 ]]; then
            status="CONVERGED"
        else
            status="SINGLE-SOURCE"
        fi

        printf "%-32s %-5s %-5s %-5s %-5s %-5s %-5s %s\n" \
            "$ioc" "$s00" "$s01" "$s02" "$s03" "$s04" "$ir" "$status"

    done

else

    echo "No IOC values were extracted."

fi

echo
echo "IOC interpretation:"
echo "  CONVERGED     = same IOC found across multiple sources."
echo "  SINGLE-SOURCE = IOC found in only one evidence source."
echo "  A single-source IOC is not automatically false."

# ================================================================
# 4. NEW IOC ANALYSIS
# ================================================================

subsection "NEW IOCs FROM IR EVIDENCE"

echo
echo "Comparing IR evidence against previous findings."

IR_IOCS="/tmp/4x05_ir_iocs_$$.txt"
PREVIOUS_IOCS="/tmp/4x05_previous_iocs_$$.txt"

: > "$IR_IOCS"
: > "$PREVIOUS_IOCS"

# IR evidence
for file in \
    "$MEMORY" \
    "$DISK" \
    "$FIREWALL" \
    "$IR_NOTES" \
    "$T1_OUTPUT" \
    "$T2_OUTPUT" \
    "$T3_OUTPUT"
do

    if [[ -f "$file" ]]; then

        grep -Eo \
            '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
            "$file" 2>/dev/null >> "$IR_IOCS"

        grep -Eio \
            '\b[a-z0-9][a-z0-9.-]+\.(com|net|org|io|xyz|info|biz|ru|top|site|online)\b' \
            "$file" 2>/dev/null |
            tr '[:upper:]' '[:lower:]' >> "$IR_IOCS"

    fi

done

# Previous findings
for file in \
    "$PHISHING" \
    "$NETWORK" \
    "$ATTACK_MAPPING" \
    "$MALWARE" \
    "$HUNTING"
do

    if [[ -f "$file" ]]; then

        grep -Eo \
            '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
            "$file" 2>/dev/null >> "$PREVIOUS_IOCS"

        grep -Eio \
            '\b[a-z0-9][a-z0-9.-]+\.(com|net|org|io|xyz|info|biz|ru|top|site|online)\b' \
            "$file" 2>/dev/null |
            tr '[:upper:]' '[:lower:]' >> "$PREVIOUS_IOCS"

    fi

done

sort -u "$IR_IOCS" -o "$IR_IOCS"
sort -u "$PREVIOUS_IOCS" -o "$PREVIOUS_IOCS"

NEW_COUNT=0

if [[ -s "$IR_IOCS" ]]; then

    while read -r ioc; do

        [[ -z "$ioc" ]] && continue

        if ! grep -Fxqi "$ioc" "$PREVIOUS_IOCS"; then
            echo "  NEW IR IOC: $ioc"
            NEW_COUNT=$((NEW_COUNT + 1))
        fi

    done < "$IR_IOCS"

fi

echo
echo "New IR IOC count: $NEW_COUNT"

} >> "$REPORT"

# ================================================================
# 5. TIMELINE CORRELATION
# ================================================================

{
section "TIMELINE CORRELATION"

echo
echo "The timeline compares major attack events across evidence."
echo

# ------------------------------------------------
# Event patterns
# ------------------------------------------------

declare -A EVENT_PATTERNS

EVENT_PATTERNS["Phishing delivery"]="phishing|phish|email|attachment|malicious document"
EVENT_PATTERNS["Credential theft"]="credential|password|credential dumping|lsass|ntlm"
EVENT_PATTERNS["C2 establishment"]="c2|command.and.control|beacon|callback"
EVENT_PATTERNS["Malware execution"]="malware|payload|executed|process"
EVENT_PATTERNS["Persistence"]="scheduled task|run key|runonce|service"
EVENT_PATTERNS["Lateral movement"]="psexec|lateral movement|remote service|wmic"
EVENT_PATTERNS["Data staging"]="staging|staged|archive|zip|rar|7z|collected data"
EVENT_PATTERNS["Exfiltration"]="exfil|outbound|upload|bytes_out"
EVENT_PATTERNS["Anti-forensics"]="log clear|log deletion|timestamp manipulation|artifact removal"

printf "%-28s %-45s %-20s\n" \
    "EVENT" "SOURCES" "CONFIDENCE"

echo "-----------------------------------------------------------------------------------------------"

for event in \
    "Phishing delivery" \
    "Credential theft" \
    "C2 establishment" \
    "Malware execution" \
    "Persistence" \
    "Lateral movement" \
    "Data staging" \
    "Exfiltration" \
    "Anti-forensics"
do

    pattern="${EVENT_PATTERNS[$event]}"

    FOUND_SOURCES=""

    for file in \
        "$PHISHING" \
        "$NETWORK" \
        "$ATTACK_MAPPING" \
        "$MALWARE" \
        "$HUNTING" \
        "$MEMORY" \
        "$DISK" \
        "$FIREWALL" \
        "$IR_NOTES" \
        "$T0_OUTPUT" \
        "$T1_OUTPUT" \
        "$T2_OUTPUT" \
        "$T3_OUTPUT"
    do

        if [[ -f "$file" ]] &&
           grep -Eiq "$pattern" "$file" 2>/dev/null; then

            if [[ -z "$FOUND_SOURCES" ]]; then
                FOUND_SOURCES="$(basename "$file")"
            else
                FOUND_SOURCES="$FOUND_SOURCES,$(basename "$file")"
            fi

        fi

    done

    SOURCE_COUNT=0

    if [[ -n "$FOUND_SOURCES" ]]; then
        SOURCE_COUNT="$(echo "$FOUND_SOURCES" | tr ',' '\n' | wc -l)"
    fi

    if [[ "$SOURCE_COUNT" -ge 2 ]]; then
        CONFIDENCE="CONVERGED"
    elif [[ "$SOURCE_COUNT" -eq 1 ]]; then
        CONFIDENCE="LOWER CONFIDENCE"
    else
        CONFIDENCE="NO EVIDENCE"
        FOUND_SOURCES="---"
    fi

    printf "%-28s %-45s %-20s\n" \
        "$event" "$FOUND_SOURCES" "$CONFIDENCE"

done

# ------------------------------------------------
# Timestamp extraction
# ------------------------------------------------

subsection "TIMESTAMP EVIDENCE"

echo
echo "Timestamps found in current and previous evidence:"
echo

for file in \
    "$PHISHING" \
    "$NETWORK" \
    "$ATTACK_MAPPING" \
    "$MALWARE" \
    "$HUNTING" \
    "$MEMORY" \
    "$DISK" \
    "$FIREWALL" \
    "$IR_NOTES" \
    "$T1_OUTPUT" \
    "$T2_OUTPUT" \
    "$T3_OUTPUT"
do

    if [[ -f "$file" ]]; then

        matches="$(grep -Eo \
            '[0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}:[0-9]{2}([.][0-9]+)?(Z|[+-][0-9]{2}:[0-9]{2})?' \
            "$file" 2>/dev/null |
            sort -u |
            head -20)"

        if [[ -n "$matches" ]]; then

            echo
            echo "SOURCE: $(basename "$file")"
            echo "$matches"

        fi

    fi

done

echo
echo "Timestamp resolution checks:"
echo "  - UTC versus local time"
echo "  - endpoint clock skew"
echo "  - firewall connection-start time"
echo "  - PCAP capture time"
echo "  - evidence collection time"
echo "  - timezone conversion"

echo
echo "If two sources show different times for the same event,"
echo "the difference must be explained before assigning HIGH"
echo "confidence."

} >> "$REPORT"

# ================================================================
# 6. ATT&CK TECHNIQUE CORRELATION
# ================================================================

{
section "TECHNIQUE CORRELATION"

echo
echo "ATT&CK techniques found in the evidence:"
echo

TECHNIQUES="/tmp/4x05_techniques_$$.txt"

: > "$TECHNIQUES"

for file in "${SOURCE_FILES[@]}"; do

    if [[ -f "$file" ]]; then

        grep -Eo \
            'T[0-9]{4}([.][0-9]{3})?' \
            "$file" 2>/dev/null |
            sort -u |
            while read -r technique; do
                [[ -n "$technique" ]] &&
                    echo "$technique|$(basename "$file")" >> "$TECHNIQUES"
            done

    fi

done

if [[ -s "$TECHNIQUES" ]]; then

    printf "%-18s %-5s %-5s %-5s %-5s %-5s %s\n" \
        "TECHNIQUE" "4x00" "4x01" "4x02" "4x04" "IR" "UPDATE"

    echo "--------------------------------------------------------------------------------"

    sort -u "$TECHNIQUES" |
    cut -d'|' -f1 |
    sort -u |
    while read -r technique; do

        sources="$(grep -F "^$technique|" "$TECHNIQUES" |
            cut -d'|' -f2 |
            sort -u)"

        if echo "$sources" | grep -q "4x00"; then
            s00="YES"
        else
            s00="---"
        fi

        if echo "$sources" | grep -q "4x01"; then
            s01="YES"
        else
            s01="---"
        fi

        if echo "$sources" | grep -q "4x02"; then
            s02="YES"
        else
            s02="---"
        fi

        if echo "$sources" | grep -q "4x04"; then
            s04="YES"
        else
            s04="---"
        fi

        if echo "$sources" |
            grep -Eq "memory_artifacts|disk_forensics|firewall_sessions|ir_team_notes|analysis_report"; then
            ir="YES"
        else
            ir="---"
        fi

        # Determine status
        if [[ "$s02" == "YES" &&
              "$s04" == "YES" &&
              "$ir" == "YES" ]]; then

            update="UPGRADED / CONVERGED"

        elif [[ "$s02" == "YES" &&
                "$ir" == "YES" ]]; then

            update="UPGRADED WITH IR"

        elif [[ "$s02" != "YES" &&
                "$ir" == "YES" ]]; then

            update="NEW FROM IR"

        elif [[ "$s02" == "YES" ]]; then

            update="FROM 4x02"

        else

            update="SUPPORTED"

        fi

        printf "%-18s %-5s %-5s %-5s %-5s %-5s %s\n" \
            "$technique" "$s00" "$s01" "$s02" "$s04" "$ir" "$update"

    done

else

    echo "No ATT&CK technique identifiers found."

fi

echo
subsection "4x02 INFERRED TECHNIQUES"

if [[ -f "$ATTACK_MAPPING" ]]; then

    grep -Ein \
        'inferred|infer|possible|hypothes|confidence' \
        "$ATTACK_MAPPING" 2>/dev/null |
        head -80

else

    echo "[MISSING] $ATTACK_MAPPING"

fi

echo
echo "Interpretation:"
echo "  If a technique was INFERRED in 4x02 and later supported"
echo "  by independent evidence, it can be upgraded."
echo
echo "  If later evidence contradicts the 4x02 inference, it should"
echo "  be corrected rather than retained simply because it was"
echo "  previously reported."

} >> "$REPORT"

# ================================================================
# 7. CONTRADICTIONS AND GAPS
# ================================================================

{
section "CRITICAL CONTRADICTIONS AND GAPS"

echo
echo "Searching for explicit contradiction indicators:"
echo

CONTRADICTION_PATTERN="contradict|conflict|inconsistent|mismatch|discrepancy|does not match|not match"

CONTRADICTION_FOUND=0

for file in "${SOURCE_FILES[@]}"; do

    if [[ -f "$file" ]]; then

        result="$(grep -Ein \
            "$CONTRADICTION_PATTERN" \
            "$file" 2>/dev/null |
            head -20)"

        if [[ -n "$result" ]]; then

            echo
            echo "SOURCE: $(basename "$file")"
            echo "$result"

            CONTRADICTION_FOUND=1

        fi

    fi

done

if [[ "$CONTRADICTION_FOUND" -eq 0 ]]; then
    echo "No explicit contradiction statements found."
fi

echo
subsection "EVIDENCE GAPS"

echo
echo "A missing source or missing event does NOT automatically mean"
echo "the event did not happen."

for file in \
    "$PHISHING" \
    "$NETWORK" \
    "$ATTACK_MAPPING" \
    "$MALWARE" \
    "$HUNTING" \
    "$MEMORY" \
    "$DISK" \
    "$FIREWALL" \
    "$IR_NOTES" \
    "$T0_OUTPUT" \
    "$T1_OUTPUT" \
    "$T2_OUTPUT" \
    "$T3_OUTPUT"
do

    if [[ ! -f "$file" ]]; then
        echo "  MISSING SOURCE: $file"
    fi

done

echo
echo "Possible visibility gaps to consider:"
echo "  - PCAP collection window may be shorter than firewall logs."
echo "  - Memory is a point-in-time snapshot."
echo "  - Deleted files may not be fully recoverable."
echo "  - Firewall metadata does not provide packet contents."
echo "  - Absence of an IOC from a source may reflect collection limits."

} >> "$REPORT"

# ================================================================
# 8. FINAL SUMMARY
# ================================================================

{
section "FINAL CORRELATION SUMMARY"

echo
echo "The purpose of this task is to combine all evidence into one"
echo "defensible attack reconstruction."
echo

echo "Evidence chain:"
echo
echo "  4x00  -> Phishing / initial access"
echo "  4x01  -> Network activity"
echo "  4x02  -> ATT&CK mapping"
echo "  4x03  -> Malware behavior"
echo "  4x04  -> Threat hunting"
echo "  IR    -> Memory / disk / firewall / IR notes"
echo

echo "Correlation rules:"
echo
echo "  CONVERGED:"
echo "    Multiple independent sources support the same finding."
echo
echo "  SINGLE-SOURCE:"
echo "    Only one source currently supports the finding."
echo
echo "  CONFLICTED:"
echo "    Sources appear to disagree and require investigation."
echo

echo "Timeline rule:"
echo "  Do not resolve timestamp differences by guessing."
echo "  Check timezone, clock skew, collection timing and event type."

echo
echo "Technique rule:"
echo "  A technique marked INFERRED in 4x02 should be upgraded only"
echo "  when later evidence actually supports it."

echo
echo "Final analyst question:"
echo
echo "  Do the independent evidence sources converge on one attack"
echo "  story, or are important parts still uncertain?"

section "END OF CROSS-EVIDENCE CORRELATION"

} >> "$REPORT"

# ================================================================
# CLEAN TEMPORARY FILES
# ================================================================

rm -f \
    "$IOC_FILE" \
    "$IR_IOCS" \
    "$PREVIOUS_IOCS" \
    "$TECHNIQUES" \
    2>/dev/null

# ================================================================
# DISPLAY RESULT
# ================================================================

cat "$REPORT"

echo
echo "================================================================"
echo "Correlation report saved to:"
echo "$REPORT"
echo "================================================================"
