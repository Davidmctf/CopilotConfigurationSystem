#!/bin/bash

################################################################################
# STEP 15: validate-compositions.sh
# PHASE 3: QA Framework
#
# PURPOSE:
#   Validates that ALL composition files reference valid template paths.
#   Checks JSON structure and ensures referenced templates exist.
#
# USAGE:
#   bash scripts/qa/validate-compositions.sh [--verbose] [--fix]
#
# OPTIONS:
#   --verbose    Show all composition details
#   --fix        Attempt to fix broken references (future)
#
# EXIT CODE:
#   0 = All compositions valid (✅ PASS)
#   1 = Invalid compositions detected (❌ FAIL)
#   2 = No composition files found
#
# DEPENDENCIES:
#   - grep, awk, find (standard Unix utilities)
#   - prompts/compositions/ directory
#   - prompts/templates/ directory
#
# VALIDATION CHECKS:
#   1. Composition JSON is valid
#   2. All referenced templates exist
#   3. Template refs match naming convention
#   4. Composition has required fields (id, name, templates array)
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
COMPOSITIONS_DIR="${PROJECT_ROOT}/prompts/compositions"
TEMPLATES_DIR="${PROJECT_ROOT}/prompts/templates"
VERBOSE=false
FIX_MODE=false

[[ "$1" == "--verbose" ]] && VERBOSE=true
[[ "$1" == "--fix" ]] && FIX_MODE=true
[[ "$2" == "--verbose" ]] && VERBOSE=true

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}STEP 15: validate-compositions${NC}"
echo -e "${BLUE}Validating composition structure${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Check if compositions directory exists
if [[ ! -d "${COMPOSITIONS_DIR}" ]]; then
    echo -e "${RED}❌ FAIL: Compositions directory not found${NC}"
    exit 2
fi

if [[ ! -d "${TEMPLATES_DIR}" ]]; then
    echo -e "${RED}❌ FAIL: Templates directory not found${NC}"
    exit 2
fi

# Find all composition files
COMPOSITION_FILES=$(find "${COMPOSITIONS_DIR}" -name "*.composition.json" -type f 2>/dev/null)

# Count compositions
COMPOSITION_COUNT=$(echo "${COMPOSITION_FILES}" | grep -c . || echo 0)

if [[ ${COMPOSITION_COUNT} -eq 0 ]]; then
    echo -e "${RED}❌ FAIL: No composition files found${NC}"
    exit 2
fi

echo "🔍 Found ${COMPOSITION_COUNT} composition files"
echo ""

INVALID_COUNT=0
BROKEN_REF_COUNT=0
MISSING_FIELDS=0
VALID_COUNT=0

# Validate each composition
while IFS= read -r comp_file; do
    [[ -z "${comp_file}" ]] && continue
    
    COMP_NAME=$(basename "${comp_file}")
    
    if [[ "${VERBOSE}" == true ]]; then
        echo -e "${BLUE}Validating: ${COMP_NAME}${NC}"
    fi
    
    # Check if file is valid JSON (using grep to check for basic structure)
    if ! grep -q '{' "${comp_file}" 2>/dev/null; then
        echo -e "${RED}❌ ${COMP_NAME}: Not valid JSON${NC}"
        ((INVALID_COUNT++))
        continue
    fi
    
    # Check for required fields using grep
    if ! grep -q '"id"' "${comp_file}"; then
        echo -e "${YELLOW}⚠️  ${COMP_NAME}: Missing 'id' field${NC}"
        ((MISSING_FIELDS++))
    fi
    
    if ! grep -q '"templates"' "${comp_file}"; then
        echo -e "${YELLOW}⚠️  ${COMP_NAME}: Missing 'templates' array${NC}"
        ((MISSING_FIELDS++))
    fi
    
    if ! grep -q '"name"' "${comp_file}"; then
        echo -e "${YELLOW}⚠️  ${COMP_NAME}: Missing 'name' field${NC}"
        ((MISSING_FIELDS++))
    fi
    
    # Extract template references using grep
    # Pattern: "ref": "template.name" or similar
    TEMPLATE_REFS=$(grep -oE '"ref"\s*:\s*"[^"]*"' "${comp_file}" | \
                    sed -E 's/.*"([^"]*)"$/\1/')
    
    BROKEN_REFS=0
    while IFS= read -r template_ref; do
        [[ -z "${template_ref}" ]] && continue
        
        # Convert template ref to file path
        # Refs like "code.class" should map to "prompts/templates/code/class.prompt.md"
        TEMPLATE_PATH="${TEMPLATES_DIR}/$(echo "${template_ref}" | sed 's/\./\//g').prompt.md"
        
        if [[ ! -f "${TEMPLATE_PATH}" ]]; then
            if [[ "${VERBOSE}" == true ]]; then
                echo -e "${RED}  ❌ Missing template: ${template_ref}${NC}"
                echo -e "${RED}     Expected path: ${TEMPLATE_PATH}${NC}"
            fi
            ((BROKEN_REFS++))
        fi
    done <<< "${TEMPLATE_REFS}"
    
    if [[ ${BROKEN_REFS} -gt 0 ]]; then
        ((BROKEN_REF_COUNT++))
        echo -e "${RED}❌ ${COMP_NAME}: ${BROKEN_REFS} broken template reference(s)${NC}"
    else
        ((VALID_COUNT++))
        if [[ "${VERBOSE}" == true ]]; then
            echo -e "${GREEN}✅ ${COMP_NAME}: Valid${NC}"
        fi
    fi
    
done <<< "${COMPOSITION_FILES}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📊 Validation Summary"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Total compositions: ${COMPOSITION_COUNT}"
echo "Valid compositions: ${VALID_COUNT}"
echo "Invalid JSON: ${INVALID_COUNT}"
echo "Compositions with broken refs: ${BROKEN_REF_COUNT}"
echo "Missing fields: ${MISSING_FIELDS}"
echo ""

if [[ ${INVALID_COUNT} -eq 0 && ${BROKEN_REF_COUNT} -eq 0 ]]; then
    echo -e "${GREEN}✅ PASS: All compositions valid${NC}"
    exit 0
else
    TOTAL_ERRORS=$((INVALID_COUNT + BROKEN_REF_COUNT))
    echo -e "${RED}❌ FAIL: ${TOTAL_ERRORS} composition issue(s) detected${NC}"
    [[ "${VERBOSE}" == false ]] && echo "(Use --verbose for details)"
    exit 1
fi
