# Level Design Guide

## Overview
Levels in Mecha Shmup are defined using Lua table files. This allows for precise control over enemy patterns, timing, and gameplay flow without code changes.

##Location
Level files are stored in: `levels/level<N>.lua`

## Level Structure

```lua
return {
  name = "Level Name",              -- Display name
  description = "Level description",  -- Optional description  
  duration = 90,                     -- Level duration in seconds
  
  events = {
    -- Array of timeline events
    {time = 1.0, type = "spawn", enemy = "scout", x = 100, y = -50},
    {time = 5.0, type = "formation", pattern = "line", enemy = "interceptor", count = 5},
    -- ...more events
  }
}
```

## Event Types

### 1. spawn - Single Enemy
Spawns a single enemy at a specific position.

```lua
{
  time = 1.0,           -- Time in seconds from level start
  type = "spawn",
  enemy = "scout",      -- Enemy type: scout, interceptor, bomber, kamikaze
  x = 320,              -- X position (0-640)
  y = -50               -- Y position (negative = above screen)
}
```

### 2. formation - Enemy Formation
Spawns a group of enemies in a specific pattern.

```lua
{
  time = 10.0,
  type = "formation",
  pattern = "vformation",   -- Pattern: line, vformation, wave, diamond, swarm
  enemy = "interceptor",    -- Enemy type for whole formation
  count = 5                 -- Number of enemies
}
```

**Formation Patterns:**
- `line` - Horizontal line
- `vformation` - V-shaped formation
- `wave` - Sine wave pattern
- `diamond` - Diamond/rhombus shape
- `swarm` - Tight circular cluster

### 3. boss - Boss Battle
Spawns a boss enemy.

```lua
{
  time = 85.0,
  type = "boss",
  boss = "vorkath"      -- Boss identifier
}
```

### 4. powerup - Power-up Drop
Spawns a specific power-up item.

```lua
{
  time = 30.0,
  type = "powerup",
  powerupType = "health",   -- Type: health, weapon, special, shield, score
  x = 320,                  -- X position (optional, random if not specified)
  y = -50                   -- Y position (optional)
}
```

### 5. message - Display Message
Shows a message to the player.

```lua
{
  time = 80.0,
  type = "message",
  text = "WARNING: BOSS APPROACHING",
  duration = 3              -- Display duration in seconds (optional, default 3)
}
```

### 6. background - Change Background Theme
Changes the visual background theme with optional smooth transition.

```lua
{
  time = 35.0,
  type = "background",
  theme = "nebula",        -- Theme: space, water, mechanical, crystal, nebula, forest
  instant = false          -- Optional: true for instant change, false for smooth transition (default)
}
```

**Available Themes:**
- `space` - Deep space with stars (default)
- `water` - Ocean depths with waves and caustics shader
- `mechanical` - Tech sector with circuit patterns and energy flows
- `crystal` - Crystal caverns with geometric fractal patterns
- `nebula` - Nebula field with colorful clouds
- `forest` - Forest canopy with trees and foliage

**Debug Controls:**
- Press `F3` to enable debug mode
- Press `1` (in debug mode) to cycle through backgrounds manually

## Enemy Types

| Type | HP | Speed | Behavior | Movement Pattern |
|------|-----|-------|----------|------------------|
| `scout` | 10 | Fast | V-pattern bullets (2 ethereal, 1 solid) | Sine wave |
| `interceptor` | 25 | Medium | Aims at player (1 ethereal, 2 solid) | Sine wave |
| `bomber` | 40 | Slow | Wide spread (4 ethereal, 5 solid) | Sine wave |
| `kamikaze` | 15 | Very Fast | No bullets, rushes player | Rush |
| `hunter` | 18 | Fast | Aimed burst (2+2 bullets) | Zigzag |
| `sniper` | 12 | Slow | Single precise shot | Hover |
| `artillery` | 35 | Very Slow | Heavy barrage spread | Strafe |

## Movement Patterns

Enemies now use a **multi-phase movement system** with three phases:

### Phase Structure
Each enemy movement pattern consists of:
1. **Intro Phase** - Entry behavior (controlled entrance)
2. **Main Phase** - Primary attack pattern
3. **Exit Phase** - Leaving behavior (accelerate away, strafe off, etc.)

### Available Patterns

**Sine Wave** (scout, interceptor, bomber)
- Intro: Gentle descent
- Main: Classic sine wave motion
- Exit: Continue offscreen

**Zigzag** (hunter)
- Intro: Controlled descent at 70% speed
- Main: Sharp lateral zigzag movements
- Exit: Offscreen

**Circular** (can be configured)
- Intro: Slow descent
- Main: Expanding spiral pattern (8 seconds)
- Exit: Accelerate downward

**Dive** (can be configured)
- Intro: Sine wave descent (1.5s)
- Main: Triggered at Y=200, dives toward player
- Exit: Offscreen

**Hover** (sniper)
- Intro: Descend to position
- Main: Hover with drift (8 seconds)
- Exit: Strafe sideways while leaving

**Strafe** (artillery)
- Intro: Side entrance with curve
- Main: Side-to-side motion (6 seconds)
- Exit: Accelerate downward

**Rush** (kamikaze)
- Intro: Brief slow descent
- Main: Rush directly at player
- Exit: Offscreen

### Phase Behaviors

**Intro Behaviors:**
- `descend` - Simple downward movement with speed modifier
- `sine_descent` - Descend with gentle sine wave
- `side_entrance` - Enter from side with curve

**Main Behaviors:**
- `sine` - Classic wave pattern
- `zigzag` - Sharp directional changes
- `circular` - Spiral with expanding radius
- `dive_attack` - Lock onto and charge player
- `strafe` - Horizontal oscillation
- `hover_drift` - Stay at position with gentle movement
- `rush` - Direct pursuit of player

**Exit Behaviors:**
- `offscreen` - Continue current movement until leaving
- `accelerate_down` - Speed up and exit downward
- `strafe_exit` - Move sideways while exiting

This creates much more dynamic and interesting enemy behavior compared to simple single-pattern movement!

## Design Tips

### Timing
- Start with simple patterns in first 10-20 seconds
- Build intensity gradually
- Leave breathing room between major attacks
- Boss battles typically start around 80-90 seconds

### Formations
- Mix formation types for visual variety
- Use different enemy types to vary difficulty
- Consider player position when placing formations

### Pacing Example
```lua
0-15s:   Introduction - Simple scouts
15-30s:  Build-up - Add interceptors and formations
30-50s:  Intensity - Mixed enemies, complex patterns
50-70s:  Climax - Heavy bombardment, swarms
70-80s:  Calm before storm - Clear screen, drop power-up
80-90s:  Boss preparation - Warning message
90s+:    Boss battle
```

### Power-up Placement
- Place health power-ups before difficult sections
- Weapon power-ups work well mid-level
- Strategic placement rewards skilled dodging

## Testing
1. Edit your level file in `levels/levelN.lua`
2. Run the game
3. Level will load automatically
4. Iterate on timing and difficulty

## Multiple Levels
The game automatically loads the next level when the current one completes. If no next level exists, it falls back to random spawning.

levels/level1.lua → level2.lua → level3.lua → etc.

## Example: Simple Level

```lua
return {
  name = "Practice Run",
  duration = 60,
  
  events = {
    -- Opening scouts
    {time = 2, type = "spawn", enemy = "scout", x = 200, y = -50},
    {time = 2.5, type = "spawn", enemy = "scout", x = 440, y = -50},
    
    -- First formation
    {time = 10, type = "formation", pattern = "line", enemy = "scout", count = 4},
    
    -- Power-up
    {time = 20, type = "powerup", powerupType = "weapon", x = 320, y = -50},
    
    -- Bomber introduction
    {time = 30, type = "spawn", enemy = "bomber", x = 320, y = -50},
    
    -- Boss warning
    {time = 50, type = "message", text = "BOSS INCOMING!", duration = 2},
    
    -- Boss
    {time = 55, type = "boss", boss = "vorkath"},
  }
}
```

## Advanced: Dynamic Spawning

Since level files are Lua code, you can use logic:

```lua
-- Generate a wave of enemies
local events = {}
for i = 1, 10 do
  table.insert(events, {
    time = i * 2,
    type = "spawn",
    enemy = (i % 2 == 0) and "scout" or "interceptor",
    x = 50 + i * 50,
    y = -50
  })
end

return {
  name = "Generated Level",
  duration = 60,
  events = events
}
```
