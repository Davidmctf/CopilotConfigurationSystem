---
applyTo: '**'
description: 'Comprehensive guide to available chatmodes, their purposes, compositions, and usage patterns.'
---
# Chatmodes

This directory contains **chatmode definitions** - complete compositions that combine profiles, agents, and capabilities to create specific user experiences.

## Overview

Chatmodes are the **complete configuration** for how the system behaves. They compose:
- **Profile** (how to communicate)
- **Agent** (who executes)
- **Capabilities** (what can be done)
- **Context Read/Write** (how much context to use with each interactionfor optimal performance in any project)

Think of chatmodes as "presets" or "modes" that configure the entire system for specific use cases.

---

## Available Chatmodes

### 1. **agent-orchestrator.chatmode.md**
**Purpose**: Complex workflows and strategic execution

**Composition**:
```yaml
profile: collaborative
agent: orchestratorAgent
capabilities:
  - orchestration
  - multi-agent-coordination
  - workflow-optimization
  - context-awareness
```

**Best For**:
- Complex multi-step projects
- Strategic technical decisions
- Coordinated multi-agent workflows
- Comprehensive analysis and planning
- Optimization projects

**Characteristics**:
- **Verbosity**: High (thorough analysis)
- **Planning**: Maximum (strategic approach)
- **Coordination**: Excellent (multi-agent)
- **Speed**: Moderate to slow (quality over speed)

**Example Use**:
```
"Initialize a production-ready full-stack app with CI/CD"
"Decide between microservices vs monolith for our use case"
"Debug and fix performance issue across the application"
```

---

### 2. **quick-assistant.chatmode.md**
**Purpose**: Fast, everyday development assistance

**Composition**:
```yaml
profile: focused
agent: baseAgent
capabilities:
  - code-assistance
  - tool-usage
  - context-awareness
```

**Best For**:
- Daily development tasks
- Bug fixes
- Quick implementations
- Syntax questions
- Command help

**Characteristics**:
- **Verbosity**: Low (concise)
- **Planning**: Minimal (action-first)
- **Coordination**: Not applicable
- **Speed**: Fast (optimized for speed)

**Example Use**:
```
"Fix this null pointer exception"
"Add email validation to form"
"Git command to revert last commit"
```

---

### 3. **research-assistant.chatmode.md**
**Purpose**: Comprehensive research and analysis

**Composition**:
```yaml
profile: exploratory
agent: baseAgent
capabilities:
  - context-awareness
  - code-assistance
```

**Best For**:
- Technology evaluation
- Learning deep dives
- Comparative analysis
- Strategic research
- Due diligence

**Characteristics**:
- **Verbosity**: Very high (comprehensive)
- **Planning**: N/A (information gathering)
- **Coordination**: Not applicable
- **Speed**: Slow (thorough research)

**Example Use**:
```
"Research authentication solutions for B2B SaaS"
"Compare state management libraries for React"
"Explain microservices architecture in depth"
```

---

## Chatmode Selection Guide

### All chatmodes are designed to work together. Choose based on your current need context with project complexity, time sensitivity, and desired output depth.:

- **${workspaceFolder}/.copilot/** : can set default chatmode and preferences.

### Quick Decision Tree

```
What do you need?

├─ Quick answer or fix?
│  └─ Use: quick-assistant
│
├─ Need to learn or research?
│  └─ Use: research-assistant
│
└─ Complex task or decision?
   └─ Use: agent-orchestrator
```

### Detailed Decision Matrix

| Your Need | Best Chatmode | Why |
|-----------|---------------|-----|
| Fix bug | quick-assistant | Fast, direct solution |
| Add feature | quick-assistant | Straightforward implementation |
| Syntax question | quick-assistant | Quick answer |
| Research options | research-assistant | Comprehensive analysis |
| Learn concept | research-assistant | Deep understanding |
| Compare technologies | research-assistant | Detailed comparison |
| Complex refactoring | agent-orchestrator | Multi-step planning |
| Architecture decision | agent-orchestrator | Strategic thinking |
| Multi-service task | agent-orchestrator | Coordination needed |

---

## Progressive Workflow Pattern

For complex projects, use chatmodes progressively:

```
Phase 1: RESEARCH (research-assistant)
Task: "Research authentication solutions"
Output: Comprehensive analysis of all options

↓

Phase 2: DECIDE (agent-orchestrator)
Task: "Decide between Auth0 and Keycloak based on research"
Output: Well-reasoned decision with plan

↓

Phase 3: IMPLEMENT (quick-assistant)
Task: "Implement Auth0 integration"
Output: Working implementation
```

This pattern maximizes the strengths of each chatmode.

---

## Chatmode Structure

Each chatmode follows this structure:

```markdown
---
[YAML Frontmatter]
id: chatmode-id
version: 1.0.0
name: Display Name
description: Brief description
profile: profile-reference
agent: agent-reference
capabilities:
  - capability-1
  - capability-2
applyTo: use-case-category
---

# Chatmode Name

## Overview
What this chatmode is for

## Composition
How it's composed (profile + agent + capabilities)

## Use Cases
When to use this chatmode

## Typical Workflows
Common usage patterns

## Examples
Concrete examples

## When to Use / When NOT to Use
Clear guidance

## Switching Chatmodes
When to change modes

## Integration
How it works with ecosystem

## Performance Characteristics
Speed, verbosity, etc.

## Configuration
How to configure

## Best Practices
Usage recommendations

## Limitations
What it can't do

## Quality Metrics
Success criteria

## Summary
Quick reference
```

---

## Comparison Matrix

| Aspect | quick-assistant | agent-orchestrator | research-assistant |
|--------|----------------|-------------------|-------------------|
| **Profile** | focused | collaborative | exploratory |
| **Agent** | baseAgent | orchestratorAgent | baseAgent |
| **Capabilities** | 3 | 4 | 2 |
| **Response Time** | Fast | Moderate-Slow | Slow |
| **Token Usage** | Low | High | Very High |
| **Verbosity** | Minimal | High | Very High |
| **Planning Depth** | None | Maximum | N/A |
| **Research Depth** | None | Moderate | Maximum |
| **Coordination** | No | Yes | No |
| **Best For** | Implementation | Planning & Execution | Research |
| **Typical Output** | <150 words + code | 500-2000 words | 2000-4000 words |

---

## When to Use Each Chatmode

### Use `quick-assistant` (70% of tasks):
- ✅ You know what you want
- ✅ It's a standard task
- ✅ You need it fast
- ✅ It's straightforward
- ✅ You're coding/implementing

### Use `agent-orchestrator` (20% of tasks):
- ✅ Task is complex
- ✅ Multiple steps involved
- ✅ Need planning
- ✅ Making decisions
- ✅ Coordinating multiple things

### Use `research-assistant` (10% of tasks):
- ✅ Learning something new
- ✅ Evaluating options
- ✅ Need comprehensive understanding
- ✅ Making strategic decisions
- ✅ Researching technologies

---

## Integration Patterns

### Pattern 1: Independent Usage

```
User uses one chatmode for complete task:
- quick-assistant: "Fix bug" → Fixed
- research-assistant: "Research X" → Report
- agent-orchestrator: "Build feature" → Complete
```

### Pattern 2: Sequential Progression

```
research-assistant → agent-orchestrator → quick-assistant

Research → Decision → Implementation
```

### Pattern 3: Dynamic Switching

```
Start: quick-assistant ("Fix login")
Discover: Complex issue
Switch: agent-orchestrator (plan comprehensive fix)
Implement: quick-assistant (execute plan)
```

### Pattern 4: Escalation

```
quick-assistant attempts task
Recognizes complexity
Recommends: agent-orchestrator
User accepts switch
```

---

## Creating New Chatmodes

To create a new chatmode:

### 1. Identify Need
```
What specific use case isn't well-served?
What unique combination would help?
```

### 2. Choose Components
```yaml
profile: [focused | collaborative | exploratory]
agent: [baseAgent | orchestratorAgent | custom]
capabilities: [list of required capabilities]
```

### 3. Create File
```bash
touch chatmodes/new-chatmode.chatmode.md
```

### 4. Follow Template
- Include YAML frontmatter
- Document composition
- Provide examples
- Specify use cases
- Define when to use/avoid

### 5. Validate
- ✅ References valid profile
- ✅ References valid agent
- ✅ Lists existing capabilities
- ✅ Follows structure
- ✅ Provides examples

### 6. Update This README
- Add to available chatmodes
- Update comparison matrix
- Add usage examples

---

## Advanced Concepts

### Chatmode Switching

Chatmodes can recommend switching when appropriate:

```python
# Pseudo-code for switching logic
if task_complexity > chatmode_capability:
    recommend_switch(to=more_capable_chatmode)
    
if task_simplified and using_complex_chatmode:
    recommend_switch(to=simpler_chatmode)
    
if need_research_before_decision:
    recommend_switch(to=research_assistant)
```

### Context Preservation

When switching chatmodes:
- ✅ Context is preserved
- ✅ Previous work referenced
- ✅ Smooth transition
- ✅ User informed of switch

### Chatmode Memory

Chatmodes can learn:
- Frequently used patterns
- User preferences
- Common workflows
- Optimization opportunities

---

## Best Practices

### 1. Choose the Right Tool

Don't use a sledgehammer for a thumbtack:
```
❌ agent-orchestrator for "fix typo"
✅ quick-assistant for "fix typo"

❌ quick-assistant for "design architecture"
✅ agent-orchestrator for "design architecture"
```

### 2. Let Chatmodes Guide You

Trust chatmode recommendations:
```
If quick-assistant says "this is complex, let me escalate"
→ Let it switch to agent-orchestrator

If agent-orchestrator says "let me research first"
→ Let it use research-assistant pattern
```

### 3. Understand Trade-offs

Each chatmode trades something:
```
quick-assistant: Speed ↔ Depth
agent-orchestrator: Thoroughness ↔ Speed
research-assistant: Comprehensiveness ↔ Brevity
```

### 4. Use Progressive Patterns

For big projects, go through phases:
```
1. Research (research-assistant)
2. Decide (agent-orchestrator)
3. Implement (quick-assistant)
```

---

## Configuration

### Project-Level Configuration

```json
// .copilot/config/settings.json
{
  "defaultChatmode": "quick-assistant",
  "chatmodes": {
    "quick-assistant": {
      "enabled": true,
      "shortcuts": ["qa", "quick"]
    },
    "agent-orchestrator": {
      "enabled": true,
      "shortcuts": ["ao", "orchestrate"]
    },
    "research-assistant": {
      "enabled": true,
      "shortcuts": ["ra", "research"]
    }
  }
}
```

### User Preferences

```json
{
  "chatmodePreferences": {
    "autoSwitch": true,
    "verbosityPreference": "balanced",
    "defaultMode": "quick-assistant"
  }
}
```

---

## Troubleshooting

### "Chatmode giving too much detail"

**Problem**: Getting long responses when you want quick answers  
**Solution**: Use `quick-assistant` instead of others

### "Not enough planning"

**Problem**: Tasks failing because of lack of planning  
**Solution**: Use `agent-orchestrator` for complex tasks

### "Need more options evaluated"

**Problem**: Only seeing 1-2 options, need more  
**Solution**: Use `research-assistant` for comprehensive analysis

### "Switching too often"

**Problem**: Chatmodes switching frequently  
**Solution**: Choose appropriate chatmode from start

---

## Performance Tips

### Optimize Token Usage

```
For 10 small tasks: quick-assistant (10 interactions)
Better than: agent-orchestrator (1 interaction planning all 10)
```

### Optimize Response Time

```
For urgent fix: quick-assistant (immediate)
Avoid: research-assistant (slow, thorough)
```

### Optimize Quality

```
For critical decision: agent-orchestrator (thorough)
Avoid: quick-assistant (quick, less thorough)
```

---

## Related Documentation

- [**Profiles**: `profiles/` - Behavioral patterns](./profiles/)
- [**Agents**: `../agents/` - Execution entities](../agents/)
- [**Capabilities**: `../instructions/capabilities/` - Functional modules](../instructions/capabilities/)
- [**Schemas**: `../schemas/` - Validation schemas](../schemas/)

---

## Summary

**Chatmodes** are complete system configurations that combine:
- Profiles (communication style)
- Agents (execution)
- Capabilities (functionality)

**Three chatmodes available**:
1. **quick-assistant** - Fast, everyday tasks (70% usage)
2. **agent-orchestrator** - Complex workflows (20% usage)
3. **research-assistant** - Comprehensive research (10% usage)

**Choose based on**:
- Task complexity
- Need for planning
- Need for research
- Time sensitivity
- Desired output depth

**Remember**: You can switch chatmodes mid-task as needs evolve!

---

**Last Updated**: 2025-10-15  
**Chatmodes**: 3 (quick-assistant, agent-orchestrator, research-assistant)  
**Status**: Production Ready ✅
