-- GameScene.lua
-- Main gameplay scene for Mecha Shmup

local Player = require("src.entities.Player")
local Enemy = require("src.entities.Enemy")
local PowerUp = require("src.entities.PowerUp")
local Boss = require("src.entities.Boss")
local CollisionSystem = require("src.systems.CollisionSystem")
local ParticleSystem = require("src.systems.ParticleSystem")
local ShaderSystem = require("src.systems.ShaderSystem")
local LevelSystem = require("src.systems.LevelSystem")
local BackgroundSystem = require("src.systems.BackgroundSystem")
local BulletManager = require("src.systems.BulletManager")

local GameScene = {}

function GameScene:enter(characterId, levelId, isBoss)
  print("Entering Game Scene with character: " .. (characterId or 1) .. ", level: " .. tostring(levelId or 1) .. ", isBoss: " .. tostring(isBoss or false))
  
  -- Create player
  self.player = Player:new(characterId or 1)
  self.player.weaponLevel = 1
  
  -- Store selected level
  self.selectedLevel = levelId or 1
  self.isBossFight = isBoss or false
  
  -- Intro sequence state
  self.introActive = not self.isBossFight  -- Skip intro for boss fights
  self.introPhase = "ship_entry"  -- ship_entry -> area_text -> pilot_text -> engage_text -> fade_out -> done
  self.introTimer = 0
  self.introTotalTime = 0  -- Track total time for continuous movement
  self.playerStartY = 800  -- Start off-screen below
  self.playerTargetY = 600  -- Final position
  self.player.x = 320  -- Center horizontally
  
  -- Set player position based on whether it's a boss fight
  if self.isBossFight then
    self.player.y = self.playerTargetY  -- Start at normal position
    self.player.controllable = true
  else
    self.player.y = self.playerStartY  -- Start off-screen for intro
    self.player.controllable = false
  end
  
  -- Initialize background system
  self.background = BackgroundSystem
  self.background:init(640, 720)
  
  -- Legacy star system (kept for space theme overlay)
  self.stars = {}
  for i = 1, 200 do
    table.insert(self.stars, {
      x = math.random(0, 640),
      y = math.random(0, 720),
      speed = math.random(100, 250),
      size = math.random(1, 3)
    })
  end
  
  -- Game state
  self.paused = false
  self.gameTime = 0
  self.wave = 1
  
  -- Death animation state
  self.deathAnimating = false
  self.deathTimer = 0
  self.deathDuration = 2.5  -- Total death animation duration
  self.gameOverFadeAlpha = 0
  
  -- Boss death sequence state
  self.bossDeathSequence = false
  self.bossDeathTimer = 0
  self.bossDeathPhase = "wait"  -- wait -> flash -> complete -> fade
  self.bossDeathFlashAlpha = 0
  
  -- Combat entities
  self.enemies = {}
  self.powerups = {}
  self.boss = nil
  self.bossActive = false
  
  -- Particle system (must be created before BulletManager)
  self.particles = ParticleSystem:new()
  self.particles.screenShakeEnabled = false  -- Disabled by default, using shader effects instead
  
  -- Bullet management system
  self.bulletManager = BulletManager:new(self.particles)
  
  -- Spawning systems
  self.spawnTimer = 0
  self.spawnInterval = 1.2
  self.powerupTimer = 0
  self.powerupInterval = 15.0
  self.waveTimer = 0
  self.waveInterval = 30.0
  self.formationTimer = 0
  self.formationInterval = 3.5
  
  -- Shader system
  self.shaders = ShaderSystem:new()
  
  -- Level system
  self.levelSystem = LevelSystem:new()
  local levelLoaded = self.levelSystem:loadLevel(self.selectedLevel)
  if not levelLoaded then
    print("Using random enemy spawning (no level loaded)")
  end
  
  -- Store level music for later playback (after intro)
  self.levelMusic = nil
  self.bossMusicName = "boss_fight"  -- Default
  if self.levelSystem.levelData then
    self.levelMusic = self.levelSystem.levelData.music
    self.bossMusicName = self.levelSystem.levelData.bossMusic or "boss_fight"
  end
  
  -- Set initial background from level data (for intro)
  if self.levelSystem.levelData and self.levelSystem.levelData.events then
    for _, event in ipairs(self.levelSystem.levelData.events) do
      if event.time == 0.0 and event.type == "background" then
        self.background:setTheme(event.theme or "space", event.instant)
        break
      end
    end
  end
  
  -- UI elements
  self.showDebug = false
  self.messageText = ""
  self.messageTimer = 0
  
  -- If this is a boss fight, spawn boss immediately
  if self.isBossFight then
    print("Boss fight mode - spawning boss immediately")
    self:spawnBoss()
    -- Play boss music
    AudioSystem:playMusic(self.bossMusicName, true, 1.5)
  end
end

function GameScene:exit()
  print("Exiting Game Scene")
  self.particles:clear()
end

function GameScene:update(dt)
  if self.paused then return end
  
  -- Update audio system
  AudioSystem:update(dt)
  
  self.gameTime = self.gameTime + dt
  self.messageTimer = math.max(0, self.messageTimer - dt)
  
  -- Handle intro sequence
  if self.introActive then
    self.introTimer = self.introTimer + dt
    self.introTotalTime = self.introTotalTime + dt
    
    -- Continuous ship movement throughout entire intro
    local totalIntroDuration = 3.0  -- Total time for ship to reach target
    local progress = math.min(1, self.introTotalTime / totalIntroDuration)
    local eased = 1 - math.pow(1 - progress, 3)  -- Ease-out cubic
    self.player.y = self.playerStartY - (self.playerStartY - self.playerTargetY) * eased
    
    if self.introPhase == "ship_entry" then
      -- Initial ship entry phase
      if self.introTimer >= 0.8 then
        self.introPhase = "area_text"
        self.introTimer = 0
      end
    elseif self.introPhase == "area_text" then
      -- Show area text for 1.0 seconds
      if self.introTimer >= 1.0 then
        self.introPhase = "pilot_text"
        self.introTimer = 0
      end
    elseif self.introPhase == "pilot_text" then
      -- Show pilot name for 0.5 seconds
      if self.introTimer >= 0.5 then
        self.introPhase = "engage_text"
        self.introTimer = 0
      end
    elseif self.introPhase == "engage_text" then
      -- Show ENGAGE! for 0.4 seconds
      if self.introTimer >= 0.4 then
        self.introPhase = "fade_out"
        self.introTimer = 0
      end
    elseif self.introPhase == "fade_out" then
      -- Quick fade out
      if self.introTimer >= 0.3 then
        self.introPhase = "done"
        self.introActive = false
        self.player.controllable = true
        self.introTimer = 0
        
        -- Start level music and play start chime
        if self.levelMusic then
          AudioSystem:playMusic(self.levelMusic, true, 1.5)
        end
        AudioSystem:playSound("start_chime")
      end
    end
  end
  
  -- Update background system (always, even during intro)
  self.background:update(dt)
  
  -- Update stars for space theme (always, even during intro)
  for _, star in ipairs(self.stars) do
    star.y = star.y + star.speed * dt
    if star.y > 720 then
      star.y = -10
      star.x = math.random(0, 640)
    end
  end
  
  -- Update particles and shaders (always, even during intro)
  self.particles:update(dt)
  self.shaders:update(dt)
  
  -- Skip rest of game logic during intro sequence
  if self.introActive then
    -- Still update player for animation
    self.player:update(dt)
    
    -- Generate engine trail particles during intro
    if math.random() < 0.5 then
      self.particles:engineTrail(self.player.x, self.player.y + 15, self.player.color)
    end
    
    return
  end
  
  -- Update player
  self.player:update(dt)
  
  -- Engine trail particles
  if math.random() < 0.5 then
    self.particles:engineTrail(self.player.x, self.player.y + 15, self.player.color)
  end
  
  -- Bullet trail particles
  for _, bullet in ipairs(self.player.bullets) do
    if math.random() < 0.3 then
      self.particles:bulletTrail(bullet.x, bullet.y, self.player.color)
    end
  end
  
  -- Wave progression
  self.waveTimer = self.waveTimer + dt
  if self.waveTimer >= self.waveInterval and not self.bossActive then
    self.wave = self.wave + 1
    self.waveTimer = 0
    self.spawnInterval = math.max(0.3, self.spawnInterval * 0.9)
    self:showMessage("WAVE " .. self.wave, 3.0)
    
    -- Trigger boss every 3 waves (if not using level system)
    if not self.levelSystem.isActive and self.wave % 3 == 0 and not self.boss then
      self:spawnBoss()
    end
  end
  
  -- Update level system (scripted spawning)
  if self.levelSystem.isActive then
    self.levelSystem:update(dt, self)
    
    -- Check if level is complete and load next level
    if self.levelSystem:isLevelComplete() and not self.bossActive then
      local nextLevel = self.levelSystem.currentLevel + 1
      local loaded = self.levelSystem:loadLevel(nextLevel)
      if not loaded then
        -- No more levels, loop back or use random spawning
        print("No more levels, using random spawning")
        self.levelSystem:disable()
      end
    end
  end
  
  -- Fallback: Random enemy spawning (when level system is not active)
  if not self.levelSystem.isActive and not self.bossActive then
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
      self:spawnEnemy()
      self.spawnTimer = 0
    end
    
    -- Formation spawning - groups of enemies
    self.formationTimer = self.formationTimer + dt
    if self.formationTimer >= self.formationInterval then
      self:spawnFormation()
      self.formationTimer = 0
    end
  end
  
  -- Power-up spawning
  self.powerupTimer = self.powerupTimer + dt
  if self.powerupTimer >= self.powerupInterval then
    self:spawnPowerUp()
    self.powerupTimer = 0
  end
  
  -- Update background system
  self.background:update(dt)
  
  -- Update enemies
  for i = #self.enemies, 1, -1 do
    local enemy = self.enemies[i]
    enemy:update(dt, self.player.x, self.player.y)
    
    -- Handle enemy shooting
    if enemy.needsToShoot then
      enemy:shoot(self.player.x, self.player.y, self.bulletManager)
      enemy.needsToShoot = false
    end
    
    -- Remove dead or off-screen enemies
    if not enemy.alive or enemy.y > 750 then
      -- Notify bullet manager that this enemy is being removed
      self.bulletManager:notifyEnemyRemoved(enemy.id)
      
      if not enemy.alive then
        -- Chance to drop power-up
        if math.random() < 0.15 then
          self:spawnPowerUpAt(enemy.x, enemy.y)
        end
      end
      table.remove(self.enemies, i)
    end
  end
  
  -- Update bullet manager
  self.bulletManager:update(dt, self.player.x, self.player.y, self.enemies)
  
  -- Update power-ups
  for i = #self.powerups, 1, -1 do
    local powerup = self.powerups[i]
    powerup:update(dt)
    if not powerup.alive then
      table.remove(self.powerups, i)
    end
  end
  
  -- Update boss
  if self.boss and self.boss.state ~= "defeated" then
    self.boss:update(dt, self.player.x, self.player.y)
  elseif self.boss and self.boss.state == "defeated" and not self.bossDeathSequence then
    -- Boss just defeated, start death sequence
    self.bossDeathSequence = true
    self.bossDeathTimer = 0
    self.bossDeathPhase = "wait"
    self.player.controllable = false  -- Disable player control during death sequence
  end
  
  -- Boss death sequence
  if self.bossDeathSequence then
    self:updateBossDeathSequence(dt)
  end
  
  -- Collision detection
  self:checkCollisions()
  
  -- Death animation handling
  if not self.player.alive and not self.deathAnimating and not self.paused then
    -- Player just died, start death animation
    self.deathAnimating = true
    self.deathTimer = 0
    
    -- Play game over sound
    AudioSystem:playSound("game_over")
    
    -- Create massive explosion at player position
    self.particles:explosion(self.player.x, self.player.y, 60, self.player.color)
    self.shaders:addExplosion(self.player.x, self.player.y, 3.0)
    self.particles:addScreenShake(5)
    
    -- Add extra explosion particles
    for i = 1, 30 do
      local angle = math.random() * math.pi * 2
      local speed = 50 + math.random() * 150
      local size = 3 + math.random() * 5
      table.insert(self.particles.particles, {
        x = self.player.x,
        y = self.player.y,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        size = size,
        baseSize = size,
        color = self.player.color,
        alpha = 1,
        baseAlpha = 1,
        lifetime = 0.8 + math.random() * 0.7,
        maxLifetime = 0.8 + math.random() * 0.7,
        shape = "circle",
        shrink = true
      })
    end
  end
  
  -- Update death animation
  if self.deathAnimating then
    self.deathTimer = self.deathTimer + dt
    
    -- Fade in game over overlay (starts fading after 1 second)
    if self.deathTimer > 1.0 then
      local fadeStart = self.deathTimer - 1.0
      self.gameOverFadeAlpha = math.min(1, fadeStart / 1.0)
    end
    
    -- After full duration, pause the game
    if self.deathTimer >= self.deathDuration then
      self.deathAnimating = false
      self:gameOver()
    end
  end
end

function GameScene:checkCollisions()
  -- Player bullets vs enemies
  local bulletHits = CollisionSystem.checkPlayerBulletsVsEnemies(self.player, self.enemies)
  for _, hit in ipairs(bulletHits) do
    if hit.type == "enemyKilled" then
      self.particles:explosion(hit.x, hit.y, hit.enemy.size, hit.enemy.color)
      self.shaders:addExplosion(hit.x, hit.y, hit.enemy.size / 20.0)
    elseif hit.type == "enemyHit" then
      self.particles:smallExplosion(hit.x, hit.y)
    end
  end
  
  -- Enemy bullets vs player
  local playerHits = CollisionSystem.checkEnemyBulletsVsPlayer(self.player, self.bulletManager)
  for _, hit in ipairs(playerHits) do
    self.particles:explosion(hit.x, hit.y, 10, {1, 0.3, 0.3})
  end
  
  -- Enemies vs player collision
  local collisionHits = CollisionSystem.checkEnemiesVsPlayer(self.player, self.enemies)
  for _, hit in ipairs(collisionHits) do
    self.particles:explosion(hit.x, hit.y, 15, {1, 0.5, 0.2})
  end
  
  -- Power-ups vs player
  local collected = CollisionSystem.checkPowerUpsVsPlayer(self.player, self.powerups)
  for _, item in ipairs(collected) do
    self.particles:powerUpCollect(item.x, item.y, {1, 0.8, 0.2})
  end
  
  -- Boss collisions
  if self.boss and self.boss.alive then
    local bossHits = CollisionSystem.checkPlayerBulletsVsBoss(self.player, self.boss)
    for _, hit in ipairs(bossHits) do
      if hit.type == "bossDefeated" then
        self.particles:explosion(hit.x, hit.y, 60, {1, 0.2, 0.2})
        self.shaders:addExplosion(hit.x, hit.y, 3.5)
        self.particles:addScreenShake(3)
      else
        self.particles:smallExplosion(hit.x, hit.y)
      end
    end
    
    local bossPlayerHits = CollisionSystem.checkBossBulletsVsPlayer(self.player, self.boss)
    for _, hit in ipairs(bossPlayerHits) do
      self.particles:explosion(hit.x, hit.y, 12, {1, 0.3, 0.3})
    end
  end
end

function GameScene:spawnEnemy()
  local enemyTypes = {"scout", "scout", "interceptor", "bomber", "kamikaze"}
  local type = enemyTypes[math.random(#enemyTypes)]
  
  -- Increase harder enemies in later waves
  if self.wave > 5 then
    type = enemyTypes[math.random(2, #enemyTypes)]
  end
  
  local x = math.random(50, 590)
  self:spawnEnemyAt(type, x, -20)
end

function GameScene:spawnEnemyAt(type, x, y)
  -- Spawn a specific enemy type at a specific position
  local enemy = Enemy:new(type, x, y)
  table.insert(self.enemies, enemy)
end

function GameScene:spawnFormation(pattern, enemyType, count)
  -- Spawn a formation with specified pattern, enemy type, and count
  pattern = pattern or "line"
  count = count or 5
  
  -- If enemyType not specified, choose randomly
  if not enemyType then
    local enemyTypes = {"scout", "scout", "interceptor", "bomber"}
    if self.wave > 5 then
      enemyTypes = {"scout", "interceptor", "interceptor", "bomber", "kamikaze"}
    end
    enemyType = enemyTypes[math.random(#enemyTypes)]
  end
  
  if pattern == "line" then
    -- Horizontal line of enemies
    local count = 4 + math.floor(self.wave / 3)
    local startX = 320 - (count * 40) / 2
    for i = 0, count - 1 do
      local enemy = Enemy:new(type, startX + i * 40, -20 - i * 15)
      table.insert(self.enemies, enemy)
    end
    
  elseif formation == "vformation" then
    -- V-shaped formation
    local count = 5
    local centerX = 320
    for i = 0, count - 1 do
      local offset = (i - math.floor(count / 2)) * 50
      local yOffset = math.abs(offset) * 0.5
      local enemy = Enemy:new(type, centerX + offset, -20 - yOffset)
      table.insert(self.enemies, enemy)
    end
    
  elseif formation == "wave" then
    -- Sine wave pattern
    local count = 6
    for i = 0, count - 1 do
      local x = 100 + (i / count) * 440
      local yOffset = math.sin(i * 0.8) * 30
      local enemy = Enemy:new(type, x, -20 + yOffset)
      table.insert(self.enemies, enemy)
    end
    
  elseif formation == "diamond" then
    -- Diamond formation
    local positions = {
      {0, -40},    -- top
      {-40, -20}, {40, -20},  -- middle
      {-80, 0}, {0, 0}, {80, 0},  -- bottom middle
      {-40, 20}, {40, 20}   -- bottom
    }
    local centerX = 320
    for _, pos in ipairs(positions) do
      local enemy = Enemy:new(type, centerX + pos[1], -20 + pos[2])
      table.insert(self.enemies, enemy)
    end
    
  elseif formation == "swarm" then
    -- Tight cluster swarm
    local count = 8 + math.floor(self.wave / 2)
    local centerX = math.random(150, 490)
    for i = 0, count - 1 do
      local angle = (i / count) * math.pi * 2
      local radius = 40 + math.random() * 30
      local x = centerX + math.cos(angle) * radius
      local y = -20 + math.sin(angle) * radius
      local enemy = Enemy:new(type, x, y)
      table.insert(self.enemies, enemy)
    end
  end
end

function GameScene:updateBossDeathSequence(dt)
  self.bossDeathTimer = self.bossDeathTimer + dt
  
  if self.bossDeathPhase == "wait" then
    -- Wait for boss death animation (2 seconds)
    if self.bossDeathTimer >= 2.0 then
      self.bossDeathPhase = "flash"
      self.bossDeathTimer = 0
      self.particles:addScreenShake(5)  -- Big shake
      self.shaders:addExplosion(self.boss.x, self.boss.y, 5.0)  -- Big explosion shader effect
    end
    
  elseif self.bossDeathPhase == "flash" then
    -- Screen white flash (0.5 seconds)
    self.bossDeathFlashAlpha = math.min(1, self.bossDeathTimer / 0.1)
    if self.bossDeathTimer >= 0.5 then
      self.bossDeathFlashAlpha = 1 - ((self.bossDeathTimer - 0.5) / 0.3)
      
      if self.bossDeathTimer >= 0.8 then
        self.bossDeathPhase = "complete"
        self.bossDeathTimer = 0
        self.bossActive = false
        self.boss = nil
        self:showMessage("AREA COMPLETED!")
        
        -- Fade back to level music
        if self.levelMusic then
          AudioSystem:playMusic(self.levelMusic, true, 2.0)
        end
      end
    end
    
  elseif self.bossDeathPhase == "complete" then
    -- Player ship flies forward, show message (2 seconds)
    -- Move player forward/up
    self.player.y = self.player.y - 150 * dt
    
    if self.bossDeathTimer >= 2.0 then
      self.bossDeathPhase = "fade"
      self.bossDeathTimer = 0
    end
    
  elseif self.bossDeathPhase == "fade" then
    -- Fade to black and transition (1 second)
    self.gameOverFadeAlpha = math.min(1, self.bossDeathTimer / 1.0)
    
    if self.bossDeathTimer >= 1.0 then
      -- Transition to next level or back to level select
      -- For now, go back to level select
      SceneManager:switch("levelSelect", self.characterId)
    end
  end
end

function GameScene:spawnPowerUp()
  local types = {"health", "weapon", "special", "shield", "score"}
  local type = types[math.random(#types)]
  local x = math.random(80, 560)
  table.insert(self.powerups, PowerUp:new(type, x, -20))
end

function GameScene:spawnPowerUpAt(x, y, type)
  -- Spawn a power-up at a specific position with optional type
  if not type then
    local types = {"health", "weapon", "special", "shield", "score"}
    type = types[math.random(#types)]
  end
  table.insert(self.powerups, PowerUp:new(type, x, y))
end

function GameScene:spawnBoss()
  self.boss = Boss:new("vorkath", 320, -100)
  self.bossActive = true
  self.enemies = {} -- Clear regular enemies
  self:showMessage("WARNING: BOSS APPROACHING!")
  
  -- Crossfade to boss music
  AudioSystem:playMusic(self.bossMusicName, true, 2.0)
end

function GameScene:showMessage(text)
  self.messageText = text
  self.messageTimer = 3.0
end

function GameScene:gameOver()
  -- Handle game over
  self.paused = true
  -- Could transition to game over scene here
end

function GameScene:draw()
  -- Begin shader post-processing
  self.shaders:beginDraw()
  
  -- Apply screen shake (optional)
  love.graphics.push()
  local shakeX, shakeY = self.particles:getShake()
  love.graphics.translate(shakeX, shakeY)
  
  -- Draw dynamic background
  self.background:draw()
  
  -- Draw additional stars for space theme (overlay)
  if self.background.currentTheme == "space" then
    love.graphics.setColor(1, 1, 1, 0.25)
    for _, star in ipairs(self.stars) do
      love.graphics.circle("fill", star.x, star.y, star.size)
    end
  end
  
  -- Draw particles (background layer)
  self.particles:draw()
  
  -- Draw power-ups
  for _, powerup in ipairs(self.powerups) do
    powerup:draw()
  end
  
  -- Draw enemies
  for _, enemy in ipairs(self.enemies) do
    enemy:draw()
  end
  
  -- Draw boss
  if self.boss then
    self.boss:draw()
  end
  
  -- Draw player ship (without hitbox)
  self.player:drawShip()
  
  -- Draw bullets from bullet manager (over player ship)
  for _, bullet in ipairs(self.bulletManager:getBullets()) do
    local color = bullet.color or {0.3, 0.9, 1}
    
    -- Glow effect
    love.graphics.setColor(color[1], color[2], color[3], 0.3)
    love.graphics.circle("fill", bullet.x, bullet.y, bullet.size * 1.4)
    
    -- Main bullet
    love.graphics.setColor(color)
    love.graphics.circle("fill", bullet.x, bullet.y, bullet.size)
    
    -- Core highlight
    love.graphics.setColor(1, 1, 1, 0.6)
    love.graphics.circle("fill", bullet.x, bullet.y, bullet.size * 0.4)
  end
  
  -- Draw player hitbox (always on top)
  self.player:drawHitbox()
  
  love.graphics.pop()
  
  -- Draw HUD (not affected by shake)
  self:drawHUD()
  
  -- End shader post-processing (applies CRT and explosion effects)
  self.shaders:endDraw()
  
  -- Draw intro sequence overlays
  if self.introActive or self.introPhase == "fade_out" then
    -- Calculate overall fade for fade_out phase
    local overlayAlpha = 1
    if self.introPhase == "fade_out" then
      overlayAlpha = 1 - (self.introTimer / 0.3)
    end
    
    -- Semi-transparent dark overlay for text contrast
    love.graphics.setColor(0, 0, 0, 0.5 * overlayAlpha)
    love.graphics.rectangle("fill", 0, 0, 640, 720)
    
    if self.introPhase == "area_text" then
      -- Calculate fade in/out
      local fadeTime = 0.2
      local alpha = 1
      if self.introTimer < fadeTime then
        alpha = self.introTimer / fadeTime
      elseif self.introTimer > 1.0 - fadeTime then
        alpha = (1.0 - self.introTimer) / fadeTime
      end
      
      -- AREA 1 text
      love.graphics.setFont(love.graphics.newFont(56))
      love.graphics.setColor(0.3, 0.9, 1, alpha)
      love.graphics.printf("AREA 1", 0, 280, 640, "center")
      
      -- Area name (from level system)
      local areaName = self.levelSystem.levelData and self.levelSystem.levelData.name or "Unknown Sector"
      love.graphics.setFont(love.graphics.newFont(24))
      love.graphics.setColor(0.7, 0.9, 1, alpha * 0.8)
      love.graphics.printf(areaName, 0, 350, 640, "center")
      
    elseif self.introPhase == "pilot_text" then
      -- Fade in/out
      local fadeInTime = 0.15
      local fadeOutTime = 0.15
      local alpha = 1
      if self.introTimer < fadeInTime then
        alpha = self.introTimer / fadeInTime
      elseif self.introTimer > 0.5 - fadeOutTime then
        alpha = (0.5 - self.introTimer) / fadeOutTime
      end
      
      -- Pilot name
      love.graphics.setFont(love.graphics.newFont(42))
      love.graphics.setColor(self.player.color[1], self.player.color[2], self.player.color[3], alpha)
      love.graphics.printf(self.player.name:upper(), 0, 310, 640, "center")
      
    elseif self.introPhase == "engage_text" then
      -- Fade in and pulse
      local fadeInTime = 0.1
      local fadeOutTime = 0.1
      local baseAlpha = 1
      if self.introTimer < fadeInTime then
        baseAlpha = self.introTimer / fadeInTime
      elseif self.introTimer > 0.4 - fadeOutTime then
        baseAlpha = (0.4 - self.introTimer) / fadeOutTime
      end
      
      local pulseAlpha = baseAlpha * (0.7 + 0.3 * math.sin(self.introTimer * 8))
      
      -- ENGAGE! text
      love.graphics.setFont(love.graphics.newFont(64))
      love.graphics.setColor(1, 1, 0.3, pulseAlpha)
      love.graphics.printf("ENGAGE!", 0, 300, 640, "center")
      
      -- Add glow effect
      love.graphics.setColor(1, 0.8, 0.2, pulseAlpha * 0.3)
      love.graphics.printf("ENGAGE!", -2, 298, 640, "center")
      love.graphics.printf("ENGAGE!", 2, 302, 640, "center")
    end
  end
  
  -- Draw message overlay
  if self.messageTimer > 0 then
    local alpha = math.min(1, self.messageTimer / 0.5)
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.printf(self.messageText, 0, 320, 640, "center")
  end
  
  -- Draw pause overlay
  if self.paused then
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, 640, 720)
    
    if self.player.alive then
      love.graphics.setFont(love.graphics.newFont(48))
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.printf("PAUSED", 0, 300, 640, "center")
      
      love.graphics.setFont(love.graphics.newFont(18))
      love.graphics.printf("Press ESC to Resume", 0, 370, 640, "center")
      love.graphics.printf("Press Q to Quit to Menu", 0, 400, 640, "center")
    else
      -- Game Over screen with fade
      love.graphics.setFont(love.graphics.newFont(64))
      love.graphics.setColor(1, 0.3, 0.3, self.gameOverFadeAlpha)
      love.graphics.printf("GAME OVER", 0, 250, 640, "center")
      
      love.graphics.setFont(love.graphics.newFont(24))
      love.graphics.setColor(1, 1, 1, self.gameOverFadeAlpha)
      love.graphics.printf("Final Score: " .. string.format("%08d", self.player.score), 
                           0, 340, 640, "center")
      love.graphics.printf("Wave Reached: " .. self.wave, 0, 380, 640, "center")
      
      love.graphics.setFont(love.graphics.newFont(18))
      love.graphics.printf("Press Q to Return to Menu", 0, 450, 640, "center")
    end
  end
  
  -- Draw boss death sequence overlays
  if self.bossDeathSequence then
    -- White flash effect (Megaman X style)
    if self.bossDeathFlashAlpha > 0 then
      love.graphics.setColor(1, 1, 1, self.bossDeathFlashAlpha)
      love.graphics.rectangle("fill", 0, 0, 640, 720)
    end
    
    -- Fade to black at the end
    if self.bossDeathPhase == "fade" then
      love.graphics.setColor(0, 0, 0, self.gameOverFadeAlpha)
      love.graphics.rectangle("fill", 0, 0, 640, 720)
    end
  end
  
  -- Draw death animation overlay (fading in game over)
  if self.deathAnimating and self.gameOverFadeAlpha > 0 then
    love.graphics.setColor(0, 0, 0, 0.7 * self.gameOverFadeAlpha)
    love.graphics.rectangle("fill", 0, 0, 640, 720)
    
    -- Game Over text fading in
    love.graphics.setFont(love.graphics.newFont(64))
    love.graphics.setColor(1, 0.3, 0.3, self.gameOverFadeAlpha)
    love.graphics.printf("GAME OVER", 0, 250, 640, "center")
    
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.setColor(1, 1, 1, self.gameOverFadeAlpha)
    love.graphics.printf("Final Score: " .. string.format("%08d", self.player.score), 
                         0, 340, 640, "center")
    love.graphics.printf("Wave Reached: " .. self.wave, 0, 380, 640, "center")
  end
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
end

function GameScene:drawHUD()
  -- Top bar - serves as level indicator or boss health bar
  local barWidth = 630
  local barHeight = 10
  local barX = (640 - barWidth) / 2
  local barY = 2
  
  if self.bossActive and self.boss and self.boss.alive then
    -- BOSS HEALTH BAR
    local healthInfo = self.boss:getHealthInfo()
    
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", barX - 3, barY - 1, barWidth + 6, barHeight + 2, 2, 2)
    love.graphics.setColor(0.15, 0.15, 0.2, 0.8)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight, 2, 2)
    
    -- Health fill
    local healthPercent = healthInfo.healthPercent
    if healthPercent > 0.6 then
      love.graphics.setColor(healthInfo.phaseColor[1], healthInfo.phaseColor[2], healthInfo.phaseColor[3], 0.95)
    elseif healthPercent > 0.3 then
      love.graphics.setColor(1, 0.6, 0.2, 0.95)
    else
      love.graphics.setColor(1, 0.2, 0.2, 0.95)
    end
    love.graphics.rectangle("fill", barX, barY, barWidth * healthPercent, barHeight, 2, 2)
    
    -- Outline
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight, 2, 2)
    
    -- Boss name on the bar
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(1, 1, 1, 0.95)
    local nameText = healthInfo.name .. " - " .. healthInfo.phaseName
    local nameWidth = love.graphics.getFont():getWidth(nameText)
    love.graphics.print(nameText, 320 - nameWidth / 2, barY + 1)
    
    love.graphics.setLineWidth(1)
  else
    -- LEVEL NAME INDICATOR
    local levelName = self.levelSystem.levelData and self.levelSystem.levelData.name or "COMBAT ZONE"
    
    -- Semi-transparent background
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", barX - 3, barY - 1, barWidth + 6, barHeight + 2, 2, 2)
    love.graphics.setColor(0.1, 0.15, 0.25, 0.7)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight, 2, 2)
    
    -- Outline
    love.graphics.setLineWidth(1)
    love.graphics.setColor(0.3, 0.5, 0.8, 0.6)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight, 2, 2)
    
    -- Level name text
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.setColor(0.6, 0.8, 1, 0.9)
    local nameWidth = love.graphics.getFont():getWidth(levelName)
    love.graphics.print(levelName, 320 - nameWidth / 2, barY + 1)
    
    love.graphics.setLineWidth(1)
  end
  
  local font = love.graphics.newFont(13)
  love.graphics.setFont(font)
  
  -- Top left: Health (moved down to avoid bar)
  love.graphics.setColor(1, 1, 1, 0.9)
  love.graphics.print("HP:", 6, 16)
  for i = 1, self.player.maxHealth do
    if i <= self.player.health then
      love.graphics.setColor(1, 0.3, 0.3, 1)
      love.graphics.circle("fill", 35 + i * 18, 23, 5)
    else
      love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
      love.graphics.circle("line", 35 + i * 18, 23, 5)
    end
  end
  
  -- Top right: Lives (moved down to avoid bar)
  love.graphics.setFont(font)
  love.graphics.setColor(1, 1, 1, 0.9)
  love.graphics.print("LIVES:", 560, 16)
  love.graphics.print("x" .. self.player.lives, 615, 16)
  
  -- Second row left: Special charges
  love.graphics.setColor(1, 1, 1, 0.9)
  love.graphics.print("SP:", 6, 36)
  for i = 1, self.player.maxSpecialCharges do
    if i <= self.player.specialCharges then
      love.graphics.setColor(0.3, 0.8, 1, 1)
      love.graphics.rectangle("fill", 35 + i * 16, 36, 11, 11)
    else
      love.graphics.setColor(0.3, 0.3, 0.3, 0.5)
      love.graphics.rectangle("line", 35 + i * 16, 36, 11, 11)
    end
  end
  
  -- Second row right: Weapon level  
  love.graphics.setColor(1, 1, 1, 0.9)
  love.graphics.print("WPN:", 560, 36)
  love.graphics.setColor(1, 1, 0.5, 1)
  love.graphics.print("LV" .. (self.player.weaponLevel or 1), 605, 36)
  
  -- Top center: Score with subtle background (moved down)
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle("fill", 240, 13, 160, 18, 3, 3)
  love.graphics.setColor(1, 1, 1, 0.95)
  love.graphics.setFont(love.graphics.newFont(14))
  love.graphics.printf(string.format("%08d", self.player.score), 240, 15, 160, "center")
  
  -- Wave below score
  love.graphics.setFont(love.graphics.newFont(11))
  love.graphics.setColor(0.7, 0.8, 1, 0.8)
  love.graphics.printf("WAVE " .. self.wave, 0, 34, 640, "center")
  
  -- Pilot name (bottom left corner)
  love.graphics.setColor(self.player.color)
  love.graphics.setFont(love.graphics.newFont(12))
  love.graphics.print(self.player.name, 10, 695)
  love.graphics.setColor(0.7, 0.7, 0.7, 1)
  love.graphics.print(self.player.mecha, 10, 707)
  
  -- Instructions (first few seconds - bottom center)
  if self.gameTime < 5 then
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.setColor(1, 1, 1, 0.7)
    love.graphics.printf("WASD: Move  |  SPACE: Fire  |  LSHIFT: Focus  |  ESC: Pause", 
                         0, 682, 640, "center")
  end
  
  -- Debug info (right side, below UI)
  if self.showDebug then
    love.graphics.setColor(0, 1, 0, 0.9)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("FPS: " .. love.timer.getFPS(), 545, 54)
    love.graphics.print("Bullets: " .. #self.player.bullets, 545, 68)
    love.graphics.print("Enemies: " .. #self.enemies, 545, 82)
    love.graphics.print("PowerUps: " .. #self.powerups, 545, 96)
    love.graphics.print("Particles: " .. #self.particles.particles, 545, 110)
    if self.boss then
      love.graphics.print("Boss Phase: " .. self.boss.phase, 545, 124)
    end
    if self.player.debugInvincible then
      love.graphics.setColor(1, 1, 0, 1)
      love.graphics.print("[INVINCIBLE]", 545, 138)
      love.graphics.setColor(0, 1, 0, 0.9)
    end
    if self.player.debug10xDamage then
      love.graphics.setColor(1, 0.5, 0, 1)
      love.graphics.print("[10X DAMAGE]", 545, 152)
      love.graphics.setColor(0, 1, 0, 0.9)
    end
  end
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
end

function GameScene:keypressed(key)
  if key == "escape" then
    if not self.player.alive then
      SceneManager:switch("menu")
    else
      self.paused = not self.paused
    end
  elseif key == "q" and self.paused then
    SceneManager:switch("menu")
  elseif key == "f3" then
    self.showDebug = not self.showDebug
  elseif key == "b" and self.showDebug then
    -- Debug: spawn boss
    if not self.boss then
      self:spawnBoss()
    end
  elseif key == "p" and self.showDebug then
    -- Debug: spawn random power-up
    self:spawnPowerUpAt(self.player.x, self.player.y - 50)
  elseif key == "c" and self.showDebug then
    -- Debug: toggle CRT shader
    self.shaders:toggleCRT()
  elseif key == "s" and self.showDebug then
    -- Debug: toggle screen shake
    self.particles.screenShakeEnabled = not self.particles.screenShakeEnabled
  elseif key == "i" and self.showDebug then
    -- Debug: toggle invincibility
    self.player.debugInvincible = not self.player.debugInvincible
  elseif key == "x" and self.showDebug then
    -- Debug: toggle 10x damage
    self.player.debug10xDamage = not self.player.debug10xDamage
  elseif key == "1" and self.showDebug then
    -- Debug: cycle backgrounds
    local themes = {"space", "water", "mechanical", "crystal", "nebula", "forest"}
    local currentIndex = 1
    for i, theme in ipairs(themes) do
      if theme == self.background.currentTheme then
        currentIndex = i
        break
      end
    end
    local nextIndex = (currentIndex % #themes) + 1
    self:setBackground(themes[nextIndex])
    self:showMessage("Background: " .. themes[nextIndex])
  end
end

-- Set background theme (called by level system or debug)
function GameScene:setBackground(themeName, instant)
  if self.background then
    self.background:setTheme(themeName, instant)
  end
end

function GameScene:mousepressed(x, y, button)
  -- Handle mouse input if needed
end

return GameScene
