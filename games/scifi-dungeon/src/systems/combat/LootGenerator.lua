-- src/systems/combat/LootGenerator.lua
-- Loot generation from defeated enemies

local LootGenerator = {}

-- ─── Loot Generation ────────────────────────────────────────────────────────

--- Generate loot from defeated enemies
function LootGenerator.generate(enemies)
  local totalXP = 0
  local items = {}
  
  for _, enemy in ipairs(enemies) do
    totalXP = totalXP + enemy:getXPReward()
    
    -- Roll loot table
    local lootTable = enemy:getLootTable()
    for _, lootEntry in ipairs(lootTable) do
      local chance = lootEntry.chance or 0.5
      if math.random() < chance then
        table.insert(items, lootEntry.item)
      end
    end
  end
  
  return {
    xp = totalXP,
    items = items
  }
end

return LootGenerator
