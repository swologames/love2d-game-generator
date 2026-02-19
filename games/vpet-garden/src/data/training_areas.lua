-- src/data/training_areas.lua
-- Defines the five training zones placed around the garden.
-- Each area is a rectangle (x,y,w,h) the Chao can be dropped into.
-- Positions are tuned to match visual landmarks in GardenScene._drawBackground.

return {
  {
    name  = "Swim Zone",
    stat  = "swim",
    x = 130, y = 335, w = 155, h = 100,
    color = { 0.40, 0.70, 0.95 },
    label = "SWIM",
    icon  = "~",
    -- Landmark: the small garden pond (ellipse at 200, 380)
  },
  {
    name  = "Run Track",
    stat  = "run",
    x = 455, y = 410, w = 225, h = 70,
    color = { 0.95, 0.70, 0.35 },
    label = "RUN",
    icon  = ">",
    -- Landmark: the sandy path ellipse through the middle
  },
  {
    name  = "Fly Cliff",
    stat  = "fly",
    x = 880, y = 255, w = 165, h = 90,
    color = { 0.75, 0.55, 0.95 },
    label = "FLY",
    icon  = "^",
    -- Landmark: the distant right-side hill
  },
  {
    name  = "Power Rocks",
    stat  = "power",
    x = 148, y = 450, w = 130, h = 80,
    color = { 0.95, 0.45, 0.50 },
    label = "POWER",
    icon  = "!",
    -- Landmark: boulder cluster bottom-left (drawn by GardenScene)
  },
  {
    name  = "Luck Garden",
    stat  = "luck",
    x = 760, y = 445, w = 145, h = 75,
    color = { 0.60, 0.90, 0.60 },
    label = "LUCK",
    icon  = "*",
    -- Landmark: flower cluster right side
  },
  {
    name  = "Nap Spot",
    stat  = "sleep",
    x = 540, y = 470, w = 150, h = 80,
    color = { 0.70, 0.78, 0.98 },
    label = "SLEEP",
    icon  = "z",
    -- Landmark: soft centre-bottom grass, near the path ellipse
  },
}
