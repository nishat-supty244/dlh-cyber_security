# The CIS Controls Audit

## CIS Control 1: Inventory and Control of Enterprise Assets

**Score:** Partial

### Evidence
MedDefense lacked a centralized and comprehensive hardware inventory before the security assessment team built one from scratch during **Project 1x00**.

---

## CIS Control 2: Inventory and Control of Software Assets

**Score:** Partial

### Evidence
Software inventories were siloed and incomplete across departments, allowing unmanaged and outdated applications to remain active without centralized oversight. These issues were identified during **Project 1x00**.

---

## CIS Control 3: Data Protection

**Score:** Not Implemented

### Evidence
Sensitive patient Electronic Health Records (EHR) lack:
- Comprehensive data flow mapping.
- Formal data classification and labeling.
- Consistent encryption controls across legacy databases.

---

## CIS Control 4: Secure Configuration of Enterprise Assets and Software

**Score:** Not Implemented

### Evidence
Workstations and servers operate using default manufacturer configurations and lack standardized hardened security baselines, as revealed during the vulnerability assessment.

---

## CIS Control 5: Account Management

**Score:** Partial

### Evidence
User and service accounts are maintained across disconnected directories, with orphaned accounts remaining active after employee departures.

---

## CIS Control 6: Access Control Management

**Score:** Not Implemented

### Evidence
Multi-factor authentication (MFA) is missing on critical remote access portals, violating fundamental least-privilege and identity protection principles.

---

## CIS Control 7: Continuous Vulnerability Management

**Score:** Partial

### Evidence
Vulnerability scanning was introduced only recently during **Project 1x02**, revealing numerous unpatched systems without an active recurring remediation lifecycle.

---

## CIS Control 8: Audit Log Management

**Score:** Not Implemented

### Evidence
Marcus's notes confirmed a complete absence of:
- Centralized log collection.
- Security event analysis.
- SIEM-based log storage and monitoring.

---

## CIS Control 9: Email and Web Browser Protections

**Score:** Partial

### Evidence
Basic corporate email filtering exists through legacy solutions; however:
- Anti-phishing sandboxing is unavailable.
- Advanced browser isolation protections are not implemented.

---

## CIS Control 10: Malware Defenses

**Score:** Partial

### Evidence
Traditional signature-based antivirus solutions operate inconsistently across selected endpoints but lack modern centralized Endpoint Detection and Response (EDR) capabilities.

---

## CIS Control 11: Data Recovery

**Score:** Partial

### Evidence
Ad-hoc backups exist for specific administrative databases; however:
- Backups are not regularly verified.
- Storage is not properly isolated.
- Backup systems remain vulnerable to ransomware encryption.

---

## CIS Control 12: Network Infrastructure Management

**Score:** Not Implemented

### Evidence
The hospital network lacks proper segmentation, leaving legacy medical devices exposed on the same flat network as standard administrative systems.

---

## CIS Control 13: Network Monitoring and Defense

**Score:** Not Implemented

### Evidence
MedDefense has no network traffic monitoring capability, resulting in no visibility into:
- Internal lateral movement.
- Suspicious network behavior.
- Active cyber intrusions.

---

## CIS Control 14: Security Awareness and Skills Training

**Score:** Not Implemented

### Evidence
No formal security awareness training or phishing simulation program exists for hospital employees or clinical personnel.

---

## CIS Control 15: Service Provider Management

**Score:** Not Implemented

### Evidence
Third-party medical vendors and software providers connect to the hospital network without:
- Formal security assessments.
- Vendor risk tracking.
- Security compliance validation.

---

## CIS Control 16: Application Software Security

**Score:** Not Implemented

### Evidence
Custom medical software integrations are deployed without:
- Secure code review processes.
- Application security testing.
- Vulnerability lifecycle management.

---

## CIS Control 17: Incident Response Management

**Score:** Not Implemented

### Evidence
MedDefense lacks:
- A documented Incident Response Plan (IRP).
- A designated incident response team.
- Structured containment and recovery procedures.

---

## CIS Control 18: Penetration Testing

**Score:** Not Implemented

### Evidence
No simulated cyber attacks or formal penetration tests have been conducted against MedDefense's infrastructure.

---

# CIS Controls Scorecard Summary

| Implementation Status | Count |
|---|---:|
| Implemented | 0 |
| Partial | 7 |
| Not Implemented | 11 |

---

# Top 5 Priority CIS Controls

## 1. CIS Control 6: Access Control Management

### Priority Rationale
Implementing MFA across all remote and administrative access points will immediately reduce the risk of:
- Credential theft.
- Credential stuffing attacks.
- Unauthorized remote access attempts.

This addresses one of the most common initial access vectors used in healthcare ransomware attacks.

---

## 2. CIS Control 7: Continuous Vulnerability Management

### Priority Rationale
Establishing recurring vulnerability scanning and a structured patch management process will:
- Identify exposed weaknesses.
- Reduce exploitable vulnerabilities.
- Address security flaws discovered during **Project 1x02**.

---

## 3. CIS Control 11: Data Recovery

### Priority Rationale
Deploying isolated and immutable backup solutions will enable MedDefense to:
- Restore critical clinical operations quickly.
- Reduce ransomware impact.
- Avoid dependence on attacker-controlled recovery negotiations.

---

## 4. CIS Control 1: Inventory and Control of Enterprise Assets

### Priority Rationale
Expanding the asset inventory created during **Project 1x00** will ensure:
- All hardware assets are identified.
- Rogue or unmanaged devices are discovered.
- Security visibility is maintained across the environment.

---

## 5. CIS Control 17: Incident Response Management

### Priority Rationale
Developing a formal Incident Response Plan will provide the security team with:
- Clear incident triage procedures.
- Containment playbooks.
- Defined communication and escalation workflows.

This will improve MedDefense's ability to respond effectively during active cyber incidents.

---

# Overall Assessment

MedDefense currently demonstrates significant cybersecurity maturity deficiencies across preventive, detective, and response capabilities. The absence of implemented CIS Controls creates elevated exposure to ransomware, unauthorized access, data compromise, and operational disruption.

Immediate focus should be placed on identity protection, vulnerability management, recovery resilience, asset visibility, and incident response capabilities to establish a stronger security foundation.
