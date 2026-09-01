# Task 0 — Evidence Pack Inventory

## Script: `0-source_inventory.sh`

```bash
#!/usr/bin/env bash

set -euo pipefail

EVIDENCE_ROOT="$HOME/evidence_pack_primary"
OUTPUT_FILE="source_inventory.json"

# Check that the evidence pack exists
if [[ ! -d "$EVIDENCE_ROOT" ]]; then
    echo "ERROR: Evidence pack not found: $EVIDENCE_ROOT" >&2
    exit 1
fi

# Temporary file for JSON records
TMP_FILE=$(mktemp)

# Cleanup temporary file on exit
trap 'rm -f "$TMP_FILE"' EXIT

# Start JSON array
echo "[" > "$TMP_FILE"

first_record=true

# Process files under the three required directories
while IFS= read -r -d '' file; do

    relative_path="${file#$EVIDENCE_ROOT/}"
    category="${relative_path%%/*}"
    filename="${relative_path##*/}"

    # Determine source type from directory and extension
    case "$category" in
        windows)
            source_type="windows_json"
            ;;
        linux)
            source_type="linux_text"
            ;;
        network)
            case "${filename##*.}" in
                csv|CSV)
                    source_type="network_csv"
                    ;;
                json|JSON)
                    source_type="network_json"
                    ;;
                *)
                    continue
                    ;;
            esac
            ;;
        *)
            continue
            ;;
    esac

    # File size
    size_bytes=$(stat -c '%s' "$file")

    # SHA-256
    sha256=$(sha256sum "$file" | awk '{print $1}')

    # Extract record/line count and event timestamps
    first_event_time=""
    last_event_time=""

    if [[ "$source_type" == "windows_json" || "$source_type" == "network_json" ]]; then

        record_count=$(wc -l < "$file" | tr -d ' ')

        # Best-effort timestamp extraction from common JSON timestamp fields
        mapfile -t timestamps < <(
            grep -Eo '"(timestamp|time|event_time|TimeCreated|@timestamp)"[[:space:]]*:[[:space:]]*"[^"]+"' "$file" 2>/dev/null |
            sed -E 's/.*:[[:space:]]*"([^"]+)".*/\1/' |
            sort
        )

        if [[ ${#timestamps[@]} -gt 0 ]]; then
            first_event_time="${timestamps[0]}"
            last_event_time="${timestamps[${#timestamps[@]}-1]}"
        fi

    else
        line_count=$(wc -l < "$file" | tr -d ' ')

        # Best-effort extraction of timestamps from common text log formats
        mapfile -t timestamps < <(
            grep -Eo \
                '([0-9]{4}-[0-9]{2}-[0-9]{2}[T ][0-9]{2}:[0-9]{2}:[0-9]{2}([.,][0-9]+)?([+-][0-9]{2}:[0-9]{2}|Z)?)' \
                "$file" 2>/dev/null |
            sort
        )

        if [[ ${#timestamps[@]} -gt 0 ]]; then
            first_event_time="${timestamps[0]}"
            last_event_time="${timestamps[${#timestamps[@]}-1]}"
        fi
    fi

    # Write comma between JSON records
    if [[ "$first_record" == false ]]; then
        echo "," >> "$TMP_FILE"
    fi

    first_record=false

    cat >> "$TMP_FILE" <<EOF
  {
    "path": "$relative_path",
    "source_type": "$source_type",
    "size_bytes": $size_bytes,
    "sha256": "$sha256",
    "line_count": ${line_count:-null},
    "record_count": ${record_count:-null},
    "first_event_time": ${first_event_time:+\"$first_event_time\"},
    "last_event_time": ${last_event_time:+\"$last_event_time\"}
  }
EOF

done < <(
    find "$EVIDENCE_ROOT/windows" \
         "$EVIDENCE_ROOT/linux" \
         "$EVIDENCE_ROOT/network" \
         -type f -print0 2>/dev/null
)

# Finish JSON
echo "]" >> "$TMP_FILE"

# Validate and write final JSON
if command -v jq >/dev/null 2>&1; then
    jq '.' "$TMP_FILE" > "$OUTPUT_FILE"
else
    cp "$TMP_FILE" "$OUTPUT_FILE"
fi

# Calculate human-readable summary
windows_count=$(find "$EVIDENCE_ROOT/windows" -type f 2>/dev/null | wc -l | tr -d ' ')
linux_count=$(find "$EVIDENCE_ROOT/linux" -type f 2>/dev/null | wc -l | tr -d ' ')
network_count=$(find "$EVIDENCE_ROOT/network" -type f 2>/dev/null | wc -l | tr -d ' ')

windows_bytes=$(find "$EVIDENCE_ROOT/windows" -type f -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum+0}')
linux_bytes=$(find "$EVIDENCE_ROOT/linux" -type f -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum+0}')
network_bytes=$(find "$EVIDENCE_ROOT/network" -type f -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum+0}')

total_count=$((windows_count + linux_count + network_count))
total_bytes=$((windows_bytes + linux_bytes + network_bytes))

# Convert bytes to MB
format_mb() {
    awk -v bytes="$1" 'BEGIN { printf "%.1f MB", bytes / 1024 / 1024 }'
}

echo "windows : $windows_count files  |  $(format_mb "$windows_bytes")"
echo "linux   : $linux_count files  |  $(format_mb "$linux_bytes")"
echo "network : $network_count files  |  $(format_mb "$network_bytes")"
echo "total   : $total_count files  |  $(format_mb "$total_bytes")"
echo "manifest written to $OUTPUT_FILE"
