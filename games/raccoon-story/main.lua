-- Raccoon Story
-- A cozy top-down game about a raccoon collecting trash for their family
-- Main game entry point

-- Load local references for better performance
local lg = love.graphics
local lt = love.timer

-- Load scene manager and scenes
local SceneManager = require("src.scenes.SceneManager")
local MenuScene = require("src.scenes.MenuScene")
local GameScene = require("src.scenes.GameScene")

-- Game state
local game = {
  title = "Raccoon Story",
  version = "0.1.0",
  state = "running"
}

-- Development mode flag
local DEV_MODE = true

function love.load()
  -- Set up window
  lg.setDefaultFilter("nearest", "nearest") -- Pixel-perfect rendering
  
  -- Seed random number generator
  math.randomseed(os.time())
  
  -- Register scenes
  SceneManager:register("menu", MenuScene)
  SceneManager:register("game", GameScene)
  
  print("=== Raccoon Story ===")
  print("Version: " .. game.version)
  print("Press SPACE in menu to start game")
  print("Press ESC to open menus")
  print("=====================")
  
  -- Start with menu scene
  SceneManager:switch("menu")
end

function love.update(dt)
  -- Update scene manager
  SceneManager:update(dt)
end

function love.draw()
  -- Draw current scene
  SceneManager:draw()
  
  -- Show FPS in dev mode
  if DEV_MODE then
    lg.setColor(0, 1, 0, 0.8)
    lg.print("FPS: " .. love.timer.getFPS(), lg.getWidth() - 70, 10)
    lg.setColor(1, 1, 1)
  end
end

function love.keypressed(key)
  -- Pass to scene manager (scenes handle their own ESC logic now)
  SceneManager:keypressed(key)
end

function love.keyreleased(key)
  -- Pass to scene manager
  SceneManager:keyreleased(key)
end

function love.mousepressed(x, y, button)
  -- Pass to scene manager
  SceneManager:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  -- Pass to scene manager
  SceneManager:mousereleased(x, y, button)
end

function love.gamepadpressed(joystick, button)
  -- Pass to scene manager
  SceneManager:gamepadpressed(joystick, button)
end

-- Error handler
function love.errorhandler(msg)
  print("ERROR: " .. msg)
  print(debug.traceback())
  
  -- Show error screen
  if not love.graphics or not love.graphics.isCreated() then
    return
  end
  
  love.graphics.reset()
  love.graphics.setBackgroundColor(89, 0, 0)
  
  local errorDraw = function()
    lg.clear(89/255, 0, 0)
    lg.setColor(1, 1, 1)
    lg.printf("Error:\n" .. msg, 20, 20, lg.getWidth() - 40)
    lg.printf("Press ESC to quit", 0, lg.getHeight() - 40, lg.getWidth(), "center")
  end
  
  return function()
    love.event.pump()
    
    for e, a in love.event.poll() do
      if e == "quit" then
        return 1
      elseif e == "keypressed" and a == "escape" then
        return 1
      end
    end
    
    errorDraw()
    love.graphics.present()
    love.timer.sleep(0.1)
  end
end
