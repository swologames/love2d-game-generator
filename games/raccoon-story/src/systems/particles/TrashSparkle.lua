-- TrashSparkle: continuous emitter factory for gold twinkles around trash items

local TrashSparkle = {}

-- Create a new continuous emitter table
function TrashSparkle.create(x, y)
  return {
    x = x,
    y = y,
    type = "trashSparkle",
    timer = 0,
    interval = 0.2,
    radius = 15,
    active = true
  }
end

-- Emit one sparkle particle from the given emitter into activeParticles
function TrashSparkle.emit(emitter, particlePool, activeParticles, particleCount, maxParticles)
  if particleCount >= maxParticles then return particleCount end

  local angle = math.random() * math.pi * 2
  local dist = math.random() * emitter.radius

  local particle = table.remove(particlePool) or require("src.systems.particles.Emitter").newParticle()
  particle.x = emitter.x + math.cos(angle) * dist
  particle.y = emitter.y + math.sin(angle) * dist
  particle.vx = 0
  particle.vy = -20
  particle.ax = 0
  particle.ay = 0
  particle.life = 1.5
  particle.maxLife = 1.5
  particle.size = 0.3 + math.random() * 0.2
  particle.targetSize = 0
  particle.rotation = math.random() * math.pi * 2
  particle.rotationSpeed = (math.random() - 0.5) * 2
  particle.startR = 1; particle.startG = 0.843; particle.startB = 0;  particle.startA = 0.8
  particle.endR   = 1; particle.endG   = 1;     particle.endB   = 0.5; particle.endA   = 0
  particle.damping = 0.98
  particle.type = "sparkle"

  table.insert(activeParticles, particle)
  return particleCount + 1
end

return TrashSparkle
