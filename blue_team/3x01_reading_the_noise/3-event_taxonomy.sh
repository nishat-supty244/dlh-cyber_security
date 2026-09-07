#!/bin/bash
# Task 3: Event Type Taxonomy
set -euo pipefail

HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
DATA_FILE="$HANDOFF_DIR/data/enriched_events.json"

if [ ! -f "$DATA_FILE" ]; then
    if [ -f "enriched_events.json" ]; then
        DATA_FILE="enriched_events.json"
    else
        echo "Error: enriched_events.json not found in handoff data or current directory." >&2
        exit 1
    fi
fi

python3 - "$DATA_FILE" << 'PYTHON_SCRIPT'
import sys
import json
from collections import Counter

data_file = sys.argv[1]

# Define canonical taxonomy rules covering the required minimum labels
taxonomy_rules = [
    {"source_type": "auth", "match": {"action": "login", "status": "success"}, "label": "login_success"},
    {"source_type": "auth", "match": {"action": "login", "status": "failure"}, "label": "login_failure"},
    {"source_type": "auth", "match": {"action": "logout"}, "label": "logout"},
    {"source_type": "auth", "match": {"action": "lockout"}, "label": "account_lockout"},
    {"source_type": "auth", "match": {"action": "privilege_escalation"}, "label": "privilege_escalation"},
    {"source_type": "process", "match": {"action": "start"}, "label": "process_start"},
    {"source_type": "process", "match": {"action": "stop"}, "label": "process_stop"},
    {"source_type": "process", "match": {"action": "spawn"}, "label": "child_process_spawn"},
    {"source_type": "file", "match": {"action": "read", "sensitivity": "high"}, "label": "file_read_sensitive"},
    {"source_type": "file", "match": {"action": "write", "sensitivity": "high"}, "label": "file_write_sensitive"},
    {"source_type": "file", "match": {"action": "chmod"}, "label": "file_permission_change"},
    {"source_type": "network", "match": {"direction": "outbound"}, "label": "network_connection_outbound"},
    {"source_type": "network", "match": {"direction": "inbound"}, "label": "network_connection_inbound"},
    {"source_type": "network", "match": {"status": "alert"}, "label": "network_alert"},
    {"source_type": "network", "match": {"status": "blocked"}, "label": "network_blocked"},
]

# Write out event_taxonomy.json
with open("event_taxonomy.json", "w", encoding="utf-8") as f:
    json.dump(taxonomy_rules, f, indent=2)

labeled_records = []
records_labeled = 0
records_unlabeled = 0
label_counter = Counter()

with open(data_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue

        assigned_label = "unlabeled"
        for rule in taxonomy_rules:
            # Check source_type match if present in rule
            if "source_type" in rule and rec.get("source_type") != rule["source_type"]:
                continue
            
            matched = True
            for k, v in rule["match"].items():
                if rec.get(k) != v:
                    matched = False
                    break
            if matched:
                assigned_label = rule["label"]
                break

        rec["canonical_label"] = assigned_label
        labeled_records.append(rec)

        if assigned_label != "unlabeled":
            records_labeled += 1
        else:
            records_unlabeled += 1
        label_counter[assigned_label] += 1

# Write labeled dataset to labeled_events.json (NDJSON)
with open("labeled_events.json", "w", encoding="utf-8") as out:
    for rec in labeled_records:
        out.write(json.dumps(rec) + "\n")

print(f"taxonomy rules         : {len(taxonomy_rules)}")
print(f"records labeled        : {records_labeled}")
print(f"records unlabeled      : {records_unlabeled}")
print("canonical label distribution (top 10):")
for label, count in label_counter.most_common(10):
    print(f"  {label:<26} {count}")
print("event_taxonomy.json written")
print("labeled_events.json written")
PYTHON_SCRIPT
