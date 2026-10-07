#!/bin/bash

# ============================================================
# Task 1 - Memory Artifact Analysis
# Project: 4x05 Attack Reconstruction
# Host: WS-RECV-03
#
# Purpose:
#   Analyze memory artifacts to identify:
#   1. Running processes
#   2. Network connections
#   3. Loaded modules/DLLs
#   4. Scheduled task persistence
#   5. HEALTHBANE IOC matches
#
# Required tools:
#   grep, sort, uniq, wc, date, jq
# ============================================================

set -u

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

MEMORY_FILE="$PROJECT_DIR/ir_evidence/memory_artifacts.txt"
IOC_FILE="$PROJECT_DIR/reference/healthbane_ioc_master.json"

OUTPUT_DIR="$PROJECT_DIR/task1_output"
REPORT="$OUTPUT_DIR/memory_analysis_report.txt"

mkdir -p "$OUTPUT_DIR"

# ------------------------------------------------------------
# Check required files
# ------------------------------------------------------------

echo "[+] Checking evidence files..."

if [ ! -f "$MEMORY_FILE" ]; then
    echo "[ERROR] Memory artifact file not found:"
    echo "        $MEMORY_FILE"
    exit 1
fi

if [ ! -f "$IOC_FILE" ]; then
    echo "[ERROR] IOC database not found:"
    echo "        $IOC_FILE"
    exit 1
fi

echo "[+] Memory file: $MEMORY_FILE"
echo "[+] IOC database: $IOC_FILE"
echo

# ------------------------------------------------------------
# Validate IOC JSON
# ------------------------------------------------------------

echo "[+] Validating IOC database..."

if ! jq empty "$IOC_FILE" >/dev/null 2>&1; then
    echo "[ERROR] IOC database is not valid JSON."
    exit 1
fi

echo "[+] IOC database is valid JSON."
echo

# ------------------------------------------------------------
# Start report
# ------------------------------------------------------------

{
    echo "============================================================"
    echo "TASK 1 - MEMORY ARTIFACT ANALYSIS"
    echo "Project: 4x05 Attack Reconstruction"
    echo "Host: WS-RECV-03"
    echo "Analysis Date: $(date)"
    echo "============================================================"
    echo
    echo "Evidence:"
    echo "  Memory: $MEMORY_FILE"
    echo "  IOC DB: $IOC_FILE"
    echo
} > "$REPORT"

# ------------------------------------------------------------
# Basic evidence statistics
# ------------------------------------------------------------

echo "[+] Collecting basic statistics..."

TOTAL_LINES=$(wc -l < "$MEMORY_FILE")

{
    echo "------------------------------------------------------------"
    echo "1. EVIDENCE STATISTICS"
    echo "------------------------------------------------------------"
    echo "Memory artifact lines: $TOTAL_LINES"
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 2. RUNNING PROCESSES
# ------------------------------------------------------------

echo "[+] Analyzing running processes..."

{
    echo "------------------------------------------------------------"
    echo "2. RUNNING PROCESSES"
    echo "------------------------------------------------------------"
    echo
    echo "Potential HEALTHBANE-related process names:"
    echo
} >> "$REPORT"

# Search for known suspicious process patterns.
# The -i option makes the search case-insensitive.

grep -Ein \
    'svchost.*update|update.*svchost|sync.*healthdata|healthdata.*sync|powershell|pwsh|encodedcommand|-enc|rundll32|regsvr32|mshta|wscript|cscript' \
    "$MEMORY_FILE" \
    >> "$REPORT" 2>/dev/null || echo "No matching suspicious process indicators found." >> "$REPORT"

{
    echo
    echo "All process-related lines:"
    echo
} >> "$REPORT"

grep -Ein \
    'process|pid|parent|ppid|svchost|taskhost|powershell|cmd.exe|explorer.exe' \
    "$MEMORY_FILE" \
    >> "$REPORT" 2>/dev/null || echo "No process-related lines found." >> "$REPORT"

echo >> "$REPORT"

# ------------------------------------------------------------
# 3. NETWORK CONNECTIONS
# ------------------------------------------------------------

echo "[+] Analyzing network connections..."

{
    echo "------------------------------------------------------------"
    echo "3. NETWORK CONNECTIONS"
    echo "------------------------------------------------------------"
    echo
    echo "Network-related evidence:"
    echo
} >> "$REPORT"

grep -Ein \
    'network|connection|remote|local|tcp|udp|listening|established|foreign|peer|socket|443|8443|445|http|https|dns' \
    "$MEMORY_FILE" \
    >> "$REPORT" 2>/dev/null || echo "No network-related lines found." >> "$REPORT"

echo >> "$REPORT"

# ------------------------------------------------------------
# 4. KNOWN IOC MATCHING
# ------------------------------------------------------------

echo "[+] Cross-referencing memory evidence against IOC database..."

{
    echo "------------------------------------------------------------"
    echo "4. IOC CROSS-REFERENCE"
    echo "------------------------------------------------------------"
    echo
    echo "The following IOC values were extracted from the IOC database"
    echo "and searched for in the memory artifact."
    echo
} >> "$REPORT"

# Extract string values from JSON.
# sort -u removes duplicate IOC values.

IOC_VALUES=$(jq -r '.. | strings' "$IOC_FILE" 2>/dev/null | sort -u)

MATCH_COUNT=0

while IFS= read -r IOC; do

    # Ignore very short values because they create many false matches.
    if [ "${#IOC}" -lt 4 ]; then
        continue
    fi

    if grep -Fqi "$IOC" "$MEMORY_FILE"; then

        MATCH_COUNT=$((MATCH_COUNT + 1))

        {
            echo "[KNOWN] $IOC"
            echo "  Evidence:"
            grep -Ein -F "$IOC" "$MEMORY_FILE"
            echo
        } >> "$REPORT"

    fi

done <<< "$IOC_VALUES"

if [ "$MATCH_COUNT" -eq 0 ]; then
    echo "No direct IOC matches were found." >> "$REPORT"
fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 5. LOADED MODULES / DLLs
# ------------------------------------------------------------

echo "[+] Analyzing loaded modules and DLLs..."

{
    echo "------------------------------------------------------------"
    echo "5. LOADED MODULES / DLLs"
    echo "------------------------------------------------------------"
    echo
    echo "Potential credential-access or security-tool related modules:"
    echo
} >> "$REPORT"

grep -Ein \
    'dll|module|credential|lsass|sam|security authority|sekurlsa|mimikatz|ntdll|advapi|crypt|vault' \
    "$MEMORY_FILE" \
    >> "$REPORT" 2>/dev/null || echo "No suspicious module indicators found." >> "$REPORT"

echo >> "$REPORT"

# ------------------------------------------------------------
# 6. SCHEDULED TASK PERSISTENCE
# ------------------------------------------------------------

echo "[+] Searching for scheduled task persistence..."

{
    echo "------------------------------------------------------------"
    echo "6. SCHEDULED TASK PERSISTENCE"
    echo "------------------------------------------------------------"
    echo
} >> "$REPORT"

SCHEDULE_MATCHES=$(grep -Ein \
    'scheduled task|schedule|task name|trigger|action|taskpath|taskname|02:00|powershell.*-enc|healthsync' \
    "$MEMORY_FILE" \
    2>/dev/null || true)

if [ -n "$SCHEDULE_MATCHES" ]; then

    echo "$SCHEDULE_MATCHES" >> "$REPORT"

    {
        echo
        echo "ATT&CK Mapping:"
        echo "  T1053.005 - Scheduled Task/Job: Scheduled Task"
        echo
        echo "Assessment:"
        echo "  Persistence mechanism identified in memory evidence."
        echo "  Verify task name, trigger, action and creation timestamp"
        echo "  against disk evidence and previous investigation findings."
    } >> "$REPORT"

else

    echo "No scheduled-task indicators found." >> "$REPORT"

fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 7. HEALTHBANE PROCESS INDICATORS
# ------------------------------------------------------------

echo "[+] Searching specifically for HEALTHBANE indicators..."

{
    echo "------------------------------------------------------------"
    echo "7. HEALTHBANE-SPECIFIC INDICATORS"
    echo "------------------------------------------------------------"
    echo
} >> "$REPORT"

HEALTHBANE_MATCHES=$(grep -Ein \
    'healthbane|healthsync|sync_healthdata|svchost_update|svchost.*update|healthdata|health-sync' \
    "$MEMORY_FILE" \
    2>/dev/null || true)

if [ -n "$HEALTHBANE_MATCHES" ]; then

    echo "$HEALTHBANE_MATCHES" >> "$REPORT"

else

    echo "No direct HEALTHBANE process indicators found." >> "$REPORT"

fi

echo >> "$REPORT"

# ------------------------------------------------------------
# 8. UNKNOWN / NEW NETWORK INDICATORS
# ------------------------------------------------------------

echo "[+] Looking for IP addresses in memory evidence..."

{
    echo "------------------------------------------------------------"
    echo "8. IP ADDRESSES OBSERVED IN MEMORY"
    echo "------------------------------------------------------------"
    echo
} >> "$REPORT"

# Extract IPv4 addresses from the memory file.
# grep -E identifies IPv4-looking strings.

IP_ADDRESSES=$(grep -Eo \
    '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' \
    "$MEMORY_FILE" \
    | sort -u || true)

if [ -n "$IP_ADDRESSES" ]; then

    while IFS= read -r IP; do

        if [ -z "$IP" ]; then
            continue
        fi

        if grep -Fqi "$IP" "$IOC_FILE"; then
            echo "[KNOWN] $IP" >> "$REPORT"
        else
            echo "[NEW] $IP" >> "$REPORT"
        fi

        grep -Ein -F "$IP" "$MEMORY_FILE" >> "$REPORT"

        echo >> "$REPORT"

    done <<< "$IP_ADDRESSES"

else

    echo "No IPv4 addresses found." >> "$REPORT"

fi

# ------------------------------------------------------------
# 9. ATT&CK MAPPING SUMMARY
# ------------------------------------------------------------

echo "[+] Creating ATT&CK mapping summary..."

{
    echo "------------------------------------------------------------"
    echo "9. ATT&CK TECHNIQUE SUMMARY"
    echo "------------------------------------------------------------"
    echo
    echo "T1053.005 - Scheduled Task/Job: Scheduled Task"
    echo "  Evidence source: memory_artifacts.txt"
    echo "  Relevance: Possible persistence mechanism"
    echo
    echo "T1059.001 - Command and Scripting Interpreter: PowerShell"
    echo "  Evidence source: memory_artifacts.txt if PowerShell activity is present"
    echo
    echo "T1003.001 - OS Credential Dumping: LSASS Memory"
    echo "  Evidence source: memory_artifacts.txt if LSASS/credential-access"
    echo "  modules or related evidence are observed"
    echo
    echo "T1071.001 - Application Layer Protocol: Web Protocols"
    echo "  Evidence source: memory network connections if HTTP/HTTPS C2 is observed"
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 10. STATUS / CONFIDENCE GUIDANCE
# ------------------------------------------------------------

{
    echo "------------------------------------------------------------"
    echo "10. FINDING STATUS AND CONFIDENCE"
    echo "------------------------------------------------------------"
    echo
    echo "KNOWN:"
    echo "  Indicator already exists in the HEALTHBANE IOC database."
    echo
    echo "NEW:"
    echo "  Indicator was observed in memory but is not present in the IOC database."
    echo "  NEW does NOT automatically mean malicious."
    echo
    echo "MODIFIED:"
    echo "  Related to a known indicator but appears as a variant or modified form."
    echo
    echo "CONFIRMED:"
    echo "  Direct evidence supported by at least two independent sources."
    echo
    echo "PROBABLE:"
    echo "  Strong evidence from one source with supporting context."
    echo
    echo "POSSIBLE:"
    echo "  Technique is logically consistent, but evidence is limited or ambiguous."
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# 11. ANALYSIS LIMITATIONS
# ------------------------------------------------------------

{
    echo "------------------------------------------------------------"
    echo "11. ANALYSIS LIMITATIONS"
    echo "------------------------------------------------------------"
    echo
    echo "This script performs initial text-based correlation."
    echo
    echo "Important:"
    echo "  - A NEW IOC is not automatically malicious."
    echo "  - A process name alone does not prove execution by HEALTHBANE."
    echo "  - A loaded DLL alone does not prove credential dumping."
    echo "  - A network connection alone does not prove C2."
    echo "  - Scheduled task evidence should be correlated with disk and"
    echo "    previous investigation evidence."
    echo "  - Final CONFIRMED findings require independent supporting evidence."
    echo
} >> "$REPORT"

# ------------------------------------------------------------
# Finish
# ------------------------------------------------------------

echo "============================================================" >> "$REPORT"
echo "END OF MEMORY ANALYSIS" >> "$REPORT"
echo "============================================================" >> "$REPORT"

echo
echo "[+] Memory analysis completed."
echo "[+] Report created:"
echo "    $REPORT"
echo
echo "[+] Preview:"
echo

# Show first part of report.
head -80 "$REPORT"
