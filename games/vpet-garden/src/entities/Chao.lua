-- src/entities/Chao.lua
-- Thin orchestrator that wires together sub-modules.

local ChaoStats      = require("src/entities/chao/ChaoStats")
local ChaoAI         = require("src/entities/chao/ChaoAI")
local ChaoAnimator   = require("src/entities/chao/ChaoAnimator")
local ChaoInteraction = require("src/entities/chao/ChaoInteraction")

local Chao = {}
Chao.__index = Chao

function Chao:new(x, y, name)
  local c = setmetatable({}, self)
  c.name        = name or "Chao"
  c.stats       = ChaoStats:new()
  c.ai          = ChaoAI:new(x, y)
  c.animator    = ChaoAnimator:new()
  c.interaction = ChaoInteraction:new()

  -- When petted: update stats and force happy state
  c.interaction:onPetCallback(function(cx, cy)
    c.stats:pet()
    c.ai:forceState("petted", 1.5)
    if c.onPetted then c.onPetted(cx, cy) end
  end)

  return c
end

--- x/y access delegates to the AI position
function Chao:getPos()
  return self.ai.x, self.ai.y
end

--- Feed the chao a fruit definition table
function Chao:feed(fruit)
  self.stats:feed(fruit)
  self.ai:forceState("eating", 3.0)
end

--- Update all sub-modules
function Chao:update(dt, mx, my, mouseDown)
  self.stats:tick(dt)
  self.ai:update(dt, self.stats)
  self.animator:update(dt, self.ai.state)
  self.interaction:update(dt, self.ai.x, self.ai.y, mx, my, mouseDown)
end

--- Draw: delegates to animator
function Chao:draw()
  self.animator:draw(self.ai.x, self.ai.y, self.ai.facingRight)

  -- Name label on hover
  if self.interaction.isHovered then
    love.graphics.setColor(0.2, 0.15, 0.30, 0.85)
    love.graphics.setFont(love.graphics.newFont(11))
    local tw = love.graphics.getFont():getWidth(self.name)
    love.graphics.print(self.name, self.ai.x - tw / 2, self.ai.y - 48)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

--- Forward mouse-press to interaction module
function Chao:mousepressed(x, y)
  return self.interaction:handlePress(x, y, self.ai.x, self.ai.y)
end

return Chao
