-- Shared chase, stopChase, and return behaviors for enemy entities

local Chase = {}

-- Moves entity toward player each frame.
-- Checks chaseTimer >= chaseDuration → stopChase then onStop.
-- Checks catch collision → onCatch.
function Chase.update(entity, dt, player, onCatch, onStop)
  entity.chaseTimer = entity.chaseTimer + dt

  -- Track last seen position
  entity.lastSeenX = player.x
  entity.lastSeenY = player.y

  -- Move toward player
  local dx = player.x - entity.x
  local dy = player.y - entity.y
  local dist = math.sqrt(dx * dx + dy * dy)

  if dist > 0 then
    entity.vx = (dx / dist) * entity.speed
    entity.vy = (dy / dist) * entity.speed
  end

  -- Check catch collision
  local catchDist = (entity.radius or 20) + (player.radius or 16)
  if dist < catchDist then
    onCatch()
    Chase.stopChase(entity)
    onStop(entity)
    return
  end

  -- Check if chase duration expired
  if entity.chaseTimer >= entity.chaseDuration then
    Chase.stopChase(entity)
    onStop(entity)
  end
end

-- Transitions entity to "return" state, finds nearest patrol point.
function Chase.stopChase(entity)
  entity.state = "return"
  entity.target = nil
  entity.detectionTimer = 0
  entity.vx = 0
  entity.vy = 0

  -- Find nearest patrol point to return to
  if entity.patrolPoints and #entity.patrolPoints > 0 then
    local nearestDist = math.huge
    local nearestIndex = 1
    for i, pt in ipairs(entity.patrolPoints) do
      local dx = pt.x - entity.x
      local dy = pt.y - entity.y
      local d = math.sqrt(dx * dx + dy * dy)
      if d < nearestDist then
        nearestDist = d
        nearestIndex = i
      end
    end
    entity.currentPatrolIndex = nearestIndex
    entity.returnToX = entity.patrolPoints[nearestIndex].x
    entity.returnToY = entity.patrolPoints[nearestIndex].y
  end
end

-- Moves entity back to returnToX/Y, switches to "patrol" when close.
function Chase.updateReturn(entity, dt)
  local dx = entity.returnToX - entity.x
  local dy = entity.returnToY - entity.y
  local dist = math.sqrt(dx * dx + dy * dy)

  if dist < 8 then
    entity.vx = 0
    entity.vy = 0
    entity.state = "patrol"
  else
    entity.vx = (dx / dist) * entity.speed
    entity.vy = (dy / dist) * entity.speed
  end
end

return Chase
