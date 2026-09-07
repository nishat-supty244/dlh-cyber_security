# The NIST CSF Mapping

## Function: Govern (GV)

**Current Level:** Not Implemented

### Evidence
Sarah Park noted that MedDefense followed **"none formally"** when auditors asked about security frameworks. There is no documented cybersecurity strategy, no formal risk appetite statement, and no structured cybersecurity policy framework.

### Key Gaps
- Total absence of a formal cybersecurity governance structure.
- Missing security policies, including:
  - Acceptable Use Policy
  - Incident Response Policy
  - Access Control Policy
  - Data Protection Policy
- Undefined cybersecurity roles, responsibilities, and authorities across leadership.

### Target Level: Managed

MedDefense must establish formal cybersecurity oversight by adopting **NIST CSF 2.0** as its strategic foundation. The organization should define core security roles, including the **Deputy CISO** and **Security Analyst**, and establish board-level cybersecurity reporting mechanisms within **6 months** to satisfy regulatory and auditor expectations.

---

# Function: Identify (ID)

**Current Level:** Partial

### Evidence
MedDefense did not have a unified asset inventory before the security team arrived in Project 1x00. While basic asset lists existed across separate IT silos, there was no comprehensive centralized tracking of hardware, software, or data flows. Threat and vulnerability assessments were only recently initiated across Projects 1x01 and 1x02.

### Key Gaps
- Incomplete asset visibility across clinical and administrative environments.
- Lack of continuous asset discovery capabilities.
- Informal risk assessment methodologies that fail to quantify:
  - Likelihood of exploitation.
  - Business impact.
  - Operational risk.

### Target Level: Managed

MedDefense must implement:
- Automated asset discovery solutions.
- Centralized asset inventory management.
- Continuous cybersecurity risk assessments.
- Integration between asset management and vulnerability management processes.

These improvements should be completed within **6 months** to maintain accurate visibility of the organization's expanding attack surface.

---

# Function: Protect (PR)

**Current Level:** Partial

### Evidence
The vulnerability scan from Project 1x02 revealed:
- Widespread unpatched vulnerabilities.
- Unsegmented legacy medical device networks.
- Missing multi-factor authentication (MFA) on critical remote access points.
- Inconsistent endpoint security hardening baselines across workstations.

### Key Gaps
- Lack of enforced MFA for critical systems.
- Absence of structured patch management cycles.
- Poor network segmentation between clinical and administrative environments.
- Weak identity and access management controls.
- Inconsistent endpoint security configurations.

### Target Level: Managed

Within **6 months**, MedDefense must:

- Deploy MFA across all critical systems and remote access services.
- Establish secure workstation configuration baselines.
- Implement clinical network segmentation.
- Create formal patch management schedules.
- Strengthen identity and access control mechanisms.

These actions will reduce the organization's primary attack vectors.

---

# Function: Detect (DE)

**Current Level:** Not Implemented

### Evidence
Marcus's notes confirmed **zero enterprise-wide monitoring capability**. MedDefense currently has:
- No Security Information and Event Management (SIEM) platform.
- No centralized log collection.
- No network traffic anomaly detection.
- No 24/7 security monitoring or alerting capability.

### Key Gaps
- Complete lack of real-time security visibility.
- No centralized event correlation.
- No formal log retention strategy.
- Inability to detect:
  - Unauthorized access.
  - Lateral movement.
  - Active compromises.
  - Suspicious user behavior.

### Target Level: Managed

Within **6 months**, MedDefense must implement:

- Centralized security log collection.
- SIEM-based monitoring and alerting.
- Basic network monitoring capabilities.
- Security event correlation processes.

These controls will enable timely detection of cyber threats and unauthorized activities.

---

# Function: Respond (RS)

**Current Level:** Not Implemented

### Evidence
MedDefense has no documented or tested **Incident Response Plan (IRP)**. The organization lacks:
- Defined incident triage procedures.
- Containment playbooks.
- Threat eradication workflows.
- Internal and external communication procedures.

### Key Gaps
- Absence of an established incident response framework.
- Undefined escalation paths.
- Lack of coordinated procedures for:
  - Cyber breaches.
  - Ransomware incidents.
  - Data compromise events.

### Target Level: Managed

Within **6 months**, MedDefense must:

- Develop and approve a formal Incident Response Plan.
- Define incident classification and escalation procedures.
- Create containment and recovery playbooks.
- Conduct tabletop exercises to validate response readiness.
- Establish breach notification procedures.

---

# Function: Recover (RC)

**Current Level:** Partial

### Evidence
MedDefense maintains basic periodic backups for certain administrative systems. However:
- Backups are not reliably isolated from production networks.
- Backup environments remain vulnerable to ransomware encryption.
- Recovery Time Objectives (RTOs) are undefined.
- Backup restoration integrity has never been formally tested.

### Key Gaps
- Lack of immutable or air-gapped backup storage.
- Absence of disaster recovery validation exercises.
- Undefined recovery workflows for critical clinical systems.
- No documented recovery objectives.

### Target Level: Managed

Within **6 months**, MedDefense must establish:

- Isolated and immutable backup architectures.
- Defined Recovery Time Objectives (RTOs) and Recovery Point Objectives (RPOs).
- Formal disaster recovery procedures.
- Verified backup restoration testing.
- Clinical system recovery workflows.

These improvements will strengthen operational resilience against destructive attacks, including ransomware incidents.

---

# NIST CSF Maturity Summary

| Function | Current Level | Target Level |
|---|---|---|
| Govern (GV) | Not Implemented | Managed |
| Identify (ID) | Partial | Managed |
| Protect (PR) | Partial | Managed |
| Detect (DE) | Not Implemented | Managed |
| Respond (RS) | Not Implemented | Managed |
| Recover (RC) | Partial | Managed |

**Overall Assessment:**  
MedDefense currently operates with significant cybersecurity maturity gaps, particularly in governance, detection, and incident response capabilities. Achieving a **Managed** maturity level across all NIST CSF 2.0 functions within 6 months requires establishing formal governance, improving visibility, strengthening preventive controls, deploying monitoring capabilities, formalizing incident response, and enhancing recovery resilience.
