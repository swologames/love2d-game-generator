# MCP Line Counter Setup Guide

## Quick Start

The Line Counter MCP server helps AI agents automatically count lines in files to enforce the 300-line limit in your Love2D projects.

## Python Version (Recommended - Zero Dependencies!)

Python 3 is already installed on macOS - no npm or Node.js needed!

### Step 1: Make the Script Executable

```bash
chmod +x mcp-servers/line-counter-python/server.py
```

### Step 2: Configure Claude Desktop

1. Open or create: `~/Library/Application Support/Claude/claude_desktop_config.json`

2. Add this configuration:

```json
{
  "mcpServers": {
    "line-counter": {
      "command": "python3",
      "args": ["/Users/diegopinate/Documents/Love2DAI/mcp-servers/line-counter-python/server.py"]
    }
  }
}
```

**Important:** Update the path if your workspace is in a different location. Use the absolute path.

### Step 3: Restart Claude Desktop

**Completely quit** Claude Desktop (not just close the window) and restart it for the MCP server to load.

---

## Node.js Version (Alternative)

If you prefer Node.js or need the official SDK:

### Step 1: Install Node.js

If Node.js isn't installed:

```bash
# On macOS with Homebrew
brew install node

# Verify installation
node --version  # Should show v18+ or later
npm --version   # Should show v9+ or later
```

### Step 2: Install MCP Server Dependencies

```bash
cd mcp-servers/line-counter
npm install
```

This installs the `@modelcontextprotocol/sdk` package needed for the server.

### Step 3: Configure Claude Desktop

1. Open or create: `~/Library/Application Support/Claude/claude_desktop_config.json`

2. Add this configuration:

```json
{
  "mcpServers": {
    "line-counter": {
      "command": "node",
      "args": ["/Users/diegopinate/Documents/Love2DAI/mcp-servers/line-counter/index.js"]
    }
  }
}
```

**Important:** Update the path if your workspace is in a different location. Use the absolute path.

### Step 4: Restart Claude Desktop

**Completely quit** Claude Desktop (not just close the window) and restart it for the MCP server to load.

## Verifying Installation

After restarting Claude Desktop, AI agents will have access to these tools:

1. **count_file_lines** - Analyze a single file
2. **count_multiple_files** - Batch analyze multiple files  
3. **find_oversized_files** - Scan directories for files > 300 lines

You can test by asking an agent: "Check how many lines are in games/mecha-shmup/main.lua"

## Alternative: Python Version (Zero Dependencies!)

The Python version (`line-counter-python/`) requires **no installation** - it uses only Python's standard library!

### Setup Python Version

1. Make the script executable:
   ```bash
   chmod +x mcp-servers/line-counter-python/server.py
   ```

2. Configure Claude Desktop with:
   ```json
   {
     "mcpServers": {
       "line-counter": {
         "command": "python3",
         "args": ["/Users/diegopinate/Documents/Love2DAI/mcp-servers/line-counter-python/server.py"]
       }
     }
   }
   ```

3. Restart Claude Desktop

That's it! No npm, no dependencies, just Python.
3. **find_oversized_files** - Scan directories for files > 300 lines

## Usage Examples

### Example 1: Check a file before editing

```
count_file_lines with filePath "games/mecha-shmup/src/entities/Player.lua"
```

The agent will see:
- Total lines: 287
- Approaching limit: true (> 250 lines)
- Recommendation: Consider refactoring before adding more code

### Example 2: Audit an entire game

```
find_oversized_files with directoryPath "games/mecha-shmup" and maxLines 300
```

Returns all files exceeding 300 lines, sorted by size descending.

### Example 3: Check multiple related files

```
count_multiple_files with filePaths ["src/scenes/GameScene.lua", "src/entities/Player.lua"]
```

Gets statistics for all files in one call.

## Troubleshooting

### Server not appearing in Claude Desktop

1. Verify the config file path is correct
2. Check that the absolute path in the config matches your workspace location
3. Ensure you completely quit and restarted Claude Desktop (not just closed the window)
4. Check Claude Desktop logs: `~/Library/Logs/Claude/`

### "Command not found" errors

- Ensure Node.js is installed: `node --version`
- Verify the path in the config is correct and uses absolute paths

### Permission errors

```bash
chmod +x mcp-servers/line-counter/index.js
```

## Integration with AI Workflows

Once installed, agents will automatically:

1. **Check files before editing** - Verify line counts before adding code
2. **Suggest refactoring** - Warn when files approach 250 lines
3. **Enforce limits** - Refuse to add code to files > 300 lines without splitting
4. **Audit projects** - Scan entire games for compliance

## Manual Testing

Test the server directly:

```bash
cd mcp-servers/line-counter
echo '{"filePath": "../../games/mecha-shmup/main.lua"}' | node index.js
```

## Next Steps

After installation:

1. Restart Claude Desktop
2. Ask an AI agent: "Check how many lines are in the Player.lua file"
3. The agent should use the `count_file_lines` tool automatically
4. Verify the response includes line counts and compliance flags

## Support

For issues or questions, see the project README or check the MCP documentation at https://modelcontextprotocol.io/
