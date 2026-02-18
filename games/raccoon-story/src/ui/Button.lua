-- Button.lua
-- Reusable interactive button component for UI

local Button = {}
Button.__index = Button

function Button:new(x, y, width, height, text, onClick)
  local instance = setmetatable({}, self)
  
  -- Position and size
  instance.x = x
  instance.y = y
  instance.width = width
  instance.height = height
  
  -- Content
  instance.text = text
  instance.onClick = onClick
  
  -- State
  instance.hovered = false
  instance.pressed = false
  instance.enabled = true
  instance.focused = false -- For controller navigation
  
  -- Animation
  instance.scale = 1.0
  instance.targetScale = 1.0
  instance.glowAlpha = 0
  
  -- Colors (cozy GDD palette)
  instance.normalColor = {0.545, 0.271, 0.075, 1} -- Warm brown #8B4513
  instance.hoverColor = {0.647, 0.325, 0.090, 1} -- Lighter brown
  instance.pressedColor = {0.443, 0.220, 0.061, 1} -- Darker brown
  instance.disabledColor = {0.3, 0.3, 0.3, 0.5}
  instance.textColor = {0.961, 0.871, 0.702, 1} -- Cream #F5DEB3
  instance.focusColor = {0.565, 0.933, 0.565, 1} -- Soft green #90EE90
  instance.glowColor = {1, 1, 1, 0.3}
  
  -- Sound (to be played when clicked)
  instance.clickSound = nil
  instance.hoverSound = nil
  
  return instance
end

function Button:update(dt)
  if not self.enabled then return end
  
  -- Smooth scale animation
  local lerpSpeed = 10
  self.scale = self.scale + (self.targetScale - self.scale) * lerpSpeed * dt
  
  -- Glow animation for hover
  if self.hovered or self.focused then
    self.glowAlpha = math.min(1, self.glowAlpha + 3 * dt)
  else
    self.glowAlpha = math.max(0, self.glowAlpha - 3 * dt)
  end
  
  -- Check mouse hover
  local mx, my = love.mouse.getPosition()
  local wasHovered = self.hovered
  self.hovered = self:containsPoint(mx, my)
  
  -- Play hover sound on first hover
  if self.hovered and not wasHovered and self.hoverSound then
    self.hoverSound:play()
  end
  
  -- Update target scale based on state
  if self.pressed then
    self.targetScale = 0.95
  elseif self.hovered or self.focused then
    self.targetScale = 1.1
  else
    self.targetScale = 1.0
  end
end

function Button:draw()
  local lg = love.graphics
  
  -- Calculate scaled dimensions
  local scaledWidth = self.width * self.scale
  local scaledHeight = self.height * self.scale
  local scaledX = self.x + (self.width - scaledWidth) / 2
  local scaledY = self.y + (self.height - scaledHeight) / 2
  
  -- Draw glow effect
  if self.glowAlpha > 0 then
    lg.setColor(self.glowColor[1], self.glowColor[2], self.glowColor[3], self.glowAlpha * 0.5)
    lg.rectangle("fill", scaledX - 4, scaledY - 4, scaledWidth + 8, scaledHeight + 8, 8)
  end
  
  -- Draw button background
  local color = self.normalColor
  if not self.enabled then
    color = self.disabledColor
  elseif self.pressed then
    color = self.pressedColor
  elseif self.hovered or self.focused then
    color = self.hoverColor
  end
  
  lg.setColor(color)
  lg.rectangle("fill", scaledX, scaledY, scaledWidth, scaledHeight, 6)
  
  -- Draw focus indicator (for controller)
  if self.focused then
    lg.setColor(self.focusColor)
    lg.setLineWidth(3)
    lg.rectangle("line", scaledX - 2, scaledY - 2, scaledWidth + 4, scaledHeight + 4, 8)
    lg.setLineWidth(1)
  end
  
  -- Draw button border
  lg.setColor(0, 0, 0, 0.3)
  lg.rectangle("line", scaledX, scaledY, scaledWidth, scaledHeight, 6)
  
  -- Draw text
  lg.setColor(self.textColor)
  local font = lg.getFont()
  local textWidth = font:getWidth(self.text)
  local textHeight = font:getHeight()
  local textX = self.x + (self.width - textWidth) / 2
  local textY = self.y + (self.height - textHeight) / 2
  lg.print(self.text, textX, textY)
end

function Button:mousepressed(x, y, button)
  if not self.enabled then return false end
  
  if button == 1 and self:containsPoint(x, y) then
    self.pressed = true
    return true
  end
  return false
end

function Button:mousereleased(x, y, button)
  if not self.enabled then return false end
  
  if button == 1 and self.pressed then
    self.pressed = false
    if self:containsPoint(x, y) and self.onClick then
      if self.clickSound then
        self.clickSound:stop()
        self.clickSound:play()
      end
      self.onClick()
      return true
    end
  end
  return false
end

function Button:activate()
  -- Called when activated via controller/keyboard
  if self.enabled and self.onClick then
    if self.clickSound then
      self.clickSound:stop()
      self.clickSound:play()
    end
    self.onClick()
  end
end

function Button:setFocused(focused)
  self.focused = focused
end

function Button:setEnabled(enabled)
  self.enabled = enabled
end

function Button:containsPoint(x, y)
  return x >= self.x and x <= self.x + self.width and
         y >= self.y and y <= self.y + self.height
end

function Button:setSounds(clickSound, hoverSound)
  self.clickSound = clickSound
  self.hoverSound = hoverSound
end

return Button
