-- src/entities/Tree.lua
-- A decorative tree that drops fruit when clicked.
-- Drawn entirely with programmatic Love2D shapes — no image assets.

local FruitDrop     = require("src/entities/FruitDrop")
local FruitRenderer = require("src/ui/FruitRenderer")

local DROP_COOLDOWN   = 8.0   -- seconds between drops
local SHAKE_DURATION  = 0.45  -- seconds of wobble after click
local CANOPY_RADIUS   = 44    -- px click detection radius

local Tree = {}
Tree.__index = Tree

function Tree:new(x, y, fruitData)
  local t = setmetatable({}, self)
  t.x          = x
  t.y          = y
  t.fruit      = fruitData
  t.cooldown   = 0          -- tree starts ready
  t.shakeTimer = 0
  t.scale      = 1.0
  -- Canopy center is above the base
  t.canopyX    = x
  t.canopyY    = y - 62
  return t
end

function Tree:update(dt)
  if self.cooldown > 0 then
    self.cooldown = self.cooldown - dt
    if self.cooldown < 0 then self.cooldown = 0 end
  end
  if self.shakeTimer > 0 then
    self.shakeTimer = self.shakeTimer - dt
    if self.shakeTimer < 0 then self.shakeTimer = 0 end
  end
end

function Tree:draw()
  local t = self
  local wobble = 0
  if t.shakeTimer > 0 then
    -- Oscillating shake that decays
    local frac = t.shakeTimer / SHAKE_DURATION
    wobble = math.sin(t.shakeTimer * 30) * frac * 0.12
  end

  love.graphics.push()
  love.graphics.translate(t.x, t.y)
  love.graphics.rotate(wobble)

  -- ── Trunk ──────────────────────────────────────────────────────────────────
  -- Tapered trapezoid: wider at bottom, narrower at top
  love.graphics.setColor(0.50, 0.33, 0.18, 1)
  love.graphics.polygon("fill",
    -8,   0,
     8,   0,
     5,  -45,
    -5,  -45
  )
  -- Trunk highlight
  love.graphics.setColor(0.62, 0.44, 0.26, 0.55)
  love.graphics.polygon("fill", -2, 0, 3, 0, 2, -42, -1, -42)

  -- ── Canopy (three overlapping circles) ────────────────────────────────────
  local cy = -62  -- relative to base

  -- Back layer
  love.graphics.setColor(0.24, 0.58, 0.28, 1)
  love.graphics.circle("fill",  8, cy - 6, 30)
  love.graphics.circle("fill", -8, cy - 6, 30)

  -- Middle layer
  love.graphics.setColor(0.32, 0.70, 0.35, 1)
  love.graphics.circle("fill",  0, cy - 14, 28)
  love.graphics.circle("fill", -12, cy,     22)
  love.graphics.circle("fill",  12, cy,     22)

  -- Front highlight
  love.graphics.setColor(0.44, 0.82, 0.46, 0.70)
  love.graphics.circle("fill", -5, cy - 8, 16)

  -- ── Fruit hints when ready ─────────────────────────────────────────────────
  if t.cooldown <= 0 then
    -- Two small fruit peeking from canopy
    FruitRenderer.draw(t.fruit, -12, cy + 6,  0.38, 0.92)
    FruitRenderer.draw(t.fruit,  14, cy - 12, 0.34, 0.80)
  end

  love.graphics.pop()
  love.graphics.setColor(1, 1, 1, 1)
end

--- If within canopy radius and cooldown is ready, spawn a FruitDrop and return it.
--- Otherwise return nil.
function Tree:tryClick(mx, my)
  local dx = mx - self.canopyX
  local dy = my - self.canopyY
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist > CANOPY_RADIUS then return nil end
  if self.cooldown > 0 then
    -- clicked but not ready — just shake
    self.shakeTimer = SHAKE_DURATION * 0.5
    return nil
  end
  self.cooldown   = DROP_COOLDOWN
  self.shakeTimer = SHAKE_DURATION
  return FruitDrop:new(self.x, self.canopyY, self.fruit)
end

--- Draw a small cooldown indicator ring above the tree.
function Tree:drawHint()
  if self.cooldown <= 0 then
    -- "ready" sparkle pulse
    local alpha = 0.55 + math.sin(love.timer.getTime() * 3.5) * 0.25
    love.graphics.setColor(1, 0.97, 0.55, alpha)
    love.graphics.circle("line", self.canopyX, self.canopyY - 38, 6)
  else
    -- Cooldown arc
    local frac = 1 - (self.cooldown / DROP_COOLDOWN)
    love.graphics.setColor(0.70, 0.70, 0.70, 0.40)
    love.graphics.circle("line", self.canopyX, self.canopyY - 38, 6)
    love.graphics.setColor(0.95, 0.85, 0.35, 0.70)
    love.graphics.arc("fill", self.canopyX, self.canopyY - 38, 6,
      -math.pi / 2, -math.pi / 2 + frac * math.pi * 2)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

return Tree
