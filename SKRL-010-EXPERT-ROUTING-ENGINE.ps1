# SKRL-010 Phase 2: Expert Routing Rules Engine
# Enhanced Alice v2.0 Level 3 Constitutional Framework
# Expert Coordination Architecture Repair

param(
    [switch]$AnalyzeViolations,
    [switch]$DeployRouting,
    [switch]$ValidateRepairs,
    [string]$BacklogPath = "C:\Users\ankle\.claude\BACKLOG.yaml"
)

Write-Host "SKRL-010 EXPERT ROUTING RULES ENGINE v1.0" -ForegroundColor Cyan
Write-Host "Enhanced Alice v2.0 Level 3 Expert Coordination Architecture Repair" -ForegroundColor Yellow
Write-Host "Constitutional Framework Protection with Banking-Level Standards" -ForegroundColor Green
Write-Host ""

# Expert Domain Configuration - Constitutional Requirements
$ExpertDomains = @{
    "cooper" = @{
        "triggers" = @("security", "threat", "vulnerability", "credential", "audit", "penetration", "attack", "infrastructure")
        "categories" = @("security", "infrastructure", "constitutional")
        "priority_required" = @("P0")
        "constitutional_mandate" = $true
        "banking_level_requirement" = $true
    }
    "johnny" = @{
        "triggers" = @("css", "html", "wcag", "accessibility", "responsive", "layout", "frontend", "styling")
        "categories" = @("frontend", "ui_ux", "accessibility")
        "priority_required" = @()
        "constitutional_mandate" = $false
        "banking_level_requirement" = $false
    }
    "cyber-gonzo" = @{
        "triggers" = @("verification", "osint", "research", "fact-check", "investigate", "analysis")
        "categories" = @("research", "verification", "analysis")
        "priority_required" = @()
        "constitutional_mandate" = $false
        "banking_level_requirement" = $false
    }
    "pechkin" = @{
        "triggers" = @("organize", "archive", "email", "correspondence", "file", "templates", "documentation")
        "categories" = @("organization", "documentation", "communication")
        "priority_required" = @()
        "constitutional_mandate" = $false
        "banking_level_requirement" = $false
    }
    "typesetter" = @{
        "triggers" = @("content", "editorial", "writing", "style", "brand", "voice", "tone")
        "categories" = @("editorial", "content", "brand")
        "priority_required" = @()
        "constitutional_mandate" = $false
        "banking_level_requirement" = $false
    }
}

# Load and Parse BACKLOG.yaml
function Get-BacklogTasks {
    try {
        $backlogContent = Get-Content $BacklogPath -Raw
        Write-Host "BACKLOG loaded successfully: $($backlogContent.Length) characters" -ForegroundColor Green

        # Parse YAML-like structure (simplified approach)
        $tasks = @()
        $lines = $backlogContent -split "`n"
        $currentTask = $null

        foreach ($line in $lines) {
            if ($line -match '^\s*-\s*id:\s*(.+)$') {
                if ($currentTask) { $tasks += $currentTask }
                $currentTask = @{ "id" = $matches[1].Trim() }
            }
            elseif ($currentTask -and $line -match '^\s*(\w+):\s*(.+)$') {
                $key = $matches[1].Trim()
                $value = $matches[2].Trim(' "''')
                $currentTask[$key] = $value
            }
        }
        if ($currentTask) { $tasks += $currentTask }

        Write-Host "Parsed $($tasks.Count) tasks from BACKLOG" -ForegroundColor Green
        return $tasks
    }
    catch {
        Write-Host "ERROR loading BACKLOG: $_" -ForegroundColor Red
        return @()
    }
}

# Analyze Expert Assignment Violations
function Analyze-ExpertViolations {
    param($Tasks)

    Write-Host "`nANALYZING EXPERT COORDINATION VIOLATIONS..." -ForegroundColor Yellow

    $violations = @()

    foreach ($task in $Tasks) {
        if (-not $task.id) { continue }

        $requiredExpert = Get-RequiredExpert $task
        $assignedExpert = Get-AssignedExpert $task

        if ($requiredExpert -and $requiredExpert -ne $assignedExpert) {
            $violation = @{
                "TaskId" = $task.id
                "RequiredExpert" = $requiredExpert
                "AssignedExpert" = $assignedExpert
                "Priority" = $task.priority
                "Category" = $task.category
                "Title" = $task.title
                "ViolationType" = "ExpertCoordinationFailure"
                "ConstitutionalPriority" = if ($ExpertDomains[$requiredExpert.ToLower()].constitutional_mandate) { "CRITICAL" } else { "MAJOR" }
            }
            $violations += $violation
        }
    }

    Write-Host "Expert coordination violations detected: $($violations.Count)" -ForegroundColor $(if ($violations.Count -gt 0) { "Red" } else { "Green" })
    return $violations
}

# Determine Required Expert Based on Constitutional Rules
function Get-RequiredExpert {
    param($Task)

    if (-not $Task) { return $null }

    $title = $Task.title -replace '"', ''
    $category = $Task.category
    $priority = $Task.priority

    # Constitutional Mandate: Cooper for all P0 security/infrastructure
    if ($priority -eq "P0" -and ($category -match "security|infrastructure|constitutional")) {
        return "Cooper"
    }

    # Check domain-specific triggers
    foreach ($expertName in $ExpertDomains.Keys) {
        $domain = $ExpertDomains[$expertName]

        # Check triggers in title and category
        foreach ($trigger in $domain.triggers) {
            if ($title -match $trigger -or $category -match $trigger) {
                return $expertName
            }
        }

        # Check category matches
        if ($domain.categories -contains $category) {
            return $expertName
        }

        # Check priority requirements
        if ($domain.priority_required -contains $priority) {
            return $expertName
        }
    }

    return $null
}

# Extract Currently Assigned Expert
function Get-AssignedExpert {
    param($Task)

    $assignedExpert = $Task.assigned_expert
    if (-not $assignedExpert) { return $null }

    # Extract expert name from assignment string
    foreach ($expertName in $ExpertDomains.Keys) {
        if ($assignedExpert -match $expertName) {
            return $expertName
        }
    }

    return $assignedExpert
}

# Generate Expert Assignment Remediation
function Generate-ExpertRemediation {
    param($Violations)

    Write-Host "`nGENERATING EXPERT ROUTING REMEDIATION..." -ForegroundColor Yellow

    $remediation = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "total_violations" = $violations.Count
        "critical_violations" = ($violations | Where-Object { $_.ConstitutionalPriority -eq "CRITICAL" }).Count
        "major_violations" = ($violations | Where-Object { $_.ConstitutionalPriority -eq "MAJOR" }).Count
        "remediation_tasks" = @()
    }

    foreach ($violation in $violations) {
        $remediationTask = @{
            "task_id" = $violation.TaskId
            "current_assignment" = $violation.AssignedExpert
            "required_assignment" = $violation.RequiredExpert
            "constitutional_priority" = $violation.ConstitutionalPriority
            "remediation_action" = "UPDATE assigned_expert to include $($violation.RequiredExpert)"
            "verification_required" = if ($violation.ConstitutionalPriority -eq "CRITICAL") { "Alpha+Beta verification" } else { "Standard verification" }
        }
        $remediation.remediation_tasks += $remediationTask
    }

    # Export remediation report
    $remediationJson = $remediation | ConvertTo-Json -Depth 10
    $remediationPath = "C:\Users\ankle\SKRL-010-EXPERT-ROUTING-REMEDIATION-REPORT.json"
    $remediationJson | Set-Content $remediationPath -Encoding UTF8

    Write-Host "Expert routing remediation report generated: $remediationPath" -ForegroundColor Green

    return $remediation
}

# Deploy Expert Routing Rules
function Deploy-ExpertRouting {
    param($Remediation)

    Write-Host "`nDEPLOYING EXPERT ROUTING REPAIRS..." -ForegroundColor Yellow

    $backupPath = "C:\Users\ankle\BACKLOG-BEFORE-EXPERT-ROUTING-BACKUP-$(Get-Date -Format 'yyyyMMdd-HHmmss').yaml"
    Copy-Item $BacklogPath $backupPath
    Write-Host "BACKLOG backed up to: $backupPath" -ForegroundColor Green

    # Load current BACKLOG content
    $backlogContent = Get-Content $BacklogPath -Raw
    $updatedContent = $backlogContent

    $repairCount = 0

    foreach ($task in $Remediation.remediation_tasks) {
        # Find task section in BACKLOG
        $taskPattern = "- id: $($task.task_id)"
        if ($updatedContent -match $taskPattern) {
            # Look for assigned_expert line
            $expertPattern = "assigned_expert: `"([^`"]*)`""

            if ($updatedContent -match $expertPattern) {
                # Update existing assignment
                $currentAssignment = $matches[1]
                $newAssignment = "$($currentAssignment) + $($task.required_assignment) (constitutional routing repair)"
                $updatedContent = $updatedContent -replace "assigned_expert: `"$currentAssignment`"", "assigned_expert: `"$newAssignment`""
            } else {
                # Add expert assignment after task ID
                $insertPoint = $updatedContent.IndexOf($taskPattern)
                if ($insertPoint -ge 0) {
                    $lineEnd = $updatedContent.IndexOf("`n", $insertPoint)
                    if ($lineEnd -ge 0) {
                        $insertText = "`n  assigned_expert: `"$($task.required_assignment) (constitutional routing repair)`""
                        $updatedContent = $updatedContent.Insert($lineEnd, $insertText)
                    }
                }
            }
            $repairCount++
        }
    }

    # Save updated BACKLOG
    $updatedContent | Set-Content $BacklogPath -Encoding UTF8
    Write-Host "Expert routing repairs applied: $repairCount tasks updated" -ForegroundColor Green

    return $repairCount
}

# Validate Routing Repairs
function Validate-RoutingRepairs {
    Write-Host "`nVALIDATING EXPERT ROUTING REPAIRS..." -ForegroundColor Yellow

    # Re-run violation detection
    $tasks = Get-BacklogTasks
    $remainingViolations = Analyze-ExpertViolations $tasks

    Write-Host "Remaining expert coordination violations: $($remainingViolations.Count)" -ForegroundColor $(if ($remainingViolations.Count -eq 0) { "Green" } else { "Yellow" })

    return $remainingViolations
}

# Main Execution
try {
    Write-Host "PHASE 2: EXPERT COORDINATION ARCHITECTURE REPAIR" -ForegroundColor Magenta
    Write-Host "Target: 407 MAJOR expert coordination violations" -ForegroundColor Yellow
    Write-Host ""

    # Load tasks
    $tasks = Get-BacklogTasks
    if ($tasks.Count -eq 0) {
        Write-Host "ERROR: No tasks loaded from BACKLOG" -ForegroundColor Red
        exit 1
    }

    if ($AnalyzeViolations -or -not ($DeployRouting -or $ValidateRepairs)) {
        # Analyze violations
        $violations = Analyze-ExpertViolations $tasks

        if ($violations.Count -gt 0) {
            # Generate remediation
            $remediation = Generate-ExpertRemediation $violations

            Write-Host "`nEXPERT COORDINATION ANALYSIS COMPLETE" -ForegroundColor Green
            Write-Host "Total violations requiring repair: $($violations.Count)" -ForegroundColor Yellow
            Write-Host "Critical violations (constitutional mandate): $($remediation.critical_violations)" -ForegroundColor Red
            Write-Host "Major violations (domain expertise): $($remediation.major_violations)" -ForegroundColor Yellow

            # Display top violation patterns
            Write-Host "`nTOP EXPERT ROUTING VIOLATIONS:" -ForegroundColor Yellow
            $violations | Group-Object RequiredExpert | Sort-Object Count -Descending | Select-Object -First 5 | ForEach-Object {
                Write-Host "  $($_.Name): $($_.Count) tasks requiring assignment" -ForegroundColor White
            }
        } else {
            Write-Host "No expert coordination violations detected" -ForegroundColor Green
        }
    }

    if ($DeployRouting) {
        # Load existing remediation report
        $remediationPath = "C:\Users\ankle\SKRL-010-EXPERT-ROUTING-REMEDIATION-REPORT.json"
        if (Test-Path $remediationPath) {
            $remediation = Get-Content $remediationPath | ConvertFrom-Json
            $repairCount = Deploy-ExpertRouting $remediation

            Write-Host "`nEXPERT ROUTING DEPLOYMENT COMPLETE" -ForegroundColor Green
            Write-Host "Tasks repaired: $repairCount" -ForegroundColor Green
        } else {
            Write-Host "ERROR: No remediation report found. Run with -AnalyzeViolations first." -ForegroundColor Red
        }
    }

    if ($ValidateRepairs) {
        $remainingViolations = Validate-RoutingRepairs

        if ($remainingViolations.Count -eq 0) {
            Write-Host "`nPHASE 2 EXPERT COORDINATION REPAIR: COMPLETE" -ForegroundColor Green
            Write-Host "All expert routing violations resolved" -ForegroundColor Green
            Write-Host "Constitutional framework expert coordination restored" -ForegroundColor Green
        } else {
            Write-Host "`nPHASE 2 EXPERT COORDINATION REPAIR: PARTIAL" -ForegroundColor Yellow
            Write-Host "$($remainingViolations.Count) violations remain for additional analysis" -ForegroundColor Yellow
        }
    }

    Write-Host ""
    Write-Host "SKRL-010 Phase 2 Expert Routing Rules Engine execution complete" -ForegroundColor Cyan
    Write-Host "Enhanced Alice v2.0 Level 3 Constitutional Framework operational" -ForegroundColor Green
}
catch {
    Write-Host "CRITICAL ERROR in Expert Routing Engine: $_" -ForegroundColor Red
    Write-Host "Constitutional framework protection maintained" -ForegroundColor Yellow
    exit 1
}