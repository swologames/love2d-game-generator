-- Test MinimapSystem integration
-- Run this from main.lua or a test scene

local MinimapSystem = require("src.systems.MinimapSystem")

-- Create minimap
local minimap = MinimapSystem:new(64)

-- Example 16x16 test map (0=empty, 1=wall)
local testMap = {
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,1,1,0,1,1,1,0,0,1,1,1,0,0,1},
  {1,0,1,0,0,0,0,1,0,0,1,0,0,0,0,1},
  {1,0,1,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,1,1,1,1,1,1,0,0,1,1,1,1,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,1,1,1,0,0,1,1,1,1,0,0,1,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1},
  {1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
  {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
}

-- Load map
minimap:setMap(testMap)

-- Update player position (example: center of map, facing north)
minimap:updatePlayer(8.5, 8.5, math.pi * 1.5)

-- In your draw function:
function love.draw()
  -- Draw minimap at top-right corner
  local x = love.graphics.getWidth() - 64 - 10
  local y = 10
  minimap:draw(x, y)
end

-- In your update function:
function love.update(dt)
  -- Update player position from raycaster or player system
  -- minimap:updatePlayer(playerX, playerY, playerDirection)
end
