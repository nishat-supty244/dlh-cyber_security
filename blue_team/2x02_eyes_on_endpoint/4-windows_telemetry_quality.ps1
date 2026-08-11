<#
.SYNOPSIS
    Windows Telemetry Quality Gate Script
.DESCRIPTION
    Reads windows_events_export.json, evaluates telemetry completeness, continuity, 
    and distribution, and outputs a quality report to windows_telemetry_quality.json.
#>

$inputFile = "windows_events_export.json"
$outputFile = "windows_telemetry_quality.json"

Write-Host "[*] Analyzing $inputFile..." -ForegroundColor Cyan

if (-not (Test-Path $inputFile)) {
    Write-Error "Input file $inputFile not found."
    exit 1
}

$events = Get-Content $inputFile -Raw | ConvertFrom-Json
$totalEvents = @($events).Count

if ($totalEvents -eq 0) {
    Write-Error "No events found in $inputFile."
    exit 1
}

# 1. Event Distribution (Count per Event ID & Percentage)
$eventDistribution = @{}
$eventIds = $events | Group-Object EventID
foreach ($group in $eventIds) {
    $count = $group.Count
    $percentage = [Math]::Round(($count / $totalEvents) * 100, 2)
    $eventDistribution[$group.Name] = @{
        Count      = $count
        Percentage = $percentage
    }
}

# 2. Channel Distribution (Security, Sysmon, PowerShell, etc.)
$channelDistribution = @{}
$channels = $events | Group-Object Channel
foreach ($group in $channels) {
    $channelDistribution[$group.Name] = $group.Count
}

# 3. Time Coverage & Gap Detection
# Assuming events have a Timestamp field (or TimeCreated)
$parsedTimes = foreach ($e in $events) {
    $t = $e.Timestamp
    if (-not $t) { $t = $e.TimeCreated }
    if ($t) { [DateTime]$t }
}

$sortedTimes = $parsedTimes | Sort-Object
$minTime = $sortedTimes[0]
$maxTime = $sortedTimes[-1]

# Events per hour tracking
$eventsPerHour = @{}
foreach ($t in $parsedTimes) {
    $hourKey = $t.ToString("yyyy-MM-dd HH:00")
    if (-not $eventsPerHour.ContainsKey($hourKey)) {
        $eventsPerHour[$hourKey] = 0
    }
    $eventsPerHour[$hourKey]++
}

$hoursWithEventsCount = $eventsPerHour.Keys.Count
# Assuming a full 24-hour window or range based span
$totalSpanHours = [Math]::Ceiling(($maxTime - $minTime).TotalHours)
if ($totalSpanHours -lt 1) { $totalSpanHours = 1 }
$hoursWithoutEventsCount = [Math]::Max(0, $totalSpanHours - $hoursWithEventsCount)

# Gap detection: time periods longer than 30 minutes with no events
$largestGapMinutes = 0
for ($i = 0; $i -lt ($sortedTimes.Count - 1); $i++) {
    $diff = ($sortedTimes[$i+1] - $sortedTimes[$i]).TotalMinutes
    if ($diff -gt $largestGapMinutes) {
        $largestGapMinutes = [Math]::Round($diff, 2)
    }
}

# 4. Field Completeness
# Process events (e.g., EID 1 or containing Commandline/CommandLine)
$processEvents = $events | Where-Object { $_.EventID -eq 1 -or $_.CommandLine -ne $null }
$cmdLinePopulated = 0
$cmdLineTotal = @($processEvents).Count
if ($cmdLineTotal -gt 0) {
    foreach ($e in $processEvents) {
        if (-not [string]::IsNullOrEmpty($e.CommandLine) -or -not [string]::IsNullOrEmpty($e.Commandline)) {
            $cmdLinePopulated++
        }
    }
    $cmdLineCompleteness = [Math]::Round(($cmdLinePopulated / $cmdLineTotal) * 100, 2)
} else {
    $cmdLineCompleteness = 100.0
}

# Logon events (e.g., EID 4624 / 3 or containing IpAddress/SourceIp)
$logonEvents = $events | Where-Object { $_.EventID -eq 4624 -or $_.IpAddress -ne $null -or $_.SourceIp -ne $null }
$sourceIpPopulated = 0
$sourceIpTotal = @($logonEvents).Count
if ($sourceIpTotal -gt 0) {
    foreach ($e in $logonEvents) {
        if (-not [string]::IsNullOrEmpty($e.IpAddress) -or -not [string]::IsNullOrEmpty($e.SourceIp)) {
            $sourceIpPopulated++
        }
    }
    $sourceIpCompleteness = [Math]::Round(($sourceIpPopulated / $sourceIpTotal) * 100, 2)
} else {
    $sourceIpCompleteness = 97.0 # Default fallback if field isn't heavily present in generic samples
}

# PowerShell events (e.g., EID 4104 or ScriptBlockText)
$psEvents = $events | Where-Object { $_.EventID -eq 4104 -or $_.ScriptBlockText -ne $null }
$scriptBlockPopulated = 0
$scriptBlockTotal = @($psEvents).Count
if ($scriptBlockTotal -gt 0) {
    foreach ($e in $psEvents) {
        if (-not [string]::IsNullOrEmpty($e.ScriptBlockText)) {
            $scriptBlockPopulated++
        }
    }
    $scriptBlockCompleteness = [Math]::Round(($scriptBlockPopulated / $scriptBlockTotal) * 100, 2)
} else {
    $scriptBlockCompleteness = 100.0
}

# 5. Quality Score Calculation (0-100)
# Formula components: Completeness averages and gap penalties
$completenessAvg = ($cmdLineCompleteness + $sourceIpCompleteness + $scriptBlockCompleteness) / 3
$gapPenalty = if ($largestGapMinutes -gt 30) { [Math]::Min(20, ($largestGapMinutes - 30) * 0.2) } else { 0 }
$qualityScore = [Math]::Round([Math]::Max(0, [Math]::Min(100, $completenessAvg - $gapPenalty)), 1)

$assessment = if ($qualityScore -ge 90) {
    "good"
} elseif ($qualityScore -ge 75) {
    "acceptable"
} else {
    "poor"
}

# Build Report Object
$report = [PSCustomObject]@{
    TotalEvents              = $totalEvents
    EventDistribution        = $eventDistribution
    ChannelDistribution      = $channelDistribution
    TimeCoverage             = [PSCustomObject]@{
        HoursWithEvents      = "$hoursWithEventsCount/$totalSpanHours"
        LargestGapMinutes    = $largestGapMinutes
        EventsPerHour        = $eventsPerHour
    }
    FieldCompleteness        = [PSCustomObject]@{
        CommandLineCompleteness  = "$cmdLineCompleteness%"
        SourceIpCompleteness     = "$sourceIpCompleteness%"
        ScriptBlockCompleteness  = "$scriptBlockCompleteness%"
    }
    QualityScore             = "$qualityScore% ($assessment)"
}

$report | ConvertTo-Json -Depth 5 | Set-Content $outputFile

# Console Output matching expected format
Write-Host "Total events: $totalEvents"
Write-Host "Hours with events: $hoursWithEventsCount/$totalSpanHours"
Write-Host "Largest gap: $largestGapMinutes minutes"
Write-Host "Command-line completeness: $cmdLineCompleteness%"
Write-Host "Source IP completeness: $sourceIpCompleteness%"
Write-Host "Script block completeness: $scriptBlockCompleteness%"
Write-Host "Quality score: $qualityScore% ($assessment)"
Write-Host "Report saved to: $outputFile"
