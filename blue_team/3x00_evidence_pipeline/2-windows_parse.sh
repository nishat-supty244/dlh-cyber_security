#!/bin/bash
set -euo pipefail

EVIDENCE_DIR="${1:-$HOME/evidence_pack_primary}"
OUTPUT_FILE="windows_events.json"

if [ ! -d "$EVIDENCE_DIR" ]; then
    echo "Error: Evidence directory $EVIDENCE_DIR does not exist." >&2
    exit 1
fi

python3 - "$EVIDENCE_DIR" "$OUTPUT_FILE" << 'EOF'
import sys
import os
import json

evidence_dir = sys.argv[1]
output_file = sys.argv[2]

sources = [
    ("windows/security.json", "evidence_pack", "reading security.json"),
    ("windows/sysmon.json", "evidence_pack", "reading sysmon.json"),
    ("windows/powershell.json", "evidence_pack", "reading powershell.json"),
    ("student_telemetry/windows_events.json", "student_telemetry", "appending student telemetry")
]

total_records = 0
required_fields = [
    "timestamp_raw", "hostname", "event_id", "channel", 
    "provider", "raw_message", "event_data", "source_origin"
]

with open(output_file, "w", encoding="utf-8") as out:
    for rel_path, origin, label in sources:
        filepath = os.path.join(evidence_dir, rel_path)
        if not os.path.exists(filepath):
            print(f"Warning: {filepath} does not exist, skipping.", file=sys.stderr)
            continue
        
        count = 0
        with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                except json.JSONDecodeError:
                    data = {"raw_message": line}
                
                for field in required_fields:
                    if field not in data:
                        data[field] = ""
                
                if origin == "student_telemetry":
                    if not data.get("source_origin") or data["source_origin"] == "evidence_pack":
                        data["source_origin"] = "student_telemetry"
                else:
                    data["source_origin"] = "evidence_pack"
                    
                out.write(json.dumps(data) + "\n")
                count += 1
        
        total_records += count
        print(f"{label:<27} ... {count} records")

print(f"{output_file}: {total_records}")
EOF
