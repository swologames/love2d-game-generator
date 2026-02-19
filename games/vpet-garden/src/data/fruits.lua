-- data/fruits.lua
-- Fruit definitions used by FeedingSystem and Tree entities.
-- Each entry: { name, color={r,g,b}, shape, effects={stat=delta, ...}, description }
-- shape is used by FruitRenderer to draw programmatic shapes (no image assets).

return {
  {
    name        = "Round Fruit",
    color       = { 0.95, 0.75, 0.50 },
    shape       = "round",
    effects     = { hunger = 45, energy = 8 },
    description = "A round, filling fruit. Very satisfying!",
  },
  {
    name        = "Swim Fruit",
    color       = { 0.40, 0.70, 0.95 },
    shape       = "diamond",
    effects     = { swim = 10, hunger = 38 },
    description = "Tastes like the sea. Boosts swim stat.",
  },
  {
    name        = "Run Fruit",
    color       = { 0.95, 0.55, 0.35 },
    shape       = "star",
    effects     = { run = 10, hunger = 38 },
    description = "Spicy and energising. Boosts run stat.",
  },
  {
    name        = "Fly Fruit",
    color       = { 0.80, 0.65, 0.95 },
    shape       = "crescent",
    effects     = { fly = 10, hunger = 38, energy = 8 },
    description = "Light and fluffy. Boosts fly stat.",
  },
  {
    name        = "Power Fruit",
    color       = { 0.90, 0.30, 0.35 },
    shape       = "heart",
    effects     = { power = 10, hunger = 42 },
    description = "Dense and chewy. Boosts power stat.",
  },
  {
    name        = "Luck Fruit",
    color       = { 0.40, 0.90, 0.55 },
    shape       = "bunch",
    effects     = { luck = 10, happiness = 8, hunger = 35 },
    description = "Rare four-leaf flavour. Boosts luck & mood.",
  },
  {
    name        = "Sweet Fruit",
    color       = { 0.95, 0.75, 0.85 },
    shape       = "pear",
    effects     = { happiness = 20, hunger = 40 },
    description = "Deliciously sweet. Makes the Chao very happy.",
  },
}
