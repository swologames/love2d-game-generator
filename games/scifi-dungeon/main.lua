-- Scifi Dungeon — main.lua
-- Entry point for the game.
-- Delegates all logic to the SceneManager.

local SceneManager = require("src.scenes.SceneManager")

-- ─── Love2D Callbacks ────────────────────────────────────────────────────────

function love.load()
  -- Seed the random number generator
  math.randomseed(os.time())

  -- Set the default filter for crisp pixel art rendering
  love.graphics.setDefaultFilter("nearest", "nearest")

  -- Initialise the scene manager and boot into the placeholder scene
  SceneManager:init()
  SceneManager:switch("menu")
end

function love.update(dt)
  SceneManager:update(dt)
end

function love.draw()
  SceneManager:draw()
end

-- ─── Input Forwarding ────────────────────────────────────────────────────────

function love.keypressed(key, scancode, isrepeat)
  -- Global quit shortcut (remove for release builds)
  if key == "f4" and love.keyboard.isDown("lalt") then
    love.event.quit()
    return
  end
  SceneManager:keypressed(key, scancode, isrepeat)
end

function love.keyreleased(key, scancode)
  SceneManager:keyreleased(key, scancode)
end

function love.mousepressed(x, y, button, istouch, presses)
  SceneManager:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
  SceneManager:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
  SceneManager:mousemoved(x, y, dx, dy, istouch)
end

function love.wheelmoved(x, y)
  SceneManager:wheelmoved(x, y)
end

function love.resize(w, h)
  SceneManager:resize(w, h)
end

function love.focus(focused)
  SceneManager:focus(focused)
end
