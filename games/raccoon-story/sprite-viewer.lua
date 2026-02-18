-- Visual Sprite Viewer
-- Shows all generated sprites on screen for verification
-- Usage: Run this file directly with Love2D

local SpriteGenerator = require("src.utils.SpriteGenerator")

local sprites = {}
local showLabels = true

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setTitle("Raccoon Story - Sprite Viewer")
  
  print("Generating all sprites...")
  sprites = SpriteGenerator.generateAll()
  print("Sprite generation complete!")
end

function love.draw()
  local lg = love.graphics
  lg.clear(0.15, 0.15, 0.2) -- Dark background
  
  local x, y = 20, 20
  local spacing = 60
  
  -- Title
  lg.setColor(1, 1, 1)
  lg.print("Raccoon Story - Sprite Viewer", 20, 20, 0, 2)
  lg.print("Press L to toggle labels, ESC to quit", 20, 50, 0, 1)
  
  y = 100
  
  -- Player Sprites
  lg.setColor(1, 1, 0.5)
  lg.print("PLAYER RACCOON", x, y, 0, 1.5)
  y = y + 30
  
  lg.setColor(1, 1, 1)
  lg.print("Idle Animation:", x, y)
  y = y + 20
  for i, frame in ipairs(sprites.player.idle) do
    lg.draw(frame, x + (i - 1) * spacing, y, 0, 1.5)
    if showLabels then
      lg.print(i, x + (i - 1) * spacing + 10, y + 50, 0, 0.8)
    end
  end
  y = y + 80
  
  lg.print("Walk Animation:", x, y)
  y = y + 20
  for i, frame in ipairs(sprites.player.walk) do
    lg.draw(frame, x + (i - 1) * spacing, y, 0, 1.5)
    if showLabels then
      lg.print(i, x + (i - 1) * spacing + 10, y + 50, 0, 0.8)
    end
  end
  y = y + 100
  
  -- Trash Items
  lg.setColor(1, 1, 0.5)
  lg.print("TRASH ITEMS", x, y, 0, 1.5)
  y = y + 30
  
  local trashX = x
  for name, sprite in pairs(sprites.trash) do
    lg.setColor(1, 1, 1)
    lg.draw(sprite, trashX, y, 0, 2)
    if showLabels then
      lg.print(name, trashX, y + 35, 0, 0.8)
    end
    trashX = trashX + spacing
  end
  y = y + 80
  
  -- Enemies
  lg.setColor(1, 1, 0.5)
  lg.print("ENEMIES", x, y, 0, 1.5)
  y = y + 30
  
  lg.setColor(1, 1, 1)
  lg.draw(sprites.enemies.human, x, y, 0, 1.5)
  if showLabels then
    lg.print("Human", x, y + 75, 0, 0.8)
  end
  
  lg.draw(sprites.enemies.dog, x + 80, y, 0, 1.5)
  if showLabels then
    lg.print("Dog", x + 80, y + 55, 0, 0.8)
  end
  
  y = y + 100
  
  -- Environment
  lg.setColor(1, 1, 0.5)
  lg.print("ENVIRONMENT", x, y, 0, 1.5)
  y = y + 30
  
  lg.setColor(1, 1, 1)
  lg.draw(sprites.environment.bush, x, y, 0, 1.5)
  if showLabels then
    lg.print("Bush", x + 20, y + 75, 0, 0.8)
  end
  
  lg.draw(sprites.environment.trashBin, x + 100, y, 0, 1.5)
  if showLabels then
    lg.print("Trash Bin", x + 100, y + 75, 0, 0.8)
  end
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  elseif key == "l" then
    showLabels = not showLabels
  end
end
