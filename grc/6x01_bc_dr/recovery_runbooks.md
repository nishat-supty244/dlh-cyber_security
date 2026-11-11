
# MedDefense Recovery Runbooks

**Version:** 1.0  
**Classification:** Confidential  
**Prepared by:** Nishat Sultana Supty  
**Date:** 2026-11-11  
**Status:** Draft - Pending Recovery Testing and Approval

## Purpose

This document provides step-by-step recovery instructions
for two critical MedDefense systems:

1. Laboratory Information System (LIS).
2. Active Directory (AD).

Each procedure includes:

- Command or action.
- Expected output.
- Verification check.
- Deviation handling.

The objective is to help administrators recover systems
during an incident without relying on incomplete instructions.

The LIS procedure is designed for the rebuilt Linux-based
SQLite recovery lab.

The Active Directory procedure is documentation-only
because the student lab does not provide Windows domain
controllers.

## General Recovery Rules

Before starting recovery:

1. Confirm the incident and affected system.
2. Record the recovery start time.
3. Identify the responsible administrator.
4. Confirm the latest usable backup.
5. Preserve original backup files.
6. Record all commands and results.
7. Report unexpected errors immediately.
8. Do not declare recovery successful without validation.

A successful command does not automatically mean the
application has been recovered.

## Runbook 1: Laboratory Information System Recovery

### 1. Recovery Information

| Field | Value |
| --- | --- |
| System | Laboratory Information System |
| Recovery environment | Linux / SQLite simulation |
| Responsible role | Laboratory Systems Lead |
| Verification role | Laboratory Operations Lead |
| RTO | 30 minutes |
| RPO | 1 hour |
| Backup date | 2026-04-21 |
| Expected patient orders | 5 |
| Recovery status | Not yet tested |

The LIS RTO and RPO come from the draft BIA.

The 30-minute RTO is also specified in the lab
configuration.

### 2. Lab File Locations

| Item | Location |
| --- | --- |
| Workspace | `/tmp/meddefense-dr-test` |
| Backup | `/tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz` |
| Manifest | `/tmp/meddefense-dr-test/backup/lis/2026-04-21/backup_manifest.sha256` |
| Recovery directory | `/tmp/meddefense-dr-test/recovery` |
| Staged SQL | `/tmp/meddefense-dr-test/recovery/lis_dump.sql` |
| Recovered database | `/tmp/meddefense-dr-test/recovery/lis_recovered.db` |
| Application config | `/tmp/meddefense-dr-test/config/app_config.env` |

The paths come from the provided recovery instructions
and `lab_config.env`.

### Step 1: Start Recovery and Identify the Backup

**Command or action**

Record the start time:

```bash
date -u '+%Y-%m-%dT%H:%M:%SZ'
```

Check the available backup directories:

```bash
ls -l /tmp/meddefense-dr-test/backup/lis/
```

Inspect the required backup:

```bash
ls -lh /tmp/meddefense-dr-test/backup/lis/2026-04-21/
```

**Expected output**

The backup directory contains:

```text
lis_backup.sql.gz
backup_manifest.sha256
```

The files should have nonzero sizes.

**Verification check**

Confirm that the selected backup date is
`2026-04-21`, as specified in the lab configuration.

Check that the backup and manifest are present.

This establishes the configured recovery target,
not the actual age of the data inside the backup.

**Deviation handling**

If the backup directory or files are missing:

1. Check the configured backup path.
2. Do not invent or substitute a backup date.
3. Notify the recovery coordinator.
4. Record the missing-file error.
5. Stop until an approved recovery source is identified.

### Step 2: Verify Backup Integrity

**Command or action**

Change to the backup directory:

```bash
cd /tmp/meddefense-dr-test/backup/lis/2026-04-21
```

Inspect the manifest:

```bash
cat backup_manifest.sha256
```

Run the integrity check:

```bash
sha256sum -c backup_manifest.sha256
```

**Expected output**

For a valid manifest containing the backup filename:

```text
lis_backup.sql.gz: OK
```

**Verification check**

Confirm that the command exits successfully
and that the backup is marked `OK`.

The hash must match the manifest.

**Deviation handling**

If the output contains:

```text
FAILED
```

or the command reports a missing file:

1. Stop recovery using that backup.
2. Preserve the failed backup and manifest.
3. Record the exact error.
4. Notify the Infrastructure Manager.
5. Select another approved, verified backup if available.

Do not restore a backup that failed integrity verification.

A matching hash confirms agreement with the manifest,
not that the SQL data is logically correct.

### Step 3: Create the Recovery Workspace

**Command or action**

Create the recovery directory:

```bash
mkdir -p /tmp/meddefense-dr-test/recovery
```

Verify it exists:

```bash
ls -ld /tmp/meddefense-dr-test/recovery
```

**Expected output**

A directory listing similar to:

```text
drwxr-xr-x ... /tmp/meddefense-dr-test/recovery
```

**Verification check**

Confirm the directory exists and is writable.

```bash
test -w /tmp/meddefense-dr-test/recovery && echo "Writable"
```

Expected:

```text
Writable
```

**Deviation handling**

If permission is denied:

1. Confirm the current user and directory permissions.
2. Do not change unrelated system permissions.
3. Request approved access.
4. Record the error and elapsed time.

Before restoring, inspect whether a recovery database
already exists:

```bash
ls -l /tmp/meddefense-dr-test/recovery/
```

Do not overwrite an existing recovery database
without preserving it and obtaining approval.

### Step 4: Decompress the SQL Backup

**Known deviation from the old runbook**

The outdated runbook refers to:

```text
/recovery/lis_dump.sql
```

This path is incorrect for the rebuilt lab.

The correct staging path is:

```text
/tmp/meddefense-dr-test/recovery/lis_dump.sql
```

**Command or action**

First verify the compressed file structure:

```bash
gzip -t /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz
```

Then decompress it:

```bash
gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz > /tmp/meddefense-dr-test/recovery/lis_dump.sql
```

**Expected output**

Both commands normally finish without output.

**Verification check**

Confirm that the staged SQL file exists:

```bash
ls -lh /tmp/meddefense-dr-test/recovery/lis_dump.sql
```

Check that it contains data:

```bash
test -s /tmp/meddefense-dr-test/recovery/lis_dump.sql && echo "SQL staging file ready"
```

Expected:

```text
SQL staging file ready
```

**Deviation handling**

If the old path produces:

```text
No such file or directory
```

use the corrected staging path above.

If decompression fails:

1. Stop the restore.
2. Check the gzip integrity result.
3. Confirm available disk space.
4. Record the exact error.
5. Do not use a partially decompressed SQL file.

### Step 5: Restore the SQL Dump into SQLite

**Command or action**

Confirm that SQLite is available:

```bash
sqlite3 --version
```

**Expected output**

A SQLite version number.

Next, verify that the recovery target does not
already contain a database that must be preserved.

```bash
ls -l /tmp/meddefense-dr-test/recovery/lis_recovered.db
```

If the file does not exist, the expected message is:

```text
No such file or directory
```

For a new, approved recovery target, restore the SQL:

```bash
sqlite3 -bail /tmp/meddefense-dr-test/recovery/lis_recovered.db < /tmp/meddefense-dr-test/recovery/lis_dump.sql
```

**Expected output**

A successful SQL import normally produces no output.

**Verification check**

Confirm that the database was created:

```bash
ls -lh /tmp/meddefense-dr-test/recovery/lis_recovered.db
```

Check SQLite integrity:

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "PRAGMA integrity_check;"
```

Expected:

```text
ok
```

**Deviation handling**

If SQLite reports:

```text
Error: ...
```

1. Stop the recovery procedure.
2. Preserve the error message.
3. Inspect the SQL staging file.
4. Confirm the target is the correct recovery database.
5. Do not import repeatedly into a partially restored database.
6. Obtain approval before restarting with a clean target.

The `-bail` option stops processing after a SQL error.

### Step 6: Verify Patient Order Count

**Command or action**

Run:

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT COUNT(*) FROM patient_orders;"
```

**Expected output**

```text
5
```

**Verification check**

The restored `patient_orders` table must contain
exactly five records for the supplied test dataset.

**Deviation handling**

If the result is not `5`:

1. Do not declare recovery successful.
2. Record the actual row count.
3. Confirm the correct database was restored.
4. Review the SQL import for errors.
5. Notify the Laboratory Systems Lead.

A successful row-count check does not replace
critical-result validation.

### Step 7: Confirm Critical Laboratory Results

Two critical results must be verified:

- `MRN-10043`
- `MRN-10045`

**Command or action**

Inspect the table structure:

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db ".schema patient_orders"
```

Then display the patient orders:

```bash
sqlite3 -separator '|' /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT * FROM patient_orders;"
```

Inspect the returned records for the required MRNs.

**Expected output**

The provided command-output examples specify these
critical-result records:

```text
MRN-10043|BMP|K+: 6.1 mEq/L|1
MRN-10045|TROPONIN|0.08 ng/mL|1
```

The final value `1` is part of the supplied expected
record output.

The complete table may contain additional records.

**Verification check**

Confirm both records are present and match the
expected values:

| MRN | Test | Expected result |
| --- | --- | --- |
| MRN-10043 | BMP | K+: 6.1 mEq/L |
| MRN-10045 | TROPONIN | 0.08 ng/mL |

Verify the actual table column names and meanings
using the schema before interpreting any status field.

**Deviation handling**

If either MRN is missing or the result differs:

1. Stop clinical release.
2. Record the observed value.
3. Verify the restored database and backup date.
4. Notify the Laboratory Operations Lead.
5. Investigate before approving recovery.

Do not manually change critical-result values
to make the test pass.

### Step 8: Inspect Application Configuration

**Command or action**

Display the configuration:

```bash
cat /tmp/meddefense-dr-test/config/app_config.env
```

**Expected output**

The supplied configuration includes:

```text
APP_ENV=recovery-test
APP_NAME=meddefense-lis
DB_HOST=lis-db-prod.meddefense.internal
DB_NAME=lis_production
RECOVERY_DB_PATH=/tmp/meddefense-dr-test/recovery/lis_recovered.db
HEALTHCHECK_QUERY=SELECT COUNT(*) FROM patient_orders;
```

**Verification check**

Identify:

```text
DB_HOST=lis-db-prod.meddefense.internal
```

This is a production-host configuration artifact.

It is not the local SQLite recovery database.

Also confirm:

```text
RECOVERY_DB_PATH=/tmp/meddefense-dr-test/recovery/lis_recovered.db
```

**Deviation handling**

Do not connect the recovery validation to
`lis-db-prod.meddefense.internal`.

Do not overwrite the original application configuration.

If the recovery path differs from the lab configuration,
stop and confirm the approved target.

### Step 9: Apply the Local Recovery Override

**Purpose**

Validate the restored database using its local SQLite
file path instead of the production database host.

The override applies to the validation command.
It does not modify the original configuration file.

**Command or action**

Run the local health check:

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT COUNT(*) FROM patient_orders;"
```

**Expected output**

```text
5
```

**Verification check**

Confirm that:

1. The command uses the local recovery database.
2. It does not connect to the production host.
3. The query completes without errors.
4. The expected row count is returned.
5. The critical-result checks from Step 7 pass.

**Deviation handling**

If the command cannot open the database:

1. Confirm the database path.
2. Confirm file permissions.
3. Verify the SQL import completed.
4. Recheck database integrity.
5. Record the error.

Do not mark the application as fully operational
based only on a SQLite query.

The rebuilt lab validates the recovered database.
It does not demonstrate restoration of a complete
production LIS application or analyzer interfaces.

### Step 10: Record Recovery Time and RPO Evidence

**Command or action**

Record the completion time:

```bash
date -u '+%Y-%m-%dT%H:%M:%SZ'
```

Calculate elapsed time using the recorded start
and completion timestamps.

The target RTO is 30 minutes.

**Expected output**

A UTC timestamp.

**Verification check**

Record:

- Recovery start time.
- Recovery completion time.
- Total elapsed minutes.
- Backup date.
- Latest verified data timestamp, if available.
- Integrity check result.
- Patient order count.
- Critical-result verification result.

The backup date alone does not establish the
actual recovery-point age.

**Deviation handling**

If elapsed recovery time exceeds 30 minutes,
record an RTO failure.

If the latest recoverable data timestamp is unknown,
record RPO compliance as unverified.

Do not claim that the one-hour RPO was achieved
solely because the database import succeeded.

### Step 11: Notify the Clinical Team

**Action**

Prepare a recovery notification for the
Laboratory Operations Lead and clinical stakeholders.

**Notification template**

```text
Subject: LIS Recovery Validation Update

System: Laboratory Information System
Recovery environment: SQLite recovery lab
Recovery start: [UTC timestamp]
Recovery completion: [UTC timestamp]
Elapsed recovery time: [minutes]

Backup date: 2026-04-21
Backup integrity: [Pass/Fail]
Database integrity: [Pass/Fail]
Patient orders: [Actual count]
MRN-10043: [Verified/Not verified]
MRN-10045: [Verified/Not verified]

RTO result: [Met/Exceeded/Not measured]
RPO result: [Met/Exceeded/Unverified]

Known issues: [Details]
Clinical release approval: [Pending/Approved]

Responsible administrator: [Name or role]
```

**Expected output**

A complete notification containing the actual
recovery results.

**Verification check**

Confirm that the notification:

- Identifies the restored environment.
- Includes the actual validation results.
- Reports any remaining limitations.
- Does not claim production restoration.
- Identifies whether clinical approval is pending.

**Deviation handling**

If validation is incomplete, clearly state:

```text
Recovery validation incomplete.
Clinical release not approved.
```

Do not send a successful recovery declaration
before the required checks pass.

### LIS Recovery Completion Criteria

The LIS lab recovery can be marked successful only when:

1. The selected backup passes SHA-256 verification.
2. The SQL file decompresses successfully.
3. SQLite import completes without errors.
4. Database integrity check returns `ok`.
5. `patient_orders` contains five records.
6. Both specified critical results match.
7. Local database validation succeeds.
8. Actual recovery time is recorded.
9. Any deviations are documented.

RTO and RPO compliance must be assessed separately.

Clinical release requires additional production-level
application and interface validation.

---

## Runbook 2: Active Directory Recovery

### 1. Recovery Information

| Field | Value |
| --- | --- |
| System | Active Directory |
| Domain | meddefense.local |
| Failed controller | DC01 |
| Healthy controller | DC02 |
| Scenario | DC01 confirmed unrecoverable |
| RTO | 1 hour |
| RPO | 15 minutes |
| Backup location | `\\backup-srv\ad-backups\DC01\` |
| Responsible role | Systems Administrator |
| Verification role | Infrastructure Manager |
| Execution environment | Windows Server |
| Lab status | Documentation-only |

### 2. Scenario and Assumptions

The administrator has confirmed:

- DC01 is unrecoverable.
- DC02 is healthy and responding.
- The domain is still available through DC02.
- DC01 normally holds FSMO roles.
- A system-state backup of DC01 is available.

The administrator must preserve the healthy DC02
and avoid introducing replication inconsistencies.

The supplied command-output examples describe
DC01 in a healthy state.

Those outputs are reference examples, not evidence
that DC01 is currently operational.

### Step 1: Document FSMO Role Holders

**Command or action**

Run from an elevated Windows command prompt
on a healthy domain-joined administrator workstation
or DC02:

```cmd
netdom query fsmo
```

**Expected output**

The supplied example is:

```text
Schema master               DC01.meddefense.local
Domain naming master        DC01.meddefense.local
PDC                         DC01.meddefense.local
RID pool manager            DC01.meddefense.local
Infrastructure master       DC01.meddefense.local
The command completed successfully.
```

**Verification check**

Record the current holders of:

1. Schema Master.
2. Domain Naming Master.
3. PDC Emulator.
4. RID Master.
5. Infrastructure Master.

The example indicates that DC01 holds all five roles.

Because DC01 is unrecoverable, the administrator must
confirm the live role-holder state before proceeding.

**Deviation handling**

If the command fails:

1. Confirm DC02 is reachable.
2. Verify DNS and domain connectivity.
3. Confirm administrator privileges.
4. Record the error.
5. Escalate before making FSMO changes.

If DC01 still holds critical FSMO roles and will
not return, arrange approved FSMO role seizure to DC02.

For example, an authorized administrator may use
the supported Windows PowerShell command:

```powershell
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole SchemaMaster,DomainNamingMaster,PDCEmulator,RIDMaster,InfrastructureMaster -Force
```

This is a proposed recovery action, not a command
shown in the supplied example file.

It must only be performed after confirming that
DC01 is permanently unavailable and obtaining
the required approval.

After seizure, do not reconnect the old DC01
to the domain.

### Step 2: Decide Authoritative or Non-Authoritative Recovery

**Command or action**

Evaluate the state of DC02 and the recovery objective.

Use the following decision criteria.

| Condition | Recovery decision |
| --- | --- |
| DC02 contains healthy, current directory data | Non-authoritative recovery or replacement DC |
| Specific AD objects were deleted or corrupted and must override replicated copies | Consider authoritative restore |
| DC01 permanently lost but DC02 healthy | Prefer replacement DC and replication from DC02 |
| Directory-wide corruption or conflicting copies | Stop and escalate for specialist recovery planning |

**Expected outcome**

For this scenario:

```text
DC01 unrecoverable.
DC02 healthy.
Healthy DC02 remains the directory source.
Authoritative restore is not required.
```

**Verification check**

Confirm that DC02:

- Responds to authentication requests.
- Contains the required directory information.
- Has healthy DNS and SYSVOL services.
- Has no known directory corruption.

**Deviation handling**

If DC02 is unhealthy or contains corrupted data:

1. Stop the standard recovery sequence.
2. Preserve available logs and backups.
3. Escalate to the AD recovery specialist.
4. Reassess whether authoritative restoration
   is required.

Do not perform an authoritative restore simply
because DC01 is unavailable.

### Step 3: System-State Recovery Command Sequence

**Important safety decision**

Because DC01 is confirmed unrecoverable and DC02
is healthy, the preferred operational approach is
to remove the failed DC01 from the domain metadata,
transfer or seize necessary FSMO roles, and build
a replacement domain controller that replicates
from DC02.

A system-state restore of the old DC01 is not
automatically required.

The following `wbadmin` procedure is documented
because the assignment requires it.

It applies only when a supported system-state
recovery has been explicitly approved for a
suitable Windows recovery target.

Do not run it against healthy DC02.

**Command or action**

Confirm the available backup versions:

```cmd
wbadmin get versions -backuptarget:\\backup-srv\ad-backups\DC01
```

**Expected output**

The available backup list should include the
selected recovery version:

```text
04/21/2026-01:00
```

The exact output format must be confirmed
on the Windows recovery host.

Run the provided system-state recovery command
only on the approved recovery target:

```cmd
wbadmin start systemstaterecovery -version:04/21/2026-01:00 -backuptarget:\\backup-srv\ad-backups\DC01 -quiet
```

**Expected output**

Windows Server Backup should start the selected
system-state recovery operation.

The command-output examples provide the command
pattern but not a completed recovery transcript.

A successful completion message must be observed
during a real recovery before success is recorded.

**Verification check**

Confirm:

1. The correct backup version was selected.
2. The backup target is accessible.
3. The recovery is running on the approved server.
4. The recovery operation completes successfully.
5. Windows event logs show no relevant restore errors.

A domain controller restored from backup must
follow Microsoft's supported AD DS recovery
procedures before rejoining normal replication.

**Deviation handling**

If the backup cannot be found:

1. Verify the UNC backup path.
2. Confirm network access.
3. Check backup permissions.
4. Select another approved backup version.
5. Record the failure.

If the recovery fails:

1. Do not repeatedly attempt unsafe restoration.
2. Preserve the recovery logs.
3. Escalate to the Infrastructure Manager.
4. Continue using healthy DC02 where possible.

**USN rollback warning**

Improperly restoring an old domain controller
snapshot or unsupported system state can create
USN rollback and replication inconsistencies.

Do not return an improperly restored DC01
to the production domain.

If DC01 has been permanently retired after FSMO
seizure, use a properly built replacement controller
rather than reconnecting the old DC01 instance.

### Step 4: Verify Active Directory Replication

**Command or action**

Run on the healthy DC02:

```cmd
repadmin /showrepl DC02
```

For a newly restored or replacement domain controller,
also run the command against that controller after
it is safely introduced to the domain.

**Expected output**

The supplied healthy example is:

```text
Default-First-Site-Name\DC01
==== INBOUND NEIGHBORS ======================================
DC=meddefense,DC=local
    Default-First-Site-Name\DC02 via RPC
        Last attempt @ 2026-04-21 09:42:13 was successful.
```

This is a historical example for DC01.

It must not be treated as expected live output
while DC01 remains unavailable.

For DC02, inspect the actual replication neighbors
and confirm successful attempts for any available
healthy replication partners.

**Verification check**

Confirm:

- No unexpected replication errors.
- No USN rollback warnings.
- No replication quarantine.
- Replication partners are correctly identified.
- The replacement controller, if deployed,
  receives updates from DC02.

A single surviving domain controller may have
no available inbound replication partner.

That condition must be interpreted in the context
of the confirmed DC01 loss, not automatically
treated as a successful replication test.

**Deviation handling**

If replication errors appear:

1. Record the exact error code.
2. Verify network and DNS connectivity.
3. Check the controller's replication status.
4. Investigate directory consistency.
5. Do not declare full AD redundancy restored.

### Step 5: Validate Active Directory with DCDIAG

**Command or action**

Run from an elevated Windows command prompt:

```cmd
dcdiag /s:DC02 /test:Connectivity
```

Then:

```cmd
dcdiag /s:DC02 /test:SysVolCheck
```

Then:

```cmd
dcdiag /s:DC02 /test:NetLogons
```

Finally, run the broader diagnostic:

```cmd
dcdiag /s:DC02 /v
```

**Expected output**

The supplied healthy example is:

```text
Testing server: Default-First-Site-Name\DC01
Starting test: Connectivity
......................... DC01 passed test Connectivity
Starting test: SysVolCheck
......................... DC01 passed test SysVolCheck
Starting test: NetLogons
......................... DC01 passed test NetLogons
```

This illustrates the expected pass format.

For this recovery scenario, the administrator
must see equivalent successful results for DC02.

**Verification check**

Confirm DC02 passes:

- Connectivity.
- SysVolCheck.
- NetLogons.

Review the full diagnostic output for additional
errors affecting DNS, replication or directory services.

If a replacement controller has been deployed,
repeat the relevant diagnostics against it.

**Deviation handling**

If a test fails:

1. Record the failed test.
2. Review Windows Event Viewer.
3. Check DNS and network connectivity.
4. Verify SYSVOL and NETLOGON availability.
5. Investigate the failure before declaring recovery.

Do not ignore failed tests because some other
diagnostics passed.

### Step 6: Validate Authentication and FSMO State

**Command or action**

Confirm FSMO role ownership:

```cmd
netdom query fsmo
```

Check domain controller discovery:

```cmd
nltest /dsgetdc:meddefense.local
```

Check SYSVOL and NETLOGON shares on DC02:

```cmd
net view \\DC02
```

**Expected output**

FSMO roles should be held by available,
healthy domain controllers.

Domain controller discovery should return
an available controller.

The share listing should include SYSVOL
and NETLOGON where those services are healthy.

**Verification check**

Confirm:

1. DC02 is discoverable.
2. Required FSMO roles have valid holders.
3. DNS resolution works.
4. SYSVOL and NETLOGON are available.
5. Authorized users can authenticate.
6. Critical application service accounts work.

**Deviation handling**

If authentication or discovery fails:

1. Check DNS.
2. Check time synchronization.
3. Check network connectivity.
4. Check domain controller service health.
5. Escalate before releasing dependent applications.

### Step 7: Recovery Declaration

**Command or action**

Review the recovery evidence and document the result.

**Recovery declaration criteria**

Active Directory service recovery may be declared
when all the following are satisfied:

1. DC02 remains healthy.
2. Required FSMO roles have available holders.
3. DNS and authentication work.
4. SYSVOL and NETLOGON checks pass.
5. DCDIAG shows no unresolved critical failures.
6. Replication status is consistent with the
   current controller topology.
7. Critical application authentication is verified.
8. Recovery time is recorded.
9. Any remaining loss of redundancy is documented.

If only DC02 is operational, domain service
availability may be restored while domain
controller redundancy remains degraded.

Full infrastructure recovery requires the
approved replacement controller to be deployed
and validated.

**Expected output**

A documented recovery decision:

```text
System: Active Directory
Domain: meddefense.local

DC01 status: Unrecoverable
DC02 status: [Healthy/Unhealthy]

FSMO roles: [Verified/Not verified]
Authentication: [Pass/Fail]
DNS: [Pass/Fail]
SYSVOL: [Pass/Fail]
NETLOGON: [Pass/Fail]
Replication: [Pass/Fail/Not applicable]
DCDIAG: [Pass/Fail]

Service recovery: [Confirmed/Not confirmed]
Redundancy: [Restored/Degraded]
RTO: [Met/Exceeded/Not measured]
RPO: [Met/Exceeded/Unverified]

Approved by: [Responsible role]
Date and time: [UTC timestamp]
```

**Verification check**

The Infrastructure Manager must review the
recorded evidence before approving recovery.

**Deviation handling**

If any critical validation fails:

1. Keep the incident open.
2. Continue operating through healthy DC02
   if safe and authorized.
3. Document remaining service limitations.
4. Escalate unresolved problems.
5. Do not claim full recovery.

### Active Directory Recovery Completion Criteria

The AD service recovery can be declared when:

- DC02 provides healthy domain services.
- FSMO ownership is documented and corrected if necessary.
- Authentication and DNS function correctly.
- SYSVOL and NETLOGON checks pass.
- Required diagnostic checks succeed.
- No unsafe restored DC is introduced.
- The recovery decision is approved.

Restoration of full domain controller redundancy
is a separate completion requirement.

The one-hour RTO and 15-minute RPO must be
measured and validated independently.

## Recovery Evidence and Deviation Log

For both runbooks, the administrator must maintain
a recovery record.

| Field | Required information |
| --- | --- |
| Incident ID | Unique incident reference |
| System | LIS or Active Directory |
| Administrator | Person executing recovery |
| Start time | UTC timestamp |
| End time | UTC timestamp |
| Backup version | Date and recovery-point identifier |
| Commands executed | Commands and relevant outputs |
| Verification | Checks performed and actual results |
| Deviations | Errors, incorrect paths or missing data |
| Corrective action | Action taken to resolve each deviation |
| RTO result | Met, exceeded or not measured |
| RPO result | Met, exceeded or unverified |
| Approval | Responsible reviewer and time |

### Example Deviation Entry

```text
Deviation ID: LIS-DEV-001

Issue:
Old runbook specifies /recovery/lis_dump.sql.

Expected lab path:
/tmp/meddefense-dr-test/recovery/lis_dump.sql

Corrective action:
Used the recovery path from lab_config.env.

Impact:
No change to the original compressed backup.

Actual occurrence:
To be confirmed during the recovery test.

Status:
Known runbook correction.
```

This is a documented expected deviation.
It must not be presented as an error that was
actually encountered unless the test confirms it.

## Final Recovery Checklist

### Laboratory Information System

- [ ] Correct backup identified
- [ ] SHA-256 verification passed
- [ ] Recovery workspace created
- [ ] SQL backup decompressed
- [ ] SQLite database restored
- [ ] Database integrity verified
- [ ] Five patient orders confirmed
- [ ] MRN-10043 result verified
- [ ] MRN-10045 result verified
- [ ] Production DB_HOST artifact identified
- [ ] Local recovery database validated
- [ ] Recovery duration recorded
- [ ] RPO evidence assessed
- [ ] Clinical notification prepared
- [ ] Recovery approved

### Active Directory

- [ ] DC01 unrecoverable status confirmed
- [ ] DC02 health confirmed
- [ ] FSMO role holders documented
- [ ] Restore decision documented
- [ ] System-state recovery path evaluated
- [ ] Replication health checked
- [ ] DCDIAG completed
- [ ] DNS and authentication validated
- [ ] SYSVOL and NETLOGON verified
- [ ] Recovery duration recorded
- [ ] RPO evidence assessed
- [ ] Remaining redundancy gap documented
- [ ] Recovery declaration approved

## Assumptions and Limitations

- The LIS runbook is designed for the provided SQLite lab.
- The actual LIS recovery test has not yet been performed.
- The expected row count is five.
- The two critical-result values come from the supplied
  command-output examples.
- The old LIS recovery path is known to be incorrect.
- The production database hostname must not be used
  for local SQLite validation.
- The Active Directory runbook is documentation-only.
- Windows commands cannot be executed in the Linux lab.
- The supplied AD outputs are examples, not actual
  results from a recovery exercise.
- DC02 is assumed healthy as required by the scenario.
- A permanently lost DC01 should not be reintroduced
  through an unsafe snapshot or unsupported restore.
- System-state recovery requires an approved, supported
  Windows recovery environment.
- No successful RTO or RPO achievement is claimed
  before validation.

## References

- `runbooks/old_lis_recovery_runbook.md`
- `runbooks/old_ad_recovery_notes.md`
- `runbooks/command_output_examples.md`
- `recovery_test/lab_config.env`
- `recovery_test/app_config.env`
- `business_impact_analysis.md`
- `backup_architecture.md`

**Document status:** Draft - Pending LIS Recovery Test
and Active Directory Procedure Review.
