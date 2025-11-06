---

description: 'Agent Communication Protocol (ACP) v2.0 - Standardized communication framework for multi-agent systems'
applyTo: '**'
id: protocol.acp-v2
version: 2.0.0
category: protocol
type: communication_standard
requires: [core.safety, core.communication, core.error-handling]

---

# Agent Communication Protocol (ACP) v2.0

## Purpose

Standardized communication framework for multi-agent systems, enabling efficient and reliable message exchange between agents.

## Protocol Philosophy

```yaml
principles:
  simplicity:
    - Clear message structure
    - Minimal required fields
    - Extensible design
  
  reliability:
    - Idempotent operations
    - Immutable messages
    - Full traceability
  
  safety:
    - Permission validation
    - Audit trails
    - Error recovery
```

## Message Structure

### Core Message Types

#### 1. AgentCommand

```typescript
interface AgentCommand {
  // Message Identity (REQUIRED)
  id: string;                    // Unique command ID
  timestamp: string;             // ISO 8601 timestamp
  version: "2.0";                // Protocol version
  
  // Routing (REQUIRED)
  from: string;                  // Sender agent ID
  to: string;                    // Target agent ID
  priority: Priority;            // low|medium|high|critical
  
  // Command (REQUIRED)
  action: Action;                // What to do
  parameters: Record<string, any>; // Action parameters
  
  // Context (OPTIONAL)
  context?: {
    correlationId?: string;      // For tracking related messages
    timeout?: number;            // Execution timeout (ms)
    retryPolicy?: RetryPolicy;   // How to retry on failure
  };
  
  // Security (OPTIONAL)
  security?: {
    permissions: string[];       // Required permissions
    requireApproval?: boolean;   // Needs human approval
  };
}
```

#### 2. AgentResponse

```typescript
interface AgentResponse {
  // Message Identity (REQUIRED)
  id: string;                    // Unique response ID
  commandId: string;             // Original command ID
  timestamp: string;             // ISO 8601 timestamp
  version: "2.0";                // Protocol version
  
  // Status (REQUIRED)
  from: string;                  // Responding agent ID
  status: Status;                // success|partial|failed|timeout
  
  // Results (REQUIRED)
  results: {
    data?: any;                  // Result data
    artifacts?: Artifact[];      // Created files/outputs
    summary?: string;            // Human-readable summary
  };
  
  // Execution (OPTIONAL)
  execution?: {
    duration: number;            // Execution time (ms)
    tokensUsed?: number;         // Token consumption
  };
  
  // Error (if failed)
  error?: {
    code: string;                // Error code
    message: string;             // Error description
    recoverable: boolean;        // Can retry?
  };
}
```

### Type Definitions

```typescript
type Priority = 'low' | 'medium' | 'high' | 'critical';

type Status = 'success' | 'partial' | 'failed' | 'timeout' | 'cancelled';

type Action = 
  | 'ANALYZE'
  | 'DESIGN'
  | 'IMPLEMENT'
  | 'VALIDATE'
  | 'OPTIMIZE'
  | 'REFACTOR'
  | 'DOCUMENT'
  | 'TEST'
  | 'EXECUTE';

interface RetryPolicy {
  maxAttempts: number;
  backoffMs: number;
}

interface Artifact {
  id: string;
  type: string;
  path: string;
  description: string;
}
```

## Communication Patterns

### 1. Request-Response (Synchronous)

Simple one-to-one communication:

```typescript
// Send command
const command: AgentCommand = {
  id: generateId(),
  timestamp: new Date().toISOString(),
  version: "2.0",
  from: "orchestrator",
  to: "code-agent",
  priority: "medium",
  action: "ANALYZE",
  parameters: {
    file: "src/main.ts",
    checks: ["complexity", "security"]
  }
};

// Receive response
const response: AgentResponse = await send(command);

if (response.status === 'success') {
  console.log(response.results.data);
}
```

### 2. Fire-and-Forget (Asynchronous)

Send without waiting for response:

```typescript
const command: AgentCommand = {
  id: generateId(),
  timestamp: new Date().toISOString(),
  version: "2.0",
  from: "orchestrator",
  to: "logger",
  priority: "low",
  action: "EXECUTE",
  parameters: {
    operation: "log",
    level: "info",
    message: "Task completed"
  },
  context: {
    timeout: 5000
  }
};

// Send and continue
sendAsync(command);
```

### 3. Broadcast (One-to-Many)

Send same message to multiple agents:

```typescript
const agents = ["agent-1", "agent-2", "agent-3"];

const broadcasts = agents.map(agentId => ({
  ...baseCommand,
  id: generateId(),
  to: agentId
}));

// Send to all
const responses = await Promise.all(
  broadcasts.map(cmd => send(cmd))
);

// Aggregate results
const aggregated = aggregateResponses(responses);
```

### 4. Pipeline (Sequential)

Chain agent executions:

```typescript
// Step 1: Design
const designResponse = await send({
  id: generateId(),
  timestamp: new Date().toISOString(),
  version: "2.0",
  from: "orchestrator",
  to: "architect",
  priority: "high",
  action: "DESIGN",
  parameters: {
    requirements: userRequirements
  }
});

// Step 2: Implement (using design results)
const implResponse = await send({
  id: generateId(),
  timestamp: new Date().toISOString(),
  version: "2.0",
  from: "orchestrator",
  to: "coder",
  priority: "high",
  action: "IMPLEMENT",
  parameters: {
    design: designResponse.results.data
  },
  context: {
    correlationId: designResponse.commandId
  }
});

// Step 3: Validate
const validateResponse = await send({
  id: generateId(),
  timestamp: new Date().toISOString(),
  version: "2.0",
  from: "orchestrator",
  to: "validator",
  priority: "high",
  action: "VALIDATE",
  parameters: {
    implementation: implResponse.results.data
  },
  context: {
    correlationId: implResponse.commandId
  }
});
```

### 5. Scatter-Gather (Parallel + Aggregate)

Parallel execution with result aggregation:

```typescript
// Scatter: Send to multiple agents in parallel
const analyses = ['security', 'performance', 'style'].map(type => 
  send({
    id: generateId(),
    timestamp: new Date().toISOString(),
    version: "2.0",
    from: "orchestrator",
    to: `${type}-analyzer`,
    priority: "medium",
    action: "ANALYZE",
    parameters: {
      code: sourceCode,
      type: type
    }
  })
);

// Gather: Collect all results
const results = await Promise.all(analyses);

// Aggregate
const report = {
  security: results[0].results,
  performance: results[1].results,
  style: results[2].results
};
```

## Error Handling

### Error Categories

```typescript
enum ErrorCategory {
  USER_ERROR = "user_error",           // Invalid input
  AGENT_ERROR = "agent_error",         // Agent failure
  SYSTEM_ERROR = "system_error",       // Infrastructure issue
  TIMEOUT_ERROR = "timeout_error",     // Execution timeout
  PERMISSION_ERROR = "permission_error" // Auth failure
}
```

### Recovery Strategies

#### 1. Retry with Backoff

```typescript
async function retryCommand(
  command: AgentCommand,
  maxAttempts: number = 3
): Promise<AgentResponse> {
  let attempt = 0;
  let delay = 1000;
  
  while (attempt < maxAttempts) {
    try {
      return await send(command);
    } catch (error) {
      attempt++;
      
      if (attempt >= maxAttempts) {
        throw error;
      }
      
      await sleep(delay);
      delay *= 2; // Exponential backoff
    }
  }
  
  throw new Error('Max retries exceeded');
}
```

#### 2. Fallback Agent

```typescript
async function sendWithFallback(
  command: AgentCommand,
  fallbackAgent: string
): Promise<AgentResponse> {
  try {
    return await send(command);
  } catch (error) {
    console.warn(`Primary agent failed, using fallback`);
    
    return await send({
      ...command,
      id: generateId(),
      to: fallbackAgent
    });
  }
}
```

#### 3. Circuit Breaker

```typescript
class CircuitBreaker {
  private failures = 0;
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  
  async call(
    command: AgentCommand,
    threshold: number = 5
  ): Promise<AgentResponse> {
    if (this.state === 'open') {
      throw new Error('Circuit breaker is open');
    }
    
    try {
      const response = await send(command);
      this.failures = 0;
      this.state = 'closed';
      return response;
    } catch (error) {
      this.failures++;
      
      if (this.failures >= threshold) {
        this.state = 'open';
      }
      
      throw error;
    }
  }
}
```

## Security

### Permission Validation

```typescript
function validatePermissions(
  command: AgentCommand,
  agentPermissions: string[]
): boolean {
  if (!command.security?.permissions) {
    return true; // No special permissions required
  }
  
  return command.security.permissions.every(required =>
    agentPermissions.includes(required)
  );
}
```

### Approval Workflow

```typescript
async function executeWithApproval(
  command: AgentCommand
): Promise<AgentResponse> {
  if (command.security?.requireApproval) {
    const approved = await requestHumanApproval(command);
    
    if (!approved) {
      throw new Error('Approval denied');
    }
  }
  
  return await send(command);
}
```

### Audit Trail

```typescript
interface AuditEntry {
  timestamp: string;
  messageId: string;
  type: 'command' | 'response';
  from: string;
  to: string;
  action?: Action;
  status?: Status;
}

class AuditLogger {
  log(message: AgentCommand | AgentResponse): void {
    const entry: AuditEntry = {
      timestamp: message.timestamp,
      messageId: message.id,
      type: 'commandId' in message ? 'response' : 'command',
      from: message.from,
      to: 'to' in message ? message.to : message.from,
      action: 'action' in message ? message.action : undefined,
      status: 'status' in message ? message.status : undefined
    };
    
    // Store entry in immutable log
    this.store.append(entry);
  }
}
```

## Best Practices

### 1. Message Design

✅ **Do**:
- Use descriptive action names
- Include correlation IDs for related messages
- Set appropriate timeouts
- Validate parameters before sending

❌ **Don't**:
- Send overly large payloads
- Omit error handling
- Ignore response status
- Reuse message IDs

### 2. Error Handling

✅ **Do**:
- Implement retry logic for transient errors
- Provide meaningful error messages
- Log all failures
- Have fallback strategies

❌ **Don't**:
- Silently swallow errors
- Retry non-retriable errors indefinitely
- Expose internal details in errors
- Leave resources in inconsistent state

### 3. Performance

✅ **Do**:
- Use parallel execution when possible
- Implement timeouts
- Cache responses when appropriate
- Monitor agent performance

❌ **Don't**:
- Create chatty protocols (too many small messages)
- Block waiting for non-critical responses
- Ignore performance metrics
- Over-optimize prematurely

### 4. Security

✅ **Do**:
- Validate all inputs
- Check permissions
- Require approval for critical operations
- Maintain audit trails

❌ **Don't**:
- Trust inputs blindly
- Skip permission checks
- Log sensitive data
- Execute untrusted commands

## Implementation Example

### Simple Orchestrator

```typescript
class SimpleOrchestrator {
  private agents = new Map<string, Agent>();
  private logger = new AuditLogger();
  
  async execute(
    targetAgent: string,
    action: Action,
    parameters: any
  ): Promise<AgentResponse> {
    // Build command
    const command: AgentCommand = {
      id: generateId(),
      timestamp: new Date().toISOString(),
      version: "2.0",
      from: "orchestrator",
      to: targetAgent,
      priority: "medium",
      action,
      parameters
    };
    
    // Log command
    this.logger.log(command);
    
    try {
      // Send to agent
      const response = await this.send(command);
      
      // Log response
      this.logger.log(response);
      
      return response;
      
    } catch (error) {
      // Log error
      this.logger.log({
        ...command,
        id: generateId(),
        commandId: command.id,
        status: 'failed',
        error: {
          code: 'AGENT_ERROR',
          message: error.message,
          recoverable: false
        }
      } as AgentResponse);
      
      throw error;
    }
  }
  
  private async send(command: AgentCommand): Promise<AgentResponse> {
    const agent = this.agents.get(command.to);
    
    if (!agent) {
      throw new Error(`Agent not found: ${command.to}`);
    }
    
    return await agent.handle(command);
  }
}
```

## Configuration

```yaml
acp:
  version: "2.0"
  
  timeouts:
    default: 30000      # 30 seconds
    low_priority: 60000
    high_priority: 15000
  
  retry:
    max_attempts: 3
    backoff_ms: 1000
    backoff_multiplier: 2
  
  security:
    require_permissions: true
    approval_threshold: high
    audit_level: detailed
  
  performance:
    enable_caching: true
    cache_ttl: 3600
    max_parallel: 5
```

## Version History

- v2.0.0 (2024-12-09): Simplified protocol, composition-friendly
- v1.0.0 (2024-01-01): Initial protocol specification

---

**Note**: This protocol is designed to be simple, reliable, and composable with other capabilities.
