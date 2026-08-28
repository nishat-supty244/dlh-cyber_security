#!/bin/bash
set -euo pipefail

# Configuration
OUTPUT_FILE="segmentation_rules.json"
GENERATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# ---------------------------------------------------------------
# Define the four MedDefense zones
# ---------------------------------------------------------------
ZONES_JSON=$(jq -n '[
    {
        name: "DMZ",
        cidr: "10.0.1.0/24",
        purpose: "Public-facing services",
        default_inbound: "drop",
        default_outbound: "accept"
    },
    {
        name: "INTERNAL",
        cidr: "10.0.2.0/24",
        purpose: "Clinical applications and databases",
        default_inbound: "drop",
        default_outbound: "accept"
    },
    {
        name: "MGMT",
        cidr: "10.0.3.0/24",
        purpose: "Administration",
        default_inbound: "drop",
        default_outbound: "accept"
    },
    {
        name: "MEDDEV",
        cidr: "10.0.4.0/24",
        purpose: "Medical device VLAN",
        default_inbound: "drop",
        default_outbound: "drop",
        outbound_restrictions: ["no_dmz_access", "no_public_internet_access"]
    }
]')

# ---------------------------------------------------------------
# Define cross-zone and intra-zone allow flows plus deny_all rules
# ---------------------------------------------------------------
FLOWS_JSON=$(jq -n '[
    # MGMT to INTERNAL - ssh administration
    {
        action: "allow",
        src_zone: "MGMT",
        dst_zone: "INTERNAL",
        proto: "tcp",
        dport: 22,
        justification: "Administration"
    },
    # MGMT to DMZ - ssh administration
    {
        action: "allow",
        src_zone: "MGMT",
        dst_zone: "DMZ",
        proto: "tcp",
        dport: 22,
        justification: "Administration"
    },
    # INTERNAL clinical workstations to INTERNAL server hosts
    {
        action: "allow",
        src_zone: "INTERNAL",
        dst_zone: "INTERNAL",
        proto: "tcp",
        dport: 443,
        justification: "Clinical workstations to internal server hosts"
    },
    {
        action: "allow",
        src_zone: "INTERNAL",
        dst_zone: "INTERNAL",
        proto: "tcp",
        dport: 3306,
        justification: "Clinical workstations to internal server hosts"
    },
    # DMZ to INTERNAL - databases only from named DMZ application hosts
    {
        action: "allow",
        src_zone: "DMZ",
        dst_zone: "INTERNAL",
        proto: "tcp",
        dport: 3306,
        justification: "Named DMZ application hosts to internal databases",
        exception_for: "dmz_app_hosts_only",
        src_restriction: "named_dmz_application_hosts"
    },
    # MEDDEV to INTERNAL - DICOM imaging (tcp/4242) and EHR web (tcp/443)
    {
        action: "allow",
        src_zone: "MEDDEV",
        dst_zone: "INTERNAL",
        proto: "tcp",
        dport: 4242,
        justification: "DICOM imaging to PACS"
    },
    {
        action: "allow",
        src_zone: "MEDDEV",
        dst_zone: "INTERNAL",
        proto: "tcp",
        dport: 443,
        justification: "EHR web integration for device display"
    },
    # ALL zones to MGMT resolver - DNS (udp/53 and tcp/53)
    {
        action: "allow",
        src_zone: "ALL",
        dst_zone: "MGMT",
        proto: "udp",
        dport: 53,
        justification: "DNS resolver"
    },
    {
        action: "allow",
        src_zone: "ALL",
        dst_zone: "MGMT",
        proto: "tcp",
        dport: 53,
        justification: "DNS resolver"
    },
    # MGMT to MEDDEV - administration and management access
    {
        action: "allow",
        src_zone: "MGMT",
        dst_zone: "MEDDEV",
        proto: "tcp",
        dport: 22,
        justification: "Administration access"
    },
    {
        action: "allow",
        src_zone: "MGMT",
        dst_zone: "MEDDEV",
        proto: "tcp",
        dport: 4242,
        justification: "Management access"
    },
    # Explicit deny_all for zone pairs with no allow flows
    {
        action: "deny_all",
        src_zone: "MEDDEV",
        dst_zone: "DMZ",
        proto: "any",
        dport: 0,
        justification: "No flows from MEDDEV to DMZ"
    },
    {
        action: "deny_all",
        src_zone: "MEDDEV",
        dst_zone: "INTERNET",
        proto: "any",
        dport: 0,
        justification: "No flows from MEDDEV to the public Internet"
    }
]')

# ---------------------------------------------------------------
# Build summary block
# ---------------------------------------------------------------
SUMMARY_JSON=$(echo "$FLOWS_JSON" | jq '{
    flow_count: length,
    allow_count: [.[] | select(.action == "allow")] | length,
    deny_count: [.[] | select(.action == "deny_all")] | length,
    cross_zone_pairs: 16
}')

# ---------------------------------------------------------------
# Construct and write final JSON
# ---------------------------------------------------------------
FINAL_JSON=$(jq -n \
    --arg ga "$GENERATED_AT" \
    --argjson zones "$ZONES_JSON" \
    --argjson flows "$FLOWS_JSON" \
    --argjson summary "$SUMMARY_JSON" \
    '{
        generated_at: $ga,
        zones: $zones,
        flows: $flows,
        summary: $summary
    }')

echo "$FINAL_JSON" > "$OUTPUT_FILE"

# Human-readable summary to stdout
echo "Segmentation Rules Generated"
echo "============================="
echo "Generated at:      $GENERATED_AT"
echo "Zones:             4 (DMZ, INTERNAL, MGMT, MEDDEV)"
echo "Total flows:       $(echo "$SUMMARY_JSON" | jq -r '.flow_count')"
echo "Allow rules:       $(echo "$SUMMARY_JSON" | jq -r '.allow_count')"
echo "Deny_all rules:    $(echo "$SUMMARY_JSON" | jq -r '.deny_count')"
echo "Cross-zone pairs:  $(echo "$SUMMARY_JSON" | jq -r '.cross_zone_pairs')"
echo "Output:            $OUTPUT_FILE"
