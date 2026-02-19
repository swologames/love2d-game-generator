local SceneManager = require("src/scenes/SceneManager")
local MenuScene    = require("src/scenes/MenuScene")
local GardenScene  = require("src/scenes/GardenScene")

function love.load()
  math.randomseed(os.time())
  love.graphics.setDefaultFilter("nearest", "nearest")

  SceneManager:register("menu",   MenuScene)
  SceneManager:register("garden", GardenScene)
  SceneManager:switch("menu")
end

function love.update(dt)
  SceneManager:update(dt)
end

function love.draw()
  SceneManager:draw()
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
  SceneManager:keypressed(key)
end

function love.mousepressed(x, y, button)
  SceneManager:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
  SceneManager:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
  SceneManager:mousemoved(x, y, dx, dy)
end
