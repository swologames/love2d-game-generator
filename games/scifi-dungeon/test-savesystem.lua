#!/usr/bin/env lua
-- test-savesystem.lua
-- Unit test for SaveSystem (runs without Love2D)

-- Mock love.filesystem for testing
love = {
  filesystem = {
    saves = {},
    directories = {},
    
    getSaveDirectory = function()
      return "/tmp/scifi-dungeon-test"
    end,
    
    getInfo = function(path)
      if love.filesystem.directories[path] then
        return {type = "directory"}
      elseif love.filesystem.saves[path] then
        return {type = "file"}
      end
      return nil
    end,
    
    createDirectory = function(path)
      love.filesystem.directories[path] = true
      return true
    end,
    
    write = function(path, data)
      love.filesystem.saves[path] = data
      return true
    end,
    
    read = function(path)
      local data = love.filesystem.saves[path]
      if data then
        return data
      end
      return nil, "File not found"
    end,
    
    remove = function(path)
      if love.filesystem.saves[path] then
        love.filesystem.saves[path] = nil
        return true
      end
      return false
    end
  }
}

-- Load SaveSystem
local SaveSystem = require("src.systems.SaveSystem")

-- Test helpers
local function assert_equal(actual, expected, message)
  if actual ~= expected then
    error(string.format("FAILED: %s\nExpected: %s\nActual: %s", 
      message, tostring(expected), tostring(actual)))
  end
  print("✓ " .. message)
end

local function assert_true(condition, message)
  if not condition then
    error("FAILED: " .. message)
  end
  print("✓ " .. message)
end

local function assert_not_nil(value, message)
  if value == nil then
    error("FAILED: " .. message .. " (got nil)")
  end
  print("✓ " .. message)
end

print("\n=== SaveSystem Unit Tests ===\n")

-- Test 1: Initialization
print("Test 1: Initialization")
SaveSystem:init()
assert_true(SaveSystem.initialized, "SaveSystem should be initialized")

-- Test 2: Serialization
print("\nTest 2: Serialization")
local testData = {
  version = "0.2.0",
  timestamp = 1234567890,
  playTime = 3600,
  party = {
    {name = "Alice", class = "Gunner", hp = 100, maxHP = 150},
    {name = "Bob", class = "Medic", hp = 80, maxHP = 100}
  },
  flags = {
    tutorial_completed = true,
    first_combat = false
  },
  position = {x = 8.5, y = 10.2}
}

local serialized = SaveSystem:serialize(testData)
assert_not_nil(serialized, "Serialization should produce output")
assert_true(serialized:find("Alice") ~= nil, "Serialized data should contain 'Alice'")
assert_true(serialized:find("tutorial_completed") ~= nil, "Serialized data should contain flags")

-- Test 3: Deserialization
print("\nTest 3: Deserialization")
local deserialized = SaveSystem:deserialize(serialized)
assert_not_nil(deserialized, "Deserialization should work")
assert_equal(deserialized.version, "0.2.0", "Version should match")
assert_equal(deserialized.playTime, 3600, "Play time should match")
assert_equal(deserialized.party[1].name, "Alice", "Party member name should match")
assert_equal(deserialized.flags.tutorial_completed, true, "Flags should match")

-- Test 4: Save and Load
print("\nTest 4: Save and Load")
local gameState = SaveSystem:exportGameState(
  testData.party,
  {},
  nil,
  {x = 8.5, y = 8.5},
  0,
  {tutorial_completed = true},
  3600
)

local saveSuccess, saveErr = SaveSystem:save(gameState, 1)
assert_true(saveSuccess, "Save should succeed: " .. (saveErr or ""))

local loaded = SaveSystem:load(1)
assert_not_nil(loaded, "Load should return data")
assert_equal(loaded.version, "0.2.0", "Loaded version should match")
assert_equal(loaded.playTime, 3600, "Loaded play time should match")
assert_equal(loaded.party[1].name, "Alice", "Loaded party data should match")

-- Test 5: Save exists check
print("\nTest 5: Save exists check")
assert_true(SaveSystem:exists(1), "Slot 1 should exist")
assert_true(not SaveSystem:exists(2), "Slot 2 should not exist")

-- Test 6: Get save info
print("\nTest 6: Get save info")
local info = SaveSystem:getSaveInfo(1)
assert_not_nil(info, "Save info should be returned")
assert_equal(info.slot, 1, "Save info slot should be 1")
assert_equal(info.partySize, 2, "Party size should be 2")
assert_equal(info.version, "0.2.0", "Save info version should match")

-- Test 7: Delete save
print("\nTest 7: Delete save")
local deleteSuccess = SaveSystem:delete(1)
assert_true(deleteSuccess, "Delete should succeed")
assert_true(not SaveSystem:exists(1), "Slot 1 should not exist after delete")

-- Test 8: Quick save/load
print("\nTest 8: Quick save/load")
local quickSaveSuccess = SaveSystem:quickSave(gameState)
assert_true(quickSaveSuccess, "Quick save should succeed")

local quickLoaded = SaveSystem:quickLoad()
assert_not_nil(quickLoaded, "Quick load should return data")
assert_equal(quickLoaded.party[1].name, "Alice", "Quick loaded data should match")

-- Test 9: Invalid slot numbers
print("\nTest 9: Invalid slot numbers")
local invalidSave, err = SaveSystem:save(gameState, 99)
assert_true(not invalidSave, "Save to invalid slot should fail")
assert_not_nil(err, "Error message should be returned")

-- Test 10: Corrupted save handling
print("\nTest 10: Corrupted save handling")
love.filesystem.saves["saves/save_slot_2.lua"] = "invalid lua code {{{"
local corrupted = SaveSystem:load(2)
assert_true(corrupted == nil, "Loading corrupted save should return nil")

print("\n=== All Tests Passed! ===\n")

-- Show file size stats
print("SaveSystem.lua file size check:")
local file = io.open("src/systems/SaveSystem.lua", "r")
if file then
  local lineCount = 0
  for _ in file:lines() do
    lineCount = lineCount + 1
  end
  file:close()
  print(string.format("  Lines: %d / 300 (%.1f%%)", lineCount, (lineCount / 300) * 100))
  
  if lineCount > 300 then
    print("  ⚠️  WARNING: File exceeds 300 line limit!")
  else
    print("  ✓ Within line limit")
  end
end
