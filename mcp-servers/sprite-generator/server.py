#!/usr/bin/env python3
"""MCP Server for AI-powered sprite and spritesheet generation.

This server provides tools for generating game sprites using AI image generation
(both local Stable Diffusion and hosted APIs like DALL-E), with automatic
post-processing, spritesheet packing, and Love2D integration.
"""

import sys
import os
import json
from typing import Dict, Any, Optional
from pathlib import Path

# Add parent directory to path for imports
script_dir = Path(__file__).parent
sys.path.insert(0, str(script_dir))

from config.loader import ConfigLoader
from providers.factory import ProviderFactory
from prompts.builder import PromptBuilder
from postprocess.pipeline import PostProcessor
from packing.packer import SheetPacker
from packing.atlas import AtlasExporter
from manifests.schema import ManifestValidator


class SpriteGeneratorServer:
    """MCP server for sprite generation."""
    
    def __init__(self):
        """Initialize the sprite generator server."""
        self.config = None
        self.config_loader = None
        self.prompt_builder = None
        self.post_processor = None
        self.providers = {}  # Cache for initialized providers
        
        # Load configuration
        config_path = script_dir / 'config.yaml'
        try:
            self.config_loader = ConfigLoader(str(config_path))
            self.config = self.config_loader.load()
            
            # Initialize core components
            workspace_root = self.config_loader.get_workspace_root()
            self.prompt_builder = PromptBuilder(workspace_root)
            
            postprocess_config = self.config_loader.get_postprocess_config()
            self.post_processor = PostProcessor(postprocess_config)
            
            print("Sprite generator server initialized", file=sys.stderr)
        except Exception as e:
            print(f"Warning: Failed to load config: {e}", file=sys.stderr)
            print("Server will run with limited functionality", file=sys.stderr)
    
    def _get_provider(self, provider_name: str):
        """Get or create a provider instance (with caching)."""
        if not self.config:
            raise RuntimeError("Server not properly configured")
        
        # Check cache
        if provider_name in self.providers:
            return self.providers[provider_name]
        
        # Get provider config
        provider_config = self.config_loader.get_provider_config(provider_name)
        if not provider_config:
            raise ValueError(f"No configuration found for provider: {provider_name}")
        
        if not provider_config.get('enabled', True):
            raise ValueError(f"Provider is disabled: {provider_name}")
        
        # Create and cache provider
        provider = ProviderFactory.create(provider_name, provider_config)
        self.providers[provider_name] = provider
        
        return provider
    
    def handle_initialize(self, params: Dict[str, Any]) -> Dict[str, Any]:
        """Handle MCP initialize request."""
        return {
            "protocolVersion": "2024-11-05",
            "capabilities": {"tools": {}},
            "serverInfo": {
                "name": "sprite-generator",
                "version": "1.0.0"
            }
        }
    
    def handle_list_tools(self) -> Dict[str, Any]:
        """Handle MCP tools/list request."""
        return {
            "tools": [
                {
                    "name": "generate_sprite",
                    "description": "Generate a single game sprite using AI. Reads GAME_DESIGN.md for art style consistency. Supports both local Stable Diffusion and hosted APIs (DALL-E). Output is saved to game's assets folder with optional post-processing (background removal, resizing, sharpening).",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "game_name": {
                                "type": "string",
                                "description": "Name of the game folder (e.g., 'mecha-shmup')"
                            },
                            "entity_type": {
                                "type": "string",
                                "description": "Type of entity (e.g., 'player', 'enemy', 'item', 'projectile')"
                            },
                            "action": {
                                "type": "string",
                                "description": "Action or pose (e.g., 'idle', 'walk', 'jump', 'attack', 'death')",
                                "default": "idle"
                            },
                            "provider": {
                                "type": "string",
                                "description": "Image generation provider: 'openai' or 'local_sd'",
                                "enum": ["openai", "local_sd"]
                            },
                            "style": {
                                "type": "string",
                                "description": "Art style override (uses GDD if not specified): 'pixel_art', 'hand_drawn', 'isometric', 'flat', 'cartoon'"
                            },
                            "view": {
                                "type": "string",
                                "description": "Camera view angle",
                                "default": "side_view",
                                "enum": ["side_view", "top_down", "isometric", "3_4", "front"]
                            },
                            "size": {
                                "type": "array",
                                "description": "Sprite size [width, height] in pixels",
                                "items": {"type": "integer"},
                                "default": [512, 512]
                            },
                            "filename": {
                                "type": "string",
                                "description": "Output filename (auto-generated if not specified)"
                            },
                            "post_process": {
                                "type": "boolean",
                                "description": "Apply post-processing (background removal, etc.)",
                                "default": True
                            }
                        },
                        "required": ["game_name", "entity_type"]
                    }
                },
                {
                    "name": "generate_sprite_batch",
                    "description": "Generate multiple sprites from a YAML manifest file. Manifest specifies a list of sprites with their properties. Useful for generating full character sets or multiple game assets in one operation.",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "game_name": {
                                "type": "string",
                                "description": "Name of the game folder"
                            },
                            "manifest_path": {
                                "type": "string",
                                "description": "Absolute path to YAML manifest file listing sprites to generate"
                            },
                            "provider": {
                                "type": "string",
                                "description": "Image generation provider",
                                "enum": ["openai", "local_sd"]
                            }
                        },
                        "required": ["game_name", "manifest_path"]
                    }
                },
                {
                    "name": "generate_spritesheet",
                    "description": "Generate multiple sprites and pack them into a single optimized spritesheet with atlas metadata. Creates Power-of-2 sized sheet for GPU optimization. Outputs PNG spritesheet and Lua atlas file for Love2D.",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "game_name": {
                                "type": "string",
                                "description": "Name of the game folder"
                            },
                            "sheet_name": {
                                "type": "string",
                                "description": "Name for the spritesheet (e.g., 'player_animations')"
                            },
                            "sprites": {
                                "type": "array",
                                "description": "Array of sprite specifications",
                                "items": {
                                    "type": "object",
                                    "properties": {
                                        "name": {"type": "string"},
                                        "entity": {"type": "string"},
                                        "action": {"type": "string"},
                                        "size": {"type": "array", "items": {"type": "integer"}}
                                    },
                                    "required": ["name", "entity", "action"]
                                }
                            },
                            "provider": {
                                "type": "string",
                                "description": "Image generation provider",
                                "enum": ["openai", "local_sd"]
                            }
                        },
                        "required": ["game_name", "sheet_name", "sprites"]
                    }
                },
                {
                    "name": "generate_animation_frames",
                    "description": "Generate a sequence of frames for a single animation (e.g., walk cycle, jump sequence). Automatically maintains visual consistency across frames and packs into a spritesheet.",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "game_name": {
                                "type": "string",
                                "description": "Name of the game folder"
                            },
                            "entity_name": {
                                "type": "string",
                                "description": "Entity name (e.g., 'player', 'enemy_grunt')"
                            },
                            "animation_name": {
                                "type": "string",
                                "description": "Animation name (e.g., 'walk', 'attack', 'jump')"
                            },
                            "frame_count": {
                                "type": "integer",
                                "description": "Number of frames to generate",
                                "default": 8
                            },
                            "provider": {
                                "type": "string",
                                "description": "Image generation provider",
                                "enum": ["openai", "local_sd"]
                            },
                            "size": {
                                "type": "array",
                                "description": "Frame size [width, height]",
                                "items": {"type": "integer"},
                                "default": [64, 64]
                            }
                        },
                        "required": ["game_name", "entity_name", "animation_name"]
                    }
                },
                {
                    "name": "list_generated_sprites",
                    "description": "List all sprites that have been generated for a game. Scans the game's assets/images folder and returns inventory of existing sprites.",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "game_name": {
                                "type": "string",
                                "description": "Name of the game folder"
                            }
                        },
                        "required": ["game_name"]
                    }
                },
                {
                    "name": "get_gdd_art_style",
                    "description": "Extract and return the art style information from a game's GAME_DESIGN.md. Useful for understanding what style to use for sprite generation.",
                    "inputSchema": {
                        "type": "object",
                        "properties": {
                            "game_name": {
                                "type": "string",
                                "description": "Name of the game folder"
                            }
                        },
                        "required": ["game_name"]
                    }
                }
            ]
        }
    
    def handle_call_tool(self, name: str, arguments: Dict[str, Any]) -> Dict[str, Any]:
        """Handle MCP tools/call request."""
        try:
            if name == "generate_sprite":
                result = self._generate_sprite(arguments)
            elif name == "generate_sprite_batch":
                result = self._generate_sprite_batch(arguments)
            elif name == "generate_spritesheet":
                result = self._generate_spritesheet(arguments)
            elif name == "generate_animation_frames":
                result = self._generate_animation_frames(arguments)
            elif name == "list_generated_sprites":
                result = self._list_generated_sprites(arguments)
            elif name == "get_gdd_art_style":
                result = self._get_gdd_art_style(arguments)
            else:
                return {
                    "content": [{
                        "type": "text",
                        "text": json.dumps({"error": f"Unknown tool: {name}"}, indent=2)
                    }],
                    "isError": True
                }
            
            return {
                "content": [{
                    "type": "text",
                    "text": json.dumps(result, indent=2)
                }]
            }
        
        except Exception as e:
            import traceback
            error_detail = traceback.format_exc()
            print(f"Tool execution error: {error_detail}", file=sys.stderr)
            
            return {
                "content": [{
                    "type": "text",
                    "text": json.dumps({
                        "error": str(e),
                        "tool": name,
                        "traceback": error_detail
                    }, indent=2)
                }],
                "isError": True
            }
    
    def _generate_sprite(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Generate a single sprite."""
        game_name = args["game_name"]
        entity_type = args["entity_type"]
        action = args.get("action", "idle")
        provider_name = args.get("provider", self.config.get("defaults", {}).get("provider", "local_sd"))
        style = args.get("style")
        view = args.get("view", "side_view")
        size = args.get("size", [512, 512])
        filename = args.get("filename")
        post_process = args.get("post_process", True)
        
        # Build prompt
        prompt = self.prompt_builder.build_prompt(
            entity_type=entity_type,
            action=action,
            style=style,
            view=view,
            game_name=game_name
        )
        
        defaults = self.config_loader.get_defaults()
        negative_prompt = self.prompt_builder.build_negative_prompt(
            defaults.get("negative_prompt")
        )
        
        # Get provider
        provider = self._get_provider(provider_name)
        
        # Generate image
        print(f"Generating sprite: {entity_type} {action}", file=sys.stderr)
        
        # Filter out parameters we're providing explicitly to avoid conflicts
        generation_params = {k: v for k, v in defaults.items() 
                           if k not in ['provider', 'size', 'negative_prompt']}
        
        image = provider.generate(
            prompt=prompt,
            negative_prompt=negative_prompt,
            width=size[0],
            height=size[1],
            **generation_params
        )
        
        # Post-process
        if post_process:
            image = self.post_processor.process(image, target_size=tuple(size))
        
        # Save sprite
        if not filename:
            filename = f"{entity_type}_{action}.png"
        
        output_dir = Path(self.config_loader.get_workspace_root()) / "games" / game_name / "assets" / "images" / "sprites"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / filename
        
        image.save(output_path, "PNG")
        
        # Return relative path from workspace root
        rel_path = output_path.relative_to(self.config_loader.get_workspace_root())
        
        return {
            "success": True,
            "sprite_path": str(rel_path),
            "absolute_path": str(output_path),
            "size": size,
            "prompt": prompt[:200] + "..." if len(prompt) > 200 else prompt
        }
    
    def _generate_sprite_batch(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Generate multiple sprites from a manifest."""
        game_name = args["game_name"]
        manifest_path = args["manifest_path"]
        provider_name = args.get("provider", self.config.get("defaults", {}).get("provider", "local_sd"))
        
        # Load and validate manifest
        sprite_specs = ManifestValidator.load_and_validate(manifest_path)
        
        results = []
        errors = []
        
        for spec in sprite_specs:
            try:
                sprite_args = {
                    "game_name": game_name,
                    "entity_type": spec["entity"],
                    "action": spec["action"],
                    "provider": provider_name,
                    "filename": f"{spec['name']}.png"
                }
                
                if "size" in spec:
                    sprite_args["size"] = spec["size"]
                if "style" in spec:
                    sprite_args["style"] = spec["style"]
                if "view" in spec:
                    sprite_args["view"] = spec["view"]
                
                result = self._generate_sprite(sprite_args)
                results.append(result)
                
            except Exception as e:
                errors.append({"sprite": spec["name"], "error": str(e)})
                print(f"Failed to generate {spec['name']}: {e}", file=sys.stderr)
        
        return {
            "success": True,
            "total_requested": len(sprite_specs),
            "generated": len(results),
            "failed": len(errors),
            "results": results,
            "errors": errors if errors else None
        }
    
    def _generate_spritesheet(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Generate sprites and pack into spritesheet."""
        game_name = args["game_name"]
        sheet_name = args["sheet_name"]
        sprite_specs = args["sprites"]
        provider_name = args.get("provider", self.config.get("defaults", {}).get("provider", "local_sd"))
        
        # Generate all sprites first
        from PIL import Image
        sprites = {}
        
        for spec in sprite_specs:
            try:
                sprite_args = {
                    "game_name": game_name,
                    "entity_type": spec["entity"],
                    "action": spec["action"],
                    "provider": provider_name,
                    "size": spec.get("size", [64, 64]),
                    "post_process": True
                }
                
                # Generate to temp location
                result = self._generate_sprite(sprite_args)
                
                # Load image
                img_path = Path(self.config_loader.get_workspace_root()) / result["sprite_path"]
                image = Image.open(img_path)
                sprites[spec["name"]] = image
                
            except Exception as e:
                print(f"Failed to generate sprite {spec['name']}: {e}", file=sys.stderr)
        
        if not sprites:
            raise ValueError("No sprites were successfully generated")
        
        # Pack sprites
        packer = SheetPacker(padding=4, power_of_two=True)
        sheet, rects = packer.pack(sprites)
        
        # Save spritesheet
        output_dir = Path(self.config_loader.get_workspace_root()) / "games" / game_name / "assets" / "images" / "spritesheets"
        output_dir.mkdir(parents=True, exist_ok=True)
        
        sheet_path = output_dir / f"{sheet_name}.png"
        sheet.save(sheet_path, "PNG")
        
        # Generate atlas
        atlas_lua = AtlasExporter.export_lua(rects, f"{sheet_name}.png")
        atlas_path = output_dir / f"{sheet_name}_atlas.lua"
        with open(atlas_path, 'w') as f:
            f.write(atlas_lua)
        
        # Relative paths
        rel_sheet = sheet_path.relative_to(self.config_loader.get_workspace_root())
        rel_atlas = atlas_path.relative_to(self.config_loader.get_workspace_root())
        
        return {
            "success": True,
            "sheet_path": str(rel_sheet),
            "atlas_path": str(rel_atlas),
            "sheet_size": [sheet.width, sheet.height],
            "sprite_count": len(rects),
            "sprites": [r.name for r in rects]
        }
    
    def _generate_animation_frames(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Generate animation frames and pack into sheet."""
        game_name = args["game_name"]
        entity_name = args["entity_name"]
        animation_name = args["animation_name"]
        frame_count = args.get("frame_count", 8)
        provider_name = args.get("provider", self.config.get("defaults", {}).get("provider", "local_sd"))
        size = args.get("size", [64, 64])
        
        # Generate frame specs
        sprite_specs = []
        for i in range(frame_count):
            sprite_specs.append({
                "name": f"{entity_name}_{animation_name}_{i+1:02d}",
                "entity": entity_name,
                "action": animation_name,
                "size": size
            })
        
        # Use spritesheet generation
        sheet_args = {
            "game_name": game_name,
            "sheet_name": f"{entity_name}_{animation_name}",
            "sprites": sprite_specs,
            "provider": provider_name
        }
        
        return self._generate_spritesheet(sheet_args)
    
    def _list_generated_sprites(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """List all generated sprites for a game."""
        game_name = args["game_name"]
        
        assets_dir = Path(self.config_loader.get_workspace_root()) / "games" / game_name / "assets" / "images"
        
        sprites = []
        sheets = []
        
        # Scan sprites folder
        sprites_dir = assets_dir / "sprites"
        if sprites_dir.exists():
            for png_file in sprites_dir.glob("*.png"):
                sprites.append({
                    "name": png_file.stem,
                    "path": str(png_file.relative_to(self.config_loader.get_workspace_root())),
                    "size_bytes": png_file.stat().st_size
                })
        
        # Scan spritesheets folder
        sheets_dir = assets_dir / "spritesheets"
        if sheets_dir.exists():
            for png_file in sheets_dir.glob("*.png"):
                atlas_file = png_file.with_suffix('').with_name(f"{png_file.stem}_atlas.lua")
                sheets.append({
                    "name": png_file.stem,
                    "sheet_path": str(png_file.relative_to(self.config_loader.get_workspace_root())),
                    "atlas_path": str(atlas_file.relative_to(self.config_loader.get_workspace_root())) if atlas_file.exists() else None,
                    "size_bytes": png_file.stat().st_size
                })
        
        return {
            "game_name": game_name,
            "sprite_count": len(sprites),
            "spritesheet_count": len(sheets),
            "sprites": sprites,
            "spritesheets": sheets
        }
    
    def _get_gdd_art_style(self, args: Dict[str, Any]) -> Dict[str, Any]:
        """Extract art style from GDD."""
        game_name = args["game_name"]
        
        gdd_info = self.prompt_builder._read_gdd(game_name)
        
        return {
            "game_name": game_name,
            "art_style": gdd_info.get("art_style", "Not specified"),
            "color_palette": gdd_info.get("color_palette", "Not specified"),
            "theme": gdd_info.get("theme", "Not specified"),
            "raw_info": gdd_info
        }
    
    def run(self):
        """Run the MCP server main loop."""
        print("Sprite generator MCP server starting...", file=sys.stderr)
        
        for line in sys.stdin:
            try:
                request = json.loads(line)
                method = request.get("method")
                params = request.get("params", {})
                request_id = request.get("id")
                
                response = {"jsonrpc": "2.0", "id": request_id}
                
                if method == "initialize":
                    response["result"] = self.handle_initialize(params)
                elif method == "tools/list":
                    response["result"] = self.handle_list_tools()
                elif method == "tools/call":
                    tool_name = params.get("name")
                    tool_args = params.get("arguments", {})
                    response["result"] = self.handle_call_tool(tool_name, tool_args)
                else:
                    response["error"] = {
                        "code": -32601,
                        "message": f"Method not found: {method}"
                    }
                
                print(json.dumps(response), flush=True)
            
            except json.JSONDecodeError as e:
                print(f"JSON decode error: {e}", file=sys.stderr)
                continue
            except Exception as e:
                print(f"Server error: {e}", file=sys.stderr)
                import traceback
                traceback.print_exc(file=sys.stderr)
                continue


if __name__ == "__main__":
    server = SpriteGeneratorServer()
    server.run()
