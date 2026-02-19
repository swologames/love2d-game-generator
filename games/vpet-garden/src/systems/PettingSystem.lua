-- src/systems/PettingSystem.lua
-- Detects mouse-over-chao, triggers pet animation and spawns heart particles.

local PettingSystem = {}
PettingSystem.__index = PettingSystem

function PettingSystem:new(chao, particles)
  local p = setmetatable({}, self)
  p.chao      = chao
  p.particles = particles
  p.mouseDown = false
  p.mx        = 0
  p.my        = 0

  -- Wire the chao petting callback to spawn particles
  chao.onPetted = function(cx, cy)
    particles:spawnHearts(cx, cy - 20, 4)
  end

  return p
end

function PettingSystem:update(dt)
  self.chao:update(dt, self.mx, self.my, self.mouseDown)
end

function PettingSystem:mousemoved(x, y)
  self.mx = x
  self.my = y
end

function PettingSystem:mousepressed(x, y, button)
  if button == 1 then
    self.mouseDown = true
    -- Note: click-to-pet is handled by DragSystem's onPetClick callback.
    -- PettingSystem only tracks mouseDown for the hover-hold mechanic.
  end
end

function PettingSystem:mousereleased(x, y, button)
  if button == 1 then
    self.mouseDown = false
  end
end

return PettingSystem
