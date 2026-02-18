-- DashDust: one-shot emitter for gray/white dust when player dashes

local DashDust = {}

function DashDust.emit(x, y, direction, particlePool, activeParticles, particleCount, maxParticles)
  if particleCount >= maxParticles then return particleCount end

  local count = math.random(3, 5)
  for _ = 1, count do
    if particleCount >= maxParticles then break end

    local particle = table.remove(particlePool) or require("src.systems.particles.Emitter").newParticle()

    particle.x = x + (math.random() - 0.5) * 10
    particle.y = y + (math.random() - 0.5) * 10

    local speed = 30 + math.random() * 20
    particle.vx = -direction.x * speed + (math.random() - 0.5) * 30
    particle.vy = -direction.y * speed + (math.random() - 0.5) * 30
    particle.ax = 0
    particle.ay = 0

    particle.life = 0.4 + math.random() * 0.2
    particle.maxLife = particle.life
    particle.size = 0.8 + math.random() * 0.4
    particle.targetSize = 1.5
    particle.rotation = math.random() * math.pi * 2
    particle.rotationSpeed = (math.random() - 0.5) * 3

    local gray = 0.7 + math.random() * 0.3
    particle.startR = gray; particle.startG = gray; particle.startB = gray; particle.startA = 0.6
    particle.endR   = gray; particle.endG   = gray; particle.endB   = gray; particle.endA   = 0

    particle.damping = 0.95
    particle.type = "dust"

    table.insert(activeParticles, particle)
    particleCount = particleCount + 1
  end
  return particleCount
end

return DashDust
