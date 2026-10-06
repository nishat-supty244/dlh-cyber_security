# HEALTHBANE Stage 4 - Detection Rules

## Purpose

These rule drafts convert the findings from proactive threat hunting
into repeatable automated detections.

Threat hunting cycle:

hunt -> find -> detect -> hunt again

---

## Rule 100100 - PsExec

**ATT&CK:** T1021.002

**Behavior detected:**
PsExec execution from a source that is not part of the normal
administrator baseline or activity occurring outside approved hours.

**Hunt evidence:**
Task 4 identified anomalous PsExec activity from WS-RECV-03
toward SRV-HEALTH-DB.

**Expected false positives:**
Very low.

**Baseline comparison:**
Normal activity is associated with MEDDEFENSE\robert.kim,
WS-ADMIN-01 and approved maintenance windows.

---

## Rule 100101 - LSASS Access

**ATT&CK:** T1003.001

**Behavior detected:**
A non-system process accesses lsass.exe.

**Hunt evidence:**
Task 6 identified suspicious LSASS access associated with
WS-RECV-03 and debug_tool.exe.

**Expected false positives:**
Low.

**Baseline comparison:**
Known Windows/system processes and approved security tools
are allowlisted.

---

## Rule 100102 - Service Account Misuse

**ATT&CK:** T1078.002

**Behavior detected:**
A service account authenticates from a host that is not authorized
by the service-account matrix.

**Hunt evidence:**
Task 9 identified svc_healthsync authentication from WS-RECV-03,
although the account is authorized for SRV-HEALTH-DB.

**Expected false positives:**
Very low.

**Baseline comparison:**
reference/service_accounts.txt is the source of truth for
authorized service-account hosts.

---

## Rule 100103 - WMI Child Process

**ATT&CK:** T1047

**Behavior detected:**
WMI-related processes spawn cmd.exe, PowerShell or another
command interpreter.

**Hunt evidence:**
Task 5 identified WMI activity as part of the lateral movement
sequence.

**Expected false positives:**
Medium.

**Baseline comparison:**
Compare administrator, source host, destination and time against
the documented administrative baseline.

---

## Rule 9000030 - SMB/PsExec

**ATT&CK:** T1021.002

**Behavior detected:**
SMB administrative-share activity followed by remote service
installation consistent with PsExec.

**Hunt evidence:**
Task 4 identified PsExec lateral movement toward the
health database server.

**Expected false positives:**
Low.

**Baseline comparison:**
Known administrator maintenance traffic from authorized
management hosts should be allowlisted.

---

## Detection Posture

### Before hunt

ATT&CK coverage:
approximately 55%

The environment had significant visibility gaps around
Stage 4 lateral movement and credential access.

### After hunt

ATT&CK coverage:
approximately 80%

New behavioral detection coverage addresses:

- T1021.002 - SMB/Windows Admin Shares / PsExec
- T1003.001 - LSASS Memory
- T1047 - WMI
- T1021.006 - Windows Remote Management
- T1078.002 - Domain Accounts / Service Account Misuse

The new rules should be continuously tuned against legitimate
administrator activity to control false positives.

---

## Important Detection Principle

Tool names alone should not generate high-confidence alerts.

PsExec, WMI and PowerShell are legitimate administrative tools.

Detection should combine:

WHO + SOURCE + DESTINATION + TOOL + TIME + ACCOUNT + BASELINE

This makes the detection behavioral rather than purely signature-based.
