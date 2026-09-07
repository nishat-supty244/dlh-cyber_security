#!/bin/bash

HANDOFF_DIR="${HANDOFF_DIR:-$HOME/3x00_handoff/evidence_handoff}"
DATA_FILE="$HANDOFF_DIR/data/enriched_events.json"

if [[ ! -f "$DATA_FILE" ]]; then
    echo "Error: Data file not found at $DATA_FILE" >&2
    exit 1
fi

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

verb="${1:-help}"
shift || true

source_val=""
host_val=""
from_val=""
to_val=""
category_val=""
field_val=""
limit_val="10"
bucket_val="day"

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --source)
            source_val="$2"
            shift 2
            ;;
        --host)
            host_val="$2"
            shift 2
            ;;
        --from)
            from_val="$2"
            shift 2
            ;;
        --to)
            to_val="$2"
            shift 2
            ;;
        --category)
            category_val="$2"
            shift 2
            ;;
        --field)
            field_val="$2"
            shift 2
            ;;
        --limit)
            limit_val="$2"
            shift 2
            ;;
        --bucket)
            bucket_val="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

jq_cond="true"

if [[ -n "$source_val" ]]; then
    jq_cond="$jq_cond and (.source == \$src or .source_type == \$src)"
fi
if [[ -n "$host_val" ]]; then
    jq_cond="$jq_cond and (.host == \$h or .hostname == \$h or .source_host == \$h)"
fi
if [[ -n "$category_val" ]]; then
    jq_cond="$jq_cond and (.category == \$cat or .event_category == \$cat)"
fi
if [[ -n "$from_val" ]]; then
    jq_cond="$jq_cond and (.timestamp >= \$from or .time >= \$from)"
fi
if [[ -n "$to_val" ]]; then
    jq_cond="$jq_cond and (.timestamp <= \$to or .time <= \$to)"
fi

jq_args=()
if [[ -n "$source_val" ]]; then
    jq_args+=(--arg src "$source_val")
fi
if [[ -n "$host_val" ]]; then
    jq_args+=(--arg h "$host_val")
fi
if [[ -n "$category_val" ]]; then
    jq_args+=(--arg cat "$category_val")
fi
if [[ -n "$from_val" ]]; then
    jq_args+=(--arg from "$from_val")
fi
if [[ -n "$to_val" ]]; then
    jq_args+=(--arg to "$to_val")
fi

case "$verb" in
    help)
        usage
        ;;
    filter)
        jq -c "${jq_args[@]}" 'if type=="array" then .[] else . end | select('"$jq_cond"')' "$DATA_FILE"
        ;;
    top)
        if [[ -z "$field_val" ]]; then
            echo "Error: --field is required for top command" >&2
            exit 1
        fi
        jq -r "${jq_args[@]}" --arg field "$field_val" --argjson limit "$limit_val" \
            '[if type=="array" then .[] else . end | select('"$jq_cond"') | .[$field] // "N/A" | tostring] | group_by(.) | map({value:.[0], count: length}) | sort_by(.count) | reverse | .[0:$limit] | .[] | "\(.value)\t\(.count)"' \
            "$DATA_FILE"
        ;;
    distinct)
        if [[ -z "$field_val" ]]; then
            echo "Error: --field is required for distinct command" >&2
            exit 1
        fi
        jq -r "${jq_args[@]}" --arg field "$field_val" \
            'if type=="array" then .[] else . end | select('"$jq_cond"') | .[$field] // empty' \
            "$DATA_FILE" | sort -u
        ;;
    count)
        jq "${jq_args[@]}" \
            '[if type=="array" then .[] else . end | select('"$jq_cond"')] | length' \
            "$DATA_FILE"
        ;;
    window)
        time_field="${field_val:-timestamp}"
        jq -r "${jq_args[@]}" --arg field "$time_field" --arg bucket "$bucket_val" \
            '[if type=="array" then .[] else . end | select('"$jq_cond"') | .[$field] // empty | tostring | if $bucket == "day" then .[0:10] else .[0:13] end] | group_by(.) | map({bucket:.[0], count: length}) | sort_by(.bucket) | .[] | "\(.bucket)\t\(.count)"' \
            "$DATA_FILE"
        ;;
    *)
        echo "Unknown verb: $verb" >&2
        usage
        exit 1
        ;;
esac
