# 4. Governance Architecture

## Security Governance Framework for MedDefense Health Systems

 

---

# Part 1 — RACI Matrix

**Legend:**  
- **R = Responsible:** Performs the assigned activity.  
- **A = Accountable:** Owns the final outcome and decision authority (only one accountable role per activity).  
- **C = Consulted:** Provides expertise, feedback, or recommendations.  
- **I = Informed:** Receives updates regarding progress or decisions.  

| Activity | CEO | Deputy CISO (James) | IT Director (Sarah) | Department Heads | Security Analyst |
|----------|-----|----------------------|----------------------|------------------|------------------|
| Security budget approval | A | R | C | I | C |
| Vulnerability remediation | I | A | R | I | R |
| Incident response execution | I | A | R | C | R |
| Security policy approval | A | C | C | C | R |
| Risk acceptance decisions | A | C | C | C | R |
| Security awareness training | I | A | I | R | R |
| Vendor risk assessment | I | A | C | C | R |
| Audit coordination | I | A | R | C | R |

---

# Key RACI Decision Explanations

## Security Budget Approval

The CEO holds accountability because executive leadership has ultimate responsibility for financial decisions. James, as Deputy CISO, is responsible for preparing the security budget proposal, including cost estimates and business justification based on identified risks and priorities.

Sarah is consulted because IT operations and infrastructure requirements directly influence security spending. Department Heads are informed when budget decisions impact their operational resources.

---

## Vulnerability Remediation

James is accountable for ensuring that identified vulnerabilities are addressed within agreed service-level timelines. Sarah is responsible for applying technical fixes, including patches, system updates, and configuration changes across IT-managed assets.

The Security Analyst is responsible for confirming remediation effectiveness through validation activities such as rescanning and verification based on the Task 23 Validation Plan.

This structure separates accountability, technical implementation, and independent validation.

---

## Incident Response Execution

James is accountable for activating the incident response process, approving breach notification decisions, and coordinating external communications.

Sarah is responsible for technical containment activities, including system isolation, account disabling, and infrastructure protection.

The Security Analyst performs technical investigation, evidence preservation, forensic analysis, and threat removal activities.

Department Heads are consulted when incidents affect clinical operations to ensure response activities maintain patient care continuity.

---

## Security Policy Approval

The CEO maintains accountability as the organization's highest authority for policy approval.

James provides cybersecurity expertise and contributes security requirements during policy development. Sarah is consulted to confirm technical feasibility and implementation requirements.

Department Heads provide operational feedback when policies impact healthcare workflows.

The Security Analyst is responsible for researching requirements and preparing draft policies but does not hold approval authority.

---

## Risk Acceptance Decisions

The CEO remains the final authority for accepting organizational risks. Risk acceptance is a business decision and cannot be transferred entirely to the security team.

James provides risk analysis, including financial impact calculations such as Annual Loss Expectancy (ALE), remediation costs, and recommended treatment options.

Sarah and Department Heads are consulted when risks affect technology operations or business processes.

The Security Analyst is responsible for collecting supporting evidence, calculating risk values, and maintaining risk documentation.

This separation ensures that security identifies and analyzes risks while business leadership owns the final decision.

---

## Security Awareness Training

James is accountable for the effectiveness and overall management of the security awareness program.

Department Heads are responsible for ensuring employees complete required training and participate in activities such as phishing simulations.

The Security Analyst develops training materials, manages simulations, and supports awareness initiatives.

This approach ensures managers share responsibility for employee security behavior.

---

## Vendor Risk Assessment

James is accountable for maintaining vendor security oversight and ensuring contractual compliance.

Sarah provides technical input regarding system integrations and security requirements.

Department Heads are consulted when vendors support specific business operations.

The Security Analyst conducts vendor assessments, reviews security documentation, and records findings.

---

## Audit Coordination

James is accountable for overall audit preparedness and regulatory compliance.

Sarah is responsible for providing technical evidence and completing required corrective actions.

Department Heads are consulted when audits involve their departments.

The Security Analyst manages audit documentation, evidence collection, and communication with auditors.

---

# Part 2 — Role Definitions

## Data Owner

**Assigned To:** Department Heads  
*(Example: Dr. Patel in Cardiology owns cardiovascular patient information; Revenue Cycle Manager owns billing information.)*

### Definition

The Data Owner is the business leader responsible for managing a specific category of information. This role determines:

- Data classification requirements
- Appropriate access permissions
- Business usage requirements
- Approval of access requests

The Data Owner is also responsible for understanding the business impact if the information is compromised.

### Reason for Assignment

Department Heads possess the operational and clinical knowledge required to make appropriate decisions about their data.

For example, Dr. Patel understands which healthcare professionals require access to cardiology records and what represents appropriate clinical usage.

Assigning ownership to IT or Security would create a situation where technical teams make business decisions without sufficient operational context.

---

# Data Controller

**Assigned To:** MedDefense Health Systems  
*(Represented by the CEO as the organizational authority.)*

### Definition

The Data Controller determines why and how Protected Health Information (PHI) is collected, processed, stored, and shared.

Under HIPAA terminology, MedDefense functions as the Covered Entity and is legally responsible for:

- Protecting PHI
- Maintaining compliance
- Managing privacy obligations
- Reporting breaches when required

### Reason for Assignment

MedDefense creates, receives, maintains, and transmits healthcare information as part of its medical operations.

The organization itself holds legal responsibility, and this responsibility cannot be transferred to IT teams or external vendors.

---

# Data Processor

**Assigned To:** External service providers processing PHI on behalf of MedDefense

Examples:

- SecurePoint Consulting for security assessments
- BD for medical device cloud telemetry
- Microsoft 365 for email processing

### Definition

A Data Processor is an external organization that handles PHI while providing services to the Data Controller.

Under HIPAA, these organizations operate as Business Associates and must sign Business Associate Agreements (BAAs) defining their security responsibilities.

### Reason for Assignment

These providers process healthcare information but do not determine the purpose of processing.

Their responsibilities are limited to performing contracted services while protecting MedDefense data.

---

# Data Custodian / Steward

**Assigned To:** IT Director Sarah Park and IT Operations Team

### Definition

The Data Custodian is responsible for the technical protection and maintenance of organizational information.

Responsibilities include:

- Access management
- Encryption implementation
- Backup management
- Storage security
- Transmission protection
- Security configuration

The Custodian implements decisions made by Data Owners and enforces policies defined by the organization.

### Reason for Assignment

Sarah Park and the IT team manage:

- Servers
- Databases
- Network infrastructure
- Backup platforms
- Security configurations

They administer technical controls such as PostgreSQL permissions, Active Directory accounts, Synology NAS backups, and network segmentation.

However, IT does not determine who should access data or why the data is used; they enforce business decisions through technical mechanisms.

---

# Part 3 — The CISO Function and Recommendation

# Impact of the Vacant CISO Position

The absence of a permanent Chief Information Security Officer creates several security governance challenges.

---

## 1. Lack of Clear Security Accountability

Without a dedicated CISO, cybersecurity ownership becomes unclear between James (Deputy CISO) and Sarah (IT Director).

This creates overlapping responsibilities and potential conflicts, particularly regarding areas such as endpoint security ownership.

During a cybersecurity incident, unclear authority may delay critical response decisions.

---

## 2. Limited Authority Across Departments

A Deputy CISO may not have sufficient organizational authority to enforce security requirements across independent departments.

For example, Department Heads may challenge security requirements because James does not hold executive-level authority.

A CISO provides the leadership position necessary to enforce enterprise-wide security policies.

---

## 3. Absence of Strategic Security Leadership

The Deputy CISO role primarily focuses on operational security activities.

However, developing a long-term cybersecurity strategy requires executive leadership responsible for:

- Security roadmap development
- HIPAA compliance
- Framework adoption
- Audit preparation
- Security maturity improvement

---

## 4. Reduced Board-Level Security Visibility

The Board approved a $120K security investment based on identified risks.

Without a CISO, there is no dedicated executive leader consistently communicating:

- Security posture
- Risk metrics
- Program progress
- Strategic security needs

James participates as a Deputy role rather than an executive peer.

---

## 5. Increased Audit and Regulatory Exposure

Although HIPAA does not specifically require a CISO position, regulatory investigations evaluate whether organizations demonstrate effective security leadership.

A vacant CISO role during a security incident may increase scrutiny regarding governance effectiveness and organizational responsibility.

---

# Recommendation: Implement a Virtual CISO (vCISO)

MedDefense should engage a **Virtual Chief Information Security Officer (vCISO)** through a managed security provider instead of immediately hiring a full-time CISO.

A permanent CISO position in healthcare typically requires approximately **$180,000–$250,000 annually**, which would exceed the organization's current **$120,000 security budget** and reduce available funding for critical remediation activities.

A vCISO engagement generally costs approximately **$60,000–$90,000 annually**, providing strategic security leadership while preserving budget for:

- Vulnerability remediation
- Network segmentation
- Security monitoring
- Infrastructure improvements

The vCISO would provide:

- Executive-level security leadership
- Board reporting
- HIPAA compliance guidance
- Strategic planning
- Cross-department security authority

James Chen would continue managing daily security operations and implementing the security program.

This arrangement should be reviewed after **12–18 months**, once major remediation activities are completed and MedDefense reaches a higher cybersecurity maturity level suitable for a full-time CISO.

---

# Governance Structure Diagram

```
Board of Directors
        |
        v
CEO
(Accountable for enterprise security and risk acceptance)
        |
        v
Virtual CISO (vCISO)
(Strategic security leadership, Board reporting, HIPAA compliance)
        |
        v
Deputy CISO - James Chen
(Security execution, risk analysis, incident response coordination)
        |
        v
IT Director - Sarah Park
(Infrastructure security, patching, backups, account management)
        |
        v
Department Heads
(Data ownership, employee compliance, operational input)
        |
        v
Security Analyst
(Vulnerability scanning, monitoring, validation, awareness content, investigations)
```

---

**Prepared By:** Security Department  
**References:**  
- 1x00 Organizational Context (staffing, budget, vacant CISO position)  
- 1x02 Task 20 (Budget limitations)  
- 1x03 Task 0 (Framework selection)  
- HIPAA Security Rule 45 CFR 164.308 (Administrative Safeguards — Security Management Process)  
- NIST CSF 2.0 Govern Function  

**Classification:** CONFIDENTIAL — INTERNAL USE ONLY
