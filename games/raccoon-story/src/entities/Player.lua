-- Player Entity
-- Thin orchestrator — delegates to sub-modules in src/entities/player/

local Movement      = require("src.entities.player.Movement")
local DashAbility   = require("src.entities.player.DashAbility")
local HidingAbility = require("src.entities.player.HidingAbility")
local Inventory     = require("src.entities.player.Inventory")

local Player = {}
Player.__index = Player

function Player:new(x, y)
  local instance = setmetatable({}, self)

  instance.x = x or 0
  instance.y = y or 0

  -- Movement
  instance.speed             = 150
  instance.dashSpeed         = 300
  instance.isDashing         = false
  instance.dashTimer         = 0
  instance.dashDuration      = 0.5
  instance.dashCooldown      = 3
  instance.dashCooldownTimer = 0

  -- Size
  instance.width  = 64
  instance.height = 64

  -- State
  instance.direction = "right"
  instance.isHiding  = false
  instance.isMoving  = false
  instance.vx        = 0
  instance.vy        = 0

  -- Hiding mechanics
  instance.currentHidingSpot = nil
  instance.hidingGracePeriod = 0

  -- Inventory
  instance.inventory         = {}
  instance.maxInventorySlots = 6

  -- Animation (populated by setSprites)
  instance.animSystem      = nil
  instance.stateMachine    = nil
  instance.animationsReady = false

  return instance
end

function Player:setSprites(idleFrames, walkFrames, dashFrames)
  local AnimSetup = require("src.entities.player.AnimationSetup")
  AnimSetup.setup(self, idleFrames, walkFrames, dashFrames)
  self.animationsReady = true
end

function Player:update(dt)
  HidingAbility.updateGracePeriod(self, dt)
  DashAbility.updateTimers(self, dt)

  if self.isHiding then
    self.vx = 0
    self.vy = 0
    self.isMoving = false
    if self.animationsReady then self.stateMachine:update(dt, self) end
    return
  end

  Movement.handleInput(self, dt)
  if self.animationsReady then self.stateMachine:update(dt, self) end
end

function Player:draw()
  local lg = love.graphics
  local cx = self.x + self.width  / 2
  local cy = self.y + self.height / 2

  if self.animationsReady then
    local scaleX = 1
    local dir = self.direction
    if dir == "left" or dir == "up-left" or dir == "down-left" then scaleX = -1 end
    if self.isHiding then lg.setColor(1, 1, 1, 0.3) else lg.setColor(1, 1, 1) end
    self.stateMachine:draw(cx, self.y, 0, scaleX, 1, self.width / 2, 0)
  else
    -- Placeholder
    lg.setColor(0.5, 0.5, 0.5)
    lg.rectangle("fill", self.x, self.y, self.width, self.height)
    lg.setColor(1, 1, 1)
    if string.find(self.direction, "up") then
      lg.polygon("fill", cx, cy-10, cx-5, cy, cx+5, cy)
    elseif string.find(self.direction, "down") then
      lg.polygon("fill", cx, cy+10, cx-5, cy, cx+5, cy)
    end
    if string.find(self.direction, "left") then
      lg.polygon("fill", cx-10, cy, cx, cy-5, cx, cy+5)
    elseif string.find(self.direction, "right") then
      lg.polygon("fill", cx+10, cy, cx, cy-5, cx, cy+5)
    end
  end

  -- Dash cooldown indicator
  if self.isDashing then
    lg.setColor(1, 1, 0)
    lg.circle("line", cx, cy, self.width / 2 + 3)
  elseif self.dashCooldownTimer > 0 then
    lg.setColor(1, 0, 0, 0.5)
    local progress = self.dashCooldownTimer / self.dashCooldown
    lg.arc("fill", cx, cy, self.width/2+3, -math.pi/2, -math.pi/2 + math.pi*2*(1-progress))
  end
end

function Player:dash()              return DashAbility.trigger(self)             end
function Player:hide(hidingSpot)    return HidingAbility.enter(self, hidingSpot) end
function Player:exitHide()          return HidingAbility.exit(self)              end
function Player:addToInventory(item)    return Inventory.add(self, item)         end
function Player:removeFromInventory(i)  return Inventory.remove(self, i)         end
function Player:getInventoryCount() return #self.inventory                       end

return Player
