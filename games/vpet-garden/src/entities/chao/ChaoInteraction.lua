-- src/entities/chao/ChaoInteraction.lua
-- Tracks mouse hover and petting state, emits interaction events.

local helpers = require("src/utils/helpers")

local ChaoInteraction = {}
ChaoInteraction.__index = ChaoInteraction

local HIT_RADIUS     = 30   -- pixels — collision radius for mouse hit
local PET_HOLD_TIME  = 0.25 -- seconds of hold to register a full pet

function ChaoInteraction:new()
  local i = setmetatable({}, self)
  i.isHovered    = false
  i.isBeingPetted = false
  i.holdTimer    = 0
  i._onPet       = nil   -- callback(x, y)
  i._onHover     = nil   -- callback(isHovered)
  return i
end

--- Register an optional callback fired when a full pet is registered.
-- cb(x, y) is called with the chao's world position.
function ChaoInteraction:onPetCallback(cb)
  self._onPet = cb
end

--- Register an optional callback for hover state changes.
function ChaoInteraction:onHoverCallback(cb)
  self._onHover = cb
end

--- Call every frame.
function ChaoInteraction:update(dt, chaoX, chaoY, mx, my, mouseDown)
  local wasHovered = self.isHovered
  self.isHovered = helpers.pointInCircle(mx, my, chaoX, chaoY, HIT_RADIUS)

  if self.isHovered ~= wasHovered and self._onHover then
    self._onHover(self.isHovered)
  end

  if self.isHovered and mouseDown then
    self.isBeingPetted = true
    self.holdTimer = self.holdTimer + dt
    if self.holdTimer >= PET_HOLD_TIME then
      self.holdTimer = 0
      if self._onPet then self._onPet(chaoX, chaoY) end
    end
  else
    self.isBeingPetted = false
    self.holdTimer = 0
  end
end

--- Call on mouse-press over the chao (instant single-click pet).
function ChaoInteraction:handlePress(x, y, chaoX, chaoY)
  if helpers.pointInCircle(x, y, chaoX, chaoY, HIT_RADIUS) then
    if self._onPet then self._onPet(chaoX, chaoY) end
    return true
  end
  return false
end

return ChaoInteraction
