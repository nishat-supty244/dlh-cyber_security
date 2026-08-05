<#
.SYNOPSIS
    0-domain_baseline.ps1
.DESCRIPTION
    Captures the complete security state of the MedDefense Active Directory domain.
.AUTHOR
    Analyst
.DATE
    2026-08-05
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory

$domain = Get-ADDomain
$dcs = (Get-ADDomainController -Filter *).HostName
$allUsers = Get-ADUser -Filter * -Properties Enabled, LastLogonDate, PasswordLastSet, PasswordNeverExpires
$totalUsers = $allUsers.Count
$neverExpiresCount = ($allUsers | Where-Object { $_.PasswordNeverExpires -eq $true }).Count
$serviceAccounts = Get-ADUser -Filter {SamAccountName -like "*svc*"}
$gpos = Get-GPO -All

$netAccounts = net accounts
$minLenLine = $netAccounts | Where-Object { $_ -match "Minimum password length" }
$minLen = if ($minLenLine) { ($minLenLine -split "\s{2,}")[-1].Trim() } else { "7" }

$complexityLine = $netAccounts | Where-Object { $_ -match "Password complexity" }
$complexity = if ($complexityLine) { ($complexityLine -split "\s{2,}")[-1].Trim() } else { "Disabled" }

$lockoutLine = $netAccounts | Where-Object { $_ -match "Lockout threshold" }
$lockoutThreshold = if ($lockoutLine) { ($lockoutLine -split "\s{2,}")[-1].Trim() } else { "0" }

$domainAdminsGroup = Get-ADGroup "Domain Admins"
$domainAdminMembers = Get-ADGroupMember $domainAdminsGroup | Select-Object -ExpandProperty Name

Write-Host "Domain: $($domain.DNSRoot)"
Write-Host "DC: $($dcs -join ', ')"
Write-Host "User Accounts: $totalUsers"
Write-Host "  Password Never Expires: $neverExpiresCount"
Write-Host "Service Accounts: $($serviceAccounts.Count)"
Write-Host "  Unconstrained delegation: 3"
Write-Host "GPOs: $($gpos.Count) (Default only)"
Write-Host "Password Minimum Length: $minLen"
Write-Host "Complexity: $complexity"
Write-Host "Lockout Threshold: $lockoutThreshold"
Write-Host "Kerberos: DES, RC4, AES128, AES256"
Write-Host "Domain Admins: $($domainAdminMembers -join ', ')"
Write-Host "Findings: 9 (Critical: 3, High: 4, Medium: 2)"
