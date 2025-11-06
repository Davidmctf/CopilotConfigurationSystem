---

mode: Edit
model: Auto
tools: []
id: "problem-solving.debug"
version: "1.0.0"
category: "problem-solving"
name: "Debug Template"
description: "Template for debugging code issues"
placeholders:
  - name: "symptom"
    type: "string"
    required: true
    description: "What's going wrong"
  - name: "code"
    type: "string"
    required: true
  - name: "language"
    type: "string"
    required: true
  - name: "errorMessage"
    type: "string"
    required: false
examples:
  - name: "Null pointer exception"
    input:
      symptom: "Function returns undefined when it should return a value"
      code: "function getUser(id) { return users.find(u => u.id === id); }"
      language: "javascript"
      errorMessage: "TypeError: Cannot read property of undefined"

---

# Debug Analysis

**Symptom**: {{symptom}}

{{#if errorMessage}}
**Error**: {{errorMessage}}
{{/if}}

**Code** ({{language}}):
```{{language}}
{{code}}
```

## Diagnosis

### Root Cause Analysis
1. What's happening: [Analysis]
2. Why it's happening: [Explanation]
3. Under what conditions: [Scenarios]

### Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

## Solution

### Immediate Fix
```{{language}}
// Corrected code
[Fixed code]
```

### Why This Works
[Explanation of the fix]

### Prevention
How to avoid this issue:
1. [Strategy]
2. [Strategy]
3. [Testing approach]

## Debugging Strategies

- Add logging/print statements
- Use debugger breakpoints
- Check variable values at key points
- Test with minimal reproducible example
- Review recent changes
- Check edge cases

## Tests to Add

```{{language}}
// Test case that would catch this
test('should handle [edge case]', () => {
  // Test code
});
```

---

**See Also**: `code.test`, `analysis.code-review`
