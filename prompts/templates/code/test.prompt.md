---
mode: Edit
model: Auto
tools: []
id: "code.test"
version: "1.0.0"
category: "code"
name: "Test Template"
description: "Template for generating comprehensive unit tests"
placeholders:
  - name: "targetCode"
    type: "string"
    required: true
    description: "Code to generate tests for"
  - name: "language"
    type: "string"
    required: true
    enum: ["typescript", "javascript", "python", "java", "csharp", "go", "rust"]
    description: "Programming language"
  - name: "testFramework"
    type: "string"
    required: true
    description: "Testing framework to use"
  - name: "coverageGoal"
    type: "number"
    required: false
    default: 80
    description: "Target code coverage percentage"
  - name: "includeEdgeCases"
    type: "boolean"
    required: false
    default: true
    description: "Include edge case tests"
  - name: "includeMocks"
    type: "boolean"
    required: false
    default: true
    description: "Generate mocks for dependencies"
  - name: "testStyle"
    type: "string"
    required: false
    default: "AAA"
    enum: ["AAA", "BDD", "TDD"]
    description: "Test organization style"
examples:
  - name: "Jest/TypeScript tests"
    input:
      targetCode: "async function fetchUser(id: string): Promise<User>"
      language: "typescript"
      testFramework: "jest"
      coverageGoal: 90
---

# Unit Test Generation

Generate {{language}} tests for the following code using **{{testFramework}}**:

```{{language}}
{{targetCode}}
```

## Specification

- **Framework**: {{testFramework}}
- **Coverage Target**: {{coverageGoal}}%
- **Style**: {{testStyle}} (Arrange-Act-Assert / Given-When-Then / Red-Green-Refactor)
- **Edge Cases**: {{#if includeEdgeCases}}Include{{else}}Skip{{/if}}
- **Mocks**: {{#if includeMocks}}Use mocks for dependencies{{else}}Direct calls{{/if}}

## Test Suites

**1. Happy Path**: Valid inputs, expected behavior  
**2. Edge Cases**: {{#if includeEdgeCases}}Empty, null, boundary, invalid types{{else}}N/A{{/if}}  
**3. Error Handling**: Exceptions, invalid inputs, error messages  
**4. Dependencies**: {{#if includeMocks}}Mock external services, verify calls{{else}}N/A{{/if}}  

## Assertions

- **Values**: Equality, type, null checks
- **Collections**: Length, content, order  
- **Exceptions**: Type, message
{{#if includeMocks}}- **Mocks**: Call count, arguments{{/if}}

## Requirements

1. Clear test names describing what is tested
2. {{testStyle}} pattern with proper sections
3. Target {{coverageGoal}}% coverage (all public methods, branches, error paths)
4. Realistic test data using builders/factories
5. Documentation for complex test cases

---

**See Also**: `code.function`, `code.class`, `analysis.code-review`
