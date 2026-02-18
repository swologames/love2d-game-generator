-- Player Hiding Ability Sub-module
-- Manages hiding state, current hiding spot, and grace period

local GRACE_PERIOD_DURATION = 2.0  -- seconds of invulnerability after exiting hiding

local HidingAbility = {}

-- Decrement grace period timer each frame
function HidingAbility.updateGracePeriod(self, dt)
  if self.hidingGracePeriod > 0 then
    self.hidingGracePeriod = self.hidingGracePeriod - dt
    if self.hidingGracePeriod < 0 then
      self.hidingGracePeriod = 0
    end
  end
end

-- Enter a hiding spot. Returns true on success.
function HidingAbility.enter(self, hidingSpot)
  if self.isHiding then return false end
  if not hidingSpot then return false end

  self.isHiding = true
  self.currentHidingSpot = hidingSpot
  self.vx = 0
  self.vy = 0
  self.isMoving = false

  -- Snap position to hiding spot centre
  if hidingSpot.x and hidingSpot.y then
    self.x = hidingSpot.x - self.width  / 2
    self.y = hidingSpot.y - self.height / 2
  end

  return true
end

-- Exit hiding state, granting a brief grace period. Returns true on success.
function HidingAbility.exit(self)
  if not self.isHiding then return false end

  self.isHiding = false
  self.currentHidingSpot = nil
  self.hidingGracePeriod = GRACE_PERIOD_DURATION

  return true
end

return HidingAbility
