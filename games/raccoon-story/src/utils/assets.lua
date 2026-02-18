-- Asset Manager
-- Centralized asset loading and management for Raccoon Story

local Assets = {
  images = {},
  sounds = {},
  music = {},
  fonts = {},
  sprites = {}  -- Generated sprites
}

-- Load an image and store it
function Assets:loadImage(name, path)
  local success, result = pcall(function()
    return love.graphics.newImage(path)
  end)
  
  if success then
    self.images[name] = result
    print("Loaded image: " .. name)
    return result
  else
    print("Failed to load image: " .. name .. " - " .. result)
    return nil
  end
end

-- Load a sound effect
function Assets:loadSound(name, path, sourceType)
  sourceType = sourceType or "static"
  
  local success, result = pcall(function()
    return love.audio.newSource(path, sourceType)
  end)
  
  if success then
    self.sounds[name] = result
    print("Loaded sound: " .. name)
    return result
  else
    print("Failed to load sound: " .. name .. " - " .. result)
    return nil
  end
end

-- Load music (streamed for efficiency)
function Assets:loadMusic(name, path)
  return self:loadSound(name, path, "stream")
end

-- Load a font
function Assets:loadFont(name, path, size)
  size = size or 16
  
  local success, result = pcall(function()
    return love.graphics.newFont(path, size)
  end)
  
  if success then
    self.fonts[name] = result
    print("Loaded font: " .. name .. " at size " .. size)
    return result
  else
    print("Failed to load font: " .. name .. " - " .. result)
    return nil
  end
end

-- Get a loaded image
function Assets:getImage(name)
  return self.images[name]
end

-- Get a loaded sound
function Assets:getSound(name)
  return self.sounds[name]
end

-- Get a loaded font
function Assets:getFont(name)
  return self.fonts[name]
end

-- Play a sound effect with optional volume and pitch
function Assets:playSound(name, volume, pitch)
  local sound = self.sounds[name]
  if sound then
    -- Clone the source so multiple instances can play simultaneously
    local instance = sound:clone()
    if volume then instance:setVolume(volume) end
    if pitch then instance:setPitch(pitch) end
    instance:play()
    return instance
  else
    print("Sound not found: " .. name)
  end
end

-- Play music with optional volume
function Assets:playMusic(name, volume, loop)
  local music = self.sounds[name]
  if music then
    if volume then music:setVolume(volume) end
    music:setLooping(loop == nil and true or loop)
    music:play()
    return music
  else
    print("Music not found: " .. name)
  end
end

-- Stop all playing sounds
function Assets:stopAllSounds()
  love.audio.stop()
end

-- Generate sprites programmatically
function Assets:generateSprites()
  local SpriteGenerator = require("src.utils.SpriteGenerator")
  print("[Assets] Generating programmatic sprites...")
  
  self.sprites = SpriteGenerator.generateAll()
  
  print("[Assets] Sprite generation complete!")
end

-- Get a sprite (handles nested paths)
function Assets:getSprite(category, name, subname)
  if subname then
    -- For nested sprites like player.idle or player.walk
    return self.sprites[category] and self.sprites[category][name] and self.sprites[category][name][subname]
  elseif name then
    -- For direct category.name access
    return self.sprites[category] and self.sprites[category][name]
  else
    -- Return the whole category
    return self.sprites[category]
  end
end

-- Get player sprite frames
function Assets:getPlayerSprite(animationType)
  return self.sprites.player and self.sprites.player[animationType]
end

-- Get trash item sprite
function Assets:getTrashSprite(trashType)
  return self.sprites.trash and self.sprites.trash[trashType]
end

-- Get enemy sprite
function Assets:getEnemySprite(enemyType)
  return self.sprites.enemies and self.sprites.enemies[enemyType]
end

-- Get environment sprite
function Assets:getEnvironmentSprite(envType)
  return self.sprites.environment and self.sprites.environment[envType]
end

-- Load all assets (bulk loading)
function Assets:loadAll()
  -- TODO: Load all game assets here
  print("Loading all assets...")
  
  -- Generate programmatic sprites
  self:generateSprites()
  
  -- Example:
  -- self:loadImage("raccoon", "assets/images/raccoon.png")
  -- self:loadSound("pickup", "assets/sounds/pickup.wav")
  -- self:loadMusic("menu_theme", "assets/music/menu_theme.ogg")
  
  print("Asset loading complete!")
end

return Assets
