
# MedDefense Health Systems — Vendor Management Policy

Policy number: MD-SEC-VMP-001  
Policy title: Vendor Management Policy  
Effective date: Upon CISO approval and formal issuance  
Review date: 12 months after effective date, and annually thereafter  
Owner: IT Security and Procurement (jointly)  
Approved by: Chief Information Security Officer (CISO) — Pending  
Classification: Confidential  
Applies to: MedDefense departments, employees managing vendor relationships, and all third-party providers  

**Version:** 1.0  
**Status:** Draft — not effective until approved and distributed

---

## 1. Purpose

This policy sets mandatory security rules for selecting, approving, monitoring, and ending relationships with outside providers. It protects patient information and clinical services by requiring documented checks before any vendor receives access to MedDefense systems or data.

## 2. Scope

This policy applies to all third parties, including SaaS providers, managed service providers, cloud infrastructure and backup providers, medical device vendors with network-connected products, Epic/EHR integration partners, and staffing agencies whose personnel access IT systems. It also applies to office suppliers and facilities contractors for initial risk classification, even when they have no system access.

A business owner must register each proposed vendor with Procurement. IT Security must assign a risk tier and approve required security evidence **before** vendor onboarding, production access, or transfer of MedDefense data. A purchase order or signed commercial contract does not grant security approval.

## 3. Responsibilities

| Role | Required action |
|---|---|
| Procurement | Maintain vendor register, collect evidence, block onboarding until approvals are complete, and coordinate offboarding. |
| IT Security | Classify vendors, assess security evidence, track risks, approve technical access, and conduct ongoing reviews. |
| Legal / Privacy | Determine business associate status, approve BAAs and contractual safeguards, review jurisdictions and data flows. |
| CISO | Approve this policy, decide on escalated critical risks, and authorize only exceptions permitted by this policy. |
| Business owner | Document purpose, systems, data, access, and operational dependency; confirm vendor performance and initiate offboarding. |
| Vendor | Provide truthful evidence, disclose subprocessors and changes, meet contract obligations, and promptly report incidents. |

## 4. Vendor Risk Tiers

**Tier A — Critical:** A vendor that accesses, stores, transmits, or may be exposed to electronic protected health information (ePHI), accesses clinical systems, or operates a service essential to clinical care. Examples: patient scheduling platforms, imaging vendors, backup providers handling PHI, Epic integration partners, and clinical hosting providers. CloudVault Medical's proposed backup service is **Tier A**, even though backups are encrypted, because archives and metadata may contain patient identifiers.

**Tier B — Standard:** A vendor that accesses MedDefense internal systems or networks but has no access or potential exposure to ePHI or clinical systems. Examples: support for nonclinical business applications and administrative software.

**Tier C — Low:** A vendor with no access to MedDefense systems, networks, or data. Examples: office suppliers and facilities contractors without IT access.

When access or data handling changes, IT Security must reclassify the vendor **before** the change occurs. Any vendor whose service may incidentally expose ePHI must meet Tier A requirements.

## 5. Requirements Before Onboarding

### 5.1 Tier A — All Items Mandatory

Before any onboarding or MedDefense data access, IT Security, Procurement, and Legal / Privacy must verify and record:

1. **Independent assurance:** SOC 2 Type II report or HITRUST CSF certification current within the previous 12 months.
2. **Security questionnaire:** Completed MedDefense vendor security questionnaire.
3. **Penetration testing:** Results from within the previous 12 months, with a summary of critical findings and documented remediation status.
4. **Subprocessors:** Full list of parties that may handle MedDefense data, their roles, data types, access privileges, and processing/storage jurisdictions.
5. **BAA:** A fully executed Business Associate Agreement, approved by Legal / Privacy, **before onboarding or any ePHI access; no exceptions**.

IT Security must also assess encryption, key ownership, access control, privileged support access, monitoring, backups, disaster recovery sites, incident response, and the security of vendor-delivered software updates. Unknown data-center or disaster-recovery locations must be resolved before approval.

**Decision rule:** If any mandatory item is missing, expired, or unverified, mark the vendor **Not Approved — Onboarding Blocked**. Critical unresolved findings must be remediated and verified before access. CISO risk acceptance cannot waive these mandatory Tier A requirements.

### 5.2 Tier B

Before access, obtain a completed security questionnaire, a description of requested systems and permissions, evidence of appropriate controls, signed confidentiality and security terms including incident notification, and documented IT Security approval. IT Security may request additional assurance or testing based on risk.

### 5.3 Tier C

Procurement must document the service, business owner, and confirmation of no system, network, or data access. Any proposed access requires reassessment before it begins.

## 6. Business Associate Agreement (BAA)

A signed BAA is mandatory for **every Tier A vendor** and any vendor whose service may incidentally expose ePHI. **No Tier A vendor may onboard without an executed BAA. No exception, temporary approval, or commercial contract may replace it.**

The BAA must specify:

- Permitted uses and disclosures of ePHI and prohibition of unauthorized use or disclosure.
- Administrative, physical, and technical safeguards and applicable HIPAA obligations.
- Vendor notice to MedDefense **within 24 hours of discovering a confirmed or suspected security incident affecting MedDefense data**, including suspected unauthorized access or disclosure.
- Prompt updates and cooperation with investigations, including access to relevant evidence and logs.
- Disclosure of subprocessors and binding written flow-down safeguards for those handling ePHI.
- MedDefense review of new subprocessors and changes to processing locations **before** those changes take effect.
- Return or certified destruction of MedDefense data within **30 days** after termination, except where retention is legally required or return/destruction is infeasible; retained data must remain protected.
- Support for access revocation, breach assessment, corrective action, and termination for material noncompliance.

Legal / Privacy must confirm execution and record the BAA in the vendor file before Procurement or IT Security authorizes onboarding.

## 7. Access and Supply-Chain Controls

Vendor access must be limited to approved people, systems, permissions, and duration. Vendor users must have individual accounts, use required multifactor authentication and approved remote connections, and have privileged access separately approved and logged. Vendors must not connect unapproved devices, transfer data to undisclosed subprocessors, or bypass MedDefense controls.

For vendors supplying software or updates, IT Security must assess how updates are built, authenticated, distributed, tested, and rolled back; how the vendor protects its signing and deployment systems; and how a compromised update will be reported and stopped. MedDefense may require staged deployment or suspend updates pending investigation. A legitimate vendor update channel is not proof that an update is safe.

## 8. Ongoing Monitoring and Change Review

**Tier A:** IT Security must review at least annually the assurance report/certification, questionnaire, penetration-test findings, subprocessor list, jurisdictions, BAA, incident history, access, backup/recovery controls, and outstanding remediation. Findings must have owners and deadlines.

**Tier B:** Review at least every two years and when risk changes.

**Tier C:** Reassess if services or access change.

An **immediate out-of-cycle review** is required for ownership transfer, a new or changed subprocessor, data-center or disaster-recovery relocation, significant security incident, major service change, or new access to clinical systems/data.

The vendor must notify MedDefense before planned material changes, or immediately if advance notice is impossible. IT Security may suspend access while the review is incomplete.

## 9. Incident Notification and Investigation Rights

Tier A and Tier B contracts must require the vendor to notify MedDefense IT Security **within 24 hours of discovering any confirmed or suspected incident affecting MedDefense systems or data**.

The vendor must not wait for a completed investigation or confirmed breach classification.

The first report must include available details:

1. Discovery time.
2. Affected systems or data.
3. Suspected impact.
4. Containment actions.
5. Incident contact.
6. Timing of the next update.

The vendor must provide further updates and preserve relevant evidence.

**MedDefense retains the right to conduct its own investigation independent of the vendor**, request logs and evidence, assess patient impact, suspend access, and determine its own notification obligations.

The 24-hour contractual requirement does not displace a shorter applicable legal deadline.

## 10. Findings, Decisions, and Exceptions

IT Security must record each finding in the vendor risk register, including:

- Vendor name and risk tier.
- Affected systems and data.
- Risk severity.
- Supporting evidence.
- Required remediation.
- Responsible owner.
- Deadline.
- Verification result.

Critical findings must be escalated to the CISO.

Possible assessment outcomes are:

- **Approved:** All required controls are satisfied.
- **Not Approved — Onboarding Blocked:** Mandatory evidence or security requirements are missing.
- **Approved with Conditions:** All mandatory onboarding requirements are satisfied, but remaining noncritical actions require documented owners and deadlines.

No conditional approval may bypass the Tier A BAA or other mandatory Tier A evidence requirements.

The CISO may approve documented, time-limited exceptions to nonmandatory procedural controls after risk assessment.

**There are no exceptions to the executed BAA requirement for Tier A vendors.**

Exceptions cannot override applicable law.

## 11. Offboarding and Record Retention

At contract termination, Procurement and the business owner must notify IT Security and Legal / Privacy.

Vendor accounts, VPN connections, privileged permissions, tokens, and other access must be **revoked within 24 hours**. Access must be disabled immediately if an active threat exists.

MedDefense data must be returned or securely destroyed **within 30 days**, with written certification of destruction and confirmation of applicable subprocessor deletion.

If return or destruction is infeasible or legally prohibited, Legal / Privacy must document the reason, retained data, safeguards, and eventual disposition.

IT Security must verify access removal and Procurement must close the vendor record.

MedDefense must retain policy approvals, risk assessments, BAAs, monitoring evidence, incident records, and offboarding documentation for **at least six years** under its documentation retention schedule, or longer when required by law or legal hold.

The HIPAA six-year documentation rule does not itself require all patient data to be kept for six years.

## 12. Enforcement

Procurement must stop onboarding when mandatory evidence is missing.

IT Security may block or suspend access for unacceptable security risk.

Breaches of this policy may result in:

- Remediation demands.
- Contractual remedies.
- Suspension of vendor access.
- Vendor termination.
- Escalation to Legal / Privacy.
- Regulatory reporting where required.

Employees who bypass vendor controls may face HR discipline, up to termination.

## 13. Policy Approval, Distribution, and Review

This policy becomes effective only after CISO approval and formal distribution to Procurement, IT Security, Legal / Privacy, department heads, and business owners.

IT Security and Procurement must review it annually and after major legal, technical, or vendor-risk changes.

Approval, distribution, acknowledgment, and review evidence must be retained.

The 2026-04-24 prior policy inventory records that MedDefense had **no approved Vendor Management Policy**, only a procurement checklist.

Drafting this policy alone does not close that finding; approval, distribution, and implementation are required.

## 14. CloudVault Medical — Initial Assessment Application

**Assessment status: NOT APPROVED — ONBOARDING AND ePHI TRANSFER BLOCKED.**

This section records facts supported by the supplied CloudVault documents for Task 5. It does not replace the full vendor assessment.

| Control | Evidence supplied | Required action |
|---|---|---|
| Tier classification | Proposed encrypted backups include Epic EHR exports, laboratory backups, PACS/RIS metadata, pharmacy backups, and potentially identifying recovery logs | Classify as Tier A |
| BAA | Not executed; vendor has expressed willingness to sign | Execute and approve BAA before onboarding; no exceptions |
| Incident notification | Proposed contract allows 72 hours | Amend to 24 hours from discovery of suspected or confirmed incident |
| Data deletion | Proposed contract allows 90 days | Amend to 30 days, subject to documented legal or technical exceptions |
| Penetration test | Latest test is 22 months old | Obtain results dated within 12 months and remediation evidence |
| Disaster recovery site | Location not disclosed | Disclose site and jurisdiction; complete security/privacy review |
| Subprocessors | FastRoute Health CDN (US), MetricLake Analytics GmbH (EU) | Verify data exposure, administrative access, contractual safeguards, and incident reporting duties |
| Independent assurance | Not established by supplied documents | Obtain current SOC 2 Type II or HITRUST CSF evidence |
| Security questionnaire | Completion not established by supplied documents | Obtain completed MedDefense questionnaire |

### 14.1 CloudVault Subprocessor Review

**FastRoute Health CDN**

- Location: United States.
- Service: Content delivery and transfer acceleration.
- Potential exposure: Encrypted backup transfer metadata.

**MetricLake Analytics GmbH**

- Location: European Union.
- Service: Service performance analytics.
- Potential exposure: Operational metadata and tenant identifiers.

IT Security and Legal / Privacy must determine:

1. Whether MetricLake receives patient identifiers or only service telemetry.
2. Whether metadata linked to backup archives can identify patients.
3. Whether either subprocessor has administrative access to production systems.
4. Whether subprocessors have signed agreements requiring appropriate safeguards.
5. Whether the 24-hour incident notification requirement applies through the subcontracting chain.
6. Whether the relevant processing and storage jurisdictions have been fully documented.

The EU processing location is not automatically disqualifying, but it requires a documented jurisdiction and data-flow review.

### 14.2 CloudVault Approval Decision

CloudVault must not receive MedDefense ePHI until:

1. The BAA is signed and approved.
2. Incident notification terms are changed from 72 hours to 24 hours.
3. Data deletion terms are changed from 90 days to 30 days, subject to documented exceptions.
4. A penetration test completed within the previous 12 months is provided.
5. The disaster recovery location is disclosed and reviewed.
6. Subprocessor risks and safeguards are verified.
7. Current SOC 2 Type II or HITRUST CSF evidence is provided.
8. The MedDefense vendor security questionnaire is completed.
9. IT Security verifies all Tier A requirements.
10. The required security, procurement, and legal approvals are documented.

**Final current decision: Not Approved — Onboarding Blocked.**

Sarah Park must not authorize onboarding or data transfer until all mandatory requirements are satisfied.

Helena Reyes may use Sections 6, 9, and 11 to prepare and review BAA terms.

## 15. References

- `templates/policy_header_template.md`
- `compliance/prior_policy_inventory.md`
- `vendor/cloudvault_contract_summary.md`
- `vendor/baa_status_note.md`
- `vendor/cloudvault_subprocessor_list.md`
- `compliance/hipaa_security_rule_crosswalk.md`

Relevant HIPAA Security Rule crosswalk topics:

- 45 CFR 164.308(a)(1) — Security management.
- 45 CFR 164.308(a)(6) — Security incident procedures.
- 45 CFR 164.308(b) — Business associate contracts.
- 45 CFR 164.312(a) — Access control.
- 45 CFR 164.312(b) — Audit controls.
- 45 CFR 164.312(e)(1) — Transmission security.
- 45 CFR 164.402 — Breach definition.

---

## Policy Footer

**Acknowledgment:**

I acknowledge that I have read, understood and agree to comply with this policy.

**Employee name:** ______________________________

**Signature:** ___________________________________

**Date:** ________________________________________
