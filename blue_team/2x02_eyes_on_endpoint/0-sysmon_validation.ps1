<#
.SYNOPSIS
    Sysmon Telemetry Validation Script
.DESCRIPTION
    Triggers specific security-relevant actions and verifies that Sysmon captures 
    them with the expected Event IDs and detail levels.
.NOTES
    Repository: dlh-cyber_security
    Directory: blue_team/2x02_eyes_on_endpoint
    File: 0-sysmon_validation.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

# Ensure running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator."
    exit 1
}

$LogName = "Microsoft-Windows-Sysmon/Operational"
$results = @()

Write-Host "[*] Running Sysmon telemetry validation..."

# Helper function to check for recent Sysmon events
function Test-SysmonEvent {
    param (
        [int]$EventID,
        [scriptblock]$Action,
        [string]$Description,
        [scriptblock]$ValidationCriteria
    )

    $beforeTime = (Get-Date).AddSeconds(-5)
    & $Action
    Start-Sleep -Seconds 2

    try {
        $events = Get-WinEvent -LogName $LogName -FilterXPath "*[System[(EventID=$EventID)]]" -MaxEvents 5 -ErrorAction Stop
        foreach ($evt in $events) {
            if ($evt.TimeCreated -ge $beforeTime) {
                $xml = [xml]$evt.ToXml()
                if ($null -eq $ValidationCriteria -or (& $ValidationCriteria $xml)) {
                    return $true
                }
            }
        }
    }
    catch {}
    return $false
}

# [1/5] Process creation (Event ID 1)
Write-Host "    [1/5] Process creation (Event ID 1)..."
$action1 = { Start-Process -FilePath "cmd.exe" -ArgumentList "/c whoami" -NoNewWindow -Wait }
$pass1 = Test-SysmonEvent -EventID 1 -Action $action1 -Description "cmd.exe /c whoami" -ValidationCriteria {
    param($xml)
    $cmdLine = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'CommandLine' }
    return ($cmdLine -like '*cmd.exe*whoami*')
}
if ($pass1) {
    Write-Host "          cmd.exe /c whoami -> Sysmon EID 1 captured, cmdline present   [PASS]"
    $results += "PASS"
} else {
    Write-Host "          cmd.exe /c whoami -> Sysmon EID 1 NOT captured                [FAIL]"
    $results += "FAIL"
}

# [2/5] Network connection (Event ID 3)
Write-Host "    [2/5] Network connection (Event ID 3)..."
$action2 = { Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue | Out-Null }
$pass2 = Test-SysmonEvent -EventID 3 -Action $action2 -Description "Outbound TCP" -ValidationCriteria {
    param($xml)
    $destIp = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'DestinationIp' }
    return ($destIp -ne $null)
}
if ($pass2) {
    Write-Host "          Outbound TCP -> Sysmon EID 3 captured, dest IP/port present   [PASS]"
    $results += "PASS"
} else {
    Write-Host "          Outbound TCP -> Sysmon EID 3 NOT captured                     [FAIL]"
    $results += "FAIL"
}

# [3/5] File creation (Event ID 11)
Write-Host "    [3/5] File creation (Event ID 11)..."
$testFile = "C:\Windows\Temp\test.txt"
$action3 = { Set-Content -Path $testFile -Value "Sysmon validation test file." }
$pass3 = Test-SysmonEvent -EventID 11 -Action $action3 -Description "$testFile" -ValidationCriteria {
    param($xml)
    $targetFilename = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetFilename' }
    return ($targetFilename -like '*test.txt*')
}
if ($pass3) {
    Write-Host "          C:\Windows\Temp\test.txt -> Sysmon EID 11 captured            [PASS]"
    $results += "PASS"
} else {
    Write-Host "          C:\Windows\Temp\test.txt -> Sysmon EID 11 NOT captured        [FAIL]"
    $results += "FAIL"
}

# [4/5] Registry modification (Event ID 13)
Write-Host "    [4/5] Registry modification (Event ID 13)..."
$regPath = "Registry::HKEY_CURRENT_USER\Software\SysmonTest"
$action4 = {
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "ValidationKey" -Value "TestValue"
}
$pass4 = Test-SysmonEvent -EventID 13 -Action $action4 -Description "HKCU\...\SysmonTest" -ValidationCriteria {
    param($xml)
    $targetObject = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetObject' }
    return ($targetObject -like '*SysmonTest*')
}
if ($pass4) {
    Write-Host "          HKCU\...\SysmonTest -> Sysmon EID 13 captured                 [PASS]"
    $results += "PASS"
} else {
    Write-Host "          HKCU\...\SysmonTest -> Sysmon EID 13 NOT captured             [FAIL]"
    $results += "FAIL"
}

# [5/5] DNS query (Event ID 22)
Write-Host "    [5/5] DNS query (Event ID 22)..."
$action5 = { Resolve-DnsName -Name "example.com" -Type A -ErrorAction SilentlyContinue | Out-Null }
$pass5 = Test-SysmonEvent -EventID 22 -Action $action5 -Description "nslookup example.com" -ValidationCriteria {
    param($xml)
    $queryName = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'QueryName' }
    return ($queryName -like '*example.com*')
}
if ($pass5) {
    Write-Host "          nslookup example.com -> Sysmon EID 22 captured                [PASS]"
    $results += "PASS"
} else {
    Write-Host "          nslookup example.com -> Sysmon EID 22 NOT captured            [FAIL]"
    $results += "FAIL"
}

# Cleanup phase
Write-Host "[*] Cleanup: removing test artifacts..."
if (Test-Path $testFile) { Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue }
if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue }

$totalTested = 5
$totalCaptured = ($results | Where-Object { $_ -eq "PASS" }).Count
$totalMissed = $totalTested - $totalCaptured

Write-Host "Actions tested: $totalTested | Captured: $totalCaptured | Missed: $totalMissed"
