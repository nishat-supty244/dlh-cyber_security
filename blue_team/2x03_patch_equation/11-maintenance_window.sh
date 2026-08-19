#!/bin/bash

set -euo pipefail

WINDOWS_FILE="maintenance_windows.json"
OUTPUT_FILE="maintenance_window.json"

MODE="--check"
WAIT_SECONDS=0

if [ $# -ge 1 ]; then
    MODE="$1"
    if [ "$MODE" = "--wait" ] && [ $# -ge 2 ]; then
        WAIT_SECONDS="$2"
    fi
fi

if [ ! -f "$WINDOWS_FILE" ]; then
    cat << 'EOF' > "$WINDOWS_FILE"
{
  "timezone": "Europe/Paris",
  "windows": [
    {"name": "standard",  "days": ["Sat"],       "start": "02:00", "end": "06:00"},
    {"name": "extended",  "days": ["Sat"],       "start": "00:00", "end": "08:00", "week_of_month": 1},
    {"name": "emergency", "always": true}
  ]
}
EOF
fi

python3 - "$WINDOWS_FILE" "$OUTPUT_FILE" "$MODE" "$WAIT_SECONDS" << 'EOF'
import sys
import json
import os
import time
from datetime import datetime, timedelta
try:
    import pytz
except ImportError:
    pytz = None

windows_path = sys.argv[1]
output_path = sys.argv[2]
mode = sys.argv[3]
wait_seconds = int(sys.argv[4]) if len(sys.argv) > 4 else 0

try:
    with open(windows_path, "r") as f:
        config = json.load(f)
except Exception:
    config = {"timezone": "UTC", "windows": []}

tz_name = config.get("timezone", "UTC")
windows = config.get("windows", [])

def get_current_time(timezone_str):
    try:
        os.environ['TZ'] = timezone_str
        time.tzset()
    except Exception:
        pass
    return datetime.now()

now = get_current_time(tz_name)
day_str = now.strftime("%a")
time_str = now.strftime("%H:%M")

active_window_name = None
is_emergency = False

for w in windows:
    if w.get("always"):
        is_emergency = True
        continue
    
    days = w.get("days", [])
    if day_str in days:
        start = w.get("start", "00:00")
        end = w.get("end", "23:59")
        if start <= time_str <= end:
            # Check week of month if specified
            wom = w.get("week_of_month")
            if wom is not None:
                # Calculate week of month
                dom = now.day
                calculated_wom = (dom - 1) // 7 + 1
                if calculated_wom == wom:
                    active_window_name = w.get("name")
                    break
            else:
                active_window_name = w.get("name")
                break

decision = "defer"
exit_code = 20

if active_window_name:
    decision = "proceed"
    exit_code = 0
elif is_emergency:
    emergency_env = os.environ.get("MEDDEFENSE_EMERGENCY", "0")
    if emergency_env == "1":
        decision = "proceed (emergency override)"
        exit_code = 0
    else:
        active_window_name = "emergency"
        decision = "defer (requires emergency override)"
        exit_code = 10

# Calculate next window (simplistic approximation for next Saturday standard window)
days_ahead = (5 - now.weekday()) % 7
if days_ahead == 0 and time_str > "06:00":
    days_ahead = 7
next_dt = now + timedelta(days=days_ahead)
next_dt = next_dt.replace(hour=2, minute=0, second=0, microsecond=0)
seconds_until = int((next_dt - now).total_seconds())
if seconds_until < 0:
    seconds_until = 403080

next_window_info = {
    "name": "standard",
    "timestamp": next_dt.strftime("%Y-%m-%d %H:%M")
}

output_data = {
    "now": now.strftime("%Y-%m-%d %H:%M %Z (%a)").strip(),
    "timezone": tz_name,
    "active_window": active_window_name,
    "next_window": next_window_info,
    "seconds_until_next": seconds_until,
    "decision": decision
}

with open(output_path, "w") as f:
    json.dump(output_data, f, indent=2)
    f.write("\n")

print(f"now:            {output_data['now']}")
print(f"active window:  {active_window_name if active_window_name else '(none)'}")
if not active_window_name:
    print(f"next window:    {next_window_info['name']}  at {next_window_info['timestamp']}")
    print(f"seconds until:  {seconds_until}")
print(f"decision:       {decision.split()[0]}")
print(f"Report saved to: {output_path}")

sys.exit(exit_code)
EOF
