# The Cost-Benefit Analysis

## Control 1: MFA Deployment on VPN and Administrative Accounts

**CIS Control Reference:** CIS Control 6 (Access Control Management)  

### Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $4,000 |
| Cost Breakdown | $0 license (existing O365 E3 features) + $4,000 administrative configuration and deployment labor |

### Risk Addressed

- Ransomware via RDP & Unpatched SMB (Risk #1)

### Financial Analysis

| Metric | Value |
|---|---:|
| Initial ALE | $1,400,000 |
| Post-Control ALE | $140,000 |
| ALE Reduction | $1,260,000 |
| Control Cost | $4,000 |
| Net Value | $1,256,000 |

### Verdict

**Justified**

### Recommendation

Implement immediately. MFA provides the highest ROI by eliminating credential-stuffing and compromised-password entry vectors at minimal deployment cost.

---

# Control 2: Network Segmentation (VLAN Implementation)

**CIS Control Reference:** CIS Control 12 (Network Infrastructure Management)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $15,000 |
| Cost Breakdown | $5,000 switch hardware/licensing upgrades + $10,000 professional services and engineering labor |

## Risk Addressed

- Flat Network Lateral Movement Outbreak (Risk #2)

## Financial Analysis

| Metric | Value |
|---|---:|
| Initial ALE | $1,200,000 |
| Post-Control ALE | $150,000 |
| ALE Reduction | $1,050,000 |
| Control Cost | $15,000 |
| Net Value | $1,035,000 |

## Verdict

**Justified**

## Recommendation

Implement. Network segmentation prevents small workstation compromises from escalating into hospital-wide security incidents.

---

# Control 3: Offsite Backup Replication (AWS S3 Glacier Immutable)

**CIS Control Reference:** CIS Control 11 (Data Recovery)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $12,000 |
| Cost Breakdown | $6,000 cloud storage subscription + $6,000 cloud architecture and backup pipeline configuration |

## Risk Addressed

- Unverified Backups Vulnerable to Ransomware Deletion (Risk #3)

## Financial Analysis

| Metric | Value |
|---|---:|
| Initial ALE | $990,000 |
| Post-Control ALE | $20,000 |
| ALE Reduction | $970,000 |
| Control Cost | $12,000 |
| Net Value | $958,000 |

## Verdict

**Justified**

## Recommendation

Implement. Immutable offsite backups provide ransomware-resistant recovery points and reduce dependence on attacker-controlled recovery options.

---

# Control 4: Enterprise SIEM Deployment (Wazuh Open-Source)

**CIS Control Reference:** CIS Control 8 (Audit Log Management)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $18,000 |
| Cost Breakdown | $0 software license (open-source Wazuh) + $18,000 engineering and contractor deployment labor |

## Risk Addressed

- Data Exfiltration via Missing SIEM (Risk #4)

## Financial Analysis

| Metric | Value |
|---|---:|
| Initial ALE | $625,000 |
| Post-Control ALE | $50,000 |
| ALE Reduction | $575,000 |
| Control Cost | $18,000 |
| Net Value | $557,000 |

## Verdict

**Justified**

## Recommendation

Implement. Centralized logging and anomaly detection provide critical visibility for a resource-limited security team.

---

# Control 5: Endpoint Detection and Response (EDR) Upgrade

**CIS Control Reference:** CIS Control 10 (Malware Defenses)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $22,000 |
| Cost Breakdown | $15,000 Sophos Intercept X licensing upgrade + $7,000 deployment labor |

## Risk Addressed

- Ransomware and Malware Execution Across Endpoints

## Financial Analysis

| Metric | Value |
|---|---:|
| ALE Reduction | $450,000 |
| Control Cost | $22,000 |
| Net Value | $428,000 |

## Verdict

**Justified**

## Recommendation

Implement. Replace traditional signature-based antivirus with behavioral detection capable of stopping ransomware, process injection, and fileless attacks.

---

# Control 6: Full Medical Device Network Isolation with Dedicated Monitoring

**CIS Control Reference:** CIS Control 12 & Control 13 (Network Infrastructure & Monitoring)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $25,000 |
| Cost Breakdown | $10,000 micro-segmentation hardware + $15,000 healthcare IoT monitoring configuration |

## Risk Addressed

- Medical Device Default Credential Exploits (Risk #5)

## Financial Analysis

| Metric | Value |
|---|---:|
| Initial ALE | $240,000 |
| Post-Control ALE | $12,000 |
| ALE Reduction | $228,000 |
| Control Cost | $25,000 |
| Net Value | $203,000 |

## Verdict

**Justified**

## Recommendation

Implement. Isolation protects vulnerable infusion pumps and imaging devices from unauthorized access and lateral movement.

---

# Control 7: Dedicated Firewall for Westside Clinic

**CIS Control Reference:** CIS Control 12 (Network Infrastructure Management)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $8,000 |
| Cost Breakdown | $4,000 enterprise firewall appliance + $4,000 configuration and remote deployment |

## Risk Addressed

- Branch Office Compromise and Lateral Pivot

## Financial Analysis

| Metric | Value |
|---|---:|
| ALE Reduction | $75,000 |
| Control Cost | $8,000 |
| Net Value | $67,000 |

## Verdict

**Justified**

## Recommendation

Implement. Replace the insecure consumer-grade router with an enterprise firewall to improve branch security.

---

# Control 8: 24/7 Security Operations Center Staffing (Managed SOC)

**CIS Control Reference:** CIS Control 8 & Control 13 (Audit Logging & Network Monitoring)

## Cost Details

| Item | Value |
|---|---:|
| Annual Cost | $110,000 |
| Cost Breakdown | Managed SOC service contract |

## Risk Addressed

- All Enterprise Threats (General Threat Detection)

## Financial Analysis

| Metric | Value |
|---|---:|
| ALE Reduction | $300,000 |
| Control Cost | $110,000 |
| Net Value | $190,000 |

## Verdict

**Not Justified Within Current Budget Constraint**

## Recommendation

Defer. Although the control provides positive financial value, it consumes approximately 91% of the $120,000 annual security budget and prevents implementation of higher-value foundational security controls.

---

# Cost-Benefit Summary Table (Ranked by Net Value)

| Rank | Proposed Control | CIS Control | Annual Cost | ALE Reduction | Net Value | Verdict | Budget Status |
|---|---|---|---:|---:|---:|---|---|
| 1 | MFA Deployment (VPN & Admin Accounts) | CIS Control 6 | $4,000 | $1,260,000 | $1,256,000 | Justified | IMPLEMENT ($4,000 cumulative) |
| 2 | Network Segmentation (VLANs) | CIS Control 12 | $15,000 | $1,050,000 | $1,035,000 | Justified | IMPLEMENT ($19,000 cumulative) |
| 3 | Offsite AWS Glacier Immutable Backups | CIS Control 11 | $12,000 | $970,000 | $958,000 | Justified | IMPLEMENT ($31,000 cumulative) |
| 4 | Open-Source SIEM (Wazuh) | CIS Control 8 | $18,000 | $575,000 | $557,000 | Justified | IMPLEMENT ($49,000 cumulative) |
| 5 | EDR Upgrade (Sophos Intercept X) | CIS Control 10 | $22,000 | $450,000 | $428,000 | Justified | IMPLEMENT ($71,000 cumulative) |
| 6 | Medical Device Isolation | CIS Control 12/13 | $25,000 | $228,000 | $203,000 | Justified | IMPLEMENT ($96,000 cumulative) |
| 7 | Outsourced 24/7 Managed SOC | CIS Control 8/13 | $110,000 | $300,000 | $190,000 | Not Justified (Budget) | DEFER (Exceeds Budget Cap) |
| 8 | Westside Clinic Firewall | CIS Control 12 | $8,000 | $75,000 | $67,000 | Justified | IMPLEMENT (Within Remaining Budget) |

---

# Final Investment Recommendation

Based on quantitative risk reduction and available budget constraints, MedDefense should prioritize controls with the highest financial return:

1. **Deploy MFA across VPN and privileged accounts**
2. **Implement VLAN segmentation**
3. **Deploy immutable offsite backups**
4. **Implement centralized SIEM monitoring**
5. **Upgrade endpoint protection to EDR**
6. **Isolate medical device networks**
7. **Deploy Westside Clinic enterprise firewall**

The recommended implementation sequence achieves maximum risk reduction while maintaining the $120,000 annual cybersecurity investment constraint.
