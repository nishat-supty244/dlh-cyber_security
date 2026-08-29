#!/bin/bash
set -uo pipefail

RULES_FILE="meddefense.rules"
CONFIG_FILE="./suricata.yaml"
LAB_LABELS_DIR="/home/analyst/MedDefense_Lab/PCAPs/labels"
LOG_DIR="/tmp/suricata-rule-validation"
OUTPUT_JSON="rule_validation.json"

if [[ ! -f "$RULES_FILE" ]]; then
    echo "Error: $RULES_FILE not found." >&2
    exit 1
fi

RULE_COUNT=$(grep -cE '^alert' "$RULES_FILE")
echo "[*] Loading $RULES_FILE...          $RULE_COUNT rules"
echo "[*] Running validation against labeled PCAPs..."

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
RESULTS_JSON="[]"

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
        
        suricata -c "$CONFIG_FILE" -S "$RULES_FILE" -r "$PCAP_PATH" -l "$LOG_DIR" >/dev/null 2>&1 || true
        
        if [[ -f "${LOG_DIR}/eve.json" ]]; then
            HIT_COUNT=$(jq -s --argjson target_sid "$sid" '[.[] | select(.event_type == "alert" and .alert.signature_id == $target_sid)] | length' "${LOG_DIR}/eve.json" 2>/dev/null || echo "0")
            HIT_COUNT=${HIT_COUNT:-0}
        fi
    fi

    STATUS="FAIL"
    if [[ "$HIT_COUNT" -gt 0 ]]; then
        echo "  observed: fire ($HIT_COUNT hits)                PASS"
        ((PASSED++))
        STATUS="PASS"
    else
        echo "  observed: no hits                      FAIL"
        ((FAILED++))
    fi

    # Build result item for JSON
    ITEM=$(jq -n \
        --argjson sid "$sid" \
        --arg name "$rule_name" \
        --arg pcap "$pcap_name" \
        --arg status "$STATUS" \
        --argjson hits "$HIT_COUNT" \
        '{sid: $sid, name: $name, target: $pcap, expected: "fire", observed: $status, hits: $hits}')
    
    RESULTS_JSON=$(echo "$RESULTS_JSON" | jq --argjson item "$ITEM" '. + [$item]')
done

# Write out rule_validation.json as required by the test checks
jq -n \
    --argjson rules "$RULE_COUNT" \
    --argjson passed "$PASSED" \
    --argjson failed "$FAILED" \
    --argjson results "$RESULTS_JSON" \
    '{total_rules: $rules, passed: $passed, failed: $failed, results: $results}' > "$OUTPUT_JSON"

echo ""
echo "Rules:  $RULE_COUNT"
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [[ "$FAILED" -gt 0 ]]; then
    exit 1
fi
exit 0
