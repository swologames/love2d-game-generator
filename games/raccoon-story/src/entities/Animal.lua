-- Animal Entity
-- Competing animals: possums, cats, and crows
-- They compete for trash but don't chase player for long

local Animal = {}
Animal.__index = Animal

function Animal:new(x, y, animalType)
  local instance = setmetatable({}, self)
  
  -- Position
  instance.x = x or 0
  instance.y = y or 0
  
  -- Type: "possum", "cat", or "crow"
  instance.animalType = animalType or "possum"
  
  -- Size (varies by type)
  instance.width = 64
  instance.height = 64
  
  -- Movement (varies by type)
  instance.speed = 0
  instance.vx = 0
  instance.vy = 0
  
  -- State
  instance.state = "wander" -- wander, seek_trash, grab_trash, flee
  instance.direction = "down"
  
  -- Wander behavior
  instance.wanderTargetX = x
  instance.wanderTargetY = y
  instance.wanderWaitTimer = 0
  instance.wanderWaitTime = 2
  
  -- Trash seeking
  instance.targetTrash = nil
  instance.trashDetectionRange = 150
  
  -- Player interaction
  instance.playerDetectionRange = 100
  instance.fleeTimer = 0
  instance.fleeDuration = 0
  instance.hasTrash = false
  
  -- Sprites
  instance.sprite = nil
  
  -- Collision radius
  instance.radius = 16
  
  -- Initialize type-specific stats
  instance:initTypeStats()
  
  return instance
end

-- Initialize stats based on animal type
function Animal:initTypeStats()
  if self.animalType == "possum" then
    -- Slow but determined
    self.speed = 80
    self.trashDetectionRange = 120
    self.playerDetectionRange = 80
    self.fleeDuration = 2 -- brief flee
    
  elseif self.animalType == "cat" then
    -- Quick and territorial
    self.speed = 160
    self.trashDetectionRange = 150
    self.playerDetectionRange = 120
    self.fleeDuration = 3 -- moderate flee, might return
    
  elseif self.animalType == "crow" then
    -- Flying, opportunistic
    self.speed = 100
    self.trashDetectionRange = 200
    self.playerDetectionRange = 150
    self.fleeDuration = 5 -- flies away for longer
    self.width = 64
    self.height = 64
  end
end

-- Set sprite
function Animal:setSprite(sprite)
  self.sprite = sprite
end

-- Update
function Animal:update(dt, player, trashItems)
  -- Update timers
  if self.wanderWaitTimer > 0 then
    self.wanderWaitTimer = self.wanderWaitTimer - dt
  end
  
  if self.fleeTimer > 0 then
    self.fleeTimer = self.fleeTimer - dt
  end
  
  -- State machine
  if self.state == "wander" then
    self:updateWander(dt)
    self:checkForTrash(trashItems)
    self:checkPlayerProximity(player)
    
  elseif self.state == "seek_trash" then
    self:updateSeekTrash(dt)
    self:checkPlayerProximity(player)
    
  elseif self.state == "grab_trash" then
    self:updateGrabTrash(dt)
    self:checkPlayerProximity(player)
    
  elseif self.state == "flee" then
    self:updateFlee(dt, player)
  end
  
  -- Apply velocity
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  
  -- Update direction
  self:updateDirection()
end

-- Wander around
function Animal:updateWander(dt)
  local dx = self.wanderTargetX - self.x
  local dy = self.wanderTargetY - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist < 20 then
    -- Reached wander point, pick new one
    self.vx = 0
    self.vy = 0
    
    if self.wanderWaitTimer <= 0 then
      -- Pick new random nearby point
      local angle = math.random() * math.pi * 2
      local distance = math.random(50, 150)
      self.wanderTargetX = self.x + math.cos(angle) * distance
      self.wanderTargetY = self.y + math.sin(angle) * distance
      self.wanderWaitTimer = self.wanderWaitTime
    end
  else
    -- Move toward wander target
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed * 0.5 -- slower while wandering
    self.vy = dy * self.speed * 0.5
  end
end

-- Check for nearby trash
function Animal:checkForTrash(trashItems)
  for _, trash in ipairs(trashItems) do
    if not trash.collected then
      local dx = trash.x - self.x
      local dy = trash.y - self.y
      local dist = math.sqrt(dx * dx + dy * dy)
      
      if dist < self.trashDetectionRange then
        -- Found trash!
        self.targetTrash = trash
        self.state = "seek_trash"
        print("[" .. self.animalType .. "] Found trash!")
        break
      end
    end
  end
end

-- Seek trash
function Animal:updateSeekTrash(dt)
  if not self.targetTrash or self.targetTrash.collected then
    -- Trash gone, go back to wandering
    self.state = "wander"
    self.targetTrash = nil
    return
  end
  
  local dx = self.targetTrash.x - self.x
  local dy = self.targetTrash.y - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist < 30 then
    -- Reached trash, grab it!
    self.state = "grab_trash"
    self.vx = 0
    self.vy = 0
    self.wanderWaitTimer = 1 -- wait while grabbing
  else
    -- Move toward trash
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed
    self.vy = dy * self.speed
  end
end

-- Grab trash
function Animal:updateGrabTrash(dt)
  if self.wanderWaitTimer <= 0 then
    -- Collected the trash!
    if self.targetTrash and not self.targetTrash.collected then
      self.targetTrash:collect()
      self.hasTrash = true
      print("[" .. self.animalType .. "] Grabbed trash!")
    end
    
    -- Go back to wandering
    self.state = "wander"
    self.targetTrash = nil
  end
end

-- Check if player is too close
function Animal:checkPlayerProximity(player)
  local dx = player.x - self.x
  local dy = player.y - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist < self.playerDetectionRange then
    -- Player too close, flee!
    self:startFlee(player)
  end
end

-- Flee from player
function Animal:startFlee(player)
  self.state = "flee"
  self.fleeTimer = self.fleeDuration
  
  -- If has trash, drop it
  if self.hasTrash then
    print("[" .. self.animalType .. "] Dropped trash while fleeing!")
    self.hasTrash = false
    -- Trash respawn would be handled by game scene
  end
  
  -- Abandon current trash target
  self.targetTrash = nil
end

-- Update flee behavior
function Animal:updateFlee(dt, player)
  -- Flee away from player
  local dx = self.x - player.x
  local dy = self.y - player.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist > 0 then
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed * 1.2 -- flee faster
    self.vy = dy * self.speed * 1.2
  end
  
  -- Check if flee timer expired
  if self.fleeTimer <= 0 then
    self.state = "wander"
    self.vx = 0
    self.vy = 0
  end
end

-- Update direction
function Animal:updateDirection()
  if self.vx == 0 and self.vy == 0 then
    return
  end
  
  local angle = math.atan2(self.vy, self.vx)
  
  if angle >= -math.pi / 4 and angle < math.pi / 4 then
    self.direction = "right"
  elseif angle >= math.pi / 4 and angle < 3 * math.pi / 4 then
    self.direction = "down"
  elseif angle >= 3 * math.pi / 4 or angle < -3 * math.pi / 4 then
    self.direction = "left"
  else
    self.direction = "up"
  end
end

-- Draw
function Animal:draw()
  local lg = love.graphics
  
  -- Draw sprite or placeholder
  if self.sprite then
    lg.setColor(1, 1, 1)
    
    local scaleX = 1
    if self.direction == "left" then
      scaleX = -1
    end
    
    -- For crow, add a bobbing effect (flying)
    local yOffset = 0
    if self.animalType == "crow" then
      yOffset = math.sin(love.timer.getTime() * 3) * 5
    end
    
    lg.draw(self.sprite, self.x, self.y + yOffset, 0, scaleX, 1, self.width / 2, self.height / 2)
  else
    -- Placeholder based on type
    if self.animalType == "possum" then
      lg.setColor(0.8, 0.8, 0.75)
    elseif self.animalType == "cat" then
      lg.setColor(0.9, 0.6, 0.3)
    elseif self.animalType == "crow" then
      lg.setColor(0.1, 0.1, 0.15)
    end
    lg.circle("fill", self.x, self.y, self.radius)
    
    lg.setColor(1, 1, 1)
    lg.circle("line", self.x, self.y, self.radius)
  end
  
  -- State indicator (debug)
  if true then
    lg.setColor(1, 1, 1)
    lg.print(self.animalType .. ":" .. self.state, self.x - 30, self.y - self.height / 2 - 15, 0, 0.6)
  end
  
  -- Trash indicator
  if self.hasTrash then
    lg.setColor(0.8, 0.6, 0.2)
    lg.circle("fill", self.x + 15, self.y - 15, 5)
  end
end

return Animal
