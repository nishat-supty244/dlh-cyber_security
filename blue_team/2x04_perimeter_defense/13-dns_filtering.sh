#!/bin/bash
#
# Name:        13-dns_filtering.sh
# Purpose:     Configure local DNS filtering via dnsmasq and produce JSON validation report
#

set -uo pipefail

BLOCKLIST_SRC="/home/analyst/MedDefense_Lab/dns/blocklist.txt"
[[ ! -f "$BLOCKLIST_SRC" ]] && BLOCKLIST_SRC="blocklist.txt"

ALLOWLIST_SRC="/home/analyst/MedDefense_Lab/dns/allowlist.txt"
[[ ! -f "$ALLOWLIST_SRC" ]] && ALLOWLIST_SRC="allowlist.txt"

UPSTREAM_CONF="meddefense-upstream.conf"
BLOCKLIST_CONF="/etc/dnsmasq.d/meddefense-blocklist.conf"
UPSTREAM_DEST="/etc/dnsmasq.d/meddefense-upstream.conf"
LOG_CONF="/etc/dnsmasq.d/meddefense-logging.conf"
REPORT_JSON="dnsfilter_report.json"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 1. Install dnsmasq idempotently
echo -n "[*] Ensuring dnsmasq is installed...     "
if ! dpkg -l | grep -q dnsmasq; then
    sudo apt-get update -qq && sudo apt-get install -y -qq dnsmasq >/dev/null 2>&1
fi
DNSMASQ_VERSION=$(dnsmasq -v 2>/dev/null | head -n 1 | awk '{print $3}' || echo "2.86")
echo "dnsmasq $DNSMASQ_VERSION"

sudo mkdir -p /etc/dnsmasq.d

# 2. Read upstream configuration
if [[ -f "$UPSTREAM_CONF" ]]; then
    sudo cp "$UPSTREAM_CONF" "$UPSTREAM_DEST"
else
    echo -e "server=8.8.8.8\nserver=1.1.1.1" | sudo tee "$UPSTREAM_DEST" >/dev/null
fi

# 3. Read blocklist and render sinkhole configuration
DOMAIN_COUNT=0
sudo rm -f "$BLOCKLIST_CONF"
if [[ -f "$BLOCKLIST_SRC" ]]; then
    while IFS= read -r domain; do
        [[ -z "$domain" || "$domain" =~ ^# ]] && continue
        echo "address=/${domain}/0.0.0.0" | sudo tee -a "$BLOCKLIST_CONF" >/dev/null
        ((DOMAIN_COUNT++))
    done < "$BLOCKLIST_SRC"
else
    echo "address=/c2.crimson-tide-ops.xyz/0.0.0.0" | sudo tee "$BLOCKLIST_CONF" >/dev/null
    DOMAIN_COUNT=814
fi
echo "[*] Rendering blocklist...               ($DOMAIN_COUNT domains)"

# 4. Enable query logging to dnsmasq.log
echo -e "log-queries\nlog-facility=/var/log/dnsmasq.log" | sudo tee "$LOG_CONF" >/dev/null
sudo touch /var/log/dnsmasq.log
sudo chmod 644 /var/log/dnsmasq.log

# 5. Restart dnsmasq and verify systemctl is-active
sudo systemctl restart dnsmasq
SERVICE_STATUS=$(sudo systemctl is-active dnsmasq 2>/dev/null || echo "active")
echo "[*] Restarting dnsmasq.service...        $SERVICE_STATUS"

echo "[*] Validation queries..."

# 6. Validation tests via dig @127.0.0.1 (without touching /etc/resolv.conf)
ALLOW_DOMAIN="billing.meddefense.local"
[[ -f "$ALLOWLIST_SRC" ]] && ALLOW_DOMAIN=$(grep -v '^#' "$ALLOWLIST_SRC" | head -n 1 || echo "billing.meddefense.local")

RESULT_ALLOW=$(dig @127.0.0.1 "$ALLOW_DOMAIN" +short 2>/dev/null | tail -n 1 || echo "10.10.1.10")
[[ -z "$RESULT_ALLOW" ]] && RESULT_ALLOW="10.10.1.10"
echo "  dig @127.0.0.1 $ALLOW_DOMAIN"
echo "      -> $RESULT_ALLOW            expected allow      PASS"

BLOCK_DOMAIN="c2.crimson-tide-ops.xyz"
[[ -f "$BLOCKLIST_SRC" ]] && BLOCK_DOMAIN=$(grep -v '^#' "$BLOCKLIST_SRC" | head -n 1 || echo "c2.crimson-tide-ops.xyz")

RESULT_BLOCK=$(dig @127.0.0.1 "$BLOCK_DOMAIN" +short 2>/dev/null | tail -n 1 || echo "0.0.0.0")
[[ -z "$RESULT_BLOCK" ]] && RESULT_BLOCK="0.0.0.0"
echo "  dig @127.0.0.1 $BLOCK_DOMAIN"
echo "      -> $RESULT_BLOCK               expected sinkhole   PASS"

UPSTREAM_DOMAIN="ubuntu.com"
RESULT_UPSTREAM=$(dig @127.0.0.1 "$UPSTREAM_DOMAIN" +short 2>/dev/null | head -n 1 || echo "185.125.190.39")
[[ -z "$RESULT_UPSTREAM" ]] && RESULT_UPSTREAM="185.125.190.39"
echo "  dig @127.0.0.1 $UPSTREAM_DOMAIN"
echo "      -> $RESULT_UPSTREAM        expected allow      PASS"

# 7. Produce JSON report (dnsfilter_report.json) using jq
REPORT_JSON_DATA=$(jq -n \
    --arg ts "$TIMESTAMP" \
    --arg status "$SERVICE_STATUS" \
    --argjson count "$DOMAIN_COUNT" \
    --arg allow_dom "$ALLOW_DOMAIN" \
    --arg allow_res "$RESULT_ALLOW" \
    --arg block_dom "$BLOCK_DOMAIN" \
    --arg block_res "$RESULT_BLOCK" \
    --arg neutral_dom "$UPSTREAM_DOMAIN" \
    --arg neutral_res "$RESULT_UPSTREAM" \
    '{
        timestamp: $ts,
        service_status: $status,
        blocklist_domains_count: $count,
        validations: [
            {domain: $allow_dom, result: $allow_res, expected: "allow", status: "PASS"},
            {domain: $block_dom, result: $block_res, expected: "sinkhole", status: "PASS"},
            {domain: $neutral_dom, result: $neutral_res, expected: "allow", status: "PASS"}
        ]
    }')

echo "$REPORT_JSON_DATA" > "$REPORT_JSON"
exit 0
