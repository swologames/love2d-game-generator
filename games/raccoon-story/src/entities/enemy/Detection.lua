-- Shared vision cone detection for enemy entities

local Detection = {}

-- Checks if player is within entity's vision cone.
-- Skips check if player.isHiding or player.hidingGracePeriod > 0.
-- Accumulates entity.detectionTimer; calls onDetect(player) when threshold reached.
function Detection.check(entity, player, dt, onDetect)
  -- Skip if player is hidden
  if player.isHiding or
     (player.hidingGracePeriod and player.hidingGracePeriod > 0) then
    entity.detectionTimer = 0
    return
  end

  -- Check range
  local dx = player.x - entity.x
  local dy = player.y - entity.y
  local dist = math.sqrt(dx * dx + dy * dy)

  if dist > entity.visionRange then
    entity.detectionTimer = 0
    return
  end

  -- Check vision cone angle
  local DirUtils = require("src.entities.enemy.DirectionUtils")
  local facingAngle = DirUtils.getFacingAngle(entity)
  local toPlayerAngle = math.atan2(dy, dx)
  local angleDiff = math.abs(toPlayerAngle - facingAngle)
  if angleDiff > math.pi then
    angleDiff = 2 * math.pi - angleDiff
  end

  if angleDiff > entity.visionAngle / 2 then
    entity.detectionTimer = 0
    return
  end

  -- Accumulate detection timer
  entity.detectionTimer = entity.detectionTimer + dt
  if entity.detectionTimer >= entity.detectionDelay then
    entity.detectionTimer = 0
    onDetect(player)
  end
end

return Detection
