---

description: 'Instructions for integrating the global Copilot configuration system with different IDEs (Visual Studio Enterprise and VS Code).'
applyTo: '**'

---

# IDE Integration Instructions

## Overview

This directory contains instructions for integrating the global Copilot configuration system (`.github/prompts/`) with different IDEs. The system supports seamless collaboration between Visual Studio Enterprise and VS Code users.

---

## 📚 Available Instructions

### [multi-ide.instructions.md](./multi-ide.instructions.md)
**Universal multi-IDE support instructions**

- How the `useContextVS` flag controls IDE behavior
- Context priority and mapping between `.vs/` and `.copilot/`
- Workflows for mixed teams (VS + VS Code)
- Best practices for each IDE
- Implementation details and pseudo-code

**Use this for**: Understanding the overall architecture and how different IDEs work together.

---

### [visual-studio.instructions.md](./visual-studio.instructions.md)
**Visual Studio Enterprise/Professional integration**

- Setup with `useContextVS: true`
- Using `.vs/` directory as primary context
- Automatic sync to `.copilot/` for team collaboration
- Context lifecycle during development sessions
- File structure documentation
- Troubleshooting Visual Studio-specific issues

**Use this for**: Setting up and using the system in Visual Studio Enterprise/Professional.

---

### [vscode.instructions.md](./vscode.instructions.md)
**VS Code integration**

- Setup with `useContextVS: false` (default)
- Using `.copilot/` directory exclusively
- Working with synced context from Visual Studio users
- VS Code-specific workflows and best practices
- Troubleshooting VS Code issues
- Performance optimization

**Use this for**: Setting up and using the system in VS Code.

---

## 🎯 Quick Start by IDE

### I'm using Visual Studio Enterprise

1. Read: [visual-studio.instructions.md](./visual-studio.instructions.md)
2. Copy template:
   ```bash
   cp .github/prompts/templates/visualstudio/settings-visualstudio.template.json \
      .copilot/config/settings.json
   ```
3. Configure sync (optional):
   ```bash
   cp .github/prompts/templates/visualstudio/vs-mapping.template.json \
      .copilot/sync/vs-mapping.json
   # Edit variables in vs-mapping.json
   ```
4. Open Visual Studio and start working

**Key setting**: `useContextVS: true` in settings.json

---

### I'm using VS Code

1. Read: [vscode.instructions.md](./vscode.instructions.md)
2. Copy template:
   ```bash
   cp .github/prompts/templates/local-project/settings.template.json \
      .copilot/config/settings.json
   ```
3. Open VS Code and start working

**Key setting**: `useContextVS: false` (or omit) in settings.json

---

### I'm on a mixed team (some VS, some VS Code)

1. Read: [multi-ide.instructions.md](./multi-ide.instructions.md)
2. **Visual Studio users**:
   - Set `useContextVS: true`
   - Sync to `.copilot/` automatically
   - Commit `.copilot/` after sessions
3. **VS Code users**:
   - Set `useContextVS: false`
   - Pull latest `.copilot/` before working
   - Benefit from VS users' rich context

**Key concept**: `.copilot/` directory is the shared context across all IDEs.

---

## 🏗️ Architecture Overview

### Tri-Level System

```
LEVEL 1: GLOBAL
.github/prompts/
├── chatmodes/          # Shared across all IDEs
├── agents/             # Shared across all IDEs
├── instructions/       # This directory
├── schemas/            # Validation schemas
└── scripts/           # Shared scripts
   ↓ (referenced by)

LEVEL 2: IDE-SPECIFIC
Visual Studio: .vs/              (primary for VS users)
VS Code:       .copilot/         (primary for VS Code users)
   ↓ (syncs to)

LEVEL 3: SHARED
.copilot/
├── config/             # Settings with useContextVS flag
├── context/            # Project and active context
├── .context-history/   # May contain synced indices
└── sync/               # Sync configuration (VS only)
```

### Context Flow

**Visual Studio Enterprise**:
```
Developer works in VS
     ↓
.vs/ directory updated (native, fast)
     ↓
Copilot detects useContextVS: true
     ↓
Auto-sync .vs/ → .copilot/
     ↓
Commit .copilot/ to git
     ↓
VS Code team members get updates
```

**VS Code**:
```
Developer works in VS Code
     ↓
.copilot/ directory updated directly
(or reads synced content from .copilot/)
     ↓
Copilot uses .copilot/ as only source
     ↓
Commit .copilot/ to git (optional)
     ↓
Team members get updates
```

---

## 🔑 Key Concepts

### useContextVS Flag

The `useContextVS` flag in `settings.json` controls IDE behavior:

```json
{
  "history": {
    "retention": {
      "useContextVS": true  // or false
    }
  }
}
```

| Value | IDE | Behavior |
|-------|-----|----------|
| `true` | Visual Studio | Uses `.vs/` as primary, syncs to `.copilot/` |
| `false` | VS Code | Uses `.copilot/` exclusively |

**Location**: Defined in `.github/prompts/schemas/settings.schema.json` (lines 188-192)

---

### Context Mapping

Visual Studio → Copilot sync mappings:

| Visual Studio Source | Copilot Target | Content |
|---------------------|----------------|---------|
| `.vs/{project}/CopilotIndices/` | `.copilot/.context-history/CopilotIndices/` | Code & semantic indices |
| `.vs/{solution}.slnx/FileContentIndex/` | `.copilot/context/FileContentIndex/` | File content indices |
| `.vs/{solution}.slnx/v18/` | `.copilot/context/v18/` | Session state |
| `.vs/VSWorkspaceState.json` | `.copilot/workspace-state.json` | Workspace state |

**Configuration**: `.copilot/sync/vs-mapping.json` (Visual Studio only)

---

### Global References

All IDEs reference `.github/prompts/` for:

- ✅ Chatmodes (analysis layer)
- ✅ Agents (execution layer)
- ✅ Instructions (this directory)
- ✅ Schemas (validation)
- ✅ Toolsets (shared tools)

**Only difference between IDEs**: Where local context comes from (`.vs/` vs `.copilot/`)

---

## 📖 Documentation Structure

```
.github/prompts/instructions/ide-integration/
├── copilot-instructions.md             # ← You are here (IDE integration overview)
├── multi-ide.instructions.md           # Universal multi-IDE guide
├── visual-studio.instructions.md       # Visual Studio specific
└── vscode.instructions.md              # VS Code specific
```

---

## 🔗 Related Documentation

### Templates
- [Visual Studio Templates](../../templates/visualstudio/) - Settings and sync configuration for Visual Studio
- [Local Project Templates](../../templates/local-project/) - Settings for VS Code

### Main Documentation
- [Integration Guide](../../INTEGRATION_GUIDE.instructions.md) - Complete integration documentation
- [Master Documentation](../../copilot-instructions.md) - Overall system documentation

### Schemas
- [Settings Schema](../../schemas/settings.schema.json) - Validation schema for settings.json
- [Context Schema](../../schemas/context.schema.json) - Validation schema for context files

---

## ❓ Common Questions

### Q: Can I use Visual Studio Community edition?

**A**: This system is designed for Visual Studio Enterprise/Professional which have the `.vs/` directory structure with CopilotIndices. Community edition may not have all features.

For Community edition:
- Use VS Code configuration instead (`useContextVS: false`)
- You'll still benefit from all global features in `.github/prompts/`

---

### Q: What if I switch between IDEs?

**A**: You can switch freely:

1. **Visual Studio → VS Code**:
   - Your `.vs/` context is synced to `.copilot/`
   - VS Code reads from `.copilot/` automatically
   - No action needed

2. **VS Code → Visual Studio**:
   - Change `useContextVS: false` to `true` in settings.json
   - Visual Studio will use `.vs/` as primary
   - Your `.copilot/` becomes backup/sync target

---

### Q: Do I need both .vs/ and .copilot/?

**A**: Depends on your IDE:

- **Visual Studio**: You have both (`.vs/` is primary, `.copilot/` is sync target)
- **VS Code**: You only have `.copilot/`

**Important**:
- `.vs/` is in `.gitignore` (local only, never committed)
- `.copilot/` is in git (shared with team)

---

### Q: What if my team uses only VS Code?

**A**: Perfect! Simple setup:

1. Everyone uses `useContextVS: false` (default)
2. Everyone edits `.copilot/` directly
3. Standard git workflow for sharing
4. No need for `.vs/` or sync configuration

---

### Q: What if my team uses only Visual Studio?

**A**: Also simple:

1. Everyone uses `useContextVS: true`
2. Everyone uses `.vs/` as primary (optimal performance)
3. Everyone syncs to `.copilot/` for backup
4. (Optional) Commit `.copilot/` for team backup

---

### Q: How do I know if sync is working? (Visual Studio)

**A**: Check these indicators:

1. **Files exist in .copilot/**:
   ```bash
   ls -la .copilot/.context-history/CopilotIndices/
   ```

2. **Recent timestamps**:
   ```bash
   ls -lt .copilot/.context-history/CopilotIndices/
   ```

3. **Git shows changes**:
   ```bash
   git status .copilot/
   ```

If no files appear, check:
- `useContextVS: true` in settings
- `.copilot/sync/vs-mapping.json` exists
- Variables in mapping file are correct

---

## 🐛 Troubleshooting

### Issue: Don't know which IDE configuration to use

**Symptoms**: Confused about `useContextVS` setting

**Solution**:
- **Using Visual Studio Enterprise/Professional**: Set `useContextVS: true`
- **Using VS Code**: Set `useContextVS: false` or omit
- **Using Visual Studio Community**: Use VS Code configuration (`false`)

---

### Issue: Context not working in either IDE

**Symptoms**: Copilot has no context in any IDE

**Solutions**:
1. Verify `.copilot/config/settings.json` exists
2. Check that `.github/prompts/` directory exists
3. Verify global config is accessible:
   ```bash
   ls -la .github/prompts/chatmodes/
   ```
4. Check logs for errors
5. Restart IDE

---

### Issue: Mixed team context conflicts

**Symptoms**: Git conflicts in `.copilot/` directory

**Solutions**:
1. Establish clear workflow:
   - VS users: Commit after sessions
   - VS Code users: Pull before sessions
2. VS context always wins (has richer data):
   ```bash
   git checkout --theirs .copilot/
   ```
3. Avoid concurrent edits
4. Consider using git LFS for large context files

---

## 📝 Version History

- **v1.0** (2025-10-17): Initial release with Visual Studio Enterprise and VS Code support

---

**Status**: ✅ Production Ready | **Last Updated**: 2025-10-17
