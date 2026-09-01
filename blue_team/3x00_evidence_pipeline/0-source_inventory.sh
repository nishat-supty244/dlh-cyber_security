#!/bin/bash
set -euo pipefail

EVIDENCE_DIR="${1:-$HOME/evidence_pack_primary}"
MANIFEST_FILE="source_inventory.json"

if [ ! -d "$EVIDENCE_DIR" ]; then
    echo "Error: Evidence directory $EVIDENCE_DIR does not exist." >&2
    exit 1
fi

TEMP_JSON=$(mktemp)
echo "[]" > "$TEMP_JSON"

total_files=0
total_bytes=0
declare -A category_counts
declare -A category_bytes

for category in windows linux network; do
    cat_dir="$EVIDENCE_DIR/$category"
    if [ ! -d "$cat_dir" ]; then
        continue
    fi

    cat_files=0
    cat_b_count=0

    # Loop through files in the category directory safely
    for filepath in "$cat_dir"/*; do
        [ -f "$filepath" ] || continue
        
        rel_path="${filepath#$EVIDENCE_DIR/}"
        
        case "$rel_path" in
            windows/*.json) source_type="windows_json" ;;
            linux/*) source_type="linux_text" ;;
            network/*.csv) source_type="network_csv" ;;
            network/*.json) source_type="network_json" ;;
            *) source_type="unknown" ;;
        esac

        size_bytes=$(stat -c%s "$filepath")
        sha256=$(sha256sum "$filepath" | awk '{print $1}')
        line_count=$(wc -l < "$filepath")

        timestamps=$(python3 -c '
import sys, re, json
path = sys.argv[1]
stype = sys.argv[2]
first_t = None
last_t = None
iso_regex = re.compile(r"\b\d{4}-\d{2}-\d{2}[T ]\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:?\d{2})?\b")
try:
    with open(path, "r", errors="ignore") as f:
        for line in f:
            match = iso_regex.search(line)
            if match:
                t_str = match.group(0).strip()
                if not first_t:
                    first_t = t_str
                last_t = t_str
            if stype in ["windows_json", "network_json"]:
                try:
                    data = json.loads(line)
                    for k in ["timestamp", "@timestamp", "TimeCreated", "time", "datetime"]:
                        if k in data and isinstance(data[k], str):
                            if not first_t:
                                first_t = data[k]
                            last_t = data[k]
                except:
                    pass
except Exception:
    pass
print(json.dumps({"first": first_t, "last": last_t}))
' "$filepath" "$source_type")

        first_event_time=$(echo "$timestamps" | jq -r '.first')
        last_event_time=$(echo "$timestamps" | jq -r '.last')
        
        [ "$first_event_time" = "null" ] && first_event_time=""
        [ "$last_event_time" = "null" ] && last_event_time=""

        jq --arg path "$rel_path" \
           --arg st "$source_type" \
           --argjson size "$size_bytes" \
           --arg sha "$sha256" \
           --argjson lines "$line_count" \
           --arg first "$first_event_time" \
           --arg last "$last_event_time" \
           '. += [{
               "path": $path,
               "source_type": $st,
               "size_bytes": $size,
               "sha256": $sha,
               "line_count": $lines,
               "first_event_time": $first,
               "last_event_time": $last
           }]' "$TEMP_JSON" > "${TEMP_JSON}.tmp" && mv "${TEMP_JSON}.tmp" "$TEMP_JSON"

        cat_files=$((cat_files + 1))
        cat_b_count=$((cat_b_count + size_bytes))
        total_files=$((total_files + 1))
        total_bytes=$((total_bytes + size_bytes))
    done

    category_counts[$category]=$cat_files
    category_bytes[$category]=$cat_b_count
done

mv "$TEMP_JSON" "$MANIFEST_FILE"

for cat in windows linux network; do
    count=${category_counts[$cat]:-0}
    bytes=${category_bytes[$cat]:-0}
    mb=$(awk "BEGIN {printf \"%.1f\", $bytes / 1024 / 1024}")
    printf "%-8s : %d files  |  %4.1f MB\n" "$cat" "$count" "$mb"
done

total_mb=$(awk "BEGIN {printf \"%.1f\", $total_bytes / 1024 / 1024}")
printf "total    : %d files  |  %4.1f MB\n" "$total_files" "$total_mb"
echo "manifest written to $MANIFEST_FILE"
