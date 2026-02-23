#!/usr/bin/env python3
"""
Line Counter MCP Server - Simple Python Implementation
Provides tools for counting lines in files to enforce file size limits.

This is a standalone implementation that doesn't require external dependencies.
It implements the MCP protocol directly over stdio.
"""

import json
import sys
from pathlib import Path
from typing import Any, Dict, List


def count_lines(file_path: str) -> Dict[str, Any]:
    """Count lines in a file and provide detailed statistics."""
    try:
        path = Path(file_path).resolve()
        
        if not path.exists():
            raise FileNotFoundError(f"File not found: {file_path}")
        
        if not path.is_file():
            raise ValueError(f"Not a file: {file_path}")
        
        with open(path, 'r', encoding='utf-8', errors='ignore') as f:
            lines = f.readlines()
        
        total_lines = len(lines)
        non_empty_lines = sum(1 for line in lines if line.strip())
        empty_lines = total_lines - non_empty_lines
        
        # Estimate comment lines (simple heuristic)
        comment_lines = sum(1 for line in lines if line.strip().startswith(('--', '//', '#', '/*', '*')))
        
        file_size = path.stat().st_size
        
        return {
            "filePath": str(path),
            "fileName": path.name,
            "totalLines": total_lines,
            "nonEmptyLines": non_empty_lines,
            "emptyLines": empty_lines,
            "estimatedCommentLines": comment_lines,
            "sizeBytes": file_size,
            "exceedsLimit": total_lines > 300,
            "approachingLimit": 250 < total_lines <= 300,
            "fileExtension": path.suffix,
        }
    except Exception as e:
        raise Exception(f"Failed to count lines in {file_path}: {str(e)}")


def count_lines_multiple(file_paths: List[str]) -> Dict[str, Any]:
    """Count lines in multiple files."""
    results = []
    for file_path in file_paths:
        try:
            result = count_lines(file_path)
            results.append(result)
        except Exception as e:
            results.append({
                "filePath": file_path,
                "error": str(e)
            })
    
    files_exceeding = sum(1 for r in results if not r.get("error") and r.get("exceedsLimit"))
    files_approaching = sum(1 for r in results if not r.get("error") and r.get("approachingLimit"))
    
    return {
        "totalFiles": len(results),
        "filesExceedingLimit": files_exceeding,
        "filesApproachingLimit": files_approaching,
        "results": results,
    }


def find_oversized_files(directory_path: str, max_lines: int = 300) -> Dict[str, Any]:
    """Recursively find files exceeding the line limit."""
    try:
        dir_path = Path(directory_path).resolve()
        
        if not dir_path.exists():
            raise FileNotFoundError(f"Directory not found: {directory_path}")
        
        if not dir_path.is_dir():
            raise ValueError(f"Not a directory: {directory_path}")
        
        oversized_files = []
        skip_dirs = {"node_modules", ".git", "lib", "assets"}
        code_extensions = {".lua", ".js", ".ts", ".py", ".md"}
        
        def scan_directory(path: Path):
            try:
                for item in path.iterdir():
                    if item.is_dir():
                        if item.name not in skip_dirs:
                            scan_directory(item)
                    elif item.is_file() and item.suffix in code_extensions:
                        try:
                            line_info = count_lines(str(item))
                            if line_info["totalLines"] > max_lines:
                                oversized_files.append(line_info)
                        except Exception:
                            pass  # Skip files that can't be read
            except PermissionError:
                pass  # Skip directories we can't access
        
        scan_directory(dir_path)
        
        # Sort by total lines descending
        oversized_files.sort(key=lambda x: x["totalLines"], reverse=True)
        
        return {
            "directoryScanned": str(dir_path),
            "maxLinesThreshold": max_lines,
            "filesFound": len(oversized_files),
            "files": oversized_files,
        }
    except Exception as e:
        raise Exception(f"Failed to scan directory {directory_path}: {str(e)}")


def handle_list_tools() -> Dict[str, Any]:
    """Handle tools/list request."""
    return {
        "tools": [
            {
                "name": "count_file_lines",
                "description": "Count lines in a single file and provide detailed statistics including total lines, non-empty lines, and whether it exceeds the 300-line limit. Essential for enforcing Love2D project file size constraints.",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "filePath": {
                            "type": "string",
                            "description": "Absolute or relative path to the file to analyze",
                        },
                    },
                    "required": ["filePath"],
                },
            },
            {
                "name": "count_multiple_files",
                "description": "Count lines in multiple files at once. Returns an array of line count statistics for each file. Efficient for batch checking file sizes.",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "filePaths": {
                            "type": "array",
                            "items": {"type": "string"},
                            "description": "Array of file paths to analyze",
                        },
                    },
                    "required": ["filePaths"],
                },
            },
            {
                "name": "find_oversized_files",
                "description": "Recursively scan a directory to find all files exceeding a line count limit (default 300 lines). Perfect for auditing Love2D projects for compliance with file size rules. Returns detailed statistics for each oversized file.",
                "inputSchema": {
                    "type": "object",
                    "properties": {
                        "directoryPath": {
                            "type": "string",
                            "description": "Path to the directory to scan recursively",
                        },
                        "maxLines": {
                            "type": "number",
                            "description": "Maximum line count threshold (default: 300)",
                            "default": 300,
                        },
                    },
                    "required": ["directoryPath"],
                },
            },
        ]
    }


def handle_call_tool(name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
    """Handle tools/call request."""
    try:
        if name == "count_file_lines":
            result = count_lines(arguments["filePath"])
            return {
                "content": [
                    {
                        "type": "text",
                        "text": json.dumps(result, indent=2),
                    }
                ]
            }
        
        elif name == "count_multiple_files":
            result = count_lines_multiple(arguments["filePaths"])
            return {
                "content": [
                    {
                        "type": "text",
                        "text": json.dumps(result, indent=2),
                    }
                ]
            }
        
        elif name == "find_oversized_files":
            max_lines = arguments.get("maxLines", 300)
            result = find_oversized_files(arguments["directoryPath"], max_lines)
            return {
                "content": [
                    {
                        "type": "text",
                        "text": json.dumps(result, indent=2),
                    }
                ]
            }
        
        else:
            raise ValueError(f"Unknown tool: {name}")
    
    except Exception as e:
        return {
            "content": [
                {
                    "type": "text",
                    "text": json.dumps({"error": str(e)}, indent=2),
                }
            ],
            "isError": True,
        }


def handle_initialize(params: Dict[str, Any]) -> Dict[str, Any]:
    """Handle initialize request."""
    return {
        "protocolVersion": "2024-11-05",
        "capabilities": {
            "tools": {},
        },
        "serverInfo": {
            "name": "line-counter-server",
            "version": "1.0.0",
        },
    }


def main():
    """Run the MCP server using stdio."""
    print("Line Counter MCP Server (Python) running on stdio", file=sys.stderr)
    
    for line in sys.stdin:
        try:
            request = json.loads(line)
            method = request.get("method")
            params = request.get("params", {})
            request_id = request.get("id")
            
            response = {"jsonrpc": "2.0", "id": request_id}
            
            if method == "initialize":
                response["result"] = handle_initialize(params)
            
            elif method == "tools/list":
                response["result"] = handle_list_tools()
            
            elif method == "tools/call":
                tool_name = params.get("name")
                tool_args = params.get("arguments", {})
                response["result"] = handle_call_tool(tool_name, tool_args)
            
            elif method == "notifications/initialized":
                # No response needed for notifications
                continue
            
            else:
                response["error"] = {
                    "code": -32601,
                    "message": f"Method not found: {method}",
                }
            
            print(json.dumps(response), flush=True)
        
        except json.JSONDecodeError:
            continue
        except Exception as e:
            error_response = {
                "jsonrpc": "2.0",
                "id": request.get("id") if 'request' in locals() else None,
                "error": {
                    "code": -32603,
                    "message": f"Internal error: {str(e)}",
                },
            }
            print(json.dumps(error_response), flush=True)


if __name__ == "__main__":
    main()
