-- src/systems/ParticleSystem.lua
-- Manages purely-programmatic particle effects:
--   hearts   (from petting)
--   sparkles (ambient ambient floating)
--   butterflies (drifting dots)

local helpers = require("src/utils/helpers")

local ParticleSystem = {}
ParticleSystem.__index = ParticleSystem

-- ── Particle constructors ────────────────────────────────────────────────────
local function newHeart(x, y)
  return {
    kind = "heart",
    x = x, y = y,
    vx = helpers.randFloat(-25, 25),
    vy = helpers.randFloat(-60, -30),
    life = 1.4,
    maxLife = 1.4,
    size = helpers.randFloat(6, 10),
  }
end

local function newSparkle(bounds)
  return {
    kind = "sparkle",
    x  = helpers.randFloat(bounds.x, bounds.x + bounds.w),
    y  = helpers.randFloat(bounds.y, bounds.y + bounds.h),
    vy = helpers.randFloat(-12, -5),
    vx = helpers.randFloat(-6, 6),
    life = helpers.randFloat(2.0, 4.5),
    maxLife = 5.0,
    size = helpers.randFloat(2, 5),
    phase = helpers.randFloat(0, math.pi * 2),
  }
end

local function newButterfly(bounds)
  return {
    kind = "butterfly",
    x  = helpers.randFloat(bounds.x, bounds.x + bounds.w),
    y  = helpers.randFloat(bounds.y, bounds.y + bounds.h),
    vx = helpers.randFloat(-18, 18),
    vy = helpers.randFloat(-10, 10),
    life = helpers.randFloat(3.0, 7.0),
    maxLife = 7.0,
    size = helpers.randFloat(4, 7),
    flapTimer = 0,
    color = {
      helpers.randFloat(0.6, 1.0),
      helpers.randFloat(0.5, 0.9),
      helpers.randFloat(0.7, 1.0),
    },
    changeTimer = helpers.randFloat(1, 3),
  }
end

local function newStar(x, y, color)
  local angle = helpers.randFloat(0, math.pi * 2)
  local speed = helpers.randFloat(40, 90)
  return {
    kind    = "star",
    x       = x + helpers.randFloat(-10, 10),
    y       = y + helpers.randFloat(-10, 10),
    vx      = math.cos(angle) * speed,
    vy      = math.sin(angle) * speed - 20,
    life    = helpers.randFloat(0.6, 1.2),
    maxLife = 1.2,
    size    = helpers.randFloat(5, 9),
    angle   = angle,
    spin    = helpers.randFloat(-6, 6),
    color   = color or { 1, 0.92, 0.35 },
  }
end

-- ── System ────────────────────────────────────────────────────────────────────
function ParticleSystem:new(bounds)
  local p = setmetatable({}, self)
  p.particles    = {}
  p.bounds       = bounds or { x=100, y=100, w=1000, h=500 }
  p.sparkleTimer = 0
  p.butterflyTimer = 0
  p.maxSparkles  = 30
  p.maxButterflies = 8
  return p
end

function ParticleSystem:spawnHearts(x, y, count)
  count = count or 3
  for _ = 1, count do
    table.insert(self.particles, newHeart(x, y))
  end
end

function ParticleSystem:spawnStars(x, y, count, color)
  count = count or 6
  for _ = 1, count do
    table.insert(self.particles, newStar(x, y, color))
  end
end

function ParticleSystem:update(dt)
  -- Ambient spawn
  self.sparkleTimer = self.sparkleTimer + dt
  if self.sparkleTimer > 0.4 then
    self.sparkleTimer = 0
    local sc = 0
    for _, p in ipairs(self.particles) do if p.kind == "sparkle" then sc = sc + 1 end end
    if sc < self.maxSparkles then
      table.insert(self.particles, newSparkle(self.bounds))
    end
  end

  self.butterflyTimer = self.butterflyTimer + dt
  if self.butterflyTimer > 1.5 then
    self.butterflyTimer = 0
    local bc = 0
    for _, p in ipairs(self.particles) do if p.kind == "butterfly" then bc = bc + 1 end end
    if bc < self.maxButterflies then
      table.insert(self.particles, newButterfly(self.bounds))
    end
  end

  -- Update each particle
  for i = #self.particles, 1, -1 do
    local p = self.particles[i]
    p.life = p.life - dt
    if p.life <= 0 then
      table.remove(self.particles, i)
    else
      p.x = p.x + p.vx * dt
      p.y = p.y + p.vy * dt
      if p.kind == "sparkle" then
        p.phase = p.phase + dt * 2
      elseif p.kind == "butterfly" then
        p.flapTimer  = p.flapTimer  + dt
        p.changeTimer = p.changeTimer - dt
        if p.changeTimer <= 0 then
          p.vx = helpers.randFloat(-18, 18)
          p.vy = helpers.randFloat(-10, 10)
          p.changeTimer = helpers.randFloat(1, 3)
        end
      elseif p.kind == "star" then
        p.angle = p.angle + p.spin * dt
        p.vy    = p.vy + 40 * dt   -- slight gravity
      end
    end
  end
end

function ParticleSystem:draw()
  for _, p in ipairs(self.particles) do
    local alpha = p.life / p.maxLife
    if p.kind == "heart" then
      love.graphics.setColor(0.95, 0.45, 0.60, alpha)
      love.graphics.circle("fill", p.x,     p.y,               p.size * 0.6)
      love.graphics.circle("fill", p.x + p.size * 0.55, p.y,   p.size * 0.6)
      love.graphics.polygon("fill",
        p.x - p.size * 0.6, p.y + p.size * 0.1,
        p.x + p.size * 1.15, p.y + p.size * 0.1,
        p.x + p.size * 0.28, p.y + p.size * 1.0)
    elseif p.kind == "sparkle" then
      local pulse = 0.5 + 0.5 * math.sin(p.phase)
      love.graphics.setColor(0.98, 0.95, 0.65, alpha * pulse)
      love.graphics.circle("fill", p.x, p.y, p.size * pulse)
    elseif p.kind == "butterfly" then
      local c = p.color
      local flap = math.sin(p.flapTimer * 8) * p.size
      love.graphics.setColor(c[1], c[2], c[3], alpha * 0.8)
      love.graphics.ellipse("fill", p.x - flap, p.y, p.size, p.size * 0.6)
      love.graphics.ellipse("fill", p.x + flap, p.y, p.size, p.size * 0.6)
    elseif p.kind == "star" then
      local c = p.color
      love.graphics.setColor(c[1], c[2], c[3], alpha)
      -- Draw a simple 4-point star by rotating two rectangles
      love.graphics.push()
      love.graphics.translate(p.x, p.y)
      love.graphics.rotate(p.angle)
      love.graphics.rectangle("fill", -p.size * 0.5, -p.size * 0.15, p.size, p.size * 0.30)
      love.graphics.rectangle("fill", -p.size * 0.15, -p.size * 0.5, p.size * 0.30, p.size)
      love.graphics.pop()
    end
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return ParticleSystem
