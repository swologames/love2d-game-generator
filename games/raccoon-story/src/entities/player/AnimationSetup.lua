-- Player Animation Setup Sub-module
-- Builds AnimationSystem + AnimationStateMachine and attaches them to the player

local AnimationSystem    = require("src.systems.AnimationSystem")
local AnimationStateMachine = require("src.systems.AnimationStateMachine")

local AnimationSetup = {}

function AnimationSetup.setup(self, idleFrames, walkFrames, dashFrames)
  -- Create animation system
  local animSystem = AnimationSystem:new()

  if idleFrames and #idleFrames > 0 then
    animSystem:addAnimation("idle", idleFrames, 8, true)
  end

  if walkFrames and #walkFrames > 0 then
    animSystem:addAnimation("walk", walkFrames, 12, true)
  end

  if dashFrames and #dashFrames > 0 then
    animSystem:addAnimation("dash", dashFrames, 16, false)
  end

  -- Create state machine
  local sm = AnimationStateMachine:new(animSystem)

  sm:addState("idle", "idle")
  sm:addState("walk", "walk")
  sm:addState("dash", "dash")

  -- Transitions
  sm:addTransition("idle", "walk", function(p) return p.isMoving and not p.isDashing end)
  sm:addTransition("idle", "dash", function(p) return p.isDashing end)

  sm:addTransition("walk", "idle", function(p) return not p.isMoving and not p.isDashing end)
  sm:addTransition("walk", "dash", function(p) return p.isDashing end)

  sm:addTransition("dash", "walk", function(p) return not p.isDashing and p.isMoving end)
  sm:addTransition("dash", "idle", function(p) return not p.isDashing and not p.isMoving end)

  -- Attach to player
  self.animSystem  = animSystem
  self.stateMachine = sm

  -- Start in idle state
  sm:setState("idle")
end

return AnimationSetup
