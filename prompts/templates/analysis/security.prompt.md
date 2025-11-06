---
mode: Agent
model: Auto
tools: []
id: "analysis.security"
version: "1.0.0"
category: "analysis"
name: "Security Analysis Template"
description: "Template for security vulnerability analysis"
placeholders:
  - name: "codeToAnalyze"
    type: "string"
    required: true
  - name: "language"
    type: "string"
    required: true
  - name: "context"
    type: "string"
    required: false
examples:
  - name: "Check authentication logic"
    input:
      codeToAnalyze: "function login(username, password) { return db.findUser(username) && password === user.password; }"
      language: "typescript"
      context: "User authentication endpoint"
---

# Security Analysis

Analyze this **{{language}}** code for security vulnerabilities:

```{{language}}
{{codeToAnalyze}}
```

{{#if context}}
**Context**: {{context}}
{{/if}}

## Security Review

### Vulnerability Check
- [ ] Input validation (SQL injection, XSS)
- [ ] Authentication bypass
- [ ] Authorization flaws
- [ ] Sensitive data exposure
- [ ] Insecure dependencies
- [ ] Weak cryptography
- [ ] CSRF/CORS issues
- [ ] Rate limiting gaps

### Issues Found

**🔴 Critical**:
1. [Vulnerability and fix]
2. [Vulnerability and fix]

**🟡 High**:
1. [Issue and mitigation]
2. [Issue and mitigation]

**🔵 Medium**:
1. [Issue and solution]

### Recommendations

1. **Input Validation**: Sanitize all external inputs
2. **Authentication**: Use industry-standard methods
3. **Secrets**: Never hardcode credentials
4. **Dependencies**: Keep packages updated
5. **Logging**: Log security events securely
6. **Testing**: Include security test cases

### Secure Code

Provide improved code fixing all critical issues.

---

**See Also**: `analysis.code-review`
