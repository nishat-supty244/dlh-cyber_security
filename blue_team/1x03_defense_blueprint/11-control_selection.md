# 11. The Control Selection  
## Security Control Mapping, Framework Alignment, and Dependency Architecture


---

# Individual Risk Control Selections

---

# RISK-001: Credential Stuffing & Remote Access Compromise

## Risk
RISK-001

## Selected Control
**MFA Deployment on VPN and Administrative Accounts**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 6.3 — Require MFA for Remote Network Access; CIS Control 6.4 — Require MFA for Administrative Access |
| NIST CSF Mapping | PR.AC-1 — Identity management and access control are established; PR.AC-7 — Users, credentials, and devices are authenticated |
| Control Type | Preventive |
| Control Category | Technical |
| Implementation Cost | $4,000 (O365 E3 features + administrative labor) |
| Expected Risk Reduction | $1,400,000 ALE reduction |
| Dependencies | None — utilizes existing Microsoft enterprise licenses |

---

# RISK-002: Flat Network Lateral Movement Outbreak

## Risk
RISK-002

## Selected Control
**Network Segmentation (Core VLAN Implementation)**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 12.1 — Maintain an Inventory of Network Architecture; CIS Control 12.2 — Securely Manage Network Infrastructure |
| NIST CSF Mapping | PR.AC-5 — Network integrity is protected; PR.DS-5 — Protections against data leaks are implemented |
| Control Type | Preventive |
| Control Category | Technical |
| Implementation Cost | $15,000 |
| Expected Risk Reduction | $1,200,000 ALE reduction |
| Dependencies | None |

---

# RISK-003: Unverified Backup Destruction via Ransomware

## Risk
RISK-003

## Selected Control
**Offsite Backup Replication (AWS S3 Glacier Immutable Storage)**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 11.4 — Enforce Backup Atomicity and Immutability; CIS Control 11.5 — Protect Recovery Data |
| NIST CSF Mapping | PR.IP-4 — Backups are created, protected, and tested; RS.RP-1 — Response plan is executed and tested |
| Control Type | Corrective |
| Control Category | Technical |
| Implementation Cost | $12,000 |
| Expected Risk Reduction | $990,000 ALE reduction |
| Dependencies | None |

---

# RISK-004: Undetected Data Exfiltration & Dwell Time

## Risk
RISK-004

## Selected Control
**Enterprise SIEM Deployment (Open-Source Wazuh)**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 8.2 — Collect Audit Logs; CIS Control 8.5 — Collect Detailed Log Data |
| NIST CSF Mapping | DE.AE-1 — Baseline of network operations is understood; DE.CM-1 — Networks and environment are monitored |
| Control Type | Detective |
| Control Category | Technical |
| Implementation Cost | $18,000 |
| Expected Risk Reduction | $625,000 ALE reduction |
| Dependencies | Network infrastructure and endpoint logging sources must be reachable |

---

# RISK-005: Advanced Endpoint Malware & Fileless Execution

## Risk
RISK-005

## Selected Control
**Endpoint Detection and Response (EDR) Upgrade — Sophos Intercept X**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 10.2 — Deploy and Maintain EDR; CIS Control 10.3 — Enable Behavioral Endpoint Protection |
| NIST CSF Mapping | PR.DS-6 — Integrity is checked for software and firmware; DE.CM-4 — Malicious code is detected |
| Control Type | Preventive / Detective |
| Control Category | Technical |
| Implementation Cost | $22,000 |
| Expected Risk Reduction | $450,000 ALE reduction |
| Dependencies | None |

---

# RISK-006: Legacy Medical Device Exploitation

## Risk
RISK-006

## Selected Control
**Full Medical Device Network Isolation and Monitoring**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 12.3 — Establish Network Segmentation for IoT/Medical Devices; CIS Control 13.2 — Monitor Network Traffic for Unauthorized Devices |
| NIST CSF Mapping | PR.AC-5 — Network integrity is protected; ID.AM-3 — External information systems are cataloged |
| Control Type | Preventive |
| Control Category | Technical |
| Implementation Cost | $25,000 |
| Expected Risk Reduction | $240,000 ALE reduction |
| Dependencies | Core Network Segmentation (RISK-002) must be established first |

---

# RISK-007: Branch Office Perimeter Compromise

## Risk
RISK-007

## Selected Control
**Dedicated Firewall for Westside Clinic**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 12.1 — Maintain Network Perimeter Defenses; CIS Control 12.4 — Deny by Default Firewall Rules |
| NIST CSF Mapping | PR.PT-4 — Communications and control networks are protected; SC.CM-1 — Network perimeter is secured |
| Control Type | Preventive |
| Control Category | Technical |
| Implementation Cost | $8,000 |
| Expected Risk Reduction | $175,000 ALE reduction |
| Dependencies | None |

---

# RISK-008: Insider Threat & Unauthorized Privilege Abuse

## Risk
RISK-008

## Selected Control
**Role-Based Access Control (RBAC) Review & Wazuh Log Auditing**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 5.4 — Restrict Administrator Privileges; CIS Control 8.3 — Enable Log Correlation |
| NIST CSF Mapping | PR.AC-4 — Access permissions and authorizations are managed; DE.AE-3 — Incident alerts are analyzed |
| Control Type | Detective / Preventive |
| Control Category | Administrative / Technical |
| Implementation Cost | Absorbed into administrative labor and SIEM deployment |
| Expected Risk Reduction | $150,000 ALE reduction |
| Dependencies | Enterprise SIEM Deployment (RISK-004) must be active for log correlation |

---

# RISK-009: Unpatched Operating System & Software Vulnerabilities

## Risk
RISK-009

## Selected Control
**Automated Vulnerability Scanning and Vulnerability Management Policy**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 7.4 — Perform Automated Vulnerability Scans; CIS Control 7.5 — Patch Vulnerabilities in Operating Systems |
| NIST CSF Mapping | ID.RA-1 — Vulnerabilities are identified and documented; PR.IP-12 — Vulnerability management plan is executed |
| Control Type | Preventive |
| Control Category | Operational |
| Implementation Cost | Internal engineering labor using existing scanning utilities |
| Expected Risk Reduction | $130,000 ALE reduction |
| Dependencies | None |

---

# RISK-010: Phishing & Business Email Compromise (BEC)

## Risk
RISK-010

## Selected Control
**Email Gateway Security Rules & Security Awareness Training**

| Attribute | Details |
|---|---|
| CIS Control Mapping | CIS Control 9.2 — Configure Anti-Phishing Email Rules; CIS Control 14.2 — Conduct Security Awareness Training |
| NIST CSF Mapping | PR.AT-1 — All users are informed and trained; PR.DS-5 — Protections against data leaks are implemented |
| Control Type | Preventive |
| Control Category | Administrative / Technical |
| Implementation Cost | Existing O365 E3 security features and internal training hours |
| Expected Risk Reduction | $95,000 ALE reduction |
| Dependencies | None |

---

# Control Dependency Map

The following architecture diagram outlines the required sequencing and relationships between MedDefense security controls.

```text
[ Core Network Infrastructure / VLANs (RISK-002) ]
                  |
                  |
        +---------+---------+
        |                   |
        v                   v
[ Westside Clinic     [ Medical Device
  Firewall             Network Isolation
  (RISK-007) ]         (RISK-006) ]
                        

[ Enterprise SIEM Deployment (Wazuh) (RISK-004) ]
                  |
        +---------+---------+
        |                   |
        v                   v
[ RBAC Review &       [ EDR Upgrade
  Log Auditing         (Intercept X)
  (RISK-008) ]         (RISK-005) ]


[ Identity & Access Management ]
[ O365 E3 / MFA (RISK-001) ]

(Fundamental Security Baseline — No Dependencies)


[ Immutable Cloud Backups ]
[ AWS S3 Glacier (RISK-003) ]

(Independent Operational Safeguard)
