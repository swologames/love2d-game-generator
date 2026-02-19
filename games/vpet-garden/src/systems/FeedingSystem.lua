-- src/systems/FeedingSystem.lua
-- Manages Trees and FruitDrops. Replaces the old menu-based feeding UI.
-- Trees drop fruit when clicked. Drag dropped fruit onto the Chao to feed it.

local fruits  = require("src/data/fruits")
local Tree    = require("src/entities/Tree")
local helpers = require("src/utils/helpers")

local FEED_RADIUS = 45  -- px from Chao centre to trigger a feed
local MAX_DROPS   = 8   -- cap to avoid accumulation

-- Tree layout: corners of the garden, avoiding training zone overlap
local TREE_DEFS = {
  { x = 210,  y = 175,  fruit = fruits[1] },  -- Round Fruit  (top-left)
  { x = 1075, y = 195,  fruit = fruits[3] },  -- Run Fruit / star (top-right)
  { x = 135,  y = 545,  fruit = fruits[7] },  -- Sweet Fruit / pear (bottom-left)
  { x = 1060, y = 510,  fruit = fruits[6] },  -- Luck Fruit / bunch (bottom-right)
}

local FeedingSystem = {}
FeedingSystem.__index = FeedingSystem

function FeedingSystem:new(chao, particles)
  local f = setmetatable({}, self)
  f.chao      = chao
  f.particles = particles
  f.drops     = {}
  f.dragging  = nil   -- the FruitDrop currently being dragged
  f.trees     = {}
  for _, def in ipairs(TREE_DEFS) do
    table.insert(f.trees, Tree:new(def.x, def.y, def.fruit))
  end
  return f
end

-- ── Update ────────────────────────────────────────────────────────────────────
function FeedingSystem:update(dt)
  for _, tree in ipairs(self.trees) do tree:update(dt) end
  for i = #self.drops, 1, -1 do
    local drop = self.drops[i]
    drop:update(dt)
    if drop:isDead() then
      if self.dragging == drop then self.dragging = nil end
      table.remove(self.drops, i)
    end
  end
end

-- ── Draw ──────────────────────────────────────────────────────────────────────
function FeedingSystem:draw()
  for _, tree in ipairs(self.trees) do
    tree:draw()
    tree:drawHint()
  end
  for _, drop in ipairs(self.drops) do
    drop:draw()
  end
end

-- ── Input ─────────────────────────────────────────────────────────────────────
--- Returns true if the event was consumed.
function FeedingSystem:mousepressed(x, y, button)
  if button ~= 1 then return false end

  -- 1. Try to pick up an existing fruit drop (topmost first)
  for i = #self.drops, 1, -1 do
    if self.drops[i]:mousepressed(x, y) then
      self.dragging = self.drops[i]
      return true
    end
  end

  -- 2. Try to click a tree
  for _, tree in ipairs(self.trees) do
    local drop = tree:tryClick(x, y)
    if drop then
      if #self.drops < MAX_DROPS then
        table.insert(self.drops, drop)
      end
      return true
    end
    -- Consume click within canopy even if cooldown blocked
    local dx, dy = x - tree.canopyX, y - tree.canopyY
    if math.sqrt(dx * dx + dy * dy) <= 44 then
      return true
    end
  end

  return false
end

function FeedingSystem:mousereleased(x, y, button)
  if button ~= 1 or not self.dragging then return end
  local drop = self.dragging
  drop:mousereleased()
  self.dragging = nil

  -- Feed the Chao if drop released close enough
  local cx, cy = self.chao:getPos()
  if helpers.distance(x, y, cx, cy) <= FEED_RADIUS then
    self.chao:feed(drop.fruit)
    if self.particles then
      self.particles:spawnHearts(cx, cy - 25, 5)
      self.particles:spawnStars(cx, cy - 20, 6, drop.fruit.color)
    end
    for i, d in ipairs(self.drops) do
      if d == drop then table.remove(self.drops, i); break end
    end
  end
end

function FeedingSystem:mousemoved(x, y)
  if self.dragging then
    self.dragging:updateDrag(x, y)
  end
end

return FeedingSystem
