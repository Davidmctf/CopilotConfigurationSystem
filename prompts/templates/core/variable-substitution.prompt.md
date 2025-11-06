---

mode: Agent
model: Auto
tools: []
id: "core.variable-substitution"
version: "1.0.0"
category: "core"
name: "Variable Substitution"
description: "Core template for variable substitution in prompt generation"
placeholders:
  - name: "variableName"
    type: "string"
    required: true
    description: "Name of the variable to substitute"
  - name: "variableValue"
    type: "string"
    required: true
    description: "Value to substitute into the template"
  - name: "context"
    type: "string"
    required: false
    description: "Additional context for substitution"
examples:
  - name: "Simple substitution"
    input:
      variableName: "username"
      variableValue: "john_doe"
  - name: "With context"
    input:
      variableName: "apiEndpoint"
      variableValue: "/api/v1/users"
      context: "REST API documentation"

---

# Variable Substitution Template

## Purpose
This core template handles variable substitution in prompts, allowing dynamic content generation based on provided values.

## Usage Pattern
```
{{variableName}} = {{variableValue}}
```

## Context
{{#if context}}
**Context**: {{context}}
{{/if}}

## Substitution Rules

1. **Exact Match**: Replace `{{variableName}}` with `{{variableValue}}`
2. **Case Sensitive**: Variable names are case-sensitive
3. **Scope**: Substitution applies to current context only
4. **Validation**: Ensure variable exists before substitution

## Best Practices

- Use descriptive variable names
- Validate values before substitution
- Document expected value types
- Handle missing values gracefully

## Related Templates
- `core.conditional-logic` - For conditional substitutions
- `code.function` - Uses variable substitution
- `documentation.api-doc` - Uses variable substitution

---

**Note**: This is a core template used by most other templates in the system.
