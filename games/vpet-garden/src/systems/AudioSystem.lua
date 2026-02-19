-- src/systems/AudioSystem.lua
-- Manages background music and sound effects.
-- Gracefully handles missing audio files via pcall.

local AudioSystem = {}
AudioSystem.__index = AudioSystem

function AudioSystem:new()
  local a = setmetatable({}, self)
  a.music   = {}    -- name → source
  a.sounds  = {}    -- name → source
  a.bgTrack = nil
  a.volume  = 0.5
  return a
end

--- Load a streaming music track (does not start playing).
function AudioSystem:loadMusic(name, path)
  local ok, src = pcall(love.audio.newSource, path, "stream")
  if ok then
    self.music[name] = src
    src:setLooping(true)
    src:setVolume(self.volume)
  else
    print("[AudioSystem] missing music: " .. tostring(path))
  end
end

--- Load a static sound effect.
function AudioSystem:loadSound(name, path)
  local ok, src = pcall(love.audio.newSource, path, "static")
  if ok then
    self.sounds[name] = src
    src:setVolume(self.volume)
  else
    print("[AudioSystem] missing sound: " .. tostring(path))
  end
end

--- Start looping background music track.
function AudioSystem:playMusic(name)
  if self.bgTrack then
    self.bgTrack:stop()
  end
  local src = self.music[name]
  if src then
    src:play()
    self.bgTrack = src
  end
end

--- Stop background music.
function AudioSystem:stopMusic()
  if self.bgTrack then
    self.bgTrack:stop()
    self.bgTrack = nil
  end
end

--- Play a one-shot sound effect.
function AudioSystem:playSound(name)
  local src = self.sounds[name]
  if src then
    if src:isPlaying() then src:stop() end
    src:play()
  end
end

--- Set master volume (0..1).
function AudioSystem:setVolume(v)
  self.volume = v
  for _, src in pairs(self.music)  do src:setVolume(v) end
  for _, src in pairs(self.sounds) do src:setVolume(v) end
end

function AudioSystem:update(dt)
  -- Reserved for future crossfades / dynamic music
end

return AudioSystem
