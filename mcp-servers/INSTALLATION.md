# Line Counter MCP Server - Installation Summary

I've created an MCP server that provides tools for AI agents to automatically count lines in files, helping enforce the 300-line file size limit in your Love2D projects.

## What Was Created

```
mcp-servers/
├── README.md                      # Overview of all MCP servers
├── SETUP_GUIDE.md                 # Detailed setup instructions
├── line-counter/                  # Node.js implementation (RECOMMENDED)
│   ├── package.json
│   ├── index.js                   # Main server code
│   ├── README.md
│   └── .gitignore
└── line-counter-python/           # Python implementation (experimental)
    ├── server.py
    ├── requirements.txt
    └── README.md
```

## Available Tools

The server provides 3 tools for AI agents:

### 1. count_file_lines
Analyzes a single file with detailed statistics:
- Total lines
- Non-empty lines / empty lines
- Estimated comment lines
- File size in bytes
- Boolean flags: `exceedsLimit` (>300) and `approachingLimit` (250-300)

### 2. count_multiple_files
Batch analyze multiple files at once with summary statistics.

### 3. find_oversized_files
Recursively scans directories to find all files exceeding the line limit (default 300). Returns results sorted by size.

## Quick Setup

### Python Version (Recommended - Zero Dependencies!)

No npm, no Node.js, no external packages - just Python 3 which is already on your Mac!

1. **Make the script executable:**
   ```bash
   chmod +x mcp-servers/line-counter-python/server.py
   ```

2. **Configure Claude Desktop:**
   
   Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:
   
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
   
   ⚠️ **Update the path** if your workspace is in a different location.

3. **Restart Claude Desktop completely** (quit and reopen)

### Node.js Version (Alternative)

If you prefer Node.js:

1. **Install Node.js:**
   ```bash
   brew install node
   ```

2. **Install dependencies:**
   ```bash
   cd mcp-servers/line-counter
   npm install
   ```

3. **Configure Claude Desktop:**
   
   Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:
   
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
   
   ⚠️ **Update the path** if your workspace is in a different location.

3. **Restart Claude Desktop completely** (quit and reopen)

## How AI Agents Will Use It

Once installed, agents will automatically:

1. **Check files before editing:**
   ```
   User: "Add a new feature to Player.lua"
   Agent: [uses count_file_lines]
         "Player.lua has 287 lines (approaching limit). 
          I'll implement this as a separate module instead."
   ```

2. **Audit projects:**
   ```
   User: "Check which files in mecha-shmup need refactoring"
   Agent: [uses find_oversized_files]
         "Found 3 files exceeding 300 lines: ..."
   ```

3. **Enforce limits:**
   - Warn when files approach 250 lines
   - Refuse to add code to files >300 lines without splitting
   - Suggest componentization strategies

## Benefits

✅ **Automatic enforcement** of file size rules  
✅ **Proactive warnings** before files become too large  
✅ **Project-wide auditing** with one command  
✅ **Detailed statistics** for refactoring decisions  
✅ **Maintains code quality** across all Love2D games  

## Next Steps

1. Install Node.js if not already installed
2. Run `npm install` in the line-counter directory
3. Configure Claude Desktop (see SETUP_GUIDE.md)
4. Restart Claude Desktop
5. Test by asking an agent to check a file's line count

## Documentation

- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Complete setup instructions
- [line-counter/README.md](line-counter/README.md) - Tool usage and API
- [README.md](README.md) - MCP servers overview

## Troubleshooting

**If Node.js isn't installed:**
```bash
brew install node
```

**If the server doesn't appear in Claude:**
- Verify the path in the config is absolute and correct
- Ensure you completely quit and restarted Claude Desktop
- Check Claude logs: `~/Library/Logs/Claude/`

**To test the server manually:**
```bash
cd mcp-servers/line-counter
node index.js  # Should output "Line Counter MCP Server running on stdio"
```

---

The MCP server is ready to use once you complete the installation steps!
