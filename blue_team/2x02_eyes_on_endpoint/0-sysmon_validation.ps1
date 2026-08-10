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

# Ensure running with Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as an Administrator to query Sysmon logs and perform certain test actions."
    exit 1
}

$LogName = "Microsoft-Windows-Sysmon/Operational"
$results = @()

Write-Host "[*] Running Sysmon telemetry validation..." -ForegroundColor Cyan

# Helper function to check for recent Sysmon events
function Test-SysmonEvent {
    param (
        [int]$EventID,
        [scriptblock]$Action,
        [string]$Description,
        [scriptblock]$ValidationCriteria
    )

    # Get the latest event record number or timestamp before action
    $beforeTime = Get-Date

    # Execute the trigger action
    & $Action

    # Give Sysmon a brief moment to write to the event log
    Start-Sleep -Seconds 2

    # Query the event log for events matching the ID after our action timestamp
    try {
        $events = Get-WinEvent -LogName $LogName -FilterXPath "*[System[(EventID=$EventID) and TimeCreated[timediff(@SystemTime) <= 10000]]]" -ErrorAction Stop
        
        if ($events) {
            foreach ($evt in $events) {
                $xml = [xml]$evt.ToXml()
                # Run custom validation criteria if provided
                if ($null -eq $ValidationCriteria -or (& $ValidationCriteria $xml)) {
                    Write-Host "    $Description -> Sysmon EID $EventID captured, details present" -ForegroundColor Green
                    return $true
                }
            }
        }
    }
    catch {
        # Catch if no events found or log error
    }

    Write-Host "    $Description -> Sysmon EID $EventID NOT captured or missing details" -ForegroundColor Red
    return $false
}

# [1/5] Process creation (Event ID 1)
Write-Host "    [1/5] Process creation (Event ID 1)..." -NoNewline
$action1 = {
    Start-Process -FilePath "cmd.exe" -ArgumentList "/c whoami" -NoNewWindow -Wait
}
$pass1 = Test-SysmonEvent -EventID 1 -Action $action1 -Description "cmd.exe /c whoami" -ValidationCriteria {
    param($xml)
    $cmdLine = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'CommandLine' }
    return ($cmdLine -like '*cmd.exe*whoami*')
}
if (-not $pass1) { $results += [PSCustomObject]@{ Test="Process Creation"; Status="FAIL" } } else { $results += [PSCustomObject]@{ Test="Process Creation"; Status="PASS" } }


# [2/5] Network connection (Event ID 3)
Write-Host "    [2/5] Network connection (Event ID 3)..." -NoNewline
$action2 = {
    # Perform a quick TCP connection test to an external or local routable address
    Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue | Out-Null
}
$pass2 = Test-SysmonEvent -EventID 3 -Action $action2 -Description "Outbound TCP" -ValidationCriteria {
    param($xml)
    $destinationIp = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'DestinationIp' }
    return ($destinationIp -ne $null)
}
if (-not $pass2) { $results += [PSCustomObject]@{ Test="Network Connection"; Status="FAIL" } } else { $results += [PSCustomObject]@{ Test="Network Connection"; Status="PASS" } }


# [3/5] File creation (Event ID 11)
Write-Host "    [3/5] File creation (Event ID 11)..." -NoNewline
$testFile = "C:\Windows\Temp\test.txt"
$action3 = {
    Set-Content -Path $testFile -Value "Sysmon validation test file."
}
$pass3 = Test-SysmonEvent -EventID 11 -Action $action3 -Description "$testFile" -ValidationCriteria {
    param($xml)
    $targetFilename = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetFilename' }
    return ($targetFilename -like '*test.txt*')
}
if (-not $pass3) { $results += [PSCustomObject]@{ Test="File Creation"; Status="FAIL" } } else { $results += [PSCustomObject]@{ Test="File Creation"; Status="PASS" } }


# [4/5] Registry modification (Event ID 13)
Write-Host "    [4/5] Registry modification (Event ID 13)..." -NoNewline
$regPath = "Registry::HKEY_CURRENT_USER\Software\SysmonTest"
$action4 = {
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "ValidationKey" -Value "TestValue"
}
$pass4 = Test-SysmonEvent -EventID 13 -Action $action4 -Description "HKCU\...\SysmonTest" -ValidationCriteria {
    param($xml)
    $targetObject = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'TargetObject' }
    return ($targetObject -like '*SysmonTest*')
}
if (-not $pass4) { $results += [PSCustomObject]@{ Test="Registry Modification"; Status="FAIL" } } else { $results += [PSCustomObject]@{ Test="Registry Modification"; Status="PASS" } }


# [5/5] DNS query (Event ID 22)
Write-Host "    [5/5] DNS query (Event ID 22)..." -NoNewline
$action5 = {
    Resolve-DnsName -Name "example.com" -Type A -ErrorAction SilentlyContinue | Out-Null
}
$pass5 = Test-SysmonEvent -EventID 22 -Action $action5 -Description "nslookup example.com" -ValidationCriteria {
    param($xml)
    $queryName = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'QueryName' }
    return ($queryName -like '*example.com*')
}
if (-not $pass5) { $results += [PSCustomObject]@{ Test="DNS Query"; Status="FAIL" } } else { $results += [PSCustomObject]@{ Test="DNS Query"; Status="PASS" } }


# Cleanup phase
Write-Host "[*] Cleanup: removing test artifacts..." -ForegroundColor Cyan
if (Test-Path $testFile) {
    Remove-Item -Path $testFile -Force -ErrorAction SilentlyContinue
}
if (Test-Path $regPath) {
    Remove-Item -Path $regPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Summary calculation
$totalTested = $results.Count
$totalCaptured = ($results | Where-Object { $_.Status -eq "PASS" }).Count
$totalMissed = $totalTested - $totalCaptured

Write-Host "Actions tested: $totalTested | Captured: $totalCaptured | Missed: $totalMissed" -ForegroundColor Yellow
