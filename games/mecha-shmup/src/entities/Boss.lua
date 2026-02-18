-- Boss.lua
-- Boss entity for Mecha Shmup
-- Epic 5-Phase Boss System - Vor'kath the Ravager

local Boss = {}
Boss.__index = Boss

-- Phase Configuration: Each phase has unique HP and patterns
local PHASE_CONFIG = {
  {
    hp = 800,
    name = "Phase 1: Awakening",
    color = {1, 0.2, 0.2},
    attackCooldown = 2.0,
    moveSpeed = 80,
    patterns = {"circleSpray", "targetedBarrage"}
  },
  {
    hp = 1000,
    name = "Phase 2: Enraged",
    color = {1, 0.4, 0.1},
    attackCooldown = 1.5,
    moveSpeed = 120,
    patterns = {"dualSpiral", "waveBarrage", "crossPattern"}
  },
  {
    hp = 1200,
    name = "Phase 3: Critical",
    color = {1, 0.6, 0.2},
    attackCooldown = 1.2,
    moveSpeed = 150,
    patterns = {"explosionRing", "homingSwarm", "laserSweep"}
  },
  {
    hp = 1400,
    name = "Phase 4: Desperate",
    color = {1, 0.3, 0.8},
    attackCooldown = 0.9,
    moveSpeed = 180,
    patterns = {"chaosStorm", "spiralBarrage", "bulletHell"}
  },
  {
    hp = 1600,
    name = "Phase 5: Final Stand",
    color = {0.8, 0.1, 1},
    attackCooldown = 0.7,
    moveSpeed = 200,
    patterns = {"ultimatePattern", "doubleCross", "finalBarrage"}
  }
}

function Boss:new(type, x, y)
  local instance = setmetatable({}, self)
  
  -- Vor'kath the Ravager stats
  instance.name = "VOR'KATH THE RAVAGER"
  instance.type = type or "vorkath"
  instance.startX = x or 320
  instance.startY = y or -150  -- Start above screen
  instance.x = instance.startX
  instance.y = instance.startY
  
  -- Large imposing size
  instance.size = 80
  instance.hitboxSize = 60
  instance.score = 50000
  
  -- Phase system
  instance.phase = 1
  instance.totalPhases = 5
  instance.phaseHealth = PHASE_CONFIG[1].hp
  instance.maxPhaseHealth = PHASE_CONFIG[1].hp
  instance.phaseData = PHASE_CONFIG[1]
  
  -- State management
  instance.state = "intro"  -- intro, fighting, phase_transition, dying, defeated
  instance.alive = true
  instance.introTimer = 0
  instance.transitionTimer = 0
  instance.phaseTransitionDuration = 3.0
  instance.deathTimer = 0
  instance.deathDuration = 2.0
  
  -- Combat
  instance.attackTimer = 0
  instance.attackPattern = nil
  instance.patternStep = 0
  instance.bullets = {}
  
  -- Movement
  instance.moveTimer = 0
  instance.targetX = 320  -- Center position
  instance.targetY = 120  -- Back of screen
  instance.movementPattern = "hover"
  instance.movementTimer = 0
  
  -- Visual effects
  instance.flashTime = 0
  instance.glowTime = 0
  instance.rotationAngle = 0
  instance.pulsePhase = 0
  
  -- Animation state
  instance.wingAngle = 0
  instance.coreRotation = 0
  
  return instance
end

function Boss:update(dt, playerX, playerY)
  if not self.alive then return end
  
  -- Update timers and animations
  self.glowTime = self.glowTime + dt
  self.pulsePhase = self.pulsePhase + dt
  self.wingAngle = self.wingAngle + dt * 2
  self.coreRotation = self.coreRotation + dt * (0.5 + self.phase * 0.3)
  
  if self.flashTime > 0 then
    self.flashTime = self.flashTime - dt
  end
  
  -- State machine
  if self.state == "dying" then
    self:updateDying(dt)
    return
  elseif self.state == "intro" then
    self:updateIntro(dt)
  elseif self.state == "fighting" then
    self:updateFighting(dt, playerX, playerY)
  elseif self.state == "phase_transition" then
    self:updatePhaseTransition(dt)
  elseif self.state == "defeated" then
    -- Boss defeated, handled externally
  end
  
  -- Update all bullets
  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    bullet.x = bullet.x + bullet.vx * dt
    bullet.y = bullet.y + bullet.vy * dt
    bullet.lifetime = (bullet.lifetime or 0) + dt
    
    -- Acceleration for some bullet types
    if bullet.accel then
      bullet.vx = bullet.vx + bullet.accel.x * dt
      bullet.vy = bullet.vy + bullet.accel.y * dt
    end
    
    -- Homing bullets
    if bullet.homing and playerX and playerY then
      local dx = playerX - bullet.x
      local dy = playerY - bullet.y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist > 1 then
        local homingForce = bullet.homing * dt
        bullet.vx = bullet.vx + (dx / dist) * homingForce
        bullet.vy = bullet.vy + (dy / dist) * homingForce
        
        -- Cap bullet speed
        local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
        if speed > 400 then
          bullet.vx = (bullet.vx / speed) * 400
          bullet.vy = (bullet.vy / speed) * 400
        end
      end
    end
    
    -- Remove off-screen or expired bullets
    if bullet.y > 750 or bullet.y < -30 or bullet.x < -30 or bullet.x > 670 or 
       (bullet.maxLifetime and bullet.lifetime > bullet.maxLifetime) then
      table.remove(self.bullets, i)
    end
  end
end

function Boss:updateIntro(dt)
  self.introTimer = self.introTimer + dt
  
  -- Phase 1: Enter from top (0-2 seconds)
  if self.introTimer < 2.0 then
    local progress = self.introTimer / 2.0
    local eased = 1 - math.pow(1 - progress, 3)  -- Ease-out cubic
    self.y = self.startY + (self.targetY - self.startY) * eased
  -- Phase 2: Settle and prepare (2-3 seconds)
  elseif self.introTimer < 3.0 then
    self.y = self.targetY + math.sin((self.introTimer - 2.0) * 8) * 10
  -- Phase 3: Ready to fight
  else
    self.y = self.targetY
    self.state = "fighting"
    self.introTimer = 0
  end
  
  self.x = self.targetX
end

function Boss:updateFighting(dt, playerX, playerY)
  self.moveTimer = self.moveTimer + dt
  self.attackTimer = self.attackTimer + dt
  self.movementTimer = self.movementTimer + dt
  
  -- Movement pattern based on phase
  self:updateMovement(dt)
  
  -- Execute attack patterns
  if self.attackTimer >= self.phaseData.attackCooldown then
    self:executeAttackPattern(playerX, playerY)
    self.attackTimer = 0
  end
  
  -- Check if phase health depleted
  if self.phaseHealth <= 0 then
    if self.phase < self.totalPhases then
      self:startPhaseTransition()
    else
      -- Final phase depleted, start death animation
      self.state = "dying"
      self.deathTimer = 0
    end
  end
end

function Boss:updatePhaseTransition(dt)
  self.transitionTimer = self.transitionTimer + dt
  
  -- Transition effects: shake, pulse, then next phase
  if self.transitionTimer >= self.phaseTransitionDuration then
    self:advancePhase()
    self.state = "fighting"
    self.transitionTimer = 0
  end
  
  -- Stop moving during transition
  self.x = self.targetX + math.sin(self.transitionTimer * 10) * (5 * (1 - self.transitionTimer / self.phaseTransitionDuration))
end

function Boss:updateDying(dt)
  self.deathTimer = self.deathTimer + dt
  
  -- After death animation completes, mark as defeated
  -- Keep alive=true so boss remains visible during GameScene death sequence
  if self.deathTimer >= self.deathDuration then
    self.state = "defeated"
  end
end

function Boss:updateMovement(dt)
  local moveSpeed = self.phaseData.moveSpeed
  
  if self.phase == 1 then
    -- Phase 1: Slow horizontal sweeps
    self.targetX = 320 + math.sin(self.movementTimer * 0.5) * 150
    self.targetY = 120
  elseif self.phase == 2 then
    -- Phase 2: Figure-8 pattern
    self.targetX = 320 + math.sin(self.movementTimer * 0.8) * 180
    self.targetY = 120 + math.sin(self.movementTimer * 1.6) * 40
  elseif self.phase == 3 then
    -- Phase 3: Aggressive dashes
    if math.floor(self.movementTimer) % 3 < 0.5 then
      self.targetX = (math.floor(self.movementTimer / 3) % 2 == 0) and 150 or 490
    end
    self.targetY = 100 + math.sin(self.movementTimer * 2) * 30
  elseif self.phase == 4 then
    -- Phase 4: Circular sweeps
    local radius = 120
    self.targetX = 320 + math.cos(self.movementTimer * 1.2) * radius
    self.targetY = 150 + math.sin(self.movementTimer * 1.2) * 50
  else
    -- Phase 5: Erratic teleport-like movement
    if math.floor(self.movementTimer * 2) % 2 == 0 then
      self.targetX = 100 + math.random() * 440
      self.targetY = 80 + math.random() * 60
    end
  end
  
  -- Smooth movement toward target
  local dx = self.targetX - self.x
  local dy = self.targetY - self.y
  local dist = math.sqrt(dx * dx + dy * dy)
  
  if dist > 5 then
    self.x = self.x + (dx / dist) * moveSpeed * dt
    self.y = self.y + (dy / dist) * moveSpeed * dt
  end
end

function Boss:startPhaseTransition()
  self.state = "phase_transition"
  self.transitionTimer = 0
  self.bullets = {}  -- Clear all bullets during transition
end

function Boss:advancePhase()
  self.phase = self.phase + 1
  self.phaseData = PHASE_CONFIG[self.phase]
  self.phaseHealth = self.phaseData.hp
  self.maxPhaseHealth = self.phaseData.hp
  self.attackTimer = 0
  self.movementTimer = 0
end

function Boss:executeAttackPattern(playerX, playerY)
  local patterns = self.phaseData.patterns
  local pattern = patterns[math.random(#patterns)]
  
  if pattern == "circleSpray" then
    self:attackCircleSpray()
  elseif pattern == "targetedBarrage" then
    self:attackTargetedBarrage(playerX, playerY)
  elseif pattern == "dualSpiral" then
    self:attackDualSpiral()
  elseif pattern == "waveBarrage" then
    self:attackWaveBarrage()
  elseif pattern == "crossPattern" then
    self:attackCrossPattern()
  elseif pattern == "explosionRing" then
    self:attackExplosionRing()
  elseif pattern == "homingSwarm" then
    self:attackHomingSwarm(playerX, playerY)
  elseif pattern == "laserSweep" then
    self:attackLaserSweep()
  elseif pattern == "chaosStorm" then
    self:attackChaosStorm(playerX, playerY)
  elseif pattern == "spiralBarrage" then
    self:attackSpiralBarrage()
  elseif pattern == "bulletHell" then
    self:attackBulletHell()
  elseif pattern == "ultimatePattern" then
    self:attackUltimatePattern(playerX, playerY)
  elseif pattern == "doubleCross" then
    self:attackDoubleCross()
  elseif pattern == "finalBarrage" then
    self:attackFinalBarrage(playerX, playerY)
  end
end

-- PHASE 1 ATTACKS --
function Boss:attackCircleSpray()
  local numBullets = 16
  local speed = 180
  
  for i = 0, numBullets - 1 do
    local angle = (i / numBullets) * math.pi * 2
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      size = 6,
      color = {1, 0.3, 0.3}
    })
  end
end

function Boss:attackTargetedBarrage(playerX, playerY)
  local numShots = 5
  local spread = 0.3
  
  for i = 0, numShots - 1 do
    local dx = playerX - self.x
    local dy = playerY - self.y
    local angle = math.atan2(dy, dx) + (i - numShots / 2) * spread
    
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * 280,
      vy = math.sin(angle) * 280,
      size = 7,
      color = {1, 0.4, 0.4}
    })
  end
end

-- PHASE 2 ATTACKS --
function Boss:attackDualSpiral()
  local numArms = 4
  local bulletsPerArm = 3
  local angleOffset = self.glowTime * 3
  
  for arm = 0, numArms - 1 do
    for i = 0, bulletsPerArm - 1 do
      local angle = angleOffset + (arm / numArms) * math.pi * 2
      local speed = 150 + i * 30
      
      table.insert(self.bullets, {
        x = self.x,
        y = self.y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        size = 5 + i,
        color = {1, 0.5, 0.2}
      })
    end
  end
end

function Boss:attackWaveBarrage()
  local numWaves = 3
  local bulletsPerWave = 12
  
  for wave = 0, numWaves - 1 do
    for i = 0, bulletsPerWave - 1 do
      local xOffset = (i - bulletsPerWave / 2) * 40
      local wavePhase = (i / bulletsPerWave) * math.pi * 2
      
      table.insert(self.bullets, {
        x = self.x + xOffset,
        y = self.y,
        vx = math.sin(wavePhase) * 60,
        vy = 160 + wave * 20,
        size = 5,
        color = {1, 0.6, 0.3}
      })
    end
  end
end

function Boss:attackCrossPattern()
  local directions = {
    {0, 1}, {0, -1}, {1, 0}, {-1, 0},  -- Cardinal
    {0.707, 0.707}, {-0.707, 0.707}, {0.707, -0.707}, {-0.707, -0.707}  -- Diagonal
  }
  local speed = 200
  
  for _, dir in ipairs(directions) do
    for i = 1, 3 do
      table.insert(self.bullets, {
        x = self.x,
        y = self.y,
        vx = dir[1] * speed * (0.7 + i * 0.15),
        vy = dir[2] * speed * (0.7 + i * 0.15),
        size = 6,
        color = {1, 0.7, 0.2}
      })
    end
  end
end

-- PHASE 3 ATTACKS --
function Boss:attackExplosionRing()
  -- Multiple expanding rings
  for ring = 0, 2 do
    local delay = ring * 0.15
    local numBullets = 20 + ring * 4
    local speed = 120 + ring * 40
    
    for i = 0, numBullets - 1 do
      local angle = (i / numBullets) * math.pi * 2
      
      table.insert(self.bullets, {
        x = self.x,
        y = self.y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        size = 4 + ring * 2,
        color = {1, 0.6, 0.3},
        lifetime = -delay  -- Delayed start
      })
    end
  end
end

function Boss:attackHomingSwarm(playerX, playerY)
  local numHoming = 8
  
  for i = 0, numHoming - 1 do
    local angle = (i / numHoming) * math.pi * 2
    local initialSpeed = 100
    
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * initialSpeed,
      vy = math.sin(angle) * initialSpeed,
      size = 6,
      color = {1, 0.3, 0.7},
      homing = 200,  -- Homing force
      maxLifetime = 8
    })
  end
end

function Boss:attackLaserSweep()
  -- Dense line of bullets that sweeps
  local numBullets = 30
  local sweepAngle = -math.pi/2 + math.sin(self.glowTime * 2) * 0.5
  
  for i = 0, numBullets - 1 do
    local offset = (i - numBullets / 2) * 8
    local perpAngle = sweepAngle + math.pi/2
    local startX = self.x + math.cos(perpAngle) * offset
    local startY = self.y + math.sin(perpAngle) * offset
    
    table.insert(self.bullets, {
      x = startX,
      y = startY,
      vx = math.cos(sweepAngle) * 250,
      vy = math.sin(sweepAngle) * 250,
      size = 4,
      color = {1, 0.8, 0.4}
    })
  end
end

-- PHASE 4 ATTACKS --
function Boss:attackChaosStorm(playerX, playerY)
  -- Random spray aimed in player's general direction
  local numBullets = 30
  
  for i = 0, numBullets - 1 do
    local dx = playerX - self.x
    local dy = playerY - self.y
    local baseAngle = math.atan2(dy, dx)
    local randomAngle = baseAngle + (math.random() - 0.5) * math.pi
    local speed = 150 + math.random() * 150
    
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(randomAngle) * speed,
      vy = math.sin(randomAngle) * speed,
      size = 4 + math.random() * 3,
      color = {1, 0.4, 0.9}
    })
  end
end

function Boss:attackSpiralBarrage()
  -- Triple spiral with acceleration
  local numArms = 3
  local bulletsPerArm = 8
  local angleOffset = self.coreRotation
  
  for arm = 0, numArms - 1 do
    for i = 0, bulletsPerArm - 1 do
      local angle = angleOffset + (arm / numArms) * math.pi * 2 + (i * 0.3)
      local speed = 100
      
      table.insert(self.bullets, {
        x = self.x,
        y = self.y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        size = 5,
        color = {1, 0.5, 1},
        accel = {
          x = math.cos(angle) * 50,
          y = math.sin(angle) * 50
        }
      })
    end
  end
end

function Boss:attackBulletHell()
  -- Dense pattern covering wide area
  for layer = 0, 2 do
    local numBullets = 24
    local layerSpeed = 140 + layer * 30
    local layerAngleOffset = (layer * 0.2)
    
    for i = 0, numBullets - 1 do
      local angle = (i / numBullets) * math.pi * 2 + layerAngleOffset
      
      table.insert(self.bullets, {
        x = self.x,
        y = self.y,
        vx = math.cos(angle) * layerSpeed,
        vy = math.sin(angle) * layerSpeed,
        size = 5,
        color = {0.9, 0.3, 1}
      })
    end
  end
end

-- PHASE 5 ATTACKS --
function Boss:attackUltimatePattern(playerX, playerY)
  -- Combination attack: Circles + homing + aimed
  -- Circle spray
  local numCircle = 20
  for i = 0, numCircle - 1 do
    local angle = (i / numCircle) * math.pi * 2
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * 200,
      vy = math.sin(angle) * 200,
      size = 6,
      color = {0.9, 0.2, 1}
    })
  end
  
  -- Homing bullets
  for i = 0, 5 do
    local angle = (i / 6) * math.pi * 2
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * 120,
      vy = math.sin(angle) * 120,
      size = 7,
      color = {1, 0.3, 0.9},
      homing = 250,
      maxLifetime = 7
    })
  end
  
  -- Aimed barrage
  local dx = playerX - self.x
  local dy = playerY - self.y
  local baseAngle = math.atan2(dy, dx)
  for i = 0, 8 do
    local angle = baseAngle + (i - 4) * 0.15
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * 320,
      vy = math.sin(angle) * 320,
      size = 8,
      color = {1, 0.4, 1}
    })
  end
end

function Boss:attackDoubleCross()
  -- Two overlapping cross patterns
  local directions = {
    {0, 1}, {0, -1}, {1, 0}, {-1, 0},
    {0.707, 0.707}, {-0.707, 0.707}, {0.707, -0.707}, {-0.707, -0.707}
  }
  
  for set = 0, 1 do
    for _, dir in ipairs(directions) do
      for i = 1, 4 do
        table.insert(self.bullets, {
          x = self.x,
          y = self.y,
          vx = dir[1] * (180 + i * 25 + set * 40),
          vy = dir[2] * (180 + i * 25 + set * 40),
          size = 5 + i,
          color = {0.8, 0.2, 1}
        })
      end
    end
  end
end

function Boss:attackFinalBarrage(playerX, playerY)
  -- Overwhelming final attack
  local dx = playerX - self.x
  local dy = playerY - self.y
  local playerAngle = math.atan2(dy, dx)
  
  -- Wide spread toward player
  for i = 0, 20 do
    local angle = playerAngle + (i - 10) * 0.25
    local speed = 200 + math.random() * 100
    
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      size = 5 + math.random() * 3,
      color = {1, 0.2, 1}
    })
  end
  
  -- Additional 360 spray
  for i = 0, 15 do
    local angle = (i / 16) * math.pi * 2 + self.coreRotation
    table.insert(self.bullets, {
      x = self.x,
      y = self.y,
      vx = math.cos(angle) * 160,
      vy = math.sin(angle) * 160,
      size = 6,
      color = {0.9, 0.3, 1}
    })
  end
end

function Boss:takeDamage(amount)
  if self.state ~= "fighting" then
    return false  -- Invulnerable during intro and transitions
  end
  
  self.phaseHealth = self.phaseHealth - amount
  self.flashTime = 0.12
  
  -- Phase health depleted, will trigger transition in update
  if self.phaseHealth <= 0 then
    self.phaseHealth = 0
    return false  -- Don't defeat until all phases complete
  end
  
  return false
end

function Boss:draw()
  if not self.alive then return end
  
  -- Get current phase color
  local baseColor = self.phaseData.color
  
  -- Helper function for flash effect (blend toward white instead of full white)
  local function getColor(r, g, b, a)
    if self.flashTime > 0 then
      -- Blend 50% toward white to keep design visible
      local blend = 0.5
      return r + (1 - r) * blend, g + (1 - g) * blend, b + (1 - b) * blend, a or 1
    else
      return r, g, b, a or 1
    end
  end
  
  -- Death animation
  if self.state == "dying" then
    local deathProgress = self.deathTimer / self.deathDuration
    local pulse = math.sin(deathProgress * math.pi * 12) * 0.5 + 0.5
    local expansion = 1 + deathProgress * 0.8
    local brightness = 0.5 + deathProgress * 0.5
    
    -- Pulsing expanding glow
    love.graphics.setColor(1, brightness, brightness, 0.4 * (1 - deathProgress))
    love.graphics.circle("fill", self.x, self.y, self.size * expansion * 2)
    
    -- Main body pulsing and expanding
    love.graphics.setColor(baseColor[1] * brightness, baseColor[2] * brightness, baseColor[3] * brightness, 1 - deathProgress * 0.5)
    love.graphics.circle("fill", self.x, self.y, self.size * expansion)
    
    -- Flashing core
    if pulse > 0.5 then
      love.graphics.setColor(1, 1, 1, pulse * (1 - deathProgress))
      love.graphics.circle("fill", self.x, self.y, self.size * 0.4 * expansion)
    end
    
    -- Draw some explosive particles
    for i = 1, 8 do
      local angle = (i / 8) * math.pi * 2 + deathProgress * 2
      local dist = self.size * expansion * (0.7 + pulse * 0.3)
      local px = self.x + math.cos(angle) * dist
      local py = self.y + math.sin(angle) * dist
      love.graphics.setColor(1, 0.6, 0, 1 - deathProgress)
      love.graphics.circle("fill", px, py, 8 * (1 + deathProgress))
    end
    
    return
  end
  
  -- Phase transition effects
  if self.state == "phase_transition" then
    local transProgress = self.transitionTimer / self.phaseTransitionDuration
    local pulse = math.sin(transProgress * math.pi * 8) * 0.5 + 0.5
    love.graphics.setColor(1, 1, 1, pulse)
    love.graphics.circle("fill", self.x, self.y, self.size * (1 + pulse * 0.5))
  end
  
  -- Outer intimidating glow
  local glowPulse = 1 + math.sin(self.glowTime * 2) * 0.3
  local glowSize = self.size * 1.5 * glowPulse
  love.graphics.setColor(baseColor[1], baseColor[2], baseColor[3], 0.2 * glowPulse)
  love.graphics.circle("fill", self.x, self.y, glowSize)
  
  -- Wing structures (animated)
  local wingSpread = math.sin(self.wingAngle) * 0.2 + 1
  love.graphics.setColor(getColor(baseColor[1] * 0.7, baseColor[2] * 0.7, baseColor[3] * 0.7))
  
  -- Left wing
  love.graphics.polygon("fill",
    self.x - self.size * 0.8, self.y,
    self.x - self.size * (1.8 * wingSpread), self.y - self.size * 0.7,
    self.x - self.size * (1.9 * wingSpread), self.y,
    self.x - self.size * (1.8 * wingSpread), self.y + self.size * 0.7
  )
  
  -- Right wing
  love.graphics.polygon("fill",
    self.x + self.size * 0.8, self.y,
    self.x + self.size * (1.8 * wingSpread), self.y - self.size * 0.7,
    self.x + self.size * (1.9 * wingSpread), self.y,
    self.x + self.size * (1.8 * wingSpread), self.y + self.size * 0.7
  )
  
  -- Wing details/engines
  love.graphics.setColor(getColor(baseColor[1] * 1.3, baseColor[2] * 1.3, baseColor[3] * 1.3))
  love.graphics.circle("fill", self.x - self.size * (1.8 * wingSpread), self.y, self.size * 0.3)
  love.graphics.circle("fill", self.x + self.size * (1.8 * wingSpread), self.y, self.size * 0.3)
  
  -- Main body core (rotating)
  love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
  love.graphics.circle("fill", self.x, self.y, self.size)
  
  -- Armor plating (octagonal)
  local armorPoints = {}
  for i = 0, 7 do
    local angle = (i / 8) * math.pi * 2 + self.coreRotation * 0.5
    table.insert(armorPoints, self.x + math.cos(angle) * self.size * 0.9)
    table.insert(armorPoints, self.y + math.sin(angle) * self.size * 0.9)
  end
  love.graphics.setColor(getColor(baseColor[1] * 0.5, baseColor[2] * 0.5, baseColor[3] * 0.5))
  love.graphics.polygon("fill", armorPoints)
  
  -- Inner rotating core
  love.graphics.setColor(getColor(baseColor[1] * 1.5, baseColor[2] * 1.5, baseColor[3] * 1.5))
  for i = 0, 5 do
    local angle = (i / 6) * math.pi * 2 + self.coreRotation
    local innerRadius = self.size * 0.5
    local x = self.x + math.cos(angle) * innerRadius
    local y = self.y + math.sin(angle) * innerRadius
    love.graphics.circle("fill", x, y, self.size * 0.15)
  end
  
  -- Central eye/core
  love.graphics.setColor(getColor(1, 1, 1))
  love.graphics.circle("fill", self.x, self.y, self.size * 0.25)
  love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
  love.graphics.circle("fill", self.x, self.y, self.size * 0.18)
  
  -- Phase indicator spikes (one per phase completed)
  if self.phase > 1 then
    love.graphics.setLineWidth(4)
    love.graphics.setColor(getColor(baseColor[1] * 1.4, baseColor[2] * 1.4, baseColor[3] * 1.4))
    for i = 1, self.phase - 1 do
      local angle = (i / self.totalPhases) * math.pi * 2 - math.pi/2
      local innerX = self.x + math.cos(angle) * self.size
      local innerY = self.y + math.sin(angle) * self.size
      local outerX = self.x + math.cos(angle) * (self.size * 1.3)
      local outerY = self.y + math.sin(angle) * (self.size * 1.3)
      love.graphics.line(innerX, innerY, outerX, outerY)
    end
    love.graphics.setLineWidth(1)
  end
  
  -- Health bar and name are now drawn in GameScene UI
  
  -- Draw bullets
  for _, bullet in ipairs(self.bullets) do
    if not bullet.lifetime or bullet.lifetime >= 0 then  -- Skip delayed bullets
      local color = bullet.color or {1, 0.4, 0.75}
      
      -- Outer glow
      love.graphics.setColor(color[1], color[2], color[3], 0.3)
      love.graphics.circle("fill", bullet.x, bullet.y, bullet.size * 1.8)
      
      -- Main bullet
      love.graphics.setColor(color[1], color[2], color[3], 1)
      love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
      
      -- Core highlight
      love.graphics.setColor(1, 1, 1, 0.7)
      love.graphics.circle("fill", bullet.x, bullet.y, bullet.size * 0.3)
      
      -- Homing indicator
      if bullet.homing then
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1, 0.5, 1, 0.5)
        love.graphics.circle("line", bullet.x, bullet.y, bullet.size * 2)
        love.graphics.setLineWidth(1)
      end
    end
  end
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setLineWidth(1)
end

-- Get health info for UI rendering
function Boss:getHealthInfo()
  return {
    name = self.name,
    phase = self.phase,
    totalPhases = self.totalPhases,
    phaseName = self.phaseData.name,
    phaseHealth = self.phaseHealth,
    maxPhaseHealth = self.maxPhaseHealth,
    healthPercent = self.phaseHealth / self.maxPhaseHealth,
    phaseColor = self.phaseData.color
  }
end

return Boss
