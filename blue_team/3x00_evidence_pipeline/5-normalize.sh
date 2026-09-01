#!/bin/bash
set -euo pipefail

python3 - << 'PYEOF'
import json
import os
import sys
from datetime import datetime

# 1. Load the Unified Schema
try:
    with open('event_schema.json', 'r') as f:
        schema = json.load(f)
    fields_def = schema.get('fields', [])
except Exception as e:
    print(f"Error loading event_schema.json: {e}")
    sys.exit(1)

required_fields = [f['name'] for f in fields_def if f.get('required')]
all_fields = [f['name'] for f in fields_def]

stats = {
    "windows_json": {"norm": 0, "quar": 0},
    "linux_text": {"norm": 0, "quar": 0}
}

# 2. Robust Timestamp Parser
def parse_timestamp(ts_raw):
    if not ts_raw: return None
    ts_raw = str(ts_raw).strip()
    
    # ISO-like format (Windows)
    if 'T' in ts_raw:
        ts_raw = ts_raw.replace('Z', '+00:00')
        try:
            return datetime.fromisoformat(ts_raw).strftime('%Y-%m-%dT%H:%M:%SZ')
        except ValueError:
            # Fallback basic string truncation if complex fractional seconds fail
            return ts_raw[:19] + "Z"
            
    # Syslog format (e.g., "Sep 01 12:34:56")
    try:
        # Defaulting to 2026 for lab data lacking years
        dt = datetime.strptime(f"2026 {ts_raw}", "%Y %b %d %H:%M:%S")
        return dt.strftime('%Y-%m-%dT%H:%M:%SZ')
    except ValueError: pass
    try:
        dt = datetime.strptime(f"2026 {ts_raw}", "%Y %b %e %H:%M:%S")
        return dt.strftime('%Y-%m-%dT%H:%M:%SZ')
    except ValueError: pass
    
    # Auditd Unix epoch (e.g., 1630000000.123)
    try:
        dt = datetime.fromtimestamp(float(ts_raw))
        return dt.strftime('%Y-%m-%dT%H:%M:%SZ')
    except ValueError: pass
    
    return None

out_norm = open('normalized_events.json', 'w', encoding='utf-8')
out_quar = open('quarantine.json', 'w', encoding='utf-8')

# 3. Processing Core
def process_file(filepath, source_label):
    if not os.path.exists(filepath):
        return
        
    with open(filepath, 'r', encoding='utf-8', errors='ignore') as infile:
        for line in infile:
            line = line.strip()
            if not line: continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue

            norm_rec = {}
            quarantine_reason = None
            
            # --- MAP FIELDS TO SCHEMA ---
            ts_raw = rec.get("timestamp_raw", "")
            norm_rec["timestamp"] = parse_timestamp(ts_raw)
            if not norm_rec["timestamp"] and "timestamp" in required_fields:
                quarantine_reason = f"Missing or unparseable timestamp: '{ts_raw}'"
                
            norm_rec["hostname"] = rec.get("hostname")
            norm_rec["source_type"] = rec.get("source_origin", source_label)
            
            if source_label == "windows_json":
                norm_rec["event_category"] = str(rec.get("channel", "windows_event"))
                norm_rec["severity"] = "info"
                norm_rec["user"] = rec.get("event_data", {}).get("TargetUserName") or rec.get("event_data", {}).get("SubjectUserName")
                norm_rec["process_name"] = rec.get("event_data", {}).get("Image")
                norm_rec["src_ip"] = rec.get("event_data", {}).get("SourceIp")
                norm_rec["dst_ip"] = rec.get("event_data", {}).get("DestinationIp")
            else:
                norm_rec["event_category"] = str(rec.get("program") or rec.get("audit_type", "linux_event"))
                norm_rec["severity"] = "info"
                norm_rec["user"] = rec.get("user")
                norm_rec["process_name"] = rec.get("parsed_fields", {}).get("comm") or rec.get("program")
                norm_rec["src_ip"] = None
                norm_rec["dst_ip"] = None
                
            norm_rec["raw_message"] = rec.get("raw_message")
            
            # --- VALIDATE & ENFORCE SCHEMA ---
            # Inject null for any missing schema fields
            for f in all_fields:
                if f not in norm_rec or norm_rec[f] == "":
                    norm_rec[f] = None
                    
            # Check required fields
            if not quarantine_reason:
                for req in required_fields:
                    if norm_rec.get(req) is None:
                        quarantine_reason = f"Missing required field: {req}"
                        break
                        
            # ROUTE: Normalized or Quarantine
            if quarantine_reason:
                rec["quarantine_reason"] = quarantine_reason
                out_quar.write(json.dumps(rec) + "\n")
                stats[source_label]["quar"] += 1
            else:
                # Reorder keys to strictly match schema definition order
                ordered_rec = {k: norm_rec[k] for k in all_fields}
                out_norm.write(json.dumps(ordered_rec) + "\n")
                stats[source_label]["norm"] += 1

process_file('windows_events.json', 'windows_json')
process_file('linux_events.json', 'linux_text')

out_norm.close()
out_quar.close()

# 4. Print Summary Output
w_norm = stats['windows_json']['norm']
w_quar = stats['windows_json']['quar']
l_norm = stats['linux_text']['norm']
l_quar = stats['linux_text']['quar']
t_norm = w_norm + l_norm
t_quar = w_quar + l_quar

print(f"{'windows_json':<16} : normalized {w_norm:>8}  quarantined {w_quar:>8}")
print(f"{'linux_text':<16} : normalized {l_norm:>8}  quarantined {l_quar:>8}")
print(f"{'total':<16} : normalized {t_norm:>8}  quarantined {t_quar:>8}")
print("normalized_events.json written")
print("quarantine.json  written")
PYEOF
