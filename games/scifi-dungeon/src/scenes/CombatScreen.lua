-- src/scenes/CombatScreen.lua
-- Combat UI overlay for turn-based combat (Phase 2) - Thin orchestrator

local CombatSystem = require("src.systems.CombatSystem")
local CombatUI = require("src.scenes.combat.CombatUI")

local CombatScreen = {}
CombatScreen.__index = CombatScreen

-- ─── Factory ────────────────────────────────────────────────────────────────

function CombatScreen:new()
  local instance = setmetatable({}, CombatScreen)
  
  instance.combatSystem = nil
  instance.active = false
  
  -- UI state
  instance.selectedEnemyIndex = 1
  instance.waitingForTarget = false
  instance.pendingAction = nil
  
  -- Animation
  instance.damageNumbers = {}  -- Floating damage text
  instance.timer = 0
  
  -- Callbacks
  instance.onVictoryCallback = nil
  instance.onDefeatCallback = nil
  instance.onFleeCallback = nil
  
  return instance
end

-- ─── Scene Lifecycle ────────────────────────────────────────────────────────

--- Start combat
-- @param data table - {party, enemies, onVictory, onDefeat, onFlee}
function CombatScreen:enter(data)
  local party = data.party
  local enemies = data.enemies
  
  self.combatSystem = CombatSystem:new(party, enemies)
  self.combatSystem:rollInitiative()
  self.active = true
  self.selectedEnemyIndex = 1
  self.waitingForTarget = false
  self.pendingAction = nil
  self.damageNumbers = {}
  
  -- Store callbacks
  self.onVictoryCallback = data.onVictory
  self.onDefeatCallback = data.onDefeat
  self.onFleeCallback = data.onFlee
  
  -- Reset callback flags
  self.victoryCalled = false
  self.defeatCalled = false
  self.fleeCalled = false
  
  -- If first turn is enemy, execute automatically
  if not self.combatSystem:isPlayerTurn() then
    self:executeAITurn()
  end
end

function CombatScreen:exit()
  self.active = false
  self.combatSystem = nil
end

-- ─── Update ─────────────────────────────────────────────────────────────────

function CombatScreen:update(dt)
  if not self.active or not self.combatSystem then return end
  
  self.timer = self.timer + dt
  
  -- Update floating damage numbers
  for i = #self.damageNumbers, 1, -1 do
    local dmg = self.damageNumbers[i]
    dmg.lifetime = dmg.lifetime - dt
    dmg.y = dmg.y - 50 * dt  -- Float upward
    
    if dmg.lifetime <= 0 then
      table.remove(self.damageNumbers, i)
    end
  end
  
  -- Check combat state and invoke callbacks (only once per state change)
  local state = self.combatSystem:getCombatState()
  if state == "victory" and self.onVictoryCallback and not self.victoryCalled then
    self.victoryCalled = true
    local loot = self.combatSystem:getLoot()
    self.onVictoryCallback(loot)
  elseif state == "defeat" and self.onDefeatCallback and not self.defeatCalled then
    self.defeatCalled = true
    self.onDefeatCallback()
  elseif state == "fled" and self.onFleeCallback and not self.fleeCalled then
    self.fleeCalled = true
    self.onFleeCallback()
  end
end

-- ─── Input ──────────────────────────────────────────────────────────────────

function CombatScreen:keypressed(key)
  if not self.active or not self.combatSystem then return end
  
  local state = self.combatSystem:getCombatState()
  if state ~= "in_progress" then
    -- Combat ended, any key exits
    if key == "space" or key == "return" then
      self:exit()
    end
    return
  end
  
  -- Target selection mode
  if self.waitingForTarget then
    self:handleTargetSelection(key)
    return
  end
  
  -- Action selection (only on player turn)
  if self.combatSystem:isPlayerTurn() then
    self:handleActionSelection(key)
  end
end

--- Handle action menu input
function CombatScreen:handleActionSelection(key)
  local actions = CombatUI.getActions()
  
  for _, action in ipairs(actions) do
    if key == action.key then
      if action.action == "attack" then
        -- Enter target selection mode
        self.waitingForTarget = true
        self.pendingAction = "attack"
        self.selectedEnemyIndex = self:getFirstLivingEnemyIndex()
      elseif action.action == "defend" then
        self:executePlayerAction("defend", nil)
      elseif action.action == "flee" then
        self:executePlayerAction("flee", nil)
      elseif action.action == "item" then
        -- Placeholder for Phase 3
        self.combatSystem:addLog("Items not yet implemented")
      end
      return
    end
  end
end

--- Handle target selection input
function CombatScreen:handleTargetSelection(key)
  local enemies = self:getLivingEnemies()
  
  if key == "left" or key == "a" then
    -- Previous enemy
    self.selectedEnemyIndex = self.selectedEnemyIndex - 1
    if self.selectedEnemyIndex < 1 then
      self.selectedEnemyIndex = #enemies
    end
  elseif key == "right" or key == "d" then
    -- Next enemy
    self.selectedEnemyIndex = self.selectedEnemyIndex + 1
    if self.selectedEnemyIndex > #enemies then
      self.selectedEnemyIndex = 1
    end
  elseif key == "return" or key == "space" then
    -- Confirm target
    local target = enemies[self.selectedEnemyIndex]
    self:executePlayerAction(self.pendingAction, target)
    self.waitingForTarget = false
    self.pendingAction = nil
  elseif key == "escape" then
    -- Cancel target selection
    self.waitingForTarget = false
    self.pendingAction = nil
  end
end

-- ─── Action Execution ───────────────────────────────────────────────────────

--- Execute player action
function CombatScreen:executePlayerAction(actionType, target)
  local success = self.combatSystem:executeAction(actionType, target, nil)
  
  if success then
    -- Add damage number if attack
    if actionType == "attack" and target then
      self:addDamageNumber(target, "HIT")
    end
    
    -- Advance turn
    self.combatSystem:nextTurn()
    
    -- Execute AI turns until next player turn
    while not self.combatSystem:isPlayerTurn() and 
          self.combatSystem:getCombatState() == "in_progress" do
      self:executeAITurn()
    end
  end
end

--- Execute AI turn
function CombatScreen:executeAITurn()
  -- Small delay could be added here for visual clarity
  local success = self.combatSystem:executeEnemyTurn()
  
  if success then
    -- Add visual feedback
    local current = self.combatSystem:getCurrentCombatant()
    if current then
      self:addDamageNumber(nil, "AI")
    end
  end
  
  self.combatSystem:nextTurn()
end

-- ─── Rendering ──────────────────────────────────────────────────────────────

function CombatScreen:draw()
  if not self.active or not self.combatSystem then return end
  
  love.graphics.push()
  love.graphics.origin()
  
  -- Background
  love.graphics.setColor(0.05, 0.05, 0.1, 0.95)
  love.graphics.rectangle("fill", 0, 0, 1280, 720)
  
  -- Draw panels using CombatUI
  CombatUI.drawInitiativeStrip(self.combatSystem)
  CombatUI.drawEnemyPanel(self:getLivingEnemies(), self.selectedEnemyIndex, self.waitingForTarget)
  CombatUI.drawPartyPanel(self.combatSystem)
  CombatUI.drawActionMenu(self.combatSystem, self.waitingForTarget)
  CombatUI.drawCombatLog(self.combatSystem)
  
  -- Draw damage numbers
  CombatUI.drawDamageNumbers(self.damageNumbers)
  
  -- Draw combat end screen if applicable
  local state = self.combatSystem:getCombatState()
  if state ~= "in_progress" then
    CombatUI.drawCombatEnd(state, self.combatSystem:getLoot())
  end
  
  love.graphics.pop()
end

-- ─── Helpers ────────────────────────────────────────────────────────────────

function CombatScreen:getLivingEnemies()
  local living = {}
  for _, enemy in ipairs(self.combatSystem.enemies) do
    if not enemy:isDead() then
      table.insert(living, enemy)
    end
  end
  return living
end

function CombatScreen:getFirstLivingEnemyIndex()
  return 1  -- Simplified for Phase 2
end

function CombatScreen:addDamageNumber(target, text)
  -- Placeholder for visual feedback
  table.insert(self.damageNumbers, {
    text = text,
    x = 400,
    y = 300,
    lifetime = 1.0
  })
end

-- ─── Callbacks ──────────────────────────────────────────────────────────────

function CombatScreen:onVictory(callback)
  self.onVictoryCallback = callback
end

function CombatScreen:onDefeat(callback)
  self.onDefeatCallback = callback
end

function CombatScreen:onFlee(callback)
  self.onFleeCallback = callback
end

return CombatScreen
