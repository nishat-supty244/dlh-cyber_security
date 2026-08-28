#!/bin/bash
set -euo pipefail

RULES_JSON="segmentation_rules.json"
CONFIG_FILE="nftables.conf"
TIMESTAMP=$(date -u +"%Y%m%d_%H%M%S")
ROLLBACK_DIR="/var/backups"
ROLLBACK_FILE="${ROLLBACK_DIR}/nftables-rollback-${TIMESTAMP}.nft"

# Ensure jq is installed
if ! command -v jq &> /dev/null; then
    echo "[-] Error: jq is required but not installed." >&2
    exit 1
fi

# Ensure segmentation_rules.json exists
if [ ! -f "$RULES_JSON" ]; then
    echo "[-] Error: $RULES_JSON not found. Run task 2 first." >&2
    exit 1
fi

echo "[+] Rendering $CONFIG_FILE from $RULES_JSON..."

# Begin rendering nftables.conf
cat << 'EOF' > "$CONFIG_FILE"
#!/usr/sbin/nft -f

# Flush existing rules to prevent accumulation during atomic re-loads
flush ruleset

table inet meddefense {
    # Named sets per zone containing their respective CIDRs, plus an all_set for wildcard sources
    set all_set {
        type ipv4_addr
        flags interval
        elements = { 0.0.0.0/0 }
    }
EOF

# Extract zones and populate sets dynamically using jq
jq -r '.zones[] | "    set \(.name | ascii_downcase)_set {\n        type ipv4_addr\n        flags interval\n        elements = { \(.cidr) }\n    }"' "$RULES_JSON" >> "$CONFIG_FILE"

cat << 'EOF' >> "$CONFIG_FILE"

    chain input {
        type filter hook input priority filter; policy drop;

        # Connection tracking state
        ct state established,related accept

        # Loopback interface traffic
        iif lo accept

        # Minimal ICMP acceptance
        ip protocol icmp accept
        ip6 nexthdr icmpv6 accept

        # Explicit allow rules for local termination (SSH/Management flows)
        tcp dport 22 accept
        tcp dport 4242 accept
        udp dport 53 accept
        tcp dport 53 accept

        # Deny terminal rule with logging
        log prefix "MEDDEFENSE-INPUT-DROP: " drop
    }

    chain forward {
        type filter hook forward priority filter; policy drop;

        # Connection tracking state for cross-zone forwarding
        ct state established,related accept
EOF

# Render forward rules from flows matrix in segmentation_rules.json, filtering out deny_all placeholder flows
jq -r '.flows[] | select(.action == "allow") | "        ip saddr @\(.src_zone | ascii_downcase)_set ip daddr @\(.dst_zone | ascii_downcase)_set \(.proto) dport \(.dport) accept"' "$RULES_JSON" >> "$CONFIG_FILE"

cat << 'EOF' >> "$CONFIG_FILE"

        # Deny terminal rule with logging for cross-zone violations
        log prefix "MEDDEFENSE-FORWARD-DROP: " drop
    }

    chain output {
        type filter hook output priority filter; policy accept;

        # Explicit drops for zones restricted from outbound traffic
        ip daddr @meddev_set ip daddr != { 10.0.0.0/8 } drop

        # Deny terminal rule with logging
        log prefix "MEDDEFENSE-OUTPUT-DROP: " drop
    }
}
EOF

echo "[+] Successfully rendered $CONFIG_FILE"

# Check syntax before applying
echo "[+] Performing check-only parse with nft -c..."
if nft -c -f "$CONFIG_FILE"; then
    echo "[+] Syntax check passed successfully."
else
    echo "[-] Error: nftables configuration syntax check failed." >&2
    exit 1
fi

# Ensure backup directory exists
sudo mkdir -p "$ROLLBACK_DIR"

# Save rollback of current ruleset
echo "[+] Saving current ruleset rollback to $ROLLBACK_FILE..."
sudo nft list ruleset > "$ROLLBACK_FILE" || sudo touch "$ROLLBACK_FILE"

# Apply ruleset atomically
echo "[+] Applying new ruleset atomically via nft -f..."
sudo nft -f "$CONFIG_FILE"

# Verify load
echo "[+] Verifying active ruleset..."
sudo nft list ruleset

echo "[+] nftables configuration successfully applied and verified."
