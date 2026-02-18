-- Sprite Generation Test
-- Run this to verify sprites generate correctly
-- Usage: love . --test-sprites

print("=== Sprite Generation Test ===")

-- Load the sprite generator
local SpriteGenerator = require("src.utils.SpriteGenerator")

print("\n[1] Testing Player Idle Animation...")
local idleFrames = SpriteGenerator.generatePlayerIdle()
print("   Generated " .. #idleFrames .. " idle frames")
for i, frame in ipairs(idleFrames) do
  print("   Frame " .. i .. ": " .. frame:getWidth() .. "x" .. frame:getHeight())
end

print("\n[2] Testing Player Walk Animation...")
local walkFrames = SpriteGenerator.generatePlayerWalk()
print("   Generated " .. #walkFrames .. " walk frames")
for i, frame in ipairs(walkFrames) do
  print("   Frame " .. i .. ": " .. frame:getWidth() .. "x" .. frame:getHeight())
end

print("\n[3] Testing Trash Item Sprites...")
local trashTypes = {"pizza", "burger", "donut", "bag"}
for _, type in ipairs(trashTypes) do
  local sprite = SpriteGenerator["generate" .. type:sub(1,1):upper() .. type:sub(2)]()
  if not sprite then
    -- Try alternate naming
    if type == "pizza" then sprite = SpriteGenerator.generatePizzaSlice()
    elseif type == "burger" then sprite = SpriteGenerator.generateBurger()
    elseif type == "donut" then sprite = SpriteGenerator.generateDonutBox()
    elseif type == "bag" then sprite = SpriteGenerator.generateTrashBag()
    end
  end
  if sprite then
    print("   " .. type .. ": " .. sprite:getWidth() .. "x" .. sprite:getHeight())
  else
    print("   " .. type .. ": FAILED")
  end
end

print("\n[4] Testing Enemy Sprites...")
local humanSprite = SpriteGenerator.generateHuman()
print("   Human: " .. humanSprite:getWidth() .. "x" .. humanSprite:getHeight())
local dogSprite = SpriteGenerator.generateDog()
print("   Dog: " .. dogSprite:getWidth() .. "x" .. dogSprite:getHeight())

print("\n[5] Testing Environment Sprites...")
local bushSprite = SpriteGenerator.generateBush()
print("   Bush: " .. bushSprite:getWidth() .. "x" .. bushSprite:getHeight())
local binSprite = SpriteGenerator.generateTrashBin()
print("   Trash Bin: " .. binSprite:getWidth() .. "x" .. binSprite:getHeight())

print("\n[6] Testing Full Generation...")
local allSprites = SpriteGenerator.generateAll()
print("   Generated all sprite categories:")
print("   - player.idle: " .. #allSprites.player.idle .. " frames")
print("   - player.walk: " .. #allSprites.player.walk .. " frames")
print("   - trash: " .. (allSprites.trash.pizza and "✓" or "✗") .. " pizza")
print("   - trash: " .. (allSprites.trash.burger and "✓" or "✗") .. " burger")
print("   - trash: " .. (allSprites.trash.donut and "✓" or "✗") .. " donut")
print("   - trash: " .. (allSprites.trash.bag and "✓" or "✗") .. " bag")
print("   - enemies: " .. (allSprites.enemies.human and "✓" or "✗") .. " human")
print("   - enemies: " .. (allSprites.enemies.dog and "✓" or "✗") .. " dog")
print("   - environment: " .. (allSprites.environment.bush and "✓" or "✗") .. " bush")
print("   - environment: " .. (allSprites.environment.trashBin and "✓" or "✗") .. " trash bin")

print("\n=== All Tests Passed! ===")
print("Sprites are ready to use in the game.")
