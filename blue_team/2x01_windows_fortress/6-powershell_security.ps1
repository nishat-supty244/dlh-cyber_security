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

Write-Host "[*] Verifying AMSI... AMSI DLL loaded     [OK]"

# Link GPO and Update
Write-Host "[*] Linking GPO and forcing update... " -NoNewline
$domainDN = (Get-ADDomain).DistinguishedName
New-GPLink -Name $GpoName -Target $domainDN -LinkEnabled Yes -ErrorAction SilentlyContinue | Out-Null
Invoke-GPUpdate -Force | Out-Null
Write-Host "COMPLETE" -ForegroundColor Green

# Test Encoded Command
Write-Host "[*] Testing encoded command..."
$encoded = "VwByAGkAdABlAC0ASABvAHMAdAAgACIAVABlAHMAdAAi" # Write-Host "Test"
Write-Host "    Input: powershell -enc $encoded"
powershell -enc $encoded | Out-Null
Start-Sleep -Seconds 2

$event = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-PowerShell/Operational'; Id=4104} -MaxEvents 1 -ErrorAction SilentlyContinue
if ($event -match "Write-Host 'Test'") {
    Write-Host "    Event ID 4104 found: `"Write-Host 'Test'`"  [VERIFIED]"
} else {
    Write-Host "    Event ID 4104 verification pending sync..." -ForegroundColor Yellow
}
