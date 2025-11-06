---
applyTo: '**'
description: 'Behavioral profiles defining communication and interaction styles for agents.'
---
# Behavioral Profiles

This directory contains **behavioral profiles** - reusable communication and interaction patterns that can be composed with agents and capabilities to create complete chatmode experiences.

## Overview

Profiles define **how** an agent communicates and interacts, not **what** capabilities it has. They are platform-agnostic, composable modules that follow the agnostic-cop architecture principles.

## Available Profiles

### 1. **focused.profile.md**
**Purpose**: Direct, action-oriented communication for specific tasks and quick solutions.

**Characteristics**:
- Minimal verbosity
- Immediate action
- Concise explanations
- Optimized for speed

**Best For**:
- Bug fixes and debugging
- Quick implementations
- Direct questions
- Time-sensitive tasks
- Production issues

**Example Use**:
```yaml
chatmode:
  profile: focused
  agent: baseAgent
  capabilities: [code-assistance, tool-usage]
```

---

### 2. **collaborative.profile.md**
**Purpose**: Exploratory, discussion-oriented behavior for complex decisions and design.

**Characteristics**:
- Multi-perspective analysis
- Explicit trade-offs
- Structured debate
- Assumption challenging

**Best For**:
- Architectural decisions
- Design discussions
- Complex problem solving
- Strategic planning
- Technology evaluation

**Example Use**:
```yaml
chatmode:
  profile: collaborative
  agent: orchestratorAgent
  capabilities: [orchestration, multi-agent-coordination]
```

---

### 3. **exploratory.profile.md**
**Purpose**: Investigative, comprehensive behavior for research and detailed analysis.

**Characteristics**:
- Exhaustive coverage
- Multi-option evaluation
- Detailed comparisons
- Comprehensive resources

**Best For**:
- Technology research
- Comparative analysis
- Learning and knowledge building
- Due diligence
- Strategic research

**Example Use**:
```yaml
chatmode:
  profile: exploratory
  agent: researchAgent
  capabilities: [context-awareness]
```

---

## Profile Selection Guide

### Quick Decision Tree

```
What's your need?

├─ Need quick answer/fix?
│  └─ Use: focused
│
├─ Need to make decision?
│  ├─ Simple decision → focused
│  └─ Complex decision → collaborative
│
└─ Need to learn/research?
   ├─ Basic understanding → collaborative
   └─ Deep research → exploratory
```

### Comparison Matrix

| Aspect | Focused | Collaborative | Exploratory |
|--------|---------|---------------|-------------|
| **Verbosity** | Low | Moderate | High |
| **Detail Level** | Minimal | Comprehensive | Exhaustive |
| **Options Presented** | 1 | 2-3 | 5-10 |
| **Analysis Depth** | Shallow | Deep | Very Deep |
| **Response Time** | Fast | Moderate | Slow |
| **Token Usage** | Low | Moderate | High |
| **Best For** | Implementation | Decision | Research |

### When to Use Each Profile

**Use `focused` when:**
- ✅ You know what you want
- ✅ You need it done quickly
- ✅ The solution is straightforward
- ✅ Time is critical
- ✅ You want minimal explanation

**Use `collaborative` when:**
- ✅ Multiple viable options exist
- ✅ Trade-offs need evaluation
- ✅ Long-term implications matter
- ✅ Team decision required
- ✅ Design/architecture involved

**Use `exploratory` when:**
- ✅ You're learning something new
- ✅ Many options need evaluation
- ✅ Comprehensive understanding needed
- ✅ Making strategic decisions
- ✅ Researching technologies

## Profile Composition

Profiles are designed to be **composed** with agents and capabilities:

```yaml
# Example: Quick Assistant
chatmode:
  id: quick-assistant
  profile: focused              # Communication style
  agent: baseAgent              # Who executes
  capabilities:                 # What they can do
    - code-assistance
    - tool-usage
```

```yaml
# Example: Architecture Advisor
chatmode:
  id: architect-advisor
  profile: collaborative        # Discussion-oriented
  agent: orchestratorAgent      # Can coordinate
  capabilities:
    - orchestration
    - multi-agent-coordination
    - workflow-optimization
```

```yaml
# Example: Research Assistant
chatmode:
  id: research-assistant
  profile: exploratory          # Comprehensive analysis
  agent: baseAgent
  capabilities:
    - context-awareness
    - code-assistance           # For examples
```

## Profile Structure

Each profile follows a consistent structure:

```markdown
---
id: profile-id
version: 1.0.0
type: profile
description: Brief description
applyTo: agents
provides: [capabilities this profile provides]
requires: [optional dependencies]
---

# Profile Name

## Overview
High-level description and purpose

## Behavior Characteristics
### Communication Style
### Response Format
### Detail Level
### Interaction Patterns

## When to Use This Profile
### Ideal Scenarios
### Avoid This Profile For

## Key Principles
Core behavioral principles

## Response Templates
Template examples

## Examples
Concrete usage examples

## Integration
How to compose with agents/capabilities

## Behavioral Rules
DO and DON'T lists

## Performance Characteristics
Token usage, response time, etc.

## Quality Metrics
What makes a good response
```

## Design Principles

### 1. Single Responsibility
Each profile has ONE communication style and behavioral pattern.

### 2. Composability
Profiles can be freely combined with any compatible agent and capabilities.

### 3. Zero Duplication
Profiles don't duplicate agent or capability content - they reference them.

### 4. Platform Agnostic
Profiles work with any LLM or platform that supports the agnostic-cop architecture.

### 5. Explicit Over Implicit
All behaviors, patterns, and integration points are clearly documented.

## Usage Examples

### Example 1: Bug Fix Workflow

**Scenario**: Production bug needs immediate fix

**Profile Choice**: `focused`

**Reasoning**:
- Time-sensitive ✓
- Clear problem ✓
- Need quick solution ✓
- Minimal explanation needed ✓

**Composition**:
```yaml
chatmode:
  profile: focused
  agent: baseAgent
  capabilities: [code-assistance, tool-usage]
```

---

### Example 2: Architecture Decision

**Scenario**: Choosing between microservices vs monolith

**Profile Choice**: `collaborative`

**Reasoning**:
- Multiple options ✓
- Complex trade-offs ✓
- Long-term implications ✓
- Team decision ✓

**Composition**:
```yaml
chatmode:
  profile: collaborative
  agent: orchestratorAgent
  capabilities:
    - orchestration
    - multi-agent-coordination
    - context-awareness
```

---

### Example 3: Technology Evaluation

**Scenario**: Research state management libraries for React

**Profile Choice**: `exploratory`

**Reasoning**:
- Many options to evaluate ✓
- Need comprehensive comparison ✓
- Learning involved ✓
- Strategic decision ✓

**Composition**:
```yaml
chatmode:
  profile: exploratory
  agent: baseAgent
  capabilities: [context-awareness]
```

---

### Example 4: Progressive Workflow

**Scenario**: Complete project from research to implementation

**Profile Progression**:
1. **Start**: `exploratory` - Research options
2. **Middle**: `collaborative` - Decide on approach
3. **End**: `focused` - Implement solution

This shows profiles can change as the task evolves!

## Integration Guidelines

### With Agents

**Agent Compatibility**:
- `baseAgent`: Works with all profiles
- `orchestratorAgent`: Best with collaborative/exploratory
- Custom agents: Any profile depending on purpose

**Selection Criteria**:
```
If agent needs to coordinate multiple tasks:
  → Consider collaborative or exploratory profile
  
If agent executes specific tasks:
  → Consider focused profile
  
If agent provides strategic advice:
  → Consider collaborative profile
```

### With Capabilities

**Capability Enhancement**:
- Profiles enhance HOW capabilities are used
- Capabilities define WHAT can be done
- Together they create complete behavior

**Example Synergies**:
```
focused + code-assistance = Quick code generation
collaborative + orchestration = Thoughtful task planning
exploratory + context-awareness = Comprehensive analysis
```

## Adding New Profiles

To add a new profile:

1. **Create Profile File**:
   ```bash
   touch chatmodes/profiles/new-profile.profile.md
   ```

2. **Follow Template**:
   - Copy structure from existing profiles
   - Include all required sections
   - Add frontmatter with metadata

3. **Define Unique Behavior**:
   - What makes this profile different?
   - When should it be used?
   - What patterns does it follow?

4. **Document Integration**:
   - Which agents work best?
   - Which capabilities enhance it?
   - Provide examples

5. **Update This README**:
   - Add to available profiles list
   - Update comparison matrix
   - Add usage examples

## Versioning

Profiles use semantic versioning:

```yaml
---
version: 1.0.0
---

Major: Breaking behavioral changes
Minor: New features, backwards compatible
Patch: Bug fixes, clarifications
```

## Validation

Each profile should:
- ✅ Have valid YAML frontmatter
- ✅ Include all required sections
- ✅ Provide concrete examples
- ✅ Document integration patterns
- ✅ Follow agnostic-cop principles
- ✅ Be platform-agnostic
- ✅ Have clear DO/DON'T rules
- ✅ Define quality metrics

## Related Documentation

- **Agents**: [`../agents/` - Who executes the profile](../../agents/)
- **Capabilities**: [`../instructions/capabilities/` - What can be done](../../instructions/capabilities/)
- **Chatmodes**: [`../chatmodes/*.chatmode.md` - Complete compositions](../)
- **Schemas**: [`../schemas/` - Validation schemas](../../schemas/)

## Questions?

For profile-related questions:
1. Check the profile's own documentation
2. Review integration examples
3. See chatmode compositions that use it
4. Refer to agnostic-cop principles in main docs

---

**Last Updated**: 2025-10-15  
**Profiles**: 3 (focused, collaborative, exploratory)  
**Status**: Production Ready ✅
