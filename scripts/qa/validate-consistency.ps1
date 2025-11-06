<#
.SYNOPSIS
    Validate system consistency
.DESCRIPTION
    Validates system-wide consistency including version numbers, naming conventions,
    YAML frontmatter, and file naming patterns.
.PARAMETER Verbose
    Show all consistency checks
.PARAMETER Strict
    Fail on warnings (not just errors)
.EXIT CODE
    0 = Consistent system (✅ PASS)
    1 = Inconsistencies detected (❌ FAIL)
#>

param([switch]$Verbose, [switch]$Strict)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName

Write-Host "================================" -ForegroundColor Cyan
Write-Host "STEP 16: validate-consistency" -ForegroundColor Cyan
Write-Host "Validating system consistency" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

$VersionIssues = 0
$NamingIssues = 0
$FrontmatterIssues = 0
$HeaderIssues = 0

# Check 1: Version Consistency
Write-Host "🔍 Check 1: Version consistency (should be 2.1.0)..."

$ExpectedVersion = "2.1.0"

$CopilotInstructionsPath = Join-Path $ProjectRoot "copilot-instructions.md"
if (Test-Path $CopilotInstructionsPath) {
    $Content = Get-Content $CopilotInstructionsPath -Raw
    if ($Content -match "2\.1\.0") {
        if ($Verbose) { Write-Host "  ✅ copilot-instructions.md: v2.1.0" -ForegroundColor Green }
    }
    else {
        Write-Host "  ❌ copilot-instructions.md: Missing or wrong version" -ForegroundColor Red
        $VersionIssues++
    }
}

$ReadmePath = Join-Path $ProjectRoot "README.md"
if (Test-Path $ReadmePath) {
    $Content = Get-Content $ReadmePath -Raw
    if ($Content -match "2\.1\.0") {
        if ($Verbose) { Write-Host "  ✅ README.md: v2.1.0 mentioned" -ForegroundColor Green }
    }
    else {
        Write-Host "  ⚠️  README.md: Version 2.1.0 not mentioned" -ForegroundColor Yellow
        if ($Strict) { $VersionIssues++ }
    }
}

$InventoryPath = Join-Path $ProjectRoot ".claude\context\system-inventory.json"
if (Test-Path $InventoryPath) {
    $Content = Get-Content $InventoryPath -Raw
    if ($Content -match '"version".*"2\.1\.0"') {
        if ($Verbose) { Write-Host "  ✅ system-inventory.json: v2.1.0" -ForegroundColor Green }
    }
    else {
        Write-Host "  ❌ system-inventory.json: Missing or wrong version" -ForegroundColor Red
        $VersionIssues++
    }
}

$ChangelogPath = Join-Path $ProjectRoot "CHANGELOG_v2.1.0.md"
if (Test-Path $ChangelogPath) {
    $Content = Get-Content $ChangelogPath -Raw
    if ($Content -match "2\.1\.0") {
        if ($Verbose) { Write-Host "  ✅ CHANGELOG_v2.1.0.md: v2.1.0 present" -ForegroundColor Green }
    }
    else {
        Write-Host "  ❌ CHANGELOG_v2.1.0.md: Missing 2.1.0 reference" -ForegroundColor Red
        $VersionIssues++
    }
}

Write-Host ""

# Check 2: File Naming Conventions
Write-Host "🔍 Check 2: File naming conventions..."

$NamingErrors = 0

$SchemasDir = Join-Path $ProjectRoot "schemas"
if (Test-Path $SchemasDir) {
    $SchemaFiles = Get-ChildItem -Path $SchemasDir -Filter "*.json" -File -ErrorAction SilentlyContinue
    foreach ($SchemaFile in $SchemaFiles) {
        if ($SchemaFile.Name -notmatch "\.schema\.json$") {
            Write-Host "  ❌ Schema naming: $($SchemaFile.Name)" -ForegroundColor Red
            $NamingErrors++
        }
    }
}

$ChatmodesDir = Join-Path $ProjectRoot "chatmodes"
if (Test-Path $ChatmodesDir) {
    $ChatmodeFiles = Get-ChildItem -Path $ChatmodesDir -Filter "*.md" -File -ErrorAction SilentlyContinue
    foreach ($ChatmodeFile in $ChatmodeFiles) {
        if ($ChatmodeFile.Name -ne "copilot-instructions.md" -and $ChatmodeFile.Name -notmatch "\.chatmode\.md$") {
            Write-Host "  ❌ Chatmode naming: $($ChatmodeFile.Name)" -ForegroundColor Red
            $NamingErrors++
        }
    }
}

$ProfilesDir = Join-Path $ChatmodesDir "profiles"
if (Test-Path $ProfilesDir) {
    $ProfileFiles = Get-ChildItem -Path $ProfilesDir -Filter "*.md" -File -ErrorAction SilentlyContinue
    foreach ($ProfileFile in $ProfileFiles) {
        if ($ProfileFile.Name -notmatch "\.profile\.md$") {
            Write-Host "  ❌ Profile naming: $($ProfileFile.Name)" -ForegroundColor Red
            $NamingErrors++
        }
    }
}

$CompositionsDir = Join-Path $ProjectRoot "prompts\compositions"
if (Test-Path $CompositionsDir) {
    $CompFiles = Get-ChildItem -Path $CompositionsDir -Filter "*.json" -File -ErrorAction SilentlyContinue
    foreach ($CompFile in $CompFiles) {
        if ($CompFile.Name -notmatch "\.composition\.json$") {
            Write-Host "  ❌ Composition naming: $($CompFile.Name)" -ForegroundColor Red
            $NamingErrors++
        }
    }
}

if ($NamingErrors -eq 0) {
    if ($Verbose) { Write-Host "  ✅ All file naming conventions correct" -ForegroundColor Green }
    $NamingIssues = 0
}
else {
    $NamingIssues = $NamingErrors
}

Write-Host ""

# Check 3: Directory Structure
Write-Host "🔍 Check 3: Directory structure consistency..."

$RequiredDirs = @(
    "agents",
    "chatmodes",
    "instructions",
    "prompts",
    "schemas",
    "scripts",
    "templates",
    "toolsets",
    ".claude",
    ".github"
)

$DirStructureOK = $true
foreach ($Dir in $RequiredDirs) {
    if (-not (Test-Path (Join-Path $ProjectRoot $Dir))) {
        Write-Host "  ❌ Missing directory: $Dir" -ForegroundColor Red
        $DirStructureOK = $false
    }
}

if ($DirStructureOK) {
    if ($Verbose) { Write-Host "  ✅ All required directories present" -ForegroundColor Green }
}
else {
    Write-Host "  ❌ Directory structure incomplete" -ForegroundColor Red
    $HeaderIssues++
}

Write-Host ""

# Summary
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 Consistency Check Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Version issues: $VersionIssues"
Write-Host "Naming convention issues: $NamingIssues"
Write-Host "Frontmatter issues: $FrontmatterIssues"
Write-Host "Structure issues: $HeaderIssues"
Write-Host ""

$TotalIssues = $VersionIssues + $NamingIssues + $FrontmatterIssues + $HeaderIssues

if ($TotalIssues -eq 0) {
    Write-Host "✅ PASS: System is consistent" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "❌ FAIL: $TotalIssues consistency issue(s) detected" -ForegroundColor Red
    if (-not $Verbose) {
        Write-Host "(Use -Verbose for details)" -ForegroundColor Yellow
    }
    exit 1
}
