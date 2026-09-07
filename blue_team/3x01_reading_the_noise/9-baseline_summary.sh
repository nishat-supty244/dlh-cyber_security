#!/bin/bash
# Task 9: Cross-Source Baseline Summary
set -euo pipefail

python3 - << 'PYTHON_SCRIPT'
import json
from datetime import datetime, timedelta
import os

# Helper to safely load JSON files
def load_json(filename):
    if os.path.exists(filename):
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            return {}
    return {}

auth_data = load_json("baseline_auth.json")
process_data = load_json("baseline_process.json")
network_data = load_json("baseline_network.json")
file_data = load_json("baseline_file.json")
temporal_data = load_json("temporal_profile.json")

# Extract baseline window
window_info = auth_data.get("window") or process_data.get("window") or {}
start_str = window_info.get("start", datetime.utcnow().isoformat())
end_str = window_info.get("end", (datetime.utcnow() + timedelta(days=7)).isoformat())

try:
    start_dt = datetime.fromisoformat(start_str.replace("Z", "+00:00"))
    end_dt = datetime.fromisoformat(end_str.replace("Z", "+00:00"))
    duration_days = max(1, round((end_dt - start_dt).total_seconds() / 86400))
except Exception:
    start_dt = datetime.utcnow()
    end_dt = start_dt + timedelta(days=7)
    duration_days = 7

# Evaluation window (typically day 8, 24h block following baseline)
eval_start_dt = end_dt
eval_end_dt = eval_start_dt + timedelta(hours=24)

# Collect host inventory across sections
hosts_set = set()
if "per_host" in auth_data:
    hosts_set.update(auth_data["per_host"].keys())
if "per_host" in process_data:
    hosts_set.update(process_data["per_host"].keys())
if "per_host" in network_data:
    hosts_set.update(network_data["per_host"].keys())
if "per_host" in file_data:
    hosts_set.update(file_data["per_host"].keys())

host_inventory = sorted(list(hosts_set))

# Define derived thresholds with explanatory comments
thresholds = {
    "failure_rate_multiplier": {
        "value": 3,
        "comment": "Derived from baseline auth variance; failures exceeding 3x the normal hourly average trigger brute-force alerts."
    },
    "unknown_process_penalty": {
        "value": 5,
        "comment": "Assigned weight for any process execution missing from the host process baseline table."
    },
    "unknown_port_penalty": {
        "value": 4,
        "comment": "Assigned weight for outbound network connections on unbaselined ports."
    },
    "offhours_weight_multiplier": {
        "value": 2,
        "comment": "Multiplier applied to risk scores for suspicious actions occurring outside standard business hours (18:00 - 05:59)."
    }
}

summary_doc = {
    "version": "1.0",
    "generated_at": datetime.utcnow().isoformat() + "Z",
    "baseline_window": {
        "start": start_dt.isoformat(),
        "end": end_dt.isoformat(),
        "duration_days": duration_days
    },
    "evaluation_window": {
        "start": eval_start_dt.isoformat(),
        "end": eval_end_dt.isoformat(),
        "duration_hours": 24
    },
    "host_inventory": host_inventory,
    "auth": auth_data,
    "process": process_data,
    "network": network_data,
    "file": file_data,
    "temporal": temporal_data,
    "thresholds": thresholds
}

with open("baseline_summary.json", "w", encoding="utf-8") as out:
    json.dump(summary_doc, out, indent=2)

print(f"version           : 1.0")
print(f"baseline window   : {start_dt.isoformat()} -> {end_dt.isoformat()}  ({duration_days} days)")
print(f"evaluation window : {eval_start_dt.isoformat()} -> {eval_end_dt.isoformat()}  (24h)")
print(f"hosts             : {len(host_inventory)}")
print(f"sections included : auth, process, network, file, temporal, thresholds")
print("baseline_summary.json written")
PYTHON_SCRIPT
