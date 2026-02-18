-- Game Scene
-- Main gameplay scene for Raccoon Story

local Player = require("src.entities.Player")
local TrashItem = require("src.entities.TrashItem")
local Human = require("src.entities.Human")
local Dog = require("src.entities.Dog")
local Animal = require("src.entities.Animal")
local AISystem = require("src.systems.AISystem")
local Assets = require("src.utils.assets")
local PauseMenu = require("src.ui.PauseMenu")
local SettingsMenu = require("src.ui.SettingsMenu")
local Panel = require("src.ui.Panel")
local Icon = require("src.ui.Icon")

local GameScene = {}

function GameScene:enter()
  print("Entering Game Scene")
  
  -- Load assets (including generated sprites)
  Assets:loadAll()
  
  -- World boundaries (must be set first)
  self.worldWidth = 1600
  self.worldHeight = 1200
  
  -- Initialize player at center of screen
  self.player = Player:new(400, 300)
  
  -- Set player sprites from generated assets
  local playerIdleFrames = Assets:getPlayerSprite("idle")
  local playerWalkFrames = Assets:getPlayerSprite("walk")
  local playerDashFrames = Assets:getPlayerSprite("dash")
  if playerIdleFrames and playerWalkFrames and playerDashFrames then
    self.player:setSprites(playerIdleFrames, playerWalkFrames, playerDashFrames)
    print("[GameScene] Player sprites loaded successfully (idle, walk, dash)")
  else
    print("[GameScene] Warning: Player sprites not loaded properly")
    print("  - Idle:", playerIdleFrames ~= nil)
    print("  - Walk:", playerWalkFrames ~= nil)
    print("  - Dash:", playerDashFrames ~= nil)
  end
  
  -- Game state
  self.score = 0
  self.itemsCollected = 0
  self.timeElapsed = 0
  
  -- Camera (simple follow)
  self.cameraX = 0
  self.cameraY = 0
  
  -- Initialize trash items (after world boundaries are set)
  self.trashItems = {}
  self:spawnTrash()
  
  -- Initialize AI System
  self.aiSystem = AISystem:new()
  self:spawnEnemies()
  print("[GameScene] ===== IMMEDIATELY AFTER SPAWN ENEMIES =====")
  
  print("[GameScene] About to initialize UI components...")
  
  -- UI state
  self.messageText = "Collect trash for your family!"
  self.messageTimer = 3
  self.messageAlpha = 1
  
  print("[GameScene] UI state initialized")
  
  -- Caught state
  self.justCaught = false
  self.caughtCooldown = 0
  
  print("[GameScene] Initializing pause menu...")
  -- Pause menu
  self.pauseMenu = PauseMenu:new()
  print("[GameScene] PauseMenu created:", self.pauseMenu ~= nil)
  self.pauseMenu.onResume = function()
    -- Game automatically unpauses when menu is hidden
  end
  self.pauseMenu.onSettings = function()
    self.settingsMenu:show()
  end
  self.pauseMenu.onRestartNight = function()
    self:restartNight()
  end
  self.pauseMenu.onQuitToMenu = function()
    self:quitToMenu()
  end
  
  -- Settings menu
  self.settingsMenu = SettingsMenu:new()
  self.settingsMenu.onBack = function()
    self.settingsMenu:hide()
  end
  
  -- HUD icons
  self.moonIcon = Icon:new("moon", 0, 0, 30)
  self.alertIcon = Icon:new("alert", 0, 0, 25, {1, 0.4, 0.4, 1})
  self.alertIcon:setPulse(true, 4, 0.3)
  self.dashIcon = Icon:new("dash", 0, 0, 20, {0.565, 0.933, 0.565, 1})
  self.homeIcon = Icon:new("home", 0, 0, 15, {1, 0.8, 0.2, 1})
  
  -- Inventory slot animation
  self.inventorySlotAnimations = {}
  for i = 1, self.player.maxInventorySlots do
    self.inventorySlotAnimations[i] = {
      scale = 1.0,
      targetScale = 1.0,
      pulse = 0
    }
  end
  
  -- HUD panels
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  self.topPanel = Panel:new(0, 0, screenWidth, 70, "translucent")
  self.sidePanel = Panel:new(screenWidth - 220, 70, 220, screenHeight - 70, "translucent")
  self.minimapPanel = Panel:new(20, screenHeight - 170, 150, 150, "translucent")
end

function GameScene:restartNight()
  print("[GameScene] Restarting night")
  self.pauseMenu:hide()
  self:enter() -- Re-initialize the scene
end

function GameScene:quitToMenu()
  print("[GameScene] Quitting to menu")
  local SceneManager = require("src.scenes.SceneManager")
  SceneManager:switch("menu")
end

function GameScene:exit()
  print("Exiting Game Scene")
  self.player = nil
  self.trashItems = nil
  if self.aiSystem then
    self.aiSystem:clear()
  end
  self.aiSystem = nil
end

function GameScene:spawnTrash()
  -- Spawn various trash items around the level
  local trashTypes = {"pizza", "burger", "donut", "pizza", "burger", "pizza", "bag"}
  
  for i = 1, 15 do
    local x = math.random(100, self.worldWidth - 100)
    local y = math.random(100, self.worldHeight - 100)
    local trashType = trashTypes[math.random(#trashTypes)]
    
    local trashItem = TrashItem:new(x, y, trashType)
    
    -- Set sprite from generated assets
    local sprite = Assets:getTrashSprite(trashType)
    if sprite then
      trashItem:setSprite(sprite)
    end
    
    table.insert(self.trashItems, trashItem)
  end
  
  print("[GameScene] Spawned " .. #self.trashItems .. " trash items with sprites")
end

function GameScene:spawnEnemies()
  -- Spawn 2-3 humans with patrol routes
  
  -- Human 1: Patrols top-left area
  local human1 = Human:new(300, 300, {
    {x = 300, y = 300},
    {x = 500, y = 300},
    {x = 500, y = 500},
    {x = 300, y = 500}
  })
  local humanSprite = Assets:getEnemySprite("human")
  local humanWalkSprite = Assets:getEnemySprite("humanWalk")
  if humanSprite and humanWalkSprite then
    human1:setSprites(humanSprite, humanWalkSprite)
  end
  self.aiSystem:addHuman(human1)
  
  -- Human 2: Patrols right side
  local human2 = Human:new(1200, 400, {
    {x = 1200, y = 400},
    {x = 1400, y = 400},
    {x = 1400, y = 700},
    {x = 1200, y = 700}
  })
  if humanSprite and humanWalkSprite then
    human2:setSprites(humanSprite, humanWalkSprite)
  end
  self.aiSystem:addHuman(human2)
  
  -- Human 3: Patrols bottom area
  local human3 = Human:new(600, 900, {
    {x = 400, y = 900},
    {x = 800, y = 900},
    {x = 800, y = 1000},
    {x = 400, y = 1000}
  })
  if humanSprite and humanWalkSprite then
    human3:setSprites(humanSprite, humanWalkSprite)
  end
  self.aiSystem:addHuman(human3)
  
  -- Spawn 1-2 dogs in yards
  
  -- Dog 1: Guards middle area
  local dog1 = Dog:new(800, 600, {
    {x = 700, y = 600},
    {x = 900, y = 600},
    {x = 900, y = 700},
    {x = 700, y = 700}
  })
  local dogSprite = Assets:getEnemySprite("dog")
  local dogRunSprite = Assets:getEnemySprite("dogRun")
  if dogSprite and dogRunSprite then
    dog1:setSprites(dogSprite, dogRunSprite)
  end
  self.aiSystem:addDog(dog1)
  
  -- Dog 2: Fast patrol near top-right
  local dog2 = Dog:new(1100, 300, {
    {x = 1000, y = 300},
    {x = 1200, y = 300},
    {x = 1200, y = 400},
    {x = 1000, y = 400}
  })
  if dogSprite and dogRunSprite then
    dog2:setSprites(dogSprite, dogRunSprite)
  end
  self.aiSystem:addDog(dog2)
  
  -- Spawn 2-3 competing animals
  
  -- Possum 1: Slow wanderer
  local possum1 = Animal:new(500, 700, "possum")
  local possumSprite = Assets:getEnemySprite("possum")
  if possumSprite then
    possum1:setSprite(possumSprite)
  end
  self.aiSystem:addAnimal(possum1)
  
  -- Cat 1: Quick territorial
  local cat1 = Animal:new(900, 400, "cat")
  local catSprite = Assets:getEnemySprite("cat")
  if catSprite then
    cat1:setSprite(catSprite)
  end
  self.aiSystem:addAnimal(cat1)
  
  -- Crow 1: Flying thief
  local crow1 = Animal:new(700, 500, "crow")
  local crowSprite = Assets:getEnemySprite("crow")
  if crowSprite then
    crow1:setSprite(crowSprite)
  end
  self.aiSystem:addAnimal(crow1)
  
  -- Optional: Another possum
  local possum2 = Animal:new(1300, 800, "possum")
  if possumSprite then
    possum2:setSprite(possumSprite)
  end
  self.aiSystem:addAnimal(possum2)
  
  print("[GameScene] Spawned enemies: " .. self.aiSystem:getTotalCount() .. " total")
  local counts = self.aiSystem:getCounts()
  print("  - Humans: " .. counts.humans)
  print("  - Dogs: " .. counts.dogs)
  print("  - Animals: " .. counts.animals)
end

function GameScene:update(dt)
  -- Update pause menu and settings
  if self.pauseMenu:isActive() then
    self.pauseMenu:update(dt)
    if self.settingsMenu:isActive() then
      self.settingsMenu:update(dt)
    end
    return -- Don't update game when paused
  end
  
  -- Update HUD icons
  self.moonIcon:update(dt)
  self.alertIcon:update(dt)
  self.dashIcon:update(dt)
  self.homeIcon:update(dt)
  
  -- Update inventory slot animations
  local inventoryCount = self.player:getInventoryCount()
  for i = 1, self.player.maxInventorySlots do
    local anim = self.inventorySlotAnimations[i]
    
    -- Pulse animation when slot is filled
    if i <= inventoryCount then
      anim.pulse = anim.pulse + dt * 3
      anim.targetScale = 1.0 + math.sin(anim.pulse) * 0.05
    else
      anim.targetScale = 1.0
      anim.pulse = 0
    end
    
    -- Smooth scale transition
    anim.scale = anim.scale + (anim.targetScale - anim.scale) * 10 * dt
  end
  
  -- Update time
  self.timeElapsed = self.timeElapsed + dt
  
  -- Update message timer and fade
  if self.messageTimer > 0 then
    self.messageTimer = self.messageTimer - dt
    -- Fade in first 0.3s, stay full for middle, fade out last second
    if self.messageTimer > 2.7 then
      self.messageAlpha = (3.0 - self.messageTimer) / 0.3
    elseif self.messageTimer < 1.0 then
      self.messageAlpha = self.messageTimer
    else
      self.messageAlpha = 1.0
    end
  end
  
  -- Update caught cooldown
  if self.caughtCooldown > 0 then
    self.caughtCooldown = self.caughtCooldown - dt
  end
  
  -- Update player
  self.player:update(dt)
  
  -- Keep player within world bounds
  self.player.x = math.max(0, math.min(self.player.x, self.worldWidth - self.player.width))
  self.player.y = math.max(0, math.min(self.player.y, self.worldHeight - self.player.height))
  
  -- Update AI System
  local aiResult = self.aiSystem:update(dt, self.player, self.trashItems)
  
  -- Check if player was caught
  if aiResult and aiResult.caught and self.caughtCooldown <= 0 then
    self:playerCaught(aiResult.enemyType, aiResult.dropCount)
  end
  
  -- Update trash items
  for _, trash in ipairs(self.trashItems) do
    trash:update(dt)
    
    -- Check collision with player
    if trash:checkCollision(self.player) then
      self:collectTrash(trash)
    end
  end
  
  -- Camera follows player (smoothly)
  local targetCameraX = self.player.x - love.graphics.getWidth() / 2 + self.player.width / 2
  local targetCameraY = self.player.y - love.graphics.getHeight() / 2 + self.player.height / 2
  
  -- Clamp camera to world bounds
  targetCameraX = math.max(0, math.min(targetCameraX, self.worldWidth - love.graphics.getWidth()))
  targetCameraY = math.max(0, math.min(targetCameraY, self.worldHeight - love.graphics.getHeight()))
  
  -- Smooth camera movement
  self.cameraX = self.cameraX + (targetCameraX - self.cameraX) * 5 * dt
  self.cameraY = self.cameraY + (targetCameraY - self.cameraY) * 5 * dt
end

function GameScene:playerCaught(enemyType, dropCount)
  print("[GameScene] Player caught by " .. enemyType .. "! Dropping " .. dropCount .. " items")
  
  -- Drop random items from inventory
  local droppedCount = 0
  for i = 1, dropCount do
    if self.player:getInventoryCount() > 0 then
      self.player:removeFromInventory(1)
      droppedCount = droppedCount + 1
      -- TODO: Spawn dropped items on ground
    end
  end
  
  -- Show message
  if droppedCount > 0 then
    self.messageText = "Caught! Lost " .. droppedCount .. " items!"
  else
    self.messageText = "Almost caught! (No items to drop)"
  end
  self.messageTimer = 3
  
  -- Set cooldown to prevent multiple catches
  self.caughtCooldown = 2
  
  -- Update score (penalty)
  self.score = math.max(0, self.score - droppedCount * 5)
end

function GameScene:collectTrash(trash)
  local data = trash:getData()
  
  -- Check if player has inventory space
  if self.player:getInventoryCount() + data.slots <= self.player.maxInventorySlots then
    -- Collect the item
    trash:collect()
    
    -- Add to inventory
    for i = 1, data.slots do
      self.player:addToInventory(data)
    end
    
    -- Update score
    self.score = self.score + data.points
    self.itemsCollected = self.itemsCollected + 1
    
    -- Show message
    self.messageText = "Collected " .. data.name .. "! (+" .. data.points .. " points)"
    self.messageTimer = 2
    
    print("Collected: " .. data.name .. " (" .. data.points .. " points)")
  else
    -- Inventory full
    self.messageText = "Inventory Full! (" .. self.player:getInventoryCount() .. "/" .. self.player.maxInventorySlots .. ")"
    self.messageTimer = 2
  end
end

function GameScene:draw()
  local lg = love.graphics
  
  -- Apply camera transform
  lg.push()
  lg.translate(-self.cameraX, -self.cameraY)
  
  -- Draw background (dark blue-green night grass)
  lg.clear(0.1, 0.2, 0.15)
  
  -- Draw world boundary
  lg.setColor(0.3, 0.3, 0.3, 0.3)
  lg.rectangle("fill", 0, 0, self.worldWidth, self.worldHeight)
  
  -- Draw grid for visual reference
  lg.setColor(0.2, 0.3, 0.2, 0.5)
  for x = 0, self.worldWidth, 64 do
    lg.line(x, 0, x, self.worldHeight)
  end
  for y = 0, self.worldHeight, 64 do
    lg.line(0, y, self.worldWidth, y)
  end
  
  -- Draw trash items
  for _, trash in ipairs(self.trashItems) do
    trash:draw()
  end
  
  -- Draw AI enemies
  self.aiSystem:draw()
  
  -- Draw player
  self.player:draw()
  
  -- Debug: Draw AI vision cones (press V to toggle in future)
  -- self.aiSystem:drawDebug()
  
  lg.pop()
  
  -- Draw HUD (no camera transform)
  self:drawHUD()
  
  -- Draw pause menu and settings on top
  if self.pauseMenu and self.pauseMenu:isActive() then
    self.pauseMenu:draw()
  end
  if self.settingsMenu and self.settingsMenu:isActive() then
    self.settingsMenu:draw()
  end
end

function GameScene:drawHUD()
  local lg = love.graphics
  local screenWidth = lg.getWidth()
  local screenHeight = lg.getHeight()
  
  -- Draw HUD panels
  self.topPanel:draw()
  self.sidePanel:draw()
  self.minimapPanel:draw()
  
  -- === TOP PANEL: Score, Time, Progress ===
  
  -- Score section (left)
  lg.setColor(0.961, 0.871, 0.702, 1) -- Cream
  lg.print("Score", 15, 15, 0, 1.2)
  lg.setColor(0.565, 0.933, 0.565, 1) -- Soft green
  lg.print(tostring(self.score), 15, 35, 0, 2)
  
  -- Items collected 
  lg.setColor(0.961, 0.871, 0.702, 0.8)
  lg.print("Items: " .. self.itemsCollected, 85, 42, 0, 1.1)
  
  -- Night timer with moon icon (center)
  local timerX = screenWidth / 2
  local timerY = 20
  
  -- Moon icon
  self.moonIcon:setPosition(timerX - 70, timerY + 15)
  self.moonIcon:draw()
  
  -- Time display
  local minutes = math.floor(self.timeElapsed / 60)
  local seconds = math.floor(self.timeElapsed % 60)
  local timeText = string.format("%02d:%02d", minutes, seconds)
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print(timeText, timerX - 25, timerY + 5, 0, 1.8)
  
  -- Progress bar (night progress - simplified to 5 minute night)
  local nightDuration = 300 -- 5 minutes
  local progress = math.min(1, self.timeElapsed / nightDuration)
  local barWidth = 150
  local barHeight = 8
  local barX = timerX - barWidth / 2
  local barY = timerY + 40
  
  lg.setColor(0.2, 0.2, 0.3, 0.8)
  lg.rectangle("fill", barX, barY, barWidth, barHeight, 4)
  lg.setColor(0.8, 0.6, 0.2, 1)
  lg.rectangle("fill", barX, barY, barWidth * progress, barHeight, 4)
  lg.setColor(0.545, 0.271, 0.075, 1)
  lg.rectangle("line", barX, barY, barWidth, barHeight, 4)
  
  -- === SIDE PANEL: Inventory ===
  
  local sidePanelX = screenWidth - 210
  local sidePanelY = 85
  
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print("Inventory", sidePanelX, sidePanelY, 0, 1.3)
  
  local inventoryCount = self.player:getInventoryCount()
  local maxSlots = self.player.maxInventorySlots
  
  -- Draw animated inventory slots
  for i = 1, maxSlots do
    local anim = self.inventorySlotAnimations[i]
    local slotSize = 35
    local x = sidePanelX + 10
    local y = sidePanelY + 35 + (i - 1) * 45
    
    -- Calculate scaled position (scale from center)
    local scaledSize = slotSize * anim.scale
    local offsetX = (slotSize - scaledSize) / 2
    local offsetY = (slotSize - scaledSize) / 2
    
    if i <= inventoryCount then
      -- Filled slot with glow
      if anim.scale > 1.02 then
        lg.setColor(1, 0.8, 0.2, 0.3)
        lg.rectangle("fill", x + offsetX - 2, y + offsetY - 2, scaledSize + 4, scaledSize + 4, 5)
      end
      
      lg.setColor(0.8, 0.6, 0.2, 1) -- Gold
      lg.rectangle("fill", x + offsetX, y + offsetY, scaledSize, scaledSize, 4)
      lg.setColor(0.961, 0.871, 0.702, 1)
      lg.setLineWidth(2)
      lg.rectangle("line", x + offsetX, y + offsetY, scaledSize, scaledSize, 4)
      lg.setLineWidth(1)
      
      -- Trash icon (simple)
      lg.setColor(0.545, 0.271, 0.075, 1)
      lg.rectangle("fill", x + offsetX + 8, y + offsetY + 10, 14, 12, 2)
      lg.rectangle("fill", x + offsetX + 6, y + offsetY + 8, 18, 3, 1)
    else
      -- Empty slot
      lg.setColor(0.3, 0.3, 0.3, 0.5)
      lg.rectangle("fill", x + offsetX, y + offsetY, scaledSize, scaledSize, 4)
      lg.setColor(0.5, 0.5, 0.5, 0.6)
      lg.rectangle("line", x + offsetX, y + offsetY, scaledSize, scaledSize, 4)
    end
  end
  
  -- Inventory count
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print(inventoryCount .. "/" .. maxSlots, sidePanelX + 60, sidePanelY + 35 + maxSlots * 45 + 5, 0, 1.3)
  
  -- Dash ability status
  local dashY = sidePanelY + 35 + maxSlots * 45 + 45
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print("Dash", sidePanelX, dashY, 0, 1.2)
  
  if self.player.dashCooldownTimer > 0 then
    local cooldownProgress = 1 - (self.player.dashCooldownTimer / self.player.dashCooldown)
    lg.setColor(1, 0.5, 0.5, 0.8)
    lg.rectangle("fill", sidePanelX + 10, dashY + 25, 150 * cooldownProgress, 6, 3)
    lg.setColor(0.3, 0.3, 0.3, 0.6)
    lg.rectangle("line", sidePanelX + 10, dashY + 25, 150, 6, 3)
    
    lg.setColor(1, 0.5, 0.5, 0.7)
    lg.print(string.format("%.1fs", self.player.dashCooldownTimer), sidePanelX + 55, dashY + 40, 0, 0.9)
  else
    lg.setColor(0.565, 0.933, 0.565, 1)
    self.dashIcon:setPosition(sidePanelX + 25, dashY + 28)
    self.dashIcon:draw()
    lg.print("Ready!", sidePanelX + 50, dashY + 20, 0, 1.1)
  end
  
  -- === MINIMAP ===
  self:drawMinimap()
  
  -- === THREAT INDICATOR ===
  if self.aiSystem:isAnyoneChasing() then
    local threatCount = self.aiSystem:getActiveThreatCount()
    local flashAlpha = 0.8 + math.sin(love.timer.getTime() * 5) * 0.2
    
    -- Alert icon
    self.alertIcon:setPosition(screenWidth / 2 - 80, 75)
    self.alertIcon:draw()
    
    lg.setColor(1, 0.4, 0.4, flashAlpha)
    lg.print("DANGER!", screenWidth / 2 - 50, 68, 0, 1.5)
    lg.setColor(1, 0.6, 0.6, flashAlpha * 0.8)
    lg.print(threatCount .. " threat" .. (threatCount > 1 and "s" or ""), screenWidth / 2 - 20, 85, 0, 0.9)
  end
  
  -- === MESSAGE DISPLAY (with smooth fade) ===
  if self.messageTimer > 0 then
    local messageY = screenHeight - 60
    
    -- Background panel for message
    lg.setColor(0.106, 0.106, 0.180, self.messageAlpha * 0.8)
    local messageWidth = love.graphics.getFont():getWidth(self.messageText) * 1.3 + 40
    local messageX = (screenWidth - messageWidth) / 2
    lg.rectangle("fill", messageX, messageY - 10, messageWidth, 40, 8)
    
    lg.setColor(1, 1, 1, self.messageAlpha)
    lg.printf(self.messageText, 0, messageY, screenWidth, "center", 0, 1.3)
  end
  
  -- === CONTROLS HINT ===
  lg.setColor(0.7, 0.7, 0.7, 0.6)
  lg.print("WASD: Move | SHIFT: Dash | ESC: Pause", 12, screenHeight - 22, 0, 0.85)
end

function GameScene:drawMinimap()
  local lg = love.graphics
  local screenHeight = lg.getHeight()
  
  local minimapX = 25
  local minimapY = screenHeight - 165
  local minimapWidth = 140
  local minimapHeight = 140
  
  -- Minimap background (darker)
  lg.setColor(0.05, 0.05, 0.1, 0.9)
  lg.rectangle("fill", minimapX, minimapY, minimapWidth, minimapHeight, 6)
  
  -- Minimap border
  lg.setColor(0.545, 0.271, 0.075, 1)
  lg.setLineWidth(2)
  lg.rectangle("line", minimapX, minimapY, minimapWidth, minimapHeight, 6)
  lg.setLineWidth(1)
  
  -- Scale for minimap
  local scaleX = minimapWidth / self.worldWidth
  local scaleY = minimapHeight / self.worldHeight
  
  -- Draw world boundary outline
  lg.setColor(0.3, 0.3, 0.4, 0.5)
  lg.rectangle("line", minimapX, minimapY, minimapWidth, minimapHeight)
  
  -- Draw den location (home icon)
  local denX = minimapX + 50 * scaleX -- Approximate den location
  local denY = minimapY + 50 * scaleY
  self.homeIcon:setPosition(denX, denY)
  self.homeIcon:draw()
  
  -- Draw enemies (if chasing or nearby)
  local playerCenterX = self.player.x + self.player.width / 2
  local playerCenterY = self.player.y + self.player.height / 2
  local visionRadius = 300 -- Show enemies within this radius
  
  local enemyList = self.aiSystem:getAllEnemies()
  for _, enemy in ipairs(enemyList) do
    local ex = enemy.x + (enemy.width or 32) / 2
    local ey = enemy.y + (enemy.height or 32) / 2
    local dist = math.sqrt((ex - playerCenterX)^2 + (ey - playerCenterY)^2)
    
    if dist < visionRadius or enemy.state == "chase" then
      local mapX = minimapX + ex * scaleX
      local mapY = minimapY + ey * scaleY
      
      if enemy.state == "chase" then
        lg.setColor(1, 0.3, 0.3, 0.9) -- Red for chasing
        lg.circle("fill", mapX, mapY, 4)
      else
        lg.setColor(1, 0.7, 0.3, 0.6) -- Orange for nearby
        lg.circle("fill", mapX, mapY, 3)
      end
    end
  end
  
  -- Draw player (always on top)
  local playerMapX = minimapX + playerCenterX * scaleX
  local playerMapY = minimapY + playerCenterY * scaleY
  lg.setColor(0.565, 0.933, 0.565, 1) -- Soft green
  lg.circle("fill", playerMapX, playerMapY, 5)
  lg.setColor(1, 1, 1)
  lg.circle("line", playerMapX, playerMapY, 5)
  
  -- Minimap label
  lg.setColor(0.961, 0.871, 0.702, 0.8)
  lg.print("Map", minimapX + 5, minimapY + minimapHeight + 5, 0, 0.9)
end

function GameScene:keypressed(key)
  -- Pass to settings menu first if active
  if self.settingsMenu:isActive() then
    return self.settingsMenu:keypressed(key)
  end
  
  -- Pass to pause menu if active
  if self.pauseMenu:isActive() then
    return self.pauseMenu:keypressed(key)
  end
  
  -- Toggle pause menu
  if key == "escape" then
    self.pauseMenu:toggle()
    return
  end
  
  -- Game controls (only when not paused)
  if key == "lshift" or key == "rshift" then
    self.player:dash()
  elseif key == "e" then
    -- Hide functionality (not fully implemented yet)
    self.player:hide()
    self.messageText = "Hiding... (not fully functional yet)"
    self.messageTimer = 1.5
  end
end

function GameScene:keyreleased(key)
  if key == "e" then
    self.player:unhide()
  end
end

function GameScene:mousepressed(x, y, button)
  if self.settingsMenu:isActive() then
    return self.settingsMenu:mousepressed(x, y, button)
  end
  
  if self.pauseMenu:isActive() then
    return self.pauseMenu:mousepressed(x, y, button)
  end
end

function GameScene:mousereleased(x, y, button)
  if self.settingsMenu:isActive() then
    return self.settingsMenu:mousereleased(x, y, button)
  end
  
  if self.pauseMenu:isActive() then
    return self.pauseMenu:mousereleased(x, y, button)
  end
end

function GameScene:gamepadpressed(joystick, button)
  if self.settingsMenu:isActive() then
    return self.settingsMenu:gamepadpressed(joystick, button)
  end
  
  if self.pauseMenu:isActive() then
    return self.pauseMenu:gamepadpressed(joystick, button)
  end
  
  -- Toggle pause with Start button
  if button == "start" then
    self.pauseMenu:toggle()
    return true
  end
  
  -- Dash with X button (or B on some controllers)
  if button == "x" or button == "b" then
    self.player:dash()
    return true
  end
  
  return false
end

return GameScene
