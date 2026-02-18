-- ParticleSystem.lua
-- Visual effects system for Mecha Shmup

local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

function ParticleSystem:new()
  local instance = setmetatable({}, self)
  
  instance.particles = {}
  instance.screenShake = 0
  instance.shakeX = 0
  instance.shakeY = 0
  instance.screenShakeEnabled = true
  
  return instance
end

function ParticleSystem:update(dt)
  -- Update particles
  for i = #self.particles, 1, -1 do
    local p = self.particles[i]
    p.lifetime = p.lifetime - dt
    
    if p.lifetime <= 0 then
      table.remove(self.particles, i)
    else
      -- Update position
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt
      
      -- Apply gravity/acceleration
      if p.gravity then
        p.vy = p.vy + p.gravity * dt
      end
      
      -- Fade out
      p.alpha = (p.lifetime / p.maxLifetime) * p.baseAlpha
      
      -- Shrink
      if p.shrink then
        p.size = p.baseSize * (p.lifetime / p.maxLifetime)
      end
      
      -- Rotation
      if p.rotation then
        p.angle = p.angle + p.rotation * dt
      end
    end
  end
  
  -- Update screen shake
  if self.screenShake > 0 then
    self.screenShake = self.screenShake - dt * 5
    if self.screenShake < 0 then
      self.screenShake = 0
    end
    
    if self.screenShakeEnabled then
      self.shakeX = (math.random() - 0.5) * self.screenShake * 10
      self.shakeY = (math.random() - 0.5) * self.screenShake * 10
    else
      self.shakeX = 0
      self.shakeY = 0
    end
  else
    self.shakeX = 0
    self.shakeY = 0
  end
end

function ParticleSystem:draw()
  for _, p in ipairs(self.particles) do
    love.graphics.push()
    love.graphics.translate(p.x, p.y)
    
    if p.angle then
      love.graphics.rotate(p.angle)
    end
    
    love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.alpha)
    
    if p.shape == "circle" then
      love.graphics.circle("fill", 0, 0, p.size)
    elseif p.shape == "square" then
      love.graphics.rectangle("fill", -p.size/2, -p.size/2, p.size, p.size)
    elseif p.shape == "line" then
      love.graphics.line(0, 0, p.length * math.cos(p.angle), p.length * math.sin(p.angle))
    end
    
    love.graphics.pop()
  end
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
end

function ParticleSystem:explosion(x, y, size, color)
  size = size or 20
  color = color or {1, 0.5, 0.2}
  
  local numParticles = 20 + size
  
  for i = 1, numParticles do
    local angle = (i / numParticles) * math.pi * 2
    local speed = 100 + math.random() * 100
    local particleSize = 2 + math.random() * 4
    
    table.insert(self.particles, {
      x = x,
      y = y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      size = particleSize,
      baseSize = particleSize,
      color = color,
      alpha = 1,
      baseAlpha = 1,
      lifetime = 0.3 + math.random() * 0.4,
      maxLifetime = 0.3 + math.random() * 0.4,
      shape = "circle",
      shrink = true
    })
  end
  
  -- Screen shake
  self:addScreenShake(1 + size / 20)
end

function ParticleSystem:smallExplosion(x, y)
  for i = 1, 10 do
    local angle = math.random() * math.pi * 2
    local speed = 50 + math.random() * 50
    
    table.insert(self.particles, {
      x = x,
      y = y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      size = 2 + math.random() * 2,
      baseSize = 2 + math.random() * 2,
      color = {1, 0.7, 0.3},
      alpha = 1,
      baseAlpha = 1,
      lifetime = 0.2 + math.random() * 0.3,
      maxLifetime = 0.2 + math.random() * 0.3,
      shape = "circle",
      shrink = true
    })
  end
end

function ParticleSystem:bulletDisintegrate(x, y, size, color)
  -- Create disintegration effect for disappearing bullets
  size = size or 8
  color = color or {1, 0.5, 0.9}
  
  local numParticles = math.max(4, math.floor(size))
  
  for i = 1, numParticles do
    local angle = (i / numParticles) * math.pi * 2 + math.random() * 0.3
    local speed = 30 + math.random() * 40
    local particleSize = size * (0.3 + math.random() * 0.3)
    
    table.insert(self.particles, {
      x = x,
      y = y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      size = particleSize,
      baseSize = particleSize,
      color = color,
      alpha = 0.8,
      baseAlpha = 0.8,
      lifetime = 0.3 + math.random() * 0.2,
      maxLifetime = 0.3 + math.random() * 0.2,
      shape = "circle",
      shrink = true
    })
  end
end

function ParticleSystem:bulletTrail(x, y, color)
  color = color or {0.3, 0.7, 1}
  
  table.insert(self.particles, {
    x = x,
    y = y,
    vx = (math.random() - 0.5) * 20,
    vy = (math.random() - 0.5) * 20,
    size = 2,
    baseSize = 2,
    color = color,
    alpha = 0.6,
    baseAlpha = 0.6,
    lifetime = 0.2,
    maxLifetime = 0.2,
    shape = "circle",
    shrink = true
  })
end

function ParticleSystem:engineTrail(x, y, color)
  color = color or {0.3, 0.7, 1}
  
  for i = 1, 2 do
    table.insert(self.particles, {
      x = x + (math.random() - 0.5) * 5,
      y = y,
      vx = (math.random() - 0.5) * 10,
      vy = 50 + math.random() * 30,
      size = 3,
      baseSize = 3,
      color = color,
      alpha = 0.5,
      baseAlpha = 0.5,
      lifetime = 0.3,
      maxLifetime = 0.3,
      shape = "circle",
      shrink = true
    })
  end
end

function ParticleSystem:powerUpCollect(x, y, color)
  color = color or {1, 0.7, 0.2}
  
  for i = 1, 15 do
    local angle = (i / 15) * math.pi * 2
    local speed = 80 + math.random() * 40
    
    table.insert(self.particles, {
      x = x,
      y = y,
      vx = math.cos(angle) * speed,
      vy = math.sin(angle) * speed,
      size = 3,
      baseSize = 3,
      color = color,
      alpha = 1,
      baseAlpha = 1,
      lifetime = 0.5,
      maxLifetime = 0.5,
      shape = "square",
      shrink = true,
      angle = 0,
      rotation = 5 + math.random() * 3
    })
  end
end

function ParticleSystem:addScreenShake(intensity)
  self.screenShake = math.min(self.screenShake + intensity, 3)
end

function ParticleSystem:getShake()
  return self.shakeX, self.shakeY
end

function ParticleSystem:clear()
  self.particles = {}
  self.screenShake = 0
  self.shakeX = 0
  self.shakeY = 0
end

return ParticleSystem
