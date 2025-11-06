---
applyTo: '**'
description: 'Inter-agent communication, coordination patterns, and collaborative execution'
capability: multi-agent-coordination
version: 1.0.0
category: coordination
dependencies:
  core:
    - safety
    - communication
    - error-handling
  capabilities:
    - context-awareness
  protocols:
    - acp-v2
  optional:
    - orchestration
    - workflow-optimization
platform: agnostic
composable: true
---

# Multi-Agent Coordination Capability

## Overview

The **Multi-Agent Coordination** capability enables effective communication, collaboration, and coordination between multiple agents. It provides the communication layer that manages *how* agents interact, share information, and work together.

### Core Responsibilities

1. **Message Passing**: Structured communication between agents
2. **Coordination Patterns**: Implementing collaboration strategies
3. **Dependency Management**: Handling inter-agent dependencies
4. **State Synchronization**: Maintaining consistency across agents
5. **Conflict Resolution**: Managing competing agent actions
6. **Collective Decision Making**: Coordinating multi-agent decisions

### Distinction from Related Capabilities

- **Multi-Agent Coordination**: Handles HOW agents communicate
- **Orchestration**: Decides WHAT to do and WHO does it
- **Workflow Optimization**: Makes execution MORE EFFICIENT

## Core Concepts

### Agent Communication Model

```yaml
communication_model:
  participants:
    sender:
      description: "Agent initiating communication"
      responsibilities:
        - compose_message
        - send_message
        - handle_response
    
    receiver:
      description: "Agent receiving communication"
      responsibilities:
        - receive_message
        - process_message
        - send_response
    
    coordinator:
      description: "Optional intermediary"
      responsibilities:
        - route_messages
        - ensure_delivery
        - manage_ordering
  
  message_flow:
    synchronous:
      description: "Request-response pattern"
      use_when: "Immediate response needed"
      characteristics:
        - blocking: true
        - ordering: guaranteed
        - reliability: high
    
    asynchronous:
      description: "Fire-and-forget pattern"
      use_when: "No immediate response needed"
      characteristics:
        - blocking: false
        - ordering: best_effort
        - reliability: moderate
    
    publish_subscribe:
      description: "Event-driven pattern"
      use_when: "Multiple consumers"
      characteristics:
        - blocking: false
        - ordering: eventual
        - reliability: configurable
```

### Message Structure (ACP v2.0)

```yaml
message_structure:
  header:
    required:
      - message_id: "Unique identifier"
      - correlation_id: "Link related messages"
      - timestamp: "Message creation time"
      - sender: "Sending agent identifier"
      - recipient: "Target agent identifier"
      - priority: "Message importance"
    
    optional:
      - reply_to: "Response destination"
      - expires_at: "Message expiration"
      - parent_message_id: "For threading"
  
  body:
    required:
      - type: "Message type/category"
      - action: "Requested action"
      - payload: "Message content"
    
    optional:
      - context: "Relevant context"
      - constraints: "Execution constraints"
      - preferences: "Sender preferences"
  
  metadata:
    optional:
      - timeout: "Max processing time"
      - retry_count: "Retry attempts"
      - checkpoint_id: "Recovery point"
      - security: "Auth/encryption info"
```

## Coordination Patterns

### Pattern 1: Request-Response

```yaml
pattern: request_response
description: "Synchronous request with expected response"
use_when:
  - immediate_result_needed
  - sequential_dependency
  - confirmation_required

flow:
  1_send_request:
    agent: sender
    action: "Compose and send message"
    blocking: true
  
  2_process_request:
    agent: receiver
    action: "Process message and generate response"
    duration: "varies"
  
  3_send_response:
    agent: receiver
    action: "Return result to sender"
  
  4_handle_response:
    agent: sender
    action: "Process received response"
    blocking: false

characteristics:
  - latency: "Low to moderate"
  - reliability: "High"
  - complexity: "Low"
  - scalability: "Moderate"

example:
  request: "Validate this design"
  response: "Design approved with 2 suggestions"
```

### Pattern 2: Pipeline

```yaml
pattern: pipeline
description: "Sequential processing through multiple agents"
use_when:
  - sequential_stages
  - output_becomes_input
  - transformation_chain

flow:
  1_stage_1:
    agent: agent_a
    input: "initial_data"
    output: "intermediate_1"
    passes_to: agent_b
  
  2_stage_2:
    agent: agent_b
    input: "intermediate_1"
    output: "intermediate_2"
    passes_to: agent_c
  
  3_stage_n:
    agent: agent_n
    input: "intermediate_n-1"
    output: "final_result"

characteristics:
  - latency: "Cumulative"
  - reliability: "Chain dependent"
  - complexity: "Moderate"
  - scalability: "Limited by slowest stage"

optimization:
  - overlap_stages
  - batch_through_pipeline
  - parallel_pipelines

example:
  stage_1: "Parse requirements" → agent_a
  stage_2: "Design architecture" → agent_b
  stage_3: "Generate code" → agent_c
  stage_4: "Validate output" → agent_d
```

### Pattern 3: Parallel Execution

```yaml
pattern: parallel_execution
description: "Multiple agents work simultaneously"
use_when:
  - independent_tasks
  - time_sensitive
  - no_dependencies

flow:
  1_broadcast:
    coordinator: "orchestrator"
    action: "Send tasks to all agents"
    agents: [agent_a, agent_b, agent_c]
  
  2_parallel_execution:
    agents: "all"
    action: "Execute independently"
    synchronization: none
  
  3_collect_results:
    coordinator: "orchestrator"
    action: "Gather all results"
    wait_for: all_complete

characteristics:
  - latency: "Parallel (max of all)"
  - reliability: "Individual failures contained"
  - complexity: "Moderate"
  - scalability: "Excellent"

synchronization:
  barrier:
    description: "Wait for all to complete"
    use_when: "All results needed"
  
  first_complete:
    description: "Use first available result"
    use_when: "Any result acceptable"
  
  majority:
    description: "Use consensus result"
    use_when: "Redundancy for reliability"

example:
  task: "Analyze codebase"
  agent_a: "Check security"
  agent_b: "Check performance"
  agent_c: "Check maintainability"
  aggregate: "Combined analysis report"
```

### Pattern 4: Saga

```yaml
pattern: saga
description: "Long-running transaction with compensation"
use_when:
  - multi_step_transaction
  - reversibility_needed
  - distributed_transaction

flow:
  1_execute_steps:
    for_each: transaction_step
      - execute_step
      - record_completion
      - prepare_compensation
  
  2_on_success:
    action: "Commit all steps"
    cleanup: "Clear compensation data"
  
  3_on_failure:
    action: "Execute compensations"
    order: "Reverse of execution"
    goal: "Restore initial state"

characteristics:
  - latency: "High (cumulative)"
  - reliability: "Very high (compensatable)"
  - complexity: "High"
  - scalability: "Moderate"

compensation_strategies:
  backward_recovery:
    description: "Undo completed steps"
    example: "Rollback database changes"
  
  forward_recovery:
    description: "Complete despite errors"
    example: "Skip optional steps"
  
  hybrid:
    description: "Combine both approaches"
    example: "Undo critical, skip optional"

example:
  transaction: "Deploy new feature"
  step_1: "Update database schema" → can_compensate: restore_backup
  step_2: "Deploy application" → can_compensate: rollback_deployment
  step_3: "Update configuration" → can_compensate: revert_config
  step_4: "Run migrations" → can_compensate: reverse_migration
  on_error: "Execute compensations in reverse order"
```

### Pattern 5: Scatter-Gather

```yaml
pattern: scatter_gather
description: "Broadcast query, aggregate responses"
use_when:
  - parallel_data_retrieval
  - multiple_perspectives_needed
  - federated_search

flow:
  1_scatter:
    coordinator: "orchestrator"
    action: "Send query to multiple agents"
    strategy:
      - broadcast_all
      - selective_subset
      - capability_based
  
  2_gather:
    coordinator: "orchestrator"
    action: "Collect responses"
    timeout: "configurable"
    partial_results: "acceptable"
  
  3_aggregate:
    coordinator: "orchestrator"
    action: "Combine responses"
    strategies:
      - merge
      - vote
      - weighted_average
      - priority_based

characteristics:
  - latency: "Parallel with timeout"
  - reliability: "Graceful degradation"
  - complexity: "Moderate to high"
  - scalability: "Good"

aggregation_methods:
  union:
    description: "Combine all unique results"
    use_when: "Comprehensive results needed"
  
  intersection:
    description: "Only common results"
    use_when: "High confidence needed"
  
  voting:
    description: "Majority or weighted consensus"
    use_when: "Redundant agents"
  
  best_match:
    description: "Select highest quality"
    use_when: "Quality over quantity"

example:
  query: "Find similar code patterns"
  scatter_to: [semantic_search, syntax_search, ml_search]
  gather: "All results within 5 seconds"
  aggregate: "Rank by relevance, deduplicate"
```

### Pattern 6: Circuit Breaker

```yaml
pattern: circuit_breaker
description: "Prevent cascading failures"
use_when:
  - agent_reliability_uncertain
  - failure_propagation_risk
  - graceful_degradation_needed

states:
  closed:
    description: "Normal operation"
    behavior: "Forward all requests"
    transition: "Opens on failure threshold"
  
  open:
    description: "Failure detected"
    behavior: "Reject requests immediately"
    transition: "Half-open after timeout"
  
  half_open:
    description: "Testing recovery"
    behavior: "Allow limited requests"
    transition:
      success: "Return to closed"
      failure: "Return to open"

parameters:
  failure_threshold: "Number of failures before opening"
  timeout: "Time before attempting recovery"
  success_threshold: "Successes needed to close"
  
characteristics:
  - latency: "Fast failure (open state)"
  - reliability: "Prevents cascade"
  - complexity: "Moderate"
  - scalability: "Excellent"

example:
  scenario: "Database agent failing"
  closed: "Forward queries normally"
  failures: "5 consecutive failures"
  open: "Return cached data or error"
  timeout: "Wait 60 seconds"
  half_open: "Try one query"
  recovery: "Close circuit on success"
```

## Dependency Management

### Dependency Types

```yaml
dependency_types:
  sequential:
    description: "Task B requires Task A output"
    coordination: "Execute in order"
    example: "Design → Implement"
  
  resource:
    description: "Tasks compete for same resource"
    coordination: "Serialize or partition"
    example: "File write operations"
  
  data:
    description: "Tasks share data"
    coordination: "Synchronize access"
    example: "Shared context updates"
  
  logical:
    description: "Business logic requires order"
    coordination: "Enforce ordering"
    example: "Validate before deploy"
```

### Dependency Resolution

```yaml
resolution:
  detection:
    methods:
      - explicit_declaration
      - static_analysis
      - runtime_detection
    
    representation:
      - dependency_graph
      - adjacency_list
      - constraint_system
  
  scheduling:
    topological_sort:
      description: "Order tasks respecting dependencies"
      guarantee: "All dependencies satisfied"
    
    critical_path:
      description: "Identify longest dependency chain"
      use: "Optimize total time"
    
    resource_aware:
      description: "Consider resource constraints"
      use: "Practical scheduling"
  
  validation:
    cycle_detection:
      description: "Detect circular dependencies"
      action: "Reject or break cycle"
    
    feasibility_check:
      description: "Verify can satisfy all"
      action: "Report impossible constraints"
```

## State Synchronization

### Synchronization Strategies

```yaml
synchronization:
  strong_consistency:
    description: "All agents see same state immediately"
    mechanism: "Distributed locks, consensus"
    pros:
      - simple_reasoning
      - guaranteed_consistency
    cons:
      - high_latency
      - reduced_availability
    use_when: "Correctness critical"
  
  eventual_consistency:
    description: "State converges over time"
    mechanism: "Async replication, CRDTs"
    pros:
      - low_latency
      - high_availability
    cons:
      - temporary_inconsistency
      - complex_reasoning
    use_when: "Availability critical"
  
  causal_consistency:
    description: "Preserve cause-effect relationships"
    mechanism: "Vector clocks, happened-before"
    pros:
      - balanced_latency
      - intuitive_behavior
    cons:
      - moderate_complexity
    use_when: "Balance needed"
```

### Conflict Resolution

```yaml
conflict_resolution:
  last_write_wins:
    description: "Most recent update prevails"
    pros: "Simple"
    cons: "May lose valid updates"
    use_when: "Updates independent"
  
  merge:
    description: "Combine conflicting updates"
    pros: "Preserve all information"
    cons: "Complex logic needed"
    use_when: "Updates can combine"
  
  application_specific:
    description: "Custom resolution logic"
    pros: "Optimal for domain"
    cons: "Must be implemented"
    use_when: "Domain knowledge available"
  
  manual:
    description: "Human intervention"
    pros: "Correct resolution"
    cons: "Slow, not automatic"
    use_when: "Ambiguous or critical"
```

## Communication Reliability

### Reliability Patterns

```yaml
reliability:
  at_most_once:
    description: "Send once, no retry"
    guarantee: "May be lost"
    overhead: "Minimal"
    use_when: "Loss acceptable"
  
  at_least_once:
    description: "Retry until acknowledged"
    guarantee: "Delivered, may duplicate"
    overhead: "Moderate"
    use_when: "Idempotent operations"
  
  exactly_once:
    description: "Delivered exactly one time"
    guarantee: "No loss, no duplicates"
    overhead: "High"
    use_when: "Critical operations"
```

### Error Handling

```yaml
error_handling:
  timeout:
    detection: "No response within limit"
    actions:
      - retry
      - use_fallback
      - fail_operation
    
  network_error:
    detection: "Connection failure"
    actions:
      - exponential_backoff_retry
      - switch_endpoint
      - use_cache
  
  agent_error:
    detection: "Agent returned error"
    actions:
      - analyze_error
      - retry_if_transient
      - use_alternative_agent
  
  partial_failure:
    detection: "Some agents failed"
    actions:
      - continue_with_partial
      - compensate_failures
      - abort_transaction
```

## Performance Optimization

### Communication Optimization

```yaml
optimization:
  message_batching:
    description: "Combine multiple messages"
    benefit: "Reduce overhead"
    tradeoff: "Increased latency"
  
  compression:
    description: "Compress message content"
    benefit: "Reduce bandwidth"
    tradeoff: "CPU overhead"
  
  connection_pooling:
    description: "Reuse connections"
    benefit: "Reduce connection overhead"
    tradeoff: "Resource consumption"
  
  async_communication:
    description: "Non-blocking messages"
    benefit: "Reduce wait time"
    tradeoff: "Complex programming model"
```

### Load Balancing

```yaml
load_balancing:
  round_robin:
    description: "Distribute evenly"
    use_when: "Agents homogeneous"
  
  least_loaded:
    description: "Send to least busy"
    use_when: "Load varies"
  
  capability_based:
    description: "Match task to capability"
    use_when: "Agents specialized"
  
  geographic:
    description: "Prefer nearby agents"
    use_when: "Latency critical"
  
  weighted:
    description: "Distribute by capacity"
    use_when: "Agents heterogeneous"
```

## Security and Trust

### Authentication

```yaml
authentication:
  agent_identity:
    description: "Verify agent identity"
    methods:
      - certificate_based
      - token_based
      - key_based
  
  message_integrity:
    description: "Ensure message not tampered"
    methods:
      - digital_signatures
      - hmac
      - checksums
```

### Authorization

```yaml
authorization:
  permissions:
    description: "What agent can do"
    levels:
      - read_only
      - read_write
      - admin
  
  policies:
    description: "Rules governing access"
    types:
      - role_based
      - attribute_based
      - capability_based
```

## Integration Points

### With Protocols

```yaml
integration_protocols:
  acp_v2:
    - use_command_structure
    - use_response_format
    - follow_message_standards
    - implement_protocol_rules
```

### With Capabilities

```yaml
integration_capabilities:
  orchestration:
    - receive_orchestration_commands
    - report_execution_status
    - provide_capability_information
  
  context_awareness:
    - share_context_updates
    - synchronize_state
    - maintain_consistency
  
  workflow_optimization:
    - report_communication_metrics
    - enable_pattern_optimization
    - support_caching_strategies
```

## Practical Examples

### Example 1: Simple Coordination

```yaml
scenario: "Code review workflow"

coordination:
  pattern: pipeline
  
  stage_1:
    agent: static_analyzer
    action: "Check code quality"
    output: "analysis_results"
  
  stage_2:
    agent: security_scanner
    action: "Check security issues"
    output: "security_results"
  
  stage_3:
    agent: test_runner
    action: "Run test suite"
    output: "test_results"
  
  aggregation:
    agent: orchestrator
    action: "Combine all results"
    output: "complete_review"
```

### Example 2: Complex Coordination

```yaml
scenario: "Distributed system deployment"

coordination:
  pattern: saga
  
  transaction_steps:
    1_update_database:
      agent: database_agent
      action: "Apply schema migration"
      compensation: "Rollback migration"
    
    2_deploy_services:
      agent: deployment_agent
      action: "Deploy new version"
      compensation: "Rollback to previous version"
    
    3_update_config:
      agent: config_agent
      action: "Update service configuration"
      compensation: "Restore old configuration"
    
    4_verify_health:
      agent: monitor_agent
      action: "Check system health"
      compensation: "Alert operations team"
  
  on_failure:
    - execute_compensations_in_reverse
    - notify_stakeholders
    - create_incident_report
```

## Best Practices

### DO

- ✅ Use appropriate coordination pattern
- ✅ Handle failures gracefully
- ✅ Implement idempotent operations
- ✅ Validate messages
- ✅ Monitor communication health
- ✅ Document dependencies
- ✅ Test coordination logic
- ✅ Use timeouts

### DON'T

- ❌ Assume reliability
- ❌ Ignore message ordering
- ❌ Skip error handling
- ❌ Create tight coupling
- ❌ Forget about timeouts
- ❌ Ignore partial failures
- ❌ Hard-code agent references
- ❌ Bypass coordination layer

## Metrics

```yaml
key_metrics:
  communication:
    - message_count
    - message_size
    - message_latency
    - error_rate
  
  coordination:
    - pattern_usage
    - success_rate
    - retry_count
    - timeout_count
  
  performance:
    - throughput
    - end_to_end_latency
    - agent_utilization
    - bottleneck_identification
```

---

**Capability Status**: Production Ready  
**Composition**: Core + Context-Awareness + ACP v2 Protocol  
**Optional Enhancement**: Orchestration, Workflow Optimization  
**Platform**: Agnostic
