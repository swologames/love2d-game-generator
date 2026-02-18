-- Input Manager
-- Handles both keyboard and controller input
-- Provides unified input API for the game

local InputManager = {}

-- Input state
InputManager.keyboard = {
  up = false,
  down = false,
  left = false,
  right = false,
  action = false, -- Space/A
  dash = false, -- Shift/B
  hide = false, -- E/X
  pause = false, -- Esc/Start
  back = false -- Esc/B
}

InputManager.controller = nil
InputManager.deadzone = 0.3

-- Initialize controller support
function InputManager:init()
  local joysticks = love.joystick.getJoysticks()
  if #joysticks > 0 then
    self.controller = joysticks[1]
    print("[InputManager] Controller detected: " .. self.controller:getName())
  else
    print("[InputManager] No controller detected, using keyboard")
  end
end

-- Update input state
function InputManager:update(dt)
  -- Keyboard input
  self.keyboard.up = love.keyboard.isDown("w", "up")
  self.keyboard.down = love.keyboard.isDown("s", "down")
  self.keyboard.left = love.keyboard.isDown("a", "left")
  self.keyboard.right = love.keyboard.isDown("d", "right")
  self.keyboard.dash = love.keyboard.isDown("lshift", "rshift")
  self.keyboard.hide = love.keyboard.isDown("e")
end

-- Get movement direction (-1 to 1 for x and y)
function InputManager:getMovement()
  local x, y = 0, 0
  
  -- Controller input (takes priority)
  if self.controller then
    local leftX = self.controller:getGamepadAxis("leftx")
    local leftY = self.controller:getGamepadAxis("lefty")
    
    if math.abs(leftX) > self.deadzone then
      x = leftX
    end
    if math.abs(leftY) > self.deadzone then
      y = leftY
    end
  end
  
  -- Keyboard input (if no controller or controller not moved)
  if x == 0 and y == 0 then
    if self.keyboard.left then x = x - 1 end
    if self.keyboard.right then x = x + 1 end
    if self.keyboard.up then y = y - 1 end
    if self.keyboard.down then y = y + 1 end
  end
  
  return x, y
end

-- Check if action button is pressed (pickup/interact)
function InputManager:isActionPressed()
  if self.controller and self.controller:isGamepadDown("a") then
    return true
  end
  return love.keyboard.isDown("space", "return")
end

-- Check if dash button is held
function InputManager:isDashHeld()
  if self.controller and self.controller:isGamepadDown("b") then
    return true
  end
  return self.keyboard.dash
end

-- Check if hide button is held
function InputManager:isHideHeld()
  if self.controller and self.controller:isGamepadDown("x") then
    return true
  end
  return self.keyboard.hide
end

-- Check if pause button was just pressed
function InputManager:isPausePressed()
  if self.controller and self.controller:isGamepadDown("start") then
    return true
  end
  return false -- Handle via keypressed event
end

-- Get UI navigation (for menus)
function InputManager:getUINavigation()
  local dx, dy = 0, 0
  
  -- Controller dpad
  if self.controller then
    if self.controller:isGamepadDown("dpup") then dy = -1 end
    if self.controller:isGamepadDown("dpdown") then dy = 1 end
    if self.controller:isGamepadDown("dpleft") then dx = -1 end
    if self.controller:isGamepadDown("dpright") then dx = 1 end
    
    -- Also check left stick for UI navigation
    if dx == 0 and dy == 0 then
      local leftX = self.controller:getGamepadAxis("leftx")
      local leftY = self.controller:getGamepadAxis("lefty")
      if math.abs(leftX) > 0.5 then dx = leftX > 0 and 1 or -1 end
      if math.abs(leftY) > 0.5 then dy = leftY > 0 and 1 or -1 end
    end
  end
  
  return dx, dy
end

-- Check if UI confirm button was pressed
function InputManager:isUIConfirm()
  if self.controller and self.controller:isGamepadDown("a") then
    return true
  end
  return love.keyboard.isDown("return", "space")
end

-- Check if UI back button was pressed
function InputManager:isUIBack()
  if self.controller and self.controller:isGamepadDown("b") then
    return true
  end
  return false -- Handle via keypressed event
end

-- Get controller type for button prompts
function InputManager:getControllerType()
  if not self.controller then
    return "keyboard"
  end
  
  local name = self.controller:getName():lower()
  if name:find("xbox") or name:find("xone") or name:find("xinput") then
    return "xbox"
  elseif name:find("playstation") or name:find("ps4") or name:find("ps5") or name:find("dualsense") then
    return "playstation"
  elseif name:find("switch") or name:find("joycon") then
    return "switch"
  end
  
  return "generic"
end

-- Get button prompt text
function InputManager:getButtonPrompt(action)
  local controllerType = self:getControllerType()
  
  if controllerType == "keyboard" then
    if action == "move" then return "WASD/Arrows" end
    if action == "action" then return "SPACE" end
    if action == "dash" then return "SHIFT" end
    if action == "hide" then return "E" end
    if action == "pause" then return "ESC" end
  elseif controllerType == "xbox" then
    if action == "move" then return "Left Stick" end
    if action == "action" then return "A" end
    if action == "dash" then return "B" end
    if action == "hide" then return "X" end
    if action == "pause" then return "Start" end
  elseif controllerType == "playstation" then
    if action == "move" then return "Left Stick" end
    if action == "action" then return "✕" end
    if action == "dash" then return "◯" end
    if action == "hide" then return "□" end
    if action == "pause" then return "Options" end
  elseif controllerType == "switch" then
    if action == "move" then return "Left Stick" end
    if action == "action" then return "B" end
    if action == "dash" then return "A" end
    if action == "hide" then return "Y" end
    if action == "pause" then return "+" end
  end
  
  return action:upper()
end

-- Vibration support
function InputManager:vibrate(duration, strength)
  if self.controller and self.controller:isVibrationSupported() then
    self.controller:setVibration(strength or 0.5, strength or 0.5, duration or 0.2)
  end
end

return InputManager
