#!/bin/bash
# 0-network_baseline.sh - Captures the local network view into a structured JSON baseline.

set -euo pipefail

# Ensure script is run as root for complete socket/process ownership visibility
if [[ $EUID -ne 0 ]]; then
    echo "[-] This script must be run with root privileges (sudo)." >&2
    exit 1
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME_VAL=$(hostname)

# 1. Interfaces
if command -v ip &>/dev/null; then
    INTERFACES=$(ip -j addr show)
else
    INTERFACES="[]"
fi

# 2. Routes
if command -v ip &>/dev/null; then
    ROUTES=$(ip -j route show)
else
    ROUTES="[]"
fi

# 3. Neighbors (ARP)
if command -v ip &>/dev/null; then
    NEIGHBORS=$(ip -j neigh show)
else
    NEIGHBORS="[]"
fi

# 4. Listeners (TCP/UDP)
LISTENING_SOCKETS=$(ss -tulnpH 2>/dev/null || true)

# 5. Established connections
ESTABLISHED_CONNECTIONS=$(ss -tnpH state established 2>/dev/null || true)

# 6. DNS Resolvers
RESOLV_CONF_CONTENT=""
if [[ -f /etc/resolv.conf ]]; then
    RESOLV_CONF_CONTENT=$(cat /etc/resolv.conf)
fi

RESOLVED_STATUS=""
if command -v resolvectl &>/dev/null; then
    RESOLVED_STATUS=$(resolvectl status --no-pager 2>/dev/null || true)
fi

# Export variables securely to environment so Python can read them safely without syntax errors
export TIMESTAMP
export HOSTNAME_VAL
export INTERFACES
export ROUTES
export NEIGHBORS
export LISTENING_SOCKETS
export ESTABLISHED_CONNECTIONS
export RESOLV_CONF_CONTENT
export RESOLVED_STATUS

# Construct JSON output using Python3 safely via environment variables
python3 -c '
import json
import os

timestamp = os.environ.get("TIMESTAMP", "")
hostname = os.environ.get("HOSTNAME_VAL", "")

try:
    interfaces = json.loads(os.environ.get("INTERFACES", "[]"))
except Exception:
    interfaces = []

try:
    routes = json.loads(os.environ.get("ROUTES", "[]"))
except Exception:
    routes = []

try:
    neighbors = json.loads(os.environ.get("NEIGHBORS", "[]"))
except Exception:
    neighbors = []

listeners_raw = os.environ.get("LISTENING_SOCKETS", "")
established_raw = os.environ.get("ESTABLISHED_CONNECTIONS", "")

listeners_list = []
for line in listeners_raw.splitlines():
    if line.strip():
        parts = line.split()
        if len(parts) >= 5:
            listeners_list.append({
                "netid": parts[0],
                "state": parts[1],
                "recv-q": parts[2],
                "send-q": parts[3],
                "local_address": parts[4],
                "peer_address": parts[5] if len(parts) > 5 else "",
                "extra": " ".join(parts[6:]) if len(parts) > 6 else ""
            })

established_list = []
for line in established_raw.splitlines():
    if line.strip():
        parts = line.split()
        if len(parts) >= 5:
            established_list.append({
                "netid": parts[0],
                "state": parts[1],
                "local_address": parts[4] if len(parts) > 4 else "",
                "peer_address": parts[5] if len(parts) > 5 else "",
                "extra": " ".join(parts[6:]) if len(parts) > 6 else ""
            })

up_interfaces = []
for iface in interfaces:
    if iface.get("operstate") == "UP" or "UP" in iface.get("flags", []):
        up_interfaces.append(iface.get("ifname"))

data = {
    "timestamp": timestamp,
    "hostname": hostname,
    "up_interfaces": up_interfaces,
    "listeners": len(listeners_list),
    "interfaces": interfaces,
    "routes": routes,
    "neighbors": neighbors,
    "listening_sockets": listeners_list,
    "established_connections": established_list,
    "dns_resolvers": {
        "resolv_conf": os.environ.get("RESOLV_CONF_CONTENT", ""),
        "resolvectl_status": os.environ.get("RESOLVED_STATUS", "")
    }
}

with open("network_baseline.json", "w") as f:
    json.dump(data, f, indent=2)
    f.write("\n")
'

echo "[+] Network baseline successfully captured to network_baseline.json"
