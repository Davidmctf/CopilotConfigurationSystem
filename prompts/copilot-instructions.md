---

description: 'Master documentation for the compositional prompt system'
applyTo: '**'

---

# Prompts System Documentation

## Overview

The **prompts system** is a compositional, platform-agnostic framework for creating reusable prompt templates and combining them into powerful workflows. This system follows the agnostic-cop architecture principles established throughout the project.

## Purpose

The prompts system provides:
- **Reusable Templates**: Atomic prompt templates for specific tasks
- **Compositional Workflows**: Combine templates for complex workflows
- **Variable Substitution**: Dynamic prompt generation
- **Validation**: Schema-based validation
- **Platform Agnosticism**: Works across different AI platforms

## Architecture

```
prompts/
┣ compositions/                                # Template combinations
┃ ┣ code-generation/                           # Complete code generation workflows
┃ ┃ ┣ class-implementation.composition.json
┃ ┃ ┗ function-implementation.composition.json
┃ ┣ code-review / # Code review workflows
┃ ┃ ┣ performance-review.composition.json
┃ ┃ ┗ security-review.composition.json
┃ ┣ documentation/ # Documentation workflows
┃ ┃ ┗ api-documentation.composition.json
┃ ┗ problem-solving/                           # Problem-solving workflows
┃ ┃ ┗ debug-analysis.composition.json
┣ templates/                                   # Atomic, reusable templates
┃ ┣ analysis/                                  # Analysis templates
┃ ┃ ┣ api-doc.prompt.md
┃ ┃ ┣ code-review.prompt.md
┃ ┃ ┣ performance.prompt.md
┃ ┃ ┗ security.prompt.md
┃ ┣ code/                                      # Code generation templates
┃ ┃ ┣ class.prompt.md
┃ ┃ ┣ function.prompt.md
┃ ┃ ┣ refactor.prompt.md
┃ ┃ ┗ test.prompt.md
┃ ┣ core /                                     # Fundamental templates
┃ ┃ ┣ conditional-logic.prompt.md
┃ ┃ ┗ variable-substitution.prompt.md
┃ ┣ documentation/                             # Documentation templates
┃ ┃ ┣ inline-comment.prompt.md
┃ ┃ ┗ readme.prompt.md
┃ ┗ problem-solving/                            # Problem-solving templates
┃   ┣ debug.prompt.md
┃   ┗ optimization.prompt.md
┗ copilot-instructions.md                       # This file

```

## Three-Layer System

### Layer 1: Templates (Atomic)
**Location**: `templates/<category>/*.promp.md`

**Purpose**: Individual, reusable prompt templates for specific tasks

**Format**: Markdown with YAML frontmatter

**Example**: `templates/code/function.promp.md`

**Structure**:
```markdown
---
id: "code.function"
version: "1.0.0"
category: "code"
name: "Function Template"
description: "Template for generating functions"
placeholders:
  - name: "functionName"
    type: "string"
    required: true
---

# Template Content
Use {{placeholders}} for dynamic values
```

**Contains**:
- Template metadata (id, version, category)
- Placeholder definitions with types and validation
- Template content with substitution variables
- Usage examples
- Related templates

### Layer 2: Compositions (Workflows)
**Location**: `compositions/<category>/*.composition.json`

**Purpose**: Combine multiple templates into complete workflows

**Format**: JSON following prompt.schema.json

**Example**: `compositions/code-generation/function-implementation.composition.json`

**Structure**:
```json
{
  "id": "composition.code-generation.function",
  "version": "1.0.0",
  "templates": [
    {"ref": "code.function", "order": 1},
    {"ref": "documentation.inline-comment", "order": 2},
    {"ref": "code.test", "order": 3, "condition": "{{includeTests}}"}
  ],
  "workflow": [
    {"step": 1, "action": "Generate function", "template": "code.function"},
    {"step": 2, "action": "Add documentation", "template": "documentation.inline-comment"}
  ]
}
```

**Contains**:
- Composition metadata
- List of templates to use (by reference)
- Workflow steps
- Examples with inputs
- Target agents and capabilities

### Layer 3: Schema (Validation)
**Location**: `../../schemas/prompt.schema.json`

**Purpose**: Validate template and composition structure

**Validates**:
- Template frontmatter
- Placeholder definitions
- Composition structure
- Template references
- Workflow definitions

## How It Works

### 1. Creating a New Template

```markdown
---
mode: Agent,
model: Auto,
tools: [],
id: "category.template-name"
version: "1.0.0"
category: "code|documentation|analysis|problem-solving|core"
name: "Human Readable Name"
description: "What this template does"
placeholders:
  - name: "variableName"
    type: "string|number|boolean|array|object"
    required: true|false
    description: "What this variable represents"
    enum: ["option1", "option2"]  # optional
    default: "defaultValue"        # optional
examples:
  - name: "Example name"
    input:
      variableName: "value"
---

# Template Content

Use {{variableName}} for substitution.

{{#if conditionalVariable}}
Conditional content
{{/if}}

{{#each arrayVariable}}
- {{this}}
{{/each}}
```

### 2. Creating a Composition

```json
{
  "$schema": "../../schemas/prompt.schema.json",
  "id": "composition.category.name",
  "version": "1.0.0",
  "name": "Composition Name",
  "description": "What this composition does",
  "category": "code-generation|code-review|documentation|problem-solving",
  "mode": "Agent",
  "model": "Auto",
  "tools": [],
  "templates": [
    {
      "ref": "template.id",
      "order": 1,
      "required": true,
      "condition": "{{optionalCondition}}"
    }
  ],
  
  "workflow": [
    {
      "step": 1,
      "action": "What happens in this step",
      "template": "template.id",
      "optional": false
    }
  ],
  
  "examples": [
    {
      "name": "Example name",
      "description": "What this example shows",
      "input": {
        "placeholder1": "value1"
      }
    }
  ]
}
```

### 3. Using a Template

```javascript
// Example: Using function template
const template = loadTemplate('code.function');
const result = template.render({
  functionName: 'calculateTotal',
  parameters: ['items: Item[]', 'tax: number'],
  returnType: 'number',
  language: 'typescript',
  description: 'Calculates total with tax'
});
```

### 4. Using a Composition

```javascript
// Example: Using function implementation composition
const composition = loadComposition('composition.code-generation.function');
const results = composition.execute({
  functionName: 'fetchUserData',
  parameters: ['userId: string'],
  returnType: 'Promise<User>',
  language: 'typescript',
  includeTests: true,
  testFramework: 'jest'
});
// Returns: [function code, documentation, tests]
```

## Available Categories

### ✅ Core Templates
**Purpose**: Fundamental templates used by other templates

**Templates**:
- `variable-substitution` - Variable substitution logic
- `conditional-logic` - Conditional content

**Use For**: Building other templates

---

### ✅ Code Templates
**Purpose**: Code generation and modification

**Templates**:
- `function` - Generate functions
- `class` - Generate classes
- `refactor` - Refactor code
- `test` - Generate tests

**Use For**: Writing, modifying, and testing code

---

### ✅ Documentation Templates
**Purpose**: Generate documentation

**Templates**:
- `api-doc` - API documentation
- `readme` - README files
- `inline-comment` - Code comments

**Use For**: Documenting code, APIs, and projects

---

### ✅ Analysis Templates
**Purpose**: Code analysis and review

**Templates**:
- `code-review` - Comprehensive code review
- `security` - Security analysis
- `performance` - Performance analysis

**Use For**: Code quality, security, and performance analysis

---

### ✅ Problem-Solving Templates
**Purpose**: Debugging and optimization

**Templates**:
- `debug` - Debug issues
- `optimization` - Optimize solutions

**Use For**: Finding and fixing problems, improving code

---

## Available Compositions

### ✅ Code Generation
**Category**: `code-generation/`

**Compositions**:
1. **function-implementation** - Complete function with docs and tests
2. **class-implementation** - Complete class with methods and tests

**Use For**: Generating production-ready code

---

### ✅ Code Review
**Category**: `code-review/`

**Compositions**:
1. **security-review** - Comprehensive security analysis with fixes
2. **performance-review** - Performance analysis with optimizations

**Use For**: Code quality assurance and improvement

---

### ✅ Documentation
**Category**: `documentation/`

**Compositions**:
1. **api-documentation** - Complete API docs with examples

**Use For**: Creating comprehensive documentation

---

### ✅ Problem Solving
**Category**: `problem-solving/`

**Compositions**:
1. **debug-analysis** - Root cause analysis with fix and tests

**Use For**: Debugging and fixing issues systematically

---

## Template Syntax

### Variable Substitution
```markdown
{{variableName}}
```

### Conditional Blocks
```markdown
{{#if condition}}
  Content when true
{{else}}
  Content when false
{{/if}}
```

### Loops
```markdown
{{#each items}}
- {{this}}
{{/each}}
```

### Nested Variables
```markdown
{{object.property}}
{{array[0]}}
```

### Comparison Operators
```markdown
{{#if value == "something"}}
{{#if value > 10}}
{{#if value !== null}}
```

### Logical Operators
```markdown
{{#if condition1 && condition2}}
{{#if condition1 || condition2}}
{{#if !condition}}
```

## Usage Guidelines

### For AI Assistants

When using the prompts system:

1. **Choose the Right Template**
   - Identify the task category
   - Select appropriate template(s)
   - Check template requirements

2. **Provide Complete Inputs**
   - All required placeholders
   - Proper types and formats
   - Valid enum values

3. **Use Compositions for Workflows**
   - Multi-step tasks
   - Complete implementations
   - Quality assurance

4. **Follow Best Practices**
   - Validate inputs
   - Handle errors gracefully
   - Test outputs
   - Document usage

### For Developers

When extending the system:

1. **Creating Templates**
   - Follow naming conventions
   - Use clear placeholders
   - Provide examples
   - Document thoroughly

2. **Creating Compositions**
   - Reference existing templates
   - Define clear workflows
   - Include examples
   - Test thoroughly

3. **Validation**
   - Use prompt.schema.json
   - Validate structure
   - Test with examples
   - Check edge cases

## Integration with Agents

### Compatible Agents
- `baseAgent` - All templates
- `orchestratorAgent` - All compositions

### Required Capabilities
- `code-assistance` - For code templates
- `context-awareness` - For all templates
- `orchestration` - For complex compositions
- `multi-agent-coordination` - For workflow compositions

## Best Practices

### Template Design
1. **Single Responsibility**: One template, one purpose
2. **Clear Placeholders**: Descriptive names and types
3. **Comprehensive Examples**: Multiple use cases
4. **Complete Documentation**: All sections documented
5. **Validation Rules**: Proper constraints

### Composition Design
1. **Logical Flow**: Steps in natural order
2. **Optional Steps**: Use conditions wisely
3. **Clear Examples**: Real-world scenarios
4. **Target Audience**: Specify agents and capabilities
5. **Error Handling**: Handle failures gracefully

### Usage Best Practices
1. **Validate Inputs**: Check before rendering
2. **Handle Errors**: Graceful failure modes
3. **Test Outputs**: Verify results
4. **Version Control**: Track changes
5. **Documentation**: Keep docs updated

## Common Patterns

### Pattern 1: Simple Template
```markdown
---
mode: Agent,
model: Auto,
tools: [],
id: "category.name"
version: "1.0.0"
category: "category"
name: "Template Name"
placeholders:
  - name: "input"
    type: "string"
    required: true
---
Process {{input}}
```

### Pattern 2: Conditional Template
```markdown
{{#if includeOptional}}
Optional content
{{/if}}
```

### Pattern 3: Loop Template
```markdown
{{#each items}}
- Process {{this}}
{{/each}}
```

### Pattern 4: Multi-Step Composition
```json
{
  "templates": [
    {"ref": "step1", "order": 1},
    {"ref": "step2", "order": 2},
    {"ref": "step3", "order": 3}
  ]
}
```

### Pattern 5: Conditional Composition
```json
{
  "templates": [
    {"ref": "always", "order": 1},
    {"ref": "optional", "order": 2, "condition": "{{flag}}"}
  ]
}
```

## Troubleshooting

### Template Not Found
**Problem**: Template reference not found  
**Solution**: Check template ID and path

### Placeholder Missing
**Problem**: Required placeholder not provided  
**Solution**: Provide all required placeholders

### Invalid Type
**Problem**: Placeholder value wrong type  
**Solution**: Check placeholder type requirements

### Syntax Error
**Problem**: Template syntax invalid  
**Solution**: Check Handlebars syntax

### Composition Fails
**Problem**: Composition execution fails  
**Solution**: Check template references and workflow

## Extending the System

### Adding New Templates
1. Create template file in appropriate category
2. Define YAML frontmatter
3. Write template content
4. Add examples
5. Validate against schema

### Adding New Compositions
1. Create composition JSON file
2. Reference existing templates
3. Define workflow
4. Add examples
5. Validate against schema

### Adding New Categories
1. Create category directory in templates/
2. Document category purpose
3. Create initial templates
4. Update this documentation

## Validation

### Template Validation
```bash
# Validate template against schema
validate-template templates/code/function.promp.md
```

### Composition Validation
```bash
# Validate composition against schema
validate-composition compositions/code-generation/function-implementation.composition.json
```

## Versioning

### Template Versioning
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- MAJOR: Breaking changes to placeholder structure
- MINOR: New features, backward compatible
- PATCH: Bug fixes

### Composition Versioning
- Follow semantic versioning
- MAJOR: Breaking changes to template references
- MINOR: New templates added
- PATCH: Bug fixes, documentation updates

## Migration Guide

### From Old System
1. Identify old prompts
2. Extract placeholders
3. Create new templates
4. Convert to new format
5. Validate and test

### Breaking Changes
- Version 2.0.0: New schema format
- Version 1.5.0: Conditional syntax changed
- Version 1.0.0: Initial release

## Performance Considerations

### Template Rendering
- Templates are cached after first load
- Variable substitution is fast
- Conditional blocks add minimal overhead

### Composition Execution
- Templates executed in order
- Async execution where possible
- Results cached per workflow

## Security Considerations

### Input Validation
- All placeholders validated
- Type checking enforced
- Enum values restricted

### Output Sanitization
- No code execution in templates
- Safe variable substitution
- XSS prevention

## Future Enhancements

### Planned Features
- Template inheritance
- Partial templates
- Dynamic template loading
- Visual template editor
- Template marketplace

### Roadmap
- Q1 2025: Template inheritance
- Q2 2025: Partial templates
- Q3 2025: Visual editor
- Q4 2025: Marketplace

## Support

- **Documentation**: This file and individual template docs
- **Examples**: See `examples` in each template
- **Issues**: Report in project issue tracker
- **Discussions**: Project discussions forum

## Contributing

### Adding Templates
1. Fork repository
2. Create template following guidelines
3. Add examples and tests
4. Submit pull request

### Improving Documentation
1. Identify gaps
2. Add clarifications
3. Include examples
4. Submit pull request

## Related Documentation

- [Capabilities](../../instructions/capabilities/) - Agent capabilities
- [Agents](../../agents/) - Agent definitions
- [Chatmodes](../../chatmodes/) - Chatmode compositions
- [Toolsets](../../scripts/) - Available tools
- [Schemas](../../schemas/) - Validation schemas

---

**Version**: 1.0.0  
**Last Updated**: October 16, 2025  
**Status**: ✅ Complete  
**Quality**: Production Ready

---

**END OF PROMPTS SYSTEM DOCUMENTATION**