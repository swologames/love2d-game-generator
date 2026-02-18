-- 4-directional facing update for animals

local DirectionUtils = {}

function DirectionUtils.updateDirection(animal)
  if animal.vx == 0 and animal.vy == 0 then return end
  local angle = math.atan2(animal.vy, animal.vx)
  if angle >= -math.pi/4 and angle < math.pi/4 then
    animal.direction = "right"
  elseif angle >= math.pi/4 and angle < 3*math.pi/4 then
    animal.direction = "down"
  elseif angle >= 3*math.pi/4 or angle < -3*math.pi/4 then
    animal.direction = "left"
  else
    animal.direction = "up"
  end
end

return DirectionUtils
