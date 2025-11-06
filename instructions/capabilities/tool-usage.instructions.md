---
applyTo: '**'
description: 'Modular capability for intelligent tool selection, execution, and orchestration.'
id: capability.tool-usage
version: 1.0.0
category: capability
type: mixin
requires: [core.safety, core.error-handling]
provides: [tool_selection, tool_execution, tool_chaining]
---

# Tool Usage Capability

## Purpose
Modular capability for intelligent tool selection, execution, and orchestration.

## Capability Overview

### What This Enables

- **Tool Discovery**: Find available tools
- **Tool Selection**: Choose appropriate tools
- **Tool Execution**: Run tools safely
- **Tool Chaining**: Compose tool sequences
- **Tool Monitoring**: Track execution and results

### Tool Philosophy

```yaml
principles:
  safety_first:
    - validate before execution
    - require approval for critical ops
    - maintain audit trails
  
  right_tool_for_job:
    - select based on requirements
    - consider alternatives
    - optimize for efficiency
  
  fail_gracefully:
    - handle errors robustly
    - provide fallbacks
    - maintain consistency
```

## Tool Discovery

### Tool Registry

```typescript
interface ToolRegistry {
  register(tool: Tool): void;
  discover(criteria: DiscoveryCriteria): Tool[];
  get(id: string): Tool | null;
  list(): Tool[];
}

interface Tool {
  id: string;
  name: string;
  description: string;
  category: ToolCategory;
  capabilities: string[];
  parameters: ParameterSchema;
  permissions: Permission[];
  metadata: ToolMetadata;
}
```

### Discovery Patterns

#### By Capability

```typescript
function discoverByCapability(
  registry: ToolRegistry,
  capability: string
): Tool[] {
  return registry.discover({
    capabilities: [capability],
    sortBy: 'relevance'
  });
}

// Example
const fileTools = discoverByCapability(registry, 'file_operations');
```

#### By Category

```typescript
enum ToolCategory {
  FILESYSTEM = 'filesystem',
  GIT = 'git',
  CODE_ANALYSIS = 'code_analysis',
  EXECUTION = 'execution',
  COMMUNICATION = 'communication',
  DATA_PROCESSING = 'data_processing'
}

function discoverByCategory(
  registry: ToolRegistry,
  category: ToolCategory
): Tool[] {
  return registry.discover({
    category,
    sortBy: 'usage_frequency'
  });
}
```

#### By Context

```typescript
function discoverByContext(
  registry: ToolRegistry,
  context: Context
): Tool[] {
  // Analyze context
  const requirements = analyzeRequirements(context);
  
  // Find matching tools
  return registry.discover({
    requirements,
    permissions: context.permissions,
    environment: context.environment
  });
}
```

## Tool Selection

### Selection Strategy

```typescript
interface SelectionStrategy {
  select(
    tools: Tool[],
    task: Task,
    context: Context
  ): Tool[];
}

class IntelligentSelector implements SelectionStrategy {
  select(tools: Tool[], task: Task, context: Context): Tool[] {
    // Score each tool
    const scored = tools.map(tool => ({
      tool,
      score: this.calculateFitScore(tool, task, context)
    }));
    
    // Sort by score
    scored.sort((a, b) => b.score - a.score);
    
    // Return best matches
    return scored
      .filter(s => s.score > THRESHOLD)
      .map(s => s.tool);
  }
  
  private calculateFitScore(
    tool: Tool,
    task: Task,
    context: Context
  ): number {
    let score = 0;
    
    // Capability match
    score += this.matchCapabilities(tool, task) * 0.4;
    
    // Permission availability
    score += this.checkPermissions(tool, context) * 0.2;
    
    // Past success rate
    score += tool.metadata.successRate * 0.2;
    
    // Performance
    score += this.evaluatePerformance(tool) * 0.1;
    
    // User preference
    score += this.getUserPreference(tool, context) * 0.1;
    
    return score;
  }
}
```

### Selection Criteria

```yaml
criteria:
  functional:
    - capabilities_match
    - parameter_compatibility
    - output_format_match
  
  non_functional:
    - performance_requirements
    - reliability_needs
    - security_constraints
    - resource_availability
  
  contextual:
    - user_permissions
    - environment_constraints
    - historical_success
    - user_preferences
```

### Decision Tree

```typescript
function selectTool(task: Task, context: Context): Tool {
  // Check if specific tool requested
  if (task.toolHint) {
    const tool = registry.get(task.toolHint);
    if (tool && canUse(tool, context)) {
      return tool;
    }
  }
  
  // Discover candidates
  const candidates = discoverByContext(registry, context);
  
  // Filter by requirements
  const suitable = candidates.filter(tool => 
    matchesRequirements(tool, task) &&
    hasPermissions(tool, context)
  );
  
  if (suitable.length === 0) {
    throw new NoSuitableToolError(task);
  }
  
  // Select best
  const strategy = new IntelligentSelector();
  const selected = strategy.select(suitable, task, context);
  
  return selected[0];  // Return top choice
}
```

## Tool Execution

### Execution Pipeline

```typescript
interface ExecutionPipeline {
  preExecution: PreExecutionHook[];
  execution: ExecutionStep;
  postExecution: PostExecutionHook[];
}

class ToolExecutor {
  async execute(
    tool: Tool,
    parameters: any,
    context: Context
  ): Promise<ExecutionResult> {
    // Pre-execution
    await this.runPreExecution(tool, parameters, context);
    
    try {
      // Main execution
      const result = await this.runTool(tool, parameters, context);
      
      // Post-execution
      await this.runPostExecution(tool, result, context);
      
      return result;
      
    } catch (error) {
      // Error handling
      return await this.handleExecutionError(error, tool, context);
    }
  }
  
  private async runPreExecution(
    tool: Tool,
    parameters: any,
    context: Context
  ): Promise<void> {
    // Validate parameters
    await this.validateParameters(tool, parameters);
    
    // Check permissions
    await this.verifyPermissions(tool, context);
    
    // Request approval if needed
    if (tool.requiresApproval) {
      await this.requestApproval(tool, parameters, context);
    }
    
    // Create checkpoint
    await this.createCheckpoint(tool, context);
    
    // Log intent
    await this.logExecution(tool, parameters, 'starting');
  }
}
```

### Safety Checks

```typescript
interface SafetyCheck {
  name: string;
  check(tool: Tool, parameters: any, context: Context): Promise<boolean>;
  severity: 'blocking' | 'warning';
}

const safetyChecks: SafetyCheck[] = [
  {
    name: 'destructive_operation',
    severity: 'blocking',
    async check(tool, parameters, context) {
      if (tool.metadata.destructive) {
        return await requestUserConfirmation(
          `${tool.name} will perform destructive operation. Continue?`
        );
      }
      return true;
    }
  },
  {
    name: 'permission_validation',
    severity: 'blocking',
    async check(tool, parameters, context) {
      return tool.permissions.every(p => 
        context.permissions.includes(p)
      );
    }
  },
  {
    name: 'parameter_validation',
    severity: 'blocking',
    async check(tool, parameters, context) {
      return validateAgainstSchema(parameters, tool.parameters);
    }
  },
  {
    name: 'resource_availability',
    severity: 'warning',
    async check(tool, parameters, context) {
      const resources = await checkResources(tool.requirements);
      return resources.available;
    }
  }
];
```

### Execution Monitoring

```typescript
class ExecutionMonitor {
  private metrics = new Map<string, ExecutionMetrics>();
  
  async monitor(
    execution: Promise<ExecutionResult>,
    tool: Tool,
    context: Context
  ): Promise<ExecutionResult> {
    const startTime = Date.now();
    const executionId = generateId();
    
    try {
      // Wait for completion
      const result = await execution;
      
      // Record success
      this.recordMetrics(executionId, {
        tool: tool.id,
        duration: Date.now() - startTime,
        status: 'success',
        result
      });
      
      return result;
      
    } catch (error) {
      // Record failure
      this.recordMetrics(executionId, {
        tool: tool.id,
        duration: Date.now() - startTime,
        status: 'failure',
        error
      });
      
      throw error;
    }
  }
}
```

## Tool Chaining

### Chain Patterns

#### Sequential Chain

```typescript
interface SequentialChain {
  tools: Tool[];
  dataFlow: DataFlowSpec;
}

async function executeSequential(
  chain: SequentialChain,
  initialInput: any,
  context: Context
): Promise<any> {
  let currentInput = initialInput;
  const results: any[] = [];
  
  for (const tool of chain.tools) {
    // Execute tool
    const result = await executor.execute(
      tool,
      mapInput(currentInput, tool),
      context
    );
    
    results.push(result);
    
    // Prepare input for next tool
    currentInput = mapOutput(result, chain.dataFlow);
  }
  
  return results[results.length - 1];
}
```

#### Parallel Chain

```typescript
interface ParallelChain {
  tools: Tool[];
  aggregation: AggregationStrategy;
}

async function executeParallel(
  chain: ParallelChain,
  input: any,
  context: Context
): Promise<any> {
  // Execute all tools concurrently
  const promises = chain.tools.map(tool =>
    executor.execute(tool, input, context)
  );
  
  // Wait for all to complete
  const results = await Promise.all(promises);
  
  // Aggregate results
  return chain.aggregation.aggregate(results);
}
```

#### Conditional Chain

```typescript
interface ConditionalChain {
  condition: (input: any, context: Context) => boolean;
  trueBranch: Tool[];
  falseBranch: Tool[];
}

async function executeConditional(
  chain: ConditionalChain,
  input: any,
  context: Context
): Promise<any> {
  const branch = chain.condition(input, context)
    ? chain.trueBranch
    : chain.falseBranch;
  
  return executeSequential({ tools: branch, dataFlow: {} }, input, context);
}
```

### Chain Building

```typescript
class ChainBuilder {
  private tools: Tool[] = [];
  private flow: DataFlowSpec = {};
  
  then(tool: Tool, mapping?: InputMapping): this {
    this.tools.push(tool);
    if (mapping) {
      this.flow[tool.id] = mapping;
    }
    return this;
  }
  
  parallel(...tools: Tool[]): this {
    this.tools.push(...tools);
    return this;
  }
  
  build(): ToolChain {
    return {
      tools: this.tools,
      flow: this.flow,
      validate: () => this.validateChain()
    };
  }
  
  private validateChain(): boolean {
    // Check that outputs match next inputs
    for (let i = 0; i < this.tools.length - 1; i++) {
      const current = this.tools[i];
      const next = this.tools[i + 1];
      
      if (!this.outputMatchesInput(current, next)) {
        throw new ChainValidationError(
          `Tool ${current.name} output incompatible with ${next.name} input`
        );
      }
    }
    
    return true;
  }
}
```

## Error Handling

### Tool-Specific Errors

```typescript
class ToolExecutionError extends Error {
  constructor(
    public tool: Tool,
    public parameters: any,
    public cause: Error,
    public recoverable: boolean
  ) {
    super(`Tool ${tool.name} failed: ${cause.message}`);
  }
}

class ToolNotFoundError extends Error {
  constructor(public toolId: string) {
    super(`Tool not found: ${toolId}`);
  }
}

class PermissionDeniedError extends Error {
  constructor(
    public tool: Tool,
    public required: Permission[],
    public available: Permission[]
  ) {
    super(`Permission denied for tool ${tool.name}`);
  }
}
```

### Recovery Strategies

```typescript
interface RecoveryStrategy {
  canRecover(error: ToolExecutionError): boolean;
  recover(error: ToolExecutionError, context: Context): Promise<ExecutionResult>;
}

class RetryRecovery implements RecoveryStrategy {
  canRecover(error: ToolExecutionError): boolean {
    return error.recoverable && 
           isTransientError(error.cause);
  }
  
  async recover(
    error: ToolExecutionError,
    context: Context
  ): Promise<ExecutionResult> {
    return await retryWithBackoff(
      () => executor.execute(error.tool, error.parameters, context),
      {
        maxAttempts: 3,
        initialDelay: 1000,
        maxDelay: 5000,
        backoffMultiplier: 2
      }
    );
  }
}

class FallbackRecovery implements RecoveryStrategy {
  canRecover(error: ToolExecutionError): boolean {
    return this.hasFallbackTool(error.tool);
  }
  
  async recover(
    error: ToolExecutionError,
    context: Context
  ): Promise<ExecutionResult> {
    const fallback = this.getFallbackTool(error.tool);
    
    // Attempt with fallback tool
    return await executor.execute(
      fallback,
      error.parameters,
      context
    );
  }
}
```

## Tool Categories

### File System Tools

```yaml
category: filesystem
tools:
  read_file:
    capabilities: [read, text_files]
    parameters:
      path: string
      encoding: string?
    returns: string
  
  write_file:
    capabilities: [write, text_files]
    parameters:
      path: string
      content: string
      mode: string?
    returns: boolean
    metadata:
      destructive: true
      requires_approval: false
  
  list_directory:
    capabilities: [read, directory]
    parameters:
      path: string
      recursive: boolean?
    returns: string[]
```

### Git Tools

```yaml
category: git
tools:
  git_status:
    capabilities: [read, git]
    parameters:
      repo_path: string
    returns: GitStatus
  
  git_commit:
    capabilities: [write, git]
    parameters:
      repo_path: string
      message: string
      files: string[]?
    returns: CommitHash
    metadata:
      destructive: false
      requires_approval: true
```

### Code Analysis Tools

```yaml
category: code_analysis
tools:
  analyze_complexity:
    capabilities: [analysis, static]
    parameters:
      file_path: string
      metrics: string[]?
    returns: ComplexityReport
  
  find_references:
    capabilities: [search, semantic]
    parameters:
      symbol: string
      scope: string?
    returns: Reference[]
```

## Tool Documentation

### Documentation Template

```markdown
# Tool: {name}

## Purpose
{what the tool does}

## Category
{category}

## Parameters

### Required
- **{param}** ({type}): {description}

### Optional
- **{param}** ({type}): {description}
  Default: {default}

## Returns
**{type}**: {description}

## Examples

### Basic Usage
```language
{example code}
```

### Advanced Usage
```language
{advanced example}
```

## Permissions Required
- {permission 1}
- {permission 2}

## Error Handling

### Common Errors
- **{error_type}**: {when it occurs} → {how to fix}

## Notes
- {important note 1}
- {important note 2}

## See Also
- {related_tool_1}
- {related_tool_2}
```

## Configuration

```yaml
tool_usage:
  discovery:
    auto_discover: true
    cache_registry: true
    cache_ttl: 3600
  
  selection:
    strategy: intelligent
    confidence_threshold: 0.7
    max_alternatives: 3
  
  execution:
    timeout_ms: 30000
    max_retries: 3
    retry_delay_ms: 1000
    approval_required:
      - destructive_operations
      - critical_changes
  
  monitoring:
    enabled: true
    log_level: info
    track_metrics: true
  
  chaining:
    max_chain_length: 10
    validate_chains: true
```

## Integration Points

### With Code Assistance

```typescript
// Use tools to support code operations
const fileContent = await tools.execute('read_file', {
  path: targetFile
});

const analysis = await codeAssistance.analyze(fileContent);

await tools.execute('write_file', {
  path: targetFile,
  content: refactoredCode
});
```

### With Context Awareness

```typescript
// Tools update context
const result = await tools.execute('git_commit', params);

await context.update({
  type: 'git_operation',
  operation: 'commit',
  result,
  timestamp: Date.now()
});
```

## Version History

- v1.0.0 (2024-12-09): Initial tool usage capability

---

**Note**: Tools should be registered dynamically based on available capabilities in the environment.
