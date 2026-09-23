#!/bin/bash
#!/usr/bin/env bash

# ============================================================
# Task 5 - The VPN Pivot
# MedDefense Network Traffic Analysis
#
# Usage:
#   ./5-vpn_pivot.sh full_timeline.pcap
#
# Purpose:
#   Identify a possible VPN session, correlate it with
#   subsequent lateral movement, and document what the
#   packet evidence proves and does not prove.
# ============================================================

set -u

PCAP="${1:-full_timeline.pcap}"

# Expected systems from previous tasks
VPN_ENDPOINT="10.10.0.1"
BILLING_IP="10.10.1.10"
NURSE_IP="10.10.2.15"

# Expected external IP from the assignment.
# The script also searches for other external IPs.
KNOWN_EXTERNAL_IP="154.118.42.89"

# ------------------------------------------------------------
# 0. Check requirements
# ------------------------------------------------------------

if ! command -v tshark >/dev/null 2>&1; then
    echo "ERROR: tshark is not installed."
    exit 1
fi

if [[ ! -f "$PCAP" ]]; then
    echo "ERROR: PCAP not found: $PCAP"
    exit 1
fi

echo "============================================================"
echo "              TASK 5 - THE VPN PIVOT"
echo "============================================================"
echo "PCAP: $PCAP"
echo


# ============================================================
# 1. BASIC PCAP INFORMATION
# ============================================================

echo "=== PCAP TIME RANGE ==="

START_TIME=$(tshark -r "$PCAP" -T fields \
    -e frame.time_epoch 2>/dev/null |
    head -1)

END_TIME=$(tshark -r "$PCAP" -T fields \
    -e frame.time_epoch 2>/dev/null |
    tail -1)

if [[ -n "$START_TIME" && -n "$END_TIME" ]]; then
    echo "First packet epoch: $START_TIME"
    echo "Last packet epoch:  $END_TIME"
else
    echo "Could not determine PCAP time range."
fi

echo


# ============================================================
# 2. IDENTIFY VPN-LOOKING CONNECTIONS
# ============================================================

echo "=== VPN / HTTPS-STYLE CONNECTIONS ==="

echo
echo "Looking for traffic involving the expected VPN endpoint:"
echo "$VPN_ENDPOINT"
echo

tshark -r "$PCAP" \
    -Y "ip.addr==$VPN_ENDPOINT && (tcp.port==443 || udp.port==443)" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e udp.srcport \
    -e udp.dstport \
    -e tcp.stream \
    -e tls.handshake.type \
    2>/dev/null |
    head -80

echo


# ============================================================
# 3. LOOK FOR EXTERNAL IP -> VPN ENDPOINT
# ============================================================

echo "=== EXTERNAL → VPN ENDPOINT ==="

echo

# RFC1918 private ranges:
# 10.0.0.0/8
# 172.16.0.0/12
# 192.168.0.0/16
#
# Anything else seen talking to the VPN endpoint is treated
# as an external candidate.

tshark -r "$PCAP" \
    -Y "ip.dst==$VPN_ENDPOINT && tcp.dstport==443" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e tcp.stream \
    2>/dev/null |
    awk -F'|' '
    function private_ip(ip) {
        if (ip ~ /^10\./) return 1
        if (ip ~ /^192\.168\./) return 1
        if (ip ~ /^172\.(1[6-9]|2[0-9]|3[0-1])\./) return 1
        return 0
    }

    !private_ip($2) {
        print
    }' |
    head -80

echo


# ============================================================
# 4. FOCUS ON THE EXPECTED EXTERNAL IP
# ============================================================

echo "=== EXPECTED EXTERNAL IP ==="

echo "Looking for: $KNOWN_EXTERNAL_IP"
echo

tshark -r "$PCAP" \
    -Y "ip.addr==$KNOWN_EXTERNAL_IP" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e tcp.stream \
    -e tls.handshake.type \
    2>/dev/null |
    head -80

echo


# ============================================================
# 5. TLS CLIENT HELLO / SERVER HELLO
# ============================================================

echo "=== TLS HANDSHAKE DETAILS ==="

echo
echo "--- TLS ClientHello ---"

tshark -r "$PCAP" \
    -Y "tls.handshake.type==1" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport \
    -e tls.handshake.version \
    -e tls.handshake.extensions_server_name \
    -e tcp.stream \
    2>/dev/null |
    head -80

echo

echo "--- TLS ServerHello ---"

tshark -r "$PCAP" \
    -Y "tls.handshake.type==2" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tls.handshake.version \
    -e tcp.stream \
    2>/dev/null |
    head -80

echo


# ============================================================
# 6. SEARCH FOR ACCOUNT / AUTHENTICATION METADATA
# ============================================================

echo "=== AUTHENTICATION / ACCOUNT METADATA ==="

echo
echo "Searching packet fields for visible 'dmarsh' information..."

DMARSH_COUNT=$(tshark -r "$PCAP" \
    -Y 'frame contains "dmarsh"' \
    -T fields \
    -e frame.number 2>/dev/null |
    wc -l)

if [[ "$DMARSH_COUNT" -gt 0 ]]; then

    echo "Found $DMARSH_COUNT packet(s) containing 'dmarsh'."
    echo

    tshark -r "$PCAP" \
        -Y 'frame contains "dmarsh"' \
        -T fields \
        -E header=y \
        -E separator="|" \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        -e tcp.stream \
        2>/dev/null |
        head -50

else
    echo "No visible 'dmarsh' string found in packet data."
    echo
    echo "This does NOT prove that dmarsh was not used."
    echo "Authentication may be encrypted or stored in a field"
    echo "not exposed by this capture."
fi

echo


# ============================================================
# 7. FIND RDP MOVEMENT
# ============================================================

echo "=== FIRST RDP MOVEMENT ==="

RDP_RESULT=$(tshark -r "$PCAP" \
    -Y "tcp.dstport==3389" \
    -T fields \
    -E separator="|" \
    -e frame.time_epoch \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    2>/dev/null |
    head -1)

if [[ -n "$RDP_RESULT" ]]; then

    echo "First RDP connection:"
    echo "$RDP_RESULT"

    FIRST_RDP_EPOCH=$(echo "$RDP_RESULT" | cut -d'|' -f1)
    FIRST_RDP_TIME=$(echo "$RDP_RESULT" | cut -d'|' -f2)
    FIRST_RDP_SRC=$(echo "$RDP_RESULT" | cut -d'|' -f3)
    FIRST_RDP_DST=$(echo "$RDP_RESULT" | cut -d'|' -f4)

else

    echo "No RDP traffic found."
    FIRST_RDP_EPOCH=""
    FIRST_RDP_TIME=""
    FIRST_RDP_SRC=""
    FIRST_RDP_DST=""
fi

echo


# ============================================================
# 8. FIND VPN SESSION START
# ============================================================

echo "=== VPN SESSION START ==="

VPN_RESULT=$(tshark -r "$PCAP" \
    -Y "ip.dst==$VPN_ENDPOINT && tcp.dstport==443 && tcp.flags.syn==1 && tcp.flags.ack==0" \
    -T fields \
    -E separator="|" \
    -e frame.time_epoch \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e tcp.stream \
    2>/dev/null |
    head -1)

if [[ -n "$VPN_RESULT" ]]; then

    echo "Possible VPN TCP session start:"
    echo "$VPN_RESULT"

    VPN_START_EPOCH=$(echo "$VPN_RESULT" | cut -d'|' -f1)
    VPN_START_TIME=$(echo "$VPN_RESULT" | cut -d'|' -f2)
    VPN_SOURCE=$(echo "$VPN_RESULT" | cut -d'|' -f3)
    VPN_DEST=$(echo "$VPN_RESULT" | cut -d'|' -f4)
    VPN_SOURCE_PORT=$(echo "$VPN_RESULT" | cut -d'|' -f5)
    VPN_DEST_PORT=$(echo "$VPN_RESULT" | cut -d'|' -f6)
    VPN_STREAM=$(echo "$VPN_RESULT" | cut -d'|' -f7)

else

    echo "No TCP/443 connection to $VPN_ENDPOINT was found."
    VPN_START_EPOCH=""
    VPN_START_TIME=""
    VPN_SOURCE=""
    VPN_DEST=""
    VPN_SOURCE_PORT=""
    VPN_DEST_PORT=""
    VPN_STREAM=""
fi

echo


# ============================================================
# 9. SESSION DURATION
# ============================================================

echo "=== VPN SESSION DURATION ==="

if [[ -n "$VPN_STREAM" ]]; then

    STREAM_TIMES=$(tshark -r "$PCAP" \
        -Y "tcp.stream==$VPN_STREAM" \
        -T fields \
        -e frame.time_epoch 2>/dev/null |
        awk '
        NR==1 {first=$1}
        {last=$1}
        END {
            if (first != "" && last != "")
                print first "|" last
        }')

    if [[ -n "$STREAM_TIMES" ]]; then

        STREAM_FIRST=$(echo "$STREAM_TIMES" | cut -d'|' -f1)
        STREAM_LAST=$(echo "$STREAM_TIMES" | cut -d'|' -f2)

        DURATION=$(awk -v start="$STREAM_FIRST" -v end="$STREAM_LAST" \
            'BEGIN {printf "%.1f", end-start}')

        echo "VPN stream: $VPN_STREAM"
        echo "Start: $STREAM_FIRST"
        echo "Last observed packet: $STREAM_LAST"
        echo "Approximate observed duration: ${DURATION} seconds"

    else
        echo "Could not calculate stream duration."
    fi

else
    echo "VPN stream was not identified."
fi

echo


# ============================================================
# 10. CORRELATE VPN WITH RDP
# ============================================================

echo "=== TIMELINE CORRELATION ==="

if [[ -n "$VPN_START_EPOCH" && -n "$FIRST_RDP_EPOCH" ]]; then

    GAP=$(awk -v vpn="$VPN_START_EPOCH" \
        -v rdp="$FIRST_RDP_EPOCH" \
        'BEGIN {printf "%.1f", rdp-vpn}')

    echo "VPN connection:  $VPN_START_TIME"
    echo "First RDP:        $FIRST_RDP_TIME"
    echo "RDP source:       $FIRST_RDP_SRC"
    echo "RDP destination:  $FIRST_RDP_DST"
    echo "Time gap:         $GAP seconds"

    GAP_MIN=$(awk -v seconds="$GAP" \
        'BEGIN {printf "%.2f", seconds/60}')

    echo "Time gap:         approximately $GAP_MIN minutes"

    if awk -v gap="$GAP" 'BEGIN {exit !(gap > 0)}'; then
        echo
        echo "Finding:"
        echo "The VPN connection was observed before the first RDP event."
    else
        echo
        echo "Finding:"
        echo "The observed RDP event occurred before the identified VPN session."
        echo "Review the PCAP and VPN identification."
    fi

else

    echo "Could not correlate VPN and RDP timestamps."
    echo "Both events must be visible in the PCAP."

fi

echo


# ============================================================
# 11. LOOK FOR POSSIBLE ASSIGNED INTERNAL IP
# ============================================================

echo "=== POSSIBLE ASSIGNED INTERNAL IP ==="

echo
echo "Looking for internal IPs communicating with the external"
echo "VPN source after the VPN session starts."

if [[ -n "$VPN_SOURCE" ]]; then

    tshark -r "$PCAP" \
        -Y "ip.addr==$VPN_SOURCE" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        2>/dev/null |
        awk -v ext="$VPN_SOURCE" '
        function private_ip(ip) {
            if (ip ~ /^10\./) return 1
            if (ip ~ /^192\.168\./) return 1
            if (ip ~ /^172\.(1[6-9]|2[0-9]|3[0-1])\./) return 1
            return 0
        }

        {
            if ($2 == ext && private_ip($3))
                print

            if ($3 == ext && private_ip($2))
                print
        }' |
        head -50

    echo
    echo "Potential internal addresses can be investigated above."
    echo "The script does not automatically label one as the VPN"
    echo "assigned address because packet evidence may not prove that."

else

    echo "External VPN source IP was not identified."
fi

echo


# ============================================================
# 12. WHOIS / GEOIP LOOKUP
# ============================================================

echo "=== GEOLOCATION / WHOIS ==="

echo

if [[ -n "$VPN_SOURCE" ]]; then

    echo "Source IP: $VPN_SOURCE"
    echo

    if command -v whois >/dev/null 2>&1; then

        echo "--- WHOIS information ---"

        whois "$VPN_SOURCE" 2>/dev/null |
            grep -Ei \
            'country|origin|originas|aut-num|org-name|orgname|netname|descr|asn' |
            head -30

    else

        echo "whois command is not installed."
        echo "Install it with:"
        echo "  sudo apt install whois"
    fi

    echo

    echo "--- GeoIP ---"

    if command -v geoiplookup >/dev/null 2>&1; then

        geoiplookup "$VPN_SOURCE"

    else

        echo "geoiplookup is not installed."
        echo "If GeoIP is available on your system, run:"
        echo "  geoiplookup $VPN_SOURCE"
        echo
        echo "WHOIS/GeoIP results should be treated as IP-registration"
        echo "or geolocation context, not proof of the attacker's"
        echo "physical location."
    fi

else

    echo "No VPN source IP identified, so no lookup was performed."

fi

echo


# ============================================================
# 13. CHECK FOR VPN-RELATED PORTS
# ============================================================

echo "=== OTHER VPN-STYLE PORTS ==="

echo
echo "Common VPN-related ports observed in the PCAP:"

tshark -r "$PCAP" \
    -T fields \
    -e tcp.dstport \
    -e udp.dstport 2>/dev/null |
    tr '\t' '\n' |
    grep -E '^(443|500|4500|1194|1701|1723)$' |
    sort | uniq -c | sort -nr

echo

echo "Note:"
echo "A port number alone does not prove that a VPN was used."
echo "Protocol metadata and surrounding traffic must be considered."
echo


# ============================================================
# 14. WHAT THE PCAP PROVES / DOES NOT PROVE
# ============================================================

echo "=== PIVOT ASSESSMENT ==="

echo
echo "If the VPN session, account metadata and timeline all correlate,"
echo "the packet evidence can support the following chain:"
echo
echo "  External source"
echo "        ↓"
echo "  VPN-related session"
echo "        ↓"
echo "  Internal network access"
echo "        ↓"
echo "  Later RDP / lateral movement"
echo
echo "This provides a plausible network path connecting external"
echo "access to the later internal activity."
echo

echo "=== LIMITATIONS ==="
echo
echo "1. Encrypted VPN authentication:"
echo "   Password contents cannot normally be read from encrypted"
echo "   packet payloads."
echo
echo "2. Account attribution:"
echo "   An account name visible in metadata does not by itself"
echo "   prove who physically used the account."
echo
echo "3. GeoIP:"
echo "   IP geolocation indicates registered/estimated location."
echo "   It does not prove the attacker's physical location."
echo
echo "4. VPN identification:"
echo "   TCP/443 alone does not prove VPN usage."
echo "   VPN-specific metadata or capture context strengthens"
echo "   the identification."
echo
echo "5. Internal IP assignment:"
echo "   An internal address seen after VPN connection is not"
echo "   automatically the VPN-assigned address without supporting"
echo "   packet evidence."
echo


# ============================================================
# 15. FINAL SUMMARY
# ============================================================

echo "============================================================"
echo "                    FINAL SUMMARY"
echo "============================================================"

echo
echo "Possible VPN source:      ${VPN_SOURCE:-NOT IDENTIFIED}"
echo "VPN destination:          ${VPN_DEST:-NOT IDENTIFIED}"
echo "VPN source port:          ${VPN_SOURCE_PORT:-N/A}"
echo "VPN destination port:     ${VPN_DEST_PORT:-N/A}"
echo "VPN start:                ${VPN_START_TIME:-NOT IDENTIFIED}"
echo "First RDP:                ${FIRST_RDP_TIME:-NOT IDENTIFIED}"

if [[ -n "$DMARSH_COUNT" && "$DMARSH_COUNT" -gt 0 ]]; then
    echo "Visible dmarsh metadata:  YES"
else
    echo "Visible dmarsh metadata:  NO"
fi

echo
echo "The final conclusion should be based on the actual packet"
echo "evidence produced above, not only on the expected output."
echo
echo "============================================================"
echo "Analysis complete."
echo "============================================================"

