-- utils/assets.lua
-- Centralised asset loader with in-memory caching.
-- Gracefully skips missing files (returns nil).

local assets = {
  _images = {},
  _sounds = {},
  _music  = {},
  _fonts  = {},
}

-- ── Images ──────────────────────────────────────────────────────────────────
function assets.loadImage(name, path)
  if assets._images[name] then return assets._images[name] end
  local ok, result = pcall(love.graphics.newImage, path)
  if ok then
    assets._images[name] = result
  else
    print("[assets] missing image: " .. path)
    assets._images[name] = nil
  end
  return assets._images[name]
end

function assets.image(name)
  return assets._images[name]
end

-- ── Sounds (static) ─────────────────────────────────────────────────────────
function assets.loadSound(name, path)
  if assets._sounds[name] then return assets._sounds[name] end
  local ok, result = pcall(love.audio.newSource, path, "static")
  if ok then
    assets._sounds[name] = result
  else
    print("[assets] missing sound: " .. path)
    assets._sounds[name] = nil
  end
  return assets._sounds[name]
end

function assets.sound(name)
  return assets._sounds[name]
end

-- ── Music (streaming) ────────────────────────────────────────────────────────
function assets.loadMusic(name, path)
  if assets._music[name] then return assets._music[name] end
  local ok, result = pcall(love.audio.newSource, path, "stream")
  if ok then
    assets._music[name] = result
  else
    print("[assets] missing music: " .. path)
    assets._music[name] = nil
  end
  return assets._music[name]
end

function assets.music(name)
  return assets._music[name]
end

-- ── Fonts ─────────────────────────────────────────────────────────────────────
function assets.loadFont(name, path, size)
  local key = name .. "_" .. tostring(size)
  if assets._fonts[key] then return assets._fonts[key] end
  local ok, result
  if path then
    ok, result = pcall(love.graphics.newFont, path, size)
  else
    ok, result = true, love.graphics.newFont(size or 14)
  end
  if ok then
    assets._fonts[key] = result
  else
    print("[assets] missing font: " .. tostring(path))
    assets._fonts[key] = love.graphics.newFont(size or 14)
  end
  return assets._fonts[key]
end

function assets.font(name, size)
  local key = name .. "_" .. tostring(size)
  return assets._fonts[key]
end

return assets
