-- src/entities/character/Progression.lua
-- Level-up and experience management for characters

local Progression = {}

-- ─── Experience Calculations ────────────────────────────────────────────────

function Progression.calculateExpToNext(level)
  -- Simple exponential curve: 100 * 1.5^(level-1)
  return math.floor(100 * math.pow(1.5, level - 1))
end

function Progression.addExperience(character, amount)
  if not character.isAlive then return false end
  
  character.experience = character.experience + amount
  local leveledUp = false
  
  while character.experience >= character.experienceToNext do
    leveledUp = Progression.levelUp(character) or leveledUp
  end
  
  return leveledUp
end

function Progression.levelUp(character)
  character.level = character.level + 1
  character.experience = character.experience - character.experienceToNext
  character.experienceToNext = Progression.calculateExpToNext(character.level)
  
  -- Increase max HP and EP
  character.maxHP = character.maxHP + character.classData.hpPerLevel
  character.maxEP = character.maxEP + character.classData.epPerLevel
  
  -- Heal to full on level up
  character.currentHP = character.maxHP
  character.currentEP = character.maxEP
  
  -- Player will get 3 stat points to distribute manually (handled by UI)
  return true
end

return Progression
