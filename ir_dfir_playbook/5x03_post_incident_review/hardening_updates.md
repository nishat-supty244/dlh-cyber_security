
# Hardening Updates: IR-2026-0414-01

**Organization:** MedDefense
**Incident ID:** IR-2026-0414-01
**Forensic Case:** LH-2026-0414-01
**Status:** Proposed — pending testing and approval

## Objective

Strengthen MedDefense workstations, authentication controls,
and credential protection following the incident.

Each proposed hardening change includes:
- The security control
- The configuration required
- The gap IDs from Task 2
- Supporting incident evidence
- A validation test

All changes must first be tested on representative
workstations before production deployment.

---

## HRD-001: PowerShell Constrained Language Mode

**Control:** PowerShell Constrained Language Mode (CLM)

**Closes:** GAP-005, GAP-006

**Evidence:**
- ART-001-F01: Malicious MSBuild inline-task XML.
- ART-002-M01: PowerShell spawned MSBuild.exe.
- ATT&CK: T1127.001.

### Configuration

**Applies to:** Non-administrative users on MedDefense
clinical and administrative workstations.

**Preferred enforcement:**
Use Windows Defender Application Control
(App Control for Business) or AppLocker application
control policies that integrate with PowerShell.

**GPO path for deploying application control:**

Computer Configuration
> Policies
> Windows Settings
> Security Settings
> Application Control Policies

For AppLocker, configure the relevant executable
and script rules. For App Control for Business,
deploy an approved application control policy.

**Registry path sometimes used in test environments:**

HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\
Control\Session Manager\Environment

Value name: __PSLockdownPolicy
Value type: REG_SZ
Value data: 4

**Important:** The __PSLockdownPolicy environment
variable is an undocumented testing mechanism,
not a supported security boundary. It must not
be relied upon to enforce CLM in production.

For production, use a properly enforced application
control policy and verify the resulting PowerShell
language mode.

### Expected Effect

For untrusted PowerShell code, Constrained Language
Mode restricts access to arbitrary .NET types,
COM objects, and advanced language features.

This reduces the attacker's ability to execute
certain malicious PowerShell techniques.

It does not directly prevent MSBuild.exe from
executing malicious XML tasks. HRD-002 provides
that additional control.

### Validation

Run PowerShell as a standard user:

$ExecutionContext.SessionState.LanguageMode

Expected result for the restricted session:

ConstrainedLanguage

Also test that prohibited .NET type usage is blocked
in a non-trusted PowerShell session.

**Gap IDs addressed:** GAP-005, GAP-006

**Validation test:** Confirm the standard-user
PowerShell session reports ConstrainedLanguage
and restricted .NET operations fail.

---

## HRD-002: AppLocker Restriction for MSBuild.exe

**Control:** Windows AppLocker executable rules

**Closes:** GAP-005, GAP-011

**Evidence:**
- ART-001-E01: MSBuild.exe execution at 02:47:00Z.
- ART-002-M01: PowerShell launched MSBuild.exe.
- ART-003-M01: MSBuild.exe observed on WST-WS-017.
- ATT&CK: T1127.001.

### Configuration

**Applies to:** MedDefense clinical and administrative
workstations where MSBuild is not required by
standard users.

**GPO path:**

Computer Configuration
> Policies
> Windows Settings
> Security Settings
> Application Control Policies
> AppLocker
> Executable Rules

**Policy logic:**

1. Create explicit allow rules for approved MSBuild
   executable paths.
2. Restrict those allow rules to the local
   Administrators group and named CI/CD identities.
3. Ensure standard users do not inherit broad
   executable allow rules that permit MSBuild.
4. Review existing publisher, path, and default
   rules for conflicts.
5. Configure executable rule enforcement.
6. Enable the Application Identity service.

**Example AppLocker XML rule structure:**

```xml
<FilePathRule
    Id="d16b8c84-1f4b-4b7d-9ad7-1b6df0a764d1"
    Name="Allow MSBuild for Administrators"
    Description="Approved administrator MSBuild execution"
    UserOrGroupSid="S-1-5-32-544"
    Action="Allow">
    <Conditions>
        <FilePathCondition
            Path="%WINDIR%\Microsoft.NET\Framework*\v*\MSBuild.exe" />
    </Conditions>
</FilePathRule>
```

The example shows one allow rule, not a complete
deployable AppLocker policy.

Additional rules are needed for all installed
MSBuild locations and approved CI/CD accounts.

The local Administrators SID is S-1-5-32-544.
CI/CD accounts must use their actual resolved SIDs.

**Important:** AppLocker default executable rules
may allow standard users to execute MSBuild from
Windows or Program Files directories.

Those broad allowances must be reviewed and
restructured before this restriction is effective.

Do not deploy an incomplete policy that could
interrupt clinical applications.

### Expected Effect

Standard users cannot launch unauthorized MSBuild
executables.

Administrators and explicitly approved build
service accounts retain required access.

### Validation

As a standard user, attempt to execute an approved
MSBuild binary.

Expected: execution blocked by AppLocker.

As an authorized administrator or CI/CD account,
repeat the test.

Expected: execution permitted.

Review:

Event Viewer
> Applications and Services Logs
> Microsoft
> Windows
> AppLocker
> EXE and DLL

**Gap IDs addressed:** GAP-005, GAP-011

**Validation test:** Confirm standard-user MSBuild
execution is blocked and approved accounts can run it.

---

## HRD-003: Conditional Access for New Geography VPN Logins

**Control:** Microsoft Entra Conditional Access and
VPN authentication risk controls

**Closes:** GAP-003, GAP-004

**Evidence:**
- Suspicious Office 365 sign-in from 45.63.9.88.
- Source geography reported as Russia.
- Conditional Access risk signals were reportedly
  suppressed by a compliant-device rule.
- VPN access remains unverified.

### Configuration

**Applies to:** MedDefense users authenticating
to VPN and other sensitive remote-access services.

**Microsoft Entra administration path:**

Microsoft Entra admin center
> Protection
> Conditional Access
> Policies

### Policy Logic

1. Include relevant MedDefense user groups.
2. Target the enterprise application used for
   VPN authentication, if integrated with Entra.
3. Require phishing-resistant MFA for sensitive
   remote access.
4. Apply sign-in risk controls without bypassing
   them solely because a device is compliant.
5. Use named locations to identify known
   organizational locations and blocked regions.
6. Monitor each user's successful authentication
   geography over a rolling 30-day period.
7. When a country is newly observed for that
   account, trigger a high-risk sign-in workflow.
8. Require step-up phishing-resistant MFA or
   block access according to assessed risk.

### Implementation Detail

Microsoft Entra Conditional Access does not provide
a native per-user condition that directly compares
the current country against that user's previous
30 days of sign-ins.

Implement the new-geography requirement using:

- Microsoft Entra sign-in logs.
- Microsoft Sentinel or equivalent SIEM analytics.
- A 30-day per-user geography baseline.
- Identity Protection risk signals.
- Supported automated response or VPN access
  enforcement integration.

For VPN services not integrated with Entra,
configure equivalent location and MFA controls
in the VPN identity provider or gateway.

### Expected Effect

Suspicious foreign authentication receives
additional verification or is blocked.

Compliant-device status alone does not bypass
the configured risk controls.

### Validation

Use an authorized test account and simulated
or controlled new-geography sign-in.

Verify that the policy evaluates the event and
requires the configured MFA or blocking action.

Check the Entra sign-in log for the applied policy,
risk evaluation, and authentication result.

**Gap IDs addressed:** GAP-003, GAP-004

**Validation test:** Confirm a new-geography
remote-access attempt triggers the required
MFA or block action.

---

## HRD-004: Windows Credential Guard

**Control:** Windows Defender Credential Guard

**Closes:** GAP-009, GAP-010

**Evidence:**
- ART-002-M04: NTLM credential material associated
  with dmarsh was observed in LSASS memory.
- ATT&CK: T1003.001.
- The evidence does not independently prove
  successful LSASS credential dumping.

### Configuration

**Applies to:** Supported MedDefense Windows
workstations, prioritizing clinical endpoints
and privileged-access systems.

**Supported platforms:**

Windows 10 Enterprise/Education and supported
Windows 11 editions, subject to Microsoft
hardware, virtualization, and edition requirements.

Credential Guard is also available on supported
Windows Server releases, with edition and
deployment limitations.

Some eligible Windows 11 systems enable
Credential Guard by default.

**Prerequisites:**

- UEFI and Secure Boot.
- Virtualization-based security support.
- Hardware virtualization enabled.
- Supported Windows edition and configuration.

**GPO path:**

Computer Configuration
> Administrative Templates
> System
> Device Guard
> Turn On Virtualization Based Security

**Recommended settings:**

Turn On Virtualization Based Security: Enabled

Platform Security Level:
Secure Boot (or Secure Boot with DMA Protection
where supported)

Credential Guard Configuration:
Enabled without UEFI lock, for a manageable
initial rollout.

Use UEFI lock only after compatibility testing
and approval because rollback is more difficult.

**Registry configuration:**

Path:
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\
Control\DeviceGuard

Value:
EnableVirtualizationBasedSecurity

Type: REG_DWORD
Data: 1

Path:
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\
Control\Lsa

Value:
LsaCfgFlags

Type: REG_DWORD
Data: 2

The value 2 enables Credential Guard without
UEFI lock on supported systems.

Restart the endpoint after policy deployment
where required.

### Expected Effect

Credential Guard uses virtualization-based
security to isolate supported authentication
secrets from the normal Windows operating system.

This reduces the risk of credential extraction
from LSASS.

It does not protect every credential type,
prevent every LSASS attack, or replace EDR
credential-access monitoring.

### Validation

Run PowerShell as administrator:

Get-CimInstance -ClassName Win32_DeviceGuard `
  -Namespace root\Microsoft\Windows\DeviceGuard |
  Select-Object SecurityServicesRunning

Expected: the running security services include
Credential Guard (value 1).

Alternatively, use msinfo32 and verify that
Credential Guard appears under running
virtualization-based security services.

**Gap IDs addressed:** GAP-009, GAP-010

**Validation test:** Confirm Credential Guard
is listed as a running security service.

---

## Implementation and Rollout

| Priority | Hardening ID | Control | Main Gap |
|---|---|---|---|
| P1 | HRD-001 | PowerShell Constrained Language Mode | GAP-005 |
| P1 | HRD-002 | AppLocker MSBuild restriction | GAP-005 |
| P1 | HRD-003 | Conditional Access and VPN risk controls | GAP-003 |
| P1 | HRD-004 | Windows Credential Guard | GAP-009 |

### Deployment Requirements

Before production deployment:

1. Test configurations on representative
   non-production clinical workstations.
2. Confirm compatibility with hospital software.
3. Review exceptions with application owners.
4. Obtain security and clinical change approval.
5. Roll out changes in stages.
6. Record validation evidence.
7. Monitor for unexpected application failures.
8. Maintain rollback procedures.

## Conclusion

The proposed controls address weaknesses identified
during the MedDefense incident. PowerShell restrictions and AppLocker reduce
opportunities for malicious LOLBin execution. Conditional Access improvements reduce exposure
to suspicious remote authentication. Credential Guard strengthens protection of
Windows authentication secrets. Each change is linked to a documented gap and
includes a validation procedure. Production implementation remains subject to
compatibility testing and change approval.
