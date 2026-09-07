cat << 'EOF' > 5-baseline_process.sh
#!/bin/bash
# Task 5: Process Execution Baseline
set -euo pipefail

BASELINE_DAYS="${BASELINE_DAYS:-7}"
INPUT_FILE="labeled_events.json"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: labeled_events.json not found." >&2
    exit 1
fi

python3 - "$INPUT_FILE" "$BASELINE_DAYS" << 'PYTHON_SCRIPT'
import sys
import json
from datetime import datetime, timedelta
from collections import defaultdict, Counter

input_file = sys.argv[1]
baseline_days = int(sys.argv[2])

events = []
with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
            events.append(rec)
        except json.JSONDecodeError:
            continue

# Filter process-related events
process_labels = {"process_start", "process_stop", "child_process_spawn"}
process_events = [ev for ev in events if ev.get("canonical_label") in process_labels or ev.get("source_type") == "process"]

if not process_events:
    process_events = events

valid_times = []
for ev in process_events:
    ts_str = ev.get("timestamp")
    if ts_str:
        try:
            dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            valid_times.append(dt)
        except ValueError:
            pass

start_dt = min(valid_times) if valid_times else datetime.utcnow()
end_dt = start_dt + timedelta(days=baseline_days)

window_events = []
for ev in process_events:
    ts_str = ev.get("timestamp")
    if ts_str:
        try:
            dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            if start_dt <= dt <= end_dt:
                window_events.append((dt, ev))
        except ValueError:
            pass

# Structures for aggregation
host_processes = defaultdict(lambda: defaultdict(lambda: {"count": 0, "first_seen": None, "last_seen": None, "users": set()}))
global_process_counter = Counter()
process_host_map = defaultdict(set)
process_total_counts = Counter()
parent_child_by_host = defaultdict(set)

for dt, ev in window_events:
    host = ev.get("hostname", "unknown")
    proc_name = ev.get("process_name") or ev.get("name") or ev.get("command") or "unknown_process"
    user = ev.get("username") or ev.get("user") or ev.get("account") or "unknown_user"
    
    # Track global stats
    global_process_counter[proc_name] += 1
    process_total_counts[proc_name] += 1
    process_host_map[proc_name].add(host)

    # Host process stats
    p_stat = host_processes[host][proc_name]
    p_stat["count"] += 1
    if p_stat["first_seen"] is None or dt.isoformat() < p_stat["first_seen"]:
        p_stat["first_seen"] = dt.isoformat()
    if p_stat["last_seen"] is None or dt.isoformat() > p_stat["last_seen"]:
        p_stat["last_seen"] = dt.isoformat()
    if user != "unknown_user":
        p_stat["users"].add(user)

    # Parent-child pairs
    parent = ev.get("parent_process") or ev.get("parent") or ev.get("parent_name")
    if parent:
        parent_child_by_host[host].add(f"{parent} -> {proc_name}")

# Format per_host data
per_host_formatted = {}
for host, procs in host_processes.items():
    per_host_formatted[host] = []
    for proc_name, stats in procs.items():
        per_host_formatted[host].append({
            "process_name": proc_name,
            "execution_count": stats["count"],
            "first_seen": stats["first_seen"],
            "last_seen": stats["last_seen"],
            "distinct_users": sorted(list(stats["users"]))
        })

# Global top 50
global_top = [{"process_name": p, "executions": c} for p, c in global_process_counter.most_common(50)]

# Rare processes: appear on only one host OR run fewer than five times total
rare_processes = []
for proc, count in process_total_counts.items():
    hosts_seen = process_host_map[proc]
    if len(hosts_seen) == 1 or count < 5:
        rare_processes.append({
            "process_name": proc,
            "total_executions": count,
            "hosts": sorted(list(hosts_seen))
        })

# Parent-child pairs formatted
parent_child_formatted = {}
total_pairs_count = 0
for host, pairs in parent_child_by_host.items():
    parent_child_formatted[host] = sorted(list(pairs))
    total_pairs_count += len(pairs)

baseline_data = {
    "window": {"start": start_dt.isoformat(), "end": end_dt.isoformat()},
    "per_host": per_host_formatted,
    "global_top": global_top,
    "rare_processes": rare_processes,
    "parent_child_pairs": parent_child_formatted
}

with open("baseline_process.json", "w", encoding="utf-8") as out:
    json.dump(baseline_data, out, indent=2)

top_proc_name, top_proc_count = (global_process_counter.most_common(1)[0] if global_process_counter else ("none", 0))

print(f"baseline window : {start_dt.isoformat()} -> {end_dt.isoformat()}")
print(f"processes indexed by host: {len(host_processes)} hosts")
print(f"global top process    : {top_proc_name} ({top_proc_count} executions)")
print(f"rare processes        : {len(rare_processes)}")
print(f"parent->child pairs   : {total_pairs_count}")
print("baseline_process.json written")
PYTHON_SCRIPT
EOF
