# Background System

## Overview
The BackgroundSystem provides dynamic, shader-based backgrounds that can be controlled through level scripts. Each background theme uses procedural generation and GLSL shaders for high visual fidelity without requiring large texture assets.

## Available Themes

### 1. Space (Default)
- **Visual**: Deep space with parallax stars
- **Style**: Classic shoot-em-up background
- **Best For**: Menu, space combat, default levels
- **Colors**: Dark blue/black with white stars

### 2. Water
- **Visual**: Animated ocean waves with caustics shader
- **Features**: 
  - Multi-layered wave animation
  - Underwater caustics effect
  - Depth gradient (lighter at top, darker below)
  - Floating bubble particles
- **Best For**: Underwater sections, fluid combat zones
- **Colors**: Deep blues and teals

### 3. Mechanical
- **Visual**: Tech sector with circuit patterns
- **Features**:
  - Grid lines (small and large)
  - Animated energy flows
  - Hexagonal patterns
  - Scanline effects
  - Tech spark particles
- **Best For**: Boss battles, industrial zones, tech levels
- **Colors**: Dark grey/blue with cyan accents

### 4. Crystal
- **Visual**: Geometric fractal patterns
- **Features**:
  - Kaleidoscope rotating effects
  - Fractal layer generation
  - Geometric shard patterns
  - Purple/pink/blue color scheme
  - Glowing gem particles
- **Best For**: Mystical areas, intense visual sections
- **Colors**: Purples, pinks, blues

### 5. Nebula
- **Visual**: Colorful nebula clouds
- **Features**:
  - Multi-octave fractal noise (FBM)
  - Animated cloud layers
  - Procedural star field
  - Color blending
  - Floating dust particles
- **Best For**: Space exploration, scenic sections
- **Colors**: Purple, pink, blue nebula clouds

### 6. Forest
- **Visual**: Forest canopy with scrolling trees
- **Features**:
  - Gradient green background
  - Parallax scrolling trees
  - Tree canopy silhouettes
  - Falling leaf particles
- **Best For**: Nature-themed levels, contrast to tech/space
- **Colors**: Dark to light greens

## Usage in Level Scripts

### Basic Background Change
```lua
{
  time = 30.0,
  type = "background",
  theme = "water"
}
```

### Instant Background Change
```lua
{
  time = 0.0,
  type = "background",
  theme = "space",
  instant = true  -- No transition, immediate change
}
```

### With Transition (Default)
```lua
{
  time = 50.0,
  type = "background",
  theme = "mechanical"
  -- Smooth 2-second fade transition (instant = false is default)
}
```

## Level Design Tips

### Timing Background Changes
- **Start of level**: Use `instant = true` at time = 0.0
- **Mid-level transitions**: Allow 2-second transition time
- **Before boss**: Change background 5-10 seconds before boss spawn for dramatic effect
- **Intensity building**: Use darker/more complex backgrounds (mechanical, crystal) for intense sections

### Theme Selection Guide
- **Easy sections**: Space, Forest (calmer visuals)
- **Medium difficulty**: Water, Nebula (moderate visual complexity)
- **High difficulty**: Mechanical, Crystal (intense visuals match gameplay intensity)
- **Boss battles**: Mechanical (tech bosses) or Crystal (mystical bosses)

### Example Timeline
```lua
events = {
  {time = 0.0, type = "background", theme = "space", instant = true},  -- Start calm
  {time = 30.0, type = "background", theme = "water"},                 -- Build atmosphere
  {time = 60.0, type = "background", theme = "mechanical"},            -- Increase intensity
  {time = 85.0, type = "message", text = "BOSS APPROACHING"},
  {time = 90.0, type = "boss", boss = "vorkath"}                       -- Boss with mechanical bg
}
```

## Debug Controls

When debug mode is enabled (Press `F3`):
- **Press `1`**: Cycle through all background themes
- **Title**: Current theme name displays in HUD

This allows rapid testing of background themes during level design.

## Technical Details

### Shader Implementation
- All shaders use GLSL (OpenGL Shading Language)
- Procedurally generated (no texture files needed)
- GPU-accelerated for 60 FPS performance
- Resolution-independent scaling

### Particle Systems
Each background includes themed particles:
- **Space**: Bright stars
- **Water**: Rising bubbles
- **Mechanical**: Tech sparks with life cycle
- **Crystal**: Rotating gem shards with glow
- **Nebula**: Floating dust clouds
- **Forest**: Falling leaves with rotation

### Performance
- Backgrounds render to canvas (single draw per frame)
- Particle updates use efficient table management
- Shader compilation happens once at startup
- Minimal CPU overhead during gameplay

## Customization

### Adding New Themes
1. Add shader code to `shaderCode` table in BackgroundSystem.lua
2. Define theme in `themes` table with:
   - `name`: Display name
   - `shader`: Shader name (or nil for non-shader rendering)
   - `particleCount`: Number of particles
   - `scrollSpeed`: Particle motion speed
   - `particleType`: Type of particles
   - `colors`: Color palette for particles
3. Implement non-shader rendering in `drawTheme()` if needed

### Modifying Existing Themes
Edit shader code in BackgroundSystem.lua:
- Adjust colors in shader `vec3` definitions
- Modify animation speeds (time multipliers)
- Change pattern scales and frequencies
- Tweak particle behavior in update/draw functions

## Integration

The BackgroundSystem is automatically initialized in GameScene and:
- Updates every frame with delta time
- Draws before all game entities
- Responds to level script background events
- Handles smooth transitions between themes

No manual initialization required - just use background events in level files!
