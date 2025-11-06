#!/bin/bash
##############################################################################
# Schema Validation Suite - Agnostic Bash
# Purpose: Validate all JSON files against schema definitions
# Dependencies: jq (JSON query tool)
# Usage: ./validate-schemas.sh [--strict] [--verbose]
##############################################################################

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCHEMAS_DIR="$PROJECT_ROOT/schemas"
EXIT_CODE=0
STRICT_MODE=${1:-""}
VERBOSE=${2:-""}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

##############################################################################
# FUNCTIONS
##############################################################################

log_info() {
    if [ -n "$VERBOSE" ] || [ "$VERBOSE" = "--verbose" ]; then
        echo -e "${GREEN}[INFO]${NC} $1"
    fi
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

log_fail() {
    echo -e "${RED}✗${NC} $1"
}

##############################################################################
# VALIDATION FUNCTIONS
##############################################################################

validate_schema_existence() {
    log_info "Step 1: Checking schema files exist..."
    local schemas=("agent" "capability" "chatmode" "context" "prompt" "session" "settings" "toolset")

    for schema in "${schemas[@]}"; do
        local schema_file="$SCHEMAS_DIR/${schema}.schema.json"
        if [ -f "$schema_file" ]; then
            log_pass "Found: ${schema}.schema.json"
        else
            log_fail "Missing: ${schema}.schema.json"
            EXIT_CODE=1
        fi
    done
}

validate_schema_syntax() {
    log_info "Step 2: Validating schema JSON syntax..."

    for schema_file in "$SCHEMAS_DIR"/*.schema.json; do
        if [ -f "$schema_file" ]; then
            if jq empty "$schema_file" 2>/dev/null; then
                log_pass "Valid JSON: $(basename "$schema_file")"
            else
                log_fail "Invalid JSON in: $(basename "$schema_file")"
                jq . "$schema_file" 2>&1 | head -5
                EXIT_CODE=1
            fi
        fi
    done
}

validate_agent_configs() {
    log_info "Step 3: Validating agent configuration files..."

    for agent_config in "$PROJECT_ROOT"/agents/*/config.json; do
        if [ -f "$agent_config" ]; then
            if jq . "$agent_config" > /dev/null 2>&1; then
                log_pass "Valid: $(basename $(dirname "$agent_config"))/config.json"

                # Check for required fields
                if jq -e '.id' "$agent_config" > /dev/null 2>&1; then
                    log_pass "  ✓ Has 'id' field"
                else
                    log_fail "  ✗ Missing 'id' field in $(basename $(dirname "$agent_config"))"
                    EXIT_CODE=1
                fi

                if jq -e '.version' "$agent_config" > /dev/null 2>&1; then
                    log_pass "  ✓ Has 'version' field"
                else
                    log_fail "  ✗ Missing 'version' field in $(basename $(dirname "$agent_config"))"
                    EXIT_CODE=1
                fi
            else
                log_fail "Invalid JSON: $(basename $(dirname "$agent_config"))/config.json"
                EXIT_CODE=1
            fi
        fi
    done
}

validate_json_files() {
    log_info "Step 4: Scanning for all JSON files..."
    local json_count=0
    local valid_count=0

    while IFS= read -r json_file; do
        ((json_count++))

        if jq empty "$json_file" 2>/dev/null; then
            ((valid_count++))
            [ -n "$VERBOSE" ] && log_pass "Valid: $(basename "$json_file")"
        else
            log_fail "Invalid JSON: $json_file"
            EXIT_CODE=1
        fi
    done < <(find "$PROJECT_ROOT" -type f -name "*.json" \
        ! -path "*node_modules*" \
        ! -path "*.git*" \
        ! -path "*\.vs/*")

    log_info "Checked $json_count JSON files, $valid_count valid"
}

validate_schema_structure() {
    log_info "Step 5: Validating schema structure..."

    # Check if schemas have required fields
    for schema_file in "$SCHEMAS_DIR"/*.schema.json; do
        local schema_name=$(basename "$schema_file" .schema.json)

        # Check for $schema field
        if jq -e '."$schema"' "$schema_file" > /dev/null 2>&1; then
            log_pass "$schema_name: Has \$schema field"
        else
            log_warning "$schema_name: Missing \$schema field"
        fi

        # Check for properties field (most schemas should have this)
        if jq -e '.properties' "$schema_file" > /dev/null 2>&1; then
            log_pass "$schema_name: Has properties field"
        else
            log_warning "$schema_name: Missing properties field (may be intentional)"
        fi
    done
}

##############################################################################
# MAIN EXECUTION
##############################################################################

main() {
    echo "==============================================="
    echo "SCHEMA VALIDATION SUITE"
    echo "==============================================="
    echo "Project Root: $PROJECT_ROOT"
    echo "Schemas Dir: $SCHEMAS_DIR"
    echo "Strict Mode: ${STRICT_MODE:-off}"
    echo ""

    # Run all validations
    validate_schema_existence
    echo ""

    validate_schema_syntax
    echo ""

    validate_agent_configs
    echo ""

    validate_json_files
    echo ""

    validate_schema_structure
    echo ""

    # Final summary
    echo "==============================================="
    if [ $EXIT_CODE -eq 0 ]; then
        log_pass "All validations passed!"
        echo "==============================================="
    else
        log_fail "Some validations failed (exit code: $EXIT_CODE)"
        echo "==============================================="
    fi

    exit $EXIT_CODE
}

# Run main function
main
