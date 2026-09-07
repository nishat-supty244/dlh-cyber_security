# STRIDE Across the Architecture

---

# System: PACS / Medical Imaging

## Architecture Notes

- Stores medical imaging data
- Depends on a legacy Windows XP MRI workstation
- Uses unencrypted data transfers to radiology workstations

| STRIDE | Threat | Impact | Severity |
|--------|--------|--------|----------|
| **S - Spoofing** | Spoofing a clinician session to retrieve medical images | Unauthorized access to PHI | **Critical** |
| **T - Tampering** | Modifying image metadata (e.g., patient ID) | Misdiagnosis and potential patient harm | **Critical** |
| **R - Repudiation** | Deleting diagnostic logs to conceal unauthorized access | Loss of audit trail required for HIPAA compliance | **High** |
| **I - Information Disclosure** | Intercepting unencrypted medical images during transmission | Widespread exposure of PHI | **Critical** |
| **D - Denial of Service** | Crashing the Windows XP workstation through an SMB exploit | Radiology department shutdown | **High** |
| **E - Elevation of Privilege** | Escalating privileges from the XP workstation to the PACS server | Full PACS administrative control | **Critical** |

### Top Threat: Tampering (T)

In a clinical imaging environment, the ability to alter image metadata or modify diagnostic images presents a direct patient safety risk. Such tampering can lead to misdiagnosis, delayed treatment, or inappropriate clinical decisions.

---

# System: Active Directory

## Architecture Notes

- Centralized authentication for users and services
- Multi-Factor Authentication (MFA) not fully implemented
- Weak password policies

| STRIDE | Threat | Impact | Severity |
|--------|--------|--------|----------|
| **S - Spoofing** | Kerberoasting to obtain service account hashes | Offline brute-force password cracking | **Critical** |
| **T - Tampering** | Unauthorized modification of Group Policy | Enterprise-wide security policy bypass | **Critical** |
| **R - Repudiation** | Clearing event logs after malicious changes | Loss of incident investigation evidence | **High** |
| **I - Information Disclosure** | Dumping the **NTDS.dit** database | Complete compromise of all domain credentials | **Critical** |
| **D - Denial of Service** | Saturating LDAP queries to crash Domain Controllers | Enterprise-wide authentication failure | **Critical** |
| **E - Elevation of Privilege** | Escalating from a standard user to Domain Admin | Complete control of the enterprise environment | **Critical** |

### Top Threat: Information Disclosure (I)

The theft of the **NTDS.dit** database provides attackers with credential material for every user and service account within the organization. This represents one of the most catastrophic security failures possible for MedDefense.

---

# System: Network Infrastructure

## Architecture Notes

- Single FortiGate firewall
- Unauthorized consumer-grade router connected to the network
- No internal network segmentation

| STRIDE | Threat | Impact | Severity |
|--------|--------|--------|----------|
| **S - Spoofing** | VPN hijacking through credential theft | Unauthorized remote access to the network | **Critical** |
| **T - Tampering** | Modifying firewall rules to permit unauthorized traffic | Circumvention of perimeter security | **Critical** |
| **R - Repudiation** | Deleting firewall or VPN logs to conceal malicious activity | Complete loss of network visibility | **High** |
| **I - Information Disclosure** | Sniffing traffic on the flat network | Exposure of credentials and PHI | **Critical** |
| **D - Denial of Service** | Distributed Denial-of-Service (DDoS) attack against the Westside consumer router | Disruption of remote network connectivity | **High** |
| **E - Elevation of Privilege** | Escalating from the consumer router into the core network | Complete bypass of perimeter defenses | **Critical** |

### Top Threat: Elevation of Privilege (E)

The unmanaged consumer-grade router creates an unauthorized entry point into the internal network. An attacker who compromises this device can bypass the corporate firewall and gain elevated access to the organization's core network infrastructure, significantly increasing the risk of widespread compromise.
