#!/bin/bash
#!/usr/bin/env python3
import json
import os
import sys
import ipaddress

EVIDENCE_DIR = os.path.expanduser("~/evidence_pack_primary/context")
input_file = "cleaned_events.json"
output_file = "enriched_events.json"

if not os.path.exists(input_file):
    print(f"Error: {input_file} not found.", file=sys.stderr)
    sys.exit(1)

# 1. Load Asset Inventory
asset_path = os.path.join(EVIDENCE_DIR, "asset_inventory.json")
assets = {}
if os.path.exists(asset_path):
    with open(asset_path, 'r', encoding='utf-8') as f:
        try:
            data = json.load(f)
            # Support list of assets or dict mapping hostname -> asset
            if isinstance(data, list):
                for item in data:
                    h = item.get("hostname", "").lower()
                    if h:
                        assets[h] = item
            elif isinstance(data, dict):
                for h, item in data.items():
                    assets[h.lower()] = item
        except json.JSONDecodeError:
            pass

# 2. Load Network Zones
zones_path = os.path.join(EVIDENCE_DIR, "network_zones.json")
zone_networks = []
if os.path.exists(zones_path):
    with open(zones_path, 'r', encoding='utf-8') as f:
        try:
            z_data = json.load(f)
            # Expecting a list of dicts with 'cidr' and 'zone' (or similar structure)
            if isinstance(z_data, list):
                for item in z_data:
                    cidr = item.get("cidr")
                    z_name = item.get("zone") or item.get("name")
                    if cidr and z_name:
                        try:
                            net = ipaddress.ip_network(cidr, strict=False)
                            zone_networks.append((net, z_name))
                        except ValueError:
                            pass
            elif isinstance(z_data, dict):
                for cidr, z_name in z_data.items():
                    try:
                        net = ipaddress.ip_network(cidr, strict=False)
                        zone_networks.append((net, z_name))
                    except ValueError:
                        pass
        except json.JSONDecodeError:
            pass

def lookup_zone(ip_str):
    if not ip_str:
        return "unknown"
    try:
        ip_obj = ipaddress.ip_address(ip_str)
        for net, zone_name in zone_networks:
            if ip_obj in net:
                return zone_name
    except ValueError:
        pass
    return "unknown"

# 3. Process Records
total_events = 0
asset_matched = 0
src_zone_resolved = 0
dst_zone_resolved = 0
unknown_hosts_set = set()

enriched_records = []

with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            rec = json.loads(line)
        except json.JSONDecodeError:
            continue

        total_events += 1
        hostname = (rec.get("hostname") or "").lower()

        # Asset enrichment
        if hostname in assets:
            a_info = assets[hostname]
            rec["asset"] = {
                "role": a_info.get("role"),
                "criticality": a_info.get("criticality"),
                "os": a_info.get("os"),
                "owner": a_info.get("owner"),
                "zone": a_info.get("zone")
            }
            asset_matched += 1
        else:
            rec["asset"] = None
            if hostname:
                unknown_hosts_set.add(hostname)

        # Network Zone enrichment
        src_ip = rec.get("src_ip")
        dst_ip = rec.get("dst_ip")

        src_z = lookup_zone(src_ip)
        dst_z = lookup_zone(dst_ip)

        rec["src_zone"] = src_z
        rec["dst_zone"] = dst_z

        if src_z != "unknown":
            src_zone_resolved += 1
        if dst_z != "unknown":
            dst_zone_resolved += 1

        enriched_records.append(rec)

# Write output
with open(output_file, 'w', encoding='utf-8') as out:
    for er in enriched_records:
        out.write(json.dumps(er) + "\n")

# Compute percentages
asset_pct = round((asset_matched / total_events * 100) if total_events > 0 else 0, 1)
src_pct = round((src_zone_resolved / total_events * 100) if total_events > 0 else 0, 1)
dst_pct = round((dst_zone_resolved / total_events * 100) if total_events > 0 else 0, 1)

# Print Summary
print(f"events processed    : {total_events}")
print(f"asset context added : {asset_matched} ({asset_pct}%)")
print(f"src_zone resolved   : {src_zone_resolved} ({src_pct}%)")
print(f"dst_zone resolved   : {dst_zone_resolved} ({dst_pct}%)")
print(f"unknown hosts       : {len(unknown_hosts_set)}")
print(f"enriched_events.json written")
EOF
