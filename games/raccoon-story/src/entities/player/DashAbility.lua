-- Player Dash Ability Sub-module
-- Manages dash timer, cooldown, and trigger

local DashAbility = {}

-- Call every frame to tick timers
function DashAbility.updateTimers(self, dt)
  -- Tick cooldown
  if self.dashCooldownTimer > 0 then
    self.dashCooldownTimer = self.dashCooldownTimer - dt
    if self.dashCooldownTimer < 0 then
      self.dashCooldownTimer = 0
    end
  end

  -- Tick active dash
  if self.isDashing then
    self.dashTimer = self.dashTimer + dt
    if self.dashTimer >= self.dashDuration then
      self.isDashing = false
      self.dashTimer = 0
    end
  end
end

-- Attempt to start a dash. Returns true if dash was started.
function DashAbility.trigger(self)
  if self.isDashing then return false end
  if self.dashCooldownTimer > 0 then return false end

  self.isDashing = true
  self.dashTimer = 0
  self.dashCooldownTimer = self.dashCooldown
  return true
end

return DashAbility
