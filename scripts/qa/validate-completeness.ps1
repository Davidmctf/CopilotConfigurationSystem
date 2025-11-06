<#
.SYNOPSIS
    Validate system completeness
.DESCRIPTION
    Validates that ALL files enumerated in system-inventory.json exist
    in the actual filesystem. Uses inventory as the "source of truth".
.PARAMETER Verbose
    Show detailed output with missing paths
.EXIT CODE
    0 = All files exist (✅ PASS)
    1 = Missing files detected (❌ FAIL)
#>

param([switch]$Verbose)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName
$InventoryFile = Join-Path $ProjectRoot ".claude\context\system-inventory.json"

Write-Host "================================" -ForegroundColor Cyan
Write-Host "STEP 14: validate-completeness" -ForegroundColor Cyan
Write-Host "Validating system completeness" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $InventoryFile)) {
    Write-Host "❌ FAIL: Inventory not found" -ForegroundColor Red
    exit 2
}

try {
    $InventoryJson = Get-Content $InventoryFile | ConvertFrom-Json
}
catch {
    Write-Host "❌ FAIL: Cannot parse inventory JSON" -ForegroundColor Red
    exit 2
}

# Extract paths from inventory
$AllPaths = @()

# Extract file paths with known extensions
$InventoryContent = Get-Content $InventoryFile -Raw
$Matches = [regex]::Matches($InventoryContent, '"(?:path|file)"\s*:\s*"([^"]+\.(md|json|jsonc|sh|yml|yaml))"')
foreach ($Match in $Matches) {
    $AllPaths += $Match.Groups[1].Value
}

# Remove duplicates
$AllPaths = $AllPaths | Sort-Object -Unique

$MissingCount = 0
$FoundCount = 0
$CheckedCount = $AllPaths.Count

Write-Host "🔍 Checking $CheckedCount inventory paths..."
Write-Host ""

foreach ($Path in $AllPaths) {
    if ([string]::IsNullOrEmpty($Path)) { continue }
    
    $FullPath = Join-Path $ProjectRoot $Path
    
    if (Test-Path $FullPath) {
        $FoundCount++
    }
    else {
        $MissingCount++
        if ($Verbose) {
            Write-Host "❌ Missing: $Path" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "📊 Validation Summary" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "Paths found in inventory: $CheckedCount"
Write-Host "Paths verified as existing: $FoundCount"
Write-Host "Paths missing: $MissingCount"
Write-Host ""

if ($MissingCount -eq 0) {
    Write-Host "✅ PASS: All inventory paths exist" -ForegroundColor Green
    exit 0
}
else {
    Write-Host "❌ FAIL: $MissingCount path(s) missing" -ForegroundColor Red
    if (-not $Verbose) {
        Write-Host "(Use -Verbose to see missing paths)" -ForegroundColor Yellow
    }
    exit 1
}
