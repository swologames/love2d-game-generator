-- src/systems/MinimapSystem.lua
-- Minimap rendering system for top-down dungeon overview

local MinimapSystem = {}
MinimapSystem.__index = MinimapSystem

-- ─── Constants ───────────────────────────────────────────────────────────────

-- Color scheme (cyberpunk sci-fi theme)
local COLORS = {
  wall = {0.227, 0.290, 0.353, 1},      -- #3a4a5a (lighter blue-grey)
  empty = {0.039, 0.055, 0.078, 1},     -- #0a0e14 (dark blue)
  player = {0, 0.749, 1, 1},            -- #00bfff (bright cyan)
  border = {0.156, 0.196, 0.235, 1},    -- #28323c (border/outline)
  fog = {0.02, 0.03, 0.05, 0.7}         -- Dark overlay for unexplored
}

-- ─── Factory ─────────────────────────────────────────────────────────────────

function MinimapSystem:new(size)
  local instance = setmetatable({}, MinimapSystem)
  
  -- Render size (e.g., 64x64 pixels)
  instance.size = size or 64
  
  -- Canvas for minimap rendering
  instance.canvas = love.graphics.newCanvas(instance.size, instance.size)
  
  -- Map data
  instance.map = nil
  instance.mapWidth = 0
  instance.mapHeight = 0
  
  -- Player state
  instance.playerX = 0
  instance.playerY = 0
  instance.playerDir = 0
  
  -- Rendering state
  instance.mapDirty = false   -- True when map needs redraw
  instance.cellSize = 4       -- Pixels per map cell
  instance.viewRadius = 0     -- 0 = show full map, >0 = show radius around player
  
  -- Fog of war (optional - tracks visited cells)
  instance.explored = {}
  instance.useFogOfWar = false
  
  return instance
end

-- ─── Map Management ──────────────────────────────────────────────────────────

function MinimapSystem:setMap(mapData)
  if not mapData or #mapData == 0 then
    print("[MinimapSystem] Warning: Empty map data")
    return
  end
  
  self.map = mapData
  self.mapHeight = #mapData
  self.mapWidth = #mapData[1]
  
  -- Calculate optimal cell size to fit map in display area
  local maxDim = math.max(self.mapWidth, self.mapHeight)
  self.cellSize = math.floor(self.size / maxDim)
  self.cellSize = math.max(1, self.cellSize) -- Minimum 1 pixel per cell
  
  -- Clear fog of war
  self.explored = {}
  
  -- Mark for redraw
  self.mapDirty = true
  
  print(string.format("[MinimapSystem] Loaded %dx%d map, cell size: %dpx", 
    self.mapWidth, self.mapHeight, self.cellSize))
end

function MinimapSystem:getCell(x, y)
  if not self.map then return 0 end
  if x < 1 or x > self.mapWidth or y < 1 or y > self.mapHeight then
    return 1 -- Out of bounds = wall
  end
  return self.map[y][x] or 0
end

-- ─── Player State ────────────────────────────────────────────────────────────

function MinimapSystem:updatePlayer(x, y, direction)
  self.playerX = x
  self.playerY = y
  self.playerDir = direction or 0
  
  -- Mark current cell as explored (for fog of war)
  if self.useFogOfWar then
    local cellX = math.floor(x)
    local cellY = math.floor(y)
    local key = cellX .. "," .. cellY
    self.explored[key] = true
  end
end

-- ─── Rendering ───────────────────────────────────────────────────────────────

function MinimapSystem:renderMapToCanvas()
  if not self.map or not self.mapDirty then
    return -- No map or already rendered
  end
  
  -- Render to canvas
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  
  -- Calculate map offset to center it in canvas
  local mapPixelWidth = self.mapWidth * self.cellSize
  local mapPixelHeight = self.mapHeight * self.cellSize
  local offsetX = math.floor((self.size - mapPixelWidth) / 2)
  local offsetY = math.floor((self.size - mapPixelHeight) / 2)
  
  -- Draw border
  love.graphics.setColor(COLORS.border)
  love.graphics.rectangle("line", 0, 0, self.size, self.size)
  
  -- Draw map cells
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      local cellValue = self:getCell(x, y)
      local px = offsetX + (x - 1) * self.cellSize
      local py = offsetY + (y - 1) * self.cellSize
      
      -- Check if explored (fog of war)
      local key = x .. "," .. y
      local isExplored = not self.useFogOfWar or self.explored[key]
      
      if isExplored then
        -- Draw cell based on type
        if cellValue == 0 then
          love.graphics.setColor(COLORS.empty)
        else
          love.graphics.setColor(COLORS.wall)
        end
        love.graphics.rectangle("fill", px, py, self.cellSize, self.cellSize)
      else
        -- Unexplored - show dark fog
        love.graphics.setColor(COLORS.fog)
        love.graphics.rectangle("fill", px, py, self.cellSize, self.cellSize)
      end
    end
  end
  
  love.graphics.setCanvas()
  love.graphics.setColor(1, 1, 1, 1) -- Reset color
  
  self.mapDirty = false
end

function MinimapSystem:drawPlayerMarker()
  -- Calculate player screen position
  local mapPixelWidth = self.mapWidth * self.cellSize
  local mapPixelHeight = self.mapHeight * self.cellSize
  local offsetX = math.floor((self.size - mapPixelWidth) / 2)
  local offsetY = math.floor((self.size - mapPixelHeight) / 2)
  
  -- Convert world coords to minimap coords
  local px = offsetX + (self.playerX - 0.5) * self.cellSize
  local py = offsetY + (self.playerY - 0.5) * self.cellSize
  
  -- Draw player as triangle pointing in direction
  love.graphics.setColor(COLORS.player)
  
  local size = math.max(3, self.cellSize * 0.8)
  
  -- Calculate triangle vertices based on direction
  local x1 = px + math.cos(self.playerDir) * size
  local y1 = py + math.sin(self.playerDir) * size
  
  local x2 = px + math.cos(self.playerDir + 2.6) * size * 0.6
  local y2 = py + math.sin(self.playerDir + 2.6) * size * 0.6
  
  local x3 = px + math.cos(self.playerDir - 2.6) * size * 0.6
  local y3 = py + math.sin(self.playerDir - 2.6) * size * 0.6
  
  love.graphics.polygon("fill", x1, y1, x2, y2, x3, y3)
  
  -- Optional: Add outline for better visibility
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.setLineWidth(1)
  love.graphics.polygon("line", x1, y1, x2, y2, x3, y3)
  
  love.graphics.setColor(1, 1, 1, 1) -- Reset color
end

function MinimapSystem:draw(x, y, drawPlayer)
  if not self.map then
    return -- No map loaded
  end
  
  -- Render map to canvas if dirty
  self:renderMapToCanvas()
  
  -- Draw canvas at specified position
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, x, y)
  
  -- Draw player marker on top if requested (default true)
  if drawPlayer == nil or drawPlayer == true then
    love.graphics.push()
    love.graphics.translate(x, y)
    self:drawPlayerMarker()
    love.graphics.pop()
  end
end

-- ─── Canvas Access ───────────────────────────────────────────────────────────

function MinimapSystem:getCanvas()
  return self.canvas
end

function MinimapSystem:getSize()
  return self.size
end

-- ─── Configuration ───────────────────────────────────────────────────────────

function MinimapSystem:setViewRadius(radius)
  -- Set to 0 to show full map, or >0 to show limited area around player
  self.viewRadius = radius
  self.mapDirty = true
end

function MinimapSystem:setFogOfWar(enabled)
  self.useFogOfWar = enabled
  if enabled then
    -- Mark starting position as explored
    local cellX = math.floor(self.playerX)
    local cellY = math.floor(self.playerY)
    local key = cellX .. "," .. cellY
    self.explored[key] = true
  end
  self.mapDirty = true
end

function MinimapSystem:revealAll()
  -- Reveal entire map (for debugging or gameplay events)
  if not self.map then return end
  
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      local key = x .. "," .. y
      self.explored[key] = true
    end
  end
  self.mapDirty = true
end

-- ─── Utility ─────────────────────────────────────────────────────────────────

function MinimapSystem:markDirty()
  -- Force redraw (useful when map changes dynamically)
  self.mapDirty = true
end

return MinimapSystem
