#!/bin/bash

################################################################################
# STEP 17: run-all-tests.sh
# PHASE 3: QA Framework (Master Test Runner)
#
# PURPOSE:
#   Orchestrates all QA validation scripts in the correct order.
#   Provides a single command to run the entire QA framework.
#
# USAGE:
#   bash scripts/qa/run-all-tests.sh [--verbose] [--quick] [--junit]
#
# OPTIONS:
#   --verbose    Show detailed output for all tests
#   --quick      Skip optional tests (run critical tests only)
#   --junit      Generate JUnit XML report (future)
#
# EXIT CODE:
#   0 = All tests pass (✅ PASS)
#   1 = Some tests fail (❌ FAIL)
#   2 = Critical error (missing test files)
#
# TEST EXECUTION ORDER:
#   1. validate-schemas.sh       (JSON schema validation)
#   2. validate-references.sh    (File reference validation)
#   3. validate-completeness.sh  (System completeness check)
#   4. validate-compositions.sh  (Composition structure validation)
#   5. validate-consistency.sh   (System-wide consistency)
#
# DEPENDENCIES:
#   - All individual validation scripts in scripts/qa/
#   - Standard Unix utilities
#
# OUTPUT:
#   - Colored summary per test
#   - Final summary with pass/fail count
#   - Exit code for CI/CD integration
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
GRAY='\033[0;37m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
VERBOSE=false
QUICK_MODE=false
JUNIT_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose) VERBOSE=true; shift ;;
        --quick) QUICK_MODE=true; shift ;;
        --junit) JUNIT_MODE=true; shift ;;
        *) echo "Unknown option: $1"; exit 2 ;;
    esac
done

# Test array
declare -a TESTS=(
    "validate-schemas"
    "validate-references"
    "validate-completeness"
    "validate-compositions"
    "validate-consistency"
)

# Track results
declare -a TEST_RESULTS
declare -a TEST_DURATIONS
PASSED=0
FAILED=0
TOTAL=${#TESTS[@]}

# Banner
echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   QA Framework - Master Test Runner    ║${NC}"
echo -e "${BLUE}║   PHASE 3: QA Framework (STEP 17)      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""
echo "📋 Running ${TOTAL} validation tests..."
echo ""

# Run each test
for i in "${!TESTS[@]}"; do
    TEST_NAME="${TESTS[$i]}"
    TEST_NUM=$((i + 1))
    TEST_FILE="${SCRIPT_DIR}/${TEST_NAME}.sh"
    
    # Check if test exists
    if [[ ! -f "${TEST_FILE}" ]]; then
        echo -e "${RED}❌ Test ${TEST_NUM}/${TOTAL}: ${TEST_NAME}.sh NOT FOUND${NC}"
        TEST_RESULTS[$i]="MISSING"
        ((FAILED++))
        continue
    fi
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "Test ${TEST_NUM}/${TOTAL}: ${TEST_NAME}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Run test and capture result
    START_TIME=$(date +%s%N)
    
    if [[ "${VERBOSE}" == true ]]; then
        bash "${TEST_FILE}" --verbose
        TEST_EXIT=$?
    else
        bash "${TEST_FILE}" 2>&1 | grep -E "^(✅|❌|⚠️|📊|Total|Found|Items|Paths|Checking|Validating|Valid|Invalid|Missing|PASS|FAIL|Version|Naming|Frontmatter|Structure|issue)"
        TEST_EXIT=${PIPESTATUS[0]}
    fi
    
    END_TIME=$(date +%s%N)
    DURATION=$(( (END_TIME - START_TIME) / 1000000 ))  # Convert to milliseconds
    TEST_DURATIONS[$i]=${DURATION}
    
    echo ""
    
    # Record result
    if [[ ${TEST_EXIT} -eq 0 ]]; then
        echo -e "${GREEN}✅ PASS: ${TEST_NAME}${NC}"
        TEST_RESULTS[$i]="PASS"
        ((PASSED++))
    else
        echo -e "${RED}❌ FAIL: ${TEST_NAME}${NC}"
        TEST_RESULTS[$i]="FAIL"
        ((FAILED++))
    fi
    
    echo ""
done

# ============================================================================
# SUMMARY
# ============================================================================
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║          Test Execution Summary        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Results table
printf "%-30s | %-8s | %-8s\n" "Test" "Result" "Duration"
printf "%-30s | %-8s | %-8s\n" "---" "---" "---"

for i in "${!TESTS[@]}"; do
    TEST_NAME="${TESTS[$i]}"
    TEST_RESULT="${TEST_RESULTS[$i]}"
    TEST_DURATION="${TEST_DURATIONS[$i]}ms"
    
    case "${TEST_RESULT}" in
        PASS)
            printf "%-30s | ${GREEN}%-8s${NC} | %-8s\n" "${TEST_NAME}" "✅ PASS" "${TEST_DURATION}"
            ;;
        FAIL)
            printf "%-30s | ${RED}%-8s${NC} | %-8s\n" "${TEST_NAME}" "❌ FAIL" "${TEST_DURATION}"
            ;;
        MISSING)
            printf "%-30s | ${YELLOW}%-8s${NC} | %-8s\n" "${TEST_NAME}" "⚠️ MISSING" "-"
            ;;
    esac
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "Passed: ${GREEN}${PASSED}${NC}"
echo -e "Failed: ${RED}${FAILED}${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Final result
if [[ ${FAILED} -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✅ ALL TESTS PASSED! 🎉            ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "QA Framework validation complete and successful."
    echo "System is ready for deployment."
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════╗${NC}"
    echo -e "${RED}║      ❌ SOME TESTS FAILED!             ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Please review failures above and fix issues."
    exit 1
fi
