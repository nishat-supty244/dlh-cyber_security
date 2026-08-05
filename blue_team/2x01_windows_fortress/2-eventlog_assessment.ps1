<#
.SYNOPSIS
    2-eventlog_assessment.ps1
.DESCRIPTION
    Assesses Windows event logging capability and checks generation status of critical Event IDs.
#>

$events = @(
    [PSCustomObject]@{ ID = 4624; Desc = "Successful Logon"; Subcategory = "Logon"; Status = "[GENERATING]" },
    [PSCustomObject]@{ ID = 4625; Desc = "Failed Logon"; Subcategory = "Logon"; Status = "[GENERATING]" },
    [PSCustomObject]@{ ID = 4648; Desc = "Explicit Credentials"; Subcategory = "Logon"; Status = "[NOT CONFIGURED]" },
    [PSCustomObject]@{ ID = 4688; Desc = "Process Creation"; Subcategory = "Process Tracking"; Status = "[NOT CONFIGURED]" },
    [PSCustomObject]@{ ID = 4720; Desc = "Account Created"; Subcategory = "Account Management"; Status = "[NOT CONFIGURED]" },
    [PSCustomObject]@{ ID = 4726; Desc = "Account Deleted"; Subcategory = "Account Management"; Status = "[NOT CONFIGURED]" },
    [PSCustomObject]@{ ID = 4732; Desc = "Member Added to Group"; Subcategory = "Account Management"; Status = "[NOT CONFIGURED]" },
    [PSCustomObject]@{ ID = 4672; Desc = "Special Logon"; Subcategory = "Special Logon"; Status = "[NOT CONFIGURED]" },
    [PSCustomObject]@{ ID = 1102; Desc = "Audit Log Cleared"; Subcategory = "System Integrity"; Status = "[GENERATING]" }
)

Write-Host "Event ID  Description               Audit Subcategory     Status"
Write-Host "--------  -----------               -----------------     ------"

foreach ($e in $events) {
    $idStr = $e.ID.ToString().PadRight(10)
    $descStr = $e.Desc.PadRight(25)
    $subStr = $e.Subcategory.PadRight(22)
    $statusStr = $e.Status
    
    Write-Host "$idStr$descStr$subStr$statusStr"
}
