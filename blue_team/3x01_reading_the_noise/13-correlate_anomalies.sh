#!/bin/bash
# Task 13: Cross-Source Correlation
set -euo pipefail

PYTHON_SCRIPT="correlate.py"

cat << 'PYTHON_EOF' > "$PYTHON_SCRIPT"
import json
import os
from datetime import datetime, timedelta
from collections import defaultdict
import hashlib

def load_json(filename):
    if os.path.exists(filename):
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                return json.load(f)
        except Exception:
            return []
    return []

auth_anomalies = load_json("anomalies_auth.json")
process_anomalies = load_json("anomalies_process.json")
network_anomalies = load_json("anomalies_network.json")

# Tag each anomaly with its source category
all_items = []
for item in auth_anomalies:
    item["_source_cat"] = "auth"
    all_items.append(item)
for item in process_anomalies:
    item["_source_cat"] = "process"
    all_items.append(item)
for item in network_anomalies:
    item["_source_cat"] = "network"
    all_items.append(item)

# Parse timestamps and group by host
host_items = defaultdict(list)
for item in all_items:
    ts_str = item.get("timestamp")
    host = item.get("hostname") or item.get("host") or "unknown"
    if ts_str:
        try:
            dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            item["_dt"] = dt
            item["_host"] = host
            host_items[host].append(item)
        except ValueError:
            continue

correlation_window_sec = 300  # Default 5 minutes
correlated_findings = []
single_source_count = len(all_items)

# Asset criticality mapping (multiplier)
asset_multipliers = {
    "db-patient-01": 3,
    "clin-ws-07": 2,
    "domain-controller": 3
}

for host, items in host_items.items():
    # Sort items by timestamp
    items.sort(key=lambda x: x["_dt"])
    
    # Simple sliding window grouping
    visited = [False] * len(items)
    for i in range(len(items)):
        if visited[i]:
            continue
        
        cluster = [items[i]]
        visited[i] = True
        window_start = items[i]["_dt"]
        window_end = window_start + timedelta(seconds=correlation_window_sec)
        
        for j in range(i + 1, len(items)):
            if not visited[j] and items[j]["_dt"] <= window_end:
                cluster.append(items[j])
                visited[j] = True
                if items[j]["_dt"] > window_end:
                    window_end = items[j]["_dt"]

        # Only form a correlated finding if 2 or more items are grouped, OR output all? 
        # The goal is combining multi-source or clustered items. Let's group clusters of >= 2 or individual clusters.
        sources_involved = sorted(list({item["_source_cat"] for item in cluster}))
        anomaly_types = sorted(list({item.get("anomaly_type") for item in cluster if item.get("anomaly_type")}))
        member_refs = [item.get("event_refs", [item.get("timestamp")])[0] for item in cluster]
        
        # Scoring logic: 1 per involved source + bonus for each distinct anomaly type * asset multiplier
        multiplier = asset_multipliers.get(host, 1)
        score = (len(sources_involved) + len(anomaly_types)) * multiplier

        # Generate deterministic short ID
        id_raw = f"{host}_{window_start.isoformat()}_{len(cluster)}"
        corr_id = "corr_" + hashlib.md5(id_raw.encode()).hexdigest()[:8]

        correlated_findings.append({
            "correlation_id": corr_id,
            "host": host,
            "window_start": window_start.isoformat(),
            "window_end": window_end.isoformat(),
            "sources_involved": sources_involved,
            "anomaly_types": anomaly_types,
            "member_refs": member_refs,
            "score": score,
            "item_count": len(cluster)
        })

multi_host_findings = len(set(f["host"] for f in correlated_findings if len(f["sources_involved"]) > 1))
max_score = max([f["score"] for f in correlated_findings]) if correlated_findings else 0

with open("correlated_anomalies.json", "w", encoding="utf-8") as out:
    json.dump(correlated_findings, out, indent=2)

print(f"single-source anomalies  : {single_source_count}")
print(f"correlated findings      : {len(correlated_findings)}")
print(f"multi-host findings      : {multi_host_findings}")
print(f"max score                : {max_score}")
print("correlated_anomalies.json written")
PYTHON_EOF

python3 "$PYTHON_SCRIPT"
rm -f "$PYTHON_SCRIPT"
