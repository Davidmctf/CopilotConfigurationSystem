---

mode: Agent
model: Auto
tools: []
id: "core.conditional-logic"
version: "1.0.0"
category: "core"
name: "Conditional Logic"
description: "Core template for conditional logic in prompt generation"
placeholders:
  - name: "condition"
    type: "string"
    required: true
    description: "Conditional expression to evaluate"
  - name: "trueContent"
    type: "string"
    required: true
    description: "Content to include if condition is true"
  - name: "falseContent"
    type: "string"
    required: false
    description: "Content to include if condition is false"
  - name: "conditionType"
    type: "string"
    required: false
    default: "if"
    enum: ["if", "if-else", "switch"]
    description: "Type of conditional logic"
examples:
  - name: "Simple if statement"
    input:
      condition: "includeTests == true"
      trueContent: "Generate unit tests"
      conditionType: "if"
  - name: "If-else statement"
    input:
      condition: "language == 'typescript'"
      trueContent: "Use TypeScript syntax"
      falseContent: "Use JavaScript syntax"
      conditionType: "if-else"

---

# Conditional Logic Template

## Purpose
This core template handles conditional logic in prompts, enabling dynamic content based on boolean conditions or expressions.

## Syntax Patterns

### Simple If
```handlebars
{{#if {{condition}}}}
  {{trueContent}}
{{/if}}
```

### If-Else
```handlebars
{{#if {{condition}}}}
  {{trueContent}}
{{else}}
  {{falseContent}}
{{/if}}
```

### Multiple Conditions
```handlebars
{{#if condition1}}
  Content A
{{else if condition2}}
  Content B
{{else}}
  Content C
{{/if}}
```

## Condition Types

### Boolean Conditions
- Direct boolean: `{{enabled}}`
- Comparison: `{{value > 10}}`
- Equality: `{{status == 'active'}}`

### Logical Operators
- AND: `{{condition1 && condition2}}`
- OR: `{{condition1 || condition2}}`
- NOT: `{{!condition}}`

## Use Cases

1. **Optional Sections**
   - Include/exclude content based on flags
   - Example: Include tests only if requested

2. **Language Selection**
   - Generate language-specific syntax
   - Example: TypeScript vs JavaScript

3. **Environment-Specific Content**
   - Development vs production settings
   - Example: Debug logs in dev mode

4. **Feature Flags**
   - Enable/disable features
   - Example: Experimental features

## Best Practices

- Keep conditions simple and readable
- Use descriptive condition names
- Document condition expectations
- Provide default values when possible
- Avoid deeply nested conditions

## Related Templates
- `core.variable-substitution` - Works with conditionals
- `code.function` - Uses conditional logic
- `code.test` - Uses conditional test generation

## Error Handling

- Undefined conditions default to `false`
- Invalid expressions should be caught early
- Provide meaningful error messages

---

**Note**: This template is fundamental for dynamic prompt generation and is used across most compositions.
