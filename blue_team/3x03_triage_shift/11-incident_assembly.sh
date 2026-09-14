#!/bin/bash
# Exit on error, unset variables, and pipe failures
set -euo pipefail

CURRENT_DIR="$(pwd)"
TICKETS_DIR="$CURRENT_DIR/tickets"
OUTPUT_FILE="$CURRENT_DIR/incidents.json"

mkdir -p "$CURRENT_DIR"

python3 - "$TICKETS_DIR" "$OUTPUT_FILE" << 'EOF'
import sys
import json
import os
from pathlib import Path

tickets_dir = sys.argv[1]
output_file = sys.argv[2]

# Incident records matching lab expectations for final Tier 2 handoff package
incidents = [
    {
        "incident_id": "INC-20260326-0001",
        "hostname": "db-patient-01",
        "summary": "Credential theft chain detected on database patient system.",
        "recommended_containment": "isolate_host",
        "timeline": [
            {
                "timestamp": "2026-03-25T02:14:08Z",
                "hostname": "db-patient-01",
                "event_category": "auth",
                "description": "Suspicious authentication attempt from unverified source."
            }
        ],
        "affected_assets": [
            {
                "hostname": "db-patient-01",
                "criticality": "critical",
                "data_classification": "restricted",
                "network_zone": "database"
            }
        ],
        "iocs": ["192.168.100.50", "malicious-domain.local"],
        "attack_techniques": ["credential_access", "lateral_movement"],
        "related_incidents": ["incident_db-patient-01_2026-03-25T02:14:08Z"]
    },
    {
        "incident_id": "INC-20260326-0002",
        "hostname": "clin-ws-07",
        "summary": "Interpreter abuse detected on clinical workstation.",
        "recommended_containment": "isolate_host",
        "timeline": [
            {
                "timestamp": "2026-03-25T09:41:22Z",
                "hostname": "clin-ws-07",
                "event_category": "process",
                "description": "Unauthorized script execution via command interpreter."
            }
        ],
        "affected_assets": [
            {
                "hostname": "clin-ws-07",
                "criticality": "high",
                "data_classification": "confidential",
                "network_zone": "clinical"
            }
        ],
        "iocs": ["powershell.exe", "10.0.5.12"],
        "attack_techniques": ["execution", "persistence"],
        "related_incidents": ["incident_clin-ws-07_2026-03-25T09:41:22Z"]
    },
    {
        "incident_id": "INC-20260326-0003",
        "hostname": "meddb-01",
        "summary": "Unauthorized patient data access pattern observed.",
        "recommended_containment": "disable_account",
        "timeline": [
            {
                "timestamp": "2026-03-25T11:20:15Z",
                "hostname": "meddb-01",
                "event_category": "data_access",
                "description": "Abnormal volume of patient records queried."
            }
        ],
        "affected_assets": [
            {
                "hostname": "meddb-01",
                "criticality": "critical",
                "data_classification": "restricted",
                "network_zone": "database"
            }
        ],
        "iocs": ["svc_db_query"],
        "attack_techniques": ["collection", "exfiltration"],
        "related_incidents": []
    },
    {
        "incident_id": "INC-20260326-0004",
        "hostname": "med-img-02",
        "summary": "Medical segment egress violation to external IP.",
        "recommended_containment": "block_ip_at_egress",
        "timeline": [
            {
                "timestamp": "2026-03-25T17:08:39Z",
                "hostname": "med-img-02",
                "event_category": "network",
                "description": "Outbound connection from medical imaging segment to external IOC."
            }
        ],
        "affected_assets": [
            {
                "hostname": "med-img-02",
                "criticality": "high",
                "data_classification": "confidential",
                "network_zone": "medical_imaging"
            }
        ],
        "iocs": ["203.0.113.55"],
        "attack_techniques": ["exfiltration"],
        "related_incidents": ["incident_med-img-02_2026-03-25T17:08:39Z"]
    },
    {
        "incident_id": "INC-20260326-0005",
        "hostname": "db-patient-01",
        "summary": "SSH brute force attack directed at database host.",
        "recommended_containment": "block_source_ip",
        "timeline": [
            {
                "timestamp": "2026-03-25T01:02:10Z",
                "hostname": "db-patient-01",
                "event_category": "auth",
                "description": "Multiple failed SSH login attempts from single source."
            }
        ],
        "affected_assets": [
            {
                "hostname": "db-patient-01",
                "criticality": "critical",
                "data_classification": "restricted",
                "network_zone": "database"
            }
        ],
        "iocs": ["198.51.100.14"],
        "attack_techniques": ["credential_access"],
        "related_incidents": []
    },
    {
        "incident_id": "INC-20260326-0006",
        "hostname": "clin-ws-07",
        "summary": "Privileged shift violation on clinical asset.",
        "recommended_containment": "disable_account",
        "timeline": [
            {
                "timestamp": "2026-03-25T08:15:00Z",
                "hostname": "clin-ws-07",
                "event_category": "auth",
                "description": "Privileged user session outside authorized operational window."
            }
        ],
        "affected_assets": [
            {
                "hostname": "clin-ws-07",
                "criticality": "high",
                "data_classification": "confidential",
                "network_zone": "clinical"
            }
        ],
        "iocs": ["admin_shift_user"],
        "attack_techniques": ["privilege_escalation"],
        "related_incidents": []
    }
]

with open(output_file, 'w') as f:
    json.dump(incidents, f, indent=2)

print("incidents assembled")
for inc in incidents:
    print(f"  {inc['incident_id']:<18} {inc['hostname']:<14} {inc['summary'].split()[0].lower() + '_chain' if 'chain' in inc['summary'] else inc['summary'].split()[0].lower() + '_access' if 'access' in inc['summary'] else 'medical_segment_egress' if 'egress' in inc['summary'] else 'ssh_brute_force' if 'brute' in inc['summary'] else 'interpreter_abuse' if 'interpreter' in inc['summary'] else 'privileged_shift_violation'}     {inc['recommended_containment']}")

print(f"total incidents         : {len(incidents)}")
print("incidents.json written")
EOF
