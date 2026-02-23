-- Example: Creating and using party members

local Character = require("src.entities.Character")
local ClassData = require("src.data.ClassData")

-- Create a party of 4 characters
local function createDefaultParty()
  local party = {}
  
  -- Front-line tank
  party[1] = Character:new("Reyes", "Marine", 1)
  
  -- Hacker/utility
  party[2] = Character:new("Nova", "Hacker", 1)
  
  -- Healer
  party[3] = Character:new("Cruz", "Medic", 1)
  
  -- Support/engineer
  party[4] = Character:new("Zeke", "Engineer", 1)
  
  return party
end

-- Example: Combat damage calculation
local function exampleCombatRound(party)
  -- Roll initiative for all party members
  for i, char in ipairs(party) do
    char:rollInitiative()
  end
  
  -- Simulate taking damage
  local marine = party[1]
  local damage = marine:takeDamage(25)
  print(string.format("%s took %d damage! HP: %d/%d", 
    marine.name, damage, marine:getHP(), marine:getMaxHP()))
  
  -- Healer responds
  local medic = party[3]
  if medic:spendEP(10) then
    local healing = marine:heal(15)
    print(string.format("%s healed %s for %d HP", 
      medic.name, marine.name, healing))
  end
end

-- Example: HUD integration
local function updateHUD(party)
  local hudDisplayData = {}
  
  for i, char in ipairs(party) do
    hudDisplayData[i] = char:toHUDData()
    
    -- The HUD data contains:
    -- name, class, level, hp, maxHP, hpPercent, 
    -- ep, maxEP, epPercent, isAlive, stats, statusEffects
  end
  
  return hudDisplayData
end

-- Example: Character progression
local function grantCombatReward(party, xpAmount)
  for i, char in ipairs(party) do
    if char:isAliveCheck() then
      local leveledUp = char:addExperience(xpAmount)
      if leveledUp then
        print(string.format("%s leveled up to level %d!", 
          char.name, char.level))
      end
    end
  end
end

return {
  createDefaultParty = createDefaultParty,
  exampleCombatRound = exampleCombatRound,
  updateHUD = updateHUD,
  grantCombatReward = grantCombatReward
}
