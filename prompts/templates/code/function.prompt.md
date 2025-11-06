---
mode: Edit
model: Auto
tools: []
id: "code.function"
version: "1.0.0"
category: "code"
name: "Function Template"
description: "Template for generating function implementations"
placeholders:
  - name: "functionName"
    type: "string"
    required: true
    description: "Name of the function"
  - name: "language"
    type: "string"
    required: true
    enum: ["typescript", "javascript", "python", "java", "csharp", "go", "rust"]
  - name: "parameters"
    type: "array"
    required: true
    description: "Function parameters"
  - name: "returnType"
    type: "string"
    required: true
    description: "Return type"
  - name: "description"
    type: "string"
    required: true
examples:
  - name: "Async API function"
    input:
      functionName: "fetchUserById"
      language: "typescript"
      parameters: ["id: string"]
      returnType: "Promise<User>"
      description: "Fetch user by ID from API"
---

# Function Implementation

Generate a **{{language}}** function:

**Name**: `{{functionName}}`  
**Parameters**: {{#each parameters}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}  
**Returns**: `{{returnType}}`

## Purpose
{{description}}

## Requirements

1. **Complete Implementation**: Fully functional code, not stubs
2. **Documentation**: Language-appropriate comments (JSDoc/docstring/Javadoc)
3. **Error Handling**: Input validation and proper error handling
4. **Edge Cases**: Handle null, empty, boundary values
5. **Type Safety**: Proper type annotations/hints
6. **Best Practices**: Clear naming, focused logic, DRY principle
7. **Testability**: Design for easy unit testing

## Output

Provide:
- Full function implementation with all logic
- Comprehensive documentation
- Error handling and validation
- Example usage in comments
- Edge case handling

---

**See Also**: `code.class`, `code.test`
