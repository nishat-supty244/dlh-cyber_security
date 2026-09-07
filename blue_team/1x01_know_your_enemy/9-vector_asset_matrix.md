# Vector-to-Asset Matrix

| Vector | EHR Database | Active Directory | Billing Server | PACS Workstation | Medical IoT | Print Server | Executive Workstations |
|---|---|---|---|---|---|---|---|
| **Phishing / Spear Phishing** | Phishing → IT credentials → Domain Admin → EHR access | Phishing → Admin credentials → AD forest control | Phishing → Clerk credentials → Billing data access | — | — | — | Phishing → Executive credentials → Internal communications access |
| **VPN Exploit** | VPN exploit → Flat network → EHR database access | VPN exploit → Domain Controller compromise | VPN exploit → Flat network → Billing server access | VPN exploit → PACS image storage access | VPN exploit → IoT device control | VPN exploit → Print server access | VPN exploit → Internal workstation access |
| **Default / Shared Credentials** | Shared credentials → Application access → EHR data exposure | Default credentials → AD account compromise | Shared credentials → Billing application access | Shared credentials → PACS workstation access | Default credentials → Pump web interface access | Shared credentials → Local administrator access | — |
| **Vulnerable Software Exploit** | Exploit → billing-srv-01 → EHR compromise | Exploit → print-srv-01 → AD synchronization compromise | Exploit → Apache vulnerability → Billing database access | Exploit → PACS viewer service compromise | Exploit → IoT firmware compromise | Exploit → Legacy printer compromise | Exploit → Unpatched desktop application |
| **Supply Chain Compromise** | Vendor access → EHR maintenance access | Vendor access → AD management | Vendor access → Billing system access | Vendor access → PACS remote support | Vendor access → IoT maintenance | Vendor access → Print management | Vendor access → O365 administrator access |
| **Insider (Malicious)** | Insider → Query EHR records | Insider → Modify AD groups | Insider → Modify billing records | Insider → Exfiltrate patient images | Insider → Sabotage IoT devices | — | Insider → Steal executive documents |
| **Insider (Negligent)** | Negligent user → Expose EHR credentials | Negligent user → Leave AD account logged in | Negligent user → Expose billing exports | Negligent user → Share PACS login | Negligent user → Leave default IoT passwords | — | Negligent user → Share executive data |
| **Physical Access** | Physical access → Server room → EHR server | Physical access → Server room → AD host | Physical access → Office PC → Billing system | Physical access → Radiology terminal | Physical access → Pump manual reset | — | Physical access → Executive PC access |

---

# Priority Intersections

## Most Connected Assets

### 1. Active Directory

**Risk Level: Critical**

Active Directory is the central authentication and authorization system for MedDefense.

A successful compromise could result in:

- Enterprise-wide account control
- Privilege escalation
- Access to critical applications
- Complete network compromise

**Defensive Priority:**
Hardening Active Directory is the highest security priority due to its role as the foundation of identity management.

---

### 2. EHR Database

**Risk Level: Critical**

The EHR database contains the organization's most sensitive patient information, including PHI.

A compromise could result in:

- Patient data exposure
- Regulatory violations
- Ransomware impact
- Significant reputational damage

**Defensive Priority:**
Protect and isolate the EHR database through segmentation, access control, monitoring, and encryption.

---

### 3. Billing Server

**Risk Level: High**

The billing server provides access to financial systems and sensitive healthcare-related information.

A compromise could enable:

- Financial fraud
- Data theft
- Further lateral movement into critical systems

**Defensive Priority:**
Restrict access, patch vulnerabilities, and monitor database activity.

---

# Most Versatile Attack Vectors

## 1. VPN Exploit

**Risk Level: Critical**

VPN exploitation is one of the most effective attack paths because it allows attackers to bypass external defenses and enter the flat internal network.

Impact:

- Direct access to internal systems
- Ability to perform reconnaissance
- Lateral movement across critical assets
- Potential compromise of EHR, AD, billing, and endpoints

---

## 2. Supply Chain Compromise

**Risk Level: Critical**

Compromised vendors can bypass traditional perimeter security because they already possess trusted access to critical systems.

Impact:

- Direct access to EHR maintenance systems
- Administrative access to infrastructure
- Potential compromise through legitimate connections

---

## 3. Insider (Malicious)

**Risk Level: High**

Malicious insiders represent a unique risk because they already possess authorized access.

Impact:

- Direct access to sensitive data
- Ability to bypass traditional security controls
- Difficult detection without behavioral monitoring

A malicious insider can reach critical assets without requiring external exploitation techniques.
