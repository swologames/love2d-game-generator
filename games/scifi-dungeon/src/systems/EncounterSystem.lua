-- EncounterSystem.lua
-- Random encounter generation for Phase 2 dungeon exploration

local EnemyData = require("src.data.EnemyData")

local EncounterSystem = {}

-- ─── Configuration ──────────────────────────────────────────────────────────

EncounterSystem.ENCOUNTER_CHANCE = 0.15  -- 15% per step
EncounterSystem.MIN_STEPS_BETWEEN = 5    -- Minimum steps before next encounter
EncounterSystem.SAFE_ROOM_CELL = 0       -- Safe rooms prevent encounters

-- ─── State ──────────────────────────────────────────────────────────────────

EncounterSystem.stepsSinceEncounter = 0
EncounterSystem.encountersThisLevel = 0
EncounterSystem.currentDistrict = 1

--- Initialize encounter system for a new level
function EncounterSystem:init(district)
  self.currentDistrict = district or 1
  self.stepsSinceEncounter = 0
  self.encountersThisLevel = 0
  print(string.format("[EncounterSystem] Initialized for District %d", self.currentDistrict))
end

--- Check if an encounter should trigger
-- @param cellType number - The cell type where player is standing
-- @return boolean - True if encounter triggered
function EncounterSystem:checkEncounter(cellType)
  -- Safe zones prevent encounters
  if self:isSafeZone(cellType) then
    return false
  end
  
  -- Minimum steps between encounters
  self.stepsSinceEncounter = self.stepsSinceEncounter + 1
  if self.stepsSinceEncounter < self.MIN_STEPS_BETWEEN then
    return false
  end
  
  -- Roll for encounter
  local roll = math.random()
  if roll < self.ENCOUNTER_CHANCE then
    self.stepsSinceEncounter = 0
    self.encountersThisLevel = self.encountersThisLevel + 1
    return true
  end
  
  return false
end

--- Check if a cell type is a safe zone
function EncounterSystem:isSafeZone(cellType)
  -- Cell type 5 = terminal/safe room
  return cellType == 5
end

--- Generate an encounter group for current district
-- @return table - Array of Enemy instances
function EncounterSystem:generateEncounter()
  local enemies = {}
  
  -- Get appropriate enemy types for this district
  local availableEnemies = EnemyData.getEnemiesByDistrict(self.currentDistrict)
  
  if #availableEnemies == 0 then
    print("[EncounterSystem] WARNING: No enemies available for district", self.currentDistrict)
    return enemies
  end
  
  -- Determine encounter size (1-3 enemies for Phase 2)
  local encounterSize = math.random(1, 3)
  
  -- Generate enemy group
  for i = 1, encounterSize do
    local template = availableEnemies[math.random(1, #availableEnemies)]
    local enemy = EnemyData.createEnemy(template.id, self.currentDistrict)
    table.insert(enemies, enemy)
  end
  
  print(string.format("[EncounterSystem] Generated encounter: %d enemies", #enemies))
  for _, enemy in ipairs(enemies) do
    print(string.format("  - %s (HP: %d, ATK: %d)", enemy.name, enemy.maxHP, enemy.attack))
  end
  
  return enemies
end

--- Reset encounter counter (used after combat)
function EncounterSystem:resetCounter()
  self.stepsSinceEncounter = 0
end

--- Get encounter statistics
function EncounterSystem:getStats()
  return {
    encountersThisLevel = self.encountersThisLevel,
    stepsSinceEncounter = self.stepsSinceEncounter,
    district = self.currentDistrict
  }
end

return EncounterSystem
