-- Sprite Generator
-- Programmatically generates sprite graphics for the game
-- Delegates to sub-modules by category

local PlayerSprites      = require("src.utils.sprites.PlayerSprites")
local TrashSprites       = require("src.utils.sprites.TrashSprites")
local EnemySprites       = require("src.utils.sprites.EnemySprites")
local EnvironmentSprites = require("src.utils.sprites.EnvironmentSprites")

local SpriteGenerator = {}

SpriteGenerator.generatePlayerIdle  = PlayerSprites.generatePlayerIdle
SpriteGenerator.generatePlayerWalk  = PlayerSprites.generatePlayerWalk
SpriteGenerator.generatePlayerDash  = PlayerSprites.generatePlayerDash

SpriteGenerator.generatePizzaSlice  = TrashSprites.generatePizzaSlice
SpriteGenerator.generateBurger      = TrashSprites.generateBurger
SpriteGenerator.generateDonutBox    = TrashSprites.generateDonutBox
SpriteGenerator.generateTrashBag    = TrashSprites.generateTrashBag

SpriteGenerator.generateHuman       = EnemySprites.generateHuman
SpriteGenerator.generateDog         = EnemySprites.generateDog
SpriteGenerator.generateHumanWalk   = EnemySprites.generateHumanWalk
SpriteGenerator.generateDogRun      = EnemySprites.generateDogRun
SpriteGenerator.generatePossum      = EnemySprites.generatePossum
SpriteGenerator.generateCat         = EnemySprites.generateCat
SpriteGenerator.generateCrow        = EnemySprites.generateCrow

SpriteGenerator.generateBush        = EnvironmentSprites.generateBush
SpriteGenerator.generateTrashBin    = EnvironmentSprites.generateTrashBin
SpriteGenerator.generateTree        = EnvironmentSprites.generateTree
SpriteGenerator.generateHouse       = EnvironmentSprites.generateHouse
SpriteGenerator.generateFence       = EnvironmentSprites.generateFence
SpriteGenerator.generateGrassPatch  = EnvironmentSprites.generateGrassPatch
SpriteGenerator.generateStreetLamp  = EnvironmentSprites.generateStreetLamp

function SpriteGenerator.generateAll()
  print("[SpriteGenerator] Generating all sprites...")
  local sprites = {
    player = {
      idle  = SpriteGenerator.generatePlayerIdle(),
      walk  = SpriteGenerator.generatePlayerWalk(),
      dash  = SpriteGenerator.generatePlayerDash()
    },
    trash = {
      pizza  = SpriteGenerator.generatePizzaSlice(),
      burger = SpriteGenerator.generateBurger(),
      donut  = SpriteGenerator.generateDonutBox(),
      bag    = SpriteGenerator.generateTrashBag()
    },
    enemies = {
      human     = SpriteGenerator.generateHuman(),
      humanWalk = SpriteGenerator.generateHumanWalk(),
      dog       = SpriteGenerator.generateDog(),
      dogRun    = SpriteGenerator.generateDogRun(),
      possum    = SpriteGenerator.generatePossum(),
      cat       = SpriteGenerator.generateCat(),
      crow      = SpriteGenerator.generateCrow()
    },
    environment = {
      bush       = SpriteGenerator.generateBush(),
      trashBin   = SpriteGenerator.generateTrashBin(),
      tree       = SpriteGenerator.generateTree(),
      house      = SpriteGenerator.generateHouse(),
      fence      = SpriteGenerator.generateFence(),
      grassPatch = SpriteGenerator.generateGrassPatch(),
      streetLamp = SpriteGenerator.generateStreetLamp()
    }
  }
  print("[SpriteGenerator] All sprites generated successfully!")
  return sprites
end

return SpriteGenerator
