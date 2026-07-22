# The Risk Register  
## Master Governance Instrument for MedDefense Health Systems


---

# MedDefense Master Risk Register (Top 10 Risks)

---

# RISK-001: Credential Stuffing & Remote Access Compromise

## Risk Description
External threat actors exploit non-multifactor-enabled remote access VPN connections or administrative login portals to gain unauthorized network access.

| Attribute | Details |
|---|---|
| Risk Category | Operational |
| Threat Source | Organized Cybercrime / Ransomware Affiliates |
| Vulnerability | Finding 003 — MFA Disabled on Remote Access & Administrative Accounts |
| Affected Assets | VPN Gateway (`vpn.meddefense.local`), Active Directory Domain Controllers (`dc-01`, `dc-02`), O365 Tenant Admin Portal |
| Likelihood | 5 (Very High — frequent automated attacks targeting legacy authentication) |
| Impact | 5 (Critical — potential full domain compromise and ransomware deployment) |
| Inherent Risk Score | 25 (Likelihood 5 × Impact 5) |
| ALE | $1,400,000 |
| Risk Owner | IT Infrastructure Manager (Sarah Park) |
| Treatment Decision | Mitigate |

## Treatment Justification
Mitigating this primary entry vector eliminates the root cause of the highest-impact ransomware scenarios for minimal investment.

## Planned Control(s)
- MFA Deployment on VPN and Administrative Accounts  
- CIS Control 6 — Account Management

## Residual Risk
Low  
**Residual Score:** 3 (Likelihood 1 × Impact 3)

## Key Risk Indicator (KRI)
- Failed VPN login spikes exceeding 500 attempts/hour
- Percentage of sessions without MFA authentication

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-002: Flat Network Lateral Movement Outbreak

## Risk Description
An attacker who compromises a single workstation moves unrestricted across the internal network and compromises critical databases and medical systems.

| Attribute | Details |
|---|---|
| Risk Category | Operational |
| Threat Source | Advanced Persistent Threat / Insider Threat / Malware |
| Vulnerability | Finding 008 — Flat Internal Network Architecture with Zero Segmentation |
| Affected Assets | Entire Internal Network Broadcast Domain, Workstations, Servers, Medical VLANs |
| Likelihood | 4 (High — common malware behavior after initial access) |
| Impact | 5 (Critical — enterprise-wide operational paralysis and data exfiltration) |
| Inherent Risk Score | 20 (Likelihood 4 × Impact 5) |
| ALE | $1,200,000 |
| Risk Owner | Network Operations Lead |
| Treatment Decision | Mitigate |

## Treatment Justification
Internal segmentation breaks the attacker kill chain and prevents localized compromises from becoming enterprise-wide incidents.

## Planned Control(s)
- Network Segmentation / VLAN Implementation  
- CIS Control 12 — Network Infrastructure Management

## Residual Risk
Low  
**Residual Score:** 4 (Likelihood 2 × Impact 2)

## KRI
- Unauthorized inter-VLAN traffic blocks
- Percentage of assets migrated to dedicated VLANs

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-003: Unverified Backup Destruction via Ransomware

## Risk Description
Ransomware operators identify and encrypt or delete local backup repositories before initiating extortion demands.

| Attribute | Details |
|---|---|
| Risk Category | Financial / Operational |
| Threat Source | Ransomware Affiliate Groups |
| Vulnerability | Finding 015 — Synology Backup NAS Vulnerable to CVE-2023-1383 and Lack of Air-Gap |
| Affected Assets | Backup Storage Server (`backup-nas-01`) and Local Historical Archives |
| Likelihood | 3 (Moderate — targeted during advanced ransomware attacks) |
| Impact | 5 (Critical — permanent data loss and prolonged hospital downtime) |
| Inherent Risk Score | 15 (Likelihood 3 × Impact 5) |
| ALE | $990,000 |
| Risk Owner | Systems Administrator |
| Treatment Decision | Mitigate |

## Treatment Justification
Immutable cloud storage ensures clean recovery points remain available even if on-premise systems are compromised.

## Planned Control(s)
- AWS S3 Glacier Immutable Backup Replication
- CIS Control 11 — Data Recovery

## Residual Risk
Low  
**Residual Score:** 4 (Likelihood 1 × Impact 4)

## KRI
- Backup verification success rate
- Immutable object-lock compliance status

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-004: Undetected Data Exfiltration & Extended Dwell Time

## Risk Description
Attackers maintain persistent access and silently extract Protected Health Information (PHI) without detection.

| Attribute | Details |
|---|---|
| Risk Category | Compliance / Financial |
| Threat Source | Cyber Espionage / Extortion Groups / Insider Threat |
| Vulnerability | Finding 001 — Absence of Centralized Logging and SIEM |
| Affected Assets | Database Servers (`db-sql-01`, `db-sql-02`), File Shares, Network Switches |
| Likelihood | 4 (High — lack of monitoring enables silent attacks) |
| Impact | 4 (Major — HIPAA penalties, legal exposure, reputational damage) |
| Inherent Risk Score | 16 (Likelihood 4 × Impact 4) |
| ALE | $625,000 |
| Risk Owner | Security Analyst |
| Treatment Decision | Mitigate |

## Treatment Justification
A centralized SIEM improves visibility, enables threat detection, and reduces attacker dwell time.

## Planned Control(s)
- Enterprise SIEM Deployment using Wazuh
- CIS Control 8 — Audit Log Management

## Residual Risk
Medium  
**Residual Score:** 6 (Likelihood 2 × Impact 3)

## KRI
- Mean Time to Detect (MTTD)
- Log agent coverage percentage

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-005: Advanced Endpoint Malware & Fileless Execution

## Risk Description
Advanced malware bypasses traditional antivirus and executes malicious payloads on clinical endpoints.

| Attribute | Details |
|---|---|
| Risk Category | Operational |
| Threat Source | Commodity Malware / Ransomware-as-a-Service |
| Vulnerability | Finding 012 — Legacy Antivirus Without Behavioral Detection |
| Affected Assets | Workstations and Hospital Servers (`ws-*`, `srv-*`) |
| Likelihood | 4 (High — continuous endpoint attacks) |
| Impact | 4 (Major — credential theft and service disruption) |
| Inherent Risk Score | 16 |
| ALE | $450,000 |
| Risk Owner | Endpoint Support Lead |
| Treatment Decision | Mitigate |

## Planned Control(s)
- Sophos Intercept X EDR Upgrade
- CIS Control 10 — Malware Defenses

## Residual Risk
Low  
**Residual Score:** 3

## KRI
- Endpoint threat block rate
- Percentage of systems running updated EDR agents

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-006: Legacy Medical Device Exploitation

## Risk Description
Unsupported medical devices operating with outdated systems are compromised through default credentials or network exploitation.

| Attribute | Details |
|---|---|
| Risk Category | Operational / Strategic |
| Threat Source | External Scanners / Compromised Internal Actors |
| Vulnerability | Finding 019 — Unpatched Imaging Equipment and Infusion Pumps |
| Affected Assets | Biomedical Devices (`med-infusion-*`, `med-mri-01`) |
| Likelihood | 3 |
| Impact | 4 |
| Inherent Risk Score | 12 |
| ALE | $240,000 |
| Risk Owner | Biomedical Engineering Director |
| Treatment Decision | Mitigate |

## Planned Control(s)
- Medical Device Network Isolation
- Dedicated Monitoring Controls
- CIS Controls 12/13

## Residual Risk
Low  
**Residual Score:** 3

## KRI
Number of unmanaged devices detected outside medical VLANs.

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-007: Branch Office Perimeter Compromise

## Risk Description
Attackers exploit the unmanaged consumer-grade router at the Westside Clinic as a backdoor into the primary hospital network.

| Attribute | Details |
|---|---|
| Risk Category | Operational |
| Threat Source | Opportunistic External Attackers |
| Vulnerability | Finding 014 — Consumer Router with Remote Management Enabled |
| Affected Asset | Westside Clinic Network Gateway |
| Likelihood | 3 |
| Impact | 3 |
| Inherent Risk Score | 9 |
| ALE | $175,000 |
| Risk Owner | Network Infrastructure Manager |
| Treatment Decision | Mitigate |

## Planned Control(s)
- Dedicated Enterprise Firewall
- Secure VPN Connectivity
- CIS Control 12

## Residual Risk
Low  
**Residual Score:** 2

## KRI
- Branch VPN uptime
- Firewall security alert volume

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-008: Insider Threat & Unauthorized Privilege Abuse

## Risk Description
Malicious or compromised employees misuse legitimate access privileges to view, modify, or steal confidential patient records.

| Attribute | Details |
|---|---|
| Risk Category | Compliance / Operational |
| Threat Source | Malicious or Negligent Insider |
| Vulnerability | Finding 022 — Excessive EHR Database Permissions |
| Affected Asset | Electronic Health Record System (`ehr-srv-01`) |
| Likelihood | 2 |
| Impact | 4 |
| Inherent Risk Score | 8 |
| ALE | $150,000 |
| Risk Owner | Compliance Officer / EHR Administrator |
| Treatment Decision | Mitigate |

## Planned Control(s)
- RBAC Review
- Wazuh Access Log Auditing
- CIS Controls 5/8

## Residual Risk
Low  
**Residual Score:** 3

## KRI
- Privilege exception requests
- Abnormal database query alerts

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-009: Unpatched Operating System & Software Vulnerabilities

## Risk Description
Attackers exploit known vulnerabilities on outdated servers and workstations to achieve remote code execution.

| Attribute | Details |
|---|---|
| Risk Category | Operational |
| Threat Source | Automated Vulnerability Scanners / Exploit Kits |
| Vulnerability | Finding 005 — Patch Management Delays Exceeding 90 Days |
| Affected Assets | Internal Servers and Workstations |
| Likelihood | 4 |
| Impact | 3 |
| Inherent Risk Score | 12 |
| ALE | $130,000 |
| Risk Owner | Patch Management Lead |
| Treatment Decision | Mitigate |

## Planned Control(s)
- Automated Vulnerability Scanning
- Monthly Patch Management Program
- CIS Control 7

## Residual Risk
Low  
**Residual Score:** 3

## KRI
- Mean Time to Patch critical vulnerabilities
- Number of overdue assets

## Review Date
October 22, 2026 (Quarterly)

---

# RISK-010: Phishing & Business Email Compromise (BEC)

## Risk Description
Employees fall victim to sophisticated phishing campaigns resulting in credential theft or fraudulent transactions.

| Attribute | Details |
|---|---|
| Risk Category | Financial / Operational |
| Threat Source | Social Engineering Groups |
| Vulnerability | Finding 031 — Lack of Phishing Training and Advanced Email Filtering |
| Affected Asset | Employee Email Accounts |
| Likelihood | 4 |
| Impact | 2 |
| Inherent Risk Score | 8 |
| ALE | $95,000 |
| Risk Owner | HR / Security Awareness Lead |
| Treatment Decision | Mitigate |

## Planned Control(s)
- Email Gateway Security Rules
- Security Awareness Training
- CIS Control 9

## Residual Risk
Low  
**Residual Score:** 2

## KRI
- Phishing simulation failure rate
- Reported suspicious email volume

## Review Date
October 22, 2026 (Quarterly)

---

# Risk Register Governance Note

This Risk Register is maintained centrally by the **Security Department** under the supervision of the Security Analyst and reviewed collaboratively with IT leadership.

The register is formally reviewed:

- Monthly for treatment progress tracking
- Quarterly for risk score reassessment
- During major infrastructure or operational changes
- Following significant security incidents
- When critical zero-day vulnerabilities affect MedDefense systems

When Key Risk Indicators (KRIs) exceed established thresholds, an automatic escalation notification is generated for:

- Chief Information Security Officer (CISO)
- IT Infrastructure Manager
- Relevant Risk Owners

The escalation process triggers immediate investigation, corrective action, and operational adjustments to restore MedDefense’s cybersecurity risk posture to acceptable levels.

---

