
#!/bin/bash
# Task 11: Process Anomalies
set -euo pipefail

SUMMARY_FILE="baseline_summary.json"
EVENTS_FILE="labeled_events.json"

if [ ! -f "$SUMMARY_FILE" ] || [ ! -f "$EVENTS_FILE" ]; then
    echo "Error: baseline_summary.json or labeled_events.json not found." >&2
    exit 1
fi

python3 - "$SUMMARY_FILE" "$EVENTS_FILE" << 'PYTHON_SCRIPT'
import sys
import json
from datetime import datetime, timedelta
from collections import defaultdict, Counter

summary_file = sys.argv[1]
events_file = sys.argv[2]

with open(summary_file, 'r', encoding='utf-8') as f:
    summary = json.load(f)

eval_window = summary.get("evaluation_window", {})
e_start_str = eval_window.get("start")
e_end_str = eval_window.get("end")

# Load events
events = []
with open(events_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            events.append(json.loads(line))
        except json.JSONDecodeError:
            continue

e_start = datetime.fromisoformat(e_start_str.replace("Z", "+00:00")) if e_start_str else None
e_end = datetime.fromisoformat(e_end_str.replace("Z", "+00:00")) if e_end_str else None

# Fallback evaluation window if missing
if not e_start:
    e_start = datetime.utcnow()
    e_end = e_start + timedelta(hours=24)

eval_events = []
for ev in events:
    ts_str = ev.get("timestamp")
    if not ts_str:
        continue
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        if e_start <= dt < e_end:
            eval_events.append((dt, ev))
    except ValueError:
        continue

# Extract baseline process intelligence from summary
process_summary = summary.get("process", {})
per_host_baseline = process_summary.get("per_host", {})
parent_child_baseline = process_summary.get("parent_child_pairs", {})
rare_processes_list = process_summary.get("rare_processes", [])

# Build fast lookup sets
host_baseline_procs = defaultdict(set)
for host, procs in per_host_baseline.items():
    for p in procs:
        p_name = p.get("process_name")
        if p_name:
            host_baseline_procs[host].add(p_name)

host_baseline_pairs = defaultdict(set)
for host, pairs in parent_child_baseline.items():
    for pair in pairs:
        host_baseline_pairs[host].add(pair)

rare_proc_names = {item.get("process_name") for item in rare_processes_list}
rare_proc_total_counts = {item.get("process_name"): item.get("total_executions", 0) for item in rare_processes_list}

HIGH_RISK_WATCHLIST = {"powershell.exe", "cmd.exe", "wscript.exe", "mshta.exe", "nc", "nmap", "wget", "curl", "python3", "bash"}

SEVERITY_RUBRIC = {
    "unknown_process_for_host": "medium",
    "unknown_parent_child": "medium",
    "rare_process_spike": "high",
    "high_risk_process": "high"
}

# Count eval executions per host/process for rare spike detection
eval_host_process_counts = defaultdict(Counter)
for dt, ev in eval_events:
    host = ev.get("hostname", "unknown")
    p_name = ev.get("process_name") or ev.get("name") or ev.get("command") or "unknown"
    eval_host_process_counts[host][p_name] += 1

anomalies = []
counts = {
    "unknown_process_for_host": 0,
    "unknown_parent_child": 0,
    "rare_process_spike": 0,
    "high_risk_process": 0
}

# Track already flagged spikes to avoid multi-entry per process per host
flagged_spikes = set()

for dt, ev in eval_events:
    host = ev.get("hostname", "unknown")
    user = ev.get("username") or ev.get("user") or ev.get("account") or "unknown"
    p_name = ev.get("process_name") or ev.get("name") or ev.get("command") or "unknown"
    parent = ev.get("parent_process") or ev.get("parent") or ev.get("parent_name") or "unknown"
    ts = ev.get("timestamp")
    event_id = ev.get("event_id", ts)

    # 1. Unknown Process for Host
    if p_name != "unknown" and p_name not in host_baseline_procs[host]:
        counts["unknown_process_for_host"] += 1
        anomalies.append({
            "timestamp": ts,
            "host": host,
            "user": user,
            "process_name": p_name,
            "parent_process_name": parent,
            "anomaly_type": "unknown_process_for_host",
            "severity": SEVERITY_RUBRIC["unknown_process_for_host"],
            "event_refs": [event_id]
        })

    # 2. Unknown Parent-Child Pair
    if parent != "unknown" and p_name != "unknown":
        pair_str = f"{parent} -> {p_name}"
        if pair_str not in host_baseline_pairs[host]:
            counts["unknown_parent_child"] += 1
            anomalies.append({
                "timestamp": ts,
                "host": host,
                "user": user,
                "process_name": p_name,
                "parent_process_name": parent,
                "anomaly_type": "unknown_parent_child",
                "severity": SEVERITY_RUBRIC["unknown_parent_child"],
                "event_refs": [event_id]
            })

    # 3. Rare Process Spike (< 5 in baseline total, > 10 in eval on single host)
    if p_name in rare_proc_names:
        baseline_total = rare_proc_total_counts.get(p_name, 0)
        eval_count = eval_host_process_counts[host][p_name]
        spike_key = (host, p_name)
        if baseline_total < 5 and eval_count > 10 and spike_key not in flagged_spikes:
            flagged_spikes.add(spike_key)
            counts["rare_process_spike"] += 1
            anomalies.append({
                "timestamp": ts,
                "host": host,
                "user": user,
                "process_name": p_name,
                "parent_process_name": parent,
                "anomaly_type": "rare_process_spike",
                "severity": SEVERITY_RUBRIC["rare_process_spike"],
                "event_refs": [event_id]
            })

    # 4. High Risk Process (Watchlist match running on a host where it did not run in baseline)
    if p_name in HIGH_RISK_WATCHLIST:
        if p_name not in host_baseline_procs[host]:
            counts["high_risk_process"] += 1
            anomalies.append({
                "timestamp": ts,
                "host": host,
                "user": user,
                "process_name": p_name,
                "parent_process_name": parent,
                "anomaly_type": "high_risk_process",
                "severity": SEVERITY_RUBRIC["high_risk_process"],
                "event_refs": [event_id]
            })

total_anomalies = sum(counts.values())

with open("anomalies_process.json", "w", encoding="utf-8") as out:
    json.dump(anomalies, out, indent=2)

print(f"evaluation window : {e_start.isoformat()} -> {e_end.isoformat()}")
print(f"unknown_process_for_host : {counts['unknown_process_for_host']}")
print(f"unknown_parent_child     : {counts['unknown_parent_child']}")
print(f"rare_process_spike       : {counts['rare_process_spike']}")
print(f"high_risk_process        : {counts['high_risk_process']}")
print(f"total anomalies          : {total_anomalies}")
print("anomalies_process.json written")
PYTHON_SCRIPT
