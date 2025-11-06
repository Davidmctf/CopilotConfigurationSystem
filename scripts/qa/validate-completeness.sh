#!/bin/bash

################################################################################
# STEP 14: validate-completeness.sh
# PHASE 3: QA Framework
#
# PURPOSE:
#   Validates that ALL files enumerated in system-inventory.json exist
#   in the actual filesystem. Uses inventory as the "source of truth".
#
# USAGE:
#   bash scripts/qa/validate-completeness.sh [--verbose]
#
# EXIT CODE:
#   0 = All files exist (✅ PASS)
#   1 = Missing files detected (❌ FAIL)
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
INVENTORY_FILE="${PROJECT_ROOT}/.claude/context/system-inventory.json"
VERBOSE=false

[[ "$1" == "--verbose" ]] && VERBOSE=true

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}STEP 14: validate-completeness${NC}"
echo -e "${BLUE}Validating system completeness${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

if [[ ! -f "${INVENTORY_FILE}" ]]; then
    echo -e "${RED}❌ FAIL: Inventory not found${NC}"
    exit 2
fi

# Extract paths that look like file paths (contain "/" or end with common extensions)
INVENTORY_PATHS=$(grep -oE 'path"\s*:\s*"[^"]+/(\.?[^/"]+)"' "${INVENTORY_FILE}" | \
                  sed -E 's/.*"([^"]+)"$/\1/' | \
                  sort -u)

# Also extract file paths that have known extensions
FILE_PATHS=$(grep -oE 'file"\s*:\s*"[^"]*\.(md|json|jsonc|sh|yml|yaml)"' "${INVENTORY_FILE}" | \
             sed -E 's/.*"([^"]+)"$/\1/' | \
             sort -u)

# Combine and deduplicate
ALL_PATHS=$(printf "%s\n%s\n" "${INVENTORY_PATHS}" "${FILE_PATHS}" | sort -u | grep -v '^$')

MISSING_COUNT=0
FOUND_COUNT=0
CHECKED_COUNT=0

mapfile -t PATH_ARRAY <<< "${ALL_PATHS}"

echo "🔍 Checking ${#PATH_ARRAY[@]} inventory paths..."
echo ""

for path in "${PATH_ARRAY[@]}"; do
    [[ -z "$path" ]] && continue
    ((CHECKED_COUNT++))
    
    FULL_PATH="${PROJECT_ROOT}/${path}"
    
    if [[ -e "${FULL_PATH}" ]]; then
        ((FOUND_COUNT++))
    else
        ((MISSING_COUNT++))
        if [[ "${VERBOSE}" == true ]]; then
            echo -e "${RED}❌ Missing: ${path}${NC}"
        fi
    fi
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📊 Validation Summary"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Paths found in inventory: ${CHECKED_COUNT}"
echo "Paths verified as existing: ${FOUND_COUNT}"
echo "Paths missing: ${MISSING_COUNT}"
echo ""

if [[ ${MISSING_COUNT} -eq 0 ]]; then
    echo -e "${GREEN}✅ PASS: All inventory paths exist${NC}"
    exit 0
else
    echo -e "${RED}❌ FAIL: ${MISSING_COUNT} path(s) missing${NC}"
    [[ "${VERBOSE}" == false ]] && echo "(Use --verbose to see missing paths)"
    exit 1
fi
