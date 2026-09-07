# Attack Surface Map

---

# Section 1: External Surface

| Entry Point | Asset | Protection | Gap ID |
|---|---|---|---|
| Patient Portal | web-srv-01 | Basic Web Application Firewall (WAF) | VULN-01 |
| VPN Endpoints | FortiGate Gateway | Partial Multi-Factor Authentication (MFA) | IAM-01 |
| Email Infrastructure | O365 / Entra ID | Basic Filtering | SEC-04 |
| Public Website | web-srv-02 | None | VULN-01 |
| DNS Records | External DNS | None | ASSET-02 |
| Remote Desktop | RDP/Gateway | None | IAM-01 |

---

# Section 2: Internal Surface

## MySQL (billing-srv-01)

- Exposed on port **3306**
- Accessible network-wide
- In a flat network environment, any compromised host can directly query sensitive billing databases.

**Risk:** Unauthorized access to financial and patient billing information.

---

## PostgreSQL (ehr-db-01)

- Exposed on port **5432**
- Accessible across the network
- Lack of segmentation enables lateral movement toward the most critical patient data repository.

**Risk:** Direct exposure of the EHR database and sensitive patient information.

---

## Management Interfaces

Affected systems include:

- NAS devices
- FortiGate administration interfaces
- IoT web management interfaces

**Security Issues:**

- Default ports exposed
- Lack of MFA protection
- Accessible by any user connected to the internal network

**Risk:** Attackers gaining administrative control over critical infrastructure.

---

## Legacy Systems

Identified systems include:

- Windows XP hosts
- Windows Server 2012 R2 hosts

**Security Issues:**

- Unpatched vulnerabilities
- Limited vendor support
- Increased risk of persistent code execution

**Risk:** Attackers can exploit outdated systems as entry points for maintaining access.

---

## Default Credentials

Affected systems include:

- PACS workstations
- Medical IoT devices

**Security Issue:**

Default credentials remain active, allowing attackers to perform brute-force attacks from anywhere within the flat network.

**Risk:** Unauthorized access to medical systems and connected devices.

---

## Flat Network Architecture

**Current Environment:**

- Entire network exists within the **10.10.0.0/16 subnet**
- No internal filtering between departments or assets

**Impact:**

The entire organization effectively operates as a single security zone, allowing attackers who compromise one device to move freely throughout the environment.

---

# Section 3: Human Surface

## Clinical Staff

**Access:**
- Access to EHR records and patient information

**Risk Factors:**

- High-stress clinical workflows
- Fast-paced decision-making environments
- Historically low security training completion rates

**Primary Threats:**

- Phishing
- Credential theft
- Accidental data exposure

---

## Reception Staff

**Role:**

- Physical access point and first contact for visitors and external parties

**Risk Factors:**

- Vulnerable to social engineering techniques

**Primary Threats:**

- Vishing
- Tailgating
- Credential harvesting

---

## IT Staff

**Access:**

- Elevated domain administrator privileges

**Risk Factors:**

- Highly privileged access
- Small, overworked security team

**Primary Threats:**

- Spear phishing
- Social engineering
- Credential compromise

---

## Executives

**Access:**

- Strategic financial and operational information

**Risk Factors:**

- High-value targets for attackers

**Primary Threats:**

- Business Email Compromise (BEC)
- Financial fraud attempts

**Security Gap:**

- Lack of rigorous verification procedures

---

## External Contractors

**Access:**

- Maintenance-level access to critical EHR and network infrastructure

**Risk Factors:**

- Dependence on third-party security practices
- Limited visibility into vendor environments

**Primary Threats:**

- Supply chain compromise
- Stolen vendor credentials

---

# Surface Assessment Summary

The **Internal Surface** represents the greatest security risk for MedDefense.

The flat network architecture significantly reduces the effectiveness of existing perimeter and human-focused security controls. Once an attacker bypasses the external defenses, the absence of internal segmentation allows rapid lateral movement across the environment.

This creates a situation where a single compromised device can escalate into an organization-wide incident.

Because internal systems lack sufficient segmentation, monitoring, and access restrictions, attackers do not require highly advanced techniques to reach MedDefense’s critical assets, including:

- EHR databases
- Billing databases
- Patient information systems

The current environment provides minimal internal resistance, allowing attackers to move through the network with limited detection or containment capability.
