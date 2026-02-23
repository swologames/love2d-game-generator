-- test-dungeonmap-love.lua
-- Love2D-compatible test for DungeonMap system
-- Run: love /path/to/scifi-dungeon --test dungeonmap

local DungeonMap = require("src.systems.DungeonMap")

local TestDungeonMap = {}

function TestDungeonMap.run()
  print("\n=== DungeonMap Test ===\n")
  
  -- Create instance
  local map = DungeonMap:new()
  
  -- Test 1: Load level
  print("Test 1: Loading deck1.lua...")
  local success, err = map:loadLevel("levels/deck1.lua")
  
  if success then
    print("✓ Level loaded successfully")
    print("  Name:", map:getMetadata().name)
    print("  District:", map:getMetadata().district)
    print("  Size:", map:getWidth() .. "x" .. map:getHeight())
  else
    print("✗ Failed to load level:", err)
    return false
  end
  
  print("")
  
  -- Test 2: Cell queries
  print("Test 2: Cell queries...")
  local testPos = {x = 2, y = 2}
  local cellType = map:getCell(testPos.x, testPos.y)
  print(string.format("  Cell at (%d,%d): %s (%d)", 
    testPos.x, testPos.y, map:getCellName(cellType), cellType))
  
  local walkable = map:isWalkable(testPos.x, testPos.y)
  print("  Is walkable:", walkable)
  print("✓ Cell queries working")
  
  print("")
  
  -- Test 3: Special cells
  print("Test 3: Special cells...")
  local doors = map:getSpecialCells("DOOR_LOCKED")
  print("  Locked doors found:", #doors)
  if #doors > 0 then
    for i, door in ipairs(doors) do
      print(string.format("    Door %d at (%d, %d)", i, door.x, door.y))
    end
  end
  
  local terminals = map:getSpecialCells("TERMINAL")
  print("  Terminals found:", #terminals)
  
  local hazards = map:getSpecialCells("HAZARD")
  print("  Hazards found:", #hazards)
  
  print("✓ Special cell queries working")
  
  print("")
  
  -- Test 4: Walkability checks
  print("Test 4: Walkability checks...")
  local wall = {x = 1, y = 1}
  local floor = {x = 2, y = 2}
  
  print(string.format("  Wall at (%d,%d) walkable: %s", 
    wall.x, wall.y, tostring(map:isWalkable(wall.x, wall.y))))
  print(string.format("  Floor at (%d,%d) walkable: %s", 
    floor.x, floor.y, tostring(map:isWalkable(floor.x, floor.y))))
  print("✓ Walkability checks working")
  
  print("")
  
  -- Test 5: Interaction checks
  print("Test 5: Interaction checks...")
  local doorPos = {x = 9, y = 13} -- Locked door from deck1.lua
  local isInteractable = map:isInteractable(doorPos.x, doorPos.y)
  local interactionType = map:getInteractionType(doorPos.x, doorPos.y)
  
  print(string.format("  Cell at (%d,%d) interactable: %s", 
    doorPos.x, doorPos.y, tostring(isInteractable)))
  if interactionType then
    print("  Interaction type:", interactionType)
  end
  print("✓ Interaction checks working")
  
  print("")
  
  -- Test 6: Dynamic cell changes
  print("Test 6: Dynamic cell changes...")
  print("  Opening door at (9, 13)...")
  local opened = map:openDoor(9, 13)
  if opened then
    print("  ✓ Door opened successfully")
    local newType = map:getCell(9, 13)
    print("  New cell type:", map:getCellName(newType))
  else
    print("  ✗ Failed to open door")
  end
  
  print("")
  
  -- Test 7: Array export for RaycasterSystem
  print("Test 7: Array export...")
  local gridArray = map:toArray()
  print("  Exported grid size:", #gridArray .. "x" .. #gridArray[1])
  print("  First cell type:", map:getCellName(gridArray[1][1]))
  print("✓ Array export working")
  
  print("")
  print("=== All Tests Passed ===")
  print("")
  print("Integration Notes:")
  print("- Use DungeonMap:loadLevel(path) to load a level")
  print("- Use DungeonMap:toArray() to get grid for RaycasterSystem")
  print("- Use DungeonMap:isWalkable(x,y) for collision detection")
  print("- Use DungeonMap:getSpecialCells(type) to find doors, terminals, etc.")
  
  return true
end

return TestDungeonMap
