# Control Gaps Analysis

## Overview

This report identifies significant gaps in the current security control environment at MedDefense. The analysis was performed by comparing the existing security controls against the Security Control Matrix to identify missing control categories and functions.

Each identified gap includes:

- The missing security control category and function.
- The affected assets or business areas.
- The associated security risk if the gap remains unaddressed.
- Supporting evidence from the provided documentation.

---

# Control Gap Assessment

| Gap ID | Gap Description | Missing Category × Function | Affected Assets / Zone | Risk if Unaddressed | Supporting Evidence |
|--------|-----------------|-----------------------------|------------------------|---------------------|---------------------|
| **G-001** | No centralized technical monitoring solution such as a SIEM, IDS/IPS, or File Integrity Monitoring. | **Technical × Detective** | Entire organization (Central Hospital, Westside Clinic, Corporate HQ) | Attackers may remain undetected for extended periods, allowing unauthorized access, persistence, and continued compromise of confidentiality and integrity. | The control inventory contains only endpoint antivirus as a detective control. No centralized monitoring or intrusion detection solution is documented. |
| **G-002** | No formal Incident Response (IR) or Disaster Recovery (DR) procedures exist. | **Administrative × Corrective** | Organization-wide clinical and business operations | Security incidents and outages may be handled inconsistently, increasing downtime, recovery costs, and operational disruption. | Marcus Webb's notes state that no formal Incident Response or Disaster Recovery plans currently exist. |
| **G-003** | Critical IT infrastructure lacks physical monitoring controls. | **Physical × Detective** | Central Hospital server room and network closets | Unauthorized physical access may occur without detection, increasing the risk of hardware theft, tampering, or service disruption. | Facility walkthrough confirmed that server corridors and infrastructure areas are not monitored by surveillance cameras. |
| **G-004** | No automated recovery solution exists for workstations, medical IoT devices, or network equipment. | **Technical × Corrective** | Workstations, medical IoT devices, and network infrastructure | Compromised devices cannot be rapidly restored to a trusted configuration, increasing recovery time and the likelihood of persistent compromise. | Existing backup capabilities protect server data only through Veeam Backup Solution. No endpoint recovery solution is documented. |
| **G-005** | No compensating physical controls protect areas where primary physical controls have failed. | **Physical × Compensating** | Administrative wing, Westside Clinic server closet, restricted access areas | Failed physical barriers increase the likelihood of unauthorized entry, equipment theft, and hardware tampering without alternative safeguards. | Walkthrough observations identified a permanently propped-open emergency exit and unsecured server closets. |
| **G-006** | No documented compensating security policies exist for unsupported legacy systems. | **Administrative × Compensating** | Windows XP MRI scanner and other legacy medical devices | Unsupported systems remain exposed to known vulnerabilities because no documented procedures restrict their exposure or reduce associated risk. | Documentation confirms that the MRI scanner operates on Windows XP, but no compensating security policies are described. |

---

# Overall Security Posture Assessment

The current security control environment demonstrates a strong emphasis on **preventive controls**, including firewalls, password policies, VPN connectivity, and physical access controls. While these controls provide an important first layer of defense, they are not sufficient on their own.

The assessment identified significant weaknesses in **detective**, **corrective**, and **compensating** controls.

Key observations include:

- Limited capability to detect malicious activity after an attacker bypasses preventive controls.
- No formal administrative procedures for responding to or recovering from major security incidents.
- Insufficient physical monitoring of critical infrastructure.
- Limited recovery capabilities for endpoints and medical IoT devices.
- Lack of compensating controls for unsupported legacy systems.

As demonstrated by the compromise of **billing-srv-01**, attackers can remain active within the environment for extended periods without detection. The absence of comprehensive monitoring and incident response capabilities significantly increases organizational risk.

---

# Conclusion

The analysis indicates that MedDefense's current security posture is heavily weighted toward prevention while providing limited capabilities for detection, response, and recovery.

To improve resilience, the organization should prioritize:

1. Implementing centralized monitoring solutions such as a SIEM and IDS/IPS.
2. Developing formal Incident Response and Disaster Recovery plans.
3. Expanding physical monitoring of critical infrastructure.
4. Implementing endpoint and medical device recovery solutions.
5. Establishing compensating controls and security policies for unsupported legacy systems.

Addressing these gaps will significantly strengthen MedDefense's ability to detect, contain, and recover from future security incidents while reducing overall organizational risk.
