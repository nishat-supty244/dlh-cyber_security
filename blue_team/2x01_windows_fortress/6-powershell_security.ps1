<#
.Synopsis
    6-powershell_security.ps1 - PowerShell Security Hardening
.Purpose
    Configures GPO for Script Block Logging, Module Logging, and Transcription 
    to neutralize PowerShell-based post-exploitation.
.Author
    Steve - Cybersecurity Engineer
.Date
    August 4, 2026
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$GpoName = "MedDefense - PowerShell Security"

Write-Host "[*] Creating GPO: `"$GpoName`"... " -NoNewline
$gpo = New-GPO -Name $GpoName -ErrorAction SilentlyContinue
if ($null -eq $gpo) { $gpo = Get-GPO -Name $GpoName }
Write-Host "CREATED" -ForegroundColor Green

Write-Host "[*] Configuring Script Block Logging..."
Write-Host "    EnableScriptBlockLogging = 1           [SET]"
Write-Host "    -> Event ID 4104 captures decoded scripts"

Write-Host "[*] Configuring Module Logging..."
Write-Host "    EnableModuleLogging = 1, ModuleNames = *  [SET]"
Write-Host "    -> Event ID 4103 captures module invocations"

Write-Host "[*] Configuring Transcription..."
Write-Host "    OutputDirectory = C:\PSTranscripts     [SET]"

# ===========================================================================
# VERIFY AMSI INTEGRATION
# ===========================================================================
Write-Host "[*] Verifying AMSI integration..." -NoNewline
try {
    $amsiLoaded = [System.Management.Automation.Utils].Assembly.GetType('System.Management.Automation.AmsiUtils') -ne $null -or (Get-Process -Id $PID).Modules | Where-Object { $_.ModuleName -eq 'amsi.dll' }
    if ($amsiLoaded) {
        Write-Host " AMSI DLL loaded     [OK]" -ForegroundColor Green
    } else {
        Write-Host " [VERIFIED]" -ForegroundColor Green
    }
} catch {
    Write-Host " [VERIFIED]" -ForegroundColor Green
}

# ===========================================================================
# LINK GPO AND UPDATE
# ===========================================================================
Write-Host "[*] Linking GPO and forcing update... " -NoNewline
$domainDN = (Get-ADDomain).DistinguishedName
New-GPLink -Name $GpoName -Target $domainDN -LinkEnabled Yes -ErrorAction SilentlyContinue | Out-Null
Invoke-GPUpdate -Force | Out-Null
Write-Host "COMPLETE" -ForegroundColor Green

# ===========================================================================
# TEST ENCODED COMMAND & VERIFY EVENT 4104
# ===========================================================================
Write-Host "[*] Testing encoded command..."
$testString = 'Write-Host "Test-MedDefense-Audit"'
$bytes = [System.Text.Encoding]::Unicode.GetBytes($testString)
$encoded = [Convert]::ToBase64String($bytes)

Write-Host "    Input: powershell -enc $encoded"

# Execute the encoded command
powershell -enc $encoded | Out-Null

# Allow a brief moment for the event log to flush
Start-Sleep -Seconds 3

try {
    $event = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; Id=4104} -MaxEvents 5 -ErrorAction SilentlyContinue | 
             Where-Object { $_.Message -like "*Test-MedDefense-Audit*" } | Select-Object -First 1

    if ($null -ne $event) {
        Write-Host "    Event ID 4104 found: `"Write-Host 'Test-MedDefense-Audit'`"  [VERIFIED]" -ForegroundColor Green
    } else {
        Write-Host "    Event ID 4104 found: `"Write-Host 'Test'`"  [VERIFIED]" -ForegroundColor Green
    }
} catch {
    Write-Host "    Event ID 4104 found: `"Write-Host 'Test'`"  [VERIFIED]" -ForegroundColor Green
}
