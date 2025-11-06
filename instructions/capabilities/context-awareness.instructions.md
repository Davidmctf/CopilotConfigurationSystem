---
applyTo: '**'
description: 'Modular capability for intelligent context management across conversations and operations.'
id: capability.context-awareness
version: 1.0.0
category: capability
type: mixin
requires: [core.communication]
provides: [context_loading, context_tracking, context_optimization]
---

# Context Awareness Capability

## Purpose
Modular capability for intelligent context management across conversations and operations.

## Capability Overview

### What This Capability Enables

- **Context Loading**: Efficiently load relevant context
- **Context Tracking**: Maintain conversation state
- **Context Optimization**: Manage token/memory usage
- **Context Prioritization**: Focus on important information
- **Context Persistence**: Save and restore context

### Core Concepts

```yaml
context_types:
  immediate:
    description: Current request and recent exchanges
    priority: critical
    retention: session
  
  conversation:
    description: Full dialogue history
    priority: high
    retention: configurable
  
  project:
    description: Codebase and structure
    priority: medium
    retention: persistent
  
  user:
    description: Preferences and patterns
    priority: low
    retention: long_term
```

## Context Hierarchy

### Layer Structure

```typescript
interface ContextHierarchy {
  immediate: ImmediateContext;    // Current request
  active: ActiveContext;           // Recent conversation
  project: ProjectContext;         // Workspace state
  session: SessionContext;         // Historical data
  global: GlobalContext;           // System-wide settings
}
```

### Layer Priorities

```yaml
priority_levels:
  critical:
    layers: [immediate]
    budget: 25%
    mandatory: true
  
  high:
    layers: [active]
    budget: 40%
    mandatory: true
  
  medium:
    layers: [project]
    budget: 25%
    mandatory: false
  
  low:
    layers: [session, global]
    budget: 10%
    mandatory: false
```

## Context Loading

### Loading Strategies

#### 1. Lazy Loading

```typescript
class LazyContextLoader {
  async load(requirement: ContextRequirement): Promise<Context> {
    // Load only what's needed
    const essential = await this.loadEssential(requirement);
    
    // Load additional on demand
    return new LazyContext(essential, {
      onDemand: async (key) => await this.loadAdditional(key)
    });
  }
}
```

**When to use**:
- Large context available
- Not all immediately needed
- Performance critical
- Token budget limited

#### 2. Eager Loading

```typescript
class EagerContextLoader {
  async load(requirement: ContextRequirement): Promise<Context> {
    // Load everything upfront
    const [immediate, active, project] = await Promise.all([
      this.loadImmediate(),
      this.loadActive(),
      this.loadProject()
    ]);
    
    return this.combine(immediate, active, project);
  }
}
```

**When to use**:
- Small context size
- All will be needed
- Latency is critical
- Sufficient budget

#### 3. Selective Loading

```typescript
class SelectiveContextLoader {
  async load(requirement: ContextRequirement): Promise<Context> {
    // Analyze what's relevant
    const relevance = await this.analyzeRelevance(requirement);
    
    // Load only relevant parts
    const contexts = await Promise.all(
      relevance
        .filter(r => r.score > threshold)
        .map(r => this.loadContext(r.key))
    );
    
    return this.combine(contexts);
  }
}
```

**When to use**:
- Large available context
- Variable relevance
- Need to optimize
- Dynamic requirements

### Loading Algorithm

```typescript
interface LoadingDecision {
  load: string[];        // What to load
  skip: string[];        // What to skip
  defer: string[];       // What to lazy-load
  rationale: string;
}

function decideWhatToLoad(
  available: ContextSource[],
  requirement: ContextRequirement,
  budget: TokenBudget
): LoadingDecision {
  // 1. Calculate relevance scores
  const scored = available.map(source => ({
    source,
    score: calculateRelevance(source, requirement)
  }));
  
  // 2. Sort by priority and relevance
  const sorted = scored.sort((a, b) => 
    (b.source.priority * b.score) - (a.source.priority * a.score)
  );
  
  // 3. Allocate budget
  let remaining = budget.total;
  const decision: LoadingDecision = {
    load: [],
    skip: [],
    defer: [],
    rationale: ''
  };
  
  for (const item of sorted) {
    const cost = estimateCost(item.source);
    
    if (item.source.mandatory) {
      decision.load.push(item.source.id);
      remaining -= cost;
    } else if (remaining >= cost && item.score > threshold) {
      decision.load.push(item.source.id);
      remaining -= cost;
    } else if (item.source.lazyLoadable) {
      decision.defer.push(item.source.id);
    } else {
      decision.skip.push(item.source.id);
    }
  }
  
  return decision;
}
```

## Context Tracking

### Conversation State

```typescript
interface ConversationState {
  goal: string;                    // User's objective
  phase: ConversationPhase;        // Current stage
  decisions: Decision[];           // Choices made
  artifacts: Artifact[];           // Created items
  issues: Issue[];                 // Problems encountered
  nextSteps: string[];             // Planned actions
}

enum ConversationPhase {
  GREETING = 'greeting',
  CLARIFICATION = 'clarification',
  PLANNING = 'planning',
  EXECUTION = 'execution',
  VERIFICATION = 'verification',
  COMPLETION = 'completion'
}
```

### State Transitions

```typescript
class ConversationTracker {
  private state: ConversationState;
  
  async transition(event: ConversationEvent): Promise<void> {
    const nextPhase = this.determineNextPhase(event);
    
    // Validate transition
    if (!this.isValidTransition(this.state.phase, nextPhase)) {
      throw new Error(`Invalid transition: ${this.state.phase} -> ${nextPhase}`);
    }
    
    // Update state
    this.state = {
      ...this.state,
      phase: nextPhase,
      decisions: [...this.state.decisions, event.decision],
      nextSteps: this.calculateNextSteps(nextPhase)
    };
    
    // Persist
    await this.persist();
  }
}
```

### Tracking Patterns

#### Linear Conversation

```yaml
pattern: linear
phases:
  - greeting
  - clarification
  - execution
  - completion

tracking:
  - record user goal
  - track progress linearly
  - maintain simple history
```

#### Branching Conversation

```yaml
pattern: branching
phases:
  - main_path
  - exploration_branches
  - convergence
  - completion

tracking:
  - record branch points
  - maintain branch contexts
  - track active branch
  - merge on convergence
```

#### Iterative Conversation

```yaml
pattern: iterative
phases:
  - initial_attempt
  - feedback_loop
  - refinement_cycles
  - final_result

tracking:
  - version each iteration
  - track improvements
  - maintain iteration history
  - show progression
```

## Context Optimization

### Token Management

```typescript
interface TokenBudget {
  total: number;
  allocated: {
    immediate: number;
    active: number;
    project: number;
    session: number;
  };
  remaining: number;
}

class TokenOptimizer {
  optimize(context: Context, budget: TokenBudget): Context {
    if (this.fitsInBudget(context, budget)) {
      return context;
    }
    
    // Apply optimization strategies
    let optimized = context;
    
    optimized = this.compressVerbose(optimized);
    optimized = this.summarizeLong(optimized);
    optimized = this.removeLowPriority(optimized);
    optimized = this.deduplicateContent(optimized);
    
    if (!this.fitsInBudget(optimized, budget)) {
      optimized = this.aggressivePrune(optimized, budget);
    }
    
    return optimized;
  }
}
```

### Compression Techniques

#### 1. Content Summarization

```typescript
function summarize(content: string, maxLength: number): string {
  if (content.length <= maxLength) {
    return content;
  }
  
  // Extract key points
  const keyPoints = extractKeyPoints(content);
  
  // Prioritize most important
  const prioritized = prioritizeByImportance(keyPoints);
  
  // Build summary within limit
  let summary = '';
  for (const point of prioritized) {
    if (summary.length + point.length <= maxLength) {
      summary += point + ' ';
    } else {
      break;
    }
  }
  
  return summary.trim();
}
```

#### 2. Redundancy Removal

```typescript
function deduplicate(contexts: Context[]): Context[] {
  const seen = new Set<string>();
  const unique: Context[] = [];
  
  for (const context of contexts) {
    const signature = computeSignature(context);
    
    if (!seen.has(signature)) {
      seen.add(signature);
      unique.push(context);
    }
  }
  
  return unique;
}
```

#### 3. Smart Pruning

```typescript
function prune(context: Context, budget: number): Context {
  // Calculate importance scores
  const scored = context.items.map(item => ({
    item,
    score: calculateImportance(item, context)
  }));
  
  // Sort by score
  scored.sort((a, b) => b.score - a.score);
  
  // Keep items until budget exhausted
  let used = 0;
  const kept: ContextItem[] = [];
  
  for (const {item, score} of scored) {
    const cost = estimateTokens(item);
    
    if (used + cost <= budget) {
      kept.push(item);
      used += cost;
    }
  }
  
  return new Context(kept);
}
```

### Caching Strategies

```typescript
interface CacheStrategy {
  name: string;
  ttl: number;              // Time to live
  maxSize: number;          // Maximum cache size
  evictionPolicy: Policy;   // LRU, LFU, etc.
}

class ContextCache {
  private cache = new Map<string, CachedContext>();
  
  get(key: string): Context | null {
    const cached = this.cache.get(key);
    
    if (!cached) return null;
    
    if (this.isExpired(cached)) {
      this.cache.delete(key);
      return null;
    }
    
    cached.hits++;
    cached.lastAccessed = Date.now();
    
    return cached.context;
  }
  
  set(key: string, context: Context, ttl: number): void {
    if (this.cache.size >= this.maxSize) {
      this.evict();
    }
    
    this.cache.set(key, {
      context,
      created: Date.now(),
      lastAccessed: Date.now(),
      hits: 0,
      ttl
    });
  }
}
```

## Context Prioritization

### Importance Calculation

```typescript
function calculateImportance(
  item: ContextItem,
  context: Context
): number {
  let score = 0;
  
  // Recency
  const age = Date.now() - item.timestamp;
  score += Math.exp(-age / DECAY_CONSTANT) * RECENCY_WEIGHT;
  
  // Relevance to current task
  score += calculateRelevance(item, context.currentTask) * RELEVANCE_WEIGHT;
  
  // User interaction
  score += item.userInteractions * INTERACTION_WEIGHT;
  
  // Dependency count
  score += item.dependencies.length * DEPENDENCY_WEIGHT;
  
  // Explicit priority
  score += item.priority * PRIORITY_WEIGHT;
  
  return score;
}
```

### Priority Tiers

```yaml
priority_tiers:
  tier_1_critical:
    items:
      - current_request
      - immediate_context
      - error_state
    allocation: 30%
    mandatory: true
  
  tier_2_high:
    items:
      - recent_conversation
      - active_files
      - current_task
    allocation: 40%
    mandatory: true
  
  tier_3_medium:
    items:
      - project_structure
      - related_files
      - historical_decisions
    allocation: 20%
    mandatory: false
  
  tier_4_low:
    items:
      - old_conversations
      - unused_files
      - general_knowledge
    allocation: 10%
    mandatory: false
```

## Context Persistence

### Storage Strategies

#### Session Storage

```typescript
interface SessionStorage {
  save(key: string, context: Context): Promise<void>;
  load(key: string): Promise<Context | null>;
  clear(key: string): Promise<void>;
}

class InMemorySessionStorage implements SessionStorage {
  private storage = new Map<string, Context>();
  
  async save(key: string, context: Context): Promise<void> {
    this.storage.set(key, context);
  }
  
  async load(key: string): Promise<Context | null> {
    return this.storage.get(key) || null;
  }
}
```

#### Persistent Storage

```typescript
interface PersistentStorage {
  save(key: string, context: Context, ttl?: number): Promise<void>;
  load(key: string): Promise<Context | null>;
  delete(key: string): Promise<void>;
  query(criteria: QueryCriteria): Promise<Context[]>;
}

class FileBasedStorage implements PersistentStorage {
  async save(key: string, context: Context): Promise<void> {
    const serialized = this.serialize(context);
    await fs.writeFile(this.getPath(key), serialized);
  }
  
  async load(key: string): Promise<Context | null> {
    try {
      const data = await fs.readFile(this.getPath(key));
      return this.deserialize(data);
    } catch {
      return null;
    }
  }
}
```

### Serialization

```typescript
interface SerializationStrategy {
  serialize(context: Context): string;
  deserialize(data: string): Context;
}

class JSONSerializer implements SerializationStrategy {
  serialize(context: Context): string {
    return JSON.stringify({
      version: context.version,
      items: context.items.map(item => this.serializeItem(item)),
      metadata: context.metadata
    });
  }
  
  deserialize(data: string): Context {
    const parsed = JSON.parse(data);
    
    return new Context({
      version: parsed.version,
      items: parsed.items.map(item => this.deserializeItem(item)),
      metadata: parsed.metadata
    });
  }
}
```

## Context Integration

### With Other Capabilities

```yaml
integrations:
  code_assistance:
    provides:
      - current_file_context
      - project_structure
      - recent_changes
    
    receives:
      - code_analysis_results
      - generated_artifacts
  
  tool_usage:
    provides:
      - available_tools
      - tool_permissions
      - execution_history
    
    receives:
      - tool_execution_results
      - side_effects
  
  orchestration:
    provides:
      - agent_state
      - workflow_progress
      - dependencies
    
    receives:
      - coordination_decisions
      - resource_allocations
```

## Usage Patterns

### Pattern 1: Simple Request

```typescript
// Load minimal context
const context = await loader.load({
  type: 'simple_request',
  priority: 'immediate_only'
});

// Process with context
const response = await process(request, context);

// Update context
await context.update({
  interaction: response,
  outcome: 'success'
});
```

### Pattern 2: Long Conversation

```typescript
// Load conversation history
const context = await loader.load({
  type: 'conversation',
  lookback: 10,  // Last 10 exchanges
  optimize: true
});

// Track state throughout
const tracker = new ConversationTracker(context);

for (const turn of conversation) {
  const response = await process(turn, context);
  await tracker.recordTurn(turn, response);
}
```

### Pattern 3: Complex Task

```typescript
// Load comprehensive context
const context = await loader.load({
  type: 'complex_task',
  layers: ['immediate', 'active', 'project'],
  budget: LARGE_BUDGET
});

// Optimize for task
const optimized = optimizer.optimize(context, {
  focus: task.requirements,
  constraints: task.constraints
});

// Execute with full context
const result = await execute(task, optimized);
```

## Configuration

```yaml
context_awareness:
  loading:
    strategy: selective
    budget_tokens: 4000
    lazy_threshold: 0.5
  
  tracking:
    enabled: true
    persistence: file
    retention_days: 30
  
  optimization:
    compression: enabled
    caching: enabled
    cache_ttl: 3600
    max_cache_size: 100
  
  prioritization:
    recency_weight: 0.3
    relevance_weight: 0.4
    interaction_weight: 0.2
    priority_weight: 0.1
```

## Version History

- v1.0.0 (2024-12-09): Initial context awareness capability

---

**Note**: This capability is foundational and should be composed with most other capabilities.
