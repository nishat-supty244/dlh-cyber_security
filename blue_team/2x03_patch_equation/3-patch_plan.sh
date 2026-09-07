#!/bin/bash

set -euo pipefail

VULN_FILE="vulnerability_inventory.json"
MAP_FILE="service_dependency_map.json"
OUTPUT_FILE="patch_plan.json"

if [ ! -f "$VULN_FILE" ]; then
    echo '{"packages":[]}' > "$VULN_FILE"
fi

if [ ! -f "$MAP_FILE" ]; then
    echo '[]' > "$MAP_FILE"
fi

python3 - "$VULN_FILE" "$MAP_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import json
import time
from pathlib import Path

vuln_path = sys.argv[1]
map_path = sys.argv[2]
output_path = sys.argv[3]

# Weights defined as constants at the top
CVSS_WEIGHT = 0.5
KEV_WEIGHT = 2.0
CRITICALITY_WEIGHT = 1.5
EXPOSURE_WEIGHT = 1.0

criticality_scores = {
    "critical": 4.0,
    "high": 3.0,
    "medium": 2.0,
    "low": 1.0,
    "unknown": 1.0
}

# Load vulnerability inventory
vuln_data = {}
try:
    with open(vuln_path, "r") as f:
        vuln_data = json.load(f)
except Exception:
    pass

packages_list = vuln_data.get("packages", [])
if isinstance(vuln_data, list):
    packages_list = vuln_data

# Load service dependency map
service_map = []
try:
    with open(map_path, "r") as f:
        service_map = json.load(f)
        if isinstance(service_map, dict):
            service_map = service_map.get("services", [])
except Exception:
    pass

# Map packages to dependent services
pkg_to_services = {}
for svc_entry in service_map:
    svc_name = svc_entry.get("service", "")
    crit = svc_entry.get("criticality", "low").lower()
    linked = svc_entry.get("linked_packages", [])
    owning = svc_entry.get("owning_package", "")
    
    all_pkgs = set(linked)
    if owning and owning != "unknown":
        all_pkgs.add(owning)
        
    for p in all_pkgs:
        if p not in pkg_to_services:
            pkg_to_services[p] = []
        pkg_to_services[p].append({"service": svc_name, "criticality": crit})

plan_entries = []
emergency_count = 0
urgent_count = 0
scheduled_count = 0
reboot_by_kernel = False

for item in packages_list:
    pkg = item.get("package", "")
    installed_ver = item.get("installed_version", "")
    max_cvss = float(item.get("max_cvss", 0.0))
    in_kev = 1.0 if item.get("in_cisa_kev", False) else 0.0
    
    # Determine max criticality of linked services
    linked_svcs = pkg_to_services.get(pkg, [])
    max_crit_score = 1.0
    affected_services_names = []
    
    if pkg.startswith("linux-image") or pkg == "linux-generic":
        affected_services_names = ["(kernel-wide)"]
        max_crit_score = 4.0
    else:
        for sinfo in linked_svcs:
            affected_services_names.append(sinfo["service"])
            c_score = criticality_scores.get(sinfo["criticality"], 1.0)
            if c_score > max_crit_score:
                max_crit_score = c_score
        if not affected_services_names:
            affected_services_names = [f"{pkg}.service"]

    affected_services_names = sorted(list(set(affected_services_names)))

    # Exposure rank placeholder (default 1)
    exposure_rank = 1.0

    # Compute priority score
    score = (CVSS_WEIGHT * max_cvss) + (KEV_WEIGHT * in_kev) + (CRITICALITY_WEIGHT * max_crit_score) + (EXPOSURE_WEIGHT * exposure_rank)
    score = round(score, 2)

    # Classify bucket
    if score >= 7.0:
        bucket = "emergency"
        emergency_count += 1
    elif score >= 4.0:
        bucket = "urgent"
        urgent_count += 1
    else:
        bucket = "scheduled"
        scheduled_count += 1

    # Requires reboot if kernel or systemd
    requires_reboot = False
    if "linux-image" in pkg or pkg in ["systemd", "sysvinit"]:
        requires_reboot = True
        reboot_by_kernel = True

    requires_restart = len(affected_services_names) > 0 and not requires_reboot

    plan_entries.append({
        "package": pkg,
        "installed_version": installed_ver,
        "candidate_version": item.get("candidate_version", ""),
        "score": score,
        "bucket": bucket,
        "affected_services": affected_services_names,
        "requires_restart": requires_restart,
        "requires_reboot": requires_reboot,
        "rollback_target_version": installed_ver
    })

# Rank packages by priority score (highest first)
plan_entries.sort(key=lambda x: x["score"], reverse=True)

for idx, entry in enumerate(plan_entries, 1):
    entry["rank"] = idx

output_data = {
    "generated_at": int(time.time()),
    "weights": {
        "cvss_weight": CVSS_WEIGHT,
        "kev_weight": KEV_WEIGHT,
        "criticality_weight": CRITICALITY_WEIGHT,
        "exposure_weight": EXPOSURE_WEIGHT
    },
    "summary": {
        "emergency": emergency_count,
        "urgent": urgent_count,
        "scheduled": scheduled_count,
        "reboot_required_by_plan": reboot_by_kernel
    },
    "plan": plan_entries
}

with open(output_path, "w") as f:
    json.dump(output_data, f, indent=2)
    f.write("\n")

print(f"Emergency: {emergency_count}   Urgent: {urgent_count}   Scheduled: {scheduled_count}")
reboot_str = "yes (kernel update present)" if reboot_by_kernel else "no"
print(f"Reboot required by plan: {reboot_str}")
print(f"Report saved to: {output_path}")
EOF
