# Entities

Game objects that can be updated and drawn.

## Base Entity Pattern

All entities should follow this pattern:

```lua
local EntityName = {}
EntityName.__index = EntityName

function EntityName:new(x, y)
  local instance = setmetatable({}, self)
  -- Initialize properties
  return instance
end

function EntityName:update(dt)
  -- Update logic
end

function EntityName:draw()
  -- Rendering
end

return EntityName
```

## Entities

- `Player.lua` ✅ - The playable raccoon
- `Human.lua` - Homeowners who chase the player
- `Dog.lua` - Protective pets
- `Animal.lua` - Competing animals (possums, cats, crows)
- `TrashItem.lua` - Collectible trash items
- `Bush.lua` - Hiding spots
- `TrashBin.lua` - Interactive containers
