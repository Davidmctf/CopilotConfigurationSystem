---

description: 'Setup guide - Installation & configuration for all IDEs'
applyTo: '**'
version: 2.1.0

---

# Getting Started - Setup (v2.1.0)

**Version**: 2.1.0 | **IDEs**: VS Code • Cursor • Visual Studio • GitHub Copilot CLI
**Time to Setup**: ~15 minutes | **Status**: ✅ Production Ready

Installation and configuration steps. For architecture, chatmodes, and usage patterns, see **[copilot-instructions.md](./copilot-instructions.md)**.

---

## 🚀 Quick Start (5 minutes)

### 1. Install Global Configuration

```bash
# All IDEs use the same config
git clone https://github.com/your-repo/copilot-config.git ~/.config/Code/User/prompts

# Alternative: use .github/prompts if git-managed
```

### 2. Initialize Your Project

**VS Code / GitHub Copilot CLI**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/
```

**Cursor**:
```bash
mkdir -p .cursor/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/
```

**Visual Studio**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/
```

### 3. Configure Settings

Edit `.copilot/config/settings.json` (or `.cursor/config/settings.json` for Cursor):

```json
{
  "env": {
    "globalConfigPath": "~/.config/Code/User/prompts"
  },
  "project": {
    "name": "my-project",
    "version": "1.0.0"
  },
  "ideDetection": {
    "enabled": true
  },
  "model": {
    "default": "copilot/claude-sonnet-4.5",
    "fallback": "copilot/claude-haiku-4.5"
  }
}
```

### 4. Start Using Copilot

Open your project in your IDE. Copilot will automatically:
- Detect your IDE
- Load chatmodes
- Use project-specific context
- Maintain session memory

---

## 🖥️ IDE-Specific Setup

### Visual Studio Enterprise

**Config**: `useContextVS: true`

**Setup**:
```bash
cp .github/prompts/templates/visualstudio/settings-visualstudio.template.json \
   .copilot/config/settings.json

# Verify useContextVS: true in settings.json
```

**Behavior**:
- Uses native `.vs/` for optimal performance
- Auto-syncs to `.copilot/` for team sharing
- Same chatmodes as all IDEs

---

### VS Code

**Config**: `useContextVS: false` (or omit)

**Setup**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp .github/prompts/templates/local-project/* .copilot/
```

**Behavior**:
- Uses `.copilot/` directly
- Safe to edit manually
- Can receive synced context from VS users

---

### Cursor

**Config**: `useCursorContext: true` (or auto-detected)

**Setup**:
```bash
mkdir -p .cursor/{config,context,.context-history/sessions}
cp .github/prompts/templates/local-project/* .cursor/
# Update paths to use .cursor/ instead of .copilot/
```

**Behavior**:
- Uses `.cursor/` exclusively
- Independent from `.copilot/` and `.vs/`
- Can optionally sync to `.copilot/` for team sharing

---

### GitHub Copilot CLI

**Config**: Automatic (same as VS Code)

**Setup**:
```bash
mkdir -p .copilot/{config,context,.context-history/sessions}
cp .github/prompts/templates/local-project/* .copilot/
```

**Behavior**:
- Uses `.copilot/` (same as VS Code)
- CLI-driven context management

---

## 👥 Team Workflows

### Mixed Team: Visual Studio + VS Code + Cursor

**All developers - Setup (one-time)**:
```bash
# 1. Clone global config
git clone https://github.com/your-repo/copilot-config.git ~/.config/Code/User/prompts

# 2. Initialize project with IDE-specific templates
cd my-project

# Visual Studio developers
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/

# VS Code developers
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Cursor developers
mkdir -p .cursor/{config,context}
cp ~/.config/Code/User/prompts/templates/local-project/* .cursor/
```

**Daily Workflow**:

Visual Studio Developer:
```bash
# Configure: useContextVS: true
# Work in Visual Studio
# Context auto-syncs to .copilot/
git add .copilot/
git commit -m "Update context from VS session"
git push
```

VS Code Developer:
```bash
git pull                    # Get latest
# Work in VS Code with synced context
git add .copilot/
git commit -m "Update context from VS Code session"
git push
```

Cursor Developer:
```bash
git pull                    # Get latest
# Work in Cursor
cp .cursor/context/* .copilot/context/ 2>/dev/null || true
git add .copilot/
git commit -m "Update context from Cursor session"
git push
```

---

### VS Code Only Team

```bash
# Setup (once)
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/local-project/* .copilot/

# Daily workflow
git pull
# Work in VS Code
git add .copilot/
git commit -m "Update context"
git push
```

---

### Visual Studio Only Team

```bash
# Setup (once)
mkdir -p .copilot/{config,context}
cp ~/.config/Code/User/prompts/templates/visualstudio/* .copilot/

# Daily workflow
# Configure: useContextVS: true
# Work in Visual Studio
git add .copilot/
git commit -m "Update context from VS session"
git push
```

---

## 🔧 Troubleshooting

### Problem: "Schema not found"

**Error**: Cannot find schema at `${globalConfigPath}/schemas/context.schema.json`

**Solution**:
```bash
# Verify path exists
ls ~/.config/Code/User/prompts/schemas/context.schema.json

# Check settings.json
cat .copilot/config/settings.json | grep globalConfigPath

# Fix path if needed
vim .copilot/config/settings.json
```

---

### Problem: "Agent not found"

**Error**: Cannot load agent 'baseAgent'

**Solution**:
```bash
# Verify agent exists
ls ~/.config/Code/User/prompts/agents/baseAgent/

# Check settings.json
cat .copilot/config/settings.json | grep defaultAgent
```

---

### Problem: Wrong IDE detected

**Symptoms**: Visual Studio user sees `.copilot/` used instead of `.vs/`

**Solution**:
1. Verify `useContextVS: true` in `.copilot/config/settings.json`
2. Verify `.vs/` directory exists
3. Restart IDE
4. Check Copilot extension is latest

---

### Problem: Cursor context not detected

**Symptoms**: Cursor has no memory

**Solution**:
1. Verify `.cursor/` directory exists
2. Check `.cursor/config/settings.json` is configured
3. Try copying from `.copilot/` if needed
4. Restart Cursor

---

### Problem: Team context not syncing

**Symptoms**: VS user commits context, but VS Code users don't see updates

**Solution**:
1. Verify VS user has `useContextVS: true`
2. Confirm `.copilot/` is NOT in `.gitignore`
3. VS Code user must `git pull` before work
4. Check `.copilot/` permissions

---

## ✅ Validation Checklist

- [ ] Global config cloned: `~/.config/Code/User/prompts/`
- [ ] Project initialized: `.copilot/` or `.cursor/` or `.vs/` exists
- [ ] Settings configured: `globalConfigPath` is correct
- [ ] IDE-specific settings: `useContextVS`, `useCursorContext`, etc. set
- [ ] Model configured: `copilot/claude-sonnet-4.5` or `copilot/claude-haiku-4.5`

---

## 📚 Next Steps

**For architecture, chatmodes, and usage**: See **[copilot-instructions.md](./copilot-instructions.md)**

**For practical examples & decision trees**: See **[USER_GUIDE.instructions.md](./USER_GUIDE.instructions.md)**

---

**Version**: 2.1.0 | **Last Updated**: 2025-11-05 | **Status**: ✅ Production Ready
