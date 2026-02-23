-- src/systems/CombatSystem.lua
-- Turn-based combat system (Phase 2) - Pure logic orchestrator

local DamageCalculator = require("src.systems.combat.DamageCalculator")
local LootGenerator = require("src.systems.combat.LootGenerator")
local TurnManager = require("src.systems.combat.TurnManager")
local CombatLog = require("src.systems.combat.CombatLog")

local CombatSystem = {}
CombatSystem.__index = CombatSystem

-- ─── Constants ──────────────────────────────────────────────────────────────

local BASE_FLEE_CHANCE = 50

-- ─── Factory ────────────────────────────────────────────────────────────────

--- Create a new combat encounter
-- @param party table - Array of Character objects
-- @param enemies table - Array of Enemy objects
function CombatSystem:new(party, enemies)
  assert(party and #party > 0, "Party must have at least one character")
  assert(enemies and #enemies > 0, "Enemies must exist")
  
  local instance = setmetatable({}, CombatSystem)
  
  -- References to combatants (not copies)
  instance.party = party
  instance.enemies = enemies
  
  -- Combat state
  instance.state = "in_progress"  -- in_progress, victory, defeat, fled
  instance.turnManager = TurnManager:new()
  instance.log = CombatLog:new()
  
  -- Turn queue access (for compatibility)
  instance.turnQueue = instance.turnManager.turnQueue
  instance.currentTurnIndex = instance.turnManager.currentTurnIndex
  
  -- Loot (generated on victory)
  instance.loot = nil
  
  return instance
end

-- ─── Initiative ─────────────────────────────────────────────────────────────

--- Roll initiative for all combatants and build turn order
function CombatSystem:rollInitiative()
  self.turnManager:rollInitiative(self.party, self.enemies, self.log)
  -- Update references for compatibility
  self.turnQueue = self.turnManager.turnQueue
  self.currentTurnIndex = self.turnManager.currentTurnIndex
end

-- ─── Turn Management ────────────────────────────────────────────────────────

--- Get the current active combatant
function CombatSystem:getCurrentCombatant()
  return self.turnManager:getCurrent()
end

--- Check if it's a player character's turn
function CombatSystem:isPlayerTurn()
  return self.turnManager:isPlayerTurn()
end

--- Advance to the next combatant's turn
function CombatSystem:nextTurn()
  self.turnManager:next(self.log)
  -- Update references for compatibility
  self.currentTurnIndex = self.turnManager.currentTurnIndex
  
  -- Check combat end conditions after turn advance
  self:checkCombatEnd()
end

-- ─── Actions ────────────────────────────────────────────────────────────────

--- Execute a combat action
-- @param actionType string - "attack", "defend", "item", "flee"
-- @param target table - Target combatant (for attacks)
-- @param data table - Additional action data
-- @return boolean - Success status
function CombatSystem:executeAction(actionType, target, data)
  local current = self:getCurrentCombatant()
  if not current then return false end
  
  local actor = current.combatant
  
  if actionType == "attack" then
    return self:performAttack(actor, target, current.isEnemy)
  elseif actionType == "defend" then
    return self:performDefend(actor)
  elseif actionType == "flee" then
    return self:attemptFlee()
  elseif actionType == "item" then
    -- Placeholder for Phase 3
    self.log:add(actor.name .. " used an item (not implemented)")
    return true
  end
  
  return false
end

--- Perform an attack action
function CombatSystem:performAttack(attacker, target, isEnemyAttack)
  if not target or target:isDead() then
    self.log:add("Invalid target!")
    return false
  end
  
  local damage = self:calculateDamage(attacker, target)
  target:takeDamage(damage)
  
  local attackerName = attacker.name or "Unknown"
  local targetName = target.name or "Unknown"
  
  self.log:add(attackerName .. " attacks " .. targetName .. " for " .. damage .. " damage!")
  
  if target:isDead() then
    self.log:add(targetName .. " has been defeated!")
  end
  
  return true
end

--- Perform defend action
function CombatSystem:performDefend(actor)
  actor:setDefending(true)
  self.log:add(actor.name .. " takes a defensive stance!")
  return true
end

--- Attempt to flee from combat
function CombatSystem:attemptFlee()
  -- Calculate flee chance: 50 + (party avg Reflexes) - (enemy avg Speed)
  local partyReflex = 0
  local livingParty = 0
  for _, char in ipairs(self.party) do
    if char:isAliveCheck() then
      partyReflex = partyReflex + (char:getStat("REF") or 0)
      livingParty = livingParty + 1
    end
  end
  partyReflex = livingParty > 0 and (partyReflex / livingParty) or 0
  
  local enemySpeed = 0
  local livingEnemies = 0
  for _, enemy in ipairs(self.enemies) do
    if not enemy:isDead() then
      enemySpeed = enemySpeed + enemy:getSpeed()
      livingEnemies = livingEnemies + 1
    end
  end
  enemySpeed = livingEnemies > 0 and (enemySpeed / livingEnemies) or 0
  
  local fleeChance = BASE_FLEE_CHANCE + partyReflex - enemySpeed
  local roll = math.random(1, 100)
  
  self.log:add("Flee attempt: " .. roll .. " vs " .. math.floor(fleeChance))
  
  if roll <= fleeChance then
    self.state = "fled"
    self.log:add("The party successfully fled from combat!")
    return true
  else
    self.log:add("Failed to flee!")
    return false
  end
end

-- ─── Damage Calculation ─────────────────────────────────────────────────────

--- Calculate damage from attacker to target
function CombatSystem:calculateDamage(attacker, target)
  return DamageCalculator.calculate(attacker, target)
end

-- ─── Combat State ───────────────────────────────────────────────────────────

--- Check if combat should end
function CombatSystem:checkCombatEnd()
  -- Check if all enemies dead
  local enemiesAlive = false
  for _, enemy in ipairs(self.enemies) do
    if not enemy:isDead() then
      enemiesAlive = true
      break
    end
  end
  
  if not enemiesAlive then
    self.state = "victory"
    self.log:add("Victory! All enemies defeated!")
    self:generateLoot()
    return
  end
  
  -- Check if all party members dead
  local partyAlive = false
  for _, char in ipairs(self.party) do
    if char:isAliveCheck() then
      partyAlive = true
      break
    end
  end
  
  if not partyAlive then
    self.state = "defeat"
    self.log:add("Defeat! The party has been wiped out!")
    return
  end
end

--- Get current combat state
function CombatSystem:getCombatState()
  return self.state
end

-- ─── AI ─────────────────────────────────────────────────────────────────────

--- Execute AI turn for current enemy
function CombatSystem:executeEnemyTurn()
  local current = self:getCurrentCombatant()
  if not current or not current.isEnemy then return false end
  
  local enemy = current.combatant
  
  -- Simple Phase 2 AI: Attack weakest party member
  local target = self:getWeakestPartyMember()
  
  if target then
    return self:performAttack(enemy, target, true)
  end
  
  return false
end

--- Get weakest (lowest HP%) party member
function CombatSystem:getWeakestPartyMember()
  local weakest = nil
  local lowestHP = math.huge
  
  for _, char in ipairs(self.party) do
    if char:isAliveCheck() then
      local hpPercent = char:getHPPercent()
      if hpPercent < lowestHP then
        lowestHP = hpPercent
        weakest = char
      end
    end
  end
  
  return weakest
end

-- ─── Loot ───────────────────────────────────────────────────────────────────

--- Generate loot from defeated enemies
function CombatSystem:generateLoot()
  self.loot = LootGenerator.generate(self.enemies)
  return self.loot
end

--- Get generated loot
function CombatSystem:getLoot()
  return self.loot
end

-- ─── Combat Log ─────────────────────────────────────────────────────────────

function CombatSystem:addLog(message)
  self.log:add(message)
end

function CombatSystem:getLog()
  return self.log:getAll()
end

function CombatSystem:getRecentLog(count)
  return self.log:getRecent(count)
end

return CombatSystem
