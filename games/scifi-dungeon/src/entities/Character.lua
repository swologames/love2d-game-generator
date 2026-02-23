-- src/entities/Character.lua
-- Party member character orchestrator (thin wrapper around sub-modules)

local ClassData = require("src.data.ClassData")
local Health = require("src.entities.character.Health")
local Stats = require("src.entities.character.Stats")
local Combat = require("src.entities.character.Combat")
local Progression = require("src.entities.character.Progression")

local Character = {}
Character.__index = Character

-- ─── Factory ─────────────────────────────────────────────────────────────────

function Character:new(name, className, level)
  -- Validate inputs
  assert(name and name ~= "", "Character name is required")
  assert(ClassData[className], "Invalid class name: " .. tostring(className))
  level = level or 1
  
  local classData = ClassData[className]
  local instance = setmetatable({}, Character)
  
  -- Basic info
  instance.name = name
  instance.class = className
  instance.className = classData.displayName
  instance.level = level
  instance.experience = 0
  instance.experienceToNext = Progression.calculateExpToNext(level)
  
  -- Stats (copy from class base stats)
  instance.stats = {}
  for statName, value in pairs(classData.baseStats) do
    instance.stats[statName] = value
  end
  
  -- Calculate max HP and EP based on level
  instance.maxHP = classData.baseHP + (level - 1) * classData.hpPerLevel
  instance.currentHP = instance.maxHP
  
  instance.maxEP = classData.baseEP + (level - 1) * classData.epPerLevel
  instance.currentEP = instance.maxEP
  
  -- Status flags
  instance.isAlive = true
  instance.isDefending = false
  
  -- Status effects (placeholder for Phase 1)
  instance.statusEffects = {}
  instance.buffs = {}
  instance.debuffs = {}
  
  -- Equipment slots (Phase 2: Full equipment system)
  instance.equipment = {
    head = nil,           -- Head armor
    torso = nil,          -- Torso armor
    hands = nil,          -- Hand armor
    feet = nil,           -- Feet armor
    main_weapon = nil,    -- Main weapon
    offhand = nil,        -- Offhand weapon/shield
    accessory1 = nil,     -- Accessory slot 1
    accessory2 = nil      -- Accessory slot 2
  }
  
  -- Abilities (placeholder for Phase 1)
  instance.abilities = {
    classData.uniqueAbility
  }
  
  -- Combat stats
  instance.initiative = 0
  instance.dodgeChance = 0
  
  -- Class reference for easy lookup
  instance.classData = classData
  
  return instance
end

-- ─── HP Management (delegated to Health module) ─────────────────────────────

function Character:getHP()
  return self.currentHP
end

function Character:getMaxHP()
  return self.maxHP
end

function Character:getHPPercent()
  return self.currentHP / self.maxHP
end

function Character:takeDamage(amount)
  return Health.takeDamage(self, amount)
end

function Character:heal(amount)
  return Health.heal(self, amount)
end

function Character:revive(hpPercent)
  Health.revive(self, hpPercent)
end

-- ─── EP Management (delegated to Health module) ─────────────────────────────

function Character:getEP()
  return self.currentEP
end

function Character:getMaxEP()
  return self.maxEP
end

function Character:getEPPercent()
  return self.currentEP / self.maxEP
end

function Character:spendEP(amount)
  return Health.spendEP(self, amount)
end

function Character:restoreEP(amount)
  Health.restoreEP(self, amount)
end

-- ─── Status Checks ──────────────────────────────────────────────────────────

function Character:isAliveCheck()
  return self.isAlive
end

function Character:isDead()
  return not self.isAlive
end

-- ─── Stat Management (delegated to Stats module) ────────────────────────────

function Character:getStat(statName)
  return Stats.getStat(self, statName)
end

function Character:getAllStats()
  return Stats.getAllStats(self)
end

-- ─── Combat Methods (delegated to Combat module) ────────────────────────────

function Character:rollInitiative()
  return Combat.rollInitiative(self)
end

function Character:setDefending(defending)
  Combat.setDefending(self, defending)
end

function Character:isDefendingCheck()
  return self.isDefending
end

function Character:attack(target)
  return Combat.attack(self, target)
end

function Character:useAbility(abilityIndex, targets)
  return Combat.useAbility(self, abilityIndex, targets)
end

-- ─── Progression (delegated to Progression module) ──────────────────────────

function Character:addExperience(amount)
  return Progression.addExperience(self, amount)
end

-- ─── Equipment (Placeholder) ────────────────────────────────────────────────

function Character:equip(slot, item)
  self.equipment[slot] = item
  return true
end

function Character:unequip(slot)
  local item = self.equipment[slot]
  self.equipment[slot] = nil
  return item
end

function Character:getEquipment(slot)
  return self.equipment[slot]
end

-- ─── HUD Data Export ────────────────────────────────────────────────────────

function Character:toHUDData()
  return {
    name = self.name,
    class = self.className,
    level = self.level,
    hp = self.currentHP,
    maxHP = self.maxHP,
    hpPercent = self:getHPPercent(),
    ep = self.currentEP,
    maxEP = self.maxEP,
    epPercent = self:getEPPercent(),
    isAlive = self.isAlive,
    stats = self:getAllStats(),
    statusEffects = self.statusEffects
  }
end

-- ─── Debug / Display ────────────────────────────────────────────────────────

function Character:toString()
  return string.format(
    "%s (Lv%d %s) - HP: %d/%d, EP: %d/%d, Status: %s",
    self.name,
    self.level,
    self.className,
    self.currentHP,
    self.maxHP,
    self.currentEP,
    self.maxEP,
    self.isAlive and "Alive" or "Dead"
  )
end

return Character
