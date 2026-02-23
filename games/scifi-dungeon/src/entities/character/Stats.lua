-- src/entities/character/Stats.lua
-- Stat calculations and management for characters

local Stats = {}

-- ─── Stat Access ────────────────────────────────────────────────────────────

function Stats.getStat(character, statName)
  local baseStat = character.stats[statName] or 0
  
  -- Placeholder: Equipment modifiers would be added here in future phases
  local equipmentBonus = 0
  
  -- Placeholder: Buff/debuff modifiers would be added here
  local statusBonus = 0
  
  return baseStat + equipmentBonus + statusBonus
end

function Stats.getAllStats(character)
  return {
    STR = Stats.getStat(character, "STR"),
    INT = Stats.getStat(character, "INT"),
    CON = Stats.getStat(character, "CON"),
    REF = Stats.getStat(character, "REF"),
    WIL = Stats.getStat(character, "WIL"),
    PER = Stats.getStat(character, "PER")
  }
end

return Stats
