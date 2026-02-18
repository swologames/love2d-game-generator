-- Animal wander, seek-trash, and grab-trash behaviour

local Wander = {}

function Wander.updateWander(animal, dt)
  local dx = animal.wanderTargetX - animal.x
  local dy = animal.wanderTargetY - animal.y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist < 20 then
    animal.vx = 0
    animal.vy = 0
    if animal.wanderWaitTimer <= 0 then
      local angle = math.random() * math.pi * 2
      local distance = math.random(50, 150)
      animal.wanderTargetX = animal.x + math.cos(angle) * distance
      animal.wanderTargetY = animal.y + math.sin(angle) * distance
      animal.wanderWaitTimer = animal.wanderWaitTime
    end
  else
    dx = dx / dist
    dy = dy / dist
    animal.vx = dx * animal.speed * 0.5
    animal.vy = dy * animal.speed * 0.5
  end
end

function Wander.checkForTrash(animal, trashItems)
  for _, trash in ipairs(trashItems) do
    if not trash.collected then
      local dx = trash.x - animal.x
      local dy = trash.y - animal.y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < animal.trashDetectionRange then
        animal.targetTrash = trash
        animal.state = "seek_trash"
        print("[" .. animal.animalType .. "] Found trash!")
        break
      end
    end
  end
end

function Wander.updateSeekTrash(animal, dt)
  if not animal.targetTrash or animal.targetTrash.collected then
    animal.state = "wander"
    animal.targetTrash = nil
    return
  end
  local dx = animal.targetTrash.x - animal.x
  local dy = animal.targetTrash.y - animal.y
  local dist = math.sqrt(dx * dx + dy * dy)
  if dist < 30 then
    animal.state = "grab_trash"
    animal.vx = 0
    animal.vy = 0
    animal.wanderWaitTimer = 1
  else
    dx = dx / dist
    dy = dy / dist
    animal.vx = dx * animal.speed
    animal.vy = dy * animal.speed
  end
end

function Wander.updateGrabTrash(animal, dt)
  if animal.wanderWaitTimer <= 0 then
    if animal.targetTrash and not animal.targetTrash.collected then
      animal.targetTrash:collect()
      animal.hasTrash = true
      print("[" .. animal.animalType .. "] Grabbed trash!")
    end
    animal.state = "wander"
    animal.targetTrash = nil
  end
end

return Wander
