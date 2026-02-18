-- SceneManager.lua
-- Manages scene transitions and lifecycle for Mecha Shmup

local SceneManager = {
  current = nil,
  scenes = {},
  nextScene = nil,
  transitioning = false,
  transitionTime = 0,
  transitionDuration = 0.3,
  fadeAlpha = 0
}

-- Register a scene with a name
function SceneManager:register(name, scene)
  self.scenes[name] = scene
  print("Scene registered: " .. name)
end

-- Switch to a new scene
function SceneManager:switch(name, ...)
  if not self.scenes[name] then
    error("Scene not found: " .. name)
  end
  
  -- Store parameters for next scene
  self.nextScene = name
  self.nextSceneParams = {...}
  
  -- Start transition
  self.transitioning = true
  self.transitionTime = 0
  self.fadeAlpha = 0
end

-- Update current scene and handle transitions
function SceneManager:update(dt)
  -- Handle transition fade
  if self.transitioning then
    self.transitionTime = self.transitionTime + dt
    
    -- Fade out
    if self.transitionTime < self.transitionDuration / 2 then
      self.fadeAlpha = (self.transitionTime / (self.transitionDuration / 2))
    else
      -- Switch scene at halfway point
      if self.nextScene then
        -- Exit current scene
        if self.current and self.current.exit then
          self.current:exit()
        end
        
        -- Switch to new scene
        self.current = self.scenes[self.nextScene]
        
        -- Enter new scene
        if self.current and self.current.enter then
          self.current:enter(unpack(self.nextSceneParams or {}))
        end
        
        self.nextScene = nil
        self.nextSceneParams = nil
      end
      
      -- Fade in
      local fadeInTime = self.transitionTime - (self.transitionDuration / 2)
      self.fadeAlpha = 1 - (fadeInTime / (self.transitionDuration / 2))
    end
    
    -- End transition
    if self.transitionTime >= self.transitionDuration then
      self.transitioning = false
      self.fadeAlpha = 0
    end
  end
  
  -- Update current scene
  if self.current and self.current.update and not self.transitioning then
    self.current:update(dt)
  end
end

-- Draw current scene and transition overlay
function SceneManager:draw()
  -- Draw current scene
  if self.current and self.current.draw then
    self.current:draw()
  end
  
  -- Draw transition fade overlay
  if self.transitioning and self.fadeAlpha > 0 then
    love.graphics.setColor(0, 0, 0, self.fadeAlpha)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
  end
end

-- Forward keypressed to current scene
function SceneManager:keypressed(key)
  if self.current and self.current.keypressed and not self.transitioning then
    self.current:keypressed(key)
  end
end

-- Forward mousepressed to current scene
function SceneManager:mousepressed(x, y, button)
  if self.current and self.current.mousepressed and not self.transitioning then
    self.current:mousepressed(x, y, button)
  end
end

return SceneManager
