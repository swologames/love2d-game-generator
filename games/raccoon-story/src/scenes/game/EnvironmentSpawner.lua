-- EnvironmentSpawner.lua
-- Populates the neighborhood with environmental objects (houses, trees, bushes, etc.)

local Assets = require("src.utils.assets")

local EnvironmentSpawner = {}

function EnvironmentSpawner.spawn(scene)
  local function add(x, y, t, w, h, solid, canHide, decorative)
    local sprite = Assets:getEnvironmentSprite(t)
    if sprite then
      table.insert(scene.environmentObjects, {
        x=x, y=y, width=w, height=h,
        sprite=sprite, type=t,
        solid=solid or false,
        canHide=canHide or false,
        decorative=decorative or false
      })
    end
  end

  -- HOUSES (96x96) - solid
  add(120,  150,  "house", 96, 96, true)
  add(800,  100,  "house", 96, 96, true)
  add(1500, 180,  "house", 96, 96, true)
  add(2400, 120,  "house", 96, 96, true)
  add(150,  2100, "house", 96, 96, true)
  add(2200, 2150, "house", 96, 96, true)
  add(2900, 1800, "house", 96, 96, true)

  -- TREES (64x96) - solid
  add(350,  450,  "tree", 64, 96, true)
  add(900,  600,  "tree", 64, 96, true)
  add(1300, 800,  "tree", 64, 96, true)
  add(1800, 500,  "tree", 64, 96, true)
  add(2200, 900,  "tree", 64, 96, true)
  add(2600, 600,  "tree", 64, 96, true)
  add(450,  1400, "tree", 64, 96, true)
  add(1100, 1600, "tree", 64, 96, true)
  add(1700, 1800, "tree", 64, 96, true)
  add(2400, 1500, "tree", 64, 96, true)
  add(600,  2100, "tree", 64, 96, true)
  add(1400, 2200, "tree", 64, 96, true)
  add(2800, 2200, "tree", 64, 96, true)

  -- BUSHES (48x48) - hiding spots
  add(500,  500,  "bush", 48, 48, false, true)
  add(750,  700,  "bush", 48, 48, false, true)
  add(1100, 500,  "bush", 48, 48, false, true)
  add(1450, 650,  "bush", 48, 48, false, true)
  add(1900, 750,  "bush", 48, 48, false, true)
  add(2300, 550,  "bush", 48, 48, false, true)
  add(2750, 800,  "bush", 48, 48, false, true)
  add(650,  1200, "bush", 48, 48, false, true)
  add(1000, 1350, "bush", 48, 48, false, true)
  add(1500, 1400, "bush", 48, 48, false, true)
  add(1950, 1300, "bush", 48, 48, false, true)
  add(2500, 1250, "bush", 48, 48, false, true)
  add(400,  1900, "bush", 48, 48, false, true)
  add(900,  2000, "bush", 48, 48, false, true)
  add(1600, 2100, "bush", 48, 48, false, true)
  add(2100, 1950, "bush", 48, 48, false, true)
  add(2700, 2050, "bush", 48, 48, false, true)
  add(3000, 1600, "bush", 48, 48, false, true)

  -- FENCES (32x32) - solid fence lines near houses
  for i = 0, 4 do add(280 + i*32,  200,  "fence", 32, 32, true) end
  for i = 0, 3 do add(950 + i*32,  150,  "fence", 32, 32, true) end
  for i = 0, 5 do add(1650 + i*32, 230,  "fence", 32, 32, true) end
  for i = 0, 4 do add(310 + i*32,  2150, "fence", 32, 32, true) end

  -- GRASS PATCHES (32x32) - decorative
  for i = 1, 28 do
    local x = math.random(100, scene.worldWidth - 100)
    local y = math.random(100, scene.worldHeight - 100)
    add(x, y, "grassPatch", 32, 32, false, false, true)
  end

  -- STREET LAMPS (32x64)
  add(600,  300,  "streetLamp", 32, 64)
  add(1200, 400,  "streetLamp", 32, 64)
  add(1900, 350,  "streetLamp", 32, 64)
  add(2500, 450,  "streetLamp", 32, 64)
  add(800,  1500, "streetLamp", 32, 64)
  add(1600, 1700, "streetLamp", 32, 64)
  add(2300, 1600, "streetLamp", 32, 64)
  add(1000, 2250, "streetLamp", 32, 64)
  add(2000, 2300, "streetLamp", 32, 64)

  -- TRASH BINS (32x48) - solid
  add(400,  350,  "trashBin", 32, 48, true)
  add(1000, 450,  "trashBin", 32, 48, true)
  add(1700, 550,  "trashBin", 32, 48, true)
  add(2200, 700,  "trashBin", 32, 48, true)
  add(700,  1600, "trashBin", 32, 48, true)
  add(1500, 1850, "trashBin", 32, 48, true)
  add(2400, 1750, "trashBin", 32, 48, true)
  add(1200, 2200, "trashBin", 32, 48, true)

  print("[EnvironmentSpawner] Spawned " .. #scene.environmentObjects .. " environment objects")
end

return EnvironmentSpawner
