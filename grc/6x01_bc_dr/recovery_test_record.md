
# LIS Recovery Test Record

**Test date:** 2026-11-11
**Test conductor:** Nishat Sultana Supty
**Declared RTO:** 30 minutes
**Test environment:** `/tmp/meddefense-dr-test/`
**Test status:** Completed

## Test Objective

Restore the Laboratory Information System database
from the provided compressed SQL backup.

Measure the actual recovery time, compare it against
the 30-minute RTO and document all deviations.

## Step Timing Log

The following entries must come directly from
`recovery_test_log.txt`.

```text
[Insert actual step timing entries]
```

## Timer Summary

```text
[Insert actual recovery_timer.sh SUMMARY output]
```

## RTO Comparison

**Declared RTO:** 30 minutes (1,800 seconds)

**Actual recovery time:** [Measured minutes and seconds]

**Difference from RTO:** [Calculated time difference]

**RTO met:** [YES / NO / NOT VERIFIED]

The RTO is met only if the actual measured recovery
duration is 30 minutes or less.

If timing evidence is missing, the RTO result must
be recorded as NOT VERIFIED.

## Conditions Encountered

### Condition 1: Path Mismatch

**Discovered at:** [Actual timestamp]

**Old runbook path:** `/recovery/lis_dump.sql`

**Correct path:**
`/tmp/meddefense-dr-test/recovery/lis_dump.sql`

**Finding:**

The old runbook specified a path that does not
match the current recovery environment.

**Resolution:**

```bash
mkdir -p /tmp/meddefense-dr-test/recovery

gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz \
  > /tmp/meddefense-dr-test/recovery/lis_dump.sql
```

**Time added:** [Measured duration / Not separately measured]

**Outcome:** [Resolved / Unresolved]

### Condition 2: Configuration Artifact

**Discovered at:** [Actual timestamp]

**Expected:** Local SQLite database.

**Actual configuration:**

`DB_HOST=lis-db-prod.meddefense.internal`

**Finding:**

The application configuration contains a
production database hostname.

**Resolution:**

Validated the restored database using:

```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT COUNT(*) FROM patient_orders;"
```

**Time added:** [Measured duration / Not separately measured]

**Outcome:** [Resolved / Unresolved]

### Condition 3: Row Count Validation

**Query:**

```sql
SELECT COUNT(*) FROM patient_orders;
```

**Expected:** 5

**Actual:** [Actual query output]

**Outcome:** [PASS / FAIL]

## Recovery Validation

### Backup Integrity

**Actual SHA-256 result:**

```text
[Actual checksum output]
```

**Outcome:** [PASS / FAIL]

### Recovered Database File

```text
[Actual ls -l output]
```

### Database Integrity

```text
[Actual PRAGMA integrity_check output]
```

### Critical Values Accessible

**Expected:**

```text
MRN-10043|BMP|K+: 6.1 mEq/L|1
MRN-10045|TROPONIN|0.08 ng/mL|1
```

**Actual:**

```text
[Actual critical-results query output]
```

**Outcome:** [PASS / FAIL]

## Test Result

**Actual recovery time:** [Measured duration]

**Declared RTO:** 30 minutes

**RTO met:** [YES / NO / NOT VERIFIED]

**Test outcome:** [PASS / CONDITIONAL PASS / FAIL / INCOMPLETE]

**RPO verification:** Not established by this test
without a verified backup data timestamp.

### Test Outcome Explanation

[Explain the actual result using the timer and
database validation evidence.]

## Lessons Learned

1. The old runbook contains an incorrect staging path.
2. The application configuration contains a production
   database hostname.
3. A successful restore must include row-count and
   critical-result validation.
4. Recovery duration must be recorded using actual
   timestamps.

## Recommended Improvements

1. Correct the staging path in the LIS runbook.
2. Clearly document the local database override.
3. Make data validation mandatory.
4. Preserve step timing and deviation records.
5. Repeat the recovery test after correcting problems.

## Evidence Files

- `recovery_timer.sh`
- `recovery_test_log.txt`
- `recovery_evidence.txt`
- `recovery_deviations.txt`
- `/tmp/meddefense-dr-test/recovery/lis_recovered.db`

**Review status:** Pending supervisor review.
