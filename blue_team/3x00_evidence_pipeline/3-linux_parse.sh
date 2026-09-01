#!/bin/bash
set -euo pipefail

EVIDENCE_DIR="${1:-$HOME/evidence_pack_primary}"
OUTPUT_FILE="linux_events.json"

if [ ! -d "$EVIDENCE_DIR" ]; then
    echo "Error: Evidence directory $EVIDENCE_DIR does not exist." >&2
    exit 1
fi

python3 - "$EVIDENCE_DIR" "$OUTPUT_FILE" << 'EOF'
import sys
import os
import re
import json

evidence_dir = sys.argv[1]
output_file = sys.argv[2]

auth_path = os.path.join(evidence_dir, "linux/auth.log")
audit_path = os.path.join(evidence_dir, "linux/audit.log")
syslog_path = os.path.join(evidence_dir, "linux/syslog")
telemetry_path = os.path.join(evidence_dir, "student_telemetry/linux_events.json")

def parse_syslog_line(line):
    # Regex for standard syslog: Month Day Time Hostname Program[pid]: message
    pattern = re.compile(r'^([A-Z][a-z]{2}\s+\d+\s+\d{2}:\d{2}:\d{2})\s+(\S+)\s+([^\[:]+)(?:\[(\d+)\])?:\s+(.*)$')
    match = pattern.match(line)
    if match:
        timestamp, hostname, program, pid, msg = match.groups()
        # Extract potential user if present in message
        user_match = re.search(r'(?:user|for|by)\s+([a-zA-Z0-9_-]+)', msg)
        user = user_match.group(1) if user_match else ""
        return {
            "timestamp_raw": timestamp,
            "hostname": hostname,
            "program": program.strip(),
            "pid": pid if pid else "",
            "user": user,
            "raw_message": line,
            "parsed_fields": {"message": msg},
            "source_origin": "evidence_pack"
        }
    else:
        return {
            "timestamp_raw": "",
            "hostname": "",
            "program": "",
            "pid": "",
            "user": "",
            "raw_message": line,
            "parsed_fields": {},
            "source_origin": "evidence_pack"
        }

def parse_audit_lines(filepath):
    if not os.path.exists(filepath):
        return [], 0
    
    total_lines = 0
    groups = {}
    group_order = []

    with open(filepath, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            total_lines += 1
            line_str = line.strip()
            if not line_str:
                continue
            
            # Extract msg=audit(timestamp:counter)
            msg_match = re.search(r'msg=audit\(([\d.]+:\d+)\)', line_str)
            group_id = msg_match.group(1) if msg_match else f"line_{total_lines}"
            
            if group_id not in groups:
                groups[group_id] = []
                group_order.append(group_id)
            groups[group_id].append(line_str)

    records = []
    for g_id in group_order:
        lines = groups[g_id]
        raw_message = " \n ".join(lines)
        
        # Parse timestamp from audit msg if available
        ts_match = re.search(r'audit\(([\d.]+):', g_id)
        timestamp_raw = ts_match.group(1) if ts_match else ""

        # Extract type=...
        type_match = re.search(r'type=([A-Z_]+)', lines[0])
        audit_type = type_match.group(1) if type_match else "UNKNOWN"

        # Extract user if present
        user_match = re.search(r'\buid=(\d+)\s+auid=(\d+)\s+ses=(\d+)\s+term=\S+\s+res=\S+\s+exe=\S+\s+unixtime=[\d.]+\s+cli=\S+\s+pid=\d+\s+comm=\S+\s+auid_name=([a-zA-Z0-9_-]+)', raw_message)
        user = user_match.group(4) if user_match else ""

        # Extract key-value pairs from lines
        kv_pairs = {"audit_group_id": g_id, "lines_count": len(lines)}
        for l in lines:
            for kv in re.finditer(r'([a-zA-Z0-9_.-]+)=("[^"]*"|\S+)', l):
                k, v = kv.groups()
                kv_pairs[k] = v.strip('"')

        records.append({
            "timestamp_raw": timestamp_raw,
            "hostname": "localhost",
            "audit_type": audit_type,
            "pid": kv_pairs.get("pid", ""),
            "user": user,
            "raw_message": raw_message,
            "parsed_fields": kv_pairs,
            "source_origin": "evidence_pack"
        })

    return records, total_lines

total_records = 0

with open(output_file, "w", encoding="utf-8") as out:
    # 1. Parse auth.log
    auth_lines = 0
    if os.path.exists(auth_path):
        with open(auth_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                auth_lines += 1
                rec = parse_syslog_line(line.strip())
                out.write(json.dumps(rec) + "\n")
                total_records += 1
    print(f"parsing auth.log      ... {auth_lines} lines  -> ~{auth_lines} records")

    # 2. Parse audit.log
    audit_records, audit_lines = parse_audit_lines(audit_path)
    for rec in audit_records:
        out.write(json.dumps(rec) + "\n")
        total_records += 1
    print(f"parsing audit.log     ... {audit_lines} lines  -> ~{len(audit_records)} records (grouped)")

    # 3. Parse syslog
    syslog_lines = 0
    if os.path.exists(syslog_path):
        with open(syslog_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                syslog_lines += 1
                rec = parse_syslog_line(line.strip())
                out.write(json.dumps(rec) + "\n")
                total_records += 1
    print(f"parsing syslog        ... {syslog_lines} lines  -> ~{syslog_lines} records")

    # 4. Append Student Telemetry
    telemetry_count = 0
    if os.path.exists(telemetry_path):
        with open(telemetry_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    data = json.loads(line)
                except json.JSONDecodeError:
                    continue
                data["source_origin"] = "student_telemetry"
                out.write(json.dumps(data) + "\n")
                telemetry_count += 1
    print(f"appending student telemetry ... {telemetry_count} records")

print(f"{output_file}: written")
EOF
