-- SettingsMenu.lua
-- Settings menu with volume sliders and options

local Button = require("src.ui.Button")
local Slider = require("src.ui.Slider")
local Panel = require("src.ui.Panel")

local SettingsMenu = {}
SettingsMenu.__index = SettingsMenu

function SettingsMenu:new()
  local instance = setmetatable({}, self)
  
  instance.active = false
  instance.focusedIndex = 1
  instance.focusables = {} -- Mix of sliders and buttons
  
  -- Layout
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local panelWidth = 600
  local panelHeight = 600
  local panelX = (screenWidth - panelWidth) / 2
  local panelY = (screenHeight - panelHeight) / 2
  
  instance.panel = Panel:new(panelX, panelY, panelWidth, panelHeight, "translucent")
  
  -- Title
  instance.titleText = "SETTINGS"
  instance.titleY = panelY + 30
  
  -- Settings data
  instance.settings = {
    masterVolume = 0.7,
    musicVolume = 0.8,
    sfxVolume = 0.6,
    fullscreen = false
  }
  
  -- Load saved settings
  instance:loadSettings()
  
  -- Create sliders
  local sliderX = panelX + 150
  local sliderWidth = 300
  local sliderHeight = 20
  local startY = panelY + 100
  local spacing = 80
  
  -- Master Volume Slider
  instance.masterSlider = Slider:new(
    sliderX, startY, sliderWidth, sliderHeight,
    0, 1, instance.settings.masterVolume,
    function(value)
      instance.settings.masterVolume = value
      instance:applyVolume()
    end
  )
  table.insert(instance.focusables, instance.masterSlider)
  
  -- Music Volume Slider
  instance.musicSlider = Slider:new(
    sliderX, startY + spacing, sliderWidth, sliderHeight,
    0, 1, instance.settings.musicVolume,
    function(value)
      instance.settings.musicVolume = value
      instance:applyVolume()
    end
  )
  table.insert(instance.focusables, instance.musicSlider)
  
  -- SFX Volume Slider
  instance.sfxSlider = Slider:new(
    sliderX, startY + spacing * 2, sliderWidth, sliderHeight,
    0, 1, instance.settings.sfxVolume,
    function(value)
      instance.settings.sfxVolume = value
      instance:applyVolume()
    end
  )
  table.insert(instance.focusables, instance.sfxSlider)
  
  -- Fullscreen toggle button
  local buttonWidth = 250
  local buttonHeight = 50
  local buttonX = (screenWidth - buttonWidth) / 2
  
  instance.fullscreenButton = Button:new(
    buttonX, startY + spacing * 3,
    buttonWidth, buttonHeight,
    instance:getFullscreenText(),
    function() instance:toggleFullscreen() end
  )
  table.insert(instance.focusables, instance.fullscreenButton)
  
  -- Test sound button
  instance.testSoundButton = Button:new(
    buttonX, startY + spacing * 4,
    buttonWidth, buttonHeight,
    "Test Sound",
    function() instance:testSound() end
  )
  table.insert(instance.focusables, instance.testSoundButton)
  
  -- Apply button
  instance.applyButton = Button:new(
    buttonX - 130, startY + spacing * 5 + 20,
    120, 50,
    "Apply",
    function() instance:apply() end
  )
  table.insert(instance.focusables, instance.applyButton)
  
  -- Back button
  instance.backButton = Button:new(
    buttonX + 10, startY + spacing * 5 + 20,
    120, 50,
    "Back",
    function() instance:back() end
  )
  table.insert(instance.focusables, instance.backButton)
  
  -- Set first focusable
  instance.focusables[1]:setFocused(true)
  
  -- Callbacks
  instance.onBack = nil
  instance.onApply = nil
  
  -- Test sound (simple beep using generated tone)
  instance.testSoundSource = nil
  
  return instance
end

function SettingsMenu:show()
  self.active = true
  self.focusedIndex = 1
  for i, focusable in ipairs(self.focusables) do
    focusable:setFocused(i == self.focusedIndex)
  end
end

function SettingsMenu:hide()
  self.active = false
end

function SettingsMenu:isActive()
  return self.active
end

function SettingsMenu:loadSettings()
  -- Load from love.filesystem
  if love.filesystem.getInfo("settings.lua") then
    local chunk = love.filesystem.load("settings.lua")
    if chunk then
      local loadedSettings = chunk()
      if loadedSettings then
        for key, value in pairs(loadedSettings) do
          self.settings[key] = value
        end
        print("[SettingsMenu] Loaded settings from file")
      end
    end
  end
  
  -- Apply loaded settings
  self:applyVolume()
  if self.settings.fullscreen then
    love.window.setFullscreen(true)
  end
end

function SettingsMenu:saveSettings()
  local settingsString = "return {\n"
  for key, value in pairs(self.settings) do
    if type(value) == "boolean" then
      settingsString = settingsString .. "  " .. key .. " = " .. tostring(value) .. ",\n"
    else
      settingsString = settingsString .. "  " .. key .. " = " .. value .. ",\n"
    end
  end
  settingsString = settingsString .. "}\n"
  
  local success = love.filesystem.write("settings.lua", settingsString)
  if success then
    print("[SettingsMenu] Settings saved to file")
  else
    print("[SettingsMenu] Failed to save settings")
  end
end

function SettingsMenu:applyVolume()
  -- Apply volume settings globally
  -- This would normally set audio sources' volumes
  love.audio.setVolume(self.settings.masterVolume)
  -- Individual source volumes would be: source:setVolume(sfxVolume * masterVolume)
end

function SettingsMenu:toggleFullscreen()
  self.settings.fullscreen = not self.settings.fullscreen
  love.window.setFullscreen(self.settings.fullscreen)
  self.fullscreenButton.text = self:getFullscreenText()
end

function SettingsMenu:getFullscreenText()
  return "Fullscreen: " .. (self.settings.fullscreen and "ON" or "OFF")
end

function SettingsMenu:testSound()
  -- Generate a simple test beep
  if not self.testSoundSource then
    local sampleRate = 44100
    local duration = 0.3
    local frequency = 440 -- A4 note
    local samples = math.floor(sampleRate * duration)
    
    local soundData = love.sound.newSoundData(samples, sampleRate, 16, 1)
    for i = 0, samples - 1 do
      local t = i / sampleRate
      local value = math.sin(2 * math.pi * frequency * t)
      -- Apply envelope to avoid clicks
      local envelope = 1
      if i < sampleRate * 0.01 then
        envelope = i / (sampleRate * 0.01)
      elseif i > samples - sampleRate * 0.05 then
        envelope = (samples - i) / (sampleRate * 0.05)
      end
      soundData:setSample(i, value * envelope)
    end
    
    self.testSoundSource = love.audio.newSource(soundData)
  end
  
  self.testSoundSource:setVolume(self.settings.sfxVolume * self.settings.masterVolume)
  self.testSoundSource:stop()
  self.testSoundSource:play()
end

function SettingsMenu:apply()
  self:saveSettings()
  if self.onApply then
    self.onApply()
  end
end

function SettingsMenu:back()
  self:saveSettings() -- Auto-save on back
  self:hide()
  if self.onBack then
    self.onBack()
  end
end

function SettingsMenu:update(dt)
  if not self.active then return end
  
  for _, focusable in ipairs(self.focusables) do
    focusable:update(dt)
  end
end

function SettingsMenu:draw()
  if not self.active then return end
  
  local lg = love.graphics
  local screenWidth = lg.getWidth()
  
  -- Draw darkened overlay
  lg.setColor(0, 0, 0, 0.7)
  lg.rectangle("fill", 0, 0, screenWidth, lg.getHeight())
  
  -- Draw panel
  self.panel:draw()
  
  -- Draw title
  lg.setColor(0.961, 0.871, 0.702, 1) -- Cream
  local titleFont = lg.getFont()
  local titleWidth = titleFont:getWidth(self.titleText)
  lg.print(self.titleText, (screenWidth - titleWidth) / 2, self.titleY, 0, 2, 2)
  
  -- Draw slider labels
  local labelX = self.panel.x + 30
  local startY = self.panel.y + 100
  local spacing = 80
  
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print("Master Volume:", labelX, startY - 10, 0, 1.2)
  lg.print("Music Volume:", labelX, startY + spacing - 10, 0, 1.2)
  lg.print("SFX Volume:", labelX, startY + spacing * 2 - 10, 0, 1.2)
  
  -- Draw sliders
  self.masterSlider:draw()
  self.musicSlider:draw()
  self.sfxSlider:draw()
  
  -- Draw buttons
  self.fullscreenButton:draw()
  self.testSoundButton:draw()
  self.applyButton:draw()
  self.backButton:draw()
  
  -- Draw controls hint
  lg.setColor(0.565, 0.933, 0.565, 1) -- Soft green
  lg.print("Controls:", self.panel.x + 30, self.panel.y + 480, 0, 1.2)
  lg.setColor(0.7, 0.7, 0.7, 0.8)
  lg.printf("Arrow Keys: Navigate | Left/Right: Adjust Slider | Enter: Activate", 
    self.panel.x, self.panel.y + 510, self.panel.width, "center", 0, 0.9)
end

function SettingsMenu:mousepressed(x, y, button)
  if not self.active then return false end
  
  for _, focusable in ipairs(self.focusables) do
    if focusable.mousepressed and focusable:mousepressed(x, y, button) then
      return true
    end
  end
  return false
end

function SettingsMenu:mousereleased(x, y, button)
  if not self.active then return false end
  
  for _, focusable in ipairs(self.focusables) do
    if focusable.mousereleased and focusable:mousereleased(x, y, button) then
      return true
    end
  end
  return false
end

function SettingsMenu:keypressed(key)
  if not self.active then return false end
  
  -- Navigation
  if key == "up" or key == "w" then
    self:moveFocus(-1)
    return true
  elseif key == "down" or key == "s" then
    self:moveFocus(1)
    return true
  end
  
  -- Slider adjustment
  local focused = self.focusables[self.focusedIndex]
  if focused.adjustValue then
    if key == "left" or key == "a" then
      focused:adjustValue(-1)
      return true
    elseif key == "right" or key == "d" then
      focused:adjustValue(1)
      return true
    end
  end
  
  -- Activation
  if key == "return" or key == "space" then
    if focused.activate then
      focused:activate()
    end
    return true
  end
  
  -- Back with ESC
  if key == "escape" then
    self:back()
    return true
  end
  
  return false
end

function SettingsMenu:gamepadpressed(joystick, button)
  if not self.active then return false end
  
  if button == "dpup" then
    self:moveFocus(-1)
    return true
  elseif button == "dpdown" then
    self:moveFocus(1)
    return true
  end
  
  local focused = self.focusables[self.focusedIndex]
  if focused.adjustValue then
    if button == "dpleft" then
      focused:adjustValue(-1)
      return true
    elseif button == "dpright" then
      focused:adjustValue(1)
      return true
    end
  end
  
  if button == "a" then
    if focused.activate then
      focused:activate()
    end
    return true
  end
  
  if button == "b" then
    self:back()
    return true
  end
  
  return false
end

function SettingsMenu:moveFocus(direction)
  self.focusables[self.focusedIndex]:setFocused(false)
  self.focusedIndex = self.focusedIndex + direction
  
  if self.focusedIndex < 1 then
    self.focusedIndex = #self.focusables
  elseif self.focusedIndex > #self.focusables then
    self.focusedIndex = 1
  end
  
  self.focusables[self.focusedIndex]:setFocused(true)
end

return SettingsMenu
