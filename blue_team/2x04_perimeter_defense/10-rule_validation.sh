#!/bin/bash
set -uo pipefail

RULES_FILE="meddefense.rules"
CONFIG_FILE="./suricata.yaml"
LAB_LABELS_DIR="/home/analyst/MedDefense_Lab/PCAPs/labels"
LOG_DIR="/tmp/suricata-rule-validation"

if [[ ! -f "$RULES_FILE" ]]; then
    echo "Error: $RULES_FILE not found." >&2
    exit 1
fi

RULE_COUNT=$(grep -cE '^alert' "$RULES_FILE")
echo "[*] Loading $RULES_FILE...          $RULE_COUNT rules"
echo "[*] Running validation against labeled PCAPs..."

# Define mapping array of SID -> Name -> PCAP filename -> Expected behavior
declare -A RULE_MAP=(
    [9000001]="MEDDEV to Internet|meddev_egress.pcap"
    [9000002]="Guest to SMB|guest_smb.pcap"
    [9000003]="Large Outbound From Server|large_outbound.pcap"
    [9000004]="DNS Tunneling Long Label|dns_tunnel.pcap"
    [9000005]="Clinical to Unauthorized DB|clinical_wrong_db.pcap"
    [9000006]="Telnet to MEDDEV|telnet_meddev.pcap"
)

PASSED=0
FAILED=0

# Ensure custom rules are part of rules path or config if necessary
# We can run suricata referencing our custom rules via command-line or config file overrides.
# Suricata allows loading extra rules or we can ensure meddefense.rules is inside /var/lib/suricata/rules/
RULES_DST="/var/lib/suricata/rules"
mkdir -p "$RULES_DST"
cp -f "$RULES_FILE" "$RULES_DST/"

for sid in 9000001 9000002 9000003 9000004 9000005 9000006; do
    IFS='|' read -r rule_name pcap_name <<< "${RULE_MAP[$sid]}"
    PCAP_PATH="${LAB_LABELS_DIR}/${pcap_name}"
    
    echo -n "sid $sid $rule_name"
    echo -n "  target: $pcap_name"
    echo -n "  expected: fire"

    HIT_COUNT=0
    if [[ -f "$PCAP_PATH" && -f "$CONFIG_FILE" ]]; then
        rm -rf "$LOG_DIR"
        mkdir -p "$LOG_DIR"
        
        # Run suricata with the rules file explicitly loaded
        suricata -c "$CONFIG_FILE" -S "$RULES_FILE" -r "$PCAP_PATH" -l "$LOG_DIR" >/dev/null 2>&1 || true
        
        if [[ -f "${LOG_DIR}/eve.json" ]]; then
            HIT_COUNT=$(jq -s --argjson target_sid "$sid" '[.[] | select(.event_type == "alert" and .alert.signature_id == $target_sid)] | length' "${LOG_DIR}/eve.json" 2>/dev/null || echo "0")
            HIT_COUNT=${HIT_COUNT:-0}
        fi
    fi

    if [[ "$HIT_COUNT" -gt 0 ]]; then
        echo "  observed: fire ($HIT_COUNT hits)                PASS"
        ((PASSED++))
    else
        echo "  observed: no hits                      FAIL"
        ((FAILED++))
    fi
done

echo ""
echo "Rules:  $RULE_COUNT"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi
exit 0
EOF

chmod +x 10-rule_validation.sh
