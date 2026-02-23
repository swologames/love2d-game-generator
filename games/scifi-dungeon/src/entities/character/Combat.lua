-- src/entities/character/Combat.lua
-- Combat-related methods for characters

local Combat = {}

-- ─── Initiative ─────────────────────────────────────────────────────────────

function Combat.rollInitiative(character)
  local reflexBonus = character:getStat("REF") * 5
  -- Use love.math.random if available (better RNG), otherwise use math.random
  local randomFunc = (_G.love and _G.love.math and _G.love.math.random) or math.random
  character.initiative = randomFunc(1, 100) + reflexBonus
  return character.initiative
end

-- ─── Defense State ──────────────────────────────────────────────────────────

function Combat.setDefending(character, defending)
  character.isDefending = defending
end

-- ─── Placeholder Combat Actions ─────────────────────────────────────────────

-- These will be fully implemented when the combat system is integrated
function Combat.attack(character, target)
  -- Will be implemented in combat system
  return 0
end

function Combat.useAbility(character, abilityIndex, targets)
  -- Will be implemented in combat system
  return false
end

return Combat
