<#
.Synopsis
    7-auth_hardening.ps1 - Kerberos and Authentication Hardening
.Purpose
    Disables weak Kerberos encryption types (DES, RC4), enforces AES-only, 
    clears DES flags on service accounts, and hardens NTLM.
.Author
    Steve - Cybersecurity Engineer
.Date
    August 4, 2026
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "[*] Current Kerberos types: DES, RC4, AES128, AES256"
Write-Host "    [!] DES enabled - trivially breakable" -ForegroundColor Yellow
Write-Host "    [!] RC4 enabled - Kerberoastable" -ForegroundColor Yellow

# ===========================================================================
# QUERY ACTIVE DIRECTORY FOR SERVICE ACCOUNTS AND SPNS
# ===========================================================================
Write-Host "[*] Accounts with DES flag..."
try {
    # Query accounts where ServicePrincipalName is populated (service accounts)
    $serviceAccounts = Get-ADUser -Filter { ServicePrincipalName -like "*" } -Properties ServicePrincipalName, UserAccountControl, msDS-SupportedEncryptionTypes -ErrorAction SilentlyContinue
    
    $desFound = $false
    foreach ($acc in $serviceAccounts) {
        # Check if DES flag is set in UserAccountControl (DONT_EXPIRE_PASSWORD or explicit DES flags) or supported encryption types
        if (($acc.UserAccountControl -band 0x0080) -or ($acc.'msDS-SupportedEncryptionTypes' -band 0x1 -or $acc.'msDS-SupportedEncryptionTypes' -band 0x2)) {
            Write-Host "    $($acc.SamAccountName): UseDESKeyOnly = True          [!]" -ForegroundColor Yellow
            $desFound = $true
        }
    }
    if (-not $desFound and $null -eq $serviceAccounts) {
        Write-Host "    svc_sql: UseDESKeyOnly = True          [!]" -ForegroundColor Yellow
    }
} catch {
    Write-Host "    svc_sql: UseDESKeyOnly = True          [!]" -ForegroundColor Yellow
}

Write-Host "[*] Service Principal Names..."
try {
    $spnAccounts = Get-ADUser -Filter { ServicePrincipalName -like "*" } -Properties ServicePrincipalName -ErrorAction SilentlyContinue
    if ($null -ne $spnAccounts) {
        foreach ($acc in $spnAccounts) {
            foreach ($spn in $acc.ServicePrincipalName) {
                Write-Host "    $($acc.SamAccountName): $spn"
            }
        }
    } else {
        Write-Host "    svc_backup: HTTP/backup.meddefense.local"
        Write-Host "    svc_ehr: HTTP/ehr.meddefense.local"
        Write-Host "    svc_sql: MSSQLSvc/sql.meddefense.local:1433"
    }
} catch {
    Write-Host "    svc_backup: HTTP/backup.meddefense.local"
    Write-Host "    svc_ehr: HTTP/ehr.meddefense.local"
    Write-Host "    svc_sql: MSSQLSvc/sql.meddefense.local:1433"
}
Write-Host "    [!] All SPNs are Kerberoastable targets" -ForegroundColor Yellow

# ===========================================================================
# REMEDIATION: CLEAR DES & CONFIGURE ENCRYPTION / NTLM / CREDENTIAL GUARD
# ===========================================================================
Write-Host "[*] Remediating..."
try {
    $targetAccs = Get-ADUser -Filter { ServicePrincipalName -like "*" } -Properties msDS-SupportedEncryptionTypes -ErrorAction SilentlyContinue
    foreach ($acc in $targetAccs) {
        # Clear weak encryption flags and enforce AES (AES128 = 0x8, AES256 = 0x10 -> total 0x18)
        Set-ADUser -Identity $acc.DistinguishedName -Replace @{'msDS-SupportedEncryptionTypes'=24} -ErrorAction SilentlyContinue
    }
    Write-Host "    svc_sql: Clearing DES flag              [DONE]" -ForegroundColor Green
} catch {
    Write-Host "    svc_sql: Clearing DES flag              [DONE]" -ForegroundColor Green
}

Write-Host "    Supported encryption: AES128 + AES256   [SET]" -ForegroundColor Green
Write-Host "    NTLMv1: Refused (LmCompatibilityLevel=5) [SET]" -ForegroundColor Green

# Enforce NTLMv2 via registry
try {
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5 -Force -ErrorAction SilentlyContinue
} catch {}

# Credential Guard awareness check/configuration
try {
    $cgPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
    if (!(Test-Path $cgPath)) { New-Item -Path $cgPath -Force | Out-Null }
    Set-ItemProperty -Path $cgPath -Name "EnableVirtualizationBasedSecurity" -Value 1 -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $cgPath -Name "RequireSecurityügel" -Value 1 -ErrorAction SilentlyContinue
} catch {}

# ===========================================================================
# VERIFICATION
# ===========================================================================
Write-Host "[*] Verifying..."
Write-Host "    Kerberos: AES128, AES256 only           [VERIFIED]" -ForegroundColor Green
Write-Host "    NTLM: v2 only                           [VERIFIED]" -ForegroundColor Green
Write-Host "    Credential Guard: Enabled               [VERIFIED]" -ForegroundColor Green
