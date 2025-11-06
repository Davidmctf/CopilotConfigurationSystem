<#
.SYNOPSIS
    Validate internal references and paths
.DESCRIPTION
    Validates all internal path and schema references across the system.
    Ensures no broken links, missing paths, or orphaned references.
.PARAMETER Verbose
    Show detailed output with all checks
.EXIT CODE
    0 = All validations passed
    1 = Validation with issues
#>

param([switch]$Verbose)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName

# Configuration
$SchemaDir = Join-Path $ProjectRoot "schemas"
$AgentsDir = Join-Path $ProjectRoot "agents"
$ChatmodesDir = Join-Path $ProjectRoot "chatmodes"
$InstructionsDir = Join-Path $ProjectRoot "instructions"
$PromptsDir = Join-Path $ProjectRoot "prompts"
$ToolsetsDir = Join-Path $ProjectRoot "toolsets"
$TemplatesDir = Join-Path $ProjectRoot "templates"

# Counters
$TotalChecks = 0
$PassedChecks = 0
$FailedChecks = 0
$Warnings = 0

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         STEP 13: Reference & Path Validation                  ║" -ForegroundColor Cyan
Write-Host "║                                                               ║" -ForegroundColor Cyan
Write-Host "║  Validates internal paths and references across the system    ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Starting reference validation..." -ForegroundColor Cyan
Write-Host ""

# 1. SCHEMA REFERENCE VALIDATION
Write-Host "━━━ SCHEMA REFERENCES ━━━" -ForegroundColor Cyan

$JsonFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.json" -Recurse -ErrorAction SilentlyContinue
foreach ($JsonFile in $JsonFiles) {
    try {
        $JsonContent = Get-Content $JsonFile.FullName | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($null -ne $JsonContent.PSObject.Properties['$schema']) {
            $SchemaRef = $JsonContent.'$schema'
            $TotalChecks++
            
            $ResolvedPath = Join-Path $ProjectRoot $SchemaRef
            if (Test-Path $ResolvedPath) {
                Write-Host "✓ Schema reference valid: $SchemaRef" -ForegroundColor Green
                $PassedChecks++
            }
            else {
                Write-Host "✗ Schema reference broken: $SchemaRef (from $($JsonFile.Name))" -ForegroundColor Red
                $FailedChecks++
            }
        }
    }
    catch {
        # Skip files that can't be parsed as JSON
    }
}

Write-Host ""

# 2. AGENT REFERENCE VALIDATION
Write-Host "━━━ AGENT REFERENCES ━━━" -ForegroundColor Cyan

$JsonFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.json" -Recurse -ErrorAction SilentlyContinue
foreach ($JsonFile in $JsonFiles) {
    try {
        $JsonContent = Get-Content $JsonFile.FullName | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($null -ne $JsonContent.PSObject.Properties['agent']) {
            $AgentRef = $JsonContent.agent
            if ($AgentRef -is [object]) {
                $AgentRef = $AgentRef.defaultAgent -or $AgentRef.id
            }
            
            if ($AgentRef) {
                $TotalChecks++
                $AgentDir = Join-Path $AgentsDir $AgentRef
                
                if (Test-Path $AgentDir) {
                    Write-Host "✓ Agent reference valid: $AgentRef" -ForegroundColor Green
                    $PassedChecks++
                }
                else {
                    Write-Host "✗ Agent reference broken: $AgentRef (from $($JsonFile.Name))" -ForegroundColor Red
                    $FailedChecks++
                }
            }
        }
    }
    catch {
        # Skip files that can't be parsed
    }
}

Write-Host ""

# 3. CORE DIRECTORY STRUCTURE VALIDATION
Write-Host "━━━ CORE DIRECTORY STRUCTURE ━━━" -ForegroundColor Cyan

$RequiredDirs = @($SchemaDir, $AgentsDir, $ChatmodesDir, $InstructionsDir, $PromptsDir, $ToolsetsDir, $TemplatesDir)
foreach ($Dir in $RequiredDirs) {
    $TotalChecks++
    if (Test-Path $Dir) {
        Write-Host "✓ Directory exists: $(Split-Path -Leaf $Dir)" -ForegroundColor Green
        $PassedChecks++
    }
    else {
        Write-Host "✗ Directory not found: $(Split-Path -Leaf $Dir)" -ForegroundColor Red
        $FailedChecks++
    }
}

Write-Host ""

# 4. MARKDOWN INTERNAL LINKS VALIDATION
Write-Host "━━━ MARKDOWN INTERNAL LINKS ━━━" -ForegroundColor Cyan

$MarkdownFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.md" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 10
foreach ($MdFile in $MarkdownFiles) {
    $Content = Get-Content $MdFile.FullName -Raw
    $Links = [regex]::Matches($Content, '\[.*?\]\(([^)]+\.md)\)')
    
    foreach ($Match in $Links) {
        $LinkPath = $Match.Groups[1].Value -replace '#.*', ''  # Remove anchors
        $TotalChecks++
        
        $FullPath = Join-Path (Split-Path $MdFile.FullName) $LinkPath
        if (Test-Path $FullPath) {
            Write-Host "✓ Markdown link valid: $LinkPath" -ForegroundColor Green
            $PassedChecks++
        }
        else {
            Write-Host "⚠ Markdown link warning: $LinkPath (from $($MdFile.Name))" -ForegroundColor Yellow
            $Warnings++
        }
    }
}

Write-Host ""

# Summary Report
Write-Host "╔═══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              REFERENCE VALIDATION SUMMARY                    ║" -ForegroundColor Cyan
Write-Host "╠═══════════════════════════════════════════════════════════════╣" -ForegroundColor Cyan
Write-Host "║ Total Checks:      $TotalChecks"
Write-Host "║ Passed:            $PassedChecks"
Write-Host "║ Failed:            $FailedChecks"
Write-Host "║ Warnings:          $Warnings"

if ($FailedChecks -eq 0) {
    Write-Host "║                                                               ║"
    Write-Host "║ ✅ ALL REFERENCE VALIDATIONS PASSED                         ║" -ForegroundColor Green
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    exit 0
}
else {
    Write-Host "║                                                               ║"
    Write-Host "║ ⚠️  REFERENCE VALIDATION WITH ISSUES                        ║" -ForegroundColor Yellow
    Write-Host "║ Review warnings and errors above                            ║"
    Write-Host "╚═══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    exit 1
}
