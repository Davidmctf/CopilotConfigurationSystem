---
mode: Edit
model: Auto
tools: []
id: "analysis.api-doc"
version: "1.0.0"
category: "analysis"
name: "API Documentation Template"
description: "Template for generating comprehensive API documentation"
placeholders:
  - name: "apiName"
    type: "string"
    required: true
  - name: "endpoints"
    type: "array"
    required: true
    description: "API endpoints to document"
  - name: "authentication"
    type: "string"
    required: false
    description: "Auth method (bearer, api-key, oauth)"
  - name: "format"
    type: "string"
    required: false
    default: "OpenAPI"
examples:
  - name: "REST API docs"
    input:
      apiName: "User Management API"
      endpoints: ["GET /users", "POST /users", "GET /users/{id}"]
      authentication: "bearer"
---

# API Documentation

Generate comprehensive documentation for **{{apiName}}** API.

## Sections Required

1. **Overview**: What the API does, key features

2. **Authentication**: {{#if authentication}}{{authentication}}{{else}}Auth method{{/if}}
   - How to authenticate
   - Token/key requirements

3. **Endpoints**: {{#each endpoints}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}
   - Method and URL
   - Parameters and body
   - Response format
   - Error codes
   - Example requests/responses

4. **Data Models**: Schema definitions for requests/responses

5. **Error Handling**: Common error codes and meanings

6. **Rate Limiting**: Usage limits if applicable

7. **Examples**: Working code examples in 2+ languages

8. **Pagination**: If applicable, how to paginate

## Standards

- {{#if format}}{{format}}{{else}}OpenAPI 3.0{{/if}} format
- Clear endpoint descriptions
- Complete examples
- Type information
- Error documentation
- Authentication details

## Output

Provide:
- Complete API documentation
- All endpoints documented
- Example requests/responses
- Error codes and meanings
- Authentication setup
- Code examples
- Pagination/filtering details

---

**See Also**: `analysis.code-review`
