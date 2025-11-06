---

description: 'VS Code integration - Part of multi-IDE agnostic system (also supports Cursor, Visual Studio, GitHub Copilot CLI)'
applyTo: '**/.vscode*/**, **/code/**, **/visual studio code/**, **/.code/**'
type: instruction
category: ide-integration
ide: vscode
version: 2.1.0

---

# VS Code Integration (v2.1.0 - Multi-IDE Agnostic)

**IDE**: VS Code  
**Context Directory**: `.copilot/`  
**Global Config**: `.github/prompts/` (shared across ALL IDEs)  
**Status**: ✅ Production Ready  
**Also Works With**: Cursor, Visual Studio, GitHub Copilot CLI

---

## Overview

VS Code uses the global Copilot configuration with `.copilot/` directory as the primary context source. This setup is **identical across all IDEs** - VS Code, Cursor, Visual Studio, and GitHub Copilot CLI all use the same chatmodes, agents, and instructions.

```
.copilot/                        (VS Code context - SAME as CLI)
   ↓ (references)
.github/prompts/                 (shared by ALL IDEs - chatmodes, agents, etc.)
```

**Multi-IDE Key**: The setup is **completely IDE-agnostic**. No IDE-specific customization needed.

---

## Setup

### Step 1: Install Global Configuration

```bash
# All IDEs use the same global config
git clone https://github.com/Davidmctf/CopilotConfigurationSystem/copilot-config.git \
  ~/.config/Code/User/prompts

# Or: .github/ if git-managed
git clone ... .github/prompts
```

### Step 2: Create .copilot/ Structure

```bash
cd your-project

# Create directories
mkdir -p .copilot/config .copilot/context .copilot/.context-history/sessions
```

### Step 3: Configure Settings

```bash
# Copy template
cp ~/.config/Code/User/prompts/templates/local-project/settings.template.json \
   .copilot/config/settings.json
```

**Edit `.copilot/config/settings.json`**:

```json
{
  "$schema": "${globalConfigPath}/schemas/settings.schema.json",
  
  "env": {
    "globalConfigPath": "~/.config/Code/User/prompts"
  },
  
  "project": {
    "name": "my-project",
    "version": "1.0.0"
  },
  
  "ideDetection": {
    "enabled": true,
    "detectedIDE": "auto",
    "useContextVS": false        // VS Code always false
  },
  
  "agent": {
    "defaultAgent": "baseAgent",
    "contextPath": "${globalConfigPath}/agents"
  },
  
  "model": {
    "default": "copilot/claude-sonnet-4.5",
    "fallback": "copilot/claude-haiku-4.5"
  }
}
```

### Step 4: Initialize Context Files

```bash
# Copy context templates
cp ~/.config/Code/User/prompts/templates/local-project/project-context.template.json \
   .copilot/context/project-context.json

cp ~/.config/Code/User/prompts/templates/local-project/active-context.template.json \
   .copilot/context/active-context.json
```

### Step 5: Verify

1. Open VS Code
2. Open your project
3. Copilot should detect `.copilot/` automatically
4. Test with a simple prompt

---

## How It Works

### Context Priority

When `useContextVS: false` (default):

```
1. .copilot/.context-history/       (primary - VS Code context)
   ↓ (may contain synced data from Visual Studio users)
2. .github/prompts/                 (always referenced - shared chatmodes, agents)
```

**Key**: Same behavior across all IDEs. VS Code, Cursor, and Copilot CLI all use identical logic.

### Context Updates

**Direct Mode** (VS Code only team):
```
Your work in VS Code
     ↓
.copilot/ updated directly
     ↓
git commit
     ↓
Team pulls updates
```

**Synced Mode** (Mixed team with Visual Studio):
```
Visual Studio user works
     ↓
.vs/ → .copilot/ auto-sync
     ↓
git commit
     ↓
You pull and get context
```

---

## File Structure

### .copilot/ Directory

```
.copilot/
├── config/
│   └── settings.json              # useContextVS: false (standard for VS Code)
├── context/
│   ├── project-context.json       # Project metadata
│   ├── active-context.json        # Current state
│   └── [synced from VS if team]   # May receive from Visual Studio users
├── .context-history/
│   ├── CopilotIndices/            # Code indices
│   └── sessions/*.jsonl           # Session history
└── mcp.json                       # MCP config (optional)
```

---

## Team Collaboration

### Scenario 1: VS Code Only Team

**Setup**: All developers use VS Code.

**Workflow**:

```bash
# 1. Initial setup
mkdir -p .copilot/config .copilot/context .copilot/.context-history/sessions
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# 2. Work normally
# - Edit code
# - Copilot uses .copilot/

# 3. Share context
git add .copilot/
git commit -m "Update context from VS Code session"
git push

# 4. Team pulls
git pull
```

**Result**: Everyone edits `.copilot/` directly, same chatmodes across all.

---

### Scenario 2: Mixed Team (VS Code + Visual Studio)

**Setup**: Some use VS Code, some use Visual Studio Enterprise.

**Your Workflow** (VS Code User):

```bash
# 1. Setup
mkdir -p .copilot/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Verify settings: useContextVS: false

# 2. Get latest (morning)
git pull

# 3. Work in VS Code
# - Same chatmodes as VS users
# - Your code understanding is shared

# 4. Update context (optional)
git add .copilot/
git commit -m "Update from VS Code"
git push
```

**VS User Workflow** (They):

```bash
# They work in Visual Studio
# - Copilot uses .vs/ (native, fast)
# - Auto-syncs to .copilot/
# - Commits .copilot/ to git
```

**Result**: Seamless collaboration. Same chatmodes, shared context, no IDE conflicts.

---

### Scenario 3: VS Code + Cursor Mixed Team

**Setup**: Some use VS Code, some use Cursor.

**Your Workflow** (VS Code):

```bash
# Same as pure VS Code setup
mkdir -p .copilot/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/
```

**Cursor User Workflow**:

```bash
# They use .cursor/ instead
mkdir -p .cursor/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/

# They sync to .copilot/ for git sharing
cp .cursor/context/* .copilot/context/
git add .copilot/
git commit -m "Update from Cursor"
```

**Result**: Both IDEs use same chatmodes. Context sharing via .copilot/ in git.

---

## Configuration Reference

### settings.json (VS Code)

```json
{
  "$schema": "${globalConfigPath}/schemas/settings.schema.json",

  "env": {
    "globalConfigPath": "~/.config/Code/User/prompts"
  },

  "project": {
    "name": "your-project",
    "version": "1.0.0"
  },

  "ideDetection": {
    "enabled": true,
    "detectedIDE": "auto",
    "useContextVS": false           // ← KEY: Always false for VS Code
  },

  "agent": {
    "defaultAgent": "baseAgent",
    "contextPath": "${globalConfigPath}/agents"
  },

  "context": {
    "core": {
      "path": "${configPath}/context/project-context.json",
      "$schema": "${globalConfigPath}/schemas/context.schema.json"
    },
    "active": {
      "path": "${configPath}/context/active-context.json",
      "$schema": "${globalConfigPath}/schemas/context.schema.json"
    }
  },

  "history": {
    "path": "${configPath}/.context-history/",
    "retention": {
      "useContextVS": false         // ← Always false
    }
  },

  "model": {
    "default": "copilot/claude-sonnet-4.5",
    "fallback": "copilot/claude-haiku-4.5"
  },

  "mcp": {
    "enabled": true,
    "configPath": "${configPath}/mcp.json"
  }
}
```

---

## Best Practices

### ✅ DO

✅ Set `useContextVS: false` (or omit)  
✅ Commit `.copilot/` to git  
✅ Pull before work (esp. mixed teams)  
✅ Use same chatmodes as all IDEs  
✅ Reference `.github/prompts/` for all configs  

### ❌ DON'T

❌ Set `useContextVS: true` (VS Code can't use it)  
❌ Expect `.vs/` directory (doesn't exist in VS Code)  
❌ Commit `.vs/` (if accidentally created)  
❌ Create IDE-specific chatmodes (already global)  

---

## Troubleshooting

### Issue: Copilot has no context

**Solutions**:

```bash
# 1. Verify .copilot/ exists
ls -la .copilot/

# 2. Check settings.json
cat .copilot/config/settings.json

# 3. Verify useContextVS is false
grep "useContextVS" .copilot/config/settings.json
# Should show: "useContextVS": false (or not present)

# 4. Pull latest
git pull

# 5. Restart VS Code
```

### Issue: Context seems stale

**Solutions**:

```bash
# If mixed team with VS users:
git log -1 --oneline .copilot/
# See when last updated from VS

# Pull latest
git pull

# Check if VS user synced recently
# (Ask them to save files to trigger sync)
```

### Issue: Conflicts in .copilot/

**Solutions**:

```bash
# If on mixed team, accept VS version (they have richer context)
git checkout --theirs .copilot/
git add .copilot/
git commit -m "Resolve conflict: accept VS context"

# OR: Manual merge if VS Code only team
# (Standard git conflict resolution)
```

---

## Multi-IDE Summary

| Aspect | VS Code | Cursor | Visual Studio | Copilot CLI |
|--------|---------|--------|---------------|------------|
| Context Dir | `.copilot/` | `.cursor/` | `.vs/` | `.copilot/` |
| `useContextVS` | `false` | `false` | `true` | `false` |
| Chatmodes | Same | Same | Same | Same |
| Agents | Same | Same | Same | Same |
| Setup Time | ~5 min | ~5 min | ~5 min | ~5 min |
| Token Reduction | 85% | 85% | 85% | 85% |

**Key**: All IDEs use identical logic. No IDE-specific customization needed.

---

## Related Documentation

- [multi-ide.instructions.md](./multi-ide.instructions.md) - Universal multi-IDE guide
- [cursor.instructions.md](./cursor.instructions.md) - Cursor-specific tips
- [visual-studio.instructions.md](./visual-studio.instructions.md) - Visual Studio tips
- [../../copilot-instructions.md](../../copilot-instructions.md) - Master documentation

---

**Version**: 2.1.0 | **Last Updated**: 2025-10-21 | **Status**: ✅ Production Ready (Multi-IDE Agnostic)
