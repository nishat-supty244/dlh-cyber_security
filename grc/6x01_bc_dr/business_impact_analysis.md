
# MedDefense Business Impact Analysis

**Version:** 1.0  
**Classification:** Confidential  
**Prepared by:** Nishat Sultana Supty  
**Date:** 2026-11-11  

# MedDefense Business Impact Analysis

**Version:** 1.0  
**Classification:** Confidential  
**Prepared by:** Nishat Sultana Supty 
**Date:** 2026-11-11  
**CISO approval:** Supty Date: 11.11.2026
**Status:** Draft for clinical, finance, IT and CISO review; not yet approved

## Executive Summary

MedDefense is a 230-bed acute-care hospital operating emergency, ICU, surgery,
radiology, laboratory and pharmacy services around the clock. This assessment
covers ten systems and prioritizes them by patient harm, clinical workarounds,
regulatory duties, financial exposure and recovery dependencies. A prolonged
outage can delay medication decisions, critical laboratory results and imaging,
while an outage of Network Core or Active Directory can disrupt several
clinical systems at once.

The proposed Tier 1 systems are Network Core, Active Directory, Epic EHR,
Pharmacy Dispensing System and Medical Device Integration Gateway. LIS and
PACS/RIS are Tier 2 because time-critical diagnostics require rapid recovery;
their specific targets must be confirmed by clinical leadership. The remaining
systems are Tier 2 or Tier 3 as shown below. No system is classified Tier 4.

**These are planning targets, not demonstrated capabilities.** In particular,
LIS currently has a nightly SQL export, which cannot by itself assure the
proposed one-hour RPO. A separate lab configuration specifies a 30-minute LIS
recovery-test target; this BIA proposes the same RTO for planning, but only a
measured recovery test can establish whether it is achievable. Revenue
exposures are scenario estimates, not figures supplied by MedDefense Finance.

## Methodology

1. Review the system inventory for clinical functions, owners and known DR gaps.
2. Evaluate the consequences at one, four and 24 hours using downtime notes.
3. Identify direct and cascading dependencies using the dependency-map seed.
4. Assign a priority tier based primarily on patient safety and cascade risk,
   then consider compliance, finances and availability of manual alternatives.
5. Propose MTD (maximum tolerable downtime), RTO (target restoration time)
   and RPO (maximum tolerable age of recoverable data), all in elapsed time.
6. Require each RTO to be strictly shorter than its MTD and identify gaps
   between proposed targets and the current backup or recovery arrangements.

**Priority definitions:** Tier 1 = immediate or cascading clinical safety risk;
Tier 2 = urgent clinical or recovery-support function; Tier 3 = important
supporting service with temporary alternatives; Tier 4 = deferrable service.
These definitions and all targets require approval by accountable owners.

**Regulatory basis:** HIPAA Security Rule 45 CFR 164.308(a)(7)(i) and
164.308(a)(7)(ii)(A)-(E) cover contingency planning, backups, disaster
recovery, emergency operations, testing and criticality analysis.
45 CFR 164.312(c)(1) addresses integrity, and 164.312(e)(1) addresses
transmission security. Joint Commission emergency-management expectations
are relevant to continuity, staff responsibilities and downtime communication.
These references describe relevant controls, not automatic reportable events
or predetermined penalties from any outage.

**Financial method:** The hourly USD amounts below are illustrative *gross
operational exposure bands* (delayed care, diverted activity, overtime and
reconciliation costs), not audited losses or additive system-level revenue.
Concurrent outages overlap and must not be summed. Finance must replace them
with MedDefense-specific encounter volumes, payer mix and downtime costs.

## System Impact Assessment

### 1. Active Directory

- **Owner:** Systems Administrator. **Tier:** 1.
- **At 1 hour:** Existing sessions may remain usable, but new clinicians and
  shift-change staff may be unable to sign in to Epic, LIS or pharmacy systems.
- **At 4 hours:** Expiring sessions and failed service authentication block
  orders, result access and medication workflows across departments.
- **At 24 hours:** Sustained inability to authenticate staff undermines safe
  patient handoffs and makes paper-to-system reconciliation extensive.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(C), (E) for emergency access
  continuity and criticality; Joint Commission emergency role/continuity needs.
- **Revenue exposure:** Proposed $5,000-$15,000 per hour, overlapping with
  affected clinical applications; Finance validation required.
- **Dependencies and cascade:** Network Core -> Active Directory -> Epic,
  LIS/PACS/pharmacy authentication, messaging, SOC and DR access control.
- **MTD:** 2 hours. **RTO:** 1 hour. **RPO:** 15 minutes.
- **Gap:** Secondary domain controller exists, but DC01 recovery was not
  recently tested; confirm identity replication and restore behavior.

### 2. Epic EHR

- **Owner:** Clinical Applications Manager. **Tier:** 1.
- **At 1 hour:** Clinicians lose electronic order entry, current allergy and
  medication context, chart review and clinical documentation; paper workflows
  need immediate activation.
- **At 4 hours:** Missing order/result reconciliation and delayed medication
  decisions increase risks in ED, ICU and inpatient care.
- **At 24 hours:** Large paper-chart backlog, missing longitudinal context and
  delayed coordination create serious patient-safety exposure.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E) and 164.312(c)(1);
  Joint Commission continuity and safe handoff expectations.
- **Revenue exposure:** Proposed $15,000-$40,000 per hour from deferred
  encounters, documentation/billing disruption and overtime; validate.
- **Dependencies and cascade:** Network Core + Active Directory -> Epic;
  Epic interfaces with LIS, pharmacy and PACS/RIS. Epic loss disrupts orders,
  medication documentation and result distribution even if subsystems run.
- **MTD:** 2 hours. **RTO:** 1 hour. **RPO:** 15 minutes.
- **Gap:** Vendor replication is documented, but local downtime procedures
  are outdated; replication and end-to-end restoration remain unproven here.

### 3. Laboratory Information System

- **Owner:** Laboratory Systems Lead. **Tier:** 2.
- **At 1 hour:** STAT tests require paper/phone routing; specimen identity,
  analyzer association and critical-result notification are at risk.
- **At 4 hours:** Manual specimen tracking increases mislabeling and missed
  critical-value calls; treatment decisions can be delayed.
- **At 24 hours:** Large unposted result backlog and reconciliation errors
  can materially affect ICU, ED and inpatient treatment.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(A)-(E), 164.312(c)(1);
  Joint Commission emergency continuity and communication expectations.
- **Revenue exposure:** Proposed $3,000-$9,000 per hour from delayed testing,
  repeat specimens and manual staffing; validate.
- **Dependencies and cascade:** Network Core + Active Directory + Epic
  interface engine + instrument feeds -> LIS -> result posting and critical
  value delivery to clinicians.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 1 hour.
- **Gap:** Nightly SQL export does not support a one-hour RPO on its own;
  implement more frequent protected backups or change the approved target.
  The 30-minute RTO is a target, not a claimed test result.

### 4. PACS/RIS

- **Owner:** Radiology Systems Lead. **Tier:** 2.
- **At 1 hour:** Urgent images may still be acquired, but comparison with
  prior studies, reporting and delivery to ED/clinicians are delayed.
- **At 4 hours:** Stroke, trauma and surgical decisions face delayed imaging
  interpretation and unreliable report handoffs.
- **At 24 hours:** Accumulated unread or undistributed studies risk missed
  diagnoses and significant care delays.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(c)(1);
  Joint Commission emergency diagnostic continuity expectations.
- **Revenue exposure:** Proposed $4,000-$12,000 per hour from delayed scans,
  interpretation and repeat work; validate.
- **Dependencies and cascade:** Network Core + Active Directory + imaging
  modalities + Epic ordering -> PACS/RIS -> image access and reports.
- **MTD:** 2 hours. **RTO:** 1 hour. **RPO:** 30 minutes.
- **Gap:** Storage snapshots exist, but restore ordering is undocumented;
  verify consistency between images, metadata and reports.

### 5. Pharmacy Dispensing System

- **Owner:** Pharmacy IT Lead. **Tier:** 1.
- **At 1 hour:** Manual verification/dispensing slows urgent medication
  delivery; electronic allergy, interaction and barcode checks degrade.
- **At 4 hours:** Repeated manual dispensing raises wrong-drug, wrong-dose
  and controlled-substance reconciliation risks.
- **At 24 hours:** Medication administration records and controlled-substance
  tracking become difficult to reconcile, threatening treatment safety.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(c)(1);
  Joint Commission medication safety and emergency workflow expectations.
- **Revenue exposure:** Proposed $3,000-$10,000 per hour from delayed care,
  additional verification staffing and interrupted dispensing; validate.
- **Dependencies and cascade:** Network Core + Active Directory + Epic ->
  pharmacy application -> medication cabinets, verification and administration.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 15 minutes.
- **Gap:** Backup schedule exists, but manual verification is inconsistent;
  validate restore and controlled-substance reconciliation procedures.

### 6. Medical Device Integration Gateway

- **Owner:** Biomedical IT Lead. **Tier:** 1.
- **At 1 hour:** Bedside monitors continue locally, but automatic charting
  and alarm routing degrade; staff need direct bedside surveillance.
- **At 4 hours:** Manual vital-sign transcription and missed remote alerts
  increase risk for ICU and telemetry patients.
- **At 24 hours:** Sustained gaps in alarm routing and vital-sign histories
  can delay recognition of patient deterioration.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(c)(1),
  164.312(e)(1); Joint Commission patient-monitoring continuity relevance.
- **Revenue exposure:** Proposed $2,000-$7,000 per hour from intensive
  manual monitoring and delayed care; validate.
- **Dependencies and cascade:** Network Core + clinical VLAN segmentation
  -> gateway -> Epic telemetry feeds and nursing alarm routing.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 5 minutes.
- **Gap:** Vendor backup status is unclear; only local configuration export
  is identified. Confirm which telemetry is recoverable and whether a
  five-minute RPO is technically feasible.

### 7. Network Core

- **Owner:** Network Engineering Lead. **Tier:** 1.
- **At 1 hour:** Routing/switching failure simultaneously interrupts
  authentication, clinical application access, device interfaces and alerts.
- **At 4 hours:** Multiple departments lose coordinated electronic workflows;
  manual escalation and patient diversion may be necessary.
- **At 24 hours:** Widespread isolation of systems and communications creates
  major patient-safety risk and prevents coordinated restoration.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(e)(1);
  Joint Commission emergency communications and continuity expectations.
- **Revenue exposure:** Proposed $20,000-$50,000 per hour of hospital-wide
  disruption; do not add to dependent-system estimates.
- **Dependencies and cascade:** Network Core -> Active Directory -> Epic,
  LIS, pharmacy, messaging, SOC and DR; also directly supports device gateway,
  PACS image movement and backup replication.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 24 hours for network
  configuration changes (not clinical transaction data).
- **Gap:** Configuration backups exist but failover testing is limited;
  verify equipment replacement, VLANs, routing and config restore.

### 8. Email and Secure Messaging

- **Owner:** Collaboration Services Lead. **Tier:** 3.
- **At 1 hour:** Clinical notifications and administrative escalation are
  delayed; approved telephone/pager alternatives may bridge urgent needs.
- **At 4 hours:** Missed messages and unclear handoffs delay consultations,
  incident coordination and regulatory correspondence.
- **At 24 hours:** Prolonged loss of secure communication creates missed
  escalation risks and a large message reconciliation backlog.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(C), 164.312(e)(1) where ePHI
  is transmitted; Joint Commission emergency communication expectations.
- **Revenue exposure:** Proposed $500-$2,000 per hour from coordination
  delays and overtime; validate.
- **Dependencies and cascade:** Network egress + Active Directory/identity
  provider + mobile access -> secure messages and clinical notifications.
- **MTD:** 8 hours. **RTO:** 4 hours. **RPO:** 1 hour.
- **Gap:** Cloud service exists, but local continuity procedures are
  incomplete; verify alternate critical-result communication paths.

### 9. Backup and DR Infrastructure

- **Owner:** Infrastructure Manager. **Tier:** 2.
- **At 1 hour:** Live care may continue, but backup jobs and restore readiness
  are at risk; concurrent clinical failure could become harder to recover.
- **At 4 hours:** Recovery operations may be blocked by inaccessible catalogs,
  storage or restore tooling, extending clinical downtime.
- **At 24 hours:** Missing backups/replication can widen permanent data-loss
  exposure and jeopardize restoration after a second failure.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(A), (B), (D), (E) and
  164.312(c)(1) for backup integrity and recovery testing.
- **Revenue exposure:** Proposed $1,000-$5,000 per hour of response and
  deferred recovery capability; catastrophic-loss exposure not quantified.
- **Dependencies and cascade:** Network Core + Active Directory access +
  backup catalog/storage -> restores for all protected clinical systems.
- **MTD:** 8 hours. **RTO:** 2 hours. **RPO:** 1 hour for backup catalog and
  job metadata; protected application RPOs are assessed separately.
- **Gap:** Monitoring gaps are known; verify immutable/offsite copies,
  catalog access and ability to restore without production identity services.

### 10. Security Operations Platform

- **Owner:** SOC Manager. **Tier:** 3.
- **At 1 hour:** SIEM alerts and central EDR management may be delayed;
  active threats can go unnoticed while clinical systems remain available.
- **At 4 hours:** Reduced incident detection and triage can allow threats to
  spread or delay containment during an outage.
- **At 24 hours:** Significant visibility gaps hinder investigation, evidence
  preservation and confidence in safely returning systems to service.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(C)-(E), 164.312(c)(1)
  where monitoring supports emergency integrity and restoration decisions.
- **Revenue exposure:** Proposed $500-$3,000 per hour for extra manual
  monitoring and response; breach-loss exposure not quantified.
- **Dependencies and cascade:** Network Core + Active Directory + log sources
  + EDR management -> SIEM/EDR visibility -> response and safe recovery.
- **MTD:** 8 hours. **RTO:** 4 hours. **RPO:** 15 minutes of security
  telemetry, subject to source-side buffering and retention validation.
- **Gap:** Cold restore is documented but alerting continuity is untested;
  confirm buffered log ingestion after restoration.

## Dependency Map

```text
Network Core
|-- Active Directory
|   |-- Epic EHR
|   |   |-- LIS interface
|   |   |-- Pharmacy Dispensing System
|   |   `-- PACS/RIS ordering and results
|   |-- Email and Secure Messaging
|   |-- Security Operations Platform
|   `-- Backup and DR Infrastructure access control
|-- Medical Device Integration Gateway
|   `-- Epic telemetry and nursing alarm routing
|-- PACS/RIS image movement
`-- Backup replication traffic

Backup and DR Infrastructure
`-- Restore capability for protected systems
```

The diagram reflects the provided dependency seed, with the device-gateway
clinical outputs and backup restore role made explicit from the inventory.
A dependency arrow represents a recovery prerequisite or important interface,
not proof that every downstream service stops immediately.

**Proposed recovery order:** (1) Network Core; (2) Active Directory or
approved emergency identity access; (3) backup/DR access; (4) highest-risk
clinical systems, with pharmacy, device gateway, Epic and urgent LIS/PACS
functions coordinated in parallel where safe; (5) messaging; (6) security
visibility; (7) lower-priority support functions. Do not delay emergency
clinical workarounds while technical prerequisites are restored.

## RTO / RPO / MTD Summary Table

| System | Tier | RTO | RPO | MTD | Proposed hourly exposure |
| --- | --- | --- | --- | --- | --- |
| Active Directory | 1 | 1 h | 15 min | 2 h | $5k-$15k |
| Epic EHR | 1 | 1 h | 15 min | 2 h | $15k-$40k |
| LIS | 2 | 30 min | 1 h | 1 h | $3k-$9k |
| PACS/RIS | 2 | 1 h | 30 min | 2 h | $4k-$12k |
| Pharmacy Dispensing | 1 | 30 min | 15 min | 1 h | $3k-$10k |
| Medical Device Gateway | 1 | 30 min | 5 min | 1 h | $2k-$7k |
| Network Core | 1 | 30 min | 24 h (config) | 1 h | $20k-$50k |
| Email and Secure Messaging | 3 | 4 h | 1 h | 8 h | $0.5k-$2k |
| Backup and DR Infrastructure | 2 | 2 h | 1 h (catalog) | 8 h | $1k-$5k |
| Security Operations Platform | 3 | 4 h | 15 min | 8 h | $0.5k-$3k |

All RTOs are strictly less than their MTDs. Every RPO is a time interval.
These targets must be reviewed against achievable backup intervals, replication,
restore tests, vendor contracts and clinical tolerance before approval.

## Assumptions and Limitations

- This is a fictional MedDefense planning assessment, not a live hospital BIA.
- Source materials establish the ten systems, owners, dependencies, known DR
  status and general one-, four- and 24-hour downtime consequences.
- The sources do **not** provide actual revenue rates, approved recovery
  objectives, patient volumes by service or confirmed alternate-workflow
  capacities. Hourly exposures and RTO/RPO/MTD values are explicit proposals.
- Estimates are non-additive; simultaneous outages share financial effects.
- A 24-hour impact description does not imply that a 24-hour outage is safe
  or that the proposed MTD could be extended to that point.
- Clinical leaders must validate time-to-harm for critical results, urgent
  medications, stroke/trauma imaging and bedside alarm workflows.
- Finance must substantiate hourly estimates using local encounter data,
  reimbursement, staffing costs and patient diversion assumptions.
- IT owners must verify vendor dependencies, backup frequency, retention,
  identity break-glass access, alternate networks and restore sequence.
- The nightly LIS SQL export does not demonstrate the proposed one-hour RPO;
  no successful restore, data integrity check or achieved RTO is asserted.
- HIPAA and Joint Commission references identify relevant requirements;
  outage duration alone does not prove a violation or reporting trigger.
- CISO approval is intentionally blank. The document is not signed or
  formally adopted until reviewed and approved by authorized personnel.

**Source materials reviewed:**

- `bia/meddefense_system_inventory.csv`
- `bia/downtime_impact_notes.md`
- `bia/regulatory_reference_map.md`
- `backup_architecture/dependency_map_seed.md`
 
**Status:** Draft for clinical, finance, IT and CISO review; not yet approved

## Executive Summary

MedDefense is a 230-bed acute-care hospital operating emergency, ICU, surgery,
radiology, laboratory and pharmacy services around the clock. This assessment
covers ten systems and prioritizes them by patient harm, clinical workarounds,
regulatory duties, financial exposure and recovery dependencies. A prolonged
outage can delay medication decisions, critical laboratory results and imaging,
while an outage of Network Core or Active Directory can disrupt several
clinical systems at once.

The proposed Tier 1 systems are Network Core, Active Directory, Epic EHR,
Pharmacy Dispensing System and Medical Device Integration Gateway. LIS and
PACS/RIS are Tier 2 because time-critical diagnostics require rapid recovery;
their specific targets must be confirmed by clinical leadership. The remaining
systems are Tier 2 or Tier 3 as shown below. No system is classified Tier 4.

**These are planning targets, not demonstrated capabilities.** In particular,
LIS currently has a nightly SQL export, which cannot by itself assure the
proposed one-hour RPO. A separate lab configuration specifies a 30-minute LIS
recovery-test target; this BIA proposes the same RTO for planning, but only a
measured recovery test can establish whether it is achievable. Revenue
exposures are scenario estimates, not figures supplied by MedDefense Finance.

## Methodology

1. Review the system inventory for clinical functions, owners and known DR gaps.
2. Evaluate the consequences at one, four and 24 hours using downtime notes.
3. Identify direct and cascading dependencies using the dependency-map seed.
4. Assign a priority tier based primarily on patient safety and cascade risk,
   then consider compliance, finances and availability of manual alternatives.
5. Propose MTD (maximum tolerable downtime), RTO (target restoration time)
   and RPO (maximum tolerable age of recoverable data), all in elapsed time.
6. Require each RTO to be strictly shorter than its MTD and identify gaps
   between proposed targets and the current backup or recovery arrangements.

**Priority definitions:** Tier 1 = immediate or cascading clinical safety risk;
Tier 2 = urgent clinical or recovery-support function; Tier 3 = important
supporting service with temporary alternatives; Tier 4 = deferrable service.
These definitions and all targets require approval by accountable owners.

**Regulatory basis:** HIPAA Security Rule 45 CFR 164.308(a)(7)(i) and
164.308(a)(7)(ii)(A)-(E) cover contingency planning, backups, disaster
recovery, emergency operations, testing and criticality analysis.
45 CFR 164.312(c)(1) addresses integrity, and 164.312(e)(1) addresses
transmission security. Joint Commission emergency-management expectations
are relevant to continuity, staff responsibilities and downtime communication.
These references describe relevant controls, not automatic reportable events
or predetermined penalties from any outage.

**Financial method:** The hourly USD amounts below are illustrative *gross
operational exposure bands* (delayed care, diverted activity, overtime and
reconciliation costs), not audited losses or additive system-level revenue.
Concurrent outages overlap and must not be summed. Finance must replace them
with MedDefense-specific encounter volumes, payer mix and downtime costs.

## System Impact Assessment

### 1. Active Directory

- **Owner:** Systems Administrator. **Tier:** 1.
- **At 1 hour:** Existing sessions may remain usable, but new clinicians and
  shift-change staff may be unable to sign in to Epic, LIS or pharmacy systems.
- **At 4 hours:** Expiring sessions and failed service authentication block
  orders, result access and medication workflows across departments.
- **At 24 hours:** Sustained inability to authenticate staff undermines safe
  patient handoffs and makes paper-to-system reconciliation extensive.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(C), (E) for emergency access
  continuity and criticality; Joint Commission emergency role/continuity needs.
- **Revenue exposure:** Proposed $5,000-$15,000 per hour, overlapping with
  affected clinical applications; Finance validation required.
- **Dependencies and cascade:** Network Core -> Active Directory -> Epic,
  LIS/PACS/pharmacy authentication, messaging, SOC and DR access control.
- **MTD:** 2 hours. **RTO:** 1 hour. **RPO:** 15 minutes.
- **Gap:** Secondary domain controller exists, but DC01 recovery was not
  recently tested; confirm identity replication and restore behavior.

### 2. Epic EHR

- **Owner:** Clinical Applications Manager. **Tier:** 1.
- **At 1 hour:** Clinicians lose electronic order entry, current allergy and
  medication context, chart review and clinical documentation; paper workflows
  need immediate activation.
- **At 4 hours:** Missing order/result reconciliation and delayed medication
  decisions increase risks in ED, ICU and inpatient care.
- **At 24 hours:** Large paper-chart backlog, missing longitudinal context and
  delayed coordination create serious patient-safety exposure.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E) and 164.312(c)(1);
  Joint Commission continuity and safe handoff expectations.
- **Revenue exposure:** Proposed $15,000-$40,000 per hour from deferred
  encounters, documentation/billing disruption and overtime; validate.
- **Dependencies and cascade:** Network Core + Active Directory -> Epic;
  Epic interfaces with LIS, pharmacy and PACS/RIS. Epic loss disrupts orders,
  medication documentation and result distribution even if subsystems run.
- **MTD:** 2 hours. **RTO:** 1 hour. **RPO:** 15 minutes.
- **Gap:** Vendor replication is documented, but local downtime procedures
  are outdated; replication and end-to-end restoration remain unproven here.

### 3. Laboratory Information System

- **Owner:** Laboratory Systems Lead. **Tier:** 2.
- **At 1 hour:** STAT tests require paper/phone routing; specimen identity,
  analyzer association and critical-result notification are at risk.
- **At 4 hours:** Manual specimen tracking increases mislabeling and missed
  critical-value calls; treatment decisions can be delayed.
- **At 24 hours:** Large unposted result backlog and reconciliation errors
  can materially affect ICU, ED and inpatient treatment.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(A)-(E), 164.312(c)(1);
  Joint Commission emergency continuity and communication expectations.
- **Revenue exposure:** Proposed $3,000-$9,000 per hour from delayed testing,
  repeat specimens and manual staffing; validate.
- **Dependencies and cascade:** Network Core + Active Directory + Epic
  interface engine + instrument feeds -> LIS -> result posting and critical
  value delivery to clinicians.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 1 hour.
- **Gap:** Nightly SQL export does not support a one-hour RPO on its own;
  implement more frequent protected backups or change the approved target.
  The 30-minute RTO is a target, not a claimed test result.

### 4. PACS/RIS

- **Owner:** Radiology Systems Lead. **Tier:** 2.
- **At 1 hour:** Urgent images may still be acquired, but comparison with
  prior studies, reporting and delivery to ED/clinicians are delayed.
- **At 4 hours:** Stroke, trauma and surgical decisions face delayed imaging
  interpretation and unreliable report handoffs.
- **At 24 hours:** Accumulated unread or undistributed studies risk missed
  diagnoses and significant care delays.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(c)(1);
  Joint Commission emergency diagnostic continuity expectations.
- **Revenue exposure:** Proposed $4,000-$12,000 per hour from delayed scans,
  interpretation and repeat work; validate.
- **Dependencies and cascade:** Network Core + Active Directory + imaging
  modalities + Epic ordering -> PACS/RIS -> image access and reports.
- **MTD:** 2 hours. **RTO:** 1 hour. **RPO:** 30 minutes.
- **Gap:** Storage snapshots exist, but restore ordering is undocumented;
  verify consistency between images, metadata and reports.

### 5. Pharmacy Dispensing System

- **Owner:** Pharmacy IT Lead. **Tier:** 1.
- **At 1 hour:** Manual verification/dispensing slows urgent medication
  delivery; electronic allergy, interaction and barcode checks degrade.
- **At 4 hours:** Repeated manual dispensing raises wrong-drug, wrong-dose
  and controlled-substance reconciliation risks.
- **At 24 hours:** Medication administration records and controlled-substance
  tracking become difficult to reconcile, threatening treatment safety.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(c)(1);
  Joint Commission medication safety and emergency workflow expectations.
- **Revenue exposure:** Proposed $3,000-$10,000 per hour from delayed care,
  additional verification staffing and interrupted dispensing; validate.
- **Dependencies and cascade:** Network Core + Active Directory + Epic ->
  pharmacy application -> medication cabinets, verification and administration.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 15 minutes.
- **Gap:** Backup schedule exists, but manual verification is inconsistent;
  validate restore and controlled-substance reconciliation procedures.

### 6. Medical Device Integration Gateway

- **Owner:** Biomedical IT Lead. **Tier:** 1.
- **At 1 hour:** Bedside monitors continue locally, but automatic charting
  and alarm routing degrade; staff need direct bedside surveillance.
- **At 4 hours:** Manual vital-sign transcription and missed remote alerts
  increase risk for ICU and telemetry patients.
- **At 24 hours:** Sustained gaps in alarm routing and vital-sign histories
  can delay recognition of patient deterioration.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(c)(1),
  164.312(e)(1); Joint Commission patient-monitoring continuity relevance.
- **Revenue exposure:** Proposed $2,000-$7,000 per hour from intensive
  manual monitoring and delayed care; validate.
- **Dependencies and cascade:** Network Core + clinical VLAN segmentation
  -> gateway -> Epic telemetry feeds and nursing alarm routing.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 5 minutes.
- **Gap:** Vendor backup status is unclear; only local configuration export
  is identified. Confirm which telemetry is recoverable and whether a
  five-minute RPO is technically feasible.

### 7. Network Core

- **Owner:** Network Engineering Lead. **Tier:** 1.
- **At 1 hour:** Routing/switching failure simultaneously interrupts
  authentication, clinical application access, device interfaces and alerts.
- **At 4 hours:** Multiple departments lose coordinated electronic workflows;
  manual escalation and patient diversion may be necessary.
- **At 24 hours:** Widespread isolation of systems and communications creates
  major patient-safety risk and prevents coordinated restoration.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(B)-(E), 164.312(e)(1);
  Joint Commission emergency communications and continuity expectations.
- **Revenue exposure:** Proposed $20,000-$50,000 per hour of hospital-wide
  disruption; do not add to dependent-system estimates.
- **Dependencies and cascade:** Network Core -> Active Directory -> Epic,
  LIS, pharmacy, messaging, SOC and DR; also directly supports device gateway,
  PACS image movement and backup replication.
- **MTD:** 1 hour. **RTO:** 30 minutes. **RPO:** 24 hours for network
  configuration changes (not clinical transaction data).
- **Gap:** Configuration backups exist but failover testing is limited;
  verify equipment replacement, VLANs, routing and config restore.

### 8. Email and Secure Messaging

- **Owner:** Collaboration Services Lead. **Tier:** 3.
- **At 1 hour:** Clinical notifications and administrative escalation are
  delayed; approved telephone/pager alternatives may bridge urgent needs.
- **At 4 hours:** Missed messages and unclear handoffs delay consultations,
  incident coordination and regulatory correspondence.
- **At 24 hours:** Prolonged loss of secure communication creates missed
  escalation risks and a large message reconciliation backlog.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(C), 164.312(e)(1) where ePHI
  is transmitted; Joint Commission emergency communication expectations.
- **Revenue exposure:** Proposed $500-$2,000 per hour from coordination
  delays and overtime; validate.
- **Dependencies and cascade:** Network egress + Active Directory/identity
  provider + mobile access -> secure messages and clinical notifications.
- **MTD:** 8 hours. **RTO:** 4 hours. **RPO:** 1 hour.
- **Gap:** Cloud service exists, but local continuity procedures are
  incomplete; verify alternate critical-result communication paths.

### 9. Backup and DR Infrastructure

- **Owner:** Infrastructure Manager. **Tier:** 2.
- **At 1 hour:** Live care may continue, but backup jobs and restore readiness
  are at risk; concurrent clinical failure could become harder to recover.
- **At 4 hours:** Recovery operations may be blocked by inaccessible catalogs,
  storage or restore tooling, extending clinical downtime.
- **At 24 hours:** Missing backups/replication can widen permanent data-loss
  exposure and jeopardize restoration after a second failure.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(A), (B), (D), (E) and
  164.312(c)(1) for backup integrity and recovery testing.
- **Revenue exposure:** Proposed $1,000-$5,000 per hour of response and
  deferred recovery capability; catastrophic-loss exposure not quantified.
- **Dependencies and cascade:** Network Core + Active Directory access +
  backup catalog/storage -> restores for all protected clinical systems.
- **MTD:** 8 hours. **RTO:** 2 hours. **RPO:** 1 hour for backup catalog and
  job metadata; protected application RPOs are assessed separately.
- **Gap:** Monitoring gaps are known; verify immutable/offsite copies,
  catalog access and ability to restore without production identity services.

### 10. Security Operations Platform

- **Owner:** SOC Manager. **Tier:** 3.
- **At 1 hour:** SIEM alerts and central EDR management may be delayed;
  active threats can go unnoticed while clinical systems remain available.
- **At 4 hours:** Reduced incident detection and triage can allow threats to
  spread or delay containment during an outage.
- **At 24 hours:** Significant visibility gaps hinder investigation, evidence
  preservation and confidence in safely returning systems to service.
- **Regulatory:** HIPAA 164.308(a)(7)(ii)(C)-(E), 164.312(c)(1)
  where monitoring supports emergency integrity and restoration decisions.
- **Revenue exposure:** Proposed $500-$3,000 per hour for extra manual
  monitoring and response; breach-loss exposure not quantified.
- **Dependencies and cascade:** Network Core + Active Directory + log sources
  + EDR management -> SIEM/EDR visibility -> response and safe recovery.
- **MTD:** 8 hours. **RTO:** 4 hours. **RPO:** 15 minutes of security
  telemetry, subject to source-side buffering and retention validation.
- **Gap:** Cold restore is documented but alerting continuity is untested;
  confirm buffered log ingestion after restoration.

## Dependency Map

```text
Network Core
|-- Active Directory
|   |-- Epic EHR
|   |   |-- LIS interface
|   |   |-- Pharmacy Dispensing System
|   |   `-- PACS/RIS ordering and results
|   |-- Email and Secure Messaging
|   |-- Security Operations Platform
|   `-- Backup and DR Infrastructure access control
|-- Medical Device Integration Gateway
|   `-- Epic telemetry and nursing alarm routing
|-- PACS/RIS image movement
`-- Backup replication traffic

Backup and DR Infrastructure
`-- Restore capability for protected systems
```

The diagram reflects the provided dependency seed, with the device-gateway
clinical outputs and backup restore role made explicit from the inventory.
A dependency arrow represents a recovery prerequisite or important interface,
not proof that every downstream service stops immediately.

**Proposed recovery order:** (1) Network Core; (2) Active Directory or
approved emergency identity access; (3) backup/DR access; (4) highest-risk
clinical systems, with pharmacy, device gateway, Epic and urgent LIS/PACS
functions coordinated in parallel where safe; (5) messaging; (6) security
visibility; (7) lower-priority support functions. Do not delay emergency
clinical workarounds while technical prerequisites are restored.

## RTO / RPO / MTD Summary Table

| System | Tier | RTO | RPO | MTD | Proposed hourly exposure |
| --- | --- | --- | --- | --- | --- |
| Active Directory | 1 | 1 h | 15 min | 2 h | $5k-$15k |
| Epic EHR | 1 | 1 h | 15 min | 2 h | $15k-$40k |
| LIS | 2 | 30 min | 1 h | 1 h | $3k-$9k |
| PACS/RIS | 2 | 1 h | 30 min | 2 h | $4k-$12k |
| Pharmacy Dispensing | 1 | 30 min | 15 min | 1 h | $3k-$10k |
| Medical Device Gateway | 1 | 30 min | 5 min | 1 h | $2k-$7k |
| Network Core | 1 | 30 min | 24 h (config) | 1 h | $20k-$50k |
| Email and Secure Messaging | 3 | 4 h | 1 h | 8 h | $0.5k-$2k |
| Backup and DR Infrastructure | 2 | 2 h | 1 h (catalog) | 8 h | $1k-$5k |
| Security Operations Platform | 3 | 4 h | 15 min | 8 h | $0.5k-$3k |

All RTOs are strictly less than their MTDs. Every RPO is a time interval.
These targets must be reviewed against achievable backup intervals, replication,
restore tests, vendor contracts and clinical tolerance before approval.

## Assumptions and Limitations

- This is a fictional MedDefense planning assessment, not a live hospital BIA.
- Source materials establish the ten systems, owners, dependencies, known DR
  status and general one-, four- and 24-hour downtime consequences.
- The sources do **not** provide actual revenue rates, approved recovery
  objectives, patient volumes by service or confirmed alternate-workflow
  capacities. Hourly exposures and RTO/RPO/MTD values are explicit proposals.
- Estimates are non-additive; simultaneous outages share financial effects.
- A 24-hour impact description does not imply that a 24-hour outage is safe
  or that the proposed MTD could be extended to that point.
- Clinical leaders must validate time-to-harm for critical results, urgent
  medications, stroke/trauma imaging and bedside alarm workflows.
- Finance must substantiate hourly estimates using local encounter data,
  reimbursement, staffing costs and patient diversion assumptions.
- IT owners must verify vendor dependencies, backup frequency, retention,
  identity break-glass access, alternate networks and restore sequence.
- The nightly LIS SQL export does not demonstrate the proposed one-hour RPO;
  no successful restore, data integrity check or achieved RTO is asserted.
- HIPAA and Joint Commission references identify relevant requirements;
  outage duration alone does not prove a violation or reporting trigger.
- CISO approval is intentionally blank. The document is not signed or
  formally adopted until reviewed and approved by authorized personnel.

**Source materials reviewed:**

- `bia/meddefense_system_inventory.csv`
- `bia/downtime_impact_notes.md`
- `bia/regulatory_reference_map.md`
- `backup_architecture/dependency_map_seed.md`
