-- Panel.lua
-- Rounded panel background for UI elements

local Panel = {}
Panel.__index = Panel

function Panel:new(x, y, width, height, style)
  local instance = setmetatable({}, self)
  
  instance.x = x
  instance.y = y
  instance.width = width
  instance.height = height
  
  -- Style options: "solid", "translucent", "outlined"
  instance.style = style or "translucent"
  
  -- Colors (GDD cozy palette)
  instance.backgroundColor = {0.106, 0.106, 0.180, 0.9} -- Deep blue-purple night #1A1A2E
  instance.borderColor = {0.545, 0.271, 0.075, 1} -- Warm brown #8B4513
  instance.shadowColor = {0, 0, 0, 0.5}
  
  -- Visual properties
  instance.cornerRadius = 12
  instance.borderWidth = 3
  instance.shadowOffset = 4
  
  return instance
end

function Panel:draw()
  local lg = love.graphics
  
  if self.style == "solid" or self.style == "translucent" then
    -- Draw shadow
    lg.setColor(self.shadowColor)
    lg.rectangle("fill", 
      self.x + self.shadowOffset, 
      self.y + self.shadowOffset, 
      self.width, 
      self.height, 
      self.cornerRadius
    )
    
    -- Draw background
    lg.setColor(self.backgroundColor)
    lg.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius)
  end
  
  if self.style == "outlined" or self.style == "solid" then
    -- Draw border
    lg.setColor(self.borderColor)
    lg.setLineWidth(self.borderWidth)
    lg.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius)
    lg.setLineWidth(1)
  end
end

function Panel:setPosition(x, y)
  self.x = x
  self.y = y
end

function Panel:setSize(width, height)
  self.width = width
  self.height = height
end

function Panel:setStyle(style)
  self.style = style
end

function Panel:containsPoint(x, y)
  return x >= self.x and x <= self.x + self.width and
         y >= self.y and y <= self.y + self.height
end

return Panel
