---

description: 'Multi-IDE agnostic integration for VS Code, Cursor, Visual Studio, and GitHub Copilot CLI'
applyTo: '**'
type: instruction
category: ide-integration
version: 2.1.0

---

# Multi-IDE Integration Instructions (v2.1.0)

**Supported IDEs**: VS Code • Cursor • Visual Studio Enterprise • GitHub Copilot CLI  
**Global Config Location**: All IDEs use `~/.config/Code/User/prompts/` or `.github/prompts/`  
**Status**: ✅ Production Ready

---

## Overview

The global configuration system is **completely IDE-agnostic**:

- **Same chatmodes** work across all IDEs
- **Same agents** produce identical results
- **Same instructions** apply universally
- **IDE differences**: Only LOCAL context directory

```
GLOBAL (.github/prompts/ or ~/.config/Code/User/prompts/)
   ↓ (used identically by)
┌──────────────┬────────────┬──────────────┬──────────────┐
│   VS Code    │   Cursor   │Visual Studio │   Copilot    │
│              │            │   Enterprise │      CLI     │
└──────────────┴────────────┴──────────────┴──────────────┘
   ↓               ↓             ↓              ↓
.copilot/      .cursor/       .vs/         .copilot/
(direct)       (native)    (native+sync)   (direct)
```

---

## IDE Detection & Configuration

### Automatic IDE Detection

The system detects your IDE and configures accordingly:

```json
{
  "ideDetection": {
    "enabled": true,
    "detectedIDE": "auto",  // or manually set: "vscode", "cursor", "visualstudio", "copilot-cli"
    "contextPriority": {
      "visualStudio": [".vs/", ".copilot/", ".github/prompts/"],
      "vscode": [".copilot/", ".github/prompts/"],
      "cursor": [".cursor/", ".github/prompts/"],
      "copilotCli": [".copilot/", ".github/prompts/"]
    }
  }
}
```

### By IDE

#### Visual Studio Enterprise/Professional

**Config**: `useContextVS: true`

**Context Priority**:
```
.vs/{project}/CopilotIndices/        (primary - native VS context)
   ↓ (auto-syncs to)
.copilot/.context-history/           (for team via git)
   ↓ (references)
.github/prompts/                     (chatmodes, agents, instructions)
```

**Behavior**:
- ✅ Uses native `.vs/` for optimal performance
- ✅ Auto-syncs to `.copilot/` for sharing
- ✅ References same `.github/prompts/` as other IDEs
- ✅ Team members (VS Code/Cursor users) get synced context

**Setup**:
```bash
mkdir -p .copilot/config .copilot/context
cp .github/prompts/templates/visualstudio/settings-visualstudio.template.json \
   .copilot/config/settings.json
```

**Note**: ⚠️ DO NOT edit `.copilot/` manually - it's auto-synced from `.vs/`

---

#### VS Code

**Config**: `useContextVS: false` (or omit)

**Context Priority**:
```
.copilot/.context-history/           (direct usage)
   ↓ (may receive synced data from)
Visual Studio users                  (via git)
   ↓ (references)
.github/prompts/                     (chatmodes, agents, instructions)
```

**Behavior**:
- ✅ Uses `.copilot/` directly (no special sync)
- ✅ Can receive synced context from VS users
- ✅ Safe to edit `.copilot/` manually
- ✅ References same `.github/prompts/` as other IDEs

**Setup**:
```bash
mkdir -p .copilot/config .copilot/context
cp .github/prompts/templates/local-project/* .copilot/
```

---

#### Cursor

**Config**: `useCursorContext: true` (or auto-detected)

**Context Priority**:
```
.cursor/                             (native Cursor context)
   ↓ (references)
.github/prompts/                     (chatmodes, agents, instructions)
```

**Behavior**:
- ✅ Uses `.cursor/` exclusively (Cursor-native)
- ✅ Independent from `.copilot/` and `.vs/`
- ✅ Same chatmodes via `.github/prompts/`
- ✅ No sync needed - Cursor manages context internally

**Setup**:
```bash
mkdir -p .cursor/config .cursor/context
cp .github/prompts/templates/local-project/* .cursor/
# Adjust paths for .cursor/ instead of .copilot/
```

**Note**: Cursor may also use `.copilot/` for compatibility. Check your Cursor version.

---

#### GitHub Copilot CLI

**Config**: Automatic (same as VS Code)

**Context Priority**:
```
.copilot/                            (CLI context)
   ↓ (may receive synced data from)
Visual Studio users                  (via git)
   ↓ (references)
.github/prompts/                     (chatmodes, agents, instructions)
```

**Behavior**:
- ✅ Uses `.copilot/` (same as VS Code)
- ✅ CLI-driven context management
- ✅ Same setup as VS Code
- ✅ References same `.github/prompts/`

**Setup**:
```bash
# Same as VS Code
mkdir -p .copilot/config .copilot/context
cp .github/prompts/templates/local-project/* .copilot/
```

---

## Team Workflows

### Mixed Team: Visual Studio + VS Code + Cursor

#### Setup (One-Time)

**All Developers**:
```bash
# 1. Install global config (same for all IDEs)
git clone https://github.com/Davidmctf/CopilotConfigurationSystem/copilot-config.git \
  ~/.config/Code/User/prompts

# 2. Initialize project
cd my-project

# 3. IDE-specific initialization
# VS developers:
mkdir -p .copilot/config .copilot/context
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/

# VS Code developers:
mkdir -p .copilot/config .copilot/context
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Cursor developers:
mkdir -p .cursor/config .cursor/context
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/
# (adjust settings to use .cursor/ instead of .copilot/)
```

#### Workflow

**Visual Studio Developer (Alice)**:
```bash
# 1. Configure settings.json
echo '{"useContextVS": true, "globalConfigPath": "~/.config/Code/User/prompts"}' \
  > .copilot/config/settings.json

# 2. Work in Visual Studio
# - Copilot uses .vs/ (native, optimal performance)
# - Auto-syncs to .copilot/ (for team)

# 3. Commit synced context (daily)
git add .copilot/
git commit -m "Update context from Visual Studio session"
git push
```

**VS Code Developer (Bob)**:
```bash
# 1. Configure settings.json
echo '{"useContextVS": false, "globalConfigPath": "~/.config/Code/User/prompts"}' \
  > .copilot/config/settings.json

# 2. Pull latest context (morning + before work)
git pull

# 3. Work in VS Code
# - Copilot uses .copilot/ (synced from Alice)
# - Gets latest context automatically

# 4. Commit any manual updates (if needed)
git add .copilot/
git commit -m "Update context from VS Code session"
git push
```

**Cursor Developer (Charlie)**:
```bash
# 1. Configure settings.json (in .cursor/)
echo '{"useCursorContext": true, "globalConfigPath": "~/.config/Code/User/prompts"}' \
  > .cursor/config/settings.json

# 2. Pull latest from git
git pull

# 3. Work in Cursor
# - Copilot uses .cursor/ (Cursor-native)
# - Also references .copilot/ if needed for compatibility

# 4. Share context via .copilot/ if team asks
cp .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor session (synced to .copilot/)"
git push
```

**Result**: All three IDEs share context via `.copilot/` in git, reference same `.github/prompts/`.

---

### VS Code Only Team

```bash
# Setup (once)
mkdir -p .copilot/config .copilot/context
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Workflow (all developers same)
# 1. Pull latest
git pull

# 2. Work in VS Code
# - Edit .copilot/ directly if needed
# - Copilot uses same chatmodes as everyone

# 3. Commit changes
git add .copilot/
git commit -m "Update context"
git push
```

**Result**: Unified workflow, minimal coordination.

---

### Cursor Only Team

```bash
# Setup (once)
mkdir -p .cursor/config .cursor/context
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/

# Workflow (all developers same)
# 1. Pull latest (if shared via .copilot/)
git pull
cp .copilot/context/* .cursor/context/ 2>/dev/null || true

# 2. Work in Cursor
# - Use .cursor/ directly
# - Copilot uses same chatmodes as everyone

# 3. Commit changes
cp .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor"
git push
```

**Result**: Cursor-native context with git sharing via `.copilot/`.

---

### Visual Studio Only Team

```bash
# Setup (once)
mkdir -p .copilot/config .copilot/context
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/

# Workflow (all developers same)
# 1. Configure: useContextVS: true

# 2. Work in Visual Studio
# - Uses .vs/ (native, optimal)
# - Auto-syncs to .copilot/

# 3. Commit synced context
git add .copilot/
git commit -m "Backup context from Visual Studio"
git push
```

**Result**: VS-native performance with git backup.

---

## IDE-Specific Considerations

### Visual Studio

✅ **Advantages**:
- Native `.vs/` context (optimal performance)
- Auto-sync to `.copilot/` (automatic)
- Large enterprise teams can share via `.copilot/`

⚠️ **Cautions**:
- `.vs/` directory is local-only (don't commit)
- Manual edits to `.copilot/` will be overwritten
- Set `useContextVS: true` for best results

---

### VS Code

✅ **Advantages**:
- Direct `.copilot/` editing (no auto-sync)
- Safe to modify context manually
- Can receive synced context from VS users

⚠️ **Cautions**:
- Set `useContextVS: false` to avoid confusion
- Pull updates from Visual Studio users regularly

---

### Cursor

✅ **Advantages**:
- Native `.cursor/` context (Cursor-exclusive)
- Independent from other IDEs
- Same chatmodes as all IDEs

⚠️ **Cautions**:
- May also read from `.copilot/` for compatibility
- Share context via `.copilot/` for team coordination

---

### GitHub Copilot CLI

✅ **Advantages**:
- Same setup as VS Code
- Headless operation (no IDE needed)
- Can reference same `.copilot/` context

⚠️ **Cautions**:
- Set `useContextVS: false` (CLI can't access `.vs/`)
- Use `.copilot/` for all CLI operations

---

## Global Configuration (Same for All IDEs)

Regardless of IDE, all projects reference:

```
.github/prompts/
├── chatmodes/              (identical for all IDEs)
├── agents/                 (identical for all IDEs)
├── instructions/           (identical for all IDEs)
├── prompts/                (identical for all IDEs)
├── schemas/                (identical for all IDEs)
├── scripts/               (identical for all IDEs)
└── templates/              (project initialization)
```

**Key Point**: NO IDE-specific customization in global config. All IDEs use the same chatmodes and agents.

---

## Troubleshooting

### Issue: Wrong IDE detected

**Symptoms**: Visual Studio user sees `.copilot/` being used instead of `.vs/`

**Solution**:
1. Check `.copilot/config/settings.json` has `"useContextVS": true`
2. Verify `.vs/` directory exists and has content
3. Restart IDE
4. Check Copilot extension version

---

### Issue: Cursor not detecting context

**Symptoms**: Cursor seems to have no memory

**Solution**:
1. Check `.cursor/` directory exists
2. Verify `.cursor/config/settings.json` is configured
3. Try copying from `.copilot/` if needed
4. Restart Cursor

---

### Issue: Team context not syncing

**Symptoms**: VS users commit to `.copilot/`, but VS Code users don't see updates

**Solution**:
1. Verify VS user has `"useContextVS": true`
2. Confirm `.copilot/` is committed (not in `.gitignore`)
3. VS Code user must `git pull` to get latest
4. Check `.copilot/` directory is readable

---

## Summary Table

| IDE | Context Dir | Config | Priority | Sync |
|-----|------------|--------|----------|------|
| VS Code | `.copilot/` | `useContextVS: false` | Direct | Via git |
| Cursor | `.cursor/` | `useCursorContext: true` | Native | Via git or manual |
| Visual Studio | `.vs/` | `useContextVS: true` | Primary | Auto to `.copilot/` |
| Copilot CLI | `.copilot/` | `useContextVS: false` | Direct | Via git |

**All IDEs use** `.github/prompts/` for chatmodes, agents, instructions.

---

## Related Documentation

- [vscode.instructions.md](./vscode.instructions.md) - VS Code specific tips
- [cursor.instructions.md](./cursor.instructions.md) - Cursor specific tips
- [visual-studio.instructions.md](./visual-studio.instructions.md) - Visual Studio specific tips
- [copilot-instructions.md](./copilot-instructions.md) - GitHub Copilot CLI tips
- [../../copilot-instructions.md](../../copilot-instructions.md) - Master documentation

---

**Version**: 2.1.0 | **Last Updated**: 2025-10-21 | **Status**: ✅ Production Ready for All IDEs
