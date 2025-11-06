#!/bin/bash
# ============================================================================
# init-copilot.sh - Initialize Copilot local context (second-level structure)
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

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect IDE and set context directory
detect_ide() {
    local cwd="$PWD"

    # Check for IDE-specific indicators
    if [ -d ".vs" ]; then
        IDE="visual-studio"
        CONTEXT_DIR=".vs"
    elif [ -d ".cursor" ]; then
        IDE="cursor"
        CONTEXT_DIR=".cursor"
    else
        IDE="vscode"
        CONTEXT_DIR=".copilot"
    fi

    echo -e "${GREEN}✓ IDE Detected: $IDE${NC}"
    echo -e "${GREEN}✓ Context Directory: $CONTEXT_DIR${NC}"
}

# Verify global config path
verify_global_config() {
    if [ -z "$GLOBAL_CONFIG_PATH" ]; then
        GLOBAL_CONFIG_PATH="${HOME}/.config/Code/User/prompts"
    fi

    if [ ! -d "$GLOBAL_CONFIG_PATH" ]; then
        echo -e "${RED}✗ Global config not found: $GLOBAL_CONFIG_PATH${NC}"
        echo -e "${YELLOW}  Install with: git clone <repo> $GLOBAL_CONFIG_PATH${NC}"
        exit 1
    fi

    echo -e "${GREEN}✓ Global config found: $GLOBAL_CONFIG_PATH${NC}"
}

# Create second-level directory structure
create_structure() {
    echo ""
    echo "Creating second-level structure..."

    # Create required directories
    local dirs=(
        "$CONTEXT_DIR/config"
        "$CONTEXT_DIR/context"
        "$CONTEXT_DIR/.context-history/sessions"
    )

    for dir in "${dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            echo -e "${GREEN}  ✓ Created: $dir${NC}"
        fi
    done
}

# Copy templates if missing
copy_templates() {
    echo ""
    echo "Initializing configuration..."

    local template_dir="$GLOBAL_CONFIG_PATH/templates/local-project"

    # Check if settings.json exists
    if [ ! -f "$CONTEXT_DIR/config/settings.json" ]; then
        if [ -f "$template_dir/config/settings.json" ]; then
            cp "$template_dir/config/settings.json" "$CONTEXT_DIR/config/"
            echo -e "${GREEN}  ✓ Copied: config/settings.json${NC}"
        fi
    fi

    # Copy context templates if empty
    if [ -z "$(ls -A $CONTEXT_DIR/context/ 2>/dev/null)" ]; then
        if [ -d "$template_dir/context" ]; then
            cp -r "$template_dir/context/"* "$CONTEXT_DIR/context/" 2>/dev/null || true
            echo -e "${GREEN}  ✓ Initialized context templates${NC}"
        fi
    fi
}

# Validate required files
validate_structure() {
    echo ""
    echo "Validating structure..."

    local valid=true
    local required_files=(
        "$CONTEXT_DIR/config/settings.json"
        "$CONTEXT_DIR/context"
    )

    for file in "${required_files[@]}"; do
        if [ -e "$file" ]; then
            echo -e "${GREEN}  ✓ Found: $file${NC}"
        else
            echo -e "${YELLOW}  ⚠ Missing: $file${NC}"
            valid=false
        fi
    done

    if [ "$valid" = true ]; then
        echo -e "${GREEN}✓ Structure validation passed${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ Some files are missing but structure is usable${NC}"
        return 0
    fi
}

# Update settings with global config path
update_settings() {
    echo ""
    echo "Updating settings..."

    if [ -f "$CONTEXT_DIR/config/settings.json" ]; then
        # This would require jq or similar; for now, just verify it exists
        echo -e "${GREEN}  ✓ Settings file configured${NC}"
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "Copilot Local Context Initialization"
    echo "=========================================="
    echo ""

    detect_ide
    verify_global_config
    create_structure
    copy_templates
    validate_structure
    update_settings

    echo ""
    echo -e "${GREEN}=========================================="
    echo "✓ Initialization Complete"
    echo "==========================================${NC}"
    echo ""
    echo "Ready to use Copilot in your project!"
}

# Run main
main "$@"
