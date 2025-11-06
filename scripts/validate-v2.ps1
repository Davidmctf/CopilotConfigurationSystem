# validate-v2.ps1
# Validation script for Architecture v2.0.0
# Version: 1.0.0
# Date: 2025-10-16

Write-Host "🔍 Validating v2.0.0 Architecture..." -ForegroundColor Cyan
Write-Host ""

$ERRORS = 0
$WARNINGS = 0

# Function to check JSON validity
function Test-JsonValidity {
    param([string]$FilePath)
    
    if (Test-Path $FilePath) {
        try {
            Get-Content $FilePath | ConvertFrom-Json | Out-Null
            Write-Host "✅ JSON valid: $FilePath" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Host "❌ JSON invalid: $FilePath" -ForegroundColor Red
            $script:ERRORS++
            return $false
        }
    }
    else {
        Write-Host "⚠️  File not found: $FilePath" -ForegroundColor Yellow
        $script:WARNINGS++
        return $false
    }
}

# Function to check version in file
function Test-Version {
    param([string]$FilePath, [string]$ExpectedVersion)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content -match "version.*$ExpectedVersion" -or $content -match "Version.*$ExpectedVersion") {
            Write-Host "✅ Version $ExpectedVersion found in: $FilePath" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "⚠️  Version $ExpectedVersion not found in: $FilePath" -ForegroundColor Yellow
            $script:WARNINGS++
            return $false
        }
    }
    else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
        $script:ERRORS++
        return $false
    }
}

# Function to check for required content
function Test-Content {
    param([string]$FilePath, [string]$SearchTerm, [string]$Description)
    
    if (Test-Path $FilePath) {
        $content = Get-Content $FilePath -Raw
        if ($content -match $SearchTerm) {
            Write-Host "✅ Found '$Description' in: $FilePath" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "⚠️  Missing '$Description' in: $FilePath" -ForegroundColor Yellow
            $script:WARNINGS++
            return $false
        }
    }
    else {
        Write-Host "❌ File not found: $FilePath" -ForegroundColor Red
        $script:ERRORS++
        return $false
    }
}

# Phase 1: Checking JSON Files
Write-Host "📁 Phase 1: Checking JSON Files..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Test-JsonValidity "agents/baseAgent/config.json"
Test-JsonValidity "agents/orchestratorAgent/config.json"
Write-Host ""

# Phase 2: Checking Versions
Write-Host "📝 Phase 2: Checking Versions..." -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Test-Version "agents/baseAgent/config.json" "2.0.0"
Test-Version "agents/orchestratorAgent/config.json" "2.0.0"
Test-Version "agents/baseAgent/AGENTS.md" "2.0.0"
Test-Version "agents/orchestratorAgent/AGENTS.md" "2.0.0"
Test-Version "chatmodes/profiles/collaborative.profile.md" "2.0.0"
Test-Version "chatmodes/profiles/focused.profile.md" "2.0.0"
Test-Version "instructions/capabilities/orchestration.instructions.md" "2.0.0"
Test-Version "chatmodes/quick-assistant.chatmode.md" "2.0.0"
Test-Version "chatmodes/research-assistant.chatmode.md" "2.0.0"
Test-Version "chatmodes/agent-orchestrator.chatmode.md" "2.0.0"
Test-Version "instructions/core/communication.instructions.md" "2.0.0"
Write-Host ""

# Phase 3: Checking v2.0 Features
Write-Host "🔎 Phase 3: Checking v2.0 Features..." -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Test-Content "chatmodes/profiles/collaborative.profile.md" "refutation" "Refutation capability"
Test-Content "chatmodes/profiles/collaborative.profile.md" "assumption" "Assumption challenging"
Test-Content "chatmodes/profiles/focused.profile.md" "validation" "Quick validation"
Test-Content "instructions/capabilities/orchestration.instructions.md" "chatmode" "Chatmode integration"
Test-Content "agents/baseAgent/AGENTS.md" "agent_executor" "Agent executor mode"
Test-Content "agents/baseAgent/AGENTS.md" "JSON" "JSON output"
Write-Host ""

# Phase 4: Checking Communication Modes
Write-Host "📋 Phase 4: Checking Communication Modes..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Test-Content "agents/baseAgent/config.json" "agent_executor" "Agent executor in baseAgent"
Test-Content "agents/orchestratorAgent/config.json" "agent_executor" "Agent executor in orchestratorAgent"
Test-Content "chatmodes/agent-orchestrator.chatmode.md" "human_interactive" "Human interactive in chatmode"
Write-Host ""

# Phase 5: Checking Documentation
Write-Host "📚 Phase 5: Checking Documentation..." -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
if (Test-Path "CHANGELOG_v2.0.0.md") {
    Write-Host "✅ CHANGELOG_v2.0.0.md exists" -ForegroundColor Green
}
else {
    Write-Host "⚠️  CHANGELOG_v2.0.0.md not found" -ForegroundColor Yellow
    $WARNINGS++
}

if (Test-Path "USAGE_GUIDE_v2.0.md") {
    Write-Host "✅ USAGE_GUIDE_v2.0.md exists" -ForegroundColor Green
}
else {
    Write-Host "⚠️  USAGE_GUIDE_v2.0.md not found" -ForegroundColor Yellow
    $WARNINGS++
}
Write-Host ""

# Phase 6: Checking Backup
Write-Host "🔄 Phase 6: Checking Backup..." -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan
if (Test-Path "backups") {
    $BackupCount = @(Get-ChildItem "backups" -Directory -Filter "backup-*" -ErrorAction SilentlyContinue).Count
    if ($BackupCount -gt 0) {
        Write-Host "✅ Found $BackupCount backup(s)" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  No backups found in backups/ directory" -ForegroundColor Yellow
        $WARNINGS++
    }
}
else {
    Write-Host "⚠️  backups/ directory not found" -ForegroundColor Yellow
    $WARNINGS++
}
Write-Host ""

# Validation Summary
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "📊 Validation Summary" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════" -ForegroundColor Cyan
Write-Host "Errors:   $ERRORS" -ForegroundColor Red
Write-Host "Warnings: $WARNINGS" -ForegroundColor Yellow
Write-Host ""

if ($ERRORS -eq 0 -and $WARNINGS -eq 0) {
    Write-Host "✅ All checks passed! Architecture v2.0.0 is valid." -ForegroundColor Green
    exit 0
}
elseif ($ERRORS -eq 0) {
    Write-Host "⚠️  Validation completed with warnings. Review above." -ForegroundColor Yellow
    exit 0
}
else {
    Write-Host "❌ Validation failed with $ERRORS error(s). Fix errors above." -ForegroundColor Red
    exit 1
}
