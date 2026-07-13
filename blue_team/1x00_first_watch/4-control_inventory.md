# Security Control Inventory

## Overview

This document provides an inventory of the security controls currently implemented within the MedDefense environment. Each control is classified according to:

- **Category**
  - Technical
  - Administrative
  - Physical
- **Function**
  - Preventive
  - Detective
  - Corrective
  - Compensating
  - Deterrent

The inventory identifies the assets protected by each control and references the source documentation used during the assessment.

---

# Security Control Inventory

| Control ID | Control Name | Description | Category | Function | Asset(s) Protected | Source |
|------------|--------------|-------------|----------|----------|--------------------|--------|
| **C-001** | Fortinet FortiGate 100F Firewall | Restricts unauthorized network traffic entering the Central Hospital network. | Technical | Preventive | Central Hospital internal network (10.10.0.0/16) | IT Asset List (Document 2) |
| **C-002** | Sophos Endpoint Protection | Detects and blocks malicious software on organizational workstations. | Technical | Preventive, Detective | Windows workstations (Central, Westside, HQ) | IT Service Contracts (Document 4) |
| **C-003** | Veeam Backup Solution | Performs automated nightly backups of server data to a local NAS. | Technical | Corrective | EHR database and server files | IT Service Contracts (Document 4), Marcus's Notes (Document 3) |
| **C-004** | Password Complexity Policy | Enforces an 8-character minimum password length, complexity requirements, and 90-day password rotation. | Administrative | Preventive | User accounts and Active Directory authentication | Marcus's Notes (Document 3) |
| **C-005** | ClearView Security Guard Service | Provides an on-site security guard at the Central Hospital main entrance during business hours (Monday–Friday, 7:00 AM–7:00 PM). | Physical | Preventive, Deterrent | Central Hospital facility | IT Service Contracts (Document 4) |
| **C-006** | Site-to-Site VPN | Encrypts communications between Central Hospital, Westside Clinic, and Corporate Headquarters. | Technical | Preventive | Inter-site data communications | IT Asset List (Document 2) |
| **C-007** | Guest WiFi Isolation | Provides a separate wireless network for non-corporate devices. | Technical | Preventive | Internal corporate network | Marcus's Notes (Document 3) |
| **C-008** | HID Global Badge Access System | Controls physical access to secured facility areas using Active Directory-integrated keycards. | Physical | Preventive | Building entrances and server rooms | IT Asset List (Document 2) |
| **C-009** | Server Room UPS (Uninterruptible Power Supply) | Provides approximately 20 minutes of emergency power during electrical outages. | Physical | Compensating | Central server infrastructure | Marcus's Notes (Document 3) |
| **C-010** | Microsoft 365 E3 Enterprise Licensing | Provides cloud-based email security, identity management, and productivity security features. | Administrative / Technical | Preventive | Email services and corporate data | IT Service Contracts (Document 4) |
| **C-011** | Active Directory Domain Controller Policies | Centrally manages authentication, authorization, and user access policies. | Technical | Preventive | Organization-wide authentication services | IT Asset List (Document 2) |
| **C-012** | Parking Garage Camera System | Monitors the exterior perimeter and staff parking areas using surveillance cameras. | Physical | Detective, Deterrent | Central Hospital exterior and parking facilities | Marcus's Notes (Document 3) |

---

# Control Summary Matrix

The following matrix classifies each security control according to both its **category** and **primary security function**.

| Category | Preventive | Detective | Corrective | Compensating | Deterrent |
|----------|------------|-----------|------------|---------------|------------|
| **Technical** | C-001, C-002, C-006, C-007, C-011 | C-002 | C-003 | — | — |
| **Administrative** | C-004, C-010 | — | — | — | — |
| **Physical** | C-005, C-008 | C-012 | — | C-009 | C-005, C-012 |

---

# Summary

The current security control inventory demonstrates that MedDefense has implemented controls across all three security control categories:

- **Technical controls** primarily focus on preventing unauthorized access, securing communications, protecting endpoints, and enabling recovery through backups.
- **Administrative controls** establish organizational policies for authentication and cloud service security.
- **Physical controls** protect facilities, critical infrastructure, and personnel through access control, surveillance, onsite security personnel, and backup power systems.

Although preventive controls represent the majority of implemented safeguards, comparatively fewer detective, corrective, and compensating controls are present. This imbalance suggests opportunities to strengthen monitoring capabilities, incident detection, resilience, and business continuity throughout the environment.
