# The OSINT Hunt

This report identifies vulnerabilities that were **not detected during the original MedDefense vulnerability scan**. These issues were missed because they involve firmware, cloud services, or specialized applications that require authenticated access or vendor-specific scanning techniques.

---

# 1. FortiGate FortiOS Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | Fortinet PSIRT / NIST National Vulnerability Database (NVD) |
| **CVE** | **CVE-2025-43892** |
| **Associated Advisory** | FG-IR-26-154 |
| **Affected Product** | FortiGate 100F Firewall (FortiOS) |
| **Estimated CVSS** | 6.5–7.5 (Medium–High) |

---

## Why the Scan Missed It

The vulnerability scan focused primarily on internal hosts and application servers.

It did **not** have authenticated administrative access to:

- Inspect the firewall firmware version
- Analyze proprietary FortiOS components
- Evaluate the firewall control plane

As a result, firmware-specific vulnerabilities remained undetected.

---

## Potential Impact on MedDefense

Successful exploitation could allow an attacker to:

- Read portions of firewall memory
- Leak administrator credentials
- Steal active session tokens
- Expose routing and network configuration
- Compromise the organization's primary network perimeter

This could ultimately weaken perimeter security and facilitate further attacks against internal systems.

---

## Recommendation

MedDefense should:

- Audit the installed FortiOS firmware version.
- Review Fortinet Advisory **FG-IR-26-154**.
- Upgrade the firewall to the latest supported FortiOS release.
- Apply all vendor security patches.

---

# 2. Microsoft Office 365 / Microsoft Entra ID Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | Microsoft Security Advisories / CISA Alerts |
| **CVE** | None (Technique-based attack) |
| **Attack Technique** | Adversary-in-the-Middle (AiTM) Phishing / Session Hijacking |
| **Affected Product** | Microsoft Office 365 E3 / Microsoft Entra ID |
| **Severity** | Critical |

---

## Why the Scan Missed It

Traditional vulnerability scanners are designed to inspect:

- On-premises hosts
- Network services
- Installed software

They cannot assess cloud-native security controls such as:

- Conditional Access policies
- Identity Provider (IdP) configuration
- Session management
- Authentication policies
- Microsoft Entra ID tenant settings

---

## Potential Impact on MedDefense

If MedDefense relies on Microsoft 365 for daily operations, an AiTM phishing attack could enable attackers to:

- Bypass Multi-Factor Authentication (MFA)
- Steal authenticated session cookies
- Access employee email accounts
- Read patient communications
- Access cloud-based documents
- Maintain persistent access without triggering password changes

---

## Recommendation

To reduce this risk, MedDefense should:

- Deploy phishing-resistant MFA (FIDO2 security keys or Certificate-Based Authentication).
- Enforce Microsoft Entra Conditional Access policies.
- Disable legacy authentication protocols.
- Monitor identity sign-in logs for suspicious activity.

---

# 3. Synology DSM Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | Synology Security Advisory / NIST National Vulnerability Database (NVD) |
| **CVE** | **CVE-2024-0854** |
| **Affected Product** | Synology DiskStation Manager (DSM 7) |
| **Estimated CVSS** | 5.4–6.5 (Moderate–Important) |

---

## Why the Scan Missed It

Although the vulnerability scanner detected the NAS device as a live host, it lacked:

- Administrative credentials
- DSM application-layer plugins
- Version fingerprinting capabilities

Without authenticated scanning, the exact DSM version and associated vulnerabilities could not be identified.

---

## Potential Impact on MedDefense

An attacker could exploit the open redirect vulnerability to:

- Create convincing phishing links
- Redirect administrators to malicious websites
- Steal administrative credentials
- Deliver malicious payloads
- Abuse the trusted reputation of the internal backup server

Compromising the backup infrastructure could also threaten business continuity and disaster recovery capabilities.

---

## Recommendation

MedDefense should:

- Upgrade Synology DSM to the latest patched release.
- Disable public access to DSM management interfaces.
- Restrict ports **5000** and **5001** to a dedicated management VLAN.
- Limit administrative access using firewall rules and network segmentation.

---

# Summary Table

| Vulnerability | Affected Product | Why It Was Missed | Severity | Recommended Action |
|--------------|------------------|-------------------|----------|--------------------|
| **CVE-2025-43892** | FortiGate 100F (FortiOS) | Firewall firmware was not authenticated or inspected | Medium–High | Update FortiOS and apply vendor patches |
| **AiTM Session Hijacking** | Microsoft Office 365 / Entra ID | Cloud identity services were outside the scan scope | Critical | Implement phishing-resistant MFA and Conditional Access |
| **CVE-2024-0854** | Synology DSM 7 | Scanner lacked authenticated DSM version detection | Moderate–Important | Upgrade DSM, restrict management ports, and isolate NAS on a management VLAN |

---

# Conclusion

The MedDefense vulnerability assessment demonstrates that automated infrastructure scans provide only **partial visibility** into an organization's security posture. Critical risks affecting **network appliances**, **cloud identity platforms**, and **specialized storage systems** may remain undetected without authenticated scanning, cloud security assessments, and vendor-specific vulnerability management.

To strengthen its overall security posture, MedDefense should complement traditional vulnerability scanning with firmware management, cloud configuration reviews, authenticated application assessments, and continuous monitoring of vendor security advisories.
