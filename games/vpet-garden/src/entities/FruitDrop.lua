-- src/entities/FruitDrop.lua
-- A single fruit lying on the ground after being dropped from a Tree.
-- Supports physics (gravity + single bounce), drag-to-feed, and lifetime fade.

local FruitRenderer = require("src/ui/FruitRenderer")
local helpers       = require("src/utils/helpers")

local GRAVITY   = 400   -- px/s²
local GROUND_Y  = 568   -- y where fruit settles on the grass
local LIFETIME  = 15.0  -- seconds before it fades away
local FADE_START = 12.0 -- start fading at this remaining lifetime
local DRAG_SCALE = 1.25 -- scale up while dragging
local PICK_RADIUS = 22  -- px radius for click detection

local FruitDrop = {}
FruitDrop.__index = FruitDrop

function FruitDrop:new(x, y, fruit)
  local f = setmetatable({}, self)
  f.x         = x
  f.y         = y
  f.fruit     = fruit
  f.vx        = helpers.randFloat(-40, 40)
  f.vy        = helpers.randFloat(-120, -70)
  f.grounded  = false
  f.alpha     = 1.0
  f.lifetime  = LIFETIME
  f.dragging  = false
  f.dragOffX  = 0
  f.dragOffY  = 0
  f.bobTimer  = 0
  return f
end

function FruitDrop:update(dt)
  if self.dragging then return end  -- physics paused while held

  if not self.grounded then
    -- Apply gravity
    self.vy = self.vy + GRAVITY * dt
    self.x  = self.x + self.vx * dt
    self.y  = self.y + self.vy * dt

    -- Bounce off ground
    if self.y >= GROUND_Y then
      self.y = GROUND_Y
      if math.abs(self.vy) > 40 then
        self.vy = -self.vy * 0.38
        self.vx = self.vx * 0.75
      else
        self.vy = 0
        self.vx = 0
        self.grounded = true
      end
    end
  else
    -- Gentle bob while sitting on ground
    self.bobTimer = self.bobTimer + dt
  end

  -- Count down lifetime
  self.lifetime = self.lifetime - dt
  if self.lifetime <= 0 then
    self.alpha = 0
  elseif self.lifetime < (LIFETIME - FADE_START) then
    -- fade during last few seconds
    self.alpha = helpers.clamp(self.lifetime / (LIFETIME - FADE_START), 0, 1)
  end
end

function FruitDrop:draw()
  if self.alpha <= 0 then return end

  local drawX = self.x
  local drawY = self.y
  if self.grounded and not self.dragging then
    drawY = drawY + math.sin(self.bobTimer * 1.5) * 1.5
  end

  local sc = self.dragging and DRAG_SCALE or 1.0

  -- Shadow ellipse
  love.graphics.setColor(0, 0, 0, 0.18 * self.alpha)
  love.graphics.ellipse("fill", drawX, GROUND_Y + 3, 12 * sc, 4 * sc, 12)

  FruitRenderer.draw(self.fruit, drawX, drawY, sc, self.alpha)
end

--- Returns true and starts drag if the click is within pick radius.
function FruitDrop:mousepressed(mx, my)
  if self.alpha <= 0 then return false end
  if helpers.distance(mx, my, self.x, self.y) <= PICK_RADIUS then
    self.dragging  = true
    self.grounded  = true
    self.dragOffX  = self.x - mx
    self.dragOffY  = self.y - my
    return true
  end
  return false
end

function FruitDrop:mousereleased()
  self.dragging = false
end

function FruitDrop:updateDrag(mx, my)
  if self.dragging then
    self.x = mx + self.dragOffX
    self.y = my + self.dragOffY
  end
end

--- True if this drop should be removed (faded out completely).
function FruitDrop:isDead()
  return self.alpha <= 0
end

return FruitDrop
