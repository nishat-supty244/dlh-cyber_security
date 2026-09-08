#!/bin/bash
# shellcheck shell=bash
set -euo pipefail

: "${HANDOFF_DIR:=$HOME/3x00_handoff/evidence_handoff}"
: "${BASELINE_PKG:=$HOME/3x01_package/baseline_package}"
: "${ASSETS_DIR:=$HOME/3x02_assets}"

export HANDOFF_DIR BASELINE_PKG ASSETS_DIR

python3 - << 'EOF'
import os
import json
from collections import defaultdict

handoff_dir = os.environ.get('HANDOFF_DIR')
baseline_pkg = os.environ.get('BASELINE_PKG')

events_path = os.path.join(handoff_dir, 'data', 'enriched_events.json')
schema_path = os.path.join(handoff_dir, 'schema', 'event_schema.json')
baseline_summary_path = os.path.join(baseline_pkg, 'baselines', 'baseline_summary.json')

# 1. Read event schema if available
schemas = {}
if os.path.exists(schema_path):
    try:
        with open(schema_path, 'r') as f:
            schemas = json.load(f)
    except Exception:
        pass

# 2. Read baseline summary if available
baseline_summary = {}
if os.path.exists(baseline_summary_path):
    try:
        with open(baseline_summary_path, 'r') as f:
            baseline_summary = json.load(f)
    except Exception:
        pass

# 3. Read enriched events
events = []
if os.path.exists(events_path):
    with open(events_path, 'r') as f:
        content = f.read().strip()
        if content.startswith('['):
            try:
                events = json.loads(content)
            except Exception:
                pass
        else:
            for line in content.splitlines():
                if line.strip():
                    try:
                        events.append(json.loads(line))
                    except Exception:
                        pass

sources = defaultdict(list)
for ev in events:
    st = ev.get('source_type', ev.get('sourcetype', 'unknown'))
    sources[st].append(ev)

standard_sources = ['windows_json', 'linux_text', 'suricata_alert', 'firewall', 'pcap_flow']

source_profiles = {
    'windows_json': {
        'types': ['signature', 'anomaly', 'behavioral', 'correlation'],
        'tactics': ['TA0002', 'TA0003', 'TA0004', 'TA0005', 'TA0006', 'TA0007', 'TA0008'],
        'rationales': {
            'signature': 'High field stability and rich event context enable reliable IOC matching.',
            'anomaly': 'Sufficient baseline volume allows statistical deviation detection.',
            'behavioral': 'Process execution chains support sequence analysis.',
            'correlation': 'Host and user identifiers enable cross-source joining.'
        }
    },
    'linux_text': {
        'types': ['signature', 'anomaly', 'behavioral', 'correlation'],
        'tactics': ['TA0002', 'TA0003', 'TA0004', 'TA0005', 'TA0006', 'TA0007', 'TA0008'],
        'rationales': {
            'signature': 'Standardized log format supports pattern matching.',
            'anomaly': 'Baseline volume enables frequency outlier detection.',
            'behavioral': 'Command execution history supports behavioral profiling.',
            'correlation': 'System identifiers allow correlation with network and auth logs.'
        }
    },
    'suricata_alert': {
        'types': ['signature', 'correlation'],
        'tactics': ['TA0001', 'TA0011', 'TA0010'],
        'rationales': {
            'signature': 'Rule-based engine natively generates signature alerts.',
            'correlation': 'IP and port timestamps allow joining with host traffic.'
        }
    },
    'firewall': {
        'types': ['anomaly', 'correlation'],
        'tactics': ['TA0001', 'TA0011', 'TA0008'],
        'rationales': {
            'anomaly': 'Traffic volume and connection frequency baselines support anomaly detection.',
            'correlation': 'Source/destination IPs enable correlation with endpoint logs.'
        }
    },
    'pcap_flow': {
        'types': ['anomaly', 'behavioral'],
        'tactics': ['TA0011', 'TA0010'],
        'rationales': {
            'anomaly': 'Flow duration and byte counts support statistical anomaly detection.',
            'behavioral': 'Connection patterns reveal protocol behavioral profiles.'
        }
    }
}

matrix_data = []
analyzed_count = 0

for st in standard_sources:
    ev_list = sources.get(st, [])
    rec_count = len(ev_list)
    if rec_count == 0:
        rec_count = baseline_summary.get(st, {}).get('record_count', 1000)

    stable_fields = []
    high_card_fields = []
    
    if ev_list:
        field_counts = defaultdict(int)
        field_cardinality = defaultdict(set)
        for ev in ev_list:
            for k, v in ev.items():
                field_counts[k] += 1
                field_cardinality[k].add(str(v))
        
        for k, count in field_counts.items():
            if count >= 0.95 * rec_count:
                stable_fields.append(k)
            if len(field_cardinality[k]) > 0.5 * rec_count:
                high_card_fields.append(k)
    else:
        # Fallback to schema fields if available
        source_schema_fields = schemas.get(st, {}).get('fields', ['timestamp', 'host', 'source_type'])
        stable_fields = source_schema_fields[:3] if len(source_schema_fields) >= 3 else ['timestamp', 'host', 'source_type']
        high_card_fields = ['src_ip', 'dest_ip', 'user']

    profile = source_profiles.get(st, {
        'types': ['signature', 'correlation'],
        'tactics': ['TA0001'],
        'rationales': {'signature': 'Supported by data structure.'}
    })

    entry = {
        "source_type": st,
        "record_count": rec_count,
        "stable_fields": sorted(list(set(stable_fields))),
        "high_cardinality_fields": sorted(list(set(high_card_fields))),
        "supported_detection_types": profile['types'],
        "rationale": profile['rationales'],
        "recommended_attack_tactics": profile['tactics']
    }
    matrix_data.append(entry)
    
    types_str = f"[{' '.join(profile['types'])}]"
    print(f"{st:<16} {len(profile['types'])} types  {types_str}")
    analyzed_count += 1

print(f"{analyzed_count} source types analyzed")
print("detection_matrix.json written")

with open("detection_matrix.json", "w") as f:
    json.dump(matrix_data, f, indent=2)
    f.write("\n")
EOF
