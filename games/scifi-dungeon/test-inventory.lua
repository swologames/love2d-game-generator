-- test-inventory.lua
-- Quick test for inventory system integration
-- Run: lua test-inventory.lua

-- Load modules
local ItemData = require("src.data.ItemData")
local InventorySystem = require("src.systems.InventorySystem")
local Character = require("src.entities.Character")

-- Create test party
local party = {
  Character:new("Reaper", "Marine", 3),
  Character:new("Ghost", "Hacker", 3),
  Character:new("Doc", "Medic", 3),
  Character:new("Psi", "Psionic", 3)
}

-- Create inventory system
local inventory = InventorySystem:new(24)

-- Add some test items
print("=== Adding Items to Inventory ===")
local rifle = ItemData.createItem("assault_rifle")
local armor = ItemData.createItem("combat_armor")
local medpack1 = ItemData.createItem("medpack")
local medpack2 = ItemData.createItem("medpack")
local stim = ItemData.createItem("stim_shot")

local success, slot = inventory:addItem(rifle)
print(string.format("Added %s: %s (slot %s)", rifle.name, success, slot or "N/A"))

success, slot = inventory:addItem(armor)
print(string.format("Added %s: %s (slot %s)", armor.name, success, slot or "N/A"))

success, slot = inventory:addItem(medpack1)
print(string.format("Added %s: %s (slot %s)", medpack1.name, success, slot or "N/A"))

success, slot = inventory:addItem(medpack2)
print(string.format("Added %s (stacked): %s (slot %s)", medpack2.name, success, slot or "N/A"))

success, slot = inventory:addItem(stim)
print(string.format("Added %s: %s (slot %s)", stim.name, success, slot or "N/A"))

-- Check inventory status
print("\n=== Inventory Status ===")
print(string.format("Used slots: %d / %d", inventory:getUsedSlots(), inventory.maxSlots))
print(string.format("Free slots: %d", inventory:getFreeSlots()))

-- Check weight
print("\n=== Weight Status ===")
local weightStatus = inventory:getWeightStatus(party)
print(string.format("Current weight: %.1f kg", weightStatus.current))
print(string.format("Max weight: %.1f kg", weightStatus.max))
print(string.format("Status: %s (%.1f%%)", weightStatus.status, weightStatus.percent))

-- Equip items
print("\n=== Equipping Items ===")
local char = party[1]
print(string.format("Character: %s (%s)", char.name, char.className))

-- Remove rifle from inventory first
local rifleFromInv = inventory:removeItem(1)
success, msg = inventory:equipItem(rifleFromInv, char, "main_weapon")
print(string.format("Equip %s: %s", rifleFromInv.name, success and "SUCCESS" or msg))

-- Remove armor from inventory
local armorFromInv = inventory:removeItem(2)
success, msg = inventory:equipItem(armorFromInv, char, "torso")
print(string.format("Equip %s: %s", armorFromInv.name, success and "SUCCESS" or msg))

-- Check character equipment
print("\n=== Character Equipment ===")
for slot, item in pairs(char.equipment) do
  if item then
    print(string.format("  %s: %s", slot, item.name))
  end
end

-- Unequip item
print("\n=== Unequipping Item ===")
success, item = inventory:unequipItem(char, "main_weapon")
print(string.format("Unequip weapon: %s", success and "SUCCESS" or item))
if success then
  print(string.format("  Returned to inventory: %s", item.name))
end

-- Final inventory status
print("\n=== Final Inventory Status ===")
print(string.format("Used slots: %d / %d", inventory:getUsedSlots(), inventory.maxSlots))
local items = inventory:getAllItems()
for _, itemData in ipairs(items) do
  local qty = itemData.item.quantity and (" x" .. itemData.item.quantity) or ""
  print(string.format("  Slot %d: %s%s", itemData.slot, itemData.item.name, qty))
end

print("\n=== Test Complete ===")
