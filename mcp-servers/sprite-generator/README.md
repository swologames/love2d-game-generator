# Sprite Generator MCP Server

AI-powered sprite and spritesheet generation for Love2D games. Supports both local Stable Diffusion and hosted APIs (DALL-E), with automatic post-processing, GDD-aware style consistency, and Love2D integration.

## Features

- **Dual Provider Support**: Local Stable Diffusion or OpenAI DALL-E
- **GDD Integration**: Reads GAME_DESIGN.md for automatic style consistency
- **Single Sprite Generation**: Generate individual sprites on demand
- **Batch Generation**: Generate multiple sprites from YAML manifests
- **Spritesheet Packing**: Automatic power-of-2 optimization with atlas generation
- **Animation Frames**: Generate frame sequences with visual consistency
- **Post-Processing**: Background removal, resizing, sharpening, color quantization
- **Love2D Ready**: Direct integration with game asset folders and Lua atlas format

## Installation

### 1. Install Dependencies

```bash
cd mcp-servers/sprite-generator
pip install -r requirements.txt
```

**Note**: For local Stable Diffusion on Apple Silicon Macs, you may need to install PyTorch with MPS support:

```bash
pip3 install torch torchvision --index-url https://download.pytorch.org/whl/cpu
```

### 2. Download Models (for Local SD)

The first time you use local Stable Diffusion, models will be downloaded automatically to `~/.cache/huggingface/`. This is a ~4GB download.

**Optional**: Use a specialized pixel art model:

```bash
# Edit config.yaml and change model_path to one of:
# - "runwayml/stable-diffusion-v1-5" (default, general purpose)
# - "nerijs/pixel-art-xl" (pixel art specialized)
# - "prompthero/openjourney" (game art style)
```

### 3. Configure API Keys (for OpenAI)

If using DALL-E, set your OpenAI API key:

```bash
export OPENAI_API_KEY="sk-..."
```

Or add it directly to `config.yaml`:

```yaml
providers:
  openai:
    api_key: "sk-..."
```

### 4. Configure for Claude Desktop

Edit `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "sprite-generator": {
      "command": "python3",
      "args": ["/Users/YOUR_USERNAME/Documents/Love2DAI/mcp-servers/sprite-generator/server.py"]
    }
  }
}
```

**Important**: Use the absolute path to `server.py`.

### 5. Restart Claude Desktop

Completely quit and restart Claude Desktop for changes to take effect.

## Configuration

Edit `config.yaml` to customize behavior:

### Provider Settings

```yaml
providers:
  openai:
    enabled: true
    api_key: null  # Set via env var or here
    model: "dall-e-3"
    quality: "standard"  # or "hd"
  
  local_sd:
    enabled: true
    model_path: "runwayml/stable-diffusion-v1-5"
    device: "mps"  # mps (Apple Silicon), cuda (NVIDIA), cpu
    torch_dtype: "float16"
```

### Default Parameters

```yaml
defaults:
  provider: "local_sd"  # Default provider
  size: [512, 512]
  steps: 30  # SD inference steps
  guidance_scale: 7.5
  negative_prompt: "watermark, text, signature, blurry"
```

### Post-Processing

```yaml
postprocess:
  remove_background: true  # Requires rembg
  normalize_size: true
  sharpen: true
  color_quantize: false  # Set to integer (e.g., 16) for palette reduction
```

## Available Tools

### 1. generate_sprite

Generate a single game sprite.

**Example**:
```
Generate a pixel art player idle sprite for mecha-shmup using local SD
```

**Parameters**:
- `game_name`: Game folder name (e.g., "mecha-shmup")
- `entity_type`: Entity type (e.g., "player", "enemy", "item")
- `action`: Action/pose (e.g., "idle", "walk", "jump", "attack")
- `provider`: "openai" or "local_sd"
- `style`: Optional override (e.g., "pixel_art", "hand_drawn")
- `view`: Camera angle (e.g., "side_view", "top_down")
- `size`: [width, height] in pixels
- `post_process`: Enable post-processing (default: true)

**Output**: Saves to `games/{game}/assets/images/sprites/{filename}.png`

### 2. generate_sprite_batch

Generate multiple sprites from a YAML manifest.

**Manifest Format** (`sprites.yaml`):
```yaml
- name: player_idle
  entity: player
  action: idle
  size: [64, 64]
  style: pixel_art

- name: player_walk_1
  entity: player
  action: walk
  size: [64, 64]

- name: enemy_patrol
  entity: enemy_grunt
  action: walk
  size: [48, 48]
```

**Example**:
```
Generate sprites from manifest at /path/to/sprites.yaml for mecha-shmup
```

### 3. generate_spritesheet

Generate sprites and pack into an optimized spritesheet.

**Example**:
```
Generate a spritesheet named "player_animations" for mecha-shmup with these sprites:
- name: idle, entity: player, action: idle, size: [64, 64]
- name: walk_1, entity: player, action: walk, size: [64, 64]
- name: jump, entity: player, action: jump, size: [64, 64]
```

**Output**:
- `games/{game}/assets/images/spritesheets/{name}.png` - Packed spritesheet
- `games/{game}/assets/images/spritesheets/{name}_atlas.lua` - Lua atlas with coords

**Atlas Usage in Love2D**:
```lua
local atlas = require('assets.images.spritesheets.player_animations_atlas')
local sheet = love.graphics.newImage(atlas.sheet)

-- Create quads from atlas
local quads = {}
for name, coords in pairs(atlas.sprites) do
  quads[name] = love.graphics.newQuad(
    coords.x, coords.y, coords.w, coords.h,
    sheet:getDimensions()
  )
end

-- Draw a sprite
love.graphics.draw(sheet, quads['idle'], x, y)
```

### 4. generate_animation_frames

Generate a sequence of animation frames automatically.

**Example**:
```
Generate 8 frames of walk animation for player entity in mecha-shmup, size 64x64
```

**Parameters**:
- `game_name`: Game folder
- `entity_name`: Entity (e.g., "player")
- `animation_name`: Animation (e.g., "walk", "attack")
- `frame_count`: Number of frames (default: 8)
- `size`: Frame size [width, height]

**Output**: Spritesheet with frames named `{entity}_{animation}_01` through `_NN`

### 5. list_generated_sprites

List all generated sprites for a game.

**Example**:
```
List all generated sprites for mecha-shmup
```

### 6. get_gdd_art_style

Extract art style information from a game's GAME_DESIGN.md.

**Example**:
```
Get the art style for mecha-shmup from its GDD
```

## Usage Examples

### Quick Single Sprite

```
Generate a pixel art enemy idle sprite for mecha-shmup
```

AI will:
1. Read `games/mecha-shmup/GAME_DESIGN.md` for art style
2. Build optimized prompt with GDD context
3. Generate using default provider (local SD)
4. Remove background and optimize
5. Save to `games/mecha-shmup/assets/images/sprites/enemy_idle.png`

### Full Character Set

Create `character_set.yaml`:
```yaml
- name: player_idle
  entity: player
  action: idle
  size: [64, 64]

- name: player_walk_1
  entity: player
  action: walk
  size: [64, 64]

- name: player_walk_2
  entity: player
  action: walk
  size: [64, 64]

- name: player_jump
  entity: player
  action: jump
  size: [64, 64]

- name: player_attack
  entity: player
  action: attack
  size: [64, 64]
```

Then:
```
Generate sprites from /path/to/character_set.yaml for mecha-shmup using local_sd
```

### Animation Sequence

```
Generate 6 frames of jump animation for player in mecha-shmup, size 64x64, using local_sd
```

Output: `player_jump.png` spritesheet + `player_jump_atlas.lua`

## Troubleshooting

### Models Not Downloading

If Stable Diffusion models fail to download:

```bash
# Manually download
huggingface-cli login
huggingface-cli download runwayml/stable-diffusion-v1-5
```

### CUDA/MPS Not Available

If you get device errors, force CPU mode in `config.yaml`:

```yaml
providers:
  local_sd:
    device: "cpu"
    torch_dtype: "float32"
```

### Background Removal Fails

If `rembg` fails to install:

```bash
pip install rembg --no-deps
pip install onnxruntime Pillow
```

Or disable in `config.yaml`:

```yaml
postprocess:
  remove_background: false
```

### OpenAI Rate Limits

DALL-E has rate limits. If you hit them:
- Use local SD instead
- Add delays between batch generations
- Reduce batch sizes

### Out of Memory (OOM)

For large batches or high-res sprites on limited hardware:

```yaml
defaults:
  size: [256, 256]  # Smaller default size

performance:
  cache_models: false  # Don't keep models in memory
```

## Performance Notes

### Local SD Performance (Apple Silicon)

| Mac Model | Resolution | Time per Sprite |
|-----------|-----------|----------------|
| M1 8GB | 512x512 | ~15 seconds |
| M2 16GB | 512x512 | ~8 seconds |
| M3 Max | 1024x1024 | ~5 seconds |

### DALL-E Performance

- **Generation**: ~5-10 seconds
- **Cost**: ~$0.04 per 1024x1024 image ($0.02 for standard quality)
- **Batch of 20 sprites**: ~$0.80

## Tips for Best Results

1. **Specify style in GDD**: Add clear art style descriptions in `GAME_DESIGN.md`
2. **Consistent sizing**: Use same size for all sprites in an animation
3. **Iterative refinement**: Generate, test in game, adjust prompts if needed
4. **Use manifests**: Batch generation is more efficient than one-by-one
5. **Local SD for iteration**: Use free local generation during development, switch to DALL-E for final polish

## Model Recommendations

| Use Case | Recommended Model |
|----------|------------------|
| Pixel art games | `nerijs/pixel-art-xl` |
| Hand-drawn platformers | `runwayml/stable-diffusion-v1-5` |
| Sci-fi themes | `prompthero/openjourney` |
| High quality finals | OpenAI DALL-E 3 (hd quality) |

## License

This MCP server is part of the Love2DAI workspace.
