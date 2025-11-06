---

description: 'Tool categories and collections documentation for agent scripts'
applyTo: '**'

---

# Toolsets Documentation

## Overview

This directory contains the **scripts** system - a compositional, platform-agnostic framework for defining and organizing tools that agents can use to perform actions. The system follows the agnostic-cop architecture principles established in the rest of the project.

## Purpose

The scripts system provides:
- **Modular tool definitions** - Individual tools with complete specifications
- **Categorical organization** - Tools grouped by purpose and domain
- **Compositional collections** - Reusable scripts that combine related tools
- **Validation and safety** - Schema-based validation and permission control
- **Platform agnosticism** - Works across different environments and platforms

## Architecture

```
scripts/
┣ categories/              # Tool category documentation
┃ ┣ filesystem.category.md
┃ ┣ git.category.md (future)
┃ ┗ copilot-instructions.md (this file)
┃
┣ tools/                   # Individual tool definitions
┃ ┣ filesystem/
┃ ┃ ┣ read_file.tool.jsonc
┃ ┃ ┣ write_file.tool.jsonc
┃ ┃ ┣ list_directory.tool.jsonc
┃ ┃ ┗ search_files.tool.jsonc
┃ ┗ git/ (future)
┃
┗ collections/             # Tool collections (scripts)
  ┣ basic.script.jsonc
  ┣ advanced.script.jsonc (future)
  ┗ orchestrator.script.jsonc (future)
```

## Three-Layer System

### Layer 1: Categories (Documentation)
**Location**: `categories/*.category.md`

**Purpose**: High-level documentation explaining the purpose, use cases, and best practices for a category of related tools.

**Example**: `filesystem.category.md` documents all filesystem operations

**Contains**:
- Category overview and purpose
- List of tools in the category
- Use cases and workflows
- Best practices and security considerations
- Integration points with other categories

### Layer 2: Tools (Definitions)
**Location**: `tools/<category>/*.tool.jsonc`

**Purpose**: Detailed JSON specifications for individual tools following the script schema.

**Example**: `tools/filesystem/read_file.tool.jsonc` defines the read_file tool

**Contains**:
- Tool metadata (id, version, name)
- Function signature and parameters
- Return type and structure
- Error codes and handling
- Permissions required
- Examples and usage notes

### Layer 3: Collections (Compositions)
**Location**: `collections/*.script.jsonc`

**Purpose**: Curated collections of tools grouped for specific agent capabilities or use cases.

**Example**: `basic.script.jsonc` combines essential filesystem tools

**Contains**:
- Collection metadata
- List of included tools (by reference)
- Combined permissions
- Use cases for the collection
- Best practices for using the collection

## How It Works

### 1. Define Individual Tools
Each tool is defined in its own JSON file following the schema:

```json
{
  "$schema": "../../../schemas/script.schema.json",
  "id": "tool_name",
  "version": "1.0.0",
  "name": "Human Readable Name",
  "description": "What the tool does",
  "category": "filesystem",
  "function": "filesystem:function_name",
  "parameters": { /* JSON Schema */ },
  "permissions": { /* Required permissions */ },
  "metadata": { /* Additional info */ }
}
```

### 2. Document in Categories
Create a `.category.md` file that explains the purpose and usage of all tools in that category.

### 3. Compose Collections
Create script collections that reference tools by ID:

```json
{
  "id": "basic",
  "version": "1.0.0",
  "name": "Basic Toolset",
  "tools": [
    "filesystem.read_file",
    "filesystem.write_file"
  ],
  "permissions": { /* Combined permissions */ }
}
```

### 4. Reference from Agents
Agents reference scripts in their configuration:

```json
{
  "agent": "baseAgent",
  "scripts": ["basic"],
  "capabilities": ["code-assistance", "context-awareness"]
}
```

## Available Categories

### ✅ Filesystem
**Status**: Implemented  
**File**: [filesystem.category.md](./filesystem.category.md)

**Tools**:
- `read_file` - Read text files
- `write_file` - Create/overwrite files
- `list_directory` - List directory contents
- `search_files` - Search for files by pattern

**Use For**: File operations, code analysis, configuration management, project setup

### 🔄 Git (Future)
**Status**: Planned  
**File**: `git.category.md` (to be created)

**Tools** (planned):
- `git_status` - Check repository status
- `git_commit` - Create commits
- `git_diff` - View differences
- `git_log` - View commit history

**Use For**: Version control operations, commit management, history analysis

### 🔄 Code Analysis (Future)
**Status**: Planned  
**File**: `code-analysis.category.md` (to be created)

**Tools** (planned):
- `analyze_complexity` - Calculate complexity metrics
- `find_dependencies` - Extract dependencies
- `detect_issues` - Identify code issues
- `suggest_improvements` - Generate improvement suggestions

**Use For**: Code quality analysis, refactoring support, technical debt assessment

### 🔄 Orchestration (Future)
**Status**: Planned  
**File**: `orchestration.category.md` (to be created)

**Tools** (planned):
- `analyze_request` - Analyze user requests
- `decompose_task` - Break down complex tasks
- `select_agent` - Choose appropriate agent
- `monitor_execution` - Track task progress

**Use For**: Multi-agent coordination, workflow management, task orchestration

## Available Collections

### ✅ Basic Toolset
**Status**: Implemented  
**File**: [../collections/basic.script.json](../collections/basic.script.jsonc)

**Includes**:
- Essential filesystem operations
- Read and write capabilities
- Directory navigation
- File search

**Target Agents**: baseAgent, all agents  
**Use Cases**: General file operations, basic automation

### 🔄 Advanced Toolset (Future)
**Status**: Planned

**Will Include**:
- All basic tools
- File deletion and move operations
- Binary file handling
- Advanced search features

**Target Agents**: Agents with elevated permissions  
**Use Cases**: Complex file operations, system administration

### 🔄 Orchestrator Toolset (Future)
**Status**: Planned

**Will Include**:
- All advanced tools
- Orchestration tools
- Multi-agent coordination
- Workflow management

**Target Agents**: orchestratorAgent  
**Use Cases**: Complex workflows, multi-agent coordination

## Usage Guidelines

### For AI Assistants Working on This Project

When creating or modifying tools:

1. **Always validate against schema**
   ```bash
   # Validate tool definition
   jsonschema -i tools/category/tool.tool.json schemas/script.schema.json
   ```

2. **Follow naming conventions**
   - Categories: `category.category.md`
   - Tools: `tool_name.tool.jsonc`
   - Collections: `collection_name.script.jsonc`

3. **Include complete examples**
   - Every tool needs practical examples
   - Show common use cases
   - Include error scenarios

4. **Document permissions clearly**
   - Specify exactly what permissions are needed
   - Explain why permissions are required
   - Note security implications

5. **Maintain composability**
   - Tools should be independently usable
   - Collections should reference, not duplicate
   - Follow single responsibility principle

### For Agents Using Tools

When using tools from collections:

1. **Check permissions first**
   - Verify you have required permissions
   - Request additional permissions if needed
   - Explain why permissions are necessary

2. **Validate inputs**
   - All paths should be validated
   - Check for directory traversal attempts
   - Sanitize user inputs

3. **Handle errors gracefully**
   - Check error codes
   - Provide clear error messages
   - Suggest alternative actions

4. **Follow best practices**
   - Read tool usage notes
   - Apply recommended patterns
   - Respect security constraints

## Integration with Other Systems

### Agents
**Location**: `agents/*/config.json`

Agents reference scripts in their configuration:
```json
{
  "scripts": ["basic", "advanced"],
  "capabilities": ["code-assistance"]
}
```

### Capabilities
**Location**: `instructions/capabilities/tool-usage.instructions.md`

The `tool-usage` capability defines how agents should use tools effectively.

### Schemas
**Location**: `schemas/script.schema.json`

The script schema validates all tool and collection definitions.

## Development Workflow

### Adding a New Tool

1. **Create tool definition**
   ```bash
   # Create JSON file in appropriate category
   tools/category/new_tool.tool.jsonc
   ```

2. **Validate against schema**
   ```bash
   jsonschema -i tools/category/new_tool.tool.jsonc schemas/script.schema.json
   ```

3. **Update category documentation**
   ```markdown
   # In categories/category.category.md
   - Add tool to list
   - Document use cases
   - Add examples
   ```

4. **Add to collection**
   ```jsonc
   // In collections/collection.script.jsonc
   "tools": [
     "existing.tool",
     "category.new_tool"  // Add new tool reference
   ]
   ```

### Adding a New Category

1. **Create category documentation**
   ```bash
   categories/new_category.category.md
   ```

2. **Create tools directory**
   ```bash
   mkdir tools/new_category
   ```

3. **Define initial tools**
   ```bash
   # Create at least 2-3 fundamental tools
   tools/new_category/tool1.tool.jsonc
   tools/new_category/tool2.tool.jsonc
   ```

4. **Update this documentation**
   - Add to Available Categories section
   - Document purpose and use cases

### Creating a New Collection

1. **Identify tool needs**
   - What agent or use case needs this?
   - Which tools should be included?
   - What permissions are required?

2. **Create collection file**
   ```bash
   collections/new_collection.script.jsonc
   ```

3. **Reference tools by ID**
   ```jsonc
   {
     "id": "new_collection",
     "tools": [
       "category.tool1",
       "category.tool2"
     ]
   }
   ```

4. **Document use cases**
   - Who uses this collection?
   - What problems does it solve?
   - What are the best practices?

## Best Practices

### Tool Design
- **Single Responsibility**: Each tool does one thing well
- **Clear Interface**: Parameters and returns are well-defined
- **Error Handling**: All error cases are documented
- **Examples**: Practical examples are provided
- **Safety First**: Destructive operations require confirmation

### Category Organization
- **Logical Grouping**: Related tools go together
- **Clear Purpose**: Category purpose is well-defined
- **Complete Documentation**: All aspects are documented
- **Practical Examples**: Real-world use cases shown
- **Integration Guidance**: How it fits with other categories

### Collection Composition
- **Purpose-Driven**: Collections serve specific use cases
- **Minimal**: Include only necessary tools
- **Documented**: Use cases and best practices included
- **Validated**: Follows schema requirements
- **Tested**: Verify all referenced tools exist

## Security Considerations

### Permission Model
- All tools require explicit permissions
- Permissions are validated at runtime
- Agents can only use tools they're authorized for
- Destructive operations require user confirmation

### Path Safety
- All paths are validated
- Directory traversal is prevented
- Access is restricted to allowed directories
- System paths are protected

### Input Validation
- All inputs are sanitized
- Type checking is enforced
- Bounds are validated
- Injection attacks are prevented

## Validation

All tool definitions and collections must validate against the schema:

```bash
# Validate a tool
jsonschema -i tools/filesystem/read_file.tool.jsonc schemas/script.schema.json

# Validate a collection
jsonschema -i collections/basic.script.jsonc schemas/script.schema.json
```

## Future Enhancements

### Planned Features
- Tool versioning and deprecation
- Dynamic tool loading
- Tool usage metrics
- Performance profiling
- Automatic documentation generation

### Planned Categories
- **Git**: Version control operations
- **Code Analysis**: Static analysis and linting
- **Testing**: Test execution and coverage
- **Deployment**: CI/CD and deployment tools
- **Database**: Database operations and queries

### Planned Collections
- **Developer**: Complete development script
- **Reviewer**: Code review and analysis tools
- **Automation**: CI/CD and automation tools
- **Administrator**: System administration tools

## References

- [Toolset Schema](../../schemas/script.schema.json) - Validation schema
- [Tool Usage Capability](../../instructions/capabilities/tool-usage.instructions.md) - How to use tools
- [Agent Configurations](../../agents/) - Agent script references
- [Architecture Documentation](../../copilot-instructions.md) - Overall system architecture

## Version History

- **1.0.0** (2025-10-15) - Initial scripts documentation
  - Filesystem category implemented
  - Basic collection created
  - Documentation established
  - Schema validation in place

---

**Status**: Active Development  
**Completeness**: Phase 1 Complete (Filesystem)  
**Next Steps**: Implement Git and Code Analysis categories  
**Last Updated**: 2025-10-15
