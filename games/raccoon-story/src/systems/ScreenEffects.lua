-- ScreenEffects orchestrator for Raccoon Story
-- Delegates shake and vignette logic to sub-modules under src/systems/effects/

local ShakeEffect   = require("src.systems.effects.ShakeEffect")
local VignetteEffect= require("src.systems.effects.VignetteEffect")

local ScreenEffects = {}

function ScreenEffects:new()
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  local instance = {
    shake    = ShakeEffect.new(),
    vignette = VignetteEffect.new(sw, sh),

    -- Bush sway properties (when player is hiding)
    bushSwayOffset = 0,
    bushSwaySpeed  = 2,
    bushSwayAmount = 0.5,

    screenWidth  = sw,
    screenHeight = sh
  }
  setmetatable(instance, {__index = self})
  print("[ScreenEffects] Initialized")
  return instance
end

-- Screen shake
function ScreenEffects:shake(duration, intensity)
  ShakeEffect.shake(self.shake, duration, intensity)
end

function ScreenEffects:getShakeOffset()
  return ShakeEffect.getOffset(self.shake)
end

function ScreenEffects:applyToCamera()
  return ShakeEffect.getOffset(self.shake)
end

-- Vignette
function ScreenEffects:setVignetteIntensity(intensity, immediate)
  VignetteEffect.setIntensity(self.vignette, intensity, immediate)
end

function ScreenEffects:setVignetteDanger(dangerLevel)
  VignetteEffect.setDanger(self.vignette, dangerLevel)
end

-- Lighting helpers (delegated to VignetteEffect)
function ScreenEffects:drawStreetLampGlow(x, y, radius, intensity)
  VignetteEffect.drawStreetLampGlow(x, y, radius, intensity)
end

function ScreenEffects:drawWindowLight(x, y, width, height, intensity)
  VignetteEffect.drawWindowLight(x, y, width, height, intensity)
end

function ScreenEffects:drawAmbientMoonlight()
  VignetteEffect.drawAmbientMoonlight(self.screenWidth, self.screenHeight)
end

-- Bush sway
function ScreenEffects:updateBushSway(dt, isHiding)
  if isHiding then
    self.bushSwayOffset = self.bushSwayOffset + dt * self.bushSwaySpeed
    if self.bushSwayOffset > math.pi * 4 then
      self.bushSwayOffset = self.bushSwayOffset - math.pi * 4
    end
  else
    self.bushSwayOffset = self.bushSwayOffset * 0.9
  end
end

function ScreenEffects:getBushSwayOffset()
  if self.bushSwayOffset > 0.01 then
    local swayX = math.sin(self.bushSwayOffset) * self.bushSwayAmount
    local swayY = math.cos(self.bushSwayOffset * 0.7) * self.bushSwayAmount * 0.5
    return swayX, swayY
  end
  return 0, 0
end

-- Main update
function ScreenEffects:update(dt, gameState)
  ShakeEffect.update(self.shake, dt)
  VignetteEffect.update(self.vignette, dt)

  local isHiding = gameState and gameState.playerIsHiding or false
  self:updateBushSway(dt, isHiding)

  if gameState and gameState.dangerLevel ~= nil then
    self:setVignetteDanger(gameState.dangerLevel)
  end
end

-- Draw overlays
function ScreenEffects:drawOverlays()
  self:drawAmbientMoonlight()
  VignetteEffect.draw(self.vignette)
end

-- Utility
function ScreenEffects:clear()
  self.shake.shakeX        = 0
  self.shake.shakeY        = 0
  self.shake.shakeDuration = 0
  self.bushSwayOffset      = 0
  print("[ScreenEffects] Cleared all effects")
end

return ScreenEffects
