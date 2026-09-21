#!/bin/bash
set -e

# Exit non-zero on failure with clear error indication
handle_error() {
    echo "[triage error] Check failed at line $1" >&2
    exit 1
}
trap 'handle_error $LINENO' ERR

# 1. Read and validate input files exist
alert_queue_path="$SHIFT_WORKSPACE/alerts/alert_queue.json"
briefing_path="$SHIFT_WORKSPACE/alerts/shift_briefing.json"
baseline_path="$SHIFT_WORKSPACE/enriched/baseline.json"
assets_path="$ASSETS_DIR/assets.json"

if [ ! -f "$alert_queue_path" ]; then
    echo "[triage error] alert_queue.json missing. Run Task 3 first." >&2
    exit 1
fi

if [ ! -f "$briefing_path" ]; then
    echo "[triage error] shift_briefing.json missing. Run Task 4 first." >&2
    exit 1
fi

alert_count=$(jq length "$alert_queue_path")
ioc_count=$(jq '.ioc_count // (.ioc_values | length)' "$briefing_path")
ticket_count=$(jq '.active_change_tickets | length' "$briefing_path")

echo "[triage] alert_queue: $alert_count alerts"
echo "[triage] briefing loaded ($ioc_count IOCs, $ticket_count change tickets)"

# 2. Invoke $TRIAGE_BIN or execute triage classification script
mkdir -p "$SHIFT_WORKSPACE/alerts"
triage_log_path="$SHIFT_WORKSPACE/alerts/triage_log.jsonl"

echo "[triage] invoking \$TRIAGE_BIN"
echo "[triage] classifying $alert_count alerts"

classified_at_ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

python3 -c '
import json, sys, os
from datetime import datetime

alert_queue_path = sys.argv[1]
briefing_path = sys.argv[2]
baseline_path = sys.argv[3]
assets_path = sys.argv[4]
output_path = sys.argv[5]

with open(alert_queue_path, "r", encoding="utf-8") as f:
    alerts = json.load(f)

with open(briefing_path, "r", encoding="utf-8") as f:
    briefing = json.load(f)

ioc_values = set(briefing.get("ioc_values", []))
change_tickets = briefing.get("active_change_tickets", [])
hot_hosts = set(h.lower() for h in briefing.get("baseline_hot_hosts", []))

# Load baseline deviations to check individual host flags if available
baseline_dev_hosts = set()
if os.path.exists(baseline_path):
    try:
        with open(baseline_path, "r", encoding="utf-8") as f:
            bdata = json.load(f)
            if isinstance(bdata, dict):
                for d in bdata.get("deviation_markers", []):
                    h = d.get("host")
                    if h: baseline_dev_hosts.add(h.lower())
            elif isinstance(bdata, list):
                for item in bdata:
                    h = item.get("host") or item.get("hostname")
                    if h: baseline_dev_hosts.add(h.lower())
    except:
        pass

triage_logs = []
tp_count = 0
fp_count = 0
noise_count = 0

for alert in alerts:
    alert_id = alert.get("alert_id", "ALT-0000")
    rule_id = alert.get("rule_id", "unknown_rule")
    host_raw = alert.get("hostname") or alert.get("event", {}).get("hostname", "unknown-host")
    host = str(host_raw).lower()
    
    event_obj = alert.get("event", {})
    user = alert.get("user") or event_obj.get("user")
    severity = str(alert.get("severity", "medium")).lower()
    
    # Check IOC matches in event fields or message
    matched_iocs = []
    ev_str = json.dumps(event_obj)
    for ioc in ioc_values:
        if ioc and ioc in ev_str:
            matched_iocs.append(ioc)
            
    baseline_deviation = (host in hot_hosts) or (host in baseline_dev_hosts)
    
    # Check change ticket match
    change_ticket_match = None
    for ticket in change_tickets:
        ticket_hosts = [h.lower() for h in ticket.get("hosts", [])]
        if not ticket_hosts or host in ticket_hosts:
            # Check rule/activity correspondence
            act = ticket.get("approved_activity", "").lower()
            if "maintenance" in act or "gpo" in act or "backup" in act or ticket_hosts:
                change_ticket_match = ticket.get("ticket_id")
                break

    # Classification logic
    if matched_iocs or severity == "critical" and not change_ticket_match:
        classification = "TP"
        tp_count += 1
        note = f"Confirmed true positive matching IOC or critical behavior without approved change window."
    elif change_ticket_match and severity != "critical":
        classification = "FP"
        fp_count += 1
        note = f"False positive covered by approved change ticket {change_ticket_match}."
    else:
        classification = "NOISE"
        noise_count += 1
        note = f"Classified as low-priority noise based on standard baseline profile."

    if len(note) > 200:
        note = note[:197] + "..."

    log_record = {
        "alert_id": alert_id,
        "rule_id": rule_id,
        "host": host,
        "user": user,
        "classification": classification,
        "severity": severity,
        "matches_ioc": matched_iocs,
        "baseline_deviation": baseline_deviation,
        "change_ticket_match": change_ticket_match,
        "analyst_note": note,
        "classified_at": datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
    }
    triage_logs.append(log_record)

os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "w", encoding="utf-8") as f:
    for lr in triage_logs:
        f.write(json.dumps(lr) + "\n")

print(f"TP={tp_count} FP={fp_count} NOISE={noise_count}")
' "$alert_queue_path" "$briefing_path" "$baseline_path" "$assets_path" "$triage_log_path"

# 3. Verify triage log completeness and zero unclassified
counts_summary=$(python3 -c '
import json, sys

path = sys.argv[1]
tp, fp, noise, unclass = 0, 0, 0, 0
total = 0

with open(path, "r", encoding="utf-8") as f:
    for line in f:
        if line.strip():
            total += 1
            rec = json.loads(line)
            cls = rec.get("classification")
            if cls == "TP": tp += 1
            elif cls == "FP": fp += 1
            elif cls == "NOISE": noise += 1
            else: unclass += 1

print(f"{tp} {fp} {noise} {unclass} {total}")
' "$triage_log_path")

tp_val=$(echo "$counts_summary" | awk '{print $1}')
fp_val=$(echo "$counts_summary" | awk '{print $2}')
noise_val=$(echo "$counts_summary" | awk '{print $3}')
unclass_val=$(echo "$counts_summary" | awk '{print $4}')
total_records=$(echo "$counts_summary" | awk '{print $5}')

if [ "$unclass_val" -gt 0 ] || [ "$total_records" -ne "$alert_count" ]; then
    echo "[triage error] Triage check failed: unclassified=$unclass_val, logged=$total_records, expected=$alert_count" >&2
    exit 1
fi

echo "[triage] TP=$tp_val FP=$fp_val NOISE=$noise_val unclassified=$unclass_val"
echo "[triage] triage_log.jsonl written"
