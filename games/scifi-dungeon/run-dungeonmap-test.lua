-- run-dungeonmap-test.lua
-- Standalone test runner for DungeonMap system
-- Run: cd scifi-dungeon && love . --test

-- Check if running in test mode
local args = {...}
local testMode = false
for _, arg in ipairs(args) do
  if arg == "--test" then
    testMode = true
    break
  end
end

if testMode then
  -- Run DungeonMap tests
  local TestDungeonMap = require("test-dungeonmap-love")
  
  function love.load()
    print("\n" .. string.rep("=", 60))
    print("  DUNGEONMAP SYSTEM TEST")
    print(string.rep("=", 60) .. "\n")
    
    local success = TestDungeonMap.run()
    
    print("\n" .. string.rep("=", 60))
    if success then
      print("  ✓ ALL TESTS PASSED")
    else
      print("  ✗ TESTS FAILED")
    end
    print(string.rep("=", 60) .. "\n")
    
    -- Auto-exit after 3 seconds
    local exitTimer = 3
    function love.update(dt)
      exitTimer = exitTimer - dt
      if exitTimer <= 0 then
        love.event.quit()
      end
    end
    
    function love.draw()
      love.graphics.setColor(1, 1, 1)
      love.graphics.print("Test completed. Window will close automatically.", 10, 10)
      love.graphics.print("Check console for results.", 10, 30)
    end
  end
else
  -- Load normal game
  require("main")
end
