#!/bin/bash
#!/usr/bin/env bash

# ================================================================
# 6-kill_chain.sh
# MedDefense - Complete Kill Chain Reconstruction
#
# Purpose:
#   Combine evidence from Tasks 1-5 into one attack timeline.
#
# Usage:
#   chmod +x 6-kill_chain.sh
#   ./6-kill_chain.sh
#
# Optional:
#   ./6-kill_chain.sh /path/to/4x00_context.txt
# ================================================================

set -u

# -----------------------------
# FILES
# -----------------------------

EMAIL_CONTEXT="${1:-4x00_email_evidence.txt}"

PHISHING_PCAP="phishing_click.pcap"
C2_PCAP="c2_beaconing.pcap"
DNS_PCAP="dns_exfil.pcap"
LATERAL_PCAP="lateral_movement.pcap"
FULL_PCAP="full_timeline.pcap"

# -----------------------------
# KNOWN SCENARIO VALUES
# These come from the assignment context.
# They are used as investigation filters,
# not as hardcoded final results.
# -----------------------------

PHISHING_DOMAIN="meddefense-portal.com"
PHISHING_IP="91.234.99.107"

VPN_EXTERNAL_IP="154.118.42.89"
VPN_ENDPOINT="10.10.0.1"

DMarsh="dmarsh"

BILLING_IP="10.10.1.10"
NURSE_IP="10.10.2.15"
NAS_IP="10.10.1.60"

# -----------------------------
# COLORS / HEADERS
# -----------------------------

line() {
    printf '%*s\n' 64 '' | tr ' ' '='
}

section() {
    echo
    line
    echo "$1"
    line
}

# -----------------------------
# REQUIREMENTS
# -----------------------------

if ! command -v tshark >/dev/null 2>&1; then
    echo "[ERROR] TShark is not installed."
    exit 1
fi

echo
echo "================================================================"
echo "   COMPLETE KILL CHAIN RECONSTRUCTION"
echo "   MedDefense Incident"
echo "================================================================"

# -----------------------------
# CHECK FILES
# -----------------------------

section "1. EVIDENCE FILE CHECK"

FILES=(
    "$PHISHING_PCAP"
    "$C2_PCAP"
    "$DNS_PCAP"
    "$LATERAL_PCAP"
    "$FULL_PCAP"
)

for f in "${FILES[@]}"; do
    if [[ -f "$f" ]]; then
        echo "[FOUND] $f"
    else
        echo "[MISSING] $f"
    fi
done

if [[ -f "$EMAIL_CONTEXT" ]]; then
    echo "[FOUND] $EMAIL_CONTEXT"
else
    echo "[INFO] Email context file not found: $EMAIL_CONTEXT"
    echo "       4x00 is context evidence, not necessarily a PCAP."
fi

# -----------------------------
# HELPER
# -----------------------------

first_last_time() {
    local pcap="$1"

    if [[ ! -f "$pcap" ]]; then
        return
    fi

    echo "First packet:"
    tshark -r "$pcap" -T fields \
        -e frame.time \
        -c 1 2>/dev/null

    echo "Last packet:"
    tshark -r "$pcap" -T fields \
        -e frame.time \
        2>/dev/null | tail -1
}

# ================================================================
# PHASE 1
# INITIAL ACCESS / PHISHING
# ================================================================

section "PHASE 1: INITIAL ACCESS - PHISHING"

echo "Evidence source: 4x00 email context + phishing_click.pcap"
echo

if [[ -f "$EMAIL_CONTEXT" ]]; then
    echo "--- 4x00 EMAIL CONTEXT ---"
    cat "$EMAIL_CONTEXT"
    echo
else
    echo "4x00 email context is not available as a local text file."
    echo "Use your 4x00 findings for the email timestamp and recipient."
fi

if [[ -f "$PHISHING_PCAP" ]]; then

    echo
    echo "--- PHISHING PCAP TIME RANGE ---"
    first_last_time "$PHISHING_PCAP"

    echo
    echo "--- DNS QUERIES FOR PHISHING DOMAIN ---"

    tshark -r "$PHISHING_PCAP" \
        -Y "dns.qry.name contains \"$PHISHING_DOMAIN\"" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e dns.qry.name \
        2>/dev/null | head -20

    echo
    echo "--- TRAFFIC TO PHISHING IP ---"

    tshark -r "$PHISHING_PCAP" \
        -Y "ip.addr == $PHISHING_IP" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.dstport \
        -e tls.handshake.type \
        2>/dev/null | head -30

    echo
    echo "Evidence interpretation:"
    echo "  DNS resolution to the phishing domain is packet evidence."
    echo "  TLS communication with the phishing IP is packet evidence."
    echo "  A credential submission is an inference unless directly visible."
else
    echo "[SKIP] $PHISHING_PCAP not found."
fi

# ================================================================
# PHASE 2
# C2 BEACONING
# ================================================================

section "PHASE 2: C2 BEACONING"

echo "Evidence source: $C2_PCAP"

if [[ -f "$C2_PCAP" ]]; then

    echo
    echo "--- C2 PCAP TIME RANGE ---"
    first_last_time "$C2_PCAP"

    echo
    echo "--- CONNECTIONS TO KNOWN PHISHING/C2 IP ---"

    tshark -r "$C2_PCAP" \
        -Y "ip.addr == $PHISHING_IP" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        -e tcp.stream \
        2>/dev/null | head -60

    echo
    echo "--- HTTPS/TLS SESSIONS ---"

    tshark -r "$C2_PCAP" \
        -Y "tcp.port == 443 || tls" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.dstport \
        -e tcp.stream \
        2>/dev/null | head -60

    echo
    echo "--- POSSIBLE BEACON TIMING ---"

    tshark -r "$C2_PCAP" \
        -Y "ip.addr == $PHISHING_IP && tcp.flags.syn == 1 && tcp.flags.ack == 0" \
        -T fields \
        -e frame.time_epoch \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.dstport \
        2>/dev/null

    echo
    echo "Evidence interpretation:"
    echo "  Repeated connections are packet evidence."
    echo "  A regular interval can support a beaconing assessment."
    echo "  Repetition alone does not prove malware."
else
    echo "[SKIP] $C2_PCAP not found."
fi

# ================================================================
# PHASE 3
# VPN PIVOT
# ================================================================

section "PHASE 3: EXTERNAL ACCESS / VPN PIVOT"

echo "Evidence source: $FULL_PCAP"

VPN_TIME_EPOCH=""

if [[ -f "$FULL_PCAP" ]]; then

    echo
    echo "--- VPN CONNECTION CANDIDATES ---"

    tshark -r "$FULL_PCAP" \
        -Y "ip.src == $VPN_EXTERNAL_IP && ip.dst == $VPN_ENDPOINT && tcp.dstport == 443" \
        -T fields \
        -e frame.time \
        -e frame.time_epoch \
        -e ip.src \
        -e tcp.srcport \
        -e ip.dst \
        -e tcp.dstport \
        -e tcp.stream \
        2>/dev/null | head -30

    VPN_TIME_EPOCH=$(tshark -r "$FULL_PCAP" \
        -Y "ip.src == $VPN_EXTERNAL_IP && ip.dst == $VPN_ENDPOINT && tcp.dstport == 443 && tcp.flags.syn == 1 && tcp.flags.ack == 0" \
        -T fields \
        -e frame.time_epoch \
        2>/dev/null | head -1)

    echo
    echo "--- VPN TIMESTAMP ---"

    if [[ -n "$VPN_TIME_EPOCH" ]]; then
        tshark -r "$FULL_PCAP" \
            -Y "frame.time_epoch == $VPN_TIME_EPOCH" \
            -T fields \
            -e frame.time \
            -e ip.src \
            -e ip.dst \
            -e tcp.srcport \
            -e tcp.dstport \
            2>/dev/null
    else
        echo "No matching VPN SYN found."
    fi

    echo
    echo "--- dmarsh SEARCH ---"

    tshark -r "$FULL_PCAP" \
        -Y "frame contains \"$DMarsh\"" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        2>/dev/null | head -30

    echo
    echo "--- TLS INFORMATION ---"

    tshark -r "$FULL_PCAP" \
        -Y "ip.addr == $VPN_ENDPOINT && tcp.port == 443 && tls" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tls.handshake.type \
        -e tls.handshake.extensions_server_name \
        2>/dev/null | head -40

    echo
    echo "Evidence interpretation:"
    echo "  External-to-VPN traffic is packet evidence."
    echo "  dmarsh is reported only if visible in captured data."
    echo "  Encrypted authentication details may not be visible."
else
    echo "[SKIP] $FULL_PCAP not found."
fi

# ================================================================
# PHASE 4
# RDP / LATERAL MOVEMENT
# ================================================================

section "PHASE 4: LATERAL MOVEMENT - RDP"

echo "Evidence source: $LATERAL_PCAP"

RDP_TIME_EPOCH=""

if [[ -f "$LATERAL_PCAP" ]]; then

    echo
    echo "--- RDP CONNECTIONS ---"

    tshark -r "$LATERAL_PCAP" \
        -Y "tcp.dstport == 3389" \
        -T fields \
        -e frame.time \
        -e frame.time_epoch \
        -e ip.src \
        -e tcp.srcport \
        -e ip.dst \
        -e tcp.dstport \
        -e tcp.stream \
        2>/dev/null | head -40

    RDP_TIME_EPOCH=$(tshark -r "$LATERAL_PCAP" \
        -Y "tcp.dstport == 3389 && tcp.flags.syn == 1 && tcp.flags.ack == 0" \
        -T fields \
        -e frame.time_epoch \
        2>/dev/null | head -1)

    echo
    echo "--- FIRST RDP CONNECTION ---"

    if [[ -n "$RDP_TIME_EPOCH" ]]; then
        tshark -r "$LATERAL_PCAP" \
            -Y "frame.time_epoch == $RDP_TIME_EPOCH" \
            -T fields \
            -e frame.time \
            -e ip.src \
            -e ip.dst \
            -e tcp.srcport \
            -e tcp.dstport \
            2>/dev/null
    else
        echo "No RDP SYN found."
    fi

    echo
    echo "--- SMB TRAFFIC ---"

    tshark -r "$LATERAL_PCAP" \
        -Y "tcp.port == 445" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        -e tcp.flags.reset \
        2>/dev/null | head -80

    echo
    echo "--- NAS ACTIVITY ---"

    tshark -r "$LATERAL_PCAP" \
        -Y "ip.addr == $NAS_IP && tcp.port == 445" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        2>/dev/null | head -50

    echo
    echo "--- ACCESS DENIED / RESET INDICATORS ---"

    tshark -r "$LATERAL_PCAP" \
        -Y "tcp.flags.reset == 1 || smb2" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.dstport \
        -e tcp.flags.reset \
        2>/dev/null | head -80

else
    echo "[SKIP] $LATERAL_PCAP not found."
fi

# ================================================================
# PHASE 5
# DNS EXFILTRATION
# ================================================================

section "PHASE 5: DNS EXFILTRATION"

echo "Evidence source: $DNS_PCAP"

EXFIL_TIME_EPOCH=""

if [[ -f "$DNS_PCAP" ]]; then

    echo
    echo "--- DNS PCAP TIME RANGE ---"
    first_last_time "$DNS_PCAP"

    echo
    echo "--- DNS TXT QUERIES ---"

    tshark -r "$DNS_PCAP" \
        -Y "dns.qry.type == 16" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e dns.qry.name \
        -e dns.qry.type \
        2>/dev/null | head -80

    echo
    echo "--- LONG DNS LABELS ---"

    tshark -r "$DNS_PCAP" \
        -Y "dns.qry.name" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e dns.qry.name \
        2>/dev/null |
    awk -F'\t' '
    {
        n=$4
        count=split(n,a,".")
        longest=0

        for(i=1;i<=count;i++){
            if(length(a[i]) > longest)
                longest=length(a[i])
        }

        if(longest >= 40)
            print
    }' | head -80

    echo
    echo "--- DNS QUERY COUNT ---"

    TOTAL_DNS=$(tshark -r "$DNS_PCAP" \
        -Y "dns.qry.name" \
        -T fields \
        -e frame.number \
        2>/dev/null | wc -l)

    TXT_DNS=$(tshark -r "$DNS_PCAP" \
        -Y "dns.qry.type == 16" \
        -T fields \
        -e frame.number \
        2>/dev/null | wc -l)

    echo "Total DNS queries observed: $TOTAL_DNS"
    echo "TXT queries observed:      $TXT_DNS"

    EXFIL_TIME_EPOCH=$(tshark -r "$DNS_PCAP" \
        -Y "dns.qry.type == 16" \
        -T fields \
        -e frame.time_epoch \
        2>/dev/null | tail -1)

    echo
    echo "Evidence interpretation:"
    echo "  Long encoded DNS labels are packet evidence."
    echo "  TXT queries are packet evidence."
    echo "  Repeated encoded queries can support a DNS-tunneling assessment."
    echo "  Actual plaintext exfiltrated data may not be recoverable."
else
    echo "[SKIP] $DNS_PCAP not found."
fi

# ================================================================
# PHASE 6
# TIMELINE
# ================================================================

section "6. MASTER TIMELINE"

echo
echo "The following timestamps are extracted from the available evidence."
echo

echo "--- phishing_click.pcap ---"
if [[ -f "$PHISHING_PCAP" ]]; then
    first_last_time "$PHISHING_PCAP"
fi

echo
echo "--- c2_beaconing.pcap ---"
if [[ -f "$C2_PCAP" ]]; then
    first_last_time "$C2_PCAP"
fi

echo
echo "--- full_timeline.pcap / VPN ---"
if [[ -n "$VPN_TIME_EPOCH" ]]; then
    tshark -r "$FULL_PCAP" \
        -Y "frame.time_epoch == $VPN_TIME_EPOCH" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        2>/dev/null
fi

echo
echo "--- lateral_movement.pcap / RDP ---"
if [[ -n "$RDP_TIME_EPOCH" ]]; then
    tshark -r "$LATERAL_PCAP" \
        -Y "frame.time_epoch == $RDP_TIME_EPOCH" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e tcp.srcport \
        -e tcp.dstport \
        2>/dev/null
fi

echo
echo "--- dns_exfil.pcap ---"
if [[ -n "$EXFIL_TIME_EPOCH" ]]; then
    tshark -r "$DNS_PCAP" \
        -Y "frame.time_epoch == $EXFIL_TIME_EPOCH" \
        -T fields \
        -e frame.time \
        -e ip.src \
        -e ip.dst \
        -e dns.qry.name \
        2>/dev/null
fi

# ================================================================
# DWELL TIME
# ================================================================

section "7. DWELL TIME"

FIRST_ACCESS=""
LAST_EXFIL=""

if [[ -f "$PHISHING_PCAP" ]]; then
    FIRST_ACCESS=$(tshark -r "$PHISHING_PCAP" \
        -T fields -e frame.time_epoch \
        2>/dev/null | head -1)
fi

if [[ -f "$DNS_PCAP" ]]; then
    LAST_EXFIL=$(tshark -r "$DNS_PCAP" \
        -T fields -e frame.time_epoch \
        2>/dev/null | tail -1)
fi

if [[ -n "$FIRST_ACCESS" && -n "$LAST_EXFIL" ]]; then

    DWELL_SECONDS=$(awk -v a="$FIRST_ACCESS" -v b="$LAST_EXFIL" 'BEGIN {print b-a}')

    if awk -v x="$DWELL_SECONDS" 'BEGIN {exit !(x >= 0)}'; then
        DAYS=$(( ${DWELL_SECONDS%.*} / 86400 ))
        HOURS=$(( (${DWELL_SECONDS%.*} % 86400) / 3600 ))
        MINUTES=$(( (${DWELL_SECONDS%.*} % 3600) / 60 ))

        echo "First known packet in phishing PCAP:"
        date -d "@$FIRST_ACCESS" 2>/dev/null || echo "$FIRST_ACCESS"

        echo
        echo "Last observed packet in DNS exfil PCAP:"
        date -d "@$LAST_EXFIL" 2>/dev/null || echo "$LAST_EXFIL"

        echo
        echo "Approximate dwell time:"
        echo "${DAYS} days, ${HOURS} hours, ${MINUTES} minutes"
    else
        echo "Could not calculate dwell time."
        echo "The PCAPs may use different or non-overlapping timelines."
    fi

else
    echo "Dwell time could not be calculated automatically."
    echo "One or both endpoint timestamps were unavailable."
fi

# ================================================================
# VPN -> RDP TIME GAP
# ================================================================

section "8. VPN → RDP CORRELATION"

if [[ -n "$VPN_TIME_EPOCH" && -n "$RDP_TIME_EPOCH" ]]; then

    GAP=$(awk -v v="$VPN_TIME_EPOCH" -v r="$RDP_TIME_EPOCH" \
        'BEGIN {print r-v}')

    echo "VPN start epoch: $VPN_TIME_EPOCH"
    echo "RDP start epoch: $RDP_TIME_EPOCH"
    echo

    if awk -v x="$GAP" 'BEGIN {exit !(x >= 0)}'; then
        MINUTES=$(awk -v x="$GAP" 'BEGIN {printf "%.2f", x/60}')
        echo "Time from VPN to first RDP: approximately ${MINUTES} minutes"
    else
        echo "RDP timestamp appears earlier than VPN timestamp."
        echo "Check whether the two PCAPs use the same time reference."
    fi

else
    echo "VPN or RDP timestamp unavailable."
fi

# ================================================================
# VISIBILITY / DEFENSE SCORECARD
# ================================================================

section "9. VISIBILITY / DEFENSE SCORECARD"

echo
echo "EMAIL AUTHENTICATION / POLICY"
echo "  Source: 4x00 email evidence"
echo "  Determine from the email evidence whether SPF/DKIM/DMARC"
echo "  or other mail controls detected/rejected the message."

echo
echo "USER CLICK"
echo "  Source: phishing_click.pcap"
echo "  Look for DNS/TLS traffic to the phishing domain."

echo
echo "TLS ENCRYPTION"
echo "  Source: phishing_click.pcap / full_timeline.pcap"
echo "  TLS metadata may be visible while encrypted content is hidden."

echo
echo "BEACONING VISIBILITY"
echo "  Source: c2_beaconing.pcap"
echo "  Repeated connections can be measured and correlated."

echo
echo "VPN AUTHENTICATION"
echo "  Source: full_timeline.pcap"
echo "  Network connection and visible account context may be observable."
echo "  Password/MFA success is not assumed unless packet evidence shows it."

echo
echo "RDP ACCESS"
echo "  Source: lateral_movement.pcap"
echo "  TCP/3389 traffic provides network evidence of RDP activity."

echo
echo "SMB ENUMERATION"
echo "  Source: lateral_movement.pcap"
echo "  TCP/445 and SMB activity provide evidence of internal discovery."

echo
echo "DNS EXFILTRATION"
echo "  Source: dns_exfil.pcap"
echo "  Long encoded labels / TXT queries can support DNS tunneling assessment."

# ================================================================
# CRITICAL PIVOT POINTS
# ================================================================

section "10. CRITICAL PIVOT POINTS"

echo
echo "1. PHISHING"
echo "   Potential intervention: email filtering / user reporting / URL blocking."

echo
echo "2. PHISHING SITE CONNECTION"
echo "   Potential intervention: DNS/web filtering and endpoint/browser controls."

echo
echo "3. C2 BEACONING"
echo "   Potential intervention: detect repeated outbound communication."

echo
echo "4. VPN ACCESS"
echo "   Potential intervention: MFA, conditional access, VPN anomaly detection."

echo
echo "5. RDP"
echo "   Potential intervention: restrict workstation-to-server RDP."

echo
echo "6. SMB ENUMERATION"
echo "   Potential intervention: network segmentation and access controls."

echo
echo "7. DNS EXFILTRATION"
echo "   Potential intervention: DNS monitoring, TXT-query inspection,"
echo "   egress filtering and anomaly detection."

# ================================================================
# IMPACT ASSESSMENT
# ================================================================

section "11. IMPACT ASSESSMENT"

echo
echo "SYSTEMS OBSERVED IN THE INVESTIGATION:"
echo "  WS-NURSE-04       = $NURSE_IP"
echo "  billing-srv-01    = $BILLING_IP"
echo "  NAS-01            = $NAS_IP"
echo "  VPN endpoint      = $VPN_ENDPOINT"
echo

echo "POTENTIALLY ACCESSED:"
echo "  - Clinical workstation"
echo "  - Billing server"
echo "  - NAS / billing backup share"
echo "  - Other internal systems observed in SMB traffic"

echo
echo "RESISTED / FAILED ACCESS:"
echo "  - Systems returning access denied"
echo "  - Connections that were reset/refused"

echo
echo "POTENTIAL EXFILTRATION:"
echo "  - Data encoded in DNS queries"
echo "  - DNS TXT traffic"
echo "  - Exact plaintext data should not be claimed unless recovered"

echo
echo "UNCONFIRMED FROM PCAP ALONE:"
echo "  - Exact password used"
echo "  - Whether MFA was enabled/disabled"
echo "  - Whether endpoint malware executed"
echo "  - Exact identity/location of the person operating the system"
echo "  - Exact contents of all exfiltrated data"
echo "  - Whether a SIEM alert actually fired"

# ================================================================
# MITRE ATT&CK
# ================================================================

section "12. MITRE ATT&CK MAPPING"

cat <<'EOF'
PHISHING
  T1566.002 - Phishing: Spearphishing Link

CREDENTIAL / WEB SESSION
  T1056.003 - Input Capture: Web Portal Capture
  Use only when the evidence supports this interpretation.

C2 / BEACONING
  T1071.001 - Application Layer Protocol: Web Protocols

VPN / EXTERNAL ACCESS
  T1133 - External Remote Services

RDP
  T1021.001 - Remote Services: RDP

SMB / NETWORK DISCOVERY
  T1135 - Network Share Discovery
  T1021.002 - SMB/Windows Admin Shares

FILE/DIRECTORY DISCOVERY
  T1083 - File and Directory Discovery

DNS EXFILTRATION
  T1048.003 - Exfiltration Over Alternative Protocol: Exfiltration Over
              Unencrypted Non-C2 Protocol
EOF

# ================================================================
# FINAL NARRATIVE
# ================================================================

section "13. FINAL KILL CHAIN SUMMARY"

cat <<EOF
1. PHISHING
   The 4x00 evidence establishes the initial phishing context.

2. PHISHING CLICK
   phishing_click.pcap provides network evidence that the victim system
   communicated with the phishing infrastructure.

3. C2 / BEACONING
   c2_beaconing.pcap shows repeated outbound communication that can be
   assessed for automated beaconing behavior.

4. VPN PIVOT
   full_timeline.pcap is examined for external communication from
   $VPN_EXTERNAL_IP to the VPN endpoint $VPN_ENDPOINT.

5. RDP
   lateral_movement.pcap is examined for TCP/3389 activity and the
   internal path toward the billing server.

6. DISCOVERY
   SMB traffic is examined for network-share and file/directory discovery.

7. DNS EXFILTRATION
   dns_exfil.pcap is examined for repeated encoded DNS/TXT traffic.

IMPORTANT:
  Packet evidence and analytical inference must remain separate.

  Packet evidence = what the PCAP directly shows.

  Analytical inference = what the combined evidence reasonably suggests.

  Do not claim a password, malware execution, MFA status, attacker identity,
  or exact stolen data unless another evidence source confirms it.
EOF

line
echo "KILL CHAIN RECONSTRUCTION COMPLETE"
line
