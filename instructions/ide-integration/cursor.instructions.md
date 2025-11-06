---

description: 'Cursor-specific integration instructions for the multi-IDE agnostic configuration system'
applyTo: '**/.cursor*/**, **/cursor/**'
type: instruction
category: ide-integration
version: 1.0

---

# Cursor Integration Instructions

**IDE**: Cursor AI  
**Context Directory**: `.cursor/`  
**Global Config**: `.github/prompts/` (same as all IDEs)  
**Status**: ✅ Production Ready

---

## Overview

Cursor is a fully supported IDE in the multi-IDE agnostic system. It uses **native `.cursor/` context management** while referencing the same global configuration as VS Code, Visual Studio, and GitHub Copilot CLI.

```
.cursor/                        (Cursor-specific context)
   ↓ (references)
.github/prompts/                (shared chatmodes, agents, instructions)
```

**Key Benefit**: Same chatmodes and agents work identically across Cursor and all other IDEs - no IDE-specific customization needed.

---

## Setup

### 1. Install Global Configuration

```bash
# Linux/Mac
git clone https://github.com/Davidmctf/CopilotConfigurationSystem/copilot-config.git \
  ~/.config/Code/User/prompts

# Or use .github/ if git-managed
# git clone ... .github/prompts
```

### 2. Initialize Project (Cursor)

```bash
cd your-project

# Create Cursor context directories
mkdir -p .cursor/config .cursor/context .cursor/.context-history/sessions

# Copy templates
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/
```

### 3. Configure Settings

**File**: `.cursor/config/settings.json`

```json
{
  "version": "2.1.0",
  "env": {
    "globalConfigPath": "~/.config/Code/User/prompts"
  },
  "project": {
    "name": "my-project",
    "version": "1.0.0",
    "description": "Project description"
  },
  "ideDetection": {
    "enabled": true,
    "detectedIDE": "cursor",
    "useCursorContext": true
  },
  "model": {
    "default": "copilot/claude-sonnet-4.5",
    "fallback": "copilot/claude-haiku-4.5"
  }
}
```

### 4. (Optional) Share Context with Team

If your team uses multiple IDEs and wants to share context via git:

```bash
# Sync Cursor context to .copilot/ for git sharing (daily)
cp -r .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor session"
git push

# Pull latest from Visual Studio or VS Code users
git pull
cp .copilot/context/* .cursor/context/ 2>/dev/null || true
```

---

## Context Directory Structure

```
.cursor/
├── config/
│   └── settings.json              # Configuration (step 3 above)
├── context/
│   ├── project-context.json       # Project metadata (static)
│   └── active-context.json        # Current state (dynamic)
├── .context-history/
│   └── sessions/
│       └── *.jsonl                # Session history (streaming)
└── mcp.json                       # MCP servers config (optional)
```

### Context Files

**project-context.json** (Static):
- Project metadata (rarely changes)
- Tech stack, architecture, patterns
- ~500 tokens

**active-context.json** (Dynamic):
- Current state (changes frequently)
- Recent files, tasks, metrics
- ~800-1000 tokens

**.context-history/** (Persistent):
- Session history (JSONL format)
- Messages, decisions, learned facts
- Selective loading for efficiency

---

## Usage

### Using Chatmodes in Cursor

All chatmodes work identically:

1. **quick-assistant** - Fast help mode (< 3s validation)
2. **research-assistant** - Deep analysis mode (critical thinking)
3. **agent-orchestrator** - Complex workflows (multi-agent coordination)

**Selection**:
- Use `/` to trigger slash commands
- Or invoke via Cursor's chat interface
- Same behavior as VS Code

### Agent Execution

Agents execute silently and return structured results:

- **baseAgent** - General-purpose executor
- **orchestratorAgent** - Multi-agent coordinator (70-80% token reduction)

**Token Savings**: Same 85% total reduction as other IDEs.

---

## Cursor-Specific Features

### AI Autocomplete

✅ Works with any chatmode  
✅ References same `.github/prompts/`  
✅ Uses same global configuration

### Chat Interface

✅ Access all chatmodes  
✅ Same instruction set as VS Code  
✅ Identical dual-mode behavior

### Composer (if available)

✅ Access all agents  
✅ Same orchestration patterns  
✅ Identical execution semantics

---

## Team Collaboration

### Cursor + VS Code Mixed Team

**Setup**:
- VS Code users: `.copilot/`
- Cursor users: `.cursor/`
- Shared: `.github/prompts/`

**Workflow**:

```bash
# Cursor user (morning)
git pull

# If .copilot/ was updated, sync to .cursor/
cp .copilot/context/* .cursor/context/ 2>/dev/null || true

# Work in Cursor
# ... (use same chatmodes as VS Code users)

# Cursor user (end of day)
cp .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor"
git push
```

**Result**: All chatmodes identical, seamless collaboration.

---

### Cursor + Visual Studio Mixed Team

**Setup**:
- VS: `.vs/` (auto-syncs to `.copilot/`)
- Cursor: `.cursor/` (manual sync via git)
- Shared: `.github/prompts/`

**Workflow**:

```bash
# Cursor user (morning)
git pull
cp .copilot/context/* .cursor/context/ 2>/dev/null || true

# Work in Cursor
# ... (same chatmodes as VS users)

# Cursor user (end of day)
cp .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor"
git push
```

**Result**: VS users get native performance, Cursor users get shared context.

---

## Best Practices (Cursor-Specific)

### ✅ DO

- ✅ Use `.cursor/` for all local context
- ✅ Reference `.github/prompts/` for global config
- ✅ Share context via `.copilot/` if team uses multiple IDEs
- ✅ Commit `.copilot/` (not `.cursor/`) to git for team
- ✅ Enable `ideDetection` in settings

### ❌ DON'T

- ❌ Commit `.cursor/` to git (local-only)
- ❌ Edit VS user's `.copilot/` manually (they auto-sync from `.vs/`)
- ❌ Duplicate chatmode definitions (they're already global)
- ❌ Modify global `.github/prompts/` for Cursor-specific changes (all IDEs use it)

---

## Troubleshooting

### Issue: Cursor not detecting context

**Symptoms**: Cursor chat has no memory

**Solution**:
1. Verify `.cursor/config/settings.json` exists
2. Check `"useCursorContext": true` in settings
3. Verify `.cursor/context/project-context.json` exists
4. Restart Cursor
5. If still failing, manually trigger context load

---

### Issue: Context from VS team not syncing

**Symptoms**: VS users commit context, but Cursor user doesn't see it

**Solution**:
1. Verify `.copilot/` exists in git
2. Pull latest: `git pull`
3. Manually sync: `cp .copilot/context/* .cursor/context/`
4. Restart Cursor

---

### Issue: Chatmodes work in VS Code but not Cursor

**Symptoms**: Same chatmode behaves differently

**Possible Causes**:
- Wrong global config path in settings
- Cursor is reading from wrong context directory
- Global config not installed

**Solution**:
1. Check `globalConfigPath` in `.cursor/config/settings.json`
2. Verify path points to `.github/prompts/`
3. Test path manually: `ls ~/.config/Code/User/prompts/chatmodes/`
4. If missing, reinstall global config

---

## IDE-Specific Variables

Cursor uses same variable system as other IDEs:

| Variable | Example |
|----------|---------|
| `${globalConfigPath}` | `~/.config/Code/User/prompts` |
| `${workspaceFolder}` | `/path/to/project` |
| `${configPath}` | `${workspaceFolder}/.cursor` |

---

## Comparison with Other IDEs

| Aspect | Cursor | VS Code | Visual Studio | Copilot CLI |
|--------|--------|---------|---------------|------------|
| Context Dir | `.cursor/` | `.copilot/` | `.vs/` | `.copilot/` |
| Global Config | `.github/prompts/` | `.github/prompts/` | `.github/prompts/` | `.github/prompts/` |
| Chatmodes | Identical | Identical | Identical | Identical |
| Agents | Identical | Identical | Identical | Identical |
| Token Reduction | 85% | 85% | 85% | 85% |
| Setup Time | ~5 min | ~5 min | ~5 min | ~5 min |

**Result**: No IDE-specific tuning needed - write once, run anywhere.

---

## Additional Resources

- [multi-ide.instructions.md](./multi-ide.instructions.md) - Multi-IDE setup guide
- [vscode.instructions.md](./vscode.instructions.md) - VS Code specific tips
- [visual-studio.instructions.md](./visual-studio.instructions.md) - Visual Studio specific tips
- [../../copilot-instructions.md](../../copilot-instructions.md) - Master documentation
- [../../INTEGRATION_GUIDE.instructions.md](../../INTEGRATION_GUIDE.instructions.md) - Full integration guide

---

**Version**: 1.0 | **Last Updated**: 2025-10-21 | **Status**: ✅ Production Ready for Cursor
