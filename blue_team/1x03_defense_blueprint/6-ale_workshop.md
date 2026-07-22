# ALE Workshop: Quantitative Risk Analysis & Control Investment

## Risk 1: Ransomware via Exposed RDP and Unpatched SMB Vulnerabilities

**Source:** GAP-002 + Finding 001 (RDP Exposed), Finding 004/006 (Unpatched OS) + Kill Chain #1 (Organized Crime / RaaS)  
**Asset:** Core Electronic Health Record (EHR) Database & Domain Controllers  

### Risk Calculation

| Metric | Value |
|---|---:|
| Asset Value (AV) | $3,500,000 |
| Replacement/Recovery Cost | $500,000 |
| Revenue Loss During Downtime | $2,000,000 ($400,000/day × 5 days) |
| Regulatory Penalties | $500,000 |
| Reputation/Patient Trust Impact | $500,000 |
| Exposure Factor (EF) | 80% |

**Reasoning:**  
RaaS deployment across domain controllers can encrypt core databases and Active Directory services, crippling approximately 80% of primary operational infrastructure.

### Single Loss Expectancy (SLE)

\[
SLE = AV \times EF
\]

\[
SLE = \$3,500,000 \times 0.80 = \$2,800,000
\]

### Annualized Rate of Occurrence (ARO)

**ARO:** 0.5 (Once every 2 years)

**Reasoning:**  
Healthcare organizations with exposed remote access and legacy SMB vulnerabilities are frequent targets for ransomware affiliates.

### Annualized Loss Expectancy (ALE)

\[
ALE = SLE \times ARO
\]

\[
ALE = \$2,800,000 \times 0.5 = \$1,400,000
\]

### Proposed Control

**Control:**  
Enforce mandatory MFA on all remote access points and deploy automated emergency patching.

**Framework Mapping:** CIS Control 6 & Control 7

| Item | Value |
|---|---:|
| Annual Control Cost | $15,000 |
| Estimated ALE After Control | $140,000 |
| Risk Reduction | EF reduced to 15%, ARO reduced to 0.1 |

### Net Benefit

\[
\$1,400,000 - \$140,000 - \$15,000
\]

**Net Benefit = $1,245,000/year**

---

# Risk 2: Flat Network Lateral Movement and Hospital-Wide Outbreak

**Source:** GAP-001 + Finding 003 (PostgreSQL Open), Finding 007 (LDAP Unsigned) + Kill Chain #1 & #3  
**Asset:** Internal Hospital Network Infrastructure & Broadcast Domain  

## Risk Calculation

| Metric | Value |
|---|---:|
| Asset Value (AV) | $5,000,000 |
| Replacement/Recovery Cost | $1,000,000 |
| Revenue Loss During Downtime | $2,500,000 ($500,000/day × 5 days) |
| Regulatory Penalties | $750,000 |
| Reputation/Patient Trust Impact | $750,000 |
| Exposure Factor (EF) | 60% |

**Reasoning:**  
A flat internal network allows malware to move freely from administrative systems into clinical devices and imaging infrastructure.

## Single Loss Expectancy (SLE)

\[
SLE = \$5,000,000 \times 0.60
\]

**SLE = $3,000,000**

## Annualized Rate of Occurrence (ARO)

**ARO:** 0.4 (Once every 2.5 years)

**Reasoning:**  
Zero internal segmentation and exposed services allow rapid escalation after initial compromise.

## Annualized Loss Expectancy (ALE)

\[
ALE = \$3,000,000 \times 0.4
\]

**ALE = $1,200,000**

## Proposed Control

**Control:**  
Implement VLAN segmentation and inter-VLAN firewall rules.

**Framework Mapping:** CIS Control 12

| Item | Value |
|---|---:|
| Annual Control Cost | $25,000 |
| Estimated ALE After Control | $150,000 |
| Risk Reduction | EF reduced to 10%, ARO reduced to 0.05 |

## Net Benefit

\[
\$1,200,000 - \$150,000 - \$25,000
\]

**Net Benefit = $1,025,000/year**

---

# Risk 3: Unverified Backups Vulnerable to Ransomware Destruction

**Source:** GAP-005 + Finding 011 (Local Backups Accessible) + Kill Chain #1 (RaaS Extortion)  
**Asset:** Enterprise Backup Archives and Historical Data Repositories  

## Risk Calculation

| Metric | Value |
|---|---:|
| Asset Value (AV) | $4,000,000 |
| Replacement/Recovery Cost | $2,000,000 |
| Revenue Loss During Downtime | $1,200,000 |
| Regulatory Penalties | $400,000 |
| Reputation/Patient Trust Impact | $400,000 |
| Exposure Factor (EF) | 75% |

**Reasoning:**  
Ransomware operators commonly delete accessible backups before encryption, eliminating recovery options.

## Single Loss Expectancy (SLE)

\[
SLE = \$4,000,000 \times 0.75
\]

**SLE = $3,000,000**

## Annualized Rate of Occurrence (ARO)

**ARO:** 0.33 (Once every 3 years)

## Annualized Loss Expectancy (ALE)

\[
ALE = \$3,000,000 \times 0.33
\]

**ALE = $990,000**

## Proposed Control

**Control:**  
Deploy immutable, air-gapped backup storage and monthly restoration testing.

**Framework Mapping:** CIS Control 11

| Item | Value |
|---|---:|
| Annual Control Cost | $18,000 |
| Estimated ALE After Control | $20,000 |
| Risk Reduction | EF reduced to 5%, ARO reduced to 0.05 |

## Net Benefit

\[
\$990,000 - \$20,000 - \$18,000
\]

**Net Benefit = $952,000/year**

---

# Risk 4: Data Exfiltration via Compromised Credentials / Missing SIEM

**Source:** GAP-004 + Finding 008/009 (No Logging/SIEM) + Kill Chain #2 (Nation-State Exfiltration)  
**Asset:** Patient Electronic Health Records Database (50,000 Records)

## Risk Calculation

| Metric | Value |
|---|---:|
| Asset Value (AV) | $2,500,000 |
| Replacement/Recovery Cost | $200,000 |
| Revenue Loss | $0 |
| Regulatory Penalties | $1,500,000 |
| Reputation/Patient Trust Impact | $800,000 |
| Exposure Factor (EF) | 100% |

**Reasoning:**  
Without monitoring controls, attackers can silently exfiltrate the complete targeted record set.

## Single Loss Expectancy (SLE)

\[
SLE = \$2,500,000 \times 1.00
\]

**SLE = $2,500,000**

## Annualized Rate of Occurrence (ARO)

**ARO:** 0.25 (Once every 4 years)

## Annualized Loss Expectancy (ALE)

\[
ALE = \$2,500,000 \times 0.25
\]

**ALE = $625,000**

## Proposed Control

**Control:**  
Deploy centralized log aggregation and SIEM monitoring.

**Framework Mapping:** CIS Control 8

| Item | Value |
|---|---:|
| Annual Control Cost | $20,000 |
| Estimated ALE After Control | $50,000 |
| Risk Reduction | EF reduced to 20%, ARO reduced to 0.05 |

## Net Benefit

\[
\$625,000 - \$50,000 - \$20,000
\]

**Net Benefit = $555,000/year**

---

# Risk 5: Medical Device Exploitation (Infusion Pumps / Default Credentials)

**Source:** GAP-007 + Finding 010 (BD Alaris Default Credentials) + Kill Chain #3  
**Asset:** Connected Biomedical IoT Infrastructure  

## Risk Calculation

| Metric | Value |
|---|---:|
| Asset Value (AV) | $1,200,000 |
| Replacement/Recovery Cost | $400,000 |
| Revenue Loss During Downtime | $300,000 |
| Regulatory Penalties | $250,000 |
| Reputation/Patient Trust Impact | $250,000 |
| Exposure Factor (EF) | 40% |

**Reasoning:**  
Default credentials on biomedical devices allow automated exploitation and disruption of clinical workflows.

## Single Loss Expectancy (SLE)

\[
SLE = \$1,200,000 \times 0.40
\]

**SLE = $480,000**

## Annualized Rate of Occurrence (ARO)

**ARO:** 0.5 (Once every 2 years)

## Annualized Loss Expectancy (ALE)

\[
ALE = \$480,000 \times 0.5
\]

**ALE = $240,000**

## Proposed Control

**Control:**  
Enforce secure configuration baselines and rotate all default vendor passwords.

**Framework Mapping:** CIS Control 4

| Item | Value |
|---|---:|
| Annual Control Cost | $10,000 |
| Estimated ALE After Control | $12,000 |
| Risk Reduction | EF reduced to 10%, ARO reduced to 0.05 |

## Net Benefit

\[
\$240,000 - \$12,000 - \$10,000
\]

**Net Benefit = $218,000/year**

---

# Risk Prioritization by ALE

| Rank | Risk Description | Source / Gap | Asset Value (AV) | SLE | ARO | ALE Before Control | Control Cost | Net Benefit |
|---|---|---|---:|---:|---:|---:|---:|---:|
| 1 | Ransomware via RDP & Unpatched SMB | GAP-002 (Finding 001, 004, 006) | $3,500,000 | $2,800,000 | 0.5 | $1,400,000 | $15,000 | $1,245,000 |
| 2 | Flat Network Lateral Movement Outbreak | GAP-001 (Finding 003, 007) | $5,000,000 | $3,000,000 | 0.4 | $1,200,000 | $25,000 | $1,025,000 |
| 3 | Unverified Backups Vulnerable to Deletion | GAP-005 (Finding 011) | $4,000,000 | $3,000,000 | 0.33 | $990,000 | $18,000 | $952,000 |
| 4 | Data Exfiltration via Missing SIEM | GAP-004 (Finding 008, 009) | $2,500,000 | $2,500,000 | 0.25 | $625,000 | $20,000 | $555,000 |
| 5 | Medical Device Default Credential Exploits | GAP-007 (Finding 010) | $1,200,000 | $480,000 | 0.5 | $240,000 | $10,000 | $218,000 |

---

# ALE Investment Conclusion

The quantitative analysis demonstrates that cybersecurity controls provide significant financial risk reduction for MedDefense Health Systems.

The highest-value investments are:

1. **MFA + Emergency Patch Management**  
   - Annual Investment: $15,000  
   - Annual Risk Reduction Benefit: $1,245,000  

2. **Network Segmentation and Firewall Controls**  
   - Annual Investment: $25,000  
   - Annual Risk Reduction Benefit: $1,025,000  

3. **Immutable Backup Infrastructure**  
   - Annual Investment: $18,000  
   - Annual Risk Reduction Benefit: $952,000  

Implementing these controls reduces the organization’s ransomware exposure, limits lateral movement, improves regulatory compliance, and strengthens overall cybersecurity resilience.
