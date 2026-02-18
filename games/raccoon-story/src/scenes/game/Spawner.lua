-- Spawner.lua
-- Handles spawning of trash items and enemies into the game world

local TrashItem = require("src.entities.TrashItem")
local Human    = require("src.entities.Human")
local Dog      = require("src.entities.Dog")
local Animal   = require("src.entities.Animal")
local Assets   = require("src.utils.assets")

local Spawner = {}

function Spawner.spawnTrash(scene)
  local trashTypes = {"pizza", "burger", "donut", "pizza", "burger", "pizza", "bag"}

  for i = 1, 30 do
    local x = math.random(100, scene.worldWidth - 100)
    local y = math.random(100, scene.worldHeight - 100)
    local trashType = trashTypes[math.random(#trashTypes)]

    local trashItem = TrashItem:new(x, y, trashType)

    local sprite = Assets:getTrashSprite(trashType)
    if sprite then
      trashItem:setSprite(sprite)
    end

    trashItem.sparkleEmitter = scene.particleSystem:createTrashSparkle(x + 8, y + 8)

    table.insert(scene.trashItems, trashItem)
  end

  print("[Spawner] Spawned " .. #scene.trashItems .. " trash items with sparkles")
end

function Spawner.spawnEnemies(scene)
  local humanSprite     = Assets:getEnemySprite("human")
  local humanWalkSprite = Assets:getEnemySprite("humanWalk")
  local dogSprite       = Assets:getEnemySprite("dog")
  local dogRunSprite    = Assets:getEnemySprite("dogRun")
  local possumSprite    = Assets:getEnemySprite("possum")
  local catSprite       = Assets:getEnemySprite("cat")
  local crowSprite      = Assets:getEnemySprite("crow")

  -- Human 1: Patrols top-left area
  local human1 = Human:new(500, 600, {
    {x=500,y=600},{x=800,y=600},{x=800,y=900},{x=500,y=900}
  })
  if humanSprite and humanWalkSprite then human1:setSprites(humanSprite, humanWalkSprite) end
  scene.aiSystem:addHuman(human1)

  -- Human 2: Patrols center area
  local human2 = Human:new(1600, 800, {
    {x=1600,y=800},{x=2000,y=800},{x=2000,y=1200},{x=1600,y=1200}
  })
  if humanSprite and humanWalkSprite then human2:setSprites(humanSprite, humanWalkSprite) end
  scene.aiSystem:addHuman(human2)

  -- Human 3: Patrols bottom area
  local human3 = Human:new(1000, 1800, {
    {x=800,y=1800},{x=1400,y=1800},{x=1400,y=2100},{x=800,y=2100}
  })
  if humanSprite and humanWalkSprite then human3:setSprites(humanSprite, humanWalkSprite) end
  scene.aiSystem:addHuman(human3)

  -- Dog 1: Guards middle-left area
  local dog1 = Dog:new(1200, 1200, {
    {x=1100,y=1100},{x=1400,y=1100},{x=1400,y=1400},{x=1100,y=1400}
  })
  if dogSprite and dogRunSprite then dog1:setSprites(dogSprite, dogRunSprite) end
  scene.aiSystem:addDog(dog1)

  -- Dog 2: Fast patrol near right area
  local dog2 = Dog:new(2400, 700, {
    {x=2200,y=700},{x=2600,y=700},{x=2600,y=1000},{x=2200,y=1000}
  })
  if dogSprite and dogRunSprite then dog2:setSprites(dogSprite, dogRunSprite) end
  scene.aiSystem:addDog(dog2)

  -- Possum 1: Slow wanderer in middle area
  local possum1 = Animal:new(900, 1400, "possum")
  if possumSprite then possum1:setSprite(possumSprite) end
  scene.aiSystem:addAnimal(possum1)

  -- Cat 1: Quick territorial in upper area
  local cat1 = Animal:new(1800, 900, "cat")
  if catSprite then cat1:setSprite(catSprite) end
  scene.aiSystem:addAnimal(cat1)

  -- Crow 1: Flying thief in center
  local crow1 = Animal:new(1500, 1100, "crow")
  if crowSprite then crow1:setSprite(crowSprite) end
  scene.aiSystem:addAnimal(crow1)

  -- Possum 2: Another wanderer in lower area
  local possum2 = Animal:new(2200, 1700, "possum")
  if possumSprite then possum2:setSprite(possumSprite) end
  scene.aiSystem:addAnimal(possum2)

  print("[Spawner] Spawned enemies: " .. scene.aiSystem:getTotalCount() .. " total")
  local counts = scene.aiSystem:getCounts()
  print("  - Humans: " .. counts.humans)
  print("  - Dogs: " .. counts.dogs)
  print("  - Animals: " .. counts.animals)
end

return Spawner
