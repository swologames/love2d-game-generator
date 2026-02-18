-- PauseMenu.lua
-- Pause menu overlay for the game

local Button = require("src.ui.Button")
local Panel = require("src.ui.Panel")

local PauseMenu = {}
PauseMenu.__index = PauseMenu

function PauseMenu:new()
  local instance = setmetatable({}, self)
  
  instance.active = false
  instance.buttons = {}
  instance.focusedIndex = 1
  
  -- Layout
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local panelWidth = 400
  local panelHeight = 500
  local panelX = (screenWidth - panelWidth) / 2
  local panelY = (screenHeight - panelHeight) / 2
  
  instance.panel = Panel:new(panelX, panelY, panelWidth, panelHeight, "translucent")
  
  -- Title properties
  instance.titleText = "PAUSED"
  instance.titleY = panelY + 40
  
  -- Button properties
  local buttonWidth = 300
  local buttonHeight = 60
  local buttonX = (screenWidth - buttonWidth) / 2
  local buttonStartY = panelY + 120
  local buttonSpacing = 80
  
  -- Create buttons
  table.insert(instance.buttons, Button:new(
    buttonX, buttonStartY,
    buttonWidth, buttonHeight,
    "Resume",
    function() instance:resume() end
  ))
  
  table.insert(instance.buttons, Button:new(
    buttonX, buttonStartY + buttonSpacing,
    buttonWidth, buttonHeight,
    "Settings",
    function() instance:openSettings() end
  ))
  
  table.insert(instance.buttons, Button:new(
    buttonX, buttonStartY + buttonSpacing * 2,
    buttonWidth, buttonHeight,
    "Restart Night",
    function() instance:restartNight() end
  ))
  
  table.insert(instance.buttons, Button:new(
    buttonX, buttonStartY + buttonSpacing * 3,
    buttonWidth, buttonHeight,
    "Quit to Menu",
    function() instance:quitToMenu() end
  ))
  
  -- Set first button as focused
  instance.buttons[1]:setFocused(true)
  
  -- Callbacks (to be set by the game scene)
  instance.onResume = nil
  instance.onSettings = nil
  instance.onRestartNight = nil
  instance.onQuitToMenu = nil
  
  return instance
end

function PauseMenu:show()
  self.active = true
  self.focusedIndex = 1
  for i, button in ipairs(self.buttons) do
    button:setFocused(i == self.focusedIndex)
  end
end

function PauseMenu:hide()
  self.active = false
end

function PauseMenu:toggle()
  if self.active then
    self:hide()
  else
    self:show()
  end
end

function PauseMenu:isActive()
  return self.active
end

function PauseMenu:resume()
  self:hide()
  if self.onResume then
    self.onResume()
  end
end

function PauseMenu:openSettings()
  if self.onSettings then
    self.onSettings()
  end
end

function PauseMenu:restartNight()
  if self.onRestartNight then
    self.onRestartNight()
  end
end

function PauseMenu:quitToMenu()
  if self.onQuitToMenu then
    self.onQuitToMenu()
  end
end

function PauseMenu:update(dt)
  if not self.active then return end
  
  for _, button in ipairs(self.buttons) do
    button:update(dt)
  end
end

function PauseMenu:draw()
  if not self.active then return end
  
  local lg = love.graphics
  local screenWidth = lg.getWidth()
  local screenHeight = lg.getHeight()
  
  -- Draw darkened overlay
  lg.setColor(0, 0, 0, 0.7)
  lg.rectangle("fill", 0, 0, screenWidth, screenHeight)
  
  -- Draw panel
  self.panel:draw()
  
  -- Draw title
  lg.setColor(0.961, 0.871, 0.702, 1) -- Cream
  local titleFont = lg.getFont()
  local titleWidth = titleFont:getWidth(self.titleText)
  lg.print(self.titleText, (screenWidth - titleWidth) / 2, self.titleY, 0, 2, 2)
  
  -- Draw buttons
  for _, button in ipairs(self.buttons) do
    button:draw()
  end
  
  -- Draw controls hint
  lg.setColor(0.7, 0.7, 0.7, 0.8)
  lg.printf("ESC: Resume | Arrow Keys/D-Pad: Navigate | Enter/A: Select", 
    0, screenHeight - 40, screenWidth, "center", 0, 0.9)
end

function PauseMenu:mousepressed(x, y, button)
  if not self.active then return false end
  
  for _, btn in ipairs(self.buttons) do
    if btn:mousepressed(x, y, button) then
      return true
    end
  end
  return false
end

function PauseMenu:mousereleased(x, y, button)
  if not self.active then return false end
  
  for _, btn in ipairs(self.buttons) do
    if btn:mousereleased(x, y, button) then
      return true
    end
  end
  return false
end

function PauseMenu:keypressed(key)
  if not self.active then return false end
  
  -- ESC to resume
  if key == "escape" then
    self:resume()
    return true
  end
  
  -- Navigation with arrow keys or WASD
  if key == "up" or key == "w" then
    self:moveFocus(-1)
    return true
  elseif key == "down" or key == "s" then
    self:moveFocus(1)
    return true
  end
  
  -- Activation with Enter or Space
  if key == "return" or key == "space" then
    self.buttons[self.focusedIndex]:activate()
    return true
  end
  
  return false
end

function PauseMenu:gamepadpressed(joystick, button)
  if not self.active then return false end
  
  -- Navigate with D-pad
  if button == "dpup" then
    self:moveFocus(-1)
    return true
  elseif button == "dpdown" then
    self:moveFocus(1)
    return true
  end
  
  -- Activate with A button
  if button == "a" then
    self.buttons[self.focusedIndex]:activate()
    return true
  end
  
  -- Resume with B or Start
  if button == "b" or button == "start" then
    self:resume()
    return true
  end
  
  return false
end

function PauseMenu:moveFocus(direction)
  self.buttons[self.focusedIndex]:setFocused(false)
  self.focusedIndex = self.focusedIndex + direction
  
  -- Wrap around
  if self.focusedIndex < 1 then
    self.focusedIndex = #self.buttons
  elseif self.focusedIndex > #self.buttons then
    self.focusedIndex = 1
  end
  
  self.buttons[self.focusedIndex]:setFocused(true)
end

return PauseMenu
