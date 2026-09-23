#!/bin/bash
# MedDefense - Clinical Network Baseline Analysis
# Usage:
#   ./0-baseline_analysis.sh normal_baseline_clinical.pcap
#
# Purpose:
#   Build a reproducible baseline of normal clinical network traffic.

set -euo pipefail

PCAP_FILE="${1:-normal_baseline_clinical.pcap}"
OUTPUT_JSON="baseline_clinical.json"

# --------------------------------------------------
# 0. CHECKS
# --------------------------------------------------

if [ ! -f "$PCAP_FILE" ]; then
    echo "Error: PCAP file '$PCAP_FILE' not found."
    exit 1
fi

if ! command -v tshark >/dev/null 2>&1; then
    echo "Error: tshark is not installed."
    exit 1
fi

echo "=================================================="
echo "      MEDDEFENSE CLINICAL NETWORK BASELINE"
echo "=================================================="
echo "PCAP: $PCAP_FILE"
echo ""

# --------------------------------------------------
# 1. BASIC PCAP INFORMATION
# --------------------------------------------------

echo "=== PCAP INFORMATION ==="

START_TIME=$(tshark -r "$PCAP_FILE" -T fields \
    -e frame.time_epoch 2>/dev/null | head -n 1)

END_TIME=$(tshark -r "$PCAP_FILE" -T fields \
    -e frame.time_epoch 2>/dev/null | tail -n 1)

TOTAL_PACKETS=$(tshark -r "$PCAP_FILE" -T fields \
    -e frame.number 2>/dev/null | wc -l)

echo "Total packets: $TOTAL_PACKETS"
echo "Start epoch:   ${START_TIME:-N/A}"
echo "End epoch:     ${END_TIME:-N/A}"
echo ""

# --------------------------------------------------
# 2. PROTOCOL DISTRIBUTION
# --------------------------------------------------

echo "=== PROTOCOL DISTRIBUTION ==="

echo "[TShark filter]"
echo "  tcp / udp / icmp / everything else"
echo ""

TCP_COUNT=$(tshark -r "$PCAP_FILE" \
    -Y "tcp" -T fields -e frame.number 2>/dev/null | wc -l)

UDP_COUNT=$(tshark -r "$PCAP_FILE" \
    -Y "udp" -T fields -e frame.number 2>/dev/null | wc -l)

ICMP_COUNT=$(tshark -r "$PCAP_FILE" \
    -Y "icmp || icmpv6" -T fields -e frame.number 2>/dev/null | wc -l)

OTHER_COUNT=$((TOTAL_PACKETS - TCP_COUNT - UDP_COUNT - ICMP_COUNT))

pct() {
    awk -v n="$1" -v t="$TOTAL_PACKETS" \
        'BEGIN { if (t > 0) printf "%.1f", (n/t)*100; else print "0.0" }'
}

echo "TCP:   $(pct "$TCP_COUNT")%  ($TCP_COUNT packets)"
echo "UDP:   $(pct "$UDP_COUNT")%  ($UDP_COUNT packets)"
echo "ICMP:  $(pct "$ICMP_COUNT")%  ($ICMP_COUNT packets)"
echo "Other: $(pct "$OTHER_COUNT")%  ($OTHER_COUNT packets)"
echo ""

# --------------------------------------------------
# 3. APPLICATION BREAKDOWN
# --------------------------------------------------

echo "=== APPLICATION BREAKDOWN ==="
echo ""

count_filter() {
    tshark -r "$PCAP_FILE" -Y "$1" \
        -T fields -e frame.number 2>/dev/null | wc -l
}

HTTPS_COUNT=$(count_filter "tcp.port == 443")
HTTP_COUNT=$(count_filter "tcp.port == 80")
DNS_COUNT=$(count_filter "udp.port == 53 || tcp.port == 53")
KERBEROS_COUNT=$(count_filter "tcp.port == 88 || udp.port == 88")
LDAP_COUNT=$(count_filter "tcp.port == 389 || udp.port == 389")
SMB_COUNT=$(count_filter "tcp.port == 445")
NTP_COUNT=$(count_filter "udp.port == 123")
PRINT_COUNT=$(count_filter "tcp.port == 9100")

# Common endpoint/agent ports.
# These are only a heuristic because the exact agent depends on the environment.
AGENT_COUNT=$(count_filter \
    "tcp.port == 1514 || tcp.port == 1515 || tcp.port == 5044 || tcp.port == 2055")

KNOWN_APP=$((HTTPS_COUNT + HTTP_COUNT + DNS_COUNT + KERBEROS_COUNT + LDAP_COUNT + SMB_COUNT + NTP_COUNT + PRINT_COUNT + AGENT_COUNT))
APP_OTHER=$((TOTAL_PACKETS - KNOWN_APP))

app_pct() {
    awk -v n="$1" -v t="$TOTAL_PACKETS" \
        'BEGIN { if (t > 0) printf "%.1f", (n/t)*100; else print "0.0" }'
}

echo "HTTPS (443):       $(app_pct "$HTTPS_COUNT")%"
echo "HTTP (80):         $(app_pct "$HTTP_COUNT")%"
echo "DNS (53):          $(app_pct "$DNS_COUNT")%"
echo "Kerberos (88):     $(app_pct "$KERBEROS_COUNT")%"
echo "LDAP (389):        $(app_pct "$LDAP_COUNT")%"
echo "SMB (445):         $(app_pct "$SMB_COUNT")%"
echo "NTP (123):         $(app_pct "$NTP_COUNT")%"
echo "Printing (9100):   $(app_pct "$PRINT_COUNT")%"
echo "Agent/Telemetry:   $(app_pct "$AGENT_COUNT")%"
echo "Other:             $(app_pct "$APP_OTHER")%"
echo ""

# --------------------------------------------------
# 4. TOP 10 SOURCE IPS BY BYTES
# --------------------------------------------------

echo "=== TOP 10 SOURCE IPS ==="

echo "[TShark command]"
echo '  tshark -r PCAP -T fields -e ip.src -e frame.len'
echo ""

tshark -r "$PCAP_FILE" \
    -T fields \
    -e ip.src \
    -e frame.len 2>/dev/null |
awk -F '\t' '
    $1 != "" {
        bytes[$1] += $2
    }
    END {
        for (ip in bytes)
            print ip, bytes[ip]
    }
' |
sort -k2 -nr |
head -n 10 |
awk '
{
    mb=$2/1024/1024
    printf "%2d. %-16s %.2f MB\n", NR, $1, mb
}
'

echo ""

# --------------------------------------------------
# 5. TOP 10 DESTINATIONS BY CONNECTIONS
# --------------------------------------------------

echo "=== TOP 10 DESTINATION IPS ==="

echo "[TShark filter]"
echo "  tcp.flags.syn == 1 && tcp.flags.ack == 0"
echo ""

tshark -r "$PCAP_FILE" \
    -Y "tcp.flags.syn == 1 && tcp.flags.ack == 0" \
    -T fields \
    -e ip.dst 2>/dev/null |
sort |
uniq -c |
sort -nr |
head -n 10 |
awk '
{
    printf "%2d. %-16s %d connections\n", NR, $2, $1
}
'

echo ""

# --------------------------------------------------
# 6. DNS QUERY PROFILE
# --------------------------------------------------

echo "=== DNS QUERY PROFILE ==="

DNS_QUERY_COUNT=$(tshark -r "$PCAP_FILE" \
    -Y "dns.flags.response == 0 && dns.qry.name" \
    -T fields -e dns.qry.name 2>/dev/null | wc -l)

DURATION_MINUTES=$(awk -v s="$START_TIME" -v e="$END_TIME" \
    'BEGIN {
        d=(e-s)/60
        if (d < 1) d=1
        printf "%.2f", d
    }')

DNS_PER_MIN=$(awk -v q="$DNS_QUERY_COUNT" -v d="$DURATION_MINUTES" \
    'BEGIN { printf "%.2f", q/d }')

echo "Total DNS queries:       $DNS_QUERY_COUNT"
echo "Capture duration:        $DURATION_MINUTES minutes"
echo "Average queries/minute:  $DNS_PER_MIN"
echo ""

echo "Top 20 queried domains:"
tshark -r "$PCAP_FILE" \
    -Y "dns.flags.response == 0 && dns.qry.name" \
    -T fields -e dns.qry.name 2>/dev/null |
sort |
uniq -c |
sort -nr |
head -n 20 |
awk '
{
    printf "%2d. %-45s %d queries\n", NR, $2, $1
}
'

echo ""

DNS_A=$(tshark -r "$PCAP_FILE" \
    -Y "dns.flags.response == 0 && dns.qry.type == 1" \
    -T fields -e frame.number 2>/dev/null | wc -l)

DNS_AAAA=$(tshark -r "$PCAP_FILE" \
    -Y "dns.flags.response == 0 && dns.qry.type == 28" \
    -T fields -e frame.number 2>/dev/null | wc -l)

DNS_MX=$(tshark -r "$PCAP_FILE" \
    -Y "dns.flags.response == 0 && dns.qry.type == 15" \
    -T fields -e frame.number 2>/dev/null | wc -l)

DNS_TXT=$(tshark -r "$PCAP_FILE" \
    -Y "dns.flags.response == 0 && dns.qry.type == 16" \
    -T fields -e frame.number 2>/dev/null | wc -l)

echo "DNS query types:"
echo "  A:     $DNS_A"
echo "  AAAA:  $DNS_AAAA"
echo "  TXT:   $DNS_TXT"
echo "  MX:    $DNS_MX"
echo ""

# --------------------------------------------------
# 7. CONNECTION DURATION
# --------------------------------------------------

echo "=== CONNECTION DURATION DISTRIBUTION ==="

echo "[TShark command]"
echo "  tshark -r PCAP -q -z conv,tcp"
echo ""

# Extract TCP conversation duration from tshark conversation table.
# The first numeric field after the address/port columns is handled
# by using tshark's fields directly where possible.

tshark -r "$PCAP_FILE" -q -z conv,tcp 2>/dev/null |
awk '
/<->/ {
    for (i=1; i<=NF; i++) {
        if ($i ~ /^[0-9]+\.[0-9]+$/) {
            duration=$i
            break
        }
    }

    if (duration != "") {
        if (duration < 1)
            short++
        else if (duration <= 30)
            medium++
        else
            long++

        total++
    }
}
END {
    if (total > 0) {
        printf "Short (<1s):       %.1f%%\n", (short/total)*100
        printf "Medium (1-30s):    %.1f%%\n", (medium/total)*100
        printf "Long (>30s):       %.1f%%\n", (long/total)*100
    }
}
'

echo ""

# --------------------------------------------------
# 8. TLS ANALYSIS
# --------------------------------------------------

echo "=== TLS ANALYSIS ==="

echo "Observed SNI values:"
tshark -r "$PCAP_FILE" \
    -Y "tls.handshake.extensions_server_name" \
    -T fields \
    -e tls.handshake.extensions_server_name 2>/dev/null |
sort -u |
sed '/^$/d' |
head -n 50

echo ""

echo "TLS versions:"
tshark -r "$PCAP_FILE" \
    -Y "tls.handshake" \
    -T fields \
    -e tls.handshake.version 2>/dev/null |
sort |
uniq -c |
sort -nr

echo ""

echo "Certificate issuers:"
tshark -r "$PCAP_FILE" \
    -Y "x509af.issuer" \
    -T fields \
    -e x509af.issuer 2>/dev/null |
sort -u |
sed '/^$/d'

echo ""

# --------------------------------------------------
# 9. TEMPORAL PATTERN
# --------------------------------------------------

echo "=== TEMPORAL PATTERN ==="

echo "[TShark filter]"
echo "  -e frame.time_epoch"
echo ""

tshark -r "$PCAP_FILE" \
    -T fields \
    -e frame.time_epoch 2>/dev/null |
awk '
{
    minute=int($1/60)
    packets[minute]++
}
END {
    for (m in packets)
        print m, packets[m]
}
' |
sort -n |
awk '
BEGIN {
    print "Minute-bin packet volume:"
}
{
    printf "  %s : %d packets\n", $1, $2
}
'

echo ""

# --------------------------------------------------
# 10. BASELINE SIGNATURES
# --------------------------------------------------

echo "=== BASELINE SIGNATURES ==="

echo "Normal DNS rate:"
echo "  $DNS_PER_MIN queries/minute"

echo ""

echo "Normal TXT query rate:"
TXT_PER_MIN=$(awk -v q="$DNS_TXT" -v d="$DURATION_MINUTES" \
    'BEGIN { printf "%.4f", q/d }')
echo "  $TXT_PER_MIN TXT queries/minute"

echo ""

echo "Normal external connection rhythm:"
echo "  See TOP 10 DESTINATION IPS and temporal packet-volume bins above."

echo ""

echo "Normal packet volume range:"
MIN_PACKETS=$(tshark -r "$PCAP_FILE" \
    -T fields -e frame.time_epoch 2>/dev/null |
awk '
{
    minute=int($1/60)
    packets[minute]++
}
END {
    min=-1
    max=0

    for (m in packets) {
        if (min == -1 || packets[m] < min)
            min=packets[m]

        if (packets[m] > max)
            max=packets[m]
    }

    printf "%d", min
}')

MAX_PACKETS=$(tshark -r "$PCAP_FILE" \
    -T fields -e frame.time_epoch 2>/dev/null |
awk '
{
    minute=int($1/60)
    packets[minute]++
}
END {
    max=0
    for (m in packets)
        if (packets[m] > max)
            max=packets[m]

    printf "%d", max
}')

echo "  $MIN_PACKETS - $MAX_PACKETS packets/minute"

echo ""

echo "Known-good services observed:"
tshark -r "$PCAP_FILE" \
    -T fields \
    -e ip.dst \
    -e tcp.dstport \
    -e udp.dstport 2>/dev/null |
awk -F '\t' '
{
    if ($2 != "") print $1 ":" $2
    if ($3 != "") print $1 ":" $3
}
' |
sort |
uniq -c |
sort -nr |
head -n 20

echo ""

# --------------------------------------------------
# 11. SAVE SIMPLE JSON BASELINE
# --------------------------------------------------

echo "=== SAVING BASELINE ==="

cat > "$OUTPUT_JSON" <<EOF
{
  "pcap": "$PCAP_FILE",
  "total_packets": $TOTAL_PACKETS,
  "capture_start_epoch": "${START_TIME:-0}",
  "capture_end_epoch": "${END_TIME:-0}",
  "protocol_distribution": {
    "tcp_packets": $TCP_COUNT,
    "udp_packets": $UDP_COUNT,
    "icmp_packets": $ICMP_COUNT,
    "other_packets": $OTHER_COUNT
  },
  "dns_profile": {
    "total_queries": $DNS_QUERY_COUNT,
    "queries_per_minute": $DNS_PER_MIN,
    "A_queries": $DNS_A,
    "AAAA_queries": $DNS_AAAA,
    "TXT_queries": $DNS_TXT,
    "MX_queries": $DNS_MX,
    "TXT_queries_per_minute": $TXT_PER_MIN
  },
  "packet_volume_range_per_minute": {
    "minimum": $MIN_PACKETS,
    "maximum": $MAX_PACKETS
  },
  "known_bad_iocs_expected_absent": [
    "91.234.99.107",
    "154.118.42.89",
    "data-sync.meddefense-portal.com"
  ]
}
EOF

echo "BASELINE SAVED: $OUTPUT_JSON"
echo ""

echo "=================================================="
echo "             BASELINE ANALYSIS COMPLETE"
echo "=================================================="
