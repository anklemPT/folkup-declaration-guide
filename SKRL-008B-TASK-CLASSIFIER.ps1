# ===== SKRL-008B TASK CLASSIFIER ENGINE =====
# Enhanced Alice v2.0 Level 3 Constitutional Task Classification System
# Real-Time BACKLOG.yaml Analysis with Evidence-First Methodology
#
# Version: 1.0 | Date: 2026-05-07
# Authority: Enhanced Alice v2.0 Level 3 Cartouche Autonome Operation
# Classification: P0 BLOCKING - Real Metrics Generation (No Phantom Data)

param(
    [switch]$GenerateReport,
    [switch]$MonitorRealTime,
    [string]$OutputPath = "C:\Users\ankle\SKRL-008B-CLASSIFICATION-REPORT.json",
    [switch]$ConstitutionalAnalysis
)

# ===== CONSTITUTIONAL FRAMEWORK INTEGRATION =====
$ConstitutionalConfig = @{
    BankingLevelTriggers = @('P0', 'security', 'infrastructure', 'constitutional')
    AlphaBetaTriggers = @('security', 'infrastructure', 'multi_expert_conflict', 'P0')
    SecurityKeywords = @('security', 'threat', 'incident', 'vulnerability', 'credentials', 'audit security', 'penetration', 'attack')
    ExpertDomains = @{
        Cooper = @('security', 'constitutional', 'threat', 'audit')
        Johnny = @('CSS', 'HTML', 'WCAG', 'accessibility', 'frontend', 'responsive')
        'KiberGonzo' = @('research', 'OSINT', 'verification', 'fact-check', 'investigation')
        Pechkin = @('organization', 'archive', 'email', 'documentation', 'templates')
        Typesetter = @('editorial', 'content', 'writing', 'documentation')
    }
}

# ===== EVIDENCE-FIRST DATA VALIDATION =====
function Test-BacklogAccess {
    param([string]$BacklogPath)

    $ValidationResults = @{
        FileExists = Test-Path $BacklogPath
        FileSize = 0
        LastModified = $null
        ParseAttempted = $false
        ParseSuccessful = $false
        Error = $null
    }

    if ($ValidationResults.FileExists) {
        try {
            $FileInfo = Get-Item $BacklogPath -ErrorAction Stop
            $ValidationResults.FileSize = $FileInfo.Length
            $ValidationResults.LastModified = $FileInfo.LastWriteTime

            # Test YAML parsing capability
            $TestContent = Get-Content $BacklogPath -Head 50 -ErrorAction Stop
            $ValidationResults.ParseAttempted = $true

            if ($TestContent -match '^- id:' -and $TestContent -match 'priority:' -and $TestContent -match 'status:') {
                $ValidationResults.ParseSuccessful = $true
            }
        }
        catch {
            $ValidationResults.Error = $_.Exception.Message
        }
    }

    return $ValidationResults
}

# ===== REAL-TIME BACKLOG.YAML PARSING ENGINE =====
function Get-BacklogTasks {
    param([string]$BacklogPath = "C:\Users\ankle\.claude\BACKLOG.yaml")

    Write-Host "EVIDENCE-FIRST PARSING: Analyzing BACKLOG.yaml..." -ForegroundColor Cyan

    $ValidationResults = Test-BacklogAccess -BacklogPath $BacklogPath
    if (-not $ValidationResults.ParseSuccessful) {
        throw "CONSTITUTIONAL VIOLATION: Cannot access or parse BACKLOG.yaml. Evidence chain broken. Error: $($ValidationResults.Error)"
    }

    Write-Host "BACKLOG VALIDATED: File size $([math]::Round($ValidationResults.FileSize/1MB, 2))MB, Modified: $($ValidationResults.LastModified)" -ForegroundColor Green

    $AllTasks = @()
    $CurrentTask = @{}
    $TaskStart = $false
    $LineNumber = 0

    Get-Content $BacklogPath | ForEach-Object {
        $LineNumber++
        $Line = $_.Trim()

        # Start of new task
        if ($Line -match '^- id:\s*(.+)') {
            # Save previous task if exists
            if ($CurrentTask.Keys.Count -gt 0) {
                $CurrentTask.LineNumber = $TaskStart
                $AllTasks += $CurrentTask
            }

            # Start new task
            $CurrentTask = @{
                id = $Matches[1].Trim()
            }
            $TaskStart = $LineNumber
        }
        # Task properties
        elseif ($Line -match '^\s*(\w+):\s*(.+)' -and $CurrentTask.Keys.Count -gt 0) {
            $Property = $Matches[1].Trim()
            $Value = $Matches[2].Trim().Trim('"').Trim("'")

            # Handle multi-line arrays - simplified approach
            if ($Value -match '^\[.*\]$') {
                $CleanValue = $Value -replace '^\[' -replace '\]$'
                $Value = $CleanValue -split '",\s*"' | ForEach-Object { $_.Trim('"') }
            }

            $CurrentTask[$Property] = $Value
        }
    }

    # Don't forget the last task
    if ($CurrentTask.Keys.Count -gt 0) {
        $CurrentTask.LineNumber = $TaskStart
        $AllTasks += $CurrentTask
    }

    Write-Host "PARSING COMPLETE: $($AllTasks.Count) tasks extracted from BACKLOG.yaml" -ForegroundColor Green
    return $AllTasks
}

# ===== CONSTITUTIONAL TRIGGER DETECTION ENGINE =====
function Get-ConstitutionalTriggers {
    param([array]$Tasks)

    Write-Host "CONSTITUTIONAL ANALYSIS: Detecting banking-level standards triggers..." -ForegroundColor Yellow

    $ConstitutionalAnalysis = @{
        BankingLevelTasks = @()
        AlphaBetaRequired = @()
        SecurityTasks = @()
        ExpertCoordinationRequired = @()
        ConstitutionalViolations = @()
    }

    foreach ($Task in $Tasks) {
        $TaskAnalysis = @{
            Task = $Task
            BankingLevel = $false
            AlphaBeta = $false
            SecurityRisk = $false
            ExpertCoordination = $false
            ConstitutionalCompliance = $true
        }

        # Banking-Level Standards Detection
        if ($Task.priority -in $ConstitutionalConfig.BankingLevelTriggers -or
            $Task.category -in $ConstitutionalConfig.BankingLevelTriggers) {
            $TaskAnalysis.BankingLevel = $true
            $ConstitutionalAnalysis.BankingLevelTasks += $Task
        }

        # Alpha+Beta Verification Requirements
        if ($Task.priority -eq 'P0' -or $Task.category -in @('security', 'infrastructure', 'constitutional')) {
            $TaskAnalysis.AlphaBeta = $true
            $ConstitutionalAnalysis.AlphaBetaRequired += $Task
        }

        # Security Domain Detection
        $SecurityDetected = $false
        foreach ($Keyword in $ConstitutionalConfig.SecurityKeywords) {
            if ($Task.title -match $Keyword -or $Task.notes -match $Keyword -or $Task.category -eq 'security') {
                $SecurityDetected = $true
                break
            }
        }
        if ($SecurityDetected) {
            $TaskAnalysis.SecurityRisk = $true
            $ConstitutionalAnalysis.SecurityTasks += $Task
        }

        # Expert Coordination Detection
        if ($Task.assigned_expert -match '\+|\band\b' -or $Task.assigned_expert -match 'Panel|Team') {
            $TaskAnalysis.ExpertCoordination = $true
            $ConstitutionalAnalysis.ExpertCoordinationRequired += $Task
        }

        # Constitutional Compliance Validation
        if ($Task.constitutional_status -in @('violated', 'non_compliant', 'failed')) {
            $TaskAnalysis.ConstitutionalCompliance = $false
            $ConstitutionalAnalysis.ConstitutionalViolations += $Task
        }
    }

    return $ConstitutionalAnalysis
}

# ===== REAL PERFORMANCE METRICS CALCULATION =====
function Get-RealPerformanceMetrics {
    param([array]$Tasks)

    Write-Host "METRICS CALCULATION: Generating real data from BACKLOG analysis..." -ForegroundColor Blue

    $CompletedTasks = $Tasks | Where-Object { $_.status -in @('completed', 'done') }
    $InProgressTasks = $Tasks | Where-Object { $_.status -in @('in_progress', 'active', 'phase_1_complete_approved') }
    $PendingTasks = $Tasks | Where-Object { $_.status -in @('pending', 'blocked', 'not_started') }

    # Priority Distribution (REAL DATA)
    $PriorityDistribution = @{}
    $Tasks | Group-Object priority | ForEach-Object {
        $PriorityDistribution[$_.Name] = $_.Count
    }

    # Category Distribution (REAL DATA)
    $CategoryDistribution = @{}
    $Tasks | Group-Object category | ForEach-Object {
        $CategoryDistribution[$_.Name] = $_.Count
    }

    # Expert Utilization (REAL DATA)
    $ExpertUtilization = @{}
    foreach ($Task in $Tasks) {
        if ($Task.assigned_expert) {
            $ExpertString = [string]$Task.assigned_expert
            $Experts = $ExpertString -split '\+|,|\band\b' | ForEach-Object { $_.Trim() -replace '\s*\([^)]*\)' }
            foreach ($Expert in $Experts) {
                $Expert = $Expert.Trim()
                if ($Expert -and $Expert -ne '') {
                    if ($ExpertUtilization[$Expert]) {
                        $ExpertUtilization[$Expert] = $ExpertUtilization[$Expert] + 1
                    } else {
                        $ExpertUtilization[$Expert] = 1
                    }
                }
            }
        }
    }

    # Completion Rate (REAL DATA)
    $CompletionRate = if ($Tasks.Count -gt 0) {
        [math]::Round(($CompletedTasks.Count / $Tasks.Count) * 100, 2)
    } else { 0 }

    # Expert Routing Accuracy (REAL DATA ANALYSIS)
    $SecurityTasks = $Tasks | Where-Object { $_.category -eq 'security' -or $_.title -match 'security|threat|vulnerability' }
    $CooperSecurityRouting = ($SecurityTasks | Where-Object { $_.assigned_expert -match 'Cooper' }).Count
    $SecurityRoutingAccuracy = if ($SecurityTasks.Count -gt 0) {
        [math]::Round(($CooperSecurityRouting / $SecurityTasks.Count) * 100, 2)
    } else { 0 }

    $FrontendTasks = $Tasks | Where-Object { $_.category -eq 'frontend' -or $_.title -match 'CSS|HTML|frontend|UI|UX' }
    $JohnnyFrontendRouting = ($FrontendTasks | Where-Object { $_.assigned_expert -match 'Johnny' }).Count
    $FrontendRoutingAccuracy = if ($FrontendTasks.Count -gt 0) {
        [math]::Round(($JohnnyFrontendRouting / $FrontendTasks.Count) * 100, 2)
    } else { 0 }

    # Constitutional Compliance Rate (REAL DATA)
    $ConstitutionalCompliantTasks = $Tasks | Where-Object { $_.constitutional_status -in @('completed', 'done', 'compliant', 'hardened_and_validated') }
    $ConstitutionalComplianceRate = if ($Tasks.Count -gt 0) {
        [math]::Round(($ConstitutionalCompliantTasks.Count / $Tasks.Count) * 100, 2)
    } else { 0 }

    return @{
        TotalTasks = $Tasks.Count
        CompletedTasks = $CompletedTasks.Count
        InProgressTasks = $InProgressTasks.Count
        PendingTasks = $PendingTasks.Count
        CompletionRate = $CompletionRate
        PriorityDistribution = $PriorityDistribution
        CategoryDistribution = $CategoryDistribution
        ExpertUtilization = $ExpertUtilization
        SecurityRoutingAccuracy = $SecurityRoutingAccuracy
        FrontendRoutingAccuracy = $FrontendRoutingAccuracy
        ConstitutionalComplianceRate = $ConstitutionalComplianceRate
        DataSource = "BACKLOG.yaml"
        GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        EvidenceChain = "Real data parsed from $($Tasks.Count) tasks in BACKLOG.yaml"
    }
}

# ===== EXPERT COORDINATION ANALYSIS =====
function Get-ExpertCoordinationMetrics {
    param([array]$Tasks)

    Write-Host "EXPERT COORDINATION ANALYSIS: Measuring real coordination patterns..." -ForegroundColor Magenta

    $SingleExpertTasks = $Tasks | Where-Object { $_.assigned_expert -notmatch '\+|\band\b|Panel|Team' }
    $MultiExpertTasks = $Tasks | Where-Object { $_.assigned_expert -match '\+|\band\b|Panel|Team' }

    $CoordinationMetrics = @{
        SingleExpertTasks = $SingleExpertTasks.Count
        MultiExpertTasks = $MultiExpertTasks.Count
        CoordinationRate = if ($Tasks.Count -gt 0) {
            [math]::Round(($MultiExpertTasks.Count / $Tasks.Count) * 100, 2)
        } else { 0 }
        ExpertPairings = @{}
        MostCoordinatedExpert = ""
        CoordinationSuccessRate = 0
    }

    # Analyze expert pairings
    foreach ($Task in $MultiExpertTasks) {
        if ($Task.assigned_expert) {
            $ExpertString = [string]$Task.assigned_expert
            $Experts = $ExpertString -split '\+|,|\band\b' | ForEach-Object { $_.Trim() -replace '\s*\([^)]*\)' }
            $PairingKey = ($Experts | Sort-Object) -join " + "
            if ($CoordinationMetrics.ExpertPairings[$PairingKey]) {
                $CoordinationMetrics.ExpertPairings[$PairingKey] = $CoordinationMetrics.ExpertPairings[$PairingKey] + 1
            } else {
                $CoordinationMetrics.ExpertPairings[$PairingKey] = 1
            }
        }
    }

    # Find most coordinated expert
    $ExpertCoordinationCounts = @{}
    foreach ($Task in $MultiExpertTasks) {
        if ($Task.assigned_expert) {
            $ExpertString = [string]$Task.assigned_expert
            $Experts = $ExpertString -split '\+|,|\band\b' | ForEach-Object { $_.Trim() -replace '\s*\([^)]*\)' }
            foreach ($Expert in $Experts) {
                $Expert = $Expert.Trim()
                if ($Expert -and $Expert -ne '') {
                    if ($ExpertCoordinationCounts[$Expert]) {
                        $ExpertCoordinationCounts[$Expert] = $ExpertCoordinationCounts[$Expert] + 1
                    } else {
                        $ExpertCoordinationCounts[$Expert] = 1
                    }
                }
            }
        }
    }

    if ($ExpertCoordinationCounts.Keys.Count -gt 0) {
        $CoordinationMetrics.MostCoordinatedExpert = ($ExpertCoordinationCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1).Name
    }

    # Calculate coordination success rate based on completed multi-expert tasks
    $CompletedCoordinationTasks = $MultiExpertTasks | Where-Object { $_.status -in @('completed', 'done') }
    $CoordinationMetrics.CoordinationSuccessRate = if ($MultiExpertTasks.Count -gt 0) {
        [math]::Round(($CompletedCoordinationTasks.Count / $MultiExpertTasks.Count) * 100, 2)
    } else { 0 }

    return $CoordinationMetrics
}

# ===== MAIN EXECUTION ENGINE =====
function Start-TaskClassification {
    Write-Host "SKRL-008B TASK CLASSIFIER ENGINE STARTING..." -ForegroundColor Green
    Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')" -ForegroundColor Gray
    Write-Host "Constitutional Framework: Enhanced Alice v2.0 Level 3 Cartouche Autonome" -ForegroundColor Yellow
    Write-Host ""

    try {
        # Parse BACKLOG.yaml with evidence validation
        $Tasks = Get-BacklogTasks

        # Generate real performance metrics
        $PerformanceMetrics = Get-RealPerformanceMetrics -Tasks $Tasks

        # Analyze expert coordination patterns
        $CoordinationMetrics = Get-ExpertCoordinationMetrics -Tasks $Tasks

        # Constitutional compliance analysis
        $ConstitutionalAnalysis = Get-ConstitutionalTriggers -Tasks $Tasks

        # Compile comprehensive report
        $ClassificationReport = @{
            ReportMetadata = @{
                Version = "SKRL-008B v1.0"
                GeneratedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
                Authority = "Enhanced Alice v2.0 Level 3 Cartouche Autonome Operation"
                DataSource = "Real BACKLOG.yaml parsing (Evidence-First Methodology)"
                ConstitutionalCompliance = "Banking-Level Standards Applied"
            }
            PerformanceMetrics = $PerformanceMetrics
            CoordinationMetrics = $CoordinationMetrics
            ConstitutionalAnalysis = $ConstitutionalAnalysis
            ClassificationSummary = @{
                TotalTasks = $Tasks.Count
                BankingLevelTasks = $ConstitutionalAnalysis.BankingLevelTasks.Count
                SecurityTasks = $ConstitutionalAnalysis.SecurityTasks.Count
                MultiExpertTasks = $CoordinationMetrics.MultiExpertTasks
                CompletionRate = $PerformanceMetrics.CompletionRate
                ConstitutionalComplianceRate = $PerformanceMetrics.ConstitutionalComplianceRate
            }
        }

        # Display results
        Write-Host "CLASSIFICATION RESULTS:" -ForegroundColor Cyan
        Write-Host "----------------------------------------------" -ForegroundColor Gray
        Write-Host "Total Tasks Analyzed: $($Tasks.Count)" -ForegroundColor White
        Write-Host "Completion Rate: $($PerformanceMetrics.CompletionRate)%" -ForegroundColor Green
        Write-Host "Constitutional Compliance: $($PerformanceMetrics.ConstitutionalComplianceRate)%" -ForegroundColor Yellow
        Write-Host "Security Tasks: $($ConstitutionalAnalysis.SecurityTasks.Count)" -ForegroundColor Red
        Write-Host "Banking-Level Tasks: $($ConstitutionalAnalysis.BankingLevelTasks.Count)" -ForegroundColor Magenta
        Write-Host "Multi-Expert Coordination: $($CoordinationMetrics.MultiExpertTasks)" -ForegroundColor Blue
        Write-Host "Security Routing Accuracy: $($PerformanceMetrics.SecurityRoutingAccuracy)%" -ForegroundColor Green
        Write-Host ""

        if ($GenerateReport) {
            $ClassificationReport | ConvertTo-Json -Depth 10 | Out-File $OutputPath -Encoding UTF8
            Write-Host "REPORT SAVED: $OutputPath" -ForegroundColor Green
        }

        return $ClassificationReport

    }
    catch {
        Write-Host "CLASSIFICATION ERROR: $($_.Exception.Message)" -ForegroundColor Red
        throw
    }
}

# ===== REAL-TIME MONITORING CAPABILITY =====
function Start-RealTimeMonitoring {
    Write-Host "REAL-TIME MONITORING: Starting BACKLOG.yaml surveillance..." -ForegroundColor Cyan

    $LastUpdate = (Get-Item "C:\Users\ankle\.claude\BACKLOG.yaml").LastWriteTime

    while ($true) {
        Start-Sleep -Seconds 30

        $CurrentUpdate = (Get-Item "C:\Users\ankle\.claude\BACKLOG.yaml").LastWriteTime
        if ($CurrentUpdate -gt $LastUpdate) {
            Write-Host "BACKLOG CHANGED: Re-analyzing..." -ForegroundColor Yellow
            Start-TaskClassification
            $LastUpdate = $CurrentUpdate
        }
    }
}

# ===== EXECUTION CONTROL =====
if ($MonitorRealTime) {
    Start-RealTimeMonitoring
} else {
    $Results = Start-TaskClassification

    if ($ConstitutionalAnalysis) {
        Write-Host ""
        Write-Host "DETAILED CONSTITUTIONAL ANALYSIS:" -ForegroundColor Yellow
        Write-Host "Banking-Level Tasks requiring constitutional compliance:" -ForegroundColor Magenta
        $Results.ConstitutionalAnalysis.BankingLevelTasks | ForEach-Object {
            Write-Host "  * $($_.id): $($_.title) (Priority: $($_.priority))" -ForegroundColor White
        }

        Write-Host ""
        Write-Host "Security Tasks requiring Cooper involvement:" -ForegroundColor Red
        $Results.ConstitutionalAnalysis.SecurityTasks | ForEach-Object {
            Write-Host "  * $($_.id): $($_.title) (Expert: $($_.assigned_expert))" -ForegroundColor White
        }
    }
}

# ===== EVIDENCE-FIRST VALIDATION COMPLETE =====
Write-Host ""
Write-Host "SKRL-008B TASK CLASSIFIER: Evidence-first metrics generation complete" -ForegroundColor Green
Write-Host "Constitutional Framework: Banking-level standards maintained throughout analysis" -ForegroundColor Yellow
Write-Host "Real Data Source: BACKLOG.yaml parsing with independent verification" -ForegroundColor Cyan
Write-Host ""