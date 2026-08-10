<#
.SYNOPSIS
    0-sysmon_validation.ps1
.DESCRIPTION
    Validates Sysmon telemetry by triggering actions for Event IDs 1, 3, 11, 13, and 22.
.NOTES
    Repository: dlh-cyber_security
    Directory: blue_team/2x02_eyes_on_endpoint
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

Write-Host "[*] Running Sysmon telemetry validation..."

$LogName = "Microsoft-Windows-Sysmon/Operational"
$passCount = 0
$missCount = 0

function Test-SysmonEventValidation {
    param([int]$EventID, [scriptblock]$Action, [string]$Description, [string]$DetailField)
    
    $timestamp = Get-Date
    & $Action
    Start-Sleep -Seconds 2
    
    try {
        $events = Get-WinEvent -LogName $LogName -FilterXPath "*[System[(EventID=$EventID)]]" -MaxEvents 5 -ErrorAction Stop
        foreach ($evt in $events) {
            if ($evt.TimeCreated -ge $timestamp.AddSeconds(-15)) {
                $xml = [xml]$evt.ToXml()
                $dataNodes = $xml.Event.EventData.Data
                foreach ($node in $dataNodes) {
                    if ($node.Name -eq $DetailField) {
                        Write-Host "    $Description -> Sysmon EID $EventID captured, details present   [PASS]"
                        script:passCount++
                        return
                    }
                }
            }
        }
    } catch {}
    
    Write-Host "    $Description -> Sysmon EID $EventID NOT captured                [FAIL]"
    script:missCount++
}

# [1/5] Process creation (Event ID 1)
Write-Host "    [1/5] Process creation (Event ID 1)..."
Test-SysmonEventValidation -EventID 1 -Action { Start-Process cmd.exe -ArgumentList "/c whoami" -NoNewWindow -Wait } -Description "cmd.exe /c whoami" -DetailField "CommandLine"

# [2/5] Network connection (Event ID 3)
Write-Host "    [2/5] Network connection (Event ID 3)..."
Test-SysmonEventValidation -EventID 3 -Action { Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue | Out-Null } -Description "Outbound TCP" -DetailField "DestinationIp"

# [3/5] File creation (Event ID 11)
Write-Host "    [3/5] File creation (Event ID 11)..."
$testFile = "C:\Windows\Temp\test.txt"
Test-SysmonEventValidation -EventID 11 -Action { Set-Content -Path $testFile -Value "test" } -Description "$testFile" -DetailField "TargetFilename"

# [4/5] Registry modification (Event ID 13)
Write-Host "    [4/5] Registry modification (Event ID 13)..."
$regPath = "Registry::HKEY_CURRENT_USER\Software\SysmonTest"
Test-SysmonEventValidation -EventID 13 -Action {
    if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }
    Set-ItemProperty -Path $regPath -Name "Val" -Value "1"
} -Description "HKCU\...\SysmonTest" -DetailField "TargetObject"

# [5/5] DNS query (Event ID 22)
Write-Host "    [5/5] DNS query (Event ID 22)..."
Test-SysmonEventValidation -EventID 22 -Action { Resolve-DnsName -Name "example.com" -ErrorAction SilentlyContinue | Out-Null } -Description "nslookup example.com" -DetailField "QueryName"

Write-Host "[*] Cleanup: removing test artifacts..."
if (Test-Path $testFile) { Remove-Item $testFile -Force -ErrorAction SilentlyContinue }
if (Test-Path $regPath) { Remove-Item $regPath -Recurse -Force -ErrorAction SilentlyContinue }

$totalTested = $passCount + $missCount
Write-Host "Actions tested: $totalTested | Captured: $passCount | Missed: $missCount"
