-- Dog Enemy Entity

local Dog = {}
Dog.__index = Dog

function Dog:new(x, y, patrolPoints)
  local instance = setmetatable({}, self)
  
  instance.x = x or 0
  instance.y = y or 0
  instance.width = 64
  instance.height = 64
  instance.speed = 180
  instance.vx = 0
  instance.vy = 0
  instance.state = "patrol"
  instance.direction = "down"
  instance.patrolPoints = patrolPoints or {{x = x, y = y}}
  instance.currentPatrolIndex = 1
  instance.patrolWaitTime = 1.5
  instance.patrolWaitTimer = 0
  instance.visionRange = 150
  instance.visionAngle = math.pi / 2
  instance.detectionTimer = 0
  instance.detectionDelay = 0.3
  instance.chaseTimer = 0
  instance.chaseMinDuration = 10
  instance.chaseMaxDuration = 15
  instance.chaseDuration = 12
  instance.target = nil
  instance.lastSeenX = 0
  instance.lastSeenY = 0
  instance.barkTimer = 0
  instance.barkDuration = 0.5
  instance.hasBarked = false
  instance.returnToX = x
  instance.returnToY = y
  instance.idleSprite = nil
  instance.runSprite = nil
  instance.currentFrame = 1
  instance.animTimer = 0
  instance.animFPS = 12
  instance.radius = 18
  return instance
end

function Dog:setSprites(idleSprite, runFrames)
  self.idleSprite = idleSprite
  self.runSprite = runFrames
end

function Dog:update(dt, player)
  local DirUtils = require("src.entities.enemy.DirectionUtils")
  local spriteFrames = self.runSprite
  DirUtils.updateAnimationFrames(self, dt, spriteFrames)
  if self.state == "patrol" then
    local Patrol = require("src.entities.enemy.Patrol")
    Patrol.update(self, dt)
    local Detection = require("src.entities.enemy.Detection")
    Detection.check(self, player, dt, function(p)
      self.state = "bark"
      self.target = p
      self.barkTimer = 0
      self.hasBarked = false
      self.vx = 0
      self.vy = 0
      print("[Dog] BARK! Player detected!")
    end)
  elseif self.state == "bark" then
    self.barkTimer = self.barkTimer + dt
    if not self.hasBarked and self.barkTimer >= self.barkDuration / 2 then
      self.hasBarked = true
    end
    if self.barkTimer >= self.barkDuration then
      self.state = "chase"
      self.target = player
      self.chaseTimer = 0
      self.chaseDuration = math.random(self.chaseMinDuration * 10, self.chaseMaxDuration * 10) / 10
      print("[Dog] Started chasing for " .. self.chaseDuration .. " seconds")
    end
  elseif self.state == "chase" then
    local Chase = require("src.entities.enemy.Chase")
    Chase.update(self, dt, player, function()
      print("[Dog] Caught the player!")
      return math.random(2, 3)
    end, function(d)
      print("[Dog] Stopped chasing, returning")
    end)
  elseif self.state == "return" then
    local Chase = require("src.entities.enemy.Chase")
    Chase.updateReturn(self, dt)
  end
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt
  DirUtils.updateDirection(self)
end

function Dog:stopChase()
  local Chase = require("src.entities.enemy.Chase")
  Chase.stopChase(self)
  print("[Dog] Stopped chasing, returning")
end

function Dog:draw()
  local lg = love.graphics
  
  if self.runSprite and self.currentFrame <= #self.runSprite then
    local sprite = self.runSprite[self.currentFrame]
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
    lg.setColor(0.6, 0.4, 0.2)
    lg.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    lg.setColor(1, 1, 1)
    lg.circle("line", self.x, self.y, self.radius)
  end
  if self.state == "bark" then
    lg.setColor(1, 1, 0)
    lg.print("BARK!", self.x - 15, self.y - self.height/2 - 20, 0, 1)
  end
  if true then
    lg.setColor(1, 1, 1)
    lg.print(self.state, self.x - 20, self.y - self.height/2 - 35, 0, 0.7)
  end
end

return Dog
