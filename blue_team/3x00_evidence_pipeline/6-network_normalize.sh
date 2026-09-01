#!/bin/bash
#!/usr/bin/env python3
import json
import os
import sys
import csv
from datetime import datetime, timezone

EVIDENCE_DIR = os.path.expanduser("~/evidence_pack_primary/network")
if not os.path.exists(EVIDENCE_DIR):
    # Fallback to local relative path if testing locally
    EVIDENCE_DIR = "network"

# 1. Load Unified Schema
try:
    with open('event_schema.json', 'r') as f:
        schema = json.load(f)
    fields_def = schema.get('fields', [])
except Exception as e:
    print(f"Error loading event_schema.json: {e}")
    sys.exit(1)

all_fields = [f['name'] for f in fields_def]
required_fields = [f['name'] for f in fields_def if f.get('required')]

network_records = []
counts = {"firewall.csv": 0, "suricata_eve.json": 0, "pcap_summary.json": 0}

def to_iso(dt):
    if not dt:
        return None
    return dt.astimezone(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

# 2. Process firewall.csv
fw_path = os.path.join(EVIDENCE_DIR, "firewall.csv")
if os.path.exists(fw_path):
    with open(fw_path, 'r', encoding='utf-8', errors='ignore') as f:
        reader = csv.DictReader(f)
        for row in reader:
            norm_rec = {}
            # Timestamp: Unix epoch seconds
            try:
                ts = float(row.get("timestamp", 0))
                norm_rec["timestamp"] = to_iso(datetime.fromtimestamp(ts, tz=timezone.utc))
            except (ValueError, TypeError):
                norm_rec["timestamp"] = None

            norm_rec["hostname"] = "firewall-gw"
            norm_rec["source_type"] = "firewall"
            norm_rec["event_category"] = "network"
            norm_rec["severity"] = "high" if row.get("action") == "BLOCK" else "info"
            norm_rec["user"] = None
            norm_rec["process_name"] = None
            norm_rec["src_ip"] = row.get("src_ip")
            norm_rec["dst_ip"] = row.get("dst_ip")
            norm_rec["raw_message"] = json.dumps(row)

            # Enforce schema fields
            for f_name in all_fields:
                if f_name not in norm_rec or norm_rec[f_name] == "":
                    norm_rec[f_name] = None

            network_records.append(norm_rec)
            counts["firewall.csv"] += 1

# 3. Process suricata_eve.json
suricata_path = os.path.join(EVIDENCE_DIR, "suricata_eve.json")
if os.path.exists(suricata_path):
    with open(suricata_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue

            norm_rec = {}
            # Timestamp: ISO 8601 with microseconds/TZ
            ts_str = rec.get("timestamp")
            try:
                dt = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
                norm_rec["timestamp"] = to_iso(dt)
            except (ValueError, TypeError, AttributeError):
                norm_rec["timestamp"] = None

            norm_rec["hostname"] = rec.get("host", "suricata-sensor")
            norm_rec["source_type"] = "suricata"
            norm_rec["event_category"] = "network_alert"
            
            # Map severity and signature
            alert_info = rec.get("alert", {})
            sev_num = alert_info.get("severity", 3)
            norm_rec["severity"] = "high" if sev_num == 1 else ("medium" if sev_num == 2 else "low")
            
            norm_rec["user"] = None
            norm_rec["process_name"] = None
            norm_rec["src_ip"] = rec.get("src_ip")
            norm_rec["dst_ip"] = rec.get("dest_ip")
            norm_rec["raw_message"] = json.dumps(rec)

            for f_name in all_fields:
                if f_name not in norm_rec or norm_rec[f_name] == "":
                    norm_rec[f_name] = None

            network_records.append(norm_rec)
            counts["suricata_eve.json"] += 1

# 4. Process pcap_summary.json
pcap_path = os.path.join(EVIDENCE_DIR, "pcap_summary.json")
if os.path.exists(pcap_path):
    with open(pcap_path, 'r', encoding='utf-8', errors='ignore') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue

            norm_rec = {}
            # Timestamp: MM/DD/YYYY HH:MM:SS AM/PM
            ts_str = rec.get("start_time")
            try:
                dt = datetime.strptime(ts_str, "%m/%d/%Y %I:%M:%S %p")
                dt = dt.replace(tzinfo=timezone.utc)
                norm_rec["timestamp"] = to_iso(dt)
            except (ValueError, TypeError):
                norm_rec["timestamp"] = None

            norm_rec["hostname"] = rec.get("sensor", "pcap-analyzer")
            norm_rec["source_type"] = "pcap"
            norm_rec["event_category"] = "network_flow"
            norm_rec["severity"] = "info"
            norm_rec["user"] = None
            norm_rec["process_name"] = None
            norm_rec["src_ip"] = rec.get("src_ip")
            norm_rec["dst_ip"] = rec.get("dst_ip")
            norm_rec["raw_message"] = json.dumps(rec)

            for f_name in all_fields:
                if f_name not in norm_rec or norm_rec[f_name] == "":
                    norm_rec[f_name] = None

            network_records.append(norm_rec)
            counts["pcap_summary.json"] += 1

# 5. Write Outputs
with open("network_events.json", "w", encoding="utf-8") as out_net:
    for nr in network_records:
        out_net.write(json.dumps(nr) + "\n")

with open("normalized_events.json", "a", encoding="utf-8") as out_norm:
    for nr in network_records:
        out_norm.write(json.dumps(nr) + "\n")

# 6. Print Expected Console Format
print(f"firewall.csv        : ~{counts['firewall.csv']} records normalized")
print(f"suricata_eve.json   :  ~{counts['suricata_eve.json']} records normalized")
print(f"pcap_summary.json   :  ~{counts['pcap_summary.json']} records normalized")
print("appended to normalized_events.json")
print("network_events.json written")
