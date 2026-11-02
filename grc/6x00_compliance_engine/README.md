**Learning Objectives – Questions & Answers**

**1\. Technical Learning Objectives**

Q1. How do you map deployed security controls to NIST CSF 2.0 subcategories?

Answer: Identify the security controls already implemented in an organization and match them with the relevant NIST Cybersecurity Framework (CSF) 2.0 subcategories. Use real evidence, such as firewall configurations, system logs, security policies, and audit reports, to prove that the controls exist and operate.

Example: MedDefense uses network segmentation to protect its EHR servers. We map this control to the relevant NIST CSF Protect subcategory and attach firewall configuration evidence.

Q2. How do you identify compliance gaps across the Govern, Protect, Detect, Respond, and Recover functions?

Answer: Compare the organization's existing security practices with NIST CSF requirements to identify missing or ineffective controls.

- Govern (GV): Missing security policies, responsibilities, or risk management processes.
- Protect (PR): Weak access controls, missing MFA, or insufficient encryption.
- Detect (DE): Missing monitoring tools, alerts, or SIEM.
- Respond (RS): No documented incident response procedures.
- Recover (RC): Missing backup testing or disaster recovery plans.

Example: If MedDefense has no SIEM, this represents a gap in its detection capabilities.

Q3. How do you evaluate a vendor's security posture using a structured risk assessment methodology?

Answer: Assess a vendor's security controls, data handling practices, regulatory compliance, and incident response capabilities. Identify potential threats, evaluate their likelihood and impact, and recommend risk treatment measures.

Example: MedDefense uses Nexus Patient Scheduling, a third-party SaaS provider. We assess its encryption, access controls, incident notification procedures, and handling of patient information.

**2\. Conceptual Learning Objectives**

Q4. What is the relationship between NIST CSF 2.0 subcategories and HIPAA Security Rule implementation specifications?

Answer: NIST CSF 2.0 provides a framework for managing cybersecurity risks, while the HIPAA Security Rule establishes legal requirements for protecting electronic protected health information (ePHI) in covered entities and business associates.

NIST CSF subcategories can be mapped to HIPAA requirements to help organizations organize and evaluate their security controls. However, following NIST CSF does not automatically guarantee HIPAA compliance.

Example: NIST CSF addresses access management, while HIPAA requires appropriate access controls to protect ePHI.

Q5. What is the difference between a security control that exists and one that is documented and supported by evidence?

Answer: A control may be technically implemented, but auditors need documentation and evidence to verify that it is properly configured and functioning.

Example:

- Control exists: MedDefense has a firewall.
- Control documented: Firewall rules and configuration procedures are recorded.
- Control evidence-supported: Configuration exports, change records, and relevant logs demonstrate that the firewall is configured and operating as intended.

Q6. What does the principle "Policy without specificity and enforcement mechanism is not policy" mean?

Answer: A security policy must clearly define what is required, who is responsible, and how compliance will be enforced or verified.

Example:

- Weak policy: Employees must use strong passwords.
- Strong policy: Employees must use passwords of at least 14 characters, and the organization's identity management system must enforce the minimum length.

A policy without clear requirements and enforcement is difficult to implement and audit.

**3\. Transversal Learning Objectives**

Q7. How do you write security policies that are concise enough to read and specific enough to enforce?

Answer: Use simple language, avoid unnecessary explanations, and clearly define the security requirements, responsible roles, and enforcement methods.

Example: "All remote access to MedDefense systems must use MFA. The IT Security Team is responsible for enforcing and reviewing this requirement."

Q8. How do you package compliance evidence so an auditor can independently evaluate it?

Answer: Organize evidence in a structured format that includes the control requirement, implementation status, supporting artifacts, evidence references, and any identified gaps.

Example:

| **Control**          | **Evidence**                          | **Status**  |
| -------------------- | ------------------------------------- | ----------- |
| MFA                  | Identity provider configuration       | Implemented |
| Network segmentation | Firewall rules and VLAN configuration | Implemented |
| Security monitoring  | SIEM logs and alerts                  | Missing     |
| Incident response    | Approved IR playbook                  | Documented  |

These statuses are illustrative; actual MedDefense findings must be verified against the project artifacts.

Q9. How do you translate compliance findings into executive language without losing accuracy?

Answer: Explain technical security gaps in terms of business risks, operational impact, regulatory exposure, and recommended actions. Avoid unnecessary technical jargon while keeping the findings accurate.

Example:

- Technical finding: MedDefense lacks centralized SIEM monitoring and correlation.
- Executive explanation: "The organization has limited ability to detect coordinated cyberattacks across its systems. This increases the risk of delayed incident detection and potential disruption to patient services. Implementing centralized security monitoring would improve visibility and response capabilities."

**Quick Revision – Important Concepts**

| **Concept**         | **Simple meaning**                                                     |
| ------------------- | ---------------------------------------------------------------------- |
| NIST CSF 2.0        | Framework for managing cybersecurity risks                             |
| HIPAA Security Rule | US security requirements for protecting electronic patient information |
| Security control    | Measure used to reduce security risks                                  |
| Compliance gap      | Missing or insufficient requirement or control                         |
| Evidence            | Proof that a control is implemented or operating                       |
| Risk assessment     | Process of identifying and evaluating risks                            |
| Vendor assessment   | Evaluating the security of a third-party provider                      |
| Security policy     | Document defining mandatory security rules                             |
| Enforcement         | Making sure security requirements are followed                         |
| Audit               | Independent examination of controls and evidence                       |

Main takeaway: In this MedDefense exercise, main goal is to identify existing security controls, map them to NIST CSF 2.0 and relevant HIPAA requirements, collect supporting evidence, identify gaps, and explain the risks and improvements clearly to management.
