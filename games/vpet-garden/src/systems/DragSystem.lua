-- src/systems/DragSystem.lua
-- Mouse-drag mechanic for the Chao.
-- Short click (<DRAG_DELAY seconds) on the Chao = pet.
-- Hold click (>= DRAG_DELAY seconds) + move = drag to lift.
-- Dropping onto a training area starts continuous training.
-- Dragging out of a training area stops training.

local helpers = require("src/utils/helpers")
local areas   = require("src/data/training_areas")

local DragSystem = {}
DragSystem.__index = DragSystem

local PICK_RADIUS  = 34    -- px: how close mouse must be to pick up the Chao
local SPRING       = 14    -- spring stiffness (higher = snappier follow)
local DRAG_DELAY   = 0.20  -- seconds of hold before a press becomes a drag

function DragSystem:new(chao, trainingSystem)
  local d = setmetatable({}, self)
  d.chao      = chao
  d.training  = trainingSystem
  d.dragging  = false
  d.offsetX   = 0
  d.offsetY   = 0
  d.wobble    = 0
  -- pending-press state
  d._pending      = false   -- waiting to decide click vs drag
  d._pendingTimer = 0
  d._pressX       = 0
  d._pressY       = 0
  d._petCallback  = nil     -- called when a short-click is confirmed as a pet
  return d
end

--- Register a callback to fire when a short press is resolved as a pet.
function DragSystem:onPetClick(cb)
  self._petCallback = cb
end

-- ── Update ────────────────────────────────────────────────────────────────────
function DragSystem:update(dt)
  -- Pending: count hold time, promote to drag when threshold is reached
  if self._pending then
    self._pendingTimer = self._pendingTimer + dt
    if self._pendingTimer >= DRAG_DELAY then
      self:_startDrag(self._pressX, self._pressY)
    end
  end

  if not self.dragging then return end

  local mx, my = love.mouse.getPosition()
  local tx = mx - self.offsetX
  local ty = my - self.offsetY

  -- Exponential spring follow — gives a fun slightly-lagging dangle
  local t = 1 - math.exp(-SPRING * dt)
  self.chao.ai.x = self.chao.ai.x + (tx - self.chao.ai.x) * t
  self.chao.ai.y = self.chao.ai.y + (ty - self.chao.ai.y) * t

  self.wobble = self.wobble + dt
end

-- ── Input ────────────────────────────────────────────────────────────────────
--- Returns true if the click was consumed (hit the Chao).
function DragSystem:mousepressed(x, y, button)
  if button ~= 1 then return false end

  local cx, cy = self.chao.ai.x, self.chao.ai.y
  if helpers.distance(x, y, cx, cy) <= PICK_RADIUS then
    -- Start pending — we don't know yet if this is a click or drag
    self._pending      = true
    self._pendingTimer = 0
    self._pressX       = x
    self._pressY       = y
    return true   -- consume the event so other systems don't also react
  end
  return false
end

function DragSystem:mousereleased(x, y, button)
  if button ~= 1 then return end

  -- Released while still pending → short click → pet
  if self._pending then
    self._pending = false
    if self._petCallback then
      self._petCallback(self.chao.ai.x, self.chao.ai.y)
    end
    return
  end

  if not self.dragging then return end
  self.dragging = false

  local area = self:_areaAt(self.chao.ai.x, self.chao.ai.y)
  if area then
    self.training:startTraining(area)
    self.chao.ai:forceState("training", -1)
  else
    self.chao.ai:releaseState()
    self.chao.ai:forceState("happy", 1.8)
  end
end

-- ── Private ───────────────────────────────────────────────────────────────────
function DragSystem:_startDrag(x, y)
  self._pending = false
  self.dragging = true
  self.offsetX  = x - self.chao.ai.x
  self.offsetY  = y - self.chao.ai.y
  self.wobble   = 0

  self.training:stopTraining()
  self.chao.ai:forceState("dragging", -1)
end

-- ── Queries ───────────────────────────────────────────────────────────────────
function DragSystem:isDragging()
  return self.dragging
end

--- Returns training area the Chao is currently hovering over (or nil).
function DragSystem:hoveredArea()
  if not self.dragging then return nil end
  return self:_areaAt(self.chao.ai.x, self.chao.ai.y)
end

function DragSystem:_areaAt(x, y)
  for _, area in ipairs(areas) do
    if x >= area.x and x <= area.x + area.w
    and y >= area.y and y <= area.y + area.h then
      return area
    end
  end
  return nil
end

return DragSystem
