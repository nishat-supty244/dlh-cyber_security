#!/bin/bash

set -euo pipefail

OUTPUT_FILE="pre_patch_state.json"

python3 - "$OUTPUT_FILE" << 'EOF'
import sys
import subprocess
import json
import os
import hashlib
import time
import socket
from pathlib import Path

output_file = sys.argv[1]

timestamp = int(time.time())
hostname = socket.gethostname()

# Record kernel release (uname -r)
kernel = ""
try:
    kernel = subprocess.run(["uname", "-r"], capture_output=True, text=True, check=True).stdout.strip()
except Exception:
    kernel = os.uname().release

# Record pending reboot indicator (/var/run/reboot-required presence)
reboot_required = os.path.exists("/var/run/reboot-required")

# Record package versions for every installed package via dpkg
packages = {}
try:
    dpkg_res = subprocess.run(["dpkg-query", "-W", "-f=${binary:Package}\t${Version}\t${Status}\n"], capture_output=True, text=True, check=True)
    for line in dpkg_res.stdout.splitlines():
        parts = line.split("\t")
        if len(parts) >= 3 and "installed" in parts[2]:
            packages[parts[0]] = parts[1]
except Exception:
    pass

# Record service state for every active systemd service: ActiveState, SubState, MainPID
services = {}
try:
    sys_res = subprocess.run(["systemctl", "list-units", "--type=service", "--state=active", "--no-legend"], capture_output=True, text=True)
    for line in sys_res.stdout.splitlines():
        parts = line.strip().split()
        if not parts:
            continue
        svc_name = parts[0]
        show_res = subprocess.run(["systemctl", "show", svc_name, "-p", "ActiveState,SubState,MainPID", "--no-ambiguous"], capture_output=True, text=True)
        
        state_info = {"ActiveState": "unknown", "SubState": "unknown", "MainPID": "0"}
        for sline in show_res.stdout.splitlines():
            if "=" in sline:
                k, v = sline.split("=", 1)
                state_info[k.strip()] = v.strip()
        services[svc_name] = state_info
except Exception:
    pass

# Record listening sockets via ss -tulnp
listening = []
try:
    ss_res = subprocess.run(["ss", "-tulnp"], capture_output=True, text=True)
    for line in ss_res.stdout.splitlines()[1:]:  # skip header
        listening.append(line.strip())
except Exception:
    pass

# Record SHA-256 hashes of every configuration file under /etc tracked by a package
conffile_hashes = {}
try:
    # Get list of files tracked by packages using dpkg -S /etc/ or query all packages via dpkg -L
    # A standard way via dpkg is querying all installed packages with dpkg -L
    pkgs_list = list(packages.keys())
    # To optimize, we can use dpkg-query to list conffiles or files in /etc
    # Or query dpkg database directly
    dpkg_list = subprocess.run(["dpkg", "-S", "/etc/"], capture_output=True, text=True)
    for line in dpkg_list.stdout.splitlines():
        if ":" in line:
            parts = line.split(":", 1)
            fpath = parts[1].strip()
            if os.path.isfile(fpath) and not os.path.islink(fpath):
                try:
                    hasher = hashlib.sha256()
                    with open(fpath, "rb") as cf:
                        while chunk := cf.read(8192):
                            hasher.update(chunk)
                    conffile_hashes[fpath] = hasher.hexdigest()
                except Exception:
                    pass
except Exception:
    pass

snapshot_data = {
    "timestamp": timestamp,
    "hostname": hostname,
    "kernel": kernel,
    "packages": packages,
    "services": services,
    "listening": listening,
    "conffile_hashes": conffile_hashes,
    "reboot_required": reboot_required
}

with open(output_file, "w") as f:
    json.dump(snapshot_data, f, indent=2)
    f.write("\n")

file_size_kb = round(os.path.getsize(output_file) / 1024)
print(f"Snapshot: {output_file}")
print(f"Size: {file_size_kb} KB")
print(f"Kernel: {kernel}")
print(f"Reboot required: {str(reboot_required).lower()}")
EOF
