-- Player Entity
-- The playable raccoon character

local AnimationSystem = require("src.systems.AnimationSystem")
local AnimationStateMachine = require("src.systems.AnimationStateMachine")

local Player = {}
Player.__index = Player

function Player:new(x, y)
  local instance = setmetatable({}, self)
  
  -- Position
  instance.x = x or 0
  instance.y = y or 0
  
  -- Movement
  instance.speed = 150 -- pixels per second
  instance.dashSpeed = 300
  instance.isDashing = false
  instance.dashTimer = 0
  instance.dashDuration = 0.5
  instance.dashCooldown = 3
  instance.dashCooldownTimer = 0
  
  -- Size
  instance.width = 64
  instance.height = 64
  
  -- State
  instance.direction = "right" -- up, down, left, right, up-left, up-right, down-left, down-right
  instance.isHiding = false
  instance.isMoving = false
  instance.vx = 0 -- Velocity for state machine
  instance.vy = 0
  
  -- Inventory
  instance.inventory = {}
  instance.maxInventorySlots = 6
  
  -- Animation system (will be initialized after sprites are loaded)
  instance.animSystem = nil
  instance.stateMachine = nil
  instance.animationsReady = false
  
  return instance
end

-- Set sprite references and initialize animations
function Player:setSprites(idleFrames, walkFrames, dashFrames)
  -- Create animation system
  self.animSystem = AnimationSystem:new()
  
  -- Add animations with GDD-specified FPS
  -- Idle: 4 frames, 6 FPS, Loop
  self.animSystem:addAnimation("idle", idleFrames, 6, true)
  
  -- Walk: 6 frames, 12 FPS, Loop
  self.animSystem:addAnimation("walk", walkFrames, 12, true)
  
  -- Dash: 3 frames, 15 FPS, No Loop
  self.animSystem:addAnimation("dash", dashFrames, 15, false)
  
  -- Create state machine
  self.stateMachine = AnimationStateMachine:new(self.animSystem)
  
  -- Define states
  self.stateMachine:addState("idle", "idle")
  self.stateMachine:addState("walk", "walk")
  self.stateMachine:addState("dash", "dash", function()
    -- On enter dash state
    print("[Player] Started dash animation")
  end, function()
    -- On exit dash state
    print("[Player] Completed dash animation")
  end)
  
  -- Define transitions
  -- Idle -> Walk
  self.stateMachine:addTransition("idle", "walk", function(ctx)
    return ctx.isMoving and not ctx.isDashing
  end)
  
  -- Walk -> Idle
  self.stateMachine:addTransition("walk", "idle", function(ctx)
    return not ctx.isMoving and not ctx.isDashing
  end)
  
  -- Any -> Dash (when dashing)
  self.stateMachine:addTransition("idle", "dash", function(ctx)
    return ctx.isDashing
  end)
  
  self.stateMachine:addTransition("walk", "dash", function(ctx)
    return ctx.isDashing
  end)
  
  -- Dash -> Idle (when dash ends and not moving)
  self.stateMachine:addTransition("dash", "idle", function(ctx)
    return not ctx.isDashing and not ctx.isMoving
  end)
  
  -- Dash -> Walk (when dash ends and moving)
  self.stateMachine:addTransition("dash", "walk", function(ctx)
    return not ctx.isDashing and ctx.isMoving
  end)
  
  -- Set initial state
  self.stateMachine:setState("idle")
  
  self.animationsReady = true
  print("[Player] Animation system initialized")
end

function Player:update(dt)
  -- Update dash cooldown
  if self.dashCooldownTimer > 0 then
    self.dashCooldownTimer = self.dashCooldownTimer - dt
  end
  
  -- Update dash duration
  if self.isDashing then
    self.dashTimer = self.dashTimer + dt
    if self.dashTimer >= self.dashDuration then
      self.isDashing = false
      self.dashTimer = 0
    end
  end
  
  -- Movement input
  local dx, dy = 0, 0
  local currentSpeed = self.isDashing and self.dashSpeed or self.speed
  
  if love.keyboard.isDown("w", "up") then
    dy = -1
  end
  if love.keyboard.isDown("s", "down") then
    dy = 1
  end
  if love.keyboard.isDown("a", "left") then
    dx = -1
  end
  if love.keyboard.isDown("d", "right") then
    dx = 1
  end
  
  -- Normalize diagonal movement
  if dx ~= 0 and dy ~= 0 then
    local magnitude = math.sqrt(dx * dx + dy * dy)
    dx = dx / magnitude
    dy = dy / magnitude
  end
  
  -- Update direction (8-directional)
  if dx ~= 0 or dy ~= 0 then
    if dy < 0 then
      if dx < 0 then
        self.direction = "up-left"
      elseif dx > 0 then
        self.direction = "up-right"
      else
        self.direction = "up"
      end
    elseif dy > 0 then
      if dx < 0 then
        self.direction = "down-left"
      elseif dx > 0 then
        self.direction = "down-right"
      else
        self.direction = "down"
      end
    else
      if dx < 0 then
        self.direction = "left"
      else
        self.direction = "right"
      end
    end
  end
  
  -- Apply movement
  self.isMoving = (dx ~= 0 or dy ~= 0)
  self.vx = dx * currentSpeed
  self.vy = dy * currentSpeed
  self.x = self.x + dx * currentSpeed * dt
  self.y = self.y + dy * currentSpeed * dt
  
  -- Update animation state machine
  if self.animationsReady then
    self.stateMachine:update(dt, self)
  end
end

function Player:draw()
  local lg = love.graphics
  
  if self.animationsReady then
    -- Calculate sprite flip/rotation based on 8-directional movement
    local scaleX = 1
    local scaleY = 1
    local rotation = 0
    
    -- Determine horizontal flip based on direction
    if self.direction == "left" or self.direction == "up-left" or self.direction == "down-left" then
      scaleX = -1
    end
    
    -- For up/down variations, we can optionally add slight rotation
    -- For this implementation, we'll use flipping only for simplicity
    -- (vertical directions don't need rotation as the sprite is designed to work for all)
    
    -- Draw with proper origin for flipping
    lg.setColor(1, 1, 1) -- Reset color to white for proper sprite rendering
    self.stateMachine:draw(
      self.x + self.width / 2,
      self.y,
      rotation,
      scaleX,
      scaleY,
      self.width / 2,
      0
    )
  else
    -- Fallback: Draw simple placeholder (rectangle)
    lg.setColor(0.5, 0.5, 0.5) -- Gray for raccoon
    lg.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Draw direction indicator
    lg.setColor(1, 1, 1)
    local centerX = self.x + self.width / 2
    local centerY = self.y + self.height / 2
    
    -- Simple arrow based on primary direction
    if string.find(self.direction, "up") then
      lg.polygon("fill", centerX, centerY - 10, centerX - 5, centerY, centerX + 5, centerY)
    elseif string.find(self.direction, "down") then
      lg.polygon("fill", centerX, centerY + 10, centerX - 5, centerY, centerX + 5, centerY)
    end
    
    if string.find(self.direction, "left") then
      lg.polygon("fill", centerX - 10, centerY, centerX, centerY - 5, centerX, centerY + 5)
    elseif string.find(self.direction, "right") then
      lg.polygon("fill", centerX + 10, centerY, centerX, centerY - 5, centerX, centerY + 5)
    end
  end
  
  -- Draw dash cooldown indicator
  local centerX = self.x + self.width / 2
  local centerY = self.y + self.height / 2
  
  if self.isDashing then
    lg.setColor(1, 1, 0) -- Yellow while dashing
    lg.circle("line", centerX, centerY, self.width / 2 + 3)
  elseif self.dashCooldownTimer > 0 then
    lg.setColor(1, 0, 0, 0.5) -- Red while on cooldown
    local progress = self.dashCooldownTimer / self.dashCooldown
    lg.arc("fill", centerX, centerY, self.width / 2 + 3, -math.pi/2, -math.pi/2 + (math.pi * 2 * (1 - progress)))
  end
end

function Player:dash()
  if self.dashCooldownTimer <= 0 and not self.isDashing then
    self.isDashing = true
    self.dashTimer = 0
    self.dashCooldownTimer = self.dashCooldown
    -- TODO: Play dash sound
  end
end

function Player:hide()
  -- TODO: Check if near hiding spot
  self.isHiding = true
  -- TODO: Play hide sound
end

function Player:unhide()
  self.isHiding = false
end

function Player:addToInventory(item)
  if #self.inventory < self.maxInventorySlots then
    table.insert(self.inventory, item)
    return true
  end
  return false
end

function Player:removeFromInventory(index)
  if index and self.inventory[index] then
    return table.remove(self.inventory, index)
  elseif #self.inventory > 0 then
    -- Remove last item if no index specified
    return table.remove(self.inventory)
  end
  return nil
end

function Player:getInventoryCount()
  return #self.inventory
end

return Player
