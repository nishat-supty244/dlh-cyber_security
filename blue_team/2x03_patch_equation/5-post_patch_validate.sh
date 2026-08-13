#!/bin/bash

set -euo pipefail

PRE_STATE_FILE="pre_patch_state.json"
MAP_FILE="service_dependency_map.json"
PROBES_FILE="service_probes.json"
OUTPUT_FILE="post_patch_validation.json"

if [ ! -f "$PRE_STATE_FILE" ]; then
    echo "Error: $PRE_STATE_FILE not found." >&2
    exit 1
fi

if [ ! -f "$MAP_FILE" ]; then
    echo "[]" > "$MAP_FILE"
fi

if [ ! -f "$PROBES_FILE" ]; then
    echo "{}" > "$PROBES_FILE"
fi

python3 - "$PRE_STATE_FILE" "$MAP_FILE" "$PROBES_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import json
import subprocess
import time

pre_state_path = sys.argv[1]
map_path = sys.argv[2]
probes_path = sys.argv[3]
output_path = sys.argv[4]

# Load pre-patch state
try:
    with open(pre_state_path, "r") as f:
        pre_data = json.load(f)
except Exception:
    pre_data = {}

pre_services = pre_data.get("services", {})
pre_listening = pre_data.get("listening", [])

# Load service dependency map for critical services
try:
    with open(map_path, "r") as f:
        map_data = json.load(f)
        if isinstance(map_data, dict):
            map_data = map_data.get("services", [])
except Exception:
    map_data = []

critical_services = set()
for entry in map_data:
    if entry.get("criticality", "").lower() == "critical":
        critical_services.add(entry.get("service", ""))

# Load service probes definition
try:
    with open(probes_path, "r") as f:
        probes_data = json.load(f)
except Exception:
    probes_data = {}

details = []
service_checks_total = 0
service_checks_passed = 0

listening_checks_total = 0
listening_checks_passed = 0

probe_checks_total = 0
probe_checks_passed = 0

# 1. Verify service ActiveState
for svc, state_info in pre_services.items():
    service_checks_total += 1
    pre_active = state_info.get("ActiveState", "active")
    
    # Check live system status via systemctl show
    live_active = "unknown"
    try:
        res = subprocess.run(["systemctl", "show", svc, "-p", "ActiveState", "--value"], capture_output=True, text=True, timeout=5)
        live_active = res.stdout.strip()
    except Exception:
        pass
    
    status = "pass"
    # Regression if pre was active and post is not active (or active/reloading is good)
    if pre_active == "active" and live_active not in ["active", "reloading"]:
        status = "regression"
    elif live_active == "unknown":
        status = "regression"

    if status == "pass":
        service_checks_passed += 1
    
    details.append({
        "type": "service_state",
        "target": svc,
        "pre_state": pre_active,
        "post_state": live_active,
        "status": status
    })

# 2. Verify listening sockets
# Extract ports or distinct socket identifiers from ss output lines
live_listening = []
try:
    res = subprocess.run(["ss", "-tulnp"], capture_output=True, text=True, timeout=5)
    live_listening = res.stdout.splitlines()
except Exception:
    pass

for sock_line in pre_listening:
    if not sock_line.strip():
        continue
    listening_checks_total += 1
    
    # Extract address/port portion from socket line for flexible matching
    parts = sock_line.split()
    matched = False
    if len(parts) >= 4:
        target_addr = parts[3]
        # Check if target_addr or similar port signature exists in live listening lines
        for live_line in live_listening:
            if target_addr in live_line:
                matched = True
                break
    
    status = "pass" if matched else "regression"
    if status == "pass":
        listening_checks_passed += 1
        
    details.append({
        "type": "listening_socket",
        "target": sock_line,
        "status": status
    })

# 3. Critical liveness probes
for svc in critical_services:
    probe_checks_total += 1
    probe_def = probes_data.get(svc, {})
    cmd = probe_def.get("command", "")
    
    probe_ok = False
    if cmd:
        try:
            res = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
            if res.returncode == 0:
                probe_ok = True
        except Exception:
            pass
    else:
        # Default fallback check if no custom command defined
        try:
            res = subprocess.run(["systemctl", "is-active", "--quiet", svc], timeout=5)
            if res.returncode == 0:
                probe_ok = True
        except Exception:
            pass

    status = "pass" if probe_ok else "probe_failed"
    if status == "pass":
        probe_checks_passed += 1
        
    details.append({
        "type": "liveness_probe",
        "target": svc,
        "status": status
    })

total_checks = service_checks_total + listening_checks_total + probe_checks_total
total_passed = service_checks_passed + listening_checks_passed + probe_checks_passed
total_failed = total_checks - total_passed

has_regression_or_failure = any(d["status"] != "pass" for d in details)

output_json = {
    "total_checks": total_checks,
    "passed": total_passed,
    "failed": total_failed,
    "details": details
}

with open(output_path, "w") as f:
    json.dump(output_json, f, indent=2)
    f.write("\n")

print(f"Service state checks:     {service_checks_passed}/{service_checks_total}   PASS" if service_checks_passed == service_checks_total else f"Service state checks:     {service_checks_passed}/{service_checks_total}   FAIL")
print(f"Listening socket checks:  {listening_checks_passed}/{listening_checks_total}   PASS" if listening_checks_passed == listening_checks_total else f"Listening socket checks:  {listening_checks_passed}/{listening_checks_total}   FAIL")
print(f"Critical liveness probes: {probe_checks_passed}/{probe_checks_total}     PASS" if probe_checks_passed == probe_checks_total else f"Critical liveness probes: {probe_checks_passed}/{probe_checks_total}   FAIL")

verdict_str = "PASS" if not has_regression_or_failure else "FAIL"
print(f"VERDICT: {verdict_str} ({total_passed}/{total_checks})")
print(f"Report saved to: {output_path}")

if has_regression_or_failure:
    sys.exit(1)
else:
    sys.exit(0)
EOF
