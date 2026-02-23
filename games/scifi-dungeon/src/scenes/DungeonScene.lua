-- src/scenes/DungeonScene.lua
-- Main gameplay scene integrating Phase 2 systems:
-- RaycasterSystem, MinimapSystem, HUD, DungeonMap, Audio, Combat, Save/Load

local SceneManager = require("src.scenes.SceneManager")
local RaycasterSystem = require("src.systems.RaycasterSystem")
local MinimapSystem = require("src.systems.MinimapSystem")
local HUD = require("src.ui.HUD")
local Character = require("src.entities.Character")
local DungeonMap = require("src.systems.DungeonMap")
local EncounterSystem = require("src.systems.EncounterSystem")
local AudioSystem = require("src.systems.AudioSystem")
local SaveSystem = require("src.systems.SaveSystem")

local DungeonScene = {}
DungeonScene.__index = DungeonScene

-- ─── Constants ───────────────────────────────────────────────────────────────

local STEP_SIZE = 1.0        -- Move exactly 1 grid cell
local ROTATE_ANGLE = math.pi / 2  -- Rotate exactly 90 degrees
local MOVE_DURATION = 0.15   -- Animation duration in seconds
local ROT_DURATION = 0.10    -- Rotation animation duration

-- ─── Factory ─────────────────────────────────────────────────────────────────

function DungeonScene:new()
  return setmetatable({}, DungeonScene)
end

-- ─── Lifecycle ───────────────────────────────────────────────────────────────

function DungeonScene:load()
  -- Initialize global systems
  AudioSystem:init()
  SaveSystem:init()
  
  -- Initialize scene systems
  self.raycaster = RaycasterSystem:new()
  self.minimap = MinimapSystem:new(128)
  self.hud = HUD:new()
  self.dungeonMap = DungeonMap:new()
  
  -- Game state
  self.party = nil
  self.currentDistrict = 1
  self.currentLevel = "levels/deck1.lua"
  
  -- Player state
  self.playerX = 2.5
  self.playerY = 2.5
  self.playerDir = math.pi * 1.5
  
  -- Movement animation state
  self.isMoving = false
  self.isRotating = false
  self.moveTimer = 0
  self.rotateTimer = 0
  self.startX = 0
  self.startY = 0
  self.targetX = 0
  self.targetY = 0
  self.startDir = 0
  self.targetDir = 0
  
  print("[DungeonScene] Systems initialized")
end

function DungeonScene:enter(data)
  -- Load from save data or start new game
  if data and data.currentLevel then
    self:loadGameState(data)
  else
    -- Default new game state
    self:startNewGame()
  end
  
  -- Start dungeon music
  AudioSystem:playMusic("d1_sprawl", 1.5)
  
  print("[DungeonScene] Entered - ESC=Menu | Tab=Inventory | E=Interact")
  print("[DungeonScene] F5=Quick Save | F9=Quick Load")
end

function DungeonScene:exit()
  -- Stop music
  AudioSystem:stopMusic(1.0)
  print("[DungeonScene] Exiting dungeon")
end

-- ─── Game State Management ──────────────────────────────────────────────────

function DungeonScene:startNewGame()
  -- Create default party
  self.party = {
    Character:new("Rex", "Marine", 1),
    Character:new("Cipher", "Hacker", 1),
    Character:new("Nova", "Medic", 1),
    Character:new("Vex", "Psionic", 1)
  }
  
  -- Simulate some damage for HUD testing
  self.party[1]:takeDamage(15)
  self.party[3]:takeDamage(8)
  
  -- Load starting level
  self.currentLevel = "levels/deck1.lua"
  self.currentDistrict = 1
  
  local success = self.dungeonMap:loadLevel(self.currentLevel)
  if success then
    self.raycaster:setMap(self.dungeonMap.grid)
    self.minimap:setMap(self.dungeonMap.grid)
    
    -- Use spawn point from level if available
    if self.dungeonMap.metadata.playerSpawn then
      self.playerX = self.dungeonMap.metadata.playerSpawn.x
      self.playerY = self.dungeonMap.metadata.playerSpawn.y
      self.playerDir = self.dungeonMap.metadata.playerSpawn.dir or math.pi * 1.5
    end
  else
    print("[DungeonScene] ERROR: Failed to load level")
    -- Fall back to center position
    self.playerX = 10.5
    self.playerY = 10.5
    self.playerDir = math.pi * 1.5
  end
  
  -- Initialize position state
  self:resetMovementState()
  
  -- Initialize encounter system
  EncounterSystem:init(self.currentDistrict)
  
  -- Update HUD
  self:updateHUD()
  
  print(string.format("[DungeonScene] New game started: %s | District %d",
    self.dungeonMap.metadata.name or "Unknown", self.currentDistrict))
end

function DungeonScene:loadGameState(data)
  -- Load party
  self.party = data.party
  
  -- Load level
  self.currentLevel = data.currentLevel or "levels/deck1.lua"
  self.currentDistrict = data.currentDistrict or 1
  
  local success = self.dungeonMap:loadLevel(self.currentLevel)
  if success then
    self.raycaster:setMap(self.dungeonMap.grid)
    self.minimap:setMap(self.dungeonMap.grid)
  end
  
  -- Load player position
  self.playerX = data.playerX or 2.5
  self.playerY = data.playerY or 2.5
  self.playerDir = data.playerDir or math.pi * 1.5
  
  -- Initialize position state
  self:resetMovementState()
  
  -- Initialize encounter system
  EncounterSystem:init(self.currentDistrict)
  
  -- Update HUD
  self:updateHUD()
  
  print(string.format("[DungeonScene] Loaded: %s | District %d | Party: %d",
    self.dungeonMap.metadata.name or "Unknown", self.currentDistrict, #self.party))
end

function DungeonScene:resetMovementState()
  self.isMoving = false
  self.isRotating = false
  self.moveTimer = 0
  self.rotateTimer = 0
  self.startX = self.playerX
  self.startY = self.playerY
  self.targetX = self.playerX
  self.targetY = self.playerY
  self.startDir = self.playerDir
  self.targetDir = self.playerDir
  
  self.raycaster:setPlayerPos(self.playerX, self.playerY, self.playerDir)
  self.minimap:updatePlayer(self.playerX, self.playerY, self.playerDir)
end

-- ─── Update ──────────────────────────────────────────────────────────────────

function DungeonScene:update(dt)
  -- Don't update if overlay is active
  if SceneManager:hasOverlay() then
    return
  end
  
  -- Handle movement animations
  self:updateMovementAnimation(dt)
  
  -- Update systems
  self.raycaster:render()
  self.hud:update(dt)
  
  -- Update HUD
  self:updateHUD()
end

function DungeonScene:updateMovementAnimation(dt)
  -- Update position animation
  if self.isMoving then
    self.moveTimer = self.moveTimer + dt
    local progress = math.min(self.moveTimer / MOVE_DURATION, 1.0)
    
    -- Smooth easing (ease-out)
    local t = 1 - (1 - progress) * (1 - progress)
    
    self.playerX = self.startX + (self.targetX - self.startX) * t
    self.playerY = self.startY + (self.targetY - self.startY) * t
    
    if progress >= 1.0 then
      self.playerX = self.targetX
      self.playerY = self.targetY
      self.isMoving = false
      
      -- Check for encounter after movement completes
      self:checkEncounter()
    end
    
    self.raycaster:setPlayerPos(self.playerX, self.playerY, self.playerDir)
    self.minimap:updatePlayer(self.playerX, self.playerY, self.playerDir)
  end
  
  -- Update rotation animation
  if self.isRotating then
    self.rotateTimer = self.rotateTimer + dt
    local progress = math.min(self.rotateTimer / ROT_DURATION, 1.0)
    
    -- Smooth easing
    local t = 1 - (1 - progress) * (1 - progress)
    
    -- Handle angle wrapping
    local angleDiff = self.targetDir - self.startDir
    
    -- Normalize to shortest path
    if angleDiff > math.pi then
      angleDiff = angleDiff - 2 * math.pi
    elseif angleDiff < -math.pi then
      angleDiff = angleDiff + 2 * math.pi
    end
    
    self.playerDir = self.startDir + angleDiff * t
    
    if progress >= 1.0 then
      self.playerDir = self.targetDir
      self.isRotating = false
    end
    
    self.raycaster:setPlayerPos(self.playerX, self.playerY, self.playerDir)
    self.minimap:updatePlayer(self.playerX, self.playerY, self.playerDir)
  end
end

-- ─── Movement ────────────────────────────────────────────────────────────────

function DungeonScene:tryMove(dx, dy)
  -- Don't start new move if already moving/rotating
  if self.isMoving or self.isRotating then
    return
  end
  
  -- Calculate target position (move 1 full grid cell)
  local targetX = self.playerX + dx * STEP_SIZE
  local targetY = self.playerY + dy * STEP_SIZE
  
  -- Check collision at target
  if self:canMoveTo(targetX, targetY) then
    self.isMoving = true
    self.moveTimer = 0
    self.startX = self.playerX
    self.startY = self.playerY
    self.targetX = targetX
    self.targetY = targetY
    
    -- Play footstep sound
    AudioSystem:playSFX("step_metal")
  end
end

function DungeonScene:tryRotate(direction)
  -- Don't start new rotation if already moving/rotating
  if self.isMoving or self.isRotating then
    return
  end
  
  self.isRotating = true
  self.rotateTimer = 0
  self.startDir = self.playerDir
  self.targetDir = self.playerDir + direction * ROTATE_ANGLE
  
  -- Normalize target angle to [0, 2π)
  while self.targetDir < 0 do
    self.targetDir = self.targetDir + 2 * math.pi
  end
  while self.targetDir >= 2 * math.pi do
    self.targetDir = self.targetDir - 2 * math.pi
  end
end

function DungeonScene:canMoveTo(x, y)
  -- Check if position is valid using DungeonMap
  if not self.dungeonMap or not self.dungeonMap.loaded then
    return false
  end
  
  local cellX = math.floor(x)
  local cellY = math.floor(y)
  
  return self.dungeonMap:isWalkable(cellX, cellY)
end

-- ─── Encounter System ───────────────────────────────────────────────────────

function DungeonScene:checkEncounter()
  -- Get cell type at player position
  local cellX = math.floor(self.playerX)
  local cellY = math.floor(self.playerY)
  
  if not self.dungeonMap or not self.dungeonMap.loaded then
    return
  end
  
  local cellType = self.dungeonMap:getCell(cellX, cellY)
  
  -- Check if encounter should trigger
  if EncounterSystem:checkEncounter(cellType) then
    self:triggerEncounter()
  end
end

function DungeonScene:triggerEncounter()
  print("[DungeonScene] Encounter triggered!")
  
  -- Generate enemies
  local enemies = EncounterSystem:generateEncounter()
  
  if #enemies == 0 then
    print("[DungeonScene] No enemies generated, skipping encounter")
    return
  end
  
  -- Launch combat screen as overlay
  SceneManager:pushOverlay("combat", {
    party = self.party,
    enemies = enemies,
    onVictory = function(loot)
      self:onCombatVictory(loot)
    end,
    onDefeat = function()
      self:onCombatDefeat()
    end,
    onFlee = function()
      self:onCombatFlee()
    end
  })
end

function DungeonScene:onCombatVictory(loot)
  print("[DungeonScene] Combat victory! Loot:", loot and #loot or 0, "items")
  -- TODO Phase 3: Add loot to inventory
  SceneManager:popOverlay()
end

function DungeonScene:onCombatDefeat()
  print("[DungeonScene] Party defeated! Game Over")
  SceneManager:popOverlay()
  SceneManager:switch("menu")
end

function DungeonScene:onCombatFlee()
  print("[DungeonScene] Fled from combat")
  SceneManager:popOverlay()
end

-- ─── Interaction System ─────────────────────────────────────────────────────

function DungeonScene:interact()
  -- Check cell in front of player
  local checkDist = 1.0
  local checkX = self.playerX + math.cos(self.playerDir) * checkDist
  local checkY = self.playerY + math.sin(self.playerDir) * checkDist
  
  local cellX = math.floor(checkX)
  local cellY = math.floor(checkY)
  
  if not self.dungeonMap or not self.dungeonMap.loaded then
    return
  end
  
  local cellType = self.dungeonMap:getCell(cellX, cellY)
  local CT = DungeonMap.CELL_TYPES
  
  if cellType == CT.DOOR then
    print("[DungeonScene] Door (already open)")
    
  elseif cellType == CT.DOOR_LOCKED then
    print("[DungeonScene] Door is locked - need key")
    AudioSystem:playSFX("door_locked")
    
  elseif cellType == CT.TERMINAL then
    print("[DungeonScene] Accessing terminal - Quick saving...")
    AudioSystem:playSFX("terminal_boop")
    self:quickSave()
    
  elseif cellType == CT.STAIRS_DOWN then
    print("[DungeonScene] Stairs down - TODO: Level transition")
    
  elseif cellType == CT.STAIRS_UP then
    print("[DungeonScene] Stairs up - TODO: Level transition")
  end
end

-- ─── Save/Load System ───────────────────────────────────────────────────────

function DungeonScene:quickSave()
  local saveData = self:captureGameState()
  local success = SaveSystem:save(saveData, 1)
  
  if success then
    print("[DungeonScene] ✓ Quick saved to slot 1")
    self.hud:addMessage("Game saved", {0, 1, 0, 1})
  else
    print("[DungeonScene] ✗ Quick save failed")
    self.hud:addMessage("Save failed", {1, 0, 0, 1})
  end
end

function DungeonScene:quickLoad()
  local saveData = SaveSystem:load(1)
  
  if saveData then
    print("[DungeonScene] Quick loading from slot 1...")
    self:loadGameState(saveData)
    self.hud:addMessage("Game loaded", {0, 1, 0, 1})
  else
    print("[DungeonScene] ✗ No save file found")
    self.hud:addMessage("No save file", {1, 1, 0, 1})
  end
end

function DungeonScene:captureGameState()
  return {
    version = SaveSystem.saveVersion,
    timestamp = os.time(),
    
    -- Party data
    party = self.party,
    
    -- Level data
    currentLevel = self.currentLevel,
    currentDistrict = self.currentDistrict,
    
    -- Player position
    playerX = self.playerX,
    playerY = self.playerY,
    playerDir = self.playerDir,
  }
end

-- ─── HUD Management ─────────────────────────────────────────────────────────

function DungeonScene:updateHUD()
  -- Update HUD with current player direction
  self.hud:setPlayerStats({
    direction = self.playerDir,
    location = (self.dungeonMap and self.dungeonMap.metadata.name) or "Unknown",
    depth = self.currentDistrict
  })
  
  -- Update party member stats in HUD
  if self.party then
    for i, character in ipairs(self.party) do
      self.hud:updatePartyMember(i, character:toHUDData())
    end
  end
end

function DungeonScene:countAliveParty()
  if not self.party then return 0 end
  
  local count = 0
  for _, character in ipairs(self.party) do
    if character.isAlive then
      count = count + 1
    end
  end
  return count
end

-- ─── Draw ────────────────────────────────────────────────────────────────────

function DungeonScene:draw()
  -- Render raycaster viewport (left side: 768x576 at 0,0)
  self.raycaster:draw(0, 0)
  
  -- Render HUD (right side: starts at x=768)
  self.hud:draw()
  
  -- Render minimap on HUD
  self.minimap:draw(768 + 192, 100)
  
  -- Debug info overlay
  if love.keyboard.isDown("f1") then
    self:drawDebugInfo()
  end
end

function DungeonScene:drawDebugInfo()
  love.graphics.setColor(0, 0, 0, 0.8)
  love.graphics.rectangle("fill", 0, 720 - 80, 500, 80)
  
  love.graphics.setColor(0, 1, 0, 1)
  love.graphics.setFont(love.graphics.newFont(12))
  
  local status = ""
  if self.isMoving then status = " [MOVING]"
  elseif self.isRotating then status = " [ROTATING]"
  end
  
  local debugText = string.format(
    "POS: (%.1f, %.1f) | DIR: %.0f° | ALIVE: %d/4%s",
    self.playerX, self.playerY,
    math.deg(self.playerDir),
    self:countAliveParty(),
    status
  )
  
  love.graphics.print(debugText, 10, 720 - 70)
  
  local cellX, cellY = math.floor(self.playerX), math.floor(self.playerY)
  local cellType = self.dungeonMap and self.dungeonMap:getCell(cellX, cellY) or -1
  local cellName = DungeonMap.CELL_NAMES[cellType] or "UNKNOWN"
  love.graphics.print(string.format("CELL: (%d,%d) = %s", cellX, cellY, cellName), 10, 720 - 52)
  
  love.graphics.setColor(0, 0.75, 1, 1)
  love.graphics.print("WASD/Arrows=Move/Rotate | E=Interact | Tab=Inventory | F5=Save F9=Load | Hold F1=Debug", 10, 720 - 30)
  
  love.graphics.setColor(1, 1, 1, 1)
end

-- ─── Input ───────────────────────────────────────────────────────────────────

function DungeonScene:keypressed(key)
  -- Don't process input if overlay is active
  if SceneManager:hasOverlay() then
    return
  end
  
  -- Menu
  if key == "escape" then
    SceneManager:switch("menu")
    return
  end
  
  -- Inventory screen
  if key == "tab" or key == "i" then
    self:openInventory()
    return
  end
  
  -- Quick save/load
  if key == "f5" then
    self:quickSave()
    return
  end
  
  if key == "f9" then
    self:quickLoad()
    return
  end
  
  -- Interaction
  if key == "space" or key == "e" then
    self:interact()
    return
  end
  
  -- Grid-based movement
  if key == "w" or key == "up" then
    local dx = math.cos(self.playerDir)
    local dy = math.sin(self.playerDir)
    self:tryMove(dx, dy)
    
  elseif key == "s" or key == "down" then
    local dx = -math.cos(self.playerDir)
    local dy = -math.sin(self.playerDir)
    self:tryMove(dx, dy)
    
  elseif key == "a" or key == "left" then
    self:tryRotate(1)  -- Counter-clockwise
    
  elseif key == "d" or key == "right" then
    self:tryRotate(-1)  -- Clockwise
  end
end

function DungeonScene:openInventory()
  print("[DungeonScene] Opening inventory...")
  SceneManager:pushOverlay("inventory", {
    party = self.party,
    onClose = function()
      SceneManager:popOverlay()
    end
  })
end

function DungeonScene:mousepressed(x, y, button)
  -- TODO Phase 3: Mouse interaction
end

return DungeonScene
