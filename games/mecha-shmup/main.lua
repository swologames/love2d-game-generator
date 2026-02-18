-- Mecha Shmup - Main Entry Point
-- A vertical scrolling shoot 'em up game

-- Require the scene manager
SceneManager = require("src.scenes.SceneManager")

-- Require audio system
AudioSystem = require("src.systems.AudioSystem")

-- Require all scenes
local MenuScene = require("src.scenes.MenuScene")
local LevelSelectScene = require("src.scenes.LevelSelectScene")
local CharacterSelectScene = require("src.scenes.CharacterSelectScene")
local GameScene = require("src.scenes.GameScene")

-- Love2D callback: Initialize the game
function love.load()
  -- Set window title
  love.window.setTitle("Mecha Shmup")
  
  -- Initialize audio system
  AudioSystem:init()
  
  -- Register all scenes
  SceneManager:register("menu", MenuScene)
  SceneManager:register("levelSelect", LevelSelectScene)
  SceneManager:register("characterSelect", CharacterSelectScene)
  SceneManager:register("game", GameScene)
  
  -- Start with the main menu
  SceneManager:switch("menu")
  
  print("Mecha Shmup loaded! Starting at Main Menu.")
end

-- Love2D callback: Update game logic
function love.update(dt)
  AudioSystem:update(dt)
  SceneManager:update(dt)
end

-- Love2D callback: Draw the game
function love.draw()
  SceneManager:draw()
end

-- Love2D callback: Handle key presses
function love.keypressed(key)
  SceneManager:keypressed(key)
end

-- Love2D callback: Handle mouse presses
function love.mousepressed(x, y, button)
  SceneManager:mousepressed(x, y, button)
end
