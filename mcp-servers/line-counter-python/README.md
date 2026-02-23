# Line Counter MCP Server (Python)

✅ **Recommended:** Zero-dependency Python implementation using only the standard library!

This implementation has no external dependencies and works with Python 3.7+ (already installed on macOS).

## Installation

No installation needed! Python 3 is already on your Mac.

```bash
# Verify Python is installed
python3 --version

# Make the script executable
chmod +x mcp-servers/line-counter-python/server.py
```

## Configuration

Add to Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

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

**Note:** Update the path if your workspace is in a different location.

## Testing

Test the server manually:

```bash
cd /Users/diegopinate/Documents/Love2DAI
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}' | python3 mcp-servers/line-counter-python/server.py
```

You should see a JSON response with server info.

Test line counting:

```bash
cat << 'EOF' | python3 mcp-servers/line-counter-python/server.py 2>&1 | grep -v "running on stdio"
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{}}
{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"count_file_lines","arguments":{"filePath":"games/mecha-shmup/main.lua"}}}
EOF
```

## Configuration

Add to Claude Desktop config (`~/Library/Application Support/Claude/claude_desktop_config.json`):

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

## Usage

Same tools as the Node.js version:
- `count_file_lines`
- `count_multiple_files`
- `find_oversized_files`

See the main `SETUP_GUIDE.md` for detailed usage instructions.

## Testing

```bash
python3 server.py
```

Then in another terminal:
```bash
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | python3 server.py
```
