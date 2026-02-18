# Systems

Core game systems that manage gameplay logic.

## System Pattern

Systems typically manage collections of entities or game-wide state:

```lua
local SystemName = {}

function SystemName:init()
  -- Initialize system
end

function SystemName:update(dt, entities)
  -- Update logic for all managed entities
end

function SystemName:cleanup()
  -- Clean up resources
end

return SystemName
```

## Systems

- `CollisionSystem.lua` - Collision detection and response
- `AISystem.lua` - Enemy AI behaviors and pathfinding
- `InventorySystem.lua` - Player inventory management
- `TimeSystem.lua` - Night cycle and time tracking
