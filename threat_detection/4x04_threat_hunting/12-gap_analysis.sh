#!/bin/bash

# ================================================================
# Task 12 - Detection Gap Analysis
# HEALTHBANE Stage 4
# ================================================================

set -u
set -o pipefail

echo "================================================================"
echo "   DETECTION GAP ANALYSIS - Stage 4 Techniques"
echo "================================================================"
echo

# ----------------------------------------------------------------
# Helper function: print one detection gap
# ----------------------------------------------------------------
print_gap() {
    local number="$1"
    local technique="$2"
    local finding="$3"
    local missed="$4"
    local source="$5"
    local rule="$6"
    local priority="$7"

    echo "GAP ${number}: ${technique}"
    echo "  Hunt Finding: ${finding}"
    echo "  Why Missed: ${missed}"
    echo "  Data Source: ${source}"
    echo "  Required Rule: ${rule}"
    echo "  Priority: ${priority}"
    echo
}

# ----------------------------------------------------------------
# GAP 1 - PsExec
# ATT&CK T1021.002
# ----------------------------------------------------------------
print_gap \
"1" \
"T1021.002 PsExec Lateral Movement" \
"PsExec was used from non-admin workstation WS-RECV-03 toward SRV-HEALTH-DB" \
"Missing rule" \
"Sysmon Event 1 (Process Creation)" \
"Alert when Image or CommandLine contains PsExec AND source host is not WS-ADMIN-01 OR activity occurs outside 08:00-18:00; allowlist authorized administrator activity" \
"P1"

# ----------------------------------------------------------------
# GAP 2 - LSASS Memory
# ATT&CK T1003.001
# ----------------------------------------------------------------
print_gap \
"2" \
"T1003.001 LSASS Credential Access" \
"Non-system process accessed lsass.exe on WS-RECV-03" \
"Missing rule" \
"Sysmon Event 10 (Process Access)" \
"Alert when TargetImage contains lsass.exe AND SourceImage is not an approved Windows/system process; use an allowlist for legitimate security and system tools" \
"P1"

# ----------------------------------------------------------------
# GAP 3 - WMI
# ATT&CK T1047
# ----------------------------------------------------------------
print_gap \
"3" \
"T1047 WMI Remote Execution" \
"WMI activity was used for remote activity against target systems" \
"Missing rule" \
"Sysmon Event 1 plus Windows WMI/PowerShell telemetry" \
"Alert on wmiprvse.exe, wmic.exe, or remote WMI execution when source host, account, target, or time is outside the authorized administrative baseline; allowlist approved administrators and management hosts" \
"P1"

# ----------------------------------------------------------------
# GAP 4 - PowerShell Remoting / WinRM
# ATT&CK T1021.006
# ----------------------------------------------------------------
print_gap \
"4" \
"T1021.006 Windows Remote Management" \
"PowerShell Remoting/WinRM activity was used during the lateral movement sequence" \
"Missing rule" \
"PowerShell logs plus Sysmon Event 1" \
"Alert on Enter-PSSession, Invoke-Command, WinRM/WinRS, or PowerShell remote execution when the source account or host is not authorized or activity is outside the normal administrative baseline" \
"P1"

# ----------------------------------------------------------------
# GAP 5 - Service Account Misuse
# ATT&CK T1078.002
# ----------------------------------------------------------------
print_gap \
"5" \
"T1078.002 Domain Accounts - Service Account Misuse" \
"svc_healthsync authenticated from workstation WS-RECV-03 instead of its authorized service host" \
"Missing rule" \
"Windows Event 4624" \
"Compare TargetUserName against the service-account authorization matrix and alert when the source host is not authorized; also flag workstation-originated or interactive logons and apply the matrix as the allowlist" \
"P1"

# ----------------------------------------------------------------
# GAP 6 - NTLM / Pass-the-Hash-style Activity
# ATT&CK T1550.002 where applicable
# ----------------------------------------------------------------
print_gap \
"6" \
"T1550.002 Pass the Hash / NTLM-style Activity" \
"NTLM authentication associated with suspicious service-account or lateral movement activity should be investigated when supported by the available telemetry" \
"Overly specific rule" \
"Windows Event 4624 plus authentication telemetry" \
"Alert when NTLM authentication is combined with an unauthorized source host, privileged or service account, unusual logon type, or lateral movement; allowlist known legacy systems and approved NTLM use" \
"P2"

# ----------------------------------------------------------------
# Summary
# ----------------------------------------------------------------
echo "SUMMARY:"
echo "  The required telemetry was available for the main Stage 4 hunt."
echo "  Existing detection logic did not adequately identify the behavior."
echo "  The primary remediation is to add behavioral rules using"
echo "  source host, user, destination, time, process, and baseline context."
echo
echo "  Priority breakdown:"
echo "    P1: PsExec, LSASS, WMI, PowerShell Remoting, Service Account Misuse"
echo "    P2: NTLM / Pass-the-Hash-style activity"
echo
echo "  Key lesson:"
echo "    Legitimate Windows tools require behavioral detection,"
echo "    not only malware signatures or IOC matching."
echo
echo "================================================================"
echo "   END OF DETECTION GAP ANALYSIS"
echo "================================================================"
