# Go Language Server (`gopls`) Integration

This document outlines the rules and guidelines for using the `gopls` language server, which is integrated via the `language-server` Model Context Protocol (MCP) server. This server enhances your capabilities for reading, understanding, and modifying Go code.

## Overview

The `language-server` MCP provides access to powerful language-specific features directly from the Go language server (`gopls`). This allows for deep code intelligence, making it easier to navigate and manipulate Go projects.

**IMPORTANT**: All LSP tools must be called using the `use_mcp_tool` function with the proper parameters. Do not call LSP tools directly.

## Available Tools

The following tools are available through the `language-server` MCP. Always use these tools when performing tasks on Go code to ensure accuracy and efficiency.

### `definition`
- **Purpose**: To find where a symbol (like a function, type, or variable) is defined.
- **When to use**: Use this when you need to understand the implementation of a specific piece of code. Instead of manually searching for a function's source, you can directly jump to its definition.
- **Usage**:
```xml
<use_mcp_tool>
<server_name>language-server</server_name>
<tool_name>definition</tool_name>
<arguments>
{
  "symbolName": "util.MyFunction"
}
</arguments>
</use_mcp_tool>
```

### `references`
- **Purpose**: To find all places where a symbol is used.
- **When to use**: This is crucial for impact analysis. Before renaming or modifying a function or variable, use `references` to see where it's used throughout the codebase. This helps prevent breaking changes.
- **Usage**:
```xml
<use_mcp_tool>
<server_name>language-server</server_name>
<tool_name>references</tool_name>
<arguments>
{
  "symbolName": "mypackage.MyType"
}
</arguments>
</use_mcp_tool>
```

### `diagnostics`
- **Purpose**: To get a list of errors and warnings for a specific file.
- **When to use**: After modifying a file, run `diagnostics` to check for any syntax errors, compilation issues, or linter warnings. This ensures code quality and correctness before you finalize your changes.
- **Usage**:
```xml
<use_mcp_tool>
<server_name>language-server</server_name>
<tool_name>diagnostics</tool_name>
<arguments>
{
  "filePath": "cmd/server/main.go",
  "showLineNumbers": true,
  "contextLines": false
}
</arguments>
</use_mcp_tool>
```

### `hover`
- **Purpose**: To get quick information about a symbol, such as its type and documentation.
- **When to use**: When you quickly need to know what a variable's type is or what a function does without navigating away from your current context.
- **Usage**:
```xml
<use_mcp_tool>
<server_name>language-server</server_name>
<tool_name>hover</tool_name>
<arguments>
{
  "filePath": "cmd/server/main.go",
  "line": 10,
  "column": 5
}
</arguments>
</use_mcp_tool>
```

### `rename_symbol`
- **Purpose**: To safely rename a symbol across the entire project.
- **When to use**: When you need to change the name of a function, variable, or type. This tool handles updating all references automatically, which is much safer than a manual find-and-replace.
- **Usage**:
```xml
<use_mcp_tool>
<server_name>language-server</server_name>
<tool_name>rename_symbol</tool_name>
<arguments>
{
  "filePath": "cmd/server/main.go",
  "line": 25,
  "column": 12,
  "newName": "NewFunctionName"
}
</arguments>
</use_mcp_tool>
```

### `edit_file`
- **Purpose**: To apply programmatic text edits to a file.
- **When to use**: This is a powerful tool for complex, multi-location changes within a single file that can be determined programmatically. It is often used for refactoring tasks identified by the language server. For simple search-and-replace, `apply_diff` might be easier.
- **Usage**:
```xml
<use_mcp_tool>
<server_name>language-server</server_name>
<tool_name>edit_file</tool_name>
<arguments>
{
  "filePath": "cmd/server/main.go",
  "edits": [
    {
      "startLine": 1,
      "endLine": 5,
      "newText": "new content"
    }
  ]
}
</arguments>
</use_mcp_tool>
```

## Core Principle: LSP First

When working with Go code, you **must** prioritize using the `language-server` tools for all code exploration, analysis, and modification tasks. These tools provide precise, context-aware information that is superior to generic file operations.

**Only** resort to tools like `read_file` or `search_files` for Go code if a specific task cannot be accomplished with an LSP tool.

## General Guidelines

- **LSP for Exploration**: Before reading a Go file, first consider if `definition`, `references`, or `hover` can get you the information you need more efficiently. Use these tools to navigate the codebase logically.
- **Always prefer LSP tools over manual edits**: For actions like renaming, finding definitions, or finding references, the LSP tools are more reliable and less error-prone than manual searching or text replacement.
- **Validate changes**: After any modification, run `diagnostics` on the affected files to ensure you haven't introduced any errors.
- **Understand the context**: Use `definition` and `hover` to build a strong understanding of the code before you make changes.
- **Assess impact**: Use `references` to understand the potential impact of a change before you implement it.
- **Correct MCP Usage**: Always use the `use_mcp_tool` function with `server_name: "language-server"` and the appropriate `tool_name` and `arguments` parameters as shown in the examples above.
