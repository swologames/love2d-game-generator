-- src/ui/FruitRenderer.lua
-- Draws fruit shapes programmatically using Love2D primitives.
-- No image assets — every shape is built from polygons, circles, and lines.
-- Public API: FruitRenderer.draw(fruit, x, y, scale, alpha)

local FruitRenderer = {}

-- ── Helper: build a star polygon ─────────────────────────────────────────────
local function starPoints(cx, cy, outerR, innerR, points, angleOffset)
  local verts = {}
  for i = 0, points * 2 - 1 do
    local angle = (i / (points * 2)) * math.pi * 2 + (angleOffset or -math.pi / 2)
    local r = (i % 2 == 0) and outerR or innerR
    table.insert(verts, cx + math.cos(angle) * r)
    table.insert(verts, cy + math.sin(angle) * r)
  end
  return verts
end

-- ── Shape drawers (each receives color r,g,b and scale) ──────────────────────

local function drawRound(x, y, s, r, g, b, a)
  -- Body
  love.graphics.setColor(r, g, b, a)
  love.graphics.circle("fill", x, y, 13 * s)
  -- Shine
  love.graphics.setColor(1, 1, 1, 0.45 * a)
  love.graphics.circle("fill", x - 4 * s, y - 4 * s, 4 * s)
  -- Stem
  love.graphics.setColor(0.40, 0.25, 0.10, a)
  love.graphics.setLineWidth(2 * s)
  love.graphics.line(x, y - 13 * s, x + 3 * s, y - 18 * s)
  -- Leaf
  love.graphics.setColor(0.30, 0.72, 0.30, a)
  love.graphics.ellipse("fill", x + 5 * s, y - 17 * s, 5 * s, 3 * s, 20)
  love.graphics.setLineWidth(1)
end

local function drawStar(x, y, s, r, g, b, a)
  local verts = starPoints(x, y, 14 * s, 6 * s, 5)
  love.graphics.setColor(r, g, b, a)
  love.graphics.polygon("fill", verts)
  -- Inner glow
  local inner = starPoints(x, y, 8 * s, 4 * s, 5)
  love.graphics.setColor(math.min(r + 0.25, 1), math.min(g + 0.25, 1), math.min(b + 0.25, 1), 0.55 * a)
  love.graphics.polygon("fill", inner)
  -- Stem
  love.graphics.setColor(0.40, 0.25, 0.10, a)
  love.graphics.setLineWidth(2 * s)
  love.graphics.line(x, y - 14 * s, x, y - 19 * s)
  love.graphics.setLineWidth(1)
end

local function drawPear(x, y, s, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  -- Lower bulb (wide)
  love.graphics.ellipse("fill", x, y + 4 * s, 11 * s, 13 * s, 20)
  -- Upper bulb (narrow)
  love.graphics.ellipse("fill", x, y - 6 * s, 7 * s, 9 * s, 20)
  -- Shine
  love.graphics.setColor(1, 1, 1, 0.40 * a)
  love.graphics.circle("fill", x - 3 * s, y - 8 * s, 3 * s)
  -- Stem
  love.graphics.setColor(0.40, 0.25, 0.10, a)
  love.graphics.setLineWidth(2 * s)
  love.graphics.line(x, y - 15 * s, x + 2 * s, y - 21 * s)
  -- Leaf
  love.graphics.setColor(0.30, 0.72, 0.30, a)
  love.graphics.ellipse("fill", x + 5 * s, y - 20 * s, 5 * s, 3 * s, 20)
  love.graphics.setLineWidth(1)
end

local function drawBunch(x, y, s, r, g, b, a)
  -- Three grapes in a triangle
  local positions = { {x - 7*s, y + 4*s}, {x + 7*s, y + 4*s}, {x, y - 5*s} }
  for _, p in ipairs(positions) do
    love.graphics.setColor(r, g, b, a)
    love.graphics.circle("fill", p[1], p[2], 8 * s)
    love.graphics.setColor(1, 1, 1, 0.35 * a)
    love.graphics.circle("fill", p[1] - 2*s, p[2] - 2*s, 2.5 * s)
  end
  -- Stem
  love.graphics.setColor(0.40, 0.25, 0.10, a)
  love.graphics.setLineWidth(2 * s)
  love.graphics.line(x, y - 13 * s, x, y - 19 * s)
  -- Leaf
  love.graphics.setColor(0.30, 0.72, 0.30, a)
  love.graphics.ellipse("fill", x + 5 * s, y - 17 * s, 6 * s, 3 * s, 20)
  love.graphics.setLineWidth(1)
end

local function drawDiamond(x, y, s, r, g, b, a)
  -- Gem shape: top, mid-left, bottom, mid-right
  local pts = { x, y-15*s,  x+11*s, y-2*s,  x, y+12*s,  x-11*s, y-2*s }
  love.graphics.setColor(r, g, b, a)
  love.graphics.polygon("fill", pts)
  -- Facet highlight
  love.graphics.setColor(1, 1, 1, 0.45 * a)
  love.graphics.polygon("fill", x, y-15*s, x+11*s, y-2*s, x, y-2*s)
  -- Facet outline
  love.graphics.setColor(math.max(r-0.2,0), math.max(g-0.2,0), math.max(b-0.2,0), 0.7 * a)
  love.graphics.setLineWidth(1.5 * s)
  love.graphics.polygon("line", pts)
  love.graphics.setLineWidth(1)
end

local function drawHeart(x, y, s, r, g, b, a)
  love.graphics.setColor(r, g, b, a)
  -- Two circles forming the top
  love.graphics.circle("fill", x - 6*s, y - 4*s, 8*s)
  love.graphics.circle("fill", x + 6*s, y - 4*s, 8*s)
  -- Bottom triangle
  love.graphics.polygon("fill", x - 14*s, y - 4*s,  x + 14*s, y - 4*s,  x, y + 11*s)
  -- Shine
  love.graphics.setColor(1, 1, 1, 0.40 * a)
  love.graphics.circle("fill", x - 7*s, y - 7*s, 3*s)
end

local function drawCrescent(x, y, s, r, g, b, a)
  -- Approximate crescent via polygon: outer arc + inner arc
  local outerR, innerR, offsetX = 14*s, 11*s, 6*s
  local verts = {}
  -- Outer arc: -130° to 130°
  for deg = -130, 130, 18 do
    local rad = math.rad(deg)
    table.insert(verts, x + math.cos(rad) * outerR)
    table.insert(verts, y + math.sin(rad) * outerR)
  end
  -- Inner arc: 130° back to -130°, shifted right
  for deg = 130, -130, -18 do
    local rad = math.rad(deg)
    table.insert(verts, x + offsetX + math.cos(rad) * innerR)
    table.insert(verts, y + math.sin(rad) * innerR)
  end
  love.graphics.setColor(r, g, b, a)
  love.graphics.polygon("fill", verts)
  -- Shine dot
  love.graphics.setColor(1, 1, 1, 0.40 * a)
  love.graphics.circle("fill", x - 6*s, y - 6*s, 3*s)
end

-- ── Shape dispatch table ──────────────────────────────────────────────────────
local SHAPES = {
  round    = drawRound,
  star     = drawStar,
  pear     = drawPear,
  bunch    = drawBunch,
  diamond  = drawDiamond,
  heart    = drawHeart,
  crescent = drawCrescent,
}

-- ── Public API ────────────────────────────────────────────────────────────────
--- Draw a fruit at (x, y) using its shape definition.
-- @param fruit   table from src/data/fruits.lua (must have .color and .shape)
-- @param x, y   centre position in screen pixels
-- @param scale  optional scale multiplier (default 1.0)
-- @param alpha  optional opacity 0..1 (default 1.0)
function FruitRenderer.draw(fruit, x, y, scale, alpha)
  scale = scale or 1.0
  alpha = alpha or 1.0
  local c = fruit.color
  local fn = SHAPES[fruit.shape] or drawRound
  fn(x, y, scale, c[1], c[2], c[3], alpha)
  love.graphics.setColor(1, 1, 1, 1)
end

return FruitRenderer
