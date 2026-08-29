#!/bin/bash
set -euo pipefail

# Configuration
PCAP_PATH="${1:-/home/analyst/MedDefense_Lab/PCAPs/mixed_traffic.pcap}"
OUTPUT_FILE="suricata_alerts.json"
CATEGORIES_FILE="signature_categories.json"
TMP_DIR=$(mktemp -d)
STARTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Ensure dependencies are available
for cmd in suricata jq; do
    if ! command -v "$cmd" &> /dev/null; then
        echo "[-] Error: Required command '$cmd' is not installed." >&2
        exit 1
    fi
done

if [ ! -f "$PCAP_PATH" ]; then
    echo "[-] Error: PCAP file not found at $PCAP_PATH" >&2
    exit 1
fi

if [ ! -f "suricata.yaml" ]; then
    echo "[-] Error: suricata.yaml not found in current directory." >&2
    exit 1
fi

echo "[+] Running Suricata replay on $PCAP_PATH..."
sudo suricata -c ./suricata.yaml -r "$PCAP_PATH" -l "$TMP_DIR"

FINISHED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EVE_JSON="$TMP_DIR/eve.json"

if [ ! -f "$EVE_JSON" ]; then
    echo "[-] Error: Suricata did not generate eve.json." >&2
    exit 1
fi

echo "[+] Parsing eve.json alerts and categorizing results..."

# Load signature categories if available, else empty object
if [ -f "$CATEGORIES_FILE" ]; then
    CAT_MAP=$(cat "$CATEGORIES_FILE")
else
    CAT_MAP="{}"
fi

# Process alerts via jq to build the comprehensive JSON structure
jq \
  --arg pcap "$PCAP_PATH" \
  --arg started "$STARTED_AT" \
  --arg finished "$FINISHED_AT" \
  --argjson cat_map "$CAT_MAP" \
  '
  # Collect all alert events into an array
  [ . | select(.event_type == "alert") | {
      timestamp: .timestamp,
      src_ip: .src_ip,
      src_port: .src_port,
      dst_ip: .dst_ip,
      dst_port: .dst_port,
      proto: .proto,
      signature: .alert.signature,
      signature_id: .alert.signature_id,
      category: .alert.category,
      severity: .alert.severity
  } ] as $alerts |

  # Compute statistics
  ($alerts | length) as $total_alerts |
  ([$alerts[].signature_id] | unique | length) as $unique_signatures |

  # Severity distribution count
  ([$alerts | group_by(.severity) | .[] | {key: (.[0].severity | tostring), value: length}] | from_entries) as $severity_distribution |

  # Count per signature
  ([$alerts | group_by(.signature) | .[] | {sig: .[0].signature, count: length}] | sort_by(.count) | reverse) as $by_signature |

  # Top sources
  ([$alerts | group_by(.src_ip) | .[] | {ip: .[0].src_ip, count: length}] | sort_by(.count) | reverse) as $top_sources |

  # Top destinations
  ([$alerts | group_by(.dst_ip) | .[] | {ip: .[0].dst_ip, count: length}] | sort_by(.count) | reverse) as $top_destinations |

  # Categorization mapping
  ($alerts | map(
    . + {
      classification: ($cat_map[(.signature_id | tostring)] // "other")
    }
  )) as $classified_alerts |

  ([$classified_alerts | group_by(.classification) | .[] | {key: .[0].classification, value: length}] | from_entries) as $by_category |

  {
    pcap: $pcap,
    started_at: $started,
    finished_at: $finished,
    total_alerts: $total_alerts,
    unique_signatures: $unique_signatures,
    severity_distribution: $severity_distribution,
    by_category: $by_category,
    top_sources: $top_sources,
    top_destinations: $top_destinations,
    alerts: $classified_alerts
  }
' "$EVE_JSON" > "$OUTPUT_FILE"

# Clean up temporary directory
rm -rf "$TMP_DIR"

echo "[+] Analysis completed successfully. Output written to $OUTPUT_FILE"
