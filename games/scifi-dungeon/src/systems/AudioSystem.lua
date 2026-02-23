-- AudioSystem.lua
-- Basic audio management for scifi-dungeon Phase 2
-- Handles music playback, sound effects, and volume controls

local AudioSystem = {
  -- Volume settings
  masterVolume = 1.0,
  musicVolume = 0.7,
  sfxVolume = 0.8,
  
  -- Audio sources
  musicTracks = {},      -- Loaded music tracks (streaming)
  sfxSounds = {},        -- Loaded sound effects (static)
  
  -- Playback state
  currentMusic = nil,    -- Currently playing music source
  currentMusicId = nil,  -- ID of current music track
  musicFade = nil,       -- Fade transition state
  
  -- SFX management
  activeSFX = {},        -- Currently playing SFX sources
  maxSFX = 16,           -- Max simultaneous sound effects
  
  -- Asset paths
  musicPaths = {},       -- trackId -> file path
  sfxPaths = {},         -- soundId -> file path
  
  -- State
  initialized = false
}

--- Initialize the audio system
function AudioSystem:init()
  if self.initialized then
    return
  end
  
  print("[AudioSystem] Initializing...")
  
  -- Preload Phase 2 audio assets
  self:preloadMusic("menu_theme", "assets/music/menu_theme.ogg")
  self:preloadMusic("d1_sprawl", "assets/music/d1_sprawl.ogg")
  
  self:preloadSFX("step_metal", "assets/sounds/step_metal.wav")
  self:preloadSFX("step_grate", "assets/sounds/step_grate.wav")
  self:preloadSFX("door_open", "assets/sounds/door_open.wav")
  self:preloadSFX("door_locked", "assets/sounds/door_locked.wav")
  
  self.initialized = true
  print("[AudioSystem] Ready (Phase 2 - placeholder audio)")
end

--- Preload a music track
-- @param trackId Unique identifier for the track
-- @param path File path relative to game root
function AudioSystem:preloadMusic(trackId, path)
  self.musicPaths[trackId] = path
  
  -- Try to load the music file
  local success, source = pcall(function()
    return love.audio.newSource(path, "stream")
  end)
  
  if success then
    source:setLooping(true)
    self.musicTracks[trackId] = source
    print("[AudioSystem] Loaded music:", trackId)
  else
    print("[AudioSystem] WARNING: Music file not found:", path, "- running without audio")
    self.musicTracks[trackId] = nil
  end
end

--- Preload a sound effect
-- @param soundId Unique identifier for the sound
-- @param path File path relative to game root
function AudioSystem:preloadSFX(soundId, path)
  self.sfxPaths[soundId] = path
  
  -- Try to load the sound file
  local success, source = pcall(function()
    return love.audio.newSource(path, "static")
  end)
  
  if success then
    self.sfxSounds[soundId] = source
    print("[AudioSystem] Loaded SFX:", soundId)
  else
    print("[AudioSystem] WARNING: SFX file not found:", path, "- running without audio")
    self.sfxSounds[soundId] = nil
  end
end

--- Play or crossfade to a music track
-- @param trackId Music track identifier
-- @param fadeTime Crossfade duration in seconds (default: 0.5)
function AudioSystem:playMusic(trackId, fadeTime)
  fadeTime = fadeTime or 0.5
  
  -- If same track is playing, do nothing
  if self.currentMusicId == trackId and self.currentMusic and self.currentMusic:isPlaying() then
    return
  end
  
  local newTrack = self.musicTracks[trackId]
  
  -- If track doesn't exist, quietly fail
  if not newTrack then
    print("[AudioSystem] Music track not loaded:", trackId)
    return
  end
  
  -- If there's current music, crossfade
  if self.currentMusic and self.currentMusic:isPlaying() then
    self:crossfadeMusic(newTrack, trackId, fadeTime)
  else
    -- Start new track with fade in
    self:startMusic(newTrack, trackId, fadeTime)
  end
end

--- Start a new music track with fade in
function AudioSystem:startMusic(source, trackId, fadeTime)
  self.currentMusic = source
  self.currentMusicId = trackId
  
  source:setVolume(0)
  source:play()
  
  -- Setup fade in
  if fadeTime > 0 then
    self.musicFade = {
      source = source,
      startVolume = 0,
      targetVolume = self.musicVolume * self.masterVolume,
      duration = fadeTime,
      elapsed = 0,
      fadeOut = nil
    }
  else
    source:setVolume(self.musicVolume * self.masterVolume)
  end
  
  print("[AudioSystem] Playing music:", trackId)
end

--- Crossfade from current music to new track
function AudioSystem:crossfadeMusic(newSource, trackId, fadeTime)
  local oldSource = self.currentMusic
  
  -- Start new track at 0 volume
  newSource:setVolume(0)
  newSource:play()
  
  -- Setup crossfade
  self.musicFade = {
    source = newSource,
    startVolume = 0,
    targetVolume = self.musicVolume * self.masterVolume,
    duration = fadeTime,
    elapsed = 0,
    fadeOut = {
      source = oldSource,
      startVolume = oldSource:getVolume(),
      targetVolume = 0
    }
  }
  
  self.currentMusic = newSource
  self.currentMusicId = trackId
  
  print("[AudioSystem] Crossfading to:", trackId)
end

--- Stop current music with fade out
-- @param fadeTime Fade out duration in seconds (default: 0.5)
function AudioSystem:stopMusic(fadeTime)
  if not self.currentMusic or not self.currentMusic:isPlaying() then
    return
  end
  
  fadeTime = fadeTime or 0.5
  
  if fadeTime > 0 then
    self.musicFade = {
      source = nil,
      startVolume = 0,
      targetVolume = 0,
      duration = fadeTime,
      elapsed = 0,
      fadeOut = {
        source = self.currentMusic,
        startVolume = self.currentMusic:getVolume(),
        targetVolume = 0
      }
    }
  else
    self.currentMusic:stop()
    self.currentMusic = nil
    self.currentMusicId = nil
  end
  
  print("[AudioSystem] Stopping music")
end

--- Play a sound effect
-- @param soundId Sound effect identifier
-- @param volume Volume multiplier (0.0-1.0, optional)
-- @param pitch Pitch multiplier (0.5-2.0, optional)
function AudioSystem:playSFX(soundId, volume, pitch)
  local source = self.sfxSounds[soundId]
  
  -- If sound doesn't exist, quietly fail
  if not source then
    return
  end
  
  -- Check if we're at max SFX limit
  self:cleanupSFX()
  if #self.activeSFX >= self.maxSFX then
    -- Stop oldest sound to make room
    table.remove(self.activeSFX, 1):stop()
  end
  
  -- Clone the source to allow simultaneous playback
  local playSource = source:clone()
  
  -- Set volume and pitch
  volume = volume or 1.0
  pitch = pitch or 1.0
  playSource:setVolume(volume * self.sfxVolume * self.masterVolume)
  playSource:setPitch(pitch)
  
  -- Play and track
  playSource:play()
  table.insert(self.activeSFX, playSource)
end

--- Remove finished sound effects from active list
function AudioSystem:cleanupSFX()
  local i = 1
  while i <= #self.activeSFX do
    if not self.activeSFX[i]:isPlaying() then
      table.remove(self.activeSFX, i)
    else
      i = i + 1
    end
  end
end

--- Update audio system (call in love.update)
function AudioSystem:update(dt)
  -- Update music fade
  if self.musicFade then
    self.musicFade.elapsed = self.musicFade.elapsed + dt
    local progress = math.min(1, self.musicFade.elapsed / self.musicFade.duration)
    
    -- Fade in new track
    if self.musicFade.source then
      local volume = self.musicFade.startVolume + 
                     (self.musicFade.targetVolume - self.musicFade.startVolume) * progress
      self.musicFade.source:setVolume(volume)
    end
    
    -- Fade out old track
    if self.musicFade.fadeOut then
      local volume = self.musicFade.fadeOut.startVolume + 
                     (self.musicFade.fadeOut.targetVolume - self.musicFade.fadeOut.startVolume) * progress
      self.musicFade.fadeOut.source:setVolume(volume)
      
      if progress >= 1 then
        self.musicFade.fadeOut.source:stop()
      end
    end
    
    -- Clear fade when complete
    if progress >= 1 then
      self.musicFade = nil
    end
  end
  
  -- Cleanup finished sound effects periodically
  if love.timer.getTime() % 1 < dt then
    self:cleanupSFX()
  end
end

--- Set master volume
-- @param volume Volume level (0.0-1.0)
function AudioSystem:setMasterVolume(volume)
  self.masterVolume = math.max(0, math.min(1, volume))
  self:updateAllVolumes()
  print("[AudioSystem] Master volume:", self.masterVolume)
end

--- Set music volume
-- @param volume Volume level (0.0-1.0)
function AudioSystem:setMusicVolume(volume)
  self.musicVolume = math.max(0, math.min(1, volume))
  if self.currentMusic then
    self.currentMusic:setVolume(self.musicVolume * self.masterVolume)
  end
  print("[AudioSystem] Music volume:", self.musicVolume)
end

--- Set sound effects volume
-- @param volume Volume level (0.0-1.0)
function AudioSystem:setSFXVolume(volume)
  self.sfxVolume = math.max(0, math.min(1, volume))
  print("[AudioSystem] SFX volume:", self.sfxVolume)
end

--- Update all playing audio volumes
function AudioSystem:updateAllVolumes()
  -- Update current music
  if self.currentMusic then
    self.currentMusic:setVolume(self.musicVolume * self.masterVolume)
  end
  
  -- Update active SFX
  for _, source in ipairs(self.activeSFX) do
    if source:isPlaying() then
      -- Can't get original volume, so set to current settings
      source:setVolume(self.sfxVolume * self.masterVolume)
    end
  end
end

--- Get master volume
function AudioSystem:getMasterVolume()
  return self.masterVolume
end

--- Get music volume
function AudioSystem:getMusicVolume()
  return self.musicVolume
end

--- Get SFX volume
function AudioSystem:getSFXVolume()
  return self.sfxVolume
end

--- Pause all audio
function AudioSystem:pauseAll()
  if self.currentMusic then
    self.currentMusic:pause()
  end
  
  for _, source in ipairs(self.activeSFX) do
    source:pause()
  end
end

--- Resume all audio
function AudioSystem:resumeAll()
  if self.currentMusic then
    self.currentMusic:play()
  end
  
  for _, source in ipairs(self.activeSFX) do
    source:play()
  end
end

--- Stop all audio
function AudioSystem:stopAll()
  if self.currentMusic then
    self.currentMusic:stop()
  end
  
  for _, source in ipairs(self.activeSFX) do
    source:stop()
  end
  
  self.activeSFX = {}
  self.currentMusic = nil
  self.currentMusicId = nil
  self.musicFade = nil
end

--- Clean up audio resources
function AudioSystem:cleanup()
  print("[AudioSystem] Cleaning up...")
  
  self:stopAll()
  
  -- Release all sources
  for _, source in pairs(self.musicTracks) do
    source:release()
  end
  
  for _, source in pairs(self.sfxSounds) do
    source:release()
  end
  
  self.musicTracks = {}
  self.sfxSounds = {}
  self.initialized = false
end

return AudioSystem
