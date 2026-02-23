-- src/scenes/InventoryScreen.lua
-- Full-screen inventory & party management overlay

local InventoryScreen = {}
InventoryScreen.__index = InventoryScreen

-- ─── Constants ──────────────────────────────────────────────────────────────

local SCREEN_WIDTH, SCREEN_HEIGHT = 1280, 720
local PANEL_MARGIN = 20
local LEFT_PANEL_WIDTH = 620
local RIGHT_PANEL_X = LEFT_PANEL_WIDTH + (PANEL_MARGIN * 2)
local RIGHT_PANEL_WIDTH = SCREEN_WIDTH - RIGHT_PANEL_X - PANEL_MARGIN

-- Colors (from HUD)
local COLOR_BG = {0.039, 0.055, 0.078, 0.95}
local COLOR_PANEL = {0.078, 0.109, 0.149, 1}
local COLOR_ACCENT = {0.000, 0.749, 1.000, 1}
local COLOR_TEXT = {0.878, 0.910, 0.941, 1}
local COLOR_TEXT_DIM = {0.5, 0.5, 0.5, 1}
local COLOR_WARNING = {1.000, 0.800, 0.000, 1}
local COLOR_DANGER = {1.000, 0.235, 0.235, 1}
local COLOR_SELECTED = {0.000, 0.749, 1.000, 0.3}

local GRID_COLS, GRID_ROWS = 6, 4
local SLOT_SIZE, SLOT_SPACING = 60, 8

local EQUIPMENT_SLOTS = {
  {name = "head", label = "Head", y = 0},
  {name = "torso", label = "Torso", y = 1},
  {name = "hands", label = "Hands", y = 2},
  {name = "feet", label = "Feet", y = 3},
  {name = "main_weapon", label = "Weapon", y = 4},
  {name = "offhand", label = "Offhand", y = 5},
  {name = "accessory1", label = "Acc 1", y = 6},
  {name = "accessory2", label = "Acc 2", y = 7}
}

-- ─── Factory ────────────────────────────────────────────────────────────────

function InventoryScreen:new()
  local instance = setmetatable({}, InventoryScreen)
  instance.active = false
  instance.party = nil
  instance.inventory = nil
  instance.selectedPanel = "party"
  instance.selectedCharIndex = 1
  instance.selectedSlotIndex = 1
  instance.selectedItemSlot = 1
  instance.fontSmall = love.graphics.newFont(10)
  instance.fontNormal = love.graphics.newFont(12)
  instance.fontLarge = love.graphics.newFont(16)
  return instance
end

-- ─── Scene Lifecycle ────────────────────────────────────────────────────────

function InventoryScreen:enter(party, inventory, callbacks)
  self.active = true
  self.party = party
  self.inventory = inventory
  self.selectedPanel = "party"
  self.selectedCharIndex = 1
  self.selectedItemSlot = 1
  
  -- Store callback
  self.onCloseCallback = callbacks and callbacks.onClose
end

function InventoryScreen:exit()
  self.active = false
  
  -- Call close callback if provided
  if self.onCloseCallback then
    self.onCloseCallback()
  end
end

function InventoryScreen:update(dt) end

-- ─── Input Handling ─────────────────────────────────────────────────────────

function InventoryScreen:keypressed(key)
  if key == "tab" or key == "escape" then
    self:exit()
    return true
  end
  
  if key == "left" or key == "right" then
    self.selectedPanel = key == "left" and "party" or "inventory"
    return true
  end
  
  return self.selectedPanel == "party" and self:handlePartyInput(key) 
         or self:handleInventoryInput(key)
end

function InventoryScreen:handlePartyInput(key)
  if key == "up" then
    self.selectedCharIndex = math.max(1, self.selectedCharIndex - 1)
  elseif key == "down" then
    self.selectedCharIndex = math.min(#self.party, self.selectedCharIndex + 1)
  elseif key == "return" or key == "space" then
    return true
  else
    return false
  end
  return true
end

function InventoryScreen:handleInventoryInput(key)
  if key == "up" then
    self.selectedItemSlot = math.max(1, self.selectedItemSlot - GRID_COLS)
  elseif key == "down" then
    self.selectedItemSlot = math.min(self.inventory.maxSlots, self.selectedItemSlot + GRID_COLS)
  elseif key == "left" then
    if self.selectedItemSlot % GRID_COLS ~= 1 then
      self.selectedItemSlot = self.selectedItemSlot - 1
    end
  elseif key == "right" then
    if self.selectedItemSlot % GRID_COLS ~= 0 then
      self.selectedItemSlot = math.min(self.inventory.maxSlots, self.selectedItemSlot + 1)
    end
  elseif key == "return" or key == "space" then
    local item = self.inventory:getItem(self.selectedItemSlot)
    if item and item.type == "consumable" then
      print("Using: " .. item.name)
    end
  else
    return false
  end
  return true
end

-- ─── Rendering ──────────────────────────────────────────────────────────────

function InventoryScreen:draw()
  if not self.active then return end
  
  love.graphics.setColor(COLOR_BG)
  love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
  
  self:drawPartyPanel()
  self:drawInventoryPanel()
  self:drawHelpText()
end

function InventoryScreen:drawPartyPanel()
  local x, y = PANEL_MARGIN, PANEL_MARGIN
  
  love.graphics.setColor(COLOR_PANEL)
  love.graphics.rectangle("fill", x, y, LEFT_PANEL_WIDTH, SCREEN_HEIGHT - 60)
  
  local borderColor = self.selectedPanel == "party" and COLOR_ACCENT or COLOR_TEXT_DIM
  love.graphics.setColor(borderColor)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, LEFT_PANEL_WIDTH, SCREEN_HEIGHT - 60)
  
  love.graphics.setFont(self.fontLarge)
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.print("PARTY ROSTER", x + 10, y + 10)
  
  local charY = y + 50
  for i, character in ipairs(self.party) do
    self:drawCharacterCard(character, x + 10, charY, i == self.selectedCharIndex)
    charY = charY + 140
  end
end

function InventoryScreen:drawCharacterCard(char, x, y, selected)
  local w, h = LEFT_PANEL_WIDTH - 20, 130
  
  if selected and self.selectedPanel == "party" then
    love.graphics.setColor(COLOR_SELECTED)
    love.graphics.rectangle("fill", x, y, w, h)
  end
  
  love.graphics.setColor(selected and COLOR_ACCENT or COLOR_TEXT_DIM)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", x, y, w, h)
  
  love.graphics.setFont(self.fontNormal)
  love.graphics.setColor(COLOR_TEXT)
  love.graphics.print(char.name .. " (" .. char.className .. ")", x + 10, y + 5)
  
  love.graphics.setFont(self.fontSmall)
  love.graphics.print("HP: " .. char.currentHP .. "/" .. char.maxHP, x + 10, y + 25)
  love.graphics.print("EP: " .. char.currentEP .. "/" .. char.maxEP, x + 10, y + 40)
  
  local equipY = y + 60
  for _, slot in ipairs(EQUIPMENT_SLOTS) do
    if slot.y < 4 then
      local item = char.equipment[slot.name]
      local itemName = item and item.name or "[Empty]"
      local color = item and COLOR_TEXT or COLOR_TEXT_DIM
      
      love.graphics.setColor(COLOR_TEXT_DIM)
      love.graphics.print(slot.label .. ": ", x + 10, equipY)
      love.graphics.setColor(color)
      love.graphics.print(itemName, x + 80, equipY)
      equipY = equipY + 15
    end
  end
end

function InventoryScreen:drawInventoryPanel()
  local x, y = RIGHT_PANEL_X, PANEL_MARGIN
  
  love.graphics.setColor(COLOR_PANEL)
  love.graphics.rectangle("fill", x, y, RIGHT_PANEL_WIDTH, SCREEN_HEIGHT - 60)
  
  local borderColor = self.selectedPanel == "inventory" and COLOR_ACCENT or COLOR_TEXT_DIM
  love.graphics.setColor(borderColor)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", x, y, RIGHT_PANEL_WIDTH, SCREEN_HEIGHT - 60)
  
  love.graphics.setFont(self.fontLarge)
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.print("SHARED INVENTORY", x + 10, y + 10)
  
  self:drawInventoryGrid(x + 20, y + 50)
  
  local weightInfo = self.inventory:getWeightStatus(self.party)
  love.graphics.setFont(self.fontNormal)
  love.graphics.setColor(weightInfo.overEncumbered and COLOR_DANGER or COLOR_TEXT)
  love.graphics.print(string.format("Weight: %.1f / %.1f kg", 
    weightInfo.current, weightInfo.max), x + 20, y + 330)
  
  love.graphics.setColor(weightInfo.overEncumbered and COLOR_DANGER or COLOR_TEXT_DIM)
  love.graphics.print("Status: " .. weightInfo.status, x + 20, y + 350)
  
  self:drawSelectedItemInfo(x + 20, y + 390)
end

function InventoryScreen:drawInventoryGrid(x, y)
  for row = 0, GRID_ROWS - 1 do
    for col = 0, GRID_COLS - 1 do
      local slotIndex = row * GRID_COLS + col + 1
      local slotX = x + col * (SLOT_SIZE + SLOT_SPACING)
      local slotY = y + row * (SLOT_SIZE + SLOT_SPACING)
      local item = self.inventory:getItem(slotIndex)
      
      if slotIndex == self.selectedItemSlot and self.selectedPanel == "inventory" then
        love.graphics.setColor(COLOR_SELECTED)
        love.graphics.rectangle("fill", slotX, slotY, SLOT_SIZE, SLOT_SIZE)
      end
      
      love.graphics.setColor(item and {0.2, 0.2, 0.2, 1} or {0.1, 0.1, 0.1, 1})
      love.graphics.rectangle("fill", slotX, slotY, SLOT_SIZE, SLOT_SIZE)
      
      love.graphics.setColor(COLOR_TEXT_DIM)
      love.graphics.setLineWidth(1)
      love.graphics.rectangle("line", slotX, slotY, SLOT_SIZE, SLOT_SIZE)
      
      if item then
        love.graphics.setFont(self.fontSmall)
        love.graphics.setColor(COLOR_TEXT)
        love.graphics.printf(item.name, slotX + 2, slotY + 20, SLOT_SIZE - 4, "center")
      end
    end
  end
end

function InventoryScreen:drawSelectedItemInfo(x, y)
  local item = self.inventory:getItem(self.selectedItemSlot)
  if not item then
    love.graphics.setFont(self.fontNormal)
    love.graphics.setColor(COLOR_TEXT_DIM)
    love.graphics.print("[No item selected]", x, y)
    return
  end
  
  love.graphics.setFont(self.fontNormal)
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.print(item.name, x, y)
  
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT)
  love.graphics.printf(item.description or "", x, y + 20, 380, "left")
  
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.print("Type: " .. item.type, x, y + 70)
  love.graphics.print("Weight: " .. item.weight .. " kg", x, y + 85)
  love.graphics.print("Rarity: " .. item.rarity, x, y + 100)
end

function InventoryScreen:drawHelpText()
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.printf("TAB/ESC: Close | Arrow Keys: Navigate | ENTER: Select/Use",
    0, SCREEN_HEIGHT - 30, SCREEN_WIDTH, "center")
end

return InventoryScreen
