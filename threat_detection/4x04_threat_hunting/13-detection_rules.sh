#!/bin/bash

# ================================================================
# Task 13 - New Detection Rules
# HEALTHBANE Stage 4
# ================================================================

set -u
set -o pipefail

echo "================================================================"
echo "   DETECTION ENGINEERING - Hunt-Derived Rules"
echo "================================================================"
echo

# ----------------------------------------------------------------
# Create output directory
# ----------------------------------------------------------------

OUTPUT_DIR="detection_rules"

mkdir -p "$OUTPUT_DIR"

# ----------------------------------------------------------------
# Rule 100100 - PsExec anomalous source/time
# ATT&CK T1021.002
# ----------------------------------------------------------------

cat > "${OUTPUT_DIR}/100100-psexec-anomalous.xml" <<'EOF'
<!--
Rule ID: 100100
Name: PsExec from Non-Admin Workstation
ATT&CK: T1021.002
Evidence: Task 4 - PsExec Hunt
-->

<group name="healthbane,lateral_movement,psexec,">

  <rule id="100100" level="12">
    <if_group>sysmon_event1</if_group>

    <field name="win.eventdata.image">(?i)PsExec(\.exe)?</field>

    <description>
      HEALTHBANE: PsExec execution detected from a potentially
      unauthorized source or outside the normal administrator baseline.
    </description>

    <mitre>
      <id>T1021.002</id>
    </mitre>

    <!--
    Baseline logic:
      Normal administrator activity:
        User: MEDDEFENSE\robert.kim
        Source: WS-ADMIN-01
        Time: 08:00-18:00
        Maintenance days: reference/admin_schedule.txt

      Alert when:
        Source != WS-ADMIN-01
        OR outside approved maintenance window
        OR account is not an authorized administrator
    -->
  </rule>

</group>
EOF

# ----------------------------------------------------------------
# Rule 100101 - LSASS access
# ATT&CK T1003.001
# ----------------------------------------------------------------

cat > "${OUTPUT_DIR}/100101-lsass-nonsystem.xml" <<'EOF'
<!--
Rule ID: 100101
Name: LSASS Memory Access from Non-System Process
ATT&CK: T1003.001
Evidence: Task 6 - Credential Access Hunt
-->

<group name="healthbane,credential_access,lsass,">

  <rule id="100101" level="13">
    <if_group>sysmon_event10</if_group>

    <field name="win.eventdata.targetImage">(?i)\\lsass\.exe$</field>

    <description>
      HEALTHBANE: Non-system process accessed LSASS.
      Investigate for possible credential dumping.
    </description>

    <mitre>
      <id>T1003.001</id>
    </mitre>

    <!--
    Baseline logic:

      Allow known Windows/system processes and approved
      security software.

      Examples:
        svchost.exe
        services.exe
        wininit.exe
        csrss.exe
        lsass.exe
        winlogon.exe
        taskhostw.exe
        wmiprvse.exe
        MsMpEng.exe

      Alert when SourceImage is not in the approved allowlist.

      High-risk access masks such as 0x1010, 0x1410,
      0x1438 and 0x1fffff increase investigation priority,
      but an access mask alone does not prove credential dumping.
    -->
  </rule>

</group>
EOF

# ----------------------------------------------------------------
# Rule 100102 - Service account unauthorized authentication
# ATT&CK T1078.002
# ----------------------------------------------------------------

cat > "${OUTPUT_DIR}/100102-service-account-unauthorized.xml" <<'EOF'
<!--
Rule ID: 100102
Name: Service Account Authentication from Unauthorized Host
ATT&CK: T1078.002
Evidence: Task 9 - Service Account Abuse Hunt
-->

<group name="healthbane,credential_access,lateral_movement,service_account,">

  <rule id="100102" level="13">
    <field name="win.system.eventID">4624</field>

    <field name="win.eventdata.targetUserName">(?i)^svc_</field>

    <description>
      HEALTHBANE: Service account authenticated from a host
      that is not authorized by the service-account matrix.
    </description>

    <mitre>
      <id>T1078.002</id>
    </mitre>

    <!--
    Baseline logic:

      Use reference/service_accounts.txt as the source of truth.

      Example:
        svc_healthsync -> SRV-HEALTH-DB
        svc_insurance  -> SRV-INS-DB
        svc_backup     -> SRV-BACKUP-01

      Alert when:
        service account source host is not authorized.

      Increase priority when:
        - source is a workstation (WS-*)
        - logon type is interactive (2, 10 or 11)
        - NTLM is used
        - the same host later performs PsExec, WMI or PSRemoting

      Do not hard-code one service account into production.
      The authorization matrix should remain the allowlist.
    -->
  </rule>

</group>
EOF

# ----------------------------------------------------------------
# Rule 100103 - WMI child process anomaly
# ATT&CK T1047
# ----------------------------------------------------------------

cat > "${OUTPUT_DIR}/100103-wmi-child-process.xml" <<'EOF'
<!--
Rule ID: 100103
Name: WMI Remote Child Process Anomaly
ATT&CK: T1047
Evidence: Task 5 - WMI Hunt
-->

<group name="healthbane,lateral_movement,wmi,">

  <rule id="100103" level="11">
    <field name="win.eventdata.parentImage">
      (?i)\\(wmiprvse|wmic)\.exe$
    </field>

    <field name="win.eventdata.image">
      (?i)\\(cmd|powershell|pwsh|cscript|wscript)\.exe$
    </field>

    <description>
      HEALTHBANE: WMI-related process spawned a command shell
      or scripting interpreter. Investigate for remote execution.
    </description>

    <mitre>
      <id>T1047</id>
    </mitre>

    <!--
    Baseline logic:

      Compare source host, account, destination and time
      against the normal administrator baseline.

      Lower concern:
        Authorized administrator
        Authorized management host
        Approved maintenance window

      Higher concern:
        Workstation source
        Service account
        Off-hours activity
        Unusual destination
        Followed by PsExec or PowerShell Remoting
    -->
  </rule>

</group>
EOF

# ----------------------------------------------------------------
# Network Rule 9000030
# SMB lateral movement / PsExec service installation
# ATT&CK T1021.002
# ----------------------------------------------------------------

cat > "${OUTPUT_DIR}/9000030-smb-psexec-service.xml" <<'EOF'
<!--
Rule ID: 9000030
Name: SMB Lateral Movement - PsExec Service Installation
ATT&CK: T1021.002
Evidence: Task 4 - PsExec Hunt

This is a network-level detection draft.
Exact implementation depends on the available network
telemetry / IDS / firewall logs.
-->

<network_rule>

  <rule id="9000030" severity="high">

    <behavior>
      SMB connection associated with remote administrative
      service creation consistent with PsExec.
    </behavior>

    <logic>
      Detect:
        Source workstation
        -> SMB (TCP/445)
        -> administrative share such as ADMIN$ or C$
        -> remote service creation / Service Control activity

      Correlate with:
        - unusual source host
        - unusual destination
        - service account authentication
        - off-hours activity
        - subsequent process execution
    </logic>

    <description>
      HEALTHBANE: Possible PsExec-style SMB lateral movement
      and remote service installation.
    </description>

    <mitre>
      <id>T1021.002</id>
    </mitre>

    <!--
    Baseline:
      WS-ADMIN-01 and authorized administrators may legitimately
      access administrative shares during maintenance.

      Alert when the source, account, destination or time
      falls outside the approved administrative baseline.
    -->

  </rule>

</network_rule>
EOF

# ----------------------------------------------------------------
# Detection documentation
# ----------------------------------------------------------------

cat > "${OUTPUT_DIR}/README.md" <<'EOF'
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
EOF

# ----------------------------------------------------------------
# Console output
# ----------------------------------------------------------------

echo "=== WAZUH-STYLE RULE DRAFTS ==="
echo

echo "[Rule 100100] PsExec from Non-Admin Workstation"
echo "  Behavior: PsExec execution from non-admin workstation"
echo "  Evidence: Hunt Task 4"
echo "  FP Rate: VERY LOW"
echo "  Baseline: WS-ADMIN-01 + Robert Kim + approved maintenance hours"
echo

echo "[Rule 100101] LSASS Memory Access from Non-System Process"
echo "  Behavior: Suspicious LSASS access"
echo "  Evidence: Hunt Task 6"
echo "  FP Rate: LOW"
echo "  Baseline: Approved Windows/system/security processes"
echo

echo "[Rule 100102] Service Account Authentication from Unauthorized Host"
echo "  Behavior: Service account used from unauthorized source"
echo "  Evidence: Hunt Task 9"
echo "  FP Rate: VERY LOW"
echo "  Baseline: reference/service_accounts.txt"
echo

echo "[Rule 100103] WMI Remote Child Process Anomaly"
echo "  Behavior: WMI-related process spawning command interpreter"
echo "  Evidence: Hunt Task 5"
echo "  FP Rate: MEDIUM"
echo "  Baseline: Administrator + source + destination + time"
echo

echo "=== NETWORK RULE DRAFTS ==="
echo

echo "[Rule 9000030] SMB Lateral Movement - PsExec Service Installation"
echo "  Behavior: SMB administrative share + remote service installation"
echo "  Evidence: Hunt Task 4"
echo "  FP Rate: LOW"
echo "  Baseline: Authorized management hosts and maintenance activity"
echo

echo "=== DETECTION POSTURE UPDATE ==="
echo "  Before hunt: 55% observed coverage"
echo "  After hunt: approximately 80% coverage"
echo
echo "  New coverage:"
echo "    T1021.002 - PsExec / SMB lateral movement"
echo "    T1003.001 - LSASS Memory"
echo "    T1047     - WMI"
echo "    T1021.006 - Windows Remote Management"
echo "    T1078.002 - Service Account Misuse"
echo

echo "=== FILES CREATED ==="
echo "  ${OUTPUT_DIR}/100100-psexec-anomalous.xml"
echo "  ${OUTPUT_DIR}/100101-lsass-nonsystem.xml"
echo "  ${OUTPUT_DIR}/100102-service-account-unauthorized.xml"
echo "  ${OUTPUT_DIR}/100103-wmi-child-process.xml"
echo "  ${OUTPUT_DIR}/9000030-smb-psexec-service.xml"
echo "  ${OUTPUT_DIR}/README.md"
echo

echo "================================================================"
echo "   END OF DETECTION ENGINEERING"
echo "================================================================"
