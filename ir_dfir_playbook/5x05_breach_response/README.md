**Learning Objectives**

**1\. Technical Objectives**

**Q1. How do you activate and execute an Incident Response (IR) program during a multi-host, multi-phase incident?**

**Answer: Activate the IR plan, assign responsibilities, assess the incident severity, identify affected hosts, contain threats, preserve evidence, eradicate the attack, recover systems, and document every action. The team must operate independently without step-by-step guidance.**

**Q2. How do you preserve volatile and non-volatile evidence across four affected hosts during an active attack?**

**Answer: Collect volatile evidence such as RAM, running processes, and network connections before it disappears. Preserve non-volatile evidence such as disk images, logs, and files. Use SHA-256 hashes, timestamps, and chain-of-custody records to maintain evidence integrity.**

**Q3. How do you analyze memory, disk, proxy, and Sysmon artifacts to reconstruct a 72-hour attack chain?**

**Answer: Correlate evidence from different sources:**

- **Memory: Identify malicious processes and injected code.**
- **Disk: Examine malicious files and persistence mechanisms.**
- **Proxy logs: Identify suspicious web traffic and C2 communication.**
- **Sysmon: Track process execution, network connections, and system changes.**

**Combine timestamps to reconstruct the attack from initial access to the final malicious activity.**

**Q4. How do you eradicate a Cobalt Strike implant, staged ransomware, and exposed credentials?**

**Answer: Isolate compromised systems, identify and remove malicious implants and persistence mechanisms, block attacker communication, and eliminate staged ransomware. Reset exposed credentials, revoke compromised sessions, patch vulnerabilities, and verify systems are clean before restoring operations.**

**Q5. What is a HIPAA four-factor assessment, and how do you prepare a board-quality incident brief?**

**Answer: A HIPAA four-factor assessment evaluates the probability that protected health information (PHI) was compromised by examining:**

1. **The nature and extent of PHI involved.**
2. **The unauthorized person who accessed or received it.**
3. **Whether PHI was actually acquired or viewed.**
4. **How effectively the risk was mitigated.**

**A board-quality brief summarizes the incident, business impact, patient-data risks, regulatory obligations, actions taken, remaining risks, and decisions required.**

**2\. Conceptual Objectives**

**Q6. How do you combine previously learned incident response, forensic, and improvement skills?**

**Answer: Apply the complete incident response lifecycle: preparation, detection, analysis, containment, eradication, recovery, and lessons learned. Use forensic evidence to support decisions and improve security controls to prevent future incidents.**

**Q7. How do you make decisions when incident information is incomplete?**

**Answer: Evaluate available evidence, identify uncertainties, assess risks, and choose the safest reasonable action. Document the decision, supporting evidence, assumptions, alternatives, and potential consequences.**

**Q8. How should incident communication change depending on the audience, severity, and regulatory requirements?**

**Answer: Adapt communication to the audience:**

- **Technical teams: Provide detailed findings, indicators of compromise, and remediation steps.**
- **Management: Explain business impact, risks, progress, and required decisions.**
- **Board members: Focus on operational, financial, and strategic consequences.**
- **Regulators: Provide accurate, evidence-based information within applicable reporting deadlines.**

**3\. Transversal Objectives**

**Q9. Why must every incident response document stand alone?**

**Answer: Each document must contain enough information for another person to understand the incident and continue the work without verbal explanations or previous context. Include timestamps, evidence references, decisions, actions, responsibilities, and outcomes.**

**Q10. Why must every incident response decision be traceable to evidence or documented reasoning?**

**Answer: Traceability demonstrates why decisions were made and whether they were justified. It supports audits, legal investigations, regulatory compliance, accountability, and future incident response improvements.**

**Key takeaway: This exercise tests your ability to independently manage a complex cybersecurity incident, preserve and analyze evidence, eliminate threats, assess regulatory obligations, and communicate findings professionally.**

**See another version**

**Is this conversation helpful so far?**
