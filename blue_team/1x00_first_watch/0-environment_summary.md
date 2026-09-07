# Environment Summary Report

**Date:** July 13, 2026  
**Subject:** Environment Analysis for MedDefense Health Systems  
**Location:** `dlh-cyber_security/blue_team/1x00_first_watch/0-environment_summary.md`

---

# 1. Organization Overview

## 1.1 Facilities

MedDefense Health Systems operates across multiple locations, including an acute care hospital, an outpatient clinic, and a corporate headquarters. Each location supports different operational functions and maintains access to critical healthcare information systems.

| Site | Location Type | Primary Functions | Approximate Headcount |
|------|---------------|-------------------|-----------------------|
| Central Hospital | Acute Care Facility | Emergency care, surgery, cardiology, inpatient services, and clinical operations | 1,400 |
| Westside Clinic | Outpatient Facility | Primary care, imaging, and minor procedures | 180 |
| Corporate HQ | Administrative Office | Finance, HR, Legal, Marketing, and IT operations | 220 |

---

## 1.2 Security Reporting Structure

### Leadership

The Deputy Chief Information Security Officer (CISO), James Chen, is responsible for leading security operations and reports directly to the Chief Executive Officer (CEO).

### Operational Conflict

A separation exists between the Security function and IT Operations:

- James Chen leads security activities but does not have operational authority over IT infrastructure.
- Sarah Park, the IT Director, manages IT operations.

This organizational structure creates potential challenges because security recommendations may not have direct enforcement authority over operational teams.

### Staffing

The organization currently has approximately **12 IT staff members** supporting the entire environment.

---

# 2. IT Infrastructure Overview

## 2.1 Central Hospital Servers

| Server | Function | Technology |
|--------|----------|------------|
| ehr-srv-01 | Electronic Health Record application server | Healthcare application server |
| ehr-db-01 | EHR database server | PostgreSQL Database |
| pacs-srv-01 | Medical imaging system | Windows Server 2016 |
| ad-dc-01 / ad-dc-02 | Active Directory and domain management | Windows Server 2019 |
| file-srv-01 | File storage services | Windows Server 2016 |
| billing-srv-01 | Billing and claims processing | Ubuntu 18.04 |
| print-srv-01 | Printing services | Windows Server 2012 R2 (unverified) |
| backup-srv-01 | Backup infrastructure | Ubuntu 22.04 with Local NAS |
| web-srv-01 | Public website and patient portal | Public-facing server |

---

## 2.2 Westside Clinic and Headquarters Servers

### Westside Clinic

| Server | Function | Notes |
|--------|----------|------|
| ws-srv-01 | File sharing and scheduling | Potential unidentified additional server in server closet |

### Corporate Headquarters

Corporate HQ does not maintain on-premise servers. The location relies primarily on cloud services and site-to-site VPN connectivity.

---

# 3. Network Infrastructure

## 3.1 Network Equipment

| Location | Network Equipment |
|----------|------------------|
| Central Hospital | Cisco Core switch, two Cisco access switches per floor, Fortinet FortiGate 100F firewall |
| Westside Clinic | Unmanaged switch and Netgear Nighthawk consumer-grade router |
| Corporate HQ | Network managed by building landlord with VLAN segregation |

---

## 3.2 Current Network Architecture

The current environment operates on a flat:

```
10.10.0.0/16
```

network.

Available documentation does not provide a complete network diagram or confirmed VLAN segmentation strategy.

The lack of verified segmentation increases the risk of lateral movement during a security incident.

---

# 4. Endpoints and IoT Devices

## 4.1 Endpoint Inventory

| Location | Devices |
|----------|---------|
| Central Hospital | Approximately 320 workstations, 60 thin clients, and 25 clinical iPads |
| Westside Clinic | Approximately 45 workstations |
| Corporate HQ | Approximately 150 workstations |

The organization does not currently have a confirmed inventory containing all endpoint operating systems, patch levels, and security configurations.

---

## 4.2 Medical IoT Devices

MedDefense uses several network-connected medical devices:

| Device | Quantity | Security Consideration |
|--------|----------|------------------------|
| Philips IntelliVue monitors | ~80 | Patient monitoring systems |
| BD Alaris infusion pumps | ~120 | Network-connected medication delivery systems |
| Siemens MAGNETOM MRI | 1 | Runs Windows XP |
| GE Revolution CT scanner | 1 | Operating system details unverified |

Medical IoT devices require careful security management because vulnerabilities may affect patient safety and clinical operations.

---

# 5. Data and Critical Services

## 5.1 Data Handled

MedDefense processes sensitive healthcare information, including:

- Protected Health Information (PHI)
- Electronic Health Records (EHR)
- Billing and insurance claims data
- Diagnostic imaging data stored in PACS

These data types require strong confidentiality, integrity, and availability protections.

---

## 5.2 Critical Services

| Service | Business Importance |
|---------|--------------------|
| EHR System | Required for patient diagnosis, treatment decisions, and clinical workflows |
| PACS Imaging System | Required for medical image access and diagnosis |
| Nurse Call System | Critical for patient safety and emergency communication |
| Site-to-Site VPN | Enables communication between facilities and remote operations |
| Infusion Pumps | Network-connected systems supporting medication administration |

---

# 6. Known Unknowns and Security Gaps

## 6.1 Network Visibility

Current documentation does not provide:

- Complete network topology
- Confirmed VLAN configuration
- Verified network segmentation controls

---

## 6.2 Endpoint Management

The organization lacks:

- Confirmed endpoint inventory
- Complete operating system information
- Verified patch status for workstations and tablets

---

## 6.3 Physical Security

Known concerns include:

- Westside Clinic server closet access is unconfirmed and may not be physically secured.
- Central Hospital server room access controls are not audited or managed using high-security procedures.

---

## 6.4 Compliance and Governance

Identified governance gaps:

- No formal HIPAA security assessment has been completed.
- No documented Incident Response (IR) plan exists.
- No Business Continuity Plan (BCP) exists.
- No Disaster Recovery (DR) plan exists.

---

## 6.5 Shadow Assets and Shadow IT

Potential unmanaged assets include:

- Possible unidentified server at Westside Clinic.
- Unknown operating system details for the GE Revolution CT scanner.
- Unconfirmed guest WiFi isolation at Central Hospital.
- Cloud services used by departments without security visibility outside of Microsoft 365.

---

# 7. Security Assessment Priorities

Based on the available documentation, the highest-priority improvement areas are:

1. Verify and document the complete network architecture.
2. Implement proper network segmentation between clinical, administrative, and IoT environments.
3. Secure unmanaged network infrastructure at the Westside Clinic.
4. Establish complete asset inventory and endpoint management processes.
5. Develop formal Incident Response, Business Continuity, and Disaster Recovery plans.
6. Perform a formal HIPAA security assessment.

---

# Conclusion

This environment summary is based on fragmented documentation and currently available information. MedDefense operates a complex healthcare technology environment containing highly sensitive patient information and critical clinical systems.

The most significant security concerns involve incomplete asset visibility, insufficient network segmentation, unmanaged infrastructure, and the absence of formal security governance processes. Addressing these areas will improve MedDefense's overall security posture and reduce operational and compliance risks.
