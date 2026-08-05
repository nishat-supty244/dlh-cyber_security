<#
.SYNOPSIS
    3-telemetry_reference.ps1 - Windows Telemetry Reference Builder
.DESCRIPTION
    Builds a machine-readable Windows event reference mapping Security, PowerShell, 
    and Sysmon Event IDs to MedDefense detection use cases, generating windows_event_reference.json.
.AUTHOR
    Analyst
.DATE
    2026-08-05
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[*] Building Windows Telemetry Reference Mapping..." -ForegroundColor Yellow

$telemetryReference = @(
    # Security Log Events (9)
    [PSCustomObject]@{
        event_id = 4624
        event_name = "Successful Logon"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit Logon (Success)"
        security_meaning = "Indicates a user or service successfully authenticated to the system."
        normal_frequency = "High"
        triage_priority = "Low"
        crimson_tide_phase = "Initial Access / Lateral Movement"
        example_suspicious_pattern = "Logon from unusual source IP or at odd hours using administrative credentials."
        validation_method = "Initiate a successful interactive or remote logon session."
    },
    [PSCustomObject]@{
        event_id = 4625
        event_name = "Failed Logon"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit Logon (Failure)"
        security_meaning = "Indicates an authentication attempt failed due to bad credentials or account restrictions."
        normal_frequency = "Medium"
        triage_priority = "Medium"
        crimson_tide_phase = "Credential Access"
        example_suspicious_pattern = "High frequency of failed logons in a short window indicating brute-force or password spraying."
        validation_method = "Attempt logging in with an incorrect password."
    },
    [PSCustomObject]@{
        event_id = 4648
        event_name = "Explicit Credentials"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit Logon (Success and Failure)"
        security_meaning = "A logon was attempted using explicit credentials provided by an application."
        normal_frequency = "Low"
        triage_priority = "Medium"
        crimson_tide_phase = "Lateral Movement"
        example_suspicious_pattern = "Use of runas.exe or tools passing explicit credentials to pivot across hosts."
        validation_method = "Run a process using runas /netonly."
    },
    [PSCustomObject]@{
        event_id = 4672
        event_name = "Special Logon"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit Special Logon"
        security_meaning = "Special privileges assigned to a new logon (e.g., Administrator or SYSTEM level tokens)."
        normal_frequency = "Low"
        triage_priority = "High"
        crimson_tide_phase = "Privilege Escalation"
        example_suspicious_pattern = "Special logon immediately following an external or untrusted user authentication."
        validation_method = "Log on using an administrative account."
    },
    [PSCustomObject]@{
        event_id = 4688
        event_name = "Process Creation"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit Process Creation (Include command line)"
        security_meaning = "A new process has been created, capturing parent process and command-line arguments."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Execution"
        example_suspicious_pattern = "cmd.exe or powershell.exe spawned by unexpected parent applications like Word or Outlook."
        validation_method = "Launch a command shell process."
    },
    [PSCustomObject]@{
        event_id = 4720
        event_name = "Account Created"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit User Account Management"
        security_meaning = "A new user account was created in Active Directory or locally."
        normal_frequency = "Low"
        triage_priority = "High"
        crimson_tide_phase = "Persistence"
        example_suspicious_pattern = "Creation of unauthorized administrative accounts outside normal provisioning workflows."
        validation_method = "Create a test local or domain user account."
    },
    [PSCustomObject]@{
        event_id = 4726
        event_name = "Account Deleted"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit User Account Management"
        security_meaning = "A user account was deleted from the system or domain."
        normal_frequency = "Low"
        triage_priority = "Medium"
        crimson_tide_phase = "Defense Evasion / Impact"
        example_suspicious_pattern = "Deletion of forensic or administrative accounts created during an intrusion."
        validation_method = "Delete a test user account."
    },
    [PSCustomObject]@{
        event_id = 4732
        event_name = "Member Added to Group"
        log_source = "Security"
        audit_or_sensor_dependency = "Audit Security Group Management"
        security_meaning = "A security-enabled local or domain group membership was modified."
        normal_frequency = "Low"
        triage_priority = "High"
        crimson_tide_phase = "Privilege Escalation"
        example_suspicious_pattern = "Addition of non-administrative user accounts into Domain Admins or Administrators groups."
        validation_method = "Add a test user to a local group."
    },
    [PSCustomObject]@{
        event_id = 1102
        event_name = "Audit Log Cleared"
        log_source = "Security"
        audit_or_sensor_dependency = "System Integrity Subcategory"
        security_meaning = "The Security event log was explicitly cleared by a user or process."
        normal_frequency = "Zero"
        triage_priority = "Critical"
        crimson_tide_phase = "Defense Evasion"
        example_suspicious_pattern = "Log clearing events executed via wevtutil or programmatic APIs to hide traces of compromise."
        validation_method = "Clear security log or inspect audit configurations."
    },

    # PowerShell Log Events (2)
    [PSCustomObject]@{
        event_id = 4103
        event_name = "PowerShell Module Logging"
        log_source = "PowerShell"
        audit_or_sensor_dependency = "Module Logging Group Policy Enabled"
        security_meaning = "Pipeline execution details and executed module pipelines captured by PowerShell."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Execution"
        example_suspicious_pattern = "Execution of malicious scripts containing encoded commands or invocation of sensitive modules."
        validation_method = "Execute a custom PowerShell module command."
    },
    [PSCustomObject]@{
        event_id = 4104
        event_name = "PowerShell Script Block Logging"
        log_source = "PowerShell"
        audit_or_sensor_dependency = "Script Block Logging Group Policy Enabled"
        security_meaning = "Full content of code blocks executed by PowerShell regardless of obfuscation."
        normal_frequency = "High"
        triage_priority = "High"
        crimson_tide_phase = "Execution / Discovery"
        example_suspicious_pattern = "Large blocks of obfuscated or base64-encoded strings decoded and executed in memory."
        validation_method = "Run an inline script block in PowerShell."
    },

    # Sysmon Log Events (6)
    [PSCustomObject]@{
        event_id = 1
        event_name = "Process Creation (Sysmon)"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Driver Installed (Config ID 1)"
        security_meaning = "Enhanced process creation logging including full command lines and cryptographic hashes."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Execution"
        example_suspicious_pattern = "Execution of unsigned binaries running out of temporary directories or AppData."
        validation_method = "Trigger a process start monitored by Sysmon."
    },
    [PSCustomObject]@{
        event_id = 3
        event_name = "Network Connection"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Driver Installed (Config ID 3)"
        security_meaning = "Logs TCP/UDP network connections initiated or accepted by processes."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Command and Control / Exfiltration"
        example_suspicious_pattern = "Uncommon processes making direct outbound connections to external IP addresses on non-standard ports."
        validation_method = "Perform an outbound network request (e.g., Invoke-WebRequest)."
    },
    [PSCustomObject]@{
        event_id = 7
        event_name = "Image Loaded (DLL)"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Driver Installed (Config ID 7)"
        security_meaning = "Logs DLL modules loaded into processes, including signatures and hashes."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Defense Evasion / Injection"
        example_suspicious_pattern = "Loading of unsigned DLLs or suspicious libraries into native system processes (DLL hijacking)."
        validation_method = "Load an assembly or DLL via PowerShell."
    },
    [PSCustomObject]@{
        event_id = 11
        event_name = "File Creation"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Driver Installed (Config ID 11)"
        security_meaning = "Tracks file creation events and modification timestamps."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Persistence / Lateral Movement"
        example_suspicious_pattern = "Dropping executables or scripts into Startup folders, system directories, or web roots."
        validation_method = "Create a new file in a monitored directory."
    },
    [PSCustomObject]@{
        event_id = 13
        event_name = "Registry Event (Value Set)"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Driver Installed (Config ID 13)"
        security_meaning = "Monitors registry modifications for persistence mechanisms and configuration changes."
        normal_frequency = "High"
        triage_priority = "High"
        crimson_tide_phase = "Persistence"
        example_suspicious_pattern = "Modifications to Run/RunOnce keys, Image File Execution Options, or Winlogon helpers."
        validation_method = "Modify a monitored registry path."
    },
    [PSCustomObject]@{
        event_id = 22
        event_name = "DNS Query"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Driver Installed (Config ID 22)"
        security_meaning = "Logs DNS lookups performed by processes, assisting in domain resolution tracking."
        normal_frequency = "High"
        triage_priority = "Medium"
        crimson_tide_phase = "Command and Control"
        example_suspicious_pattern = "High volume of random subdomain queries indicative of DNS tunneling or C2 communications."
        validation_method = "Perform a DNS lookup query via Resolve-DnsName."
    }
)

# Counts
$secCount = ($telemetryReference | Where-Object { $_.log_source -eq "Security" }).Count
$psCount = ($telemetryReference | Where-Object { $_.log_source -eq "PowerShell" }).Count
$sysCount = ($telemetryReference | Where-Object { $_.log_source -eq "Sysmon" }).Count
$totalCount = $telemetryReference.Count

# Build Output Object
$outputObject = [PSCustomObject]@{
    generated_timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    security_events_mapped = $secCount
    powershell_events_mapped = $psCount
    sysmon_events_mapped = $sysCount
    total_events_documented = $totalCount
    reference_data = $telemetryReference
}

$outputJsonPath = "windows_event_reference.json"
$outputObject | ConvertTo-Json -Depth 5 | Out-File -FilePath $outputJsonPath -Force -Encoding UTF8

# Print Exact Required Standard Console Statistics
Write-Host "Security events mapped: $secCount"
Write-Host "PowerShell events mapped: $psCount"
Write-Host "Sysmon events mapped: $sysCount"
Write-Host "Total events documented: $totalCount"
Write-Host "Reference saved to: $outputJsonPath" -ForegroundColor Green
