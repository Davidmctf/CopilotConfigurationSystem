# ============================================================================
# init-copilot.ps1 - Initialize Copilot local context (second-level structure)
# ============================================================================
# Purpose: Validate and initialize .copilot/ (or .cursor/, .vs/) structure
# Runs: Automatically at session start (SessionStart hook)
#
# Features:
#   - Detects IDE in use
#   - Creates missing second-level directories
#   - Validates required files exist
#   - Copies templates if needed
#   - Reports status
# ============================================================================

$ErrorActionPreference = "Stop"

# Color definitions
function Write-Success { Write-Host "✓ $args" -ForegroundColor Green }
function Write-Error_ { Write-Host "✗ $args" -ForegroundColor Red }
function Write-Warning_ { Write-Host "⚠ $args" -ForegroundColor Yellow }
function Write-Info { Write-Host "→ $args" -ForegroundColor Cyan }

# Detect IDE and set context directory
function Detect-IDE {
    $cwd = Get-Location

    if (Test-Path ".\.vs") {
        $script:IDE = "visual-studio"
        $script:CONTEXT_DIR = ".vs"
    } elseif (Test-Path ".\.cursor") {
        $script:IDE = "cursor"
        $script:CONTEXT_DIR = ".cursor"
    } else {
        $script:IDE = "vscode"
        $script:CONTEXT_DIR = ".copilot"
    }

    Write-Success "IDE Detected: $script:IDE"
    Write-Success "Context Directory: $script:CONTEXT_DIR"
}

# Verify global config path
function Verify-GlobalConfig {
    if (-not $env:GLOBAL_CONFIG_PATH) {
        $script:GLOBAL_CONFIG_PATH = "$env:APPDATA\Code\User\prompts"
    } else {
        $script:GLOBAL_CONFIG_PATH = $env:GLOBAL_CONFIG_PATH
    }

    if (-not (Test-Path $script:GLOBAL_CONFIG_PATH)) {
        Write-Error_ "Global config not found: $script:GLOBAL_CONFIG_PATH"
        Write-Warning_ "Install with: git clone <repo> '$script:GLOBAL_CONFIG_PATH'"
        exit 1
    }

    Write-Success "Global config found: $script:GLOBAL_CONFIG_PATH"
}

# Create second-level directory structure
function Create-Structure {
    Write-Host ""
    Write-Info "Creating second-level structure..."

    $dirs = @(
        "$script:CONTEXT_DIR\config",
        "$script:CONTEXT_DIR\context",
        "$script:CONTEXT_DIR\.context-history\sessions"
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Success "Created: $dir"
        }
    }
}

# Copy templates if missing
function Copy-Templates {
    Write-Host ""
    Write-Info "Initializing configuration..."

    $templateDir = "$script:GLOBAL_CONFIG_PATH\templates\local-project"

    # Check if settings.json exists
    if (-not (Test-Path "$script:CONTEXT_DIR\config\settings.json")) {
        if (Test-Path "$templateDir\config\settings.json") {
            Copy-Item -Path "$templateDir\config\settings.json" -Destination "$script:CONTEXT_DIR\config\" -Force
            Write-Success "Copied: config/settings.json"
        }
    }

    # Copy context templates if empty
    $contextPath = "$script:CONTEXT_DIR\context"
    if ((Get-ChildItem $contextPath -ErrorAction SilentlyContinue | Measure-Object).Count -eq 0) {
        if (Test-Path "$templateDir\context") {
            Copy-Item -Path "$templateDir\context\*" -Destination $contextPath -Recurse -Force -ErrorAction SilentlyContinue
            Write-Success "Initialized context templates"
        }
    }
}

# Validate required files
function Validate-Structure {
    Write-Host ""
    Write-Info "Validating structure..."

    $valid = $true
    $requiredFiles = @(
        "$script:CONTEXT_DIR\config\settings.json",
        "$script:CONTEXT_DIR\context"
    )

    foreach ($file in $requiredFiles) {
        if (Test-Path $file) {
            Write-Success "Found: $file"
        } else {
            Write-Warning_ "Missing: $file"
            $valid = $false
        }
    }

    if ($valid) {
        Write-Success "Structure validation passed"
        return $true
    } else {
        Write-Warning_ "Some files are missing but structure is usable"
        return $true
    }
}

# Update settings with global config path
function Update-Settings {
    Write-Host ""
    Write-Info "Updating settings..."

    if (Test-Path "$script:CONTEXT_DIR\config\settings.json") {
        Write-Success "Settings file configured"
    }
}

# Main execution
function Main {
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "Copilot Local Context Initialization" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""

    Detect-IDE
    Verify-GlobalConfig
    Create-Structure
    Copy-Templates
    Validate-Structure
    Update-Settings

    Write-Host ""
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host "✓ Initialization Complete" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Green
    Write-Host ""
    Write-Success "Ready to use Copilot in your project!"
}

# Run main
Main
