# 5. The ALE Update

## Part 1 – Original vs. Updated ALE

### Single Loss Expectancy (SLE)

| **Metric** | **Value** |
|------------|-----------|
| **Single Loss Expectancy (SLE)** | **$1,500,000** |
| **Basis** | Estimated average impact of regional hospital ransomware incidents, including operational disruption, regulatory penalties, recovery expenses, and business interruption costs. |

---

## Original ARO & ALE (from 1x03)

| **Metric** | **Calculation** | **Result** |
|------------|-----------------|------------|
| **Original Annualized Rate of Occurrence (ARO)** | Estimated once every 5 years based on historical healthcare sector averages | **0.2** |
| **Original Annualized Loss Expectancy (ALE)** | `$1,500,000 × 0.2` | **$300,000 per year** |

### Original Risk Interpretation

Under the original risk model, ransomware represented a relatively low-frequency but high-impact event. With an ALE of approximately **$300,000 annually**, some security controls with significant implementation costs or operational impact could appear difficult to justify financially.

---

## Updated ARO & ALE (Crimson Tide Intelligence)

| **Metric** | **Calculation** | **Result** |
|------------|-----------------|------------|
| **Updated Annualized Rate of Occurrence (ARO)** | `5 confirmed hospital attacks × (365 / 10)` | **182.5** |
| **Updated Annualized Loss Expectancy (ALE)** | `$1,500,000 × 182.5` | **$273,750,000 per year** |

---

## Explanation of Change

The Annualized Rate of Occurrence (ARO) changed significantly because new threat intelligence converted a theoretical, long-term statistical risk into an active and localized threat campaign.

When a ransomware group such as **Crimson Tide** demonstrates repeated successful attacks within the same geographic region, MedDefense is no longer facing a passive industry-average risk. Instead, the organization is operating inside an active targeting window where the probability of attack is substantially increased.

The updated ALE reflects the reality that threat frequency, attacker capability, and regional targeting behavior must be incorporated into risk calculations.

---

# Part 2 – Budget Impact

## Shift in Cost-Benefit Conclusions

The updated ALE completely changes the financial justification for cybersecurity investments.

Previously:

- ALE: **$300,000/year**
- High-cost security controls required stronger financial justification.
- Some preventive measures could appear optional or lower priority.

After Crimson Tide intelligence:

- ALE: **$273.75 million/year**
- Any control that successfully prevents or reduces this attack chain produces significant financial value.
- Security investments become risk-reduction necessities rather than optional improvements.

---

## FortiGate Support Contract ROI ($2,400)

The **$2,400 FortiGate vendor support contract** provides extremely high return on investment because it enables immediate remediation of **CVE-2023-27997**, a critical perimeter vulnerability.

### ROI Assessment

| **Investment** | **Potential Loss Prevented** | **Business Impact** |
|----------------|------------------------------|---------------------|
| **$2,400 FortiGate support contract** | Potential $1.5M+ ransomware loss event | Eliminates a critical external attack path and reduces likelihood of enterprise compromise |

Compared with the potential financial impact of a successful ransomware incident, the cost of emergency patch enablement is negligible.

---

## Board Budget Approval Recommendation

**Recommendation: Approve immediate emergency cybersecurity funding.**

The Board should authorize spending beyond the original **$120,000 security budget framework** because MedDefense is facing an active regional ransomware campaign rather than a normal operational risk scenario.

Traditional procurement cycles and quarterly budgeting processes are designed for predictable business operations. They are not appropriate during an active cyber threat event where delays increase the probability of catastrophic operational disruption.

Immediate funding should support:

- FortiGate support contract renewal and emergency patching (**$2,400**)
- Rapid network micro-segmentation deployment
- Enterprise EDR expansion
- Backup protection and isolation improvements
- Managed incident response capabilities

---

## Final Risk Decision

The updated ALE demonstrates that delaying critical cybersecurity controls creates a significantly greater financial risk than the cost of implementing them. With a potential annualized exposure of **$273.75 million**, emergency security investments represent a necessary business protection measure rather than an additional expense.

Immediate remediation is financially justified, operationally necessary, and critical to maintaining patient care availability and organizational resilience.
