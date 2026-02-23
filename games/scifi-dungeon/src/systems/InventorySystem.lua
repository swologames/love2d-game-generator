-- src/systems/InventorySystem.lua
-- Manages shared party inventory and equipment

local InventorySystem = {}
InventorySystem.__index = InventorySystem

local DEFAULT_MAX_SLOTS = 24
local BASE_CARRY_WEIGHT = 10

local EQUIPMENT_SLOTS = {
  "head", "torso", "hands", "feet",
  "main_weapon", "offhand", "accessory1", "accessory2"
}

-- ─── Factory ────────────────────────────────────────────────────────────────

function InventorySystem:new(maxSlots)
  local instance = setmetatable({}, InventorySystem)
  instance.maxSlots = maxSlots or DEFAULT_MAX_SLOTS
  instance.slots = {}
  for i = 1, instance.maxSlots do instance.slots[i] = nil end
  return instance
end

-- ─── Item Management ────────────────────────────────────────────────────────

function InventorySystem:addItem(item)
  assert(item, "Cannot add nil item")
  
  -- Check for stackable items
  if item.stackable then
    local existingSlot = self:findItemById(item.id)
    if existingSlot then
      local existingItem = self.slots[existingSlot]
      if existingItem.quantity < existingItem.maxStack then
        existingItem.quantity = existingItem.quantity + (item.quantity or 1)
        return true, existingSlot
      end
    end
  end
  
  -- Find first empty slot
  local freeSlot = self:findFreeSlots(item.size or 1)
  if freeSlot then
    self.slots[freeSlot] = item
    return true, freeSlot
  end
  return false, nil
end

function InventorySystem:removeItem(slotIndex)
  assert(slotIndex and slotIndex >= 1 and slotIndex <= self.maxSlots, "Invalid slot")
  local item = self.slots[slotIndex]
  self.slots[slotIndex] = nil
  return item
end

function InventorySystem:getItem(slotIndex)
  if not slotIndex or slotIndex < 1 or slotIndex > self.maxSlots then return nil end
  return self.slots[slotIndex]
end

function InventorySystem:findItemById(itemId)
  for i = 1, self.maxSlots do
    if self.slots[i] and self.slots[i].id == itemId then return i end
  end
  return nil
end

function InventorySystem:findFreeSlots(size)
  for i = 1, self.maxSlots do
    if not self.slots[i] then return i end
  end
  return nil
end

function InventorySystem:getFreeSlots()
  local count = 0
  for i = 1, self.maxSlots do
    if not self.slots[i] then count = count + 1 end
  end
  return count
end

function InventorySystem:getUsedSlots()
  return self.maxSlots - self:getFreeSlots()
end

function InventorySystem:isFull()
  return self:getFreeSlots() == 0
end

-- ─── Weight Management ──────────────────────────────────────────────────────

function InventorySystem:getTotalWeight()
  local total = 0
  for i = 1, self.maxSlots do
    local item = self.slots[i]
    if item then
      total = total + ((item.weight or 0) * (item.quantity or 1))
    end
  end
  return total
end

function InventorySystem:calculateMaxWeight(party)
  if not party or #party == 0 then return BASE_CARRY_WEIGHT end
  local highestStr = 0
  for _, character in ipairs(party) do
    local str = character.stats and character.stats.strength or 0
    if str > highestStr then highestStr = str end
  end
  return BASE_CARRY_WEIGHT + (highestStr * 2)
end

function InventorySystem:isOverEncumbered(party)
  return self:getTotalWeight() > self:calculateMaxWeight(party)
end

function InventorySystem:getWeightStatus(party)
  local current = self:getTotalWeight()
  local max = self:calculateMaxWeight(party)
  local percent = (current / max) * 100
  
  local status = "Normal"
  if percent >= 100 then status = "Overencumbered"
  elseif percent >= 80 then status = "Heavy Load" end
  
  return {
    current = current, max = max, percent = percent,
    status = status, overEncumbered = percent >= 100
  }
end

-- ─── Equipment Management ───────────────────────────────────────────────────

function InventorySystem:equipItem(item, character, slotName)
  assert(item and character and slotName, "Missing required parameter")
  
  -- Validate slot
  local validSlot = false
  for _, slot in ipairs(EQUIPMENT_SLOTS) do
    if slot == slotName then validSlot = true; break end
  end
  if not validSlot then return false, "Invalid equipment slot" end
  
  -- Check slot compatibility
  if item.slot and item.slot ~= slotName then
    if not (item.slot == "accessory" and 
           (slotName == "accessory1" or slotName == "accessory2")) then
      return false, "Item cannot be equipped in " .. slotName
    end
  end
  
  -- Unequip existing item
  if character.equipment[slotName] then
    local success = self:addItem(character.equipment[slotName])
    if not success then return false, "Inventory full" end
  end
  
  character.equipment[slotName] = item
  return true
end

function InventorySystem:unequipItem(character, slotName)
  assert(character and slotName, "Missing required parameter")
  
  local item = character.equipment[slotName]
  if not item then return false, "No item equipped" end
  
  local success = self:addItem(item)
  if not success then return false, "Inventory full" end
  
  character.equipment[slotName] = nil
  return true, item
end

-- ─── Utility Functions ──────────────────────────────────────────────────────

function InventorySystem:getItemsByType(itemType)
  local items = {}
  for i = 1, self.maxSlots do
    if self.slots[i] and self.slots[i].type == itemType then
      table.insert(items, {slot = i, item = self.slots[i]})
    end
  end
  return items
end

function InventorySystem:countItem(itemId)
  local count = 0
  for i = 1, self.maxSlots do
    local item = self.slots[i]
    if item and item.id == itemId then
      count = count + (item.quantity or 1)
    end
  end
  return count
end

function InventorySystem:getAllItems()
  local items = {}
  for i = 1, self.maxSlots do
    if self.slots[i] then
      table.insert(items, {slot = i, item = self.slots[i]})
    end
  end
  return items
end

function InventorySystem:clear()
  for i = 1, self.maxSlots do self.slots[i] = nil end
end

return InventorySystem
