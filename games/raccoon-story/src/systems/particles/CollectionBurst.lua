-- CollectionBurst: gold sparkle burst when trash is collected

local CollectionBurst = {}

function CollectionBurst.emit(x, y, particlePool, activeParticles, particleCount, maxParticles)
  if particleCount >= maxParticles then return particleCount end

  local count = math.random(8, 10)
  for i = 1, count do
    if particleCount >= maxParticles then break end

    local particle = table.remove(particlePool) or require("src.systems.particles.Emitter").newParticle()

    local angle = (i / count) * math.pi * 2 + (math.random() - 0.5) * 0.5
    local speed = 60 + math.random() * 40

    particle.x = x
    particle.y = y
    particle.vx = math.cos(angle) * speed
    particle.vy = math.sin(angle) * speed
    particle.ax = 0
    particle.ay = 80

    particle.life = 0.6 + math.random() * 0.3
    particle.maxLife = particle.life
    particle.size = 0.5 + math.random() * 0.3
    particle.targetSize = 0
    particle.rotation = math.random() * math.pi * 2
    particle.rotationSpeed = (math.random() - 0.5) * 8

    particle.startR = 1; particle.startG = 0.9; particle.startB = 0.2; particle.startA = 1
    particle.endR   = 1; particle.endG   = 0.7; particle.endB   = 0;   particle.endA   = 0

    particle.damping = 0.96
    particle.type = "collection"

    table.insert(activeParticles, particle)
    particleCount = particleCount + 1
  end
  return particleCount
end

return CollectionBurst
