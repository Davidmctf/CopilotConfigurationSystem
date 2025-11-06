---
mode: agent
description: 'Orchestrator Agent Profile - Reference documentation for multi-agent coordination'
id: orchestratorAgent
version: 2.1.0
type: agent-profile
status: stable
extends: baseAgent
extends_purpose: documentation_reference
communication_mode: agent_coordinator
reference_only: true
---

# Orchestrator Agent Profile (Reference)

## Overview

The Orchestrator Agent Profile documents **multi-agent coordination capabilities**. This is a **reference profile** - it is not loaded as a separate agent. Use this document to understand coordination patterns, workflow orchestration, and error aggregation strategies.

**Important**: This profile is documentation only. For actual implementation, refer to `defaultAgent/AGENTS.md`.

## Purpose

- Document multi-agent coordination patterns
- Show workflow orchestration strategies
- Provide error aggregation patterns
- Guide complex task decomposition

## Design Philosophy

This profile **references baseAgent for documentation only**:
- Shows how base capabilities are composed
- Documents coordination on top of execution patterns
- Never loads or imports baseAgent code
- Exists as reference architecture

## Communication Mode

**Mode**: Agent Coordinator (Mode 2)

**Coordination Characteristics**:
- Receive execution plans (not analyze them)
- Dispatch commands to specialized components
- Monitor execution status
- Aggregate results into unified output
- Handle errors technically (no user prompts)

## Execution Patterns

### Structured Coordination Pattern

```json
{
  "execution_plan": {
    "mode": "mixed",
    "phases": [
      {
        "name": "preparation",
        "mode": "serial",
        "tasks": [
          {"task": "validate_schema", "component": "validator"}
        ]
      },
      {
        "name": "processing",
        "mode": "parallel",
        "tasks": [
          {"task": "process_data", "component": "processor"},
          {"task": "generate_report", "component": "reporter"}
        ]
      }
    ]
  }
}
```

### Coordination Checkpoints

```json
{
  "status": "executing",
  "current_phase": "processing",
  "checkpoints": [
    "✓ preparation completed (1.2s)",
    "→ processor: 65% complete",
    "→ reporter: 80% complete"
  ]
}
```

### Result Aggregation

```json
{
  "status": "completed",
  "execution_summary": {
    "total_phases": 2,
    "total_components_used": 3,
    "total_duration_ms": 4520,
    "success_rate": 1.0
  },
  "phase_results": [
    {
      "phase": "preparation",
      "component": "validator",
      "status": "completed",
      "output": {"validation": "passed"}
    },
    {
      "phase": "processing",
      "components": [
        {"name": "processor", "status": "completed", "items": 1000},
        {"name": "reporter", "status": "completed", "format": "pdf"}
      ]
    }
  ]
}
```

### Error Aggregation Pattern

```json
{
  "status": "partial_failure",
  "successful_components": 2,
  "failed_components": 1,
  "errors": [
    {
      "component": "database_component",
      "error_code": "SCHEMA_CONFLICT",
      "details": {
        "table": "users",
        "conflict": "index already exists"
      },
      "blocking": true
    }
  ],
  "recovery_options": [
    {
      "action": "retry_failed_components",
      "components": ["database_component"]
    },
    {
      "action": "rollback_successful",
      "scope": "phase_2"
    },
    {
      "action": "escalate",
      "reason": "manual_intervention_required"
    }
  ]
}
```

## Orchestration Strategies

### 1. Pipeline Pattern

Sequential execution with data flow:

```
Input → Component A → Component B → Component C → Output
```

**Use When**: Clear sequential dependencies, output feeds next step

### 2. Parallel Pattern

Concurrent independent tasks:

```
Input → ┬ Component A ┬
        ├ Component B ┤ → Aggregate → Output
        └ Component C ┘
```

**Use When**: Tasks independent, no shared state, performance critical

### 3. Saga Pattern

Coordinated transactions with compensation:

```
Step 1 → Step 2 → Step 3
  ↓        ↓        ↓
Comp 1 ← Comp 2 ← Comp 3 (on failure)
```

**Use When**: Multiple state changes, rollback required, consistency critical

### 4. Scatter-Gather Pattern

Distribute work and collect results:

```
Input → Scatter → [A, B, C, D] → Gather → Output
```

**Use When**: Same operation on multiple items, parallelization possible

### 5. Event-Driven Pattern

Reactive processing:

```
Event → Handler → Processing → New Events
```

**Use When**: Asynchronous workflows, dynamic task generation

### 6. Hierarchical Pattern

Nested orchestration:

```
Main Orchestrator
├─ Sub-Orchestrator A
│  ├─ Component 1
│  └─ Component 2
└─ Sub-Orchestrator B
   ├─ Component 3
   └─ Component 4
```

**Use When**: Very complex workflows, multiple abstraction levels

## Coordination Capabilities

### Task Decomposition

- Analyze complex requests
- Break into coordinated subtasks
- Map to appropriate components
- Maintain dependency tracking

### Parallel Execution

- Identify independent tasks
- Execute concurrently
- Manage resource allocation
- Aggregate results

### Error Aggregation

- Track failures per component
- Aggregate error information
- Determine impact scope
- Suggest recovery strategies

### State Management

- Track execution progress
- Maintain coordination state
- Handle checkpoints
- Enable resume operations

### Resource Management

- Monitor resource usage
- Enforce resource limits
- Prevent resource exhaustion
- Clean up on completion

## Limitations

- **Component Limit**: Maximum 3 concurrent components
- **Task Limit**: Maximum 5 concurrent tasks
- **Timeout**: 120 seconds (2 minutes)
- **Complexity**: Very complex workflows may need manual decomposition

## Configuration Reference

### Execution Parameters

```yaml
max_concurrent_components: 3
max_concurrent_tasks: 5
timeout_ms: 120000
default_strategy: adaptive
monitoring: enabled
```

### Phase Execution Modes

| Mode | Behavior | Best For |
|------|----------|----------|
| serial | Sequential execution | Dependencies, order critical |
| parallel | Concurrent execution | Independent tasks |
| mixed | Serial and parallel phases | Complex workflows |

## Usage Examples

### Example 1: Multi-Phase Workflow

**Coordination Plan**:
```json
{
  "execution_plan": {
    "mode": "saga",
    "rollback_on_failure": true,
    "phases": [
      {
        "name": "database",
        "mode": "serial",
        "tasks": [{"task": "migrate_schema", "component": "db"}]
      },
      {
        "name": "backend",
        "mode": "serial",
        "tasks": [{"task": "deploy_api", "component": "api"}]
      },
      {
        "name": "frontend",
        "mode": "serial",
        "tasks": [{"task": "deploy_ui", "component": "ui"}]
      }
    ]
  }
}
```

**Execution Output**:
```json
{
  "status": "completed",
  "execution_time_ms": 8420,
  "phases_completed": 3,
  "components_used": 3,
  "results": {
    "database": {
      "files_created": ["migrations/001_schema.sql"],
      "status": "success"
    },
    "backend": {
      "files_modified": ["api.ts"],
      "status": "success"
    },
    "frontend": {
      "files_modified": ["App.tsx"],
      "status": "success"
    }
  }
}
```

### Example 2: Parallel Analysis

**Coordination Plan**:
```json
{
  "execution_plan": {
    "mode": "parallel",
    "components": [
      {"component": "security_auditor", "task": "analyze_security"},
      {"component": "performance_analyzer", "task": "analyze_performance"},
      {"component": "quality_checker", "task": "analyze_quality"}
    ]
  }
}
```

**Execution Progress**:
```json
{
  "status": "executing",
  "progress": {
    "security_auditor": 45,
    "performance_analyzer": 95,
    "quality_checker": 72
  }
}
```

**Results**:
```json
{
  "status": "completed",
  "results": {
    "security": {"critical": 3, "medium": 5, "low": 12},
    "performance": {"optimization_opportunities": 8},
    "quality": {"score": 7.5}
  }
}
```

## Integration Points

### Extends

- **baseAgent** (documentation reference for base capabilities)

### Coordinates

- Any specialized components/agents available in the system
- Maintains coordination through execution plans, not code references

### Design Rules

- ❌ Does NOT reference baseAgent code
- ❌ Does NOT reference defaultAgent
- ❌ Does NOT import other profiles
- ✅ Documents coordination patterns
- ✅ Shows how to decompose complex tasks

## Architectural Notes

### Self-Documenting

This profile documents orchestration without implementing it. The patterns shown here guide how complex tasks should be decomposed.

### No Upward References

Like baseAgent, this profile does not reference:
- defaultAgent (ancestor)
- Other agent profiles (siblings)

This maintains clean architecture and prevents context bloat.

### For Task Decomposition

When facing a complex task, use this profile to:
1. Choose appropriate coordination pattern
2. Decompose into components/phases
3. Map to available agents/skills
4. Define execution sequence
5. Plan error recovery

## Version History

### v2.1.0 (2025-11-05)
- Marked as reference-only profile
- Removed all upward/circular references
- Updated to align with new architecture
- Clarified extends purpose (documentation only)

### v2.0.0 (2025-10-16)
- Transitioned to Agent Coordinator mode
- Removed strategic narratives during execution
- Implemented structured coordination patterns

### v1.0.0 (2025-10-15)
- Initial stable release
- Full orchestration capabilities documented

## References

**Architecture**: See `../copilot-instructions.md` for design principles  
**Base Profile**: See `../baseAgent/AGENTS.md` for base capabilities (reference only)  
**Implementation**: See `../AGENTS.md` for actual skill implementation

---

**Type**: Reference Profile  
**Status**: Documentation ✅  
**Extends**: baseAgent (for documentation reference only)  
**Last Updated**: 2025-11-05  
**Maintained By**: System  
**Note**: This is documentation for coordination patterns. Use baseAgent/defaultAgent profiles for implementation.
