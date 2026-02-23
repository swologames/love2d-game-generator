-- DungeonMap.lua
-- Phase 2: Basic map loading system for grid-based dungeon levels
-- Loads level data from Lua files in levels/ directory
-- Manages 2D grid of cells with collision and interaction queries

local DungeonMap = {}
DungeonMap.__index = DungeonMap

-- Cell type constants
DungeonMap.CELL_TYPES = {
  FLOOR = 0,
  WALL_STANDARD = 1,
  WALL_DAMAGED = 2,
  DOOR = 3,
  DOOR_LOCKED = 4,
  TERMINAL = 5,
  STAIRS_DOWN = 6,
  STAIRS_UP = 7,
  HAZARD = 8,
  SECRET_WALL = 9
}

-- Reverse lookup for debugging
DungeonMap.CELL_NAMES = {}
for name, value in pairs(DungeonMap.CELL_TYPES) do
  DungeonMap.CELL_NAMES[value] = name
end

function DungeonMap:new()
  local instance = setmetatable({}, self)
  
  instance.grid = {}          -- 2D array [y][x] of cell types
  instance.width = 0          -- Map width
  instance.height = 0         -- Map height
  instance.metadata = {}      -- Level metadata (name, district, etc.)
  instance.specialCells = {}  -- Cache of special cell positions by type
  instance.loaded = false     -- Whether a level is currently loaded
  
  return instance
end

function DungeonMap:loadLevel(levelPath)
  print("[DungeonMap] Loading level:", levelPath)
  
  -- Attempt to load the level file
  local success, levelData = pcall(function()
    local chunk = love.filesystem.load(levelPath)
    if not chunk then
      error("Failed to load level file: " .. levelPath)
    end
    return chunk()
  end)
  
  if not success then
    print("[DungeonMap] ERROR:", levelData)
    return false, levelData
  end
  
  -- Validate level data structure
  if not levelData or type(levelData) ~= "table" then
    local err = "Invalid level data format"
    print("[DungeonMap] ERROR:", err)
    return false, err
  end
  
  if not levelData.grid or type(levelData.grid) ~= "table" then
    local err = "Level missing 'grid' table"
    print("[DungeonMap] ERROR:", err)
    return false, err
  end
  
  -- Store metadata
  self.metadata = {
    name = levelData.name or "Unnamed Level",
    district = levelData.district or "Unknown",
    difficulty = levelData.difficulty or 1,
    description = levelData.description or ""
  }
  
  -- Load grid data
  self.grid = levelData.grid
  self.height = #self.grid
  self.width = self.height > 0 and #self.grid[1] or 0
  
  -- Validate grid dimensions
  if self.width == 0 or self.height == 0 then
    local err = "Invalid grid dimensions"
    print("[DungeonMap] ERROR:", err)
    return false, err
  end
  
  -- Build special cells cache
  self:buildSpecialCellsCache()
  
  self.loaded = true
  print(string.format("[DungeonMap] Loaded: %s (%dx%d)", 
    self.metadata.name, self.width, self.height))
  
  return true
end

function DungeonMap:buildSpecialCellsCache()
  -- Clear existing cache
  self.specialCells = {}
  for cellType, _ in pairs(self.CELL_TYPES) do
    self.specialCells[cellType] = {}
  end
  
  -- Scan grid and cache special cell positions
  for y = 1, self.height do
    for x = 1, self.width do
      local cellType = self.grid[y][x]
      local cellName = self.CELL_NAMES[cellType]
      
      if cellName and cellType ~= self.CELL_TYPES.FLOOR and cellType ~= self.CELL_TYPES.WALL_STANDARD then
        table.insert(self.specialCells[cellName], {x = x, y = y, type = cellType})
      end
    end
  end
  
  -- Log special cells found
  for cellName, cells in pairs(self.specialCells) do
    if #cells > 0 then
      print(string.format("[DungeonMap] Found %d %s cells", #cells, cellName))
    end
  end
end

function DungeonMap:getCell(x, y)
  -- Return cell type at position (x, y)
  -- Returns nil if out of bounds
  if not self:isValidPosition(x, y) then
    return nil
  end
  
  return self.grid[y][x]
end

function DungeonMap:setCell(x, y, cellType)
  -- Set cell type at position (x, y)
  -- Used for dynamic changes (e.g., opening doors)
  if not self:isValidPosition(x, y) then
    return false
  end
  
  local oldType = self.grid[y][x]
  self.grid[y][x] = cellType
  
  -- Update special cells cache if needed
  if oldType ~= cellType then
    self:buildSpecialCellsCache()
  end
  
  return true
end

function DungeonMap:isValidPosition(x, y)
  -- Check if position is within map bounds
  return x >= 1 and x <= self.width and y >= 1 and y <= self.height
end

function DungeonMap:isWalkable(x, y)
  -- Check if player can walk on this cell
  local cellType = self:getCell(x, y)
  
  if cellType == nil then
    return false -- Out of bounds
  end
  
  -- Walkable cell types
  local walkable = {
    [self.CELL_TYPES.FLOOR] = true,
    [self.CELL_TYPES.DOOR] = true,
    [self.CELL_TYPES.TERMINAL] = true,
    [self.CELL_TYPES.STAIRS_DOWN] = true,
    [self.CELL_TYPES.STAIRS_UP] = true,
    [self.CELL_TYPES.HAZARD] = true -- Walkable but causes damage
  }
  
  return walkable[cellType] == true
end

function DungeonMap:isBlocking(x, y)
  -- Check if cell blocks line of sight / movement
  return not self:isWalkable(x, y)
end

function DungeonMap:getSpecialCells(cellTypeName)
  -- Get all cells of a specific type
  -- cellTypeName: string key from CELL_TYPES (e.g., "DOOR_LOCKED")
  return self.specialCells[cellTypeName] or {}
end

function DungeonMap:getWidth()
  return self.width
end

function DungeonMap:getHeight()
  return self.height
end

function DungeonMap:getMetadata()
  return self.metadata
end

function DungeonMap:isLoaded()
  return self.loaded
end

function DungeonMap:toArray()
  -- Export grid as 2D array for RaycasterSystem compatibility
  -- Returns a copy to prevent external modifications
  local copy = {}
  for y = 1, self.height do
    copy[y] = {}
    for x = 1, self.width do
      copy[y][x] = self.grid[y][x]
    end
  end
  return copy
end

function DungeonMap:getCellName(cellType)
  -- Get human-readable name for cell type
  return self.CELL_NAMES[cellType] or "UNKNOWN"
end

function DungeonMap:getCellTypeByName(name)
  -- Get cell type code by name
  return self.CELL_TYPES[name]
end

function DungeonMap:openDoor(x, y)
  -- Convert locked/closed door to open door
  local cellType = self:getCell(x, y)
  
  if cellType == self.CELL_TYPES.DOOR_LOCKED or cellType == self.CELL_TYPES.DOOR then
    self:setCell(x, y, self.CELL_TYPES.FLOOR)
    print(string.format("[DungeonMap] Door opened at (%d, %d)", x, y))
    return true
  end
  
  return false
end

function DungeonMap:isHazard(x, y)
  -- Check if cell is a hazard (deals damage)
  return self:getCell(x, y) == self.CELL_TYPES.HAZARD
end

function DungeonMap:isInteractable(x, y)
  -- Check if cell can be interacted with (Space key)
  local cellType = self:getCell(x, y)
  
  local interactable = {
    [self.CELL_TYPES.DOOR] = true,
    [self.CELL_TYPES.DOOR_LOCKED] = true,
    [self.CELL_TYPES.TERMINAL] = true,
    [self.CELL_TYPES.STAIRS_DOWN] = true,
    [self.CELL_TYPES.STAIRS_UP] = true
  }
  
  return interactable[cellType] == true
end

function DungeonMap:getInteractionType(x, y)
  -- Return interaction type for interactable cells
  local cellType = self:getCell(x, y)
  
  if cellType == self.CELL_TYPES.DOOR or cellType == self.CELL_TYPES.DOOR_LOCKED then
    return "door"
  elseif cellType == self.CELL_TYPES.TERMINAL then
    return "terminal"
  elseif cellType == self.CELL_TYPES.STAIRS_DOWN then
    return "stairs_down"
  elseif cellType == self.CELL_TYPES.STAIRS_UP then
    return "stairs_up"
  end
  
  return nil
end

function DungeonMap:revealSecretWall(x, y)
  -- Convert secret wall to floor (when discovered)
  if self:getCell(x, y) == self.CELL_TYPES.SECRET_WALL then
    self:setCell(x, y, self.CELL_TYPES.FLOOR)
    print(string.format("[DungeonMap] Secret wall revealed at (%d, %d)", x, y))
    return true
  end
  return false
end

function DungeonMap:clear()
  -- Clear current level data
  self.grid = {}
  self.width = 0
  self.height = 0
  self.metadata = {}
  self.specialCells = {}
  self.loaded = false
  print("[DungeonMap] Level cleared")
end

return DungeonMap
