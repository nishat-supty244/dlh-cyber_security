# Supply Chain Risk Assessment

---

# Vendor: MedTech Solutions

- **Service:** EHR maintenance provider
- **Access Type:** Network (VPN) and Application (Direct server access)
- **Access Scope:** Full administrative control over the EHR application server and associated patient databases

## Compromise Scenario
A threat actor compromises MedTech Solutions' internal network, moves laterally to the VPN client used for the MedDefense account, and executes arbitrary code on the EHR server to exfiltrate patient records.

## Existing Controls
- VPN with Multi-Factor Authentication (MFA)
- Vendor access logs (manual review)

## Risk Assessment: **Critical**

MedTech Solutions has the **"keys to the kingdom"** for MedDefense’s most sensitive patient data. Their persistent, high-level access creates a direct path to compromise regulated PHI and disrupt critical healthcare operations.

---

# Vendor: Microsoft

- **Service:** O365 E3 (Email, SharePoint, OneDrive)
- **Access Type:** Application and Identity
- **Access Scope:** Access to corporate communications, internal documentation, and user identity management through Entra ID

## Compromise Scenario
Microsoft experiences a global identity breach. Attackers use OAuth token manipulation or forged authentication assertions to gain unauthorized access to MedDefense email systems and internal SharePoint resources.

## Existing Controls
- Conditional Access policies
- Entra ID Multi-Factor Authentication (MFA)

## Risk Assessment: **High**

Although Microsoft maintains strong security capabilities, a compromise of this platform would have a catastrophic impact because it could expose internal communications, sensitive documents, and identity systems.

---

# Vendor: Sophos

- **Service:** Endpoint Protection (EDR)
- **Access Type:** Application (Agent-level)
- **Access Scope:** Full visibility and control over endpoints, including the ability to push configurations and software updates

## Compromise Scenario
An attacker gains access to the Sophos management console, disables EDR protection across the organization, and distributes malicious payloads to workstations simultaneously.

## Existing Controls
- Role-Based Access Control (RBAC) within the management console

## Risk Assessment: **High**

Sophos manages MedDefense’s primary defensive security layer. A compromise of this platform could disable endpoint protections and leave the entire organization vulnerable to further attacks.

---

# Vendor: Siemens

- **Service:** MRI scanner maintenance
- **Access Type:** Network (to a standalone legacy device)
- **Access Scope:** Access to a Windows XP-based workstation connected to the MRI scanner

## Compromise Scenario
An attacker exploits vulnerabilities in the Windows XP workstation, uses it as a pivot point to scan the internal network, and attempts to reach the hospital domain.

## Existing Controls
- VLAN isolation
- Firewall rules restricting outbound traffic

## Risk Assessment: **Medium**

Although access is limited to a single isolated device, the use of legacy Windows XP technology introduces significant vulnerabilities and provides a potential entry point for lateral movement.

---

# Vendor: Greenfield Building Management

- **Service:** Building network/infrastructure management
- **Access Type:** Physical and Network
- **Access Scope:** Management of physical switches and building-wide VLAN infrastructure

## Compromise Scenario
An attacker compromises Greenfield’s administrative portal, allowing them to monitor traffic or conduct man-in-the-middle attacks on VLAN infrastructure shared with MedDefense.

## Existing Controls
- VLAN separation
- Traffic encryption where enabled

## Risk Assessment: **Medium**

Greenfield controls critical network infrastructure components that could enable traffic interception. However, they do not have direct access to MedDefense’s core servers or EHR applications.

---

# Supply Chain Risk Summary

The vendor compromise that would cause the greatest damage to **MedDefense** is **MedTech Solutions**.

Their direct, high-privilege access to the EHR server provides an immediate pathway to:

- Patient data theft
- PHI exposure
- Operational disruption
- Healthcare service interruption

To reduce supply chain risk across all vendors, MedDefense should implement:

- **Zero Trust Network Access (ZTNA)**
- **Privileged Access Management (PAM)**

These controls would replace persistent vendor VPN access with:

- Granular access permissions
- Time-limited vendor sessions
- Continuous monitoring
- Recorded administrative activity

This approach ensures MedDefense no longer blindly trusts vendor connections and can better manage third-party access based on verified identity, device posture, and business requirements.
