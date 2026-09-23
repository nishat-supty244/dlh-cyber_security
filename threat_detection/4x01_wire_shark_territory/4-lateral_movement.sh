#!/bin/bash
#!/usr/bin/env bash

# ============================================================
# Task 4 - The Lateral Trail
# MedDefense Network Traffic Analysis
#
# Usage:
#   ./4-lateral_movement.sh lateral_movement.pcap
#
# Purpose:
#   Analyze lateral movement using packet evidence only.
# ============================================================

set -u

PCAP="${1:-lateral_movement.pcap}"

# -----------------------------
# 0. Check requirements
# -----------------------------

if ! command -v tshark >/dev/null 2>&1; then
    echo "ERROR: tshark is not installed."
    exit 1
fi

if [[ ! -f "$PCAP" ]]; then
    echo "ERROR: PCAP not found: $PCAP"
    exit 1
fi

# Known systems from the assignment
NURSE_IP="10.10.2.15"
BILLING_IP="10.10.1.10"
NAS_IP="10.10.1.60"

echo "============================================================"
echo "        TASK 4 - THE LATERAL TRAIL"
echo "============================================================"
echo "PCAP: $PCAP"
echo

# ============================================================
# 1. CROSS-SUBNET TRAFFIC
# ============================================================

echo "=== CROSS-SUBNET TRAFFIC ==="

CROSS_FILTER='
(
    (ip.src matches "^10\.10\.2\." && ip.dst matches "^10\.10\.1\.")
    ||
    (ip.src matches "^10\.10\.1\." && ip.dst matches "^10\.10\.2\.")
    ||
    (ip.src matches "^10\.10\.1\." && ip.dst matches "^10\.10\.4\.")
    ||
    (ip.src matches "^10\.10\.4\." && ip.dst matches "^10\.10\.1\.")
)
'

CROSS_COUNT=$(tshark -r "$PCAP" -Y "$CROSS_FILTER" -T fields \
    -e ip.src -e ip.dst 2>/dev/null |
    awk 'NF>=2 {print $1 "|" $2}' |
    sort -u |
    wc -l)

TOTAL_CROSS_PACKETS=$(tshark -r "$PCAP" -Y "$CROSS_FILTER" -T fields \
    -e frame.number 2>/dev/null |
    wc -l)

NURSE_CONNECTIONS=$(tshark -r "$PCAP" \
    -Y "ip.src==$NURSE_IP || ip.dst==$NURSE_IP" \
    -T fields -e ip.src -e ip.dst -e tcp.stream 2>/dev/null |
    awk 'NF>=2 {print $1 "|" $2}' |
    sort -u |
    wc -l)

echo "Cross-subnet packets: $TOTAL_CROSS_PACKETS"
echo "Unique source-destination pairs: $CROSS_COUNT"
echo "Unique connections involving WS-NURSE-04 ($NURSE_IP): $NURSE_CONNECTIONS"
echo

echo "--- Source -> Destination pairs ---"

tshark -r "$PCAP" -Y "$CROSS_FILTER" -T fields \
    -e ip.src -e ip.dst 2>/dev/null |
    awk 'NF>=2 {print $1 " -> " $2}' |
    sort | uniq -c |
    sort -nr

echo


# ============================================================
# 2. RDP / SMB / KERBEROS / NTLM TRAFFIC
# ============================================================

echo "=== AUTHENTICATION-RELATED TRAFFIC ==="

echo
echo "--- RDP traffic (TCP/3389) ---"

tshark -r "$PCAP" \
    -Y "tcp.port==3389" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    -e tcp.flags.syn \
    -e tcp.flags.ack \
    2>/dev/null |
    head -30

echo

echo "--- SMB traffic (TCP/445 or TCP/139) ---"

tshark -r "$PCAP" \
    -Y "tcp.port==445 || tcp.port==139" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.srcport \
    -e tcp.dstport \
    2>/dev/null |
    head -40

echo

echo "--- Kerberos traffic (UDP/TCP 88) ---"

tshark -r "$PCAP" \
    -Y "tcp.port==88 || udp.port==88" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e kerberos.msg_type \
    -e kerberos.cname_string \
    2>/dev/null |
    head -30

echo

echo "--- NTLM authentication traffic ---"

tshark -r "$PCAP" \
    -Y "ntlmssp" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e ntlmssp.messagetype \
    -e ntlmssp.auth.username \
    -e ntlmssp.auth.domain \
    2>/dev/null |
    head -40

echo


# ============================================================
# 3. DETAILED RDP EVENTS
# ============================================================

echo "=== RDP EVENTS ==="

RDP_FILTER="tcp.port==3389"

tshark -r "$PCAP" -Y "$RDP_FILTER" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.stream \
    -e tcp.flags \
    2>/dev/null |
    awk -F'|' '
    BEGIN {
        printf "%-25s | %-15s | %-15s | %-8s | %s\n",
        "Timestamp","Source","Destination","Stream","TCP Flags"
        print "-------------------------|----------------|----------------|--------|----------"
    }
    {
        printf "%-25s | %-15s | %-15s | %-8s | %s\n",
        $1,$2,$3,$4,$5
    }' |
    head -50

echo


# ============================================================
# 4. SMB SESSION / SHARE ACTIVITY
# ============================================================

echo "=== SMB SESSION / SHARE ACTIVITY ==="

echo
echo "--- SMB/SMB2 packets with visible account information ---"

tshark -r "$PCAP" \
    -Y "smb || smb2" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e smb2.session_flags \
    -e smb2.acct \
    -e smb2.tree \
    -e smb2.filename \
    2>/dev/null |
    head -60

echo

echo "--- SMB2 commands ---"

tshark -r "$PCAP" \
    -Y "smb2" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e smb2.cmd \
    -e smb2.filename \
    2>/dev/null |
    head -60

echo


# ============================================================
# 5. TCP RESET / REFUSED CONNECTIONS
# ============================================================

echo "=== FAILED / RESET CONNECTIONS ==="

echo
echo "--- TCP RST packets ---"

tshark -r "$PCAP" \
    -Y "tcp.flags.reset==1" \
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
    head -60

RST_COUNT=$(tshark -r "$PCAP" \
    -Y "tcp.flags.reset==1" \
    -T fields -e frame.number 2>/dev/null |
    wc -l)

echo
echo "Total TCP RST packets: $RST_COUNT"
echo

echo "Meaning:"
echo "TCP RST means the TCP connection was reset/refused."
echo "It does NOT by itself prove why the connection failed."
echo


# ============================================================
# 6. ACCESS ATTEMPTS TO INTERNAL SYSTEMS
# ============================================================

echo "=== INTERNAL ACCESS ATTEMPTS ==="

echo
echo "--- Connections from billing-srv-01 ---"

tshark -r "$PCAP" \
    -Y "ip.src==$BILLING_IP && tcp.flags.syn==1 && tcp.flags.ack==0" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport \
    -e tcp.stream \
    2>/dev/null |
    awk -F'|' '
    BEGIN {
        printf "%-25s | %-15s | %-15s | %-8s | %s\n",
        "Timestamp","Source","Destination","Port","Stream"
        print "-------------------------|----------------|----------------|--------|--------"
    }
    {
        printf "%-25s | %-15s | %-15s | %-8s | %s\n",
        $1,$2,$3,$4,$5
    }' |
    head -100

echo


# ============================================================
# 7. SMB ENUMERATION
# ============================================================

echo "=== SMB ENUMERATION ==="

echo
echo "--- Possible SMB directory/file enumeration ---"

tshark -r "$PCAP" \
    -Y "smb2.cmd==3 || smb2.cmd==5 || smb2.cmd==6 || smb2.cmd==8" \
    -T fields \
    -E header=y \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e smb2.cmd \
    -e smb2.filename \
    2>/dev/null |
    head -100

echo

echo "Useful SMB2 commands:"
echo "  3 = TREE_CONNECT"
echo "  5 = CREATE"
echo "  6 = CLOSE"
echo "  8 = READ"
echo

echo "--- Visible SMB filenames / paths ---"

tshark -r "$PCAP" \
    -Y "smb2.filename" \
    -T fields \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e smb2.filename \
    2>/dev/null |
    sort -u |
    head -100

echo


# ============================================================
# 8. NAS-01 ACTIVITY
# ============================================================

echo "=== NAS-01 ACTIVITY ==="

echo "Traffic involving NAS-01 ($NAS_IP):"

tshark -r "$PCAP" \
    -Y "ip.addr==$NAS_IP" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport \
    -e tcp.srcport \
    2>/dev/null |
    head -80

echo


# ============================================================
# 9. ATTACK PATH RECONSTRUCTION
# ============================================================

echo "=== ATTACK PATH RECONSTRUCTION ==="

echo
echo "Known systems:"
echo "  WS-NURSE-04    = $NURSE_IP"
echo "  billing-srv-01 = $BILLING_IP"
echo "  NAS-01         = $NAS_IP"
echo

echo "--- Traffic involving WS-NURSE-04 ---"

tshark -r "$PCAP" \
    -Y "ip.addr==$NURSE_IP" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport \
    -e tcp.srcport \
    2>/dev/null |
    head -60

echo

echo "--- Traffic originating from billing-srv-01 ---"

tshark -r "$PCAP" \
    -Y "ip.src==$BILLING_IP" \
    -T fields \
    -E separator="|" \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e tcp.dstport \
    2>/dev/null |
    head -100

echo


# ============================================================
# 10. BASELINE COMPARISON
# ============================================================

echo "=== BASELINE COMPARISON ==="

echo
echo "The following questions should be compared with Task 0:"
echo

echo "1. Does WS-NURSE-04 normally RDP to billing-srv-01?"

RDP_NURSE_TO_BILLING=$(tshark -r "$PCAP" \
    -Y "ip.src==$NURSE_IP && ip.dst==$BILLING_IP && tcp.dstport==3389" \
    -T fields -e frame.number 2>/dev/null |
    wc -l)

if [[ "$RDP_NURSE_TO_BILLING" -gt 0 ]]; then
    echo "   Incident PCAP: YES - RDP traffic observed."
else
    echo "   Incident PCAP: NO RDP traffic observed."
fi

echo
echo "2. Does billing-srv-01 normally enumerate other systems?"

echo "   Check the Task 0 baseline for normal SMB destinations."
echo "   Incident SMB destinations from billing-srv-01:"

tshark -r "$PCAP" \
    -Y "ip.src==$BILLING_IP && (tcp.dstport==445 || tcp.dstport==139)" \
    -T fields \
    -e ip.dst 2>/dev/null |
    sort -u

echo
echo "3. Does billing-srv-01 normally access NAS-01?"

NAS_ACCESS=$(tshark -r "$PCAP" \
    -Y "ip.src==$BILLING_IP && ip.dst==$NAS_IP && (tcp.dstport==445 || tcp.dstport==139)" \
    -T fields -e frame.number 2>/dev/null |
    wc -l)

if [[ "$NAS_ACCESS" -gt 0 ]]; then
    echo "   Incident PCAP: NAS-01 SMB traffic observed."
else
    echo "   Incident PCAP: No NAS-01 SMB traffic observed."
fi

echo
echo "IMPORTANT:"
echo "The incident PCAP shows what happened during this capture."
echo "The baseline is required to decide whether the behavior is normal."
echo


# ============================================================
# 11. MITRE ATT&CK MAPPING
# ============================================================

echo "=== MITRE ATT&CK MAPPING ==="

echo
echo "Observed behavior → possible ATT&CK technique"
echo

if [[ "$RDP_NURSE_TO_BILLING" -gt 0 ]]; then
    echo "RDP observed:"
    echo "  T1021.001 - Remote Services: Remote Desktop Protocol"
    echo
fi

SMB_COUNT=$(tshark -r "$PCAP" \
    -Y "ip.src==$BILLING_IP && (tcp.dstport==445 || tcp.dstport==139)" \
    -T fields -e frame.number 2>/dev/null |
    wc -l)

if [[ "$SMB_COUNT" -gt 0 ]]; then
    echo "SMB activity observed:"
    echo "  T1021.002 - Remote Services: SMB/Windows Admin Shares"
    echo
    echo "Possible share discovery:"
    echo "  T1135 - Network Share Discovery"
    echo
fi

FILE_ACTIVITY=$(tshark -r "$PCAP" \
    -Y "smb2.filename" \
    -T fields -e smb2.filename 2>/dev/null |
    wc -l)

if [[ "$FILE_ACTIVITY" -gt 0 ]]; then
    echo "SMB filenames/directories visible:"
    echo "  T1083 - File and Directory Discovery"
    echo
fi

echo "If packet evidence shows successful use of a domain account:"
echo "  T1078.002 - Valid Accounts: Domain Accounts"
echo
echo "Note: packet evidence showing an account name does not by itself"
echo "prove that the credentials were stolen."


# ============================================================
# 12. FINAL SUMMARY
# ============================================================

echo
echo "============================================================"
echo "                    SUMMARY"
echo "============================================================"

echo
echo "Cross-subnet packets: $TOTAL_CROSS_PACKETS"
echo "Unique cross-subnet pairs: $CROSS_COUNT"
echo "TCP RST packets: $RST_COUNT"
echo "RDP packets from WS-NURSE-04 to billing-srv-01: $RDP_NURSE_TO_BILLING"
echo "SMB packets from billing-srv-01: $SMB_COUNT"
echo "NAS-01 SMB packets from billing-srv-01: $NAS_ACCESS"

echo
echo "Main investigation questions:"
echo "  [1] Where did WS-NURSE-04 connect?"
echo "  [2] Did RDP authentication/session establishment occur?"
echo "  [3] Which systems did billing-srv-01 contact?"
echo "  [4] Which attempts were successful?"
echo "  [5] Which attempts were denied/reset?"
echo "  [6] Was SMB used for enumeration?"
echo "  [7] Was NAS-01 accessed?"
echo "  [8] How does this differ from the Task 0 baseline?"
echo
echo "============================================================"
echo "Analysis complete."
echo "============================================================"

