# MCP Servers

This directory contains MCP (Model Context Protocol) servers that provide tools for AI agents working with Love2D game projects.

## Available Servers

### Line Counter

Provides tools for counting lines in files to enforce the 300-line file size limit required by the Love2D project standards.

**Tools:**
- `count_file_lines` - Analyze a single file with detailed statistics
- `count_multiple_files` - Batch analyze multiple files
- `find_oversized_files` - Recursively scan directories for oversized files

**Implementations:**
- Node.js: `line-counter/` (recommended)
- Python: `line-counter-python/`

### Sprite Generator

AI-powered sprite and spritesheet generation for Love2D games. Supports both local Stable Diffusion and hosted APIs (DALL-E).

**Tools:**
- `generate_sprite` - Generate a single game sprite with AI
- `generate_sprite_batch` - Generate multiple sprites from YAML manifest
- `generate_spritesheet` - Generate and pack sprites into optimized spritesheet
- `generate_animation_frames` - Generate animation frame sequences
- `list_generated_sprites` - List all generated sprites for a game
- `get_gdd_art_style` - Extract art style from GAME_DESIGN.md

**Features:**
- GDD-aware for style consistency
- Background removal and post-processing
- Power-of-2 spritesheet packing
- Love2D Lua atlas generation
- Both local (free) and API (paid) generation

**Location:** `sprite-generator/`

See [sprite-generator/README.md](sprite-generator/README.md) for detailed setup and usage.

## Quick Setup

### Python Version (Recommended - Zero Dependencies!)

Python 3 is already installed on macOS - no npm or Node.js needed!

1. Make the script executable:
   ```bash
   chmod +x mcp-servers/line-counter-python/server.py
   ```

2. Add to Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:
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

That's it! ✅

### Node.js Version (Alternative)

1. Install Node.js:
   ```bash
   brew install node
   ```

2. Install dependencies:
   ```bash
   cd line-counter
   npm install
   ```

3. Add to Claude Desktop config at `~/Library/Application Support/Claude/claude_desktop_config.json`:
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

4. Restart Claude Desktop

### Option 2: Python (Alternative)

1. Install dependencies:
   ```bash
   cd line-counter-python
   pip3 install -r requirements.txt
   ```

2. Add to Claude Desktop config:
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

## Usage Example

Once configured, AI agents can automatically use these tools:

```
User: "Check if Player.lua is approaching the 300-line limit"

Agent: [uses count_file_lines tool]
The Player.lua file has 287 lines and is approaching the 300-line limit. 
It should be refactored before adding more features.
```

## File Size Enforcement

These tools help enforce the critical file size rules from the Copilot instructions:

- **MAXIMUM 300 lines** per Lua file
- **Files approaching 250 lines** should be reviewed for extraction
- **Files > 300 lines MUST be split** before adding code

## Detailed Documentation

- [Setup Guide](SETUP_GUIDE.md) - Comprehensive setup instructions
- [line-counter/README.md](line-counter/README.md) - Node.js implementation details
- [line-counter-python/README.md](line-counter-python/README.md) - Python implementation details

## Benefits for AI Agents

Once installed, agents will:

1. ✅ **Check file sizes automatically** before making edits
2. ✅ **Warn when files approach limits** (>250 lines)
3. ✅ **Refuse to add code to oversized files** without refactoring
4. ✅ **Audit entire projects** for compliance
5. ✅ **Provide actionable statistics** for refactoring decisions

## Troubleshooting

### Server not appearing

- Verify config file location: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Check absolute paths are correct
- Completely quit and restart Claude Desktop
- Check logs: `~/Library/Logs/Claude/`

### Node.js not found

```bash
brew install node
node --version
```

### Python dependencies failing

```bash
# Upgrade pip first
pip3 install --upgrade pip

# Then install requirements
pip3 install -r requirements.txt
```

## Development

To add new MCP servers:

1. Create a new directory: `mcp-servers/my-server/`
2. Implement using MCP SDK (Node.js or Python)
3. Add configuration instructions
4. Update this README

## Resources

- [MCP Documentation](https://modelcontextprotocol.io/)
- [MCP SDK (Node.js)](https://github.com/modelcontextprotocol/typescript-sdk)
- [Claude Desktop Configuration](https://docs.anthropic.com/claude/docs/mcp)
