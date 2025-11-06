---
mode: Edit
model: Auto
tools: []
id: "code.refactor"
version: "1.0.0"
category: "code"
name: "Refactor Template"
description: "Template for refactoring existing code with improvement recommendations"
placeholders:
  - name: "originalCode"
    type: "string"
    required: true
    description: "The code to be refactored"
  - name: "language"
    type: "string"
    required: true
    enum: ["typescript", "javascript", "python", "java", "csharp", "go", "rust"]
    description: "Programming language"
  - name: "refactorGoal"
    type: "string"
    required: true
    enum: ["readability", "performance", "maintainability", "testability", "security", "modernization"]
    description: "Primary goal of refactoring"
  - name: "preserveBehavior"
    type: "boolean"
    required: false
    default: true
    description: "Must preserve existing behavior exactly"
  - name: "breakingChangesAllowed"
    type: "boolean"
    required: false
    default: false
    description: "Can introduce breaking API changes"
  - name: "additionalContext"
    type: "string"
    required: false
    description: "Additional context about the code"
examples:
  - name: "Improve readability"
    input:
      originalCode: "function x(a,b){return a>b?a:b}"
      language: "javascript"
      refactorGoal: "readability"
      preserveBehavior: true
---

# Code Refactoring Template

Refactor the following **{{language}}** code with focus on **{{refactorGoal}}**:

## Original Code

```{{language}}
{{originalCode}}
```

{{#if additionalContext}}
## Context
{{additionalContext}}
{{/if}}

## Refactoring Constraints

- **Preserve Behavior**: {{preserveBehavior}}
- **Breaking Changes Allowed**: {{breakingChangesAllowed}}
- **Primary Goal**: {{refactorGoal}}

## Refactoring Focus

Goal: {{refactorGoal}}
{{#if refactorGoal == "readability"}}- Improve naming, extract constants, simplify expressions{{else if refactorGoal == "performance"}}- Optimize algorithms, reduce operations, improve data structures{{else if refactorGoal == "maintainability"}}- Break functions, reduce coupling, add docs{{else if refactorGoal == "testability"}}- Extract dependencies, reduce side effects{{else if refactorGoal == "security"}}- Fix vulnerabilities, validate inputs{{else if refactorGoal == "modernization"}}- Use modern features, update APIs{{/if}}

## Refactored Code

Provide the improved code with:

### Implementation
```{{language}}
// Refactored version
[Improved code here]
```

### Key Changes
List the major changes made:
1. **Change 1**: [Description and rationale]
2. **Change 2**: [Description and rationale]
3. **Change 3**: [Description and rationale]

### Improvements Achieved
Quantify improvements where possible:
{{#if refactorGoal == "readability"}}
- Cyclomatic complexity: Before → After
- Average line length: Before → After
- Comment-to-code ratio improved
{{else if refactorGoal == "performance"}}
- Time complexity: O(?) → O(?)
- Space complexity: O(?) → O(?)
- Estimated performance gain: X%
{{else if refactorGoal == "maintainability"}}
- Function/method count: Before → After
- Lines per function: Before → After
- Coupling score improved
{{else if refactorGoal == "testability"}}
- Testable units: Before → After
- Dependencies reducible: Yes/No
- Mock-friendly: Yes/No
{{/if}}

## Verification

{{#if preserveBehavior}}
**Behavior Preservation**: All outputs must match originals for same inputs.
{{else}}
**Behavior Changes**: Document differences and update tests accordingly.
{{/if}}

**Test Coverage**: Ensure refactored code passes all existing tests.

## Breaking Changes

{{#if breakingChangesAllowed}}
If changes break existing code:
1. Document all breaking changes clearly
2. Provide migration path for updating code
3. Note version requirements
{{else}}
No breaking changes - drop-in replacement.
{{/if}}

## Summary

**Goal Achieved**: {{refactorGoal}} improvements applied  
**Behavior Preserved**: {{preserveBehavior}}  
**Tests Required**: Verify all existing tests pass

---

**See Also**: `analysis.code-review`, `code.test`
