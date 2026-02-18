-- Icon.lua
-- HUD icon renderer with built-in icon library

local Icon = {}
Icon.__index = Icon

-- Icon definitions (simple geometric shapes for now)
local iconLibrary = {
  heart = function(x, y, size)
    local lg = love.graphics
    -- Simple heart shape using circles and triangle
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    lg.circle("fill", -5, -3, 5)
    lg.circle("fill", 5, -3, 5)
    lg.polygon("fill", -10, 2, 10, 2, 0, 12)
    
    lg.pop()
  end,
  
  moon = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- Crescent moon
    lg.setColor(0.961, 0.871, 0.702, 1) -- Cream
    lg.circle("fill", 0, 0, 10)
    lg.setColor(0.106, 0.106, 0.180, 1) -- Night blue
    lg.circle("fill", 4, -2, 8)
    
    lg.pop()
  end,
  
  alert = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- Warning triangle
    lg.polygon("fill", 0, -10, -8, 8, 8, 8)
    lg.setColor(0, 0, 0)
    lg.rectangle("fill", -1, -4, 2, 6)
    lg.circle("fill", 0, 5, 1.5)
    
    lg.pop()
  end,
  
  trash = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- Trash can
    lg.rectangle("fill", -6, -4, 12, 10)
    lg.rectangle("fill", -8, -6, 16, 2)
    lg.setColor(0, 0, 0, 0.3)
    lg.rectangle("fill", -4, -2, 2, 6)
    lg.rectangle("fill", 2, -2, 2, 6)
    
    lg.pop()
  end,
  
  star = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- 5-pointed star
    local points = {}
    for i = 0, 4 do
      local angle = (i * 2 * math.pi / 5) - math.pi / 2
      local outerRadius = 10
      local innerRadius = 4
      
      table.insert(points, math.cos(angle) * outerRadius)
      table.insert(points, math.sin(angle) * outerRadius)
      
      local innerAngle = angle + math.pi / 5
      table.insert(points, math.cos(innerAngle) * innerRadius)
      table.insert(points, math.sin(innerAngle) * innerRadius)
    end
    lg.polygon("fill", points)
    
    lg.pop()
  end,
  
  dash = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- Speed lines
    for i = 1, 3 do
      local offset = (i - 2) * 4
      lg.rectangle("fill", -10 + i * 2, offset, 8 - i, 2)
    end
    
    lg.pop()
  end,
  
  home = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- House
    lg.polygon("fill", 0, -8, -8, 0, 8, 0)
    lg.rectangle("fill", -6, 0, 12, 10)
    lg.setColor(0, 0, 0, 0.3)
    lg.rectangle("fill", -2, 4, 4, 6)
    
    lg.pop()
  end,
  
  paw = function(x, y, size)
    local lg = love.graphics
    lg.push()
    lg.translate(x, y)
    local scale = size / 20
    lg.scale(scale, scale)
    
    -- Paw print
    lg.circle("fill", 0, 2, 5) -- Main pad
    lg.circle("fill", -4, -4, 3) -- Toe 1
    lg.circle("fill", 0, -6, 3) -- Toe 2
    lg.circle("fill", 4, -4, 3) -- Toe 3
    
    lg.pop()
  end
}

function Icon:new(iconType, x, y, size, color)
  local instance = setmetatable({}, self)
  
  instance.iconType = iconType
  instance.x = x
  instance.y = y
  instance.size = size or 20
  instance.color = color or {1, 1, 1, 1}
  instance.visible = true
  
  -- Animation properties
  instance.pulse = false
  instance.pulseSpeed = 2
  instance.pulseAmount = 0.2
  instance.pulsePhase = 0
  
  instance.rotate = false
  instance.rotationSpeed = 1
  instance.rotation = 0
  
  return instance
end

function Icon:update(dt)
  if self.pulse then
    self.pulsePhase = self.pulsePhase + self.pulseSpeed * dt
  end
  
  if self.rotate then
    self.rotation = self.rotation + self.rotationSpeed * dt
  end
end

function Icon:draw()
  if not self.visible then return end
  
  local lg = love.graphics
  local iconFunc = iconLibrary[self.iconType]
  
  if not iconFunc then
    -- Draw a placeholder if icon not found
    lg.setColor(1, 0, 1) -- Magenta for missing icon
    lg.circle("line", self.x, self.y, self.size / 2)
    return
  end
  
  lg.push()
  
  -- Apply rotation if enabled
  if self.rotate then
    lg.translate(self.x, self.y)
    lg.rotate(self.rotation)
    lg.translate(-self.x, -self.y)
  end
  
  -- Apply pulse scale if enabled
  local scale = 1.0
  if self.pulse then
    scale = 1.0 + math.sin(self.pulsePhase) * self.pulseAmount
  end
  
  if scale ~= 1.0 then
    lg.translate(self.x, self.y)
    lg.scale(scale, scale)
    lg.translate(-self.x, -self.y)
  end
  
  -- Draw the icon
  lg.setColor(self.color)
  iconFunc(self.x, self.y, self.size)
  
  lg.pop()
end

function Icon:setPosition(x, y)
  self.x = x
  self.y = y
end

function Icon:setSize(size)
  self.size = size
end

function Icon:setColor(r, g, b, a)
  self.color = {r, g, b, a or 1}
end

function Icon:setPulse(enabled, speed, amount)
  self.pulse = enabled
  if speed then self.pulseSpeed = speed end
  if amount then self.pulseAmount = amount end
end

function Icon:setRotate(enabled, speed)
  self.rotate = enabled
  if speed then self.rotationSpeed = speed end
end

function Icon:setVisible(visible)
  self.visible = visible
end

return Icon
