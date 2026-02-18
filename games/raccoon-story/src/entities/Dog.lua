-- Dog Enemy Entity
-- Faster patrol with more aggressive chase behavior

local Dog = {}
Dog.__index = Dog

function Dog:new(x, y, patrolPoints)
  local instance = setmetatable({}, self)
  
  -- Position
  instance.x = x or 0
  instance.y = y or 0
  
  -- Size (32x32 base, scaled to 64x64)
  instance.width = 64
  instance.height = 64
  
  -- Movement
  instance.speed = 180 -- px/s (faster than player's 150)
  instance.vx = 0
  instance.vy = 0
  
  -- State
  instance.state = "patrol" -- patrol, chase, return, bark
  instance.direction = "down"
  
  -- Patrol behavior
  instance.patrolPoints = patrolPoints or {{x = x, y = y}}
  instance.currentPatrolIndex = 1
  instance.patrolWaitTime = 1.5 -- seconds (less wait than human)
  instance.patrolWaitTimer = 0
  
  -- Detection (smaller vision cone but still effective)
  instance.visionRange = 150 -- pixels (less than human)
  instance.visionAngle = math.pi / 2 -- 90 degrees
  instance.detectionTimer = 0
  instance.detectionDelay = 0.3 -- faster detection
  
  -- Chase
  instance.chaseTimer = 0
  instance.chaseMinDuration = 10 -- more aggressive
  instance.chaseMaxDuration = 15
  instance.chaseDuration = 12
  instance.target = nil
  instance.lastSeenX = 0
  instance.lastSeenY = 0
  
  -- Bark state
  instance.barkTimer = 0
  instance.barkDuration = 0.5
  instance.hasBarked = false
  
  -- Return to patrol
  instance.returnToX = x
  instance.returnToY = y
  
  -- Sprites
  instance.idleSprite = nil
  instance.runSprite = nil
  instance.currentFrame = 1
  instance.animTimer = 0
  instance.animFPS = 12 -- faster animation
  
  -- Collision radius
  instance.radius = 18
  
  return instance
end

-- Set sprites
function Dog:setSprites(idleSprite, runFrames)
  self.idleSprite = idleSprite
  self.runSprite = runFrames
end

-- Update
function Dog:update(dt, player)
  -- Update animation
  self:updateAnimation(dt)
  
  -- State machine
  if self.state == "patrol" then
    self:updatePatrol(dt)
    self:checkDetection(player, dt)
  elseif self.state == "bark" then
    self:updateBark(dt, player)
  elseif self.state == "chase" then
    self:updateChase(dt, player)
  elseif self.state == "return" then
    self:updateReturn(dt)
  end
  
  -- Apply velocity
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  
  -- Update facing direction
  self:updateDirection()
end

-- Update patrol behavior
function Dog:updatePatrol(dt)
  if #self.patrolPoints < 2 then
    -- No patrol route, just idle
    self.vx = 0
    self.vy = 0
    return
  end
  
  local targetPoint = self.patrolPoints[self.currentPatrolIndex]
  local dx = targetPoint.x - self.x
  local dy = targetPoint.y - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist < 10 then
    -- Reached patrol point
    self.vx = 0
    self.vy = 0
    
    self.patrolWaitTimer = self.patrolWaitTimer + dt
    if self.patrolWaitTimer >= self.patrolWaitTime then
      self.patrolWaitTimer = 0
      self.currentPatrolIndex = (self.currentPatrolIndex % #self.patrolPoints) + 1
    end
  else
    -- Move toward patrol point
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed
    self.vy = dy * self.speed
  end
end

-- Check detection
function Dog:checkDetection(player, dt)
  local dx = player.x - self.x
  local dy = player.y - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  -- Check range
  if dist > self.visionRange then
    self.detectionTimer = 0
    return false
  end
  
  -- Check angle
  local angleToPlayer = math.atan2(dy, dx)
  local facingAngle = self:getFacingAngle()
  
  local angleDiff = math.abs(angleToPlayer - facingAngle)
  if angleDiff > math.pi then
    angleDiff = 2 * math.pi - angleDiff
  end
  
  if angleDiff < self.visionAngle / 2 then
    self.detectionTimer = self.detectionTimer + dt
    
    if self.detectionTimer >= self.detectionDelay then
      -- Bark first!
      self:startBark(player)
      return true
    end
  else
    self.detectionTimer = 0
  end
  
  return false
end

-- Bark when detecting player
function Dog:startBark(player)
  self.state = "bark"
  self.target = player
  self.barkTimer = 0
  self.hasBarked = false
  self.vx = 0
  self.vy = 0
  print("[Dog] BARK! Player detected!")
  -- TODO: Play bark sound
end

-- Update bark state
function Dog:updateBark(dt, player)
  self.barkTimer = self.barkTimer + dt
  
  if not self.hasBarked and self.barkTimer >= self.barkDuration / 2 then
    self.hasBarked = true
    -- Could trigger sound effect here
  end
  
  if self.barkTimer >= self.barkDuration then
    -- Start chasing after bark
    self:startChase(player)
  end
end

-- Start chase
function Dog:startChase(player)
  self.state = "chase"
  self.target = player
  self.chaseTimer = 0
  self.chaseDuration = math.random(self.chaseMinDuration * 10, self.chaseMaxDuration * 10) / 10
  print("[Dog] Started chasing for " .. self.chaseDuration .. " seconds")
end

-- Update chase
function Dog:updateChase(dt, player)
  self.chaseTimer = self.chaseTimer + dt
  
  -- Update last seen
  self.lastSeenX = player.x
  self.lastSeenY = player.y
  
  -- Chase toward player
  local dx = player.x - self.x
  local dy = player.y - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist > 5 then
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed
    self.vy = dy * self.speed
  else
    self.vx = 0
    self.vy = 0
  end
  
  -- Check if should stop
  if self.chaseTimer >= self.chaseDuration then
    self:stopChase()
  end
  
  -- Check collision
  if dist < (self.radius + player.width / 2) then
    self:catchPlayer(player)
  end
end

-- Stop chase
function Dog:stopChase()
  print("[Dog] Stopped chasing, returning")
  self.state = "return"
  self.target = nil
  
  -- Find nearest patrol point
  local nearestDist = math.huge
  for i, point in ipairs(self.patrolPoints) do
    local dx = point.x - self.x
    local dy = point.y - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist < nearestDist then
      nearestDist = dist
      self.returnToX = point.x
      self.returnToY = point.y
      self.currentPatrolIndex = i
    end
  end
end

-- Return to patrol
function Dog:updateReturn(dt)
  local dx = self.returnToX - self.x
  local dy = self.returnToY - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist < 10 then
    self.state = "patrol"
    self.vx = 0
    self.vy = 0
  else
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed
    self.vy = dy * self.speed
  end
end

-- Catch player (dogs make you drop more items)
function Dog:catchPlayer(player)
  print("[Dog] Caught the player!")
  -- Player drops 2-3 items
  local dropCount = math.random(2, 3)
  return dropCount
end

-- Get facing angle
function Dog:getFacingAngle()
  if self.direction == "right" then return 0
  elseif self.direction == "down" then return math.pi / 2
  elseif self.direction == "left" then return math.pi
  elseif self.direction == "up" then return -math.pi / 2
  elseif self.direction == "down-right" then return math.pi / 4
  elseif self.direction == "down-left" then return 3 * math.pi / 4
  elseif self.direction == "up-left" then return -3 * math.pi / 4
  elseif self.direction == "up-right" then return -math.pi / 4
  end
  return 0
end

-- Update direction
function Dog:updateDirection()
  if self.vx == 0 and self.vy == 0 then
    return
  end
  
  local angle = math.atan2(self.vy, self.vx)
  
  if angle >= -math.pi / 8 and angle < math.pi / 8 then
    self.direction = "right"
  elseif angle >= math.pi / 8 and angle < 3 * math.pi / 8 then
    self.direction = "down-right"
  elseif angle >= 3 * math.pi / 8 and angle < 5 * math.pi / 8 then
    self.direction = "down"
  elseif angle >= 5 * math.pi / 8 and angle < 7 * math.pi / 8 then
    self.direction = "down-left"
  elseif angle >= 7 * math.pi / 8 or angle < -7 * math.pi / 8 then
    self.direction = "left"
  elseif angle >= -7 * math.pi / 8 and angle < -5 * math.pi / 8 then
    self.direction = "up-left"
  elseif angle >= -5 * math.pi / 8 and angle < -3 * math.pi / 8 then
    self.direction = "up"
  elseif angle >= -3 * math.pi / 8 and angle < -math.pi / 8 then
    self.direction = "up-right"
  end
end

-- Update animation
function Dog:updateAnimation(dt)
  if not self.runSprite then return end
  
  self.animTimer = self.animTimer + dt
  local frameDuration = 1 / self.animFPS
  
  if self.animTimer >= frameDuration then
    self.animTimer = self.animTimer - frameDuration
    self.currentFrame = (self.currentFrame % #self.runSprite) + 1
  end
end

-- Draw
function Dog:draw()
  local lg = love.graphics
  
  -- Draw sprite or placeholder
  if self.runSprite and self.currentFrame <= #self.runSprite then
    local sprite = self.runSprite[self.currentFrame]
    
    lg.setColor(1, 1, 1)
    
    local scaleX = 1
    if self.direction == "left" or self.direction == "up-left" or self.direction == "down-left" then
      scaleX = -1
    end
    
    lg.draw(sprite, self.x, self.y, 0, scaleX, 1, self.width / 2, self.height / 2)
  elseif self.idleSprite then
    lg.setColor(1, 1, 1)
    lg.draw(self.idleSprite, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
  else
    -- Placeholder (brown rectangle)
    lg.setColor(0.6, 0.4, 0.2)
    lg.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    lg.setColor(1, 1, 1)
    lg.circle("line", self.x, self.y, self.radius)
  end
  
  -- Bark indicator
  if self.state == "bark" then
    lg.setColor(1, 1, 0)
    lg.print("BARK!", self.x - 15, self.y - self.height / 2 - 20, 0, 1)
  end
  
  -- State indicator (debug)
  if true then
    lg.setColor(1, 1, 1)
    lg.print(self.state, self.x - 20, self.y - self.height / 2 - 35, 0, 0.7)
  end
end

return Dog
