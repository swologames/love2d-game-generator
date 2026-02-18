-- Slider.lua
-- Volume/settings slider component

local Slider = {}
Slider.__index = Slider

function Slider:new(x, y, width, height, minValue, maxValue, initialValue, onChange)
  local instance = setmetatable({}, self)
  
  instance.x = x
  instance.y = y
  instance.width = width
  instance.height = height
  instance.minValue = minValue
  instance.maxValue = maxValue
  instance.value = initialValue
  instance.onChange = onChange
  instance.dragging = false
  instance.focused = false
  instance.enabled = true
  
  -- Visual properties (GDD cozy palette)
  instance.trackColor = {0.3, 0.3, 0.3, 1}
  instance.fillColor = {0.545, 0.271, 0.075, 1} -- Warm brown
  instance.handleColor = {0.961, 0.871, 0.702, 1} -- Cream
  instance.handleHoverColor = {0.565, 0.933, 0.565, 1} -- Soft green
  instance.focusColor = {0.565, 0.933, 0.565, 1} -- Soft green for focus
  instance.handleRadius = 10
  
  -- Animation
  instance.handleScale = 1.0
  
  return instance
end

function Slider:getValue()
  return self.value
end

function Slider:setValue(value)
  local oldValue = self.value
  self.value = math.max(self.minValue, math.min(value, self.maxValue))
  if self.onChange and math.abs(oldValue - self.value) > 0.01 then
    self.onChange(self.value)
  end
end

function Slider:update(dt)
  if not self.enabled then return end
  
  if self.dragging then
    local mx = love.mouse.getX()
    local t = (mx - self.x) / self.width
    t = math.max(0, math.min(1, t))
    local newValue = self.minValue + t * (self.maxValue - self.minValue)
    self:setValue(newValue)
  end
  
  -- Animate handle on hover
  local mx, my = love.mouse.getPosition()
  local t = (self.value - self.minValue) / (self.maxValue - self.minValue)
  local handleX = self.x + t * self.width
  local handleY = self.y + self.height / 2
  local dist = math.sqrt((mx - handleX)^2 + (my - handleY)^2)
  
  if dist <= self.handleRadius * 1.5 or self.focused then
    self.handleScale = math.min(1.3, self.handleScale + 5 * dt)
  else
    self.handleScale = math.max(1.0, self.handleScale - 5 * dt)
  end
end

function Slider:draw()
  local lg = love.graphics
  
  -- Track background
  lg.setColor(self.trackColor)
  lg.rectangle("fill", self.x, self.y, self.width, self.height, self.height / 2)
  
  -- Fill (shows current value)
  local t = (self.value - self.minValue) / (self.maxValue - self.minValue)
  local fillWidth = self.width * t
  lg.setColor(self.fillColor)
  lg.rectangle("fill", self.x, self.y, fillWidth, self.height, self.height / 2)
  
  -- Handle
  local handleX = self.x + t * self.width
  local handleY = self.y + self.height / 2
  
  -- Handle glow for focus
  if self.focused then
    lg.setColor(self.focusColor[1], self.focusColor[2], self.focusColor[3], 0.3)
    lg.circle("fill", handleX, handleY, self.handleRadius * self.handleScale + 4)
  end
  
  -- Handle shadow
  lg.setColor(0, 0, 0, 0.3)
  lg.circle("fill", handleX + 2, handleY + 2, self.handleRadius * self.handleScale)
  
  -- Handle
  local handleColor = self.handleColor
  if self.dragging or (self.handleScale > 1.1) then
    handleColor = self.handleHoverColor
  end
  lg.setColor(handleColor)
  lg.circle("fill", handleX, handleY, self.handleRadius * self.handleScale)
  
  -- Handle border
  lg.setColor(0.545, 0.271, 0.075, 1)
  lg.setLineWidth(2)
  lg.circle("line", handleX, handleY, self.handleRadius * self.handleScale)
  lg.setLineWidth(1)
  
  -- Value display (percentage)
  if self.dragging or self.focused then
    local percent = math.floor(t * 100)
    lg.setColor(1, 1, 1)
    local text = percent .. "%"
    local font = lg.getFont()
    local textWidth = font:getWidth(text)
    lg.print(text, handleX - textWidth / 2, handleY - 25)
  end
end

function Slider:mousepressed(x, y, button)
  if not self.enabled then return false end
  
  if button == 1 then
    local t = (self.value - self.minValue) / (self.maxValue - self.minValue)
    local handleX = self.x + t * self.width
    local handleY = self.y + self.height / 2
    
    local dist = math.sqrt((x - handleX)^2 + (y - handleY)^2)
    if dist <= self.handleRadius * 1.5 then
      self.dragging = true
      return true
    end
    
    -- Also allow clicking on track to jump to position
    if x >= self.x and x <= self.x + self.width and
       y >= self.y and y <= self.y + self.height then
      self.dragging = true
      local newT = (x - self.x) / self.width
      local newValue = self.minValue + newT * (self.maxValue - self.minValue)
      self:setValue(newValue)
      return true
    end
  end
  return false
end

function Slider:mousereleased(x, y, button)
  if button == 1 then
    self.dragging = false
  end
end

function Slider:adjustValue(delta)
  -- For keyboard/controller adjustment
  local range = self.maxValue - self.minValue
  local step = range * 0.05 -- 5% steps
  self:setValue(self.value + delta * step)
end

function Slider:setFocused(focused)
  self.focused = focused
end

function Slider:setEnabled(enabled)
  self.enabled = enabled
end

return Slider
