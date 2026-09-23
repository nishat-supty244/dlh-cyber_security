
#!/bin/bash

# ================================================================
# 7-detection_rules.sh
# MedDefense - Detection Engineering
#
# Purpose:
# Turn findings from Tasks 1-6 into operational detection logic.
# The script uses TShark to test the rules against the PCAP evidence.
# ================================================================

set -u

# ----------------------------------------------------------------
# Configuration
# ----------------------------------------------------------------

C2_PCAP="c2_beaconing.pcap"
PHISHING_PCAP="phishing_click.pcap"
FULL_PCAP="full_timeline.pcap"
LATERAL_PCAP="lateral_movement.pcap"
DNS_PCAP="dns_exfil.pcap"

C2_IP="91.234.99.107"
VPN_SOURCE="154.118.42.89"
VPN_ENDPOINT="10.10.0.1"
CLINICAL_HOST="10.10.2.15"
BILLING_SERVER="10.10.1.10"
PHISHING_DOMAIN="meddefense-portal.com"
EXFIL_DOMAIN="data-sync.meddefense-portal.com"

# ----------------------------------------------------------------
# Basic checks
# ----------------------------------------------------------------

echo "================================================================"
echo "   DETECTION ENGINEERING PLAN"
echo "================================================================"
echo

if ! command -v tshark >/dev/null 2>&1; then
    echo "[ERROR] tshark is not installed."
    echo "Install it with:"
    echo "  sudo apt install tshark"
    exit 1
fi

for file in "$C2_PCAP" "$PHISHING_PCAP" "$FULL_PCAP" \
            "$LATERAL_PCAP" "$DNS_PCAP"; do

    if [ ! -f "$file" ]; then
        echo "[ERROR] Missing file: $file"
        exit 1
    fi
done

echo "[+] TShark found."
echo "[+] All required PCAP files found."
echo

# ----------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------

count_lines()
{
    if [ -f "$1" ]; then
        grep -c . "$1" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

# ================================================================
# DETECTION 1
# C2 BEACONING
# ================================================================

echo "================================================================"
echo "[*] Detection 1: C2 Beaconing"
echo "================================================================"

echo "Type: Frequency-based behavioral detection"
echo

echo "Logic:"
echo "  1. Group connections by source IP and destination IP."
echo "  2. Count connections during a 3600 second window."
echo "  3. If count > 10, calculate connection intervals."
echo "  4. Calculate interval mean and standard deviation."
echo "  5. Alert when:"
echo "       connection_count > 10"
echo "       AND interval_stddev < interval_mean * 0.15"
echo

echo "Data source:"
echo "  PCAP-derived session logs, Zeek conn.log,"
echo "  NetFlow or proxy logs"
echo

echo "Test scenario:"
echo "  10.10.2.15 -> 91.234.99.107"
echo "  approximately every 300 seconds"
echo "  for approximately 24 sessions."
echo

echo "[+] Running C2 beaconing test..."

C2_TIMES=$(tshark -r "$C2_PCAP" \
    -Y "ip.dst == $C2_IP" \
    -T fields \
    -e frame.time_epoch 2>/dev/null)

C2_COUNT=$(printf "%s\n" "$C2_TIMES" | grep -c '^[0-9]')

if [ "$C2_COUNT" -gt 10 ]; then

    echo "    Connections observed: $C2_COUNT"

    INTERVALS=$(printf "%s\n" "$C2_TIMES" | awk '
        NR > 1 {
            diff = $1 - previous
            if (diff > 0)
                print diff
        }
        {
            previous = $1
        }
    ')

    STATS=$(printf "%s\n" "$INTERVALS" | awk '
        {
            sum += $1
            sumsq += ($1 * $1)
            n++
        }

        END {
            if (n == 0) {
                print "0 0"
                exit
            }

            mean = sum / n
            variance = (sumsq / n) - (mean * mean)

            if (variance < 0)
                variance = 0

            stddev = sqrt(variance)

            printf "%.2f %.2f\n", mean, stddev
        }
    ')

    MEAN=$(echo "$STATS" | awk '{print $1}')
    STDDEV=$(echo "$STATS" | awk '{print $2}')

    echo "    Interval mean: $MEAN seconds"
    echo "    Interval standard deviation: $STDDEV seconds"

    THRESHOLD=$(awk -v mean="$MEAN" 'BEGIN {print mean * 0.15}')

    if awk -v std="$STDDEV" -v threshold="$THRESHOLD" \
        'BEGIN {exit !(std < threshold)}'; then

        echo
        echo "    [ALERT] Possible C2 beaconing detected."
        echo "    Reason:"
        echo "      More than 10 connections observed."
        echo "      Connection timing is relatively regular."

    else

        echo
        echo "    [INFO] Frequent connections detected,"
        echo "           but interval regularity threshold was not met."

    fi

else

    echo "    [INFO] Fewer than 11 matching connections observed."

fi

echo
echo "Would detect:"
echo "  Phase 3 - C2 beaconing in c2_beaconing.pcap"
echo

echo "False positives:"
echo "  Software update clients"
echo "  Monitoring agents"
echo "  Backup tools"
echo "  Scheduled applications"
echo "  Baseline comparison is required."
echo


# ================================================================
# DETECTION 2
# DNS QUERY LENGTH ANOMALY
# ================================================================

echo "================================================================"
echo "[*] Detection 2: DNS Query Length Anomaly"
echo "================================================================"

echo "Logic:"
echo "  If the left-most DNS label exceeds 40 characters,"
echo "  flag the query as suspicious."
echo
echo "  Higher confidence:"
echo "    label length > 40"
echo "    AND query type == TXT"
echo "    AND repeated queries target the same base domain"
echo

echo "Why encoded labels matter:"
echo "  DNS labels can be used to carry encoded information."
echo "  Long, changing labels may therefore indicate DNS tunneling."
echo

echo "Data source:"
echo "  DNS logs, Zeek dns.log, recursive DNS logs or PCAP"
echo

echo "[+] Running DNS label-length test..."

LONG_DNS=$(tshark -r "$DNS_PCAP" \
    -Y "dns.qry.name" \
    -T fields \
    -e frame.time_epoch \
    -e ip.src \
    -e dns.qry.name \
    -e dns.qry.type 2>/dev/null |
awk -F '\t' '
{
    name=$3

    n=split(name, parts, ".")

    if (length(parts[1]) > 40)
        print $1 "\t" $2 "\t" parts[1] "\t" length(parts[1]) "\t" $4
}')

LONG_COUNT=$(printf "%s\n" "$LONG_DNS" | grep -c .)

echo "    Long-label queries detected: $LONG_COUNT"

if [ "$LONG_COUNT" -gt 0 ]; then
    echo
    echo "    [ALERT] DNS label length anomaly detected."
    echo
    echo "    Examples:"
    printf "%s\n" "$LONG_DNS" | head -5
else
    echo
    echo "    [INFO] No DNS labels longer than 40 characters found."
fi

echo
echo "Would detect:"
echo "  Suspicious long DNS labels associated with Phase 7"
echo "  DNS exfiltration."
echo

echo "False positives:"
echo "  CDN identifiers"
echo "  Cloud services"
echo "  Tracking systems"
echo "  Long legitimate hostnames"
echo


# ================================================================
# DETECTION 3
# VPN GEO-ANOMALY
# ================================================================

echo "================================================================"
echo "[*] Detection 3: VPN Geo-Anomaly"
echo "================================================================"

echo "Logic:"
echo "  If VPN source country or ASN is not expected"
echo "  AND the account has no normal history from that geography,"
echo "  alert on suspicious VPN login."
echo

echo "Required data:"
echo "  VPN authentication logs"
echo "  Source IP"
echo "  Username/account"
echo "  GeoIP database"
echo "  ASN information"
echo "  User login history"
echo "  Approved country/ASN list"
echo

echo "[+] Searching for VPN source activity..."

VPN_MATCHES=$(tshark -r "$FULL_PCAP" \
    -Y "ip.src == $VPN_SOURCE && ip.dst == $VPN_ENDPOINT && tcp.dstport == 443" \
    -T fields \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport 2>/dev/null)

VPN_COUNT=$(printf "%s\n" "$VPN_MATCHES" | grep -c .)

echo "    Matching VPN traffic packets: $VPN_COUNT"

if [ "$VPN_COUNT" -gt 0 ]; then

    echo
    echo "    [ALERT] VPN connection from observed external source."
    echo "    Source IP: $VPN_SOURCE"
    echo "    VPN endpoint: $VPN_ENDPOINT:443"
    echo
    echo "    NOTE:"
    echo "    Geo/ASN anomaly cannot be proven from the PCAP alone."
    echo "    A GeoIP/ASN lookup and organization baseline are required."

else

    echo "    [INFO] No matching VPN traffic found."
fi

echo
echo "Would detect:"
echo "  Phase 4 - VPN pivot"
echo "  Observed source: 154.118.42.89"
echo

echo "False positives:"
echo "  Employees travelling"
echo "  Mobile networks"
echo "  Corporate VPNs"
echo "  Approved third-party access"
echo


# ================================================================
# DETECTION 4
# CROSS-ROLE RDP
# ================================================================

echo "================================================================"
echo "[*] Detection 4: Cross-Role RDP"
echo "================================================================"

echo "Logic:"
echo "  If a clinical/non-IT account initiates RDP"
echo "  to a server subnet:"
echo "      ALERT: Possible lateral movement"
echo

echo "Packet metadata:"
echo "  Source IP"
echo "  Destination IP"
echo "  TCP destination port 3389"
echo

echo "Authentication-log enrichment:"
echo "  Username"
echo "  Account role"
echo "  Windows logon event"
echo

echo "[+] Running RDP test..."

RDP_MATCHES=$(tshark -r "$LATERAL_PCAP" \
    -Y "ip.src == $CLINICAL_HOST && ip.dst == $BILLING_SERVER && tcp.dstport == 3389" \
    -T fields \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport 2>/dev/null)

RDP_COUNT=$(printf "%s\n" "$RDP_MATCHES" | grep -c .)

echo "    RDP packets matching clinical -> billing: $RDP_COUNT"

if [ "$RDP_COUNT" -gt 0 ]; then

    echo
    echo "    [ALERT] Cross-role RDP behavior detected."
    echo
    echo "    Source: $CLINICAL_HOST"
    echo "    Destination: $BILLING_SERVER"
    echo "    Protocol: RDP"
    echo "    Port: 3389"

else

    echo
    echo "    [INFO] No matching RDP traffic found."
fi

echo
echo "Would detect:"
echo "  Phase 5 - RDP lateral movement"
echo

echo "False positives:"
echo "  Help-desk support"
echo "  IT administrators"
echo "  Emergency troubleshooting"
echo "  Approved clinical administration"
echo


# ================================================================
# DETECTION 5
# DNS TXT TUNNELING
# ================================================================

echo "================================================================"
echo "[*] Detection 5: DNS Tunneling TXT Query Detection"
echo "================================================================"

echo "Logic:"
echo "  Count TXT queries per source IP and base domain"
echo "  within a 120 second window."
echo
echo "  Alert when:"
echo "      TXT query count > 10"
echo "      AND encoded/long labels are present"
echo

echo "Data source:"
echo "  DNS logs, Zeek dns.log or PCAP"
echo

echo "[+] Running DNS TXT frequency test..."

TXT_DATA=$(tshark -r "$DNS_PCAP" \
    -Y "dns.qry.type == 16" \
    -T fields \
    -e frame.time_epoch \
    -e ip.src \
    -e dns.qry.name 2>/dev/null |
sort -n)

TXT_COUNT=$(printf "%s\n" "$TXT_DATA" | grep -c .)

echo "    TXT queries observed: $TXT_COUNT"

if [ "$TXT_COUNT" -gt 0 ]; then

    echo
    echo "    Calculating 120-second query windows..."

    TXT_ALERTS=$(printf "%s\n" "$TXT_DATA" |
    awk -F '\t' '
    {
        time=$1
        src=$2
        domain=$3

        key=src "|" domain

        if (!(key in first_time)) {
            first_time[key]=time
            count[key]=0
        }

        if (time - first_time[key] <= 120) {
            count[key]++
        }
        else {
            if (count[key] > 10) {
                print key "\t" count[key]
            }

            first_time[key]=time
            count[key]=1
        }
    }

    END {
        for (key in count) {
            if (count[key] > 10)
                print key "\t" count[key]
        }
    }')

    TXT_ALERT_COUNT=$(printf "%s\n" "$TXT_ALERTS" | grep -c .)

    if [ "$TXT_ALERT_COUNT" -gt 0 ]; then

        echo
        echo "    [ALERT] High-frequency TXT query pattern detected."
        echo
        echo "    Source/domain/count:"
        printf "%s\n" "$TXT_ALERTS" | head -10

    else

        echo
        echo "    [INFO] No source/domain exceeded 10 TXT queries"
        echo "           within a 120-second window."
    fi

else

    echo
    echo "    [INFO] No TXT queries found."
fi

echo
echo "Would detect:"
echo "  Phase 7 - DNS tunneling / data exfiltration"
echo

echo "False positives:"
echo "  Legitimate TXT-based applications"
echo "  Security verification systems"
echo "  Cloud services"
echo "  Email/security infrastructure"
echo


# ================================================================
# DETECTION 6
# TLS TO CAMPAIGN LOOKALIKE DOMAIN
# ================================================================

echo "================================================================"
echo "[*] Detection 6: TLS to Campaign Lookalike Domain"
echo "================================================================"

echo "Logic:"
echo "  Extract TLS SNI values."
echo "  Compare them against a local phishing IOC list"
echo "  or first-seen domain table."
echo
echo "  If SNI matches a known campaign IOC:"
echo "      ALERT"
echo

echo "No live domain-age feed is required."
echo "The SOC can maintain:"
echo "  - phishing IOC list"
echo "  - first-seen domain table"
echo "  - campaign domain list"
echo

echo "IOC used for this exercise:"
echo "  $PHISHING_DOMAIN"
echo

echo "[+] Searching TLS SNI..."

SNI_MATCHES=$(tshark -r "$PHISHING_PCAP" \
    -Y "tls.handshake.extensions_server_name" \
    -T fields \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tls.handshake.extensions_server_name 2>/dev/null |
grep -F "$PHISHING_DOMAIN")

SNI_COUNT=$(printf "%s\n" "$SNI_MATCHES" | grep -c .)

echo "    Matching TLS SNI records: $SNI_COUNT"

if [ "$SNI_COUNT" -gt 0 ]; then

    echo
    echo "    [ALERT] TLS connection to campaign lookalike domain."
    echo
    echo "    Evidence:"
    printf "%s\n" "$SNI_MATCHES" | head -10

else

    echo
    echo "    [INFO] Campaign IOC was not found in TLS SNI."
    echo "    This can happen when:"
    echo "      - TLS SNI is unavailable"
    echo "      - the traffic is encrypted differently"
    echo "      - the PCAP does not contain the relevant handshake"
fi

echo
echo "Would detect:"
echo "  Phase 2 - phishing click / credential harvesting"
echo

echo "False positives:"
echo "  Newly registered legitimate domains"
echo "  Security testing domains"
echo "  Legitimate domains resembling known brands"
echo


# ================================================================
# DETECTION COVERAGE UPDATE
# ================================================================

echo
echo "================================================================"
echo "=== DETECTION COVERAGE UPDATE ==="
echo "================================================================"
echo

echo "Before packet analysis:"
echo "  Campaign visible mainly through email IOCs."
echo

echo "After packet analysis:"
echo "  Detection logic now covers:"
echo "    - Phishing-click TLS activity"
echo "    - C2 beaconing"
echo "    - VPN geo/ASN anomalies"
echo "    - Cross-role RDP"
echo "    - DNS query length anomalies"
echo "    - DNS TXT tunneling"
echo

echo "Remaining gaps:"
echo "  - Endpoint execution confirmation requires endpoint telemetry."
echo "  - Exact credential content cannot be recovered from encrypted TLS."
echo "  - VPN geography requires GeoIP/ASN enrichment."
echo "  - User role requires identity/HR/AD information."
echo "  - SIEM alerts cannot be confirmed from PCAP alone."
echo

echo "================================================================"
echo "   DETECTION ENGINEERING COMPLETE"
echo "================================================================"
