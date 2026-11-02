
# NIST CSF 2.0 Gap Assessment: MedDefense Health Systems

**Assessment date:** 2026-11-02  
**Assessor:** Nishat Sultana Supty  
**Framework version:** NIST CSF 2.0  
**Regulatory context:** HIPAA Security Rule, 45 CFR Part 164  
**Assessment status:** Provisional — pending evidence verification

## Assessment Methodology

This assessment evaluates MedDefense's cybersecurity controls against 21 specified NIST CSF 2.0 subcategories across the Govern, Identify, Protect, Detect, Respond, and Recover functions.

Although the project instructions mention 22 subcategories, the supplied list contains 21.

### Implementation Status

- **Implemented:** Control is operational and supported by sufficient evidence.
- **Partial:** Control exists in some form, but implementation, coverage, or supporting evidence is incomplete.
- **Not Implemented:** Control is reported absent or has not been established.

### Gap Severity

- **Critical:** Significant security or compliance exposure requiring immediate attention.
- **High:** Major weakness requiring prioritized remediation.
- **Medium:** Important weakness requiring corrective action.
- **Low:** Minor weakness or documentation deficiency.
- **None:** No identified gap.

**Evidence limitation:** The required source files have not been supplied for verification. Evidence references are therefore marked `None`. A missing evidence reference does not necessarily mean the control is absent. All statuses and severities below are provisional.

## Gap Assessment Matrix

| CSF Function | Subcategory | Title (abbreviated) | Status | Evidence Reference | Gap Severity | Gap Description |
|---|---|---|---|---|---|---|
| GOVERN | GV.OC-01 | Organizational mission understood for risk management | Partial | None | High | No verified documentation connecting organizational objectives, clinical priorities, and cybersecurity risk decisions. |
| GOVERN | GV.PO-01 | Cybersecurity risk management policy established | Not Implemented | None | Critical | Acceptable Use and Data Classification policies are missing or outdated; no current approved organization-wide policy set is evidenced. |
| GOVERN | GV.SC-04 | Suppliers identified and prioritized by criticality | Not Implemented | None | High | No verified inventory classifying Nexus, CloudVault, and other suppliers by criticality and data exposure. |
| GOVERN | GV.SC-07 | Supplier risks tracked throughout relationships | Not Implemented | None | Critical | CloudVault lacks a current security assessment and executed BAA; supplier risk monitoring and treatment are not evidenced. |
| IDENTIFY | ID.AM-01 | Hardware assets inventoried and managed | Partial | None | Medium | Endpoint hardening work suggests asset coverage, but a complete and current hardware inventory has not been verified. |
| IDENTIFY | ID.RA-01 | Asset vulnerabilities identified and recorded | Partial | None | Medium | Incident findings identify weaknesses, but ongoing vulnerability assessment coverage and recording require verification. |
| IDENTIFY | ID.RA-06 | Risk responses selected and prioritized | Partial | None | Medium | Post-incident risk treatment is described, but documented prioritization, approvals, and follow-up require verification. |
| PROTECT | PR.AA-01 | Identities and credentials securely managed | Partial | None | High | Credential incident procedures are described, but proactive identity lifecycle controls and enforcement remain unverified. |
| PROTECT | PR.AA-05 | Access permissions reviewed and managed | Partial | None | High | No verified periodic access review, privileged access approval, or least-privilege enforcement evidence. |
| PROTECT | PR.AT-01 | Personnel receive cybersecurity awareness training | Not Implemented | None | Critical | No verified training completion records, attendance tracking, or documented recurring awareness program. |
| PROTECT | PR.DS-01 | Data at rest adequately protected | Partial | None | High | Encryption controls have been discussed, but coverage of EHR databases, backups, and other ePHI repositories is unverified. |
| PROTECT | PR.PS-01 | Configuration management practices established | Partial | None | Medium | Endpoint hardening baselines are described, but approval, deployment coverage, and periodic configuration review are unverified. |
| PROTECT | PR.PS-04 | Log records generated and available | Partial | None | Medium | Security logging and detection work is described, but log retention, completeness, and accessibility are not fully evidenced. |
| DETECT | DE.CM-01 | Networks monitored for adverse events | Partial | None | High | Network detection capabilities are described, but continuous monitoring coverage, alert routing, and review are unverified. |
| DETECT | DE.CM-06 | External service activities monitored | Partial | None | High | Monitoring of critical third-party services and supplier activities is not sufficiently evidenced. |
| DETECT | DE.AE-02 | Potentially adverse events analyzed | Partial | None | Medium | Detection and forensic analysis work is described, but repeatable triage criteria and analysis records require verification. |
| RESPOND | RS.MA-01 | Incident response plans executed effectively | Partial | None | Medium | Incident response playbooks are described, but formal approval, operational adoption, and exercise evidence remain unverified. |
| RESPOND | RS.AN-03 | Incident analysis performed and documented | Partial | None | Medium | Forensic investigations are described, but completeness of analysis records and evidence traceability require verification. |
| RESPOND | RS.CO-02 | Incident information shared with stakeholders | Partial | None | High | Incident communication responsibilities are described, but approved reporting channels, escalation criteria, and communication records require verification. |
| RECOVER | RC.RP-01 | Recovery procedures executed and verified | Partial | None | High | Recovery validation work is described, but approved recovery procedures and repeatable restoration-test evidence are unverified. |
| RECOVER | RC.CO-01 | Recovery activities communicated to stakeholders | Partial | None | Medium | No verified recovery communication plan defining recipients, approval responsibilities, and reporting milestones. |

## Summary

### Implementation Counts

| Implementation Status | Count |
|---|---:|
| Implemented | 0 |
| Partial | 17 |
| Not Implemented | 4 |
| **Total** | **21** |

**Note:** These counts are provisional. Zero controls are marked Implemented because the required evidence has not been verified, not because MedDefense necessarily lacks functioning controls.

### Top 3 Pre-Audit Priorities

1. **GV.PO-01 (Critical):** Develop, review, and formally approve the missing Acceptable Use and Data Classification policies, including enforcement requirements and assigned responsibilities.

2. **GV.SC-07 (Critical):** Escalate CloudVault's missing Business Associate Agreement to Legal and Privacy, complete its vendor security assessment, and document supplier risk treatment decisions.

3. **PR.AT-01 (Critical):** Verify the existing security awareness training program, obtain completion records, and establish mandatory training requirements and evidence tracking where necessary.

### Connection to Upcoming Governance Work

The provisional assessment identifies significant weaknesses in cybersecurity governance, vendor risk management, security awareness, access management, monitoring, and recovery assurance. These gaps directly connect to the upcoming MedDefense governance and resilience activities. The next steps should focus on developing enforceable security policies, assigning control ownership, establishing formal review procedures, assessing third-party risks, and maintaining verifiable compliance evidence. Recovery procedures should also be tested and documented to support clinical service continuity. Addressing these weaknesses will improve MedDefense's readiness for the upcoming HIPAA audit and strengthen its overall cybersecurity risk management program.

## Evidence Verification Requirements

The following artifacts must be reviewed before finalizing this assessment:

| Required Artifact | Relevant Assessment Areas |
|---|---|
| `endpoint_hardening_baseline.md` | Asset inventory, system configurations, identity controls |
| `sigma_detection_catalog.md` | Monitoring, detection, event analysis |
| `ir_playbook_index.md` | Incident response and communications |
| `forensic_findings_summary.md` | Vulnerability identification and incident analysis |
| `recovery_validation_summary.md` | Recovery procedures and validation |
| `security_awareness_training_status.md` | Security awareness training |
| `risk_register_updates.yaml` | Risk identification and assessment |
| `risk_treatment_plan.md` | Risk prioritization and remediation |
| `nist_csf_2_0_subcategory_reference.md` | NIST CSF subcategory requirements |
| `hipaa_security_rule_crosswalk.md` | HIPAA Security Rule mapping |

### Final Verification Actions

1. Review all ten required source artifacts.
2. Confirm that each referenced control is actually implemented.
3. Replace `None` with the exact supporting artifact filename where evidence exists.
4. Reassess implementation statuses and gap severities.
5. Recalculate implementation counts.
6. Update the top three remediation priorities if necessary.
7. Confirm the assessment is independently reviewable before audit submission.

## Assessment Conclusion

MedDefense has undertaken substantial technical cybersecurity work, including endpoint hardening, detection engineering, incident response planning, forensic investigation, and recovery validation.

However, the available scenario identifies important governance and third-party risk management weaknesses. The organization must demonstrate not only that security controls exist, but also that they are documented, maintained, enforced, and supported by reliable evidence.

This provisional assessment provides the structure for identifying and prioritizing compliance gaps. Final conclusions must be supported by the required MedDefense artifacts before the document is submitted as an audit-ready assessment.
