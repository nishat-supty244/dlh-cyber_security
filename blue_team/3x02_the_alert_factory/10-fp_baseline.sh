
#!/bin/bash
# shellcheck shell=bash
set -euo pipefail

SUMMARY_FILE=""
if [ -f "baseline_summary.json" ]; then
    SUMMARY_FILE="baseline_summary.json"
elif [ -n "${BASELINE_PKG:-}" ] && [ -f "$BASELINE_PKG/baselines/baseline_summary.json" ]; then
    SUMMARY_FILE="$BASELINE_PKG/baselines/baseline_summary.json"
else
    SUMMARY_FILE="baseline_summary.json"
fi

if [ ! -f "$SUMMARY_FILE" ]; then
    echo "Error: Baseline summary not found locally or in BASELINE_PKG" >&2
    exit 1
fi

WINDOW_INFO=$(python3 -c '
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
        start = data.get("baseline_start", "2026-03-18")
        end = data.get("baseline_end", "2026-03-24")
        print(f"{start},{end}")
except Exception:
    print("2026-03-18,2026-03-24")
' "$SUMMARY_FILE")

START_DATE=$(echo "$WINDOW_INFO" | cut -d',' -f1)
END_DATE=$(echo "$WINDOW_INFO" | cut -d',' -f2)
WINDOW_PARAM="${START_DATE},${END_DATE}"

RULE_DIR="rules/sigma"
if [ ! -d "$RULE_DIR" ]; then
    echo "Error: Rule directory $RULE_DIR does not exist." >&2
    exit 1
fi

RULE_FILES=("$RULE_DIR"/*.yml)
TOTAL_RULES=${#RULE_FILES[@]}

echo "evaluating $TOTAL_RULES rules against baseline window $START_DATE -> $END_DATE"

python3 - << 'PY_EOF' "$RULE_DIR" "$WINDOW_PARAM" "$START_DATE" "$END_DATE"
import os
import sys
import subprocess
import json
import yaml

rule_dir = sys.argv[1]
window_param = sys.argv[2]
start_date = sys.argv[3]
end_date = sys.argv[4]

results = []
rule_files = sorted([os.path.join(rule_dir, f) for f in os.listdir(rule_dir) if f.endswith('.yml')])

for rf in rule_files:
    try:
        with open(rf, 'r') as f:
            rule_data = yaml.safe_load(f)
        rule_id = rule_data.get('id', 'unknown-id')
        rule_title = rule_data.get('title', 'unknown-title')
        level = rule_data.get('level', 'medium')
        short_name = os.path.basename(rf).replace('.yml', '')
    except Exception:
        continue

    cmd = ["./3-sigma_runner.sh", rf, "--window", window_param, "--count-only"]
    try:
        res = subprocess.run(cmd, capture_output=True, text=True, check=True)
        fp_count = int(res.stdout.strip())
    except Exception:
        fp_count = 0

    fp_rate_per_day = round(fp_count / 7.0, 2)

    results.append({
        "rule_id": rule_id,
        "rule_title": rule_title,
        "short_name": short_name,
        "level": level,
        "fp_count": fp_count,
        "baseline_window_start": start_date,
        "baseline_window_end": end_date,
        "fp_rate_per_day": fp_rate_per_day
    })

results_sorted = sorted(results, key=lambda x: x['fp_count'], reverse=True)

for r in results_sorted:
    tune_tag = "   [TUNE]" if r['fp_count'] > 10 else ""
    print(f"  {r['short_name']:35} fp= {r['fp_count']:2}{tune_tag}")

output_data = {
    "baseline_window_start": start_date,
    "baseline_window_end": end_date,
    "evaluations": results_sorted
}
with open("fp_baseline.json", "w") as f:
    json.dump(output_data, f, indent=2)

PY_EOF

echo "fp_baseline.json written"
