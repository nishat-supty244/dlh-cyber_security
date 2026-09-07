# Threat Priority Assessment

| Rank | Threat Actor Type | Primary Vector | Primary Target | Likelihood | Impact | Overall Priority | Key Gap | Recommended Action |
|------|-------------------|----------------|----------------|------------|--------|------------------|---------|--------------------|
| **1** | Ransomware Data Siege (Organized Crime) | VPN Exploit | EHR Database | Critical | Critical | **Critical** | NET-01 | **Short-term:** Segment network and implement MFA on VPN access. |
| **2** | Internal Data Theft (Malicious Insider) | Legitimate Access | EHR Database | High | Critical | **Critical** | SEC-04 | **Quick Win:** Deploy GPO controls to block unauthorized USB storage devices. |
| **3** | Credential Harvesting (Nation-State APT) | Spear Phishing | Active Directory | High | Critical | **Critical** | IAM-01 | **Short-term:** Enforce MFA on all privileged accounts. |
| **4** | Supply Chain Pivot (Nation-State APT) | Vendor Access | EHR Application | Medium | High | **High** | VEND-01 | **Long-term:** Implement a jump-host/bastion architecture with MFA. |
| **5** | Exploitation of End-of-Life Systems (Unskilled Attacker) | Vulnerable Software | PACS / MRI System | High | Medium | **Medium** | VULN-01 | **Long-term:** Replace or isolate unsupported legacy systems. |

---

# Strategic Recommendation

If MedDefense could only fund **two defensive initiatives** during the next quarter, priority should be given to:

## 1. Network Segmentation (NET-01)

Network segmentation provides the highest security impact because it limits an attacker's ability to move laterally after gaining initial access.

It protects critical assets by preventing attackers from moving freely from low-trust entry points such as:

- Compromised VPN accounts
- Infected workstations
- Phishing-based access

toward high-value systems including:

- EHR databases
- Domain Controllers
- Backup infrastructure

By separating critical environments, MedDefense introduces additional security barriers that slow attackers and improve detection opportunities.

---

## 2. Privileged Access Management (PAM) with MFA (IAM-01)

Enforcing MFA and stronger privileged access controls directly addresses the most common attack paths involving:

- Credential harvesting
- Administrative account compromise
- Vendor account abuse

Priority implementation should include:

- MFA for all administrative accounts
- MFA for vendor access
- Privileged session monitoring
- Least-privilege access enforcement

---

# Overall Security Impact

Together, **Network Segmentation (NET-01)** and **PAM with MFA (IAM-01)** provide the highest return on security investment by forcing attackers to overcome multiple security barriers instead of allowing unrestricted movement through a flat, unverified environment.

These controls transform MedDefense from a network where a single compromise can become an enterprise-wide incident into a layered defense model where:

- Access is verified
- Movement is restricted
- Privileged activity is monitored
- Critical healthcare systems receive stronger protection
