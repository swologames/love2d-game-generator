-- Human Enemy Entity
-- Patrol behavior with vision cone detection and chase

local Human = {}
Human.__index = Human

function Human:new(x, y, patrolPoints)
  local instance = setmetatable({}, self)
  instance.x = x or 0
  instance.y = y or 0
  instance.width = 64
  instance.height = 96
  instance.speed = 120
  instance.vx = 0
  instance.vy = 0
  instance.state = "patrol"
  instance.direction = "down"
  instance.patrolPoints = patrolPoints or {{x = x, y = y}}
  instance.currentPatrolIndex = 1
  instance.patrolWaitTime = 2
  instance.patrolWaitTimer = 0
  instance.visionRange = 200
  instance.visionAngle = math.pi
  instance.detectionTimer = 0
  instance.detectionDelay = 0.5
  instance.chaseTimer = 0
  instance.chaseMinDuration = 5
  instance.chaseMaxDuration = 10
  instance.chaseDuration = 7
  instance.target = nil
  instance.lastSeenX = 0
  instance.lastSeenY = 0
  instance.returnToX = x
  instance.returnToY = y
  instance.idleSprite = nil
  instance.walkSprite = nil
  instance.currentFrame = 1
  instance.animTimer = 0
  instance.animFPS = 8
  instance.radius = 20
  return instance
end

function Human:setSprites(idleSprite, walkFrames)
  self.idleSprite = idleSprite
  self.walkSprite = walkFrames
end

function Human:update(dt, player)
  local DirUtils = require("src.entities.enemy.DirectionUtils")
  DirUtils.updateAnimation(self, dt)
  if self.state == "patrol" then
    local Patrol = require("src.entities.enemy.Patrol")
    Patrol.update(self, dt)
    local Detection = require("src.entities.enemy.Detection")
    Detection.check(self, player, dt, function(p)
      self.state = "chase"
      self.target = p
      self.chaseTimer = 0
      self.chaseDuration = math.random(self.chaseMinDuration * 10, self.chaseMaxDuration * 10) / 10
      print("[Human] Started chasing player for " .. self.chaseDuration .. " seconds")
    end)
  elseif self.state == "chase" then
    local Chase = require("src.entities.enemy.Chase")
    Chase.update(self, dt, player, function()
      print("[Human] Caught the player!")
      return math.random(1, 2)
    end, function(h)
      print("[Human] Stopped chasing, returning to patrol")
    end)
  elseif self.state == "return" then
    local Chase = require("src.entities.enemy.Chase")
    Chase.updateReturn(self, dt)
  end
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  local DirUtils2 = require("src.entities.enemy.DirectionUtils")
  DirUtils2.updateDirection(self)
end

function Human:stopChase()
  local Chase = require("src.entities.enemy.Chase")
  Chase.stopChase(self)
  print("[Human] Stopped chasing, returning to patrol")
end

function Human:draw()
  local lg = love.graphics
  
  if self.walkSprite and self.currentFrame <= #self.walkSprite then
    local sprite = self.walkSprite[self.currentFrame]
    lg.setColor(1, 1, 1)
    local scaleX = 1
    if self.direction == "left" or self.direction == "up-left" or self.direction == "down-left" then
      scaleX = -1
    end
    lg.draw(sprite, self.x, self.y, 0, scaleX, 1, self.width/2, self.height/2)
  elseif self.idleSprite then
    lg.setColor(1, 1, 1)
    lg.draw(self.idleSprite, self.x, self.y, 0, 1, 1, self.width/2, self.height/2)
  else
    lg.setColor(0.8, 0.3, 0.3)
    lg.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    lg.setColor(1, 1, 1)
    lg.circle("line", self.x, self.y, self.radius)
  end
  if true then
    lg.setColor(1, 1, 1)
    lg.print(self.state, self.x - 20, self.y - self.height/2 - 15, 0, 0.7)
  end
end

return Human
