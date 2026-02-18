# Source Code Directory

This folder contains all source code for Raccoon Story, organized by functional area.

## 📁 Structure

- `/scenes` - Scene manager and individual game scenes
- `/entities` - Game objects (Player, Humans, Animals, Items)
- `/systems` - Core game systems (Collision, AI, Time, Inventory)
- `/ui` - User interface components (Buttons, HUD, Menus)
- `/utils` - Utility functions and helpers
- `/shaders` - GLSL shader implementations

## 🏗️ Architecture

### Scenes
Manage different game states and screens using the Scene Manager pattern.

- `SceneManager.lua` - Central scene coordinator
- `MenuScene.lua` - Main menu
- `DenScene.lua` - Home base / safe zone
- `GameScene.lua` - Active gameplay area

### Entities
Game objects that can be updated and drawn.

Base entity pattern:
```lua
local Entity = {}
Entity.__index = Entity

function Entity:new(x, y)
  -- Constructor
end

function Entity:update(dt)
  -- Update logic
end

function Entity:draw()
  -- Rendering
end

return Entity
```

### Systems
Core gameplay systems that manage collections of entities or game-wide logic.

- `CollisionSystem.lua` - Collision detection and response
- `AISystem.lua` - Enemy AI behaviors and pathfinding
- `InventorySystem.lua` - Player inventory management
- `TimeSystem.lua` - Night cycle and time management

### UI
Reusable user interface components.

- `Button.lua` - Interactive button widget
- `HUD.lua` - Heads-up display overlay
- `Menu.lua` - Menu framework

### Utils
Helpers and utility functions.

- `helpers.lua` - Common utility functions
- `assets.lua` - Asset loading and management

## 🎯 Code Style

- Use 2-space indentation
- Use `camelCase` for variables and functions
- Use `PascalCase` for modules/classes
- Add comments for complex logic
- Use local variables for performance
- Group related functions together

## 📚 Module Loading

Use Love2D's require system with forward slashes:

```lua
local Player = require("src.entities.Player")
local CollisionSystem = require("src.systems.CollisionSystem")
```

## 🔄 Update Order

Typical frame update order:
1. Input handling
2. Entity updates
3. System updates (AI, collision, etc.)
4. State management
5. Rendering

## 🚀 Getting Started

1. Start by implementing core entities (Player, TrashItem)
2. Build the basic game scene
3. Add systems as needed
4. Polish with UI and effects

See [GAME_DESIGN.md](../GAME_DESIGN.md) for complete specifications.
