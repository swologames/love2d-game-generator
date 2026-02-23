-- src/systems/combat/TurnManager.lua
-- Turn order and initiative management

local TurnManager = {}
TurnManager.__index = TurnManager

-- ─── Factory ────────────────────────────────────────────────────────────────

function TurnManager:new()
  local instance = setmetatable({}, TurnManager)
  instance.turnQueue = {}
  instance.currentTurnIndex = 1
  instance.turnNumber = 1
  return instance
end

-- ─── Initiative ─────────────────────────────────────────────────────────────

--- Roll initiative for all combatants and build turn order
function TurnManager:rollInitiative(party, enemies, log)
  self.turnQueue = {}
  
  -- Roll for party members
  for _, character in ipairs(party) do
    if character:isAliveCheck() then
      local roll = character:rollInitiative()
      table.insert(self.turnQueue, {
        combatant = character,
        initiative = roll,
        isEnemy = false
      })
      if log then
        log:add(character.name .. " rolled initiative: " .. roll)
      end
    end
  end
  
  -- Roll for enemies
  for _, enemy in ipairs(enemies) do
    if not enemy:isDead() then
      local roll = enemy:rollInitiative()
      table.insert(self.turnQueue, {
        combatant = enemy,
        initiative = roll,
        isEnemy = true
      })
      if log then
        log:add(enemy.name .. " rolled initiative: " .. roll)
      end
    end
  end
  
  -- Sort by initiative (highest first)
  table.sort(self.turnQueue, function(a, b)
    return a.initiative > b.initiative
  end)
  
  self.currentTurnIndex = 1
  if log then
    log:add("--- Turn " .. self.turnNumber .. " begins ---")
  end
end

-- ─── Turn Management ────────────────────────────────────────────────────────

--- Get the current active combatant
function TurnManager:getCurrent()
  if #self.turnQueue == 0 then return nil end
  return self.turnQueue[self.currentTurnIndex]
end

--- Check if it's a player character's turn
function TurnManager:isPlayerTurn()
  local current = self:getCurrent()
  return current and not current.isEnemy
end

--- Advance to the next combatant's turn
function TurnManager:next(log)
  -- Skip dead combatants
  repeat
    self.currentTurnIndex = self.currentTurnIndex + 1
    
    -- End of round, start new round
    if self.currentTurnIndex > #self.turnQueue then
      self.currentTurnIndex = 1
      self.turnNumber = self.turnNumber + 1
      if log then
        log:add("--- Turn " .. self.turnNumber .. " begins ---")
      end
      
      -- Clear defend status at start of new turn round
      self:clearDefendStatus()
    end
    
    local current = self:getCurrent()
    if current and current.combatant:isDead() then
      -- Remove dead combatant from queue
      table.remove(self.turnQueue, self.currentTurnIndex)
      self.currentTurnIndex = self.currentTurnIndex - 1
    end
  until not current or not current.combatant:isDead()
end

--- Clear defend status for all combatants (called at start of round)
function TurnManager:clearDefendStatus()
  for _, entry in ipairs(self.turnQueue) do
    entry.combatant:setDefending(false)
  end
end

return TurnManager
