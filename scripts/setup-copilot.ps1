# ============================================================================
# setup-copilot.ps1 - Interactive setup for Copilot system (Level 1 + Level 2)
# ============================================================================
# Purpose: Interactive installation of global (user-level) and project-local
#          Copilot configuration with IDE detection and schema installation
#
# Detects:
#   - Platform (Windows version, PowerShell version)
#   - Available IDEs (VS Code, Visual Studio, Cursor)
#
# Installs:
#   - Level 1: Global config at $env:USERPROFILE/AppData/Code/prompts/ or custom path
#   - Level 2: Project-local context at $pwd/.copilot/ (or chosen name)
#   - Both: Schemas, agents, chatmodes, templates
#
# Usage:
#   .\setup-copilot.ps1
#   # Or with custom paths:
#   $env:GLOBAL_CONFIG_PATH = 'C:\custom\path'
#   .\setup-copilot.ps1
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

$Colors = @{
    Success = "Green"
    Error   = "Red"
    Warning = "Yellow"
    Info    = "Cyan"
    Header  = "Blue"
}

# ============================================================================
# OUTPUT FUNCTIONS
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "============================================" -ForegroundColor $Colors.Header
    Write-Host $Message -ForegroundColor $Colors.Header
    Write-Host "============================================" -ForegroundColor $Colors.Header
    Write-Host ""
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor $Colors.Success
}

function Write-Error_ {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor $Colors.Error
}

function Write-Warning_ {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor $Colors.Warning
}

function Write-Info {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor $Colors.Info
}

function Ask-YesNo {
    param([string]$Prompt)

    while ($true) {
        $response = Read-Host -Prompt "? $Prompt (y/n)"
        switch ($response.ToLower()) {
            { $_ -in @("y", "yes") } { return $true }
            { $_ -in @("n", "no") } { return $false }
            default { Write-Warning_ "Please answer y or n" }
        }
    }
}

function Ask-Choice {
    param(
        [string]$Prompt,
        [string[]]$Options
    )

    Write-Host ""
    Write-Host "? $Prompt"
    for ($i = 0; $i -lt $Options.Count; $i++) {
        Write-Host "  $($i+1))) $($Options[$i])"
    }

    while ($true) {
        $choice = Read-Host "Select (1-$($Options.Count))"

        if ($choice -match '^\d+$' -and [int]$choice -ge 1 -and [int]$choice -le $Options.Count) {
            return $Options[[int]$choice - 1]
        }
        else {
            Write-Warning_ "Invalid choice. Please select 1-$($Options.Count)"
        }
    }
}

function Ask-Input {
    param(
        [string]$Prompt,
        [string]$Default = ""
    )

    $inputPrompt = "? $Prompt"
    if ($Default) {
        $inputPrompt += " [$Default]"
    }
    $inputPrompt += ": "

    $input = Read-Host -Prompt $inputPrompt
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    }
    return $input
}

# ============================================================================
# PLATFORM AND IDE DETECTION
# ============================================================================

function Detect-Platform {
    $script:WindowsVersion = [System.Environment]::OSVersion.Version.Major
    $script:PSVersion = $PSVersionTable.PSVersion.Major

    Write-Success "Platform detected: Windows $script:WindowsVersion"
    Write-Success "PowerShell version: $script:PSVersion"
}

function Detect-IDEs {
    $script:IDEs = @()

    # Check for VS Code
    $vscodePath = "$env:ProgramFiles\Microsoft VS Code\Code.exe"
    if (Test-Path $vscodePath) {
        $script:IDEs += "VS Code"
    }

    # Check for Visual Studio 2022
    $vsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\Community"
    if (Test-Path $vsPath) {
        $script:IDEs += "Visual Studio 2022"
    }

    # Check for Cursor
    $cursorPath = "$env:ProgramFiles\Cursor\Cursor.exe"
    if (Test-Path $cursorPath) {
        $script:IDEs += "Cursor"
    }

    # Default option
    $script:IDEs += "None (Manual Setup)"

    if ($script:IDEs.Count -gt 1) {
        Write-Success "Detected IDEs: $($script:IDEs -join ', ')"
    }
    else {
        Write-Warning_ "No IDEs detected. Manual setup recommended."
    }
}

# ============================================================================
# LEVEL 1: GLOBAL CONFIGURATION SETUP
# ============================================================================

function Setup-Level1 {
    Write-Header "LEVEL 1: Global Configuration Setup"

    # Determine default global config path
    if ([string]::IsNullOrWhiteSpace($env:GLOBAL_CONFIG_PATH)) {
        $defaultGlobalPath = "$env:USERPROFILE\AppData\Roaming\Code\User\prompts"
    }
    else {
        $defaultGlobalPath = $env:GLOBAL_CONFIG_PATH
    }

    Write-Info "Global configuration will be installed at user-level"
    Write-Info "This includes: agents, chatmodes, schemas, templates, scripts"
    Write-Host ""

    # Ask about global config installation
    if (Ask-YesNo "Install global configuration at default location?") {
        $script:GlobalConfigPath = $defaultGlobalPath
        Write-Success "Using default global config path: $script:GlobalConfigPath"
    }
    else {
        Write-Host ""
        $customPath = Ask-Input "Enter custom global config path" $defaultGlobalPath
        $script:GlobalConfigPath = $customPath
        Write-Success "Using custom global config path: $script:GlobalConfigPath"
    }

    # Check if already exists
    if (Test-Path $script:GlobalConfigPath) {
        Write-Warning_ "Global config directory already exists"
        if (-not (Ask-YesNo "Overwrite existing configuration?")) {
            Write-Info "Skipping Level 1 setup"
            return
        }
    }

    # Create global structure
    Write-Info "Creating global directory structure..."
    $dirs = @(
        "$script:GlobalConfigPath\agents",
        "$script:GlobalConfigPath\chatmodes",
        "$script:GlobalConfigPath\config",
        "$script:GlobalConfigPath\context",
        "$script:GlobalConfigPath\instructions",
        "$script:GlobalConfigPath\schemas",
        "$script:GlobalConfigPath\templates",
        "$script:GlobalConfigPath\scripts",
        "$script:GlobalConfigPath\toolsets"
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    Write-Success "Created global directory structure"

    # Create basic config template
    Write-Info "Installing placeholder schemas and configs..."

    $settingsJson = @{
        version = "2.1.0"
        env = @{
            globalConfigPath = $script:GlobalConfigPath
        }
        ideDetection = @{
            enabled = $true
            supportedIDEs = @("vscode", "visualstudio", "cursor", "github-copilot-cli")
        }
        model = @{
            default = "copilot/claude-sonnet-4.5"
            fallback = "copilot/claude-haiku-4.5"
        }
        chatmodes = @{
            "quick-assistant" = @{
                enabled = $true
                description = "Fast execution for daily tasks and bug fixes"
            }
            "research-assistant" = @{
                enabled = $true
                description = "Technology research and evaluation"
            }
            "agent-orchestrator" = @{
                enabled = $true
                description = "Architecture decisions and refutation mode"
            }
        }
        context = @{
            autoSync = $true
            history = @{
                enabled = $true
                maxSessions = 50
                retentionDays = 90
            }
            languageDetection = @{
                enabled = $true
                priority = "es-MX"
            }
        }
    } | ConvertTo-Json -Depth 10

    Set-Content -Path "$script:GlobalConfigPath\config\settings.json" -Value $settingsJson -Encoding UTF8
    Write-Success "Created settings.json"

    # Create README for global config
    $readmeContent = @"
# Copilot Global Configuration

This directory contains your global Copilot configuration shared across all projects.

## Structure

- **agents/**: Available AI agents and their configurations
- **chatmodes/**: Predefined chatmode profiles (quick-assistant, research-assistant, agent-orchestrator)
- **config/**: Global settings and configuration files
- **context/**: Global context and project templates
- **instructions/**: System instructions and guidelines
- **schemas/**: JSON schemas for validation
- **templates/**: Project templates for different IDEs
- **scripts/**: Setup and utility scripts
- **toolsets/**: Tool configurations and integrations

## First Time Setup

Run the local project initialization script:
```powershell
.\scripts\init-copilot.ps1
```

## Configuration

Edit ``config\settings.json`` to customize:
- Default model (Sonnet vs Haiku)
- Enabled chatmodes
- Language detection priority
- Context auto-sync behavior

## Version

v2.1.0 - Production Ready
"@

    Set-Content -Path "$script:GlobalConfigPath\README.md" -Value $readmeContent -Encoding UTF8
    Write-Success "Created README.md in global config"

    Write-Success "Level 1 (Global) setup complete"
}

# ============================================================================
# LEVEL 2: PROJECT-LOCAL CONFIGURATION SETUP
# ============================================================================

function Setup-Level2 {
    Write-Header "LEVEL 2: Project-Local Configuration Setup"

    Write-Info "Project-local context directory will be created in current working directory"
    Write-Info "This includes: project-specific context, session history, local settings"
    Write-Host ""

    # Ask about IDE-specific directory
    $ideOption = Ask-Choice "Which IDE are you using?" @(
        "VS Code (.copilot)",
        "Visual Studio (.vs)",
        "Cursor (.cursor)",
        "GitHub Copilot CLI (.copilot)",
        "Custom name"
    )

    switch ($ideOption) {
        "VS Code (.copilot)" {
            $script:ProjectContextDir = ".copilot"
            $script:SelectedIDE = "vscode"
        }
        "Visual Studio (.vs)" {
            $script:ProjectContextDir = ".vs"
            $script:SelectedIDE = "visualstudio"
        }
        "Cursor (.cursor)" {
            $script:ProjectContextDir = ".cursor"
            $script:SelectedIDE = "cursor"
        }
        "GitHub Copilot CLI (.copilot)" {
            $script:ProjectContextDir = ".copilot"
            $script:SelectedIDE = "github-copilot-cli"
        }
        "Custom name" {
            $script:ProjectContextDir = Ask-Input "Enter custom directory name" ".copilot"
            $script:SelectedIDE = "custom"
        }
    }

    Write-Success "Project context directory: $script:ProjectContextDir"

    # Check if already exists
    if (Test-Path $script:ProjectContextDir) {
        Write-Warning_ "Project context directory already exists: $script:ProjectContextDir"
        if (-not (Ask-YesNo "Overwrite existing project context?")) {
            Write-Info "Skipping Level 2 setup"
            return
        }
    }

    # Create project structure
    Write-Info "Creating project directory structure..."
    $dirs = @(
        "$script:ProjectContextDir\config",
        "$script:ProjectContextDir\context",
        "$script:ProjectContextDir\.context-history\sessions"
    )

    foreach ($dir in $dirs) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }
    Write-Success "Created project directory structure"

    # Create project-local settings
    $projectName = Split-Path -Leaf -Path (Get-Location).Path
    $timestamp = Get-Date -Format "O"

    $projectSettingsJson = @{
        project = @{
            name = $projectName
            version = "1.0.0"
            created = $timestamp
        }
        ide = @{
            type = $script:SelectedIDE
            contextDir = $script:ProjectContextDir
        }
        globalConfigPath = $script:GlobalConfigPath
        context = @{
            autoSync = $true
            localHistory = @{
                enabled = $true
                maxSessions = 20
            }
        }
    } | ConvertTo-Json -Depth 10

    Set-Content -Path "$script:ProjectContextDir\config\settings.json" -Value $projectSettingsJson -Encoding UTF8
    Write-Success "Created project settings.json"

    # Create project README
    $projectReadmeContent = @"
# Project Copilot Context

This directory contains project-specific Copilot configuration and session history.

## Structure

- **config/**: Project-specific settings (IDE type, custom configurations)
- **context/**: Project-specific context files and prompts
- **.context-history/sessions/**: Session history and context snapshots

## Git Management

Add to ``.gitignore``:
```
.copilot\.context-history\
.copilot\context\*.secret.*
.cursor\.context-history\
.vs\.context-history\
```

Keep in git:
```
.copilot\config\settings.json
.copilot\context\
```

## Usage

1. Edit ``.copilot\context\`` with project-specific context
2. Update ``.copilot\config\settings.json`` with project settings
3. Run your IDE with Copilot enabled

## Session History

Session history is automatically saved to ``.context-history\sessions\`` with timestamps.
Old sessions (> 90 days) are automatically cleaned up.
"@

    Set-Content -Path "$script:ProjectContextDir\README.md" -Value $projectReadmeContent -Encoding UTF8
    Write-Success "Created project README.md"

    # Create empty context files
    $contextContent = @"
# Copilot Project Context

Add your project-specific context files here.

Examples:
- architecture.md (project structure, design patterns)
- tech-stack.md (languages, frameworks, tools)
- coding-standards.md (style guide, conventions)
- domain.md (business logic, domain-specific terms)
"@

    Set-Content -Path "$script:ProjectContextDir\context\.gitkeep" -Value $contextContent -Encoding UTF8
    Write-Success "Created context placeholder"

    Write-Success "Level 2 (Project-Local) setup complete"
}

# ============================================================================
# SCHEMA INSTALLATION
# ============================================================================

function Install-Schemas {
    Write-Header "Installing JSON Schemas"

    # Create schema directory structure
    if (-not (Test-Path "$script:GlobalConfigPath\schemas")) {
        New-Item -ItemType Directory -Path "$script:GlobalConfigPath\schemas" -Force | Out-Null
    }
    if (-not (Test-Path "$script:ProjectContextDir\schemas")) {
        New-Item -ItemType Directory -Path "$script:ProjectContextDir\schemas" -Force | Out-Null
    }

    # Basic context schema
    $contextSchemaJson = @{
        '$schema' = "http://json-schema.org/draft-07/schema#"
        title = "Copilot Context Schema"
        type = "object"
        properties = @{
            version = @{
                type = "string"
                description = "Context schema version"
            }
            project = @{
                type = "object"
                properties = @{
                    name = @{ type = "string" }
                    version = @{ type = "string" }
                    description = @{ type = "string" }
                }
            }
            context = @{
                type = "object"
                properties = @{
                    language = @{ type = "string" }
                    framework = @{ type = "string" }
                    architecture = @{ type = "string" }
                }
            }
        }
    } | ConvertTo-Json -Depth 10

    Set-Content -Path "$script:GlobalConfigPath\schemas\context.schema.json" -Value $contextSchemaJson -Encoding UTF8
    Write-Success "Created context schema"

    # Settings schema
    $settingsSchemaJson = @{
        '$schema' = "http://json-schema.org/draft-07/schema#"
        title = "Copilot Settings Schema"
        type = "object"
        properties = @{
            version = @{ type = "string" }
            env = @{ type = "object" }
            ideDetection = @{ type = "object" }
            model = @{ type = "object" }
            chatmodes = @{ type = "object" }
            context = @{ type = "object" }
        }
        required = @("version")
    } | ConvertTo-Json -Depth 10

    Set-Content -Path "$script:GlobalConfigPath\schemas\settings.schema.json" -Value $settingsSchemaJson -Encoding UTF8
    Write-Success "Created settings schema"

    # Copy schemas to project
    Copy-Item -Path "$script:GlobalConfigPath\schemas\*" -Destination "$script:ProjectContextDir\schemas\" -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Success "Copied schemas to project"
}

# ============================================================================
# VALIDATION
# ============================================================================

function Validate-Installation {
    Write-Header "Validating Installation"

    $valid = $true

    # Check global structure
    Write-Host ""
    Write-Info "Checking Level 1 (Global)..."

    $globalChecks = @(
        "$script:GlobalConfigPath\config\settings.json",
        "$script:GlobalConfigPath\schemas\context.schema.json",
        "$script:GlobalConfigPath\schemas\settings.schema.json"
    )

    foreach ($check in $globalChecks) {
        if (Test-Path $check) {
            Write-Success "Found: $(Split-Path -Leaf -Path $check)"
        }
        else {
            Write-Error_ "Missing: $check"
            $valid = $false
        }
    }

    # Check project structure
    Write-Host ""
    Write-Info "Checking Level 2 (Project)..."

    $projectChecks = @(
        "$script:ProjectContextDir\config\settings.json",
        "$script:ProjectContextDir\context\.gitkeep",
        "$script:ProjectContextDir\.context-history\sessions"
    )

    foreach ($check in $projectChecks) {
        if (Test-Path $check) {
            Write-Success "Found: $(Split-Path -Leaf -Path $check)"
        }
        else {
            Write-Error_ "Missing: $check"
            $valid = $false
        }
    }

    Write-Host ""
    if ($valid) {
        Write-Success "Installation validation passed!"
    }
    else {
        Write-Warning_ "Some files may be missing, but installation is usable"
    }
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================

function Print-Summary {
    Write-Header "Installation Summary"

    Write-Host ""
    Write-Host "LEVEL 1 - Global Configuration" -ForegroundColor $Colors.Info
    Write-Host "Location: $script:GlobalConfigPath"
    Write-Host "Includes: agents, chatmodes, schemas, templates, scripts"
    Write-Host ""

    Write-Host "LEVEL 2 - Project Context" -ForegroundColor $Colors.Info
    Write-Host "Location: $script:ProjectContextDir"
    Write-Host "IDE: $script:SelectedIDE"
    Write-Host ""

    Write-Host "NEXT STEPS" -ForegroundColor $Colors.Info
    Write-Host "1. Review configuration:"
    Write-Host "   - $script:GlobalConfigPath\config\settings.json"
    Write-Host "   - $script:ProjectContextDir\config\settings.json"
    Write-Host ""
    Write-Host "2. Add project context:"
    Write-Host "   - Edit files in $script:ProjectContextDir\context\"
    Write-Host ""
    Write-Host "3. Start using Copilot:"
    Write-Host "   - Open your IDE in this directory"
    Write-Host "   - Copilot should auto-detect context"
    Write-Host ""

    Write-Success "Setup complete! Happy coding!"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Main {
    Write-Header "Copilot System Setup"

    Write-Info "This script will install Copilot at two levels:"
    Write-Info "1. LEVEL 1 - Global user configuration"
    Write-Info "2. LEVEL 2 - Project-local context"
    Write-Host ""

    # Detect environment
    Detect-Platform
    Detect-IDEs

    # Confirm proceeding
    Write-Host ""
    if (-not (Ask-YesNo "Proceed with installation?")) {
        Write-Warning_ "Setup cancelled"
        exit 0
    }

    # Run setup phases
    Setup-Level1
    Setup-Level2
    Install-Schemas
    Validate-Installation
    Print-Summary
}

# Run main
Main
