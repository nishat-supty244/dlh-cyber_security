#!/bin/bash
set -euo pipefail

# Environment variables with default fallback paths
HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
BASELINE_PKG="${BASELINE_PKG:-$HOME/3x01_package/baseline_package}"
CATALOG_DIR="${CATALOG_DIR:-$HOME/3x02_package/detection_catalog}"
TRIAGE_PKG="${TRIAGE_PKG:-$HOME/3x03_package/triage_package}"
ASSETS_DIR="${ASSETS_DIR:-$HOME/3x04_assets}"
WAZUH_EXPORTS="${WAZUH_EXPORTS:-$ASSETS_DIR/wazuh_exports}"

# Ensure common binary paths are included (e.g., /usr/local/bin)
export PATH="/usr/local/bin:$PATH"

# Helper function to extract tool versions cleanly
get_version() {
    local cmd="$1"
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd not found on PATH" >&2
        exit 1
    fi
    case "$cmd" in
        jq)
            jq --version | sed 's/jq-//'
            ;;
        yq)
            yq --version | awk '{print $NF}'
            ;;
        python3)
            python3 --version | awk '{print $2}'
            ;;
        sigma)
            sigma version 2>&1 | awk '{print $NF}'
            ;;
        xmllint)
            xmllint --version 2>&1 | grep -oE '[0-9]+' | head -n 1
            ;;
        curl)
            curl --version | head -n 1 | awk '{print $2}'
            ;;
    esac
}

# 1. Verify required CLI tools
JQ_VER=$(get_version jq)
YQ_VER=$(get_version yq)
PY_VER=$(get_version python3)
SIGMA_VER=$(get_version sigma)
XML_VER=$(get_version xmllint)
CURL_VER=$(get_version curl)

printf "jq          : %s\n" "$JQ_VER"
printf "yq          : %s\n" "$YQ_VER"
printf "python3     : %s\n" "$PY_VER"
printf "sigma-cli   : %s\n" "$SIGMA_VER"
printf "xmllint     : %s\n" "$XML_VER"
printf "curl        : %s\n" "$CURL_VER"

# 2. Verify upstream directories exist
for dir_var in HANDOFF_DIR BASELINE_PKG CATALOG_DIR TRIAGE_PKG ASSETS_DIR; do
    eval val=\$$dir_var
    if [ ! -d "$val" ]; then
        echo "Error: Directory $val ($dir_var) does not exist." >&2
        exit 1
    fi
done

# 3. Confirm enriched events exist and are non-empty
ENRICHED_JSON="$HANDOFF_DIR/data/enriched_events.json"
if [ ! -s "$ENRICHED_JSON" ]; then
    echo "Error: $ENRICHED_JSON missing or empty." >&2
    exit 1
fi
echo "handoff     : ok (enriched_events.json present)"

# 4. Confirm Sigma rules directory and count rules
SIGMA_RULES_DIR="$CATALOG_DIR/rules/sigma"
if [ ! -d "$SIGMA_RULES_DIR" ]; then
    echo "Error: Sigma rules directory $SIGMA_RULES_DIR does not exist." >&2
    exit 1
fi
RULE_COUNT=$(find "$SIGMA_RULES_DIR" -name "*.yml" -o -name "*.yaml" | wc -l)
echo "catalog     : ok ($RULE_COUNT sigma rules)"

# 5. Verify Wazuh export artifacts are present
REQUIRED_FILES=(
    "field_mapping.json"
    "index_metadata.json"
    "anchor_search_results.json"
    "scenario_a_search_results.json"
    "scenario_b_search_results.json"
    "scenario_c_search_results.json"
    "anchor_dashboard_trace.json"
    "scenario_a_dashboard_trace.json"
    "scenario_b_dashboard_trace.json"
    "scenario_c_dashboard_trace.json"
)

for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$WAZUH_EXPORTS/$f" ]; then
        echo "Error: Missing required Wazuh export file: $f" >&2
        exit 1
    fi
done
echo "wazuh_exports : ok (field_mapping, index_metadata, 4 search_results, 4 dashboard_traces)"

# 6. Verify anchor event matching in enriched events
ANCHOR_JSON="$ASSETS_DIR/anchor_event.json"
if [ ! -f "$ANCHOR_JSON" ]; then
    echo "Error: $ANCHOR_JSON missing." >&2
    exit 1
fi

TARGET_HOST=$(jq -r '.target_host // .host // .computer // "db-patient-01"' "$ANCHOR_JSON")
MATCH_COUNT=$(jq --arg host "$TARGET_HOST" '[.[] | select(.host == $host or .computer == $host or .target_host == $host)] | length' "$ENRICHED_JSON")

if [ "$MATCH_COUNT" -gt 0 ]; then
    echo "anchor      : ok ($TARGET_HOST matched in enriched_events.json)"
else
    echo "Error: Anchor target host '$TARGET_HOST' not found in $ENRICHED_JSON" >&2
    exit 1
fi

echo "all checks  : passed"
