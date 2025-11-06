---
mode: Edit
model: Auto
tools: []
id: "code.class"
version: "1.0.0"
category: "code"
name: "Class Template"
description: "Template for generating complete class implementations with properties, methods, and documentation"
placeholders:
  - name: "className"
    type: "string"
    required: true
    pattern: "^[A-Z][a-zA-Z0-9]*$"
    description: "Name of the class (PascalCase)"
  - name: "language"
    type: "string"
    required: true
    enum: ["typescript", "javascript", "python", "java", "csharp", "go", "rust"]
    description: "Programming language"
  - name: "properties"
    type: "array"
    required: true
    description: "Class properties/fields"
  - name: "methods"
    type: "array"
    required: true
    description: "Class methods"
  - name: "implements"
    type: "array"
    required: false
    description: "Interfaces to implement"
  - name: "extends"
    type: "string"
    required: false
    description: "Parent class to extend"
  - name: "description"
    type: "string"
    required: true
    description: "What the class represents"
  - name: "includeConstructor"
    type: "boolean"
    required: false
    default: true
    description: "Include constructor/initializer"
  - name: "includeGettersSetters"
    type: "boolean"
    required: false
    default: false
    description: "Generate getters/setters for properties"
examples:
  - name: "Service class with dependency injection"
    input:
      className: "UserService"
      language: "typescript"
      properties: ["private apiClient: ApiClient", "private cache: Map<string, User>"]
      methods: ["async getUser(id: string): Promise<User>", "async updateUser(id: string, data): Promise<User>"]
      description: "User service with caching"
---

# Class Implementation Template

Generate a **{{language}}** class with the following specifications:

## Specification

**Class**: `{{className}}` ({{language}})  
**Purpose**: {{description}}
{{#if extends}}**Extends**: `{{extends}}`{{/if}}  
{{#if implements}}**Implements**: {{#each implements}}`{{this}}`{{#unless @last}}, {{/unless}}{{/each}}{{/if}}

**Properties**: {{#each properties}}`{{this}}`{{#unless @last}} | {{/unless}}{{/each}}  
**Methods**: {{#each methods}}`{{this}}`{{#unless @last}} | {{/unless}}{{/each}}

## Implementation Requirements

1. **Structure**: {{language}} class with properties, constructor, and methods
2. **Documentation**: Language-appropriate comments (JSDoc/docstring/Javadoc/XML)
3. **Constructor**: {{#if includeConstructor}}Initialize all properties{{else}}Default initialization{{/if}}
4. **Getters/Setters**: {{#if includeGettersSetters}}Implement with validation{{else}}Direct access{{/if}}
5. **Methods**: Complete implementations with error handling and input validation
{{#if extends}}6. **Inheritance**: Call parent appropriately, override as needed{{/if}}
{{#if implements}}7. **Interfaces**: Implement all members per contract{{/if}}

## Best Practices

- Single Responsibility Principle
- Encapsulation & proper access modifiers
- Clear, descriptive names
- Dependency injection for external dependencies
- Testable design (no tight coupling)

---

**See Also**: `code.function`, `code.test`, `documentation.api-doc`
