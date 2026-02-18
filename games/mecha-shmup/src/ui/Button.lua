-- Button.lua
-- Reusable button UI component for Mecha Shmup

local Button = {}
Button.__index = Button

function Button:new(x, y, width, height, text, onClick)
  local instance = setmetatable({}, self)
  
  instance.x = x
  instance.y = y
  instance.width = width
  instance.height = height
  instance.text = text
  instance.onClick = onClick
  instance.hovered = false
  instance.enabled = true
  
  -- Colors from GDD - Cyan/blue primary, white text
  instance.normalColor = {0.1, 0.3, 0.4, 1}
  instance.hoverColor = {0.2, 0.6, 0.8, 1}
  instance.pressedColor = {0.1, 0.5, 0.7, 1}
  instance.disabledColor = {0.2, 0.2, 0.2, 0.5}
  instance.textColor = {1, 1, 1, 1}
  instance.borderColor = {0.3, 0.8, 1, 1}
  
  -- Animation
  instance.glowIntensity = 0
  instance.glowTime = 0
  
  return instance
end

function Button:update(dt)
  if not self.enabled then return end
  
  local mx, my = love.mouse.getPosition()
  local wasHovered = self.hovered
  self.hovered = self:containsPoint(mx, my)
  
  -- Animate glow effect
  if self.hovered then
    self.glowTime = self.glowTime + dt * 3
    self.glowIntensity = math.min(1, self.glowIntensity + dt * 4)
  else
    self.glowIntensity = math.max(0, self.glowIntensity - dt * 4)
  end
end

function Button:draw()
  local color = self.normalColor
  
  if not self.enabled then
    color = self.disabledColor
  elseif self.hovered then
    color = self.hoverColor
  end
  
  -- Draw button background
  love.graphics.setColor(color)
  love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 4, 4)
  
  -- Draw glow effect when hovered
  if self.hovered and self.glowIntensity > 0 then
    local glowAlpha = 0.3 * self.glowIntensity * (0.5 + 0.5 * math.sin(self.glowTime * 2))
    love.graphics.setColor(self.borderColor[1], self.borderColor[2], self.borderColor[3], glowAlpha)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.x - 2, self.y - 2, self.width + 4, self.height + 4, 4, 4)
  end
  
  -- Draw border
  love.graphics.setColor(self.borderColor)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", self.x, self.y, self.width, self.height, 4, 4)
  
  -- Draw text
  love.graphics.setColor(self.textColor)
  local font = love.graphics.getFont()
  local textWidth = font:getWidth(self.text)
  local textHeight = font:getHeight()
  local textX = self.x + (self.width - textWidth) / 2
  local textY = self.y + (self.height - textHeight) / 2
  love.graphics.print(self.text, textX, textY)
  
  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

function Button:containsPoint(x, y)
  return x >= self.x and x <= self.x + self.width and
         y >= self.y and y <= self.y + self.height
end

function Button:mousepressed(x, y, button)
  if button == 1 and self.enabled and self:containsPoint(x, y) then
    if self.onClick then
      self.onClick()
    end
    return true
  end
  return false
end

return Button
