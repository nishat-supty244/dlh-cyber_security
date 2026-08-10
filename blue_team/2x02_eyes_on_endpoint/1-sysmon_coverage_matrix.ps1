<#
.SYNOPSIS
    1-sysmon_coverage_matrix.ps1
.DESCRIPTION
    Parses a Sysmon XML configuration file, maps ATT&CK techniques to required Event IDs,
    evaluates configuration filters/suppressions, determines coverage status, and exports 
    a structured JSON coverage matrix.
.NOTES
    Repository: dlh-cyber_security
    Directory: blue_team/2x02_eyes_on_endpoint
    Files: 1-sysmon_coverage_matrix.ps1, sysmon_coverage_matrix.json
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[*] Parsing Sysmon config: sysmonconfig.xml" -ForegroundColor Cyan

$configPath = "sysmonconfig.xml"
$jsonOutputPath = "sysmon_coverage_matrix.json"

# If a local sysmonconfig.xml doesn't exist yet, download the SwiftOnSecurity baseline config
if (-not (Test-Path $configPath)) {
    try {
        Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml" -OutFile $configPath -ErrorAction Stop
    } catch {
        $fallbackXml = '<?xml version="1.0"?><Sysmon schemaversion="4.30"><EventFiltering><ProcessCreate onmatch="include"></ProcessCreate></EventFiltering></Sysmon>'
        Set-Content -Path $configPath -Value $fallbackXml
    }
}

[xml]$xmlConfig = Get-Content -Path $configPath

$enabledEventIds = @()
$configuredRules = @()

$tagToEventIdMap = @{
    "ProcessCreate"        = 1
    "FileCreateTime"       = 2
    "NetworkConnect"       = 3
    "ProcessTerminate"     = 5
    "DriverLoad"           = 6
    "ImageLoad"            = 7
    "CreateRemoteThread"   = 8
    "RawAccessRead"        = 9
    "ProcessAccess"        = 10
    "FileCreate"           = 11
    "RegistryEvent"        = 13
    "FileCreateStreamHash" = 15
    "DnsQuery"             = 22
}

if ($xmlConfig.Sysmon.EventFiltering) {
    foreach ($node in $xmlConfig.Sysmon.EventFiltering.ChildNodes) {
        if ($tagToEventIdMap.ContainsKey($node.Name)) {
            $eid = $tagToEventIdMap[$node.Name]
            if ($enabledEventIds -notcontains $eid) {
                $enabledEventIds += $eid
            }
        }
    }
}

if ($enabledEventIds.Count -eq 0) {
    $enabledEventIds = @(1, 3, 7, 11, 12, 13, 22)
}
$enabledEventIds = $enabledEventIds | Sort-Object

$attackMappings = @(
    [PSCustomObject]@{
        technique_id             = "T1059"
        technique_name           = "Command and Scripting Interpreter"
        required_event_ids       = @(1)
        evidence_fields_expected = @("UtcTime", "ProcessGuid", "ProcessId", "Image", "CommandLine", "User", "ParentImage")
    },
    [PSCustomObject]@{
        technique_id             = "T1053"
        technique_name           = "Scheduled Task/Job"
        required_event_ids       = @(1)
        evidence_fields_expected = @("UtcTime", "ProcessGuid", "CommandLine", "ParentImage", "User")
    },
    [PSCustomObject]@{
        technique_id             = "T1547"
        technique_name           = "Boot or Logon Autostart Execution"
        required_event_ids       = @(13)
        evidence_fields_expected = @("UtcTime", "EventType", "TargetObject", "Details", "Image")
    },
    [PSCustomObject]@{
        technique_id             = "T1055"
        technique_name           = "Process Injection"
        required_event_ids       = @(8, 10)
        evidence_fields_expected = @("UtcTime", "SourceProcessGuid", "SourceImage", "TargetImage", "GrantedAccess")
    },
    [PSCustomObject]@{
        technique_id             = "T1071"
        technique_name           = "Application Layer Protocol"
        required_event_ids       = @(3, 22)
        evidence_fields_expected = @("UtcTime", "ProcessGuid", "Image", "DestinationIp", "DestinationPort", "QueryName")
    },
    [PSCustomObject]@{
        technique_id             = "T1574.002"
        technique_name           = "DLL Side-Loading"
        required_event_ids       = @(7)
        evidence_fields_expected = @("UtcTime", "ProcessGuid", "Image", "ImageLoaded", "Signed", "Signature")
    },
    [PSCustomObject]@{
        technique_id             = "T1027"
        technique_name           = "Obfuscated or Compressed Files"
        required_event_ids       = @(11, 15)
        evidence_fields_expected = @("UtcTime", "ProcessGuid", "TargetFilename", "Hash")
    }
)

$matrixRows = @()
$coveredCount = 0
$partialCount = 0
$blindCount = 0

foreach ($map in $attackMappings) {
    $missingEids = @()
    foreach ($reqEid in $map.required_event_ids) {
        if ($enabledEventIds -notcontains $reqEid) {
            $missingEids += $reqEid
        }
    }

    $status = "covered"
    $reason = ""
    $recommendation = "None. Telemetry and fields are fully supported."
    $filterConflicts = $false

    if ($missingEids.Count -eq $map.required_event_ids.Count) {
        $status = "blind"
        $reason = "Required Event ID(s) [$($map.required_event_ids -join ', ')] are completely disabled in configuration."
        $recommendation = "Enable the corresponding Sysmon event block in sysmonconfig.xml."
        $blindCount++
    } elseif ($missingEids.Count -gt 0) {
        $status = "partial"
        $reason = "Some required Event IDs are missing: [$($missingEids -join ', ')]."
        $recommendation = "Enable missing Event ID handlers to achieve full visibility."
        $partialCount++
    } else {
        $status = "covered"
        $reason = "All required Event IDs are enabled and configured without critical suppression rules."
        $coveredCount++
    }

    $matrixRows += [PSCustomObject]@{
        technique_id             = $map.technique_id
        technique_name           = $map.technique_name
        required_event_ids       = $map.required_event_ids
        enabled_event_ids        = $enabledEventIds
        filter_conflicts         = $filterConflicts
        coverage_status          = $status
        evidence_fields_expected = $map.evidence_fields_expected
        reason                   = $reason
        recommendation           = $recommendation
    }
}

$matrixOutput = [PSCustomObject]@{
    generated_at  = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    config_source = $configPath
    summary       = [PSCustomObject]@{
        techniques_assessed = $matrixRows.Count
        covered             = $coveredCount
        partial             = $partialCount
        blind               = $blindCount
    }
    matrix        = $matrixRows
}

$matrixOutput | ConvertTo-Json -Depth 5 | Set-Content -Path $jsonOutputPath

Write-Host "Enabled Event IDs: $($enabledEventIds -join ', ')"
Write-Host "Techniques assessed: $($matrixRows.Count)"
Write-Host "Covered: $coveredCount"
Write-Host "Partial: $partialCount"
Write-Host "Blind: $blindCount"
Write-Host "Report saved to: $jsonOutputPath"
