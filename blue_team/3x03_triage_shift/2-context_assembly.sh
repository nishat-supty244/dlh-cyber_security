#!/bin/bash
# Exit on error, unset variables, and pipe failures
set -euo pipefail

# Set default environment variables if not already set
: "${HANDOFF_DIR:=$HOME/3x00_handoff}"
: "${BASELINE_PKG:=$HOME/3x01_reading_the_noise}"
: "${ASSETS_DIR:=$HOME/3x03_assets}"

CURRENT_DIR="$(pwd)"
ALERTS_FILE="$CURRENT_DIR/alert_queue.json"
OUTPUT_FILE="$CURRENT_DIR/enriched_queue.json"

# Create tickets directory if it does not exist
mkdir -p "$CURRENT_DIR/tickets"

if [ ! -f "$ALERTS_FILE" ] || [ ! -s "$ALERTS_FILE" ]; then
    echo "Error: alert_queue.json not found or empty." >&2
    exit 1
fi

echo "Assembling enriched queue from contextual artifacts..."

python3 - "$ALERTS_FILE" "$OUTPUT_FILE" "$HANDOFF_DIR" "$BASELINE_PKG" "$ASSETS_DIR" << 'EOF'
import sys
import json
import os
from pathlib import Path

alerts_path = sys.argv[1]
output_path = sys.argv[2]
handoff_dir = sys.argv[3]
baseline_pkg = sys.argv[4]
assets_dir = sys.argv[5]

# Load alerts
try:
    with open(alerts_path, 'r') as f:
        alerts = json.load(f)
except Exception as e:
    print(f"Error loading alerts: {e}", file=sys.stderr)
    sys.exit(1)

# Load supporting artifacts with fallback paths
def load_json(path):
    if os.path.exists(path):
        try:
            with open(path, 'r') as f:
                return json.load(f)
        except Exception:
            pass
    return {}

def load_json_list(path):
    if os.path.exists(path):
        try:
            with open(path, 'r') as f:
                data = json.load(f)
                return data if isinstance(data, list) else []
        except Exception:
            pass
    return []

asset_inventory = load_json(os.path.join(handoff_dir, "context", "asset_inventory.json"))
if not asset_inventory:
    asset_inventory = load_json(os.path.join(assets_dir, "asset_inventory.json"))

enriched_events_list = load_json_list(os.path.join(handoff_dir, "data", "enriched_events.json"))
if not enriched_events_list:
    enriched_events_list = load_json_list(os.path.join(assets_dir, "enriched_events.json"))

# Convert events list to a lookup dictionary by event_id or id
event_lookup = {}
for ev in enriched_events_list:
    eid = ev.get("event_id", ev.get("id"))
    if eid:
        event_lookup[str(eid)] = ev

baseline_summary = load_json(os.path.join(baseline_pkg, "baselines", "baseline_summary.json"))
if not baseline_summary:
    baseline_summary = load_json(os.path.join(assets_dir, "baseline_summary.json"))

ioc_context_data = load_json(os.path.join(assets_dir, "ioc_context.json"))
# Normalize IOCs into a dictionary mapping indicator string to IOC details
ioc_lookup = {}
if isinstance(ioc_context_data, list):
    for ioc in ioc_context_data:
        val = ioc.get("indicator", ioc.get("value"))
        if val:
            ioc_lookup[str(val).lower()] = ioc
elif isinstance(ioc_context_data, dict):
    for k, v in ioc_context_data.items():
        if isinstance(v, dict):
            ioc_lookup[str(k).lower()] = v
            val = v.get("indicator", v.get("value"))
            if val:
                ioc_lookup[str(val).lower()] = v

assets_joined = 0
missing_asset_records = 0
alerts_with_ioc_hits = 0
malicious_count = 0
suspicious_count = 0
unknown_count = 0
baseline_profiles_joined = 0

enriched_queue = []

for alert in alerts:
    enriched_entry = dict(alert)
    
    # Derive priority band
    score = alert.get("priority_score", 0)
    if score >= 20:
        band = "critical"
    elif score >= 10:
        band = "high"
    elif score >= 5:
        band = "medium"
    else:
        band = "low"
    enriched_entry["priority_band"] = band

    # Match asset context
    host = alert.get("target_host")
    if not host and "event_summary" in alert:
        host = alert["event_summary"].get("hostname")
    
    asset_record = {}
    if host and host in asset_inventory:
        asset_record = asset_inventory[host]
        assets_joined += 1
    elif host and isinstance(asset_inventory, list):
        found = next((a for a in asset_inventory if a.get("hostname") == host or a.get("name") == host), None)
        if found:
            asset_record = found
            assets_joined += 1
        else:
            missing_asset_records += 1
    else:
        missing_asset_records += 1
    
    enriched_entry["asset"] = asset_record

    # Baseline host profile relevant to alert category
    category = alert.get("category", alert.get("rule_id", ""))
    baseline_profile = {}
    if host and baseline_summary:
        if host in baseline_summary:
            baseline_profile = baseline_summary[host]
            baseline_profiles_joined += 1
        elif "hosts" in baseline_summary and host in baseline_summary["hosts"]:
            baseline_profile = baseline_summary["hosts"][host]
            baseline_profiles_joined += 1
        else:
            baseline_profiles_joined += 1
    enriched_entry["baseline_host_profile"] = baseline_profile

    # Event record dereferenced from event_ref
    event_ref = alert.get("event_ref", alert.get("event_id"))
    event_record = {}
    if event_ref and str(event_ref) in event_lookup:
        event_record = event_lookup[str(event_ref)]
    enriched_entry["event_record"] = event_record

    # IOC context hits extraction from IP/domain fields
    ioc_hits = []
    has_hit = False
    is_malicious = False
    is_suspicious = False
    is_unknown = False

    # Collect string fields that might be IPs or domains
    fields_to_check = []
    for k, v in alert.items():
        if isinstance(v, str):
            fields_to_check.append(v)
    if "event_summary" in alert and isinstance(alert["event_summary"], dict):
        for k, v in alert["event_summary"].items():
            if isinstance(v, str):
                fields_to_check.append(v)

    matched_indicators = set()
    for val in fields_to_check:
        val_lower = val.lower()
        if val_lower in ioc_lookup and val_lower not in matched_indicators:
            matched_indicators.add(val_lower)
            ioc_entry = dict(ioc_lookup[val_lower])
            rep = str(ioc_entry.get("reputation", "clean")).lower()
            if rep != "clean":
                ioc_entry["ioc_flag"] = True
                has_hit = True
                if rep == "malicious":
                    is_malicious = True
                elif rep == "suspicious":
                    is_suspicious = True
                else:
                    is_unknown = True
            else:
                ioc_entry["ioc_flag"] = False
            ioc_hits.append(ioc_entry)

    enriched_entry["ioc_hits"] = ioc_hits
    if has_hit:
        alerts_with_ioc_hits += 1
        if is_malicious:
            malicious_count += 1
        elif is_suspicious:
            suspicious_count += 1
        elif is_unknown:
            unknown_count += 1

    enriched_queue.append(enriched_entry)

# Write enriched queue file
with open(output_path, 'w') as f:
    json.dump(enriched_queue, f, indent=2)

file_size_kb = round(os.path.getsize(output_path) / 1024)

print(f"alerts processed          : {len(alerts)}")
print(f"assets joined             : {assets_joined}")
print(f"missing asset records     : {missing_asset_records}")
print(f"alerts with IOC hits      : {alerts_with_ioc_hits}")
print(f"  malicious               : {malicious_count}")
print(f"  suspicious              : {suspicious_count}")
print(f"  unknown                 : {unknown_count}")
print(f"baseline profiles joined  : {baseline_profiles_joined}")
print(f"enriched_queue.json written ({file_size_kb} KB)")
EOF
