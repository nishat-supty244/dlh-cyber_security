#!/bin/bash
#!/usr/bin/env python3
import json
import os
import sys
from datetime import datetime, timezone, timedelta
from collections import Counter

input_file = "normalized_events.json"
output_file = "cleaned_events.json"
log_file = "cleaning_log.json"

if not os.path.exists(input_file):
    print(f"Error: {input_file} not found.", file=sys.stderr)
    sys.exit(1)

records = []
with open(input_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            records.append(json.loads(line))
        except json.JSONDecodeError:
            continue

cleaning_log = []
cleaned_records = []

# Counters for reporting
stats = {
    "malformed_detected": 0, "malformed_repaired": 0, "malformed_dropped": 0,
    "dup_detected": 0, "dup_removed": 0,
    "hostname_normalized": 0,
    "encoding_detected": 0, "encoding_repaired": 0,
    "tz_flagged": 0
}

# Pass 1: Collect timestamps to find dominant median date for TZ analysis
valid_dates = []
for r in records:
    ts = r.get("timestamp")
    if ts:
        try:
            dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
            valid_dates.append(dt)
        except ValueError:
            pass

median_date = None
if valid_dates:
    valid_dates.sort()
    median_date = valid_dates[len(valid_dates) // 2]

seen_signatures = set()
record_id_counter = 1

for r in records:
    rec_id = f"rec_{record_id_counter}"
    record_id_counter += 1
    
    modified = False
    
    # 1. Encoding Errors Check
    raw_msg = r.get("raw_message", "")
    if raw_msg and "\ufffd" in raw_msg:
        stats["encoding_detected"] += 1
        # Attempt repair by replacing replacement chars or re-decoding
        fixed_msg = raw_msg.replace("\ufffd", "?")
        cleaning_log.append({
            "defect_type": "encoding_error",
            "original_value": raw_msg[:100],
            "corrected_value": fixed_msg[:100],
            "record_id": rec_id,
            "reason": "Found unicode replacement characters (mojibake/encoding mismatch)."
        })
        r["raw_message"] = fixed_msg
        stats["encoding_repaired"] += 1

    # 2. Malformed Timestamps Check
    ts = r.get("timestamp")
    repaired_ts = None
    if not ts:
        stats["malformed_detected"] += 1
        stats["malformed_dropped"] += 1
        cleaning_log.append({
            "defect_type": "malformed_timestamp",
            "original_value": str(ts),
            "corrected_value": None,
            "record_id": rec_id,
            "reason": "Missing timestamp; unable to repair."
        })
        continue
    else:
        try:
            dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
            repaired_ts = dt
        except ValueError:
            stats["malformed_detected"] += 1
            # Attempt fallback repair
            try:
                # Try parsing standard formats
                dt = datetime.strptime(ts[:19], "%Y-%m-%d %H:%M:%S").replace(tzinfo=timezone.utc)
                repaired_ts = dt
                r["timestamp"] = dt.strftime('%Y-%m-%dT%H:%M:%SZ')
                stats["malformed_repaired"] += 1
                cleaning_log.append({
                    "defect_type": "malformed_timestamp",
                    "original_value": ts,
                    "corrected_value": r["timestamp"],
                    "record_id": rec_id,
                    "reason": "Timestamp did not parse as ISO 8601; repaired using standard fallback."
                })
            except Exception:
                stats["malformed_dropped"] += 1
                cleaning_log.append({
                    "defect_type": "malformed_timestamp",
                    "original_value": ts,
                    "corrected_value": None,
                    "record_id": rec_id,
                    "reason": "Timestamp unrepairable; dropped from cleaned dataset."
                })
                continue

    # 3. Timezone Inconsistency Check (if outside 12h window from median)
    if median_date and repaired_ts:
        diff = abs(repaired_ts - median_date)
        if diff > timedelta(hours=12):
            stats["tz_flagged"] += 1
            cleaning_log.append({
                "defect_type": "suspected_wrong_tz",
                "original_value": ts,
                "corrected_value": ts,
                "record_id": rec_id,
                "reason": f"Timestamp deviates by {diff} from median evidence timeframe (>12h threshold)."
            })

    # 4. Hostname Case Inconsistency
    hostname = r.get("hostname")
    if hostname and hostname != hostname.lower():
        stats["hostname_normalized"] += 1
        orig_host = hostname
        hostname = hostname.lower()
        r["hostname"] = hostname
        cleaning_log.append({
            "defect_type": "hostname_case",
            "original_value": orig_host,
            "corrected_value": hostname,
            "record_id": rec_id,
            "reason": "Normalized uppercase/mixed-case hostname to lowercase."
        })

    # 5. Duplicates Check
    sig = (r.get("timestamp"), r.get("hostname"), r.get("source_type"), r.get("raw_message"))
    if sig in seen_signatures:
        stats["dup_detected"] += 1
        stats["dup_removed"] += 1
        cleaning_log.append({
            "defect_type": "duplicate_record",
            "original_value": f"Duplicate signature for host {r.get('hostname')}",
            "corrected_value": None,
            "record_id": rec_id,
            "reason": "Exact match on timestamp, hostname, source_type, and raw_message. Removed duplicate."
        })
        continue
    else:
        seen_signatures.add(sig)

    cleaned_records.append(r)

# Write outputs
with open(output_file, 'w', encoding='utf-8') as out:
    for cr in cleaned_records:
        out.write(json.dumps(cr) + "\n")

with open(log_file, 'w', encoding='utf-8') as out_log:
    for log_entry in cleaning_log:
        out_log.write(json.dumps(log_entry) + "\n")

# Print Expected Output Summary
print(f"malformed timestamps   :  detected {stats['malformed_detected']:<4} repaired {stats['malformed_repaired']:<4} dropped {stats['malformed_dropped']:<4}")
print(f"duplicates             :  detected {stats['dup_detected']:<4} removed {stats['dup_removed']:<4}")
print(f"hostname case          :  normalized {stats['hostname_normalized']}")
print(f"encoding errors        :  detected {stats['encoding_detected']:<4} repaired {stats['encoding_repaired']:<4}")
print(f"suspected wrong tz     :  flagged {stats['tz_flagged']}")
print(f"cleaned_events.json    written")
print(f"cleaning_log.json      written")
EOF
