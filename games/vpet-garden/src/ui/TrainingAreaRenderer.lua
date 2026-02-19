-- src/ui/TrainingAreaRenderer.lua
-- Themed programmatic visuals for each training zone.
-- Each zone draws its own animated background before labels.
-- Animations driven by self.timer (updated each frame).

local trainingAreas = require("src/data/training_areas")

local TrainingAreaRenderer = {}
TrainingAreaRenderer.__index = TrainingAreaRenderer

-- ── Zone themed drawers (x,y,w,h = area rect, t = timer, font = small font) ─

local function drawSwimZone(x, y, w, h, t)
  local cx, cy = x + w/2, y + h/2
  love.graphics.setColor(0.28, 0.55, 0.88, 0.55)  -- water base
  love.graphics.ellipse("fill", cx, cy, w*0.48, h*0.48)
  love.graphics.setColor(0.22, 0.42, 0.78, 0.30)  -- deep centre
  love.graphics.ellipse("fill", cx, cy, w*0.30, h*0.30)
  for i = 1, 3 do  -- ripple rings
    local phase = t * 1.5 + i * 1.2
    local scale = 0.22 + 0.22 * math.abs(math.sin(phase))
    love.graphics.setColor(0.72, 0.92, 1.0, 0.28 - scale * 0.10)
    love.graphics.ellipse("line", cx, cy, w * scale, h * scale * 0.55)
  end
  local pads = {  -- lily pads
    { cx - w*0.18, cy + h*0.08 },
    { cx + w*0.15, cy - h*0.10 },
    { cx + w*0.02, cy + h*0.16 },
  }
  for _, p in ipairs(pads) do
    love.graphics.setColor(0.26, 0.60, 0.28, 0.85)
    love.graphics.circle("fill", p[1], p[2], 7)
    love.graphics.setColor(0.20, 0.48, 0.22, 0.60)
    love.graphics.circle("line", p[1], p[2], 7)
    love.graphics.setColor(0.98, 0.90, 0.55, 0.90)
    love.graphics.circle("fill", p[1], p[2], 2)
  end
  local shimmer  -- shimmer lines = 0.30 + 0.12 * math.sin(t * 2.5)
  love.graphics.setColor(0.82, 0.96, 1.0, shimmer)
  love.graphics.line(cx - w*0.28, cy - h*0.06, cx + w*0.28, cy - h*0.06)
  love.graphics.line(cx - w*0.14, cy + h*0.04, cx + w*0.14, cy + h*0.04)
end

local function drawRunTrack(x, y, w, h, t)
  local cx, cy = x + w/2, y + h/2
  love.graphics.setColor(0.72, 0.54, 0.24, 0.55)  -- dirt base
  love.graphics.ellipse("fill", cx, cy, w*0.48, h*0.48)
  love.graphics.setColor(0.60, 0.42, 0.18, 0.28)  -- inner track band
  love.graphics.ellipse("fill", cx, cy, w*0.42, h*0.28)
  love.graphics.setColor(0.96, 0.92, 0.76, 0.68)  -- lane dashes
  local dashW, count = w * 0.07, 5
  local gap = (w * 0.84) / count
  for i = 0, count - 1 do
    love.graphics.rectangle("fill", x + w*0.08 + i * gap, cy - 1.5, dashW, 3)
  end
  local offset = (t * 55) % (w * 0.78)  -- motion-blur streaks
  love.graphics.setColor(0.95, 0.88, 0.60, 0.38)
  for i = 1, 3 do
    local bx = x + w*0.06 + ((offset + i * w * 0.27) % (w * 0.84))
    local by = cy - h*0.18 + (i - 1) * h * 0.18
    love.graphics.line(bx, by, bx + 16, by)
  end
  love.graphics.setColor(0.95, 0.82, 0.46, 0.50)  -- direction chevrons
  for i = 0, 2 do
    local chx = cx - w*0.18 + i * w*0.18
    love.graphics.line(chx, cy + h*0.18, chx + 8, cy + h*0.03, chx + 16, cy + h*0.18)
  end
end

local function drawFlyCliff(x, y, w, h, t)
  local cx, cy = x + w/2, y + h/2
  love.graphics.setColor(0.62, 0.74, 0.98, 0.55)  -- sky base
  love.graphics.ellipse("fill", cx, cy, w*0.48, h*0.48)
  love.graphics.setColor(0.88, 0.94, 1.0, 0.25)  -- sky highlight
  love.graphics.ellipse("fill", cx, cy - h*0.18, w*0.38, h*0.22)
  local clouds = {
    { cx - w*0.20, cy - h*0.18 },
    { cx + w*0.18, cy - h*0.22 },
  }
  for _, c in ipairs(clouds) do
    local drift = math.sin(t * 0.55 + c[1] * 0.01) * 3
    love.graphics.setColor(1, 1, 1, 0.78)
    love.graphics.circle("fill", c[1] + drift,      c[2],     9)
    love.graphics.circle("fill", c[1] + drift + 10, c[2],     7)
    love.graphics.circle("fill", c[1] + drift - 8,  c[2] + 2, 6)
  end
  local wA  -- wind arcs = 0.30 + 0.18 * math.sin(t * 1.8)
  love.graphics.setColor(0.82, 0.92, 1.0, wA)
  love.graphics.arc("line", cx - w*0.06, cy + h*0.12, 22, -0.40, 0.40)
  love.graphics.arc("line", cx + w*0.20, cy + h*0.04, 15, -0.50, 0.30)
  local spts = {  -- sparkle crosshairs
    { cx - w*0.30, cy + h*0.02 },
    { cx + w*0.28, cy + h*0.08 },
    { cx + w*0.06, cy - h*0.02 },
  }
  for i, s in ipairs(spts) do
    local alpha = 0.45 + 0.55 * math.abs(math.sin(t * 2.5 + i * 2.0))
    local sz    = 1.5 + math.abs(math.sin(t * 3.0 + i)) * 1.5
    love.graphics.setColor(1, 1, 0.88, alpha * 0.82)
    love.graphics.circle("fill", s[1], s[2], sz)
    love.graphics.line(s[1] - sz*2.2, s[2], s[1] + sz*2.2, s[2])
    love.graphics.line(s[1], s[2] - sz*2.2, s[1], s[2] + sz*2.2)
  end
end

local function drawPowerRocks(x, y, w, h, t)
  local cx, cy = x + w/2, y + h/2
  love.graphics.setColor(0.50, 0.44, 0.40, 0.55)  -- stone base
  love.graphics.ellipse("fill", cx, cy, w*0.48, h*0.48)
  love.graphics.setColor(0.68, 0.38, 0.32, 0.20)  -- reddish undertone
  love.graphics.ellipse("fill", cx, cy, w*0.38, h*0.38)
  local boulders = {
    { cx - w*0.22, cy + h*0.10, 13, 10 },
    { cx + w*0.16, cy + h*0.12, 11,  9 },
    { cx,          cy - h*0.10, 10,  8 },
    { cx + w*0.26, cy - h*0.02,  8,  7 },
  }
  for _, b in ipairs(boulders) do
    love.graphics.setColor(0.60, 0.54, 0.50, 0.92)
    love.graphics.ellipse("fill", b[1], b[2], b[3], b[4])
    love.graphics.setColor(0.78, 0.72, 0.68, 0.58)  -- highlight chip
    love.graphics.ellipse("fill", b[1] - b[3]*0.28, b[2] - b[4]*0.30, b[3]*0.44, b[4]*0.36)
    love.graphics.setColor(0.36, 0.30, 0.26, 0.68)  -- rim
    love.graphics.ellipse("line", b[1], b[2], b[3], b[4])
  end
  love.graphics.setColor(0.28, 0.22, 0.18, 0.58)  -- ground cracks
  love.graphics.line(cx - w*0.28, cy + h*0.22, cx - w*0.08, cy + h*0.06, cx + w*0.04, cy + h*0.18)
  love.graphics.line(cx + w*0.08, cy + h*0.20, cx + w*0.22, cy + h*0.06)
end

local function drawLuckGarden(x, y, w, h, t)
  local cx, cy = x + w/2, y + h/2
  love.graphics.setColor(0.18, 0.56, 0.26, 0.52)  -- mystical green base
  love.graphics.ellipse("fill", cx, cy, w*0.48, h*0.48)
  love.graphics.setColor(0.70, 0.90, 0.40, 0.14 + 0.08 * math.sin(t * 1.6))  -- golden glow
  love.graphics.ellipse("fill", cx, cy, w*0.28, h*0.28)
  local clovers = {
    { cx - w*0.22, cy + h*0.08 },
    { cx + w*0.18, cy - h*0.08 },
    { cx - w*0.04, cy - h*0.15 },
  }
  for _, cl in ipairs(clovers) do
    love.graphics.setColor(0.24, 0.72, 0.34, 0.82)
    for i = 0, 3 do
      local ang = i * math.pi / 2
      love.graphics.circle("fill", cl[1] + math.cos(ang)*4.5, cl[2] + math.sin(ang)*4.5, 4.5)
    end
    love.graphics.setColor(0.40, 0.88, 0.48, 0.58)
    love.graphics.circle("fill", cl[1], cl[2], 2.5)
  end
  local spts = {  -- sparkle crosses
    { cx - w*0.28, cy - h*0.05 }, { cx + w*0.24, cy + h*0.12 },
    { cx + w*0.06, cy + h*0.22 }, { cx - w*0.08, cy + h*0.18 },
    { cx + w*0.28, cy - h*0.18 },
  }
  for i, sp in ipairs(spts) do
    local alpha = 0.35 + 0.65 * math.abs(math.sin(t * 2.8 + i * 1.4))
    local sz    = 1.5 + math.abs(math.sin(t * 3.0 + i)) * 2.0
    love.graphics.setColor(0.94, 1.0, 0.70, alpha)
    love.graphics.circle("fill", sp[1], sp[2], sz)
    love.graphics.line(sp[1] - sz*1.8, sp[2], sp[1] + sz*1.8, sp[2])
    love.graphics.line(sp[1], sp[2] - sz*1.8, sp[1], sp[2] + sz*1.8)
  end
end

local function drawNapSpot(x, y, w, h, t, smallFont)
  local cx, cy = x + w/2, y + h/2
  love.graphics.setColor(0.60, 0.68, 0.95, 0.55)  -- lavender base
  love.graphics.ellipse("fill", cx, cy, w*0.48, h*0.48)
  love.graphics.setColor(0.86, 0.88, 1.0, 0.10 + 0.06 * math.sin(t * 1.2))  -- moonbeam glow
  love.graphics.ellipse("fill", cx, cy - h*0.05, w*0.40, h*0.38)
  love.graphics.setColor(0.96, 0.96, 0.74, 0.92)  -- crescent moon body
  love.graphics.circle("fill", cx - w*0.22, cy - h*0.16, 11)
  love.graphics.setColor(0.60, 0.68, 0.95, 0.95)   -- same as base to erase slice
  love.graphics.circle("fill", cx - w*0.16, cy - h*0.22, 9)
  local sA  -- tiny star near moon = 0.55 + 0.45 * math.abs(math.sin(t * 2.2))
  love.graphics.setColor(0.96, 0.96, 0.74, sA)
  love.graphics.circle("fill", cx - w*0.06, cy - h*0.26, 2)
  if smallFont then love.graphics.setFont(smallFont) end  -- Zzz wisps
  local zGlyphs = { "Z", "z", "z" }
  for i, g in ipairs(zGlyphs) do
    local phase = (t * 0.65 + i * 0.85) % 1.8
    local zy    = cy + h*0.18 - (phase / 1.8) * h * 0.58
    local zx    = cx + w*0.18 + math.sin(phase * 3) * 7 + (i - 2) * 9
    local za    = (1.0 - phase / 1.8) * 0.72
    love.graphics.setColor(0.80, 0.82, 1.0, za)
    love.graphics.print(g, zx, zy)
  end
end

-- ── Theme dispatch ───────────────────────────────────────────────────────────
local themeDrawers = {
  swim  = drawSwimZone,
  run   = drawRunTrack,
  fly   = drawFlyCliff,
  power = drawPowerRocks,
  luck  = drawLuckGarden,
  sleep = drawNapSpot,
}

-- ── Constructor ──────────────────────────────────────────────────────────────
function TrainingAreaRenderer:new(chao, drag, training)
  local o = setmetatable({}, self)
  o.chao       = chao
  o.drag       = drag
  o.training   = training
  o.timer      = 0
  o.labelFont  = love.graphics.newFont(10)
  o.headerFont = love.graphics.newFont(12)
  o.smallFont  = love.graphics.newFont(9)
  return o
end

function TrainingAreaRenderer:update(dt)
  self.timer = self.timer + dt
end

-- ── Main draw ────────────────────────────────────────────────────────────────
function TrainingAreaRenderer:draw()
  local t           = self.timer
  local isDragging  = self.drag:isDragging()
  local hoveredArea = self.drag:hoveredArea()
  local activeArea  = self.training.activeArea
  local headerFont  = self.headerFont
  local labelFont   = self.labelFont

  for _, area in ipairs(trainingAreas) do
    local ax, ay, aw, ah = area.x, area.y, area.w, area.h
    local cx = ax + aw * 0.5
    local cy = ay + ah * 0.5
    local rx = aw * 0.52
    local ry = ah * 0.52
    local c  = area.color

    local isActive  = activeArea == area
    local isHovered = hoveredArea == area
    local pulse     = 0.5 + 0.5 * math.sin(t * 3 + cx * 0.01)

    -- Themed background visual
    local drawer = themeDrawers[area.stat]
    if drawer then
      drawer(ax, ay, aw, ah, t, self.smallFont)
    end

    -- Hover / active overlay tint
    if isActive then
      love.graphics.setColor(c[1], c[2], c[3], 0.20 + 0.10 * pulse)
      love.graphics.ellipse("fill", cx, cy, rx, ry)
    elseif isHovered then
      love.graphics.setColor(c[1], c[2], c[3], 0.28 + 0.12 * pulse)
      love.graphics.ellipse("fill", cx, cy, rx, ry)
    end

    -- Rim border (brighter when active/hovered)
    local rimAlpha = isActive  and (0.65 + 0.25 * pulse)
                  or (isDragging and 0.50 or 0.22)
    love.graphics.setColor(c[1], c[2], c[3], rimAlpha)
    love.graphics.ellipse("line", cx, cy, rx, ry)

    -- Label with drop-shadow contrast fix
    local labelAlpha = isDragging and 1.0 or 0.85
    love.graphics.setFont(headerFont)
    local lw = headerFont:getWidth(area.label)
    local lh = headerFont:getHeight()
    local lx = cx - lw * 0.5
    local ly = cy - lh * 0.5 - 2
    love.graphics.setColor(0, 0, 0, labelAlpha * 0.70)
    love.graphics.print(area.label, lx + 1, ly + 1)
    love.graphics.setColor(
      math.min(c[1] * 1.8 + 0.30, 1),
      math.min(c[2] * 1.8 + 0.30, 1),
      math.min(c[3] * 1.8 + 0.30, 1),
      labelAlpha)
    love.graphics.print(area.label, lx, ly)

    -- Stat readout when actively training here
    if isActive then
      local displayStat = area.stat == "sleep" and "energy" or area.stat
      local val     = math.floor(self.chao.stats[displayStat])
      local statStr = displayStat:upper() .. ": " .. val
      love.graphics.setFont(labelFont)
      love.graphics.setColor(0, 0, 0, 0.80)
      local sw = labelFont:getWidth(statStr)
      love.graphics.print(statStr, cx - sw * 0.5 + 1, cy + lh * 0.5 + 3)
      love.graphics.setColor(1, 1, 0.85, 0.95)
      love.graphics.print(statStr, cx - sw * 0.5, cy + lh * 0.5 + 2)
    end
  end

  love.graphics.setColor(1, 1, 1, 1)
end

return TrainingAreaRenderer
