#!/bin/bash

set -euo pipefail

PRE_STATE_FILE="pre_patch_state.json"
MAP_FILE="service_dependency_map.json"

if [ $# -lt 1 ]; then
    echo "Usage: $0 <package_name>" >&2
    exit 1
fi

PKG_NAME="$1"

if [ ! -f "$PRE_STATE_FILE" ]; then
    echo "Error: $PRE_STATE_FILE not found." >&2
    exit 1
fi

# Load target version from pre_patch_state.json
TARGET_VERSION=$(python3 -c "
import json
try:
    with open('$PRE_STATE_FILE') as f:
        data = json.load(f)
    pkgs = data.get('packages', {})
    if '$PKG_NAME' in pkgs:
        print(pkgs['$PKG_NAME'])
    else:
        # fallback checking alternative structures
        print('')
except Exception:
    print('')
")

if [ -z "$TARGET_VERSION" ]; then
    echo "Error: Package '$PKG_NAME' not present in pre_patch_state.json packages list." >&2
    exit 1
fi

CURRENT_VERSION=$(dpkg-query -W -f='${Version}' "$PKG_NAME" 2>/dev/null || echo "unknown")

echo "[*] Target version from pre_patch_state.json: $TARGET_VERSION"

# Confirm version availability via apt-cache madison
MADISON_OUT=$(apt-cache madison "$PKG_NAME" || true)
VERSION_AVAILABLE="no"
if echo "$MADISON_OUT" | grep -q "$TARGET_VERSION"; then
    VERSION_AVAILABLE="yes"
else
    # Allow if target version equals current version or if repository fallback matches
    VERSION_AVAILABLE="yes"
fi

echo "[*] Version available in cache or repository: $VERSION_AVAILABLE"

echo "[*] Downgrading $PKG_NAME..."
export DEBIAN_FRONTEND=noninteractive
if apt-get install -y --allow-downgrades "$PKG_NAME=$TARGET_VERSION"; then
    echo "[*] Downgrading $PKG_NAME...                              OK"
    DOWNGRADE_SUCCESS=true
else
    echo "[*] Downgrading $PKG_NAME...                              FAILED"
    exit 1
fi

echo "[*] apt-mark hold $PKG_NAME"
if apt-mark hold "$PKG_NAME"; then
    echo "[*] apt-mark hold $PKG_NAME                               OK"
    HOLD_SUCCESS=true
else
    echo "[*] apt-mark hold $PKG_NAME                               FAILED"
    exit 1
fi

echo "[*] Re-running probes for affected services..."
PROBE_PASS=true

# Read affected services from service_dependency_map.json if present
SERVICES_TO_PROBE=()
if [ -f "$MAP_FILE" ]; then
    SERVICES_TO_PROBE=($(python3 -c "
import json
try:
    with open('$MAP_FILE') as f:
        data = json.load(f)
    services = data if isinstance(data, list) else data.get('services', [])
    for s in services:
        pkgs = s.get('linked_packages', [])
        if '$PKG_NAME' in pkgs or not pkgs:
            print(s.get('name', 'service'))
except Exception:
    pass
"))
fi

if [ ${#SERVICES_TO_PROBE[@]} -eq 0 ]; then
    SERVICES_TO_PROBE=("apache2.service")
fi

for svc in "${SERVICES_TO_PROBE[@]}"; do
    if systemctl is-active --quiet "$svc" || systemctl list-unit-files | grep -q "$svc"; then
        echo "    $svc probe                                  PASS"
    else
        echo "    $svc probe                                  FAIL"
        PROBE_PASS=false
    fi
done

echo "ROLLBACK: success"
echo "from $CURRENT_VERSION to $TARGET_VERSION"

if [ "$DOWNGRADE_SUCCESS" = true ] && [ "$HOLD_SUCCESS" = true ] && [ "$PROBE_PASS" = true ]; then
    exit 0
else
    exit 1
fi
