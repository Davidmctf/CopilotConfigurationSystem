<#
.SYNOPSIS
    Validate composition structure
.DESCRIPTION
    Validates that ALL composition files reference valid template paths.
    Checks JSON structure and ensures referenced templates exist.
.PARAMETER Verbose
    Show all composition details
.PARAMETER Fix
    Attempt to fix broken references (future)
.EXIT CODE
    0 = All compositions valid (✅ PASS)
    1 = Invalid compositions detected (❌ FAIL)
    2 = No composition files found
#>

param([switch]$Verbose, [switch]$Fix)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName
$CompositionsDir = Join-Path $ProjectRoot "prompts\compositions"
$TemplatesDir = Join-Path $ProjectRoot "prompts\templates"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "STEP 15: validate-compositions" -ForegroundColor Cyan
Write-Host "Validating composition structure" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $CompositionsDir)) {
    Write-Host "❌ FAIL: Compositions directory not found" -ForegroundColor Red
    exit 2
}

if (-not (Test-Path $TemplatesDir)) {
    Write-Host "❌ FAIL: Templates directory not found" -ForegroundColor Red
    exit 2
}

$CompositionFiles = Get-ChildItem -Path $CompositionsDir -Filter "*.composition.json" -File -ErrorAction SilentlyContinue
$CompositionCount = $CompositionFiles.Count

if ($CompositionCount -eq 0) {
    Write-Host "❌ FAIL: No composition files found" -ForegroundColor Red
    exit 2
}

Write-Host "🔍 Found $CompositionCount composition files"
Write-Host ""

$InvalidCount = 0
$BrokenRefCount = 0
$MissingFields = 0
$ValidCount = 0

foreach ($CompFile in $CompositionFiles) {
    $CompName = $CompFile.Name
    
    if ($Verbose) {
        Write-Host "Validating: $CompName" -ForegroundColor Cyan
    }
    
    try {
        $CompJson = Get-Content $CompFile.FullName | ConvertFrom-Json
    }
    catch {
        Write-Host "❌ $CompName : Not valid JSON" -ForegroundColor Red
        $InvalidCount++
        continue
    }
    
    # Check for required fields
    $HasId = $null -ne $CompJson.id
    $HasTemplates = $null -ne $CompJson.templates
    $HasName = $null -ne $CompJson.name
    
    if (-not $HasId) {
        Write-Host "⚠️  $CompName : Missing 'id' field" -ForegroundColor Yellow
        $MissingFields++
    }
    
    if (-not $HasTemplates) {
        Write-Host "⚠️  $CompName : Missing 'templates' array" -ForegroundColor Yellow
        $MissingFields++
    }
    
    if (-not $HasName) {
        Write-Host "⚠️  $CompName : Missing 'name' field" -ForegroundColor Yellow
        $MissingFields++
    }
    
    # Check template references
    $BrokenRefs = 0
    if ($CompJson.templates) {
        foreach ($Template in $CompJson.templates) {
            $TemplateRef = $Template.ref
            if ($TemplateRef) {
                # Convert template ref to file path
                # Refs like "code.class" should map to "templates/code/class.prompt.md"
                $TemplatePath = Join-Path $TemplatesDir ($TemplateRef.Replace(".", "\") + ".prompt.md")
                
                if (-not (Test-Path $TemplatePath)) {
                    if ($Verbose) {
                        Write-Host "  ❌ Missing template: $TemplateRef" -ForegroundColor Red
                        Write-Host "     Expected path: $TemplatePath" -ForegroundColor Red
                    }
                    $BrokenRefs++
                }
            }
        }
    }
    
    if ($BrokenRefs -gt 0) {
        $BrokenRefCount++
        Write-Host "❌ $CompName : $BrokenRefs broken template reference(s)" -ForegroundColor Red
    }
    else {
        $ValidCount++
        if ($Verbose) {
            Write-Host "✅ $CompName : Valid" -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 Validation Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Total compositions: $CompositionCount"
Write-Host "Valid compositions: $ValidCount"
Write-Host "Invalid JSON: $InvalidCount"
Write-Host "Compositions with broken refs: $BrokenRefCount"
Write-Host "Missing fields: $MissingFields"
Write-Host ""

if ($InvalidCount -eq 0 -and $BrokenRefCount -eq 0) {
    Write-Host "✅ PASS: All compositions valid" -ForegroundColor Green
    exit 0
}
else {
    $TotalErrors = $InvalidCount + $BrokenRefCount
    Write-Host "❌ FAIL: $TotalErrors composition issue(s) detected" -ForegroundColor Red
    if (-not $Verbose) {
        Write-Host "(Use -Verbose for details)" -ForegroundColor Yellow
    }
    exit 1
}
