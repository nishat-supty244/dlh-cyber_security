
# Sigma Rule Validation Report

**Incident:** IR-2026-0414-01  
**Organization:** MedDefense  
**Test samples:** incident_sysmon.jsonl, clean_sysmon.jsonl

## 1. Objective

Validate the Sigma detection rules created in Tasks 3 and 4.

The rules must detect known malicious activity in the incident logs
while minimizing false positives in normal workstation activity.

Target false positive rate: less than 0.1% of clean events.

## 2. Validation Method

A Bash script, validate_rules.sh, was used to evaluate the
Sigma rule conditions against both JSONL log samples.

For each rule, the script calculates:

- Total events processed
- Number of matching events
- Match rate
- Clean-baseline false positive rate
- Matching clean events requiring review

Match rate = (Matched events / Total events) * 100

The script uses a limited Sigma-compatible matcher.
Full production compatibility requires validation using
the target SIEM's Sigma backend.

## 3. Rule 1: PowerShell MSBuild LOLBin Execution

**File:** sigma_powershell_msbuild_lolbin.yml  
**MITRE ATT&CK:** T1127.001

### Incident Data Results

- Total events: [TO BE FILLED]
- Matches: [TO BE FILLED]
- Match rate: [TO BE FILLED]%
- Did the rule detect the attack? [YES/NO]
- Verdict: [PASS/FAIL]

### Clean Data Results

- Total events: [TO BE FILLED]
- Matches: [TO BE FILLED]
- False positive rate: [TO BE FILLED]%
- Verdict: [PASS/REVIEW]

### False Positive Analysis

[Describe legitimate PowerShell, Visual Studio, or
MSBuild activity matched by the rule, if any.]

### Tuning Decisions

[Document each change, the reason, and the results
after retesting. Write "No changes required" if
the rule meets the acceptance criteria.]

## 4. Rule 2: MSBuild Network/C2 Detection

**File:** sigma_msbuild_c2_network.yml  
**MITRE ATT&CK:** [FROM TASK 4]

### Incident Data Results

- Total events: [TO BE FILLED]
- Matches: [TO BE FILLED]
- Match rate: [TO BE FILLED]%
- Did the rule detect the attack? [YES/NO]
- Verdict: [PASS/FAIL]

### Clean Data Results

- Total events: [TO BE FILLED]
- Matches: [TO BE FILLED]
- False positive rate: [TO BE FILLED]%
- Verdict: [PASS/REVIEW]

### False Positive Analysis

[Describe matched legitimate network connections,
including any NuGet or approved build traffic.]

### Tuning Decisions

[Document filters added or modified, why they were
needed, and the result after retesting.]

## 5. Final Validation Summary

| Rule | Incident Detection | Clean FP Rate | Verdict |
|---|---|---|---|
| PowerShell MSBuild LOLBin | TBD | TBD | TBD |
| MSBuild Network/C2 | TBD | TBD | TBD |

## 6. Acceptance Criteria

A rule passes when:

1. It matches the expected incident behavior.
2. Its clean-baseline match rate is below 0.1%.
3. Any legitimate matches have been reviewed.
4. All rule changes are documented.
5. The final tuned rule has been retested.

## 7. Conclusion

[Complete after running the tests. State whether
each rule passed, what was changed, and whether
further validation is required before deployment.]
