# Complete Control Matrix

This document serves as the authoritative inventory of all security controls identified throughout the **MedDefense Health Systems security assessment**. It consolidates technical, administrative, and physical controls, evaluates their effectiveness, and maps security coverage across critical assets.

---

# Part 1: Control Registry (Updated)

| Control ID | Control Name | Category | Function | Asset(s) Protected | Effectiveness | Evidence / Source |
|------------|--------------|----------|----------|-------------------|---------------|------------------|
| **C-001** | Fortinet FortiGate 100F | Technical | Preventive | Central Network | Adequate | Existing firewall infrastructure |
| **C-002** | Sophos Endpoint Protection | Technical | Preventive / Detective | Workstations | Adequate | Endpoint security deployment |
| **C-003** | Veeam Backup | Technical | Corrective | EHR Data | Weak | Backup configuration assessment |
| **C-004** | Password Policy | Administrative | Preventive | User Accounts | Adequate | Identity management review |
| **C-005** | Security Guard | Physical | Detective / Deterrent | Central Facility | Weak | Physical security assessment |
| **C-006** | Site-to-Site VPN | Technical | Preventive | Inter-site Data | Adequate | Network connectivity review |
| **C-007** | Guest WiFi Isolation | Technical | Preventive | Corporate Network | Adequate | Wireless network assessment |
| **C-008** | HID Badge System | Physical | Preventive | Entry Points | Adequate | Physical access control review |
| **C-009** | Server Room UPS | Physical | Compensating | Central Servers | Adequate | Infrastructure resilience assessment |
| **C-010** | O365 E3 Licensing | Administrative | Preventive | Email / Data | Adequate | Microsoft 365 configuration review |
| **C-011** | Active Directory Domain Policies | Technical | Preventive | Organization-wide Authentication | Adequate | Identity and access management review |
| **C-012** | Garage Camera System | Physical | Detective / Deterrent | Facility Perimeter | Weak | Physical monitoring assessment |
| **C-013** | MRI Micro-Segmentation | Technical | Preventive | MRI Workstation | Strong (Proposed) | Recommended security improvement |
| **C-014** | Industrial Firewall | Technical | Compensating | MRI Workstation | Strong (Proposed) | Recommended security improvement |
| **C-015** | Physical Port Security | Physical | Preventive | MRI Workstation | Strong (Proposed) | Recommended security improvement |

---

# Part 2: Updated Control Summary Matrix

**Effectiveness Rating:**
- **1 = Weak**
- **2 = Adequate**
- **3 = Strong**

Values represent:

**(Number of Controls / Average Effectiveness Rating)**

| Category | Preventive | Detective | Corrective | Compensating | Deterrent |
|----------|------------|-----------|------------|---------------|-----------|
| **Technical** | (6 / 2.3) | (1 / 2.0) | (1 / 1.0) | (1 / 3.0) | (0 / 0) |
| **Administrative** | (2 / 2.0) | (0 / 0) | (0 / 0) | (0 / 0) | (0 / 0) |
| **Physical** | (3 / 2.3) | (1 / 1.0) | (0 / 0) | (1 / 2.0) | (2 / 1.0) |

---

# Part 3: Control Coverage Map

| Critical Asset | Preventive Controls | Detective Controls | Corrective Controls | Compensating Controls | Coverage Assessment |
|----------------|--------------------|-------------------|--------------------|-----------------------|--------------------|
| **EHR System** | C-004, C-011 | None | C-003 | None | **Under-Protected** |
| **Medical IoT** | C-001 | None | None | None | **Under-Protected** |
| **PACS / Imaging** | C-013, C-015 | None | None | C-014 | **Partially Protected** |
| **Network Core** | C-001, C-006 | None | None | None | **Under-Protected** |
| **Billing Infrastructure** | C-004, C-011 | None | C-003 | None | **Under-Protected** |

---

# Control Coverage Analysis

## EHR System

The EHR environment relies primarily on authentication controls and backup capabilities. While Active Directory policies and password controls provide baseline protection, the absence of strong detective controls, MFA, and advanced monitoring leaves the system vulnerable to unauthorized access and ransomware attacks.

**Coverage Status:** Under-Protected

---

## Medical IoT

Medical IoT devices depend heavily on network-level protections. Current controls provide limited isolation and monitoring, creating risks from unauthorized access, device manipulation, and exploitation of vulnerable medical equipment.

**Coverage Status:** Under-Protected

---

## PACS / Imaging

The PACS environment benefits from proposed segmentation and physical security improvements. However, the lack of strong detective and corrective controls limits the ability to identify and recover from compromise.

**Coverage Status:** Partially Protected

---

## Network Core

The network core has firewall and VPN protections, but limited monitoring and insufficient segmentation reduce overall resilience. A compromise of core infrastructure could affect all clinical and administrative systems.

**Coverage Status:** Under-Protected

---

## Billing Infrastructure

Billing systems have basic authentication and backup controls but remain vulnerable due to previous compromise indicators, weak backup configuration, and limited monitoring capabilities.

**Coverage Status:** Under-Protected

---

# Overall Assessment

The control matrix indicates that MedDefense has foundational security controls in place; however, critical gaps remain in:

- Network segmentation
- Multi-factor authentication
- Security monitoring and detection
- Backup resilience
- Medical IoT protection
- Incident response capabilities

The highest priority improvements should focus on strengthening controls protecting **EHR systems, Medical IoT devices, Network Core infrastructure, and Billing systems**, as these assets represent the greatest operational and patient safety risks.
