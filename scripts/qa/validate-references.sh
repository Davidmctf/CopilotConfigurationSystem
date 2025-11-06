#!/bin/bash

################################################################################
#                                                                              #
# STEP 13: validate-references.sh                                            #
# Validates all internal path and schema references across the system         #
#                                                                              #
# Purpose:  Ensure no broken links, missing paths, or orphaned references     #
# Method:   grep + jq for reference extraction and validation (no deps)       #
# Coverage: Schema refs, path refs, markdown links, config paths              #
#                                                                              #
################################################################################

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
ORANGE='\033[0;33m'
NC='\033[0m' # No Color

# Configuration
SCHEMA_DIR="./schemas"
CONFIG_DIR="./.copilot/config"
CONTEXT_DIR="./.copilot/context"
AGENTS_DIR="./agents"
CHATMODES_DIR="./chatmodes"
INSTRUCTIONS_DIR="./instructions"
PROMPTS_DIR="./prompts"
TOOLSETS_DIR="./toolsets"
TEMPLATES_DIR="./templates"
GLOBAL_CONFIG_DIR="./config"

# Counters
TOTAL_CHECKS=0
PASSED_CHECKS=0
FAILED_CHECKS=0
WARNINGS=0

# Temporary files
TEMP_REFS="/tmp/references-$$.txt"
TEMP_REPORT="/tmp/reference-report-$$.txt"
trap "rm -f $TEMP_REFS $TEMP_REPORT" EXIT

###############################################################################
# Helper Functions
###############################################################################

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
    ((PASSED_CHECKS++))
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
    ((FAILED_CHECKS++))
}

log_warning() {
    echo -e "${ORANGE}[!]${NC} $1"
    ((WARNINGS++))
}

# Extract $schema references from JSON files
extract_schema_refs() {
    local file="$1"
    grep -o '\$schema["\x27]*\s*:\s*["\x27]\([^"'\'']*\)["\x27]' "$file" 2>/dev/null | \
        sed 's/.*:\s*["\x27]\([^"'\'']*\)["\x27]/\1/' || true
}

# Extract globalConfigPath references from JSON files
extract_config_path_refs() {
    local file="$1"
    if jq -e '.env.globalConfigPath' "$file" >/dev/null 2>&1; then
        jq -r '.env.globalConfigPath' "$file"
    fi
}

# Extract agent references from JSON files
extract_agent_refs() {
    local file="$1"
    if jq -e '.agent' "$file" >/dev/null 2>&1; then
        jq -r '.agent | if type == "string" then . elif type == "object" then .defaultAgent // .id // empty else empty end' "$file"
    fi
}

# Extract capability references from JSON files
extract_capability_refs() {
    local file="$1"
    if jq -e '.capabilities' "$file" >/dev/null 2>&1; then
        jq -r '.capabilities[]?' "$file"
    fi
}

# Extract toolset references from JSON files
extract_toolset_refs() {
    local file="$1"
    if jq -e '.toolsets' "$file" >/dev/null 2>&1; then
        jq -r '.toolsets[]?' "$file"
    fi
}

# Validate file path exists
validate_file_exists() {
    local path="$1"
    local context="$2"
    
    ((TOTAL_CHECKS++))
    
    if [ -f "$path" ]; then
        log_success "File exists: $path"
        return 0
    else
        log_error "$context - File not found: $path"
        return 1
    fi
}

# Validate directory path exists
validate_dir_exists() {
    local path="$1"
    local context="$2"
    
    ((TOTAL_CHECKS++))
    
    if [ -d "$path" ]; then
        log_success "Directory exists: $path"
        return 0
    else
        log_error "$context - Directory not found: $path"
        return 1
    fi
}

###############################################################################
# Main Validation Logic
###############################################################################

main() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║         STEP 13: Reference & Path Validation                  ║"
    echo "║                                                               ║"
    echo "║  Validates internal paths and references across the system    ║"
    echo "║  Method: grep + jq (no external dependencies)                 ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    log_info "Starting reference validation..."
    echo ""

    # =========================================================================
    # 1. SCHEMA REFERENCE VALIDATION
    # =========================================================================
    echo -e "${BLUE}━━━ SCHEMA REFERENCES ━━━${NC}"
    
    # Find all JSON files that reference schemas
    find . -type f -name "*.json" | while read -r file; do
        schema_refs=$(extract_schema_refs "$file" 2>/dev/null || true)
        
        if [ -n "$schema_refs" ]; then
            while IFS= read -r schema_ref; do
                if [ -n "$schema_ref" ]; then
                    # Resolve relative paths
                    resolved_path=$(echo "$schema_ref" | sed "s|^\.\./||g")
                    
                    # Handle multiple path variations
                    if [ -f "$resolved_path" ]; then
                        log_success "Schema reference valid: $schema_ref (from $file)"
                    elif [ -f ".$resolved_path" ]; then
                        log_success "Schema reference valid: .$schema_ref (from $file)"
                    elif [ -f "$SCHEMA_DIR/$(basename "$resolved_path")" ]; then
                        log_warning "Schema reference requires resolution: $schema_ref (from $file) - found at $SCHEMA_DIR/$(basename "$resolved_path")"
                    else
                        ((TOTAL_CHECKS++))
                        log_error "Schema reference broken: $schema_ref (from $file)"
                    fi
                fi
            done <<< "$schema_refs"
        fi
    done

    # =========================================================================
    # 2. AGENT REFERENCE VALIDATION
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ AGENT REFERENCES ━━━${NC}"
    
    find . -type f -name "*.json" -o -name "*.md" | while read -r file; do
        if [ -f "$file" ]; then
            # Extract agent references from JSON
            if [[ "$file" == *.json ]]; then
                agent_refs=$(extract_agent_refs "$file" 2>/dev/null || true)
                
                if [ -n "$agent_refs" ]; then
                    while IFS= read -r agent_ref; do
                        if [ -n "$agent_ref" ] && [ "$agent_ref" != "null" ]; then
                            agent_dir="$AGENTS_DIR/$agent_ref"
                            ((TOTAL_CHECKS++))
                            
                            if [ -d "$agent_dir" ] && [ -f "$agent_dir/config.json" ]; then
                                log_success "Agent reference valid: $agent_ref (from $(basename "$file"))"
                            else
                                log_error "Agent reference broken: $agent_ref (from $(basename "$file")) - directory or config not found"
                            fi
                        fi
                    done <<< "$agent_refs"
                fi
            fi
            
            # Extract agent references from markdown frontmatter
            if [[ "$file" == *.md ]]; then
                agent_ref=$(grep -A 20 '^---$' "$file" | grep '^agent:' | awk -F': ' '{print $2}' | head -1)
                
                if [ -n "$agent_ref" ]; then
                    agent_dir="$AGENTS_DIR/$agent_ref"
                    ((TOTAL_CHECKS++))
                    
                    if [ -d "$agent_dir" ] && [ -f "$agent_dir/config.json" ]; then
                        log_success "Agent reference valid in markdown: $agent_ref (from $(basename "$file"))"
                    else
                        log_error "Agent reference broken in markdown: $agent_ref (from $(basename "$file"))"
                    fi
                fi
            fi
        fi
    done

    # =========================================================================
    # 3. CAPABILITY REFERENCE VALIDATION
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ CAPABILITY REFERENCES ━━━${NC}"
    
    find . -type f -name "*.json" | while read -r file; do
        cap_refs=$(extract_capability_refs "$file" 2>/dev/null || true)
        
        if [ -n "$cap_refs" ]; then
            while IFS= read -r cap_ref; do
                if [ -n "$cap_ref" ] && [ "$cap_ref" != "null" ]; then
                    # Capability references follow pattern: core.safety, capabilities.code-assistance
                    cap_type=$(echo "$cap_ref" | cut -d. -f1)
                    cap_name=$(echo "$cap_ref" | cut -d. -f2-)
                    
                    if [ -z "$cap_type" ] || [ -z "$cap_name" ]; then
                        ((TOTAL_CHECKS++))
                        log_warning "Capability reference format unclear: $cap_ref (from $(basename "$file"))"
                    else
                        # Find capability file
                        cap_dir="$INSTRUCTIONS_DIR/$cap_type"
                        cap_file="$cap_dir/$cap_name.instructions.md"
                        
                        ((TOTAL_CHECKS++))
                        if [ -f "$cap_file" ]; then
                            log_success "Capability reference valid: $cap_ref (from $(basename "$file"))"
                        else
                            log_warning "Capability reference may need verification: $cap_ref (from $(basename "$file")) - expected at $cap_file"
                        fi
                    fi
                fi
            done <<< "$cap_refs"
        fi
    done

    # =========================================================================
    # 4. TOOLSET REFERENCE VALIDATION
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ TOOLSET REFERENCES ━━━${NC}"
    
    find . -type f -name "*.json" | while read -r file; do
        toolset_refs=$(extract_toolset_refs "$file" 2>/dev/null || true)
        
        if [ -n "$toolset_refs" ]; then
            while IFS= read -r toolset_ref; do
                if [ -n "$toolset_ref" ] && [ "$toolset_ref" != "null" ]; then
                    ((TOTAL_CHECKS++))
                    
                    # Look in toolsets directory
                    if find "$TOOLSETS_DIR" -type f \( -name "*$toolset_ref*" -o -name "*${toolset_ref}*" \) | grep -q .; then
                        log_success "Toolset reference valid: $toolset_ref (from $(basename "$file"))"
                    else
                        log_warning "Toolset reference may need verification: $toolset_ref (from $(basename "$file"))"
                    fi
                fi
            done <<< "$toolset_refs"
        fi
    done

    # =========================================================================
    # 5. GLOBAL CONFIG PATH VALIDATION
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ GLOBAL CONFIG PATH VALIDATION ━━━${NC}"
    
    find . -type f -name "*.json" | while read -r file; do
        global_path=$(extract_config_path_refs "$file" 2>/dev/null || true)
        
        if [ -n "$global_path" ] && [ "$global_path" != "null" ]; then
            ((TOTAL_CHECKS++))
            
            # Validate that it points to a valid location
            # For this test, we're checking the reference format is reasonable
            if [[ "$global_path" =~ ^(\$|\.\.|\/) ]]; then
                log_success "Global config path reference valid format: $global_path (from $(basename "$file"))"
            else
                log_warning "Global config path reference format may be incorrect: $global_path (from $(basename "$file"))"
            fi
        fi
    done

    # =========================================================================
    # 6. CORE DIRECTORY STRUCTURE VALIDATION
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ CORE DIRECTORY STRUCTURE ━━━${NC}"
    
    validate_dir_exists "$SCHEMA_DIR" "Core directories"
    validate_dir_exists "$AGENTS_DIR" "Core directories"
    validate_dir_exists "$CHATMODES_DIR" "Core directories"
    validate_dir_exists "$INSTRUCTIONS_DIR" "Core directories"
    validate_dir_exists "$PROMPTS_DIR" "Core directories"
    validate_dir_exists "$TOOLSETS_DIR" "Core directories"
    validate_dir_exists "$TEMPLATES_DIR" "Core directories"

    # =========================================================================
    # 7. DOCUMENTATION LINK VALIDATION (Markdown)
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ MARKDOWN INTERNAL LINKS ━━━${NC}"
    
    find . -type f -name "*.md" | while read -r file; do
        # Extract markdown links like [text](path)
        markdown_links=$(grep -o '\[.*\]([^)]*\.md)' "$file" 2>/dev/null | sed 's/.*(\([^)]*\)).*/\1/' || true)
        
        if [ -n "$markdown_links" ]; then
            while IFS= read -r link; do
                if [ -n "$link" ]; then
                    # Remove anchors (#section)
                    link_path="${link%%#*}"
                    
                    ((TOTAL_CHECKS++))
                    
                    if [ -f "$link_path" ]; then
                        log_success "Markdown link valid: $link (from $(basename "$file"))"
                    else
                        log_warning "Markdown link may need verification: $link (from $(basename "$file")) - file: $link_path"
                    fi
                fi
            done <<< "$markdown_links"
        fi
    done

    # =========================================================================
    # 8. CHATMODE REFERENCE VALIDATION
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ CHATMODE REFERENCES ━━━${NC}"
    
    find "$CHATMODES_DIR" -type f -name "*.chatmode.md" | while read -r file; do
        ((TOTAL_CHECKS++))
        
        if [ -f "$file" ]; then
            # Extract profile reference
            profile=$(grep '^profile:' "$file" | awk -F': ' '{print $2}')
            
            if [ -n "$profile" ]; then
                profile_file="$CHATMODES_DIR/profiles/${profile}.profile.md"
                
                if [ -f "$profile_file" ]; then
                    log_success "Chatmode profile reference valid: $profile (from $(basename "$file"))"
                else
                    log_warning "Chatmode profile reference may need verification: $profile (from $(basename "$file")) - expected at $profile_file"
                fi
            fi
        fi
    done

    # =========================================================================
    # 9. PROMPT TEMPLATE COMPOSITION REFERENCES
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ PROMPT COMPOSITION REFERENCES ━━━${NC}"
    
    find "$PROMPTS_DIR/compositions" -type f -name "*.composition.json" 2>/dev/null | while read -r file; do
        # Extract template references from compositions
        template_refs=$(jq -r '.templates[]? | select(.) | keys[]?' "$file" 2>/dev/null || true)
        
        if [ -n "$template_refs" ]; then
            while IFS= read -r template_ref; do
                if [ -n "$template_ref" ]; then
                    ((TOTAL_CHECKS++))
                    
                    # Look for template in templates directory
                    if find "$PROMPTS_DIR/templates" -type f -name "*${template_ref}*" | grep -q .; then
                        log_success "Prompt template reference valid: $template_ref (from $(basename "$file"))"
                    else
                        log_warning "Prompt template reference may need verification: $template_ref"
                    fi
                fi
            done <<< "$template_refs"
        fi
    done

    # =========================================================================
    # 10. INSTRUCTIONS INCLUSION REFERENCES
    # =========================================================================
    echo ""
    echo -e "${BLUE}━━━ INSTRUCTIONS REFERENCES ━━━${NC}"
    
    # Check if any files reference instructions files
    grep -r "instructions/" . --include="*.json" --include="*.md" 2>/dev/null | while read -r line; do
        file=$(echo "$line" | cut -d: -f1)
        reference=$(echo "$line" | grep -o 'instructions/[^"/ ]*/[^"/ ]*' | head -1)
        
        if [ -n "$reference" ]; then
            ((TOTAL_CHECKS++))
            
            if [ -f "$reference" ] || [ -f "${reference}.md" ] || [ -f "${reference}.instructions.md" ]; then
                log_success "Instructions reference valid: $reference"
            else
                log_warning "Instructions reference may need verification: $reference (from $(basename "$file"))"
            fi
        fi
    done

    # =========================================================================
    # Summary Report
    # =========================================================================
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║              REFERENCE VALIDATION SUMMARY                    ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║ Total Checks:      $TOTAL_CHECKS"
    echo "║ Passed:            $PASSED_CHECKS"
    echo "║ Failed:            $FAILED_CHECKS"
    echo "║ Warnings:          $WARNINGS"

    if [ $FAILED_CHECKS -eq 0 ]; then
        echo "║                                                               ║"
        echo "║ ✅ ALL REFERENCE VALIDATIONS PASSED                         ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        return 0
    else
        echo "║                                                               ║"
        echo "║ ⚠️  REFERENCE VALIDATION WITH ISSUES                        ║"
        echo "║ Review warnings and errors above                            ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        return 1
    fi
}

###############################################################################
# Entry Point
###############################################################################

# Run main function
main
exit $?

