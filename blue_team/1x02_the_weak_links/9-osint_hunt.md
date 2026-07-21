# The OSINT Hunt

This assessment identifies additional security risks discovered through **Open Source Intelligence (OSINT) research** that were not detected during the original vulnerability scan. These findings highlight gaps in traditional vulnerability scanning, especially for **network security appliances, cloud identity platforms, and backup infrastructure**.

---

# 1. FortiGate FortiOS Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | NVD Database Details for CVE-2024-23113 / Fortinet PSIRT Advisory FG-IR-24-029 |
| **CVE** | **CVE-2024-23113** |
| **Affected Product** | MedDefense Perimeter Firewall (FortiGate 100F running FortiOS) |
| **Severity** | Critical |
| **CVSS Base Score** | **9.8** |

---

## Why the Scan Missed It

The automated vulnerability scan was limited to:

- Internal application nodes
- Local subnet targets
- Standard network-accessible systems

The scan lacked:

- Authenticated administrative access
- FortiOS firmware inspection capability
- Proprietary protocol plugin support
- Visibility into firewall control plane components

Therefore, the scanner was unable to evaluate vulnerabilities affecting the FortiGate firewall firmware.

---

## Potential Impact on MedDefense

Successful exploitation could allow a remote attacker to:

- Execute unauthorized commands or code
- Take complete control of the perimeter firewall
- Modify firewall configurations
- Bypass network security controls
- Access restricted clinical network segments

A compromised firewall could provide attackers with a direct entry point into critical healthcare infrastructure.

---

## Recommendation

MedDefense should:

- Upgrade FortiOS immediately to a vendor-patched version:
  - **FortiOS 7.2.7 or later**
  - **FortiOS 7.0.14 or later**
- Restrict firewall administration interfaces to trusted internal VLANs.
- Enable strong administrator authentication.
- Continuously monitor firewall logs for suspicious activity.

---

# 2. Microsoft Office 365 / Entra ID Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | CISA Advisory / Microsoft Security Guidance on Adversary-in-the-Middle (AiTM) Phishing and Session Hijacking |
| **CVE** | N/A |
| **Attack Vector** | Cloud Identity & Access Management Attack |
| **Affected Product** | MedDefense Microsoft Office 365 E3 Tenant (Microsoft Entra ID) |
| **Severity** | Critical |

---

## Why the Scan Missed It

Traditional vulnerability scanners focus on:

- On-premise IP-addressable hosts
- Operating system vulnerabilities
- Installed software packages
- Network service exposure

They do not provide visibility into:

- Cloud tenant security configuration
- Identity provider settings
- Conditional Access policies
- Authentication session management
- Token security mechanisms

---

## Potential Impact on MedDefense

Since MedDefense relies on Microsoft Office 365 E3 for hospital operations and communication, attackers using **Adversary-in-the-Middle (AiTM)** phishing techniques could:

- Bypass traditional MFA protections
- Steal active session cookies
- Hijack employee accounts
- Access confidential medical communications
- Exfiltrate corporate documents
- Maintain persistent cloud access

This creates a significant risk to patient privacy and organizational confidentiality.

---

## Recommendation

MedDefense should:

- Enforce phishing-resistant MFA, including:
  - FIDO2 hardware security keys
  - Certificate-Based Authentication
- Implement Microsoft Entra ID Conditional Access policies.
- Disable legacy authentication protocols.
- Monitor identity logs for suspicious sign-in behavior.
- Implement continuous identity threat detection.

---

# 3. Synology DSM Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | NVD Database Details for CVE-2025-1021 / Synology Security Advisory Synology-SA-25:03 |
| **CVE** | **CVE-2025-1021** |
| **Affected Product** | MedDefense Backup NAS running Synology DSM 7 |
| **Severity** | Critical |
| **CVSS Base Score** | **8.8 - 9.8** |

---

## Why the Scan Missed It

The automated scanner detected the NAS device as an active online host but lacked:

- Application-level scanning credentials
- DSM administrative permissions
- Deep file-system inspection capabilities
- Accurate DSM component fingerprinting

As a result, the scanner could not determine the vulnerable internal DSM components.

---

## Potential Impact on MedDefense

A remote unauthenticated attacker exploiting the missing authorization flaw in the **synocopy component** could:

- Read arbitrary files
- Access system credentials
- Retrieve configuration data
- Expose backup archives
- Compromise disaster recovery storage

For MedDefense, this could result in:

- Loss of sensitive healthcare backup data
- Exposure of internal infrastructure details
- Severe impact on recovery capabilities during ransomware incidents

---

## Recommendation

MedDefense should:

- Upgrade Synology DSM 7 immediately to:
  - **DSM 7.2.2-72806-3 or later**
- Disable external internet exposure of NAS management ports.
- Restrict NAS access to authorized administrators only.
- Isolate backup storage within a dedicated management network segment.
- Apply strict access control policies.

---

# Summary Table

| Vulnerability | Affected System | CVE | Severity | Why Scan Missed It | Recommended Action |
|--------------|-----------------|-----|----------|-------------------|-------------------|
| FortiOS Remote Code Execution | FortiGate 100F Firewall | CVE-2024-23113 | Critical (9.8) | No firmware/API inspection or authenticated firewall scanning | Upgrade FortiOS and restrict administrative access |
| AiTM Cloud Identity Attack | Microsoft Office 365 E3 / Entra ID | N/A | Critical | Cloud identity controls are outside traditional scanner visibility | Deploy phishing-resistant MFA and Conditional Access |
| Synology DSM Authorization Flaw | Backup NAS (DSM 7) | CVE-2025-1021 | Critical (8.8–9.8) | No DSM authenticated deep scanning | Patch DSM and isolate backup infrastructure |

---

# Conclusion

The OSINT assessment demonstrates that vulnerability scanners alone cannot provide complete visibility into an organization's security posture.

The MedDefense vulnerability scan identified many internal infrastructure issues; however, significant risks remained hidden within:

- Perimeter security devices
- Cloud identity infrastructure
- Backup storage systems

A mature vulnerability management program should combine:

- Automated vulnerability scanning
- OSINT threat intelligence
- Vendor security advisories
- Authenticated assessments
- Cloud security reviews
- Firmware analysis

Without these additional security measures, critical vulnerabilities may remain undetected despite apparently acceptable vulnerability scan results.
