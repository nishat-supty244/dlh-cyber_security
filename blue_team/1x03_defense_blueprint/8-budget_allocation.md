# The Budget Game

# Part 1 — The Selection

Based on the Cost-Benefit Analysis from Task 7, MedDefense can assemble an optimized cybersecurity control portfolio that maximizes risk reduction while remaining within the **$120,000 annual security budget constraint**.

## Funded Controls

**Total Spend: $104,000**

| Control | Cost | Risk Reduction Objective |
|---|---:|---|
| MFA Deployment on VPN and Administrative Accounts | $4,000 | Neutralizes credential-stuffing attacks and remote access compromise vectors |
| Network Segmentation / VLAN Implementation | $15,000 | Prevents lateral movement across the hospital network |
| Offsite AWS S3 Glacier Immutable Backups | $12,000 | Protects recovery points from ransomware deletion |
| Enterprise SIEM Deployment (Wazuh) | $18,000 | Provides centralized logging, monitoring, and threat detection |
| EDR Upgrade to Sophos Intercept X | $22,000 | Provides behavioral endpoint protection against ransomware and malware |
| Medical Device Network Isolation | $25,000 | Protects vulnerable infusion pumps and imaging devices |
| Dedicated Firewall for Westside Clinic | $8,000 | Replaces insecure consumer-grade routing infrastructure |

---

## Funded Portfolio Justification

### 1. MFA Deployment on VPN and Administrative Accounts ($4,000)

**Security Impact:**
- Eliminates password-only authentication risks.
- Blocks credential theft and brute-force access attempts.
- Protects remote administrative access paths.

---

### 2. Network Segmentation / VLAN Implementation ($15,000)

**Security Impact:**
- Breaks the existing flat network architecture.
- Limits attacker movement after initial compromise.
- Prevents workstation infections from becoming hospital-wide incidents.

---

### 3. Offsite AWS S3 Glacier Immutable Backups ($12,000)

**Security Impact:**
- Creates ransomware-resistant recovery points.
- Prevents attackers from destroying backup repositories.
- Improves business continuity and disaster recovery capabilities.

---

### 4. Enterprise SIEM Deployment via Wazuh ($18,000)

**Security Impact:**
- Establishes centralized security visibility.
- Enables anomaly detection and investigation.
- Improves incident response capability.

---

### 5. EDR Upgrade to Sophos Intercept X ($22,000)

**Security Impact:**
- Replaces traditional signature-based antivirus.
- Detects behavioral ransomware activity.
- Provides protection against:
  - Process injection
  - Fileless malware
  - Suspicious execution behavior

---

### 6. Medical Device Network Isolation ($25,000)

**Security Impact:**
- Segments vulnerable biomedical systems.
- Protects infusion pumps and imaging devices.
- Reduces risk from default credentials and unauthorized access.

---

### 7. Dedicated Firewall for Westside Clinic ($8,000)

**Security Impact:**
- Removes insecure consumer-grade network equipment.
- Provides enterprise-level traffic filtering.
- Prevents branch-office compromise from reaching hospital systems.

---

# Deferred Controls

## 24/7 Managed Security Operations Center (SOC) Staffing

**Cost:** $110,000/year

## Decision: Deferred

### Reasoning

Although the managed SOC provides positive financial value, implementing it would consume approximately **91% of the entire annual cybersecurity budget**.

Funding the SOC would prevent implementation of higher-priority foundational security controls:

- MFA
- Network segmentation
- Immutable backups
- SIEM monitoring
- EDR protection
- Medical device isolation

These engineering controls provide significantly higher return on investment and directly address existing critical vulnerabilities.

**Decision:**  
Deferred until FY2027 after cybersecurity fundamentals and operational maturity have been established.

---

# Rejected Controls

**None**

All evaluated controls demonstrated:

- Positive net financial value
- Alignment with CIS Controls
- Reduction of identified risks

The Managed SOC was not rejected due to technical limitations; it was only deferred because of current capital constraints.

---

# Budget Summary

| Category | Amount |
|---|---:|
| Total Annual Security Budget | $120,000 |
| Total Allocated Investment | $104,000 |
| Remaining Contingency Reserve | $16,000 |

## Contingency Purpose

The remaining $16,000 reserve will support:

- Emergency security licensing
- Hardware replacement
- Critical vulnerability remediation
- Unexpected infrastructure requirements

---

# Part 2 — The Opportunity Cost

Because the $120,000 budget cannot fund all evaluated controls simultaneously, deferring the Managed SOC creates a measurable remaining risk exposure.

## Opportunity Cost Statement

By deferring **24/7 Security Operations Center (SOC) Staffing ($110,000/year)**, MedDefense accepts approximately:

\[
\$300,000
\]

in annual residual risk exposure.

This represents the estimated ALE reduction that would have been gained through:

- Continuous threat monitoring
- 24/7 alert investigation
- Live incident response support
- After-hours attack detection

The organization accepts this exposure temporarily to prioritize foundational security improvements with higher immediate return.

---

# Part 3 — Alternative Security Portfolio Analysis

To determine whether a lower-cost portfolio could achieve similar results, an alternative allocation was evaluated.

---

# Alternative Allocation Proposal: Lean Security Baseline

## Funded Controls

| Control | Cost |
|---|---:|
| MFA Deployment | $4,000 |
| Network Segmentation | $15,000 |
| Offsite Immutable Backups | $12,000 |
| Open-Source SIEM (Wazuh) | $18,000 |
| Westside Clinic Firewall | $8,000 |

## Total Alternative Cost

\[
\$4,000 + \$15,000 + \$12,000 + \$18,000 + \$8,000
\]

**Total Cost = $57,000**

---

# Alternative Portfolio Omissions

The alternative portfolio excludes:

| Control | Cost | Impact |
|---|---:|---|
| EDR Upgrade | $22,000 | Leaves endpoint malware detection weaker |
| Medical Device Isolation | $25,000 | Leaves biomedical devices exposed |

---

# Portfolio Risk Reduction Comparison

## Primary Recommendation

### Total Annual ALE Reduction

| Control | ALE Reduction |
|---|---:|
| MFA Deployment | $1,260,000 |
| Network Segmentation | $1,050,000 |
| Immutable Backups | $970,000 |
| SIEM Deployment | $575,000 |
| EDR Upgrade | $450,000 |
| Medical Device Isolation | $228,000 |
| Westside Clinic Firewall | $75,000 |

### Total Risk Reduction

\[
\$1,260,000 + \$1,050,000 + \$970,000 + \$575,000 + \$450,000 + \$228,000 + \$75,000
\]

## **Total ALE Reduction = $4,608,000/year**

**Investment Cost:** $104,000

---

## Alternative Portfolio

### Total Annual ALE Reduction

| Control | ALE Reduction |
|---|---:|
| MFA Deployment | $1,260,000 |
| Network Segmentation | $1,050,000 |
| Immutable Backups | $970,000 |
| SIEM Deployment | $575,000 |
| Westside Clinic Firewall | $75,000 |

### Total Risk Reduction

\[
\$1,260,000 + \$1,050,000 + \$970,000 + \$575,000 + \$75,000
\]

## **Total ALE Reduction = $3,930,000/year**

**Investment Cost:** $57,000

---

# Trade-Off Analysis

| Metric | Primary Portfolio | Alternative Portfolio |
|---|---:|---:|
| Total Investment | $104,000 | $57,000 |
| Annual ALE Reduction | $4,608,000 | $3,930,000 |
| Additional Risk Reduction | +$678,000 | — |
| Remaining Vulnerabilities | Minimal | Endpoint & medical device exposure |

## Conclusion

Although the alternative portfolio saves **$47,000** in annual spending, it sacrifices approximately:

\[
\$678,000
\]

in annual risk reduction.

Given MedDefense’s healthcare environment, regulatory obligations, and patient safety requirements, the primary recommendation provides superior security value by addressing:

- Ransomware execution
- Endpoint compromise
- Biomedical device exploitation
- Network-based attack escalation

The recommended portfolio achieves the strongest balance between **financial efficiency, operational resilience, regulatory compliance, and patient safety protection**.
