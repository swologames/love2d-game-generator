-- CollisionSystem.lua
-- Collision detection and resolution for Mecha Shmup

local CollisionSystem = {}

-- Check if two circles overlap
function CollisionSystem.circleCollision(x1, y1, r1, x2, y2, r2)
  local dx = x2 - x1
  local dy = y2 - y1
  local dist = math.sqrt(dx * dx + dy * dy)
  return dist < (r1 + r2)
end

-- Check if point is in circle
function CollisionSystem.pointInCircle(px, py, cx, cy, r)
  local dx = px - cx
  local dy = py - cy
  return (dx * dx + dy * dy) < (r * r)
end

-- Check AABB collision
function CollisionSystem.aabbCollision(box1, box2)
  return box1.x < box2.x + box2.width and
         box1.x + box1.width > box2.x and
         box1.y < box2.y + box2.height and
         box1.y + box1.height > box2.y
end

-- Check player bullets vs enemies
function CollisionSystem.checkPlayerBulletsVsEnemies(player, enemies)
  local hits = {}
  
  for i = #player.bullets, 1, -1 do
    local bullet = player.bullets[i]
    local bulletHit = false
    
    for j, enemy in ipairs(enemies) do
      if enemy.alive then
        -- Check collision
        if CollisionSystem.circleCollision(
          bullet.x, bullet.y, 3,
          enemy.x, enemy.y, enemy.size
        ) then
          -- Damage enemy
          local enemyDied = enemy:takeDamage(bullet.damage or player:getEffectiveDamage())
          
          if enemyDied then
            table.insert(hits, {
              type = "enemyKilled",
              enemy = enemy,
              x = enemy.x,
              y = enemy.y,
              score = enemy.score
            })
            
            -- Add score
            player.score = player.score + enemy.score
          else
            table.insert(hits, {
              type = "enemyHit",
              x = enemy.x,
              y = enemy.y
            })
          end
          
          -- Remove bullet unless piercing
          if not bullet.piercing then
            table.remove(player.bullets, i)
            bulletHit = true
            break
          end
        end
      end
    end
  end
  
  return hits
end

-- Check enemy bullets vs player
function CollisionSystem.checkEnemyBulletsVsPlayer(player, bulletManager)
  if not player.alive or player.invulnerable then return {} end
  
  local hits = {}
  local bullets = bulletManager:getBullets()
  
  for i = #bullets, 1, -1 do
    local bullet = bullets[i]
    
    -- Check collision with player hitbox
    if CollisionSystem.circleCollision(
      bullet.x, bullet.y, bullet.size,
      player.x, player.y, player.hitboxSize
    ) then
      -- Player takes damage
      player:takeDamage(bullet.damage or 1)
      
      -- Create disintegration effect for bullet
      if bulletManager.particles then
        bulletManager.particles:bulletDisintegrate(bullet.x, bullet.y, bullet.size, bullet.color)
      end
      
      table.remove(bullets, i)
      
      table.insert(hits, {
        type = "playerHit",
        x = player.x,
        y = player.y
      })
    end
  end
  
  return hits
end

-- Check enemies vs player (collision damage)
function CollisionSystem.checkEnemiesVsPlayer(player, enemies)
  if not player.alive or player.invulnerable then return {} end
  
  local hits = {}
  
  for i = #enemies, 1, -1 do
    local enemy = enemies[i]
    if enemy.alive then
      -- Check collision
      if CollisionSystem.circleCollision(
        player.x, player.y, player.hitboxSize,
        enemy.x, enemy.y, enemy.size
      ) then
        -- Player takes damage
        player:takeDamage(1)
        
        -- Enemy dies from collision
        enemy.alive = false
        
        table.insert(hits, {
          type = "collision",
          x = enemy.x,
          y = enemy.y
        })
        
        table.remove(enemies, i)
      end
    end
  end
  
  return hits
end

-- Check power-ups vs player
function CollisionSystem.checkPowerUpsVsPlayer(player, powerups)
  local collected = {}
  
  for i = #powerups, 1, -1 do
    local powerup = powerups[i]
    if powerup.alive then
      -- Check collision with larger radius for easier collection
      if CollisionSystem.circleCollision(
        player.x, player.y, player.hitboxSize + 10,
        powerup.x, powerup.y, powerup.size
      ) then
        if powerup:collect(player) then
          table.insert(collected, {
            type = powerup.type,
            x = powerup.x,
            y = powerup.y
          })
          table.remove(powerups, i)
        end
      end
    end
  end
  
  return collected
end

-- Check boss bullets vs player
function CollisionSystem.checkBossBulletsVsPlayer(player, boss)
  if not player.alive or player.invulnerable or not boss or not boss.alive then 
    return {} 
  end
  
  local hits = {}
  
  for i = #boss.bullets, 1, -1 do
    local bullet = boss.bullets[i]
    
    if CollisionSystem.circleCollision(
      bullet.x, bullet.y, bullet.size,
      player.x, player.y, player.hitboxSize
    ) then
      player:takeDamage(bullet.damage or 1)
      table.remove(boss.bullets, i)
      
      table.insert(hits, {
        type = "playerHit",
        x = player.x,
        y = player.y
      })
    end
  end
  
  return hits
end

-- Check player bullets vs boss
function CollisionSystem.checkPlayerBulletsVsBoss(player, boss)
  if not boss or not boss.alive then return {} end
  
  local hits = {}
  
  for i = #player.bullets, 1, -1 do
    local bullet = player.bullets[i]
    
    -- Check collision with boss hitbox
    if CollisionSystem.circleCollision(
      bullet.x, bullet.y, 3,
      boss.x, boss.y, boss.hitboxSize
    ) then
      local bossDied = boss:takeDamage(bullet.damage or player:getEffectiveDamage())
      
      if bossDied then
        table.insert(hits, {
          type = "bossDefeated",
          x = boss.x,
          y = boss.y,
          score = boss.score
        })
        player.score = player.score + boss.score
      else
        table.insert(hits, {
          type = "bossHit",
          x = bullet.x,
          y = bullet.y
        })
      end
      
      if not bullet.piercing then
        table.remove(player.bullets, i)
        break
      end
    end
  end
  
  return hits
end

return CollisionSystem
