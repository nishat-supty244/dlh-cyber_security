# 15. Medical IoT Risk Analysis

## BD Alaris Assessment

### Vulnerability Description

The **BD Alaris infusion pump ecosystem** contains multiple security vulnerabilities identified through vendor advisories and security bulletins, including **CISA ICSMA-23-194-01**, which covers affected BD Alaris system components such as **Guardrails Editor v12.1.2**.

A major vulnerability, **CVE-2023-30562**, involves **insufficient verification of data authenticity**, allowing attackers to perform out-of-band tampering with dataset files (`.gre`) distributed to **Point-of-Care Units (PCUs)**. An attacker could potentially modify medication delivery parameters or configuration datasets before they are loaded into infusion pumps.

Additional identified weaknesses include:

- **Unauthenticated configuration changes**, allowing unauthorized modification of device settings.
- **Improper signature verification** during wireless card firmware updates, enabling potentially malicious firmware manipulation.
- **Cross-Site Scripting (XSS)** vulnerabilities affecting management servers, which may allow attackers to execute unauthorized scripts within administrative interfaces.

These vulnerabilities create a significant risk because compromised infusion pumps can directly impact patient treatment and physical safety.

---

### Vendor Recommendation

BD recommends implementing strong network security controls around Alaris systems, including:

- Deploying **network perimeter security controls**.
- Restricting network communication using **firewalls and Access Control Lists (ACLs)**.
- Allowing Point-of-Care Units (PCUs) to communicate only with required services, such as:
  - DNS
  - DHCP
  - Systems Manager communication over **TCP port 3613**
- Segmenting BD Alaris devices into a dedicated and isolated **Virtual Local Area Network (VLAN)**.
- Preventing unnecessary communication between medical devices and general corporate systems.

These controls reduce the attack surface and limit the possibility of lateral movement from compromised corporate endpoints.

---

### MedDefense Implementation Status

MedDefense has **not implemented the recommended security controls**.

The current infrastructure follows a **flat internal network architecture**, where BD Alaris infusion pumps operate on the same network segment as:

- General corporate workstations
- Administrative systems
- Internal servers
- Other non-medical devices

Because network segmentation has not been applied, compromised internal endpoints can potentially communicate directly with infusion pumps.

This creates a high-risk environment where attackers gaining access to a normal corporate workstation could perform lateral movement toward critical medical devices.

---

# Philips IntelliVue Assessment

## Data Flows

Philips IntelliVue patient monitoring systems process and transmit sensitive real-time clinical information, including:

- Continuous ECG waveform data
- Blood pressure measurements
- Oxygen saturation (SpO2) readings
- Patient identification information
- HL7-based clinical event messages
- Alarm notifications and monitoring data

These systems are critical components of hospital patient monitoring infrastructure and require strong protection against unauthorized access or manipulation.

---

## Attacker Capabilities

Due to the presence of **unauthenticated web interfaces** and exposed **HL7 communication ports** on the flat network environment, an attacker with network access may be able to:

- View live patient physiological data.
- Modify patient monitor display configurations.
- Inject spoofed clinical information.
- Trigger false alarms.
- Cause alarm fatigue among medical staff.
- Disrupt communication between monitoring systems and healthcare applications.

Unlike traditional IT systems, manipulation of medical monitoring devices can directly influence clinical decision-making and patient care.

---

# Patient Safety Dimension

## Medical IoT Risk Classification

Medical device vulnerabilities must be evaluated differently from standard cybersecurity risks because they belong to a **physical safety and life-support category**.

In traditional IT environments:

- Confidentiality loss may result in data exposure.
- Availability loss may result in operational downtime.
- Integrity loss may result in incorrect information.

However, in medical IoT environments, cyber compromise can translate directly into physical harm.

---

## Worst-Case Scenario Comparison

| System Type | Cyber Impact | Potential Consequence |
|---|---|---|
| Standard IT workstation | Data theft or system outage | Loss of confidentiality or operational disruption |
| Medical infusion pump | Unauthorized medication changes | Patient injury, overdose, or death |
| Patient monitoring system | False telemetry or alarm manipulation | Incorrect diagnosis or delayed emergency response |

A compromised infusion pump could potentially:

- Deliver excessive medication doses.
- Stop medication delivery.
- Modify therapy parameters.
- Endanger patients dependent on continuous treatment.

Therefore, medical device security must prioritize **patient safety and operational integrity over traditional cybersecurity priorities alone**.

---

# Remediation Challenge

## Regulatory Constraints

Medical devices are regulated as complete medical systems by authorities such as the **U.S. Food and Drug Administration (FDA)**.

Healthcare organizations cannot freely:

- Modify operating system components.
- Install generic security patches.
- Replace software binaries.
- Alter proprietary firmware.

Unauthorized modifications may invalidate medical device certification and regulatory approval.

---

## Operational Continuity Challenges

Medical devices often operate in critical care environments where downtime is unacceptable.

Unlike standard enterprise systems:

- Devices cannot always be rebooted immediately.
- Emergency patching may interrupt patient monitoring.
- Taking equipment offline may directly affect ongoing treatments.

Security improvements must therefore be carefully planned around clinical availability requirements.

---

## Vendor Dependency

Healthcare organizations are dependent on medical device manufacturers for:

- Firmware updates.
- Security patches.
- Vulnerability remediation.
- Certified maintenance procedures.

Hospitals generally cannot directly modify proprietary medical device firmware due to legal, safety, and regulatory restrictions.

As a result, remediation timelines may depend on:

- Vendor patch development cycles.
- Regulatory approval processes.
- Scheduled maintenance windows.

---

# Risk Conclusion

The current MedDefense environment presents a **critical Medical IoT security risk** due to the lack of network segmentation and exposure of life-critical devices on a flat internal network.

The highest-priority remediation actions include:

1. Implement dedicated VLAN segmentation for medical devices.
2. Restrict communication using firewall rules and ACLs.
3. Apply vendor-approved firmware and security updates.
4. Monitor medical device network traffic continuously.
5. Establish strict access controls between corporate IT systems and clinical IoT environments.

Protecting medical IoT systems requires treating cybersecurity as a **patient safety requirement**, not only as a traditional information security concern.
