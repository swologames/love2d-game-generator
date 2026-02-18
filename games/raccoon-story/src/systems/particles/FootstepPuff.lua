-- FootstepPuff: subtle dust puffs when player walks

local FootstepPuff = {}

function FootstepPuff.emit(x, y, particlePool, activeParticles, particleCount, maxParticles)
  if particleCount >= maxParticles then return particleCount end

  local count = math.random(1, 2)
  for _ = 1, count do
    if particleCount >= maxParticles then break end

    local particle = table.remove(particlePool) or require("src.systems.particles.Emitter").newParticle()

    particle.x = x + (math.random() - 0.5) * 8
    particle.y = y
    particle.vx = (math.random() - 0.5) * 10
    particle.vy = -5 - math.random() * 5
    particle.ax = 0
    particle.ay = 0

    particle.life = 0.3 + math.random() * 0.2
    particle.maxLife = particle.life
    particle.size = 0.3 + math.random() * 0.2
    particle.targetSize = 0.6
    particle.rotation = math.random() * math.pi * 2
    particle.rotationSpeed = (math.random() - 0.5) * 2

    particle.startR = 0.5; particle.startG = 0.4; particle.startB = 0.3; particle.startA = 0.3
    particle.endR   = 0.5; particle.endG   = 0.4; particle.endB   = 0.3; particle.endA   = 0

    particle.damping = 0.92
    particle.type = "footstep"

    table.insert(activeParticles, particle)
    particleCount = particleCount + 1
  end
  return particleCount
end

return FootstepPuff
