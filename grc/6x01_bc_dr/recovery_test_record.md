
# LIS Recovery Test Record

**Test date:** [Actual test date]  
**Test conductor:** Nishat Sultana Supty  
**Declared RTO:** 30 minutes  
**Test environment:** `/tmp/meddefense-dr-test/`  
**Test status:** Pending final review

## Test Objective

Restore the Laboratory Information System database from
the supplied compressed SQL backup into a local SQLite
database.

Measure the actual recovery duration, verify the restored
patient data and document deviations from the old runbook.

## Step Timing Log

Paste the complete contents of `recovery_test_log.txt`
below after running the recovery.

```text
[Paste actual step timing log]
```

### Timer Summary

```text
[Paste actual output from ./recovery_timer.sh SUMMARY]
```

## Conditions Encountered

### Condition 1: Path Mismatch

**Discovered at:** [Actual timestamp]

**Runbook specified:**

`/recovery/lis_dump.sql`

**Actual path:**

`/tmp/meddefense-dr-test/recovery/lis_dump.sql`

**Problem:**

The old runbook used an outdated recovery path that
does not match the rebuilt SQLite lab.

**Resolution:**

```bash
mkdir -p /tmp/meddefense-dr-test/recovery

gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz \
  > /tmp/meddefense-dr-test/recovery/lis_dump.sql
```

**Time added:** [Measured minutes and seconds]

**Outcome:** [Resolved / Unresolved]

### Condition 2: Configuration Artifact

**Discovered at:** [Actual timestamp]

**Expected:** Local SQLite recovery database.

**Actual configuration:**

`DB_HOST=lis-db-prod.meddefense.internal`

**Problem:**

The application configuration still contains the
production database hostname.

This is not the correct target for the SQLite lab.

**Resolution:**

Used the local recovery database path:

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT COUNT(*) FROM patient_orders;"
```

The original application configuration was not modified.

**Time added:** [Measured minutes and seconds]

**Outcome:** [Resolved / Unresolved]

### Condition 3: Row Count Check

**Query:**

```sql
SELECT COUNT(*) FROM patient_orders;
```

**Expected:** 5

**Actual:** [Paste exact result]

**Outcome:** [PASS / FAIL]

## Recovery Validation

### Backup Integrity

**Command:**

```bash
sha256sum -c backup_manifest.sha256
```

**Actual output:**

```text
[Paste checksum verification output]
```

**Result:** [PASS / FAIL]

### Recovered Database File

**Command:**

```bash
ls -l /tmp/meddefense-dr-test/recovery/lis_recovered.db
```

**Actual output:**

```text
[Paste actual ls -l output]
```

### Database Integrity

**Command:**

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "PRAGMA integrity_check;"
```

**Actual output:**

```text
[Paste actual output]
```

### Critical Values Accessible

**Command:**

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT patient_mrn, test_code, result_value, critical_flag FROM patient_orders WHERE patient_mrn IN ('MRN-10043','MRN-10045');"
```

**Expected records:**

```text
MRN-10043|BMP|K+: 6.1 mEq/L|1
MRN-10045|TROPONIN|0.08 ng/mL|1
```

**Actual output:**

```text
[Paste actual query output]
```

**Result:** [PASS / FAIL]

## Test Result

**Actual recovery time:** [From timer summary]

**Declared RTO:** 30 minutes

**RTO met:** [YES / NO]

**Test outcome:** [PASS / CONDITIONAL PASS / FAIL]

**RPO verification:** Not established by this restore test
unless a verified backup data timestamp is available.

### Outcome Criteria

- PASS: All required validation checks passed and
  recovery completed within 30 minutes.
- CONDITIONAL PASS: The database was recovered and
  validated, but a documented limitation remains.
- FAIL: Recovery was incomplete, required data checks
  failed, or the 30-minute RTO was exceeded.

## Lessons Learned

1. The old LIS runbook contains an outdated recovery path.
2. The application configuration references a production
   database host rather than the local recovery database.
3. The restored database must be checked for the expected
   patient order count and critical laboratory results.
4. Recovery timing and deviations must be recorded
   during execution, not reconstructed from memory.

## Recommended Improvements

1. Update the LIS runbook with the correct staging path.
2. Document the local database validation override.
3. Include mandatory row-count and critical-result checks.
4. Keep an accurate timing log for future recovery tests.
5. Retest after correcting any issues discovered.

## Evidence Files

- `recovery_timer.sh`
- `recovery_test_log.txt`
- `recovery_deviations.txt`
- `recovery_test_record.md`
- `/tmp/meddefense-dr-test/recovery/lis_recovered.db`

**Review status:** Pending supervisor review.
