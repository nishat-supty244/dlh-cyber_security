# MedDefense Health Systems: Comprehensive Asset Registry

## Overview

This asset registry consolidates information collected from multiple sources, including:

- Onboarding documentation
- Incident logs
- Physical security observations
- IT service contracts
- Network scan results

The purpose of this registry is to establish a centralized view of MedDefense's technology assets, identify ownership, classify critical systems, and highlight undocumented or unmanaged assets.

---

# 1. Asset Registry

| Asset ID | Name | Type | Location | Owner | OS / Platform | Critical Services | Segment | Status | Notes |
|----------|------|------|----------|-------|---------------|------------------|---------|--------|------|
| A-001 | ehr-srv-01 | Server | Central | IT | Ubuntu 20.04 | EHR Application | 10.10.0.0/16 | Active | Primary healthcare application server |
| A-002 | ehr-db-01 | Server | Central | IT | Ubuntu 20.04 | PostgreSQL Database | 10.10.0.0/16 | Active | Stores EHR database information |
| A-003 | pacs-srv-01 | Server | Central | Radiology | Windows Server 2016 | Medical Imaging | 10.10.0.0/16 | Active | PACS imaging infrastructure |
| A-004 | billing-srv-01 | Server | Central | Finance | Ubuntu 18.04 | Billing System | 10.10.0.0/16 | Active | **Compromised - Cryptominer detected** |
| A-005 | ad-dc-01 | Server | Central | IT | Windows Server 2019 | Domain Authentication | 10.10.0.0/16 | Active | Primary domain controller |
| A-006 | ad-dc-02 | Server | Central | IT | Windows Server 2019 | Domain Authentication | 10.10.0.0/16 | Active | Secondary domain controller |
| A-007 | file-srv-01 | Server | Central | IT | Windows Server 2016 | File Shares | 10.10.0.0/16 | Active | Internal file storage |
| A-008 | backup-srv-01 | Server | Central | IT | Ubuntu 22.04 | Veeam Backup | 10.10.0.0/16 | Active | Backup infrastructure |
| A-009 | web-srv-01 | Server | Central | IT | Ubuntu 20.04 | Public Website | DMZ | Active | Public-facing web infrastructure |
| A-010 | ws-srv-01 | Server | Westside | IT | Windows Server 2016 | Scheduling Services | 10.10.0.0/16 | Active | Clinic scheduling server |
| A-011 | FortiGate-100F | Network Device | Central | IT | FortiOS | Firewall | 10.10.0.0/16 | Active | Network security gateway |
| A-012 | MRI-Scanner | IoT / Medical Device | Central | Radiology | Windows XP Embedded | Imaging | 10.10.0.0/16 | Active | Critical legacy system |
| A-013 | Philips-Mon-01 | IoT / Medical Device | Central | Clinical | Proprietary | Patient Monitoring | 10.10.0.0/16 | Active | IP: 10.10.3.47 |
| A-014 | Alaris-Pump-01 | IoT / Medical Device | Central | Clinical | Proprietary | Infusion Management | 10.10.0.0/16 | Active | Network-connected infusion pump |
| A-015 | Workstation-HR | Endpoint | HQ | HR | Windows 10/11 | HR File Access | 10.10.0.0/16 | Active | HR workstation |
| A-016 | Guest-AP-01 | Network Device | Central | IT | Ubiquiti | Guest WiFi | Guest / Unknown | Active | Requires isolation audit |
| A-017 | Print-Srv-01 | Server | Central | IT | Windows Server 2012 | Print Queue | 10.10.0.0/16 | Unknown | Unverified asset; not confirmed active |
| A-018 | Unk-Server-WS | Server | Westside | IT | Unknown | Unknown | 10.10.0.0/16 | Shadow IT | Detected in server closet |
| A-019 | Nighthawk-Rtr | Network Device | Westside | IT | Consumer Firmware | VPN / Routing | 10.10.0.0/16 | Shadow IT | Consumer-grade router |
| A-020 | GE-Revolution | IoT / Medical Device | Central | Radiology | Unknown | CT Imaging | 10.10.0.0/16 | Active | Requires operating system audit |

---

# 2. Asset Risk Observations

## Critical Assets

The following assets require priority protection due to their impact on healthcare operations:

| Asset | Reason for Criticality |
|-------|------------------------|
| ehr-srv-01 | Supports electronic patient records and clinical workflows |
| ehr-db-01 | Stores critical patient healthcare information |
| pacs-srv-01 | Required for medical imaging and diagnosis |
| billing-srv-01 | Supports financial operations and was previously compromised |
| MRI-Scanner | Legacy medical device with significant vulnerability exposure |
| Alaris-Pump-01 | Network-connected device affecting medication delivery |

---

# 3. Reconciliation Notes

## 3.1 Undocumented and Shadow IT Assets

Network scanning identified assets that were not included in the official asset inventory.

| Asset | Location | Discovery Details | Risk |
|------|----------|------------------|------|
| Cisco WS-C2960 Switch | Westside Clinic | Detected at IP `10.10.4.12` but missing from asset documentation | Unknown ownership and configuration status |
| Legacy Terminal | Central Basement | Detected at IP `10.10.2.22` | Unknown purpose and security status |
| Additional Westside Server | Westside Clinic | Detected at IP `10.10.5.5` but absent from ServiceDesk export | Potential unmanaged server |

---

# 4. Documentation Discrepancies

## Print Server Status

**Asset:** A-017 Print-Srv-01

Issue:

- Listed in documentation as an existing asset.
- Not identified during network scanning.

Possible explanations:

- System is offline.
- System has been decommissioned.
- Asset documentation is outdated.

Required Action:

- Verify operational status.
- Update asset inventory accordingly.

---

## Westside Server Documentation Conflict

**Asset:** A-018 Unk-Server-WS

Issue:

- Physical documentation references an additional server in the Westside server closet.
- Network scanning detected a device at:

```
10.10.5.5
```

Required Action:

- Identify system owner.
- Document operating system and purpose.
- Apply standard security controls.

---

## Guest WiFi Isolation Concern

Issue:

Documentation indicates that Guest WiFi is isolated.

However:

- Marcus's notes indicate uncertainty regarding proper isolation.
- Network scanning suggests Guest SSID activity exists on the same management subnet as clinical devices.

Risk:

Improper guest network segmentation could allow unauthorized devices to access clinical infrastructure.

Required Action:

- Validate VLAN configuration.
- Confirm firewall rules.
- Perform segmentation testing.

---

# 5. Infusion Pump Inventory Discrepancy

Issue:

The asset inventory estimates approximately:

```
~120 BD Alaris infusion pumps
```

However, network scanning identified:

```
80+ active infusion pump devices
```

Potential explanations:

- Some devices may be offline.
- Some IP addresses may represent orphaned entries.
- Asset records may contain outdated information.

Risk:

Incomplete medical device inventory may prevent effective vulnerability management and incident response.

Required Action:

- Perform a complete medical IoT inventory reconciliation.
- Remove inactive records.
- Confirm ownership and operational status.

---

# 6. Asset Management Assessment

The asset discovery process identified several weaknesses:

- Incomplete asset inventory.
- Presence of undocumented systems.
- Shadow IT infrastructure.
- Unverified medical device operating systems.
- Network documentation inconsistencies.

These issues increase security risk because unknown assets cannot be properly patched, monitored, or protected.

---

# Conclusion

The MedDefense asset registry demonstrates significant visibility gaps between documented infrastructure and the actual network environment.

The highest-priority actions are:

1. Perform a complete asset discovery and reconciliation process.
2. Remove or document all shadow IT assets.
3. Verify medical device inventory accuracy.
4. Confirm network segmentation, especially for guest and IoT networks.
5. Establish continuous asset monitoring.

Maintaining an accurate asset inventory is essential for effective vulnerability management, incident response, and regulatory compliance.
