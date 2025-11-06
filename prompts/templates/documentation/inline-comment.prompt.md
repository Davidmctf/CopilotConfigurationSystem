---

mode: Edit
model: Auto
tools: []
id: "documentation.inline-comment"
version: "1.0.0"
category: "documentation"
name: "Inline Comment Template"
description: "Template for generating meaningful inline comments"
placeholders:
  - name: "codeSnippet"
    type: "string"
    required: true
    description: "Code to document"
  - name: "language"
    type: "string"
    required: true
    enum: ["typescript", "javascript", "python", "java", "csharp", "go", "rust"]
  - name: "complexity"
    type: "string"
    required: false
    description: "Complexity level (simple/moderate/complex)"
examples:
  - name: "Document algorithm"
    input:
      codeSnippet: "for (let i = 0; i < n; i++) { for (let j = i + 1; j < n; j++) { if (arr[i] > arr[j]) swap(arr, i, j); } }"
      language: "typescript"
      complexity: "moderate"

---

# Inline Documentation

Add meaningful comments to this **{{language}}** code:

```{{language}}
{{codeSnippet}}
```

{{#if complexity}}
**Complexity**: {{complexity}}
{{/if}}

## Comment Guidelines

1. **Explain "Why"**: Not what the code does, but why it's needed
2. **Clarify Intent**: Express business logic and design decisions
3. **Flag Issues**: Mark workarounds, technical debt, or limitations
4. **Simplify Complex Logic**: Break down non-obvious operations
5. **Avoid Redundancy**: Don't repeat what the code clearly shows

## Focus Areas

- Complex algorithms or business logic
- Non-obvious parameter usage
- Performance considerations
- Edge case handling
- References to external systems
- Justification for design decisions

## Best Practices

- Use single-line comments for clarity
- Place comments before the code they explain
- Keep comments concise and relevant
- Update comments when code changes
- Avoid commented-out code

## Output

Provide the code with inline comments that improve understanding without over-commenting.

---

**See Also**: `documentation.readme`, `code.function`
