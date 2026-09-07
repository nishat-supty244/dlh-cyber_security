#!/bin/bash
# Task 15: Baseline Validation
set -euo pipefail

SUMMARY_FILE="baseline_summary.json"
if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: baseline_summary.json not found." >&2
    exit 1
fi

python3 - << 'PYTHON_SCRIPT'
import json
import subprocess
import os
import sys

with open("baseline_summary.json", 'r', encoding='utf-8') as f:
    summary = json.load(f)

b_window = summary.get("baseline_window", {})
e_window = summary.get("evaluation_window", {})

def run_checks(is_self_check):
    if is_self_check:
        summary["evaluation_window"] = b_window
    else:
        summary["evaluation_window"] = e_window
    
    with open("baseline_summary.json", 'w', encoding='utf-8') as f:
        json.dump(summary, f, indent=2)

    if os.path.exists("./10-anomalies_auth.sh"):
        subprocess.run(["./10-anomalies_auth.sh"], check=False, stdout=subprocess.DEVNULL)
    if os.path.exists("./11-anomalies_process.sh"):
        subprocess.run(["./11-anomalies_process.sh"], check=False, stdout=subprocess.DEVNULL)
    if os.path.exists("./12-anomalies_network.sh"):
        subprocess.run(["./12-anomalies_network.sh"], check=False, stdout=subprocess.DEVNULL)

    def load_json(fn):
        if os.path.exists(fn):
            try:
                with open(fn, 'r', encoding='utf-8') as cf:
                    return json.load(cf)
            except Exception:
                return []
        return []

    auth_anom = load_json("anomalies_auth.json")
    proc_anom = load_json("anomalies_process.json")
    net_anom = load_json("anomalies_network.json")

    prefix = "self_check" if is_self_check else "live_check"
    with open(f"{prefix}_auth.json", "w", encoding='utf-8') as f:
        json.dump(auth_anom, f, indent=2)
    with open(f"{prefix}_process.json", "w", encoding='utf-8') as f:
        json.dump(proc_anom, f, indent=2)
    with open(f"{prefix}_network.json", "w", encoding='utf-8') as f:
        json.dump(net_anom, f, indent=2)

    return auth_anom + proc_anom + net_anom

# Run Self-Check against baseline window
self_items = run_checks(True)

# Run Live-Check against evaluation window
live_items = run_checks(False)

# Restore evaluation window in summary
summary["evaluation_window"] = e_window
with open("baseline_summary.json", 'w', encoding='utf-8') as f:
    json.dump(summary, f, indent=2)

def get_breakdown(items):
    breakdown = {}
    for item in items:
        t = item.get("anomaly_type", "unknown")
        breakdown[t] = breakdown.get(t, 0) + 1
    return breakdown

self_total = len(self_items)
live_total = len(live_items)
snr = round(live_total / max(self_total, 1), 2)

self_breakdown = get_breakdown(self_items)
live_breakdown = get_breakdown(live_items)

acceptable_threshold = 5
verdict = "pass" if self_total < acceptable_threshold and snr >= 3.0 else "fail"

validation_doc = {
    "self_check_total": self_total,
    "live_check_total": live_total,
    "signal_to_noise_ratio": snr,
    "self_check_breakdown": self_breakdown,
    "live_check_breakdown": live_breakdown,
    "verdict": verdict
}

with open("baseline_validation.json", "w", encoding='utf-8') as out:
    json.dump(validation_doc, out, indent=2)

print(f"self-check anomalies (baseline window): {self_total}")
print(f"live-check anomalies (evaluation win ): {live_total}")
print(f"signal-to-noise ratio                : {snr}")
print(f"verdict                              : {verdict}")
print("baseline_validation.json written")

if verdict == "fail":
    sys.exit(1)
else:
    sys.exit(0)
PYTHON_SCRIPT
