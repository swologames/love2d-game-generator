-- Animal Entity
-- Competing animals: possums, cats, and crows

local TypeStats      = require("src.entities.animal.TypeStats")
local Wander         = require("src.entities.animal.Wander")
local Flee           = require("src.entities.animal.Flee")
local DirectionUtils = require("src.entities.animal.DirectionUtils")

local Animal = {}
Animal.__index = Animal

function Animal:new(x, y, animalType)
  local instance = setmetatable({}, self)
  instance.x = x or 0
  instance.y = y or 0
  instance.animalType = animalType or "possum"
  instance.width = 64
  instance.height = 64
  instance.speed = 0
  instance.vx = 0
  instance.vy = 0
  instance.state = "wander"
  instance.direction = "down"
  instance.wanderTargetX = x
  instance.wanderTargetY = y
  instance.wanderWaitTimer = 0
  instance.wanderWaitTime = 2
  instance.targetTrash = nil
  instance.trashDetectionRange = 150
  instance.playerDetectionRange = 100
  instance.fleeTimer = 0
  instance.fleeDuration = 0
  instance.hasTrash = false
  instance.sprite = nil
  instance.radius = 16
  TypeStats.initTypeStats(instance)
  return instance
end

function Animal:setSprite(sprite)
  self.sprite = sprite
end

function Animal:update(dt, player, trashItems)
  if self.wanderWaitTimer > 0 then self.wanderWaitTimer = self.wanderWaitTimer - dt end
  if self.fleeTimer > 0 then self.fleeTimer = self.fleeTimer - dt end

  if self.state == "wander" then
    Wander.updateWander(self, dt)
    Wander.checkForTrash(self, trashItems)
    Flee.checkPlayerProximity(self, player)
  elseif self.state == "seek_trash" then
    Wander.updateSeekTrash(self, dt)
    Flee.checkPlayerProximity(self, player)
  elseif self.state == "grab_trash" then
    Wander.updateGrabTrash(self, dt)
    Flee.checkPlayerProximity(self, player)
  elseif self.state == "flee" then
    Flee.updateFlee(self, dt, player)
  end

  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  DirectionUtils.updateDirection(self)
end

function Animal:draw()
  local lg = love.graphics
  if self.sprite then
    lg.setColor(1, 1, 1)
    local scaleX = 1
    if self.direction == "left" then scaleX = -1 end
    local yOffset = 0
    if self.animalType == "crow" then
      yOffset = math.sin(love.timer.getTime() * 3) * 5
    end
    lg.draw(self.sprite, self.x, self.y + yOffset, 0, scaleX, 1, self.width/2, self.height/2)
  else
    if self.animalType == "possum" then lg.setColor(0.8, 0.8, 0.75)
    elseif self.animalType == "cat" then lg.setColor(0.9, 0.6, 0.3)
    elseif self.animalType == "crow" then lg.setColor(0.1, 0.1, 0.15)
    end
    lg.circle("fill", self.x, self.y, self.radius)
    lg.setColor(1, 1, 1)
    lg.circle("line", self.x, self.y, self.radius)
  end
  if true then
    lg.setColor(1, 1, 1)
    lg.print(self.animalType .. ":" .. self.state, self.x - 30, self.y - self.height/2 - 15, 0, 0.6)
  end
  if self.hasTrash then
    lg.setColor(0.8, 0.6, 0.2)
    lg.circle("fill", self.x + 15, self.y - 15, 5)
  end
end

return Animal
