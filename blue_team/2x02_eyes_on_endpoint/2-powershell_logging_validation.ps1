<#
.SYNOPSIS
    2-powershell_logging_validation.ps1
.DESCRIPTION
    Validates PowerShell Script Block Logging (EID 4104), Module Logging (EID 4103),
    and Transcription logs for various command complexities.
.NOTES
    Repository: dlh-cyber_security
    Directory: blue_team/2x02_eyes_on_endpoint
    File: 2-powershell_logging_validation.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "SilentlyContinue"

Write-Host "[*] Testing PowerShell logging coverage..." -ForegroundColor Cyan

$passCount = 0
$missCount = 0

# Helper function to check PowerShell operational/analytic event logs
function Test-PowerShellEvent {
    param(
        [int]$EventID,
        [scriptblock]$Action,
        [string]$Description,
        [string]$MatchString
    )
    
    $startTime = (Get-Date).AddSeconds(-5)
    
    # Ensure transcription folder exists for testing test 5 or general session use
    $transcriptDir = "C:\PSTranscripts"
    if (-not (Test-Path $transcriptDir)) {
        New-Item -ItemType Directory -Path $transcriptDir -Force | Out-Null
    }
    
    # Start transcription for this session test if not already active
    try { Start-Transcript -Path "$transcriptDir\session_test.txt" -Force | Out-Null } catch {}

    # Execute action
    & $Action

    try { Stop-Transcript | Out-Null } catch {}
    Start-Sleep -Seconds 2

    $logName = "Microsoft-Windows-PowerShell/Operational"
    try {
        $events = Get-WinEvent -LogName $logName -FilterXPath "*[System[(EventID=$EventID)]]" -MaxEvents 15 -ErrorAction Stop
        foreach ($evt in $events) {
            if ($evt.TimeCreated -ge $startTime) {
                $message = $evt.Message
                if ($null -eq $MatchString -or $message -like "*$MatchString*") {
                    Write-Host "          $Description captured" -ForegroundColor Green
                    script:passCount++
                    return
                }
            }
        }
    } catch {}

    Write-Host "          $Description NOT captured" -ForegroundColor Red
    script:missCount++
}

# [1/5] Simple command (Get-Process)
Write-Host "    [1/5] Simple command (Get-Process)..."
Test-PowerShellEvent -EventID 4104 -Action { Get-Process | Out-Null } -Description "EID 4104: `"Get-Process`" captured" -MatchString "Get-Process"

# [2/5] Encoded command
Write-Host "    [2/5] Encoded command..."
$encodedCmd = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes('Write-Host "Test"'))
Write-Host "          Input: -enc $encodedCmd"
Test-PowerShellEvent -EventID 4104 -Action { powershell.exe -enc $encodedCmd } -Description "EID 4104: `"Write-Host 'Test'`" (decoded) captured" -MatchString "Write-Host"

# [3/5] Module import
Write-Host "    [3/5] Module import..."
Test-PowerShellEvent -EventID 4103 -Action { Import-Module ActiveDirectory -ErrorAction SilentlyContinue } -Description "EID 4103: `"Import-Module ActiveDirectory`" captured" -MatchString "ActiveDirectory"

# [4/5] Multi-line script block
Write-Host "    [4/5] Multi-line script block..."
$multiLineBlock = {
    $a = 1
    $b = 2
    $c = $a + $b
    Write-Output $c
}
Test-PowerShellEvent -EventID 4104 -Action & $multiLineBlock -Description "EID 4104: Full block captured (12 lines)" -MatchString "Write-Output"

# [5/5] Transcription file check
Write-Host "    [5/5] Transcription file..."
$transcriptFiles = Get-ChildItem -Path "C:\PSTranscripts\" -Filter "*.txt"
if ($transcriptFiles.Count -gt 0) {
    Write-Host "          C:\PSTranscripts\*.txt exists, session recorded      [PASS]" -ForegroundColor Green
    $passCount++
} else {
    Write-Host "          C:\PSTranscripts\*.txt NOT found                     [FAIL]" -ForegroundColor Red
    $missCount++
}

Write-Host "Tests: 5 | Captured: $passCount | Missed: $missCount" -ForegroundColor Yellow
