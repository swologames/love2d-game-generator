-- Shared patrol behavior for enemy entities

local Patrol = {}

-- Moves entity toward current patrol point, handles wait timer.
-- Sets vx/vy on entity.
function Patrol.update(entity, dt)
  if not entity.patrolPoints or #entity.patrolPoints == 0 then
    entity.vx = 0
    entity.vy = 0
    return
  end

  local target = entity.patrolPoints[entity.currentPatrolIndex]
  local dx = target.x - entity.x
  local dy = target.y - entity.y
  local dist = math.sqrt(dx * dx + dy * dy)

  if dist < 8 then
    -- Arrived at patrol point, wait before advancing
    entity.vx = 0
    entity.vy = 0
    entity.patrolWaitTimer = entity.patrolWaitTimer + dt
    if entity.patrolWaitTimer >= entity.patrolWaitTime then
      entity.patrolWaitTimer = 0
      entity.currentPatrolIndex =
        (entity.currentPatrolIndex % #entity.patrolPoints) + 1
    end
  else
    -- Move toward patrol point
    entity.patrolWaitTimer = 0
    entity.vx = (dx / dist) * entity.speed
    entity.vy = (dy / dist) * entity.speed
  end
end

return Patrol
