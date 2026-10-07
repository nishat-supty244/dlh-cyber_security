#!/bin/bash

# ================================================================
# HEALTHBANE Attack Reconstruction
# Task 5: Stage 1-2 Reconstruction
# ================================================================
#
# Purpose:
# Reconstruct:
#   Stage 1 - Initial Access / Phishing
#   Stage 2 - C2 Establishment
#
# Sources:
#   4x00 - Phishing investigation
#   4x01 - Network forensics
#   4x02 - Attack mapping / intelligence context
#   T3   - Firewall analysis
#   IR   - Firewall session evidence
#
# IMPORTANT:
#   This script does NOT invent timestamps, IPs, or findings.
#   It extracts evidence from the available project files.
# ================================================================

set -uo pipefail

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PREVIOUS_DIR="$BASE_DIR/previous_findings"
IR_DIR="$BASE_DIR/ir_evidence"

PHISHING="$PREVIOUS_DIR/4x00_phishing_summary.txt"
NETWORK="$PREVIOUS_DIR/4x01_network_timeline.txt"
ATTACK_MAPPING="$PREVIOUS_DIR/4x02_attack_mapping.json"

FIREWALL="$IR_DIR/firewall_sessions_ws_recv_03.json"
IR_NOTES="$IR_DIR/ir_team_notes.txt"

T3_OUTPUT="$BASE_DIR/task3_output/firewall_analysis_report.txt"

OUTPUT_DIR="$BASE_DIR/task5_output"
OUTPUT_FILE="$OUTPUT_DIR/stages_1_2_reconstruction.txt"

mkdir -p "$OUTPUT_DIR"

# ------------------------------------------------
# Helper functions
# ------------------------------------------------

print_header() {
    echo "================================================================"
    echo "   ATTACK RECONSTRUCTION: Stages 1-2"
    echo "   Initial Access through C2 Establishment"
    echo "================================================================"
}

section() {
    echo
    echo "----------------------------------------------------------------"
    echo "$1"
    echo "----------------------------------------------------------------"
}

check_file() {
    local file="$1"
    local description="$2"

    if [ -f "$file" ]; then
        echo "[AVAILABLE] $description"
        echo "            $file"
    else
        echo "[MISSING]   $description"
        echo "            $file"
    fi
}

search_file() {
    local pattern="$1"
    local file="$2"

    if [ -f "$file" ]; then
        grep -Ein "$pattern" "$file" 2>/dev/null || true
    fi
}

# ------------------------------------------------
# Validate evidence sources
# ------------------------------------------------

print_header

section "1. EVIDENCE SOURCE CHECK"

check_file "$PHISHING" "4x00 Phishing Investigation"
check_file "$NETWORK" "4x01 Network Timeline"
check_file "$ATTACK_MAPPING" "4x02 Attack Mapping / Intelligence"
check_file "$FIREWALL" "IR Firewall Session Data"
check_file "$IR_NOTES" "IR Team Notes"
check_file "$T3_OUTPUT" "Task 3 Firewall Analysis"

# ------------------------------------------------
# STAGE 1
# Initial Access / Phishing
# ------------------------------------------------

section "2. STAGE 1 - INITIAL ACCESS (PHISHING)"

echo
echo "Goal:"
echo "  Reconstruct the phishing campaign and identify the"
echo "  credential-compromise event involving Diane."
echo

echo "---- Campaign / Email Evidence ----"

if [ -f "$PHISHING" ]; then

    search_file \
        "email|campaign|phishing|malicious|delivered|recipient|sender|subject" \
        "$PHISHING"

else
    echo "[NO DATA] 4x00 phishing summary is unavailable."
fi

echo
echo "---- Diane / Credential Compromise Evidence ----"

if [ -f "$PHISHING" ]; then

    search_file \
        "Diane|Marsh|click|clicked|credential|submitted|login|portal|WS-RECV-03" \
        "$PHISHING"

else
    echo "[NO DATA] Cannot reconstruct Diane's event without 4x00."
fi

echo
echo "---- Email Header / Authentication Evidence ----"

if [ -f "$PHISHING" ]; then

    search_file \
        "header|From:|To:|Received:|Return-Path|SPF|DKIM|DMARC|authentication" \
        "$PHISHING"

else
    echo "[NO DATA] Email header evidence unavailable."
fi

echo
echo "---- Phishing Domain / URL Evidence ----"

if [ -f "$PHISHING" ]; then

    search_file \
        "domain|URL|lookalike|typosquat|registration|Namecheap|Microsoft|Outlook|protection" \
        "$PHISHING"

else
    echo "[NO DATA] Domain evidence unavailable."
fi

echo
echo "---- Stage 1 ATT&CK Mapping ----"

echo "T1566.001 - Phishing: Spearphishing Link"
echo "  Required evidence:"
echo "    * Malicious email"
echo "    * Link/URL"
echo "    * Victim interaction"
echo

echo "T1078 - Valid Accounts"
echo "  Required evidence:"
echo "    * Credential harvesting"
echo "    * Credentials subsequently used"
echo "    * Authentication evidence"
echo

echo "Stage 1 confidence must be assigned from the actual evidence."
echo "Do NOT treat a phishing email alone as proof of credential use."

# ------------------------------------------------
# Stage 1 temporal anchor extraction
# ------------------------------------------------

section "3. STAGE 1 - TEMPORAL ANCHORS"

echo
echo "Potential timestamps from 4x00 involving Diane, clicks,"
echo "credential submission, or phishing activity:"
echo

if [ -f "$PHISHING" ]; then

    grep -Ein \
        "202[0-9][-/:][0-9]{1,2}[-/:][0-9]{1,2}|[0-9]{1,2}:[0-9]{2}(:[0-9]{2})?.*(UTC|GMT|CET|CEST)|timestamp|Diane|Marsh|click|submit" \
        "$PHISHING" 2>/dev/null || true

else
    echo "[NO DATA] 4x00 unavailable."
fi

echo
echo "Analyst requirement:"
echo "  Select the exact credential-exposure timestamp from the"
echo "  evidence above and cite the original source."

# ------------------------------------------------
# STAGE 2
# C2 Establishment
# ------------------------------------------------

section "4. STAGE 2 - C2 ESTABLISHMENT"

echo
echo "Goal:"
echo "  Correlate 4x01 PCAP/network findings with the 14-day"
echo "  firewall session evidence."
echo

echo "---- 4x01 C2 / Beacon Evidence ----"

if [ -f "$NETWORK" ]; then

    search_file \
        "C2|beacon|beaconing|interval|5.?minute|300|HTTPS|HTTP|443|8443|POST|connection|destination" \
        "$NETWORK"

else
    echo "[NO DATA] 4x01 network timeline unavailable."
fi

echo
echo "---- Firewall C2 Evidence ----"

if [ -f "$FIREWALL" ]; then

    echo "Firewall session count:"
    jq '
        if type == "array" then length
        elif .sessions then (.sessions | length)
        else 0
        end
    ' "$FIREWALL" 2>/dev/null || echo "[ERROR] Unable to parse firewall JSON."

    echo
    echo "Potential HTTPS / C2 sessions:"
    jq -r '
        def sessions:
            if type == "array" then .
            elif .sessions then .sessions
            else []
            end;

        sessions[]
        | select(
            ((.dst_port // .destination_port // .port // "") | tostring) == "443"
            or
            ((.dst_port // .destination_port // .port // "") | tostring) == "8443"
        )
        | [
            (.timestamp // .time // .start_time // "UNKNOWN_TIME"),
            (.src_ip // .source_ip // "UNKNOWN_SRC"),
            (.dst_ip // .destination_ip // "UNKNOWN_DST"),
            (.dst_port // .destination_port // .port // "UNKNOWN_PORT"),
            (.protocol // "UNKNOWN_PROTOCOL"),
            (.bytes_out // .outbound_bytes // 0),
            (.bytes_in // .inbound_bytes // 0)
          ]
        | @tsv
    ' "$FIREWALL" 2>/dev/null || true

else
    echo "[NO DATA] Firewall session file unavailable."
fi

# ------------------------------------------------
# 5-minute beacon analysis
# ------------------------------------------------

section "5. C2 BEACON INTERVAL ANALYSIS"

echo
echo "4x01 evidence referring to beacon intervals:"
echo

if [ -f "$NETWORK" ]; then

    grep -Ein \
        "5.?minute|300.?second|interval|beacon|periodic|regular|every 5|300" \
        "$NETWORK" 2>/dev/null || true

else
    echo "[NO DATA] 4x01 unavailable."
fi

echo
echo "Firewall sessions occurring on common C2 ports:"
echo

if [ -f "$FIREWALL" ]; then

    jq -r '
        def sessions:
            if type == "array" then .
            elif .sessions then .sessions
            else []
            end;

        sessions[]
        | select(
            ((.dst_port // .destination_port // .port // "") | tostring) == "443"
            or
            ((.dst_port // .destination_port // .port // "") | tostring) == "8443"
        )
        | [
            (.timestamp // .time // .start_time // "UNKNOWN"),
            (.dst_ip // .destination_ip // "UNKNOWN"),
            (.dst_port // .destination_port // .port // "UNKNOWN"),
            (.protocol // "UNKNOWN")
          ]
        | @tsv
    ' "$FIREWALL" 2>/dev/null \
    | sort

fi

echo
echo "Interpretation:"
echo "  A 5-minute pattern in 4x01 should be compared with the"
echo "  firewall timestamps. Matching periodic sessions increase"
echo "  confidence that both sources represent the same C2."

# ------------------------------------------------
# Secondary C2 investigation
# ------------------------------------------------

section "6. SECONDARY C2 INVESTIGATION"

echo
echo "Searching Task 3 analysis for unknown/new external IPs:"
echo

if [ -f "$T3_OUTPUT" ]; then

    grep -Ein \
        "unknown|new|NOT IN IOC|secondary C2|8443|first session|first seen|last seen" \
        "$T3_OUTPUT" 2>/dev/null || true

else
    echo "[NO DATA] Task 3 output unavailable."
fi

echo
echo "Searching IR notes for the firewall-flagged IP:"
echo

if [ -f "$IR_NOTES" ]; then

    grep -Ein \
        "unknown IP|unknown_ip|secondary|C2|8443|James Chen|firewall" \
        "$IR_NOTES" 2>/dev/null || true

else
    echo "[NO DATA] IR notes unavailable."
fi

echo
echo "Firewall external destinations on port 8443:"
echo

if [ -f "$FIREWALL" ]; then

    jq -r '
        def sessions:
            if type == "array" then .
            elif .sessions then .sessions
            else []
            end;

        sessions[]
        | select(
            ((.dst_port // .destination_port // .port // "") | tostring) == "8443"
        )
        | [
            (.timestamp // .time // .start_time // "UNKNOWN"),
            (.src_ip // .source_ip // "UNKNOWN"),
            (.dst_ip // .destination_ip // "UNKNOWN"),
            (.protocol // "UNKNOWN"),
            (.bytes_out // .outbound_bytes // 0),
            (.bytes_in // .inbound_bytes // 0)
          ]
        | @tsv
    ' "$FIREWALL" 2>/dev/null | sort

else
    echo "[NO DATA] Firewall data unavailable."
fi

echo
echo "Secondary C2 assessment:"
echo
echo "  If the secondary IP first appears AFTER the Stage 2 C2"
echo "  timestamp, it should NOT be described as active during"
echo "  the initial C2 establishment."
echo
echo "  If it appears during Stage 2 and shows the same periodic"
echo "  behavior, investigate it as a possible secondary C2."
echo
echo "  A firewall-only observation should normally receive"
echo "  PROBABLE confidence unless another independent source"
echo "  confirms its role."

# ------------------------------------------------
# ATT&CK correlation
# ------------------------------------------------

section "7. ATT&CK TECHNIQUE CORRELATION"

echo
echo "T1566.001 - Phishing: Spearphishing Link"
echo "  Evidence source: 4x00 phishing investigation"
echo

echo "T1078 - Valid Accounts"
echo "  Evidence source: credential compromise + subsequent authentication"
echo "  Requirement: do not mark CONFIRMED without evidence of account use."
echo

echo "T1071.001 - Application Layer Protocol: Web Protocols"
echo "  Evidence source: 4x01 network traffic + firewall sessions"
echo

echo "T1573.001 - Encrypted Channel: Symmetric Cryptography"
echo "  Evidence source: encrypted C2 traffic, if supported by 4x01 evidence"
echo "  Requirement: HTTPS alone does not automatically prove the exact"
echo "              cryptographic technique; use the existing ATT&CK mapping"
echo "              if supported."
echo

echo "T1568 - Dynamic Resolution"
echo "  Only include if 4x01 / 4x02 evidence demonstrates dynamic"
echo "  resolution or attacker-controlled resolution behavior."

# ------------------------------------------------
# Confidence assessment
# ------------------------------------------------

section "8. CONFIDENCE ASSESSMENT"

echo
echo "CONFIRMED"
echo "  Direct evidence from two independent sources, or"
echo "  exceptionally strong primary evidence."
echo

echo "PROBABLE"
echo "  Strong evidence from one source with supporting context."
echo

echo "POSSIBLE"
echo "  Technique/activity is plausible, but evidence is limited"
echo "  or ambiguous."
echo

echo "Recommended reconstruction events:"
echo
echo "  1. Phishing campaign delivery"
echo "     Source: 4x00"
echo "     Technique: T1566.001"
echo
echo "  2. Diane clicks credential-harvesting link"
echo "     Source: 4x00"
echo "     Technique: T1566.001"
echo
echo "  3. Credentials exposed"
echo "     Source: 4x00 + authentication evidence if available"
echo "     Technique: T1078"
echo
echo "  4. First C2 beacon"
echo "     Source: 4x01 + firewall"
echo "     Technique: T1071.001"
echo
echo "  5. Encrypted C2 channel"
echo "     Source: 4x01"
echo "     Technique: T1573.001 if evidence supports it"
echo
echo "  6. Secondary C2"
echo "     Source: T3 firewall analysis"
echo "     Confidence depends on whether another source confirms it."

# ------------------------------------------------
# Reconstruction summary
# ------------------------------------------------

section "9. STAGE 1-2 RECONSTRUCTION SUMMARY"

echo
echo "The final narrative must answer these questions:"
echo

echo "STAGE 1:"
echo "  * When was the phishing campaign active?"
echo "  * Which email reached Diane?"
echo "  * When did Diane click?"
echo "  * When were credentials exposed?"
echo "  * What evidence proves the credential-harvesting site"
echo "    was attacker-controlled?"
echo

echo "STAGE 2:"
echo "  * When was the first C2 beacon?"
echo "  * What was the C2 destination?"
echo "  * Was the beacon approximately every 5 minutes?"
echo "  * Does the firewall independently show the same behavior?"
echo "  * When did the secondary C2 IP first appear?"
echo "  * Was it active during Stage 2 or only later?"
echo "  * Are timestamp differences explained by timezone/clock skew?"
echo

echo "IMPORTANT:"
echo "  Do not use the example dates, IP addresses, byte counts,"
echo "  or conclusions from the assignment text as actual findings."
echo "  They are only examples."

# ------------------------------------------------
# Save complete output
# ------------------------------------------------

{
    print_header
    echo
    echo "Generated by: 5-stages_1_2.sh"
    echo "Project: HEALTHBANE Attack Reconstruction"
    echo "Sources: 4x00, 4x01, 4x02, IR Firewall, Task 3"
    echo
    echo "NOTE:"
    echo "This output is an evidence extraction/reconstruction aid."
    echo "Final confidence decisions must be based on the actual evidence."
} > "$OUTPUT_FILE"

echo
echo "================================================================"
echo "Output saved to:"
echo "  $OUTPUT_FILE"
echo "================================================================"
