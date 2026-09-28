[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$PlanJsonPath
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PlanJsonPath -PathType Leaf)) {
    throw "Plan JSON was not found: $PlanJsonPath"
}

$plan = Get-Content -Raw -LiteralPath $PlanJsonPath | ConvertFrom-Json
# Initial deployment only: updates, deletions, and no-change plans are rejected.
# This checks expected resource creations; it does not calculate Azure costs.
$expectedCreates = @(
    "azurerm_resource_group.assessment",
    "azurerm_policy_definition.allowed_vm_skus",
    "azurerm_resource_group_policy_assignment.allowed_vm_skus"
)

$changes = @($plan.resource_changes | Where-Object { $_.change.actions -notcontains "no-op" })
$foundAddresses = @($changes | ForEach-Object { $_.address })
$unexpected = @($changes | Where-Object {
    $_.change.actions.Count -ne 1 -or
    $_.change.actions[0] -ne "create" -or
    $_.address -notin $expectedCreates
})
$missing = @($expectedCreates | Where-Object { $_ -notin $foundAddresses })

if ($unexpected.Count -gt 0 -or $missing.Count -gt 0 -or $changes.Count -ne $expectedCreates.Count) {
    $found = if ($changes.Count) { $changes | ForEach-Object { "$($_.address): $($_.change.actions -join ',')" } } else { "no changes" }
    throw @"
Plan rejected by the zero-cost guard.
Expected only: $($expectedCreates -join '; ')
Found: $($found -join '; ')
Missing: $($missing -join '; ')
"@
}

Write-Host "PASS  Initial plan contains exactly the three expected resource creations:"
$changes | ForEach-Object { Write-Host "  - $($_.address)" }
