-- src/data/ItemData.lua
-- Central item database and factory for Phase 2

local ItemData = {}

-- ─── Item Database ──────────────────────────────────────────────────────────

ItemData.items = {
  -- Weapons
  assault_rifle = {
    id = "assault_rifle", name = "Assault Rifle", type = "weapon", slot = "main_weapon",
    stats = {damage = {15, 20}, range = "short", accuracy = 75, critChance = 10},
    weight = 3.5, rarity = "standard", size = 2,
    description = "Standard-issue automatic rifle. Reliable mid-range weapon.",
    sprite = "rifle_01", modSlots = 2
  },
  shock_baton = {
    id = "shock_baton", name = "Shock Baton", type = "weapon", slot = "main_weapon",
    stats = {damage = {8, 12}, range = "melee", accuracy = 85, stunChance = 25},
    weight = 1.2, rarity = "standard", size = 1,
    description = "Electrified riot control weapon. High accuracy, chance to stun.",
    sprite = "baton_01", modSlots = 1
  },
  plasma_pistol = {
    id = "plasma_pistol", name = "Plasma Pistol", type = "weapon", slot = "main_weapon",
    stats = {damage = {12, 16}, range = "short", accuracy = 70, burnChance = 15},
    weight = 1.8, rarity = "modified", size = 1,
    description = "Compact energy weapon with burn effect.",
    sprite = "plasma_pistol_01", modSlots = 1
  },
  
  -- Armor
  combat_armor = {
    id = "combat_armor", name = "Combat Armor", type = "armor", slot = "torso",
    stats = {defense = 8, resistance = {physical = 20, energy = 10}},
    weight = 5.0, rarity = "standard", size = 3,
    description = "Heavy plated armor. Solid protection against physical damage.",
    sprite = "armor_combat_01", modSlots = 2
  },
  nano_suit = {
    id = "nano_suit", name = "Nano-Weave Suit", type = "armor", slot = "torso",
    stats = {defense = 5, resistance = {physical = 10, energy = 20}, evasion = 10},
    weight = 2.5, rarity = "modified", size = 2,
    description = "Lightweight nano-fiber armor. Better vs energy, bonus evasion.",
    sprite = "armor_nano_01", modSlots = 3
  },
  tactical_vest = {
    id = "tactical_vest", name = "Tactical Vest", type = "armor", slot = "torso",
    stats = {defense = 4, resistance = {physical = 15, energy = 5}},
    weight = 2.0, rarity = "standard", size = 2,
    description = "Basic protective vest. Light and maneuverable.",
    sprite = "armor_vest_01", modSlots = 1
  },
  
  -- Consumables
  medpack = {
    id = "medpack", name = "MedPack", type = "consumable", slot = nil,
    stats = {healAmount = 40, usageTime = "combat"},
    weight = 0.5, rarity = "standard", size = 1,
    description = "Emergency medical kit. Restores 40 HP instantly.",
    sprite = "item_medpack_01", stackable = true, maxStack = 5
  },
  stim_shot = {
    id = "stim_shot", name = "Stim Shot", type = "consumable", slot = nil,
    stats = {epRestore = 30, duration = 0, usageTime = "combat"},
    weight = 0.3, rarity = "standard", size = 1,
    description = "Combat stimulant. Restores 30 EP immediately.",
    sprite = "item_stim_01", stackable = true, maxStack = 5
  },
  hack_module = {
    id = "hack_module", name = "Hack Module", type = "consumable", slot = nil,
    stats = {hackBonus = 25, duration = 1},
    weight = 0.2, rarity = "modified", size = 1,
    description = "Disposable hacking tool. +25 to next hack attempt.",
    sprite = "item_hack_01", stackable = true, maxStack = 3
  },
  
  -- Accessories
  shield_generator = {
    id = "shield_generator", name = "Shield Generator", type = "accessory", slot = "accessory",
    stats = {shieldHP = 20, regenRate = 5},
    weight = 1.5, rarity = "military", size = 2,
    description = "Personal energy shield. Absorbs damage, regenerates slowly.",
    sprite = "acc_shield_01", modSlots = 1
  },
  neural_amp = {
    id = "neural_amp", name = "Neural Amplifier", type = "accessory", slot = "accessory",
    stats = {willpower = 2, epRegen = 5},
    weight = 0.5, rarity = "modified", size = 1,
    description = "Cybernetic implant. Increases Willpower and EP regen.",
    sprite = "acc_neural_01", modSlots = 0
  }
}

-- ─── Factory Functions ──────────────────────────────────────────────────────

function ItemData.createItem(itemId)
  local template = ItemData.items[itemId]
  assert(template, "Unknown item ID: " .. tostring(itemId))
  
  local item = {}
  for key, value in pairs(template) do
    item[key] = type(value) == "table" and ItemData._deepCopy(value) or value
  end
  
  item.instanceId = ItemData._generateInstanceId()
  item.quantity = item.stackable and 1 or nil
  return item
end

function ItemData._deepCopy(original)
  local copy = {}
  for key, value in pairs(original) do
    copy[key] = type(value) == "table" and ItemData._deepCopy(value) or value
  end
  return copy
end

local _nextInstanceId = 1
function ItemData._generateInstanceId()
  local id = _nextInstanceId
  _nextInstanceId = _nextInstanceId + 1
  return "item_" .. id
end

function ItemData.getTemplate(itemId)
  return ItemData.items[itemId]
end

function ItemData.getItemsByType(itemType)
  local items = {}
  for id, item in pairs(ItemData.items) do
    if item.type == itemType then table.insert(items, id) end
  end
  return items
end

function ItemData.getItemsByRarity(rarity)
  local items = {}
  for id, item in pairs(ItemData.items) do
    if item.rarity == rarity then table.insert(items, id) end
  end
  return items
end

return ItemData
