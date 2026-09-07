#!/bin/bash
# Reusable Query Toolkit for 3x01
# Must pass shellcheck and run on Ubuntu 22.04 LTS

set -euo pipefail

# Handle HANDOFF_DIR default
HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
DATA_FILE="$HANDOFF_DIR/data/enriched_events.json"

usage() {
    cat <<EOF
query_toolkit.sh <verb> [options]
  filter   emit matching records as ndjson
  top      top N values of a field
  distinct distinct values of a field
  count    number of matching records
  window   bucketed counts by time window
  help     this message
EOF
}

if [ $# -eq 0 ] || [ "$1" = "help" ]; then
    usage
    exit 0
fi

VERB="$1"
shift

# Check if data file exists
if [ ! -f "$DATA_FILE" ]; then
    echo "Error: Data file not found at $DATA_FILE" >&2
    exit 1
fi

# Parse common options for filtering
# Supported flags: --source, --host, --from, --to, --category
SOURCE=""
HOST=""
FROM=""
TO=""
CATEGORY=""

# Field/Limit specific options
FIELD=""
LIMIT=10
BUCKET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)
            SOURCE="$2"
            shift 2
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        --from)
            FROM="$2"
            shift 2
            ;;
        --to)
            TO="$2"
            shift 2
            ;;
        --category)
            CATEGORY="$2"
            shift 2
            ;;
        --field)
            FIELD="$2"
            shift 2
            ;;
        --limit)
            LIMIT="$2"
            shift 2
            ;;
        --bucket)
            BUCKET="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            usage
            exit 1
            ;;
    esac
done

# Build jq filter string dynamically based on provided options
# Assuming typical fields like .source, .host (or source/destination host fields), .timestamp, .category
# Adjust field names based on your event_schema.json if necessary.
JQ_FILTER="select(true"

if [ -n "$SOURCE" ]; then
    JQ_FILTER="$JQ_FILTER and (.source == \$source or .source_type == \$source)"
fi
if [ -n "$HOST" ]; then
    JQ_FILTER="$JQ_FILTER and (.host == \$host or .destination_host == \$host or .source_host == \$host)"
fi
if [ -n "$FROM" ]; then
    JQ_FILTER="$JQ_FILTER and (.timestamp >= \$from)"
fi
if [ -n "$TO" ]; then
    JQ_FILTER="$JQ_FILTER and (.timestamp <= \$to)"
fi
if [ -n "$CATEGORY" ]; then
    JQ_FILTER="$JQ_FILTER and (.category == \$category or .event_category == \$category)"
fi

JQ_FILTER="$JQ_FILTER)"

# Execute based on verb
case "$VERB" in
    filter)
        jq --arg source "$SOURCE" --arg host "$HOST" --arg from "$FROM" --arg to "$TO" --arg category "$CATEGORY" \
           -c "$JQ_FILTER" "$DATA_FILE"
        ;;
    count)
        jq --arg source "$SOURCE" --arg host "$HOST" --arg from "$FROM" --arg to "$TO" --arg category "$CATEGORY" \
           -s "[ .[] | $JQ_FILTER ] | length" "$DATA_FILE"
        ;;
    distinct)
        if [ -z "$FIELD" ]; then
            echo "Error: --field is required for 'distinct'" >&2
            exit 1
        fi
        jq --arg source "$SOURCE" --arg host "$HOST" --arg from "$FROM" --arg to "$TO" --arg category "$CATEGORY" \
           -r "[ .[] | $JQ_FILTER | .[$FIELD] ] | unique | .[]" "$DATA_FILE"
        ;;
    top)
        if [ -z "$FIELD" ]; then
            echo "Error: --field is required for 'top'" >&2
            exit 1
        fi
        jq --arg source "$SOURCE" --arg host "$HOST" --arg from "$FROM" --arg to "$TO" --arg category "$CATEGORY" \
           --argjson limit "$LIMIT" \
           '[ .[] | $JQ_FILTER | .[$FIELD] ] | map(select(. != null)) | group_by(.) | map({val: .[0], count: length}) | sort_by(.count) | reverse | .[0:$limit] | .[] | "\(.val)\t\(.count)"' \
           "$DATA_FILE" -r
        ;;
    window)
        if [ -z "$FIELD" ] || [ -z "$BUCKET" ]; then
            echo "Error: --field and --bucket are required for 'window'" >&2
            exit 1
        fi
        # Bucket by hour (YYYY-MM-DDTHH) or day (YYYY-MM-DD)
        SUB_LEN=$([ "$BUCKET" = "hour" ] && echo 13 || echo 10)
        jq --arg source "$SOURCE" --arg host "$HOST" --arg from "$FROM" --arg to "$TO" --arg category "$CATEGORY" \
           --argjson slen "$SUB_LEN" \
           '[ .[] | $JQ_FILTER | {bucket: (.timestamp[0:$slen]), val: .[$FIELD]} ] | group_by(.bucket) | map({bucket: .[0].bucket, count: length}) | .[] | "\(.bucket)\t\(.count)"' \
           "$DATA_FILE" -r
        ;;
    *)
        echo "Unknown verb: $VERB" >&2
        usage
        exit 1
        ;;
esac
