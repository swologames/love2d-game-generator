-- ParticleSystem orchestrator for Raccoon Story
-- Delegates all effect logic to sub-modules under src/systems/particles/

local Emitter         = require("src.systems.particles.Emitter")
local TrashSparkle    = require("src.systems.particles.TrashSparkle")
local DashDust        = require("src.systems.particles.DashDust")
local FootstepPuff    = require("src.systems.particles.FootstepPuff")
local DetectionAlert  = require("src.systems.particles.DetectionAlert")
local CollectionBurst = require("src.systems.particles.CollectionBurst")

local ParticleSystem = {}

function ParticleSystem:new()
  local instance = {
    activeParticles = {},
    particlePool    = {},
    emitters        = {},
    burstEffects    = {},
    maxParticles    = 200,
    particleCount   = 0,
    particleImage   = nil
  }
  setmetatable(instance, {__index = self})
  instance.particleImage = Emitter.createParticleTexture()
  print("[ParticleSystem] Initialized with max particles:", instance.maxParticles)
  return instance
end

-- Continuous emitter factories
function ParticleSystem:createTrashSparkle(x, y)
  local emitter = TrashSparkle.create(x, y)
  table.insert(self.emitters, emitter)
  return emitter
end

-- One-shot emitters
function ParticleSystem:emitDashDust(x, y, direction)
  self.particleCount = DashDust.emit(x, y, direction, self.particlePool, self.activeParticles, self.particleCount, self.maxParticles)
end

function ParticleSystem:emitFootstepPuff(x, y)
  self.particleCount = FootstepPuff.emit(x, y, self.particlePool, self.activeParticles, self.particleCount, self.maxParticles)
end

function ParticleSystem:emitDetectionAlert(x, y)
  DetectionAlert.emit(x, y, self.burstEffects)
end

function ParticleSystem:emitCollectionBurst(x, y)
  self.particleCount = CollectionBurst.emit(x, y, self.particlePool, self.activeParticles, self.particleCount, self.maxParticles)
end

function ParticleSystem:update(dt)
  -- Tick continuous emitters
  for i = #self.emitters, 1, -1 do
    local emitter = self.emitters[i]
    if emitter.active then
      emitter.timer = emitter.timer + dt
      if emitter.timer >= emitter.interval then
        emitter.timer = emitter.timer - emitter.interval
        if emitter.type == "trashSparkle" then
          self.particleCount = TrashSparkle.emit(emitter, self.particlePool, self.activeParticles, self.particleCount, self.maxParticles)
        end
      end
    else
      table.remove(self.emitters, i)
    end
  end

  -- Update active particles
  for i = #self.activeParticles, 1, -1 do
    local p = self.activeParticles[i]
    if not Emitter.updateParticle(p, dt) then
      table.remove(self.activeParticles, i)
      table.insert(self.particlePool, p)
      self.particleCount = self.particleCount - 1
    end
  end

  -- Update burst effects
  for i = #self.burstEffects, 1, -1 do
    local effect = self.burstEffects[i]
    if effect.type == "alert" then
      if not DetectionAlert.update(effect, dt) then
        table.remove(self.burstEffects, i)
      end
    end
  end
end

function ParticleSystem:draw()
  local lg = love.graphics
  lg.push()
  Emitter.drawParticles(self.activeParticles, self.particleImage)
  for _, effect in ipairs(self.burstEffects) do
    if effect.type == "alert" then DetectionAlert.draw(effect) end
  end
  lg.setColor(1, 1, 1, 1)
  lg.pop()
end

function ParticleSystem:updateEmitter(emitter, x, y)
  if emitter then emitter.x = x; emitter.y = y end
end

function ParticleSystem:removeEmitter(emitter)
  for _, e in ipairs(self.emitters) do
    if e == emitter then e.active = false; break end
  end
end

function ParticleSystem:clear()
  self.activeParticles = {}
  self.emitters        = {}
  self.burstEffects    = {}
  self.particleCount   = 0
  print("[ParticleSystem] Cleared all particles")
end

function ParticleSystem:getStats()
  return {
    activeParticles = #self.activeParticles,
    pooledParticles = #self.particlePool,
    emitters        = #self.emitters,
    burstEffects    = #self.burstEffects
  }
end

return ParticleSystem
