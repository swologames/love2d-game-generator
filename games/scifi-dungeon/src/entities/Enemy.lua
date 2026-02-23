-- src/entities/Enemy.lua
-- Enemy entity orchestrator for turn-based combat (Phase 2)

local Enemy = {}
Enemy.__index = Enemy

-- ─── Factory ─────────────────────────────────────────────────────────────────

--- Create a new enemy from an enemy template
-- @param enemyData table - The enemy template from EnemyData
-- @param level number - Optional level scaling (default: template base)
function Enemy:new(enemyData, level)
  assert(enemyData, "Enemy data is required")
  assert(enemyData.id, "Enemy data must have an id")
  
  level = level or 1
  
  local instance = setmetatable({}, Enemy)
  
  -- Basic info
  instance.id = enemyData.id
  instance.name = enemyData.name
  instance.level = level
  
  -- Roll HP from range for variety
  local hpMin = enemyData.hp.min or enemyData.hp
  local hpMax = enemyData.hp.max or enemyData.hp
  instance.maxHP = math.random(hpMin, hpMax)
  instance.currentHP = instance.maxHP
  
  -- Base stats
  instance.attack = enemyData.attack
  instance.defense = enemyData.defense
  instance.speed = enemyData.speed
  instance.range = enemyData.range or "melee"
  
  -- AI and behavior
  instance.aiType = enemyData.ai_type or "aggressive"
  
  -- Status
  instance.isAlive = true
  instance.isDefending = false
  instance.initiative = 0
  
  -- Status effects (placeholder for Phase 3)
  instance.statusEffects = {}
  
  -- Loot and rewards
  instance.xpReward = enemyData.xp_reward or 0
  instance.lootTable = enemyData.loot_table or {}
  
  -- Visual data
  instance.sprite = enemyData.sprite or "unknown"
  
  -- Store reference to full template data
  instance.templateData = enemyData
  
  return instance
end

-- ─── HP Management ──────────────────────────────────────────────────────────

function Enemy:getHP()
  return self.currentHP
end

function Enemy:getMaxHP()
  return self.maxHP
end

function Enemy:getHPPercent()
  if self.maxHP == 0 then return 0 end
  return self.currentHP / self.maxHP
end

--- Take damage with defense reduction formula (matches Character system)
-- @param amount number - Raw damage amount
-- @return number - Actual damage taken after defense
function Enemy:takeDamage(amount)
  if not self.isAlive then return 0 end
  
  amount = math.max(0, math.floor(amount))
  
  -- Apply defense modifier (same formula as Character system)
  local defense = self.defense
  local damageReduction = defense / (defense + 100)
  local actualDamage = math.floor(amount * (1 - damageReduction))
  
  -- Defending adds additional damage reduction
  if self.isDefending then
    actualDamage = math.floor(actualDamage * 0.8)  -- 20% reduction when defending
  end
  
  self.currentHP = math.max(0, self.currentHP - actualDamage)
  
  if self.currentHP <= 0 then
    self.currentHP = 0
    self.isAlive = false
  end
  
  return actualDamage
end

--- Heal HP (for enemies with regeneration or healing abilities)
-- @param amount number - Amount to heal
-- @return number - Actual HP restored
function Enemy:heal(amount)
  if not self.isAlive then return 0 end
  
  amount = math.max(0, math.floor(amount))
  local oldHP = self.currentHP
  self.currentHP = math.min(self.maxHP, self.currentHP + amount)
  
  return self.currentHP - oldHP
end

--- Check if enemy is dead
-- @return boolean
function Enemy:isDead()
  return not self.isAlive
end

-- ─── Combat ─────────────────────────────────────────────────────────────────

--- Roll initiative for turn order (1d100 + speed modifier)
-- @return number - Initiative value
function Enemy:rollInitiative()
  -- Same formula as combat system: 1d100 + speed
  self.initiative = math.random(1, 100) + self.speed
  return self.initiative
end

--- Get initiative value
-- @return number
function Enemy:getInitiative()
  return self.initiative
end

--- Set defending state (for AI defensive behavior)
-- @param defending boolean
function Enemy:setDefending(defending)
  self.isDefending = defending
end

--- Get base attack value
-- @return number
function Enemy:getAttack()
  return self.attack
end

--- Get defense value
-- @return number
function Enemy:getDefense()
  return self.defense
end

--- Get speed value
-- @return number
function Enemy:getSpeed()
  return self.speed
end

--- Get range type
-- @return string - "melee", "short", or "long"
function Enemy:getRange()
  return self.range
end

--- Get AI behavior type
-- @return string - "aggressive", "defensive", or "tactical"
function Enemy:getAIType()
  return self.aiType
end

-- ─── Display Data ───────────────────────────────────────────────────────────

--- Return data formatted for combat UI display
-- @return table - Display data
function Enemy:toDisplayData()
  return {
    id = self.id,
    name = self.name,
    level = self.level,
    currentHP = self.currentHP,
    maxHP = self.maxHP,
    hpPercent = self:getHPPercent(),
    isAlive = self.isAlive,
    isDefending = self.isDefending,
    initiative = self.initiative,
    sprite = self.sprite,
    attack = self.attack,
    defense = self.defense,
    speed = self.speed,
    range = self.range,
    aiType = self.aiType,
    statusEffects = self.statusEffects  -- Empty for Phase 2
  }
end

--- Get basic stats string for debugging
-- @return string
function Enemy:getStatsString()
  return string.format(
    "%s (Lv.%d) | HP: %d/%d | ATK: %d | DEF: %d | SPD: %d | Range: %s | AI: %s",
    self.name, self.level, self.currentHP, self.maxHP,
    self.attack, self.defense, self.speed, self.range, self.aiType
  )
end

-- ─── Loot ───────────────────────────────────────────────────────────────────

--- Get loot table for this enemy
-- @return table - Loot table with XP and item drops
function Enemy:getLootTable()
  return {
    xp = self.xpReward,
    items = self.lootTable
  }
end

--- Get XP reward for defeating this enemy
-- @return number
function Enemy:getXPReward()
  return self.xpReward
end

-- ─── Status Effects (Placeholder for Phase 3) ──────────────────────────────

--- Add a status effect (Phase 3 implementation)
function Enemy:addStatusEffect(effectType, duration)
  -- Placeholder for Phase 3
  table.insert(self.statusEffects, {
    type = effectType,
    duration = duration
  })
end

--- Remove a status effect
function Enemy:removeStatusEffect(effectType)
  -- Placeholder for Phase 3
  for i = #self.statusEffects, 1, -1 do
    if self.statusEffects[i].type == effectType then
      table.remove(self.statusEffects, i)
    end
  end
end

--- Update status effects (called each turn)
function Enemy:updateStatusEffects()
  -- Placeholder for Phase 3
  for i = #self.statusEffects, 1, -1 do
    local effect = self.statusEffects[i]
    effect.duration = effect.duration - 1
    if effect.duration <= 0 then
      table.remove(self.statusEffects, i)
    end
  end
end

return Enemy
