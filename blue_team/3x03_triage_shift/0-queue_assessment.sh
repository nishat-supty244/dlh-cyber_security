#!/bin/bash
# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Ensure we are looking in the current working directory where the files reside
CURRENT_DIR="$(pwd)"
ALERTS_FILE="$CURRENT_DIR/alert_queue.json"
SCHEMA_FILE="$CURRENT_DIR/alert_queue_schema.json"
OUTPUT_FILE="$CURRENT_DIR/queue_assessment.json"

if [ ! -f "$ALERTS_FILE" ] || [ ! -s "$ALERTS_FILE" ]; then
    echo "Error: alert_queue.json not found or is empty in $CURRENT_DIR." >&2
    exit 1
fi

echo "Generating alert queue assessment from: $ALERTS_FILE"

python3 - "$ALERTS_FILE" "$SCHEMA_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import json
from datetime import datetime
from collections import defaultdict

alerts_path = sys.argv[1]
schema_path = sys.argv[2] if len(sys.argv) > 2 and sys.argv[2] else ""
output_path = sys.argv[3]

try:
    with open(alerts_path, 'r') as f:
        content = f.read().strip()
        if not content:
            alerts = []
        else:
            alerts = json.loads(content)
except Exception as e:
    print(f"Error parsing JSON from {alerts_path}: {e}", file=sys.stderr)
    sys.exit(1)

schema = {}
if schema_path:
    try:
        with open(schema_path, 'r') as f:
            schema = json.load(f)
    except Exception:
        pass

def validate_alert(alert, schema):
    if not schema:
        return True
    try:
        import jsonschema
        jsonschema.validate(instance=alert, schema=schema)
        return True
    except ImportError:
        required = schema.get("required", [])
        for req in required:
            if req not in alert:
                return False
        return True
    except Exception:
        return False

validation_errors = []
valid_alerts = []

for alert in alerts:
    if validate_alert(alert, schema):
        valid_alerts.append(alert)
    else:
        validation_errors.append(alert.get("alert_id", "unknown"))

queue_size = len(alerts)
priority_bands = {"critical": 0, "high": 0, "medium": 0, "low": 0}
by_rule_counts = defaultdict(int)
by_host_counts = defaultdict(int)
by_tactic_counts = defaultdict(int)
host_scores = defaultdict(int)
timestamps = []

for alert in valid_alerts:
    score = alert.get("priority_score", 0)
    if score >= 20:
        priority_bands["critical"] += 1
    elif score >= 10:
        priority_bands["high"] += 1
    elif score >= 5:
        priority_bands["medium"] += 1
    else:
        priority_bands["low"] += 1

    rule_id = alert.get("rule_id", "unknown")
    by_rule_counts[rule_id] += 1

    if "target_host" in alert:
        host = alert["target_host"]
    elif "event_summary" in alert and "hostname" in alert["event_summary"]:
        host = alert["event_summary"]["hostname"]
    else:
        host = "unknown"
    
    by_host_counts[host] += 1
    host_scores[host] += score

    tactics = alert.get("attack_tactics", alert.get("tactics", []))
    if not tactics and "rule_tags" in alert:
        tactics = [t for t in alert["rule_tags"] if "tactic" in t.lower() or t.startswith("TA")]
    for t in tactics:
        by_tactic_counts[t] += 1

    ts = alert.get("event_summary", {}).get("timestamp")
    if ts:
        timestamps.append(ts)

timestamps.sort()
time_span = {
    "start": timestamps[0] if timestamps else "",
    "end": timestamps[-1] if timestamps else ""
}

sorted_rules = dict(sorted(by_rule_counts.items(), key=lambda x: x[1], reverse=True))
sorted_hosts = dict(sorted(by_host_counts.items(), key=lambda x: x[1], reverse=True))
sorted_tactics = dict(sorted(by_tactic_counts.items(), key=lambda x: x[1], reverse=True))

top_targets_sorted = sorted(host_scores.items(), key=lambda x: x[1], reverse=True)[:3]
top_targets = [{"hostname": h, "cumulative_score": s} for h, s in top_targets_sorted]

assessment_data = {
    "queue_size": queue_size,
    "validation_errors": validation_errors,
    "by_priority_band": priority_bands,
    "by_rule": sorted_rules,
    "by_hostname": sorted_hosts,
    "by_attack_tactic": sorted_tactics,
    "time_span": time_span,
    "top_targets": top_targets
}

with open(output_path, 'w') as f:
    json.dump(assessment_data, f, indent=2)

current_date = datetime.utcnow().strftime("%Y-%m-%d")
print(f"=== SHIFT BRIEFING {current_date} ===")
print(f"queue size           : {queue_size} alerts")
print(f"validation errors    : {len(validation_errors)}")
print(f"time span            : {time_span['start']} -> {time_span['end']}")
print("priority bands")
for band, count in priority_bands.items():
    print(f"  {band:<10}: {count:>2}")
print(f"\nSuccessfully wrote output to {output_path}")
EOF
