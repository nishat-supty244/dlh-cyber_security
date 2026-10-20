
# Rule Validation Report

**Organization:** MedDefense
**Incident ID:** IR-2026-0414-01
**Forensic Case:** LH-2026-0414-01
**Validation Date:** 2026-10-20

## 1. Objective

Validate the Sigma detection rules developed in Tasks 3 and 4
against the provided incident and clean Sysmon logs.

The purpose is to confirm that the rules:

- Detect known malicious activity.
- Produce minimal false positives on legitimate activity.
- Meet the false positive threshold of less than 0.1%.
- Can be tuned before production deployment.

## 2. Test Data

Two Sysmon JSONL files were provided:

| File | Total Events | Description |
|---|---:|---|
| incident_sysmon.jsonl | 17 | Sysmon events from compromised workstations WST-WS-031 and WST-WS-017 |
| clean_sysmon.jsonl | 21 | Normal workstation events, including legitimate development activity |

The files are small lab samples rather than full production
log collections.

### Validation Formula

Match Rate (%) = (Matched Events / Total Events) × 100

Target false positive rate: less than 0.1%.

## 3. Rule 1: PowerShell MSBuild LOLBin Execution

**Rule File:** sigma_powershell_msbuild_lolbin.yml

**MITRE ATT&CK:** T1127.001

**Severity:** High

### Detection Purpose

Detect suspicious process creation when PowerShell or
Windows script hosts launch MSBuild.exe or other trusted
developer utilities.

This behavior was observed during the MedDefense incident.

### Incident Data Results

| Metric | Result |
|---|---|
| Total events | 17 |
| Matched events | 2 |
| Match rate | 11.765% |
| Verdict | PASS |

### Matched Incident Events

**Match 1**

- Timestamp: 2026-04-14T02:46:58Z
- Host: WST-WS-031
- Parent process: powershell.exe
- Child process: MSBuild.exe
- Child PID: 8104
- Behavior: Suspicious PowerShell-to-MSBuild execution

**Match 2**

- Timestamp: 2026-04-14T03:27:13Z
- Host: WST-WS-017
- Parent process: powershell.exe
- Child process: MSBuild.exe
- Child PID: 5108
- Behavior: Suspicious PowerShell-to-MSBuild execution

### Incident Detection Verdict

PASS

The rule matched both expected PowerShell-to-MSBuild
execution events in the incident sample.

## 4. Rule 1: Clean Baseline Validation

| Metric | Result |
|---|---|
| Total events | 21 |
| Matched events | 0 |
| False positive rate | 0.000% |
| Target | Below 0.1% |
| Verdict | PASS |

### False Positive Analysis

No events matched the rule in the clean sample.

The clean data includes legitimate developer activity:

- Visual Studio launching MSBuild.exe.
- PowerShell launching dotnet.exe.
- Normal software build operations.

These activities did not satisfy the rule's combined
parent-child process conditions.

### Tuning Decision

No changes were required for Rule 1.

Reason:

- Both known attack process-creation events were detected.
- No matching events occurred in the clean baseline.
- The measured false positive rate was 0.000%.

The original Sigma rule was retained.

## 5. Rule 2: MSBuild Network/C2 Detection

**Rule File:** Task 4 Sigma rule (not yet supplied)

**Validation Status:** PENDING

### Detection Purpose

Detect suspicious outbound network connections associated
with MSBuild.exe and potential command-and-control activity.

### Relevant Incident Evidence

The incident sample includes MSBuild connections to:

- 185.220.101.47:443
- 91.234.99.107:443

These connections are associated with the MedDefense attack.

### Relevant Clean Baseline Evidence

The clean sample contains 14 legitimate MSBuild
connections to:

- api.nuget.org:443

These represent normal software development traffic.

### Validation Results

| Sample | Total Events | Matches | Match Rate | Verdict |
|---|---:|---:|---|---|
| Incident | 17 | Not measured | Pending | PENDING |
| Clean | 21 | Not measured | Pending | PENDING |

The Task 4 Sigma rule must be supplied before its
actual match counts can be determined.

### Potential False Positive Pattern

A broadly written MSBuild network detection rule
may match legitimate connections to api.nuget.org.

If confirmed during testing, consider excluding
approved NuGet traffic using a destination hostname
filter, then rerun validation.

No tuning has been applied without the actual rule.

## 6. Rule Changes and Retesting

| Rule | Change | Reason | Retest Result |
|---|---|---|---|
| Rule 1 | No changes | Incident detected; clean rate 0.000% | PASS |
| Rule 2 | Pending | Rule not supplied | PENDING |

## 7. Final Validation Summary

| Rule | Incident Detection | Clean FP Rate | Status |
|---|---|---|---|
| PowerShell MSBuild LOLBin | 2 matches | 0.000% | PASS |
| MSBuild Network/C2 | Not measured | Not measured | PENDING |

## 8. Limitations

The provided incident and clean samples contain only
17 and 21 events respectively.

Therefore, the results demonstrate detection behavior
on these lab samples but do not establish production
false positive performance.

With 21 clean events, a single match would represent
a 4.762% match rate.

The validation script supports basic Sigma conditions
and selected field modifiers. Production deployment
requires testing through a compatible Sigma backend
and the target SIEM.

## 9. Conclusion

The PowerShell MSBuild LOLBin rule successfully detected
both expected suspicious execution events in the incident
sample and generated zero matches in the clean baseline.

Its observed false positive rate was 0.000%, meeting the
lab's threshold of less than 0.1%.

No tuning was required for Rule 1.

Rule 2 remains pending until the Task 4 Sigma file is
available for testing.

Both rules should undergo additional validation with
larger representative datasets before production use.
