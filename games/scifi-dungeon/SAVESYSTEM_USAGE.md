-- SaveSystem Usage Example for scifi-dungeon
-- This demonstrates how to integrate SaveSystem with game scenes

local SaveSystem = require("src.systems.SaveSystem")

-- Initialize at game startup (in main.lua or MenuScene)
function love.load()
  SaveSystem:init()
end

-- Example: Saving game state from DungeonScene
function DungeonScene:saveGame()
  -- Gather game state
  local gameState = SaveSystem:exportGameState(
    self.party,              -- Party data (characters, stats, equipment)
    self.inventory.items,    -- Inventory items
    self.dungeonMap,         -- DungeonMap instance (includes explored/doorStates)
    self.player.position,    -- Player position {x, y}
    self.player.direction,   -- Player direction in radians
    self.gameFlags,          -- Game flags/progress
    self.playTime            -- Play time in seconds
  )
  
  -- Save to slot 1 (Phase 2: single slot only)
  local success, err = SaveSystem:save(gameState, 1)
  
  if success then
    print("Game saved successfully!")
    -- Show confirmation message to player
  else
    print("Failed to save:", err)
    -- Show error message to player
  end
end

-- Example: Loading game state in MenuScene
function MenuScene:continueGame()
  -- Check if save exists
  if not SaveSystem:exists(1) then
    print("No save file found")
    return
  end
  
  -- Get save info for display
  local saveInfo = SaveSystem:getSaveInfo(1)
  if saveInfo then
    print(string.format("Save found: District %d, %d seconds played",
      saveInfo.district, saveInfo.playTime))
  end
  
  -- Load the save
  local gameState = SaveSystem:load(1)
  
  if gameState then
    -- Transition to DungeonScene with loaded state
    sceneManager:switch("dungeon", "fade", 1.0, gameState)
  else
    print("Failed to load save file")
  end
end

-- Example: Restoring game state in DungeonScene
function DungeonScene:enter(gameState)
  if gameState then
    -- Restore from save
    self.party = gameState.party
    self.inventory:setItems(gameState.inventory)
    self.player.position = gameState.playerPosition
    self.player.direction = gameState.playerDirection
    self.gameFlags = gameState.flags
    self.playTime = gameState.playTime
    
    -- Restore map state
    if gameState.exploredCells then
      self.dungeonMap.explored = gameState.exploredCells
    end
    if gameState.doorStates then
      self.dungeonMap.doorStates = gameState.doorStates
    end
    
    -- Load correct level
    self.dungeonMap:loadLevel(gameState.currentLevel)
    
    print("Game state restored from save")
  else
    -- New game - initialize fresh
    self:initNewGame()
  end
end

-- Example: Quick save (bound to F5 key)
function DungeonScene:keypressed(key)
  if key == "f5" then
    local gameState = SaveSystem:exportGameState(
      self.party, self.inventory.items, self.dungeonMap,
      self.player.position, self.player.direction,
      self.gameFlags, self.playTime
    )
    SaveSystem:quickSave(gameState)
    print("Quick saved!")
  elseif key == "f9" then
    local gameState = SaveSystem:quickLoad()
    if gameState then
      -- Reload current scene with saved state
      sceneManager:switch("dungeon", "none", 0, gameState)
      print("Quick loaded!")
    end
  end
end

-- Example: Menu "Continue" button logic
function MenuScene:initButtons()
  local continueButton = Button:new(
    x, y, width, height,
    "Continue",
    function() self:continueGame() end
  )
  
  -- Enable only if save exists
  continueButton.enabled = SaveSystem:exists(1)
  
  table.insert(self.buttons, continueButton)
end

-- Example: Safe Room terminal save option (Phase 3)
function SafeRoomTerminal:onSaveSelected()
  local gameState = SaveSystem:exportGameState(
    dungeon.party, dungeon.inventory.items, dungeon.dungeonMap,
    dungeon.player.position, dungeon.player.direction,
    dungeon.gameFlags, dungeon.playTime
  )
  
  local success = SaveSystem:save(gameState, 1)
  
  if success then
    self:showMessage("Progress saved to terminal.")
  else
    self:showMessage("ERROR: Failed to save. Memory corrupted.")
  end
end
