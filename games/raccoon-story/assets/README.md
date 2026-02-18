# Assets Directory

This folder contains all game assets for Raccoon Story.

## 📁 Structure

- `/images` - Sprites, textures, tilesets, backgrounds
- `/sounds` - Sound effects (.wav, .ogg)
- `/music` - Music tracks (.ogg recommended)
- `/fonts` - Font files (.ttf, .otf)
- `/shaders` - GLSL shader source files

## 🎨 Asset Guidelines

### Images
- **Sprite Size**: 32x32 pixels for most entities
- **Format**: PNG with transparency
- **Naming**: Use lowercase with underscores (e.g., `raccoon_walk.png`)
- **Organization**: Group by type (characters, items, environment)

### Audio
- **Sound Effects**: WAV or OGG format, short and punchy
- **Music**: OGG format (better compression for looping tracks)
- **Volume**: Normalize audio levels to avoid clipping
- **Naming**: Descriptive names (e.g., `trash_pickup.wav`, `night_theme.ogg`)

### Fonts
- **Format**: TTF or OTF
- **License**: Ensure fonts are free for commercial use or properly licensed
- **Recommendation**: Rounded, friendly fonts that match the cozy aesthetic

### Shaders
- **Format**: GLSL shader files (.glsl)
- **Documentation**: Comment shader code explaining parameters and effects
- **Testing**: Test on multiple platforms for compatibility

## 📝 Asset Credits

Keep track of all third-party assets and their licenses:

- **Asset Name** - Creator - License - URL

## 🚀 Loading Assets

Assets are loaded via the asset management system in `/src/utils/assets.lua`.

Example:
```lua
local Assets = require("src.utils.assets")
Assets:loadImage("raccoon", "assets/images/raccoon.png")
```

## 🎨 Art Style Reference

See [GAME_DESIGN.md](../GAME_DESIGN.md) Section 6 for art style guidelines, color palette, and visual specifications.
