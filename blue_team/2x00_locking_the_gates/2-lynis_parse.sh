#!/bin/bash
# Defensive bash practices
set -euo pipefail

# Ensure a report file argument is provided, defaulting to /var/log/lynis-report.dat if omitted
REPORT_FILE="${1:-/var/log/lynis-report.dat}"

if [ ! -f "$REPORT_FILE" ]; then
    echo "Error: Lynis report file '$REPORT_FILE' not found." >&2
    exit 1
fi

# Extract hardening index, defaulting to 0 if not present
HARDENING_INDEX=$(grep '^hardening_index=' "$REPORT_FILE" | cut -d'=' -f2)
HARDENING_INDEX=${HARDENING_INDEX:-0}

# Parse findings using awk and construct a JSON array via jq
awk -F'|' '
BEGIN { print "[" }
/^warning\[\]=|^suggestion\[\]=|^manual_check\[\]=/ {
    split($0, a, "=")
    type = a[1]
    sub(/\[\]$/, "", type)
    
    test_id = $1
    sub(/^.*=/, "", test_id)
    
    # Reconstruct message if it contains pipes
    msg = ""
    for (i = 2; i <= NF; i++) {
        msg = (i == 2) ? $i : msg "|" $i
    }
    
    # Escape quotes for JSON validity
    gsub(/"/, "\\\"", msg)
    
    if (count > 0) print ","
    printf "  {\"severity\": \"%s\", \"test_id\": \"%s\", \"message\": \"%s\"}", type, test_id, msg
    count++
}
END { print "\n]" }
' "$REPORT_FILE" > /tmp/lynis_findings_raw.json

# Combine hardening index and findings into the final JSON output using jq
jq -n \
    --argjson index "$HARDENING_INDEX" \
    --slurpfile findings /tmp/lynis_findings_raw.json \
    '{hardening_index: $index, findings: $findings[0]}'

# Clean up temp file
rm -f /tmp/lynis_findings_raw.json
