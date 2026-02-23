-- test-map-simple.lua
-- Quick test of DungeonMap loading
-- Run: love /path/to/scifi-dungeon test-map-simple.lua

local DungeonMap = require("src.systems.DungeonMap")

function love.load()
  print("\n=== Quick DungeonMap Test ===\n")
  
  local map = DungeonMap:new()
  local success, err = map:loadLevel("levels/deck1.lua")
  
  if success then
    print("✓ Level loaded:", map:getMetadata().name)
    print("  Size:", map:getWidth() .. "x" .. map:getHeight())
    print("  Doors:", #map:getSpecialCells("DOOR_LOCKED"))
    print("  Terminals:", #map:getSpecialCells("TERMINAL"))
    print("\n✓ DungeonMap system working correctly!\n")
    
    -- Test walkability
    print("Walkability test:")
    print("  Floor (2,2):", map:isWalkable(2, 2))
    print("  Wall (1,1):", map:isWalkable(1, 1))
  else
    print("✗ Failed:", err)
  end
  
  -- Auto quit after showing results
  love.timer.sleep(0.1)
  love.event.quit()
end

function love.draw()
  -- Nothing to draw
end
