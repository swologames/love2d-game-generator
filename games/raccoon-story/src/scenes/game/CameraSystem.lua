-- CameraSystem.lua
-- Smooth camera follow with world-boundary clamping

local CameraSystem = {}

function CameraSystem.update(scene, dt)
  local sw = love.graphics.getWidth()
  local sh = love.graphics.getHeight()

  local targetX = scene.player.x - sw / 2 + scene.player.width  / 2
  local targetY = scene.player.y - sh / 2 + scene.player.height / 2

  -- Clamp to world bounds
  targetX = math.max(0, math.min(targetX, scene.worldWidth  - sw))
  targetY = math.max(0, math.min(targetY, scene.worldHeight - sh))

  -- Smooth follow (lerp at 5x speed)
  scene.cameraX = scene.cameraX + (targetX - scene.cameraX) * 5 * dt
  scene.cameraY = scene.cameraY + (targetY - scene.cameraY) * 5 * dt
end

return CameraSystem
