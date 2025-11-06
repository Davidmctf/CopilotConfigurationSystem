---
mode: agent
description: 'Base Agent Profile - Reference documentation for core execution capabilities'
id: baseAgent
version: 2.1.0
type: agent-profile
status: stable
communication_mode: agent_executor
extends: none
reference_only: true
---

# Base Agent Profile (Reference)

## Overview

The Base Agent Profile documents **core execution capabilities** used by defaultAgent. This is a **reference profile** - it is not loaded as a separate agent. Use this document to understand the baseline execution patterns and error handling strategies.

**Important**: This profile is documentation only. The actual implementation is integrated into `defaultAgent/AGENTS.md`.

## Purpose

- Document baseline execution patterns
- Show foundational error handling strategies
- Provide reference for capability requirements
- Guide specialized agent development

## Communication Mode

**Mode**: Agent Executor (Mode 2)

**Behavioral Characteristics**:
- Execute structured commands silently
- Report progress via checkpoints
- Return structured results (JSON/tables)
- No conversational narratives
- No external agent references
- Input validation before execution
- Graceful error handling with recovery options

## Execution Patterns

### Silent Step-by-Step Pattern

```json
{
  "status": "executing",
  "checkpoints": [
    "✓ validation passed",
    "✓ environment detected",
    "→ executing command"
  ]
}
```

```json
{
  "status": "completed",
  "output": {
    "files_modified": 5,
    "duration_ms": 1234,
    "errors": 0
  }
}
```

### Error Handling Pattern

```json
{
  "status": "error",
  "error_code": "FILE_NOT_FOUND",
  "details": {
    "file": "config.json",
    "searched_paths": [
      "/workspace/config.json",
      "/home/user/config.json"
    ]
  },
  "recovery_options": [
    {
      "action": "create_default",
      "params": {"template": "config.default.json"}
    },
    {
      "action": "use_alternative",
      "params": {"file": "config.backup.json"}
    }
  ]
}
```

## Core Capabilities

### File Operations

- Read files (text, binary, large files)
- Write files (create, overwrite, append)
- Modify files (targeted edits, regex replacements)
- Delete files (with confirmation)
- List directories (recursive, filtered)

### Command Execution

- Execute system commands
- Capture output and error streams
- Monitor process execution
- Handle timeouts gracefully
- Retry failed commands

### Process Management

- Start and stop processes
- Monitor process health
- Log process output
- Handle process crashes

### Context Management

- Monitor context window usage
- Prevent context overflow
- Load capabilities on demand
- Clean up unused resources

### Safety Features

- Input validation (command injection prevention)
- Path validation (directory traversal prevention)
- Operation confirmation for destructive actions
- Sensitive data masking in logs
- Resource limits enforcement

## Limitations

- **Single-threaded**: Max 1 concurrent task
- **Timeout**: 30 seconds per operation
- **Retry**: 3 attempts with exponential backoff
- **Scope**: Basic file and command operations
- **Context**: 100KB limit per operation

## Error Codes

| Code | Meaning | Recovery |
|------|---------|----------|
| `FILE_NOT_FOUND` | File doesn't exist | Create or use alternative |
| `PERMISSION_DENIED` | No access rights | Check permissions or elevate |
| `INVALID_COMMAND` | Command not recognized | Check syntax or use alternative |
| `TIMEOUT` | Operation exceeded time limit | Retry or break into smaller steps |
| `CONTEXT_OVERFLOW` | Context window full | Clean up and retry |

## Configuration Reference

### Environment Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `AGENT_INITIALIZED` | boolean | Whether agent is ready |
| `AGENT_SHELL` | string | Detected shell (bash/pwsh) |
| `AGENT_PLATFORM` | string | Platform (Windows/Linux/macOS) |
| `OPERATION_TIMEOUT` | integer | Timeout in milliseconds |

### Execution Limits

```yaml
max_concurrent_tasks: 1
timeout_ms: 30000
retry_attempts: 3
retry_backoff_multiplier: 2
context_limit_bytes: 102400
```

## Usage Examples

### Example 1: Simple File Read

**Input**:
```json
{
  "command": "read_file",
  "params": {
    "path": "src/config.json"
  }
}
```

**Output**:
```json
{
  "status": "completed",
  "content": "{ ... }",
  "size_bytes": 1024,
  "encoding": "utf-8"
}
```

### Example 2: File Creation with Validation

**Input**:
```json
{
  "command": "write_file",
  "params": {
    "path": "output/result.txt",
    "content": "Result data",
    "mode": "create"
  }
}
```

**Output**:
```json
{
  "status": "completed",
  "file": "output/result.txt",
  "bytes_written": 11,
  "created": true
}
```

### Example 3: Command Execution with Error Handling

**Input**:
```json
{
  "command": "execute",
  "params": {
    "cmd": "npm test",
    "cwd": "./project",
    "timeout_ms": 30000
  }
}
```

**Output on Success**:
```json
{
  "status": "completed",
  "exit_code": 0,
  "stdout": "All tests passed",
  "duration_ms": 5000
}
```

**Output on Error**:
```json
{
  "status": "error",
  "error_code": "COMMAND_FAILED",
  "exit_code": 1,
  "stderr": "Test failed at line 42",
  "recovery_options": [
    {
      "action": "retry",
      "params": {"attempts_remaining": 2}
    },
    {
      "action": "debug",
      "params": {"run_with_verbose": true}
    }
  ]
}
```

## Integration Points

### Used By

- **defaultAgent** - Integrates all base capabilities
- Specialized agents that extend base patterns

### Extends

- None (base profile)

### Extended By

- orchestratorAgent (adds coordination capabilities)

## Architectural Notes

### Single Responsibility

This profile focuses exclusively on **execution and error handling**. Capabilities like orchestration, planning, or analysis are handled by specialized profiles.

### No Upward References

This profile does **not reference**:
- defaultAgent (parent)
- orchestratorAgent (sibling)
- External agents or skills

This prevents circular dependencies and context bloat.

### For New Profiles

When extending or creating new profiles:
1. Start with this base pattern
2. Add specialized capabilities
3. Never reference back to parent
4. Document extensions clearly

## Version History

### v2.1.0 (2025-11-05)
- Marked as reference-only profile
- Removed all external agent references
- Updated to align with new architecture
- Clarified limitations and error codes

### v2.0.0 (2025-10-16)
- Transitioned to Agent Executor mode
- Removed conversational patterns
- Implemented structured JSON communication

### v1.0.0 (2025-10-15)
- Initial stable release
- Core capabilities implemented

## References

**Architecture**: See `../copilot-instructions.md` for design principles  
**Implementation**: See `../AGENTS.md` for actual implementation  
**Examples**: See `../orchestratorAgent/AGENTS.md` for advanced patterns

---

**Type**: Reference Profile  
**Status**: Documentation ✅  
**Extends**: None  
**Last Updated**: 2025-11-05  
**Maintained By**: System  
**Note**: This is documentation. Implementation is in defaultAgent.
