# The Security Strategy Document

 

---

# 1. Executive Summary

MedDefense Health Systems currently operates under a critical risk posture characterized by:

- Flat network architecture
- Absence of centralized logging
- Unsegmented legacy medical devices
- Widespread un-multifaceted remote access points

These weaknesses expose patient care systems and Electronic Health Records (EHR) to imminent ransomware disruption.

To resolve these vulnerabilities within the hard annual budget cap of **$120,000**, MedDefense adopts a risk-based defense strategy aligned with:

- **NIST Cybersecurity Framework (CSF) 2.0**
- **CIS Controls v8**

This strategy invests **$120,000** into high-impact foundational safeguards, achieving an estimated aggregate:

> **Annual Loss Expectation (ALE) Reduction: $5,170,000**

---

## Top 3 Priority Actions

### 1. Enforce Multi-Factor Authentication (MFA)

Implement MFA across:

- All remote access VPN gateways
- Administrative accounts
- Privileged access systems

### 2. Deploy Core Network Segmentation

Implement VLAN-based segmentation to:

- Prevent lateral movement
- Isolate clinical systems
- Protect biomedical devices

### 3. Establish Centralized Security Monitoring

Deploy:

- SIEM-based centralized logging
- Immutable cloud backups

Objectives:

- Accelerate threat detection
- Enable ransomware recovery
- Improve forensic capability

---

# 2. Governance Framework

## Framework Selection Rationale

MedDefense adopts:

| Framework | Purpose |
|---|---|
| NIST CSF 2.0 | Strategic cybersecurity risk management |
| CIS Controls v8 | Technical security implementation baseline |

These frameworks provide:

- International recognition
- Audit readiness
- Healthcare infrastructure alignment

---

## NIST CSF Current Profile

| Function | Current State | Target |
|---|---|---|
| Identify | Tier 1 Immature | Tier 3 |
| Protect | Tier 1 Immature | Tier 3 |
| Detect | Tier 1 Immature | Tier 3 |
| Respond | Tier 1 Immature | Tier 3 |
| Recover | Tier 1 Immature | Tier 3 |

---

## CIS Controls Maturity

Current state:

- Ad-hoc **Tier 0**

Target:

- Implemented **Tier 2 security baseline**

Coverage:

- CIS Controls 1–18

---

## Governance Structure & Roles

| Role | Responsibility |
|---|---|
| Executive Board | Data control and strategic oversight |
| Clinical Department Heads (e.g., Dr. Patel) | Data ownership |
| Cloud / Third-party Vendors | Data processing |
| IT Director Sarah Park | Data custodianship |
| Fractional vISO | CISO governance function |

---

# 3. Quantitative Risk Analysis

## Top 5 Risks by Annual Loss Expectation (ALE)

| Risk ID | Risk Description | ALE | Inherent Score |
|---|---|---:|---:|
| RISK-001 | Credential Stuffing & Remote Access Compromise | $1,400,000 | 25 |
| RISK-002 | Flat Network Lateral Movement Outbreak | $1,200,000 | 20 |
| RISK-003 | Unverified Backup Destruction via Ransomware | $990,000 | 15 |
| RISK-004 | Undetected Data Exfiltration & Dwell Time | $625,000 | 16 |
| RISK-005 | Advanced Endpoint Malware & Fileless Execution | $450,000 | 16 |

---

## Risk Register Summary

- Total enterprise risks tracked: **10**
- Risks requiring mitigation: **8**
- Controlled acceptance decisions: **2**

---

## Risk Appetite Statement

MedDefense maintains:

### Low-to-Moderate Risk Appetite

For:

- Operational disruption
- Service interruptions

### Zero-Tolerance Risk Appetite

For:

- Patient safety impacts
- Healthcare continuity failures
- PHI integrity compromise

---

# 4. Control Strategy

## Cost-Benefit Analysis

Control investments prioritize:

- Maximum risk reduction per dollar
- Authentication security
- Endpoint protection
- Network segmentation

---

## Budget Allocation

**Total Security Investment Cap: $120,000**

| Security Control | Allocation |
|---|---:|
| Ecosystem & Endpoint Defense (EDR/MFA) | $26,000 |
| Network Segmentation & Firewalls | $23,000 |
| Cloud SIEM & Log Aggregation | $18,000 |
| Immutable Backup Replication | $12,000 |
| Contingency & Reserve | $41,000 |

---

## Control Mapping

Controls align with:

| Control | Framework Mapping |
|---|---|
| MFA Implementation | CIS 6.3 / 6.4 |
| VLAN Segmentation | CIS 12.1 / 12.2 |
| Logging & Monitoring | NIST Detect Function |
| Backup Protection | NIST Recover Function |

---

# Quick Wins (2 Weeks, $0 Cost)

Implemented immediately:

- Enforce administrator MFA
- Disable SMBv1
- Disable unnecessary RDP exposure
- Remove stale vendor accounts
- Enable Microsoft 365 Safe Links rewriting
- Enforce 5-minute screen lock policy

---

# 5. Architecture Recommendations

## Network Segmentation Design

Replace flat architecture with five security zones:

| VLAN | Zone | Purpose |
|---|---|---|
| VLAN 10 | Server Zone | Core infrastructure |
| VLAN 20 | Clinical Workstation Zone | Hospital user systems |
| VLAN 30 | Medical Device Zone | Biomedical equipment |
| VLAN 40 | Management Zone | Administrative systems |
| VLAN 50 | Guest/IoT Zone | External and IoT devices |

---

## Kill Chain Disruption Analysis

Security improvements disrupt attack paths through:

- Stateful firewall enforcement
- Default-deny inter-VLAN policies
- Restricted asset discovery

Result:

> 100% disruption of MedDefense's top 5 identified kill chains during lateral movement and discovery phases.

---

# 6. Policy Foundation

## Acceptable Use Policy (MED-POL-001)

Mandatory requirements:

- Acceptable technology usage
- Prohibition of unauthorized USB devices
- Prohibition of personal routers
- Mandatory MFA adoption
- Data classification handling
- Continuous monitoring acceptance

---

## Policy Roadmap

| Timeline | Policy |
|---|---|
| Q3 2026 | Incident Response Plan |
| Q4 2026 | Vendor Risk Management Policy |
| Q1 2027 | Data Retention & Privacy Policy |

---

# 7. Residual Risk Assessment

## Red Team Findings

Remaining attack paths:

- Human social engineering attacks
- Vishing campaigns
- Third-party vendor access tunnels

---

## Accepted Risks

### RISK-006: Windows XP MRI Workstation

Justification:

- Replacement cost: $2.1M lease penalty
- Network isolation implemented
- Compensating controls applied

---

### RISK-009: Legacy Archiving Server

Justification:

- Middleware rewrite cost: $85,000
- Restricted access
- Monitoring controls enabled

---

## Year 2 Security Priorities

Future initiatives:

1. Third-Party Risk Management (TPRM)
2. Zero Trust Network Access (ZTNA)
3. User Behavior Analytics (UBA)

---

# 8. Implementation Roadmap (6-Month Plan)

---

## Phase 1 — Months 1–2

### Activities

- Execute quick wins
- Procure EDR licenses
- Procure SIEM licenses
- Deploy administrative MFA
- Establish baseline GPOs

### Success Metrics

- 100% administrator MFA coverage
- Completion of zero-cost improvements

---

## Phase 2 — Months 3–4

### Activities

- Deploy VLAN segmentation
- Implement AWS immutable backups
- Deploy Sophos EDR
- Configure Wazuh SIEM telemetry

### Success Metrics

- Zero uncontrolled lateral traffic
- Active centralized log ingestion

---

## Phase 3 — Months 5–6

### Activities

- Conduct vulnerability assessments
- Perform incident response tabletop exercises
- Finalize security policy acknowledgments
- Optimize firewall rules

### Success Metrics

- Closed vulnerability backlog
- Verified recovery testing

---

# 9. Next Steps

This security strategy establishes the foundation for:

> **Project 1x04 — Cryptographic Foundation**

The next phase will transition MedDefense from perimeter-focused defense toward:

- Encryption at rest
- Encryption in transit
- Stronger data protection mechanisms

By executing this roadmap, MedDefense transforms from an exposed healthcare environment into:

- A resilient healthcare institution
- An auditable security environment
- A defensible cybersecurity architecture

---

**END OF DOCUMENT**
