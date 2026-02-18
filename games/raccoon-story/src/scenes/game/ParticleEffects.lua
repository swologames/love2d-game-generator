-- ParticleEffects.lua
-- Triggers footstep puffs and dash dust during the update loop.
-- Must be called BEFORE scene.player:update(dt) so wasDashing is captured correctly.

local ParticleEffects = {}

function ParticleEffects.update(scene, dt)
  local player = scene.player

  -- Capture dash state BEFORE player:update so we can detect the rising edge
  local wasDashing = player.isDashing

  -- Dash dust: emit once when dash starts
  if player.isDashing and not wasDashing then
    local dirX, dirY = 0, 0
    if player.vx ~= 0 or player.vy ~= 0 then
      local mag = math.sqrt(player.vx * player.vx + player.vy * player.vy)
      dirX = player.vx / mag
      dirY = player.vy / mag
    else
      if string.find(player.direction, "right") then dirX =  1 end
      if string.find(player.direction, "left")  then dirX = -1 end
      if string.find(player.direction, "up")    then dirY = -1 end
      if string.find(player.direction, "down")  then dirY =  1 end
    end
    scene.particleSystem:emitDashDust(
      player.x + player.width  / 2,
      player.y + player.height / 2,
      {x = dirX, y = dirY}
    )
  end

  -- Footstep puffs: periodic while walking (not dashing or hiding)
  if player.isMoving and not player.isDashing and not player.isHiding then
    scene.footstepTimer = scene.footstepTimer + dt
    if scene.footstepTimer >= scene.footstepInterval then
      scene.footstepTimer = 0
      scene.particleSystem:emitFootstepPuff(
        player.x + player.width  / 2,
        player.y + player.height
      )
    end
  else
    scene.footstepTimer = 0
  end
end

return ParticleEffects
