---
description: 'Visual Studio Enterprise integration - Part of multi-IDE agnostic system (also supports VS Code, Cursor, GitHub Copilot CLI)'
applyTo: '**/*.vs*/** , **/visual studio*/**'
type: instruction
category: ide-integration
ide: visualstudio
version: 2.1.0
---

# Visual Studio Enterprise Integration (v2.1.0 - Multi-IDE Agnostic)

**IDE**: Visual Studio Enterprise/Professional  
**Context Directory**: `.vs/` (primary) → `.copilot/` (team sharing)  
**Global Config**: `.github/prompts/` (shared across ALL IDEs)  
**Status**: ✅ Production Ready  
**Also Works With**: VS Code, Cursor, GitHub Copilot CLI

---

## Overview

Visual Studio Enterprise uses the global Copilot configuration with native `.vs/` directory integration. The system **automatically syncs** to `.copilot/` for team collaboration with VS Code, Cursor, and Copilot CLI users.

```
.vs/                             (Visual Studio native - FAST)
   ↓ (auto-syncs to)
.copilot/                        (team sharing)
   ↓ (references)
.github/prompts/                 (shared by ALL IDEs)
```

**Multi-IDE Key**: Same chatmodes, agents, and instructions work across all IDEs. VS provides native performance, others use synced `.copilot/`.

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
mkdir -p .copilot/sync
```

### Step 3: Configure Settings

```bash
# Copy Visual Studio template
cp ~/.config/Code/User/prompts/templates/visualstudio/settings-visualstudio.template.json \
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
    "useContextVS": true          // ← VS Enterprise: always true
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

### Step 4: Configure Sync Mapping (Optional but Recommended)

```bash
# Copy sync configuration
cp ~/.config/Code/User/prompts/templates/visualstudio/vs-mapping.template.json \
   .copilot/sync/vs-mapping.json
```

**Edit `.copilot/sync/vs-mapping.json`**:

```json
{
  "version": "1.0",
  "mappings": {
    "copilotIndices": {
      "source": ".vs/{projectName}/CopilotIndices/{vsVersion}/",
      "target": ".copilot/.context-history/CopilotIndices/"
    },
    "fileContentIndex": {
      "source": ".vs/{solutionName}.slnx/FileContentIndex/",
      "target": ".copilot/context/FileContentIndex/"
    },
    "sessionState": {
      "source": ".vs/{solutionName}.slnx/v18/",
      "target": ".copilot/context/v18/"
    }
  },
  "syncRules": {
    "autoSync": true,
    "syncOnSave": true,
    "syncOnClose": true
  },
  "variables": {
    "projectName": "YourProjectName",     // ← UPDATE
    "solutionName": "YourSolution.slnx",  // ← UPDATE
    "vsVersion": "18.0.877.25981"
  }
}
```

### Step 5: Initialize Context Files

```bash
# Copy context templates
cp ~/.config/Code/User/prompts/templates/local-project/project-context.template.json \
   .copilot/context/project-context.json

cp ~/.config/Code/User/prompts/templates/local-project/active-context.template.json \
   .copilot/context/active-context.json
```

### Step 6: Verify

1. Open Visual Studio
2. Copilot should detect `.vs/` automatically
3. Changes should sync to `.copilot/`
4. Test with a simple prompt

---

## How It Works

### Context Priority

When `useContextVS: true`:

```
1. .vs/{project}/CopilotIndices/       (primary - native VS context - FASTEST)
   ↓ (if not found or empty)
2. .copilot/.context-history/          (fallback)
   ↓ (always referenced)
3. .github/prompts/                    (global chatmodes, agents, instructions)
```

**Performance**: Native `.vs/` context is fastest. Automatically syncs to `.copilot/` for team.

### Automatic Synchronization

When enabled, Copilot syncs:

```
.vs/                              →  .copilot/
├── {project}/CopilotIndices/     →  .context-history/CopilotIndices/
├── {solution}.slnx/
│   ├── FileContentIndex/         →  context/FileContentIndex/
│   └── v18/                      →  context/v18/
└── VSWorkspaceState.json         →  workspace-state.json
```

**Sync Triggers**:
- On save (if `syncOnSave: true`)
- On close (if `syncOnClose: true`)
- Manual trigger

**Conflict Resolution**: Visual Studio always wins (`.vs/` → `.copilot/`)

---

## File Structure

### .vs/ Directory (Local, Not in Git)

```
.vs/
├── {ProjectName}/
│   └── CopilotIndices/
│       └── {vsVersion}/
│           ├── CodeChunks.db
│           └── SemanticSymbols.db
├── {SolutionName}.slnx/
│   ├── FileContentIndex/
│   ├── v18/
│   └── DesignTimeBuild/
└── VSWorkspaceState.json
```

**Note**: `.vs/` is in `.gitignore` (local only, large files)

### .copilot/ Directory (In Git for Team Sharing)

```
.copilot/
├── config/
│   └── settings.json              # useContextVS: true
├── sync/
│   └── vs-mapping.json            # Sync configuration
├── context/
│   ├── project-context.json       # Project metadata
│   ├── active-context.json        # Current state
│   ├── FileContentIndex/          # ← Synced from .vs/
│   └── v18/                       # ← Synced from .vs/
├── .context-history/
│   ├── CopilotIndices/            # ← Synced from .vs/
│   └── sessions/*.jsonl
└── workspace-state.json           # ← Synced from .vs/
```

**Note**: `.copilot/` committed to git (shared with team)

---

## Team Collaboration

### Scenario 1: Visual Studio Only Team

**Setup**: All developers use Visual Studio Enterprise.

**Workflow** (All Developers):

```bash
# 1. Initial setup
mkdir -p .copilot/{config,sync,context,.context-history/sessions}
cp templates/visualstudio/* .copilot/
# Update settings: useContextVS: true

# 2. Work in Visual Studio
# - Copilot uses .vs/ (native, optimal)
# - Auto-syncs to .copilot/

# 3. Share context (backup)
git add .copilot/
git commit -m "Backup context from VS session"
git push
```

**Result**: Optimal performance with native VS context.

---

### Scenario 2: Mixed Team (VS Code + Visual Studio)

**Your Workflow** (Visual Studio):

```bash
# 1. Setup
mkdir -p .copilot/{config,sync,context,.context-history/sessions}
cp templates/visualstudio/* .copilot/
# useContextVS: true, sync enabled

# 2. Work in Visual Studio
# - Copilot uses .vs/ (native, fast)
# - Auto-syncs to .copilot/ on save/close

# 3. Share with team
git add .copilot/
git commit -m "Update context from VS session"
git push
```

**VS Code User Workflow**:

```bash
# They use .copilot/ directly
mkdir -p .copilot/{config,context,.context-history/sessions}
cp templates/local-project/* .copilot/
# useContextVS: false

# They pull your synced context
git pull

# Same chatmodes, same agents, different IDEs
```

**Result**: Seamless collaboration. VS gets native performance, VS Code gets synced context.

---

### Scenario 3: Mixed Team (Cursor + Visual Studio)

**Your Workflow** (Visual Studio):

```bash
# Same as above VS Code scenario
mkdir -p .copilot/{config,sync,context,.context-history/sessions}
cp templates/visualstudio/* .copilot/
# useContextVS: true
```

**Cursor User Workflow**:

```bash
# They use .cursor/ natively
mkdir -p .cursor/{config,context,.context-history/sessions}
cp templates/local-project/* .cursor/

# They can sync to .copilot/ for git sharing
cp .cursor/context/* .copilot/context/
git add .copilot/
git commit -m "Sync Cursor context to .copilot/"
```

**Result**: All IDEs use same chatmodes. Context shared via `.copilot/` in git.

---

## Configuration Reference

### settings.json (Visual Studio)

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
    "useContextVS": true            // ← KEY: Always true for VS
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
      "useContextVS": true          // ← Always true
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

✅ Set `useContextVS: true` (optimal for VS)  
✅ Enable sync mapping (for team)  
✅ Commit `.copilot/` to git  
✅ Keep `.vs/` in `.gitignore`  
✅ Let sync happen automatically  
✅ Use same chatmodes as all IDEs  

### ❌ DON'T

❌ Set `useContextVS: false` (defeats VS optimization)  
❌ Commit `.vs/` to git (large, local-specific)  
❌ Edit `.copilot/` manually (will be overwritten)  
❌ Create IDE-specific chatmodes (already global)  
❌ Disable sync (team benefits from it)  

---

## Troubleshooting

### Issue: Copilot not using .vs/ context

**Solutions**:

```bash
# 1. Check settings.json
cat .copilot/config/settings.json | grep "useContextVS"
# Should show: "useContextVS": true

# 2. Verify .vs/ directory exists
dir .vs

# 3. Restart Visual Studio

# 4. Check Copilot extension version
# (Update if needed)
```

### Issue: Sync not working

**Solutions**:

```bash
# 1. Verify sync mapping
cat .copilot/sync/vs-mapping.json

# 2. Check project name matches
# (Should match your project exactly)

# 3. Verify .copilot/ is writable
# (Check folder permissions)

# 4. Manually trigger
# (Save a file to trigger onSave sync)

# 5. Check if files synced
dir .copilot/.context-history/CopilotIndices/
```

### Issue: Context not shared with VS Code team

**Solutions**:

```bash
# 1. Verify sync completed
ls -la .copilot/.context-history/

# 2. Commit and push
git add .copilot/
git commit -m "Sync from VS"
git push

# 3. VS Code user pulls
# They run: git pull

# 4. Verify they have context
# Ask them to check .copilot/ exists
```

---

## Multi-IDE Comparison

| Aspect | VS Enterprise | VS Code | Cursor | Copilot CLI |
|--------|---------------|---------|--------|------------|
| Context Dir | `.vs/` | `.copilot/` | `.cursor/` | `.copilot/` |
| `useContextVS` | `true` | `false` | `false` | `false` |
| Performance | Fastest (native) | Good | Good | Good |
| Sync to Team | `.copilot/` | Via pull | Via git | Via pull |
| Chatmodes | Same | Same | Same | Same |
| Agents | Same | Same | Same | Same |
| Token Reduction | 85% | 85% | 85% | 85% |

**Key**: All IDEs use identical logic and same chatmodes. No IDE-specific tuning needed.

---

## Advanced: Optimizing for Mixed Teams

If your team uses multiple IDEs:

1. **VS Users** (you):
   - Set `useContextVS: true` in settings
   - Enable sync mapping
   - Commit `.copilot/` after sessions

2. **VS Code/Cursor Users**:
   - Use `.copilot/` or `.cursor/`
   - Pull latest from git
   - Get VS context automatically

3. **Workflow**:
   - VS: Work → Sync → Commit → Push
   - Others: Pull → Work → (Optional: Commit) → Push
   - Result: Shared context, no conflicts

---

## Related Documentation

- [multi-ide.instructions.md](./multi-ide.instructions.md) - Universal multi-IDE guide
- [vscode.instructions.md](./vscode.instructions.md) - VS Code integration
- [cursor.instructions.md](./cursor.instructions.md) - Cursor integration
- [../../copilot-instructions.md](../../copilot-instructions.md) - Master documentation

---

**Version**: 2.1.0 | **Last Updated**: 2025-10-21 | **Status**: ✅ Production Ready (Multi-IDE Agnostic)
