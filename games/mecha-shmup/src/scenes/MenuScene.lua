-- MenuScene.lua
-- Main menu scene for Mecha Shmup

local Button = require("src.ui.Button")
local ShaderSystem = require("src.systems.ShaderSystem")

local MenuScene = {}

function MenuScene:enter()
  print("Entering Main Menu")
  
  -- Start menu music (fade in over 1 second)
  AudioSystem:playMusic("menu", true, 1.0)
  
  -- Title
  self.title = "RECLAIM"
  self.subtitle = "Tau Deu Invasion"
  
  -- Background stars animation
  self.stars = {}
  for i = 1, 100 do
    table.insert(self.stars, {
      x = math.random(0, 640),
      y = math.random(0, 720),
      speed = math.random(80, 180),
      size = math.random(1, 3)
    })
  end
  
  -- Create menu buttons
  local centerX = 320
  local startY = 320
  local buttonWidth = 280
  local buttonHeight = 50
  local spacing = 70
  
  self.buttons = {}
  
  -- Start Game button
  table.insert(self.buttons, Button:new(
    centerX - buttonWidth / 2,
    startY,
    buttonWidth,
    buttonHeight,
    "START GAME",
    function()
      AudioSystem:playSound("click_long")
      print("Start Game clicked")
      SceneManager:switch("characterSelect", 1)  -- Start at level 1
    end
  ))
  
  -- Level Select button
  table.insert(self.buttons, Button:new(
    centerX - buttonWidth / 2,
    startY + spacing,
    buttonWidth,
    buttonHeight,
    "LEVEL SELECT",
    function()
      AudioSystem:playSound("click_long")
      print("Level Select clicked")
      SceneManager:switch("levelSelect")
    end
  ))
  
  -- Options button (placeholder)
  table.insert(self.buttons, Button:new(
    centerX - buttonWidth / 2,
    startY + spacing * 2,
    buttonWidth,
    buttonHeight,
    "OPTIONS",
    function()
      AudioSystem:playSound("click_short")
      print("Options (not yet implemented)")
    end
  ))
  
  -- Quit button
  table.insert(self.buttons, Button:new(
    centerX - buttonWidth / 2,
    startY + spacing * 3,
    buttonWidth,
    buttonHeight,
    "QUIT",
    function()
      love.event.quit()
    end
  ))
  
  -- Animation state
  self.titlePulse = 0
  
  -- Shader system
  self.shaders = ShaderSystem:new()
end

function MenuScene:exit()
  print("Exiting Main Menu")
end

function MenuScene:update(dt)
  -- Update background stars
  for _, star in ipairs(self.stars) do
    star.y = star.y + star.speed * dt
    if star.y > 720 then
      star.y = -10
      star.x = math.random(0, 640)
    end
  end
  
  -- Update title animation
  self.titlePulse = self.titlePulse + dt
  
  -- Update buttons
  for _, button in ipairs(self.buttons) do
    button:update(dt)
  end
  
  -- Update shaders
  self.shaders:update(dt)
end

function MenuScene:draw()
  -- Begin shader post-processing
  self.shaders:beginDraw()
  
  -- Draw space background
  love.graphics.setColor(0.05, 0.05, 0.15, 1)
  love.graphics.rectangle("fill", 0, 0, 640, 720)
  
  -- Draw stars
  love.graphics.setColor(1, 1, 1, 0.25)
  for _, star in ipairs(self.stars) do
    love.graphics.circle("fill", star.x, star.y, star.size)
  end
  
  -- Draw title with pulse effect
  local titleScale = 1 + 0.05 * math.sin(self.titlePulse * 2)
  local titleFont = love.graphics.newFont(48)
  love.graphics.setFont(titleFont)
  
  -- Title glow
  love.graphics.setColor(0.3, 0.8, 1, 0.5 * (0.5 + 0.5 * math.sin(self.titlePulse * 2)))
  love.graphics.printf(self.title, 0, 150, 640, "center")
  
  -- Title text
  love.graphics.setColor(0.4, 0.9, 1, 1)
  love.graphics.printf(self.title, 0, 150, 640, "center")
  
  -- Subtitle
  local subtitleFont = love.graphics.newFont(18)
  love.graphics.setFont(subtitleFont)
  love.graphics.setColor(0.7, 0.7, 0.7, 1)
  love.graphics.printf(self.subtitle, 0, 220, 640, "center")
  
  -- Draw buttons
  love.graphics.setFont(love.graphics.newFont(20))
  for _, button in ipairs(self.buttons) do
    button:draw()
  end
  
  -- Draw version/credits
  love.graphics.setFont(love.graphics.newFont(12))
  love.graphics.setColor(0.5, 0.5, 0.5, 1)
  love.graphics.print("v1.0 | Made with Love2D", 10, 700)
  
  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
  
  -- End shader post-processing (applies CRT effect)
  self.shaders:endDraw()
end

function MenuScene:keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "space" or key == "return" then
    AudioSystem:playSound("click_long")
    SceneManager:switch("characterSelect")
  end
end

function MenuScene:mousepressed(x, y, button)
  for _, btn in ipairs(self.buttons) do
    if btn:mousepressed(x, y, button) then
      break
    end
  end
end

return MenuScene
