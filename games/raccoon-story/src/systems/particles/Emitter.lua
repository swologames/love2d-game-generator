-- Emitter: base particle pool and per-particle update/draw logic

local Emitter = {}

function Emitter.newParticle()
  return {
    x = 0, y = 0,
    vx = 0, vy = 0,
    ax = 0, ay = 0,
    life = 0, maxLife = 1,
    size = 1, targetSize = 0,
    rotation = 0, rotationSpeed = 0,
    r = 1, g = 1, b = 1, a = 1,
    startR = 1, startG = 1, startB = 1, startA = 1,
    endR = 1, endG = 1, endB = 1, endA = 0,
    damping = 1,
    type = "generic"
  }
end

function Emitter.createParticleTexture()
  local imageData = love.image.newImageData(16, 16)
  imageData:mapPixel(function(x, y)
    local dx = x - 8
    local dy = y - 8
    local dist = math.sqrt(dx * dx + dy * dy)
    local alpha = math.max(0, 1 - dist / 8)
    return 1, 1, 1, alpha
  end)
  local img = love.graphics.newImage(imageData)
  img:setFilter("linear", "linear")
  return img
end

-- Update a single particle. Returns true if still alive.
function Emitter.updateParticle(p, dt)
  p.vx = p.vx + p.ax * dt
  p.vy = p.vy + p.ay * dt
  p.vx = p.vx * p.damping
  p.vy = p.vy * p.damping
  p.x = p.x + p.vx * dt
  p.y = p.y + p.vy * dt
  p.rotation = p.rotation + p.rotationSpeed * dt
  p.life = p.life - dt

  local progress = 1 - (p.life / p.maxLife)
  p.size = p.size + (p.targetSize - p.size) * 2 * dt
  p.r = p.startR + (p.endR - p.startR) * progress
  p.g = p.startG + (p.endG - p.startG) * progress
  p.b = p.startB + (p.endB - p.startB) * progress
  p.a = p.startA + (p.endA - p.startA) * progress

  return p.life > 0
end

-- Draw all active particles
function Emitter.drawParticles(activeParticles, particleImage)
  local lg = love.graphics
  for _, p in ipairs(activeParticles) do
    lg.setColor(p.r, p.g, p.b, p.a)
    lg.draw(particleImage, p.x, p.y, p.rotation, p.size, p.size, 8, 8)
  end
end

return Emitter
