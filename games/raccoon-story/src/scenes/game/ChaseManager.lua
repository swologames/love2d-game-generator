-- ChaseManager.lua
-- Manages chase state detection, detection alert particles, and danger-level vignette

local ChaseManager = {}

-- Returns a 0-1 danger level based on chasing enemies and proximity
function ChaseManager.calcDangerLevel(scene)
  if not scene.isPlayerBeingChased then return 0 end

  local dangerLevel  = 0.5
  local playerCX     = scene.player.x + scene.player.width  / 2
  local playerCY     = scene.player.y + scene.player.height / 2

  for _, human in ipairs(scene.aiSystem.humans or {}) do
    if human.state == "chase" then
      local dx   = human.x - playerCX
      local dy   = human.y - playerCY
      local dist = math.sqrt(dx*dx + dy*dy)
      if dist < 150 then
        dangerLevel = math.min(1, dangerLevel + (150 - dist) / 150 * 0.5)
      end
    end
  end

  for _, dog in ipairs(scene.aiSystem.dogs or {}) do
    if dog.state == "chase" then
      local dx   = dog.x - playerCX
      local dy   = dog.y - playerCY
      local dist = math.sqrt(dx*dx + dy*dy)
      if dist < 150 then
        dangerLevel = math.min(1, dangerLevel + (150 - dist) / 150 * 0.5)
      end
    end
  end

  return dangerLevel
end

-- Emits detection alert particles for enemies that just entered chase state
function ChaseManager.emitDetectionAlerts(scene)
  -- Humans: reset isPlayerBeingChased here so updateChaseState can re-evaluate cleanly
  for _, human in ipairs(scene.aiSystem.humans or {}) do
    if human.state == "chase" then
      scene.isPlayerBeingChased = true
      if not human.alertShown then
        scene.particleSystem:emitDetectionAlert(human.x + 16, human.y)
        human.alertShown = true
      end
    else
      human.alertShown = false
    end
  end

  -- Dogs (check even if already being chased by a human)
  for _, dog in ipairs(scene.aiSystem.dogs or {}) do
    if dog.state == "chase" then
      scene.isPlayerBeingChased = true
      if not dog.alertShown then
        scene.particleSystem:emitDetectionAlert(dog.x + 16, dog.y)
        dog.alertShown = true
      end
    else
      dog.alertShown = false
    end
  end
end

-- Handles chase state transitions, timer, screen shake, and stopChase calls
function ChaseManager.updateChaseState(scene, dt)
  local wasBeingChased      = scene.isPlayerBeingChased
  scene.isPlayerBeingChased = false

  -- Re-check from scratch
  for _, human in ipairs(scene.aiSystem.humans or {}) do
    if human.state == "chase" then
      scene.isPlayerBeingChased = true
      break
    end
  end

  if not scene.isPlayerBeingChased then
    for _, dog in ipairs(scene.aiSystem.dogs or {}) do
      if dog.state == "chase" then
        scene.isPlayerBeingChased = true
        break
      end
    end
  end

  -- Player just hid while being chased: start lose-sight timer
  if scene.player.isHiding and wasBeingChased and scene.chaseEndTimer == 0 then
    scene.chaseEndTimer = 1.0
    print("[ChaseManager] Player hiding while chased - starting lose sight timer")
  end

  -- Subtle screen shake while being chased
  if scene.isPlayerBeingChased then
    scene.screenEffects:shake(0.3, 5)
  end

  -- Tick lose-sight timer
  if scene.chaseEndTimer > 0 then
    scene.chaseEndTimer = scene.chaseEndTimer - dt

    if scene.chaseEndTimer <= 0 then
      scene.chaseEndTimer = 0

      -- Make all chasing enemies lose sight
      local returned = false
      for _, human in ipairs(scene.aiSystem.humans or {}) do
        if human.state == "chase" then
          human:stopChase()
          returned = true
        end
      end
      for _, dog in ipairs(scene.aiSystem.dogs or {}) do
        if dog.state == "chase" then
          dog:stopChase()
          returned = true
        end
      end

      if returned then
        scene.messageText  = "Enemies lost sight - safe for now"
        scene.messageTimer = 3
        print("[ChaseManager] Enemies lost sight - returning to patrol")
      end
    end
  end

  -- Reset timer if player left hiding or is no longer being chased
  if not scene.player.isHiding and scene.chaseEndTimer > 0 then
    scene.chaseEndTimer = 0
  end
end

return ChaseManager
