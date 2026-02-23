-- src/data/ClassData.lua
-- Base stats and configuration for the 5 character classes

local ClassData = {
  -- Marine: Front-line tank (STR primary)
  Marine = {
    displayName = "Marine",
    role = "Tank / Front-line Combatant",
    primaryStat = "STR",
    armorType = "Heavy Exo-Armour",
    weaponFocus = {"Assault Rifle", "Shotgun", "Melee"},
    
    -- Base stats (at level 1)
    -- Characters start with 30 points distributed (min 2, max 10 per stat)
    baseStats = {
      STR = 9,   -- Strength: Physical damage, carry weight
      INT = 3,   -- Intelligence: Ability damage, hack success
      CON = 8,   -- Constitution: Max HP, resistance
      REF = 5,   -- Reflexes: Initiative, dodge
      WIL = 3,   -- Willpower: Psi damage, cooldown reduction
      PER = 2    -- Perception: Trap detection, loot find
    },
    
    -- HP/EP scaling
    baseHP = 50,
    hpPerLevel = 8,
    baseEP = 20,
    epPerLevel = 2,
    
    -- Unique ability (placeholder for Phase 1)
    uniqueAbility = {
      name = "Suppressive Fire",
      description = "Pins an enemy group, reducing their accuracy for 2 turns",
      cost = 15
    },
    
    passive = {
      name = "Bulwark",
      description = "15% chance to auto-block physical damage for adjacent party members"
    }
  },
  
  -- Hacker: Utility and crowd control (INT primary)
  Hacker = {
    displayName = "Hacker",
    role = "Utility / Crowd Control",
    primaryStat = "INT",
    armorType = "Light Nano-Suit",
    weaponFocus = {"Sidearms", "Shock Devices"},
    
    baseStats = {
      STR = 3,
      INT = 9,
      CON = 4,
      REF = 7,
      WIL = 5,
      PER = 2
    },
    
    baseHP = 30,
    hpPerLevel = 5,
    baseEP = 40,
    epPerLevel = 4,
    
    uniqueAbility = {
      name = "System Breach",
      description = "Disables robot/drone enemies for 1-2 turns; unlocks doors",
      cost = 20
    },
    
    passive = {
      name = "Exploit",
      description = "Crits apply a random debuff"
    }
  },
  
  -- Medic: Healer and buffer (WIL primary)
  Medic = {
    displayName = "Medic",
    role = "Healer / Buffer",
    primaryStat = "WIL",
    armorType = "Medium Bio-Weave Suit",
    weaponFocus = {"SMGs", "Injector Pistols"},
    
    baseStats = {
      STR = 3,
      INT = 6,
      CON = 6,
      REF = 4,
      WIL = 9,
      PER = 2
    },
    
    baseHP = 35,
    hpPerLevel = 6,
    baseEP = 35,
    epPerLevel = 3,
    
    uniqueAbility = {
      name = "Emergency Protocol",
      description = "Instantly revives a dead party member with 25% HP (once per 5 encounters)",
      cost = 30
    },
    
    passive = {
      name = "Triage",
      description = "Heal-over-time effects grant +10% bonus HP"
    }
  },
  
  -- Engineer: Crowd control and turret deployment (CON primary)
  Engineer = {
    displayName = "Engineer",
    role = "Crowd Control / Turret Deployment",
    primaryStat = "CON",
    armorType = "Medium Combat Chassis",
    weaponFocus = {"Grenade Launcher", "Flamethrower", "Wrench"},
    
    baseStats = {
      STR = 6,
      INT = 7,
      CON = 9,
      REF = 3,
      WIL = 3,
      PER = 2
    },
    
    baseHP = 45,
    hpPerLevel = 7,
    baseEP = 25,
    epPerLevel = 2,
    
    uniqueAbility = {
      name = "Deploy Turret",
      description = "Places a turret that attacks enemies for 3 rounds",
      cost = 25
    },
    
    passive = {
      name = "Salvage",
      description = "Recovers ammo/components from destroyed robots"
    }
  },
  
  -- Psionic: Damage amplifier and debuffer (WIL + INT primary)
  Psionic = {
    displayName = "Psionic",
    role = "Damage Amplifier / Debuffer",
    primaryStat = "WIL",
    secondaryStat = "INT",
    armorType = "Psi-Amplification Suit (light)",
    weaponFocus = {"Psi-Blades", "Psi-Cannons"},
    
    baseStats = {
      STR = 2,
      INT = 8,
      CON = 3,
      REF = 6,
      WIL = 9,
      PER = 2
    },
    
    baseHP = 25,
    hpPerLevel = 4,
    baseEP = 45,
    epPerLevel = 5,
    
    uniqueAbility = {
      name = "Mind Shatter",
      description = "Deals heavy Psi damage to a single target, chance to stun",
      cost = 35
    },
    
    passive = {
      name = "Resonance",
      description = "Every 3rd ability used in combat triggers a free low-damage Psi Pulse"
    }
  }
}

-- Validation function to ensure all classes follow the same structure
function ClassData.validate()
  local requiredFields = {"displayName", "role", "primaryStat", "baseStats", "baseHP", "hpPerLevel", "baseEP", "epPerLevel"}
  
  for className, classData in pairs(ClassData) do
    if type(classData) == "table" and classData.displayName then
      for _, field in ipairs(requiredFields) do
        if not classData[field] then
          error(string.format("Class %s is missing required field: %s", className, field))
        end
      end
    end
  end
end

-- Helper to get list of all valid class names
function ClassData.getClassNames()
  return {"Marine", "Hacker", "Medic", "Engineer", "Psionic"}
end

return ClassData
