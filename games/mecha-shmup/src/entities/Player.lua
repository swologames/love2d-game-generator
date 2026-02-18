-- Player.lua
-- Player entity for Mecha Shmup

local Player = {}
Player.__index = Player

function Player:new(characterId)
  local instance = setmetatable({}, self)
  
  -- Character data from GDD
  local characters = {
    { -- Kai Rexford - Valkyrie
      name = "Kai Rexford",
      mecha = "VK-01 Valkyrie",
      speed = 400,
      health = 3,
      shotDamage = 10,
      fireRate = 0.15,
      specialCharges = 5,
      hitboxSize = 6,
      color = {0.3, 0.7, 1}
    },
    { -- Zara Nakamura - Phantom
      name = "Zara Nakamura",
      mecha = "PH-03 Phantom",
      speed = 480,
      health = 2,
      shotDamage = 6,
      fireRate = 0.08,
      specialCharges = 5,
      hitboxSize = 8,
      color = {1, 0.3, 0.7}
    },
    { -- Viktor Kozlov - Bastion
      name = "Viktor Kozlov",
      mecha = "BN-05 Bastion",
      speed = 350,
      health = 4,
      shotDamage = 20,
      fireRate = 0.35,
      specialCharges = 3,
      hitboxSize = 6,
      color = {1, 0.7, 0.2}
    }
  }
  
  local charData = characters[characterId]
  
  -- Position
  instance.x = 320  -- Center of 640px wide screen
  instance.y = 600
  
  -- Character properties
  instance.characterId = characterId
  instance.name = charData.name
  instance.mecha = charData.mecha
  instance.color = charData.color
  
  -- Stats from GDD
  instance.speed = charData.speed
  instance.focusSpeed = charData.speed * 0.5
  instance.maxHealth = charData.health
  instance.health = charData.health
  instance.shotDamage = charData.shotDamage
  instance.fireRate = charData.fireRate
  instance.specialCharges = charData.specialCharges
  instance.maxSpecialCharges = charData.specialCharges
  instance.hitboxSize = charData.hitboxSize
  
  -- State
  instance.focusMode = false
  instance.invulnerable = false
  instance.invulnerableTime = 0
  instance.alive = true
  instance.controllable = true  -- Can be disabled during cutscenes/intro
  instance.debugInvincible = false  -- Debug mode: toggle with 'i' key
  instance.debug10xDamage = false  -- Debug mode: toggle with 'x' key
  
  -- Shooting
  instance.bullets = {}
  instance.shootTimer = 0
  instance.canShoot = true
  
  -- Get effective shot damage (with debug multiplier)
  instance.getEffectiveDamage = function(self)
    return self.shotDamage * (self.debug10xDamage and 10 or 1)
  end
  instance.weaponLevel = 1  -- Power-ups increase this
  
  -- Animation
  instance.thrustAnim = 0
  
  -- Score
  instance.score = 0
  instance.lives = 3
  
  return instance
end

function Player:update(dt)
  if not self.alive then return end
  
  -- Only accept input if controllable
  if self.controllable then
    -- Movement
    local currentSpeed = self.focusMode and self.focusSpeed or self.speed
    
    if love.keyboard.isDown("left", "a") then
      self.x = self.x - currentSpeed * dt
    end
    if love.keyboard.isDown("right", "d") then
      self.x = self.x + currentSpeed * dt
    end
    if love.keyboard.isDown("up", "w") then
      self.y = self.y - currentSpeed * dt
    end
    if love.keyboard.isDown("down", "s") then
      self.y = self.y + currentSpeed * dt
    end
    
    -- Keep in bounds (with margin)
    local margin = 20
    self.x = math.max(margin, math.min(self.x, 640 - margin))
    self.y = math.max(margin, math.min(self.y, 720 - margin))
    
    -- Focus mode
    self.focusMode = love.keyboard.isDown("lshift", "rshift")
    
    -- Shooting
    self.shootTimer = self.shootTimer + dt
    
    if love.keyboard.isDown("space", "z") and self.shootTimer >= self.fireRate then
      self:shoot()
      self.shootTimer = 0
    end
  end
  
  -- Update bullets
  for i = #self.bullets, 1, -1 do
    local bullet = self.bullets[i]
    
    -- Use velocity vectors if present, otherwise straight up
    if bullet.vx and bullet.vy then
      bullet.x = bullet.x + bullet.vx * dt
      bullet.y = bullet.y + bullet.vy * dt
    else
      bullet.y = bullet.y - bullet.speed * dt
    end
    
    -- Remove off-screen bullets
    if bullet.y < -10 or bullet.x < -10 or bullet.x > 650 then
      table.remove(self.bullets, i)
    end
  end
  
  -- Invulnerability
  if self.invulnerable then
    self.invulnerableTime = self.invulnerableTime - dt
    if self.invulnerableTime <= 0 then
      self.invulnerable = false
    end
  end
  
  -- Animation
  self.thrustAnim = self.thrustAnim + dt * 10
end

function Player:shoot()
  local level = math.min(self.weaponLevel or 1, 5)
  local baseSpeed = 500
  
  -- Character-specific bullet patterns - Narrower DoDonPachi style cones
  if self.characterId == 1 then
    -- Kai: Focused forward cone
    local angleSpread = 0.12 + level * 0.03  -- Much narrower cone
    local bulletCount = 3 + level  -- Fewer bullets
    
    for i = 0, bulletCount - 1 do
      local ratio = (i / (bulletCount - 1)) - 0.5  -- -0.5 to 0.5
      local angle = ratio * angleSpread * 2
      local speed = baseSpeed
      
      table.insert(self.bullets, {
        x = self.x,
        y = self.y - 20,
        vx = math.sin(angle) * speed,
        vy = -math.cos(angle) * speed,
        damage = self:getEffectiveDamage(),
        size = 4
      })
    end
    
  elseif self.characterId == 2 then
    -- Zara: Moderate spread for coverage
    local bulletCount = 3 + level
    local angleSpread = 0.18 + level * 0.04  -- Moderate spread
    
    for i = 0, bulletCount - 1 do
      local ratio = (i / (bulletCount - 1)) - 0.5
      local angle = ratio * angleSpread * 2
      local speed = 580
      
      table.insert(self.bullets, {
        x = self.x,
        y = self.y - 20,
        vx = math.sin(angle) * speed,
        vy = -math.cos(angle) * speed,
        damage = self:getEffectiveDamage() * 0.9,
        size = 3
      })
    end
    
  elseif self.characterId == 3 then
    -- Viktor: Concentrated piercing cone
    -- Center piercing shot
    table.insert(self.bullets, {
      x = self.x,
      y = self.y - 25,
      vx = 0,
      vy = -650,
      damage = self:getEffectiveDamage() * 1.5,
      size = 6,
      piercing = true
    })
    
    -- Tight cone pattern
    if level >= 2 then
      local bulletCount = 2 + math.floor(level / 2)
      local angleSpread = 0.1 + level * 0.02
      
      for i = 1, bulletCount * 2 do
        local side = (i % 2 == 0) and 1 or -1
        local distance = math.ceil(i / 2)
        local angle = (distance / (bulletCount + 1)) * angleSpread * side
        local speed = 600
        
        table.insert(self.bullets, {
          x = self.x,
          y = self.y - 20,
          vx = math.sin(angle) * speed,
          vy = -math.cos(angle) * speed,
          damage = self:getEffectiveDamage(),
          size = 4
        })
      end
    end
  end
end

function Player:takeDamage(amount)
  if self.invulnerable or not self.alive or self.debugInvincible then return end
  
  self.health = self.health - amount
  
  if self.health <= 0 then
    self:die()
  else
    -- Temporary invulnerability
    self.invulnerable = true
    self.invulnerableTime = 2.0
  end
end

function Player:die()
  self.alive = false
  self.lives = self.lives - 1
  -- Game over or respawn logic here
end

function Player:draw()
  self:drawShip()
  self:drawHitbox()
end

function Player:drawShip()
  if not self.alive then return end
  
  -- Debug invincibility glow
  if self.debugInvincible then
    local glowPulse = math.sin(love.timer.getTime() * 8) * 0.3 + 0.7
    love.graphics.setColor(1, 1, 0, 0.3 * glowPulse)
    love.graphics.circle("fill", self.x, self.y, 35)
    love.graphics.setColor(1, 1, 0, 0.5 * glowPulse)
    love.graphics.circle("fill", self.x, self.y, 25)
  end
  
  -- Flash when invulnerable
  local alpha = 1
  if self.invulnerable and math.floor(self.invulnerableTime * 10) % 2 == 0 then
    alpha = 0.5
  end
  
  -- Engine thrust animation
  local thrustIntensity = (math.sin(self.thrustAnim) + 1) / 2
  
  -- Draw character-specific ships
  if self.characterId == 1 then
    -- Kai: VK-01 Valkyrie - Sleek, aerodynamic, forward-swept wings
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    
    -- Main fuselage (elongated)
    love.graphics.ellipse("fill", self.x, self.y, 10, 22)
    
    -- Forward-swept wings
    love.graphics.polygon("fill",
      self.x - 25, self.y + 8,
      self.x - 10, self.y - 8,
      self.x - 8, self.y + 12
    )
    love.graphics.polygon("fill",
      self.x + 25, self.y + 8,
      self.x + 10, self.y - 8,
      self.x + 8, self.y + 12
    )
    
    -- Wing tips (accent)
    love.graphics.setColor(self.color[1] * 1.3, self.color[2] * 1.3, self.color[3] * 1.3, alpha)
    love.graphics.polygon("fill",
      self.x - 25, self.y + 8,
      self.x - 22, self.y + 5,
      self.x - 20, self.y + 10
    )
    love.graphics.polygon("fill",
      self.x + 25, self.y + 8,
      self.x + 22, self.y + 5,
      self.x + 20, self.y + 10
    )
    
    -- Nose cone
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    love.graphics.polygon("fill",
      self.x - 6, self.y - 18,
      self.x, self.y - 25,
      self.x + 6, self.y - 18
    )
    
    -- Cockpit
    love.graphics.setColor(0.2, 0.3, 0.4, alpha)
    love.graphics.ellipse("fill", self.x, self.y - 5, 6, 8)
    
    -- Engine pods
    love.graphics.setColor(self.color[1] * 0.7, self.color[2] * 0.7, self.color[3] * 0.7, alpha)
    love.graphics.rectangle("fill", self.x - 12, self.y + 15, 5, 10)
    love.graphics.rectangle("fill", self.x + 7, self.y + 15, 5, 10)
    
    -- Engine thrust
    love.graphics.setColor(0.3, 0.6, 1, 0.7 * thrustIntensity * alpha)
    love.graphics.circle("fill", self.x - 9, self.y + 28, 4 + thrustIntensity * 2)
    love.graphics.circle("fill", self.x + 9, self.y + 28, 4 + thrustIntensity * 2)
    
  elseif self.characterId == 2 then
    -- Zara: PH-03 Phantom - Angular, sharp, wide stance
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    
    -- Main body (diamond-shaped)
    love.graphics.polygon("fill",
      self.x, self.y - 20,
      self.x - 8, self.y,
      self.x, self.y + 20,
      self.x + 8, self.y
    )
    
    -- Wide angular wings
    love.graphics.polygon("fill",
      self.x - 28, self.y + 5,
      self.x - 8, self.y - 5,
      self.x - 8, self.y + 8
    )
    love.graphics.polygon("fill",
      self.x + 28, self.y + 5,
      self.x + 8, self.y - 5,
      self.x + 8, self.y + 8
    )
    
    -- Wing edges (sharp accent)
    love.graphics.setColor(self.color[1] * 1.4, self.color[2] * 1.4, self.color[3] * 1.4, alpha)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.x - 28, self.y + 5, self.x - 8, self.y - 5)
    love.graphics.line(self.x + 28, self.y + 5, self.x + 8, self.y - 5)
    
    -- Nose blade
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    love.graphics.polygon("fill",
      self.x - 3, self.y - 20,
      self.x, self.y - 28,
      self.x + 3, self.y - 20
    )
    
    -- Cockpit (small, stealthy)
    love.graphics.setColor(0.15, 0.15, 0.25, alpha)
    love.graphics.circle("fill", self.x, self.y - 2, 5)
    
    -- Twin tail fins
    love.graphics.setColor(self.color[1] * 0.8, self.color[2] * 0.8, self.color[3] * 0.8, alpha)
    love.graphics.polygon("fill",
      self.x - 6, self.y + 18,
      self.x - 6, self.y + 25,
      self.x - 3, self.y + 22
    )
    love.graphics.polygon("fill",
      self.x + 6, self.y + 18,
      self.x + 6, self.y + 25,
      self.x + 3, self.y + 22
    )
    
    -- Engine thrust (twin streams)
    love.graphics.setColor(1, 0.3, 0.8, 0.8 * thrustIntensity * alpha)
    love.graphics.ellipse("fill", self.x - 6, self.y + 28, 3 + thrustIntensity * 2, 5 + thrustIntensity * 3)
    love.graphics.ellipse("fill", self.x + 6, self.y + 28, 3 + thrustIntensity * 2, 5 + thrustIntensity * 3)
    
  elseif self.characterId == 3 then
    -- Viktor: BN-05 Bastion - Bulky, armored, rectangular
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    
    -- Main armored body
    love.graphics.rectangle("fill", self.x - 12, self.y - 20, 24, 35)
    
    -- Armor plating (layered rectangles)
    love.graphics.setColor(self.color[1] * 1.2, self.color[2] * 1.2, self.color[3] * 1.2, alpha)
    love.graphics.rectangle("fill", self.x - 10, self.y - 18, 20, 8)
    love.graphics.rectangle("fill", self.x - 10, self.y - 5, 20, 8)
    
    -- Heavy wings (thick, sturdy)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], alpha)
    love.graphics.polygon("fill",
      self.x - 26, self.y + 10,
      self.x - 12, self.y - 5,
      self.x - 12, self.y + 15
    )
    love.graphics.polygon("fill",
      self.x + 26, self.y + 10,
      self.x + 12, self.y - 5,
      self.x + 12, self.y + 15
    )
    
    -- Wing armor plates
    love.graphics.setColor(self.color[1] * 0.7, self.color[2] * 0.7, self.color[3] * 0.7, alpha)
    love.graphics.rectangle("fill", self.x - 24, self.y + 8, 10, 6)
    love.graphics.rectangle("fill", self.x + 14, self.y + 8, 10, 6)
    
    -- Reinforced nose
    love.graphics.setColor(self.color[1] * 0.8, self.color[2] * 0.8, self.color[3] * 0.8, alpha)
    love.graphics.polygon("fill",
      self.x - 10, self.y - 20,
      self.x, self.y - 26,
      self.x + 10, self.y - 20
    )
    
    -- Cockpit (armored canopy)
    love.graphics.setColor(0.25, 0.2, 0.15, alpha)
    love.graphics.rectangle("fill", self.x - 7, self.y - 12, 14, 10)
    
    -- Heavy engine blocks
    love.graphics.setColor(self.color[1] * 0.6, self.color[2] * 0.6, self.color[3] * 0.6, alpha)
    love.graphics.rectangle("fill", self.x - 10, self.y + 15, 8, 12)
    love.graphics.rectangle("fill", self.x + 2, self.y + 15, 8, 12)
    
    -- Engine thrust (wide, powerful)
    love.graphics.setColor(1, 0.6, 0.2, 0.8 * thrustIntensity * alpha)
    love.graphics.rectangle("fill", self.x - 10, self.y + 27, 8, 6 + thrustIntensity * 4)
    love.graphics.rectangle("fill", self.x + 2, self.y + 27, 8, 6 + thrustIntensity * 4)
    love.graphics.setColor(1, 0.9, 0.5, 0.6 * thrustIntensity * alpha)
    love.graphics.rectangle("fill", self.x - 9, self.y + 28, 6, 4 + thrustIntensity * 3)
    love.graphics.rectangle("fill", self.x + 3, self.y + 28, 6, 4 + thrustIntensity * 3)
  end
  
  -- Draw bullets
  love.graphics.setColor(self.color[1], self.color[2], self.color[3], 1)
  for _, bullet in ipairs(self.bullets) do
    if bullet.piercing then
      love.graphics.setLineWidth(bullet.size)
      love.graphics.line(bullet.x, bullet.y, bullet.x, bullet.y + 15)
    else
      love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
    end
  end
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setLineWidth(1)
end

function Player:drawHitbox()
  if not self.alive then return end
  
  -- Draw hitbox indicator (always visible, renders on top of everything)
  love.graphics.setColor(0.2, 0.5, 1, 0.6)
  love.graphics.circle("fill", self.x, self.y, self.hitboxSize)
  love.graphics.setColor(0.3, 0.7, 1, 0.9)
  love.graphics.circle("line", self.x, self.y, self.hitboxSize)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.circle("fill", self.x, self.y, 2)
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setLineWidth(1)
end

return Player
