#!/bin/bash
# Path: dlh-cyber_security/blue_team/2x05_defensible_endpoint/1-baseline_snapshot.sh

mkdir -p capstone/baseline
LOG_PATH="capstone/baseline/lynis_baseline.log"
JSON_PATH="capstone/baseline/baseline_linux.json"

# Run Lynis audit securely and capture output
echo "Running Lynis audit on $(hostname)..."
lynis audit system --quick --no-colors > "$LOG_PATH"

# Extract metrics
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
LYNIS_VERSION=$(lynis show version 2>/dev/null || echo "unknown")

# Parse log data, utilizing awk for robust extraction across Lynis versions
HARDENING_INDEX=$(awk -F '[:[]' '/Hardening index/ {gsub(/[^0-9]/, "", $2); print $2; exit}' "$LOG_PATH")
WARNINGS_COUNT=$(awk -F ':' '/Warnings \(found\)/ {gsub(/[^0-9]/, "", $2); print $2; exit}' "$LOG_PATH")
SUGGESTIONS_COUNT=$(awk -F ':' '/Suggestions \(found\)/ {gsub(/[^0-9]/, "", $2); print $2; exit}' "$LOG_PATH")

# Generate JSON payload (cat is used over jq to remove external dependencies)
cat <<EOF > "$JSON_PATH"
{
  "timestamp": "$TIMESTAMP",
  "hostname": "$HOSTNAME",
  "lynis_version": "$LYNIS_VERSION",
  "hardening_index": ${HARDENING_INDEX:-0},
  "warnings_count": ${WARNINGS_COUNT:-0},
  "suggestions_count": ${SUGGESTIONS_COUNT:-0},
  "log_path": "$LOG_PATH"
}
EOF

echo "Linux baseline snapshot finalized: $JSON_PATH"
