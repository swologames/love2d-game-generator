-- LevelSystem.lua
-- Timeline-based level management system for scripted enemy patterns

local LevelSystem = {}
LevelSystem.__index = LevelSystem

function LevelSystem:new()
  local instance = setmetatable({}, self)
  
  instance.currentLevel = nil
  instance.levelData = nil
  instance.levelTime = 0
  instance.eventIndex = 1
  instance.isActive = false
  instance.levelComplete = false
  
  return instance
end

function LevelSystem:loadLevel(levelNumber)
  -- Load level data from file
  local levelPath = "levels.level" .. levelNumber
  local success, levelData = pcall(require, levelPath)
  
  if not success then
    print("Warning: Could not load level " .. levelNumber .. ", using fallback")
    self.levelData = nil
    self.isActive = false
    return false
  end
  
  self.currentLevel = levelNumber
  self.levelData = levelData
  self.levelTime = 0
  self.eventIndex = 1
  self.isActive = true
  self.levelComplete = false
  
  print("Loaded level: " .. levelData.name)
  return true
end

function LevelSystem:update(dt, gameScene)
  if not self.isActive or not self.levelData then
    return
  end
  
  self.levelTime = self.levelTime + dt
  
  -- Process events at current time
  while self.eventIndex <= #self.levelData.events do
    local event = self.levelData.events[self.eventIndex]
    
    if event.time <= self.levelTime then
      self:executeEvent(event, gameScene)
      self.eventIndex = self.eventIndex + 1
    else
      break
    end
  end
  
  -- Check if level is complete
  if self.levelTime >= self.levelData.duration then
    self.levelComplete = true
  end
end

function LevelSystem:executeEvent(event, gameScene)
  if event.type == "spawn" then
    -- Spawn single enemy
    gameScene:spawnEnemyAt(event.enemy, event.x, event.y)
    
  elseif event.type == "formation" then
    -- Spawn formation
    gameScene:spawnFormation(event.pattern, event.enemy, event.count)
    
  elseif event.type == "wave" then
    -- Spawn multiple enemies (legacy support)
    if event.enemies then
      for _, enemyType in ipairs(event.enemies) do
        local x = 100 + math.random() * 440
        gameScene:spawnEnemyAt(enemyType, x, -50)
      end
    end
    
  elseif event.type == "boss" then
    -- Spawn boss
    gameScene:spawnBoss()
    
  elseif event.type == "powerup" then
    -- Spawn power-up
    local x = event.x or (100 + math.random() * 440)
    local y = event.y or -50
    gameScene:spawnPowerUpAt(x, y, event.powerupType)
    
  elseif event.type == "message" then
    -- Display message
    local duration = event.duration or 2.0
    gameScene:showMessage(event.text, duration)
  
  elseif event.type == "background" then
    -- Change background theme
    gameScene:setBackground(event.theme or "space", event.instant)
    
  else
    print("Unknown event type: " .. tostring(event.type))
  end
end

function LevelSystem:reset()
  self.levelTime = 0
  self.eventIndex = 1
  self.levelComplete = false
end

function LevelSystem:isLevelComplete()
  return self.levelComplete
end

function LevelSystem:getCurrentLevelName()
  if self.levelData then
    return self.levelData.name
  end
  return "Unknown"
end

function LevelSystem:disable()
  self.isActive = false
end

function LevelSystem:enable()
  self.isActive = true
end

return LevelSystem
