#!/bin/bash

# ================================================================
# Evidence Inventory - HEALTHBANE Attack Reconstruction
# Task: 0 - Evidence Inventory
# ================================================================

set -u

OUTPUT_DATE=$(date '+%Y-%m-%d')
HOSTNAME=$(hostname)

echo "================================================================"
echo "   EVIDENCE INVENTORY - HEALTHBANE Reconstruction"
echo "   Analyst Host: $HOSTNAME"
echo "   Date: $OUTPUT_DATE"
echo "================================================================"
echo

# ----------------------------------------------------------------
# Check required directories
# ----------------------------------------------------------------

for DIR in ir_evidence previous_findings reference; do
    if [ ! -d "$DIR" ]; then
        echo "ERROR: Missing directory: $DIR"
        exit 1
    fi
done

# ----------------------------------------------------------------
# Function: determine investigation phase
# ----------------------------------------------------------------

get_phase() {
    local FILE="$1"

    case "$FILE" in
        4x00_*)
            echo "4x00 (Phishing Dissection)"
            ;;
        4x01_*)
            echo "4x01 (Network Forensics)"
            ;;
        4x02_*)
            echo "4x02 (Threat Intelligence / ATT&CK)"
            ;;
        4x03_*)
            echo "4x03 (Malware Analysis)"
            ;;
        4x04_*)
            echo "4x04 (Threat Hunting)"
            ;;
        memory_artifacts.txt|disk_forensics_report.txt|firewall_sessions_ws_recv_03.json|ir_team_notes.txt)
            echo "4x05-IR (Incident Response)"
            ;;
        *)
            echo "Reference"
            ;;
    esac
}

# ----------------------------------------------------------------
# Function: determine evidence type
# ----------------------------------------------------------------

get_type() {
    local FILE="$1"

    case "$FILE" in
        4x00_*)
            echo "Email / Phishing"
            ;;
        4x01_*)
            echo "Network"
            ;;
        4x02_*)
            echo "Intelligence / ATT&CK"
            ;;
        4x03_*)
            echo "Malware"
            ;;
        4x04_*)
            echo "SIEM / Threat Hunting"
            ;;
        memory_artifacts.txt)
            echo "Memory"
            ;;
        disk_forensics_report.txt)
            echo "Disk Forensics"
            ;;
        firewall_sessions_ws_recv_03.json)
            echo "Firewall"
            ;;
        ir_team_notes.txt)
            echo "Incident Response Notes"
            ;;
        healthbane_ioc_master.json)
            echo "IOC Database"
            ;;
        attck_navigator_80pct.json)
            echo "ATT&CK Mapping"
            ;;
        meddefense_asset_inventory.txt)
            echo "Asset Inventory"
            ;;
        network_topology.txt)
            echo "Network Topology"
            ;;
        *)
            echo "Unknown"
            ;;
    esac
}

# ----------------------------------------------------------------
# Function: determine reliability
# ----------------------------------------------------------------

get_reliability() {
    local FILE="$1"

    case "$FILE" in
        memory_artifacts.txt|disk_forensics_report.txt|firewall_sessions_ws_recv_03.json)
            echo "HIGH - Primary forensic evidence"
            ;;
        ir_team_notes.txt)
            echo "LOW - Preliminary / requires validation"
            ;;
        4x00_*|4x01_*|4x02_*|4x03_*|4x04_*)
            echo "MEDIUM - Derived investigation summary"
            ;;
        *)
            echo "HIGH - Reference source"
            ;;
    esac
}

# ----------------------------------------------------------------
# Function: determine coverage
# ----------------------------------------------------------------

get_coverage() {
    local FILE="$1"

    case "$FILE" in
        4x00_phishing_summary.txt)
            echo "Week 11 - Initial phishing campaign"
            ;;
        4x01_network_timeline.txt)
            echo "48h window surrounding phishing incident"
            ;;
        4x02_attack_mapping.json)
            echo "Post-intelligence analysis period"
            ;;
        4x03_malware_summary.txt)
            echo "Malware analysis period"
            ;;
        4x04_hunting_report.txt)
            echo "Threat hunting period - Weeks 14-15"
            ;;
        memory_artifacts.txt)
            echo "WS-RECV-03 capture - Week 16-17"
            ;;
        disk_forensics_report.txt)
            echo "WS-RECV-03 disk image - Week 16-17"
            ;;
        firewall_sessions_ws_recv_03.json)
            echo "14 days of WS-RECV-03 firewall sessions"
            ;;
        ir_team_notes.txt)
            echo "IR investigation - Week 16-17"
            ;;
        healthbane_ioc_master.json)
            echo "IOC accumulation across 4x00-4x04"
            ;;
        attck_navigator_80pct.json)
            echo "Post-4x04 ATT&CK coverage baseline"
            ;;
        meddefense_asset_inventory.txt)
            echo "Current asset inventory"
            ;;
        network_topology.txt)
            echo "Current network architecture"
            ;;
        *)
            echo "See source content"
            ;;
    esac
}

# ----------------------------------------------------------------
# Function: extract useful findings
# ----------------------------------------------------------------

get_findings() {
    local FILE="$1"

    # Search for common analytical keywords.
    # Keep output short because this is an inventory, not a full report.

    grep -iE \
        'IOC|C2|C&C|beacon|DNS|exfil|lateral|persistence|scheduled task|credential|phishing|malware|RAT|patient|database|staging|PowerShell|MITRE|ATT&CK|unknown IP' \
        "$FILE" 2>/dev/null |
        head -n 4 |
        tr '\n' ' ' |
        cut -c1-350

    echo
}

# ----------------------------------------------------------------
# SOURCE CATALOG
# ----------------------------------------------------------------

echo "SOURCE CATALOG:"
echo

INDEX=1

for DIR in previous_findings ir_evidence reference; do

    for FILE in "$DIR"/*; do

        [ -f "$FILE" ] || continue

        BASENAME=$(basename "$FILE")

        echo "  [$INDEX] $FILE"
        echo "       Phase: $(get_phase "$BASENAME")"
        echo "       Type: $(get_type "$BASENAME")"
        echo "       Coverage: $(get_coverage "$BASENAME")"
        echo "       Reliability: $(get_reliability "$BASENAME")"

        echo "       Size: $(wc -c < "$FILE") bytes"
        echo "       Lines: $(wc -l < "$FILE")"

        echo -n "       Key content: "
        get_findings "$FILE"

        echo

        INDEX=$((INDEX + 1))
    done
done

# ----------------------------------------------------------------
# TEMPORAL COVERAGE MATRIX
# ----------------------------------------------------------------

echo "================================================================"
echo "TEMPORAL COVERAGE MATRIX"
echo "================================================================"

echo
echo "Week 11  [EMAIL] [NETWORK]"
echo "Week 12  [INTEL]"
echo "Week 13  [MALWARE]"
echo "Week 14  [SIEM/HUNT]"
echo "Week 15  [SIEM/HUNT]"
echo "Week 16  [SIEM] [IR]"
echo "Week 17  [IR]"
echo

echo "TEMPORAL GAPS:"
echo "  GAP: Endpoint forensic evidence is limited before the IR"
echo "       collection on WS-RECV-03."
echo
echo "  GAP: Network PCAP coverage is limited to the 4x01 capture"
echo "       window; later activity relies on other telemetry."
echo
echo "  GAP: Memory and disk evidence is available only for"
echo "       WS-RECV-03."
echo

# ----------------------------------------------------------------
# DOMAIN COVERAGE
# ----------------------------------------------------------------

echo "================================================================"
echo "DOMAIN COVERAGE"
echo "================================================================"

echo
echo "Initial Access:"
echo "  EMAIL + NETWORK"
echo
echo "Execution:"
echo "  MALWARE + ENDPOINT/SIEM"
echo
echo "Persistence:"
echo "  IR MEMORY + DISK"
echo
echo "C2:"
echo "  NETWORK + MALWARE + FIREWALL"
echo
echo "Lateral Movement:"
echo "  NETWORK + THREAT HUNT"
echo
echo "Data Staging:"
echo "  DISK FORENSICS"
echo
echo "Exfiltration:"
echo "  NETWORK + DISK + FIREWALL"
echo

echo "DOMAIN GAPS:"
echo "  GAP: Persistence was not covered by previous hunting rules."
echo "  GAP: Disk evidence exists only for WS-RECV-03."
echo "  GAP: Unknown firewall destination requires validation."
echo "  GAP: Data exfiltration must be correlated with network evidence."
echo

# ----------------------------------------------------------------
# CRITICAL QUESTIONS
# ----------------------------------------------------------------

echo "================================================================"
echo "CRITICAL QUESTIONS FOR RECONSTRUCTION"
echo "================================================================"

echo
echo "[Q1] Does the new firewall evidence confirm or contradict"
echo "     the 4x01 network timeline for WS-RECV-03?"

echo
echo "[Q2] What is the previously unknown destination IP?"
echo "     Is it secondary C2 infrastructure or unrelated traffic?"

echo
echo "[Q3] Did the staged patient data actually leave the network,"
echo "     or was exfiltration interrupted?"

echo
echo "[Q4] Was the scheduled task the only persistence mechanism"
echo "     on WS-RECV-03?"

echo
echo "[Q5] Are there additional persistence mechanisms in the"
echo "     disk, memory, registry, or scheduled task evidence?"

echo
echo "[Q6] Which previous findings are confirmed by the new IR"
echo "     evidence, and which need to be corrected?"

echo
echo "[Q7] Which ATT&CK techniques are now CONFIRMED, PROBABLE,"
echo "     or POSSIBLE after all evidence is correlated?"

echo
echo "[Q8] What data was actually accessed, staged, or exfiltrated?"
echo

echo "================================================================"
echo "END OF EVIDENCE INVENTORY"
echo "================================================================"
