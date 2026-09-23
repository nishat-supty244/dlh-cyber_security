#!/bin/bash
# MedDefense - DNS Tunnel Analysis
# Usage:
#   ./3-dns_tunnel.sh dns_exfil.pcap
#
# Purpose:
#   Detect and analyze possible DNS tunneling from billing-srv-01.

set -euo pipefail

PCAP_FILE="${1:-dns_exfil.pcap}"
SOURCE_IP="10.10.1.10"

# Known/expected legitimate domains.
# Add more if they are known from your environment.
EXPECTED_REGEX='(^|\.)(meddefense\.com|microsoft\.com|microsoftonline\.com|office365\.com|ubuntu\.com|ubuntuupdates\.org|windows\.com)$'

echo "=================================================="
echo "           MEDDEFENSE DNS TUNNEL ANALYSIS"
echo "=================================================="
echo "PCAP:       $PCAP_FILE"
echo "Source IP:  $SOURCE_IP"
echo ""

# --------------------------------------------------
# 0. CHECKS
# --------------------------------------------------

if [ ! -f "$PCAP_FILE" ]; then
    echo "Error: PCAP '$PCAP_FILE' not found."
    exit 1
fi

if ! command -v tshark >/dev/null 2>&1; then
    echo "Error: tshark is not installed."
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    echo "Error: python3 is required for decoding."
    exit 1
fi

# --------------------------------------------------
# 1. EXTRACT DNS QUERIES
# --------------------------------------------------

echo "=== 1. DNS QUERY EXTRACTION ==="

echo "[TShark filter]"
echo "  ip.src == $SOURCE_IP && dns.flags.response == 0 && dns.qry.name"
echo ""

QUERY_FILE=$(mktemp)
trap 'rm -f "$QUERY_FILE"' EXIT

tshark -r "$PCAP_FILE" \
    -Y "ip.src == $SOURCE_IP && dns.flags.response == 0 && dns.qry.name" \
    -T fields \
    -E separator='|' \
    -e frame.time_epoch \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e dns.qry.name \
    -e dns.qry.type \
    -e dns.qry.name.len \
    2>/dev/null > "$QUERY_FILE"

TOTAL_QUERIES=$(wc -l < "$QUERY_FILE" | tr -d ' ')

echo "Total DNS queries from $SOURCE_IP: $TOTAL_QUERIES"
echo ""

if [ "$TOTAL_QUERIES" -eq 0 ]; then
    echo "No DNS queries from $SOURCE_IP were found."
    exit 0
fi

# --------------------------------------------------
# 2. TIME SPAN
# --------------------------------------------------

FIRST_TIME=$(head -n 1 "$QUERY_FILE" | cut -d'|' -f1)
LAST_TIME=$(tail -n 1 "$QUERY_FILE" | cut -d'|' -f1)

TIME_SPAN_SECONDS=$(awk -v first="$FIRST_TIME" -v last="$LAST_TIME" '
BEGIN {
    d=last-first
    if (d < 1) d=1
    printf "%.2f", d
}')

TIME_SPAN_MINUTES=$(awk -v seconds="$TIME_SPAN_SECONDS" '
BEGIN {
    printf "%.2f", seconds/60
}')

QUERY_RATE=$(awk -v count="$TOTAL_QUERIES" -v minutes="$TIME_SPAN_MINUTES" '
BEGIN {
    if (minutes > 0)
        printf "%.2f", count/minutes
    else
        print "0"
}')

echo "First query:          $FIRST_TIME"
echo "Last query:           $LAST_TIME"
echo "Total time span:      $TIME_SPAN_MINUTES minutes"
echo "Overall query rate:   $QUERY_RATE queries/minute"
echo ""

# --------------------------------------------------
# 3. NORMAL VS ANOMALOUS CLASSIFICATION
# --------------------------------------------------

echo "=== 2. DNS QUERY CLASSIFICATION ==="

NORMAL_FILE=$(mktemp)
ANOMALOUS_FILE=$(mktemp)

trap 'rm -f "$QUERY_FILE" "$NORMAL_FILE" "$ANOMALOUS_FILE"' EXIT

while IFS='|' read -r epoch time src dnsserver domain qtype name_len; do

    # Extract the first label of the domain.
    first_label="${domain%%.*}"

    # Length of first label.
    label_length=${#first_label}

    # Determine whether the label looks encoded.
    encoded_score=$(python3 - "$first_label" <<'PY'
import sys
import string
import math

label = sys.argv[1]

if not label:
    print(0)
    raise SystemExit

# Characters often seen in Base32/Base64-style data.
allowed = set(string.ascii_letters + string.digits + "+/=_-")

ratio = sum(c in allowed for c in label) / len(label)

# More useful as a simple heuristic:
# long labels containing mostly letters/numbers are suspicious.
score = 0

if len(label) >= 30:
    score += 1

if ratio >= 0.95:
    score += 1

# Very few vowels can be a weak indication of encoded data.
vowels = sum(c.lower() in "aeiou" for c in label)
if len(label) >= 20 and vowels / len(label) < 0.25:
    score += 1

print(score)
PY
)

    is_expected=0

    if echo "$domain" | grep -Eiq "$EXPECTED_REGEX"; then
        is_expected=1
    fi

    # Known tunnel domain is automatically anomalous.
    if echo "$domain" | grep -Eiq '(^|\.)data-sync\.meddefense-portal\.com$'; then
        is_expected=0
    fi

    # Suspicion rules:
    # - unfamiliar domain
    # - long first label
    # - TXT query
    # - encoded-looking label
    if [ "$is_expected" -eq 0 ] || \
       [ "$label_length" -ge 30 ] || \
       [ "$qtype" = "16" ] || \
       [ "$encoded_score" -ge 2 ]; then

        echo "$epoch|$time|$src|$dnsserver|$domain|$qtype|$name_len|$label_length" \
            >> "$ANOMALOUS_FILE"
    else
        echo "$epoch|$time|$src|$dnsserver|$domain|$qtype|$name_len|$label_length" \
            >> "$NORMAL_FILE"
    fi

done < "$QUERY_FILE"

NORMAL_COUNT=$(wc -l < "$NORMAL_FILE" | tr -d ' ')
ANOMALOUS_COUNT=$(wc -l < "$ANOMALOUS_FILE" | tr -d ' ')

echo "Total DNS queries:   $TOTAL_QUERIES"
echo "Normal queries:      $NORMAL_COUNT"
echo "Anomalous queries:   $ANOMALOUS_COUNT"
echo ""

# --------------------------------------------------
# 4. ANOMALOUS QUERY ANALYSIS
# --------------------------------------------------

echo "=== 3. ANOMALOUS QUERY ANALYSIS ==="

if [ "$ANOMALOUS_COUNT" -eq 0 ]; then
    echo "No anomalous DNS queries were identified by the heuristic."
else

    echo ""
    echo "Most common anomalous domains:"

    cut -d'|' -f5 "$ANOMALOUS_FILE" |
    sort |
    uniq -c |
    sort -nr |
    head -n 20

    echo ""
    echo "Sample anomalous queries:"

    head -n 20 "$ANOMALOUS_FILE" |
    while IFS='|' read -r epoch time src dnsserver domain qtype name_len label_length; do

        first_label="${domain%%.*}"
        base_domain="${domain#*.}"

        echo "----------------------------------------"
        echo "Time:             $time"
        echo "Full query:       $domain"
        echo "Base domain:      $base_domain"
        echo "First label:      $first_label"
        echo "Label length:     $label_length characters"
        echo "DNS query type:   $qtype"
        echo "DNS name length:  ${name_len:-N/A}"

    done

fi

echo ""

# --------------------------------------------------
# 5. FIND TUNNEL DOMAIN
# --------------------------------------------------

echo "=== 4. POSSIBLE TUNNEL DOMAIN ==="

TUNNEL_DOMAIN=$(cut -d'|' -f5 "$ANOMALOUS_FILE" |
    grep -Ei 'data-sync\.meddefense-portal\.com' |
    sed -E 's/^[^.]+\.(data-sync\.meddefense-portal\.com.*)$/\1/' |
    head -n 1 || true)

if [ -z "$TUNNEL_DOMAIN" ]; then
    TUNNEL_DOMAIN=$(cut -d'|' -f5 "$ANOMALOUS_FILE" |
        grep -Ei 'data-sync\.meddefense-portal\.com' |
        head -n 1 |
        sed -E 's/^[^.]+\.//' || true)
fi

if [ -n "$TUNNEL_DOMAIN" ]; then
    echo "Known tunnel base domain observed:"
    echo "  $TUNNEL_DOMAIN"
else
    echo "Known tunnel domain was not directly observed."
    echo "Review anomalous domains above."
fi

echo ""

# --------------------------------------------------
# 6. LABEL LENGTH ANALYSIS
# --------------------------------------------------

echo "=== 5. SUBDOMAIN LABEL LENGTH ==="

if [ "$ANOMALOUS_COUNT" -gt 0 ]; then

    awk -F'|' '
    {
        sum += $8
        count++
        if (min == "" || $8 < min) min=$8
        if ($8 > max) max=$8
    }
    END {
        if (count > 0) {
            printf "Minimum label length: %d\n", min
            printf "Maximum label length: %d\n", max
            printf "Average label length: %.2f\n", sum/count
        }
    }
    ' "$ANOMALOUS_FILE"

else
    echo "No anomalous labels to analyze."
fi

echo ""

# --------------------------------------------------
# 7. SAMPLE DECODING
# --------------------------------------------------

echo "=== 6. SAMPLE ENCODED LABEL DECODING ==="

echo "The script attempts:"
echo "  1. Base32"
echo "  2. Base64"
echo ""
echo "Failure is reported rather than inventing decoded data."
echo ""

head -n 5 "$ANOMALOUS_FILE" |
while IFS='|' read -r epoch time src dnsserver domain qtype name_len label_length; do

    LABEL="${domain%%.*}"

    echo "----------------------------------------"
    echo "Timestamp: $time"
    echo "Encoded label: $LABEL"
    echo "Length: $label_length"

    python3 - "$LABEL" <<'PY'
import sys
import base64
import binascii
import string

label = sys.argv[1]

print("")

# -------------------------
# Base32 attempt
# -------------------------

try:
    padded = label.upper()
    padded += "=" * ((8 - len(padded) % 8) % 8)

    decoded = base64.b32decode(
        padded,
        casefold=True
    )

    print("Base32: SUCCESS")
    print("Decoded bytes:", decoded[:200])

except Exception as e:
    print("Base32: failed")
    print("Reason:", str(e))

# -------------------------
# Base64 attempt
# -------------------------

try:
    padded = label
    padded += "=" * ((4 - len(padded) % 4) % 4)

    decoded = base64.b64decode(
        padded,
        validate=True
    )

    print("Base64: SUCCESS")
    print("Decoded bytes:", decoded[:200])

except Exception as e:
    print("Base64: failed")
    print("Reason:", str(e))
PY

done

echo ""

# --------------------------------------------------
# 8. DNS RESPONSE ANALYSIS
# --------------------------------------------------

echo "=== 7. DNS RESPONSE ANALYSIS ==="

echo "[TShark filter]"
echo "  ip.dst == $SOURCE_IP && dns.flags.response == 1"
echo ""

RESPONSE_FILE=$(mktemp)
trap 'rm -f "$QUERY_FILE" "$NORMAL_FILE" "$ANOMALOUS_FILE" "$RESPONSE_FILE"' EXIT

tshark -r "$PCAP_FILE" \
    -Y "ip.dst == $SOURCE_IP && dns.flags.response == 1" \
    -T fields \
    -E separator='|' \
    -e frame.time \
    -e ip.src \
    -e ip.dst \
    -e dns.qry.name \
    -e dns.qry.type \
    -e dns.txt \
    -e dns.resp.len \
    -e dns.count.answers \
    2>/dev/null > "$RESPONSE_FILE"

RESPONSE_COUNT=$(wc -l < "$RESPONSE_FILE" | tr -d ' ')

echo "DNS responses to $SOURCE_IP: $RESPONSE_COUNT"
echo ""

echo "Response record types observed:"

awk -F'|' '
{
    type=$5

    if (type == "16")
        txt++
    else if (type == "1")
        a++
    else if (type == "28")
        aaaa++
    else if (type == "15")
        mx++
    else
        other++
}
END {
    printf "  A:      %d\n", a+0
    printf "  AAAA:   %d\n", aaaa+0
    printf "  TXT:    %d\n", txt+0
    printf "  MX:     %d\n", mx+0
    printf "  Other:  %d\n", other+0
}
' "$RESPONSE_FILE"

echo ""

echo "Sample TXT responses:"

awk -F'|' '$5 == "16" {
    print "----------------------------------------"
    print "Time:     " $1
    print "Server:   " $2
    print "Query:    " $4
    print "TXT data: " $6
    print "Length:   " $7
}' "$RESPONSE_FILE" | head -n 40

echo ""

# --------------------------------------------------
# 9. EXFILTRATION VOLUME
# --------------------------------------------------

echo "=== 8. EXFILTRATION VOLUME ==="

if [ "$ANOMALOUS_COUNT" -gt 0 ]; then

    AVG_LABEL=$(awk -F'|' '
    {
        sum += $8
        count++
    }
    END {
        if (count > 0)
            printf "%.2f", sum/count
        else
            print "0"
    }
    ' "$ANOMALOUS_FILE")

    ENCODED_BYTES=$(awk -v count="$ANOMALOUS_COUNT" \
                         -v avg="$AVG_LABEL" \
    'BEGIN {
        printf "%.2f", count * avg
    }')

    # Base32 overhead:
    # roughly 8 encoded characters represent 5 bytes.
    RAW_BASE32=$(awk -v encoded="$ENCODED_BYTES" '
    BEGIN {
        printf "%.2f", encoded * 5 / 8
    }')

    # Base64 overhead:
    # roughly 4 encoded characters represent 3 bytes.
    RAW_BASE64=$(awk -v encoded="$ENCODED_BYTES" '
    BEGIN {
        printf "%.2f", encoded * 3 / 4
    }')

    EXFIL_RATE=$(awk -v raw="$RAW_BASE32" \
                     -v minutes="$TIME_SPAN_MINUTES" '
    BEGIN {
        if (minutes > 0)
            printf "%.2f", raw/minutes
        else
            print "0"
    }')

    echo "Anomalous queries:           $ANOMALOUS_COUNT"
    echo "Average encoded label:       $AVG_LABEL bytes/chars"
    echo "Estimated encoded volume:    $ENCODED_BYTES bytes"
    echo "Estimated raw if Base32:     $RAW_BASE32 bytes"
    echo "Estimated raw if Base64:     $RAW_BASE64 bytes"
    echo "Approx. raw rate (Base32):   $EXFIL_RATE bytes/minute"

else
    echo "No anomalous queries available for volume estimation."
fi

echo ""

# --------------------------------------------------
# 10. COMPARE WITH BASELINE
# --------------------------------------------------

echo "=== 9. DETECTION COMPARISON ==="

echo ""
echo "                 NORMAL BASELINE        DNS TUNNEL"
echo "------------------------------------------------------------"

BASELINE_DNS_RATE="See Task 0 baseline_clinical.json"

echo "DNS rate:         $BASELINE_DNS_RATE    $QUERY_RATE queries/min"
echo "Query type:       A/AAAA mainly         Check anomalous/TXT"
echo "Label length:     Usually short          See measured values"
echo "Encoding:         Human-readable         Encoded-looking labels"
echo "Rate pattern:     Variable               Check interval consistency"
echo "Domain:           Known services         Check unfamiliar domains"
echo ""

# --------------------------------------------------
# 11. INTERVAL ANALYSIS
# --------------------------------------------------

echo "=== 10. QUERY INTERVAL ANALYSIS ==="

if [ "$ANOMALOUS_COUNT" -gt 1 ]; then

    awk -F'|' '
    NR == 1 {
        previous=$1
        next
    }

    {
        interval=$1-previous

        sum+=interval
        count++

        if (min == "" || interval < min)
            min=interval

        if (interval > max)
            max=interval

        previous=$1
    }

    END {
        if (count > 0) {
            printf "Average interval: %.2f seconds\n", sum/count
            printf "Minimum interval: %.2f seconds\n", min
            printf "Maximum interval: %.2f seconds\n", max
        }
    }
    ' "$ANOMALOUS_FILE"

else
    echo "Not enough anomalous queries for interval analysis."
fi

echo ""

# --------------------------------------------------
# 12. CONCLUSION
# --------------------------------------------------

echo "=== 11. CONCLUSION ==="

if [ "$ANOMALOUS_COUNT" -gt 0 ]; then

    TXT_ANOMALOUS=$(awk -F'|' '$6 == "16" {count++} END {print count+0}' \
        "$ANOMALOUS_FILE")

    LONG_LABELS=$(awk -F'|' '$8 >= 30 {count++} END {print count+0}' \
        "$ANOMALOUS_FILE")

    echo "Observed anomalous DNS activity:"
    echo "  - Anomalous queries: $ANOMALOUS_COUNT"
    echo "  - TXT/anomalous queries: $TXT_ANOMALOUS"
    echo "  - Long labels (>=30 chars): $LONG_LABELS"
    echo ""
    echo "These characteristics can be consistent with DNS tunneling."
    echo ""
    echo "IMPORTANT:"
    echo "The script does not claim exfiltration solely from long DNS labels."
    echo "A stronger tunnel assessment requires multiple indicators together:"
    echo "  - repeated queries"
    echo "  - long/encoded labels"
    echo "  - unusual query types"
    echo "  - regular timing"
    echo "  - unfamiliar destination domain"
    echo "  - possible encoded response data"
    echo ""
    echo "Review the packet-level evidence above before making the final"
    echo "forensic conclusion."

else

    echo "No anomalous DNS queries were identified."
    echo "The supplied traffic does not show the expected DNS tunnel pattern"
    echo "using the current detection heuristics."

fi

echo ""
echo "=================================================="
echo "          DNS TUNNEL ANALYSIS COMPLETE"
echo "=================================================="
