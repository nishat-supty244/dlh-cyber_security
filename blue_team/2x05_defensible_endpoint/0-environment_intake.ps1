<#
.SYNOPSIS
Captures the unhardened state of the Windows endpoint.
#>

$OutputFile = "intake_windows_$($env:COMPUTERNAME)_$([DateTimeOffset]::Now.ToUnixTimeSeconds()).txt"
Write-Host "Starting Windows Environment Intake. Writing to $OutputFile..."

$Output = @()

$Output += "=== SYSTEM INFO ==="
$os = Get-CimInstance Win32_OperatingSystem
$Output += "Hostname: $($os.CSName)"
$Output += "OS Build: $($os.Version) / $($os.BuildNumber)"
$hotfixes = Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5
$Output += "Latest Patches: $($hotfixes.HotFixID -join ', ')"

$Output += "`n=== INSTALLED FEATURE COUNT ==="
if ($os.Caption -match "Server") {
    $Output += (Get-WindowsFeature | Where-Object InstallState -eq 'Installed').Count
} else {
    $Output += (Get-WindowsOptionalFeature -Online | Where-Object State -eq 'Enabled').Count
}

$Output += "`n=== RUNNING SERVICES ==="
$Output += (Get-Service | Where-Object Status -eq 'Running' | Select-Object Name, DisplayName | Out-String)

$Output += "`n=== LOCAL USER ACCOUNTS ==="
$Output += (Get-LocalUser | Select-Object Name, Enabled, Description | Out-String)

$Output += "`n=== WINDOWS FIREWALL STATE ==="
$Output += (Get-NetFirewallProfile | Select-Object Name, Enabled, DefaultInboundAction | Out-String)

$Output += "`n=== AUDIT POLICY SUMMARY ==="
$Output += (auditpol /get /category:* | Out-String)

$Output += "`n=== SYSMON PRESENCE ==="
$sysmon = Get-Service Sysmon -ErrorAction SilentlyContinue
if ($sysmon) {
    $Output += "Sysmon Service: $($sysmon.Status)"
    $log = Get-WinEvent -ListLog "Microsoft-Windows-Sysmon/Operational" -ErrorAction SilentlyContinue
    $Output += "Event Channel Size (Bytes): $($log.MaximumSizeInBytes)"
} else {
    $Output += "Sysmon is not installed."
}

$Output += "`n=== POWERSHELL LOGGING STATE ==="
$regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
if (Test-Path $regPath) {
    $val = (Get-ItemProperty -Path $regPath -Name EnableScriptBlockLogging -ErrorAction SilentlyContinue).EnableScriptBlockLogging
    $Output += "ScriptBlockLogging Enabled: $($val -eq 1)"
} else {
    $Output += "ScriptBlockLogging Registry Key: Not Configured"
}

$Output += "`n=== ACCOUNT LOCKOUT AND PASSWORD POLICY ==="
$Output += (net accounts | Out-String)

$Output | Out-File -FilePath $OutputFile -Encoding UTF8
Write-Host "Windows Intake complete."
