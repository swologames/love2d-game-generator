-- src/entities/character/Health.lua
-- HP and EP management for characters

local Health = {}

-- ─── HP Management ──────────────────────────────────────────────────────────

function Health.takeDamage(character, amount)
  if not character.isAlive then return 0 end
  
  amount = math.max(0, math.floor(amount))
  
  -- Apply defense modifier (placeholder - will be expanded with equipment)
  local defense = character:getStat("CON") * 0.5
  local damageReduction = defense / (defense + 100)
  local actualDamage = math.floor(amount * (1 - damageReduction))
  
  character.currentHP = math.max(0, character.currentHP - actualDamage)
  
  if character.currentHP <= 0 then
    character.currentHP = 0
    character.isAlive = false
  end
  
  return actualDamage
end

function Health.heal(character, amount)
  if not character.isAlive then return 0 end
  
  amount = math.max(0, math.floor(amount))
  local oldHP = character.currentHP
  character.currentHP = math.min(character.maxHP, character.currentHP + amount)
  
  return character.currentHP - oldHP
end

function Health.revive(character, hpPercent)
  hpPercent = hpPercent or 0.25
  
  character.isAlive = true
  character.currentHP = math.floor(character.maxHP * hpPercent)
  character.currentEP = math.floor(character.maxEP * 0.5)
end

-- ─── EP Management ──────────────────────────────────────────────────────────

function Health.spendEP(character, amount)
  if character.currentEP < amount then
    return false
  end
  
  character.currentEP = character.currentEP - amount
  return true
end

function Health.restoreEP(character, amount)
  amount = math.max(0, math.floor(amount))
  character.currentEP = math.min(character.maxEP, character.currentEP + amount)
end

return Health
