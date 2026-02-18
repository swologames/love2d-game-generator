-- GameScene.lua
-- Thin orchestrator: wires all game sub-systems together.
-- All heavy logic lives in src/scenes/game/ sub-modules.

local Player         = require("src.entities.Player")
local AISystem       = require("src.systems.AISystem")
local ParticleSystem = require("src.systems.ParticleSystem")
local ScreenEffects  = require("src.systems.ScreenEffects")
local Assets         = require("src.utils.assets")
local PauseMenu      = require("src.ui.PauseMenu")
local SettingsMenu   = require("src.ui.SettingsMenu")
local Panel          = require("src.ui.Panel")
local Icon           = require("src.ui.Icon")

local Spawner          = require("src.scenes.game.Spawner")
local EnvSpawner       = require("src.scenes.game.EnvironmentSpawner")
local EnvRenderer      = require("src.scenes.game.EnvironmentRenderer")
local HUD              = require("src.scenes.game.HUD")
local HidingFeedback   = require("src.scenes.game.HidingFeedback")
local ChaseManager     = require("src.scenes.game.ChaseManager")
local CollisionHandler = require("src.scenes.game.CollisionHandler")
local CameraSystem     = require("src.scenes.game.CameraSystem")
local ParticleEffects  = require("src.scenes.game.ParticleEffects")

local GameScene = {}

-- ─── Lifecycle ───────────────────────────────────────────────────────────────

function GameScene:enter()
  print("Entering Game Scene")
  Assets:loadAll()

  self.worldWidth  = 3200
  self.worldHeight = 2400

  -- Player
  self.player = Player:new(400, 300)
  local idleF = Assets:getPlayerSprite("idle")
  local walkF = Assets:getPlayerSprite("walk")
  local dashF = Assets:getPlayerSprite("dash")
  if idleF and walkF and dashF then
    self.player:setSprites(idleF, walkF, dashF)
    print("[GameScene] Player sprites loaded successfully (idle, walk, dash)")
  else
    print("[GameScene] Warning: Player sprites not loaded properly")
  end

  -- Game state
  self.score          = 0
  self.itemsCollected = 0
  self.timeElapsed    = 0
  self.cameraX        = 0
  self.cameraY        = 0

  -- Environment, particles, trash, enemies
  self.environmentObjects = {}
  self:spawnEnvironment()
  self.particleSystem = ParticleSystem:new()
  self.screenEffects  = ScreenEffects:new()
  self.trashItems     = {}
  self:spawnTrash()
  self.aiSystem = AISystem:new()
  self:spawnEnemies()

  -- UI state
  self.messageText  = "Collect trash for your family!"
  self.messageTimer = 3
  self.messageAlpha = 1

  -- Caught / chase state
  self.justCaught          = false
  self.caughtCooldown      = 0
  self.nearbyBushes        = {}
  self.isPlayerBeingChased = false
  self.chaseEndTimer       = 0

  -- Footstep timer
  self.footstepTimer    = 0
  self.footstepInterval = 0.3

  -- Menus
  self.pauseMenu = PauseMenu:new()
  self.pauseMenu.onResume       = function() end
  self.pauseMenu.onSettings     = function() self.settingsMenu:show() end
  self.pauseMenu.onRestartNight = function() self:restartNight() end
  self.pauseMenu.onQuitToMenu   = function() self:quitToMenu() end

  self.settingsMenu = SettingsMenu:new()
  self.settingsMenu.onBack = function() self.settingsMenu:hide() end

  -- HUD icons
  self.moonIcon  = Icon:new("moon",  0, 0, 30)
  self.alertIcon = Icon:new("alert", 0, 0, 25, {1, 0.4, 0.4, 1})
  self.alertIcon:setPulse(true, 4, 0.3)
  self.dashIcon  = Icon:new("dash",  0, 0, 20, {0.565, 0.933, 0.565, 1})
  self.homeIcon  = Icon:new("home",  0, 0, 15, {1, 0.8, 0.2, 1})

  -- Inventory slot animations
  self.inventorySlotAnimations = {}
  for i = 1, self.player.maxInventorySlots do
    self.inventorySlotAnimations[i] = {scale = 1.0, targetScale = 1.0, pulse = 0}
  end

  -- HUD panels
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()
  self.topPanel     = Panel:new(0, 0, sw, 70, "translucent")
  self.sidePanel    = Panel:new(sw - 220, 70, 220, sh - 70, "translucent")
  self.minimapPanel = Panel:new(20, sh - 170, 150, 150, "translucent")
end

function GameScene:restartNight()
  print("[GameScene] Restarting night")
  self.pauseMenu:hide()
  self:enter()
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
  self.environmentObjects = nil
  if self.aiSystem then
    self.aiSystem:clear()
  end
  self.aiSystem = nil
end

-- Sub-module delegation wrappers
function GameScene:spawnTrash()       Spawner.spawnTrash(self)     end
function GameScene:spawnEnemies()     Spawner.spawnEnemies(self)   end
function GameScene:spawnEnvironment() EnvSpawner.spawn(self)       end

function GameScene:update(dt)
  if self.pauseMenu:isActive() then
    self.pauseMenu:update(dt)
    if self.settingsMenu:isActive() then self.settingsMenu:update(dt) end
    return
  end
  self.moonIcon:update(dt); self.alertIcon:update(dt)
  self.dashIcon:update(dt); self.homeIcon:update(dt)
  local inventoryCount = self.player:getInventoryCount()
  for i = 1, self.player.maxInventorySlots do
    local anim = self.inventorySlotAnimations[i]
    if i <= inventoryCount then
      anim.pulse = anim.pulse + dt * 3
      anim.targetScale = 1.0 + math.sin(anim.pulse) * 0.05
    else
      anim.targetScale = 1.0; anim.pulse = 0
    end
    anim.scale = anim.scale + (anim.targetScale - anim.scale) * 10 * dt
  end
  self.timeElapsed = self.timeElapsed + dt
  if self.messageTimer > 0 then
    self.messageTimer = self.messageTimer - dt
    if     self.messageTimer > 2.7 then self.messageAlpha = (3.0 - self.messageTimer) / 0.3
    elseif self.messageTimer < 1.0 then self.messageAlpha = self.messageTimer
    else                                self.messageAlpha = 1.0 end
  end
  if self.caughtCooldown > 0 then self.caughtCooldown = self.caughtCooldown - dt end
  ParticleEffects.update(self, dt)
  self.player:update(dt)
  self.player.x = math.max(0, math.min(self.player.x, self.worldWidth  - self.player.width))
  self.player.y = math.max(0, math.min(self.player.y, self.worldHeight - self.player.height))
  self.particleSystem:update(dt)
  local dangerLevel = ChaseManager.calcDangerLevel(self)
  self.screenEffects:setVignetteDanger(dangerLevel)
  ChaseManager.emitDetectionAlerts(self)
  HidingFeedback.updateNearbyBushes(self)
  ChaseManager.updateChaseState(self, dt)
  local aiResult = self.aiSystem:update(dt, self.player, self.trashItems)
  if aiResult and aiResult.caught and self.caughtCooldown <= 0 then
    CollisionHandler.playerCaught(self, aiResult.enemyType, aiResult.dropCount)
  end
  for _, trash in ipairs(self.trashItems) do
    trash:update(dt)
    if trash:checkCollision(self.player) then
      CollisionHandler.collectTrash(self, trash)
    end
  end
  CollisionHandler.checkEnvironmentCollisions(self)
  CameraSystem.update(self, dt)
end

function GameScene:draw()
  local lg = love.graphics
  local shakeX, shakeY = self.screenEffects:getShakeOffset()
  lg.push()
  lg.translate(-self.cameraX + shakeX, -self.cameraY + shakeY)
  lg.clear(0.1, 0.2, 0.15)
  lg.setColor(0.3, 0.3, 0.3, 0.3)
  lg.rectangle("fill", 0, 0, self.worldWidth, self.worldHeight)
  lg.setColor(0.2, 0.3, 0.2, 0.5)
  for x = 0, self.worldWidth,  64 do lg.line(x, 0, x, self.worldHeight) end
  for y = 0, self.worldHeight, 64 do lg.line(0, y, self.worldWidth,  y) end
  EnvRenderer.draw(self)
  for _, trash in ipairs(self.trashItems) do trash:draw() end
  self.aiSystem:draw()
  self.player:draw()
  HidingFeedback.draw(self)
  self.particleSystem:draw()
  lg.pop()
  HUD.draw(self)
  if self.pauseMenu   and self.pauseMenu:isActive()   then self.pauseMenu:draw()   end
  if self.settingsMenu and self.settingsMenu:isActive() then self.settingsMenu:draw() end
end

function GameScene:keypressed(key)
  if self.settingsMenu:isActive() then return self.settingsMenu:keypressed(key) end
  if self.pauseMenu:isActive()    then return self.pauseMenu:keypressed(key) end
  if key == "escape" then self.pauseMenu:toggle(); return end
  if key == "lshift" or key == "rshift" then
    self.player:dash()
  elseif key == "e" then
    if self.player.isHiding then
      self.player:exitHide()
      self.messageText = "Left hiding spot"; self.messageTimer = 1.5
    elseif #self.nearbyBushes > 0 then
      local closest, closestDist = nil, math.huge
      local pcx = self.player.x + self.player.width / 2
      local pcy = self.player.y + self.player.height / 2
      for _, bush in ipairs(self.nearbyBushes) do
        local dx = (bush.x + bush.width / 2) - pcx
        local dy = (bush.y + bush.height / 2) - pcy
        local d  = math.sqrt(dx * dx + dy * dy)
        if d < closestDist then closestDist = d; closest = bush end
      end
      if closest and self.player:hide(closest) then
        self.messageText = "Hiding... (Press E to exit)"; self.messageTimer = 2.5
      end
    else
      self.messageText = "No hiding spot nearby"; self.messageTimer = 1.5
    end
  end
end

function GameScene:keyreleased(key)
  if key == "e" then self.player:unhide() end
end

function GameScene:mousepressed(x, y, button)
  if self.settingsMenu:isActive() then return self.settingsMenu:mousepressed(x, y, button) end
  if self.pauseMenu:isActive()    then return self.pauseMenu:mousepressed(x, y, button) end
end

function GameScene:mousereleased(x, y, button)
  if self.settingsMenu:isActive() then return self.settingsMenu:mousereleased(x, y, button) end
  if self.pauseMenu:isActive()    then return self.pauseMenu:mousereleased(x, y, button) end
end

function GameScene:gamepadpressed(joystick, button)
  if self.settingsMenu:isActive() then return self.settingsMenu:gamepadpressed(joystick, button) end
  if self.pauseMenu:isActive()    then return self.pauseMenu:gamepadpressed(joystick, button) end
  if button == "start" then self.pauseMenu:toggle(); return true end
  if button == "x" or button == "b" then self.player:dash(); return true end
  return false
end

return GameScene
