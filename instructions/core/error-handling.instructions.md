---

applyTo: '**'
description: 'Establish robust, consistent error handling patterns that maintain system stability and provide actionable guidance.'
id: core.error-handling
version: 1.0.0
category: core
priority: high

---

# Error Handling Instructions

## Purpose
Establish robust, consistent error handling patterns that maintain system stability and provide actionable guidance.

## Error Philosophy

### Core Tenets

1. **Fail Gracefully**: Never crash; always provide recovery path
2. **Fail Informatively**: Clear errors aid debugging
3. **Fail Safely**: Errors shouldn't expose vulnerabilities
4. **Fail Forward**: Learn from errors to prevent recurrence

### Error Hierarchy

```yaml
error_severity:
  critical:
    description: System-breaking, data loss risk
    action: immediate_halt
    notification: all_stakeholders
    
  high:
    description: Feature broken, significant impact
    action: stop_operation
    notification: team
    
  medium:
    description: Degraded functionality
    action: log_and_continue
    notification: monitoring
    
  low:
    description: Minor issues, warnings
    action: log_only
    notification: debug_logs
```

## Error Classification

### 1. User Errors

**Characteristics**: Caused by user input or actions

**Examples**:
- Invalid input data
- Missing required parameters
- Incorrect command syntax
- Out-of-range values

**Handling**:
```typescript
interface UserError {
  type: 'user_error';
  message: string;           // User-friendly message
  field?: string;            // Which input caused error
  expected: string;          // What was expected
  received: string;          // What was received
  suggestion: string;        // How to fix
  examples?: string[];       // Valid examples
}
```

**Response Pattern**:
```markdown
❌ **Input Error**: [Field] is invalid

**Expected**: [Description of valid input]
**Received**: [What user provided]

**Fix**: [Clear correction steps]

**Example**: [Show valid input]
```

### 2. System Errors

**Characteristics**: Internal failures, not user-caused

**Examples**:
- File system errors
- Network failures
- Memory exhaustion
- Dependency failures

**Handling**:
```typescript
interface SystemError {
  type: 'system_error';
  code: string;              // Error code
  message: string;           // Internal description
  userMessage: string;       // User-safe message
  cause?: Error;             // Root cause
  recoverable: boolean;      // Can retry?
  recovery?: RecoveryPlan;   // How to recover
}
```

**Response Pattern**:
```markdown
⚠️ **System Issue**: [User-safe description]

**What We're Doing**: [Automatic recovery attempts]

**What You Can Do**: [User actions if any]

**Status**: [Current state]
```

### 3. Validation Errors

**Characteristics**: Data doesn't meet requirements

**Examples**:
- Schema violations
- Constraint failures
- Type mismatches
- Business rule violations

**Handling**:
```typescript
interface ValidationError {
  type: 'validation_error';
  field: string;
  rule: string;              // Which rule failed
  message: string;
  value: any;                // Failed value
  constraints: any;          // Rule parameters
}
```

**Response Pattern**:
```markdown
❌ **Validation Failed**: [Field name]

**Rule**: [Which constraint]
**Issue**: [Why it failed]
**Fix**: [How to correct]

**Valid Range**: [Acceptable values]
```

### 4. Permission Errors

**Characteristics**: Insufficient authorization

**Examples**:
- Missing permissions
- Unauthorized access
- Rate limiting
- Resource restrictions

**Handling**:
```typescript
interface PermissionError {
  type: 'permission_error';
  resource: string;          // What was accessed
  required: Permission[];    // Needed permissions
  current: Permission[];     // Current permissions
  suggestion: string;        // How to get access
}
```

**Response Pattern**:
```markdown
🔒 **Access Denied**: [Resource]

**Required**: [Permissions needed]
**Current**: [Your permissions]

**To Gain Access**: [Steps to request permission]
```

### 5. Operational Errors

**Characteristics**: Expected failure conditions

**Examples**:
- File not found
- Resource busy
- Timeout
- Rate limited

**Handling**:
```typescript
interface OperationalError {
  type: 'operational_error';
  operation: string;
  reason: string;
  retryable: boolean;
  retryAfter?: number;
  alternative?: string;
}
```

**Response Pattern**:
```markdown
⏸️ **Operation Failed**: [What was attempted]

**Reason**: [Why it failed]
**Retry**: [Whether retry would help]
**Alternative**: [Different approach]
```

## Error Recovery Strategies

### 1. Retry with Backoff

```typescript
interface RetryPolicy {
  maxAttempts: number;
  initialDelay: number;
  maxDelay: number;
  backoffMultiplier: number;
  retryableErrors: string[];
}

async function retryWithBackoff<T>(
  operation: () => Promise<T>,
  policy: RetryPolicy
): Promise<T> {
  let attempt = 0;
  let delay = policy.initialDelay;
  
  while (attempt < policy.maxAttempts) {
    try {
      return await operation();
    } catch (error) {
      attempt++;
      
      if (!isRetryable(error, policy) || attempt >= policy.maxAttempts) {
        throw error;
      }
      
      await sleep(delay);
      delay = Math.min(delay * policy.backoffMultiplier, policy.maxDelay);
    }
  }
  
  throw new Error(`Failed after ${policy.maxAttempts} attempts`);
}
```

### 2. Fallback Strategy

```typescript
interface FallbackChain<T> {
  primary: () => Promise<T>;
  fallbacks: Array<() => Promise<T>>;
  description: string;
}

async function executeWithFallback<T>(
  chain: FallbackChain<T>
): Promise<T> {
  const attempts: Array<{method: string, error?: Error}> = [];
  
  try {
    return await chain.primary();
  } catch (primaryError) {
    attempts.push({method: 'primary', error: primaryError});
    
    for (let i = 0; i < chain.fallbacks.length; i++) {
      try {
        const result = await chain.fallbacks[i]();
        logFallbackSuccess(attempts, i);
        return result;
      } catch (fallbackError) {
        attempts.push({method: `fallback-${i}`, error: fallbackError});
      }
    }
    
    throw new FallbackExhaustedError(chain.description, attempts);
  }
}
```

### 3. Circuit Breaker

```typescript
class CircuitBreaker {
  private state: 'closed' | 'open' | 'half-open' = 'closed';
  private failures: number = 0;
  private lastFailure?: Date;
  
  constructor(
    private threshold: number,
    private timeout: number,
    private resetTimeout: number
  ) {}
  
  async execute<T>(operation: () => Promise<T>): Promise<T> {
    if (this.state === 'open') {
      if (this.shouldAttemptReset()) {
        this.state = 'half-open';
      } else {
        throw new CircuitOpenError();
      }
    }
    
    try {
      const result = await this.executeWithTimeout(operation);
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  private onSuccess(): void {
    this.failures = 0;
    this.state = 'closed';
  }
  
  private onFailure(): void {
    this.failures++;
    this.lastFailure = new Date();
    
    if (this.failures >= this.threshold) {
      this.state = 'open';
    }
  }
}
```

### 4. Graceful Degradation

```typescript
interface DegradationLevel {
  name: string;
  features: string[];
  performance: number;    // Percentage of normal
}

const degradationLevels: DegradationLevel[] = [
  {
    name: 'full',
    features: ['all'],
    performance: 100
  },
  {
    name: 'reduced',
    features: ['core', 'essential'],
    performance: 70
  },
  {
    name: 'minimal',
    features: ['core'],
    performance: 40
  },
  {
    name: 'emergency',
    features: ['critical-only'],
    performance: 10
  }
];

function degrade(currentLevel: string, error: Error): DegradationLevel {
  const current = degradationLevels.findIndex(l => l.name === currentLevel);
  const next = current + 1;
  
  if (next >= degradationLevels.length) {
    throw new SystemFailureError('Cannot degrade further');
  }
  
  return degradationLevels[next];
}
```

## Error Logging

### Log Levels

```yaml
log_levels:
  debug:
    when: development
    includes: [stack_traces, variable_values, flow_info]
  
  info:
    when: normal_operations
    includes: [operation_started, operation_completed]
  
  warn:
    when: degraded_operation
    includes: [error_details, recovery_actions]
  
  error:
    when: operation_failed
    includes: [error_details, user_impact, recovery_status]
  
  critical:
    when: system_failure
    includes: [full_context, all_attempts, escalation_path]
```

### Structured Logging

```typescript
interface ErrorLog {
  timestamp: string;
  level: LogLevel;
  error: {
    type: string;
    code: string;
    message: string;
    stack?: string;
  };
  context: {
    operation: string;
    user?: string;
    session?: string;
    environment: string;
  };
  recovery: {
    attempted: RecoveryAttempt[];
    successful: boolean;
    fallback?: string;
  };
  impact: {
    severity: Severity;
    affected_users?: number;
    downtime?: number;
  };
}
```

## Error Propagation

### Guidelines

1. **Catch at appropriate level**: Don't catch just to rethrow
2. **Add context**: Enrich errors as they bubble up
3. **Preserve cause chain**: Maintain error lineage
4. **Convert at boundaries**: Change error types when crossing layers

### Example

```typescript
// Domain Layer
class DomainError extends Error {
  constructor(
    message: string,
    public code: string,
    public cause?: Error
  ) {
    super(message);
  }
}

// Application Layer - adds business context
try {
  await domainOperation();
} catch (error) {
  throw new ApplicationError(
    'Business operation failed',
    'BIZ_001',
    error  // Preserve cause
  );
}

// API Layer - converts to HTTP
try {
  await applicationOperation();
} catch (error) {
  if (error instanceof ApplicationError) {
    return {
      status: 400,
      body: {
        error: error.code,
        message: sanitizeForUser(error.message)
      }
    };
  }
  // ... handle other error types
}
```

## User Communication

### Error Message Template

```markdown
## [Severity Icon] [Brief Description]

### What Happened
[Clear explanation of the error]

### Why It Happened  
[Root cause in simple terms]

### What We're Doing
[Automatic recovery steps]

### What You Can Do
1. [Action 1]
2. [Action 2]

### Need Help?
[Where to get support]

### Technical Details
<details>
<summary>For debugging (optional)</summary>

- Error Code: [CODE]
- Operation: [OPERATION]
- Timestamp: [TIME]
- Trace ID: [ID]

</details>
```

### Communication Principles

**Do**:
- Lead with impact, not technical details
- Provide clear next steps
- Offer alternatives when possible
- Show empathy and understanding
- Include helpful context

**Don't**:
- Blame the user
- Use technical jargon
- Expose system internals
- Leave user stranded
- Make promises you can't keep

## Error Prevention

### Input Validation

```typescript
function validateAndSanitize(input: any, schema: Schema): ValidationResult {
  const errors: ValidationError[] = [];
  
  // Type checking
  if (!checkTypes(input, schema)) {
    errors.push(typeError(input, schema));
  }
  
  // Range validation
  if (!checkRanges(input, schema)) {
    errors.push(rangeError(input, schema));
  }
  
  // Pattern matching
  if (!checkPatterns(input, schema)) {
    errors.push(patternError(input, schema));
  }
  
  // Business rules
  if (!checkBusinessRules(input, schema)) {
    errors.push(businessRuleError(input, schema));
  }
  
  return {
    valid: errors.length === 0,
    errors,
    sanitized: sanitize(input)
  };
}
```

### Defensive Programming

```typescript
// Check preconditions
function processData(data: any): Result {
  assert(data !== null, 'Data cannot be null');
  assert(data.length > 0, 'Data cannot be empty');
  assert(isValid(data), 'Data must be valid');
  
  // Safe operation
  try {
    return doProcess(data);
  } catch (error) {
    // Ensure postconditions even in error
    cleanup();
    throw error;
  }
}

// Check invariants
class Account {
  private balance: number = 0;
  
  withdraw(amount: number): void {
    assert(amount > 0, 'Amount must be positive');
    assert(this.balance >= amount, 'Insufficient funds');
    
    this.balance -= amount;
    
    assert(this.balance >= 0, 'Balance invariant violated');
  }
}
```

## Error Testing

### Test Categories

```typescript
describe('Error Handling', () => {
  describe('User Errors', () => {
    it('should reject invalid input');
    it('should provide helpful error message');
    it('should suggest valid alternatives');
  });
  
  describe('System Errors', () => {
    it('should retry transient failures');
    it('should fall back to alternative');
    it('should log error details');
  });
  
  describe('Recovery', () => {
    it('should recover from partial failure');
    it('should restore consistent state');
    it('should maintain data integrity');
  });
});
```

## Error Checklist

Before releasing:

- [ ] All error cases identified
- [ ] Clear error messages written
- [ ] Recovery strategies implemented
- [ ] Fallbacks tested
- [ ] Logs structured properly
- [ ] User communication clear
- [ ] No sensitive data in errors
- [ ] Retry logic appropriate
- [ ] Circuit breakers configured
- [ ] Monitoring alerts set

## Version History

- v1.0.0 (2024-12-09): Initial error handling instructions

---

**Remember**: Good error handling is invisible when things work, invaluable when they don't.
