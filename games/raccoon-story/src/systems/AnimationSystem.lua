-- Animation System
-- Handles frame-based sprite animations with configurable FPS

local AnimationSystem = {}
AnimationSystem.__index = AnimationSystem

function AnimationSystem:new()
  local instance = setmetatable({}, self)
  
  instance.animations = {}
  instance.currentAnimation = nil
  instance.currentFrame = 0
  instance.timer = 0
  instance.playing = true
  instance.looping = true
  instance.onComplete = nil
  
  return instance
end

-- Add an animation to the system
-- @param name: Unique animation name
-- @param frames: Array of canvas/image frames
-- @param fps: Frames per second (default 12)
-- @param loop: Whether to loop the animation (default true)
function AnimationSystem:addAnimation(name, frames, fps, loop)
  if not frames or #frames == 0 then
    print("[AnimationSystem] Warning: No frames provided for animation:", name)
    return false
  end
  
  self.animations[name] = {
    name = name,
    frames = frames,
    fps = fps or 12,
    loop = loop ~= false,
    frameCount = #frames,
    frameTime = 1 / (fps or 12)
  }
  
  print("[AnimationSystem] Added animation:", name, "| Frames:", #frames, "| FPS:", fps or 12, "| Loop:", loop ~= false)
  return true
end

-- Play an animation by name
-- @param name: Animation name to play
-- @param reset: Reset to first frame if already playing (default true)
function AnimationSystem:play(name, reset)
  if reset == nil then reset = true end
  
  if not self.animations[name] then
    print("[AnimationSystem] Warning: Animation not found:", name)
    return false
  end
  
  -- Don't restart if already playing and reset is false
  if self.currentAnimation == name and not reset then
    return true
  end
  
  self.currentAnimation = name
  
  if reset then
    self.currentFrame = 0
    self.timer = 0
  end
  
  self.playing = true
  
  local anim = self.animations[name]
  self.looping = anim.loop
  
  return true
end

-- Stop animation playback
function AnimationSystem:stop()
  self.playing = false
end

-- Pause animation
function AnimationSystem:pause()
  self.playing = false
end

-- Resume animation
function AnimationSystem:resume()
  self.playing = true
end

-- Reset current animation to first frame
function AnimationSystem:reset()
  self.currentFrame = 0
  self.timer = 0
end

-- Update animation based on delta time
function AnimationSystem:update(dt)
  if not self.playing or not self.currentAnimation then
    return
  end
  
  local anim = self.animations[self.currentAnimation]
  if not anim then return end
  
  self.timer = self.timer + dt
  
  -- Calculate current frame based on accumulated time
  local previousFrame = self.currentFrame
  self.currentFrame = math.floor(self.timer / anim.frameTime)
  
  -- Handle animation end
  if self.currentFrame >= anim.frameCount then
    if anim.loop then
      -- Loop back to start
      self.currentFrame = 0
      self.timer = 0
    else
      -- Stay on last frame
      self.currentFrame = anim.frameCount - 1
      self.playing = false
      
      if self.onComplete then
        self.onComplete(self.currentAnimation)
        self.onComplete = nil
      end
    end
  end
end

-- Get current frame canvas/image
function AnimationSystem:getCurrentFrame()
  if not self.currentAnimation then return nil end
  
  local anim = self.animations[self.currentAnimation]
  if not anim then return nil end
  
  -- Lua arrays are 1-indexed
  return anim.frames[self.currentFrame + 1]
end

-- Get current frame index (0-based)
function AnimationSystem:getCurrentFrameIndex()
  return self.currentFrame
end

-- Draw current frame at specified position with optional transforms
-- @param x, y: Position
-- @param r: Rotation (radians)
-- @param sx, sy: Scale factors
-- @param ox, oy: Origin offsets
function AnimationSystem:draw(x, y, r, sx, sy, ox, oy)
  local frame = self:getCurrentFrame()
  
  if frame then
    love.graphics.draw(frame, x, y, r or 0, sx or 1, sy or 1, ox or 0, oy or 0)
  end
end

-- Set callback for when non-looping animation completes
function AnimationSystem:setOnComplete(callback)
  self.onComplete = callback
end

-- Check if animation is playing
function AnimationSystem:isPlaying()
  return self.playing
end

-- Get current animation name
function AnimationSystem:getCurrentAnimation()
  return self.currentAnimation
end

-- Check if a specific animation exists
function AnimationSystem:hasAnimation(name)
  return self.animations[name] ~= nil
end

return AnimationSystem
