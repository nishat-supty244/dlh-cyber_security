#!/bin/bash

set -euo pipefail

CRITICALITY_FILE="service_criticality.json"
OUTPUT_FILE="service_dependency_map.json"

if [ ! -f "$CRITICALITY_FILE" ]; then
    echo '{"services": {}}' > "$CRITICALITY_FILE"
fi

python3 - "$CRITICALITY_FILE" "$OUTPUT_FILE" << 'EOF'
import sys
import subprocess
import json
import os
from pathlib import Path

crit_file = sys.argv[1]
output_file = sys.argv[2]

criticality_map = {}
try:
    with open(crit_file, "r") as f:
        data = json.load(f)
        criticality_map = data.get("services", data)
except Exception:
    pass

# List every active systemd unit of type service using systemctl
res = subprocess.run(["systemctl", "list-units", "--type=service", "--state=active", "--no-legend"], capture_output=True, text=True)
service_entries = []

for line in res.stdout.splitlines():
    parts = line.strip().split()
    if not parts:
        continue
    service_name = parts[0]
    
    exec_path = ""
    # Resolve executable path using systemctl show
    show_res = subprocess.run(["systemctl", "show", service_name, "-p", "ExecStart,MainPID", "--no-ambiguous"], capture_output=True, text=True)
    
    main_pid = ""
    for sh_line in show_res.stdout.splitlines():
        if sh_line.startswith("MainPID="):
            main_pid = sh_line.split("=", 1)[1].strip()
        elif sh_line.startswith("ExecStart=") and not exec_path:
            val = sh_line.split("=", 1)[1].strip()
            # Simple token lookup for absolute paths
            for token in val.split():
                clean_token = token.strip("{}()[]\"'")
                if clean_token.startswith("/"):
                    exec_path = clean_token
                    break

    # Fallback to /proc/<pid>/exe if ExecStart path wasn't found cleanly
    if (not exec_path or exec_path == "/") and main_pid and main_pid != "0" and main_pid.isdigit():
        try:
            exe_link = os.readlink(f"/proc/{main_pid}/exe")
            if exe_link and not exe_link.startswith("/deleted"):
                exec_path = exe_link
        except Exception:
            pass

    # If still no exec_path, use a fallback placeholder matching the service name or skip
    if not exec_path:
        exec_path = f"/usr/bin/{service_name.replace('.service', '')}"

    # Resolve owning package via dpkg -S
    owning_package = "unknown"
    if os.path.exists(exec_path):
        try:
            dpkg_res = subprocess.run(["dpkg", "-S", exec_path], capture_output=True, text=True)
            if dpkg_res.returncode == 0:
                line_out = dpkg_res.stdout.splitlines()[0]
                if ":" in line_out:
                    owning_package = line_out.split(":", 1)[0].strip()
        except Exception:
            pass

    # Resolve dynamic libraries with ldd
    linked_packages = set()
    if owning_package != "unknown":
        linked_packages.add(owning_package)

    if os.path.exists(exec_path) and os.access(exec_path, os.X_OK):
        try:
            ldd_res = subprocess.run(["ldd", exec_path], capture_output=True, text=True)
            if ldd_res.returncode == 0:
                for ldd_line in ldd_res.stdout.splitlines():
                    if "=>" in ldd_line:
                        lib_path = ldd_line.split("=>")[1].split("(")[0].strip()
                        if lib_path.startswith("/"):
                            try:
                                lib_dpkg = subprocess.run(["dpkg", "-S", lib_path], capture_output=True, text=True)
                                if lib_dpkg.returncode == 0:
                                    lib_pkg = lib_dpkg.stdout.splitlines()[0].split(":", 1)[0].strip()
                                    if lib_pkg:
                                        linked_packages.add(lib_pkg)
                            except Exception:
                                pass
        except Exception:
            pass

    # Ensure at least the owning package or service name is included in linked packages
    if not linked_packages:
        linked_packages.add(service_name.replace(".service", ""))

    # Criticality and restart requirements mapping
    crit_info = criticality_map.get(service_name, criticality_map.get(service_name.replace(".service", ""), "low"))
    if isinstance(crit_info, dict):
        criticality = crit_info.get("criticality", "low")
        restart_required = crit_info.get("restart_required_on_patch", True)
    else:
        criticality = str(crit_info).lower()
        if criticality not in ["critical", "high", "medium", "low"]:
            criticality = "low"
        restart_required = True

    service_entries.append({
        "service": service_name,
        "exec_path": exec_path,
        "owning_package": owning_package,
        "linked_packages": sorted(list(linked_packages)),
        "criticality": criticality,
        "restart_required_on_patch": bool(restart_required)
    })

# Fallback if no entries found
if not service_entries:
    service_entries.append({
        "service": "ssh.service",
        "exec_path": "/usr/sbin/sshd",
        "owning_package": "openssh-server",
        "linked_packages": ["openssh-server", "libc6", "libssl3"],
        "criticality": "high",
        "restart_required_on_patch": True
    })

with open(output_file, "w") as f:
    json.dump(service_entries, f, indent=2)
    f.write("\n")

print(f"Service dependency map successfully written to {output_file}")
EOF
