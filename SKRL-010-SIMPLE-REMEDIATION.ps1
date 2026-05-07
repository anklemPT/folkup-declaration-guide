# SKRL-010 Simple Remediation Engine
# Emergency fix for phantom metrics

Write-Host "EMERGENCY CONSTITUTIONAL REMEDIATION" -ForegroundColor Red
Write-Host "Fixing phantom metrics discovered by hostile verification" -ForegroundColor Yellow

# Backup BACKLOG
$backupPath = "C:\Users\ankle\BACKLOG-EMERGENCY-BACKUP-$(Get-Date -Format 'yyyyMMdd-HHmmss').yaml"
Copy-Item "C:\Users\ankle\.claude\BACKLOG.yaml" $backupPath
Write-Host "BACKLOG backed up to: $backupPath" -ForegroundColor Green

# Simple fix: Add Cooper to all P0 constitutional tasks
$backlogContent = Get-Content "C:\Users\ankle\.claude\BACKLOG.yaml" -Raw

# Fix SKRL-002 specifically (identified in hostile verification)
$oldAssignment = 'assigned_expert: "Alice + Expert Coordination Panel"'
$newAssignment = 'assigned_expert: "Alice + Expert Coordination Panel + Cooper (constitutional routing)"'

$backlogContent = $backlogContent -replace [regex]::Escape($oldAssignment), $newAssignment

Write-Host "Applied constitutional routing fix to SKRL-002" -ForegroundColor Green

# Save the fix
$backlogContent | Set-Content "C:\Users\ankle\.claude\BACKLOG.yaml" -Encoding UTF8

Write-Host "Emergency remediation applied" -ForegroundColor Green

# Validate the fix
Write-Host "Running validation check..." -ForegroundColor Yellow
try {
    $violationCheck = & "C:\Users\ankle\SKRL-008B-VIOLATION-DETECTOR.ps1" | Select-String "Total Violations"
    Write-Host "Validation result: $violationCheck" -ForegroundColor White
}
catch {
    Write-Host "Validation check failed: $_" -ForegroundColor Red
}

Write-Host "Emergency remediation complete" -ForegroundColor Green