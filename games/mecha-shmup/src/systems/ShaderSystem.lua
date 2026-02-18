-- ShaderSystem.lua
-- Manages visual shaders for Mecha Shmup

local ShaderSystem = {}
ShaderSystem.__index = ShaderSystem

function ShaderSystem:new()
  local instance = setmetatable({}, self)
  
  -- Load shaders
  instance.crtShader = nil
  instance.explosionShader = nil
  instance.canvas = nil
  
  -- Shader settings
  instance.crtEnabled = true
  instance.crtIntensity = 0.7
  
  -- Explosion tracking
  instance.explosions = {}
  instance.maxExplosions = 10
  
  -- Try to load shaders
  local success, err = pcall(function()
    instance.crtShader = love.graphics.newShader("src/shaders/crt.glsl")
    instance.explosionShader = love.graphics.newShader("src/shaders/explosion.glsl")
  end)
  
  if not success then
    print("Warning: Could not load shaders:", err)
  end
  
  -- Create canvas for post-processing
  instance.canvas = love.graphics.newCanvas(640, 720)
  
  return instance
end

function ShaderSystem:update(dt)
  -- Update explosion effects
  for i = #self.explosions, 1, -1 do
    self.explosions[i].time = self.explosions[i].time - dt
    if self.explosions[i].time <= 0 then
      table.remove(self.explosions, i)
    end
  end
end

function ShaderSystem:addExplosion(x, y, size)
  -- Add new explosion effect
  if #self.explosions < self.maxExplosions then
    table.insert(self.explosions, {
      x = x,
      y = y,
      size = size or 1.0,
      time = 0.4  -- Duration
    })
  end
end

function ShaderSystem:beginDraw()
  -- Start drawing to canvas
  love.graphics.setCanvas(self.canvas)
  love.graphics.clear()
end

function ShaderSystem:endDraw()
  -- Finish drawing to canvas
  love.graphics.setCanvas()
  
  -- Apply shaders and draw to screen
  love.graphics.push()
  love.graphics.origin()
  
  -- Apply explosion shader
  if self.explosionShader and #self.explosions > 0 then
    love.graphics.setShader(self.explosionShader)
    
    -- Set explosion uniform data
    local positions = {}
    local times = {}
    local sizes = {}
    
    for i = 1, self.maxExplosions do
      if i <= #self.explosions then
        positions[i] = {self.explosions[i].x, self.explosions[i].y}
        times[i] = self.explosions[i].time
        sizes[i] = self.explosions[i].size
      else
        positions[i] = {0, 0}
        times[i] = 0
        sizes[i] = 1
      end
    end
    
    self.explosionShader:send("screenSize", {640, 720})
    self.explosionShader:send("time", love.timer.getTime())
    self.explosionShader:send("explosionPos", unpack(positions))
    self.explosionShader:send("explosionTime", unpack(times))
    self.explosionShader:send("explosionSize", unpack(sizes))
    self.explosionShader:send("explosionCount", #self.explosions)
  end
  
  -- Apply CRT shader
  if self.crtEnabled and self.crtShader then
    love.graphics.setShader(self.crtShader)
    self.crtShader:send("screenSize", {640, 720})
    self.crtShader:send("time", love.timer.getTime())
    self.crtShader:send("intensity", self.crtIntensity)
  end
  
  -- Draw canvas to screen
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.canvas, 0, 0)
  
  -- Reset shader
  love.graphics.setShader()
  love.graphics.pop()
end

function ShaderSystem:toggleCRT()
  self.crtEnabled = not self.crtEnabled
end

function ShaderSystem:setCRTIntensity(intensity)
  self.crtIntensity = math.max(0, math.min(1, intensity))
end

return ShaderSystem
