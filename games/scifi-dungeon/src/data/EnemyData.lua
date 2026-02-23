-- src/data/EnemyData.lua
-- Enemy type definitions and factory for Phase 2 combat

local EnemyData = {}

-- ─── Enemy Templates ────────────────────────────────────────────────────────

--- Gang Raider - District 1 light melee/pistol enemy
-- Lightly augmented street thug, aggressive and fast but fragile
EnemyData.gang_raider = {
  id = "gang_raider",
  name = "Gang Raider",
  
  -- Stats
  hp = {min = 20, max = 30},  -- HP range for variety
  attack = 8,
  defense = 2,
  speed = 12,  -- For initiative rolls
  
  -- Combat behavior
  range = "melee",  -- Melee range (will close distance)
  ai_type = "aggressive",  -- Always attacks, prefers weak targets
  
  -- Rewards
  xp_reward = 15,
  
  -- Loot table (Phase 2: simple drops, Phase 3: expanded)
  loot_table = {
    {item = "medpack", chance = 0.3},  -- 30% chance for medpack
    {item = "credits", amount = {min = 10, max = 25}, chance = 0.8}  -- Credits range
  },
  
  -- Visual
  sprite = "gang_raider",  -- Placeholder for sprite system
  
  -- Description (for codex/UI)
  description = "Lightly augmented street thug armed with knife and pistol. Fast but fragile.",
  faction = "None",
  district = 1
}

--- Warden Scout - District 1-2 armored enforcer with shock baton
-- Armored enforcer, defensive and tactical
EnemyData.warden_scout = {
  id = "warden_scout",
  name = "Warden Scout",
  
  -- Stats (higher defense, moderate damage)
  hp = {min = 35, max = 50},
  attack = 12,
  defense = 8,  -- Significantly higher defense (armored)
  speed = 8,    -- Slower than raiders due to armor
  
  -- Combat behavior
  range = "melee",  -- Shock baton is melee range
  ai_type = "defensive",  -- Uses defend action, protects allies
  
  -- Rewards
  xp_reward = 25,
  
  -- Loot table
  loot_table = {
    {item = "medpack", chance = 0.4},
    {item = "stim_shot", chance = 0.25},  -- Energy restoration item
    {item = "credits", amount = {min = 20, max = 40}, chance = 0.9},
    {item = "shock_cell", chance = 0.15}  -- Crafting component
  },
  
  -- Visual
  sprite = "warden_scout",
  
  -- Description
  description = "Armored Warden enforcer with shock baton. Heavily armored and tactical.",
  faction = "Wardens",
  district_range = {1, 2}  -- Appears in both District 1 and 2
}

-- ─── Factory Function ───────────────────────────────────────────────────────

--- Create an Enemy instance from a template ID
-- @param enemyTypeId string - The enemy template ID (e.g., "gang_raider")
-- @param level number - Optional level for scaling (default: 1)
-- @return Enemy instance or nil if template not found
function EnemyData.createEnemy(enemyTypeId, level)
  local template = EnemyData[enemyTypeId]
  
  if not template then
    error("Unknown enemy type: " .. tostring(enemyTypeId))
    return nil
  end
  
  -- Lazy load Enemy class to avoid circular dependency
  local Enemy = require("src.entities.Enemy")
  
  return Enemy:new(template, level)
end

--- Get enemy template data without creating an instance
-- @param enemyTypeId string
-- @return table or nil
function EnemyData.getTemplate(enemyTypeId)
  return EnemyData[enemyTypeId]
end

--- Get all enemy type IDs
-- @return table - Array of enemy IDs
function EnemyData.getAllEnemyTypes()
  local types = {}
  for key, value in pairs(EnemyData) do
    if type(value) == "table" and value.id then
      table.insert(types, value.id)
    end
  end
  return types
end

--- Get enemies by district
-- @param district number
-- @return table - Array of enemy templates
function EnemyData.getEnemiesByDistrict(district)
  local enemies = {}
  
  for key, value in pairs(EnemyData) do
    if type(value) == "table" and value.id then
      -- Check if enemy appears in this district
      if value.district == district then
        table.insert(enemies, value)
      elseif value.district_range then
        if district >= value.district_range[1] and district <= value.district_range[2] then
          table.insert(enemies, value)
        end
      end
    end
  end
  
  return enemies
end

--- Get enemies by faction
-- @param faction string
-- @return table - Array of enemy templates
function EnemyData.getEnemiesByFaction(faction)
  local enemies = {}
  
  for key, value in pairs(EnemyData) do
    if type(value) == "table" and value.id and value.faction == faction then
      table.insert(enemies, value)
    end
  end
  
  return enemies
end

-- ─── Encounter Generation Helpers (Phase 2 basic, Phase 3 expanded) ────────

--- Generate a random enemy encounter for a district
-- @param district number - District level (1-5)
-- @param difficulty string - "easy", "medium", "hard" (Phase 3)
-- @return table - Array of enemy type IDs
function EnemyData.generateEncounter(district, difficulty)
  difficulty = difficulty or "medium"
  
  local availableEnemies = EnemyData.getEnemiesByDistrict(district)
  
  if #availableEnemies == 0 then
    return {}
  end
  
  -- Phase 2: Simple random selection
  -- Phase 3: Will use difficulty scaling and composition rules
  local encounter = {}
  local encounterSize = math.random(1, 3)  -- 1-3 enemies per encounter
  
  for i = 1, encounterSize do
    local randomEnemy = availableEnemies[math.random(1, #availableEnemies)]
    table.insert(encounter, randomEnemy.id)
  end
  
  return encounter
end

--- Create enemy group from encounter data
-- @param encounterData table - Array of enemy type IDs
-- @param level number - Optional level scaling
-- @return table - Array of Enemy instances
function EnemyData.createEnemyGroup(encounterData, level)
  local group = {}
  
  for _, enemyTypeId in ipairs(encounterData) do
    local enemy = EnemyData.createEnemy(enemyTypeId, level)
    if enemy then
      table.insert(group, enemy)
    end
  end
  
  return group
end

return EnemyData
