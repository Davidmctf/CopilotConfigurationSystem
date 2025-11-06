---
applyTo: "**AGENTS.md**"
description: "Defines the architecture and reference rules for agent profiles."
---

# Agent Architecture Reference

## Design Principles

### 1. No Circular References

**Rule**: An agent that extends or inherits from another agent **cannot reference its parent or siblings**.

```plaintext
✗ INVALID HIERARCHY
orchestratorAgent extends baseAgent
├─ baseAgent can NOT reference orchestratorAgent
├─ baseAgent can NOT reference defaultAgent
└─ This creates circular dependency

✓ VALID HIERARCHY
defaultAgent (root, self-contained)
├─ baseAgent (configuration profile only)
└─ orchestratorAgent (extends baseAgent, never referenced upward)
```

### 2. Self-Contained Skills

The **defaultAgent** (Copilot Skill) is completely self-contained:

- ✅ Contains all runtime logic
- ✅ Contains all initialization code
- ✅ Contains all execution capabilities
- ❌ Does NOT reference child agents
- ❌ Does NOT import from baseAgent or orchestratorAgent

### 3. Specialized Profiles as Documentation

baseAgent and orchestratorAgent exist as **configuration profiles**, not as referenced components:

- They document specific capabilities
- They are reference documents
- They are NOT imported or loaded by defaultAgent
- They exist in separate directories for organization only

---

## Agent Hierarchy

```
defaultAgent (v2.1.0)
│
├─ Self-Contained Skill
│  ├─ Runtime detection (Windows/Linux/macOS)
│  ├─ Shell detection (PowerShell/Bash)
│  ├─ Command execution
│  ├─ File operations
│  └─ Process management
│
├─ baseAgent/ (Reference Only)
│  └─ Documents baseline capabilities
│     (NOT auto-loaded, NOT referenced by defaultAgent)
│
└─ orchestratorAgent/ (Reference Only)
   └─ Documents multi-agent coordination patterns
      (NOT auto-loaded, NOT referenced by defaultAgent)
```

---

## Reference Rules

### ✅ Valid References

1. **defaultAgent → External Services/APIs**
   - VSCode APIs
   - Copilot APIs
   - System commands

2. **defaultAgent → Specialized Skills** (if available)
   - Can delegate to other Copilot Skills
   - Must be explicit delegation, not implicit import

3. **Documentation References**
   - baseAgent can reference defaultAgent (as parent)
   - orchestratorAgent can reference baseAgent (as parent)

### ❌ Invalid References

1. **Child → Parent References**
   ```
   ✗ baseAgent references defaultAgent (parent)
   ✗ orchestratorAgent references baseAgent (parent)
   ✗ orchestratorAgent references defaultAgent (ancestor)
   ```

2. **Circular References**
   ```
   ✗ defaultAgent → baseAgent → defaultAgent
   ✗ Any agent that creates a loop
   ```

3. **Internal File Imports**
   ```
   ✗ defaultAgent imports from ./baseAgent/AGENTS.md
   ✗ baseAgent imports from ./orchestratorAgent/AGENTS.md
   ✗ Using @agents/baseAgent in defaultAgent
   ```

---

## Implementation Guidelines

### For New Agents/Profiles

1. **Determine Type**
   - **Skill**: Standalone Copilot capability → Implement in defaultAgent
   - **Profile**: Configuration documentation → Create as separate agent profile

2. **If Creating New Profile**
   - Create new directory: `./newProfile/AGENTS.md`
   - Only reference existing parents (not children)
   - Never reference defaultAgent or siblings

3. **If Extending an Agent**
   - Use `extends: parentAgent` in frontmatter
   - Add specialized capabilities
   - Never reference back to parent

### For Modifying Existing Agents

1. **Before adding imports**
   - Check if it would create upward reference
   - Check if it would create circular reference
   - If yes → integrate functionality instead

2. **Integration Pattern**
   - Move referenced code inline
   - Add inline comments referencing source
   - Example:
     ```yaml
     # This implementation is adapted from baseAgent/AGENTS.md
     # See lines 50-75 for original pattern
     ```

---

## Architecture Decision: Why No Circular References?

### Problem Context Loading

When defaultAgent references baseAgent, and baseAgent references orchestratorAgent:

```
defaultAgent loads AGENTS.md
  ↓
  Copilot reads @agents/baseAgent reference
  ↓
  baseAgent/AGENTS.md loads
  ↓
  baseAgent references @agents/orchestratorAgent
  ↓
  orchestratorAgent/AGENTS.md loads (extends baseAgent)
  ↓
  Circle: orchestratorAgent extends baseAgent, causing re-load?
  ↓
  Context window consumed, execution stalls
```

### Solution: Self-Contained defaultAgent

```
defaultAgent loads AGENTS.md
  ↓
  All logic integrated inline
  ↓
  No external @agent references
  ↓
  baseAgent and orchestratorAgent loaded only when:
    - Explicitly requested by documentation
    - User runs comparison analysis
    - Debugging capability differences
  ↓
  Clean context, no loops
```

---

## Specialized Profiles: When and How to Use

### baseAgent Profile

**Location**: `./baseAgent/AGENTS.md`

**Purpose**:
- Reference documentation for base capabilities
- Defines baseline execution pattern
- Shows foundational error handling

**How to Access**:
- View for documentation: `cat ./baseAgent/AGENTS.md`
- Reference in comments: `# See baseAgent/AGENTS.md:50 for error pattern`
- Not referenced by defaultAgent code

**Extends**: None (base profile)

### orchestratorAgent Profile

**Location**: `./orchestratorAgent/AGENTS.md`

**Purpose**:
- Reference documentation for multi-agent coordination
- Documents orchestration patterns
- Shows advanced error aggregation

**How to Access**:
- View for documentation: `cat ./orchestratorAgent/AGENTS.md`
- Reference in comments when multi-agent coordination needed
- Not referenced by defaultAgent code

**Extends**: baseAgent (configuration reference only)

---

## Testing the Architecture

### No Circular References Test

```bash
# This should NOT cause context overflow
cat agents/AGENTS.md | wc -l  # Should be under 300 lines

# baseAgent should be independent
grep -c "@agents/orchestrator" agents/baseAgent/AGENTS.md  # Should be 0

# orchestratorAgent should NOT reference upward
grep -c "@agents/baseAgent" agents/orchestratorAgent/AGENTS.md  # Should be 0 (only extends in yaml)

# defaultAgent should NOT import other agents
grep -c "@agents/" agents/AGENTS.md  # Should be 0
```

---

## Migration Checklist

If migrating from old architecture to this pattern:

- [ ] defaultAgent is self-contained (no @agents/ references)
- [ ] baseAgent documents base capabilities only
- [ ] orchestratorAgent documents orchestration patterns only
- [ ] No child agents reference parents
- [ ] Runtime detection is integrated into defaultAgent
- [ ] Script functions are inline, not referenced
- [ ] Context usage is under 100KB for typical operations
- [ ] All functionality works without loading child agents

---

## Version History

### v2.1.0 (2025-11-05)
- Integrated runtime detection into defaultAgent
- Removed circular references
- Made baseAgent and orchestratorAgent reference-only profiles
- Established architectural rules

### v2.0.0 (2025-10-16)
- Initial agent profiles with extends pattern
- Introduced orchestratorAgent
- Documentation of lazy loading (not fully implemented)

---

**Maintained By**: System  
**Last Updated**: 2025-11-05  
**Status**: Active
