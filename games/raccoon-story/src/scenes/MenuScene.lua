-- Menu Scene
-- Main menu for Raccoon Story

local Button = require("src.ui.Button")
local Panel = require("src.ui.Panel")
local Icon = require("src.ui.Icon")
local SettingsMenu = require("src.ui.SettingsMenu")

local MenuScene = {}

function MenuScene:enter()
  print("Entering Main Menu")
  
  -- Screen dimensions
  self.screenWidth = love.graphics.getWidth()
  self.screenHeight = love.graphics.getHeight()
  
  -- Background stars
  self.stars = {}
  for i = 1, 100 do
    table.insert(self.stars, {
      x = math.random(0, self.screenWidth),
      y = math.random(0, self.screenHeight),
      size = math.random(1, 3),
      twinkle = math.random() * math.pi * 2,
      twinkleSpeed = 0.5 + math.random() * 1.5
    })
  end
  
  -- Title animation
  self.titleY = 120
  self.titleBounce = 0
  self.titleScale = 1.0
  
  -- Raccoon mascot animation (simple floating)
  self.raccoonY = self.titleY + 60
  self.raccoonBounce = 0
  
  -- Settings menu
  self.settingsMenu = SettingsMenu:new()
  self.settingsMenu.onBack = function()
    self.settingsMenu:hide()
  end
  
  -- Create buttons
  self.buttons = {}
  self.focusedIndex = 1
  
  local buttonWidth = 300
  local buttonHeight = 60
  local buttonX = (self.screenWidth - buttonWidth) / 2
  local buttonStartY = 350
  local buttonSpacing = 80
  
  -- New Game button
  table.insert(self.buttons, Button:new(
    buttonX, buttonStartY,
    buttonWidth, buttonHeight,
    "New Game",
    function() self:startNewGame() end
  ))
  
  -- Continue button (disabled if no save)
  local continueButton = Button:new(
    buttonX, buttonStartY + buttonSpacing,
    buttonWidth, buttonHeight,
    "Continue",
    function() self:continueGame() end
  )
  -- Check if save file exists
  if not love.filesystem.getInfo("save.lua") then
    continueButton:setEnabled(false)
  end
  table.insert(self.buttons, continueButton)
  
  -- Settings button
  table.insert(self.buttons, Button:new(
    buttonX, buttonStartY + buttonSpacing * 2,
    buttonWidth, buttonHeight,
    "Settings",
    function() self:openSettings() end
  ))
  
  -- Credits button
  table.insert(self.buttons, Button:new(
    buttonX, buttonStartY + buttonSpacing * 3,
    buttonWidth, buttonHeight,
    "Credits",
    function() self:showCredits() end
  ))
  
  -- Quit button
  table.insert(self.buttons, Button:new(
    buttonX, buttonStartY + buttonSpacing * 4,
    buttonWidth, buttonHeight,
    "Quit",
    function() self:quit() end
  ))
  
  -- Set first button as focused
  self.buttons[1]:setFocused(true)
  
  -- Credits display
  self.showingCredits = false
  self.creditsPanel = Panel:new(
    self.screenWidth / 2 - 300,
    self.screenHeight / 2 - 200,
    600, 400, "translucent"
  )
end

function MenuScene:exit()
  print("Exiting Main Menu")
  self.buttons = nil
  self.stars = nil
end

function MenuScene:startNewGame()
  print("[MenuScene] Starting new game")
  local SceneManager = require("src.scenes.SceneManager")
  SceneManager:switch("game")
end

function MenuScene:continueGame()
  print("[MenuScene] Continuing game")
  -- TODO: Load save data
  local SceneManager = require("src.scenes.SceneManager")
  SceneManager:switch("game")
end

function MenuScene:openSettings()
  print("[MenuScene] Opening settings")
  self.settingsMenu:show()
end

function MenuScene:showCredits()
  print("[MenuScene] Showing credits")
  self.showingCredits = true
end

function MenuScene:hideCredits()
  self.showingCredits = false
end

function MenuScene:quit()
  print("[MenuScene] Quitting game")
  love.event.quit()
end

function MenuScene:update(dt)
  -- Update stars twinkle
  for _, star in ipairs(self.stars) do
    star.twinkle = star.twinkle + star.twinkleSpeed * dt
  end
  
  -- Title bounce animation
  self.titleBounce = self.titleBounce + dt * 2
  self.titleY = 120 + math.sin(self.titleBounce) * 10
  self.titleScale = 1.0 + math.sin(self.titleBounce * 1.5) * 0.05
  
  -- Raccoon float animation
  self.raccoonBounce = self.raccoonBounce + dt * 3
  self.raccoonY = self.titleY + 60 + math.sin(self.raccoonBounce) * 5
  
  -- Update settings menu first (if active)
  if self.settingsMenu:isActive() then
    self.settingsMenu:update(dt)
    return
  end
  
  -- Update buttons if not showing credits
  if not self.showingCredits then
    for _, button in ipairs(self.buttons) do
      button:update(dt)
    end
  end
end

function MenuScene:draw()
  local lg = love.graphics
  
  -- Background (night sky)
  lg.clear(0.106, 0.106, 0.180) -- Deep blue-purple night #1A1A2E
  
  -- Draw stars
  for _, star in ipairs(self.stars) do
    local alpha = 0.5 + math.sin(star.twinkle) * 0.5
    lg.setColor(1, 1, 1, alpha)
    lg.circle("fill", star.x, star.y, star.size)
  end
  
  -- Draw moon
  lg.setColor(0.961, 0.871, 0.702, 0.8) -- Cream
  lg.circle("fill", self.screenWidth - 150, 100, 60)
  lg.setColor(0.106, 0.106, 0.180, 1)
  lg.circle("fill", self.screenWidth - 130, 90, 50)
  
  -- Draw title
  lg.setColor(0.961, 0.871, 0.702, 1) -- Cream
  local titleText = "RACCOON STORY"
  local font = lg.getFont()
  local titleWidth = font:getWidth(titleText) * 3
  lg.print(titleText, (self.screenWidth - titleWidth) / 2, self.titleY, 0, 3 * self.titleScale, 3 * self.titleScale)
  
  -- Draw subtitle
  lg.setColor(0.565, 0.933, 0.565, 0.8) -- Soft green
  local subtitle = "A Cozy Trash Collection Adventure"
  local subtitleWidth = font:getWidth(subtitle) * 1.2
  lg.print(subtitle, (self.screenWidth - subtitleWidth) / 2, self.titleY + 60, 0, 1.2, 1.2)
  
  -- Draw simple raccoon "sprite" (placeholder emoji/icon)
  lg.setColor(0.545, 0.271, 0.075, 1) -- Brown for raccoon
  lg.circle("fill", self.screenWidth / 2, self.raccoonY + 80, 25)
  lg.setColor(0.3, 0.3, 0.3) -- Dark gray for mask
  lg.circle("fill", self.screenWidth / 2 - 10, self.raccoonY + 70, 8)
  lg.circle("fill", self.screenWidth / 2 + 10, self.raccoonY + 70, 8)
  lg.setColor(1, 1, 1) -- White for eyes
  lg.circle("fill", self.screenWidth / 2 - 10, self.raccoonY + 70, 4)
  lg.circle("fill", self.screenWidth / 2 + 10, self.raccoonY + 70, 4)
  
  -- Draw buttons (if not showing credits or settings)
  if not self.showingCredits and not self.settingsMenu:isActive() then
    for _, button in ipairs(self.buttons) do
      button:draw()
    end
    
    -- Draw controls hint
    lg.setColor(0.7, 0.7, 0.7, 0.6)
    lg.printf("Arrow Keys/D-Pad: Navigate | Enter/A: Select | ESC: Quit", 
      0, self.screenHeight - 30, self.screenWidth, "center", 0, 0.9)
  end
  
  -- Draw credits overlay
  if self.showingCredits then
    lg.setColor(0, 0, 0, 0.8)
    lg.rectangle("fill", 0, 0, self.screenWidth, self.screenHeight)
    
    self.creditsPanel:draw()
    
    lg.setColor(0.961, 0.871, 0.702, 1)
    local creditsX = self.creditsPanel.x + 30
    local creditsY = self.creditsPanel.y + 30
    lg.print("CREDITS", creditsX + 200, creditsY, 0, 2, 2)
    
    lg.setColor(1, 1, 1)
    creditsY = creditsY + 80
    lg.print("Game Design & Development:", creditsX, creditsY, 0, 1.2)
    creditsY = creditsY + 30
    lg.print("  Love2D + AI Assistant", creditsX + 20, creditsY)
    
    creditsY = creditsY + 50
    lg.print("Made with Love2D Framework", creditsX, creditsY, 0, 1.2)
    
    creditsY = creditsY + 50
    lg.print("Special Thanks:", creditsX, creditsY, 0, 1.2)
    creditsY = creditsY + 30
    lg.print("  All raccoons everywhere", creditsX + 20, creditsY)
    creditsY = creditsY + 25
    lg.print("  Trash enthusiasts", creditsX + 20, creditsY)
    
    lg.setColor(0.565, 0.933, 0.565, 1)
    lg.printf("Press ESC or ENTER to close", 
      0, self.creditsPanel.y + self.creditsPanel.height - 40, 
      self.screenWidth, "center", 0, 1.1)
  end
  
  -- Draw settings menu on top
  self.settingsMenu:draw()
end

function MenuScene:mousepressed(x, y, button)
  if self.settingsMenu:isActive() then
    return self.settingsMenu:mousepressed(x, y, button)
  end
  
  if self.showingCredits then
    return false
  end
  
  for _, btn in ipairs(self.buttons) do
    if btn:mousepressed(x, y, button) then
      return true
    end
  end
end

function MenuScene:mousereleased(x, y, button)
  if self.settingsMenu:isActive() then
    return self.settingsMenu:mousereleased(x, y, button)
  end
  
  if self.showingCredits then
    return false
  end
  
  for _, btn in ipairs(self.buttons) do
    if btn:mousereleased(x, y, button) then
      return true
    end
  end
end

function MenuScene:keypressed(key)
  -- Settings menu gets priority
  if self.settingsMenu:isActive() then
    return self.settingsMenu:keypressed(key)
  end
  
  -- Credits screen
  if self.showingCredits then
    if key == "escape" or key == "return" or key == "space" then
      self:hideCredits()
      return true
    end
    return false
  end
  
  -- Quit with ESC
  if key == "escape" then
    self:quit()
    return true
  end
  
  -- Navigation
  if key == "up" or key == "w" then
    self:moveFocus(-1)
    return true
  elseif key == "down" or key == "s" then
    self:moveFocus(1)
    return true
  end
  
  -- Activation
  if key == "return" or key == "space" then
    self.buttons[self.focusedIndex]:activate()
    return true
  end
  
  return false
end

function MenuScene:gamepadpressed(joystick, button)
  if self.settingsMenu:isActive() then
    return self.settingsMenu:gamepadpressed(joystick, button)
  end
  
  if self.showingCredits then
    if button == "a" or button == "b" or button == "start" then
      self:hideCredits()
      return true
    end
    return false
  end
  
  -- Navigation
  if button == "dpup" then
    self:moveFocus(-1)
    return true
  elseif button == "dpdown" then
    self:moveFocus(1)
    return true
  end
  
  -- Activation
  if button == "a" then
    self.buttons[self.focusedIndex]:activate()
    return true
  end
  
  -- Back/Quit
  if button == "b" or button == "start" then
    self:quit()
    return true
  end
  
  return false
end

function MenuScene:moveFocus(direction)
  self.buttons[self.focusedIndex]:setFocused(false)
  self.focusedIndex = self.focusedIndex + direction
  
  -- Wrap around
  if self.focusedIndex < 1 then
    self.focusedIndex = #self.buttons
  elseif self.focusedIndex > #self.buttons then
    self.focusedIndex = 1
  end
  
  -- Skip disabled buttons
  if not self.buttons[self.focusedIndex].enabled then
    self:moveFocus(direction)
    return
  end
  
  self.buttons[self.focusedIndex]:setFocused(true)
end

return MenuScene
