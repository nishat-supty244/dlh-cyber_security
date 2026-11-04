
# MedDefense Health Systems
# CloudVault Medical — Vendor Risk Assessment

**Assessment ID:** MD-VRA-CV-001  
**Vendor:** CloudVault Medical  
**Assessment date:** 2026-11-04  
**Assessment owner:** IT Security  
**Security reviewer:** Helena Reyes  
**Business owner:** Infrastructure Manager  
**Data owner:** Clinical Applications Manager  
**Classification:** Confidential  
**Vendor risk tier:** Tier A — Critical  
**Assessment status:** Not Approved — Onboarding Blocked  
**Policy reference:** `vendor_management_policy.md` (MD-SEC-VMP-001)

---

## 1. Vendor Overview

CloudVault Medical is a proposed third-party provider of clinical backup archives and disaster recovery storage for MedDefense Health Systems.

The proposed contract term is three years.

CloudVault would store encrypted backup archives containing:

- Epic Electronic Health Record (EHR) database exports.
- Laboratory Information System backups.
- PACS/RIS medical imaging metadata.
- Pharmacy dispensing system backups.
- Operational recovery logs that may contain patient identifiers.

CloudVault would receive backups through an encrypted transfer pipeline. Its support personnel may access the backup management console. MedDefense would retain ownership of encryption keys under the proposed design.

Because CloudVault would store or process electronic Protected Health Information (ePHI), it is classified as **Tier A — Critical** under the MedDefense Vendor Management Policy.

Tier A vendors must satisfy all mandatory pre-engagement requirements before onboarding or receiving ePHI.

The assessment is based on CloudVault's 15 questionnaire responses and the supporting contract, BAA, and subprocessor records.

## 2. Assessment Criteria

Each questionnaire item is assigned one of four ratings:

| Rating | Meaning |
|---|---|
| Pass | The supplied evidence meets the applicable policy requirement. |
| Acceptable | The response is acceptable, but supporting evidence or routine monitoring is still needed. |
| Concern | A security or contractual weakness requires corrective action or further verification. |
| Critical Concern | A mandatory requirement is unmet or a significant risk prevents approval. |

A Pass rating for one item does not constitute overall vendor approval.

## 3. Security Questionnaire Findings

| # | Finding (abbreviated response) | Risk Rating | Gap Description | Required Action |
|---|---|---|---|---|
| 1 | SOC 2 Type II report dated 11 months ago | Pass | No date gap; report contents have not been reviewed in the supplied evidence. | Obtain the report and verify scope, findings, and coverage of CloudVault services before approval. |
| 2 | No HITRUST CSF certification | Pass | No gap because policy accepts SOC 2 Type II **or** HITRUST. | No separate HITRUST certification required if the SOC 2 report is valid and acceptable. |
| 3 | AES-256 encryption at rest | Acceptable | Encryption is reported, but implementation and key-management controls have not been verified. | Confirm encryption configuration, MedDefense key ownership, and access restrictions. |
| 4 | TLS 1.2 encryption in transit | Acceptable | TLS 1.2 meets the stated transmission-security baseline; configuration evidence is not provided. | Verify secure transfer configuration and certificate validation. |
| 5 | Penetration test completed 22 months ago; no findings summary | Critical Concern | Tier A policy requires results dated within 12 months and remediation status. | Provide a penetration test report dated within 12 months, a critical-findings summary, and evidence of remediation. |
| 6 | Two subprocessors disclosed: US CDN and EU analytics provider | Concern | Data exposure, administrative access, and contractual safeguards remain unclear. | Complete subprocessor due diligence and verify data flows, safeguards, jurisdictions, and incident notification obligations. |
| 7 | Primary data center in US; DR site undisclosed | Critical Concern | MedDefense cannot determine all storage locations or complete its jurisdiction and recovery-site assessment. | Disclose the DR site location, jurisdiction, data handled, and security controls before approval. |
| 8 | Incident notification within 72 hours after internal breach confirmation | Critical Concern | Policy requires notification within 24 hours of discovering a confirmed or suspected incident affecting MedDefense data. | Amend contract and BAA to require notification within 24 hours of discovery, including suspected incidents. |
| 9 | Data deletion within 90 days of written request | Critical Concern | Policy requires return or certified destruction within 30 days after termination, subject to documented legal or technical exceptions. | Amend contract to require return or certified destruction within 30 days, with written confirmation. |
| 10 | Background checks at hire only | Acceptable | No recurring checks are reported; the policy does not prescribe a fixed recurring background-check interval. | Verify role-based screening and access review procedures for personnel with sensitive access. |
| 11 | MFA enabled for privileged accounts using TOTP | Pass | No identified gap against the MFA requirement. | Verify enforcement for all privileged accounts and remote support access. |
| 12 | Monthly vulnerability scans; quarterly target for critical remediation | Concern | Quarterly remediation may leave critical weaknesses unresolved for an extended period, especially on ePHI systems. | Provide severity-based remediation timelines, evidence of critical vulnerability handling, and escalation procedures. |
| 13 | Right to audit with 60 days' written notice | Concern | Notice period may delay urgent investigations or evidence requests. | Amend terms to allow prompt evidence requests and incident-related investigations without a 60-day delay. |
| 14 | Willing to execute BAA; not yet signed | Critical Concern | A signed BAA is mandatory for every Tier A vendor before onboarding or ePHI access. | Execute a Legal / Privacy-approved BAA before onboarding. No exception permitted. |
| 15 | Annual online PHI handling training | Acceptable | Training is reported, but completion records and coverage of relevant personnel are not supplied. | Obtain training records showing completion by personnel with access to MedDefense data. |

## 4. Critical Findings

### CF-01 — Outdated Penetration Test (Item 5)

**Risk:** Unidentified or unresolved vulnerabilities in systems that store or manage clinical backups.

CloudVault's latest penetration test was performed 22 months ago, and no findings summary was supplied.

MedDefense requires Tier A vendors to provide penetration test results dated within the previous 12 months, including critical findings and their remediation status.

Without current testing evidence, MedDefense cannot determine whether important weaknesses have been identified and corrected. This creates security risk for patient data and weakens the evidence available to demonstrate reasonable vendor due diligence.

**Required before approval:**

CloudVault must provide a penetration test report dated within the previous 12 months, a summary of critical findings, and evidence that critical findings have been remediated and verified.

**Status:** Open — Approval Blocker.

### CF-02 — Undisclosed Disaster Recovery Site (Item 7)

**Risk:** Unknown storage jurisdiction and unverified protection of clinical backup data.

CloudVault states that its primary data center is in the United States but has not disclosed the location of its disaster recovery site.

Because backups may contain ePHI, MedDefense must know where the data is stored, replicated, and recovered.

Without this information, MedDefense cannot complete its privacy, contractual, jurisdiction, and security review. The missing information also prevents assessment of the recovery site's physical and technical safeguards.

An undisclosed foreign location is not automatically a HIPAA violation, but the lack of information prevents MedDefense from verifying compliance with its policy.

**Required before approval:**

CloudVault must disclose the disaster recovery site's country, jurisdiction, service operator, data types, and applicable security controls. IT Security and Legal / Privacy must document their review.

**Status:** Open — Approval Blocker.

### CF-03 — Inadequate Incident Notification (Item 8)

**Risk:** Delayed detection, containment, and assessment of incidents affecting MedDefense data.

CloudVault's proposed contract requires notification within 72 hours after the vendor internally confirms a breach.

MedDefense policy requires notification within 24 hours of discovering a confirmed or suspected incident affecting MedDefense systems or data.

The current wording creates two problems:

1. The notification deadline is 48 hours longer than MedDefense permits.
2. The clock begins after internal confirmation, which could further delay notification of a suspected incident.

This delay could prevent MedDefense from quickly containing an incident, protecting patient information, preserving evidence, and assessing its own regulatory obligations.

**Required before approval:**

CloudVault must sign amended contractual and BAA terms requiring notification within 24 hours of discovering a confirmed or suspected incident affecting MedDefense data.

The terms must require prompt updates, cooperation, and access to relevant investigation evidence.

**Status:** Open — Approval Blocker.

### CF-04 — Excessive Data Deletion Period (Item 9)

**Risk:** Patient information remains with a former vendor longer than MedDefense permits.

CloudVault proposes deleting data within 90 days of a written request.

MedDefense policy requires data return or certified destruction within 30 days after contract termination, subject to documented legal or technical exceptions.

The current clause creates a potential 60-day difference from the policy target and depends on a separate written request.

Longer retention increases the period during which former vendor systems or accounts could expose MedDefense data.

HIPAA does not impose a universal 30-day destruction deadline; this is MedDefense's contractual security requirement.

**Required before approval:**

CloudVault must amend the contract to require data return or secure destruction within 30 days of termination, with written certification and applicable subprocessor confirmation.

Any legally required or technically infeasible retention must be documented and protected.

**Status:** Open — Approval Blocker.

### CF-05 — Missing Business Associate Agreement (Item 14)

**Risk:** CloudVault could receive ePHI without the required written HIPAA business associate safeguards.

The BAA status note dated 2026-04-24 confirms that CloudVault is willing to execute a BAA, but no agreement has been signed.

CloudVault would store clinical backups containing ePHI. Therefore, it must be treated as a business associate under the MedDefense policy and applicable HIPAA requirements.

Without an executed BAA, MedDefense lacks the required written agreement defining CloudVault's permitted use of ePHI, safeguards, reporting obligations, subprocessor requirements, and data handling at termination.

This creates direct regulatory and contractual exposure if ePHI is transferred before the agreement is executed.

**Required before approval:**

CloudVault and MedDefense must execute a BAA approved by Legal / Privacy that includes:

- Permitted uses and disclosures of ePHI.
- Required security safeguards.
- Notification within 24 hours of discovering a confirmed or suspected incident affecting MedDefense data.
- Subprocessor safeguards and written flow-down obligations.
- Investigation cooperation and evidence access.
- Data return or certified destruction requirements.
- Termination and access revocation provisions.

**No Tier A onboarding or ePHI access is permitted without an executed BAA. No exception is allowed.**

**Status:** Open — Mandatory Approval Blocker.

## 5. Additional Findings Requiring Resolution

### AF-01 — Subprocessor Risk (Item 6)

CloudVault has disclosed two subprocessors:

| Subprocessor | Jurisdiction | Service | Potential Data Exposure |
|---|---|---|---|
| FastRoute Health CDN | United States | Content delivery and transfer acceleration | Encrypted backup transfer metadata |
| MetricLake Analytics GmbH | European Union | Service performance analytics | Operational metadata and tenant identifiers |

The following questions remain unanswered:

- Does MetricLake receive patient identifiers or only service telemetry?
- Can backup metadata be linked to identifiable patients?
- Do subprocessors have administrative access to production systems?
- Are appropriate contractual safeguards in place?
- Are subprocessors required to support incident reporting and investigations?

**Required action:** CloudVault must provide complete data-flow and access descriptions, relevant contractual safeguards, and evidence of subprocessor oversight. IT Security and Legal / Privacy must approve the arrangements before ePHI access.

### AF-02 — Vulnerability Remediation Timing (Item 12)

CloudVault performs monthly vulnerability scans, which is a positive control.

However, its quarterly remediation target for critical findings may allow serious vulnerabilities to remain unresolved for too long.

**Required action:** CloudVault must provide a severity-based remediation process, escalation requirements, and evidence of how critical vulnerabilities affecting ePHI systems are handled.

### AF-03 — Audit and Investigation Access (Item 13)

CloudVault allows audits with 60 days' written notice.

This may be acceptable for planned routine audits but is not sufficient for urgent incident investigations.

**Required action:** Amend contractual terms to permit prompt evidence requests and incident-related investigations without the routine 60-day notice period.

## 6. Overall Risk Assessment

| Category | Assessment |
|---|---|
| Vendor classification | Tier A — Critical |
| ePHI involvement | Yes |
| Independent assurance | Reported as current; full report review outstanding |
| Encryption | Reported controls acceptable, subject to verification |
| Penetration testing | Critical gap |
| Subprocessor oversight | Incomplete |
| Disaster recovery location | Critical gap |
| Incident notification | Critical contractual gap |
| Data deletion | Critical contractual gap |
| Business Associate Agreement | Critical mandatory gap |
| Overall risk | Critical |
| Approval readiness | Not ready |

### Findings Summary

- **Pass:** 3 items.
- **Acceptable:** 4 items.
- **Concern:** 3 items.
- **Critical Concern:** 5 items.
- **Total:** 15 items.

CloudVault has reported several useful security controls, including encryption, MFA, and a recent SOC 2 Type II report.

However, these controls do not compensate for missing mandatory Tier A requirements.

## 7. Final Recommendation

### Decision: DO NOT APPROVE

**CloudVault Medical must not be approved for onboarding, contract sign-off, production access, or ePHI transfer at this time.**

The decision is based on five critical concerns:

1. The penetration test is 22 months old, exceeding the 12-month requirement.
2. The disaster recovery site location is undisclosed.
3. Incident notification is 72 hours after confirmation rather than 24 hours after discovery.
4. Data deletion is 90 days rather than the required 30 days.
5. The mandatory Business Associate Agreement has not been executed.

Subprocessor due diligence and other contractual security requirements also remain incomplete.

These gaps prevent MedDefense from demonstrating that CloudVault satisfies its Tier A Vendor Management Policy.

The BAA requirement is unconditional. Neither business urgency nor CISO risk acceptance may authorize onboarding without an executed BAA.

**Recommendation to Dr. Morales:** Do not sign the CloudVault contract until IT Security and Legal / Privacy verify the required corrective actions and issue a new approval decision.

## 8. Requirements for Reassessment

The following conditions must be satisfied before CloudVault can be reconsidered for approval.

| ID | Required Condition | Responsible Party | Acceptance Evidence |
|---|---|---|---|
| RC-01 | Execute a BAA before onboarding or ePHI access. | CloudVault / Legal / Privacy | Signed and approved BAA |
| RC-02 | Replace the 72-hour incident clause with notification within 24 hours of discovery of a suspected or confirmed incident. | CloudVault / Legal | Executed contract amendment and matching BAA terms |
| RC-03 | Replace the 90-day deletion clause with return or certified destruction within 30 days after termination, subject to documented exceptions. | CloudVault / Legal | Executed contract amendment |
| RC-04 | Provide penetration test results dated within 12 months and verified remediation of critical findings. | CloudVault / IT Security | Current test report, findings summary, remediation evidence |
| RC-05 | Disclose the disaster recovery site and complete jurisdiction and security review. | CloudVault / IT Security / Privacy | Site details and documented approval |
| RC-06 | Complete subprocessor assessment, including data flows, access, jurisdictions, and safeguards. | CloudVault / Legal / Privacy | Updated subprocessor register and approved review |
| RC-07 | Provide the current SOC 2 Type II report for scope and findings review. | CloudVault / IT Security | Reviewed assurance report |
| RC-08 | Verify encryption, MFA, administrative access, and key-management controls. | CloudVault / IT Security | Technical evidence and assessment record |
| RC-09 | Provide satisfactory critical vulnerability remediation and urgent audit cooperation terms. | CloudVault / IT Security / Legal | Approved remediation procedure and contractual terms |
| RC-10 | Provide evidence of relevant staff training and access screening. | CloudVault / IT Security | Training and personnel-control evidence |

### Reassessment Process

1. CloudVault submits the required evidence and amended contractual terms.
2. IT Security reviews the technical findings.
3. Legal / Privacy verifies the BAA, subprocessor obligations, and contractual protections.
4. Procurement confirms that all mandatory documents are complete.
5. Open findings are updated in the vendor risk register.
6. The CISO reviews any escalated residual risks.
7. MedDefense issues a new documented vendor approval decision.

No production access or ePHI transfer may begin before the required approvals are completed.

## 9. Evidence and References

This assessment uses:

- `vendor/cloudvault_security_questionnaire.md` — 15 questionnaire responses supplied for Task 5.
- `vendor/cloudvault_contract_summary.md` — service scope, access model, and contractual issues.
- `vendor/cloudvault_subprocessor_list.md` — disclosed subprocessors and unresolved questions.
- `vendor/baa_status_note.md` — BAA execution status and required provisions.
- `vendor_management_policy.md` — Tier A requirements, monitoring, incident reporting, and offboarding.

### Relevant Compliance References

- HIPAA Security Rule — 45 CFR §164.308(a)(1): Security Management Process.
- HIPAA Security Rule — 45 CFR §164.308(b): Business Associate Contracts.
- HIPAA Security Rule — 45 CFR §164.312: Technical Safeguards.
- HIPAA Business Associate Contract Requirements — 45 CFR §164.504(e).
- NIST CSF 2.0 — GV.SC: Cybersecurity Supply Chain Risk Management.

---

## 10. Assessment Sign-Off

**Security assessment decision:** Do Not Approve

**Security reviewer:** Helena Reyes  
**Review status:** Draft — Awaiting formal sign-off

**IT Security approval:** Pending

**Legal / Privacy review:** Pending

**CISO review:** Pending

**Contract authorization:** Blocked pending reassessment

**Assessment conclusion:** CloudVault Medical does not currently satisfy MedDefense's mandatory Tier A vendor security requirements. The proposed contract must not proceed to approval until the identified blockers are resolved and verified.
