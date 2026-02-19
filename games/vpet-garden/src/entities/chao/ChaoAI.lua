-- src/entities/chao/ChaoAI.lua
-- Simple wander AI for the Chao.
-- States: wandering, idle, happy, eating, sleeping, tired, dragging, training

local helpers = require("src/utils/helpers")

local ChaoAI = {}
ChaoAI.__index = ChaoAI

-- Garden bounds (the Chao can walk around in)
local BOUNDS = { x = 160, y = 120, w = 960, h = 480 }

local SPEED           = 40
local IDLE_MIN        = 1.5
local IDLE_MAX        = 4.0
local WANDER_MIN      = 1.0
local WANDER_MAX      = 3.5
local SLEEP_ENERGY    = 15
local WAKE_ENERGY     = 50
local TIRED_ENERGY    = 35   -- below this, chao becomes visibly tired (outside sleep zone)

function ChaoAI:new(x, y)
  local a = setmetatable({}, self)
  a.x      = x or 400
  a.y      = y or 300
  a.vx     = 0
  a.vy     = 0
  a.state  = "idle"
  a.timer  = helpers.randFloat(IDLE_MIN, IDLE_MAX)
  a.facingRight     = true
  a._overrideTimer  = 0
  a._overrideLocked = false   -- true = hold until releaseState() is called
  return a
end

--- Force a state externally.
-- Pass duration > 0 for a timed override.
-- Pass duration <= 0 (or nil) for a permanent lock until releaseState().
function ChaoAI:forceState(state, duration)
  self.state = state
  self.vx    = 0
  self.vy    = 0
  if duration and duration > 0 then
    self._overrideTimer  = duration
    self._overrideLocked = false
  else
    self._overrideTimer  = 0
    self._overrideLocked = true
  end
end

--- Release a permanent lock, returning the chao to normal AI next frame.
function ChaoAI:releaseState()
  self._overrideLocked = false
  self._overrideTimer  = 0
end

function ChaoAI:update(dt, stats)
  -- Permanent or timed external override
  if self._overrideLocked then
    self:_applyVelocity(dt)
    return
  end
  if self._overrideTimer > 0 then
    self._overrideTimer = self._overrideTimer - dt
    if self._overrideTimer <= 0 then
      self.state = "idle"
      self.timer = helpers.randFloat(IDLE_MIN, IDLE_MAX)
    end
    self:_applyVelocity(dt)
    return
  end

  -- Sleep check (auto-sleep at very low energy)
  if self.state ~= "sleeping" and stats and stats.energy < SLEEP_ENERGY then
    self.state = "sleeping"
    self.vx    = 0
    self.vy    = 0
    self.timer = helpers.randFloat(5, 12)
    return
  end
  if self.state == "sleeping" then
    self.timer = self.timer - dt
    if self.timer <= 0 and stats and stats.energy >= WAKE_ENERGY then
      self.state = "idle"
      self.timer = helpers.randFloat(IDLE_MIN, IDLE_MAX)
    end
    return
  end

  -- Tired check: low energy but not fully asleep yet — chao looks exhausted
  local isTired = stats and stats.energy < TIRED_ENERGY
  if isTired and self.state ~= "tired" then
    self.state = "tired"
    self.vx    = 0
    self.vy    = 0
    self.timer = helpers.randFloat(3, 6)
    return
  end
  if self.state == "tired" then
    -- Shuffle very slowly or stay still
    self.timer = self.timer - dt
    if not isTired then
      -- Recovered enough energy
      self.state = "idle"
      self.timer = helpers.randFloat(IDLE_MIN, IDLE_MAX)
    elseif self.timer <= 0 then
      -- Occasionally shuffle a tiny step then slump again
      local angle = helpers.randFloat(0, 2 * math.pi)
      self.vx    = math.cos(angle) * SPEED * 0.25
      self.vy    = math.sin(angle) * SPEED * 0.25
      self.timer = helpers.randFloat(0.4, 1.0)
      if self.vx ~= 0 then self.facingRight = self.vx > 0 end
    end
    self:_applyVelocity(dt)
    self:_clampToBounds()
    -- Bleed velocity when tired so the chao drifts to a stop
    self.vx = self.vx * (1 - dt * 4)
    self.vy = self.vy * (1 - dt * 4)
    return
  end

  -- Normal wander/idle cycle
  self.timer = self.timer - dt
  if self.state == "idle" then
    self.vx = 0
    self.vy = 0
    if self.timer <= 0 then
      self:_chooseNewDirection()
    end
  elseif self.state == "wandering" then
    if self.timer <= 0 then
      self.state = "idle"
      self.timer = helpers.randFloat(IDLE_MIN, IDLE_MAX)
    end
  end

  self:_applyVelocity(dt)
  self:_clampToBounds()
end

function ChaoAI:_chooseNewDirection()
  local angle = helpers.randFloat(0, 2 * math.pi)
  self.vx    = math.cos(angle) * SPEED
  self.vy    = math.sin(angle) * SPEED
  self.state = "wandering"
  self.timer = helpers.randFloat(WANDER_MIN, WANDER_MAX)
  if self.vx ~= 0 then
    self.facingRight = self.vx > 0
  end
end

function ChaoAI:_applyVelocity(dt)
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
end

function ChaoAI:_clampToBounds()
  local b = BOUNDS
  if self.x < b.x      then self.x = b.x;      self.vx = math.abs(self.vx)  end
  if self.x > b.x+b.w  then self.x = b.x+b.w;  self.vx = -math.abs(self.vx) end
  if self.y < b.y      then self.y = b.y;       self.vy = math.abs(self.vy)  end
  if self.y > b.y+b.h  then self.y = b.y+b.h;  self.vy = -math.abs(self.vy) end
end

return ChaoAI
