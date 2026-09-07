# 9. The OSINT Hunt

## 1. FortiGate FortiOS Vulnerability

### Source
- NVD Database Details for **CVE-2024-23113**
- Fortinet PSIRT Advisory **FG-IR-24-029**

### Vulnerability Details

| Field | Details |
|---|---|
| **CVE** | CVE-2024-23113 |
| **Affected Product** | MedDefense Perimeter Firewall (FortiGate 100F running FortiOS) |
| **CVSS Severity** | Critical |
| **CVSS Base Score** | 9.8 |

### Why the Scan Missed It

The automated vulnerability scan was limited to internal application nodes and local subnet targets. It did not include:

- Authenticated administrative access to network security appliances.
- Proprietary FortiOS protocol analysis.
- Firmware-level inspection of the firewall control plane.

As a result, the scanner was unable to identify vulnerabilities existing within the FortiGate firmware environment.

### MedDefense Impact

Successful exploitation of this vulnerability could allow a remote attacker to execute unauthorized commands or code through specially crafted network packets.

Potential consequences include:

- Complete takeover of the MedDefense perimeter firewall.
- Unauthorized modification of firewall rules.
- Bypass of network security controls.
- Unauthorized access to clinical network segments.
- Potential lateral movement toward critical healthcare systems.

### Recommendation

Immediate remediation actions:

- Upgrade FortiOS to a vendor-patched version:
  - **FortiOS 7.2.7 or later**
  - **FortiOS 7.0.14 or later**
- Restrict firewall administrative interfaces to trusted internal VLANs only.
- Disable unnecessary external management access.
- Monitor firewall logs for suspicious administrative activity.

---

# 2. Microsoft Office 365 / Entra ID Vulnerability

### Source

- CISA Advisory on Adversary-in-the-Middle (AiTM) Phishing Attacks
- Microsoft Security Guidance for Entra ID Identity Protection

### Vulnerability Details

| Field | Details |
|---|---|
| **CVE** | N/A |
| **Affected Product** | MedDefense Microsoft Office 365 E3 Tenant (Microsoft Entra ID) |
| **Severity** | Critical Business Risk |

### Why the Scan Missed It

Traditional vulnerability scanners primarily evaluate:

- IP-addressable systems.
- Network services.
- On-premise infrastructure vulnerabilities.

They do not assess:

- Cloud tenant security configurations.
- Identity provider policies.
- Authentication mechanisms.
- Session token protection.
- Conditional Access settings.

Therefore, the scanner had no visibility into Microsoft Entra ID identity risks.

### MedDefense Impact

MedDefense relies heavily on Microsoft Office 365 E3 for hospital operations. An attacker using an Adversary-in-the-Middle (AiTM) phishing technique could:

- Steal authentication session cookies.
- Bypass traditional MFA protections.
- Hijack legitimate user sessions.
- Access confidential medical communications.
- Exfiltrate corporate and patient-related information.

This creates a significant risk to:

- Patient confidentiality.
- Regulatory compliance.
- Healthcare operations.
- Organizational reputation.

### Recommendation

Implement the following security controls:

- Enforce phishing-resistant MFA:
  - FIDO2 hardware security keys.
  - Passkeys supported by Microsoft Entra ID.
- Deploy Conditional Access policies requiring strong authentication.
- Disable legacy authentication protocols.
- Enable Microsoft Defender for Identity and Cloud Apps monitoring.
- Continuously review risky sign-ins and compromised accounts.

---

# 3. Synology DSM Vulnerability

### Source

- NVD Database Details for **CVE-2025-1021**
- Synology Security Advisory **Synology-SA-25:03**

### Vulnerability Details

| Field | Details |
|---|---|
| **CVE** | CVE-2025-1021 |
| **Affected Product** | MedDefense Backup NAS (Synology DSM 7) |
| **CVSS Severity** | Critical |
| **CVSS Base Score** | 8.8 - 9.8 |

### Why the Scan Missed It

The automated scanner identified the NAS host as active but lacked:

- Application-level authentication credentials.
- Synology DSM-specific vulnerability plugins.
- Required file-system permissions.
- Deep inspection capabilities for DSM internal components.

Because of these limitations, the scanner could not accurately fingerprint vulnerable DSM sub-components.

### MedDefense Impact

The vulnerability affects the Synology **synocopy** component and may allow a remote unauthenticated attacker to access unauthorized files.

Potential impacts include:

- Exposure of backup archives.
- Disclosure of system credentials.
- Leakage of configuration files.
- Compromise of disaster recovery resources.
- Loss of confidentiality of sensitive healthcare data.

For MedDefense, compromise of backup infrastructure could severely impact:

- Data recovery capabilities.
- Business continuity operations.
- Patient record availability.

### Recommendation

Immediate remediation steps:

- Upgrade Synology DSM to:
  - **DSM 7.2.2-72806-3 or later**
- Remove direct internet exposure of NAS management services.
- Restrict NAS access to isolated administrative management networks.
- Enforce strong authentication for administrative accounts.
- Regularly test backup integrity and recovery procedures.

---

# Summary of Critical Findings

| Vulnerability | Asset | Severity | Primary Risk |
|---|---|---|---|
| **CVE-2024-23113 FortiGate FortiOS** | Perimeter Firewall | Critical (CVSS 9.8) | Firewall takeover and network compromise |
| **Microsoft Entra ID AiTM Risk** | Office 365 E3 Tenant | Critical Business Risk | Identity compromise and data theft |
| **CVE-2025-1021 Synology DSM** | Backup NAS | Critical (CVSS 8.8-9.8) | Backup exposure and confidentiality loss |

These findings demonstrate that vulnerability scanning alone is insufficient for modern healthcare environments. A complete security assessment must include network appliances, cloud identity platforms, and specialized infrastructure components to identify risks that traditional scanners cannot detect.
