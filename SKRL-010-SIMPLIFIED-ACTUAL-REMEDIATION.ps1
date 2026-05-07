# SKRL-010 SIMPLIFIED ACTUAL REMEDIATION ENGINE
# Enhanced Alice v2.0 Level 3 Constitutional Framework
# Phase 3: Systematic BACKLOG Constitutional Remediation

param(
    [switch]$Execute,
    [string]$BacklogPath = "C:\Users\ankle\.claude\BACKLOG.yaml"
)

Write-Host "SKRL-010 SIMPLIFIED ACTUAL REMEDIATION ENGINE" -ForegroundColor Red
Write-Host "Enhanced Alice v2.0 Level 3 Constitutional Framework" -ForegroundColor Yellow
Write-Host "Phase 3: Systematic BACKLOG Constitutional Remediation" -ForegroundColor Magenta
Write-Host ""

# Load remediation reports
$ExpertRoutingReportPath = "C:\Users\ankle\SKRL-010-EXPERT-ROUTING-REMEDIATION-REPORT.json"
$ConstitutionalReportPath = "C:\Users\ankle\SKRL-010-CONSTITUTIONAL-VERIFICATION-REMEDIATION-REPORT.json"

function Apply-ExpertRouting {
    Write-Host "APPLYING EXPERT ROUTING FIXES..." -ForegroundColor Yellow

    if (-not (Test-Path $ExpertRoutingReportPath)) {
        Write-Host "Expert routing report not found: $ExpertRoutingReportPath" -ForegroundColor Red
        return $false
    }

    try {
        # Load report
        $report = Get-Content $ExpertRoutingReportPath | ConvertFrom-Json

        # Backup BACKLOG
        $backupPath = "C:\Users\ankle\BACKLOG-ACTUAL-REMEDIATION-BACKUP-$(Get-Date -Format 'yyyyMMdd-HHmmss').yaml"
        Copy-Item $BacklogPath $backupPath
        Write-Host "BACKLOG backed up to: $backupPath" -ForegroundColor Green

        # Load BACKLOG content
        $backlogContent = Get-Content $BacklogPath -Raw
        $changesApplied = 0

        foreach ($task in $report.remediation_tasks) {
            $taskId = $task.task_id
            $requiredExpert = $task.required_assignment

            Write-Host "Processing $taskId -> $requiredExpert" -ForegroundColor White

            # Simple string replacement approach
            $taskPattern = "- id: $taskId"
            $taskStart = $backlogContent.IndexOf($taskPattern)

            if ($taskStart -ge 0) {
                # Find the section for this task (until next task or section)
                $nextTask = $backlogContent.IndexOf("`n- id:", $taskStart + 1)
                $nextSection = $backlogContent.IndexOf("`n# =", $taskStart + 1)

                $sectionEnd = $backlogContent.Length
                if ($nextTask -gt 0 -and ($nextSection -lt 0 -or $nextTask -lt $nextSection)) {
                    $sectionEnd = $nextTask
                } elseif ($nextSection -gt 0) {
                    $sectionEnd = $nextSection
                }

                $taskSection = $backlogContent.Substring($taskStart, $sectionEnd - $taskStart)

                # Check if assigned_expert exists in this section
                if ($taskSection.Contains("assigned_expert:")) {
                    # Find the assigned_expert line
                    $lines = $taskSection -split "`n"
                    for ($i = 0; $i -lt $lines.Count; $i++) {
                        if ($lines[$i].Contains("assigned_expert:")) {
                            $currentLine = $lines[$i]

                            # Only update if expert not already included
                            if (-not $currentLine.Contains($requiredExpert)) {
                                # Extract current expert assignment
                                $quotedPart = ""
                                $startQuote = $currentLine.IndexOf('"')
                                $endQuote = $currentLine.LastIndexOf('"')

                                if ($startQuote -ge 0 -and $endQuote -gt $startQuote) {
                                    $quotedPart = $currentLine.Substring($startQuote + 1, $endQuote - $startQuote - 1)
                                }

                                # Create new assignment
                                $newAssignment = "$quotedPart + $requiredExpert (constitutional routing)"
                                $newLine = $currentLine.Replace($quotedPart, $newAssignment)

                                # Replace in full content
                                $backlogContent = $backlogContent.Replace($currentLine, $newLine)
                                $changesApplied++
                                Write-Host "  Updated: $quotedPart -> $newAssignment" -ForegroundColor Green
                            } else {
                                Write-Host "  Skipped: $requiredExpert already assigned" -ForegroundColor Gray
                            }
                            break
                        }
                    }
                } else {
                    # Add assigned_expert field
                    $insertPoint = $backlogContent.IndexOf("`n", $taskStart + $taskPattern.Length)
                    if ($insertPoint -gt 0) {
                        $insertText = "`n  assigned_expert: `"$requiredExpert (constitutional routing)`""
                        $backlogContent = $backlogContent.Insert($insertPoint, $insertText)
                        $changesApplied++
                        Write-Host "  Added: assigned_expert = $requiredExpert" -ForegroundColor Green
                    }
                }
            }
        }

        # Save updated BACKLOG
        Set-Content -Path $BacklogPath -Value $backlogContent -Encoding UTF8
        Write-Host "Expert routing applied: $changesApplied changes" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "ERROR applying expert routing: $_" -ForegroundColor Red
        return $false
    }
}

function Apply-ConstitutionalVerification {
    Write-Host "APPLYING CONSTITUTIONAL VERIFICATION FIELDS..." -ForegroundColor Yellow

    if (-not (Test-Path $ConstitutionalReportPath)) {
        Write-Host "Constitutional verification report not found" -ForegroundColor Red
        return $true  # Not critical
    }

    try {
        $report = Get-Content $ConstitutionalReportPath | ConvertFrom-Json
        $backlogContent = Get-Content $BacklogPath -Raw
        $changesApplied = 0

        foreach ($taskData in $report.remediation_tasks) {
            $taskId = $taskData.task_id

            Write-Host "Processing constitutional fields for $taskId" -ForegroundColor White

            foreach ($field in $taskData.required_fields) {
                $fieldName = $field.field_name
                $fieldValue = $field.required_value

                # Add field if not exists
                $fieldPattern = "  $fieldName"+":`n"
                if (-not $backlogContent.Contains($fieldPattern)) {
                    $taskPattern = "- id: $taskId"
                    $taskStart = $backlogContent.IndexOf($taskPattern)

                    if ($taskStart -gt 0) {
                        $insertPoint = $backlogContent.IndexOf("`n`n", $taskStart)
                        if ($insertPoint -gt 0) {
                            $insertText = "  $fieldName" + ": `"$fieldValue`"`n"
                            $backlogContent = $backlogContent.Insert($insertPoint, $insertText)
                            $changesApplied++
                            Write-Host "  Added: $fieldName = $fieldValue" -ForegroundColor Green
                        }
                    }
                }
            }
        }

        # Save updated BACKLOG
        Set-Content -Path $BacklogPath -Value $backlogContent -Encoding UTF8
        Write-Host "Constitutional verification applied: $changesApplied fields" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "ERROR applying constitutional verification: $_" -ForegroundColor Red
        return $false
    }
}

function Validate-Remediation {
    Write-Host "VALIDATING ACTUAL REMEDIATION RESULTS..." -ForegroundColor Yellow

    try {
        $violationOutput = & "C:\Users\ankle\SKRL-008B-VIOLATION-DETECTOR.ps1" 2>&1

        $summaryMatch = $violationOutput | Select-String "Total Violations Detected: (\d+)"
        if ($summaryMatch) {
            $totalViolations = $summaryMatch.Matches[0].Groups[1].Value
            Write-Host "Current violations after remediation: $totalViolations" -ForegroundColor Green
        }

        return $true
    }
    catch {
        Write-Host "Validation check failed: $_" -ForegroundColor Yellow
        return $false
    }
}

# Main Execution
if ($Execute) {
    Write-Host "EXECUTING CONSTITUTIONAL REMEDIATION PHASE 3" -ForegroundColor Magenta
    Write-Host ""

    # Apply expert routing
    $expertSuccess = Apply-ExpertRouting

    # Apply constitutional verification
    $constitutionalSuccess = Apply-ConstitutionalVerification

    if ($expertSuccess -and $constitutionalSuccess) {
        Write-Host ""
        Write-Host "ACTUAL REMEDIATION COMPLETE" -ForegroundColor Green
        Write-Host "Constitutional changes applied to BACKLOG.yaml" -ForegroundColor Green

        # Validate results
        Validate-Remediation
    } else {
        Write-Host "PARTIAL REMEDIATION - Some components failed" -ForegroundColor Yellow
    }
} else {
    Write-Host "Use -Execute to apply constitutional remediation" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "SKRL-010 Simplified Actual Remediation complete" -ForegroundColor Cyan