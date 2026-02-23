-- SaveSystem.lua
-- Save/Load game state management for scifi-dungeon Phase 2

local SaveSystem = {
  saveDirectory = "saves",
  maxSlots = 3,
  saveVersion = "0.2.0",
  initialized = false
}

function SaveSystem:init()
  if self.initialized then return end
  print("[SaveSystem] Initializing...")
  
  local dirInfo = love.filesystem.getInfo(self.saveDirectory)
  if not dirInfo then
    local success = love.filesystem.createDirectory(self.saveDirectory)
    if success then
      print("[SaveSystem] Created save directory:", self.saveDirectory)
    else
      print("[SaveSystem] ERROR: Could not create save directory")
    end
  end
  
  self.initialized = true
  print("[SaveSystem] Ready. Save location:", love.filesystem.getSaveDirectory())
end

function SaveSystem:getSlotFilename(slotNumber)
  return string.format("%s/save_slot_%d.lua", self.saveDirectory, slotNumber)
end

function SaveSystem:exists(slotNumber)
  return love.filesystem.getInfo(self:getSlotFilename(slotNumber)) ~= nil
end

function SaveSystem:getSaveInfo(slotNumber)
  if not self:exists(slotNumber) then return nil end
  
  local saveData = self:load(slotNumber)
  if not saveData then return nil end
  
  return {
    slot = slotNumber,
    timestamp = saveData.timestamp or 0,
    playTime = saveData.playTime or 0,
    district = saveData.currentDistrict or 1,
    level = saveData.currentLevel or "deck1",
    version = saveData.version or "unknown",
    partySize = saveData.party and #saveData.party or 0
  }
end

function SaveSystem:serialize(data, indent)
  indent = indent or 0
  local indentStr = string.rep("  ", indent)
  local nextIndent = string.rep("  ", indent + 1)
  local dataType = type(data)
  
  if dataType == "table" then
    local result = "{\n"
    for key, value in pairs(data) do
      result = result .. nextIndent
      if type(key) == "string" then
        if key:match("^[%a_][%w_]*$") then
          result = result .. key .. " = "
        else
          result = result .. '["' .. key .. '"] = '
        end
      else
        result = result .. "[" .. tostring(key) .. "] = "
      end
      result = result .. self:serialize(value, indent + 1) .. ",\n"
    end
    result = result .. indentStr .. "}"
    return result
  elseif dataType == "string" then
    return '"' .. data:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
  elseif dataType == "number" or dataType == "boolean" then
    return tostring(data)
  else
    return "nil"
  end
end

function SaveSystem:deserialize(str)
  if not str or str == "" then
    print("[SaveSystem] ERROR: Empty or nil string to deserialize")
    return nil
  end
  
  if not str:match("^%s*return%s+") then
    str = "return " .. str
  end
  
  local loadFunc = loadstring or load
  local chunk, loadError = loadFunc(str)
  if not chunk then
    print("[SaveSystem] ERROR: Failed to parse save data:", loadError)
    return nil
  end
  
  local success, result = pcall(chunk)
  if not success then
    print("[SaveSystem] ERROR: Failed to execute save data:", result)
    return nil
  end
  
  return result
end

function SaveSystem:validateSaveData(data)
  if type(data) ~= "table" then
    return false, "Save data is not a table"
  end
  if not data.version then
    return false, "Missing version field"
  end
  if not data.party then
    return false, "Missing party data"
  end
  if not data.currentDistrict or not data.currentLevel then
    return false, "Missing location data"
  end
  if not data.playerPosition then
    return false, "Missing player position"
  end
  return true
end

function SaveSystem:exportGameState(party, inventory, map, playerPos, playerDir, flags, playTime)
  local gameState = {
    version = self.saveVersion,
    timestamp = os.time(),
    playTime = playTime or 0,
    party = party or {},
    inventory = inventory or {},
    currentDistrict = 1,
    currentLevel = map and map.name or "deck1",
    playerPosition = playerPos or {x = 8.5, y = 8.5},
    playerDirection = playerDir or 0,
    exploredCells = {},
    doorStates = {},
    flags = flags or {}
  }
  
  if map then
    if map.explored then
      for key, value in pairs(map.explored) do
        gameState.exploredCells[key] = value
      end
    end
    if map.doorStates then
      for key, value in pairs(map.doorStates) do
        gameState.doorStates[key] = value
      end
    end
  end
  
  return gameState
end

function SaveSystem:save(gameState, slotNumber)
  slotNumber = slotNumber or 1
  
  if slotNumber < 1 or slotNumber > self.maxSlots then
    return false, string.format("Invalid slot number: %d (must be 1-%d)", slotNumber, self.maxSlots)
  end
  
  local valid, err = self:validateSaveData(gameState)
  if not valid then
    return false, "Invalid save data: " .. err
  end
  
  local serialized = self:serialize(gameState)
  local filename = self:getSlotFilename(slotNumber)
  local success, writeError = pcall(function()
    love.filesystem.write(filename, serialized)
  end)
  
  if not success then
    print("[SaveSystem] ERROR: Failed to write save file:", writeError)
    return false, "Failed to write save file: " .. tostring(writeError)
  end
  
  print(string.format("[SaveSystem] Game saved to slot %d: %s", slotNumber, filename))
  return true
end

function SaveSystem:load(slotNumber)
  slotNumber = slotNumber or 1
  
  if not self:exists(slotNumber) then
    print(string.format("[SaveSystem] No save found in slot %d", slotNumber))
    return nil
  end
  
  local filename = self:getSlotFilename(slotNumber)
  local contents, readError = love.filesystem.read(filename)
  
  if not contents then
    print("[SaveSystem] ERROR: Failed to read save file:", readError)
    return nil
  end
  
  local gameState = self:deserialize(contents)
  if not gameState then
    print("[SaveSystem] ERROR: Failed to deserialize save data")
    return nil
  end
  
  local valid, err = self:validateSaveData(gameState)
  if not valid then
    print("[SaveSystem] ERROR: Corrupted save data:", err)
    return nil
  end
  
  print(string.format("[SaveSystem] Game loaded from slot %d", slotNumber))
  return gameState
end

function SaveSystem:delete(slotNumber)
  if not self:exists(slotNumber) then return false end
  
  local filename = self:getSlotFilename(slotNumber)
  local success = love.filesystem.remove(filename)
  
  if success then
    print(string.format("[SaveSystem] Deleted save slot %d", slotNumber))
  else
    print(string.format("[SaveSystem] ERROR: Failed to delete slot %d", slotNumber))
  end
  
  return success
end

function SaveSystem:quickSave(gameState)
  return self:save(gameState, 1)
end

function SaveSystem:quickLoad()
  return self:load(1)
end

return SaveSystem
