#!/bin/bash
# 1-attack_surface.sh - Classifies listening sockets from network_baseline.json into an attack surface report.

set -uo pipefail

# Ensure script is run as root for complete dpkg/socket inspection
if [[ $EUID -ne 0 ]]; then
    echo "[-] This script must be run with root privileges (sudo)." >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME_VAL=$(hostname)

# Check if network_baseline.json exists
if [[ ! -f "network_baseline.json" ]]; then
    echo "[-] network_baseline.json not found. Run 0-network_baseline.sh first." >&2
    exit 1
fi

# Export variables for safe Python processing
export TIMESTAMP
export HOSTNAME_VAL

python3 -c '
import json
import os
import subprocess
import re

timestamp = os.environ.get("TIMESTAMP", "")
hostname = os.environ.get("HOSTNAME_VAL", "")

try:
    with open("network_baseline.json", "r") as f:
        baseline = json.load(f)
except Exception as e:
    print(f"[-] Error reading network_baseline.json: {e}")
    baseline = {}

listeners = baseline.get("listening_sockets", [])

# Built-in catalog and criticality mappings per instructions
service_catalog = {
    3306: "database",
    5432: "database",
    80: "web",
    443: "web",
    22: "ssh",
    53: "dns",
    123: "ntp",
    111: "rpc",
    2049: "nfs",
    445: "smb",
    139: "smb",
    631: "print",
    161: "snmpv2c",
    23: "telnet",
    21: "ftp",
    513: "rlogin"
}

service_criticality = {
    "database": "critical",
    "web": "high",
    "ssh": "critical",
    "dns": "critical",
    "ntp": "medium",
    "rpc": "high",
    "nfs": "high",
    "smb": "high",
    "print": "low",
    "snmpv2c": "medium",
    "telnet": "critical",
    "ftp": "high",
    "rlogin": "critical",
    "unknown": "low"
}

sockets_output = []
flagged_counts = {"critical": 0, "high": 0, "medium": 0, "low": 0, "unknown_function": 0}

for listener in listeners:
    local_addr = listener.get("local_address", "")
    # Parse port and bind address
    bind_addr = ""
    port = 0
    if ":" in local_addr:
        # Format can be IP:PORT or [IPv6]:PORT
        if local_addr.startswith("["):
            parts = local_addr.rsplit("]:", 1)
            bind_addr = parts[0].lstrip("[")
            port = int(parts[1]) if len(parts) > 1 and parts[1].isdigit() else 0
        else:
            parts = local_addr.rsplit(":", 1)
            bind_addr = parts[0]
            port = int(parts[1]) if len(parts) > 1 and parts[1].isdigit() else 0

    extra = listener.pids if "pids" in listener else listener.get("extra", "")
    
    # Extract process name/PID if available
    process_name = "unknown"
    pid = ""
    
    # ss output extra typically contains users:(( "process_name",pid=123,... ))
    pid_match = re.search(r"pid=(\d+)", extra)
    if pid_match:
        pid = pid_match.group(1)
        try:
            with open(f"/proc/{pid}/comm", "r") as pf:
                process_name = pf.read().strip()
        except Exception:
            pass
            
    if process_name == "unknown":
        name_match = re.search(r"\"([^\"]+)\"", extra)
        if name_match:
            process_name = name_match.group(1)

    # Resolve package via dpkg -S using the binary path if possible
    package = "unknown"
    if pid:
        try:
            exe_path = os.readlink(f"/proc/{pid}/exe")
            dpkg_res = subprocess.run(["dpkg", "-S", exe_path], capture_output=True, text=True)
            if dpkg_res.returncode == 0:
                pkg_line = dpkg_res.stdout.strip()
                package = pkg_line.split(":")[0]
        except Exception:
            pass

    # Function & Criticality mapping
    func = service_catalog.get(port, "unknown")
    criticality = service_criticality.get(func, "low")

    if func == "unknown":
        flagged_counts["unknown_function"] += 1

    # Exposure flags evaluation
    exposure_flags = []
    
    # Check for 0.0.0.0 or :: binding on sensitive services
    is_universal_bind = bind_addr in ["0.0.0.0", "::", "*"]
    if is_universal_bind and func in ["database", "rpc"]:
        exposure_flags.append("bound_0.0.0.0")
        exposure_flags.append(f"{func}_exposed")
    elif is_universal_bind and func == "unknown":
        # General wide open check
        exposure_flags.append("bound_0.0.0.0")

    # Insecure protocols check
    insecure_funcs = ["telnet", "ftp", "snmpv1", "snmpv2c", "rlogin", "nfs"]
    if func in insecure_funcs:
        if func in ["snmpv1", "snmpv2c"]:
            exposure_flags.append(f"insecure_protocol_{func}")
        else:
            exposure_flags.append(f"insecure_protocol_{func}")

    # Track severity counts if flagged
    if exposure_flags:
        if criticality in flagged_counts:
            flagged_counts[criticality] += 1
        else:
            flagged_counts["low"] += 1

    sockets_output.append({
        "proto": listener.get("netid", "tcp"),
        "port": port,
        "bind_addr": bind_addr,
        "process": process_name,
        "package": package,
        "function": func,
        "criticality": criticality,
        "exposure_flags": exposure_flags
    })

report = {
    "generated_at": timestamp,
    "hostname": hostname,
    "sockets": sockets_output,
    "summary": flagged_counts
}

with open("attack_surface.json", "w") as f:
    json.dump(report, f, indent=2)
    f.write("\n")

print("[+] Attack surface report successfully written to attack_surface.json")
'
