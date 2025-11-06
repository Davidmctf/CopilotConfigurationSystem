---
applyTo: '**'
description: 'Modular capability for providing intelligent code assistance across languages and frameworks.'
id: capability.code-assistance
version: 1.0.0
category: capability
type: mixin
requires: [core.safety, core.communication]
provides: [code_generation, code_analysis, code_refactoring]
---

# Code Assistance Capability

## Purpose
Modular capability for providing intelligent code assistance across languages and frameworks.

## Capability Overview

### What This Capability Enables

- **Code Generation**: Create new code from specifications
- **Code Analysis**: Review and evaluate existing code
- **Code Refactoring**: Improve code structure and quality
- **Code Documentation**: Generate and maintain documentation
- **Code Debugging**: Identify and fix issues

### Language Agnostic Principles

This capability works across languages by focusing on:
- Universal programming concepts
- Language-specific best practices
- Framework conventions
- Community standards

## Code Generation

### Generation Patterns

#### 1. From Specification

```markdown
Input: Functional requirements
Output: Implementation

Process:
1. Understand requirements
2. Choose appropriate patterns
3. Generate code structure
4. Add implementation details
5. Include documentation
6. Add error handling
```

#### 2. From Examples

```markdown
Input: Reference implementation
Output: Similar code for new context

Process:
1. Analyze example structure
2. Extract patterns
3. Adapt to new context
4. Maintain idioms
5. Preserve intent
```

#### 3. From Tests

```markdown
Input: Test cases
Output: Implementation that passes tests

Process:
1. Understand test expectations
2. Design minimal implementation
3. Verify against tests
4. Refine as needed
```

### Code Quality Standards

#### Must Include

✅ **Always**:
- Clear variable/function names
- Appropriate comments
- Error handling
- Input validation
- Type safety (where applicable)

✅ **When Relevant**:
- Documentation strings
- Usage examples
- Edge case handling
- Performance considerations
- Security measures

❌ **Avoid**:
- Magic numbers
- Deep nesting
- Long functions
- Unclear intent
- Premature optimization

### Generation Template

```markdown
## Generated Code

### Purpose
[What this code does]

### Approach
[How it accomplishes the goal]

### Usage
```[language]
[Example usage]
```

### Implementation
```[language]
[Actual code]
```

### Notes
- [Important consideration 1]
- [Important consideration 2]

### Testing
[How to verify it works]
```

## Code Analysis

### Analysis Dimensions

#### 1. Correctness

```yaml
checks:
  - logic_errors
  - type_mismatches
  - null_reference_risks
  - race_conditions
  - edge_case_handling
```

#### 2. Security

```yaml
checks:
  - injection_vulnerabilities
  - authentication_issues
  - authorization_flaws
  - data_exposure
  - crypto_misuse
```

#### 3. Performance

```yaml
checks:
  - algorithmic_complexity
  - memory_usage
  - unnecessary_operations
  - database_query_efficiency
  - caching_opportunities
```

#### 4. Maintainability

```yaml
checks:
  - code_complexity
  - coupling_level
  - cohesion_quality
  - naming_clarity
  - documentation_completeness
```

#### 5. Best Practices

```yaml
checks:
  - language_idioms
  - framework_conventions
  - design_patterns
  - error_handling
  - testing_approach
```

### Analysis Report Format

```markdown
## Code Analysis Report

### Summary
[Overall assessment]

### Findings

#### Critical Issues
[Issues requiring immediate attention]

#### Improvements
[Enhancement opportunities]

#### Good Practices
[What's done well]

### Recommendations

#### Priority 1 (Critical)
- [Issue]: [Description]
  - **Impact**: [Severity]
  - **Fix**: [Solution]
  - **Effort**: [Time estimate]

#### Priority 2 (High)
[Similar structure]

#### Priority 3 (Medium)
[Similar structure]

### Code Quality Metrics
- Complexity: [Score]
- Test Coverage: [Percentage]
- Documentation: [Score]
- Security: [Score]
```

## Code Refactoring

### Refactoring Principles

1. **Preserve Behavior**: Don't change what code does
2. **Small Steps**: Incremental changes
3. **Test Coverage**: Verify before/after
4. **Clear Intent**: Each refactor has clear goal
5. **Reversible**: Can undo if needed

### Common Refactorings

#### Extract Function

**When**:
- Code block used multiple times
- Function is too long
- Improve readability

**Pattern**:
```markdown
Before:
[Long function with repeated logic]

After:
[Main function calling extracted helpers]
[Extracted helper functions]
```

#### Rename

**When**:
- Name doesn't reflect purpose
- Terminology changed
- Improve clarity

**Pattern**:
```markdown
Changes:
- Old: `processData()`
- New: `validateAndSanitizeUserInput()`

Rationale: [Why new name is better]
```

#### Extract Variable

**When**:
- Complex expression
- Repeated calculation
- Improve readability

**Pattern**:
```markdown
Before:
if (user.age > 18 && user.hasLicense && user.passedTest) {
  // ...
}

After:
const canDrive = user.age > 18 && user.hasLicense && user.passedTest;
if (canDrive) {
  // ...
}
```

#### Simplify Conditional

**When**:
- Nested conditions
- Complex boolean logic
- Repeated checks

**Pattern**:
```markdown
Before:
[Complex nested if/else]

After:
[Guard clauses + simple conditions]
```

### Refactoring Workflow

```markdown
1. **Identify Smell**: What needs improvement?
2. **Write Tests**: Ensure current behavior
3. **Plan Changes**: Break into small steps
4. **Execute**: One refactor at a time
5. **Verify**: Run tests after each step
6. **Commit**: Save working state
7. **Repeat**: Continue with next refactor
```

## Code Documentation

### Documentation Levels

#### 1. Inline Comments

**When to use**:
- Complex algorithm
- Non-obvious logic
- Workarounds
- Performance optimizations

**Example**:
```language
// Calculate compound interest using continuous compounding
// formula: A = P * e^(rt)
// where P = principal, r = rate, t = time
const amount = principal * Math.exp(rate * time);
```

#### 2. Function Documentation

**Required Information**:
- Purpose
- Parameters
- Return value
- Exceptions
- Examples (if complex)

**Template**:
```language
/**
 * [Brief description]
 *
 * [Detailed explanation if needed]
 *
 * @param {Type} paramName - Description
 * @returns {Type} Description
 * @throws {ErrorType} When [condition]
 *
 * @example
 * // Example usage
 * result = functionName(arg);
 */
```

#### 3. Module/Class Documentation

**Required Information**:
- Purpose and responsibility
- Public interface
- Usage examples
- Related components
- Design decisions

#### 4. README Documentation

**Sections**:
- Overview
- Installation
- Usage
- API Reference
- Examples
- Contributing
- License

### Documentation Standards

**Do**:
- Explain WHY, not just WHAT
- Keep synchronized with code
- Use examples liberally
- Include edge cases
- Note dependencies

**Don't**:
- State the obvious
- Repeat code in prose
- Leave outdated docs
- Write novels
- Use ambiguous language

## Language-Specific Guidelines

### Adaptation Pattern

```yaml
language_guidelines:
  core_principles:
    - [Universal principle 1]
    - [Universal principle 2]
  
  language_specific:
    typescript:
      - Use strong typing
      - Leverage interfaces
      - Employ generics appropriately
    
    python:
      - Follow PEP 8
      - Use type hints
      - Embrace duck typing
    
    [other_languages]:
      - [Language-specific practice]
```

### Convention Sources

```markdown
Priority for conventions:
1. Project-specific guidelines
2. Team standards
3. Framework conventions
4. Language official style guide
5. Community best practices
```

## Testing Integration

### Test-Driven Development

```markdown
TDD Workflow:
1. Write failing test
2. Write minimal code to pass
3. Refactor
4. Repeat

Benefits:
- Clear requirements
- Better design
- Built-in regression tests
- Confidence in changes
```

### Test Categories

```yaml
test_types:
  unit:
    scope: single_function
    dependencies: mocked
    speed: fast
  
  integration:
    scope: multiple_components
    dependencies: real_or_stubbed
    speed: medium
  
  e2e:
    scope: full_system
    dependencies: all_real
    speed: slow
```

## Code Review Support

### Review Checklist

```markdown
- [ ] Functionality correct
- [ ] Error handling appropriate
- [ ] Security vulnerabilities addressed
- [ ] Performance acceptable
- [ ] Tests comprehensive
- [ ] Documentation clear
- [ ] Style consistent
- [ ] No code smells
- [ ] Dependencies necessary
- [ ] Backwards compatible (if applicable)
```

### Review Comment Format

```markdown
**[Severity]**: [Issue or Suggestion]

**Location**: [File:Line or Function]

**Current**: [What code does now]

**Suggested**: [Proposed change]

**Rationale**: [Why this is better]

**Example**: [Show improved code]
```

## Integration Points

### Required Capabilities

This capability requires:
- `core.safety`: For secure code generation
- `core.communication`: For explaining code

### Provides To Other Capabilities

- Code examples for documentation
- Test cases for validation
- Implementation patterns for architecture

### Extension Points

Can be extended with:
- Language-specific plugins
- Framework-specific templates
- Organization coding standards
- AI-assisted code generation

## Usage Examples

### Example 1: Generate Function

```markdown
Request: "Create a function to validate email addresses"

Response:
[Analyze requirements]
[Choose validation approach]
[Generate implementation]
[Add documentation]
[Include tests]
[Explain decisions]
```

### Example 2: Refactor Code

```markdown
Request: "Improve this function's readability"

Response:
[Analyze current code]
[Identify improvements]
[Apply refactorings]
[Show before/after]
[Explain changes]
[Verify behavior preserved]
```

### Example 3: Review Code

```markdown
Request: "Review this authentication module"

Response:
[Security analysis]
[Best practices check]
[Performance review]
[Structured feedback]
[Prioritized recommendations]
```

## Configuration

### Capability Settings

```yaml
code_assistance:
  default_language: [infer_from_context]
  style_guide: [project_specific]
  complexity_threshold: 10
  documentation_required: true
  test_coverage_target: 80
  security_scanning: enabled
```

## Version History

- v1.0.0 (2024-12-09): Initial code assistance capability

---

**Note**: This capability should be composed with others (context-awareness, tool-usage) for full functionality.
