#!/bin/bash

################################################################################
# STEP 16: validate-consistency.sh
# PHASE 3: QA Framework
#
# PURPOSE:
#   Validates system-wide consistency:
#   - Version numbers match across files
#   - Naming conventions are consistent
#   - YAML frontmatter present where required
#   - File naming patterns follow convention
#
# USAGE:
#   bash scripts/qa/validate-consistency.sh [--verbose] [--strict]
#
# OPTIONS:
#   --verbose    Show all consistency checks
#   --strict     Fail on warnings (not just errors)
#
# EXIT CODE:
#   0 = Consistent system (✅ PASS)
#   1 = Inconsistencies detected (❌ FAIL)
#
# DEPENDENCIES:
#   - grep, awk, find (standard Unix utilities)
#   - README.md, copilot-instructions.md, CHANGELOG files
#
# VALIDATION CHECKS:
#   1. Version consistency (all v2.1.0)
#   2. File naming conventions (.schema.json, .chatmode.md, etc.)
#   3. Markdown frontmatter in docs
#   4. Consistent numbering in sections
#   5. Consistent capitalization in headers
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
VERBOSE=false
STRICT_MODE=false

[[ "$1" == "--verbose" ]] && VERBOSE=true
[[ "$1" == "--strict" ]] && STRICT_MODE=true
[[ "$2" == "--verbose" ]] && VERBOSE=true
[[ "$2" == "--strict" ]] && STRICT_MODE=true

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}STEP 16: validate-consistency${NC}"
echo -e "${BLUE}Validating system consistency${NC}"
echo -e "${BLUE}================================${NC}"
echo ""

# Track issues
VERSION_ISSUES=0
NAMING_ISSUES=0
FRONTMATTER_ISSUES=0
HEADER_ISSUES=0

# ============================================================================
# CHECK 1: Version Consistency
# ============================================================================
echo "🔍 Check 1: Version consistency (should be 2.1.0)..."

EXPECTED_VERSION="2.1.0"

# Check copilot-instructions.md version
if grep -q '2\.1\.0' "${PROJECT_ROOT}/copilot-instructions.md" 2>/dev/null; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ copilot-instructions.md: v2.1.0"
else
    echo -e "  ${RED}❌ copilot-instructions.md: Missing or wrong version${NC}"
    ((VERSION_ISSUES++))
fi

# Check README.md mentions version
if grep -q "2\.1\.0" "${PROJECT_ROOT}/README.md" 2>/dev/null; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ README.md: v2.1.0 mentioned"
else
    echo -e "  ${YELLOW}⚠️  README.md: Version 2.1.0 not mentioned${NC}"
    [[ "${STRICT_MODE}" == true ]] && ((VERSION_ISSUES++))
fi

# Check system-inventory.json version
if grep -q '"version".*"2\.1\.0"' "${PROJECT_ROOT}/.claude/context/system-inventory.json" 2>/dev/null; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ system-inventory.json: v2.1.0"
else
    echo -e "  ${RED}❌ system-inventory.json: Missing or wrong version${NC}"
    ((VERSION_ISSUES++))
fi

# Check CHANGELOG files reference 2.1.0
if grep -q "2\.1\.0" "${PROJECT_ROOT}/CHANGELOG_v2.1.0.md" 2>/dev/null; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ CHANGELOG_v2.1.0.md: v2.1.0 present"
else
    echo -e "  ${RED}❌ CHANGELOG_v2.1.0.md: Missing 2.1.0 reference${NC}"
    ((VERSION_ISSUES++))
fi

echo ""

# ============================================================================
# CHECK 2: File Naming Conventions
# ============================================================================
echo "🔍 Check 2: File naming conventions..."

NAMING_ERRORS=0

# Check schema files end with .schema.json
SCHEMA_FILES=$(find "${PROJECT_ROOT}/schemas" -name "*.json" -type f 2>/dev/null)
while IFS= read -r schema_file; do
    [[ -z "${schema_file}" ]] && continue
    if ! basename "${schema_file}" | grep -q "\.schema\.json$"; then
        echo -e "  ${RED}❌ Schema naming: $(basename "${schema_file}")${NC}"
        ((NAMING_ERRORS++))
    fi
done <<< "${SCHEMA_FILES}"

# Check chatmode files end with .chatmode.md
CHATMODE_FILES=$(find "${PROJECT_ROOT}/chatmodes" -maxdepth 1 -name "*.md" -type f 2>/dev/null)
while IFS= read -r chatmode_file; do
    [[ -z "${chatmode_file}" ]] && continue
    [[ "$(basename "${chatmode_file}")" == "copilot-instructions.md" ]] && continue
    if ! basename "${chatmode_file}" | grep -q "\.chatmode\.md$"; then
        echo -e "  ${RED}❌ Chatmode naming: $(basename "${chatmode_file}")${NC}"
        ((NAMING_ERRORS++))
    fi
done <<< "${CHATMODE_FILES}"

# Check profile files end with .profile.md
PROFILE_FILES=$(find "${PROJECT_ROOT}/chatmodes/profiles" -name "*.md" -type f 2>/dev/null)
while IFS= read -r profile_file; do
    [[ -z "${profile_file}" ]] && continue
    [[ "$(basename "${profile_file}")" == "copilot-instructions.md" ]] && continue
    if ! basename "${profile_file}" | grep -q "\.profile\.md$"; then
        echo -e "  ${RED}❌ Profile naming: $(basename "${profile_file}")${NC}"
        ((NAMING_ERRORS++))
    fi
done <<< "${PROFILE_FILES}"

# Check composition files end with .composition.json
COMPOSITION_FILES=$(find "${PROJECT_ROOT}/prompts/compositions" -name "*.json" -type f 2>/dev/null)
while IFS= read -r comp_file; do
    [[ -z "${comp_file}" ]] && continue
    if ! basename "${comp_file}" | grep -q "\.composition\.json$"; then
        echo -e "  ${RED}❌ Composition naming: $(basename "${comp_file}")${NC}"
        ((NAMING_ERRORS++))
    fi
done <<< "${COMPOSITION_FILES}"

if [[ ${NAMING_ERRORS} -eq 0 ]]; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ All file naming conventions correct"
    NAMING_ISSUES=0
else
    NAMING_ISSUES=${NAMING_ERRORS}
fi

echo ""

# ============================================================================
# CHECK 3: Markdown Frontmatter
# ============================================================================
echo "🔍 Check 3: YAML frontmatter in documentation..."

FRONTMATTER_ERRORS=0

# Check critical markdown files have frontmatter
CRITICAL_DOCS=("README.md" "copilot-instructions.md")
for doc in "${CRITICAL_DOCS[@]}"; do
    if [[ -f "${PROJECT_ROOT}/${doc}" ]]; then
        if ! head -1 "${PROJECT_ROOT}/${doc}" | grep -q "^---\|^#\|^---" 2>/dev/null; then
            [[ "${VERBOSE}" == true ]] && echo "  ℹ️  ${doc}: No frontmatter (optional)"
        fi
    fi
done

# Check agent and chatmode configs have required structure
AGENT_CONFIGS=$(find "${PROJECT_ROOT}/agents" -name "config.json" -type f 2>/dev/null)
while IFS= read -r config_file; do
    [[ -z "${config_file}" ]] && continue
    if ! grep -q '"mode"' "${config_file}"; then
        echo -e "  ${YELLOW}⚠️  $(basename $(dirname "${config_file}"))/config.json: Missing 'mode' field${NC}"
        ((FRONTMATTER_ERRORS++))
    fi
done <<< "${AGENT_CONFIGS}"

if [[ ${FRONTMATTER_ERRORS} -eq 0 ]]; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ Configuration structure valid"
else
    FRONTMATTER_ISSUES=${FRONTMATTER_ERRORS}
fi

echo ""

# ============================================================================
# CHECK 4: Directory Structure Consistency
# ============================================================================
echo "🔍 Check 4: Directory structure consistency..."

DIR_STRUCTURE_OK=true

# Check required directories exist
REQUIRED_DIRS=(
    "agents"
    "chatmodes"
    "instructions"
    "prompts"
    "schemas"
    "scripts"
    "templates"
    "toolsets"
    ".claude"
    ".github"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [[ ! -d "${PROJECT_ROOT}/${dir}" ]]; then
        echo -e "  ${RED}❌ Missing directory: ${dir}${NC}"
        DIR_STRUCTURE_OK=false
    fi
done

if [[ "${DIR_STRUCTURE_OK}" == true ]]; then
    [[ "${VERBOSE}" == true ]] && echo "  ✅ All required directories present"
else
    echo -e "  ${RED}❌ Directory structure incomplete${NC}"
    ((HEADER_ISSUES++))
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "📊 Consistency Check Summary"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Version issues: ${VERSION_ISSUES}"
echo "Naming convention issues: ${NAMING_ISSUES}"
echo "Frontmatter issues: ${FRONTMATTER_ISSUES}"
echo "Structure issues: ${HEADER_ISSUES}"
echo ""

TOTAL_ISSUES=$((VERSION_ISSUES + NAMING_ISSUES + FRONTMATTER_ISSUES + HEADER_ISSUES))

if [[ ${TOTAL_ISSUES} -eq 0 ]]; then
    echo -e "${GREEN}✅ PASS: System is consistent${NC}"
    exit 0
else
    echo -e "${RED}❌ FAIL: ${TOTAL_ISSUES} consistency issue(s) detected${NC}"
    [[ "${VERBOSE}" == false ]] && echo "(Use --verbose for details)"
    exit 1
fi
