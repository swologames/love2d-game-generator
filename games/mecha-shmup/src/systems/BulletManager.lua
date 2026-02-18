-- BulletManager.lua
-- Centralized bullet management system for enemy bullets
-- Handles bullets independently from enemy lifecycle

local BulletManager = {}
BulletManager.__index = BulletManager

function BulletManager:new(particleSystem)
  local instance = setmetatable({}, self)
  
  instance.bullets = {}  -- All active bullets
  instance.particles = particleSystem  -- Reference to particle system for effects
  
  return instance
end

function BulletManager:addBullet(bullet, creatorEnemy)
  -- Store the bullet with a reference to its creator
  bullet.creatorId = creatorEnemy and creatorEnemy.id or nil
  bullet.creatorAlive = true
  table.insert(self.bullets, bullet)
end

function BulletManager:notifyEnemyRemoved(enemyId)
  -- Called when an enemy is removed (dies or goes off-screen)
  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    
    if bullet.creatorId == enemyId then
      bullet.creatorAlive = false
      
      -- Ethereal bullets disappear when creator is removed
      if bullet.bulletType == "ethereal" then
        -- Create disintegration effect
        if self.particles then
          self.particles:bulletDisintegrate(bullet.x, bullet.y, bullet.size, bullet.color)
        end
        table.remove(self.bullets, i)
      end
      -- Solid bullets persist but stop pattern updates (already handled)
    end
  end
end

function BulletManager:update(dt, playerX, playerY, enemies)
  -- Create a map of alive enemies for quick lookup
  local aliveEnemies = {}
  for _, enemy in ipairs(enemies) do
    if enemy.alive then
      aliveEnemies[enemy.id] = enemy
    end
  end
  
  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    
    -- Track bullet lifetime
    bullet.timer = (bullet.timer or 0) + dt
    
    -- Find the creator enemy if it still exists
    local creatorEnemy = bullet.creatorId and aliveEnemies[bullet.creatorId] or nil
    
    -- Update multi-phase bullet behavior (only if creator is alive or bullet is solid)
    if creatorEnemy or (bullet.bulletType == "solid" and not bullet.patternStopped) then
      -- Mark solid bullets to stop pattern when creator dies
      if not creatorEnemy and bullet.bulletType == "solid" then
        bullet.patternStopped = true
      end
      
      -- Only update pattern if not stopped
      if not bullet.patternStopped and creatorEnemy then
        self:updateBulletPhase(bullet, dt, playerX, playerY)
      end
    end
    
    -- Update position
    bullet.x = bullet.x + (bullet.vx or 0) * dt
    bullet.y = bullet.y + (bullet.vy or 0) * dt
    
    -- Check if bullet has expired (multi-phase bullets expire when all phases complete)
    local totalDuration = 0
    if bullet.phases then
      for _, phase in ipairs(bullet.phases) do
        totalDuration = totalDuration + phase.duration
      end
      -- If we've exceeded total phase duration, remove bullet
      if bullet.timer > totalDuration then
        if self.particles then
          self.particles:bulletDisintegrate(bullet.x, bullet.y, bullet.size, bullet.color)
        end
        table.remove(self.bullets, i)
        goto continue
      end
    end
    
    -- Check orphaned bullet lifetime (solid bullets after creator dies)
    if bullet.bulletType == "solid" and not creatorEnemy then
      if bullet.timer > 8.0 then
        if self.particles then
          self.particles:bulletDisintegrate(bullet.x, bullet.y, bullet.size, bullet.color)
        end
        table.remove(self.bullets, i)
        goto continue
      end
    end
    
    -- Remove off-screen bullets
    if bullet.y > 750 or bullet.y < -50 or bullet.x < -50 or bullet.x > 690 then
      if self.particles then
        self.particles:bulletDisintegrate(bullet.x, bullet.y, bullet.size, bullet.color)
      end
      table.remove(self.bullets, i)
    end
    
    ::continue::
  end
end

function BulletManager:updateBulletPhase(bullet, dt, playerX, playerY)
  -- Multi-phase bullet behavior (copied from Enemy.lua)
  if not bullet.phases then return end
  
  -- Check for phase transition
  local currentPhase = bullet.phases[bullet.currentPhase or 1]
  if not currentPhase then return end
  
  if (bullet.phaseTimer or 0) >= currentPhase.duration then
    bullet.currentPhase = (bullet.currentPhase or 1) + 1
    bullet.phaseTimer = 0
    
    -- If out of phases, use last phase indefinitely
    if bullet.currentPhase > #bullet.phases then
      bullet.currentPhase = #bullet.phases
    end
  end
  
  bullet.phaseTimer = (bullet.phaseTimer or 0) + dt
  
  -- Execute current phase behavior
  local phase = bullet.phases[bullet.currentPhase or 1]
  if not phase then return end
  
  local behavior = phase.behavior
  
  if behavior == "homing" then
    -- Homing behavior: gradually turn toward player
    local dx = playerX - bullet.x
    local dy = playerY - bullet.y
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      local targetVx = (dx / dist) * phase.speed
      local targetVy = (dy / dist) * phase.speed
      local turnRate = phase.turnRate or 2.0
      
      bullet.vx = bullet.vx + (targetVx - bullet.vx) * turnRate * dt
      bullet.vy = bullet.vy + (targetVy - bullet.vy) * turnRate * dt
      
      -- Normalize and apply speed
      local currentSpeed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
      if currentSpeed > 0 then
        bullet.vx = (bullet.vx / currentSpeed) * phase.speed
        bullet.vy = (bullet.vy / currentSpeed) * phase.speed
      end
    end
    
  elseif behavior == "sine_wave" then
    -- Move in a sine wave pattern
    local amplitude = phase.amplitude or 50
    local frequency = phase.frequency or 2.0
    
    bullet.timer = (bullet.timer or 0) + dt
    local offset = math.sin(bullet.timer * frequency) * amplitude
    
    -- Calculate perpendicular direction
    local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    if speed > 0 then
      local perpX = -bullet.vy / speed
      local perpY = bullet.vx / speed
      
      -- Apply the offset change
      local lastOffset = bullet.lastOffset or 0
      local offsetDelta = offset - lastOffset
      bullet.lastOffset = offset
      
      bullet.x = bullet.x + perpX * offsetDelta
      bullet.y = bullet.y + perpY * offsetDelta
    end
    
  elseif behavior == "cosine_wave" then
    -- Move in a cosine wave pattern
    local amplitude = phase.amplitude or 50
    local frequency = phase.frequency or 2.0
    
    bullet.timer = (bullet.timer or 0) + dt
    local offset = math.cos(bullet.timer * frequency) * amplitude
    
    local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    if speed > 0 then
      local perpX = -bullet.vy / speed
      local perpY = bullet.vx / speed
      
      local lastOffset = bullet.lastOffset or 0
      local offsetDelta = offset - lastOffset
      bullet.lastOffset = offset
      
      bullet.x = bullet.x + perpX * offsetDelta
      bullet.y = bullet.y + perpY * offsetDelta
    end
    
  elseif behavior == "accelerate" then
    local acceleration = phase.acceleration or 100
    local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    if speed > 0 then
      local newSpeed = speed + acceleration * dt
      bullet.vx = (bullet.vx / speed) * newSpeed
      bullet.vy = (bullet.vy / speed) * newSpeed
    end
    
  elseif behavior == "spiral" then
    local spiralRate = phase.spiralRate or 2.0
    bullet.spiralAngle = (bullet.spiralAngle or 0) + spiralRate * dt
    
    local radius = phase.radius or 40
    local speed = phase.speed or 120
    
    bullet.vx = math.cos(bullet.spiralAngle) * speed
    bullet.vy = math.sin(bullet.spiralAngle) * speed + radius
    
  elseif behavior == "spread" then
    local spreadRate = phase.spreadRate or 100
    local angle = math.atan2(bullet.vy, bullet.vx)
    local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    
    local perpX = math.cos(angle + math.pi/2)
    local perpY = math.sin(angle + math.pi/2)
    
    bullet.vx = bullet.vx + perpX * spreadRate * dt
    bullet.vy = bullet.vy + perpY * spreadRate * dt
    
  elseif behavior == "converge" then
    local convergeRate = phase.convergeRate or 80
    local targetX = bullet.phaseStartX or bullet.x
    local targetY = bullet.phaseStartY or bullet.y
    
    local dx = targetX - bullet.x
    local dy = targetY - bullet.y
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      bullet.vx = bullet.vx + (dx / dist) * convergeRate * dt
      bullet.vy = bullet.vy + (dy / dist) * convergeRate * dt
    end
    
  elseif behavior == "expand" then
    local expandRate = phase.expandRate or 50
    local centerX = bullet.phaseStartX or bullet.x
    local centerY = bullet.phaseStartY or bullet.y
    
    local dx = bullet.x - centerX
    local dy = bullet.y - centerY
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      bullet.vx = (dx / dist) * expandRate
      bullet.vy = (dy / dist) * expandRate
    end
  end
  
  -- Update bullet size if phase has size changes
  if phase.startSize and phase.endSize and phase.sizeChangeRate then
    bullet.currentSize = bullet.currentSize or phase.startSize
    if bullet.currentSize < phase.endSize then
      bullet.currentSize = math.min(phase.endSize, bullet.currentSize + phase.sizeChangeRate * dt)
    elseif bullet.currentSize > phase.endSize then
      bullet.currentSize = math.max(phase.endSize, bullet.currentSize - phase.sizeChangeRate * dt)
    end
    bullet.size = bullet.currentSize
  elseif phase.sizePulse then
    bullet.timer = (bullet.timer or 0) + dt
    local minSize = phase.sizePulse.min or 4
    local maxSize = phase.sizePulse.max or 10
    local frequency = phase.sizePulse.frequency or 3
    bullet.size = minSize + (maxSize - minSize) * (0.5 + 0.5 * math.sin(bullet.timer * frequency))
  end
end

function BulletManager:clear()
  self.bullets = {}
end

function BulletManager:getBullets()
  return self.bullets
end

return BulletManager
