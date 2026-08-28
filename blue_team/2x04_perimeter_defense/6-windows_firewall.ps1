<#
.SYNOPSIS
    Aligns Windows Firewall to the MedDefense segmentation design using segmentation_rules.json.
.DESCRIPTION
    Reads segmentation_rules.json, sets profile defaults, enables logging, cleans up old rules,
    and creates new inbound rules matching the flow matrix.
#>

$ErrorActionPreference = "Stop"
$RulesJsonPath = "segmentation_rules.json"

if (-not (Test-Path -Path $RulesJsonPath)) {
    Write-Error "[-] Error: $RulesJsonPath not found in the current directory. Run task 2 first."
    exit 1
}

Write-Host "[*] Reading $RulesJsonPath..." -ForegroundColor Cyan
$Config = Get-Content -Path $RulesJsonPath -Raw | ConvertFrom-Json

Write-Host "[*] Setting profile defaults..." -ForegroundColor Cyan
$Profiles = @("Domain", "Private", "Public")
foreach ($Profile in $Profiles) {
    Set-NetFirewallProfile -Profile $Profile -DefaultInboundAction Block -DefaultOutboundAction Allow -LogBlocked True -LogFileName "%systemroot%\system32\LogFiles\Firewall\meddefense.log"
    Write-Host "  $Profile`:  DefaultInboundAction=Block  LogBlocked=True   [SET]"
}

Write-Host "[*] Clearing previous MedDefense-* rules..." -ForegroundColor Cyan
$ExistingRules = Get-NetFirewallRule -DisplayName "MedDefense-*" -ErrorAction SilentlyContinue
$RemovedCount = 0
if ($ExistingRules) {
    $RemovedCount = @($ExistingRules).Count
    $ExistingRules | Remove-NetFirewallRule
}
Write-Host "  [$RemovedCount removed]"

Write-Host "[*] Creating rules from flow matrix..." -ForegroundColor Cyan

# Create a lookup table for zone CIDRs
$ZoneCidrs = @{}
foreach ($Zone in $Config.zones) {
    $ZoneCidrs[$Zone.name] = $Zone.cidr
}

# Also map 'ALL' to any/all or loop through zones
$ZoneCidrs["ALL"] = "Any"

foreach ($Flow in $Config.flows) {
    # We care about inbound flows that terminate on this host / specific rules
    if ($Flow.action -eq "allow") {
        $SrcZone = $Flow.src_zone
        $Proto = $Flow.proto
        $DPort = $Flow.dport
        
        $DisplayName = "MedDefense-$SrcZone-$($Proto.ToUpper())-$DPort"
        
        # Determine RemoteAddress based on source zone CIDR
        $RemoteAddr = if ($ZoneCidrs.ContainsKey($SrcZone)) { $ZoneCidrs[$SrcZone] } else { "Any" }
        if ($RemoteAddr -eq "Any") {
            $RemoteAddr = $null
        }

        # Build parameters for New-NetFirewallRule
        $RuleParams = @{
            DisplayName  = $DisplayName
            Direction    = "Inbound"
            Action       = "Allow"
            Protocol     = $Proto
            LocalPort    = $DPort
            Profile      = "Any"
        }

        if ($RemoteAddr) {
            $RuleParams["RemoteAddress"] = $RemoteAddr
        }

        try {
            New-NetFirewallRule @RuleParams -ErrorAction Stop | Out-Null
            Write-Host "  $DisplayName`  Inbound Allow $Proto $DPort    [CREATED]" -ForegroundColor Green
        } catch {
            Write-Warning "  Failed to create rule $DisplayName`: $_"
        }
    }
}

Write-Host "[*] Windows firewall alignment completed successfully." -ForegroundColor Green
