# SKRL-011 Constitutional Framework Health Monitor
# Enhanced Alice v2.0 Level 3 Constitutional Framework
# Banking-Level Standards Continuous Monitoring and Health Assessment

param(
    [switch]$MonitorHealth,
    [switch]$AssessCompliance,
    [switch]$CheckFrameworkIntegrity,
    [switch]$RunDailyAssessment,
    [string]$RulesPath = "C:\Users\ankle\.claude\rules",
    [string]$BacklogPath = "C:\Users\ankle\.claude\BACKLOG.yaml",
    [string]$ConfigPath = "C:\Users\ankle\.claude\settings.json"
)

Write-Host "SKRL-011 CONSTITUTIONAL FRAMEWORK HEALTH MONITOR v1.0" -ForegroundColor Cyan
Write-Host "Enhanced Alice v2.0 Level 3 Constitutional Framework Health Assessment" -ForegroundColor Yellow
Write-Host "Banking-Level Standards Continuous Monitoring" -ForegroundColor Green
Write-Host ""

# Constitutional Framework Health Metrics
$ConstitutionalFrameworkMetrics = @{
    "core_files" = @{
        "constitutional-core.md" = @{
            "criticality" = "CRITICAL"
            "required_sections" = @("Constitutional Authority Hierarchy", "Banking-Level Standards Framework", "Alpha+Beta Verification Protocol", "Evidence-First Methodology")
        }
        "expert-coordination-unified.md" = @{
            "criticality" = "CRITICAL"
            "required_sections" = @("Expert Domain Authority Framework", "Semantic Integration Architecture", "Expert Coordination Protection System")
        }
        "constitutional-compliance-monitoring.md" = @{
            "criticality" = "HIGH"
            "required_sections" = @("Automated Constitutional Gate Enforcement", "Constitutional Violation Prevention")
        }
        "expert-coordination-protection.md" = @{
            "criticality" = "HIGH"
            "required_sections" = @("Semantic Integration Integrity Protection", "Expert Isolation Attack Prevention")
        }
        "operational-protocols.md" = @{
            "criticality" = "MEDIUM"
            "required_sections" = @("System Protection Protocols", "Model Routing Framework", "Client Communication Protocol")
        }
    }
    "health_indicators" = @{
        "file_integrity" = @{
            "weight" = 30.0
            "target" = 100.0
        }
        "content_completeness" = @{
            "weight" = 25.0
            "target" = 100.0
        }
        "constitutional_compliance" = @{
            "weight" = 25.0
            "target" = 100.0
        }
        "framework_consistency" = @{
            "weight" = 20.0
            "target" = 100.0
        }
    }
    "alert_thresholds" = @{
        "critical" = 85.0
        "warning" = 90.0
        "healthy" = 95.0
    }
}

# Constitutional Framework File Integrity Check
function Test-ConstitutionalFrameworkIntegrity {
    param($RulesPath)

    Write-Host "🔍 Testing constitutional framework integrity..." -ForegroundColor Yellow

    $integrity_results = @{
        "files_checked" = 0
        "files_missing" = @()
        "files_corrupted" = @()
        "content_issues" = @()
        "integrity_score" = 0.0
    }

    if (-not (Test-Path $RulesPath)) {
        Write-Host "❌ Constitutional rules directory not found: $RulesPath" -ForegroundColor Red
        return @{
            "success" = $false
            "error" = "Rules directory not found"
        }
    }

    foreach ($file in $ConstitutionalFrameworkMetrics["core_files"].Keys) {
        $filePath = Join-Path $RulesPath $file
        $integrity_results["files_checked"]++

        if (-not (Test-Path $filePath)) {
            $integrity_results["files_missing"] += $file
            Write-Host "  ❌ Missing: $file" -ForegroundColor Red
        } else {
            try {
                $content = Get-Content $filePath -Raw -ErrorAction Stop
                $fileConfig = $ConstitutionalFrameworkMetrics["core_files"][$file]

                # Check for required sections
                foreach ($section in $fileConfig["required_sections"]) {
                    if ($content -notmatch $section) {
                        $integrity_results["content_issues"] += @{
                            "file" = $file
                            "issue" = "Missing required section: $section"
                            "criticality" = $fileConfig["criticality"]
                        }
                    }
                }

                # Check file size (basic corruption detection)
                $fileSize = (Get-Item $filePath).Length
                if ($fileSize -lt 1000) {  # Constitutional files should be substantial
                    $integrity_results["files_corrupted"] += @{
                        "file" = $file
                        "issue" = "File too small (possible corruption)"
                        "size" = $fileSize
                    }
                }

                Write-Host "  ✅ Valid: $file ($([math]::Round($fileSize/1024, 1))KB)" -ForegroundColor Green

            } catch {
                $integrity_results["files_corrupted"] += @{
                    "file" = $file
                    "issue" = "Read error: $($_.Exception.Message)"
                }
                Write-Host "  ❌ Corrupted: $file" -ForegroundColor Red
            }
        }
    }

    # Calculate integrity score
    $total_files = $integrity_results["files_checked"]
    $missing_files = $integrity_results["files_missing"].Count
    $corrupted_files = $integrity_results["files_corrupted"].Count
    $content_issues = $integrity_results["content_issues"].Count

    $integrity_score = if ($total_files -gt 0) {
        $healthy_files = $total_files - $missing_files - $corrupted_files
        $base_score = ($healthy_files / $total_files) * 100
        $content_penalty = [math]::Min(50, $content_issues * 5)  # Max 50% penalty for content issues
        [math]::Max(0, $base_score - $content_penalty)
    } else { 0 }

    $integrity_results["integrity_score"] = $integrity_score

    return @{
        "success" = $true
        "results" = $integrity_results
    }
}

# Constitutional Compliance Assessment
function Test-ConstitutionalCompliance {
    param($BacklogPath, $RulesPath)

    Write-Host "⚖️ Assessing constitutional compliance..." -ForegroundColor Yellow

    $compliance_results = @{
        "tasks_assessed" = 0
        "banking_level_tasks" = 0
        "compliance_violations" = @()
        "expert_coordination_issues" = @()
        "evidence_methodology_gaps" = @()
        "compliance_score" = 0.0
    }

    if (-not (Test-Path $BacklogPath)) {
        Write-Host "❌ BACKLOG file not found: $BacklogPath" -ForegroundColor Red
        return @{ "success" = $false; "error" = "BACKLOG not found" }
    }

    try {
        $backlogContent = Get-Content $BacklogPath -Raw

        # Parse YAML structure for compliance assessment
        $lines = $backlogContent -split "`n"
        $current_task = @{}
        $in_task = $false

        foreach ($line in $lines) {
            if ($line -match "^- id: (.+)") {
                # Process previous task if exists
                if ($in_task -and $current_task.Count -gt 0) {
                    $compliance_results["tasks_assessed"]++

                    # Check if task requires banking-level standards
                    $requires_banking = ($current_task["priority"] -eq "P0" -or
                                        $current_task["category"] -match "security|infrastructure|client_delivery" -or
                                        $current_task["constitutional_status"] -match "banking")

                    if ($requires_banking) {
                        $compliance_results["banking_level_tasks"]++

                        # Check for required banking-level fields
                        $required_fields = @("alpha_beta_verification", "evidence_first_methodology", "constitutional_compliance")
                        foreach ($field in $required_fields) {
                            if (-not ($current_task.ContainsKey($field) -and $current_task[$field])) {
                                $compliance_results["compliance_violations"] += @{
                                    "task_id" = $current_task["id"]
                                    "violation" = "Missing banking-level field: $field"
                                    "severity" = "CRITICAL"
                                }
                            }
                        }

                        # Check expert coordination for multi-expert tasks
                        if ($current_task.ContainsKey("expert_coordination")) {
                            $expert_count = ($current_task["expert_coordination"] -split ",").Count
                            if ($expert_count -gt 1 -and -not ($current_task.ContainsKey("semantic_integration"))) {
                                $compliance_results["expert_coordination_issues"] += @{
                                    "task_id" = $current_task["id"]
                                    "issue" = "Multi-expert task missing semantic integration"
                                    "expert_count" = $expert_count
                                }
                            }
                        }

                        # Check evidence methodology
                        if (-not ($current_task.ContainsKey("evidence") -and $current_task["evidence"] -and $current_task["evidence"].Length -gt 10)) {
                            $compliance_results["evidence_methodology_gaps"] += @{
                                "task_id" = $current_task["id"]
                                "gap" = "Insufficient evidence documentation"
                                "current_evidence_length" = if ($current_task.ContainsKey("evidence")) { $current_task["evidence"].Length } else { 0 }
                            }
                        }
                    }
                }

                # Start new task
                $current_task = @{
                    "id" = $Matches[1]
                }
                $in_task = $true
            }
            elseif ($in_task -and $line -match "^\s+(\w+):\s*(.+)") {
                $key = $Matches[1].Trim()
                $value = $Matches[2].Trim().Trim('"').Trim("'")
                $current_task[$key] = $value
            }
        }

        # Calculate compliance score
        $total_banking_tasks = $compliance_results["banking_level_tasks"]
        $compliance_violations = $compliance_results["compliance_violations"].Count
        $coordination_issues = $compliance_results["expert_coordination_issues"].Count
        $evidence_gaps = $compliance_results["evidence_methodology_gaps"].Count

        $compliance_score = if ($total_banking_tasks -gt 0) {
            $violation_penalty = ($compliance_violations / $total_banking_tasks) * 60  # Up to 60% penalty for violations
            $coordination_penalty = ($coordination_issues / $total_banking_tasks) * 25  # Up to 25% penalty for coordination issues
            $evidence_penalty = ($evidence_gaps / $total_banking_tasks) * 15  # Up to 15% penalty for evidence gaps

            [math]::Max(0, 100 - $violation_penalty - $coordination_penalty - $evidence_penalty)
        } else { 100 }  # No banking-level tasks = perfect compliance

        $compliance_results["compliance_score"] = $compliance_score

        return @{
            "success" = $true
            "results" = $compliance_results
        }

    } catch {
        Write-Host "❌ Error during compliance assessment: $($_.Exception.Message)" -ForegroundColor Red
        return @{ "success" = $false; "error" = $_.Exception.Message }
    }
}

# Framework Consistency Analysis
function Test-FrameworkConsistency {
    param($RulesPath)

    Write-Host "🔄 Testing framework consistency..." -ForegroundColor Yellow

    $consistency_results = @{
        "rules_analyzed" = 0
        "consistency_issues" = @()
        "missing_integrations" = @()
        "conflicting_directives" = @()
        "consistency_score" = 0.0
    }

    if (-not (Test-Path $RulesPath)) {
        return @{ "success" = $false; "error" = "Rules path not found" }
    }

    try {
        $ruleFiles = Get-ChildItem -Path $RulesPath -Filter "*.md" | Where-Object { $_.Name -match "constitutional|expert|operational" }

        foreach ($file in $ruleFiles) {
            $consistency_results["rules_analyzed"]++
            $content = Get-Content $file.FullName -Raw

            # Check for constitutional framework references
            if ($file.Name -match "expert|operational" -and $content -notmatch "constitutional.*framework|banking.*level|Enhanced Alice v2\.0") {
                $consistency_results["missing_integrations"] += @{
                    "file" = $file.Name
                    "issue" = "Missing constitutional framework integration"
                }
            }

            # Check for expert coordination references in operational files
            if ($file.Name -match "operational" -and $content -notmatch "expert.*coordination|semantic.*integration") {
                $consistency_results["missing_integrations"] += @{
                    "file" = $file.Name
                    "issue" = "Missing expert coordination integration"
                }
            }

            # Check for conflicting authority statements
            if ($content -match "override.*constitutional|bypass.*banking.*level|skip.*expert.*coordination") {
                $consistency_results["conflicting_directives"] += @{
                    "file" = $file.Name
                    "issue" = "Potentially conflicting directive detected"
                }
            }

            Write-Host "  📋 Analyzed: $($file.Name)" -ForegroundColor Gray
        }

        # Calculate consistency score
        $total_issues = $consistency_results["missing_integrations"].Count + $consistency_results["conflicting_directives"].Count
        $consistency_score = if ($consistency_results["rules_analyzed"] -gt 0) {
            [math]::Max(0, 100 - (($total_issues / $consistency_results["rules_analyzed"]) * 50))
        } else { 100 }

        $consistency_results["consistency_score"] = $consistency_score

        return @{
            "success" = $true
            "results" = $consistency_results
        }

    } catch {
        Write-Host "❌ Error during consistency analysis: $($_.Exception.Message)" -ForegroundColor Red
        return @{ "success" = $false; "error" = $_.Exception.Message }
    }
}

# Comprehensive Constitutional Health Assessment
function Start-ConstitutionalHealthAssessment {
    param($RulesPath, $BacklogPath)

    Write-Host "🏥 Starting comprehensive constitutional health assessment..." -ForegroundColor Cyan

    $health_assessment = @{
        "timestamp" = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        "assessment_version" = "SKRL-011 v1.0"
        "components" = @{}
        "overall_score" = 0.0
        "health_status" = "UNKNOWN"
        "recommendations" = @()
    }

    # Component 1: Framework Integrity
    Write-Host "1️⃣ Assessing framework integrity..." -ForegroundColor Blue
    $integrity_result = Test-ConstitutionalFrameworkIntegrity -RulesPath $RulesPath
    if ($integrity_result["success"]) {
        $health_assessment["components"]["framework_integrity"] = $integrity_result["results"]
        Write-Host "   ✅ Framework integrity: $([math]::Round($integrity_result['results']['integrity_score'], 1))%" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Framework integrity assessment failed" -ForegroundColor Red
        $health_assessment["components"]["framework_integrity"] = @{ "integrity_score" = 0; "error" = $integrity_result["error"] }
    }

    # Component 2: Constitutional Compliance
    Write-Host "2️⃣ Assessing constitutional compliance..." -ForegroundColor Blue
    $compliance_result = Test-ConstitutionalCompliance -BacklogPath $BacklogPath -RulesPath $RulesPath
    if ($compliance_result["success"]) {
        $health_assessment["components"]["constitutional_compliance"] = $compliance_result["results"]
        Write-Host "   ✅ Constitutional compliance: $([math]::Round($compliance_result['results']['compliance_score'], 1))%" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Constitutional compliance assessment failed" -ForegroundColor Red
        $health_assessment["components"]["constitutional_compliance"] = @{ "compliance_score" = 0; "error" = $compliance_result["error"] }
    }

    # Component 3: Framework Consistency
    Write-Host "3️⃣ Assessing framework consistency..." -ForegroundColor Blue
    $consistency_result = Test-FrameworkConsistency -RulesPath $RulesPath
    if ($consistency_result["success"]) {
        $health_assessment["components"]["framework_consistency"] = $consistency_result["results"]
        Write-Host "   ✅ Framework consistency: $([math]::Round($consistency_result['results']['consistency_score'], 1))%" -ForegroundColor Green
    } else {
        Write-Host "   ❌ Framework consistency assessment failed" -ForegroundColor Red
        $health_assessment["components"]["framework_consistency"] = @{ "consistency_score" = 0; "error" = $consistency_result["error"] }
    }

    # Calculate overall health score
    $metrics = $ConstitutionalFrameworkMetrics["health_indicators"]
    $weighted_score = 0.0

    if ($integrity_result["success"]) {
        $weighted_score += ($metrics["file_integrity"]["weight"] / 100.0) * $integrity_result["results"]["integrity_score"]
    }
    if ($compliance_result["success"]) {
        $weighted_score += ($metrics["constitutional_compliance"]["weight"] / 100.0) * $compliance_result["results"]["compliance_score"]
    }
    if ($consistency_result["success"]) {
        $weighted_score += ($metrics["framework_consistency"]["weight"] / 100.0) * $consistency_result["results"]["consistency_score"]
    }

    $health_assessment["overall_score"] = $weighted_score

    # Determine health status
    $thresholds = $ConstitutionalFrameworkMetrics["alert_thresholds"]
    if ($weighted_score -ge $thresholds["healthy"]) {
        $health_assessment["health_status"] = "HEALTHY"
    } elseif ($weighted_score -ge $thresholds["warning"]) {
        $health_assessment["health_status"] = "WARNING"
    } elseif ($weighted_score -ge $thresholds["critical"]) {
        $health_assessment["health_status"] = "CRITICAL"
    } else {
        $health_assessment["health_status"] = "EMERGENCY"
    }

    # Generate recommendations
    if ($integrity_result["success"] -and $integrity_result["results"]["files_missing"].Count -gt 0) {
        $health_assessment["recommendations"] += "CRITICAL: Restore missing constitutional framework files"
    }
    if ($compliance_result["success"] -and $compliance_result["results"]["compliance_violations"].Count -gt 0) {
        $health_assessment["recommendations"] += "HIGH: Address constitutional compliance violations in BACKLOG tasks"
    }
    if ($consistency_result["success"] -and $consistency_result["results"]["conflicting_directives"].Count -gt 0) {
        $health_assessment["recommendations"] += "MEDIUM: Resolve conflicting directives in framework files"
    }

    # Display results
    Write-Host ""
    Write-Host "🎯 Constitutional Framework Health Assessment Results:" -ForegroundColor Green
    Write-Host "   Overall Score: $([math]::Round($weighted_score, 1))%" -ForegroundColor White
    Write-Host "   Health Status: $($health_assessment['health_status'])" -ForegroundColor $(
        switch ($health_assessment["health_status"]) {
            "HEALTHY" { "Green" }
            "WARNING" { "Yellow" }
            "CRITICAL" { "Red" }
            "EMERGENCY" { "Magenta" }
            default { "Gray" }
        }
    )

    if ($health_assessment["recommendations"].Count -gt 0) {
        Write-Host "   Recommendations:" -ForegroundColor Yellow
        foreach ($rec in $health_assessment["recommendations"]) {
            Write-Host "     - $rec" -ForegroundColor Gray
        }
    }

    # Save assessment report
    $reportPath = "C:\Users\ankle\SKRL-011-CONSTITUTIONAL-HEALTH-REPORT.json"
    $health_assessment | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath -Encoding UTF8
    Write-Host "📄 Constitutional health report saved: $reportPath" -ForegroundColor Green

    return $health_assessment
}

# Main Execution Logic
switch ($true) {
    $MonitorHealth {
        Test-ConstitutionalFrameworkIntegrity -RulesPath $RulesPath
    }
    $AssessCompliance {
        Test-ConstitutionalCompliance -BacklogPath $BacklogPath -RulesPath $RulesPath
    }
    $CheckFrameworkIntegrity {
        Test-FrameworkConsistency -RulesPath $RulesPath
    }
    $RunDailyAssessment {
        $assessment = Start-ConstitutionalHealthAssessment -RulesPath $RulesPath -BacklogPath $BacklogPath

        Write-Host ""
        Write-Host "📊 Daily Constitutional Health Assessment Complete" -ForegroundColor Green
        Write-Host "🎯 Framework Health: $($assessment['health_status']) ($([math]::Round($assessment['overall_score'], 1))%)" -ForegroundColor $(
            switch ($assessment["health_status"]) {
                "HEALTHY" { "Green" }
                "WARNING" { "Yellow" }
                default { "Red" }
            }
        )
    }
    default {
        Write-Host "Usage: .\SKRL-011-CONSTITUTIONAL-HEALTH-MONITOR.ps1 [options]" -ForegroundColor Yellow
        Write-Host "  -MonitorHealth           Monitor constitutional framework integrity" -ForegroundColor White
        Write-Host "  -AssessCompliance        Assess constitutional compliance" -ForegroundColor White
        Write-Host "  -CheckFrameworkIntegrity Check framework consistency" -ForegroundColor White
        Write-Host "  -RunDailyAssessment      Run comprehensive daily health assessment" -ForegroundColor White
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\SKRL-011-CONSTITUTIONAL-HEALTH-MONITOR.ps1 -RunDailyAssessment" -ForegroundColor Gray
        Write-Host "  .\SKRL-011-CONSTITUTIONAL-HEALTH-MONITOR.ps1 -AssessCompliance" -ForegroundColor Gray
    }
}