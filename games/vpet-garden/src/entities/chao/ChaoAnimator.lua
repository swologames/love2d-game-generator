-- src/entities/chao/ChaoAnimator.lua
-- Draws the Chao as a programmatic blob shape.
-- Reads animation config from data/chao_animations.lua and the current AI state.

local helpers  = require("src/utils/helpers")
local animData = require("src/data/chao_animations")

local ChaoAnimator = {}
ChaoAnimator.__index = ChaoAnimator

local RADIUS   = 22   -- base body radius
local ZZ_TIMER = 0    -- module-level timer for Zzz float animation

function ChaoAnimator:new()
  local a = setmetatable({}, self)
  a.stateName   = "idle"
  a.blendState  = "idle"
  a.blendT      = 1.0      -- 0..1 blend progress
  a.cycleTimer  = 0
  a.zzzTimer    = 0
  return a
end

--- Call every frame to update anim state
function ChaoAnimator:update(dt, aiState)
  local state = aiState or "idle"
  if state ~= self.stateName then
    self.blendState = self.stateName   -- remember old for blend
    self.stateName  = state
    self.blendT     = 0
  end
  local tt = animData.transitionTime
  if self.blendT < 1 then
    self.blendT = math.min(1, self.blendT + dt / tt)
  end
  self.cycleTimer = self.cycleTimer + dt
  self.zzzTimer   = self.zzzTimer   + dt
end

--- Draw the Chao at (x, y), flipped if facingLeft
function ChaoAnimator:draw(x, y, facingRight)
  local cfg  = animData.states[self.stateName]  or animData.states.idle
  local cfg0 = animData.states[self.blendState] or animData.states.idle
  local t    = self.blendT

  -- Blend color tint
  local r = helpers.lerp(cfg0.colorTint[1], cfg.colorTint[1], t)
  local g = helpers.lerp(cfg0.colorTint[2], cfg.colorTint[2], t)
  local b = helpers.lerp(cfg0.colorTint[3], cfg.colorTint[3], t)

  -- Bob (disabled when dragging)
  local bob = math.sin(self.cycleTimer * cfg.bobSpeed) * cfg.bobAmplitude
  local drawY = y + bob

  -- Scale
  local sx = helpers.lerp(cfg0.scaleX, cfg.scaleX, t)
  local sy = helpers.lerp(cfg0.scaleY, cfg.scaleY, t)

  -- Dragging wobble rotation
  local wobbleAngle = 0
  if self.stateName == "dragging" then
    wobbleAngle = math.sin(self.cycleTimer * 9) * 0.20
  end

  -- Shadow: lifted high when dragging
  local shadowOffY  = RADIUS * 0.9
  local shadowAlpha = 0.12
  local shadowScaleX = 0.9
  if self.stateName == "dragging" then
    shadowOffY   = RADIUS * 3.5   -- shadow far below (chao is held up)
    shadowAlpha  = 0.07
    shadowScaleX = 0.5
  end
  love.graphics.setColor(0, 0, 0, shadowAlpha)
  love.graphics.ellipse("fill", x, drawY + shadowOffY * sy,
    RADIUS * shadowScaleX * math.abs(sx), RADIUS * 0.25)

  love.graphics.push()
  love.graphics.translate(x, drawY)
  if not facingRight then love.graphics.scale(-1, 1) end
  love.graphics.rotate(wobbleAngle)
  love.graphics.scale(sx, sy)

  -- Body
  love.graphics.setColor(r, g, b, 1)
  love.graphics.ellipse("fill", 0, 0, RADIUS, RADIUS * 1.05)

  -- Head bump
  love.graphics.setColor(r * 0.95, g * 0.98, b * 1.02, 1)
  love.graphics.ellipse("fill", 0, -RADIUS * 0.55, RADIUS * 0.72, RADIUS * 0.72)

  -- Ball on head
  love.graphics.setColor(r * 1.1, g * 0.85, b * 0.75, 1)
  love.graphics.circle("fill", 0, -RADIUS * 1.15, RADIUS * 0.22)

  -- Eyes
  local eyeOpen = helpers.lerp(cfg0.eyeOpen, cfg.eyeOpen, t)
  self:_drawEyes(eyeOpen)

  love.graphics.pop()

  -- Training effort sweat drops
  if self.stateName == "training" then
    self:_drawEffort(x, y)
  end

  -- Dragging panic sweat drops (flying off in all directions)
  if self.stateName == "dragging" then
    self:_drawPanicSweat(x, y)
  end

  -- Sleep Zzz
  if self.stateName == "sleeping" then
    self:_drawZzz(x, y)
  end

  -- Tired droopy Zzz (smaller, less floaty)
  if self.stateName == "tired" then
    self:_drawTiredZzz(x, y)
  end

  love.graphics.setColor(1, 1, 1, 1)
end

function ChaoAnimator:_drawEyes(openFactor)
  local ew = 5
  local eh = math.max(1, 6 * openFactor)
  love.graphics.setColor(0.15, 0.10, 0.20, 1)
  love.graphics.ellipse("fill", -8, -RADIUS * 0.60, ew * 0.5, eh * 0.5)
  love.graphics.ellipse("fill",  8, -RADIUS * 0.60, ew * 0.5, eh * 0.5)
  -- shine
  if openFactor > 0.3 then
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.circle("fill", -6, -RADIUS * 0.65, 1.5)
    love.graphics.circle("fill",  10, -RADIUS * 0.65, 1.5)
  end
end

function ChaoAnimator:_drawPanicSweat(x, y)
  -- Tiny blue sweat drops flying outward when being carried
  local t = self.cycleTimer
  local drops = {
    { ox =  26, oy = -10, phase = 0.0 },
    { ox = -28, oy =  -5, phase = 1.1 },
    { ox =  20, oy =  14, phase = 2.2 },
    { ox = -18, oy =  16, phase = 0.7 },
  }
  for _, d in ipairs(drops) do
    local alpha = 0.5 + 0.4 * math.abs(math.sin(t * 6 + d.phase))
    local off = math.sin(t * 5 + d.phase) * 3
    love.graphics.setColor(0.45, 0.72, 0.95, alpha)
    love.graphics.ellipse("fill", x + d.ox + off, y + d.oy, 3, 4.5)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function ChaoAnimator:_drawEffort(x, y)
  -- Small animated sweat/effort drops to the side of the chao
  local t = self.cycleTimer
  for i = 1, 3 do
    local ox = x + 26 + (i - 1) * 9
    local oy = y - 18 - (i - 1) * 8 + math.sin(t * 3 + i) * 3
    local alpha = 0.55 + 0.35 * math.sin(t * 4 + i * 1.2)
    love.graphics.setColor(0.55, 0.78, 0.95, alpha)
    love.graphics.circle("fill", ox, oy, 3 - (i - 1) * 0.5)
  end
  -- Effort star burst (small yellow crosses)
  local starAlpha = 0.5 + 0.4 * math.abs(math.sin(t * 5))
  love.graphics.setColor(0.98, 0.92, 0.40, starAlpha)
  love.graphics.circle("fill", x - 30, y - 25 + math.sin(t * 3) * 3, 3)
  love.graphics.setColor(1, 1, 1, 1)
end

function ChaoAnimator:_drawZzz(x, y)
  local sizes = {10, 8, 6}
  for i, sz in ipairs(sizes) do
    local ox = x + 28 + (i - 1) * 10
    local oy = y - 30 - (i - 1) * 12 - math.sin(self.zzzTimer * 0.6 + i) * 4
    local alpha = 0.6 - (i - 1) * 0.15
    love.graphics.setColor(0.75, 0.82, 0.95, alpha)
    love.graphics.setFont(love.graphics.newFont(sz))
    love.graphics.print("z", ox, oy)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

--- Droopy "Zzz..." for the tired-but-not-asleep state.
--- Smaller letters that drift sideways and fade — looks heavy and depressed.
function ChaoAnimator:_drawTiredZzz(x, y)
  local t = self.zzzTimer
  -- Two lazy Zs floating slowly upward and to the side
  local letters = {
    { size = 8,  oxBase =  24, oyBase = -28, phase = 0.0 },
    { size = 6,  oxBase =  36, oyBase = -42, phase = 1.4 },
  }
  for _, l in ipairs(letters) do
    local drift = math.sin(t * 0.35 + l.phase) * 2
    local rise  = -math.fmod(t * 5 + l.phase * 10, 28)
    local alpha = 0.25 + 0.20 * math.abs(math.sin(t * 0.35 + l.phase))
    love.graphics.setColor(0.55, 0.60, 0.75, alpha)
    love.graphics.setFont(love.graphics.newFont(l.size))
    love.graphics.print("z", x + l.oxBase + drift, y + l.oyBase + rise)
  end
  -- Small frown / sweat to reinforce the depressed look
  local sweatAlpha = 0.3 + 0.2 * math.abs(math.sin(t * 0.8))
  love.graphics.setColor(0.55, 0.78, 0.95, sweatAlpha)
  love.graphics.ellipse("fill", x - 20, y - 10, 2.5, 4)
  love.graphics.setColor(1, 1, 1, 1)
end

return ChaoAnimator
