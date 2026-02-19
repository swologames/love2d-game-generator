-- src/scenes/GardenScene.lua
-- Orchestrator for the main garden gameplay screen.
-- Wires all systems together; contains NO entity/system logic itself.

local Chao                  = require("src/entities/Chao")
local FeedingSystem         = require("src/systems/FeedingSystem")
local PettingSystem         = require("src/systems/PettingSystem")
local TrainingSystem        = require("src/systems/TrainingSystem")
local DragSystem            = require("src/systems/DragSystem")
local ParticleSystem        = require("src/systems/ParticleSystem")
local AudioSystem           = require("src/systems/AudioSystem")
local HUD                   = require("src/ui/HUD")
local TrainingAreaRenderer  = require("src/ui/TrainingAreaRenderer")
local helpers               = require("src/utils/helpers")

local GardenScene   = {}

local W, H = 1280, 720

-- Garden world bounds (keeps chao walking in the green area)
local GARDEN_BOUNDS = { x = 160, y = 120, w = 960, h = 480 }

-- ── Lifecycle ──────────────────────────────────────────────────────────────────
function GardenScene:enter()
  -- Create the Chao
  self.chao = Chao:new(W/2, H/2, "Chao")

  -- Systems
  self.particles = ParticleSystem:new(GARDEN_BOUNDS)
  self.petting   = PettingSystem:new(self.chao, self.particles)
  self.feeding   = FeedingSystem:new(self.chao, self.particles)
  self.training  = TrainingSystem:new(self.chao, self.particles)
  self.drag      = DragSystem:new(self.chao, self.training)
  self.audio     = AudioSystem:new()
  self.hud       = HUD:new()
  self.renderer  = TrainingAreaRenderer:new(self.chao, self.drag, self.training)

  -- Load audio (gracefully skips if files are absent)
  self.audio:loadMusic("bg", "assets/music/garden_ambient.ogg")
  self.audio:loadSound("pet",  "assets/sounds/pet.wav")
  self.audio:loadSound("eat",  "assets/sounds/eat.wav")
  self.audio:playMusic("bg")

  -- Wire DragSystem's short-click callback to fire a pet
  self.drag:onPetClick(function(cx, cy)
    self.chao.stats:pet()
    self.chao.ai:forceState("petted", 1.5)
    self.particles:spawnHearts(cx, cy - 20, 4)
    if self.chao.onPetted then self.chao.onPetted(cx, cy) end
  end)

  self.bgTimer = 0
end

function GardenScene:exit()
  self.audio:stopMusic()
end

-- ── Update ─────────────────────────────────────────────────────────────────────
function GardenScene:update(dt)
  self.bgTimer = self.bgTimer + dt

  self.drag:update(dt)       -- must run first: moves chao position
  self.petting:update(dt)
  self.feeding:update(dt)
  self.training:update(dt)
  self.particles:update(dt)
  self.audio:update(dt)
  self.renderer:update(dt)
end

-- ── Draw ───────────────────────────────────────────────────────────────────────
function GardenScene:draw()
  self:_drawBackground()
  self.renderer:draw()
  self.feeding:draw()    -- trees + fruit drops drawn before Chao
  self.particles:draw()
  self.chao:draw()
  self.hud:draw(self.chao, self.training)
  self.hud:drawHints()
end

-- ── Input ──────────────────────────────────────────────────────────────────────
function GardenScene:keypressed(key)
  -- (keypressed feeding removed — feeding is now drag-and-drop via trees)
end

function GardenScene:mousepressed(x, y, button)
  -- FeedingSystem gets first bite (trees + fruit drag pickup)
  if self.feeding:mousepressed(x, y, button) then return end
  -- DragSystem handles both click-to-pet and hold-to-drag for the Chao.
  -- PettingSystem only receives the event when the click missed the Chao.
  if not self.drag:mousepressed(x, y, button) then
    self.petting:mousepressed(x, y, button)
  end
end

function GardenScene:mousereleased(x, y, button)
  self.feeding:mousereleased(x, y, button)  -- release drag → maybe feed Chao
  self.drag:mousereleased(x, y, button)
  self.petting:mousereleased(x, y, button)
end

function GardenScene:mousemoved(x, y, dx, dy)
  self.feeding:mousemoved(x, y)    -- update dragged fruit position
  self.petting:mousemoved(x, y)
end

-- ── Background drawing ─────────────────────────────────────────────────────────
function GardenScene:_drawBackground()
  local t = self.bgTimer

  -- Sky
  love.graphics.setColor(0.75, 0.90, 0.85, 1)
  love.graphics.rectangle("fill", 0, 0, W, H)

  -- Distant hills
  love.graphics.setColor(0.60, 0.82, 0.65, 0.50)
  love.graphics.ellipse("fill", 300,  H * 0.55, 320, 120)
  love.graphics.ellipse("fill", 900,  H * 0.52, 280, 100)
  love.graphics.ellipse("fill", 1150, H * 0.56, 200, 90)

  -- Ground
  love.graphics.setColor(0.52, 0.78, 0.52, 1)
  love.graphics.rectangle("fill", 0, H * 0.52, W, H * 0.48)

  -- Soft inner garden area
  love.graphics.setColor(0.60, 0.85, 0.58, 0.60)
  love.graphics.ellipse("fill", W/2, H * 0.58, GARDEN_BOUNDS.w * 0.55, GARDEN_BOUNDS.h * 0.55)

  -- Path (two soft ellipses)
  love.graphics.setColor(0.85, 0.82, 0.65, 0.45)
  love.graphics.ellipse("fill", W/2, H * 0.62, 260, 55)

  -- Bushes (circles)
  local bushes = {
    { x=180,  y=480, r=38 }, { x=220,  y=510, r=28 },
    { x=1080, y=470, r=42 }, { x=1045, y=500, r=30 },
    { x=640,  y=520, r=22 }, { x=380,  y=530, r=25 },
    { x=900,  y=525, r=20 },
  }
  for _, b in ipairs(bushes) do
    local bob = math.sin(t * 0.4 + b.x * 0.05) * 2
    love.graphics.setColor(0.35, 0.68, 0.40, 0.90)
    love.graphics.circle("fill", b.x, b.y + bob, b.r)
    love.graphics.setColor(0.45, 0.78, 0.50, 0.60)
    love.graphics.circle("fill", b.x - b.r*0.3, b.y - b.r*0.2 + bob, b.r * 0.65)
  end

  -- Flowers (tiny coloured dots)
  local flowers = {
    {300, 490, {0.95,0.75,0.80}}, {340,510,{0.95,0.92,0.55}},
    {500, 505, {0.80,0.65,0.95}}, {720,515,{0.95,0.75,0.80}},
    {820, 500, {0.55,0.80,0.95}}, {950,495,{0.95,0.88,0.55}},
  }
  for _, f in ipairs(flowers) do
    local bob = math.sin(t * 1.2 + f[1]) * 1.5
    love.graphics.setColor(f[3])
    love.graphics.circle("fill", f[1], f[2] + bob, 5)
    love.graphics.setColor(1, 0.98, 0.90, 0.95)
    love.graphics.circle("fill", f[1], f[2] + bob, 2)
  end

  -- Water feature (small pond) — also serves as Swim Zone landmark
  love.graphics.setColor(0.55, 0.75, 0.90, 0.70)
  love.graphics.ellipse("fill", 200, 380, 65, 35)
  love.graphics.setColor(0.70, 0.88, 0.98, 0.45)
  love.graphics.ellipse("fill", 195, 376, 42, 20)
  -- Ripple ring
  love.graphics.setColor(0.60, 0.80, 0.95, 0.30)
  love.graphics.ellipse("line", 200, 380, 72, 40)

  -- Power Rocks landmark (bottom-left, matching Power area)
  local rockColor = { 0.62, 0.55, 0.52 }
  love.graphics.setColor(rockColor[1], rockColor[2], rockColor[3], 0.90)
  love.graphics.ellipse("fill", 175, 490, 22, 14)
  love.graphics.ellipse("fill", 205, 497, 18, 12)
  love.graphics.ellipse("fill", 158, 500, 16, 11)
  love.graphics.setColor(0.72, 0.65, 0.62, 0.70)
  love.graphics.ellipse("fill", 185, 483, 12, 8)

  love.graphics.setColor(1, 1, 1, 1)
end

return GardenScene
