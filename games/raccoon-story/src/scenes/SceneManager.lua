-- Scene Manager
-- Manages scene transitions and lifecycle
-- Part of Raccoon Story

local SceneManager = {
  current = nil,
  scenes = {},
  transitioning = false
}

-- Register a scene with a name
function SceneManager:register(name, scene)
  self.scenes[name] = scene
  return scene
end

-- Switch to a different scene
function SceneManager:switch(name, ...)
  if self.transitioning then
    return -- Prevent switching during transition
  end
  
  -- Exit current scene
  if self.current and self.current.exit then
    self.current:exit()
  end
  
  -- Switch to new scene
  self.current = self.scenes[name]
  
  if not self.current then
    error("Scene '" .. name .. "' not found!")
  end
  
  -- Enter new scene
  if self.current.enter then
    self.current:enter(...)
  end
end

-- Update current scene
function SceneManager:update(dt)
  if self.current and self.current.update then
    self.current:update(dt)
  end
end

-- Draw current scene
function SceneManager:draw()
  if self.current and self.current.draw then
    self.current:draw()
  end
end

-- Pass keypressed to current scene
function SceneManager:keypressed(key)
  if self.current and self.current.keypressed then
    self.current:keypressed(key)
  end
end

-- Pass keyreleased to current scene
function SceneManager:keyreleased(key)
  if self.current and self.current.keyreleased then
    self.current:keyreleased(key)
  end
end

-- Pass mousepressed to current scene
function SceneManager:mousepressed(x, y, button)
  if self.current and self.current.mousepressed then
    self.current:mousepressed(x, y, button)
  end
end

-- Pass mousereleased to current scene
function SceneManager:mousereleased(x, y, button)
  if self.current and self.current.mousereleased then
    self.current:mousereleased(x, y, button)
  end
end

-- Pass gamepadpressed to current scene
function SceneManager:gamepadpressed(joystick, button)
  if self.current and self.current.gamepadpressed then
    self.current:gamepadpressed(joystick, button)
  end
end

return SceneManager
