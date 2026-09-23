#!/bin/bash
# Description: Reproducible phishing-click PCAP analysis using tshark
# Usage: ./1-phishing_click.sh phishing_click.pcap

set -euo pipefail

PCAP_FILE="${1:-phishing_click.pcap}"
PHISH_DOMAIN="meddefense-portal.com"
PHISH_IP="91.234.99.107"
REAL_DOMAIN="meddefense.com"

if [ ! -f "$PCAP_FILE" ]; then
    echo "Error: PCAP file '$PCAP_FILE' not found!" >&2
    exit 1
fi

if ! command -v tshark >/dev/null 2>&1; then
    echo "Error: tshark is not installed or not in PATH." >&2
    exit 1
fi

echo "=================================================="
echo "      MEDDEFENSE PHISHING CLICK ANALYSIS"
echo "=================================================="
echo "PCAP: $PCAP_FILE"
echo ""

# --------------------------------------------------
# 1. DNS RESOLUTION
# --------------------------------------------------

echo "=== 1. DNS RESOLUTION ==="
echo "[*] TShark filter:"
echo "    dns.qry.name == \"$PHISH_DOMAIN\""
echo ""

DNS_RESULT=$(tshark -r "$PCAP_FILE" \
    -Y "dns.qry.name == \"$PHISH_DOMAIN\"" \
    -T fields \
    -E separator='|' \
    -e frame.time_epoch \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e dns.flags.response \
    -e dns.qry.name \
    -e dns.a \
    -e dns.resp.ttl \
    2>/dev/null || true)

if [ -z "$DNS_RESULT" ]; then
    echo "No DNS query for $PHISH_DOMAIN found."
else
    echo "$DNS_RESULT" | while IFS='|' read -r epoch time src dst response query answer ttl; do

        if [ "$response" = "0" ]; then
            echo "Query:"
            echo "  Timestamp: ${time:-N/A}"
            echo "  Source:    ${src:-N/A}"
            echo "  DNS Server:${dst:-N/A}"
            echo "  Domain:    ${query:-N/A}"

        elif [ "$response" = "1" ]; then
            echo "Response:"
            echo "  Timestamp: ${time:-N/A}"
            echo "  DNS Server:${src:-N/A}"
            echo "  Client:    ${dst:-N/A}"
            echo "  Domain:    ${query:-N/A}"
            echo "  Resolved:  ${answer:-N/A}"
            echo "  TTL:       ${ttl:-N/A}"
        fi

    done
fi

echo ""

# --------------------------------------------------
# 2. TCP CONNECTION / TLS CLIENTHELLO
# --------------------------------------------------

echo "=== 2. TCP / TLS HANDSHAKE ==="
echo "[*] Looking for connections involving $PHISH_IP"
echo ""

TLS_RESULT=$(tshark -r "$PCAP_FILE" \
    -Y "ip.addr == $PHISH_IP && tls.handshake.type == 1" \
    -T fields \
    -E separator='|' \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e tls.handshake.version \
    -e tls.handshake.extensions_server_name \
    -e tls.handshake.ciphersuite \
    2>/dev/null || true)

if [ -z "$TLS_RESULT" ]; then
    echo "No TLS ClientHello found for $PHISH_IP."
else
    echo "$TLS_RESULT" | while IFS='|' read -r time src dst sport dport version sni cipher; do
        echo "ClientHello:"
        echo "  Timestamp:       ${time:-N/A}"
        echo "  Source:          ${src:-N/A}:$sport"
        echo "  Destination:     ${dst:-N/A}:$dport"
        echo "  TLS version:     ${version:-N/A}"
        echo "  SNI:              ${sni:-N/A}"
        echo "  Cipher suite:    ${cipher:-N/A}"
        echo ""
    done
fi

# --------------------------------------------------
# 3. SERVER CERTIFICATE
# --------------------------------------------------

echo "=== 3. SERVER CERTIFICATE ==="
echo "[*] Extracting certificate fields from TLS handshake"
echo ""

CERT_RESULT=$(tshark -r "$PCAP_FILE" \
    -Y "ip.addr == $PHISH_IP && tls.handshake.certificate" \
    -T fields \
    -E separator='|' \
    -e frame.time \
    -e x509af.subject \
    -e x509af.issuer \
    -e x509af.notBefore \
    -e x509af.notAfter \
    -e x509af.serialNumber \
    2>/dev/null || true)

if [ -z "$CERT_RESULT" ]; then
    echo "Certificate details not available in the PCAP."
    echo "This can happen if the certificate was not captured or dissected."
else
    echo "$CERT_RESULT" | head -n 1 | while IFS='|' read -r time subject issuer notbefore notafter serial; do
        echo "Certificate:"
        echo "  Timestamp:       ${time:-N/A}"
        echo "  Subject:         ${subject:-N/A}"
        echo "  Issuer:          ${issuer:-N/A}"
        echo "  Valid from:      ${notbefore:-N/A}"
        echo "  Valid until:     ${notafter:-N/A}"
        echo "  Serial number:   ${serial:-N/A}"
    done
fi

echo ""

# --------------------------------------------------
# 4. TCP CONVERSATION STATISTICS
# --------------------------------------------------

echo "=== 4. DATA EXCHANGE ==="
echo "[*] TShark TCP conversation statistics:"
echo "    tshark -r \"$PCAP_FILE\" -q -z conv,tcp"
echo ""

tshark -r "$PCAP_FILE" -q -z conv,tcp 2>/dev/null | \
    grep -E "$PHISH_IP" || echo "No TCP conversation involving $PHISH_IP found."

echo ""

# --------------------------------------------------
# 5. PACKET COUNTS AND BYTES
# --------------------------------------------------

echo "=== 5. CLIENT / SERVER BYTES AND TCP SEGMENTS ==="

# Find internal client IP communicating with phishing IP.
CLIENT_IP=$(tshark -r "$PCAP_FILE" \
    -Y "ip.dst == $PHISH_IP && tcp.dstport == 443" \
    -T fields -e ip.src 2>/dev/null | head -n 1 || true)

if [ -z "$CLIENT_IP" ]; then
    echo "Could not identify the client IP automatically."
else
    echo "Client IP identified as: $CLIENT_IP"
    echo "Phishing server:         $PHISH_IP"
    echo ""

    CLIENT_STATS=$(tshark -r "$PCAP_FILE" \
        -Y "ip.src == $CLIENT_IP && ip.dst == $PHISH_IP && tcp" \
        -T fields \
        -e frame.len 2>/dev/null | \
        awk '{sum += $1; count++} END {print sum+0, count+0}')

    SERVER_STATS=$(tshark -r "$PCAP_FILE" \
        -Y "ip.src == $PHISH_IP && ip.dst == $CLIENT_IP && tcp" \
        -T fields \
        -e frame.len 2>/dev/null | \
        awk '{sum += $1; count++} END {print sum+0, count+0}')

    CLIENT_BYTES=$(echo "$CLIENT_STATS" | awk '{print $1}')
    CLIENT_SEGMENTS=$(echo "$CLIENT_STATS" | awk '{print $2}')

    SERVER_BYTES=$(echo "$SERVER_STATS" | awk '{print $1}')
    SERVER_SEGMENTS=$(echo "$SERVER_STATS" | awk '{print $2}')

    echo "Client -> Server:"
    echo "  Bytes:           $CLIENT_BYTES"
    echo "  TCP segments:    $CLIENT_SEGMENTS"
    echo ""

    echo "Server -> Client:"
    echo "  Bytes:           $SERVER_BYTES"
    echo "  TCP segments:    $SERVER_SEGMENTS"
fi

echo ""

# --------------------------------------------------
# 6. CONNECTION TIMELINE
# --------------------------------------------------

echo "=== 6. CONNECTION TIMELINE ==="

if [ -n "${CLIENT_IP:-}" ]; then

    echo "[*] First TCP SYN:"
    tshark -r "$PCAP_FILE" \
        -Y "ip.src == $CLIENT_IP && ip.dst == $PHISH_IP && tcp.flags.syn == 1 && tcp.flags.ack == 0" \
        -T fields -e frame.time 2>/dev/null | head -n 1 || true

    echo ""

    echo "[*] First TLS/application data:"
    tshark -r "$PCAP_FILE" \
        -Y "ip.src == $CLIENT_IP && ip.dst == $PHISH_IP && tcp.len > 0" \
        -T fields -e frame.time 2>/dev/null | head -n 1 || true

    echo ""

    echo "[*] Last data packet:"
    tshark -r "$PCAP_FILE" \
        -Y "ip.addr == $PHISH_IP && tcp.len > 0" \
        -T fields -e frame.time 2>/dev/null | tail -n 1 || true

    echo ""

    echo "[*] Connection close:"
    tshark -r "$PCAP_FILE" \
        -Y "ip.addr == $PHISH_IP && tcp.flags.fin == 1" \
        -T fields -e frame.time -e ip.src -e ip.dst 2>/dev/null || true

else
    echo "Timeline unavailable because the client IP could not be identified."
fi

echo ""

# --------------------------------------------------
# 7. METADATA-BASED CREDENTIAL SUBMISSION ANALYSIS
# --------------------------------------------------

echo "=== 7. METADATA-BASED ANALYSIS ==="

if [ -n "${CLIENT_IP:-}" ]; then

    echo "The HTTPS application data is encrypted."
    echo "Exact username/password contents cannot be determined from encrypted payloads."
    echo ""

    echo "[*] Client-to-server TLS/application packet sizes:"
    tshark -r "$PCAP_FILE" \
        -Y "ip.src == $CLIENT_IP && ip.dst == $PHISH_IP && tcp.len > 0" \
        -T fields \
        -e frame.time \
        -e frame.len \
        -e tcp.len \
        2>/dev/null | head -n 20

    echo ""
    echo "Interpretation:"
    echo "  - Packet sizes and timing can show that data was submitted."
    echo "  - They cannot prove the exact form fields or password contents."
    echo "  - A small outbound data burst may be consistent with a web-form"
    echo "    submission, but this remains a metadata-based assessment."
fi

echo ""

# --------------------------------------------------
# 8. POST-CLICK LEGITIMATE PORTAL CHECK
# --------------------------------------------------

echo "=== 8. POST-CLICK BEHAVIOR ==="
echo "[*] Checking for DNS queries to $REAL_DOMAIN"
echo ""

REAL_DNS=$(tshark -r "$PCAP_FILE" \
    -Y "dns.qry.name == \"$REAL_DOMAIN\"" \
    -T fields \
    -E separator='|' \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e dns.qry.name \
    -e dns.a \
    -e dns.resp.ttl \
    2>/dev/null || true)

if [ -z "$REAL_DNS" ]; then
    echo "No DNS query for $REAL_DOMAIN found."
else
    echo "$REAL_DNS" | while IFS='|' read -r time src dst query answer ttl; do
        echo "Timestamp:   ${time:-N/A}"
        echo "Query:       ${query:-N/A}"
        echo "Response IP: ${answer:-N/A}"
        echo "TTL:         ${ttl:-N/A}"
        echo ""
    done
fi

echo "[*] Checking for HTTPS connections to the legitimate portal..."
tshark -r "$PCAP_FILE" \
    -Y "ip.addr == 10.10.1.20 && tcp.dstport == 443" \
    -T fields \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport \
    2>/dev/null | head -n 10 || true

echo ""

# --------------------------------------------------
# 9. 4x00 CORRELATION
# --------------------------------------------------

echo "=== 9. 4x00 CORRELATION ==="

PHISH_DOMAIN_FOUND=$(tshark -r "$PCAP_FILE" \
    -Y "dns.qry.name == \"$PHISH_DOMAIN\" || tls.handshake.extensions_server_name == \"$PHISH_DOMAIN\"" \
    -T fields -e frame.number 2>/dev/null | head -n 1 || true)

PHISH_IP_FOUND=$(tshark -r "$PCAP_FILE" \
    -Y "ip.addr == $PHISH_IP" \
    -T fields -e frame.number 2>/dev/null | head -n 1 || true)

if [ -n "$PHISH_DOMAIN_FOUND" ]; then
    echo "IOC domain match: $PHISH_DOMAIN"
else
    echo "IOC domain match: NOT OBSERVED"
fi

if [ -n "$PHISH_IP_FOUND" ]; then
    echo "IOC IP match:     $PHISH_IP"
else
    echo "IOC IP match:     NOT OBSERVED"
fi

echo ""

if [ -n "$PHISH_DOMAIN_FOUND" ] || [ -n "$PHISH_IP_FOUND" ]; then
    echo "Assessment:"
    echo "  The PCAP contains network evidence associated with the phishing"
    echo "  infrastructure identified during the 4x00 investigation."
    echo ""
    echo "  The exact submitted credentials cannot be determined from encrypted"
    echo "  HTTPS traffic unless additional evidence exposes the application data."
else
    echo "Assessment:"
    echo "  The expected phishing IOC was not observed in the supplied PCAP."
fi

echo ""
echo "=================================================="
echo "              ANALYSIS COMPLETE"
echo "=================================================="
