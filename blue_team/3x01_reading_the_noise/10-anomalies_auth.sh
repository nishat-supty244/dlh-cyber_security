
#!/bin/bash
# Task 10: Authentication Anomalies
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
from collections import defaultdict

summary_file = sys.argv[1]
events_file = sys.argv[2]

with open(summary_file, 'r', encoding='utf-8') as f:
    summary = json.load(f)

baseline_window = summary.get("baseline_window", {})
eval_window = summary.get("evaluation_window", {})

b_start_str = baseline_window.get("start")
b_end_str = baseline_window.get("end")
e_start_str = eval_window.get("start")
e_end_str = eval_window.get("end")

thresholds = summary.get("thresholds", {})
failure_multiplier = thresholds.get("failure_rate_multiplier", {}).get("value", 3)
summary_max_failures = summary.get("auth", {}).get("max_failures_1h_window", 0)

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

b_start = datetime.fromisoformat(b_start_str.replace("Z", "+00:00")) if b_start_str else None
b_end = datetime.fromisoformat(b_end_str.replace("Z", "+00:00")) if b_end_str else None
e_start = datetime.fromisoformat(e_start_str.replace("Z", "+00:00")) if e_start_str else None
e_end = datetime.fromisoformat(e_end_str.replace("Z", "+00:00")) if e_end_str else None

# If eval window not explicitly set, default to 24h after baseline end
if not e_start and b_end:
    e_start = b_end
    e_end = e_start + timedelta(hours=24)

baseline_events = []
eval_events = []

for ev in events:
    ts_str = ev.get("timestamp")
    if not ts_str:
        continue
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        if b_start and b_end and b_start <= dt < b_end:
            baseline_events.append((dt, ev))
        elif e_start and e_end and e_start <= dt < e_end:
            eval_events.append((dt, ev))
    except ValueError:
        continue

# Build baseline intelligence
baseline_known_accounts = set(summary.get("auth", {}).get("known_accounts", []))
user_baseline_hours = defaultdict(set)
baseline_ip_failures = defaultdict(list)
baseline_priv_esc_hosts = defaultdict(int)

for dt, ev in baseline_events:
    user = ev.get("username") or ev.get("user") or ev.get("account")
    label = ev.get("canonical_label")
    src_ip = ev.get("src_ip")
    host = ev.get("hostname", "unknown")

    if user:
        user_baseline_hours[user].add(dt.hour)
    
    if label == "login_failure" and src_ip:
        baseline_ip_failures[src_ip].append(dt)
        
    if label == "privilege_escalation":
        baseline_priv_esc_hosts[host] += 1

# Calculate dynamic failure burst threshold
baseline_max_1h_failures = summary_max_failures
if not baseline_max_1h_failures and baseline_ip_failures:
    max_f = 0
    for ip, times in baseline_ip_failures.items():
        times.sort()
        for i in range(len(times)):
            t_start = times[i]
            t_end = t_start + timedelta(hours=1)
            cnt = sum(1 for t in times if t_start <= t <= t_end)
            if cnt > max_f:
                max_f = cnt
    baseline_max_1h_failures = max_f

burst_threshold = baseline_max_1h_failures * failure_multiplier

# Track evaluation window anomalies
anomalies = []
counts = {
    "unknown_account": 0,
    "failure_rate_burst": 0,
    "offhours_login": 0,
    "privilege_escalation_surge": 0
}

# Pre-gather evaluation failure timestamps by IP for burst detection
eval_ip_failures = defaultdict(list)
for dt, ev in eval_events:
    if ev.get("canonical_label") == "login_failure":
        ip = ev.get("src_ip")
        if ip:
            eval_ip_failures[ip].append((dt, ev))

flagged_burst_ips = set()
for dt, ev in eval_events:
    host = ev.get("hostname", "unknown")
    user = ev.get("username") or ev.get("user") or ev.get("account") or "unknown"
    src_ip = ev.get("src_ip", "unknown")
    label = ev.get("canonical_label")
    ts = ev.get("timestamp")

    # 1. Unknown Account
    if user != "unknown" and user not in baseline_known_accounts:
        counts["unknown_account"] += 1
        anomalies.append({
            "timestamp": ts,
            "host": host,
            "user": user,
            "src_ip": src_ip,
            "anomaly_type": "unknown_account",
            "baseline_value": "not in known_accounts",
            "observed_value": user,
            "severity": "high",
            "event_refs": [ev.get("event_id", ts)]
        })

    # 2. Off-hours login (Login success outside 06:00-17:59 for users who only logged in during business hours)
    if label == "login_success" and user in user_baseline_hours:
        baseline_hours = user_baseline_hours[user]
        # Check if user only ever logged in during biz hours (06-17) in baseline
        only_biz = all(6 <= h < 18 for h in baseline_hours)
        current_hour = dt.hour
        is_offhours = not (6 <= current_hour < 18)
        if only_biz and is_offhours:
            counts["offhours_login"] += 1
            anomalies.append({
                "timestamp": ts,
                "host": host,
                "user": user,
                "src_ip": src_ip,
                "anomaly_type": "offhours_login",
                "baseline_value": "business_hours_only",
                "observed_value": f"hour_{current_hour}",
                "severity": "medium",
                "event_refs": [ev.get("event_id", ts)]
            })

    # 3. Privilege Escalation Surge (>0 when baseline has 0)
    if label == "privilege_escalation":
        baseline_priv_count = baseline_priv_esc_hosts.get(host, 0)
        if baseline_priv_count == 0:
            counts["privilege_escalation_surge"] += 1
            anomalies.append({
                "timestamp": ts,
                "host": host,
                "user": user,
                "src_ip": src_ip,
                "anomaly_type": "privilege_escalation_surge",
                "baseline_value": 0,
                "observed_value": "present",
                "severity": "critical",
                "event_refs": [ev.get("event_id", ts)]
            })

# 4. Failure Rate Burst check per IP in eval window
for ip, failures in eval_ip_failures.items():
    failures.sort(key=lambda x: x[0])
    for i in range(len(failures)):
        t_start, ev = failures[i]
        t_end = t_start + timedelta(hours=1)
        window_fails = [item for item in failures if t_start <= item[0] <= t_end]
        if len(window_fails) > burst_threshold:
            # Flag once per unique burst window or per event
            ts = ev.get("timestamp")
            host = ev.get("hostname", "unknown")
            user = ev.get("username") or "unknown"
            counts["failure_rate_burst"] += 1
            anomalies.append({
                "timestamp": ts,
                "host": host,
                "user": user,
                "src_ip": ip,
                "anomaly_type": "failure_rate_burst",
                "baseline_value": f"max_1h_{baseline_max_1h_failures} * {failure_multiplier}",
                "observed_value": len(window_fails),
                "severity": "high",
                "event_refs": [item[1].get("event_id", item[1].get("timestamp")) for item in window_fails]
            })
            # Skip ahead to avoid flooding duplicate entries for the same burst
            break

total_anomalies = sum(counts.values())

with open("anomalies_auth.json", "w", encoding="utf-8") as out:
    json.dump(anomalies, out, indent=2)

print(f"evaluation window  : {e_start.isoformat()} -> {e_end.isoformat()}")
print(f"unknown_account           : {counts['unknown_account']}")
print(f"failure_rate_burst        : {counts['failure_rate_burst']}")
print(f"offhours_login            : {counts['offhours_login']}")
print(f"privilege_escalation_surge: {counts['privilege_escalation_surge']}")
print(f"total anomalies           : {total_anomalies}")
print("anomalies_auth.json written")
PYTHON_SCRIPT
