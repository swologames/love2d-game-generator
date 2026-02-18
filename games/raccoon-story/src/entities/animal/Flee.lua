-- Animal flee behaviour and player proximity detection

local Flee = {}

function Flee.checkPlayerProximity(animal, player)
  local dx = player.x - animal.x
  local dy = player.y - animal.y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist < animal.playerDetectionRange then
    Flee.startFlee(animal, player)
  end
end

function Flee.startFlee(animal, player)
  animal.state = "flee"
  animal.fleeTimer = animal.fleeDuration
  if animal.hasTrash then
    print("[" .. animal.animalType .. "] Dropped trash while fleeing!")
    animal.hasTrash = false
  end
  animal.targetTrash = nil
end

function Flee.updateFlee(animal, dt, player)
  local dx = animal.x - player.x
  local dy = animal.y - player.y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist > 0 then
    dx = dx / dist
    dy = dy / dist
    animal.vx = dx * animal.speed * 1.2
    animal.vy = dy * animal.speed * 1.2
  end
  if animal.fleeTimer <= 0 then
    animal.state = "wander"
    animal.vx = 0
    animal.vy = 0
  end
end

return Flee
