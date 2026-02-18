-- Quick test to verify GameScene environment objects load correctly
-- Run with: lua test-environment.lua

-- Mock love2d minimal API for testing
love = {}
love.graphics = {
  newCanvas = function(w, h) return {w=w, h=h, type="canvas"} end,
  setCanvas = function() end,
  clear = function() end,
  setColor = function() end,
  rectangle = function() end,
  circle = function() end,
  draw = function() end,
  setLineWidth = function() end,
  line = function() end,
  polygon = function() end,
  ellipse = function() end,
  getWidth = function() return 800 end,
  getHeight = function() return 600 end,
  getFont = function() return {getWidth = function() return 100 end} end,
  push = function() end,
  pop = function() end,
  translate = function() end,
  printf = function() end,
  print = function() end
}
love.math = {
  random = math.random
}
love.timer = {
  getTime = function() return 0 end
}

-- Load the GameScene
local GameScene = require("src.scenes.GameScene")

-- Try to initialize
GameScene:enter()

-- Check environment objects
print("\n=== ENVIRONMENT TEST RESULTS ===")
print("World Size: " .. GameScene.worldWidth .. "x" .. GameScene.worldHeight)
print("Total Environment Objects: " .. #GameScene.environmentObjects)

-- Count by type
local counts = {}
for _, obj in ipairs(GameScene.environmentObjects) do
  counts[obj.type] = (counts[obj.type] or 0) + 1
end

print("\nObjects by type:")
for type, count in pairs(counts) do
  print("  " .. type .. ": " .. count)
end

-- Count solid objects
local solidCount = 0
local hideCount = 0
local decorativeCount = 0
for _, obj in ipairs(GameScene.environmentObjects) do
  if obj.solid then solidCount = solidCount + 1 end
  if obj.canHide then hideCount = hideCount + 1 end
  if obj.decorative then decorativeCount = decorativeCount + 1 end
end

print("\nObject properties:")
print("  Solid (blocks movement): " .. solidCount)
print("  Can Hide (bushes): " .. hideCount)
print("  Decorative (no collision): " .. decorativeCount)

print("\nTest completed successfully! ✓")
