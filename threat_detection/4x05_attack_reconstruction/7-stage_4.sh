
#!/bin/bash

# ================================================================
# HEALTHBANE ATTACK RECONSTRUCTION
# Task 7: Stage 4 - Lateral Movement, Data Staging, Containment
# ================================================================
#
# Reconstructs Stage 4 by correlating:
#   4x04 - Threat hunting findings
#   T1   - Memory analysis
#   T2   - Disk forensics
#   T3   - Firewall session analysis
#   IR   - Original incident-response evidence
#
# Important:
# This script extracts evidence for analyst review.
# It does not invent credentials, timestamps, host pivots,
# data sizes, or a containment time.
# ================================================================

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PREVIOUS_DIR="$BASE_DIR/previous_findings"
IR_DIR="$BASE_DIR/ir_evidence"

HUNT="$PREVIOUS_DIR/4x04_hunting_report.txt"
MEMORY="$IR_DIR/memory_artifacts.txt"
DISK="$IR_DIR/disk_forensics_report.txt"
FIREWALL="$IR_DIR/firewall_sessions_ws_recv_03.json"
IR_NOTES="$IR_DIR/ir_team_notes.txt"

T1_OUTPUT="$BASE_DIR/task1_output/memory_analysis_report.txt"
T2_OUTPUT="$BASE_DIR/task2_output/disk_analysis_report.txt"
T3_OUTPUT="$BASE_DIR/task3_output/firewall_analysis_report.txt"

OUTPUT_DIR="$BASE_DIR/task7_output"
OUTPUT_FILE="$OUTPUT_DIR/stage_4_reconstruction.txt"

mkdir -p "$OUTPUT_DIR"

section() {
    printf '\n============================================================\n'
    printf '%s\n' "$1"
    printf '============================================================\n'
}

check_source() {
    local file="$1"
    local name="$2"

    if [[ -f "$file" ]]; then
        printf '[AVAILABLE] %s\n' "$name"
    else
        printf '[MISSING]   %s -- %s\n' "$name" "$file"
    fi
}

show_matches() {
    local file="$1"
    local pattern="$2"

    if [[ -f "$file" ]]; then
        grep -Ein "$pattern" "$file" 2>/dev/null || true
    else
        printf '[NO DATA] Source file is unavailable: %s\n' "$file"
    fi
}

# Capture all report output to a file and display it on screen.
exec > >(tee "$OUTPUT_FILE") 2>&1

section "ATTACK RECONSTRUCTION: Stage 4"
echo "Lateral Movement, Data Staging, and Containment"

# ------------------------------------------------
# 1. Source availability
# ------------------------------------------------

section "1. EVIDENCE SOURCE INVENTORY"

check_source "$HUNT" "4x04 threat hunting report"
check_source "$MEMORY" "IR memory artifacts"
check_source "$DISK" "IR disk forensics report"
check_source "$FIREWALL" "IR firewall session data"
check_source "$IR_NOTES" "IR team notes"
check_source "$T1_OUTPUT" "Task 1 memory analysis output"
check_source "$T2_OUTPUT" "Task 2 disk analysis output"
check_source "$T3_OUTPUT" "Task 3 firewall analysis output"

# ------------------------------------------------
# 2. Lateral movement
# ------------------------------------------------

section "2. LATERAL MOVEMENT CHAIN"

echo "Search for source hosts, target hosts, tools, accounts and times."
echo "Compare findings across the hunt, memory and firewall sources."

PATTERN='PsExec|PSEXEC|WMI|WinRM|PSRemoting|PowerShell Remoting|lateral movement|remote execution|svc_healthsync|SRV-HEALTH-DB|WS-RECV-03|logon|admin share|T1021|T1047'

for source in "$HUNT" "$T1_OUTPUT" "$T2_OUTPUT" "$T3_OUTPUT" "$IR_NOTES"; do
    echo
    echo "--- $source ---"
    show_matches "$source" "$PATTERN"
done

echo
echo "--- Firewall sessions involving internal systems ---"

if [[ -f "$FIREWALL" ]]; then
    if jq -e 'if type == "array" then true
              elif (.sessions | type) == "array" then true
              else false end' "$FIREWALL" >/dev/null 2>&1; then

        jq -r '
          def sessions:
            if type == "array" then .
            else .sessions
            end;

          sessions[]
          | (.src_ip // .source_ip // .src // "UNKNOWN") as $src
          | (.dst_ip // .destination_ip // .dst // "UNKNOWN") as $dst
          | select(($src | startswith("10.")) and ($dst | startswith("10.")))
          | [
              (.timestamp // .time // .start_time // "UNKNOWN_TIME"),
              $src,
              $dst,
              (.dst_port // .destination_port // .port // "UNKNOWN_PORT"),
              (.protocol // "UNKNOWN_PROTOCOL"),
              (.bytes_out // .outbound_bytes // 0)
            ]
          | @tsv
        ' "$FIREWALL" 2>/dev/null | sort || true
    else
        echo "[WARNING] Unsupported JSON structure; inspect the firewall file."
    fi
else
    echo "[NO DATA] Firewall session file unavailable."
fi

echo
echo "ATT&CK references to validate against evidence:"
echo "  T1021.002 - SMB/Windows Admin Shares (if supported)"
echo "  T1047     - Windows Management Instrumentation (if supported)"
echo "  T1021.006 - Windows Remote Management (if supported)"
echo "  T1021.001 - Remote Desktop Protocol (if supported)"
echo
echo "A firewall connection alone does not prove remote execution."
echo "Confirm tool/account/host details using hunt and endpoint evidence."

# ------------------------------------------------
# 3. Credential access
# ------------------------------------------------

section "3. CREDENTIAL ACCESS"

echo "Look for LSASS access, credential dumping, account names,"
echo "authentication events and possible additional credentials."

CREDENTIAL_PATTERN='LSASS|lsass|credential|sekurlsa|mimikatz|dump|svc_healthsync|password|NTLM|Kerberos|logon|T1003\.001|SAM|security authority'

for source in "$HUNT" "$MEMORY" "$T1_OUTPUT" "$DISK" "$IR_NOTES"; do
    echo
    echo "--- $source ---"
    show_matches "$source" "$CREDENTIAL_PATTERN"
done

echo
echo "Assessment rules:"
echo "  * LSASS access is not, by itself, proof that credentials were recovered."
echo "  * A service account appearing in a report does not prove its"
echo "    password or secret was successfully extracted."
echo "  * Report additional compromised accounts only when supported"
echo "    by explicit evidence."
echo "  * Do not print passwords, tokens, or other secret values."

# ------------------------------------------------
# 4. Data access and staging
# ------------------------------------------------

section "4. DATA ACCESS AND STAGING"

DATA_PATTERN='SRV-HEALTH-DB|database|patient|PHI|insurance|query_results|staging|export|archive|\.zip|\.7z|\.rar|\.csv|compressed|compression|T1005|T1074\.001|T1560\.001'

for source in "$HUNT" "$DISK" "$T2_OUTPUT" "$IR_NOTES"; do
    echo
    echo "--- $source ---"
    show_matches "$source" "$DATA_PATTERN"
done

echo
echo "--- Relevant file timeline evidence ---"

show_matches "$DISK" \
    'MFT|created|creation time|modified|deleted|recovered|query_results|staging_export|\.zip|\.csv'

echo
echo "Data staging interpretation:"
echo "  1. Identify where each recovered/staged file was located."
echo "  2. Compare file creation times with lateral movement times."
echo "  3. Check whether database query results were copied to WS-RECV-03."
echo "  4. Check whether archives were created after the data files."
echo "  5. Compare archive sizes with firewall outbound byte counts."
echo
echo "Do not conclude that data was exfiltrated merely because archives"
echo "exist. Confirm whether matching outbound transfers occurred."

# ------------------------------------------------
# 5. Persistence and anti-forensics
# ------------------------------------------------

section "5. PERSISTENCE AND OPERATIONAL SECURITY"

echo "--- Scheduled task / persistence evidence ---"

PERSISTENCE_PATTERN='scheduled task|HealthSync Update|HealthSyncUpdate|schtasks|Task Scheduler|T1053\.005|RunOnce|CurrentVersion\\Run|service registration|persistence'

for source in "$MEMORY" "$DISK" "$T1_OUTPUT" "$T2_OUTPUT" "$HUNT"; do
    echo
    echo "--- $source ---"
    show_matches "$source" "$PERSISTENCE_PATTERN"
done

echo
echo "--- Anti-forensics evidence ---"

ANTI_PATTERN='anti-forensic|event log cleared|log deletion|wevtutil|timestamp manipulation|timestomp|artifact removal|deleted log|Security log gap|T1070\.001|T1070\.006'

for source in "$DISK" "$T2_OUTPUT" "$HUNT" "$IR_NOTES"; do
    echo
    echo "--- $source ---"
    show_matches "$source" "$ANTI_PATTERN"
done

echo
echo "Operational security assessment:"
echo "  Determine which actions may have blended into normal administration."
echo "  Use evidence to identify what exposed the attacker: unusual account"
echo "  usage, off-hours execution, unexpected source host, periodic traffic,"
echo "  suspicious files, or other observed anomalies."
echo
echo "Do not claim log clearing or timestamp manipulation unless the"
echo "forensic evidence supports it."

# ------------------------------------------------
# 6. Containment
# ------------------------------------------------

section "6. CONTAINMENT MOMENT"

CONTAINMENT_PATTERN='containment|isolat|quarantin|incident response|hunt detected|hunt report|escalat|disabled account|blocked|remediat|Feb 12|2024-02-12'

for source in "$HUNT" "$IR_NOTES" "$T3_OUTPUT"; do
    echo
    echo "--- $source ---"
    show_matches "$source" "$CONTAINMENT_PATTERN"
done

echo
echo "Questions to resolve from the evidence:"
echo "  * What was the last confirmed malicious action before containment?"
echo "  * When was the hunt finding escalated to incident response?"
echo "  * When was WS-RECV-03 isolated, if documented?"
echo "  * When were memory and disk evidence collected?"
echo "  * Was staging still in progress at containment?"
echo
echo "The hunt detection time is not automatically the containment time."
echo "Use the actual incident-response notes or timestamps."

# ------------------------------------------------
# 7. Firewall and exfiltration correlation
# ------------------------------------------------

section "7. EXFILTRATION AND FIREWALL CORRELATION"

if [[ -f "$T3_OUTPUT" ]]; then
    show_matches "$T3_OUTPUT" \
        'exfil|bytes_out|outbound|large transfer|staging|34\.4|unknown IP|secondary C2|assessment'
else
    echo "[NO DATA] Task 3 firewall report unavailable."
fi

echo
echo "If original firewall data is available, inspect outbound sessions"
echo "during the staging period and identify the external destinations."
echo "Compare their byte counts with the actual staged-file sizes."
echo
echo "Do not estimate how many sessions or hours remained before"
echo "exfiltration unless the evidence supports a measurable rate/pattern."

# ------------------------------------------------
# 8. Confidence and gaps
# ------------------------------------------------

section "8. CONFIDENCE ASSESSMENT"

echo "CONFIRMED:"
echo "  Direct evidence from at least two independent sources."
echo
echo "PROBABLE:"
echo "  Strong evidence from one source with supporting context."
echo
echo "POSSIBLE:"
echo "  Plausible interpretation with incomplete or ambiguous evidence."
echo
echo "For every pivot and major event, record:"
echo "  Timestamp | Source host | Target host | Tool | Account"
echo "  Evidence sources | ATT&CK technique | Confidence"
echo
echo "Record hunt-missed activity only when IR evidence reveals a step"
echo "that is absent from, or not identified by, the 4x04 hunt report."

# ------------------------------------------------
# 9. Final reconstruction checklist
# ------------------------------------------------

section "9. STAGE 4 RECONSTRUCTION CHECKLIST"

cat <<'CHECKLIST'
[ ] Reconstruct every lateral movement pivot in chronological order.
[ ] Identify the source host and each target host.
[ ] Identify the tool and credential for each pivot where evidence exists.
[ ] Correlate the svc_healthsync LSASS finding with memory evidence.
[ ] Assess whether other credentials were compromised.
[ ] Identify the systems and data accessed.
[ ] Establish whether data moved to WS-RECV-03 before archiving.
[ ] Correlate the scheduled task with the attack timeline.
[ ] Document supported anti-forensics findings.
[ ] Establish the detection, escalation and containment timestamps.
[ ] Assess exfiltration using actual firewall evidence.
[ ] Assign confidence and cite source files for every major event.
CHECKLIST

section "10. OUTPUT"

echo "Reconstruction evidence saved to:"
echo "  $OUTPUT_FILE"
echo
echo "This is an evidence extraction report, not a final verified narrative."
echo "Use the extracted evidence to write the chronological Stage 4 account."
echo "================================================================"
