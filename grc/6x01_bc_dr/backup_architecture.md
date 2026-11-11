
# MedDefense Backup Architecture

**Version:** 1.0  
**Classification:** Confidential  
**Prepared by:** Nishat Sultana Supty 
**Date:** 2026-11-11  
**Status:** Draft - Proposed Design, Pending Validation

## Strategy Overview

### 1. Purpose

This document defines a backup and disaster recovery architecture
for MedDefense, a fictional 230-bed acute-care hospital.

The objective is to protect critical hospital systems, reduce
potential data loss, and restore clinical services after a major
IT failure or complete data center outage.

The architecture is based on:

- The MedDefense Business Impact Analysis (BIA).
- The current backup schedule.
- Robert Kim's backup log review findings.
- The provided system dependency map.

This document proposes improvements to the existing environment.
It does not claim that the improvements have already been
implemented or successfully tested.

### 2. Recovery Objectives

RTO (Recovery Time Objective) is the maximum target time to
restore a system after an outage.

RPO (Recovery Point Objective) is the maximum acceptable age
of recovered data, measured in time.

The following objectives come from the draft BIA.

| System | Tier | RTO | RPO |
| --- | --- | --- | --- |
| Network Core | 1 | 30 min | 24 h |
| Active Directory | 1 | 1 h | 15 min |
| Epic EHR | 1 | 1 h | 15 min |
| Pharmacy Dispensing System | 1 | 30 min | 15 min |
| Medical Device Integration Gateway | 1 | 30 min | 5 min |
| Laboratory Information System | 2 | 30 min | 1 h |
| PACS/RIS | 2 | 1 h | 30 min |
| Backup and DR Infrastructure | 2 | 2 h | 1 h |

These are proposed recovery objectives and require approval
from the responsible system owners and hospital leadership.

### 3. Overall Backup Strategy

MedDefense will use a combination of full backups, incremental
backups, application-consistent snapshots, and frequent
replication or transaction-log backups.

The architecture follows the 3-2-1 backup principle:

1. Maintain at least three copies of critical data.
2. Use at least two independent storage locations or media types.
3. Maintain at least one geographically separate copy.

An immutable or offline backup copy should also be maintained
to protect against ransomware and accidental deletion.

For Tier 1 systems, geographically separate backup storage
is mandatory.

Tier 2 systems will also use off-site backup storage because
their recovery is important to clinical operations.

### 4. Backup Storage Locations

**Primary destination**

A dedicated encrypted backup repository inside the hospital
data center will store recent backups for rapid recovery.

Depending on the system, this may include:

- Backup NAS storage.
- Dedicated backup appliances.
- Protected database backup repositories.
- Application-specific storage.
- Network configuration repositories.

**Secondary destination**

A geographically separate recovery site or encrypted cloud
backup repository will hold protected copies.

The proposed secondary environment must provide:

- Geographic separation from the main hospital.
- AES-256 encryption at rest.
- TLS 1.2 or later for backup transfers.
- Immutable or protected backup storage.
- Independent emergency administrator access.
- Sufficient capacity for required recovery points.

The current backup schedule identifies several existing
secondary destinations, including vendor-hosted storage,
cloud object storage and isolated backup accounts.

However, their geographic separation, recoverability and
accessibility during a full site outage still require testing.

### 5. Encryption and Access Control

All backups containing electronic protected health
information (ePHI) must use:

- AES-256 encryption at rest.
- TLS 1.2 or later during transfer.
- Encryption keys managed by a protected KMS or HSM.
- Restricted access based on job responsibilities.
- MFA for privileged backup administrators.
- Audit logging for backup and restore operations.

Backup encryption keys must be recoverable through an
approved emergency procedure independent of the failed
production environment.

### 6. Proposed Retention Policy

| Retention category | Proposed period |
| --- | --- |
| Recent operational backups | 30 days |
| Monthly recovery copies | 12 months |
| Annual archive copies | 7 years |

These are proposed operational retention periods.

They are not confirmed legal retention requirements.
The hospital must validate them with its compliance,
legal and clinical records teams.

For Active Directory, the technical validity of older
system-state backups must also be considered. Historical
archive retention does not mean an old domain-controller
backup can safely be restored.

### 7. Backup Verification Strategy

A successful backup job does not automatically mean that
the backup is usable.

Robert Kim's review identified insufficient verification
and missing restore testing.

The proposed verification process includes:

1. Checking the backup completion status.
2. Recording the backup timestamp.
3. Verifying SHA-256 hashes or equivalent integrity data.
4. Confirming the latest recoverable data timestamp.
5. Performing sample restore tests.
6. Checking database records and application functionality.
7. Recording the tester, date, result and corrective actions.

Proposed verification frequency:

| Verification activity | Frequency |
| --- | --- |
| Backup completion monitoring | Every job |
| Hash or integrity verification | Every job |
| Recovery-point age monitoring | Continuous |
| Critical database sample restore | Daily |
| Tier 1 recovery testing | Monthly |
| Tier 2 recovery testing | Quarterly |
| Full data center DR exercise | Twice yearly |

These verification schedules are proposed improvements.

## RPO Compliance Verification

### 1. Current Backup Assessment

The existing backup schedule was compared with the RPO
requirements from the BIA.

The comparison identifies systems whose current backup
frequency is longer than the maximum acceptable data loss.

| System | BIA RPO | Current backup frequency | Assessment |
| --- | --- | --- | --- |
| Network Core | 24 h | Every 6 h | Frequency meets |
| Active Directory | 15 min | Snapshot every 8 h; system state daily | Does not meet |
| Epic EHR | 15 min | Replication every 15 min | At limit; unverified |
| Pharmacy Dispensing | 15 min | Database hourly; config daily | Does not meet |
| Medical Device Gateway | 5 min | Daily configuration export | Does not meet |
| LIS | 1 h | Nightly SQL dump at 23:30 | Does not meet |
| PACS/RIS | 30 min | Snapshot every 4 h | Does not meet |
| Backup and DR | 1 h | Catalog every 4 h | Does not meet |

The frequency assessment does not establish that any backup
is restorable or available at the alternate recovery site.

### 2. RPO Calculation Method

The proposed architecture uses the following conservative
planning calculation:

Maximum recovery-point age =
Capture interval + maximum delivery and verification delay

To satisfy an RPO:

Maximum recovery-point age must be less than or equal to RPO.

For example:

If a system has a 60-minute RPO and backups are captured
every 15 minutes with a maximum five-minute delivery delay:

15 + 5 = 20 minutes.

20 minutes <= 60 minutes.

The design satisfies the mathematical requirement.

This calculation assumes that each protected recovery point
is successfully transferred and verified within the stated
maximum delay.

Failed jobs, replication gaps or incomplete transfers can
invalidate the calculation.

Actual compliance must therefore be measured using the
timestamp of the latest verified, recoverable off-site copy.

### 3. Robert Kim's Backup Findings

Robert Kim reviewed backup logs between April 1 and
April 21, 2026.

His findings identified the following issues.

#### Finding 1: LIS RPO Conflict

Current backup:

- Nightly SQL dump at 23:30.
- SHA-256 manifest generated automatically.
- No documented restore testing.

Required RPO: 60 minutes.

Current backup interval: 1,440 minutes.

Calculation:

1,440 minutes > 60 minutes.

**Result: The current backup schedule does not meet the RPO.**

Proposed improvement:

- Full database backup daily.
- Incremental backups every four hours.
- Transaction-log backups or equivalent recoverable points
  every 15 minutes.
- Maximum off-site delivery and verification delay: 5 minutes.
- Daily sample restore testing.

Proposed maximum recovery-point age:

15 + 5 = 20 minutes.

20 minutes <= 60 minutes.

The proposed design meets the mathematical target.

The production database technology must be verified before
selecting a transaction-log backup method.

#### Finding 2: Medical Device Gateway Geographic Copy Gap

Current backup:

- Daily configuration export at 02:30.
- Primary destination: Biomed file share.
- Secondary destination: None.
- Verification: Manual file existence check.
- No documented restore test.

Required RPO: 5 minutes.

A daily configuration export cannot provide a five-minute
recovery point for recoverable gateway data.

The missing secondary copy also creates a major risk.

A complete data center loss could destroy the production
gateway and its only configuration backup.

Proposed improvement:

- Full configuration export daily.
- Additional export after approved configuration changes.
- One-minute replication of recoverable gateway data.
- Encrypted geographically separate backup storage.
- Monthly recovery-readiness checks.
- Quarterly documented full restore tests.

Proposed maximum recovery-point age:

1 + 1 = 2 minutes.

2 minutes <= 5 minutes.

This target is achievable only if the vendor supports
the necessary replication and data recovery features.

A configuration backup alone does not establish a
five-minute RPO for historical telemetry.

#### Finding 3: Active Directory Snapshot Conflict

Current backup:

- System-state backup daily at 01:00.
- VM snapshot every eight hours.
- Backup completion is the main verification method.

Required RPO: 15 minutes.

Current snapshot interval: 480 minutes.

Calculation:

480 minutes > 15 minutes.

**Result: The current snapshot schedule does not meet the RPO.**

Proposed improvement:

- Daily system-state backup.
- Directory replication every five minutes or faster.
- Geographically separate recovery domain controller.
- Protected recoverable directory-state copies.
- Monthly isolated recovery testing.

Proposed maximum recovery-point age:

5 + 2 = 7 minutes.

7 minutes <= 15 minutes.

Replication must not be treated as a complete replacement
for protected backups.

A separate recovery copy is needed to recover from
accidental deletion, corruption or malicious changes.

#### Finding 4: Backup Completion Is Not Verification

Robert Kim found that a successful backup job only proves
that the job completed.

It does not prove the data can be restored.

The proposed architecture therefore requires:

- Hash verification.
- Test restoration.
- Database record-count checks where appropriate.
- Application-level validation.
- Tester identity and date.
- Documented evidence of successful or failed recovery.

#### Finding 5: Backup Platform Recovery Gap

The backup platform is itself a critical dependency.

If the backup catalog or management service becomes
unavailable, other systems may not be recoverable even
when their backup files still exist.

Proposed improvement:

- Protect backup catalogs in a separate recovery location.
- Maintain independent recovery credentials.
- Document backup-platform restoration.
- Test recovery without production Active Directory.
- Measure actual backup-platform recovery time.

### 4. Additional RPO Gaps from the Current Schedule

#### Pharmacy Dispensing System

Current database backup: Every 60 minutes.

Required RPO: 15 minutes.

60 minutes > 15 minutes.

Proposed recovery-point interval: 5 minutes.

Maximum delay: 2 minutes.

5 + 2 = 7 minutes.

7 minutes <= 15 minutes.

#### PACS/RIS

Current snapshot interval: 240 minutes.

Required RPO: 30 minutes.

240 minutes > 30 minutes.

Proposed recovery-point interval: 10 minutes.

Maximum delay: 5 minutes.

10 + 5 = 15 minutes.

15 minutes <= 30 minutes.

#### Backup and DR Infrastructure

Current catalog backup interval: 240 minutes.

Required RPO: 60 minutes.

240 minutes > 60 minutes.

Proposed catalog recovery-point interval: 15 minutes.

Maximum delay: 5 minutes.

15 + 5 = 20 minutes.

20 minutes <= 60 minutes.

#### Epic EHR

Current replication interval: 15 minutes.

Required RPO: 15 minutes.

The interval equals the RPO, leaving no allowance for
replication or verification delay.

Proposed recovery-point interval: 5 minutes.

Maximum delay: 2 minutes.

5 + 2 = 7 minutes.

7 minutes <= 15 minutes.

Vendor confirmation is required before implementing
a more frequent replication schedule.

#### Network Core

Current configuration backup interval: 6 hours.

Required configuration RPO: 24 hours.

6 hours <= 24 hours.

The current frequency meets the mathematical requirement.

However, geographically separate storage and bare-metal
configuration recovery must still be verified.

### 5. Proposed RPO Compliance Summary

| System | RPO | Capture interval | Max delay | Max age | Design result |
| --- | --- | --- | --- | --- | --- |
| Network Core | 24 h | 12 h | 1 h | 13 h | Meets |
| Active Directory | 15 min | 5 min | 2 min | 7 min | Meets |
| Epic EHR | 15 min | 5 min | 2 min | 7 min | Meets |
| Pharmacy Dispensing | 15 min | 5 min | 2 min | 7 min | Meets |
| Medical Device Gateway | 5 min | 1 min | 1 min | 2 min | Meets |
| LIS | 60 min | 15 min | 5 min | 20 min | Meets |
| PACS/RIS | 30 min | 10 min | 5 min | 15 min | Meets |
| Backup and DR | 60 min | 15 min | 5 min | 20 min | Meets |

All proposed capture intervals are shorter than the
corresponding RPO values.

"Meets" means the proposed schedule satisfies the
mathematical design requirement.

It does not mean the system has passed an actual recovery test.

The maximum delay values are proposed operational limits
that must be enforced through monitoring.

## Per-System Backup Specifications

### 1. Network Core

| Field | Specification |
| --- | --- |
| Tier | 1 |
| RTO / RPO | 30 min / 24 h |
| Backup type | Full configuration export and incremental change export |
| Schedule | Full daily at 00:00; incremental every 12 h and after changes |
| Retention | Recent 30 days; monthly 12 months; annual 7 years |
| Primary destination | On-site encrypted network management repository |
| Secondary destination | Geographically separate encrypted Git repository and cloud storage |
| Encryption at rest | AES-256; KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ for backup transfers |
| Integrity verification | SHA-256, configuration diff and monthly restore test |
| Restoration sequence | Recovery network, routing, switching, VLANs and firewall paths |
| Responsible role | Network Engineering Lead executes; Infrastructure Manager verifies |

**Current state**

The network configuration is currently backed up every
six hours to the network management server, with an
encrypted Git repository as the secondary destination.

The current verification uses configuration difference checks.

**Proposed improvement**

Maintain tested spare equipment or a pre-provisioned
network environment at the recovery site.

Verify that the secondary repository is geographically
separate and accessible during a complete data center loss.

Document the bare-metal replacement procedure.

The 24-hour RPO applies to configuration changes,
not patient data.

### 2. Active Directory

| Field | Specification |
| --- | --- |
| Tier | 1 |
| RTO / RPO | 1 h / 15 min |
| Backup type | Full system-state backup, protected directory copies and replication |
| Schedule | Full daily at 01:00; verified replication every 5 min |
| Retention | Recent 30 days; monthly 12 months; archive 7 years subject to AD limitations |
| Primary destination | On-site encrypted backup NAS and secondary domain controller |
| Secondary destination | Geographically separate encrypted recovery repository and domain controller |
| Encryption at rest | AES-256; KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ for backup transfers; secure AD replication |
| Integrity verification | SHA-256 and monthly isolated directory restore |
| Restoration sequence | Network, DNS, directory services and authentication verification |
| Responsible role | Systems Administrator executes; Infrastructure Manager verifies |

**Current state**

- Daily system-state backup.
- VM snapshots every eight hours.
- Backup NAS rack A.
- S3 backup account.
- Backup completion verification only.

**Proposed improvement**

Implement protected, frequent recovery points and
verify replication to a separate recovery domain controller.

Confirm that the S3 backup account is geographically
separate from the production site.

Test restoration of:

- Domain controller services.
- DNS resolution.
- User authentication.
- Service accounts.
- Group policy.

Replication alone must not be considered a replacement
for recoverable system-state backups.

### 3. Epic EHR

| Field | Specification |
| --- | --- |
| Tier | 1 |
| RTO / RPO | 1 h / 15 min |
| Backup type | Full application backup, incremental backup and vendor-supported replication |
| Schedule | Full daily at 02:00; incremental every 4 h; recovery points every 5 min |
| Retention | Recent 30 days; monthly 12 months; annual 7 years |
| Primary destination | Vendor-hosted encrypted DR storage |
| Secondary destination | Geographically separate vendor archive and protected recovery site |
| Encryption at rest | AES-256; vendor KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ |
| Integrity verification | SHA-256 or equivalent vendor integrity checks and monthly application restore |
| Restoration sequence | Network, identity, database, Epic application and clinical interfaces |
| Responsible role | Clinical Applications Manager executes with vendor; clinical lead verifies |

**Current state**

- Vendor replication every 15 minutes.
- Nightly export.
- Vendor-hosted DR site.
- Vendor cold archive.
- Monthly vendor restore certificate.

**Proposed improvement**

Reduce the recovery-point interval to five minutes,
subject to vendor approval and technical feasibility.

Verify that the vendor recovery site is geographically
separate and meets the hospital's recovery requirements.

The restoration test must confirm:

- Patient chart access.
- Medication and allergy information.
- Clinical documentation.
- Order entry.
- Laboratory results.
- Pharmacy and radiology interfaces.

A vendor restore certificate does not replace the need
to validate local clinical workflows.

### 4. Pharmacy Dispensing System

| Field | Specification |
| --- | --- |
| Tier | 1 |
| RTO / RPO | 30 min / 15 min |
| Backup type | Full database backup, incremental backup and application-consistent replication |
| Schedule | Full daily at 01:30; incremental every 4 h; recovery points every 5 min |
| Retention | Recent 30 days; monthly 12 months; annual 7 years |
| Primary destination | On-site encrypted pharmacy backup repository |
| Secondary destination | Geographically separate encrypted cloud backup |
| Encryption at rest | AES-256; KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ |
| Integrity verification | SHA-256 and monthly medication-workflow restore |
| Restoration sequence | Network, identity, database, pharmacy application and dispensing cabinets |
| Responsible role | Pharmacy IT Lead executes; Pharmacy Operations Lead verifies |

**Current state**

- Database backup every hour.
- Cabinet configuration export daily.
- Pharmacy backup share.
- Encrypted cloud copy.
- Weekly hash verification.

**Proposed improvement**

Introduce five-minute application-consistent recovery points.

Confirm that the cloud backup copy is geographically separate.

After restoration, verify:

- Medication orders.
- Allergy checking.
- Drug interaction checking.
- Dispensing cabinet connectivity.
- Controlled-substance records.
- Medication inventory.

Paper records and manual dispensing transactions must
be reconciled after recovery.

### 5. Medical Device Integration Gateway

| Field | Specification |
| --- | --- |
| Tier | 1 |
| RTO / RPO | 30 min / 5 min |
| Backup type | Full configuration export, change export and near-real-time data replication |
| Schedule | Full daily at 02:30; changes after updates; recovery points every 1 min |
| Retention | Recent 30 days; monthly 12 months; annual 7 years where applicable |
| Primary destination | On-site encrypted biomedical backup repository |
| Secondary destination | New geographically separate encrypted cloud repository |
| Encryption at rest | AES-256; KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ |
| Integrity verification | SHA-256, monthly readiness checks and quarterly full restore |
| Restoration sequence | Network, clinical VLANs, gateway, device feeds and alarm routing |
| Responsible role | Biomedical IT Lead executes; ICU/Nursing representative verifies |

**Current state**

- Daily configuration export.
- Biomed file share.
- No secondary destination.
- Manual file existence check.
- No documented restore test.

**Proposed improvement**

Create an encrypted off-site backup copy immediately.

Introduce one-minute recovery points for recoverable
gateway data where vendor-supported.

Maintain a preconfigured standby gateway to support
the proposed 30-minute RTO.

Recovery verification must include:

- Medical device connectivity.
- Bedside data collection.
- Automatic charting.
- Alarm routing.
- ICU and telemetry workflows.

The five-minute RPO must be validated against the
actual data stored by the gateway.

### 6. Laboratory Information System

| Field | Specification |
| --- | --- |
| Tier | 2 |
| RTO / RPO | 30 min / 1 h |
| Backup type | Full SQL backup, incremental backup and transaction-log backup or equivalent |
| Schedule | Full daily at 02:30; incremental every 4 h; recovery points every 15 min |
| Retention | Recent 30 days; monthly 12 months; annual 7 years |
| Primary destination | On-site encrypted backup NAS at `/backup/lis` |
| Secondary destination | CloudVault Medical backup bucket in a separate geographic location |
| Encryption at rest | AES-256; KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ |
| Integrity verification | SHA-256 and daily sample database restore |
| Restoration sequence | Network, identity, database, LIS application, analyzers and Epic interface |
| Responsible role | Laboratory Systems Lead executes; Laboratory Operations Lead verifies |

**Current state**

- Nightly SQL dump at 23:30.
- Gzip compression.
- SHA-256 manifest generation.
- Backup NAS at `/backup/lis`.
- CloudVault Medical backup bucket.
- No documented restore testing.

**Proposed improvement**

Replace the nightly-only recovery strategy with
frequent protected recovery points.

Use transaction-log backups where supported by
the production database engine.

Otherwise, use a vendor-approved method that can
provide application-consistent recovery points
every 15 minutes.

The restore test must verify:

- Database integrity.
- Patient identifiers.
- Laboratory orders.
- Specimen tracking.
- Analyzer results.
- Critical-value notifications.
- Result delivery to Epic.

The practical LIS lab test must measure the actual
recovery time and validate the recovered data.

### 7. PACS/RIS

| Field | Specification |
| --- | --- |
| Tier | 2 |
| RTO / RPO | 1 h / 30 min |
| Backup type | Full metadata backup, incremental image backup and consistent snapshots |
| Schedule | Full daily at 03:00; incremental every 4 h; recovery points every 10 min |
| Retention | Recent 30 days; monthly 12 months; annual 7 years |
| Primary destination | On-site encrypted PACS storage cluster |
| Secondary destination | Geographically separate encrypted cloud object archive |
| Encryption at rest | AES-256; KMS/HSM-managed keys |
| Encryption in transit | TLS 1.2+ |
| Integrity verification | SHA-256 and monthly image/database restore |
| Restoration sequence | Network, identity, image storage, RIS database, PACS and Epic interface |
| Responsible role | Radiology Systems Lead executes; Radiology Clinical Lead verifies |

**Current state**

- Storage snapshots every four hours.
- Metadata export nightly.
- PACS storage cluster.
- Cloud object archive.
- Quarterly restore testing, with the last test missed.

**Proposed improvement**

Introduce ten-minute consistent recovery points.

Ensure images and metadata are recoverable together.

Recovery verification must confirm:

- Patient-to-image association.
- Image availability.
- Previous studies.
- Radiology reports.
- Emergency imaging workflows.
- Epic integration.

The previously missed restore test must be rescheduled
and documented.

### 8. Backup and DR Infrastructure

| Field | Specification |
| --- | --- |
| Tier | 2 |
| RTO / RPO | 2 h / 1 h |
| Backup type | Full catalog backup, incremental backup and catalog replication |
| Schedule | Full daily at 00:00; incremental every 4 h; catalog recovery points every 15 min |
| Retention | Recent 30 days; monthly 12 months; annual 7 years |
| Primary destination | On-site encrypted DR platform storage |
| Secondary destination | Geographically separate immutable encrypted backup account |
| Encryption at rest | AES-256; independently managed KMS/HSM keys |
| Encryption in transit | TLS 1.2+ |
| Integrity verification | SHA-256 and monthly isolated platform restore |
| Restoration sequence | Emergency access, recovery network, catalog, repositories and restore services |
| Responsible role | Infrastructure Manager executes; DR Coordinator verifies |

**Current state**

- Catalog backup every four hours.
- Configuration export daily.
- DR platform storage.
- Isolated backup account.
- Monthly catalog restore testing.
- Backup platform recovery is not timed.

**Proposed improvement**

Introduce 15-minute protected catalog recovery points.

Maintain emergency access credentials and encryption keys
outside the production identity environment.

Verify the geographically separate backup account.

Test restoration of:

- Backup management services.
- Backup catalog.
- Repository connections.
- Encryption-key access.
- Recovery job execution.

The actual platform recovery time must be measured
against the two-hour RTO.

## Full Data Center Loss: Restoration Sequence

### 1. Disaster Scenario

Assume MedDefense loses its entire primary data center.

Possible causes include:

- Major power failure.
- Fire.
- Flooding.
- Infrastructure destruction.
- Severe hardware failure.

Production systems and local backup storage are unavailable.

The recovery team must use the alternate recovery environment
and geographically separate backups.

### 2. Initial Disaster Response

**Step 1: Declare the disaster**

Responsible: Incident Commander / DR Coordinator.

Actions:

1. Confirm the outage and affected systems.
2. Declare the disaster.
3. Activate the disaster recovery plan.
4. Notify hospital leadership and system owners.
5. Activate clinical downtime procedures.
6. Record the disaster declaration time.

**Step 2: Activate the alternate recovery site**

Responsible: Infrastructure Manager.

Actions:

1. Verify alternate-site power and connectivity.
2. Confirm compute and storage availability.
3. Access emergency administrator credentials.
4. Retrieve protected encryption keys.
5. Verify geographically separate backups.
6. Confirm the latest recoverable data timestamps.

The alternate site must be pre-provisioned to support
the short RTO requirements.

### 3. Dependency-Based Restoration Order

| Order | System | Recovery action |
| --- | --- | --- |
| 1 | Network Core | Restore connectivity, routing, VLANs and required security paths |
| 2 | Active Directory | Restore identity, DNS and authentication |
| 3 | Backup and DR Infrastructure | Recover catalogs and backup restore services |
| 4 | Medical Device Gateway | Restore device interfaces and alarm routing |
| 5 | Pharmacy Dispensing | Restore medication verification and dispensing |
| 6 | Epic EHR | Restore patient records, orders and clinical interfaces |
| 7 | LIS | Restore laboratory database, analyzer interfaces and results |
| 8 | PACS/RIS | Restore imaging, metadata and radiology interfaces |

This table represents the logical dependency order,
not a requirement to perform every task sequentially.

Pre-staged recovery services may be activated in parallel
once their dependencies are available.

For example, gateway and pharmacy recovery may proceed
while Epic recovery is underway.

### 4. Detailed Recovery Steps

#### Phase 1: Restore Network Core

Responsible: Network Engineering Lead.

Actions:

1. Activate the alternate-site network.
2. Restore required device configurations.
3. Verify routing and switching.
4. Restore clinical VLAN connectivity.
5. Verify DNS and required security paths.
6. Test communication between recovery components.

Expected RTO: 30 minutes.

#### Phase 2: Restore Active Directory

Responsible: Systems Administrator.

Actions:

1. Activate the recovery domain controller.
2. Verify DNS services.
3. Confirm directory consistency.
4. Test user authentication.
5. Verify required service accounts.
6. Confirm application authentication dependencies.

Expected RTO: 1 hour.

#### Phase 3: Restore Backup and DR Infrastructure

Responsible: Infrastructure Manager.

Actions:

1. Access the emergency backup environment.
2. Restore or activate the backup catalog.
3. Connect geographically separate repositories.
4. Verify encryption-key access.
5. Confirm backup integrity.
6. Start application recovery jobs.

Expected RTO: 2 hours.

For shorter clinical RTOs, critical backup access and
pre-staged recovery infrastructure must already be
available before this phase completes.

#### Phase 4: Restore Medical Device Gateway

Responsible: Biomedical IT Lead.

Actions:

1. Activate the standby gateway.
2. Restore configuration and recoverable data.
3. Connect medical devices.
4. Verify clinical VLAN communication.
5. Test automatic charting.
6. Verify alarm routing with nursing staff.

Expected RTO: 30 minutes.

#### Phase 5: Restore Pharmacy Dispensing

Responsible: Pharmacy IT Lead.

Actions:

1. Activate the standby pharmacy environment.
2. Restore the database to the verified recovery point.
3. Start pharmacy application services.
4. Connect dispensing cabinets.
5. Verify medication and allergy information.
6. Reconcile manual transactions.

Expected RTO: 30 minutes.

#### Phase 6: Restore Epic EHR

Responsible: Clinical Applications Manager.

Actions:

1. Activate vendor-supported recovery services.
2. Verify the recovered clinical database.
3. Start application services.
4. Confirm user authentication.
5. Test patient records and order entry.
6. Verify clinical interfaces.

Expected RTO: 1 hour.

#### Phase 7: Restore LIS

Responsible: Laboratory Systems Lead.

Actions:

1. Restore the laboratory database.
2. Verify database integrity.
3. Start LIS application services.
4. Reconnect analyzer interfaces.
5. Verify critical laboratory results.
6. Confirm result delivery to Epic.

Expected RTO: 30 minutes.

#### Phase 8: Restore PACS/RIS

Responsible: Radiology Systems Lead.

Actions:

1. Restore imaging storage access.
2. Restore RIS database and metadata.
3. Start PACS/RIS services.
4. Verify patient-image associations.
5. Test radiology reports.
6. Confirm Epic integration.

Expected RTO: 1 hour.

### 5. Clinical Recovery Validation

Restoration is not complete simply because a server starts.

The responsible system owner must verify:

- Application availability.
- User authentication.
- Data integrity.
- Patient information accuracy.
- Clinical interface functionality.
- Critical alerts and notifications.
- Actual recovery-point age.
- Actual recovery duration.

Clinical leadership must approve the return of recovered
systems to patient-care use.

### 6. RTO Feasibility

The proposed recovery targets are aggressive.

For example:

- Network Core: 30 minutes.
- Medical Device Gateway: 30 minutes.
- Pharmacy Dispensing: 30 minutes.
- LIS: 30 minutes.

These targets cannot reliably be achieved by rebuilding
the entire environment from scratch after a disaster.

The design therefore requires:

1. Pre-provisioned alternate-site infrastructure.
2. Preconfigured network and identity services.
3. Rapid access to verified recovery points.
4. Preconfigured standby clinical applications.
5. Automated recovery where vendor-supported.
6. Parallel restoration of independent components.
7. Regularly tested failover procedures.

The recovery team must test whether these individual
RTOs can actually be achieved during a complete
data center loss.

### 7. Return to Normal Operations

After recovery:

1. Obtain clinical leadership approval.
2. Reconcile paper records.
3. Verify laboratory and medication data.
4. Confirm backup jobs have resumed.
5. Restore normal security monitoring.
6. Record unresolved issues.
7. Complete the incident report.
8. Conduct a post-incident review.

## Dependency Restore Constraints

### 1. Network Dependency

The Network Core supports:

- Active Directory.
- Epic EHR.
- LIS.
- Pharmacy Dispensing.
- PACS/RIS.
- Medical Device Gateway.
- Backup replication.
- Security monitoring.

Without network connectivity, these systems cannot
communicate reliably.

Therefore, the recovery network must be available
before dependent services can be fully restored.

### 2. Active Directory Dependency

Active Directory provides authentication and
authorization for several hospital systems.

A directory outage may prevent users and service
accounts from accessing clinical applications.

The recovery team must restore identity services
or activate an approved emergency authentication
mechanism before dependent applications are released.

### 3. Backup Infrastructure Dependency

The backup platform requires network access and
may normally depend on Active Directory.

However, the same backup platform may be needed
to restore Active Directory.

This creates a circular dependency.

The proposed architecture resolves it through:

- Independent recovery network access.
- Emergency administrator credentials.
- Protected backup catalogs.
- Separately accessible encryption keys.
- A preconfigured recovery domain controller.
- Backup access that does not require production AD.

### 4. Clinical Application Dependencies

Epic, LIS, PACS/RIS and Pharmacy Dispensing depend
on shared infrastructure.

Recovery must consider:

- Network connectivity.
- Authentication services.
- Databases.
- Application services.
- Clinical interfaces.
- Device connections.

An application is not considered fully restored
until its required clinical functions are verified.

### 5. Medical Device Dependencies

The Medical Device Integration Gateway depends
on the clinical network and connected devices.

Its restoration must include:

- Device communication.
- Data collection.
- Automatic charting.
- Alarm routing.

The gateway must not be released for clinical use
until biomedical IT and nursing representatives
confirm the required functions.

### 6. LIS and Epic Dependency

LIS can restore its database and local laboratory
functions before Epic is fully available.

However, result delivery to Epic requires the
appropriate interface services.

During downtime, approved phone and paper
procedures must support critical-value reporting.

Once Epic is restored, queued results must be
reconciled and verified.

### 7. PACS/RIS Dependency

PACS/RIS requires both image storage and
consistent radiology metadata.

Restoring image files without their corresponding
metadata does not provide complete clinical recovery.

The restoration process must verify:

- Image availability.
- Patient associations.
- Radiology reports.
- Epic ordering and result interfaces.

### 8. Security During Recovery

Security controls must remain in place during
disaster recovery.

The recovery team must:

- Use authorized emergency accounts.
- Encrypt backup transfers.
- Verify backup integrity.
- Record privileged actions.
- Preserve relevant logs.
- Restore security monitoring promptly.
- Review emergency access after recovery.

### 9. Recovery Completion Criteria

A system is considered recovered only when:

1. Required infrastructure is available.
2. Backup integrity verification passes.
3. The application starts successfully.
4. Clinical or technical validation passes.
5. Recovered data is within the approved RPO.
6. Recovery time is within the approved RTO.
7. The responsible system owner approves release.

If the RTO or RPO is exceeded, the failure must be
recorded and investigated.

## Assumptions and Limitations

- This document is a proposed backup architecture.
- The current-state information comes from the provided
  backup schedule and Robert Kim's log review.
- Recovery targets come from the draft BIA.
- Proposed backup intervals are not yet implemented.
- Geographic separation of existing secondary destinations
  requires verification.
- Vendor support for frequent replication must be confirmed.
- Encryption and key management arrangements require testing.
- Backup retention periods require legal and compliance review.
- RPO calculations assume successful capture, transfer
  and verification within the proposed maximum delay.
- A mathematically compliant schedule does not prove
  successful recovery.
- The proposed full data center restoration sequence
  requires a practical exercise.
- No successful RTO or RPO test is claimed in this document.

## Recommended Next Steps

1. Review and approve the proposed RTO and RPO targets.
2. Correct the identified backup-frequency gaps.
3. Add an off-site copy for the Medical Device Gateway.
4. Implement more frequent LIS recovery points.
5. Improve Active Directory recovery-point protection.
6. Verify geographically separate backup storage.
7. Test encryption-key recovery and emergency access.
8. Perform the practical LIS recovery test.
9. Record actual recovery times and data integrity results.
10. Update the architecture using the test evidence.
11. Obtain system-owner and CISO approval.

## References

- `business_impact_analysis.md`
- `backup_architecture/current_backup_schedule.csv`
- `backup_architecture/backup_log_review_findings.md`
- `backup_architecture/dependency_map_seed.md`
- `bia/meddefense_system_inventory.csv`
- `bia/downtime_impact_notes.md`
- `bia/regulatory_reference_map.md`

**Document status:** Draft - Pending Implementation,
Recovery Testing and Approval.
