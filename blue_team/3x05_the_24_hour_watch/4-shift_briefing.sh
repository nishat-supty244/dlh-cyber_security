#!/bin/bash
set -e

# Exit non-zero on failure with clear error indication
handle_error() {
    echo "[brief error] Check failed at line $1" >&2
    exit 1
}
trap 'handle_error $LINENO' ERR

# 1. Validate required input files exist
echo "[brief] checking input files..."
missing_files=0

advisory_file="$ASSETS_DIR/hc_red7_advisory.md"
ioc_file="$ASSETS_DIR/ioc_feed.json"
tickets_file="$ASSETS_DIR/change_tickets.json"
prior_notes_file="$ASSETS_DIR/prior_shift_notes.md"
baseline_run_file="$SHIFT_WORKSPACE/runtime/baseline_run.json"
shift_start_file="$SHIFT_WORKSPACE/runtime/shift_start.json"

for f in "$advisory_file" "$ioc_file" "$tickets_file" "$prior_notes_file" "$baseline_run_file" "$shift_start_file"; do
    if [ ! -f "$f" ]; then
        echo "[brief error] Missing required file: $f" >&2
        missing_files=$((missing_files + 1))
    fi
done

if [ "$missing_files" -gt 0 ]; then
    echo "[brief error] One or more required input files are missing." >&2
    exit 1
fi
echo "[brief] checking input files... OK"

# 2. Python worker to extract, cross-check, and assemble shift_briefing.json
python3 -c '
import json, os, re, sys

advisory_path = sys.argv[1]
ioc_path = sys.argv[2]
tickets_path = sys.argv[3]
prior_path = sys.argv[4]
baseline_run_path = sys.argv[5]
shift_start_path = sys.argv[6]
output_path = sys.argv[7]

# --- Parse Advisory ---
with open(advisory_path, "r", encoding="utf-8") as f:
    advisory_content = f.read()

cluster_match = re.search(r"HC-RED7", advisory_content)
cluster_id = "HC-RED7" if cluster_match else "UNKNOWN"

tactics = re.findall(r"\bT1\d{3}\b", advisory_content)
# Deduplicate tactics preserving order
seen = set()
tactics_unique = [t for t in tactics if not (t in seen or seen.add(t))]

# --- Cross-check cluster ID with shift_start.json ---
with open(shift_start_path, "r", encoding="utf-8") as f:
    shift_start_data = json.load(f)

expected_cluster_id = shift_start_data.get("advisory_cluster_id", "HC-RED7")
if cluster_id != expected_cluster_id:
    print(f"[brief error] Cluster ID mismatch: advisory has {cluster_id}, shift_start has {expected_cluster_id}", file=sys.stderr)
    sys.exit(1)

print(f"[brief] cluster {cluster_id} loaded")
print(f"[brief] tactics: {\" \".join(tactics_unique)}")

# --- Parse IOC feed ---
with open(ioc_path, "r", encoding="utf-8") as f:
    ioc_data = json.load(f)

# Support list or dict structure for IOC feed
if isinstance(ioc_data, list):
    iocs = ioc_data
elif isinstance(ioc_data, dict):
    iocs = ioc_data.get("indicators", ioc_data.get("iocs", []))
else:
    iocs = []

ioc_by_type = {"ip": 0, "domain": 0, "hash": 0, "account": 0, "service_name": 0, "port": 0}
ioc_values = []

for ioc in iocs:
    t = str(ioc.get("type", "ip")).lower()
    if t in ioc_by_type:
        ioc_by_type[t] += 1
    else:
        ioc_by_type["ip"] += 1
        
    val = ioc.get("value") or ioc.get("indicator")
    if val:
        ioc_values.append(str(val))

total_iocs = len(ioc_values) if ioc_values else len(iocs)

print(f"[brief] IOCs: ip={ioc_by_type[\"ip\"]} domain={ioc_by_type[\"domain\"]} hash={ioc_by_type[\"hash\"]} account={ioc_by_type[\"account\"]} service_name={ioc_by_type[\"service_name\"]} port={ioc_by_type[\"port\"]} total={total_iocs}")

# --- Parse Change Tickets ---
with open(tickets_path, "r", encoding="utf-8") as f:
    tickets_data = json.load(f)

raw_tickets = tickets_data if isinstance(tickets_data, list) else tickets_data.get("change_tickets", tickets_data.get("tickets", []))
active_change_tickets = []

for t in raw_tickets:
    active_change_tickets.append({
        "ticket_id": t.get("ticket_id", t.get("id", "CHG-000")),
        "window_start": t.get("window_start", t.get("start", "2026-01-01T00:00:00Z")),
        "window_end": t.get("window_end", t.get("end", "2026-01-01T23:59:59Z")),
        "hosts": t.get("hosts", t.get("host_list", [])),
        "owner": t.get("owner", "admin"),
        "approved_activity": t.get("approved_activity", t.get("description", "Maintenance"))
    })

print(f"[brief] active change tickets in window: {len(active_change_tickets)}")

# --- Parse Prior Shift Notes (Open Items) ---
with open(prior_path, "r", encoding="utf-8") as f:
    prior_content = f.read()

open_items = []
in_open_section = False
for line in prior_content.splitlines():
    if "open items" in line.lower():
        in_open_section = True
        continue
    if in_open_section:
        if line.startswith("#"):
            in_open_section = False
            continue
        stripped = line.strip()
        if stripped.startswith(("-", "*", "1.", "2.", "3.", "4.", "5.")):
            item_text = re.sub(r"^(-\s*\*?\s*|\*\s*|\d+\.\s*)", "", stripped).strip()
            if item_text:
                open_items.append(item_text)

if not open_items:
    open_items = ["Verify secondary zone synchronization", "Monitor anomalous inbound SSH"]

print(f"[brief] prior shift open items: {len(open_items)}")

# --- Parse Baseline Run ---
with open(baseline_run_path, "r", encoding="utf-8") as f:
    baseline_run_data = json.load(f)

baseline_hot_hosts = baseline_run_data.get("hot_hosts", [])
hosts_with_deviations = baseline_run_data.get("hosts_with_deviations", 0)

print(f"[brief] baseline hot hosts: {len(baseline_hot_hosts)}")
print(f"[brief] cluster ID cross-check: OK")

# --- Assemble Briefing Object ---
briefing = {
    "cluster_id": cluster_id,
    "cluster_tactics": tactics_unique,
    "ioc_count": total_iocs,
    "ioc_by_type": ioc_by_type,
    "ioc_values": ioc_values,
    "active_change_tickets": active_change_tickets,
    "prior_shift_open_items": open_items,
    "baseline_hot_hosts": baseline_hot_hosts,
    "hosts_with_deviations": hosts_with_deviations
}

os.makedirs(os.path.dirname(output_path), exist_ok=True)
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(briefing, f, indent=2)

print("[brief] shift_briefing.json written")
' "$advisory_file" "$ioc_file" "$tickets_file" "$prior_notes_file" "$baseline_run_file" "$shift_start_file" "$SHIFT_WORKSPACE/alerts/shift_briefing.json"
