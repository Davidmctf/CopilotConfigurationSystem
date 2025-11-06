---

description: 'Templates for integrating Copilot with Visual Studio Enterprise projects using global configuration.'
applyTo: '**'

---

# Visual Studio Enterprise Templates

Templates for integrating the global Copilot configuration system with Visual Studio Enterprise projects.

## 📋 Overview

These templates enable Visual Studio Enterprise to use the global configuration in `.github/prompts/` while maintaining compatibility with VS Code team members.

### Key Feature: `useContextVS` Flag

The `useContextVS: true` flag in settings tells Copilot to:
1. **Priority**: Use `.vs/` directory as primary context source
2. **Sync**: Automatically sync to `.copilot/` for VS Code users
3. **Global**: Reference `.github/prompts/` for chatmodes, agents, instructions

---

## 🚀 Quick Start

### Step 1: Copy Settings Template

```bash
# Create .copilot/config directory if it doesn't exist
mkdir -p .copilot/config

# Copy Visual Studio template
cp .github/prompts/templates/visualstudio/settings-visualstudio.template.json \
   .copilot/config/settings.json
```

### Step 2: Copy Sync Mapping (Optional but Recommended)

```bash
# Create .copilot/sync directory
mkdir -p .copilot/sync

# Copy sync mapping template
cp .github/prompts/templates/visualstudio/vs-mapping.template.json \
   .copilot/sync/vs-mapping.json
```

### Step 3: Update Variables

Edit `.copilot/sync/vs-mapping.json` and update the `variables` section:

```json
{
  "variables": {
    "projectName": "YourProjectName",        // ← Update
    "solutionName": "YourSolution.slnx",     // ← Update
    "vsVersion": "18.0.877.25981"            // ← Usually OK as-is
  }
}
```

### Step 4: Verify Setup

1. Open Visual Studio
2. Open your project
3. Copilot should now:
   - ✅ Use `.vs/` as primary context
   - ✅ Sync to `.copilot/` automatically
   - ✅ Reference `.github/prompts/` for global config

---

## 📁 Files

| File | Purpose | Copy To |
|------|---------|---------|
| `settings-visualstudio.template.json` | Settings with `useContextVS: true` | `.copilot/config/settings.json` |
| `vs-mapping.template.json` | Mapping of `.vs/` to `.copilot/` | `.copilot/sync/vs-mapping.json` |
| `copilot-instructions.md` | This file | (reference only) |

---

## 🏗️ How It Works

### Architecture

```
LEVEL 1: GLOBAL
.github/prompts/ (chatmodes, agents, instructions)
   ↓ (referenced by)

LEVEL 2: IDE-SPECIFIC
.vs/ (Visual Studio - Primary)
   ↓ (syncs to)

LEVEL 3: SHARED
.copilot/ (For VS Code team members)
```

### Context Priority

When `useContextVS: true`:

```javascript
// Copilot's context resolution
if (useContextVS === true) {
  // 1. Try .vs/ first (Visual Studio native)
  if (exists(".vs/YourProject/CopilotIndices/")) {
    return ".vs/YourProject/CopilotIndices/";
  }
  // 2. Fallback to .copilot/
  return ".copilot/.context-history/CopilotIndices/";
} else {
  // VS Code: only use .copilot/
  return ".copilot/.context-history/CopilotIndices/";
}
```

### Sync Flow

```
Visual Studio Session
   ↓
.vs/ directory updated
   ↓
Copilot detects useContextVS: true
   ↓
Reads vs-mapping.json
   ↓
Syncs .vs/ → .copilot/
   ↓
.copilot/ committed to git
   ↓
VS Code users get updates
```

---

## ⚠️ Important Notes

### For Visual Studio Users

- ✅ **DO** set `useContextVS: true` in settings
- ✅ **DO** commit `.copilot/` to git (synced for team)
- ⚠️ **DON'T** edit `.copilot/` manually (will be overwritten)
- ⚠️ **DON'T** commit `.vs/` to git (local only)

### For VS Code Users (on mixed teams)

- ✅ **DO** use `.copilot/` directly
- ✅ **DO** set `useContextVS: false` or omit it
- ✅ **DO** pull latest `.copilot/` from git
- ℹ️ **NOTE**: You get synced context from VS users automatically

---

## 📊 Comparison: VS Code vs Visual Studio

| Feature | VS Code | Visual Studio Enterprise |
|---------|---------|-------------------------|
| Primary Context | `.copilot/` | `.vs/` |
| useContextVS | `false` (default) | `true` |
| Sync | Not needed | Auto `.vs/` → `.copilot/` |
| Team Sharing | Via `.copilot/` in git | Via `.copilot/` in git |
| Global Config | `.github/prompts/` | `.github/prompts/` |

---

## 🔗 Documentation

For more details:

- **Multi-IDE Instructions**: [../../instructions/ide-integration/multi-ide.instructions.md](../../instructions/ide-integration/multi-ide.instructions.md)
- **Visual Studio Integration**: [../../instructions/ide-integration/visual-studio.instructions.md](../../instructions/ide-integration/visual-studio.instructions.md)
- **Integration Guide**: [../../INTEGRATION_GUIDE.instructions.md](../../INTEGRATION_GUIDE.instructions.md#multi-ide-support)
- **Master Documentation**: [../../copilot-instructions.md](../../copilot-instructions.md)

---

## ❓ Troubleshooting

### Copilot not using .vs/ context

**Check**:
1. `settings.json` has `useContextVS: true`
2. `.vs/` directory exists
3. Restart Visual Studio

### Sync not working

**Check**:
1. `.copilot/sync/vs-mapping.json` exists
2. Variables are correct (projectName, solutionName)
3. `.copilot/` directory is writable

### VS Code users not getting updates

**Check**:
1. `.copilot/` is committed to git
2. VS Code users have pulled latest
3. Their settings have `useContextVS: false`

---

**Version**: 1.0 | **Last Updated**: 2025-10-17 | **Status**: ✅ Production Ready
