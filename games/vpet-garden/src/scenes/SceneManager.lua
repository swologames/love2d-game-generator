-- src/scenes/SceneManager.lua
-- Central scene registry and lifecycle controller.

local SceneManager = {
  current = nil,
  scenes  = {},
}

--- Register a scene table under a string name.
function SceneManager:register(name, scene)
  self.scenes[name] = scene
end

--- Switch to a named scene, calling exit() on the old and enter() on the new.
function SceneManager:switch(name, ...)
  if self.current and self.current.exit then
    self.current:exit()
  end
  self.current = self.scenes[name]
  assert(self.current, "[SceneManager] unknown scene: " .. tostring(name))
  if self.current.enter then
    self.current:enter(...)
  end
end

function SceneManager:update(dt)
  if self.current and self.current.update then
    self.current:update(dt)
  end
end

function SceneManager:draw()
  if self.current and self.current.draw then
    self.current:draw()
  end
end

function SceneManager:keypressed(key)
  if self.current and self.current.keypressed then
    self.current:keypressed(key)
  end
end

function SceneManager:mousepressed(x, y, button)
  if self.current and self.current.mousepressed then
    self.current:mousepressed(x, y, button)
  end
end

function SceneManager:mousereleased(x, y, button)
  if self.current and self.current.mousereleased then
    self.current:mousereleased(x, y, button)
  end
end

function SceneManager:mousemoved(x, y, dx, dy)
  if self.current and self.current.mousemoved then
    self.current:mousemoved(x, y, dx, dy)
  end
end

return SceneManager
