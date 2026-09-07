
#!/bin/bash
# Task 4: Authentication Baseline
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
from collections import defaultdict

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

auth_labels = {"login_success", "login_failure", "logout", "account_lockout", "privilege_escalation"}
auth_events = [ev for ev in events if ev.get("canonical_label") in auth_labels or ev.get("source_type") == "auth"]

if not auth_events:
    auth_events = events

valid_times = []
for ev in auth_events:
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
for ev in auth_events:
    ts_str = ev.get("timestamp")
    if ts_str:
        try:
            dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
            if start_dt <= dt <= end_dt:
                window_events.append((dt, ev))
        except ValueError:
            pass

per_host = defaultdict(lambda: {"login_success": 0, "login_failure": 0, "logout": 0, "account_lockout": 0, "privilege_escalation": 0})
user_counts = defaultdict(lambda: {"success": 0, "failure": 0})
known_accounts_set = set()

biz_success = 0
biz_failure = 0
off_success = 0
off_failure = 0
ip_failure_times = defaultdict(list)

for dt, ev in window_events:
    host = ev.get("hostname", "unknown")
    label = ev.get("canonical_label")
    user = ev.get("username") or ev.get("user") or ev.get("account") or "unknown"
    src_ip = ev.get("src_ip", "unknown")

    if label in per_host[host]:
        per_host[host][label] += 1

    if user != "unknown":
        known_accounts_set.add(user)
        if label == "login_success":
            user_counts[user]["success"] += 1
        elif label == "login_failure":
            user_counts[user]["failure"] += 1

    hour = dt.hour
    is_biz = 6 <= hour < 18

    if label == "login_success":
        if is_biz: biz_success += 1
        else: off_success += 1
    elif label == "login_failure":
        if is_biz: biz_failure += 1
        else: off_failure += 1

    if label == "login_failure" and src_ip != "unknown":
        ip_failure_times[src_ip].append(dt)

biz_hours = baseline_days * 12
off_hours = baseline_days * 12

biz_success_avg = round(biz_success / biz_hours, 2) if biz_hours > 0 else 0.0
biz_failure_avg = round(biz_failure / biz_hours, 2) if biz_hours > 0 else 0.0
off_success_avg = round(off_success / off_hours, 2) if off_hours > 0 else 0.0
off_failure_avg = round(off_failure / off_hours, 2) if off_hours > 0 else 0.0

max_1h_failures = 0
for ip, times in ip_failure_times.items():
    times.sort()
    for i in range(len(times)):
        t_start = times[i]
        t_end = t_start + timedelta(hours=1)
        count = sum(1 for t in times if t_start <= t <= t_end)
        if count > max_1h_failures:
            max_1h_failures = count

per_user_list = [{"username": u, "success": c["success"], "failure": c["failure"]} for u, c in user_counts.items()]

baseline_data = {
    "window": {"start": start_dt.isoformat(), "end": end_dt.isoformat()},
    "per_host": dict(per_host),
    "per_user": per_user_list,
    "known_accounts": sorted(list(known_accounts_set)),
    "business_hours_avg": {"success": biz_success_avg, "failure": biz_failure_avg},
    "offhours_avg": {"success": off_success_avg, "failure": off_failure_avg},
    "max_failures_1h_window": max_1h_failures
}

with open("baseline_auth.json", "w", encoding="utf-8") as out:
    json.dump(baseline_data, out, indent=2)

print(f"baseline window : {start_dt.isoformat()} -> {end_dt.isoformat()}")
print(f"hosts           : {len(per_host)}")
print(f"known accounts  : {len(known_accounts_set)}")
print(f"business hours  : {biz_success_avg} success/h  |  {biz_failure_avg} failure/h")
print(f"off hours       : {off_success_avg} success/h  |  {off_failure_avg} failure/h")
print(f"max 1h src_ip failures : {max_1h_failures}")
print("baseline_auth.json written")
PYTHON_SCRIPT
EOF
