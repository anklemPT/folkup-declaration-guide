# SKRL-011 Expert Coordination Protection Monitor
# Enhanced Alice v2.0 Level 3 Constitutional Framework
# Semantic Integration Integrity and Expert Isolation Attack Prevention

param(
    [switch]$MonitorIntegrity,
    [switch]$ValidateRouting,
    [switch]$DetectIsolationAttacks,
    [switch]$RunFullMonitoring,
    [string]$BacklogPath = "C:\Users\ankle\.claude\BACKLOG.yaml",
    [string]$RulesPath = "C:\Users\ankle\.claude\rules"
)

Write-Host "SKRL-011 EXPERT COORDINATION PROTECTION MONITOR v1.0" -ForegroundColor Cyan
Write-Host "Enhanced Alice v2.0 Level 3 Expert Coordination Architecture Protection" -ForegroundColor Yellow
Write-Host "Semantic Integration Integrity + Isolation Attack Prevention" -ForegroundColor Green
Write-Host ""

# Expert Coordination Architecture Framework
$ExpertCoordinationFramework = @{
    "semantic_integration_requirements" = @{
        "intent_classification" = @("BLOCKING", "ADVISORY", "GENERATIVE")
        "confidence_level" = @("HIGH", "MEDIUM", "LOW")
        "follow_up_requirements" = @("required", "recommended", "not_needed")
        "expert_validation" = $true
        "constitutional_compliance" = $true
    }
    "expert_domain_authority" = @{
        "cooper_security" = @{
            "triggers" = @("security", "threat", "vulnerability", "credentials", "audit", "penetration", "attack", "infrastructure")
            "priority" = "P0"
            "mandatory" = $true
            "constitutional_requirement" = $true
        }
        "johnny_frontend" = @{
            "triggers" = @("css", "html", "wcag", "accessibility", "responsive", "layout", "frontend", "styling")
            "priority" = "P1"
            "mandatory" = $false
            "constitutional_requirement" = $false
        }
        "cyber_gonzo_research" = @{
            "triggers" = @("verification", "osint", "research", "fact-check", "investigate", "analysis")
            "priority" = "P1"
            "mandatory" = $false
            "constitutional_requirement" = $false
        }
        "pechkin_organization" = @{
            "triggers" = @("organize", "archive", "email", "correspondence", "file", "templates", "documentation")
            "priority" = "P2"
            "mandatory" = $false
            "constitutional_requirement" = $false
        }
        "typesetter_editorial" = @{
            "triggers" = @("content", "editorial", "writing", "style", "brand", "voice", "tone")
            "priority" = "P2"
            "mandatory" = $false
            "constitutional_requirement" = $false
        }
    }
    "isolation_attack_indicators" = @{
        "expert_context_separation" = @("prevent expert knowledge sharing", "isolate expert contexts", "separate domain expertise")
        "coordination_bypass" = @("direct task assignment", "bypass expert routing", "skip coordination")
        "semantic_integration_elimination" = @("remove intent classification", "eliminate semantic footer", "bypass integration")
        "expert_authority_undermining" = @("override domain expertise", "ignore expert requirements", "minimize expert role")
    }
}

# Semantic Integration Integrity Validation
function Test-SemanticIntegrationIntegrity {
    param($TaskData, $ExpertOutputs)

    $integrity_issues = @()
    $validation_results = @()

    Write-Host "🔍 Validating semantic integration integrity..." -ForegroundColor Yellow

    # Check for required semantic footer elements
    if ($TaskData.ContainsKey("expert_coordination") -and $TaskData["expert_coordination"]) {
        $expert_count = ($TaskData["expert_coordination"] -split ",").Count

        if ($expert_count -gt 1) {
            Write-Host "  👥 Multi-expert task detected ($expert_count experts)" -ForegroundColor Blue

            # Verify semantic merge template usage
            if (-not ($TaskData.ContainsKey("semantic_integration") -and $TaskData["semantic_integration"])) {
                $integrity_issues += "MAJOR: Multi-expert task missing semantic integration template"
            }

            # Check for intent classification aggregation
            if (-not ($TaskData.ContainsKey("intent_classification") -and $TaskData["intent_classification"] -match "BLOCKING|ADVISORY|GENERATIVE")) {
                $integrity_issues += "MAJOR: Multi-expert task missing intent classification"
            }

            # Verify coordination quality gates
            $required_coordination_fields = @("semantic_integration", "intent_aggregation", "conflict_resolution")
            foreach ($field in $required_coordination_fields) {
                if (-not ($TaskData.ContainsKey($field))) {
                    $integrity_issues += "MINOR: Missing coordination field: $field"
                }
            }
        }
    }

    # Check individual expert output compliance
    if ($TaskData.ContainsKey("assigned_expert") -and $TaskData["assigned_expert"]) {
        $experts = $TaskData["assigned_expert"] -split ","
        foreach ($expert in $experts) {
            $expert = $expert.Trim()

            # Verify expert outputs include semantic footer
            if (-not ($TaskData.ContainsKey("intent_classification"))) {
                $integrity_issues += "MINOR: Expert output missing intent classification for $expert"
            }

            if (-not ($TaskData.ContainsKey("confidence_level"))) {
                $integrity_issues += "MINOR: Expert output missing confidence level for $expert"
            }

            if (-not ($TaskData.ContainsKey("follow_up_requirements"))) {
                $integrity_issues += "MINOR: Expert output missing follow-up requirements for $expert"
            }
        }
    }

    return @{
        "integrity_issues" = $integrity_issues
        "expert_count" = if ($TaskData.ContainsKey("expert_coordination")) { ($TaskData["expert_coordination"] -split ",").Count } else { 1 }
        "semantic_integration_required" = ($expert_count -gt 1)
        "compliance_score" = if ($integrity_issues.Count -eq 0) { 100 } else { [math]::Max(0, 100 - ($integrity_issues.Count * 10)) }
    }
}

# Expert Routing Integrity Validation
function Test-ExpertRoutingIntegrity {
    param($TaskData)

    $routing_violations = @()
    $routing_recommendations = @()

    Write-Host "🎯 Validating expert routing integrity..." -ForegroundColor Yellow

    $description = if ($TaskData.ContainsKey("description")) { $TaskData["description"] } else { "" }
    $title = if ($TaskData.ContainsKey("title")) { $TaskData["title"] } else { "" }
    $category = if ($TaskData.ContainsKey("category")) { $TaskData["category"] } else { "" }
    $priority = if ($TaskData.ContainsKey("priority")) { $TaskData["priority"] } else { "" }
    $assigned_expert = if ($TaskData.ContainsKey("assigned_expert")) { $TaskData["assigned_expert"] } else { "" }

    $full_text = "$description $title $category".ToLower()

    # Cooper Security Domain Validation
    $cooper_triggers = $ExpertCoordinationFramework["expert_domain_authority"]["cooper_security"]["triggers"]
    $cooper_triggered = $false
    foreach ($trigger in $cooper_triggers) {
        if ($full_text -match $trigger -or $category -eq "security" -or $priority -eq "P0") {
            $cooper_triggered = $true
            break
        }
    }

    if ($cooper_triggered) {
        if ($assigned_expert -notmatch "cooper|Cooper") {
            if ($priority -eq "P0" -or $category -eq "security") {
                $routing_violations += "CRITICAL: Security/P0 task requires Cooper involvement (constitutional mandate)"
            } else {
                $routing_violations += "MAJOR: Security-related task should include Cooper expertise"
            }
        } else {
            Write-Host "  ✅ Cooper properly assigned for security task" -ForegroundColor Green
        }
    }

    # Johnny Frontend Domain Validation
    $johnny_triggers = $ExpertCoordinationFramework["expert_domain_authority"]["johnny_frontend"]["triggers"]
    $johnny_triggered = $false
    foreach ($trigger in $johnny_triggers) {
        if ($full_text -match $trigger -or $category -eq "frontend") {
            $johnny_triggered = $true
            break
        }
    }

    if ($johnny_triggered) {
        if ($assigned_expert -notmatch "johnny|Johnny") {
            $routing_recommendations += "ADVISORY: Frontend task would benefit from Johnny expertise"
        } else {
            Write-Host "  ✅ Johnny properly assigned for frontend task" -ForegroundColor Green
        }
    }

    # КиберГонзо Research Domain Validation
    $cyber_gonzo_triggers = $ExpertCoordinationFramework["expert_domain_authority"]["cyber_gonzo_research"]["triggers"]
    $cyber_gonzo_triggered = $false
    foreach ($trigger in $cyber_gonzo_triggers) {
        if ($full_text -match $trigger -or $category -eq "research") {
            $cyber_gonzo_triggered = $true
            break
        }
    }

    if ($cyber_gonzo_triggered) {
        if ($assigned_expert -notmatch "cyber-gonzo|КиберГонзо") {
            $routing_recommendations += "ADVISORY: Research task would benefit from КиберГонзо expertise"
        } else {
            Write-Host "  ✅ КиберГонзо properly assigned for research task" -ForegroundColor Green
        }
    }

    return @{
        "routing_violations" = $routing_violations
        "routing_recommendations" = $routing_recommendations
        "cooper_required" = $cooper_triggered
        "expert_assignments_correct" = ($routing_violations.Count -eq 0)
    }
}

# Expert Isolation Attack Detection
function Test-ExpertIsolationAttacks {
    param($TaskData, $SystemContext)

    $isolation_indicators = @()
    $attack_patterns = @()

    Write-Host "🛡️ Detecting expert isolation attacks..." -ForegroundColor Yellow

    $description = if ($TaskData.ContainsKey("description")) { $TaskData["description"] } else { "" }
    $notes = if ($TaskData.ContainsKey("notes")) { $TaskData["notes"] } else { "" }
    $methodology = if ($TaskData.ContainsKey("methodology")) { $TaskData["methodology"] } else { "" }

    $full_content = "$description $notes $methodology".ToLower()

    # Check for expert context separation indicators
    $separation_indicators = $ExpertCoordinationFramework["isolation_attack_indicators"]["expert_context_separation"]
    foreach ($indicator in $separation_indicators) {
        if ($full_content -match $indicator) {
            $isolation_indicators += "Expert context separation detected: $indicator"
        }
    }

    # Check for coordination bypass indicators
    $bypass_indicators = $ExpertCoordinationFramework["isolation_attack_indicators"]["coordination_bypass"]
    foreach ($indicator in $bypass_indicators) {
        if ($full_content -match $indicator) {
            $isolation_indicators += "Coordination bypass detected: $indicator"
        }
    }

    # Check for semantic integration elimination
    $integration_indicators = $ExpertCoordinationFramework["isolation_attack_indicators"]["semantic_integration_elimination"]
    foreach ($indicator in $integration_indicators) {
        if ($full_content -match $indicator) {
            $isolation_indicators += "Semantic integration elimination detected: $indicator"
        }
    }

    # Check for expert authority undermining
    $authority_indicators = $ExpertCoordinationFramework["isolation_attack_indicators"]["expert_authority_undermining"]
    foreach ($indicator in $authority_indicators) {
        if ($full_content -match $indicator) {
            $isolation_indicators += "Expert authority undermining detected: $indicator"
        }
    }

    # Analyze isolation patterns
    if ($isolation_indicators.Count -gt 0) {
        $attack_patterns += "CRITICAL: Expert isolation attack pattern detected"

        if ($isolation_indicators.Count -ge 3) {
            $attack_patterns += "CRITICAL: Systematic expert coordination destruction attempt"
        }

        if ($TaskData.ContainsKey("priority") -and $TaskData["priority"] -eq "P0") {
            $attack_patterns += "CRITICAL: Isolation attack on P0 task (constitutional violation)"
        }
    }

    return @{
        "isolation_indicators" = $isolation_indicators
        "attack_patterns" = $attack_patterns
        "isolation_detected" = ($isolation_indicators.Count -gt 0)
        "attack_severity" = if ($attack_patterns.Count -eq 0) { "NONE" } elseif ($attack_patterns.Count -eq 1) { "LOW" } elseif ($attack_patterns.Count -eq 2) { "MEDIUM" } else { "HIGH" }
    }
}

# Comprehensive Expert Coordination Monitoring
function Start-ExpertCoordinationMonitoring {
    param($BacklogPath)

    Write-Host "🚀 Starting comprehensive expert coordination monitoring..." -ForegroundColor Cyan

    if (-not (Test-Path $BacklogPath)) {
        Write-Host "❌ BACKLOG file not found: $BacklogPath" -ForegroundColor Red
        return $false
    }

    $monitoring_results = @{
        "tasks_analyzed" = 0
        "semantic_integration_issues" = @()
        "routing_violations" = @()
        "isolation_attacks" = @()
        "constitutional_violations" = @()
        "overall_health" = "HEALTHY"
    }

    try {
        $backlogContent = Get-Content $BacklogPath -Raw

        # Parse YAML structure (simplified)
        $lines = $backlogContent -split "`n"
        $current_task = @{}
        $in_task = $false

        foreach ($line in $lines) {
            if ($line -match "^- id: (.+)") {
                # Process previous task if exists
                if ($in_task -and $current_task.Count -gt 0) {
                    $monitoring_results["tasks_analyzed"]++

                    # Test semantic integration integrity
                    $semantic_result = Test-SemanticIntegrationIntegrity -TaskData $current_task
                    if ($semantic_result["integrity_issues"].Count -gt 0) {
                        $monitoring_results["semantic_integration_issues"] += @{
                            "task_id" = $current_task["id"]
                            "issues" = $semantic_result["integrity_issues"]
                            "compliance_score" = $semantic_result["compliance_score"]
                        }
                    }

                    # Test expert routing integrity
                    $routing_result = Test-ExpertRoutingIntegrity -TaskData $current_task
                    if ($routing_result["routing_violations"].Count -gt 0 -or $routing_result["routing_recommendations"].Count -gt 0) {
                        $monitoring_results["routing_violations"] += @{
                            "task_id" = $current_task["id"]
                            "violations" = $routing_result["routing_violations"]
                            "recommendations" = $routing_result["routing_recommendations"]
                        }
                    }

                    # Test for isolation attacks
                    $isolation_result = Test-ExpertIsolationAttacks -TaskData $current_task
                    if ($isolation_result["isolation_detected"]) {
                        $monitoring_results["isolation_attacks"] += @{
                            "task_id" = $current_task["id"]
                            "indicators" = $isolation_result["isolation_indicators"]
                            "attack_patterns" = $isolation_result["attack_patterns"]
                            "severity" = $isolation_result["attack_severity"]
                        }

                        if ($isolation_result["attack_severity"] -match "MEDIUM|HIGH") {
                            $monitoring_results["constitutional_violations"] += "Expert coordination architecture violation in task: $($current_task['id'])"
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

        # Process last task
        if ($in_task -and $current_task.Count -gt 0) {
            $monitoring_results["tasks_analyzed"]++

            $semantic_result = Test-SemanticIntegrationIntegrity -TaskData $current_task
            $routing_result = Test-ExpertRoutingIntegrity -TaskData $current_task
            $isolation_result = Test-ExpertIsolationAttacks -TaskData $current_task

            # Add results as above...
        }

        # Determine overall health
        if ($monitoring_results["constitutional_violations"].Count -gt 0) {
            $monitoring_results["overall_health"] = "CRITICAL"
        }
        elseif ($monitoring_results["isolation_attacks"].Count -gt 0) {
            $monitoring_results["overall_health"] = "WARNING"
        }
        elseif ($monitoring_results["semantic_integration_issues"].Count -gt 3) {
            $monitoring_results["overall_health"] = "WARNING"
        }

        # Generate monitoring report
        Write-Host "📊 Expert Coordination Monitoring Results:" -ForegroundColor Green
        Write-Host "  Tasks analyzed: $($monitoring_results['tasks_analyzed'])" -ForegroundColor White
        Write-Host "  Semantic integration issues: $($monitoring_results['semantic_integration_issues'].Count)" -ForegroundColor $(if ($monitoring_results['semantic_integration_issues'].Count -eq 0) { "Green" } else { "Yellow" })
        Write-Host "  Routing violations: $($monitoring_results['routing_violations'].Count)" -ForegroundColor $(if ($monitoring_results['routing_violations'].Count -eq 0) { "Green" } else { "Orange" })
        Write-Host "  Isolation attacks detected: $($monitoring_results['isolation_attacks'].Count)" -ForegroundColor $(if ($monitoring_results['isolation_attacks'].Count -eq 0) { "Green" } else { "Red" })
        Write-Host "  Constitutional violations: $($monitoring_results['constitutional_violations'].Count)" -ForegroundColor $(if ($monitoring_results['constitutional_violations'].Count -eq 0) { "Green" } else { "Red" })
        Write-Host "  Overall health: $($monitoring_results['overall_health'])" -ForegroundColor $(if ($monitoring_results['overall_health'] -eq "HEALTHY") { "Green" } elseif ($monitoring_results['overall_health'] -eq "WARNING") { "Yellow" } else { "Red" })

        # Save monitoring report
        $reportPath = "C:\Users\ankle\SKRL-011-EXPERT-COORDINATION-MONITORING-REPORT.json"
        $monitoring_results | ConvertTo-Json -Depth 4 | Set-Content -Path $reportPath -Encoding UTF8
        Write-Host "📄 Expert coordination monitoring report saved: $reportPath" -ForegroundColor Green

        return $monitoring_results

    } catch {
        Write-Host "❌ Error during expert coordination monitoring: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Main Execution Logic
switch ($true) {
    $MonitorIntegrity {
        Write-Host "🔍 Monitoring semantic integration integrity..." -ForegroundColor Cyan
        Start-ExpertCoordinationMonitoring -BacklogPath $BacklogPath
    }
    $ValidateRouting {
        Write-Host "🎯 Validating expert routing integrity..." -ForegroundColor Cyan
        Start-ExpertCoordinationMonitoring -BacklogPath $BacklogPath
    }
    $DetectIsolationAttacks {
        Write-Host "🛡️ Detecting expert isolation attacks..." -ForegroundColor Cyan
        Start-ExpertCoordinationMonitoring -BacklogPath $BacklogPath
    }
    $RunFullMonitoring {
        Write-Host "🚀 Running comprehensive expert coordination monitoring..." -ForegroundColor Cyan
        $results = Start-ExpertCoordinationMonitoring -BacklogPath $BacklogPath

        if ($results) {
            Write-Host ""
            Write-Host "🎯 Expert Coordination Health: $($results['overall_health'])" -ForegroundColor $(if ($results['overall_health'] -eq "HEALTHY") { "Green" } elseif ($results['overall_health'] -eq "WARNING") { "Yellow" } else { "Red" })

            if ($results["constitutional_violations"].Count -gt 0) {
                Write-Host "⚠️ Constitutional violations require immediate attention!" -ForegroundColor Red
            }
        }
    }
    default {
        Write-Host "Usage: .\SKRL-011-EXPERT-COORDINATION-MONITOR.ps1 [options]" -ForegroundColor Yellow
        Write-Host "  -MonitorIntegrity        Monitor semantic integration integrity" -ForegroundColor White
        Write-Host "  -ValidateRouting         Validate expert routing integrity" -ForegroundColor White
        Write-Host "  -DetectIsolationAttacks  Detect expert isolation attacks" -ForegroundColor White
        Write-Host "  -RunFullMonitoring       Run comprehensive expert coordination monitoring" -ForegroundColor White
        Write-Host ""
        Write-Host "Examples:" -ForegroundColor Yellow
        Write-Host "  .\SKRL-011-EXPERT-COORDINATION-MONITOR.ps1 -RunFullMonitoring" -ForegroundColor Gray
        Write-Host "  .\SKRL-011-EXPERT-COORDINATION-MONITOR.ps1 -DetectIsolationAttacks" -ForegroundColor Gray
    }
}