-- AudioSystem.lua
-- Centralized audio management for music and sound effects

local AudioSystem = {
  music = {},
  sounds = {},
  currentMusic = nil,
  nextMusic = nil,
  musicVolume = 0.7,
  sfxVolume = 0.8,
  fadeState = "none",  -- "none", "out", "in", "crossfade"
  fadeTimer = 0,
  fadeDuration = 1.0,
  fadeOutMusic = nil
}

-- Safely load an audio source; logs a warning and returns nil on failure.
local function tryLoad(path, sourceType)
  local ok, result = pcall(love.audio.newSource, path, sourceType)
  if ok then
    return result
  else
    print("[AudioSystem] WARNING: could not load '" .. path .. "': " .. tostring(result))
    return nil
  end
end

-- Initialize audio system
function AudioSystem:init()
  -- Load all music (missing files are skipped with a log)
  self.music.menu       = tryLoad("assets/music/menu.wav",       "stream")
  self.music.level1     = tryLoad("assets/music/level1.wav",     "stream")
  self.music.level2     = tryLoad("assets/music/level2.wav",     "stream")
  self.music.boss_fight = tryLoad("assets/music/boss_fight.wav", "stream")

  -- Set all successfully loaded tracks to loop
  for _, music in pairs(self.music) do
    if music then music:setLooping(true) end
  end

  -- Load all sound effects (missing files are skipped with a log)
  self.sounds.click_long  = tryLoad("assets/sounds/click_long.wav",  "static")
  self.sounds.click_short = tryLoad("assets/sounds/click_short.wav", "static")
  self.sounds.game_over   = tryLoad("assets/sounds/game_over.wav",   "static")
  self.sounds.start_chime = tryLoad("assets/sounds/start_chime.wav", "static")

  -- Apply initial volumes
  self:updateVolumes()

  print("[AudioSystem] Initialized")
end

-- Update audio system (handles fading)
function AudioSystem:update(dt)
  if self.fadeState == "none" then return end
  
  self.fadeTimer = self.fadeTimer + dt
  local progress = math.min(1, self.fadeTimer / self.fadeDuration)
  
  if self.fadeState == "out" then
    -- Fade out current music
    if self.currentMusic then
      self.currentMusic:setVolume(self.musicVolume * (1 - progress))
      
      if progress >= 1 then
        self.currentMusic:stop()
        self.currentMusic = nil
        self.fadeState = "none"
      end
    end
    
  elseif self.fadeState == "in" then
    -- Fade in new music
    if self.currentMusic then
      self.currentMusic:setVolume(self.musicVolume * progress)
      
      if progress >= 1 then
        self.fadeState = "none"
      end
    end
    
  elseif self.fadeState == "crossfade" then
    -- Crossfade between two tracks
    if self.fadeOutMusic then
      self.fadeOutMusic:setVolume(self.musicVolume * (1 - progress))
    end
    
    if self.currentMusic then
      self.currentMusic:setVolume(self.musicVolume * progress)
    end
    
    if progress >= 1 then
      if self.fadeOutMusic then
        self.fadeOutMusic:stop()
        self.fadeOutMusic = nil
      end
      self.fadeState = "none"
    end
  end
end

-- Play music with optional fade
function AudioSystem:playMusic(musicName, fadeIn, fadeDuration)
  fadeDuration = fadeDuration or self.fadeDuration
  
  local newMusic = self.music[musicName]
  if not newMusic then
    print("Warning: Music '" .. musicName .. "' not found")
    return
  end
  
  -- If already playing this track, do nothing
  if self.currentMusic == newMusic and self.currentMusic:isPlaying() then
    return
  end
  
  -- Handle existing music
  if self.currentMusic and self.currentMusic:isPlaying() then
    if fadeIn then
      -- Crossfade to new track
      self.fadeOutMusic = self.currentMusic
      self.currentMusic = newMusic
      self.currentMusic:setVolume(0)
      self.currentMusic:play()
      
      self.fadeState = "crossfade"
      self.fadeTimer = 0
      self.fadeDuration = fadeDuration
    else
      -- Stop current, play new
      self.currentMusic:stop()
      self.currentMusic = newMusic
      self.currentMusic:setVolume(self.musicVolume)
      self.currentMusic:play()
    end
  else
    -- No current music, just play new
    self.currentMusic = newMusic
    
    if fadeIn then
      self.currentMusic:setVolume(0)
      self.currentMusic:play()
      self.fadeState = "in"
      self.fadeTimer = 0
      self.fadeDuration = fadeDuration
    else
      self.currentMusic:setVolume(self.musicVolume)
      self.currentMusic:play()
    end
  end
end

-- Stop current music with optional fade
function AudioSystem:stopMusic(fadeOut, fadeDuration)
  if not self.currentMusic then return end
  
  fadeDuration = fadeDuration or self.fadeDuration
  
  if fadeOut then
    self.fadeState = "out"
    self.fadeTimer = 0
    self.fadeDuration = fadeDuration
  else
    self.currentMusic:stop()
    self.currentMusic = nil
  end
end

-- Pause current music
function AudioSystem:pauseMusic()
  if self.currentMusic and self.currentMusic:isPlaying() then
    self.currentMusic:pause()
  end
end

-- Resume current music
function AudioSystem:resumeMusic()
  if self.currentMusic and not self.currentMusic:isPlaying() then
    self.currentMusic:play()
  end
end

-- Play a sound effect
function AudioSystem:playSound(soundName, volume)
  local sound = self.sounds[soundName]
  if not sound then
    print("Warning: Sound '" .. soundName .. "' not found")
    return
  end
  
  -- Clone the source to allow multiple simultaneous plays
  local instance = sound:clone()
  instance:setVolume((volume or 1.0) * self.sfxVolume)
  instance:play()
end

-- Set music volume (0.0 to 1.0)
function AudioSystem:setMusicVolume(volume)
  self.musicVolume = math.max(0, math.min(1, volume))
  self:updateVolumes()
end

-- Set sound effects volume (0.0 to 1.0)
function AudioSystem:setSFXVolume(volume)
  self.sfxVolume = math.max(0, math.min(1, volume))
end

-- Get current music volume
function AudioSystem:getMusicVolume()
  return self.musicVolume
end

-- Get current SFX volume
function AudioSystem:getSFXVolume()
  return self.sfxVolume
end

-- Update volumes for all playing sources
function AudioSystem:updateVolumes()
  if self.currentMusic and self.fadeState == "none" then
    self.currentMusic:setVolume(self.musicVolume)
  end
end

-- Check if music is playing
function AudioSystem:isMusicPlaying()
  return self.currentMusic and self.currentMusic:isPlaying()
end

-- Get current music name
function AudioSystem:getCurrentMusicName()
  if not self.currentMusic then return nil end
  
  for name, music in pairs(self.music) do
    if music == self.currentMusic then
      return name
    end
  end
  
  return nil
end

return AudioSystem
