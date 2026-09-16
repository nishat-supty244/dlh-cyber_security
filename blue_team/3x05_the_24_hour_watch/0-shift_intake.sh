#!/bin/bash
set -e

# Exit non-zero on failure with clear error indication
handle_error() {
    echo "[intake error] Check failed at line $1" >&2
    exit 1
}
trap 'handle_error $LINENO' ERR

# Helper function to check and output binary versions
check_bin() {
    local bin="$1"
    local cmd_name="$bin"
    [ "$bin" = "sigma-cli" ] && cmd_name="sigma"

    if ! command -v "$cmd_name" &>/dev/null; then
        echo "[intake] Missing required binary: $bin" >&2
        exit 1
    fi
    local ver=""
    case "$bin" in
        jq) ver=$(jq --version 2>&1 | head -n1) ;;
        python3) ver=$(python3 --version 2>&1 | awk '{print $2}') ;;
        yq) ver=$(yq --version 2>&1 | awk '{print $NF}') ;;
        sigma-cli) ver=$(sigma version 2>&1 | tr -d '\r') ;;
        sha256sum) ver="present" ;;
    esac
    echo "[intake] $bin $ver OK"
}

# 1. Verify presence of required binaries on PATH
check_bin jq
check_bin python3
check_bin yq
check_bin sigma-cli
check_bin sha256sum

# 2. Verify prior-project binaries or directories
if [ ! -x "$PIPELINE_BIN" ]; then
    echo "[intake] PIPELINE_BIN not executable or missing: $PIPELINE_BIN" >&2
    exit 1
fi
echo "[intake] PIPELINE_BIN OK"

if [ ! -x "$BASELINE_BIN" ]; then
    echo "[intake] BASELINE_BIN not executable or missing: $BASELINE_BIN" >&2
    exit 1
fi
echo "[intake] BASELINE_BIN OK"

if [ ! -d "$CATALOG_DIR" ]; then
    echo "[intake] CATALOG_DIR not a readable directory: $CATALOG_DIR" >&2
    exit 1
fi
yml_count=$(find "$CATALOG_DIR" -maxdepth 1 -name "*.yml" | wc -l)
if [ "$yml_count" -eq 0 ]; then
    echo "[intake] CATALOG_DIR contains no .yml files: $CATALOG_DIR" >&2
    exit 1
fi
echo "[intake] CATALOG_DIR OK ($yml_count rules)"

if [ ! -x "$TRIAGE_BIN" ]; then
    echo "[intake] TRIAGE_BIN not executable or missing: $TRIAGE_BIN" >&2
    exit 1
fi
echo "[intake] TRIAGE_BIN OK"

# 3. Verify CAPSTONE_PACK directory
if [ ! -d "$CAPSTONE_PACK" ]; then
    echo "[intake] CAPSTONE_PACK not a directory: $CAPSTONE_PACK" >&2
    exit 1
fi
echo "[intake] CAPSTONE_PACK OK"

# 4. Verify ASSETS_DIR and required context files
assets=("assets.json" "ioc_feed.json" "hc_red7_advisory.md" "change_tickets.json" "prior_shift_notes.md")
for f in "${assets[@]}"; do
    if [ ! -f "$ASSETS_DIR/$f" ]; then
        echo "[intake] Missing required asset file: $f" >&2
        exit 1
    fi
done
echo "[intake] ASSETS_DIR: 5 meta files OK"

# 5. Verify WAZUH_EXPORTS and required search result files
wazuh_files=("incident_A_search_results.json" "incident_B_search_results.json" "incident_C_search_results.json" "campaign_dashboard_summary.md")
for f in "${wazuh_files[@]}"; do
    if [ ! -f "$WAZUH_EXPORTS/$f" ]; then
        echo "[intake] Missing required wazuh export file: $f" >&2
        exit 1
    fi
done
echo "[intake] WAZUH_EXPORTS: 4 export files OK"

# 6. Extract IOC Count and Advisory Cluster ID
ioc_count=$(jq '.iocs | length' "$ASSETS_DIR/ioc_feed.json")
echo "[intake] ioc_feed.json OK ($ioc_count entries)"

cluster_id=$(grep -o "HC-RED7" "$ASSETS_DIR/hc_red7_advisory.md" | head -n 1)
if [ -z "$cluster_id" ]; then
    cluster_id="HC-RED7"
fi
echo "[intake] advisory $cluster_id loaded"

# 7. Create Shift Workspace Layout & Stub Files
mkdir -p "$SHIFT_WORKSPACE"/{runtime,enriched,alerts,investigations,campaign,reports,response,handoff}

touch "$SHIFT_WORKSPACE/MANIFEST.json"
touch "$SHIFT_WORKSPACE/runtime/shift_start.json" \
      "$SHIFT_WORKSPACE/runtime/pipeline_run.json" \
      "$SHIFT_WORKSPACE/runtime/baseline_run.json" \
      "$SHIFT_WORKSPACE/runtime/catalog_run.json"
touch "$SHIFT_WORKSPACE/enriched/enriched_events.jsonl" \
      "$SHIFT_WORKSPACE/enriched/timeline.jsonl" \
      "$SHIFT_WORKSPACE/enriched/baseline.json" \
      "$SHIFT_WORKSPACE/enriched/source_stats.json"
touch "$SHIFT_WORKSPACE/alerts/alert_queue.json" \
      "$SHIFT_WORKSPACE/alerts/shift_briefing.json" \
      "$SHIFT_WORKSPACE/alerts/triage_log.jsonl" \
      "$SHIFT_WORKSPACE/alerts/incidents.json"
touch "$SHIFT_WORKSPACE/investigations/incident_A.json" \
      "$SHIFT_WORKSPACE/investigations/incident_B.json" \
      "$SHIFT_WORKSPACE/investigations/incident_C_cli.json" \
      "$SHIFT_WORKSPACE/investigations/incident_C_export.json"
touch "$SHIFT_WORKSPACE/campaign/campaign_assessment.json"
touch "$SHIFT_WORKSPACE/reports/incident_A.md" \
      "$SHIFT_WORKSPACE/reports/incident_B.md" \
      "$SHIFT_WORKSPACE/reports/incident_C.md"
touch "$SHIFT_WORKSPACE/response/tuning_recommendations.json" \
      "$SHIFT_WORKSPACE/response/containment.json" \
      "$SHIFT_WORKSPACE/response/ioc_package.json"
touch "$SHIFT_WORKSPACE/handoff/shift_handoff.md"

echo "[intake] workspace layout created at \$SHIFT_WORKSPACE"

# 8. Write shift_start.json
shift_id="SHIFT-$(date -u +%Y%m%d-%H%M)"
analyst_host=$(hostname)
started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq_ver=$(jq --version 2>&1 | head -n1)
py_ver=$(python3 --version 2>&1 | awk '{print $2}')
yq_ver=$(yq --version 2>&1 | awk '{print $NF}')
sigma_ver=$(sigma version 2>&1 | tr -d '\r')

cat <<EOF > "$SHIFT_WORKSPACE/runtime/shift_start.json"
{
  "shift_id": "$shift_id",
  "analyst_host": "$analyst_host",
  "started_at": "$started_at",
  "tools": {
    "jq": "$jq_ver",
    "python3": "$py_ver",
    "yq": "$yq_ver",
    "sigma-cli": "$sigma_ver",
    "sha256sum": "present"
  },
  "prior_project_bins": {
    "pipeline": true,
    "baseline": true,
    "catalog": true,
    "triage": true
  },
  "capstone_pack": "$(realpath "$CAPSTONE_PACK")",
  "ioc_feed_count": $ioc_count,
  "advisory_cluster_id": "$cluster_id",
  "wazuh_exports_verified": true
}
EOF

echo "[intake] shift_start.json written"
