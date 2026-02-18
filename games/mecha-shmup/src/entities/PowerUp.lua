-- PowerUp.lua
-- Power-up collectible entity for Mecha Shmup

local PowerUp = {}
PowerUp.__index = PowerUp

-- Power-up types
local POWERUP_TYPES = {
  health = {
    name = "Health",
    color = {1, 0.3, 0.3},
    icon = "♥",
    effect = "heal"
  },
  weapon = {
    name = "Weapon Power",
    color = {0.3, 0.7, 1},
    icon = "⚡",
    effect = "weaponUp"
  },
  special = {
    name = "Special Charge",
    color = {1, 0.8, 0.2},
    icon = "★",
    effect = "specialCharge"
  },
  shield = {
    name = "Shield",
    color = {0.5, 1, 0.5},
    icon = "◆",
    effect = "shield"
  },
  score = {
    name = "Score Bonus",
    color = {1, 0.7, 1},
    icon = "◎",
    effect = "scoreBonus"
  }
}

function PowerUp:new(type, x, y)
  local instance = setmetatable({}, self)
  
  local powerupData = POWERUP_TYPES[type] or POWERUP_TYPES.score
  
  instance.type = type
  instance.x = x
  instance.y = y
  instance.name = powerupData.name
  instance.color = powerupData.color
  instance.icon = powerupData.icon
  instance.effect = powerupData.effect
  
  instance.size = 8
  instance.speed = 80
  instance.alive = true
  
  -- Animation
  instance.pulseTime = 0
  instance.rotation = 0
  
  return instance
end

function PowerUp:update(dt)
  if not self.alive then return end
  
  -- Float downward
  self.y = self.y + self.speed * dt
  
  -- Animate
  self.pulseTime = self.pulseTime + dt * 3
  self.rotation = self.rotation + dt * 2
  
  -- Remove if off-screen
  if self.y > 750 then
    self.alive = false
  end
end

function PowerUp:draw()
  if not self.alive then return end
  
  -- Pulsing glow effect
  local pulseScale = 1 + 0.2 * math.sin(self.pulseTime)
  local glowAlpha = 0.3 * (0.5 + 0.5 * math.sin(self.pulseTime * 2))
  
  -- Glow
  love.graphics.setColor(self.color[1], self.color[2], self.color[3], glowAlpha)
  love.graphics.circle("fill", self.x, self.y, self.size * pulseScale * 1.5)
  
  -- Main body
  love.graphics.setColor(self.color)
  love.graphics.circle("fill", self.x, self.y, self.size * pulseScale)
  
  -- Border
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.circle("line", self.x, self.y, self.size * pulseScale)
  
  -- Icon
  love.graphics.setFont(love.graphics.newFont(16))
  local textWidth = love.graphics.getFont():getWidth(self.icon)
  local textHeight = love.graphics.getFont():getHeight()
  love.graphics.print(self.icon, self.x - textWidth / 2, self.y - textHeight / 2)
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
end

function PowerUp:getBounds()
  return {
    x = self.x - self.size,
    y = self.y - self.size,
    width = self.size * 2,
    height = self.size * 2
  }
end

function PowerUp:collect(player)
  if not self.alive then return false end
  
  self.alive = false
  
  -- Apply effect
  if self.effect == "heal" then
    player.health = math.min(player.health + 1, player.maxHealth)
  elseif self.effect == "weaponUp" then
    player.weaponLevel = math.min((player.weaponLevel or 1) + 1, 5)
  elseif self.effect == "specialCharge" then
    player.specialCharges = math.min(player.specialCharges + 1, player.maxSpecialCharges)
  elseif self.effect == "shield" then
    player.invulnerable = true
    player.invulnerableTime = 5.0
  elseif self.effect == "scoreBonus" then
    player.score = player.score + 1000
  end
  
  return true
end

return PowerUp
