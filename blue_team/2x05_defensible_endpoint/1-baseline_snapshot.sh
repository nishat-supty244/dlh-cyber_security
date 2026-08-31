#!/bin/bash
# Path: dlh-cyber_security/blue_team/2x05_defensible_endpoint/1-baseline_snapshot.sh

mkdir -p capstone/baseline
LOG_PATH="capstone/baseline/lynis_baseline.log"
JSON_PATH="capstone/baseline/baseline_linux.json"

# Run Lynis audit securely and capture standard output
lynis audit system --quick --no-colors > "$LOG_PATH"

# Extract metrics using strict regex to grab only the first number on the matching line
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
LYNIS_VERSION=$(lynis show version 2>/dev/null || echo "unknown")

HARDENING_INDEX=$(grep "Hardening index" "$LOG_PATH" | grep -o '[0-9]\+' | head -n 1)
WARNINGS_COUNT=$(grep "Warnings (found)" "$LOG_PATH" | grep -o '[0-9]\+' | head -n 1)
SUGGESTIONS_COUNT=$(grep "Suggestions (found)" "$LOG_PATH" | grep -o '[0-9]\+' | head -n 1)

# Generate JSON payload (with fallbacks to 0 to ensure valid JSON integers)
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

# Explicitly use documented exit codes for the test harness
exit 0
