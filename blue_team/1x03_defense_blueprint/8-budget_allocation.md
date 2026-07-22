# The Budget Game

## Part 1 — The Selection

Based on the Cost-Benefit Analysis from Task 7, MedDefense can assemble an optimal cybersecurity control portfolio that maximizes risk reduction while strictly respecting the **$120,000 annual budget limit**.

---

# Funded Controls

## 1. MFA Deployment on VPN and Administrative Accounts

**Cost:** $4,000  

**Decision:** Funded  

**Purpose:**
- Eliminates credential-stuffing attacks.
- Prevents unauthorized remote access.
- Strengthens authentication for privileged accounts.

---

## 2. Network Segmentation (VLAN Implementation)

**Cost:** $15,000  

**Decision:** Funded  

**Purpose:**
- Breaks the existing flat network architecture.
- Restricts attacker lateral movement.
- Prevents small compromises from escalating into hospital-wide incidents.

---

## 3. Offsite Backup Replication (AWS S3 Glacier Immutable)

**Cost:** $12,000  

**Decision:** Funded  

**Purpose:**
- Provides immutable ransomware-resistant recovery points.
- Prevents attackers from deleting backup repositories.
- Improves business continuity and disaster recovery readiness.

---

## 4. Enterprise SIEM Deployment (Wazuh Open-Source)

**Cost:** $18,000  

**Decision:** Funded  

**Purpose:**
- Establishes centralized log collection.
- Enables continuous security monitoring.
- Improves detection and incident response capabilities.

---

## 5. Endpoint Detection and Response (EDR) Upgrade

**Cost:** $22,000  

**Decision:** Funded  

**Purpose:**
- Replaces traditional signature-based antivirus.
- Provides behavioral malware detection.
- Protects against ransomware execution, process injection, and fileless attacks.

---

## 6. Full Medical Device Network Isolation

**Cost:** $25,000  

**Decision:** Funded  

**Purpose:**
- Protects vulnerable legacy infusion pumps and imaging devices.
- Reduces exposure to unauthorized access.
- Prevents biomedical systems from becoming attack entry points.

---

## 7. Dedicated Firewall for Westside Clinic

**Cost:** $8,000  

**Decision:** Funded  

**Purpose:**
- Replaces insecure consumer-grade branch router.
- Provides enterprise-level network protection.
- Prevents branch compromise from affecting core hospital infrastructure.

---

# Deferred Controls

## 24/7 Security Operations Center Staffing (Outsourced Managed SOC)

**Cost:** $110,000/year  

**Decision:** Deferred  

## Reasoning

The managed SOC provides positive security value; however, funding it would consume approximately **91% of the total annual security budget**.

This would reduce the ability to implement foundational engineering controls, including:

- MFA deployment
- Network segmentation
- Immutable backups
- SIEM monitoring
- EDR protection
- Medical device isolation

These controls provide significantly higher immediate risk reduction and return on investment.

**Decision:**  
Deferred until FY2027 after cybersecurity fundamentals and operational maturity have been established.

---

# Rejected Controls

**None**

All eight evaluated controls demonstrated:

- Positive net financial value
- Alignment with CIS Controls
- Meaningful risk reduction benefits

The Managed SOC is **deferred, not rejected**, due to current capital constraints.

---

# Budget Usage and Remaining-Budget Anchors

| Category | Amount |
|---|---:|
| Total Budget Limit | $120,000 |
| Total Security Investment | $104,000 |
| Remaining Budget Reserve | $16,000 |

## Remaining Budget Purpose

The remaining $16,000 will be maintained as a contingency reserve for:

- Emergency licensing requirements
- Hardware replacement
- Critical vulnerability remediation
- Unexpected security infrastructure needs

---

# Part 2 — The Opportunity Cost

By deferring the Managed SOC, MedDefense accepts a measurable residual risk exposure.

## Opportunity-Cost Statement

By deferring **24/7 Security Operations Center Staffing**, MedDefense accepts an estimated:

\[
\$300,000
\]

in annual risk exposure.

This remaining exposure exists because the organization lacks:

- Continuous threat hunting
- After-hours alert monitoring
- Real-time incident investigation
- Dedicated security response coverage

The organization intentionally accepts this residual risk to prioritize higher-impact security engineering improvements within the current budget.

---

# Part 3 — The Alternative

## Alternative Allocation Proposal

To evaluate whether a lower-cost portfolio could achieve comparable risk reduction, an alternative security investment strategy was analyzed.

---

# Alternative Funded Controls

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

The alternative strategy removes:

| Control | Cost | Security Impact |
|---|---:|---|
| EDR Upgrade | $22,000 | Leaves endpoint malware detection weaker |
| Medical Device Isolation | $25,000 | Leaves biomedical devices exposed to internal threats |

---

# Comparison and Trade-Off Analysis

## Primary Recommendation Portfolio

### Total Risk Reduction

| Control | Annual ALE Reduction |
|---|---:|
| MFA Deployment | $1,260,000 |
| Network Segmentation | $1,050,000 |
| Immutable Backups | $970,000 |
| SIEM Deployment | $575,000 |
| EDR Upgrade | $450,000 |
| Medical Device Isolation | $228,000 |
| Westside Clinic Firewall | $75,000 |

### Total Annual Risk Reduction

\[
\mathbf{\$4,608,000}
\]

**Investment Cost:** $104,000

---

## Alternative Portfolio

### Total Risk Reduction

| Control | Annual ALE Reduction |
|---|---:|
| MFA Deployment | $1,260,000 |
| Network Segmentation | $1,050,000 |
| Immutable Backups | $970,000 |
| SIEM Deployment | $575,000 |
| Westside Clinic Firewall | $75,000 |

### Total Annual Risk Reduction

\[
\mathbf{\$3,930,000}
\]

**Investment Cost:** $57,000

---

# Trade-Off Summary

| Metric | Primary Recommendation | Alternative Allocation |
|---|---:|---:|
| Total Investment | $104,000 | $57,000 |
| Annual Risk Reduction | $4,608,000 | $3,930,000 |
| Cost Difference | +$47,000 | — |
| Additional Risk Reduction | +$678,000 | — |

---

# Final Recommendation

While the alternative portfolio saves **$47,000** in investment cost, it sacrifices approximately:

\[
\$678,000
\]

in annual risk reduction.

The primary recommendation provides superior security value by addressing critical healthcare attack vectors, including:

- Ransomware execution
- Endpoint compromise
- Biomedical device exploitation
- Internal network escalation

Given MedDefense’s strict healthcare regulatory environment, patient safety requirements, and board-level risk tolerance, the recommended portfolio represents the most effective use of available cybersecurity funding.
