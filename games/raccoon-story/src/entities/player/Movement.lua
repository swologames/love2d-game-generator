-- Player Movement Sub-module
-- Handles WASD/arrow input, velocity, direction, world bounds

local Movement = {}

function Movement.handleInput(self, dt)
  local up    = love.keyboard.isDown("w", "up")
  local down  = love.keyboard.isDown("s", "down")
  local left  = love.keyboard.isDown("a", "left")
  local right = love.keyboard.isDown("d", "right")

  local dx = 0
  local dy = 0

  if left  then dx = dx - 1 end
  if right then dx = dx + 1 end
  if up    then dy = dy - 1 end
  if down  then dy = dy + 1 end

  -- Normalise diagonal movement
  if dx ~= 0 and dy ~= 0 then
    local len = math.sqrt(dx * dx + dy * dy)
    dx = dx / len
    dy = dy / len
  end

  -- Update direction (8-directional)
  if dx ~= 0 or dy ~= 0 then
    if      dx > 0  and dy == 0 then self.direction = "right"
    elseif  dx < 0  and dy == 0 then self.direction = "left"
    elseif  dx == 0 and dy < 0  then self.direction = "up"
    elseif  dx == 0 and dy > 0  then self.direction = "down"
    elseif  dx > 0  and dy < 0  then self.direction = "up-right"
    elseif  dx > 0  and dy > 0  then self.direction = "down-right"
    elseif  dx < 0  and dy < 0  then self.direction = "up-left"
    elseif  dx < 0  and dy > 0  then self.direction = "down-left"
    end
  end

  -- Choose speed
  local speed = self.isDashing and self.dashSpeed or self.speed

  self.vx = dx * speed
  self.vy = dy * speed

  self.isMoving = (dx ~= 0 or dy ~= 0)

  -- Apply movement
  self.x = self.x + self.vx * dt
  self.y = self.y + self.vy * dt

  -- World bounds (constrain to window)
  local ww, wh = love.graphics.getWidth(), love.graphics.getHeight()
  self.x = math.max(0, math.min(ww - self.width,  self.x))
  self.y = math.max(0, math.min(wh - self.height, self.y))
end

return Movement
