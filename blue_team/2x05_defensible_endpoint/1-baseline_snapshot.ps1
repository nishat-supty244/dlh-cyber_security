# Path: C:\dlh-cyber_security\blue_team\2x05_defensible_endpoint\1-baseline_snapshot.ps1

$ErrorActionPreference = "Stop"

$OutputDir = "capstone/baseline"
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$LogPath = "$OutputDir/windows_baseline.log"
$JsonPath = "$OutputDir/baseline_windows.json"

# Resolve win_audit.ps1 dynamically across Windows and Linux-style paths
$CandidatePaths = @(
    "/home/analyst/MedDefense_Lab/capstone/win_audit.ps1",
    "C:\home\analyst\MedDefense_Lab\capstone\win_audit.ps1",
    "C:\MedDefense_Lab\capstone\win_audit.ps1",
    "C:\capstone\win_audit.ps1",
    "$PSScriptRoot\win_audit.ps1"
)

$AuditHelper = $CandidatePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $AuditHelper) {
    Write-Host "Searching C:\ drive for win_audit.ps1..."
    $AuditHelper = (Get-ChildItem -Path C:\ -Filter "win_audit.ps1" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}

if (-not $AuditHelper -or -not (Test-Path $AuditHelper)) {
    throw "Unable to locate win_audit.ps1. Please ensure win_audit.ps1 is downloaded on this host."
}

Write-Host "Running Windows CIS baseline audit on $env:COMPUTERNAME using $AuditHelper..."

# Execute audit helper and capture output as a string array
[string[]]$AuditOutput = & $AuditHelper

# Save raw log output
$AuditOutput | Out-File -FilePath $LogPath -Encoding UTF8

$PassCount = 0
$FailCount = 0
$NaCount = 0

foreach ($Line in $AuditOutput) {
    if ($Line -match "\bPASS\b") { $PassCount++ }
    elseif ($Line -match "\bFAIL\b") { $FailCount++ }
    elseif ($Line -match "\bNOT_APPLICABLE\b") { $NaCount++ }
}

$ControlsTotal = $PassCount + $FailCount + $NaCount
$PassRatePercent = 0

if ($ControlsTotal -gt 0) {
    $PassRatePercent = [math]::Round((($PassCount / $ControlsTotal) * 100), 2)
}

$Timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

$JsonPayload = [ordered]@{
    timestamp         = $Timestamp
    hostname          = $env:COMPUTERNAME
    controls_total    = $ControlsTotal
    pass_count        = $PassCount
    fail_count        = $FailCount
    na_count          = $NaCount
    pass_rate_percent = $PassRatePercent
    log_path          = $LogPath
}

$JsonPayload | ConvertTo-Json -Depth 3 | Out-File -FilePath $JsonPath -Encoding UTF8

Write-Host "Windows baseline snapshot finalized: $JsonPath"
