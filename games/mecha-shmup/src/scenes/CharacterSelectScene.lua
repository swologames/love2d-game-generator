-- CharacterSelectScene.lua
-- Character selection scene for Mecha Shmup

local Button = require("src.ui.Button")
local ShaderSystem = require("src.systems.ShaderSystem")

local CharacterSelectScene = {}

function CharacterSelectScene:enter(levelId, isBoss)
  print("Entering Character Select")
  
  -- Store selected level (defaults to 1 if not provided)
  self.selectedLevel = levelId or 1
  self.isBoss = isBoss or false
  print("Selected level: " .. tostring(self.selectedLevel) .. " (Boss: " .. tostring(self.isBoss) .. ")")
  
  -- Continue menu music (don't restart if already playing)
  if AudioSystem:getCurrentMusicName() ~= "menu" then
    AudioSystem:playMusic("menu", true, 1.0)
  end
  
  -- Character data from GDD
  self.characters = {
    {
      name = "Kai Rexford",
      callsign = "VALKYRIE",
      mecha = "VK-01 Valkyrie",
      weapon = "Plasma Cannon",
      special = "Homing Missiles",
      stats = {
        speed = 3,
        firepower = 3,
        defense = 3,
        difficulty = 2
      },
      description = "Balanced pilot, good for beginners.\nAll-around combat abilities.",
      color = {0.3, 0.7, 1}
    },
    {
      name = "Zara Nakamura",
      callsign = "PHANTOM",
      mecha = "PH-03 Phantom",
      weapon = "Laser Array",
      special = "EMP Burst",
      stats = {
        speed = 5,
        firepower = 2,
        defense = 2,
        difficulty = 4
      },
      description = "Speed focused, high skill cap.\nSmaller hitbox, dodge master.",
      color = {1, 0.3, 0.7}
    },
    {
      name = "Viktor Kozlov",
      callsign = "BASTION",
      mecha = "BN-05 Bastion",
      weapon = "Railgun",
      special = "Shield Barrier",
      stats = {
        speed = 2,
        firepower = 5,
        defense = 5,
        difficulty = 3
      },
      description = "Heavy weapons specialist.\nHigh damage, can take hits.",
      color = {1, 0.7, 0.2}
    }
  }
  
  self.selectedIndex = 1
  self.title = "SELECT YOUR PILOT"
  
  -- Create confirm button
  self.confirmButton = Button:new(220, 620, 200, 50, "LAUNCH MISSION", function()
    AudioSystem:playSound("click_long")
    print("Selected: " .. self.characters[self.selectedIndex].name)
    SceneManager:switch("game", self.selectedIndex, self.selectedLevel, self.isBoss)
  end)
  
  -- Animation
  self.animTime = 0
  
  -- Shader system
  self.shaders = ShaderSystem:new()
end

function CharacterSelectScene:exit()
  print("Exiting Character Select")
end

function CharacterSelectScene:update(dt)
  self.animTime = self.animTime + dt
  self.confirmButton:update(dt)
  
  -- Update shaders
  self.shaders:update(dt)
end

function CharacterSelectScene:draw()
  -- Begin shader post-processing
  self.shaders:beginDraw()
  
  -- Background
  love.graphics.setColor(0.05, 0.05, 0.15, 1)
  love.graphics.rectangle("fill", 0, 0, 640, 720)
  
  -- Title
  local titleFont = love.graphics.newFont(32)
  love.graphics.setFont(titleFont)
  love.graphics.setColor(0.4, 0.9, 1, 1)
  love.graphics.printf(self.title, 0, 30, 640, "center")
  
  -- Draw character cards
  local cardWidth = 180
  local cardHeight = 480
  local startX = 25
  local y = 100
  local spacing = 20
  
  for i, char in ipairs(self.characters) do
    local x = startX + (i - 1) * (cardWidth + spacing)
    local isSelected = (i == self.selectedIndex)
    
    -- Card background
    if isSelected then
      -- Glow effect for selected
      love.graphics.setColor(char.color[1], char.color[2], char.color[3], 0.3)
      love.graphics.rectangle("fill", x - 4, y - 4, cardWidth + 8, cardHeight + 8, 8, 8)
    end
    
    love.graphics.setColor(0.15, 0.15, 0.25, 1)
    love.graphics.rectangle("fill", x, y, cardWidth, cardHeight, 6, 6)
    
    -- Card border
    if isSelected then
      love.graphics.setColor(char.color)
      love.graphics.setLineWidth(3)
    else
      love.graphics.setColor(0.3, 0.3, 0.4, 1)
      love.graphics.setLineWidth(2)
    end
    love.graphics.rectangle("line", x, y, cardWidth, cardHeight, 6, 6)
    
    -- Character portrait placeholder
    love.graphics.setColor(char.color[1] * 0.3, char.color[2] * 0.3, char.color[3] * 0.3, 1)
    love.graphics.rectangle("fill", x + 10, y + 10, cardWidth - 20, 120, 4, 4)
    
    -- Mecha icon placeholder
    love.graphics.setColor(char.color)
    love.graphics.circle("fill", x + cardWidth / 2, y + 70, 30)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.printf(char.callsign, x, y + 60, cardWidth, "center")
    
    -- Character info
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf(char.name, x + 10, y + 145, cardWidth - 20, "center")
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf(char.mecha, x + 10, y + 175, cardWidth - 20, "center")
    
    -- Stats
    local statsY = y + 210
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.7, 0.7, 0.7, 1)
    
    local statNames = {"Speed", "Power", "Defense", "Skill"}
    local statValues = {char.stats.speed, char.stats.firepower, char.stats.defense, char.stats.difficulty}
    
    for j, statName in ipairs(statNames) do
      local statY = statsY + (j - 1) * 28
      love.graphics.print(statName, x + 15, statY)
      
      -- Stat bar
      local barX = x + 15
      local barY = statY + 15
      local barWidth = cardWidth - 30
      local barHeight = 8
      
      love.graphics.setColor(0.2, 0.2, 0.3, 1)
      love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
      
      love.graphics.setColor(char.color)
      love.graphics.rectangle("fill", barX, barY, barWidth * (statValues[j] / 5), barHeight)
    end
    
    -- Weapon info
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.printf("Weapon: " .. char.weapon, x + 10, y + 340, cardWidth - 20, "left")
    love.graphics.printf("Special: " .. char.special, x + 10, y + 360, cardWidth - 20, "left")
    
    -- Description
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(0.6, 0.6, 0.6, 1)
    love.graphics.printf(char.description, x + 10, y + 390, cardWidth - 20, "left")
    
    -- Selection indicator
    if isSelected then
      love.graphics.setColor(char.color)
      love.graphics.setFont(love.graphics.newFont(14))
      love.graphics.printf("▼ SELECTED ▼", x, y + 450, cardWidth, "center")
    end
  end
  
  -- Instructions
  love.graphics.setFont(love.graphics.newFont(14))
  love.graphics.setColor(0.7, 0.7, 0.7, 1)
  love.graphics.printf("← → Keys or Mouse  |  ENTER/Click to Confirm  |  ESC to Back",
                       0, 680, 640, "center")
  
  -- Draw confirm button
  self.confirmButton:draw()
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
  
  -- End shader post-processing (applies CRT effect)
  self.shaders:endDraw()
end

function CharacterSelectScene:keypressed(key)
  if key == "escape" then
    AudioSystem:playSound("click_short")
    SceneManager:switch("menu")
  elseif key == "left" then
    AudioSystem:playSound("click_short")
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex < 1 then
      self.selectedIndex = #self.characters
    end
  elseif key == "right" then
    AudioSystem:playSound("click_short")
    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.characters then
      self.selectedIndex = 1
    end
  elseif key == "return" or key == "space" then
    AudioSystem:playSound("click_long")
    SceneManager:switch("game", self.selectedIndex, self.selectedLevel, self.isBoss)
  end
end

function CharacterSelectScene:mousepressed(x, y, button)
  -- Check if clicking on character cards
  local cardWidth = 180
  local cardHeight = 480
  local startX = 25
  local cardY = 100
  local spacing = 20
  
  for i = 1, #self.characters do
    local cardX = startX + (i - 1) * (cardWidth + spacing)
    if x >= cardX and x <= cardX + cardWidth and y >= cardY and y <= cardY + cardHeight then
      AudioSystem:playSound("click_short")
      self.selectedIndex = i
      return
    end
  end
  
  -- Check confirm button
  self.confirmButton:mousepressed(x, y, button)
end

return CharacterSelectScene
