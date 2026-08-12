#!/bin/bash

set -euo pipefail

OUTPUT_FILE="pre_patch_state.json"
TEMP_JSON=$(mktemp)

HOSTNAME_VAL=$(hostname)
TIMESTAMP_VAL=$(date +%s)
KERNEL_VAL=$(uname -r)

# Check reboot required indicator
REBOOT_REQ="false"
if [ -f "/var/run/reboot-required" ]; then
    REBOOT_REQ="true"
fi

# 1. Record package versions for every installed package via dpkg-query
echo "Collecting packages..." >&2
PACKAGES_JSON="{}"
while read -r pkg ver status; do
    if [[ "$status" == *"installed"* ]]; then
        # Safely add to JSON via jq
        PACKAGES_JSON=$(jq -n --argjson obj "$PACKAGES_JSON" --arg p "$pkg" --arg v "$ver" '$obj + {($p): $v}')
    fi
done < <(dpkg-query -W -f='${binary:Package} ${Version} ${Status}\n' 2>/dev/null || true)

# 2. Record service state for active systemd services
echo "Collecting services..." >&2
SERVICES_JSON="{}"
while read -r svc _; do
    [ -z "$svc" ] && continue
    # ActiveState, SubState, MainPID via systemctl show
    ACTIVE_STATE=$(systemctl show -p ActiveState --value "$svc" 2>/dev/null || echo "unknown")
    SUB_STATE=$(systemctl show -p SubState --value "$svc" 2>/dev/null || echo "unknown")
    MAIN_PID=$(systemctl show -p MainPID --value "$svc" 2>/dev/null || echo "0")

    SVC_INFO=$(jq -n --arg act "$ACTIVE_STATE" --arg sub "$SUB_STATE" --arg pid "$MAIN_PID" \
        '{ActiveState: $act, SubState: $sub, MainPID: $pid}')
    
    SERVICES_JSON=$(jq -n --argjson obj "$SERVICES_JSON" --arg s "$svc" --argjson val "$SVC_INFO" \
        '$obj + {($s): $val}')
done < <(systemctl list-units --type=service --state=active --no-legend 2>/dev/null || true)

# 3. Record listening sockets via ss -tulnp
echo "Collecting listening sockets..." >&2
LISTENING_JSON="[]"
while read -r line; do
    if [ -n "$line" ]; then
        LISTENING_JSON=$(jq -n --argjson arr "$LISTENING_JSON" --arg l "$line" '$arr + [$l]')
    fi
done < <(ss -tulnp 2>/dev/null || true)

# 4. Record SHA-256 hashes of config files under /etc tracked by packages
echo "Collecting configuration file hashes..." >&2
CONFFILES_JSON="{}"
# Find files under /etc owned/tracked by packages using dpkg -S /etc/
while read -r line; do
    if [[ "$line" == *":"* ]]; then
        fpath=$(echo "$line" | cut -d':' -f2 | tr -d ' ')
        if [ -f "$fpath" ] && [ ! -L "$fpath" ]; then
            if [ -r "$fpath" ]; then
                f_hash=$(sha256sum "$fpath" 2>/dev/null | awk '{print $1}')
                if [ -n "$f_hash" ]; then
                    CONFFILES_JSON=$(jq -n --argjson obj "$CONFFILES_JSON" --arg fp "$fpath" --arg fh "$f_hash" \
                        '$obj + {($fp): $fh}')
                fi
            fi
        fi
    fi
done < <(dpkg -S /etc/ 2>/dev/null || true)

# 5. Assemble final structure using jq and output to pre_patch_state.json
jq -n \
    --argjson timestamp "$TIMESTAMP_VAL" \
    --arg hostname "$HOSTNAME_VAL" \
    --arg kernel "$KERNEL_VAL" \
    --argjson packages "$PACKAGES_JSON" \
    --argjson services "$SERVICES_JSON" \
    --argjson listening "$LISTENING_JSON" \
    --argjson conffile_hashes "$CONFFILES_JSON" \
    --argjson reboot_required "$REBOOT_REQ" \
    '{
        timestamp: $timestamp,
        hostname: $hostname,
        kernel: $kernel,
        packages: $packages,
        services: $services,
        listening: $listening,
        conffile_hashes: $conffile_hashes,
        reboot_required: ($reboot_required == "true")
    }' > "$OUTPUT_FILE"

rm -f "$TEMP_JSON"

# Output summary to stdout
FILE_SIZE_KB=$(du -k "$OUTPUT_FILE" | cut -f1)
PKG_COUNT=$(jq '.packages | length' "$OUTPUT_FILE")
SVC_COUNT=$(jq '.services | length' "$OUTPUT_FILE")

echo "Snapshot: $OUTPUT_FILE"
echo "Size: ${FILE_SIZE_KB} KB"
echo "Kernel: $KERNEL_VAL"
echo "Reboot required: $REBOOT_REQ"
