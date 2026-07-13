# MedDefense Central: Physical Security Risk Assessment

## Overview

This report presents a physical security risk assessment based on observations collected during the facility walkthrough at **MedDefense Central**.

Each observation is analyzed using a structured risk decomposition approach:

- **Vulnerability:** The identified weakness or security gap.
- **Threat:** A potential actor or event that could exploit the weakness.
- **Impact:** The potential effect on confidentiality, integrity, availability, or business operations.
- **Severity:** The overall risk rating based on potential impact and likelihood.

---

# Physical Security Risk Assessment Table

| Observation | Vulnerability | Threat | Impact | Severity |
|-------------|---------------|--------|--------|----------|
| **1. Server Room Access** | The server room has inadequate physical access controls. A universal employee badge is used without access logging, audit trails, or surveillance monitoring. | An unauthorized individual, such as a disgruntled employee, contractor, or intruder, could enter the server room to damage equipment, steal hardware, or gain direct access to storage devices. | **Availability:** Physical damage or theft of server hardware could cause critical system outages. <br><br> **Confidentiality:** Unauthorized physical access could allow access to sensitive data stored on servers or drives. | **Critical** — Physical access to core infrastructure allows attackers to bypass digital security controls and directly impact critical systems. |
| **2. Network Closet** | The network closet is unsecured, and administrative credentials for network management are stored in clear text. | A malicious actor or unauthorized employee could access network equipment, use exposed credentials, intercept traffic, modify configurations, create unauthorized VLANs, or disrupt connectivity. | **Confidentiality:** Attackers could intercept sensitive network traffic. <br><br> **Integrity:** Unauthorized users could modify network configurations. <br><br> **Availability:** Incorrect changes could cause network outages. | **Critical** — Exposed administrative credentials and unrestricted physical access create a direct path to complete network compromise. |
| **3. Nurse Station Workstations** | Workstations do not enforce session timeouts and are not consistently locked when unattended. | An unauthorized person, including visitors or patients' family members, could access active EHR sessions and view or modify patient information. | **Confidentiality:** Unauthorized access could expose Protected Health Information (PHI). <br><br> **Integrity:** Unauthorized users could modify patient records or clinical information. | **High** — Unprotected access to active EHR sessions creates significant privacy and patient safety risks. |
| **4. Medical IoT Devices** | Medical devices are running outdated firmware and are connected through a flat network architecture without proper segmentation from workstation environments. | An attacker could exploit known vulnerabilities in outdated firmware to gain remote access to medical devices and move laterally toward critical clinical systems. | **Confidentiality:** Attackers could access sensitive medical information, including patient monitoring data. <br><br> **Availability:** Compromised devices could disrupt patient monitoring or affect clinical operations. | **High** — Legacy firmware and insufficient network segmentation make critical medical devices attractive attack targets and potential entry points. |
| **5. Emergency Exit Access** | A restricted access door is permanently propped open, bypassing established physical security controls. | An unauthorized individual could enter through the unsecured exit and gain access to administrative areas or sensitive departments. | **Confidentiality:** Unauthorized individuals could access sensitive documents, offices, or equipment. <br><br> **Integrity:** Attackers could steal, modify, or damage organizational assets. | **Medium** — The vulnerability creates unauthorized access risk but has a more limited scope compared to weaknesses affecting core infrastructure. |

---

# Detailed Risk Analysis

## Observation 1: Server Room Access

### Risk Assessment

The server room lacks sufficient physical security controls because access is provided through a universal employee badge without individual tracking or monitoring.

### Potential Threat Scenario

A malicious employee, contractor, or unauthorized visitor could physically enter the server room and:

- Damage critical infrastructure.
- Remove storage devices.
- Connect unauthorized hardware.
- Access sensitive systems directly.

### Security Impact

The impact includes:

- **Availability loss** due to possible hardware destruction or service interruption.
- **Confidentiality loss** due to direct access to sensitive storage media.

### Risk Rating

**Critical**

Physical access to infrastructure provides attackers with the ability to bypass many logical security protections.

---

# Observation 2: Network Closet

### Risk Assessment

The network closet represents a critical security weakness due to unrestricted physical access and exposed administrative credentials.

### Potential Threat Scenario

An unauthorized user could:

- Access network switches.
- Modify VLAN configurations.
- Monitor network traffic.
- Disable connectivity.
- Use administrative credentials for further attacks.

### Security Impact

The impact includes:

- **Confidentiality:** Network traffic interception.
- **Integrity:** Unauthorized configuration changes.
- **Availability:** Network disruption.

### Risk Rating

**Critical**

Compromise of network infrastructure can provide organization-wide access and control.

---

# Observation 3: Nurse Station Workstations

### Risk Assessment

Clinical workstations remain vulnerable because active sessions are not automatically locked when users leave their workstations.

### Potential Threat Scenario

An unauthorized individual could access an unlocked workstation and:

- View patient records.
- Change medical information.
- Access healthcare applications.

### Security Impact

The impact includes:

- **Confidentiality:** Exposure of PHI.
- **Integrity:** Unauthorized modification of patient records.

### Risk Rating

**High**

Unattended clinical sessions create direct risks to privacy and patient safety.

---

# Observation 4: Medical IoT Devices

### Risk Assessment

Medical IoT devices represent a significant security concern due to outdated firmware and insufficient network segmentation.

### Potential Threat Scenario

An attacker could exploit known vulnerabilities to:

- Gain remote access.
- Manipulate device functionality.
- Move laterally toward clinical systems.

### Security Impact

The impact includes:

- **Confidentiality:** Exposure of medical monitoring information.
- **Availability:** Disruption of clinical device operations.

### Risk Rating

**High**

Medical devices require strong isolation because compromise could affect both cybersecurity and patient safety.

---

# Observation 5: Emergency Exit

### Risk Assessment

A propped-open emergency exit bypasses established physical access controls.

### Potential Threat Scenario

An unauthorized person could use the unsecured entrance to access restricted administrative areas.

### Security Impact

The impact includes:

- **Confidentiality:** Unauthorized access to documents, offices, or equipment.
- **Integrity:** Theft or tampering with organizational assets.

### Risk Rating

**Medium**

Although the vulnerability creates unauthorized access opportunities, the impact is more localized compared to risks affecting critical infrastructure.

---

# Conclusion

The physical security assessment identified several vulnerabilities that could significantly impact MedDefense's security posture.

The highest-priority risks are:

1. **Server room access controls** — because physical access to infrastructure can bypass cybersecurity defenses.
2. **Network closet security** — because exposed credentials and unrestricted access could lead to complete network compromise.
3. **Medical IoT security weaknesses** — because vulnerable clinical devices may directly affect patient safety.

MedDefense should prioritize strengthening physical access controls, implementing monitoring mechanisms, securing administrative credentials, enforcing workstation locking policies, and segmenting medical IoT devices from general network environments.
