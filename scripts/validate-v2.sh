#!/bin/bash

# validate-v2.sh
# Validation script for Architecture v2.0.0
# Version: 1.0.0
# Date: 2025-10-16

echo "🔍 Validating v2.0.0 Architecture..."
echo ""

ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Function to check JSON validity
check_json() {
    local file="$1"
    if [ -f "$file" ]; then
        if python -m json.tool "$file" > /dev/null 2>&1; then
            echo -e "${GREEN}✅${NC} JSON valid: $file"
        else
            echo -e "${RED}❌${NC} JSON invalid: $file"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${YELLOW}⚠️${NC}  File not found: $file"
        WARNINGS=$((WARNINGS + 1))
    fi
}

# Function to check version in file
check_version() {
    local file="$1"
    local expected_version="$2"

    if [ -f "$file" ]; then
        if grep -q "version.*$expected_version" "$file" 2>/dev/null || \
           grep -q "Version.*$expected_version" "$file" 2>/dev/null; then
            echo -e "${GREEN}✅${NC} Version $expected_version found in: $file"
        else
            echo -e "${YELLOW}⚠️${NC}  Version $expected_version not found in: $file"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "${RED}❌${NC} File not found: $file"
        ERRORS=$((ERRORS + 1))
    fi
}

# Function to check for required content
check_content() {
    local file="$1"
    local search_term="$2"
    local description="$3"

    if [ -f "$file" ]; then
        if grep -qi "$search_term" "$file"; then
            echo -e "${GREEN}✅${NC} Found '$description' in: $file"
        else
            echo -e "${YELLOW}⚠️${NC}  Missing '$description' in: $file"
            WARNINGS=$((WARNINGS + 1))
        fi
    else
        echo -e "${RED}❌${NC} File not found: $file"
        ERRORS=$((ERRORS + 1))
    fi
}

echo "📁 Phase 1: Checking JSON Files..."
echo "=================================="
check_json "agents/baseAgent/config.json"
check_json "agents/orchestratorAgent/config.json"
echo ""

echo "📝 Phase 2: Checking Versions..."
echo "=================================="
check_version "agents/baseAgent/config.json" "2.0.0"
check_version "agents/orchestratorAgent/config.json" "2.0.0"
check_version "agents/baseAgent/AGENTS.md" "2.0.0"
check_version "agents/orchestratorAgent/AGENTS.md" "2.0.0"
check_version "chatmodes/profiles/collaborative.profile.md" "2.0.0"
check_version "chatmodes/profiles/focused.profile.md" "2.0.0"
check_version "instructions/capabilities/orchestration.instructions.md" "2.0.0"
check_version "chatmodes/quick-assistant.chatmode.md" "2.0.0"
check_version "chatmodes/research-assistant.chatmode.md" "2.0.0"
check_version "chatmodes/agent-orchestrator.chatmode.md" "2.0.0"
check_version "instructions/core/communication.instructions.md" "2.0.0"
echo ""

echo "🔎 Phase 3: Checking v2.0 Features..."
echo "======================================"
check_content "chatmodes/profiles/collaborative.profile.md" "refutation" "Refutation capability"
check_content "chatmodes/profiles/collaborative.profile.md" "assumption" "Assumption challenging"
check_content "chatmodes/profiles/focused.profile.md" "validation" "Quick validation"
check_content "instructions/capabilities/orchestration.instructions.md" "chatmode" "Chatmode integration"
check_content "agents/baseAgent/AGENTS.md" "agent_executor" "Agent executor mode"
check_content "agents/baseAgent/AGENTS.md" "JSON" "JSON output"
echo ""

echo "📋 Phase 4: Checking Communication Modes..."
echo "============================================="
check_content "agents/baseAgent/config.json" "agent_executor" "Agent executor in baseAgent"
check_content "agents/orchestratorAgent/config.json" "agent_executor" "Agent executor in orchestratorAgent"
check_content "chatmodes/agent-orchestrator.chatmode.md" "human_interactive" "Human interactive in chatmode"
echo ""

echo "📚 Phase 5: Checking Documentation..."
echo "======================================="
if [ -f "CHANGELOG_v2.0.0.md" ]; then
    echo -e "${GREEN}✅${NC} CHANGELOG_v2.0.0.md exists"
else
    echo -e "${YELLOW}⚠️${NC}  CHANGELOG_v2.0.0.md not found"
    WARNINGS=$((WARNINGS + 1))
fi

if [ -f "USAGE_GUIDE_v2.0.md" ]; then
    echo -e "${GREEN}✅${NC} USAGE_GUIDE_v2.0.md exists"
else
    echo -e "${YELLOW}⚠️${NC}  USAGE_GUIDE_v2.0.md not found"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "🔄 Phase 6: Checking Backup..."
echo "==============================="
if [ -d "backups" ]; then
    BACKUP_COUNT=$(find backups -type d -name "backup-*" | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅${NC} Found $BACKUP_COUNT backup(s)"
    else
        echo -e "${YELLOW}⚠️${NC}  No backups found in backups/ directory"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo -e "${YELLOW}⚠️${NC}  backups/ directory not found"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "═══════════════════════════════════"
echo "📊 Validation Summary"
echo "═══════════════════════════════════"
echo -e "Errors:   ${RED}$ERRORS${NC}"
echo -e "Warnings: ${YELLOW}$WARNINGS${NC}"
echo ""

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}✅ All checks passed! Architecture v2.0.0 is valid.${NC}"
    exit 0
elif [ "$ERRORS" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  Validation completed with warnings. Review above.${NC}"
    exit 0
else
    echo -e "${RED}❌ Validation failed with $ERRORS error(s). Fix errors above.${NC}"
    exit 1
fi
