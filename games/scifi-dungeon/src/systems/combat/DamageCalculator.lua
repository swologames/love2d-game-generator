-- src/systems/combat/DamageCalculator.lua
-- Damage calculation and combat math

local DamageCalculator = {}

-- ─── Constants ──────────────────────────────────────────────────────────────

local DEFEND_BONUS = 0.20  -- +20% block chance when defending
local DAMAGE_VARIANCE = 0.15  -- ±15% damage variance

-- ─── Damage Calculation ─────────────────────────────────────────────────────

--- Calculate damage from attacker to target
-- Formula: (Base + Modifier) × (1 - Armor Reduction) ± 15% variance
function DamageCalculator.calculate(attacker, target)
  -- Base damage
  local baseDamage = 10  -- Default base damage
  local attackerMod = 0
  local targetDefense = 0
  
  -- Get attacker stats
  if attacker.getAttack then
    -- Enemy (has getAttack method)
    baseDamage = attacker:getAttack()
    attackerMod = 0
  else
    -- Character (has getStat method)
    local str = attacker:getStat("STR") or 0
    attackerMod = math.floor(str / 2)  -- STR contributes to physical damage
    baseDamage = 10  -- Weapon damage (will be from equipment in Phase 3)
  end
  
  -- Get target defense
  if target.getDefense then
    -- Enemy (has getDefense method)
    targetDefense = target:getDefense()
  else
    -- Character
    targetDefense = target:getStat("CON") or 0
  end
  
  -- Calculate armor reduction (cap at 75% reduction)
  local armorReduction = math.min(targetDefense / 100, 0.75)
  
  -- Apply defend bonus
  if target.isDefending then
    armorReduction = armorReduction + DEFEND_BONUS
    armorReduction = math.min(armorReduction, 0.90)  -- Cap at 90% reduction when defending
  end
  
  -- Base calculation
  local rawDamage = (baseDamage + attackerMod) * (1 - armorReduction)
  
  -- Apply variance ±15%
  local variance = 1 + (math.random() * 2 - 1) * DAMAGE_VARIANCE
  local finalDamage = math.floor(rawDamage * variance)
  
  -- Minimum 1 damage
  return math.max(1, finalDamage)
end

return DamageCalculator
