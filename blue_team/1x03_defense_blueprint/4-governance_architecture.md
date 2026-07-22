# 4. Governance Architecture

## Security Governance Structure for MedDefense Health Systems

**Date:** July 22, 2026  
**Analyst:** Security Department  
**Document:** Project 1x03 — Defense Strategy and Risk Register (Task 4)  
**Reference:** 1x00 Organizational Context, 1x03 Task 0 Framework Selection  

---

# Part 1 — RACI Matrix

## Security Governance Responsibility Assignment

### RACI Legend

- **R — Responsible:** Performs the activity and completes the work.
- **A — Accountable:** Owns the final decision and outcome.
- **C — Consulted:** Provides expertise and recommendations.
- **I — Informed:** Receives updates and awareness information.

| Security Activity | CEO / Executive Leadership | Deputy CISO (James) | IT Director (Sarah) | Department Heads | Security Analyst (You) |
|------------------|----------------------------|---------------------|---------------------|------------------|------------------------|
| Security budget approval | A | R | C | I | C |
| Vulnerability remediation | I | A | R | I | R |
| Incident response execution | I | A | R | C | R |
| Security policy approval | A | R | C | C | C |
| Risk acceptance decisions | A | R | C | C | C |
| Security awareness training | I | A | C | R | R |
| Vendor risk assessment | I | A | C | C | R |
| Audit coordination | I | A | R | C | R |

---

# RACI Assignment Explanation

## Security Budget Approval

The CEO / Executive Leadership team is **Accountable** because cybersecurity investment decisions require executive ownership and financial approval.

The Deputy CISO (James) is **Responsible** for developing the security budget proposal, estimating costs, and aligning spending with identified risks.

The IT Director (Sarah) is **Consulted** because security investments affect infrastructure and operational requirements.

Department Heads are **Informed** about budget decisions that affect their departments.

The Security Analyst provides supporting risk information and cost justification.

---

## Vulnerability Remediation

The Deputy CISO (James) is **Accountable** for ensuring vulnerabilities are addressed according to security priorities and remediation timelines.

The IT Director (Sarah) is **Responsible** for implementing technical fixes, including:

- System patching
- Configuration changes
- Access control updates

The Security Analyst is **Responsible** for:

- Vulnerability validation
- Security scanning
- Verification of remediation effectiveness

This creates separation between remediation execution and independent verification.

---

## Incident Response Execution

The Deputy CISO (James) is **Accountable** for incident response coordination, escalation decisions, and communication with leadership.

The IT Director (Sarah) is **Responsible** for technical containment activities such as:

- System isolation
- Account disabling
- Infrastructure recovery

The Security Analyst is **Responsible** for:

- Investigation
- Evidence collection
- Threat analysis
- Forensic activities

Department Heads are **Consulted** when incidents impact patient care or business operations.

---

## Security Policy Approval

The CEO / Executive Leadership team is **Accountable** because organizational policies require executive approval.

The Deputy CISO (James) is **Responsible** for policy development, cybersecurity alignment, and ensuring policies meet regulatory expectations.

The IT Director and Department Heads are **Consulted** to ensure policies are practical and operationally acceptable.

The Security Analyst supports research and documentation but does not approve policies.

---

## Risk Acceptance Decisions

The CEO / Executive Leadership team is the final **Accountable** authority for accepting business risks.

The Deputy CISO (James) is **Responsible** for preparing risk analysis, including:

- Risk impact
- Likelihood assessment
- Annual Loss Expectancy (ALE)
- Recommended treatment options

The IT Director, Department Heads, and Security Analyst are **Consulted**.

The Security Analyst does not own risk acceptance decisions because security teams identify and analyze risks, while business leadership accepts organizational risk.

---

## Security Awareness Training

The Deputy CISO is **Accountable** for the overall awareness program.

Department Heads are **Responsible** for ensuring employees complete required training.

The Security Analyst is **Responsible** for:

- Training material creation
- Phishing simulations
- Awareness measurement

---

## Vendor Risk Assessment

The Deputy CISO is **Accountable** for third-party security risk management.

The Security Analyst is **Responsible** for:

- Reviewing vendor security controls
- Assessing risks
- Documenting findings

The IT Director and Department Heads provide consultation regarding technical and operational requirements.

---

## Audit Coordination

The Deputy CISO is **Accountable** for audit readiness and compliance activities.

The IT Director is **Responsible** for providing technical evidence and completing infrastructure-related remediation.

The Security Analyst is **Responsible** for:

- Evidence collection
- Documentation preparation
- Auditor communication

---

# Part 2 — Role Definitions

---

# Data Owner

**Assigned To:** Department Heads  
**Examples:**  
- Dr. Patel — Cardiology patient records  
- Revenue Cycle Manager — Billing information  

## Definition

The Data Owner is the business leader responsible for a specific information domain.

Responsibilities include:

- Determining data classification
- Approving access requirements
- Defining appropriate data usage
- Reviewing access decisions

The Data Owner understands the business importance of information and accepts business consequences if data is improperly accessed or compromised.

## Why This Role Belongs to Department Heads

Department Heads understand the clinical and operational requirements of their information.

For example, Dr. Patel understands which healthcare professionals require access to cardiology records and what constitutes legitimate clinical usage.

IT and Security should not own data because they do not determine the business purpose of information.

---

# Data Controller

**Assigned To:** MedDefense Health Systems  
**Represented By:** CEO / Executive Leadership

## Definition

The Data Controller determines why and how Protected Health Information (PHI) is collected, processed, stored, and shared.

MedDefense is responsible for:

- HIPAA compliance
- Privacy obligations
- PHI protection
- Breach notification requirements

## Why MedDefense Holds This Role

MedDefense creates, receives, maintains, and transmits healthcare information during patient care operations.

The organization itself holds legal responsibility. This responsibility cannot be transferred to IT teams or external vendors.

---

# Data Processor

**Assigned To:** External service providers handling PHI on behalf of MedDefense

Examples:

- SecurePoint Consulting
- Medical device cloud providers
- Microsoft 365 services

## Definition

A Data Processor performs data processing activities on behalf of the Data Controller.

Processors must:

- Follow contractual requirements
- Protect PHI
- Maintain security controls
- Sign Business Associate Agreements (BAAs)

## Why These Organizations Hold This Role

Third-party vendors process healthcare information but do not decide why the information is collected or used.

They provide services while following MedDefense's instructions.

---

# Data Custodian / Steward

**Assigned To:** IT Director (Sarah) and IT Operations Team

## Definition

The Data Custodian / Steward is responsible for implementing technical safeguards that protect organizational information.

Responsibilities include:

- Access management
- Encryption
- Backup administration
- System security configuration
- Network protection
- Storage management

## Why IT Holds This Role

Sarah and the IT team manage:

- Servers
- Databases
- Network infrastructure
- Backup systems
- Endpoint security

They implement access decisions made by Data Owners and policies defined by MedDefense leadership.

## Ownership vs Custody

Data ownership belongs to business leaders because they determine why information is used, how sensitive it is, and who requires access.

Data custody belongs to IT because they maintain systems, enforce approved access controls, and implement technical protections.

IT does not decide business access requirements; IT only applies and enforces approved decisions.

---

# Part 3 — The CISO Function

# Consequences of the Vacant CISO Position

The absence of a permanent CISO creates gaps in strategic leadership, accountability, executive communication, and regulatory readiness.

---

## 1. Lack of Security Accountability

Without a permanent CISO, responsibility is divided between James (Deputy CISO) and Sarah (IT Director).

This creates uncertainty regarding security ownership and may delay important decisions during security incidents.

---

## 2. Limited Authority Across Departments

A Deputy CISO may not have sufficient executive authority to enforce cybersecurity requirements across all departments.

Department leaders may challenge security decisions because James does not have C-level authority.

A CISO provides enterprise-wide security authority.

---

## 3. Missing Strategic Security Leadership

The Deputy CISO focuses mainly on operational security activities.

A mature cybersecurity program requires strategic leadership for:

- Security roadmap development
- Framework adoption
- HIPAA compliance
- Long-term risk management

---

## 4. Reduced Board-Level Visibility

The Board approved a $120,000 cybersecurity budget.

Without a CISO, there is no dedicated executive responsible for presenting:

- Security posture
- Risk metrics
- Program progress
- Investment priorities

---

## 5. Increased Audit and Regulatory Risk

Although HIPAA does not require a specific CISO title, regulators expect organizations to demonstrate effective security leadership.

A vacant security leadership position may increase scrutiny during investigations.

---

# CISO Recommendation Options

## Option 1 — Hire a Full-Time CISO

### Advantages

- Dedicated executive security leadership
- Direct Board representation
- Strong organizational authority

### Disadvantages

- Estimated healthcare CISO salary:
  **$180,000–$250,000 annually**
- Exceeds MedDefense's current $120,000 security budget
- Reduces available funding for remediation activities

---

# Option 2 — Hire a Virtual CISO (vCISO) — Recommended

## Recommendation

MedDefense should implement a Virtual CISO (vCISO) model through a managed security provider.

## Justification

A vCISO typically costs approximately:

**$60,000–$90,000 annually**

This allows MedDefense to receive executive-level cybersecurity expertise while preserving budget for:

- Vulnerability remediation
- Network segmentation
- Security monitoring
- Infrastructure improvements

The vCISO provides:

- Strategic security leadership
- Board reporting
- HIPAA compliance guidance
- Risk governance
- Cross-department security authority

James Chen can continue managing daily security operations while the vCISO provides strategic direction.

This recommendation should be reviewed after 12–18 months when MedDefense reaches a higher cybersecurity maturity level.

---

# Governance Structure Diagram

```
Board of Directors
        |
        v
CEO / Executive Leadership
(Accountable for organizational security and risk acceptance)
        |
        v
Virtual CISO (vCISO)
(Strategic leadership, compliance, Board communication)
        |
        v
Deputy CISO (James)
(Security program execution and risk management)
        |
        v
IT Director (Sarah)
(Technical security implementation and infrastructure protection)
        |
        v
Department Heads
(Data ownership and operational decisions)
        |
        v
Security Analyst
(Security testing, monitoring, validation, investigation)
```

---

**Prepared By:** Security Department  

**References:**
- 1x00 Organizational Context
- 1x02 Task 20 Budget Analysis
- 1x03 Task 0 Framework Selection
- HIPAA Security Rule 45 CFR 164.308
- NIST CSF 2.0 Govern Function

**Classification:** CONFIDENTIAL — INTERNAL USE ONLY
