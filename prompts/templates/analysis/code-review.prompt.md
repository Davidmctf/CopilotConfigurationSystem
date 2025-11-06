---
mode: Agent
model: Auto
tools: []
id: "analysis.code-review"
version: "1.0.0"
category: "analysis"
name: "Code Review Template"
description: "Template for conducting comprehensive code reviews"
placeholders:
  - name: "codeToReview"
    type: "string"
    required: true
    description: "Code to review"
  - name: "language"
    type: "string"
    required: true
    enum: ["typescript", "javascript", "python", "java", "csharp", "go", "rust"]
    description: "Programming language"
  - name: "focusAreas"
    type: "array"
    required: false
    description: "Specific areas to review"
  - name: "context"
    type: "string"
    required: false
    description: "Project context or purpose"
examples:
  - name: "Review API endpoint"
    input:
      codeToReview: "async function createUser(data) { const user = new User(data); await db.save(user); return user; }"
      language: "typescript"
      focusAreas: ["security", "performance"]
      context: "REST API user creation"
---

# Code Review

Review the following **{{language}}** code:

```{{language}}
{{codeToReview}}
```

{{#if context}}
**Context**: {{context}}
{{/if}}

{{#if focusAreas}}
**Focus Areas**: {{#each focusAreas}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}
{{/if}}

## Review Checklist

### Functionality
- [ ] Code does what it's intended to do
- [ ] Logic is correct and handles edge cases
- [ ] No obvious bugs or issues
- [ ] Error handling is appropriate

### Code Quality
- [ ] Clear and descriptive naming
- [ ] Proper encapsulation and separation of concerns
- [ ] No code duplication (DRY principle)
- [ ] Functions/methods are focused (single responsibility)
- [ ] Reasonable cyclomatic complexity

### Readability & Maintainability
- [ ] Code is easy to understand
- [ ] Comments explain "why", not "what"
- [ ] Consistent style and formatting
- [ ] Well-documented APIs
- [ ] Easy to debug and test

### Performance
- [ ] No obvious performance issues
- [ ] Appropriate algorithms and data structures
- [ ] No unnecessary operations or iterations
- [ ] Proper caching/memoization if applicable

### Security
- [ ] Input validation and sanitization
- [ ] No hardcoded secrets or credentials
- [ ] Proper access control
- [ ] Safe handling of sensitive data
- [ ] Protection against common vulnerabilities

### Testing
- [ ] Code is testable
- [ ] Dependencies are injectable
- [ ] Adequate test coverage
- [ ] Edge cases considered

### Maintainability
- [ ] Easy to extend
- [ ] Proper error handling
- [ ] No tight coupling
- [ ] Clear dependencies

## Findings

### 🔴 Critical Issues
List any critical bugs or security issues that must be fixed:
1. [Issue]
2. [Issue]

### 🟡 Major Issues
List any significant design or quality issues:
1. [Issue]
2. [Issue]

### 🔵 Minor Issues
List any minor improvements or style issues:
1. [Issue]
2. [Issue]

### ✅ Strengths
Highlight what was done well:
1. [Strength]
2. [Strength]

## Recommendations

### Required Changes
What must be fixed before merging:
1. [Recommendation]
2. [Recommendation]

### Suggested Improvements
What would be nice to improve:
1. [Suggestion]
2. [Suggestion]

## Summary

**Overall Assessment**: [Approve/Request Changes/Reject]

**Key Takeaways**:
- [Summary point 1]
- [Summary point 2]
- [Summary point 3]

---

**See Also**: `code.refactor`, `code.test`
