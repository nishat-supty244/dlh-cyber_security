# The Risk Equation

## GAP-001: Internal Network Segmentation Deficiency

**Description:**  
Internal network operates as a single broadcast domain (**10.10.0.0/16**) with no VLAN segmentation between departments or device types.

### Vulnerability Evidence
- Finding 003: PostgreSQL Unrestricted Access.
- Finding 004: BlueKeep / EternalBlue vulnerability on MRI systems.
- Finding 010: BD Alaris default credentials.
- Finding 007: LDAP Signing Not Required.

### Threat Context
- Organized Crime / Ransomware-as-a-Service (RaaS)  
  - Kill Chain #1 — Ransomware Deployment.
- Nation-State Actors  
  - Kill Chain #2 — EHR Data Exfiltration.
- Opportunistic Attackers  
  - Kill Chain #3 — Medical Device Compromise.

### Framework Mapping
- **NIST CSF Function:** Protect (PR.IR — Technology Infrastructure Resilience)
- **CIS Control:** CIS Control 12 — Network Infrastructure Management  
  - IG1 Safeguard 12.2  
  - IG2 Safeguard 12.3

### Recommended Action
Deploy VLAN segmentation to separate:
- Clinical IoT networks.
- Medical Imaging systems.
- Administrative computing environments.
- Management networks.

Implement strict inter-VLAN firewall rules to control communication paths.

---

# GAP-002: Lack of Multi-Factor Authentication for Remote Access

**Description:**  
Remote access portals used by employees and external vendors do not enforce multi-factor authentication (MFA).

### Vulnerability Evidence
- Finding 001: Internet-exposed RDP with weak credentials.
- Finding 002: VPN portal without MFA.

### Threat Context
- Organized Crime / RaaS  
  - Kill Chain #1 — Credential Stuffing and Unauthorized Remote Access.

### Framework Mapping
- **NIST CSF Function:** Protect (PR.AA — Identity Management, Authentication, and Access Control)
- **CIS Control:** CIS Control 6 — Access Control Management  
  - IG1 Safeguard 6.3

### Recommended Action
Enforce mandatory context-aware MFA across:
- Remote VPN portals.
- Administrative endpoints.
- Cloud services.
- Privileged user accounts.

---

# GAP-003: Lack of Vulnerability Management and Patch Governance

**Description:**  
MedDefense lacks a centralized vulnerability management program and recurring patch management lifecycle.

### Vulnerability Evidence
- Finding 004: BlueKeep / MS17-010 EternalBlue vulnerability on legacy imaging systems.
- Finding 006: Unsupported Windows Server 2012 R2 systems.

### Threat Context
- Organized Crime / RaaS  
  - Kill Chain #1 — Exploitation of Known Vulnerabilities.

### Framework Mapping
- **NIST CSF Function:**  
  - Protect (PR.PS — Platform Security)
  - Identify (ID.RA — Risk Assessment)
- **CIS Control:** CIS Control 7 — Continuous Vulnerability Management  
  - IG1 Safeguard 7.1  
  - IG2 Safeguard 7.4

### Recommended Action
Establish:
- Automated recurring vulnerability scanning.
- Risk-based vulnerability prioritization.
- Formal 30-day emergency patching policy for critical infrastructure.

---

# GAP-004: Absence of Centralized Logging and SIEM Monitoring

**Description:**  
MedDefense has no centralized logging, log aggregation, or Security Information and Event Management (SIEM) capability.

### Vulnerability Evidence
- Finding 008: Lack of audit trail and log forwarding.
- Finding 009: Unmonitored local authentication logs.

### Threat Context
- Insider Threat.
- Nation-State Actors.
- Kill Chain #2 — Stealthy Lateral Movement and Data Exfiltration.

### Framework Mapping
- **NIST CSF Function:** Detect (DE.CM — Continuous Monitoring)
- **CIS Control:** CIS Control 8 — Audit Log Management  
  - IG1 Safeguard 8.2  
  - IG2 Safeguard 8.3

### Recommended Action
Deploy:
- Centralized log collection pipeline.
- SIEM platform.
- Automated alert correlation.

Collect logs from:
- Domain controllers.
- Firewalls.
- Critical servers.
- Medical systems.
- Endpoint devices.

---

# GAP-005: Weak Backup Protection and Recovery Readiness

**Description:**  
Critical clinical and administrative database backups are unverified, improperly isolated, and vulnerable to ransomware destruction.

### Vulnerability Evidence
- Finding 011: Local administrative backups accessible from production networks.

### Threat Context
- Organized Crime / RaaS  
  - Kill Chain #1 — Backup Destruction During Ransomware Extortion.

### Framework Mapping
- **NIST CSF Function:** Recover (RC.RP — Incident Recovery Plan Execution)
- **CIS Control:** CIS Control 11 — Data Recovery  
  - IG1 Safeguard 11.2  
  - IG2 Safeguard 11.4

### Recommended Action
Implement:
- Immutable backup storage.
- Air-gapped backup architecture.
- Monthly recovery restoration testing.
- Backup integrity validation procedures.

---

# GAP-006: Missing Incident Response Plan

**Description:**  
MedDefense lacks a formal documented Incident Response Plan (IRP) and structured containment procedures.

### Vulnerability Evidence
- Finding 012: No defined incident triage or containment playbooks.

### Threat Context
- All Threat Actors:
  - Organized Crime.
  - Nation-State Actors.
  - Opportunistic Attackers.

Kill Chain Impact:
- Increased dwell time due to delayed detection and response.

### Framework Mapping
- **NIST CSF Function:** Respond (RS.MA — Incident Management)
- **CIS Control:** CIS Control 17 — Incident Response Management  
  - IG1 Safeguard 17.1  
  - IG2 Safeguard 17.2

### Recommended Action
Develop, approve, and test an Incident Response Plan including:
- Incident classification.
- Triage workflows.
- Escalation procedures.
- Communication plans.
- Containment playbooks.

Conduct regular tabletop exercises.

---

# GAP-007: Default Credentials and Weak System Hardening

**Description:**  
Medical devices and workstations operate with default vendor credentials and insecure default configurations.

### Vulnerability Evidence
- Finding 010: BD Alaris infusion pump default credentials.
- Finding 005: Default administrative passwords on core network switches.

### Threat Context
- Opportunistic Attackers.
- Hacktivists.
- Kill Chain #3 — Medical Device Compromise.

### Framework Mapping
- **NIST CSF Function:** Protect (PR.PS — Platform Security)
- **CIS Control:** CIS Control 4 — Secure Configuration of Enterprise Assets and Software  
  - IG1 Safeguard 4.1  
  - IG2 Safeguard 4.2

### Recommended Action
Implement:
- Standardized secure configuration baselines.
- Immediate removal of all default credentials.
- Strong password requirements for medical equipment and network infrastructure.

---

# GAP-008: Lack of Security Awareness and Phishing Training

**Description:**  
MedDefense lacks formal security awareness training and interactive phishing simulation programs for employees.

### Vulnerability Evidence
- Finding 013: High susceptibility to credential harvesting through social engineering.

### Threat Context
- Organized Crime / RaaS  
  - Kill Chain #1 — Phishing and Spear-Phishing Initial Access.

### Framework Mapping
- **NIST CSF Function:** Protect (PR.AT — Awareness and Training)
- **CIS Control:** CIS Control 14 — Security Awareness and Skills Training  
  - IG1 Safeguard 14.1  
  - IG2 Safeguard 14.2

### Recommended Action
Implement a continuous security awareness platform including:
- Monthly phishing simulations.
- Role-based cybersecurity training.
- Clinical staff awareness programs.
- Social engineering prevention exercises.

---

# Traceability Summary Table

| Gap Reference | Description | Vulnerability Evidence | Threat Context | NIST CSF Function | CIS Control | Recommended Action |
|---|---|---|---|---|---|---|
| GAP-001 | Flat internal network with no VLAN segmentation | Findings 003, 004, 010, 007 | Organized Crime / Nation-State / Opportunistic | Protect (PR.IR) | CIS Control 12 (IG1/IG2) | Deploy VLAN segmentation separating Clinical IoT, Imaging, and Administrative networks |
| GAP-002 | Remote access portal lacks MFA | Findings 001, 002 | Organized Crime / RaaS | Protect (PR.AA) | CIS Control 6 (IG1) | Enforce MFA on remote access VPN portals and cloud endpoints |
| GAP-003 | Lack of vulnerability management and patch cadence | Findings 004, 006 | Organized Crime / RaaS | Protect (PR.PS) / Identify (ID.RA) | CIS Control 7 (IG1/IG2) | Establish automated scanning and 30-day emergency patch cycle |
| GAP-004 | No centralized logging or SIEM | Findings 008, 009 | Insider Threat / Nation-State | Detect (DE.CM) | CIS Control 8 (IG1/IG2) | Deploy centralized logging and SIEM monitoring |
| GAP-005 | Backups vulnerable to ransomware | Finding 011 | Organized Crime / RaaS | Recover (RC.RP) | CIS Control 11 (IG1/IG2) | Implement immutable, air-gapped backups and restoration testing |
| GAP-006 | No Incident Response Plan | Finding 012 | All Threat Actors | Respond (RS.MA) | CIS Control 17 (IG1/IG2) | Develop, approve, and test formal Incident Response procedures |
| GAP-007 | Default credentials and weak configurations | Findings 005, 010 | Opportunistic / Hacktivist | Protect (PR.PS) | CIS Control 4 (IG1/IG2) | Apply hardening baselines and remove default passwords |
| GAP-008 | No security awareness training | Finding 013 | Organized Crime / RaaS | Protect (PR.AT) | CIS Control 14 (IG1/IG2) | Deploy continuous awareness and phishing simulation training |
