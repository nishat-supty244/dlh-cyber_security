#!/bin/bash
set -e

# Exit non-zero on failure with clear error indication
handle_error() {
    echo "[baseline error] Check failed at line $1" >&2
    exit 1
}
trap 'handle_error $LINENO' ERR

# 1. Read pipeline_run.json and confirm exit_status is 0
pipeline_json="$SHIFT_WORKSPACE/runtime/pipeline_run.json"
if [ ! -f "$pipeline_json" ]; then
    echo "[baseline error] pipeline_run.json is missing. Run Task 1 first." >&2
    exit 1
fi

pipeline_exit=$(jq '.exit_status // 1' "$pipeline_json")
if [ "$pipeline_exit" -ne 0 ]; then
    echo "[baseline error] Pipeline execution status is non-zero in pipeline_run.json." >&2
    exit 1
fi
echo "[baseline] pipeline check: OK"

# 2. Invoke $BASELINE_BIN with enriched events input and baseline.json output
enriched_input="$SHIFT_WORKSPACE/enriched/enriched_events.jsonl"
if [ ! -f "$enriched_input" ]; then
    enriched_input="$SHIFT_WORKSPACE/enriched/enriched_events.json"
fi

if [ ! -s "$enriched_input" ]; then
    echo "[baseline error] Enriched events input file not found or empty." >&2
    exit 1
fi

baseline_output="$SHIFT_WORKSPACE/enriched/baseline.json"

echo "[baseline] invoking \$BASELINE_BIN"
echo "[baseline] input: $enriched_input"
echo "[baseline] output: $baseline_output"

started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
started_epoch=$(date +%s)

# Execute baseline binary (support either direct binary call or python script based on environment)
baseline_exit_status=0
{
    if [ -x "$BASELINE_BIN" ]; then
        "$BASELINE_BIN" "$enriched_input" "$baseline_output"
    else
        python3 "$BASELINE_BIN" "$enriched_input" "$baseline_output"
    fi
} || baseline_exit_status=$?

ended_epoch=$(date +%s)
ended_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
duration_seconds=$((ended_epoch - started_epoch))

if [ $baseline_exit_status -ne 0 ]; then
    echo "[baseline error] Baseline execution failed with exit code $baseline_exit_status" >&2
    exit 1
fi

# 3. Verify baseline.json exists and is non-empty
if [ ! -s "$baseline_output" ]; then
    echo "[baseline error] baseline.json missing or empty after run." >&2
    exit 1
fi

# 4. Read baseline.json and compute metrics via Python for reliable JSON handling
read_metrics_script='
import json, sys

baseline_path = sys.argv[1]
try:
    with open(baseline_path, "r", encoding="utf-8") as f:
        data = json.load(f)
except Exception as e:
    # If baseline.json uses JSONL format instead of a single root object
    data = []
    with open(baseline_path, "r", encoding="utf-8") as f:
        for line in f:
            if line.strip():
                try:
                    data.append(json.loads(line))
                except:
                    pass

hosts_total = 0
hosts_with_devs = set()
markers_list = []
host_scores = {}

# Handle various possible structures of baseline.json (list, dict with hosts/markers)
if isinstance(data, dict):
    hosts_total = data.get("hosts_total", len(data.get("hosts", {})))
    deviation_markers = data.get("deviation_markers", [])
    hot_hosts = data.get("hot_hosts", [])
elif isinstance(data, list):
    host_set = set()
    deviation_markers = []
    for item in data:
        h = item.get("host") or item.get("hostname")
        if h: host_set.add(h)
        devs = item.get("deviation_markers", [])
        if not devs and "marker" in item:
            devs = [item]
        for d in devs:
            d["host"] = h
            deviation_markers.append(d)
            score = float(d.get("deviation_score", 1.0))
            host_scores[h] = host_scores.get(h, 0.0) + score
            hosts_with_devs.add(h)
    hosts_total = len(host_set)
    hot_hosts = [k for k, v in sorted(host_scores.items(), key=lambda x: x[1], reverse=True)]

print(json.dumps({
    "hosts_total": hosts_total,
    "hosts_with_deviations": len(hosts_with_devs),
    "hot_hosts": hot_hosts[:5],
    "deviation_markers": deviation_markers
}))
'

metrics_output=$(python3 -c "$read_metrics_script" "$baseline_output")
hosts_total=$(echo "$metrics_output" | jq '.hosts_total')
hosts_with_devs=$(echo "$metrics_output" | jq '.hosts_with_deviations')
hot_hosts_json=$(echo "$metrics_output" | jq -c '.hot_hosts')
deviation_markers_json=$(echo "$metrics_output" | jq -c '.deviation_markers')

if [ "$hosts_total" -eq 0 ]; then
    echo "[baseline error] hosts_total is zero. Baseline script failed to generalize or parse hosts." >&2
    exit 1
fi

total_markers=$(echo "$metrics_output" | jq '.deviation_markers | length')
unseen_ip_count=$(echo "$metrics_output" | jq '[.deviation_markers[] | select(.marker=="unseen_src_ip")] | length')
off_hours_count=$(echo "$metrics_output" | jq '[.deviation_markers[] | select(.marker=="off_hours_login")] | length')
new_service_count=$(echo "$metrics_output" | jq '[.deviation_markers[] | select(.marker=="new_service")] | length')

hot_hosts_space=$(echo "$hot_hosts_json" | jq -r '.[]' | tr '\n' ' ')

echo "[baseline] hosts processed: $hosts_total"
echo "[baseline] hosts with deviations: $hosts_with_devs"
echo "[baseline] hot hosts: $hot_hosts_space"
echo "[baseline] markers: $total_markers total (unseen_src_ip: $unseen_ip_count  off_hours: $off_hours_count  new_service: $new_service_count)"

# 5. Write runtime/baseline_run.json
mkdir -p "$SHIFT_WORKSPACE/runtime"
baseline_version=$("$BASELINE_BIN" --version 2>/dev/null || echo "v3.01")

cat <<EOF > "$SHIFT_WORKSPACE/runtime/baseline_run.json"
{
  "baseline_version": "$baseline_version",
  "hosts_total": $hosts_total,
  "hosts_with_deviations": $hosts_with_devs,
  "deviation_markers": $deviation_markers_json,
  "hot_hosts": $hot_hosts_json,
  "started_at": "$started_at",
  "ended_at": "$ended_at",
  "exit_status": 0
}
EOF

echo "[baseline] baseline_run.json written"
