# Inventory System - Phase 2 Implementation

## Created Files

### 1. `/src/data/ItemData.lua` (146 lines)
Central item database with 11 items for Phase 2 testing:
- **Weapons**: assault_rifle, shock_baton, plasma_pistol
- **Armor**: combat_armor, nano_suit, tactical_vest
- **Consumables**: medpack, stim_shot, hack_module
- **Accessories**: shield_generator, neural_amp

**Key Functions:**
- `ItemData.createItem(itemId)` - Creates new item instance
- `ItemData.getTemplate(itemId)` - Get item template
- `ItemData.getItemsByType(type)` - Filter by type

### 2. `/src/systems/InventorySystem.lua` (215 lines)
Manages shared party inventory (24 slots) and equipment:

**Core API:**
- `InventorySystem:new(maxSlots)` - Create inventory
- `InventorySystem:addItem(item)` - Add to inventory
- `InventorySystem:removeItem(slot)` - Remove from slot
- `InventorySystem:getItem(slot)` - Get item at slot
- `InventorySystem:getTotalWeight()` - Calculate weight
- `InventorySystem:getWeightStatus(party)` - Get carry status
- `InventorySystem:equipItem(item, char, slot)` - Equip to character
- `InventorySystem:unequipItem(char, slot)` - Unequip from character

**Features:**
- Item stacking (consumables)
- Weight tracking (10 + highest STR × 2)
- Overencumbered detection
- Equipment validation

### 3. `/src/scenes/InventoryScreen.lua` (286 lines)
Full-screen UI overlay for inventory management:

**UI Layout:**
- Left panel: Party roster with equipment (4 characters)
- Right panel: 6×4 grid inventory (24 slots)
- Weight status display
- Item tooltip on selection

**Controls:**
- TAB/ESC: Close screen
- Arrow Keys: Navigate
- LEFT/RIGHT: Switch panels
- ENTER: Select/use item

**API:**
- `InventoryScreen:new()` - Create screen
- `InventoryScreen:enter(party, inventory)` - Activate
- `InventoryScreen:exit()` - Close
- `InventoryScreen:update(dt)` - Update logic
- `InventoryScreen:draw()` - Render UI
- `InventoryScreen:keypressed(key)` - Input handling

### 4. `/src/entities/Character.lua` (Updated)
Expanded equipment slots for Phase 2:
- head, torso, hands, feet
- main_weapon, offhand
- accessory1, accessory2

## Integration Example

```lua
-- In main.lua or DungeonScene
local ItemData = require("src.data.ItemData")
local InventorySystem = require("src.systems.InventorySystem")
local InventoryScreen = require("src.scenes.InventoryScreen")

-- Create inventory and screen
local inventory = InventorySystem:new(24)
local inventoryScreen = InventoryScreen:new()

-- Add starting items
inventory:addItem(ItemData.createItem("assault_rifle"))
inventory:addItem(ItemData.createItem("medpack"))

-- In love.keypressed
function love.keypressed(key)
  if key == "tab" then
    if inventoryScreen.active then
      inventoryScreen:exit()
    else
      inventoryScreen:enter(party, inventory)
    end
  elseif inventoryScreen.active then
    inventoryScreen:keypressed(key)
  end
end

-- In love.update
function love.update(dt)
  if inventoryScreen.active then
    inventoryScreen:update(dt)
  end
end

-- In love.draw
function love.draw()
  -- Draw game first
  -- ...
  
  -- Then inventory overlay
  if inventoryScreen.active then
    inventoryScreen:draw()
  end
end
```

## Testing

Run `lua test-inventory.lua` to test:
- Item creation and adding to inventory
- Item stacking (consumables)
- Weight calculation and encumbrance
- Equipment and unequipment
- Inventory queries

## Phase 3 Extensions

Planned additions:
- Multi-slot items (proper grid placement)
- Drag-and-drop interaction
- Item sprites/icons
- Weapon modding
- Crafting integration
- Stack splitting
- Item sorting/filtering

## Notes

- All equipment changes are instant (no animation yet)
- Items display as text (sprites in Phase 3)
- Simplified interactions (click-based in Phase 3)
- Weight limit formula: 10 + (highest STR) × 2
