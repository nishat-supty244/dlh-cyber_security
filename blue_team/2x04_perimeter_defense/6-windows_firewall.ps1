<#
.SYNOPSIS
    Aligns Windows Firewall to the MedDefense segmentation design using segmentation_rules.json.
.DESCRIPTION
    Reads segmentation_rules.json, sets profile defaults, enables dropped packet logging,
    cleans up old rules, creates inbound rules with exact naming conventions, and exports rules as JSON.
#>

$ErrorActionPreference = "Stop"
$RulesJsonPath = "segmentation_rules.json"
$ExportJsonPath = "windows_firewall_rules.json"

if (-not (Test-Path -Path $RulesJsonPath)) {
    Write-Error "[-] Error: $RulesJsonPath not found. Run task 2 first."
    exit 1
}

Write-Host "[*] Reading $RulesJsonPath..."
$Config = Get-Content -Path $RulesJsonPath -Raw | ConvertFrom-Json

Write-Host "[*] Setting profile defaults..."
$Profiles = @("Domain", "Private", "Public")
foreach ($Profile in $Profiles) {
    Set-NetFirewallProfile -Profile $Profile -DefaultInboundAction Block -DefaultOutboundAction Allow
    Set-NetFirewallProfile -Profile $Profile -LogBlocked True -LogFileName "%systemroot%\system32\LogFiles\Firewall\meddefense.log"
    Write-Host "  $Profile`:  DefaultInboundAction=Block  LogBlocked=True   [SET]"
}

Write-Host "[*] Clearing previous MedDefense-* rules..."
$ExistingRules = Get-NetFirewallRule -DisplayName "MedDefense-*" -ErrorAction SilentlyContinue
$RemovedCount = 0
if ($ExistingRules) {
    $RemovedCount = @($ExistingRules).Count
    $ExistingRules | Remove-NetFirewallRule
}
Write-Host "  [$RemovedCount removed]"

Write-Host "[*] Creating rules from flow matrix..."

$ZoneCidrs = @{}
foreach ($Zone in $Config.zones) {
    $ZoneCidrs[$Zone.name] = $Zone.cidr
}
$ZoneCidrs["ALL"] = $null

foreach ($Flow in $Config.flows) {
    if ($Flow.action -eq "allow") {
        $SrcZone = $Flow.src_zone
        $Proto = $Flow.proto
        $DPort = $Flow.dport
        
        $DisplayName = "MedDefense-$SrcZone-$($Proto.ToUpper())-$DPort"
        
        $RemoteAddr = $null
        if ($ZoneCidrs.ContainsKey($SrcZone)) {
            $RemoteAddr = $ZoneCidrs[$SrcZone]
        }

        $RuleParams = @{
            DisplayName  = $DisplayName
            Description  = "MedDefense automated rule for $SrcZone to host on $Proto/$DPort"
            Direction    = "Inbound"
            Action       = "Allow"
            Protocol     = $Proto
            LocalPort    = $DPort
            Profile      = "Any"
        }

        if ($RemoteAddr -and $RemoteAddr -ne "0.0.0.0/0") {
            $RuleParams["RemoteAddress"] = $RemoteAddr
        }

        try {
            New-NetFirewallRule @RuleParams -ErrorAction Stop | Out-Null
            Write-Host "  $DisplayName    Inbound Allow $Proto $DPort    [CREATED]"
        } catch {
            Write-Warning "  Failed to create rule $DisplayName`: $_"
        }
    }
}

Write-Host "[*] Exporting resulting Windows Firewall rules as JSON to $ExportJsonPath..."
Get-NetFirewallRule -DisplayName "MedDefense-*" | Select-Object Name, DisplayName, Enabled, Direction, Action, Profile | ConvertTo-Json -Depth 3 | Set-Content -Path $ExportJsonPath

Write-Host "[*] Windows firewall alignment and export completed successfully."
