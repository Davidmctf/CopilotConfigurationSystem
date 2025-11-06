<#
.SYNOPSIS
    Master Test Runner for QA Framework
.DESCRIPTION
    Orchestrates all QA validation scripts in the correct order.
    Provides a single command to run the entire QA framework.
.PARAMETER Verbose
    Show detailed output for all tests
.PARAMETER Quick
    Skip optional tests (run critical tests only)
.PARAMETER JUnit
    Generate JUnit XML report (future)
.EXAMPLE
    .\run-all-tests.ps1 -Verbose
    .\run-all-tests.ps1 -Quick
.EXIT CODE
    0 = All tests pass (✅ PASS)
    1 = Some tests fail (❌ FAIL)
    2 = Critical error (missing test files)
#>

param(
    [switch]$Verbose,
    [switch]$Quick,
    [switch]$JUnit
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName

$Tests = @(
    "validate-schemas",
    "validate-references",
    "validate-completeness",
    "validate-compositions",
    "validate-consistency"
)

$TestResults = @{}
$TestDurations = @{}
$Passed = 0
$Failed = 0
$Total = $Tests.Count

# Banner
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   QA Framework - Master Test Runner    ║" -ForegroundColor Cyan
Write-Host "║   PHASE 3: QA Framework (STEP 17)      ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 Running $Total validation tests..."
Write-Host ""

# Run each test
$Tests | ForEach-Object -Begin { $TestNum = 0 } -Process {
    $TestNum++
    $TestName = $_
    $TestFile = Join-Path $ScriptDir "$TestName.ps1"
    
    if (-not (Test-Path $TestFile)) {
        Write-Host "❌ Test $TestNum/$Total : $TestName.ps1 NOT FOUND" -ForegroundColor Red
        $TestResults[$TestName] = "MISSING"
        $Failed++
        return
    }
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Test $TestNum/$Total : $TestName" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    # Run test and capture result
    $Stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    
    try {
        if ($Verbose) {
            & $TestFile -Verbose
            $TestExit = $LASTEXITCODE
        }
        else {
            & $TestFile 2>&1 | Where-Object { $_ -match '^(✅|❌|⚠️|📊|Total|Found|Items|Paths|Checking|Validating|Valid|Invalid|Missing|PASS|FAIL|Version|Naming|Frontmatter|Structure|issue)' }
            $TestExit = $LASTEXITCODE
        }
    }
    catch {
        $TestExit = 1
    }
    
    $Stopwatch.Stop()
    $Duration = $Stopwatch.ElapsedMilliseconds
    $TestDurations[$TestName] = $Duration
    
    Write-Host ""
    
    if ($TestExit -eq 0) {
        Write-Host "✅ PASS: $TestName" -ForegroundColor Green
        $TestResults[$TestName] = "PASS"
        $Passed++
    }
    else {
        Write-Host "❌ FAIL: $TestName" -ForegroundColor Red
        $TestResults[$TestName] = "FAIL"
        $Failed++
    }
    
    Write-Host ""
}

# Summary
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          Test Execution Summary        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Results table
Write-Host ("{0,-30} | {1,-8} | {2,-8}" -f "Test", "Result", "Duration") 
Write-Host ("{0,-30} | {1,-8} | {2,-8}" -f "---", "---", "---")

$Tests | ForEach-Object {
    $TestResult = $TestResults[$_]
    $TestDuration = $TestDurations[$_]
    
    switch ($TestResult) {
        "PASS" {
            Write-Host ("{0,-30} | {1,-8} | {2,-8}" -f $_, "✅ PASS", "$($TestDuration)ms") -ForegroundColor Green
        }
        "FAIL" {
            Write-Host ("{0,-30} | {1,-8} | {2,-8}" -f $_, "❌ FAIL", "$($TestDuration)ms") -ForegroundColor Red
        }
        "MISSING" {
            Write-Host ("{0,-30} | {1,-8} | {2,-8}" -f $_, "⚠️ MISSING", "-") -ForegroundColor Yellow
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Total tests: $Total"
Write-Host "Passed: $Passed" -ForegroundColor Green
Write-Host "Failed: $Failed" -ForegroundColor Red
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Final result
if ($Failed -eq 0) {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║     ✅ ALL TESTS PASSED! 🎉            ║" -ForegroundColor Green
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "QA Framework validation complete and successful."
    Write-Host "System is ready for deployment."
    exit 0
}
else {
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║      ❌ SOME TESTS FAILED!             ║" -ForegroundColor Red
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please review failures above and fix issues."
    exit 1
}
