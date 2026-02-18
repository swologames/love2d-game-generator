-- Shared direction and animation utilities for enemy entities

local DirectionUtils = {}

-- Returns the facing angle (radians) based on entity.direction string.
function DirectionUtils.getFacingAngle(entity)
  local dir = entity.direction
  if     dir == "right"      then return 0
  elseif dir == "up-right"   then return -math.pi / 4
  elseif dir == "up"         then return -math.pi / 2
  elseif dir == "up-left"    then return -3 * math.pi / 4
  elseif dir == "left"       then return math.pi
  elseif dir == "down-left"  then return 3 * math.pi / 4
  elseif dir == "down"       then return math.pi / 2
  elseif dir == "down-right" then return math.pi / 4
  else   return 0
  end
end

-- Sets entity.direction from vx/vy using atan2 (8-directional).
function DirectionUtils.updateDirection(entity)
  if entity.vx == 0 and entity.vy == 0 then return end
  local angle = math.atan2(entity.vy, entity.vx)
  local pi = math.pi
  if     angle >= -pi/8   and angle <  pi/8   then entity.direction = "right"
  elseif angle >=  pi/8   and angle <  3*pi/8 then entity.direction = "down-right"
  elseif angle >=  3*pi/8 and angle <  5*pi/8 then entity.direction = "down"
  elseif angle >=  5*pi/8 and angle <  7*pi/8 then entity.direction = "down-left"
  elseif angle >=  7*pi/8 or  angle < -7*pi/8 then entity.direction = "left"
  elseif angle >= -7*pi/8 and angle < -5*pi/8 then entity.direction = "up-left"
  elseif angle >= -5*pi/8 and angle < -3*pi/8 then entity.direction = "up"
  elseif angle >= -3*pi/8 and angle < -pi/8   then entity.direction = "up-right"
  end
end

-- Advances animation using entity.walkSprite array.
function DirectionUtils.updateAnimation(entity, dt)
  if not entity.walkSprite then return end
  entity.animTimer = entity.animTimer + dt
  if entity.animTimer >= 1 / entity.animFPS then
    entity.animTimer = entity.animTimer - 1 / entity.animFPS
    entity.currentFrame = (entity.currentFrame % #entity.walkSprite) + 1
  end
end

-- Advances animation using a passed frames array.
function DirectionUtils.updateAnimationFrames(entity, dt, frames)
  if not frames then return end
  entity.animTimer = entity.animTimer + dt
  if entity.animTimer >= 1 / entity.animFPS then
    entity.animTimer = entity.animTimer - 1 / entity.animFPS
    entity.currentFrame = (entity.currentFrame % #frames) + 1
  end
end

return DirectionUtils
