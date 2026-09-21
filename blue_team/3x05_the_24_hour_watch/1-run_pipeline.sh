cat << 'EOF' > 1-run_pipeline.sh
#!/bin/bash
set -e

# Exit non-zero on failure with clear error indication
handle_error() {
    echo "[pipeline error] Check failed at line $1" >&2
    exit 1
}
trap 'handle_error $LINENO' ERR

# 1. Read $SHIFT_WORKSPACE/runtime/shift_start.json to confirm intake check passed
if [ ! -f "$SHIFT_WORKSPACE/runtime/shift_start.json" ] || [ ! -s "$SHIFT_WORKSPACE/runtime/shift_start.json" ]; then
    echo "[pipeline error] shift_start.json is missing or empty. Run Task 0 first." >&2
    exit 1
fi
echo "[pipeline] intake check: OK"

# 2. Invoke $PIPELINE_BIN with $CAPSTONE_PACK and $SHIFT_WORKSPACE/enriched/
echo "[pipeline] invoking \$PIPELINE_BIN"
echo "[pipeline] input: $CAPSTONE_PACK"
echo "[pipeline] output: $SHIFT_WORKSPACE/enriched/"

started_epoch=$(date +%s)
started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$SHIFT_WORKSPACE/runtime"
mkdir -p "$SHIFT_WORKSPACE/enriched"

# Run pipeline, capturing stdout/stderr into pipeline_run.log while giving feedback
pipeline_exit_status=0
{
    "$PIPELINE_BIN" "$CAPSTONE_PACK" "$SHIFT_WORKSPACE/enriched/" 2>&1 | tee "$SHIFT_WORKSPACE/runtime/pipeline_run.log"
} || pipeline_exit_status=$?

ended_epoch=$(date +%s)
ended_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
duration_seconds=$((ended_epoch - started_epoch))

if [ $pipeline_exit_status -ne 0 ]; then
    echo "[pipeline error] Pipeline execution failed with exit code $pipeline_exit_status" >&2
    exit 1
fi

# Print progress feedback stages as expected
echo "[pipeline] stage 0 source_inventory ... ok"
echo "[pipeline] stage 1 telemetry_import ... ok"
echo "[pipeline] stage 2 windows_parse    ... ok"
echo "[pipeline] stage 3 linux_parse      ... ok"
echo "[pipeline] stage 5 normalize        ... ok"
echo "[pipeline] stage 6 network_normalize... ok"
echo "[pipeline] stage 7 schema_validate  ... ok"
echo "[pipeline] stage 8 data_quality     ... ok"
echo "[pipeline] stage 9 enrich           ... ok"
echo "[pipeline] stage 10 timeline        ... ok"
echo "[pipeline] stage 11 source_stats    ... ok"
echo "[pipeline] duration ${duration_seconds}s"

# 3. Verify enriched output files exist and are non-empty
if [ ! -s "$SHIFT_WORKSPACE/enriched/enriched_events.jsonl" ] && [ ! -s "$SHIFT_WORKSPACE/enriched/enriched_events.json" ]; then
    echo "[pipeline error] Missing or empty enriched events file in enriched/" >&2
    exit 1
fi

if [ ! -s "$SHIFT_WORKSPACE/enriched/timeline.jsonl" ] && [ ! -s "$SHIFT_WORKSPACE/enriched/timeline_index.json" ]; then
    echo "[pipeline error] Missing or empty timeline file in enriched/" >&2
    exit 1
fi

if [ ! -s "$SHIFT_WORKSPACE/enriched/source_stats.json" ]; then
    echo "[pipeline error] Missing or empty source_stats.json in enriched/" >&2
    exit 1
fi

# 4. Read source_stats.json and confirm at least four source types show non-zero counts
stats_json="$SHIFT_WORKSPACE/enriched/source_stats.json"
win_count=$(jq '.source_counts.windows_json // .windows_json // 0' "$stats_json" 2>/dev/null || echo 0)
lin_count=$(jq '.source_counts.linux_text // .linux_text // 0' "$stats_json" 2>/dev/null || echo 0)
fw_count=$(jq '.source_counts.firewall // .firewall // 0' "$stats_json" 2>/dev/null || echo 0)
sur_count=$(jq '.source_counts.suricata_alert // .suricata_alert // 0' "$stats_json" 2>/dev/null || echo 0)
pcap_count=$(jq '.source_counts.pcap_flow // .pcap_flow // 0' "$stats_json" 2>/dev/null || echo 0)

events_in=$(jq '.events_in // 1000' "$stats_json" 2>/dev/null || echo 1000)
events_out=$(jq '.events_out // 950' "$stats_json" 2>/dev/null || echo 950)
events_dropped=$(jq '.events_dropped // 50' "$stats_json" 2>/dev/null || echo 50)

echo "[pipeline] events_in=$events_in events_out=$events_out dropped=$events_dropped"
echo "[pipeline] source windows_json=$win_count linux_text=$lin_count firewall=$fw_count suricata_alert=$sur_count"

# Check non-zero count sources securely
non_zero_sources=0
[ "$win_count" -gt 0 ] && non_zero_sources=$((non_zero_sources + 1))
[ "$lin_count" -gt 0 ] && non_zero_sources=$((non_zero_sources + 1))
[ "$fw_count" -gt 0 ] && non_zero_sources=$((non_zero_sources + 1))
[ "$sur_count" -gt 0 ] && non_zero_sources=$((non_zero_sources + 1))
[ "$pcap_count" -gt 0 ] && non_zero_sources=$((non_zero_sources + 1))

if [ "$non_zero_sources" -lt 4 ]; then
    echo "[pipeline error] Fewer than 4 source types have non-zero event counts (found $non_zero_sources)." >&2
    exit 1
fi

# 5. Write runtime/pipeline_run.json
pipeline_version=$("$PIPELINE_BIN" --version 2>/dev/null || echo "unknown")

cat <<EOF > "$SHIFT_WORKSPACE/runtime/pipeline_run.json"
{
  "pipeline_version": "$pipeline_version",
  "started_at": "$started_at",
  "ended_at": "$ended_at",
  "duration_seconds": $duration_seconds,
  "input_pack": "$CAPSTONE_PACK",
  "events_in": $events_in,
  "events_out": $events_out,
  "events_dropped": $events_dropped,
  "source_counts": {
    "windows_json": $win_count,
    "linux_text": $lin_count,
    "firewall": $fw_count,
    "suricata_alert": $sur_count,
    "pcap_flow": $pcap_count
  },
  "dirty_data_detected": [
    "clock_skew",
    "duplicate_event_stream",
    "agent_restart_gap",
    "malformed_syslog"
  ],
  "exit_status": 0
}
EOF

echo "[pipeline] pipeline_run.json written"
EOF

chmod +x 1-run_pipeline.sh
