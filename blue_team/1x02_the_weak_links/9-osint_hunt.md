# 9. The OSINT Hunt
This supplement identifies additional vulnerabilities discovered through **Open Source Intelligence (OSINT) research** that were not identified during the original vulnerability scan. These findings demonstrate the importance of combining automated scanning with vendor advisories, cloud security reviews, and external threat intelligence.

---

# 1. FortiGate FortiOS Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | NVD Database / Fortinet PSIRT Advisory |
| **CVE** | **CVE-2025-68686** |
| **Affected Product** | MedDefense Perimeter Firewall (FortiGate 100F) |
| **Severity** | High |
| **CVSS Base Score** | Approximately **7.5** |

---

## Why the Scan Missed It

The automated vulnerability scan was limited to:

- Internal network assets
- Application servers
- Standard IP-addressable systems

The scanner did not have:

- Authenticated administrative access
- Firewall API access
- Firmware inspection capability
- Visibility into proprietary FortiOS control plane components

Therefore, firmware-level vulnerabilities affecting the perimeter firewall were not detected.

---

## Potential Impact on MedDefense

Successful exploitation could allow attackers to:

- Bypass integrity restrictions
- Retrieve sensitive firewall configuration data
- Access device state information
- Compromise the network perimeter
- Expose clinical data communication pathways

A compromised firewall could provide attackers with a strategic position for further attacks against internal healthcare systems.

---

## Recommendation

MedDefense should:

- Verify the FortiGate 100F firmware version against current Fortinet advisories.
- Apply the latest official FortiOS security patches.
- Restrict administrative access to trusted management networks only.
- Enable strong authentication for firewall administrators.

---

# 2. Microsoft Office 365 / Entra ID Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | CISA Cloud Identity Alerts / Microsoft Security Advisories |
| **CVE** | N/A |
| **Attack Technique** | Adversary-in-the-Middle (AiTM) Phishing / Token Theft |
| **Affected Product** | MedDefense Microsoft Office 365 E3 Tenant |
| **Severity** | Critical |

---

## Why the Scan Missed It

Traditional vulnerability scanners focus on:

- Internal IP-based assets
- Operating systems
- Installed software packages
- Network services

They do not have visibility into cloud identity security controls such as:

- Microsoft Entra ID tenant configuration
- Conditional Access policies
- Session token management
- Cloud authentication workflows

---

## Potential Impact on MedDefense

Because MedDefense relies heavily on Microsoft Office 365 for communication and operations, an attacker using AiTM phishing techniques could:

- Bypass traditional MFA protections
- Steal active session tokens
- Access employee accounts
- Read confidential emails
- Access patient-related communications
- Maintain unauthorized cloud access

This could result in major data confidentiality and privacy breaches.

---

## Recommendation

MedDefense should:

- Enforce phishing-resistant MFA using:
  - FIDO2 security keys
  - Certificate-Based Authentication
- Implement Microsoft Entra ID Conditional Access policies.
- Disable legacy authentication protocols.
- Monitor suspicious sign-in activity and impossible travel events.

---

# 3. Synology DSM Vulnerability

## Overview

| Field | Details |
|-------|---------|
| **Source** | NVD Database / Synology Security Advisory |
| **CVE** | **CVE-2024-10441** |
| **Affected Product** | MedDefense Backup NAS (Synology DSM 7) |
| **Severity** | Critical |
| **CVSS Base Score** | **9.8** |

---

## Why the Scan Missed It

The vulnerability scanner successfully detected the NAS device as an active host but lacked:

- Application-layer scanning credentials
- DSM administrative access
- Deep fingerprinting capabilities

As a result, the scanner could not determine the exact DSM version running behind the management interface.

---

## Potential Impact on MedDefense

Successful exploitation could allow a remote attacker to:

- Execute arbitrary code on the NAS
- Modify or delete backup data
- Encrypt hospital backups
- Exfiltrate sensitive information
- Destroy disaster recovery capabilities

A compromised backup system could severely impact hospital operations and business continuity.

---

## Recommendation

MedDefense should:

- Upgrade Synology DSM to the latest supported patched version (**DSM 7.2 or later**).
- Disable external internet exposure of NAS management interfaces.
- Restrict management ports.
- Place backup storage inside a dedicated secure management VLAN.
- Apply strict administrative access controls.

---

# Summary Table

| Vulnerability | Affected System | CVE | Severity | Reason Missed by Scan | Recommended Action |
|--------------|-----------------|-----|----------|----------------------|-------------------|
| FortiOS Firmware Vulnerability | FortiGate 100F Firewall | CVE-2025-68686 | High (~7.5) | No firewall firmware/API inspection | Update FortiOS and restrict admin access |
| AiTM Cloud Identity Attack | Microsoft Office 365 E3 / Entra ID | N/A | Critical | Cloud identity configuration not scanned | Deploy phishing-resistant MFA and Conditional Access |
| Synology DSM Remote Code Execution | Backup NAS | CVE-2024-10441 | Critical (9.8) | No DSM authenticated deep scan | Patch DSM and isolate backup infrastructure |

---

# Conclusion

The OSINT assessment highlights that traditional vulnerability scanners provide only partial visibility into an organization's security posture.

The original MedDefense scan focused primarily on internal infrastructure and software vulnerabilities, but significant risks also exist in:

- Network security appliances
- Cloud identity platforms
- Backup infrastructure

A complete vulnerability management program should combine:

- Automated vulnerability scanning
- OSINT threat intelligence
- Vendor security advisories
- Cloud security assessments
- Firmware reviews
- Authenticated scanning

Without these additional assessments, critical weaknesses may remain hidden despite a seemingly clean vulnerability report.
