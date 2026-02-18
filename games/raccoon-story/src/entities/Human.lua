-- Human Enemy Entity
-- Patrol behavior with vision cone detection and chase

local Human = {}
Human.__index = Human

function Human:new(x, y, patrolPoints)
  local instance = setmetatable({}, self)
  
  -- Position
  instance.x = x or 0
  instance.y = y or 0
  
  -- Size (32x48 base, scaled to 64x96)
  instance.width = 64
  instance.height = 96
  
  -- Movement
  instance.speed = 120 -- px/s (slower than player's 150)
  instance.vx = 0
  instance.vy = 0
  
  -- State
  instance.state = "patrol" -- patrol, chase, return
  instance.direction = "down" -- facing direction
  
  -- Patrol behavior
  instance.patrolPoints = patrolPoints or {{x = x, y = y}}
  instance.currentPatrolIndex = 1
  instance.patrolWaitTime = 2 -- seconds to wait at each point
  instance.patrolWaitTimer = 0
  
  -- Detection
  instance.visionRange = 200 -- pixels
  instance.visionAngle = math.pi -- 180 degrees (π radians)
  instance.detectionTimer = 0
  instance.detectionDelay = 0.5 -- seconds before fully detecting
  
  -- Chase
  instance.chaseTimer = 0
  instance.chaseMinDuration = 5 -- minimum seconds
  instance.chaseMaxDuration = 10 -- maximum seconds
  instance.chaseDuration = 7 -- actual duration (randomized)
  instance.target = nil
  instance.lastSeenX = 0
  instance.lastSeenY = 0
  
  -- Return to patrol
  instance.returnToX = x
  instance.returnToY = y
  
  -- Sprites
  instance.idleSprite = nil
  instance.walkSprite = nil
  instance.currentFrame = 1
  instance.animTimer = 0
  instance.animFPS = 8
  
  -- Collision radius for simplified collision
  instance.radius = 20
  
  return instance
end

-- Set sprites
function Human:setSprites(idleSprite, walkFrames)
  self.idleSprite = idleSprite
  self.walkSprite = walkFrames
end

-- Update
function Human:update(dt, player)
  -- Update animation
  self:updateAnimation(dt)
  
  -- State machine
  if self.state == "patrol" then
    self:updatePatrol(dt)
    self:checkDetection(player, dt)
  elseif self.state == "chase" then
    self:updateChase(dt, player)
  elseif self.state == "return" then
    self:updateReturn(dt)
  end
  
  -- Apply velocity
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  
  -- Update facing direction based on velocity
  self:updateDirection()
end

-- Update patrol behavior
function Human:updatePatrol(dt)
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
      -- Move to next patrol point
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

-- Check if player is in vision cone
function Human:checkDetection(player, dt)
  local dx = player.x - self.x
  local dy = player.y - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  -- Check range
  if dist > self.visionRange then
    self.detectionTimer = 0
    return false
  end
  
  -- Check angle (vision cone)
  local angleToPlayer = math.atan2(dy, dx)
  local facingAngle = self:getFacingAngle()
  
  -- Normalize angle difference
  local angleDiff = math.abs(angleToPlayer - facingAngle)
  if angleDiff > math.pi then
    angleDiff = 2 * math.pi - angleDiff
  end
  
  -- Within vision cone?
  if angleDiff < self.visionAngle / 2 then
    -- Player spotted!
    self.detectionTimer = self.detectionTimer + dt
    
    if self.detectionTimer >= self.detectionDelay then
      self:startChase(player)
      return true
    end
  else
    self.detectionTimer = 0
  end
  
  return false
end

-- Start chasing the player
function Human:startChase(player)
  self.state = "chase"
  self.target = player
  self.chaseTimer = 0
  self.chaseDuration = math.random(self.chaseMinDuration * 10, self.chaseMaxDuration * 10) / 10
  print("[Human] Started chasing player for " .. self.chaseDuration .. " seconds")
end

-- Update chase behavior
function Human:updateChase(dt, player)
  self.chaseTimer = self.chaseTimer + dt
  
  -- Update last seen position
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
  
  -- Check if should stop chasing
  if self.chaseTimer >= self.chaseDuration then
    self:stopChase()
  end
  
  -- Check if caught player (collision)
  if dist < (self.radius + player.width / 2) then
    self:catchPlayer(player)
  end
end

-- Stop chasing and return to patrol
function Human:stopChase()
  print("[Human] Stopped chasing, returning to patrol")
  self.state = "return"
  self.target = nil
  
  -- Set return position to nearest patrol point
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

-- Return to patrol route
function Human:updateReturn(dt)
  local dx = self.returnToX - self.x
  local dy = self.returnToY - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist < 10 then
    -- Reached return point, resume patrol
    self.state = "patrol"
    self.vx = 0
    self.vy = 0
  else
    -- Move toward return point
    dx = dx / dist
    dy = dy / dist
    self.vx = dx * self.speed
    self.vy = dy * self.speed
  end
end

-- Catch the player
function Human:catchPlayer(player)
  print("[Human] Caught the player!")
  -- Player drops 1-2 items
  local dropCount = math.random(1, 2)
  -- This will be handled by the game scene
  return dropCount
end

-- Get facing angle based on direction
function Human:getFacingAngle()
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

-- Update direction based on velocity
function Human:updateDirection()
  if self.vx == 0 and self.vy == 0 then
    return -- Keep current direction when idle
  end
  
  local angle = math.atan2(self.vy, self.vx)
  
  -- Convert to 8-directional
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
function Human:updateAnimation(dt)
  if not self.walkSprite then return end
  
  self.animTimer = self.animTimer + dt
  local frameDuration = 1 / self.animFPS
  
  if self.animTimer >= frameDuration then
    self.animTimer = self.animTimer - frameDuration
    self.currentFrame = (self.currentFrame % #self.walkSprite) + 1
  end
end

-- Draw
function Human:draw()
  local lg = love.graphics
  
  -- Draw sprite or placeholder
  if self.walkSprite and self.currentFrame <= #self.walkSprite then
    local sprite = self.walkSprite[self.currentFrame]
    
    -- Draw sprite (centered on position)
    lg.setColor(1, 1, 1)
    
    -- Flip sprite based on direction
    local scaleX = 1
    if self.direction == "left" or self.direction == "up-left" or self.direction == "down-left" then
      scaleX = -1
    end
    
    lg.draw(sprite, self.x, self.y, 0, scaleX, 1, self.width / 2, self.height / 2)
  elseif self.idleSprite then
    lg.setColor(1, 1, 1)
    lg.draw(self.idleSprite, self.x, self.y, 0, 1, 1, self.width / 2, self.height / 2)
  else
    -- Placeholder (red rectangle)
    lg.setColor(0.8, 0.3, 0.3)
    lg.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)
    lg.setColor(1, 1, 1)
    lg.circle("line", self.x, self.y, self.radius)
  end
  
  -- Debug: Draw vision cone
  if self.state == "patrol" and false then -- Set to true for debug
    lg.setColor(1, 1, 0, 0.2)
    local facingAngle = self:getFacingAngle()
    lg.arc("fill", self.x, self.y, self.visionRange, 
           facingAngle - self.visionAngle / 2, 
           facingAngle + self.visionAngle / 2)
  end
  
  -- State indicator
  if true then -- Debug
    lg.setColor(1, 1, 1)
    lg.print(self.state, self.x - 20, self.y - self.height / 2 - 15, 0, 0.7)
  end
end

return Human
