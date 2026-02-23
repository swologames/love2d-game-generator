# DungeonMap System - Integration Guide

## Overview
The DungeonMap system provides level loading and grid management for Phase 2 of the scifi-dungeon game. It loads level data from Lua files and provides efficient queries for collision detection, special cells, and interactions.

## Files Created

### 1. `/src/systems/DungeonMap.lua` (285 lines)
Core system that manages:
- Loading level data from Lua files
- 2D grid storage and queries
- Cell type management (walls, doors, terminals, etc.)
- Walkability and collision detection
- Special cell caching and lookup
- Dynamic cell modification (opening doors, revealing secrets)

### 2. `/levels/deck1.lua`
Sample level demonstrating:
- 20×20 grid layout for District 1 (The Sprawl)
- All cell types in use
- Player spawn point
- Metadata (name, district, difficulty)
- Optional data structures for Phase 3 (enemies, loot)

## API Reference

### Creating and Loading

```lua
local DungeonMap = require("src.systems.DungeonMap")

-- Create new instance
local map = DungeonMap:new()

-- Load a level
local success, error = map:loadLevel("levels/deck1.lua")
if not success then
  print("Failed to load:", error)
end
```

### Cell Queries

```lua
-- Get cell type at position
local cellType = map:getCell(x, y)

-- Check if position is walkable
local canWalk = map:isWalkable(x, y)

-- Check if cell blocks line of sight
local blocks = map:isBlocking(x, y)

-- Check if cell is a hazard (deals damage)
local isHazard = map:isHazard(x, y)

-- Check if cell can be interacted with
local canInteract = map:isInteractable(x, y)
local interactionType = map:getInteractionType(x, y)
-- Returns: "door", "terminal", "stairs_down", "stairs_up", or nil
```

### Special Cell Lookup

```lua
-- Get all cells of a specific type
local doors = map:getSpecialCells("DOOR_LOCKED")
local terminals = map:getSpecialCells("TERMINAL")
local hazards = map:getSpecialCells("HAZARD")

-- Each entry has: {x = col, y = row, type = cellTypeCode}
for _, door in ipairs(doors) do
  print("Door at", door.x, door.y)
end
```

### Dynamic Modification

```lua
-- Open a door (converts locked/closed door to floor)
local opened = map:openDoor(x, y)

-- Reveal a secret wall
local revealed = map:revealSecretWall(x, y)

-- Set cell type directly
map:setCell(x, y, map.CELL_TYPES.FLOOR)
```

### Map Information

```lua
-- Get dimensions
local width = map:getWidth()
local height = map:getHeight()

-- Get metadata
local meta = map:getMetadata()
print(meta.name)        -- "Sprawl Entrance"
print(meta.district)    -- "The Sprawl"
print(meta.difficulty)  -- 1

-- Check if level is loaded
local loaded = map:isLoaded()
```

### RaycasterSystem Integration

```lua
-- Export grid as 2D array for RaycasterSystem
local gridArray = map:toArray()

-- Usage in RaycasterSystem
raycaster:loadMap(gridArray)
```

## Cell Type Constants

```lua
DungeonMap.CELL_TYPES = {
  FLOOR = 0,           -- Walkable empty space
  WALL_STANDARD = 1,   -- Solid wall
  WALL_DAMAGED = 2,    -- Damaged wall (future: destructible)
  DOOR = 3,            -- Open door (walkable)
  DOOR_LOCKED = 4,     -- Locked door (requires key/hack)
  TERMINAL = 5,        -- Interactive computer terminal
  STAIRS_DOWN = 6,     -- Progress to next level
  STAIRS_UP = 7,       -- Return to previous level
  HAZARD = 8,          -- Damage-dealing tile (radiation, acid)
  SECRET_WALL = 9      -- Hidden passage (revealed by scan)
}

-- Get name from code
local name = map:getCellName(cellType)

-- Get code from name
local code = map:getCellTypeByName("DOOR_LOCKED")
```

## Integration with Existing Systems

### DungeonScene.lua Integration

```lua
-- In DungeonScene:enter()
local DungeonMap = require("src.systems.DungeonMap")

function DungeonScene:enter(levelPath)
  self.map = DungeonMap:new()
  local success = self.map:loadLevel(levelPath or "levels/deck1.lua")
  
  if not success then
    -- Handle error (fallback to menu or show error screen)
    return
  end
  
  -- Get player start position from level metadata
  local levelData = require(levelPath:gsub("%.lua$", ""):gsub("/", "."))
  if levelData.playerStart then
    self.playerX = levelData.playerStart.x
    self.playerY = levelData.playerStart.y
    self.playerFacing = levelData.playerStart.facing or "south"
  end
  
  -- Pass map grid to RaycasterSystem
  self.raycaster:loadMap(self.map:toArray())
end

-- In movement logic
function DungeonScene:movePlayer(dx, dy)
  local newX = self.playerX + dx
  local newY = self.playerY + dy
  
  if self.map:isWalkable(newX, newY) then
    self.playerX = newX
    self.playerY = newY
    
    -- Check for hazards
    if self.map:isHazard(newX, newY) then
      self:dealEnvironmentalDamage()
    end
    
    return true
  end
  
  return false
end

-- In interaction handler (Space key)
function DungeonScene:interact()
  -- Check cell in front of player
  local checkX, checkY = self:getForwardCell()
  
  if self.map:isInteractable(checkX, checkY) then
    local interactionType = self.map:getInteractionType(checkX, checkY)
    
    if interactionType == "door" then
      self.map:openDoor(checkX, checkY)
      self.raycaster:loadMap(self.map:toArray()) -- Refresh raycaster
    elseif interactionType == "terminal" then
      self:showTerminalInterface()
    elseif interactionType == "stairs_down" then
      self:progressToNextLevel()
    end
  end
end
```

### RaycasterSystem Integration

```lua
-- RaycasterSystem expects numeric grid where:
-- 0 = empty/walkable
-- >0 = wall/blocking

-- The toArray() method returns compatible format
local grid = dungeonMap:toArray()
raycaster:loadMap(grid)

-- Update raycaster when map changes (doors open, etc.)
dungeonMap:openDoor(x, y)
raycaster:loadMap(dungeonMap:toArray())
```

### MinimapSystem Integration

```lua
-- MinimapSystem can use the same grid
local grid = dungeonMap:toArray()
minimap:setMap(grid, dungeonMap:getWidth(), dungeonMap:getHeight())

-- Update minimap when exploring (Phase 3)
minimap:revealCell(playerX, playerY)
```

### CollisionSystem Integration

```lua
-- Use DungeonMap for movement validation
function CollisionSystem:canMoveTo(x, y)
  return dungeonMap:isWalkable(x, y)
end

-- Check multiple positions for entity collision
function CollisionSystem:validateEntityMove(entity, dx, dy)
  local newX = entity.x + dx
  local newY = entity.y + dy
  
  -- Check map collision
  if not dungeonMap:isWalkable(newX, newY) then
    return false
  end
  
  -- Check entity-entity collision (Phase 3)
  return not self:isOccupied(newX, newY)
end
```

## Creating New Levels

### Level File Template

```lua
-- levels/deck2_room1.lua

local CELL = {
  FLOOR = 0, WALL = 1, DOOR = 3, DOOR_LOCKED = 4,
  TERMINAL = 5, STAIRS_DOWN = 6, STAIRS_UP = 7,
  HAZARD = 8, SECRET = 9
}

local F, W, D, L, T, N, U, H, S = 
  CELL.FLOOR, CELL.WALL, CELL.DOOR, CELL.DOOR_LOCKED,
  CELL.TERMINAL, CELL.STAIRS_DOWN, CELL.STAIRS_UP,
  CELL.HAZARD, CELL.SECRET

return {
  name = "Your Level Name",
  district = "The Undergrid",
  difficulty = 2,
  description = "Description here",
  
  grid = {
    {W, W, W, W, W},
    {W, U, F, F, W},
    {W, F, F, F, W},
    {W, F, F, N, W},
    {W, W, W, W, W}
  },
  
  playerStart = {x = 2, y = 2, facing = "south"},
  
  -- Optional Phase 3 data
  enemySpawns = {},
  loot = {},
  events = {}
}
```

### Level Design Tips

1. **Grid indexing**: `grid[row][column]` where [1][1] is top-left
2. **Border walls**: Surround level with walls (WALL = 1)
3. **Entry/Exit**: Place STAIRS_UP near start, STAIRS_DOWN at end
4. **Pacing**: Use locked doors to gate progression
5. **Hazards**: Place strategically to add risk/reward
6. **Secrets**: Hide doors/terminals behind SECRET_WALL cells
7. **Size**: 20×20 minimum, 40×40 maximum for performance

## Performance Notes

- **Cell queries** are O(1) - safe to call every frame
- **Special cell cache** is built once on load
- **toArray()** creates a copy - cache the result in systems
- **Grid updates** rebuild special cell cache - use sparingly

## Phase 3 Extensions

Future additions to consider:
- Enemy spawn points and patrol paths
- Loot container positions and rarity
- Trigger zones for events/traps
- Environmental effects (lighting, fog)
- Multi-floor connections
- Procedural generation hooks

## Testing

To verify the system works, add this to DungeonScene:

```lua
-- In love.load() or scene:enter()
local DungeonMap = require("src.systems.DungeonMap")
local testMap = DungeonMap:new()
local success = testMap:loadLevel("levels/deck1.lua")
print("DungeonMap test:", success and "✓ PASS" or "✗ FAIL")
```

## Troubleshooting

**"Failed to load level file"**
- Check that path is correct relative to game root
- Ensure file returns a valid Lua table
- Verify cell type constants match DungeonMap.CELL_TYPES

**"Invalid grid dimensions"**
- Ensure grid is not empty
- All rows must have same width
- Grid must be indexed [row][column]

**Map not updating after changes**
- Call `raycaster:loadMap(map:toArray())` after modifications
- Check that setCell/openDoor returned true

**Walkability issues**
- Verify cell type is in walkable list (see isWalkable())
- Check that DOOR cells are not DOOR_LOCKED
- Ensure position is within bounds (1 to width/height)

## Next Steps

1. **Integrate into DungeonScene**: Load map on scene enter
2. **Connect to movement**: Use isWalkable() for player movement
3. **Add interactions**: Implement door opening and terminals
4. **Create more levels**: Use deck1.lua as template
5. **Test with raycaster**: Verify visual rendering matches grid
6. **Add hazard damage**: Implement damage on HAZARD cells
7. **Phase 3 prep**: Plan enemy spawn and loot systems

---

**File Size**: DungeonMap.lua is well under 300 lines (285 lines including comments), meeting the componentization requirements.
