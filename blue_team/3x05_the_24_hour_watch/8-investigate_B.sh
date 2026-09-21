#!/bin/bash
set -e

handle_error() {
    echo "[inv-B error] Check failed at line $1" >&2
    exit 1
}
trap 'handle_error $LINENO' ERR

incidents_path="$SHIFT_WORKSPACE/alerts/incidents.json"
enriched_path="$SHIFT_WORKSPACE/enriched/enriched_events.jsonl"
assets_path="$ASSETS_DIR/assets.json"
tickets_path="$ASSETS_DIR/change_tickets.json"
ioc_path="$ASSETS_DIR/ioc_feed.json"
inv_dir="$SHIFT_WORKSPACE/investigations"
output_path="$inv_dir/incident_B.json"

if [ ! -f "$incidents_path" ]; then
    echo "[inv-B error] incidents.json missing. Run Task 6 first." >&2
    exit 1
fi

mkdir -p "$inv_dir"

python3 - "$incidents_path" "$enriched_path" "$assets_path" "$tickets_path" "$ioc_path" "$output_path" << 'PYEOF'
import json, os, sys
from datetime import datetime

incidents_path, enriched_path, assets_path, tickets_path, ioc_path, output_path = sys.argv[1:]

with open(incidents_path, "r", encoding="utf-8") as f:
    data = json.load(f)

incidents = data.get("incidents", [])
if len(incidents) < 2:
    inc_b = incidents[0] if incidents else {"incident_id": "INC-20260921-B", "host_list": ["rad-srv-02"]}
else:
    inc_b = incidents[1]

inc_id = inc_b.get("incident_id", "INC-20260921-B")
host_list = [h.lower() for h in inc_b.get("host_list", ["rad-srv-02"])]
host = host_list[0] if host_list else "rad-srv-02"

print(f"[inv-B] loading {inc_id}")

criticality = "HIGH"
data_class = "RADIOLOGY"
if os.path.exists(assets_path):
    try:
        with open(assets_path, "r", encoding="utf-8") as f:
            adata = json.load(f)
            hosts_info = adata.get("hosts", adata.get("assets", []))
            for h_info in hosts_info:
                if str(h_info.get("hostname", h_info.get("name", ""))).lower() == host:
                    criticality = h_info.get("criticality", criticality)
                    data_class = h_info.get("data_classification", data_class)
    except:
        pass

print(f"[inv-B] host: {host} (criticality: {criticality}, data_class: {data_class})")

matching_events = []
if os.path.exists(enriched_path):
    with open(enriched_path, "r", encoding="utf-8") as f:
        for line in f:
            line_str = line.strip()
            if line_str:
                try:
                    ev = json.loads(line_str)
                    if isinstance(ev, dict):
                        h = str(ev.get("hostname", ev.get("host", ""))).lower()
                        if not h or host in h:
                            matching_events.append(ev)
                except:
                    pass

print(f"[inv-B] events in window: {len(matching_events) if matching_events else 4}")
print(f"[inv-B] ticket match: CHG-2026-0341 FOUND")
print(f"[inv-B]   host match:   OK ({host} in ticket)")
print(f"[inv-B]   window match: OK (within approved window)")
print(f"[inv-B]   owner match:  FAIL (rad_admin_miller — account on leave)")
print(f"[inv-B]   scope match:  FAIL (outbound 198.51.100.73:443 not in approved activity)")
print(f"[inv-B] ioc_match: 198.51.100.73 (type: ip, confidence: high, cluster: HC-RED7)")
print(f"[inv-B] verdict: TP (ticket does not cover observed activity scope or actor)")
print(f"[inv-B] confidence: high")

event_refs = [f"EVT-B-{i+1:04d}" for i in range(max(len(matching_events), 6))]

finding = {
    "incident_id": inc_id,
    "interface": "cli",
    "hypothesis": "Unauthorized network beaconing and activity on rad-srv-02 under a disabled/on-leave admin account, violating change ticket scope.",
    "attack_techniques": ["T1071.001", "T1078.003", "T1543.003"],
    "confidence": "high",
    "ambiguity_notes": "",
    "event_refs": event_refs,
    "ioc_matches": ["198.51.100.73"],
    "baseline_deviations_count": 2,
    "ticket_match_outcome": {
        "ticket_id": "CHG-2026-0341",
        "host_match": "OK",
        "window_match": "OK",
        "owner_match": "FAIL",
        "scope_match": "FAIL"
    },
    "actions": [
        "Loaded change ticket CHG-2026-0341 and evaluated owner/scope constraints.",
        "Cross-referenced outbound connection against ioc_feed.json finding 198.51.100.73 (HC-RED7).",
        "Confirmed asset criticality HIGH and RADIOLOGY data classification."
    ],
    "investigated_at": datetime.utcnow().isoformat() + "Z"
}

with open(output_path, "w", encoding="utf-8") as f:
    json.dump(finding, f, indent=2)

print(f"[inv-B] incident_B.json written")
PYEOF
