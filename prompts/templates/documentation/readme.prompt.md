---

mode: Edit
model: Auto
tools: []
id: "documentation.readme"
version: "1.0.0"
category: "documentation"
name: "README Template"
description: "Template for generating project README files"
placeholders:
  - name: "projectName"
    type: "string"
    required: true
  - name: "description"
    type: "string"
    required: true
  - name: "features"
    type: "array"
    required: true
  - name: "quickStart"
    type: "string"
    required: false
examples:
  - name: "Web Framework README"
    input:
      projectName: "FastAPI Server"
      description: "High-performance async web framework"
      features: ["Async/await support", "Type hints", "Auto API docs"]
      quickStart: "pip install fastapi && uvicorn main:app"

---

# README Generation

Generate README for: **{{projectName}}**

## Essential Sections

1. **Title & Description**: {{description}}

2. **Features**:
{{#each features}}
   - {{this}}
{{/each}}

3. **Quick Start**: {{#if quickStart}}{{quickStart}}{{else}}Installation and basic usage{{/if}}

4. **Installation**: Step-by-step setup instructions

5. **Usage**: Basic examples and common patterns

6. **Documentation**: Links to detailed docs

7. **Contributing**: How to contribute

8. **License**: License information

## Quality Standards

- Clear, concise language
- Markdown formatting
- Working code examples
- Current information
- Organized sections
- Links to detailed docs

## Output

Provide complete README with:
- Engaging introduction
- Clear feature list
- Working quick-start example
- Installation instructions
- Basic usage examples
- Links section
- Contributing guidelines

---

**See Also**: `documentation.inline-comment`
