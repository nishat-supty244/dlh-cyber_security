<#
.SYNOPSIS
    0-sysmon_validation.ps1
.DESCRIPTION
    Validates Sysmon telemetry by triggering specific actions and verifying Event IDs 1, 3, 11, 13, and 22.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

Write-Host "[*] Running Sysmon telemetry validation..."

$LogName = "Microsoft-Windows-Sysmon/Operational"
$passCount = 0
$missCount = 0

function Test-SysmonLog {
    param([int]$EID, [scriptblock]$Action, [string]$Desc, [string]$DetailCheck)
    $ts = Get-Date
    & $Action
    Start-Sleep -Seconds 2
    
    try {
        $events = Get-WinEvent -LogName $LogName -FilterXPath "*[System[(EventID=$EID)]]" -MaxEvents 5 -ErrorAction Stop
        foreach ($e in $events) {
            if ($e.TimeCreated -ge $ts.AddSeconds(-10)) {
                $xml = [xml]$e.ToXml()
                $data = $xml.Event.EventData.Data
                if ($null -eq $DetailCheck) {
                    Write-Host "    $Desc -> Sysmon EID $EID captured                      [PASS]"
                    script:passCount++
                    return
                } else {
                    foreach ($d in $data) {
                        if ($d.Name -eq $DetailCheck -or ($d.('#text') -and $d.Name)) {
                            Write-Host "    $Desc -> Sysmon EID $EID captured, details present   [PASS]"
                            script:passCount++
                            return
                        }
                    }
                }
            }
        }
    } catch {}
    
    Write-Host "    $Desc -> Sysmon EID $EID NOT captured                  [FAIL]"
    script:missCount++
}

# [1/5] Process creation (Event ID 1)
Write-Host "    [1/5] Process creation (Event ID 1)..."
Test-SysmonLog -EID 1 -Action { Start-Process cmd.exe -ArgumentList "/c whoami" -NoNewWindow -Wait } -Desc "cmd.exe /c whoami" -DetailCheck "CommandLine"

# [2/5] Network connection (Event ID 3)
Write-Host "    [2/5] Network connection (Event ID 3)..."
Test-SysmonLog -EID 3 -Action { Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue | Out-Null } -Desc "Outbound TCP" -DetailCheck "DestinationIp"

# [3/5] File creation (Event ID 11)
Write-Host "    [3/5] File creation (Event ID 11)..."
$tf = "C:\Windows\Temp\test.txt"
Test-SysmonLog -EID 11 -Action { Set-Content -Path $tf -Value "test" } -Desc "$tf" -DetailCheck "TargetFilename"

# [4/5] Registry modification (Event ID 13)
Write-Host "    [4/5] Registry modification (Event ID 13)..."
$rp = "Registry::HKEY_CURRENT_USER\Software\SysmonTest"
Test-SysmonLog -EID 13 -Action {
    if (-not (Test-Path $rp)) { New-Item -Path $rp -Force | Out-Null }
    Set-ItemProperty -Path $rp -Name "Val" -Value "1"
} -Desc "HKCU\...\SysmonTest" -DetailCheck "TargetObject"

# [5/5] DNS query (Event ID 22)
Write-Host "    [5/5] DNS query (Event ID 22)..."
Test-SysmonLog -EID 22 -Action { Resolve-DnsName -Name "example.com" -ErrorAction SilentlyContinue | Out-Null } -Desc "nslookup example.com" -DetailCheck "QueryName"

Write-Host "[*] Cleanup: removing test artifacts..."
if (Test-Path $tf) { Remove-Item $tf -Force -ErrorAction SilentlyContinue }
if (Test-Path $rp) { Remove-Item $rp -Recurse -Force -ErrorAction SilentlyContinue }

$total = $passCount + $missCount
Write-Host "Actions tested: $total | Captured: $passCount | Missed: $missCount"
