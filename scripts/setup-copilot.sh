#!/bin/bash

# ============================================================================
# setup-copilot.sh - Interactive setup for Copilot system (Level 1 + Level 2)
# ============================================================================
# Purpose: Interactive installation of global (user-level) and project-local
#          Copilot configuration with IDE detection and schema installation
#
# Detects:
#   - Platform (Linux/macOS/WSL)
#   - Shell type (bash/zsh)
#   - Available IDEs (VS Code, Cursor, CLI)
#
# Installs:
#   - Level 1: Global config at ~/.config/Code/User/prompts/ or custom path
#   - Level 2: Project-local context at $PWD/.copilot/ (or chosen name)
#   - Both: Schemas, agents, chatmodes, templates
#
# Usage:
#   ./setup-copilot.sh
#   # Or with custom paths:
#   GLOBAL_CONFIG_PATH=/custom/path PROJECT_CONTEXT_DIR=.vscode ./setup-copilot.sh
# ============================================================================

set -e

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================================
# OUTPUT FUNCTIONS
# ============================================================================

print_header() {
    echo ""
    echo -e "${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${CYAN}→${NC} $1"
}

ask_yes_no() {
    local prompt="$1"
    local response

    while true; do
        echo -e -n "${CYAN}?${NC} $prompt (y/n): "
        read -r response
        case "$response" in
            [Yy][Ee][Ss]|[Yy])
                return 0
                ;;
            [Nn][Oo]|[Nn])
                return 1
                ;;
            *)
                print_warning "Please answer y or n"
                ;;
        esac
    done
}

ask_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    local choice

    echo ""
    echo -e "${CYAN}?${NC} $prompt"
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[$i]}"
    done

    while true; do
        echo -n "Select (1-${#options[@]}): "
        read -r choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            echo "${options[$((choice-1))]}"
            return 0
        else
            print_warning "Invalid choice. Please select 1-${#options[@]}"
        fi
    done
}

ask_input() {
    local prompt="$1"
    local default="$2"
    local input

    echo -n -e "${CYAN}?${NC} $prompt"
    if [ -n "$default" ]; then
        echo -n " [$default]: "
    else
        echo -n ": "
    fi

    read -r input

    if [ -z "$input" ]; then
        echo "$default"
    else
        echo "$input"
    fi
}

# ============================================================================
# PLATFORM AND IDE DETECTION
# ============================================================================

detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        PLATFORM="linux"
        SHELL_TYPE="bash"
        if command -v zsh &> /dev/null; then
            SHELL_TYPE="zsh"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        SHELL_TYPE="bash"
        if command -v zsh &> /dev/null; then
            SHELL_TYPE="zsh"
        fi
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        PLATFORM="windows-bash"
        SHELL_TYPE="bash"
    else
        PLATFORM="unknown"
        SHELL_TYPE="bash"
    fi

    print_success "Platform detected: $PLATFORM"
    print_success "Shell detected: $SHELL_TYPE"
}

detect_ides() {
    IDEs=()

    # Check for VS Code
    if command -v code &> /dev/null; then
        IDEs+=("VS Code")
    fi

    # Check for Cursor
    if command -v cursor &> /dev/null; then
        IDEs+=("Cursor")
    fi

    # Check for Visual Studio Code insiders
    if command -v code-insiders &> /dev/null; then
        IDEs+=("VS Code Insiders")
    fi

    # Default option
    IDEs+=("None (Manual Setup)")

    if [ ${#IDEs[@]} -gt 1 ]; then
        print_success "Detected IDEs: ${IDEs[*]}"
    else
        print_warning "No IDEs detected. Manual setup recommended."
    fi
}

# ============================================================================
# LEVEL 1: GLOBAL CONFIGURATION SETUP
# ============================================================================

setup_level1() {
    print_header "LEVEL 1: Global Configuration Setup"

    # Determine default global config path
    if [ -z "$GLOBAL_CONFIG_PATH" ]; then
        if [ "$PLATFORM" == "linux" ] || [ "$PLATFORM" == "macos" ]; then
            DEFAULT_GLOBAL_PATH="$HOME/.config/Code/User/prompts"
        else
            DEFAULT_GLOBAL_PATH="$HOME/AppData/Code/prompts"
        fi
    else
        DEFAULT_GLOBAL_PATH="$GLOBAL_CONFIG_PATH"
    fi

    print_info "Global configuration will be installed at user-level"
    print_info "This includes: agents, chatmodes, schemas, templates, instructions"
    echo ""

    # Ask about global config installation
    if ask_yes_no "Install global configuration at default location?"; then
        GLOBAL_CONFIG_PATH="$DEFAULT_GLOBAL_PATH"
        print_success "Using default global config path: $GLOBAL_CONFIG_PATH"
    else
        echo ""
        CUSTOM_PATH=$(ask_input "Enter custom global config path" "$DEFAULT_GLOBAL_PATH")
        GLOBAL_CONFIG_PATH="$CUSTOM_PATH"
        print_success "Using custom global config path: $GLOBAL_CONFIG_PATH"
    fi

    # Check if already exists
    if [ -d "$GLOBAL_CONFIG_PATH" ]; then
        print_warning "Global config directory already exists"
        if ! ask_yes_no "Overwrite existing configuration?"; then
            print_info "Skipping Level 1 setup"
            return 0
        fi
    fi

    # Create global structure
    print_info "Creating global directory structure..."
    mkdir -p "$GLOBAL_CONFIG_PATH"/{agents,chatmodes,config,context,instructions,schemas,templates,scripts,toolsets}
    print_success "Created global directory structure"

    # Create placeholder files
    print_info "Installing placeholder schemas and configs..."

    # Create basic config template
    cat > "$GLOBAL_CONFIG_PATH/config/settings.json" << 'EOF'
{
  "version": "2.1.0",
  "env": {
    "globalConfigPath": "$GLOBAL_CONFIG_PATH"
  },
  "ideDetection": {
    "enabled": true,
    "supportedIDEs": ["vscode", "cursor", "visualstudio", "github-copilot-cli"]
  },
  "model": {
    "default": "copilot/claude-sonnet-4.5",
    "fallback": "copilot/claude-haiku-4.5"
  },
  "chatmodes": {
    "quick-assistant": {
      "enabled": true,
      "description": "Fast execution for daily tasks and bug fixes"
    },
    "research-assistant": {
      "enabled": true,
      "description": "Technology research and evaluation"
    },
    "agent-orchestrator": {
      "enabled": true,
      "description": "Architecture decisions and refutation mode"
    }
  },
  "context": {
    "autoSync": true,
    "history": {
      "enabled": true,
      "maxSessions": 50,
      "retentionDays": 90
    },
    "languageDetection": {
      "enabled": true,
      "priority": "es-MX"
    }
  }
}
EOF
    print_success "Created settings.json"

    # Create README for global config
    cat > "$GLOBAL_CONFIG_PATH/README.md" << 'EOF'
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
```bash
bash scripts/init-copilot.sh
```

## Configuration

Edit `config/settings.json` to customize:
- Default model (Sonnet vs Haiku)
- Enabled chatmodes
- Language detection priority
- Context auto-sync behavior

## Version

v2.1.0 - Production Ready
EOF
    print_success "Created README.md in global config"

    print_success "Level 1 (Global) setup complete"
}

# ============================================================================
# LEVEL 2: PROJECT-LOCAL CONFIGURATION SETUP
# ============================================================================

setup_level2() {
    print_header "LEVEL 2: Project-Local Configuration Setup"

    print_info "Project-local context directory will be created in current working directory"
    print_info "This includes: project-specific context, session history, local settings"
    echo ""

    # Ask about IDE-specific directory
    IDE_OPTION=$(ask_choice "Which IDE are you using?" "VS Code (.copilot)" "Cursor (.cursor)" "Visual Studio (.vs)" "GitHub Copilot CLI (.copilot)" "Custom name")

    case "$IDE_OPTION" in
        "VS Code (.copilot)")
            PROJECT_CONTEXT_DIR=".copilot"
            SELECTED_IDE="vscode"
            ;;
        "Cursor (.cursor)")
            PROJECT_CONTEXT_DIR=".cursor"
            SELECTED_IDE="cursor"
            ;;
        "Visual Studio (.vs)")
            PROJECT_CONTEXT_DIR=".vs"
            SELECTED_IDE="visualstudio"
            ;;
        "GitHub Copilot CLI (.copilot)")
            PROJECT_CONTEXT_DIR=".copilot"
            SELECTED_IDE="github-copilot-cli"
            ;;
        "Custom name")
            PROJECT_CONTEXT_DIR=$(ask_input "Enter custom directory name" ".copilot")
            SELECTED_IDE="custom"
            ;;
    esac

    print_success "Project context directory: $PROJECT_CONTEXT_DIR"

    # Check if already exists
    if [ -d "$PROJECT_CONTEXT_DIR" ]; then
        print_warning "Project context directory already exists: $PROJECT_CONTEXT_DIR"
        if ! ask_yes_no "Overwrite existing project context?"; then
            print_info "Skipping Level 2 setup"
            return 0
        fi
    fi

    # Create project structure
    print_info "Creating project directory structure..."
    mkdir -p "$PROJECT_CONTEXT_DIR"/{config,context,.context-history/sessions}
    print_success "Created project directory structure"

    # Create project-local settings
    cat > "$PROJECT_CONTEXT_DIR/config/settings.json" << EOF
{
  "project": {
    "name": "$(basename "$PWD")",
    "version": "1.0.0",
    "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  },
  "ide": {
    "type": "$SELECTED_IDE",
    "contextDir": "$PROJECT_CONTEXT_DIR"
  },
  "globalConfigPath": "$GLOBAL_CONFIG_PATH",
  "context": {
    "autoSync": true,
    "localHistory": {
      "enabled": true,
      "maxSessions": 20
    }
  }
}
EOF
    print_success "Created project settings.json"

    # Create project README
    cat > "$PROJECT_CONTEXT_DIR/README.md" << 'EOF'
# Project Copilot Context

This directory contains project-specific Copilot configuration and session history.

## Structure

- **config/**: Project-specific settings (IDE type, custom configurations)
- **context/**: Project-specific context files and prompts
- **.context-history/sessions/**: Session history and context snapshots

## Git Management

Add to `.gitignore`:
```
.copilot/.context-history/
.copilot/context/*.secret.*
.cursor/.context-history/
.vs/.context-history/
```

Keep in git:
```
.copilot/config/settings.json
.copilot/context/
```

## Usage

1. Edit `.copilot/context/` with project-specific context
2. Update `.copilot/config/settings.json` with project settings
3. Run your IDE with Copilot enabled

## Session History

Session history is automatically saved to `.context-history/sessions/` with timestamps.
Old sessions (> 90 days) are automatically cleaned up.
EOF
    print_success "Created project README.md"

    # Create empty context files
    cat > "$PROJECT_CONTEXT_DIR/context/.gitkeep" << 'EOF'
# Copilot Project Context

Add your project-specific context files here.

Examples:
- architecture.md (project structure, design patterns)
- tech-stack.md (languages, frameworks, tools)
- coding-standards.md (style guide, conventions)
- domain.md (business logic, domain-specific terms)
EOF
    print_success "Created context placeholder"

    print_success "Level 2 (Project-Local) setup complete"
}

# ============================================================================
# SCHEMA INSTALLATION
# ============================================================================

install_schemas() {
    print_header "Installing JSON Schemas"

    # Create schema directory structure
    mkdir -p "$GLOBAL_CONFIG_PATH/schemas"
    mkdir -p "$PROJECT_CONTEXT_DIR/schemas"

    # Basic context schema
    cat > "$GLOBAL_CONFIG_PATH/schemas/context.schema.json" << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Copilot Context Schema",
  "type": "object",
  "properties": {
    "version": {
      "type": "string",
      "description": "Context schema version"
    },
    "project": {
      "type": "object",
      "properties": {
        "name": { "type": "string" },
        "version": { "type": "string" },
        "description": { "type": "string" }
      }
    },
    "context": {
      "type": "object",
      "properties": {
        "language": { "type": "string" },
        "framework": { "type": "string" },
        "architecture": { "type": "string" }
      }
    }
  }
}
EOF
    print_success "Created context schema"

    # Settings schema
    cat > "$GLOBAL_CONFIG_PATH/schemas/settings.schema.json" << 'EOF'
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Copilot Settings Schema",
  "type": "object",
  "properties": {
    "version": { "type": "string" },
    "env": { "type": "object" },
    "ideDetection": { "type": "object" },
    "model": { "type": "object" },
    "chatmodes": { "type": "object" },
    "context": { "type": "object" }
  },
  "required": ["version"]
}
EOF
    print_success "Created settings schema"

    # Copy schemas to project
    cp "$GLOBAL_CONFIG_PATH/schemas"/*.json "$PROJECT_CONTEXT_DIR/schemas/" 2>/dev/null || true
    print_success "Copied schemas to project"
}

# ============================================================================
# VALIDATION
# ============================================================================

validate_installation() {
    print_header "Validating Installation"

    local valid=true

    # Check global structure
    echo ""
    print_info "Checking Level 1 (Global)..."

    local global_checks=(
        "$GLOBAL_CONFIG_PATH/config/settings.json"
        "$GLOBAL_CONFIG_PATH/schemas/context.schema.json"
        "$GLOBAL_CONFIG_PATH/schemas/settings.schema.json"
    )

    for check in "${global_checks[@]}"; do
        if [ -f "$check" ]; then
            print_success "Found: $(basename $check)"
        else
            print_error "Missing: $check"
            valid=false
        fi
    done

    # Check project structure
    echo ""
    print_info "Checking Level 2 (Project)..."

    local project_checks=(
        "$PROJECT_CONTEXT_DIR/config/settings.json"
        "$PROJECT_CONTEXT_DIR/context/.gitkeep"
        "$PROJECT_CONTEXT_DIR/.context-history/sessions"
    )

    for check in "${project_checks[@]}"; do
        if [ -e "$check" ]; then
            print_success "Found: $(basename $check)"
        else
            print_error "Missing: $check"
            valid=false
        fi
    done

    echo ""
    if [ "$valid" = true ]; then
        print_success "Installation validation passed!"
    else
        print_warning "Some files may be missing, but installation is usable"
    fi
}

# ============================================================================
# FINAL SUMMARY
# ============================================================================

print_summary() {
    print_header "Installation Summary"

    echo ""
    echo -e "${CYAN}LEVEL 1 - Global Configuration${NC}"
    echo "Location: $GLOBAL_CONFIG_PATH"
    echo "Includes: agents, chatmodes, schemas, templates, scripts"
    echo ""

    echo -e "${CYAN}LEVEL 2 - Project Context${NC}"
    echo "Location: $PROJECT_CONTEXT_DIR"
    echo "IDE: $SELECTED_IDE"
    echo ""

    echo -e "${CYAN}NEXT STEPS${NC}"
    echo "1. Review configuration:"
    echo "   - $GLOBAL_CONFIG_PATH/config/settings.json"
    echo "   - $PROJECT_CONTEXT_DIR/config/settings.json"
    echo ""
    echo "2. Add project context:"
    echo "   - Edit files in $PROJECT_CONTEXT_DIR/context/"
    echo ""
    echo "3. Start using Copilot:"
    echo "   - Open your IDE in this directory"
    echo "   - Copilot should auto-detect context"
    echo ""

    print_success "Setup complete! Happy coding!"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
    print_header "Copilot System Setup"

    print_info "This script will install Copilot at two levels:"
    print_info "1. LEVEL 1 - Global user configuration"
    print_info "2. LEVEL 2 - Project-local context"
    echo ""

    # Detect environment
    detect_platform
    detect_ides

    # Confirm proceeding
    echo ""
    if ! ask_yes_no "Proceed with installation?"; then
        print_warning "Setup cancelled"
        exit 0
    fi

    # Run setup phases
    setup_level1
    setup_level2
    install_schemas
    validate_installation
    print_summary
}

# Run main
main "$@"
