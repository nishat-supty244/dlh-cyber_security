
#!/bin/bash
# shellcheck shell=bash
set -euo pipefail

: "${HANDOFF_DIR:=$HOME/3x00_handoff/evidence_handoff}"
export HANDOFF_DIR

RULE_FILE=""
EVIDENCE_FILE="$HANDOFF_DIR/data/normalized_events.json"
DRY_RUN=false
COUNT_ONLY=false
WINDOW=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --count-only)
            COUNT_ONLY=true
            shift
            ;;
        --window)
            WINDOW="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [ -z "$RULE_FILE" ]; then
                RULE_FILE="$1"
            elif [ "$EVIDENCE_FILE" = "$HANDOFF_DIR/data/normalized_events.json" ]; then
                EVIDENCE_FILE="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$RULE_FILE" ]; then
    echo "Usage: $0 <sigma_rule.yml> [evidence_file.json] [--dry-run] [--count-only] [--window start,end]" >&2
    exit 1
fi

python3 - << 'PY_EOF' "$RULE_FILE" "$EVIDENCE_FILE" "$DRY_RUN" "$COUNT_ONLY" "$WINDOW"
import sys
import json
import time
import yaml
from datetime import datetime

rule_file = sys.argv[1]
evidence_file = sys.argv[2]
dry_run = sys.argv[3] == 'true'
count_only = sys.argv[4] == 'true'
window_arg = sys.argv[5]

# Dry-run validation
try:
    with open(rule_file, 'r') as f:
        rule = yaml.safe_load(f)
    if not isinstance(rule, dict) or 'title' not in rule or 'detection' not in rule:
        raise ValueError("Invalid Sigma rule structure: missing title or detection block.")
except Exception as e:
    if dry_run:
        print(f"ERROR: {e}")
        sys.exit(1)
    else:
        print(f"Error parsing rule file: {e}", file=sys.stderr)
        sys.exit(1)

if dry_run:
    print("VALID")
    sys.exit(0)

start_time = time.time()

events = []
try:
    if os_path_exists := evidence_file:
        with open(evidence_file, 'r') as f:
            content = f.read().strip()
            if content.startswith('['):
                events = json.loads(content)
            else:
                for line in content.splitlines():
                    if line.strip():
                        try:
                            events.append(json.loads(line))
                        except Exception:
                            pass
except Exception:
    pass

# Parse window if provided
window_start = None
window_end = None
if window_arg:
    parts = window_arg.split(',')
    if len(parts) == 2:
        try:
            window_start = datetime.fromisoformat(parts[0].strip())
            window_end = datetime.fromisoformat(parts[1].strip())
        except Exception:
            pass

rule_id = rule.get('id', 'unknown-id')
rule_title = rule.get('title', 'unknown-title')
level = rule.get('level', 'medium')

detection = rule.get('detection', {})
selection = detection.get('selection', {})
condition = detection.get('condition', '')

matched_events = []

for idx, ev in enumerate(events):
    if window_start or window_end:
        ts_str = ev.get('timestamp')
        if ts_str:
            try:
                ev_time = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
                if window_start and ev_time < window_start:
                    continue
                if window_end and ev_time > window_end:
                    continue
            except Exception:
                pass

    match = True
    for k, v in selection.items():
        if isinstance(v, list):
            if ev.get(k) not in v:
                match = False
                break
        else:
            if ev.get(k) != v:
                match = False
                break
    if match:
        hostname = ev.get('host', ev.get('hostname', 'unknown-host'))
        timestamp = ev.get('timestamp', '')
        matched_events.append({
            "timestamp": timestamp,
            "hostname": hostname,
            "event_ref": idx
        })

if 'count(' in condition and matched_events:
    from collections import defaultdict
    try:
        field_to_count = condition.split('count(')[1].split(')')[0].strip()
        counts = defaultdict(list)
        for ev_ref in matched_events:
            ev = events[ev_ref['event_ref']]
            val = ev.get(field_to_count, 'unknown')
            counts[val].append(ev_ref)

        filtered_matches = []
        for val, ev_list in counts.items():
            if len(ev_list) > 5:
                filtered_matches.extend(ev_list)
        matched_events = filtered_matches
    except Exception:
        pass

execution_time_ms = int((time.time() - start_time) * 1000)

if count_only:
    print(len(matched_events))
else:
    result = {
        "rule_id": rule_id,
        "rule_title": rule_title,
        "level": level,
        "evidence_path": evidence_file,
        "match_count": len(matched_events),
        "matches": matched_events,
        "execution_time_ms": execution_time_ms
    }
    print(json.dumps(result, indent=2))
PY_EOF
