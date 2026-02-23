-- src/systems/RaycasterSystem.lua
-- Column-based raycaster for first-person dungeon rendering (Wolfenstein-3D style)

local MathUtils = require("src.utils.MathUtils")

local RaycasterSystem = {}
RaycasterSystem.__index = RaycasterSystem

-- ─── Constants ───────────────────────────────────────────────────────────────

local VIEWPORT_WIDTH = 768
local VIEWPORT_HEIGHT = 576
local TEXTURE_WIDTH = 64
local TEXTURE_HEIGHT = 64

local FLOOR_COLOR = {0.078, 0.090, 0.102, 1}   -- #141720
local CEILING_COLOR = {0.039, 0.055, 0.078, 1} -- #0a0e14

-- ─── Factory ─────────────────────────────────────────────────────────────────

function RaycasterSystem:new()
  local instance = setmetatable({}, RaycasterSystem)
  
  -- Canvas for rendering the viewport
  instance.canvas = love.graphics.newCanvas(VIEWPORT_WIDTH, VIEWPORT_HEIGHT)
  
  -- Player state
  instance.playerX = 4.5
  instance.playerY = 4.5
  instance.playerDir = math.pi * 1.5 -- Facing North (up)
  instance.fov = math.pi / 3 -- 60 degrees field of view
  
  -- Map data
  instance.map = nil
  instance.mapWidth = 0
  instance.mapHeight = 0
  
  -- Wall textures (procedurally generated)
  instance.textures = instance:createPlaceholderTextures()
  
  -- Z-buffer for sprite rendering (not implemented yet)
  instance.zBuffer = {}
  for i = 1, VIEWPORT_WIDTH do
    instance.zBuffer[i] = 0
  end
  
  -- Performance tracking
  instance.renderTime = 0
  
  return instance
end

-- ─── Texture Generation ──────────────────────────────────────────────────────

function RaycasterSystem:createPlaceholderTextures()
  local textures = {}
  
  -- Metal standard wall (riveted steel)
  textures.metal_standard = self:generateMetalTexture(
    {0.23, 0.27, 0.31}, -- Base color
    {0.18, 0.21, 0.25}  -- Darker rivets
  )
  
  -- Damaged metal wall
  textures.metal_damaged = self:generateDamagedTexture(
    {0.20, 0.23, 0.27}, -- Base color
    {0.10, 0.12, 0.14}  -- Damage marks
  )
  
  -- Door texture
  textures.door = self:generateDoorTexture(
    {0.15, 0.35, 0.45}, -- Door color (cyan tint)
    {0.00, 0.75, 1.00}  -- Panel lines (bright cyan)
  )
  
  return textures
end

function RaycasterSystem:generateMetalTexture(baseColor, detailColor)
  local imageData = love.image.newImageData(TEXTURE_WIDTH, TEXTURE_HEIGHT)
  
  for x = 0, TEXTURE_WIDTH - 1 do
    for y = 0, TEXTURE_HEIGHT - 1 do
      -- Default to base color
      local r, g, b = baseColor[1], baseColor[2], baseColor[3]
      
      -- Add vertical panel lines every 16 pixels
      if x % 16 == 0 or x % 16 == 1 then
        r, g, b = r * 0.7, g * 0.7, b * 0.7
      end
      
      -- Add horizontal seams every 16 pixels
      if y % 16 == 0 then
        r, g, b = r * 0.8, g * 0.8, b * 0.8
      end
      
      -- Add rivets at panel intersections
      if (x % 16 == 8) and (y % 16 == 8) then
        r, g, b = detailColor[1], detailColor[2], detailColor[3]
      end
      
      -- Add slight noise
      local noise = (love.math.random() - 0.5) * 0.05
      r = math.max(0, math.min(1, r + noise))
      g = math.max(0, math.min(1, g + noise))
      b = math.max(0, math.min(1, b + noise))
      
      imageData:setPixel(x, y, r, g, b, 1)
    end
  end
  
  return love.graphics.newImage(imageData)
end

function RaycasterSystem:generateDamagedTexture(baseColor, damageColor)
  local imageData = love.image.newImageData(TEXTURE_WIDTH, TEXTURE_HEIGHT)
  
  for x = 0, TEXTURE_WIDTH - 1 do
    for y = 0, TEXTURE_HEIGHT - 1 do
      local r, g, b = baseColor[1], baseColor[2], baseColor[3]
      
      -- Add panel lines
      if x % 16 == 0 then
        r, g, b = r * 0.7, g * 0.7, b * 0.7
      end
      
      -- Add damage marks (random dark spots)
      if love.math.random() < 0.02 then
        r, g, b = damageColor[1], damageColor[2], damageColor[3]
      end
      
      -- Add burn marks (darker regions)
      if (x > 20 and x < 35) and (y > 10 and y < 30) then
        r, g, b = r * 0.5, g * 0.5, b * 0.5
      end
      
      imageData:setPixel(x, y, r, g, b, 1)
    end
  end
  
  return love.graphics.newImage(imageData)
end

function RaycasterSystem:generateDoorTexture(baseColor, lineColor)
  local imageData = love.image.newImageData(TEXTURE_WIDTH, TEXTURE_HEIGHT)
  
  for x = 0, TEXTURE_WIDTH - 1 do
    for y = 0, TEXTURE_HEIGHT - 1 do
      local r, g, b = baseColor[1], baseColor[2], baseColor[3]
      
      -- Vertical center line
      if x == TEXTURE_WIDTH / 2 or x == TEXTURE_WIDTH / 2 - 1 then
        r, g, b = lineColor[1], lineColor[2], lineColor[3]
      end
      
      -- Horizontal panel lines
      if y % 24 == 0 or y % 24 == 1 then
        r, g, b = lineColor[1] * 0.6, lineColor[2] * 0.6, lineColor[3] * 0.6
      end
      
      -- Border glow
      if x < 2 or x >= TEXTURE_WIDTH - 2 then
        r = r + lineColor[1] * 0.3
        g = g + lineColor[2] * 0.3
        b = b + lineColor[3] * 0.3
      end
      
      imageData:setPixel(x, y, r, g, b, 1)
    end
  end
  
  return love.graphics.newImage(imageData)
end

-- ─── Map Management ──────────────────────────────────────────────────────────

function RaycasterSystem:setMap(mapData)
  self.map = mapData
  self.mapHeight = #mapData
  self.mapWidth = #mapData[1]
end

function RaycasterSystem:getCell(x, y)
  if not self.map then return 0 end
  if x < 1 or x > self.mapWidth or y < 1 or y > self.mapHeight then
    return 1 -- Out of bounds = wall
  end
  return self.map[y][x] or 0
end

-- ─── Player State ────────────────────────────────────────────────────────────

function RaycasterSystem:setPlayerPos(x, y, dir)
  self.playerX = x
  self.playerY = y
  if dir then
    self.playerDir = dir
  end
end

function RaycasterSystem:getPlayerPos()
  return self.playerX, self.playerY, self.playerDir
end

-- ─── Core Raycasting ─────────────────────────────────────────────────────────

function RaycasterSystem:render()
  local startTime = love.timer.getTime()
  
  -- Set canvas for rendering
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
  
  -- Draw floor and ceiling first
  self:drawFloorCeiling()
  
  -- Cast rays for each screen column
  for x = 0, VIEWPORT_WIDTH - 1 do
    self:castRay(x)
  end
  
  -- Reset canvas
  love.graphics.setCanvas()
  
  -- Track render time
  self.renderTime = (love.timer.getTime() - startTime) * 1000
end

function RaycasterSystem:drawFloorCeiling()
  -- Draw ceiling (top half)
  love.graphics.setColor(CEILING_COLOR)
  love.graphics.rectangle("fill", 0, 0, VIEWPORT_WIDTH, VIEWPORT_HEIGHT / 2)
  
  -- Draw floor (bottom half)
  love.graphics.setColor(FLOOR_COLOR)
  love.graphics.rectangle("fill", 0, VIEWPORT_HEIGHT / 2, VIEWPORT_WIDTH, VIEWPORT_HEIGHT / 2)
  
  love.graphics.setColor(1, 1, 1, 1)
end

function RaycasterSystem:castRay(screenX)
  -- Calculate ray position and direction
  local cameraX = 2 * screenX / VIEWPORT_WIDTH - 1 -- x-coordinate in camera space (-1 to 1)
  
  local rayDirX = math.cos(self.playerDir) + math.sin(self.playerDir) * cameraX * math.tan(self.fov / 2)
  local rayDirY = math.sin(self.playerDir) - math.cos(self.playerDir) * cameraX * math.tan(self.fov / 2)
  
  -- Map position
  local mapX = math.floor(self.playerX)
  local mapY = math.floor(self.playerY)
  
  -- Length of ray from one x or y-side to next x or y-side
  local deltaDistX = math.abs(1 / rayDirX)
  local deltaDistY = math.abs(1 / rayDirY)
  
  local stepX, stepY
  local sideDistX, sideDistY
  
  -- Calculate step and initial sideDist
  if rayDirX < 0 then
    stepX = -1
    sideDistX = (self.playerX - mapX) * deltaDistX
  else
    stepX = 1
    sideDistX = (mapX + 1.0 - self.playerX) * deltaDistX
  end
  
  if rayDirY < 0 then
    stepY = -1
    sideDistY = (self.playerY - mapY) * deltaDistY
  else
    stepY = 1
    sideDistY = (mapY + 1.0 - self.playerY) * deltaDistY
  end
  
  -- Perform DDA
  local hit = false
  local side = 0
  local maxDepth = 20
  local depth = 0
  
  while not hit and depth < maxDepth do
    -- Jump to next map square
    if sideDistX < sideDistY then
      sideDistX = sideDistX + deltaDistX
      mapX = mapX + stepX
      side = 0
    else
      sideDistY = sideDistY + deltaDistY
      mapY = mapY + stepY
      side = 1
    end
    
    -- Check if ray has hit a wall
    if self:getCell(mapX, mapY) > 0 then
      hit = true
    end
    
    depth = depth + 1
  end
  
  if not hit then return end
  
  -- Calculate distance to wall (perpendicular distance to avoid fish-eye)
  local perpWallDist
  if side == 0 then
    perpWallDist = (mapX - self.playerX + (1 - stepX) / 2) / rayDirX
  else
    perpWallDist = (mapY - self.playerY + (1 - stepY) / 2) / rayDirY
  end
  
  -- Store distance in z-buffer for sprite rendering
  self.zBuffer[screenX + 1] = perpWallDist
  
  -- Calculate height of wall to draw on screen
  local lineHeight = math.floor(VIEWPORT_HEIGHT / perpWallDist)
  
  -- Calculate lowest and highest pixel to fill in current stripe
  local drawStart = math.max(0, -lineHeight / 2 + VIEWPORT_HEIGHT / 2)
  local drawEnd = math.min(VIEWPORT_HEIGHT, lineHeight / 2 + VIEWPORT_HEIGHT / 2)
  
  -- Calculate texture coordinate
  local wallX
  if side == 0 then
    wallX = self.playerY + perpWallDist * rayDirY
  else
    wallX = self.playerX + perpWallDist * rayDirX
  end
  wallX = wallX - math.floor(wallX)
  
  -- Select texture based on wall type
  local cellValue = self:getCell(mapX, mapY)
  local texture = self.textures.metal_standard
  
  if cellValue == 2 then
    texture = self.textures.metal_damaged
  elseif cellValue == 3 then
    texture = self.textures.door
  end
  
  -- Calculate texture x coordinate
  local texX = math.floor(wallX * TEXTURE_WIDTH)
  if (side == 0 and rayDirX > 0) or (side == 1 and rayDirY < 0) then
    texX = TEXTURE_WIDTH - texX - 1
  end
  
  -- Draw the vertical stripe
  local quad = love.graphics.newQuad(
    texX, 0,
    1, TEXTURE_HEIGHT,
    TEXTURE_WIDTH, TEXTURE_HEIGHT
  )
  
  -- Apply shading based on side and distance
  local shade = 1.0
  if side == 1 then
    shade = 0.7 -- Horizontal walls are darker
  end
  
  -- Distance-based fog
  shade = shade * math.max(0.2, 1.0 - perpWallDist / maxDepth)
  
  love.graphics.setColor(shade, shade, shade, 1)
  love.graphics.draw(
    texture, quad,
    screenX, drawStart,
    0,
    1, (drawEnd - drawStart) / TEXTURE_HEIGHT
  )
  
  love.graphics.setColor(1, 1, 1, 1)
end

-- ─── Drawing ─────────────────────────────────────────────────────────────────

function RaycasterSystem:draw(x, y)
  x = x or 0
  y = y or 0
  love.graphics.draw(self.canvas, x, y)
end

function RaycasterSystem:drawDebugInfo(x, y)
  x = x or 10
  y = y or 10
  
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.print(string.format("Player: (%.1f, %.1f)", self.playerX, self.playerY), x, y)
  love.graphics.print(string.format("Direction: %.1f°", math.deg(self.playerDir)), x, y + 20)
  love.graphics.print(string.format("Render time: %.2fms", self.renderTime), x, y + 40)
  love.graphics.setColor(1, 1, 1, 1)
end

return RaycasterSystem
