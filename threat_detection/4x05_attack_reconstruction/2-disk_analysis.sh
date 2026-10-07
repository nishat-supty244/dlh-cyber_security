#!/bin/bash

# ============================================================
# Task 2 - Disk Forensics Analysis
# Project: 4x05 Attack Reconstruction
# Host: WS-RECV-03
#
# Purpose:
#   Analyze disk forensic evidence to identify:
#   1. Recovered deleted files
#   2. Prefetch execution history
#   3. Scheduled task persistence
#   4. Registry persistence
#   5. NTFS $MFT timeline
#   6. Anti-forensics activity
#   7. Data staging and archive activity
#
# Required tools:
#   grep, sort, uniq, wc, date, diff
# ============================================================

set -u

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

DISK_FILE="$PROJECT_DIR/ir_evidence/disk_forensics_report.txt"
TOPOLOGY_FILE="$PROJECT_DIR/reference/network_topology.txt"

OUTPUT_DIR="$PROJECT_DIR/task2_output"
REPORT="$OUTPUT_DIR/disk_analysis_report.txt"

mkdir -p "$OUTPUT_DIR"

# ------------------------------------------------------------
# Check required files
# ------------------------------------------------------------

echo "[+] Checking evidence files..."

if [ ! -f "$DISK_FILE" ]; then
    echo "[ERROR] Disk forensic report not found:"
    echo "        $DISK_FILE"
    exit 1
fi

if [ ! -f "$TOPOLOGY_FILE" ]; then
    echo "[WARNING] Network topology file not found:"
    echo "          $TOPOLOGY_FILE"
    echo "          Prefetch cross-reference will be limited."
    echo
fi

echo "[+] Disk evidence: $DISK_FILE"

if [ -f "$TOPOLOGY_FILE" ]; then
    echo "[+] Network topology: $TOPOLOGY_FILE"
fi

echo

# ------------------------------------------------------------
# Start report
# ------------------------------------------------------------

{
    echo "================================================================"
    echo "   DISK FORENSICS ANALYSIS - WS-RECV-03"
    echo "   Source: ir_evidence/disk_forensics_report.txt"
    echo "   Analysis Date: $(date)"
    echo "================================================================"
    echo
} > "$REPORT"

# ------------------------------------------------------------
# Basic evidence statistics
# ------------------------------------------------------------

TOTAL_LINES=$(wc -l < "$DISK_FILE")

{
    echo "EVIDENCE STATISTICS"
    echo "-------------------"
    echo "Disk report lines: $TOTAL_LINES"
    echo
} >> "$REPORT"

# ============================================================
# 1. RECOVERED DELETED FILES
# ============================================================

echo "[+] Analyzing recovered deleted files..."

{
    echo "================================================================"
    echo "1. RECOVERED DELETED FILES"
    echo "================================================================"
    echo
} >> "$REPORT"

# Look for deleted/recovered file evidence.
DELETED_FILES=$(grep -Ein \
    'deleted|recovered|recoverable|carved|unallocated|original path|deleted timestamp' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$DELETED_FILES" ]; then
    echo "$DELETED_FILES" >> "$REPORT"
else
    echo "No recovered deleted-file indicators found." >> "$REPORT"
fi

echo >> "$REPORT"

# ------------------------------------------------------------
# Look specifically for likely staging/data files.
# ------------------------------------------------------------

{
    echo "Potential data-staging files:"
    echo
} >> "$REPORT"

STAGING_FILES=$(grep -Ein \
    'staging|stage|query.?results|patient|database|export|\.csv|\.zip|\.7z|\.rar|\.tar|archive|compressed' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$STAGING_FILES" ]; then
    echo "$STAGING_FILES" >> "$REPORT"
else
    echo "No obvious data-staging file indicators found." >> "$REPORT"
fi

echo >> "$REPORT"

# ============================================================
# 2. DATA STAGING ANALYSIS
# ============================================================

echo "[+] Analyzing possible data staging..."

{
    echo "================================================================"
    echo "2. DATA STAGING ANALYSIS"
    echo "================================================================"
    echo
} >> "$REPORT"

# Identify evidence related to patient records/database exports.
DATA_INDICATORS=$(grep -Ein \
    'patient|PHI|PII|medical|record|database|query|export|results|csv|sql|dump' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$DATA_INDICATORS" ]; then
    echo "$DATA_INDICATORS" >> "$REPORT"

    {
        echo
        echo "Assessment:"
        echo "  The evidence above should be reviewed for database query"
        echo "  results, patient records, PHI/PII, or exported datasets."
        echo
    } >> "$REPORT"

else

    echo "No direct patient-data staging indicators found." >> "$REPORT"

fi

# ============================================================
# 3. ARCHIVE / COMPRESSION ANALYSIS
# ============================================================

echo "[+] Searching for archive/compression activity..."

{
    echo "================================================================"
    echo "3. ARCHIVE / COMPRESSION ACTIVITY"
    echo "================================================================"
    echo
} >> "$REPORT"

ARCHIVE_EVIDENCE=$(grep -Ein \
    'zip|7z|rar|tar|gzip|archive|compressed|compression|Compress-Archive|makecab' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$ARCHIVE_EVIDENCE" ]; then

    echo "$ARCHIVE_EVIDENCE" >> "$REPORT"

    {
        echo
        echo "ATT&CK:"
        echo "  T1560.001 - Archive Collected Data: Archive via Utility"
        echo
    } >> "$REPORT"

else

    echo "No archive/compression evidence found." >> "$REPORT"

fi

# ============================================================
# 4. PREFETCH ANALYSIS
# ============================================================

echo "[+] Analyzing Prefetch entries..."

{
    echo "================================================================"
    echo "4. PREFETCH ANALYSIS"
    echo "================================================================"
    echo
    echo "Programs executed on WS-RECV-03:"
    echo
} >> "$REPORT"

PREFETCH=$(grep -Ein \
    'prefetch|first execution|last execution|first exec|last exec|\.pf\b' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$PREFETCH" ]; then
    echo "$PREFETCH" >> "$REPORT"
else
    echo "No Prefetch entries found." >> "$REPORT"
fi

echo >> "$REPORT"

# ------------------------------------------------------------
# Search specifically for tools that are suspicious on a
# records department workstation.
# ------------------------------------------------------------

{
    echo "Potentially inappropriate remote administration /"
    echo "lateral movement tools:"
    echo
} >> "$REPORT"

SUSPICIOUS_TOOLS=$(grep -Ein \
    'psexec|paexec|wmic|wmiexec|psexesvc|remote.?admin|anydesk|teamviewer|radmin|putty|plink|ssh|winrs|powershell|bitsadmin' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$SUSPICIOUS_TOOLS" ]; then
    echo "$SUSPICIOUS_TOOLS" >> "$REPORT"
else
    echo "No suspicious remote-administration tools identified." >> "$REPORT"
fi

echo >> "$REPORT"

# ============================================================
# 5. PREFETCH CROSS-REFERENCE WITH NETWORK TOPOLOGY
# ============================================================

echo "[+] Cross-referencing suspicious tools with network topology..."

{
    echo "================================================================"
    echo "5. PREFETCH / NETWORK TOPOLOGY CROSS-REFERENCE"
    echo "================================================================"
    echo
} >> "$REPORT"

if [ -f "$TOPOLOGY_FILE" ]; then

    echo "Network topology evidence:" >> "$REPORT"
    echo >> "$REPORT"

    # Search for workstation role and expected services.
    grep -Ein \
        'WS-RECV-03|records|workstation|server|SMB|445|RDP|3389|SSH|22|remote|administration' \
        "$TOPOLOGY_FILE" \
        >> "$REPORT" 2>/dev/null || \
        echo "No matching topology entries found." >> "$REPORT"

    echo >> "$REPORT"

    echo "Suspicious tools found in disk evidence:" >> "$REPORT"
    echo >> "$REPORT"

    grep -Ein \
        'psexec|paexec|wmic|wmiexec|psexesvc|remote.?admin|anydesk|teamviewer|radmin|plink|winrs' \
        "$DISK_FILE" \
        >> "$REPORT" 2>/dev/null || \
        echo "No remote administration tools found." >> "$REPORT"

else

    echo "Network topology unavailable." >> "$REPORT"
    echo "Manual cross-reference required." >> "$REPORT"

fi

echo >> "$REPORT"

# ============================================================
# 6. SCHEDULED TASK XML
# ============================================================

echo "[+] Extracting scheduled task evidence..."

{
    echo "================================================================"
    echo "6. SCHEDULED TASK XML"
    echo "================================================================"
    echo
} >> "$REPORT"

TASK_XML=$(grep -Ein \
    'scheduled task|task xml|taskname|task name|trigger|startboundary|action|registration|powershell.*enc|executionpolicy|healthsync' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$TASK_XML" ]; then

    echo "$TASK_XML" >> "$REPORT"

    {
        echo
        echo "ATT&CK Mapping:"
        echo "  T1053.005 - Scheduled Task/Job: Scheduled Task"
        echo
        echo "Correlation:"
        echo "  Compare this task definition with the scheduled task found"
        echo "  in memory analysis (Task 1)."
    } >> "$REPORT"

else

    echo "No scheduled-task XML evidence found." >> "$REPORT"

fi

echo >> "$REPORT"

# ============================================================
# 7. REGISTRY PERSISTENCE
# ============================================================

echo "[+] Searching registry persistence..."

{
    echo "================================================================"
    echo "7. REGISTRY PERSISTENCE"
    echo "================================================================"
    echo
} >> "$REPORT"

REGISTRY=$(grep -Ein \
    'HKLM|HKCU|RunOnce|\\Run|registry|service registration|service key|ImagePath|CurrentVersion' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$REGISTRY" ]; then
    echo "$REGISTRY" >> "$REPORT"
else
    echo "No registry persistence indicators found." >> "$REPORT"
fi

echo >> "$REPORT"

# ============================================================
# 8. NTFS $MFT TIMELINE
# ============================================================

echo "[+] Extracting NTFS \$MFT timeline..."

{
    echo "================================================================"
    echo "8. NTFS \$MFT TIMELINE"
    echo "================================================================"
    echo
    echo "Attack window: Feb 04 - Feb 12"
    echo
} >> "$REPORT"

MFT_TIMELINE=$(grep -Ein \
    '\$MFT|MFT|created|creation|modified|modification|timestamp|C:\\Users\\Public|C:\\Windows\\Temp|Feb 0[4-9]|Feb 1[0-2]' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$MFT_TIMELINE" ]; then
    echo "$MFT_TIMELINE" >> "$REPORT"
else
    echo "No NTFS timeline evidence found." >> "$REPORT"
fi

echo >> "$REPORT"

# ============================================================
# 9. ANTI-FORENSICS
# ============================================================

echo "[+] Searching for anti-forensics indicators..."

{
    echo "================================================================"
    echo "9. ANTI-FORENSICS INDICATORS"
    echo "================================================================"
    echo
} >> "$REPORT"

ANTI_FORENSICS=$(grep -Ein \
    'anti.?forensic|event log|security log|log deletion|log cleared|cleared logs|wevtutil|eventlog|timestamp manipulation|timestomp|artifact removal|artifact deleted|evidence removal|log gap|missing events' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$ANTI_FORENSICS" ]; then

    echo "$ANTI_FORENSICS" >> "$REPORT"

    echo >> "$REPORT"
    echo "Potential ATT&CK mapping:" >> "$REPORT"
    echo "  T1070.001 - Clear Windows Event Logs" >> "$REPORT"
    echo "  T1070.006 - Timestomp (only if timestamp manipulation is confirmed)" >> "$REPORT"

else

    echo "No anti-forensics indicators found." >> "$REPORT"

fi

echo >> "$REPORT"

# ============================================================
# 10. FILE DELETION / ARTIFACT REMOVAL
# ============================================================

echo "[+] Checking for artifact removal..."

{
    echo "================================================================"
    echo "10. ARTIFACT REMOVAL"
    echo "================================================================"
    echo
} >> "$REPORT"

REMOVAL=$(grep -Ein \
    'deleted|deletion|removed|removal|erase|wiped|cleanup|cleaned|recovered deleted|unallocated' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$REMOVAL" ]; then
    echo "$REMOVAL" >> "$REPORT"
else
    echo "No explicit artifact-removal evidence found." >> "$REPORT"
fi

echo >> "$REPORT"

# ============================================================
# 11. ATT&CK SUMMARY
# ============================================================

echo "[+] Creating ATT&CK summary..."

{
    echo "================================================================"
    echo "11. ATT&CK TECHNIQUE SUMMARY"
    echo "================================================================"
    echo
    echo "T1053.005 - Scheduled Task/Job: Scheduled Task"
    echo "  Use when scheduled-task persistence is supported by evidence."
    echo
    echo "T1074.001 - Data Staged: Local Data Staging"
    echo "  Use when collected data is stored locally before exfiltration."
    echo
    echo "T1560.001 - Archive Collected Data: Archive via Utility"
    echo "  Use when collected data is compressed/archived."
    echo
    echo "T1070.001 - Indicator Removal: Clear Windows Event Logs"
    echo "  Use only when evidence supports event-log clearing."
    echo
    echo "T1070.006 - Indicator Removal: Timestomp"
    echo "  Use only when timestamp manipulation is actually identified."
    echo
} >> "$REPORT"

# ============================================================
# 12. STAGING COMPLETION ASSESSMENT
# ============================================================

echo "[+] Assessing whether staging appears complete or interrupted..."

{
    echo "================================================================"
    echo "12. STAGING COMPLETION ASSESSMENT"
    echo "================================================================"
    echo
} >> "$REPORT"

STAGING_TIMELINE=$(grep -Ein \
    'staging|query.?results|export|archive|zip|compressed|deleted|exfil|exfiltration' \
    "$DISK_FILE" \
    2>/dev/null || true)

if [ -n "$STAGING_TIMELINE" ]; then

    echo "$STAGING_TIMELINE" >> "$REPORT"

    {
        echo
        echo "Assessment guidance:"
        echo "  - Created/exported files indicate possible collection."
        echo "  - ZIP/7z/RAR/archive files indicate possible compression."
        echo "  - Deleted staging files may indicate cleanup after staging."
        echo "  - Presence of staging does NOT by itself prove successful exfiltration."
        echo "  - Confirm exfiltration using network evidence."
    } >> "$REPORT"

else

    echo "Insufficient evidence to assess staging completion." >> "$REPORT"

fi

echo >> "$REPORT"

# ============================================================
# 13. CORRELATION WITH TASK 1
# ============================================================

{
    echo "================================================================"
    echo "13. CORRELATION WITH TASK 1 - MEMORY ANALYSIS"
    echo "================================================================"
    echo
    echo "Important cross-evidence checks:"
    echo
    echo "1. Scheduled task:"
    echo "   Compare disk Task XML with memory scheduled-task evidence."
    echo
    echo "2. PowerShell:"
    echo "   Compare PowerShell execution in Prefetch with memory processes."
    echo
    echo "3. Network tools:"
    echo "   Compare PsExec/remote tools with memory network connections."
    echo
    echo "4. Staging:"
    echo "   Compare staged files with network traffic identified in later tasks."
    echo
    echo "5. Persistence:"
    echo "   Compare scheduled task creation time with the attack timeline."
    echo
} >> "$REPORT"

# ============================================================
# 14. IMPORTANT LIMITATIONS
# ============================================================

{
    echo "================================================================"
    echo "14. ANALYSIS LIMITATIONS"
    echo "================================================================"
    echo
    echo "This script performs initial text-based forensic extraction."
    echo
    echo "Do NOT automatically conclude:"
    echo
    echo "  - A deleted file was successfully exfiltrated."
    echo "  - A Prefetch entry proves malicious activity."
    echo "  - A ZIP file proves patient data was inside it."
    echo "  - A log gap automatically proves log deletion."
    echo "  - A timestamp difference automatically proves timestomping."
    echo
    echo "These findings must be correlated with independent evidence."
    echo
} >> "$REPORT"

# ============================================================
# Finish
# ============================================================

{
    echo "================================================================"
    echo "END OF DISK FORENSICS ANALYSIS"
    echo "================================================================"
} >> "$REPORT"

echo
echo "[+] Disk forensic analysis completed."
echo "[+] Report created:"
echo "    $REPORT"
echo
echo "[+] Preview:"
echo

head -100 "$REPORT"
