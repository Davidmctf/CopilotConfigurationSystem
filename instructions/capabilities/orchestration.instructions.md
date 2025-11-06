---
applyTo: '**'
description: 'High-level request orchestration, routing, and execution planning aligned with v2.0 dual-mode architecture'
capability: orchestration
version: 2.0.0
category: coordination
dependencies:
  core:
    - safety
    - communication
    - error-handling
  capabilities:
    - context-awareness
  optional:
    - tool-usage
    - multi-agent-coordination
    - workflow-optimization
platform: agnostic
composable: true
changelog:
  v2.0.0: "Simplified for v2.0 architecture. Removed verbose request analysis. Added chatmode integration guidance."
---

# Orchestration Capability

## Overview

The **Orchestration** capability provides the core orchestration logic for the v2.0.0 dual-mode architecture. It enables request analysis, task decomposition, routing, and execution planning.

### Core Responsibilities (Simplified for v2.0)

1. **Parse Request**: Understand intent and complexity
2. **Decompose**: Break into manageable tasks (if needed)
3. **Route**: Dispatch to appropriate agents/capabilities
4. **Coordinate**: Manage dependencies and execution order
5. **Aggregate**: Combine results into cohesive output

### v2.0 Architecture Context

```yaml
Chatmodes (Human-facing):
  - Use orchestration for planning
  - Perform critical analysis
  - Present results to human

Agents (Silent executors):
  - Receive commands via ACP
  - Execute technical work
  - Return structured JSON

Orchestration Role:
  - Bridge between chatmodes and agents
  - Used BY chatmodes (not standalone)
  - Provides routing and coordination logic
```

### Distinction from Related Capabilities

- **Orchestration**: Decides WHAT to do and WHO does it
- **Multi-Agent Coordination**: Handles HOW agents communicate (ACP protocol)
- **Workflow Optimization**: Makes execution MORE EFFICIENT

## Simplified Orchestration Flow (v2.0)

### 5-Step Process

```yaml
1. PARSE:
   - What does user want?
   - Single task or multiple?
   - Simple or complex?

2. DECOMPOSE (if needed):
   - Break into subtasks
   - Identify dependencies
   - Determine execution order

3. ROUTE:
   - Which agent/capability for each task?
   - Match task to specialization

4. COORDINATE:
   - Execute tasks (sequential/parallel)
   - Handle dependencies
   - Track progress

5. AGGREGATE:
   - Combine results
   - Format for human consumption
   - Return cohesive response
```

### Complexity Assessment (Simplified)

```yaml
Simple:
  Characteristics: Single action, no dependencies
  Approach: Direct execution
  Example: "Fix this bug"

Medium:
  Characteristics: 2-5 steps, some dependencies
  Approach: Sequential execution
  Example: "Refactor module X"

Complex:
  Characteristics: 5+ steps, multiple dependencies
  Approach: Phased execution
  Example: "Implement authentication system"
```

### Task Decomposition Patterns

```yaml
decomposition_strategies:
  horizontal:
    description: "Split into parallel independent tasks"
    use_when: "Tasks have no dependencies"
    example: "Analyze multiple files simultaneously"
  
  vertical:
    description: "Split into sequential dependent tasks"
    use_when: "Tasks build on each other"
    example: "Design → Implement → Test"
  
  hierarchical:
    description: "Split into nested sub-tasks"
    use_when: "Complex multi-level problems"
    example: "Feature → Modules → Functions → Tests"
  
  hybrid:
    description: "Combination of patterns"
    use_when: "Complex real-world scenarios"
    example: "Parallel analysis, sequential implementation"
```

## Integration with v2.0 Chatmodes

### How Chatmodes Use Orchestration

```yaml
quick-assistant (focused profile):
  orchestration_use: Minimal
  pattern: Direct execution for simple tasks
  example: "Fix bug" → parse → execute → return

research-assistant (exploratory profile):
  orchestration_use: Moderate
  pattern: Coordinate research across multiple sources
  example: "Research X" → decompose topics → gather → synthesize

agent-orchestrator (collaborative profile):
  orchestration_use: Heavy
  pattern: Complex multi-agent coordination
  example: "Implement feature" → design → route to agents → aggregate
```

### Chatmode-Specific Behaviors

**Quick Assistant**:
- Minimal orchestration overhead
- Direct execution when possible
- Quick validation before dispatch

**Research Assistant**:
- Orchestrates information gathering
- Coordinates multiple research tasks
- Synthesizes findings

**Agent Orchestrator**:
- Full orchestration capabilities
- Multi-agent coordination
- Critical analysis and refutation
- Phased execution

## Orchestration Rules (Simplified v2.0)

### Core Rules

```yaml
Rule 1: Parse Before Act
  - Understand request first
  - Assess complexity
  - Never skip analysis

Rule 2: Don't Over-Decompose
  - Simple tasks stay simple
  - Decompose only when beneficial
  - Balance granularity vs overhead

Rule 3: Route Intelligently
  - Match task to agent capability
  - Consider agent specialization
  - Use direct execution when possible

Rule 4: Aggregate Coherently
  - Combine results logically
  - Format for human readability
  - Maintain context
```

### Agent Selection (Simplified)

```yaml
Match Task → Agent Capability:

Code tasks → fullstack-processor
Architecture → architecture-validator
Database → database-architect
Multiple → orchestratorAgent (coordinates)

Selection logic:
  1. Identify task type
  2. Match to agent specialization
  3. Dispatch via ACP
  4. Receive structured JSON response
```

### Execution Patterns (Simplified)

```yaml
Sequential:
  When: Tasks depend on each other
  Pattern: A → B → C
  Example: Design → Implement → Test

Parallel:
  When: Tasks are independent
  Pattern: [A, B, C] simultaneously
  Example: Analyze 3 files at once

Phased:
  When: Complex with multiple stages
  Pattern: Phase1 → Phase2 → Phase3
  Example: Research → Decide → Implement
```

## Practical Examples (v2.0)

### Example 1: Simple (Direct Execution)

```yaml
Request: "Fix null pointer in UserService"

Orchestration:
  1. Parse: Simple bug fix
  2. Decompose: Not needed (single task)
  3. Route: fullstack-processor
  4. Execute: Agent fixes bug
  5. Aggregate: Return fixed code

Output: Fixed code with explanation
```

### Example 2: Medium (Sequential)

```yaml
Request: "Refactor authentication module"

Orchestration:
  1. Parse: Medium complexity refactoring
  2. Decompose:
     - Analyze current code
     - Identify improvements
     - Apply refactoring
     - Validate changes
  3. Route: fullstack-processor (sequential)
  4. Execute: Each step in order
  5. Aggregate: Refactored module + summary

Output: Refactored code with change report
```

### Example 3: Complex (Phased + Multi-Agent)

```yaml
Request: "Implement payment processing system"

Orchestration:
  1. Parse: Complex feature implementation
  2. Decompose:
     Phase 1: Design
       - Architecture design (architecture-validator)
       - Database schema (database-architect)
     Phase 2: Implementation
       - API endpoints (fullstack-processor)
       - Payment service (fullstack-processor)
     Phase 3: Validation
       - Security review (architecture-validator)
       - Testing (fullstack-processor)
  3. Route: Multiple agents, phased
  4. Execute: Phase by phase with checkpoints
  5. Aggregate: Complete system + documentation

Output: Full implementation with test coverage
```

## Best Practices (v2.0)

### DO (Enhanced for v2.0)
- ✅ **Let chatmodes handle human interaction** (agents are silent)
- ✅ Parse requests before routing
- ✅ Use direct execution for simple tasks
- ✅ Decompose only when beneficial
- ✅ Match tasks to agent specialization
- ✅ Return structured JSON from agents
- ✅ Aggregate coherently for humans

### DON'T
- ❌ **Make agents verbose** (they execute silently)
- ❌ Over-decompose simple requests
- ❌ Skip complexity assessment
- ❌ Route without understanding task type
- ❌ Ignore agent capabilities
- ❌ Return raw agent output to users (format it first)

---

## Version History

### v2.0.0 (2025-10-16)
- **Simplified for v2.0 dual-mode architecture**
- Removed verbose request analysis framework
- Added chatmode integration guidance
- Simplified orchestration flow to 5 steps
- Added practical v2.0 examples
- Emphasized agent silence (JSON output only)
- Clarified orchestration is used BY chatmodes
- Reduced from 734 lines to ~320 lines (56% reduction)

### v1.0.0 (2025-10-15)
- Initial comprehensive orchestration capability
- Detailed request analysis framework
- Extensive pattern catalog
- Complex routing strategies

---

**Capability Status**: Production Ready
**Version**: 2.0.0
**Composition**: Core + Context-Awareness
**Optional Enhancement**: Multi-Agent Coordination, Workflow Optimization
**Platform**: Agnostic
**Last Updated**: 2025-10-16
