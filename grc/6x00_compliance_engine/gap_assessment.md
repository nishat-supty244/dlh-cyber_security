
# NIST CSF 2.0 Gap Assessment: MedDefense Health Systems

**Assessment date:** 2026-11-02  
**Assessor:** Nishat Sultana Supty  
**Framework version:** NIST CSF 2.0  
**Regulatory context:** HIPAA Security Rule, 45 CFR Part 164  
**Assessment status:** Provisional — pending evidence verification

## Assessment Methodology

This assessment evaluates MedDefense Health Systems' cybersecurity controls against 21 specified NIST CSF 2.0 subcategories across the Govern, Identify, Protect, Detect, Respond, and Recover functions.

Although the project instructions mention 22 subcategories, the supplied list contains 21.

The assessment considers existing technical controls, security policies, incident response procedures, risk management activities, vendor security practices, and recovery capabilities.

Implementation status and gap severity are assigned based on available information. Final ratings require verification against the specified MedDefense evidence artifacts.

### Implementation Status

- **Implemented:** The control is operational and supported by sufficient documented evidence.
- **Partial:** The control exists in some form, but implementation, coverage, or supporting evidence is incomplete.
- **Not Implemented:** The required capability is reported absent or has not been established.

### Gap Severity

- **Critical:** Significant security or compliance exposure requiring immediate remediation.
- **High:** Major weakness requiring prioritized remediation before the audit.
- **Medium:** Important weakness requiring planned corrective action.
- **Low:** Minor weakness or documentation deficiency.
- **None:** No identified gap.

**Evidence limitation:** The required source files have not yet been supplied for verification. Evidence references are therefore marked `None`. Missing evidence does not automatically prove that a control is absent. All implementation ratings and gap severities remain provisional.

## Gap Assessment Matrix

| CSF Function | Subcategory | Title (abbreviated) | Status | Evidence Reference | Gap Severity | Gap Description |
|---|---|---|---|---|---|---|
| GOVERN | GV.OC-01 | Organizational mission understood for risk management | Partial | None | High | No verified documentation connecting clinical priorities, organizational objectives, and cybersecurity risk decisions. |
| GOVERN | GV.PO-01 | Cybersecurity risk management policy established | Not Implemented | None | Critical | Acceptable Use, Data Classification, and Vendor Management policies are missing or outdated; no current approved organization-wide policy set is evidenced. |
| GOVERN | GV.SC-04 | Suppliers identified and prioritized by criticality | Not Implemented | None | High | No verified inventory classifying Nexus, CloudVault, and other suppliers by criticality, service dependency, and ePHI exposure. |
| GOVERN | GV.SC-07 | Supplier risks tracked throughout relationships | Not Implemented | None | Critical | CloudVault lacks a current security assessment and executed BAA; ongoing supplier risk monitoring and treatment are not evidenced. |
| IDENTIFY | ID.AM-01 | Hardware assets inventoried and managed | Partial | None | Medium | Endpoint hardening work suggests asset coverage, but a complete and current hardware inventory has not been verified. |
| IDENTIFY | ID.RA-01 | Asset vulnerabilities identified and recorded | Partial | None | Medium | Incident findings identify security weaknesses, but ongoing vulnerability assessment coverage and recording require verification. |
| IDENTIFY | ID.RA-06 | Risk responses selected and prioritized | Partial | None | Medium | Post-incident risk treatment is described, but documented prioritization, approvals, ownership, and follow-up require verification. |
| PROTECT | PR.AA-01 | Identities and credentials securely managed | Partial | None | High | Credential incident procedures are described, but proactive identity lifecycle controls and enforcement remain unverified. |
| PROTECT | PR.AA-05 | Access permissions reviewed and managed | Partial | None | High | No verified periodic access reviews, privileged access approvals, or least-privilege enforcement evidence. |
| PROTECT | PR.AT-01 | Personnel receive cybersecurity awareness training | Not Implemented | None | Critical | No verified training completion records, attendance tracking, or documented recurring security awareness program. |
| PROTECT | PR.DS-01 | Data at rest adequately protected | Partial | None | High | Encryption controls have been discussed, but coverage of EHR databases, clinical backups, and other ePHI repositories is unverified. |
| PROTECT | PR.PS-01 | Configuration management practices established | Partial | None | Medium | Endpoint hardening baselines are described, but approval, deployment coverage, change management, and periodic review are unverified. |
| PROTECT | PR.PS-04 | Log records generated and available | Partial | None | Medium | Security logging and detection work is described, but log retention, completeness, protection, and accessibility are not fully evidenced. |
| DETECT | DE.CM-01 | Networks monitored for adverse events | Partial | None | High | Network detection capabilities are described, but continuous monitoring coverage, alert routing, and review are unverified. |
| DETECT | DE.CM-06 | External service activities monitored | Partial | None | High | Monitoring of critical third-party services and supplier activities is not sufficiently evidenced. |
| DETECT | DE.AE-02 | Potentially adverse events analyzed | Partial | None | Medium | Detection and forensic analysis work is described, but repeatable triage criteria, event correlation, and analysis records require verification. |
| RESPOND | RS.MA-01 | Incident response plans executed effectively | Partial | None | Medium | Incident response playbooks are described, but formal approval, operational adoption, and exercise evidence remain unverified. |
| RESPOND | RS.AN-03 | Incident analysis performed and documented | Partial | None | Medium | Forensic investigations are described, but completeness of analysis records, evidence preservation, and traceability require verification. |
| RESPOND | RS.CO-02 | Incident information shared with stakeholders | Partial | None | High | Incident communication responsibilities are described, but approved reporting channels, escalation criteria, and communication records require verification. |
| RECOVER | RC.RP-01 | Recovery procedures executed and verified | Partial | None | High | Recovery validation work is described, but approved recovery procedures, restoration-test records, and repeatable recovery evidence are unverified. |
| RECOVER | RC.CO-01 | Recovery activities communicated to stakeholders | Partial | None | Medium | No verified recovery communication plan defining recipients, approval responsibilities, reporting milestones, and recovery status updates. |

## Summary

### Implementation Counts

| Implementation Status | Count |
|---|---:|
| Implemented | 0 |
| Partial | 17 |
| Not Implemented | 4 |
| **Total** | **21** |

**Note:** These counts are provisional because the required evidence artifacts have not yet been verified. Zero controls are marked Implemented because sufficient evidence was unavailable for verification, not because MedDefense necessarily lacks functioning controls.

### Top 3 Pre-Audit Priorities

1. **GV.PO-01 (Critical) – Establish and approve enforceable security policies:** Develop, review, and formally approve the missing Acceptable Use, Data Classification, and Vendor Management policies. Define responsible owners, enforcement mechanisms, review schedules, and approval records to address critical governance and HIPAA compliance weaknesses.

2. **GV.SC-07 (Critical) – Remediate supplier risk and CloudVault compliance gaps:** Establish a formal third-party risk management process, including a risk-ranked vendor inventory under GV.SC-04, documented vendor assessments, and ongoing monitoring. Immediately escalate CloudVault Medical's missing Business Associate Agreement (BAA) to Legal and Privacy, assess its handling of ePHI, and document risk treatment decisions before the audit.

3. **RC.RP-01 (High) – Verify recovery readiness and incident communication capabilities:** Validate recovery procedures through documented restoration testing, approved recovery plans, and evidence of successful service restoration. Address related incident communication weaknesses under RS.CO-02 by establishing stakeholder notification responsibilities, escalation procedures, and documented communication records. Prioritize these activities to demonstrate MedDefense's ability to restore critical clinical services and communicate effectively during cybersecurity incidents.

### Additional Critical Gap Requiring Remediation

**PR.AT-01 (Critical) – Security awareness training:** Verify the existing security awareness training program and obtain employee completion records. If mandatory training is missing or incomplete, establish recurring training, completion tracking, and documented compliance reviews. This remains a Critical finding and must be included in the pre-audit remediation plan even though it is not one of the three primary governance and resilience workstreams.

### Connection to Upcoming Governance and Resilience Work

The identified Critical and High gaps directly affect MedDefense's ability to demonstrate effective cybersecurity governance, third-party risk management, and operational resilience during the upcoming HIPAA audit. The missing or outdated security policies under GV.PO-01 require formal approval, assigned ownership, and enforceable requirements. Supplier management weaknesses under GV.SC-07 and GV.SC-04 require immediate attention, particularly CloudVault Medical's missing BAA and security assessment. Recovery and incident communication weaknesses under RC.RP-01 and RS.CO-02 require documented restoration testing, approved procedures, and clear stakeholder communication responsibilities. These priorities directly support the upcoming policy development, vendor risk assessment, and resilience improvement activities. Other Critical findings, including PR.AT-01, must remain visible in the remediation plan with assigned owners, deadlines, and verification evidence. Completing these actions will strengthen MedDefense's audit readiness and provide independently verifiable evidence of its security program.

## Evidence Verification Requirements

The following artifacts must be reviewed before the assessment can be finalized.

| Required Artifact | Relevant Assessment Areas |
|---|---|
| `endpoint_hardening_baseline.md` | Asset inventory, system configurations, identity controls |
| `sigma_detection_catalog.md` | Network monitoring, detection, event analysis |
| `ir_playbook_index.md` | Incident response procedures and stakeholder communications |
| `forensic_findings_summary.md` | Vulnerability identification, incident analysis, evidence preservation |
| `recovery_validation_summary.md` | Recovery procedures, restoration testing, validation |
| `security_awareness_training_status.md` | Employee security awareness training and completion records |
| `risk_register_updates.yaml` | Risk identification, assessment, and tracking |
| `risk_treatment_plan.md` | Risk prioritization, ownership, remediation, and follow-up |
| `nist_csf_2_0_subcategory_reference.md` | Exact NIST CSF 2.0 subcategory requirements |
| `hipaa_security_rule_crosswalk.md` | HIPAA Security Rule mapping and regulatory context |

### Final Verification Actions

1. Review all ten required source artifacts.
2. Verify that each identified control is implemented and operational.
3. Replace `None` with the exact supporting artifact filename where evidence exists.
4. Confirm that the evidence supports the corresponding NIST CSF subcategory.
5. Reassess implementation statuses and gap severities.
6. Recalculate implementation counts based on verified findings.
7. Confirm that the top three remediation priorities reflect the most significant governance, supplier risk, and resilience exposures.
8. Assign responsible owners, remediation deadlines, and validation methods for unresolved Critical and High gaps.
9. Confirm that all evidence references are accurate and independently reviewable.
10. Finalize the assessment for inclusion in the MedDefense compliance audit package.

## Assessment Conclusion

MedDefense has undertaken substantial cybersecurity work, including endpoint hardening, detection engineering, incident response planning, forensic investigation, risk management, and recovery validation.

However, the available scenario identifies significant weaknesses in security governance, supplier risk management, security awareness, and operational resilience. Missing or outdated security policies, the absence of a current CloudVault security assessment and executed BAA, and insufficiently verified recovery and communication procedures represent important pre-audit concerns.

The highest-priority remediation work should therefore focus on establishing enforceable governance policies, strengthening third-party risk management, and validating recovery and incident communication capabilities. Security awareness training and other Critical or High findings must also be addressed through documented remediation plans.

The objective is not merely to demonstrate that security controls exist, but to provide reliable evidence that they are appropriately implemented, maintained, reviewed, and enforced.

This assessment provides a structured foundation for MedDefense's compliance improvement activities. Final implementation ratings and conclusions must be supported by verified source artifacts before the document is presented as an audit-ready assessment.
