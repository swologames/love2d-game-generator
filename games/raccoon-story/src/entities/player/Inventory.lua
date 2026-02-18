-- Player Inventory Sub-module
-- Manages the inventory table

local Inventory = {}

-- Add an item. Returns true on success, false if inventory is full.
function Inventory.add(self, item)
  if #self.inventory >= self.maxInventorySlots then
    return false
  end
  table.insert(self.inventory, item)
  return true
end

-- Remove item at 1-based index. Returns the item, or nil if index invalid.
function Inventory.remove(self, index)
  if index < 1 or index > #self.inventory then
    return nil
  end
  return table.remove(self.inventory, index)
end

return Inventory
