-- src/systems/TrainingSystem.lua
-- Continuous area-based training.
-- While the Chao sits in a training zone it slowly gains that stat;
-- energy drains faster. Dragging the Chao out (or exhaustion) stops training.

local helpers = require("src/utils/helpers")

local TrainingSystem = {}
TrainingSystem.__index = TrainingSystem

local STAT_GAIN_RATE    = 1.5    -- stat points per second
local ENERGY_DRAIN_RATE = 4.0   -- extra energy drain per second while training
local PARTICLE_INTERVAL = 2.2   -- seconds between particle bursts
local MIN_ENERGY        = 5     -- exhaustion threshold

-- Sleep area constants
local SLEEP_ENERGY_RATE  = 8.0  -- energy restored per second while sleeping in Nap Spot
local SLEEP_HAPPY_RATE   = 1.0  -- happiness also ticks up while napping
local SLEEP_WAKE_ENERGY  = 90   -- wake threshold: Chao wakes once fully rested

function TrainingSystem:new(chao, particles)
  local t = setmetatable({}, self)
  t.chao       = chao
  t.particles  = particles
  t.activeArea = nil
  t.tickTimer  = 0
  return t
end

function TrainingSystem:setParticles(particles)
  self.particles = particles
end

function TrainingSystem:startTraining(area)
  self.activeArea = area
  self.tickTimer  = 0
end

--- Stop training. Does NOT touch ChaoAI state — caller is responsible.
function TrainingSystem:stopTraining()
  self.activeArea = nil
  self.tickTimer  = 0
end

function TrainingSystem:isTraining()
  return self.activeArea ~= nil
end

function TrainingSystem:activeStatName()
  return self.activeArea and self.activeArea.stat or nil
end

--- Drag-based training has no menu cooldowns; always returns 0.
--- TrainingMenu calls this for display — keeping it at 0 means "Ready".
function TrainingSystem:cooldownFor(statName)
  return 0
end

--- Returns true when the Chao is currently resting in the Nap Spot
function TrainingSystem:isSleeping()
  return self.activeArea ~= nil and self.activeArea.stat == "sleep"
end

function TrainingSystem:update(dt)
  if not self.activeArea then return end
  local stats = self.chao.stats

  -- ── Sleep / rest area ──────────────────────────────────────────────────────
  if self.activeArea.stat == "sleep" then
    -- Put Chao into sleeping state while in the Nap Spot
    if self.chao.ai.state ~= "sleeping" then
      self.chao.ai:forceState("sleeping", 9999)
    end
    -- Restore energy and a little happiness
    stats.energy    = helpers.clamp(stats.energy    + SLEEP_ENERGY_RATE * dt, 0, 100)
    stats.happiness = helpers.clamp(stats.happiness + SLEEP_HAPPY_RATE  * dt, 0, 100)
    -- Wake up once fully rested
    if stats.energy >= SLEEP_WAKE_ENERGY then
      self.activeArea = nil
      self.tickTimer  = 0
      self.chao.ai:releaseState()
    end
    -- Spawn gentle Zzz-style sparkle particles occasionally
    self.tickTimer = self.tickTimer + dt
    if self.tickTimer >= PARTICLE_INTERVAL * 1.5 then
      self.tickTimer = 0
      if self.particles then
        self.particles:spawnStars(
          self.chao.ai.x, self.chao.ai.y, 2,
          { 0.70, 0.78, 0.98 })
      end
    end
    return
  end

  -- ── Normal training areas ─────────────────────────────────────────────────
  -- Continuous stat gain
  stats[self.activeArea.stat] =
    helpers.clamp(stats[self.activeArea.stat] + STAT_GAIN_RATE * dt, 0, 100)

  -- Accelerated energy drain
  stats.energy = helpers.clamp(stats.energy - ENERGY_DRAIN_RATE * dt, 0, 100)

  -- Auto-stop on exhaustion: chao collapses
  if stats.energy <= MIN_ENERGY then
    self.activeArea = nil
    self.tickTimer  = 0
    self.chao.ai:releaseState()
    self.chao.ai:forceState("sleeping", 10)
    return
  end

  -- Periodic coloured particle burst
  self.tickTimer = self.tickTimer + dt
  if self.tickTimer >= PARTICLE_INTERVAL then
    self.tickTimer = 0
    if self.particles then
      self.particles:spawnStars(
        self.chao.ai.x, self.chao.ai.y, 4, self.activeArea.color)
    end
  end
end

return TrainingSystem
