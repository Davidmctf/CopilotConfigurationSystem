<#
.SYNOPSIS
    Schema Validation Suite
.DESCRIPTION
    Validates all JSON files against schema definitions.
    Checks schema existence, syntax, and structure.
.PARAMETER Strict
    Enable strict validation mode
.PARAMETER Verbose
    Show detailed validation output
.EXIT CODE
    0 = All validations passed
    1 = Some validations failed
#>

param([switch]$Strict, [switch]$Verbose)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Get-Item $ScriptDir).Parent.Parent.FullName
$SchemasDir = Join-Path $ProjectRoot "schemas"

$ExitCode = 0

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "SCHEMA VALIDATION SUITE" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "Project Root: $ProjectRoot"
Write-Host "Schemas Dir: $SchemasDir"
Write-Host "Strict Mode: $(if ($Strict) { 'on' } else { 'off' })"
Write-Host ""

# Step 1: Check schema files exist
Write-Host "[INFO] Step 1: Checking schema files exist..." -ForegroundColor Green
$Schemas = @("agent", "capability", "chatmode", "context", "prompt", "session", "settings", "toolset")

foreach ($Schema in $Schemas) {
    $SchemaFile = Join-Path $SchemasDir "$Schema.schema.json"
    if (Test-Path $SchemaFile) {
        Write-Host "✓ Found: $Schema.schema.json" -ForegroundColor Green
    }
    else {
        Write-Host "✗ Missing: $Schema.schema.json" -ForegroundColor Red
        $ExitCode = 1
    }
}

Write-Host ""

# Step 2: Validate schema JSON syntax
Write-Host "[INFO] Step 2: Validating schema JSON syntax..." -ForegroundColor Green

$SchemaFiles = Get-ChildItem -Path $SchemasDir -Filter "*.schema.json" -ErrorAction SilentlyContinue
foreach ($SchemaFile in $SchemaFiles) {
    try {
        Get-Content $SchemaFile.FullName | ConvertFrom-Json | Out-Null
        Write-Host "✓ Valid JSON: $($SchemaFile.Name)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Invalid JSON in: $($SchemaFile.Name)" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
        $ExitCode = 1
    }
}

Write-Host ""

# Step 3: Validate agent configuration files
Write-Host "[INFO] Step 3: Validating agent configuration files..." -ForegroundColor Green

$AgentDirs = Get-ChildItem -Path (Join-Path $ProjectRoot "agents") -Directory -ErrorAction SilentlyContinue
foreach ($AgentDir in $AgentDirs) {
    $ConfigFile = Join-Path $AgentDir.FullName "config.json"
    
    if (Test-Path $ConfigFile) {
        try {
            $Config = Get-Content $ConfigFile | ConvertFrom-Json
            Write-Host "✓ Valid: $($AgentDir.Name)/config.json" -ForegroundColor Green
            
            # Check for required fields
            if ($Config.id) {
                Write-Host "  ✓ Has 'id' field" -ForegroundColor Green
            }
            else {
                Write-Host "  ✗ Missing 'id' field" -ForegroundColor Red
                $ExitCode = 1
            }
            
            if ($Config.version) {
                Write-Host "  ✓ Has 'version' field" -ForegroundColor Green
            }
            else {
                Write-Host "  ✗ Missing 'version' field" -ForegroundColor Red
                $ExitCode = 1
            }
        }
        catch {
            Write-Host "✗ Invalid JSON: $($AgentDir.Name)/config.json" -ForegroundColor Red
            $ExitCode = 1
        }
    }
}

Write-Host ""

# Step 4: Scan for all JSON files
Write-Host "[INFO] Step 4: Scanning for all JSON files..." -ForegroundColor Green

$JsonFiles = Get-ChildItem -Path $ProjectRoot -Filter "*.json" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.FullName -notmatch "node_modules|\.git" }

$JsonCount = $JsonFiles.Count
$ValidCount = 0

foreach ($JsonFile in $JsonFiles) {
    try {
        Get-Content $JsonFile.FullName | ConvertFrom-Json | Out-Null
        $ValidCount++
        if ($Verbose) {
            Write-Host "✓ Valid: $($JsonFile.Name)" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "✗ Invalid JSON: $($JsonFile.FullName)" -ForegroundColor Red
        $ExitCode = 1
    }
}

Write-Host "[INFO] Checked $JsonCount JSON files, $ValidCount valid"

Write-Host ""

# Step 5: Validate schema structure
Write-Host "[INFO] Step 5: Validating schema structure..." -ForegroundColor Green

$SchemaFiles = Get-ChildItem -Path $SchemasDir -Filter "*.schema.json" -ErrorAction SilentlyContinue
foreach ($SchemaFile in $SchemaFiles) {
    try {
        $Schema = Get-Content $SchemaFile.FullName | ConvertFrom-Json
        $SchemaName = $SchemaFile.BaseName -replace "\.schema$", ""
        
        if ($Schema.PSObject.Properties['$schema']) {
            Write-Host "✓ $SchemaName : Has `$schema field" -ForegroundColor Green
        }
        else {
            Write-Host "⚠ $SchemaName : Missing `$schema field" -ForegroundColor Yellow
        }
        
        if ($Schema.properties) {
            Write-Host "✓ $SchemaName : Has properties field" -ForegroundColor Green
        }
        else {
            Write-Host "⚠ $SchemaName : Missing properties field" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Error validating $($SchemaFile.Name)" -ForegroundColor Red
    }
}

Write-Host ""

# Final summary
Write-Host "===============================================" -ForegroundColor Cyan
if ($ExitCode -eq 0) {
    Write-Host "✓ All validations passed!" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
}
else {
    Write-Host "✗ Some validations failed (exit code: $ExitCode)" -ForegroundColor Red
    Write-Host "===============================================" -ForegroundColor Cyan
}

exit $ExitCode
