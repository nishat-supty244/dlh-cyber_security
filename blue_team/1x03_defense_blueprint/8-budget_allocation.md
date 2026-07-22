# 8. The Budget Game — Resource Allocation Under Budget Constraints


---

# Part 1 — The Selection

## Budget Summary

| Line Item | Amount |
|---|---:|
| Annual Security Budget | $120,000 |
| Total Spend | $120,000 |
| Budget Remaining | $0 |
| Budget Utilization | 100% |

The total spend equals the annual security budget of **$120,000**, leaving no remaining funds for additional controls.

---

# Funded Controls

| Control | Annual Cost | ALE Reduction | Net Value |
|---|---:|---:|---:|
| MFA Deployment (O365 E3, VPN, admin accounts) | $4,000 | $1,260,000 | $1,256,000 |
| Network Segmentation (VLAN implementation) | $15,000 | $1,050,000 | $1,035,000 |
| Offsite Backup Replication (AWS S3 Glacier immutable) | $12,000 | $970,000 | $958,000 |
| Enterprise SIEM Deployment (Wazuh, open-source) | $18,000 | $575,000 | $557,000 |
| Endpoint Detection and Response (EDR) Upgrade | $22,000 | $450,000 | $428,000 |
| Medical Device Network Isolation | $25,000 | $228,000 | $203,000 |
| Dedicated Firewall for Westside Clinic | $8,000 | $75,000 | $67,000 |
| **Total Spend** | **$104,000** | **$4,608,000** | **$4,504,000** |

---

# Funded Controls: Justification Summary

## MFA Deployment ($4,000)

Selected because it utilizes existing **O365 E3 enterprise licenses**, requiring primarily administrative configuration labor. MFA immediately reduces credential-stuffing attacks and unauthorized remote access compromise vectors while providing the highest net value among evaluated controls.

**Risk Reduction Impact:**
- Prevents stolen credential exploitation
- Protects VPN and administrative accounts
- Provides immediate security improvement at minimal cost

---

## Network Segmentation ($15,000)

Selected to eliminate the hospital’s flat internal network architecture. Core VLAN implementation prevents compromised workstations from enabling lateral movement across critical healthcare systems.

**Risk Reduction Impact:**
- Limits ransomware propagation
- Protects critical infrastructure zones
- Reduces internal attack surface

---

## Offsite Backup Replication ($12,000)

Selected to establish immutable recovery archives using **AWS S3 Glacier**. This ensures backup systems remain protected from ransomware operators attempting to encrypt recovery resources.

**Risk Reduction Impact:**
- Enables reliable disaster recovery
- Protects business continuity
- Reduces ransomware recovery impact

---

## Enterprise SIEM Deployment ($18,000)

Selected to deploy open-source **Wazuh SIEM** supported by internal engineering resources. It provides centralized logging, monitoring, and anomaly detection without expensive commercial licensing.

**Risk Reduction Impact:**
- Improves threat visibility
- Enables security event correlation
- Supports incident investigation

---

## Endpoint Detection and Response (EDR) Upgrade ($22,000)

Selected to replace traditional antivirus with **Sophos Intercept X** across workstations and servers. Behavioral detection capabilities improve prevention against advanced malware techniques.

**Risk Reduction Impact:**
- Detects process injection attacks
- Blocks fileless malware execution
- Improves endpoint resilience

---

## Medical Device Network Isolation ($25,000)

Selected to secure vulnerable legacy medical devices, including infusion pumps and imaging equipment, through micro-segmentation and specialized monitoring.

**Risk Reduction Impact:**
- Protects clinical technology
- Prevents unauthorized external communication
- Reduces healthcare safety risks

---

## Dedicated Firewall for Westside Clinic ($8,000)

Selected to replace the insecure consumer-grade router currently used at the branch office.

**Risk Reduction Impact:**
- Extends enterprise perimeter security
- Prevents uncontrolled branch access paths
- Improves network governance

---

# Deferred Controls

| Control | Reason for Deferral |
|---|---|
| 24/7 Managed Security Operations Center (SOC) ($110,000) | Deferred because funding this service would consume approximately 91% of available resources on a single outsourced capability. This would prevent implementation of foundational security engineering controls with higher ROI. Planned for FY2027 after security maturity improves. |

---

# Rejected Controls

| Control | Reason for Rejection |
|---|---|
| None | All evaluated controls demonstrated positive net value and alignment with CIS security principles. The SOC was deferred due to budget limitations rather than rejected. |

---

# Part 2 — The Opportunity Cost

For each deferred control, opportunity cost represents the remaining annualized risk exposure that remains unaddressed because the control was not funded.

| Deferred Control | Unaddressed ALE | Opportunity Cost Statement |
|---|---:|---|
| 24/7 Managed Security Operations Center (SOC) | $300,000 | By deferring 24/7 SOC staffing ($110,000 cost), MedDefense accepts approximately $300,000 in annual risk exposure due to the absence of continuous threat hunting and real-time incident monitoring outside business hours. |
| **Total Opportunity Cost** | **$300,000** | MedDefense knowingly accepts $300,000 in residual annual risk exposure until additional managed security funding becomes available. |

---

# Rejected Controls: Opportunity Cost

| Rejected Control | Unaddressed ALE | Opportunity Cost Statement |
|---|---:|---|
| None | $0 | No controls were rejected outright because all evaluated controls provided positive risk reduction value. |

---

# Part 3 — The Alternative

# Alternative Allocation: Lean Security Baseline

This alternative evaluates whether similar security improvements can be achieved with a reduced upfront investment.

| Control | Annual Cost | ALE Reduction | Net Value |
|---|---:|---:|---:|
| MFA Deployment | $4,000 | $1,260,000 | $1,256,000 |
| Network Segmentation | $15,000 | $1,050,000 | $1,035,000 |
| Offsite Immutable Backups | $12,000 | $970,000 | $958,000 |
| Open-Source SIEM | $18,000 | $575,000 | $557,000 |
| Westside Clinic Firewall | $8,000 | $75,000 | $67,000 |
| **Total Spend** | **$57,000** | **$3,930,000** | **$3,873,000** |

---

# Alternative Allocation Analysis

The alternative allocation leaves **$63,000 unused** but removes two critical protections:

- Endpoint Detection and Response (EDR)
- Medical Device Network Isolation

This creates significant residual risk for clinical endpoints and legacy healthcare systems.

---

# Comparison

| Metric | Primary Recommendation | Alternative Allocation |
|---|---:|---:|
| Total Spend | $104,000 | $57,000 |
| Budget Remaining | $16,000 | $63,000 |
| ALE Reduction | $4,608,000 | $3,930,000 |
| Net Value | $4,504,000 | $3,873,000 |
| Endpoint Protection | Upgraded EDR (Intercept X) | Basic Baseline Only |
| Medical Devices Secured | Yes — Isolated & Monitored | No — Unprotected |

---

# Conclusion

Although the alternative allocation reduces upfront spending by **$47,000**, it sacrifices **$678,000 in total risk reduction** by leaving clinical endpoints vulnerable to behavioral malware and medical devices exposed to internal reconnaissance and exploitation.

Given MedDefense’s healthcare regulatory obligations, operational requirements, and board-level risk tolerance, the primary recommendation provides the strongest security posture by:

- Closing critical attack vectors
- Maximizing risk reduction per dollar invested
- Protecting patient-impacting systems
- Maintaining a **$16,000 contingency reserve** within the $120,000 budget limit

The recommended allocation represents the optimal balance between financial efficiency, cybersecurity maturity, and healthcare operational resilience.

---
