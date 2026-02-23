# Love2D Game Development - Copilot Instructions

## Project Context
You are assisting with the development of Love2D games in a multi-game workspace. Each game is located in its own folder under `games/` and is a complete, independent, runnable Love2D project. Always refer to the Game Design Document (GDD) named `GAME_DESIGN.md` in the root of each game's folder to ensure implementation aligns with the design vision.

**Multi-Game Structure:**
- `games/[game-name]/GAME_DESIGN.md` - Game Design Document for each game
- `docs/GAME_DESIGN_TEMPLATE.md` - Template for new game GDDs

## Important: Task Delegation Workflow

**All game development tasks should be coordinated through the @game-designer agent first.**

When a user asks for game development help:
1. **Direct them to @game-designer** for task analysis and delegation
2. The Game Designer agent will review the GDD and coordinate specialized agents
3. Only provide direct implementation if explicitly working as a specialized agent

**Example responses to user requests:**

User: "I need to add a player health bar"
You: "Let me direct this to the Game Designer agent to coordinate the implementation:

@game-designer Please implement a player health bar according to the GDD specifications. This will involve UI components, HUD integration, and connection to the gameplay health system."

User: "The player jump feels wrong"
You: "This requires analysis and coordination. Let me engage the Game Designer:

@game-designer The player jump mechanic needs adjustment. Please review the GDD specifications and coordinate with @gameplay and @physics to tune the jump feel."

User: "Set up a new platformer game"
You: "@game-designer Please help set up a new platformer game from scratch, coordinating the foundation across all systems according to the GDD."

**Only implement directly when:**
- You are explicitly invoked as a specialized agent (e.g., @ui, @gameplay)
- The user specifically requests implementation without coordination
- Providing general Love2D framework guidance unrelated to the current game

## Multi-Game Project Structure

This workspace supports multiple independent Love2D game projects, each in its own folder under `games/`.

### Folder Structure
```
games/
├── my-platformer/              # Complete runnable Love2D project
│   ├── GAME_DESIGN.md          # Game-specific GDD (required)
│   ├── main.lua                # Love2D entry point
│   ├── conf.lua                # Love2D configuration
│   ├── /src                    # Source code
│   └── /assets                 # Game assets
├── space-shooter/              # Another independent game
│   ├── GAME_DESIGN.md
│   ├── main.lua
│   └── ...
```

### Game Context Detection

AI agents detect which game you're working on through:

**A. Explicit folder name in request:**
```
@game-designer In the "my-platformer" game, add a jump mechanic
```

**B. Agent mention with game suffix:**
```
@game-designer:my-platformer add a jump mechanic
```

**C. Inferred from open file context:**
- Open any file from `games/my-platformer/`
- Request: `@game-designer add a jump mechanic`
- Agent automatically detects "my-platformer" from file path

### Creating New Games

When a user requests a new game without specifying a folder name:
1. Ask for the game folder name first
2. Create the folder structure under `games/[folder-name]/`
3. Copy `docs/GAME_DESIGN_TEMPLATE.md` to `games/[folder-name]/GAME_DESIGN.md`
4. Generate basic `main.lua`, `conf.lua`, and folder structure
5. Guide user to fill out the GDD before implementing features

### Running Games

Each game is run independently:
```bash
cd games/[game-name]
love .
```

### Design Principles

- **Complete independence**: Each game is self-contained with no shared code
- **Unique GDD**: Each game has `GAME_DESIGN.md` at its root
- **Standard structure**: All games follow Love2D best practices
- **Clear naming**: Use kebab-case for folder names (e.g., `space-shooter`, `puzzle-adventure`)

## Love2D Framework Guidelines

### Core Principles
- **Version**: Target Love2D 11.4+ unless specified otherwise in the GDD
- **Language**: Lua 5.1/LuaJIT
- **Convention**: Use clear, idiomatic Lua code with proper module structure
- **Performance**: Optimize for 60 FPS target; avoid unnecessary allocations in update/draw loops
- **Organization**: Follow the project structure defined in the GDD

### Code Style
- Use 2-space indentation
- Use `camelCase` for variables and functions
- Use `PascalCase` for classes/modules
- Add comments for complex logic, but prefer self-documenting code
- Group related functions together
- Use local variables whenever possible for performance

### Project Structure
```lua
/project-root
├── main.lua                 -- Entry point
├── conf.lua                 -- Love2D configuration
├── /src
│   ├── /scenes             -- Scene manager and individual scenes
│   ├── /entities           -- Game entities (Player, Enemy, etc.)
│   ├── /systems            -- Systems (Physics, Collision, etc.)
│   ├── /ui                 -- UI components and menus
│   ├── /utils              -- Utility functions and helpers
│   ├── /audio              -- Audio manager and sound logic
│   └── /shaders            -- GLSL shader files
├── /assets
│   ├── /images             -- Sprites, textures, tilesets
│   ├── /sounds             -- Sound effects (.wav, .ogg)
│   ├── /music              -- Music tracks (.ogg)
│   ├── /fonts              -- Font files (.ttf, .otf)
│   └── /shaders            -- Shader source files (.glsl)
└── /lib                    -- External libraries
```

### Love2D Callbacks
Always implement required Love2D callbacks properly:

```lua
function love.load()
  -- Initialize game state, load assets
end

function love.update(dt)
  -- Update game logic, dt is delta time in seconds
end

function love.draw()
  -- Render everything to screen
end

function love.keypressed(key)
  -- Handle key press events
end

function love.mousepressed(x, y, button)
  -- Handle mouse click events
end
```

### Common Patterns

#### Object-Oriented Approach
```lua
-- Entity base class
local Entity = {}
Entity.__index = Entity

function Entity:new(x, y)
  local instance = setmetatable({}, self)
  instance.x = x or 0
  instance.y = y or 0
  return instance
end

function Entity:update(dt)
  -- Override in subclasses
end

function Entity:draw()
  -- Override in subclasses
end

return Entity
```

#### Scene Management
```lua
-- SceneManager pattern
local SceneManager = {
  current = nil,
  scenes = {}
}

function SceneManager:register(name, scene)
  self.scenes[name] = scene
end

function SceneManager:switch(name, ...)
  if self.current and self.current.exit then
    self.current:exit()
  end
  
  self.current = self.scenes[name]
  
  if self.current and self.current.enter then
    self.current:enter(...)
  end
end

function SceneManager:update(dt)
  if self.current and self.current.update then
    self.current:update(dt)
  end
end

function SceneManager:draw()
  if self.current and self.current.draw then
    self.current:draw()
  end
end

return SceneManager
```

#### Asset Loading
```lua
-- Centralized asset management
local Assets = {
  images = {},
  sounds = {},
  music = {},
  fonts = {}
}

function Assets:loadImage(name, path)
  self.images[name] = love.graphics.newImage(path)
  return self.images[name]
end

function Assets:loadSound(name, path, type)
  self.sounds[name] = love.audio.newSource(path, type or "static")
  return self.sounds[name]
end

function Assets:getImage(name)
  return self.images[name]
end

function Assets:getSound(name)
  return self.sounds[name]
end

return Assets
```

### Performance Best Practices
1. **Batch Draw Calls**: UseSpriteBatches for repeated sprites
2. **Object Pooling**: Reuse objects instead of creating/destroying
3. **Avoid table.insert in hot loops**: Pre-allocate when possible
4. **Use local copies of globals**: `local lg = love.graphics`
5. **Profile with love.timer**: Identify bottlenecks
6. **Limit string concatenation**: Use table.concat for multiple strings

### Common Love2D Functions

#### Graphics
```lua
love.graphics.draw(drawable, x, y, r, sx, sy, ox, oy)
love.graphics.rectangle(mode, x, y, width, height)
love.graphics.circle(mode, x, y, radius)
love.graphics.print(text, x, y)
love.graphics.setColor(r, g, b, a)  -- 0-1 range in Love2D 11.0+
love.graphics.push() / love.graphics.pop()
love.graphics.translate(dx, dy)
love.graphics.scale(sx, sy)
```

#### Input
```lua
love.keyboard.isDown(key)
love.mouse.getPosition()
love.mouse.isDown(button)
```

#### Audio
```lua
source:play()
source:pause()
source:stop()
source:setVolume(volume)  -- 0-1 range
source:setLooping(loop)
```

### Error Handling
Always add error handling for asset loading:

```lua
local success, result = pcall(function()
  return love.graphics.newImage("path/to/image.png")
end)

if not success then
  print("Failed to load image:", result)
  -- Fallback behavior
end
```

### Configuration (conf.lua)
```lua
function love.conf(t)
  t.title = "Game Title"
  t.version = "11.4"
  t.window.width = 1280
  t.window.height = 720
  t.window.resizable = false
  t.window.vsync = 1
  t.modules.joystick = true
  t.modules.physics = true
end
```

## Specialized Agent Coordination

**Primary Workflow: Use @game-designer as the central coordinator for all game development tasks.**

The @game-designer agent is your first point of contact. It will:
- Analyze the user's request against the GDD
- Break down complex features into manageable tasks
- Delegate to the appropriate specialized agents with clear instructions
- Ensure proper integration across systems
- Maintain GDD compliance throughout implementation

### Available Specialized Agents

The Game Designer coordinates these specialized agents:

- **@game-designer**: Central coordinator - USE THIS FIRST for all game development requests
- **@ui**: For UI components, menus, HUD elements
- **@gameplay**: For player mechanics, enemy AI, game rules
- **@gameflow**: For scene management, transitions, game states
- **@audio**: For music, sound effects, audio systems
- **@graphics**: For shaders, particle effects, visual polish
- **@physics**: For collision detection, physics simulation
- **@assets**: For asset loading, management, optimization
- **@animation**: For sprite animations, tweening

### When to Invoke Agents Directly

Direct agent invocation is appropriate when:
1. **You ARE that specialized agent** responding to a @mention
2. **The Game Designer has delegated a specific task** to you
3. **Providing general Love2D framework guidance** not specific to the current game
4. **The user explicitly requests** direct implementation without coordination

### Default Response Pattern

For game development requests, use this pattern:

```
I'll coordinate this through the Game Designer agent:

@game-designer [Describe the user's request and what needs to be implemented]
```

The Game Designer will then delegate to specialized agents as needed and ensure proper GDD alignment and system integration.

## Testing & Debugging
- Test frequently using `love .` in the project directory
- Use `print()` statements or a debug overlay for development
- Check `love.errorhandler` for runtime errors
- Profile performance with `love.timer.getTime()`

## Documentation
- Add comments explaining "why" not "what"
- Document public API functions with usage examples
- Keep the GDD updated when implementing new features
- Document any deviations from the GDD with rationale

## CRITICAL: File Size & Componentization Rules

> ⚠️ **These rules are NON-NEGOTIABLE for all Love2D game code in this workspace.**

### Hard File Size Limits
- **MAXIMUM 400 lines per Lua file.** Any file that exceeds this MUST be split before new code is added.
- **MAXIMUM 500 lines** only for top-level scene orchestrators that do nothing but wire sub-systems.
- Any file approaching 250 lines should be reviewed for extraction opportunities.

### Mandatory Componentization
- **One responsibility per file.** A file that handles movement AND combat AND input AND state violates this — split it.
- Scenes are thin orchestrators: they `require` entities and systems; they never define them.
- Data tables (config, asset manifests, level data) live in dedicated `data/` files, never inside logic files.
- **Prefer 10 small focused files over 1 large file** every single time.

### Enforcement
- Before adding any code to an existing file, check its line count. If >250 lines, refactor first.
- Before creating a new file, verify it has only one clear responsibility.
- Never put multiple unrelated classes or systems in the same file.

### Ideal Module Sizes
| Type | Target | Maximum |
|------|--------|---------|
| Entity orchestrator | <150 lines | 250 lines |
| Entity sub-module (movement, combat, etc.) | <200 lines | 300 lines |
| System | <250 lines | 300 lines |
| Scene | <300 lines | 500 lines |
| UI component | <200 lines | 300 lines |
| Data/config file | any | no limit |

## Common Pitfalls to Avoid
1. Forgetting `local` keyword (causes global pollution)
2. Modifying tables while iterating over them
3. Not handling asset loading errors
4. Creating new objects every frame (garbage collection spikes)
5. Ignoring delta time in update logic
6. Hardcoding values instead of using the GDD specifications
7. Not testing on target platforms
8. **Writing monolithic files instead of componentizing** (most common maintenance issue)

## Resources
- Official Love2D Wiki: https://love2d.org/wiki/
- API Documentation: https://love2d.org/wiki/love
- Community: https://love2d.org/forums/

---

**Remember**: Always consult the Game Design Document first before implementing features. Stay true to the design vision while writing clean, performant Love2D code.
