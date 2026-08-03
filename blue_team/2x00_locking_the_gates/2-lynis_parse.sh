#!/bin/bash
# Ensure script is idempotent and handles errors
set -e

# Check if report file argument is provided
REPORT_FILE="${1:-/var/log/lynis-report.dat}"

if [ ! -f "$REPORT_FILE" ]; then
    echo "Error: Report file '$REPORT_FILE' not found!" >&2
    exit 1
fi

# Extract hardening index (default to 0 if not found)
HARDENING_INDEX=$(grep '^hardening_index=' "$REPORT_FILE" | cut -d'=' -f2)
HARDENING_INDEX=${HARDENING_INDEX:-0}

# Temporary file to store findings in JSON lines or raw format for jq processing
FINDINGS_JSON=$(mktemp)

# Parse warnings, suggestions, and manual_checks from lynis-report.dat
# Format in dat: type[]=TEST-ID|Message description
while IFS== read -r key value; do
    case "$key" in
        warning[]|suggestion[]|manual_check[])
            # Extract severity type (warning, suggestion, manual_check)
            severity=$(echo "$key" | sed 's/\[\]//')
            
            # Split test_id and message separated by '|'
            test_id=$(echo "$value" | cut -d'|' -f1)
            message=$(echo "$value" | cut -d'|' -f2-)
            
            # Escape double quotes for valid JSON generation
            message=$(echo "$message" | sed 's/"/\\"/g')
            
            # Append as JSON object structure
            echo "{\"severity\": \"$severity\", \"test_id\": \"$test_id\", \"message\": \"$message\"}" >> "$FINDINGS_JSON"
            ;;
    esac
done < "$REPORT_FILE"

# If no findings were captured, ensure valid empty array structure
if [ ! -s "$FINDINGS_JSON" ]; then
    echo "[]" > "$FINDINGS_JSON.array"
else
    # Combine lines into a proper JSON array
    jq -s '.' "$FINDINGS_JSON" > "$FINDINGS_JSON.array"
fi

# Construct the final JSON output containing hardening_index and findings list using jq
jq -n \
    --argjson index "$HARDENING_INDEX" \
    --slurpfile findings "$FINDINGS_JSON.array" \
    '{hardening_index: $index, findings: $findings[0]}'

# Cleanup temporary files
rm -f "$FINDINGS_JSON" "$FINDINGS_JSON.array"
