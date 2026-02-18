-- LevelSelectScene.lua
-- Level selection scene for testing

local Button = require("src.ui.Button")
local ShaderSystem = require("src.systems.ShaderSystem")

local LevelSelectScene = {}

function LevelSelectScene:enter()
  print("Entering Level Select")
  
  -- Continue menu music (don't restart if already playing)
  if AudioSystem:getCurrentMusicName() ~= "menu" then
    AudioSystem:playMusic("menu", true, 1.0)
  end
  
  -- Available levels (scan levels directory or hardcode)
  self.levels = {
    {
      id = 1,
      name = "Outer Defense",
      description = "The first wave of Tau Deu forces",
      difficulty = "Easy",
      color = {0.3, 0.7, 1},
      isBoss = false
    },
    {
      id = 2,
      name = "Inner Perimeter",
      description = "Tau forces intensify their assault",
      difficulty = "Medium",
      color = {1, 0.5, 0.3},
      isBoss = false
    },
    {
      id = "boss1",
      name = "Boss Fight 1",
      description = "Test Vor'kath the Ravager - All 5 phases",
      difficulty = "BOSS",
      color = {1, 0.2, 0.2},
      isBoss = true
    },
    {
      id = "boss2",
      name = "Boss Fight 2",
      description = "Test second boss encounter",
      difficulty = "BOSS",
      color = {0.8, 0.2, 0.8},
      isBoss = true
    }
  }
  
  self.selectedIndex = 1
  self.title = "SELECT LEVEL"
  
  -- Background stars
  self.stars = {}
  for i = 1, 100 do
    table.insert(self.stars, {
      x = math.random(0, 640),
      y = math.random(0, 720),
      speed = math.random(80, 180),
      size = math.random(1, 3)
    })
  end
  
  -- Create confirm button
  self.confirmButton = Button:new(220, 620, 200, 50, "SELECT LEVEL", function()
    AudioSystem:playSound("click_long")
    local selectedLevel = self.levels[self.selectedIndex]
    print("Selected Level: " .. tostring(selectedLevel.id) .. " (Boss: " .. tostring(selectedLevel.isBoss) .. ")")
    -- Go to character select with selected level and boss flag
    SceneManager:switch("characterSelect", selectedLevel.id, selectedLevel.isBoss)
  end)
  
  -- Animation
  self.animTime = 0
  
  -- Shader system
  self.shaders = ShaderSystem:new()
end

function LevelSelectScene:exit()
  print("Exiting Level Select")
end

function LevelSelectScene:update(dt)
  self.animTime = self.animTime + dt
  self.confirmButton:update(dt)
  
  -- Update background stars
  for _, star in ipairs(self.stars) do
    star.y = star.y + star.speed * dt
    if star.y > 720 then
      star.y = -10
      star.x = math.random(0, 640)
    end
  end
  
  -- Update shaders
  self.shaders:update(dt)
end

function LevelSelectScene:draw()
  -- Begin shader post-processing
  self.shaders:beginDraw()
  
  -- Background
  love.graphics.setColor(0.05, 0.05, 0.15, 1)
  love.graphics.rectangle("fill", 0, 0, 640, 720)
  
  -- Draw stars
  love.graphics.setColor(1, 1, 1, 0.25)
  for _, star in ipairs(self.stars) do
    love.graphics.circle("fill", star.x, star.y, star.size)
  end
  
  -- Title
  local titleFont = love.graphics.newFont(32)
  love.graphics.setFont(titleFont)
  love.graphics.setColor(0.4, 0.9, 1, 1)
  love.graphics.printf(self.title, 0, 50, 640, "center")
  
  -- Draw level cards (2x2 grid layout)
  local cardWidth = 250
  local cardHeight = 160
  local cols = 2
  local rows = math.ceil(#self.levels / cols)
  local spacingX = 30
  local spacingY = 30
  local totalWidth = cols * cardWidth + (cols - 1) * spacingX
  local totalHeight = rows * cardHeight + (rows - 1) * spacingY
  local startX = (640 - totalWidth) / 2
  local startY = 180
  
  for i, level in ipairs(self.levels) do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)
    local cardX = startX + col * (cardWidth + spacingX)
    local cardY = startY + row * (cardHeight + spacingY)
    local isSelected = (i == self.selectedIndex)
    
    -- Card background
    if isSelected then
      love.graphics.setColor(level.color[1], level.color[2], level.color[3], 0.3)
    else
      love.graphics.setColor(0.1, 0.1, 0.2, 0.8)
    end
    love.graphics.rectangle("fill", cardX, cardY, cardWidth, cardHeight, 10, 10)
    
    -- Card border
    if isSelected then
      love.graphics.setLineWidth(3)
      love.graphics.setColor(level.color[1], level.color[2], level.color[3], 1)
    else
      love.graphics.setLineWidth(2)
      love.graphics.setColor(0.3, 0.3, 0.4, 1)
    end
    love.graphics.rectangle("line", cardX, cardY, cardWidth, cardHeight, 10, 10)
    
    -- Level number or BOSS text
    local numFont = love.graphics.newFont(level.isBoss and 28 or 48)
    love.graphics.setFont(numFont)
    if isSelected then
      love.graphics.setColor(level.color[1], level.color[2], level.color[3], 1)
    else
      love.graphics.setColor(0.5, 0.5, 0.6, 1)
    end
    local displayText = level.isBoss and "BOSS" or tostring(level.id)
    love.graphics.printf(displayText, cardX, cardY + 20, cardWidth, "center")
    
    -- Level name
    local nameFont = love.graphics.newFont(18)
    love.graphics.setFont(nameFont)
    if isSelected then
      love.graphics.setColor(1, 1, 1, 1)
    else
      love.graphics.setColor(0.7, 0.7, 0.8, 1)
    end
    love.graphics.printf(level.name, cardX + 10, cardY + 85, cardWidth - 20, "center")
    
    -- Difficulty
    local diffFont = love.graphics.newFont(14)
    love.graphics.setFont(diffFont)
    if isSelected then
      love.graphics.setColor(level.color[1], level.color[2], level.color[3], 1)
    else
      love.graphics.setColor(0.6, 0.6, 0.7, 1)
    end
    love.graphics.printf(level.difficulty, cardX + 10, cardY + 120, cardWidth - 20, "center")
  end
  
  -- Instructions
  local instrFont = love.graphics.newFont(16)
  love.graphics.setFont(instrFont)
  love.graphics.setColor(0.7, 0.7, 0.7, 1)
  love.graphics.printf("Use arrow keys or click to select", 0, 540, 640, "center")
  
  -- Draw level description
  local level = self.levels[self.selectedIndex]
  local descFont = love.graphics.newFont(18)
  love.graphics.setFont(descFont)
  love.graphics.setColor(level.color[1], level.color[2], level.color[3], 1)
  love.graphics.printf(level.description, 50, 575, 540, "center")
  
  -- Draw confirm button
  self.confirmButton:draw()
  
  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
  
  -- End shader post-processing
  self.shaders:endDraw()
end

function LevelSelectScene:keypressed(key)
  if key == "escape" then
    AudioSystem:playSound("click_short")
    SceneManager:switch("menu")
  elseif key == "left" then
    AudioSystem:playSound("click_short")
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex < 1 then
      self.selectedIndex = #self.levels
    end
  elseif key == "right" then
    AudioSystem:playSound("click_short")
    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.levels then
      self.selectedIndex = 1
    end
  elseif key == "up" then
    AudioSystem:playSound("click_short")
    -- Move up by 2 (one row)
    self.selectedIndex = self.selectedIndex - 2
    if self.selectedIndex < 1 then
      self.selectedIndex = self.selectedIndex + #self.levels
    end
  elseif key == "down" then
    AudioSystem:playSound("click_short")
    -- Move down by 2 (one row)
    self.selectedIndex = self.selectedIndex + 2
    if self.selectedIndex > #self.levels then
      self.selectedIndex = self.selectedIndex - #self.levels
    end
  elseif key == "return" or key == "space" then
    AudioSystem:playSound("click_long")
    local selectedLevel = self.levels[self.selectedIndex]
    SceneManager:switch("characterSelect", selectedLevel.id, selectedLevel.isBoss)
  end
end

function LevelSelectScene:mousepressed(x, y, button)
  -- Check if clicking on level cards (2x2 grid)
  local cardWidth = 250
  local cardHeight = 160
  local cols = 2
  local spacingX = 30
  local spacingY = 30
  local totalWidth = cols * cardWidth + (cols - 1) * spacingX
  local startX = (640 - totalWidth) / 2
  local startY = 180
  
  for i = 1, #self.levels do
    local col = (i - 1) % cols
    local row = math.floor((i - 1) / cols)
    local cardX = startX + col * (cardWidth + spacingX)
    local cardY = startY + row * (cardHeight + spacingY)
    if x >= cardX and x <= cardX + cardWidth and y >= cardY and y <= cardY + cardHeight then
      AudioSystem:playSound("click_short")
      self.selectedIndex = i
      return
    end
  end
  
  -- Check confirm button
  self.confirmButton:mousepressed(x, y, button)
end

return LevelSelectScene
