# The Legacy Dilemma: Compensating Control Strategy for MRI Workstation

## Overview

This report evaluates the security risks associated with the legacy MRI workstation operating on **Windows XP** and recommends compensating controls to reduce the associated cybersecurity risk.

Because the workstation cannot be upgraded without affecting the medical imaging system, compensating controls are required to reduce the likelihood and impact of a successful attack while maintaining operational continuity.

---

# 1. Risk Analysis

The MRI workstation represents a **high-risk legacy asset** because it operates on **Windows XP**, an operating system that has not received security updates since **2014**.

The absence of vendor support leaves the workstation vulnerable to numerous publicly known exploits, including:

- Remote Code Execution (RCE)
- Wormable malware
- Privilege escalation attacks
- Credential theft

The current network architecture further increases this risk.

MedDefense operates a **flat 10.10.0.0/16 network**, meaning the MRI workstation shares the same broadcast domain as servers, workstations, and other clinical devices.

If the workstation is compromised, an attacker could use it as an initial foothold to perform lateral movement throughout the environment.

Potential business impacts include:

- Unauthorized access to the Electronic Health Record (EHR) system.
- Exposure of Protected Health Information (PHI).
- Compromise of infusion pump management systems.
- Disruption of clinical services and patient care.

For these reasons, the MRI workstation should be treated as a critical security risk requiring compensating controls.

---

# 2. Compensating Control Strategy

## Control 1 – Micro-Segmentation Using Firewall Rules

### Control Type

- **Category:** Technical
- **Function:** Preventive

### Description

Implement strict firewall rules to limit the MRI workstation's network communication exclusively to the PACS server using only the required DICOM communication ports (for example, TCP port 104).

All other inbound and outbound traffic should be denied by default.

### Risk Reduction

Restricting network communication significantly reduces the attack surface by preventing unauthorized communication with other systems.

If the workstation becomes compromised, the attacker will have limited ability to move laterally across the internal network.

### Residual Risk

This control does not eliminate attacks that originate through the approved PACS communication path.

Additionally, it does not address vulnerabilities resulting from local physical access.

---

## Control 2 – Protocol-Aware Network Gateway

### Control Type

- **Category:** Technical
- **Function:** Preventive / Compensating

### Description

Deploy an industrial or protocol-aware firewall between the MRI workstation and the network.

The device should inspect DICOM traffic and identify malicious or abnormal protocol activity before it reaches the vulnerable operating system.

### Risk Reduction

The gateway acts as a virtual security layer by filtering malicious traffic before it reaches the unsupported Windows XP workstation.

This approach provides protection against many known network-based exploits without modifying the legacy operating system.

### Residual Risk

Implementation is technically complex and requires detailed knowledge of DICOM communications.

Incorrect configuration could interfere with legitimate medical imaging operations.

---

## Control 3 – Physical Access and Port Security

### Control Type

- **Category:** Physical
- **Function:** Preventive

### Description

Strengthen physical security by:

- Disabling all unused USB ports.
- Disabling unused network interfaces.
- Locking the workstation inside a tamper-evident enclosure.
- Restricting physical access to authorized personnel only.

### Risk Reduction

These measures reduce the likelihood of malware being introduced through removable media or unauthorized physical access.

They also reduce opportunities for insider attacks against the workstation.

### Residual Risk

Physical controls do not protect against attacks delivered through the network.

Regular administrative verification is required to ensure ports remain disabled and physical protections remain effective.

---

# 3. Implementation Priority

## Recommended Priority

**Highest Priority Control:** Micro-Segmentation Using Firewall Rules

### Justification

Within MedDefense's current flat network architecture, micro-segmentation provides the greatest reduction in overall organizational risk.

By limiting the MRI workstation's communication to only essential systems, this control effectively interrupts the primary attack path used for lateral movement.

Although protocol-aware firewalls and physical protections provide valuable additional security, they address more specific attack scenarios.

Network segmentation provides broader protection because it isolates the unsupported workstation from the rest of the environment.

Even if the Windows XP workstation is successfully compromised, the attacker will be significantly restricted from reaching critical systems such as:

- Electronic Health Record (EHR) servers
- Patient databases
- Infusion pump management systems
- Other clinical infrastructure

Implementing micro-segmentation therefore provides the greatest immediate improvement to MedDefense's security posture while preserving the operational availability of the MRI system.

---

# 4. Conclusion

The MRI workstation represents a significant security risk because it relies on an unsupported operating system that cannot receive modern security updates.

Replacing the workstation may not be operationally feasible; therefore, compensating controls are necessary to reduce the associated risk.

Among the recommended controls, **micro-segmentation through restrictive firewall policies** should be implemented first because it most effectively limits lateral movement and protects critical healthcare systems from compromise.

Additional controls, including protocol-aware firewalls and strengthened physical security, should be implemented to provide layered defense and further reduce the overall attack surface.
