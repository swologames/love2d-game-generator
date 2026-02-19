-- src/entities/chao/ChaoStats.lua
-- Owns all numeric stats for a Chao.
-- Provides feed(), train(), pet(), and tick() for passive decay.

local helpers = require("src/utils/helpers")

local ChaoStats = {}
ChaoStats.__index = ChaoStats

local STAT_MAX = 100
local STAT_MIN = 0

-- How much each stat decays per second passively
local DECAY_RATES = {
  hunger    = -2.0,   -- gets more hungry over time (hunger = fullness)
  happiness = -0.5,
  energy    = -0.8,
}

function ChaoStats:new()
  local s = setmetatable({}, self)
  s.swim      = 10
  s.run       = 10
  s.fly       = 10
  s.power     = 10
  s.luck      = 10
  s.happiness = 70
  s.hunger    = 80   -- 100 = full, 0 = starving
  s.energy    = 90
  return s
end

--- Apply fruit effects to stats
function ChaoStats:feed(fruit)
  if not fruit or not fruit.effects then return end
  for stat, delta in pairs(fruit.effects) do
    if self[stat] ~= nil then
      self[stat] = helpers.clamp(self[stat] + delta, STAT_MIN, STAT_MAX)
    end
  end
end

--- Apply training benefit to a single stat
function ChaoStats:train(statName, amount)
  amount = amount or 5
  if self[statName] ~= nil then
    self[statName] = helpers.clamp(self[statName] + amount, STAT_MIN, STAT_MAX)
  end
  -- Training costs energy
  self.energy = helpers.clamp(self.energy - 8, STAT_MIN, STAT_MAX)
end

--- Petting boosts happiness
function ChaoStats:pet()
  self.happiness = helpers.clamp(self.happiness + 3, STAT_MIN, STAT_MAX)
end

--- Passive decay — call every update frame
function ChaoStats:tick(dt)
  for stat, rate in pairs(DECAY_RATES) do
    self[stat] = helpers.clamp(self[stat] + rate * dt, STAT_MIN, STAT_MAX)
  end

  -- Extra happiness drain when the chao is very tired or very hungry.
  -- Being miserable in two ways at once makes things much worse.
  local extraDrain = 0
  if self.energy < 35 then
    -- Scales from 0 at energy=35 to -3/s at energy=0
    extraDrain = extraDrain + (1 - self.energy / 35) * 3.0
  end
  if self.hunger < 25 then
    -- Scales from 0 at hunger=25 to -2/s at hunger=0
    extraDrain = extraDrain + (1 - self.hunger / 25) * 2.0
  end
  if extraDrain > 0 then
    self.happiness = helpers.clamp(self.happiness - extraDrain * dt, STAT_MIN, STAT_MAX)
  end
  -- Sleepiness: ChaoAI reads energy to decide sleep/tired state
end

--- Returns a 0..1 normalised value for any stat
function ChaoStats:norm(statName)
  local v = self[statName]
  if v == nil then return 0 end
  return helpers.clamp(v / STAT_MAX, 0, 1)
end

--- Computed mood label
function ChaoStats:moodLabel()
  local h = self.happiness
  if h >= 80 then return "ecstatic"
  elseif h >= 60 then return "happy"
  elseif h >= 40 then return "content"
  elseif h >= 20 then return "sad"
  else return "miserable" end
end

return ChaoStats
