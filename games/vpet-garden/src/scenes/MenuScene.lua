-- src/scenes/MenuScene.lua
-- Title screen with a "Start Garden" button.

local helpers      = require("src/utils/helpers")
local SceneManager = require("src/scenes/SceneManager")

local MenuScene = {}

-- ── Layout constants ──────────────────────────────────────────────────────────
local W, H = 1280, 720

local BTN = { x = W/2 - 110, y = H/2 + 30, w = 220, h = 52 }

-- ── State ─────────────────────────────────────────────────────────────────────
local titleFont
local btnFont
local subtitleFont
local hoverBtn  = false
local bgTimer   = 0

-- Pastel background gradient colours
local BG_TOP    = { 0.62, 0.82, 0.72 }
local BG_BOT    = { 0.78, 0.90, 0.82 }

-- ── Lifecycle ──────────────────────────────────────────────────────────────────
function MenuScene:enter()
  titleFont    = love.graphics.newFont(52)
  btnFont      = love.graphics.newFont(20)
  subtitleFont = love.graphics.newFont(15)
  bgTimer      = 0
end

function MenuScene:exit()
  -- nothing
end

function MenuScene:update(dt)
  bgTimer = bgTimer + dt
end

-- ── Drawing ───────────────────────────────────────────────────────────────────
function MenuScene:draw()
  -- Soft gradient-ish background (two rectangles faked)
  love.graphics.setColor(BG_TOP)
  love.graphics.rectangle("fill", 0, 0, W, H / 2)
  love.graphics.setColor(BG_BOT)
  love.graphics.rectangle("fill", 0, H / 2, W, H / 2)

  -- Decorative circles (bushes / clouds)
  self:_drawDecorations()

  -- Title shadow
  love.graphics.setFont(titleFont)
  love.graphics.setColor(0.20, 0.28, 0.22, 0.30)
  love.graphics.print("VPet Garden", W/2 - titleFont:getWidth("VPet Garden")/2 + 3, H/2 - 130 + 3)

  -- Title
  love.graphics.setColor(0.20, 0.35, 0.28, 1)
  love.graphics.print("VPet Garden", W/2 - titleFont:getWidth("VPet Garden")/2, H/2 - 130)

  -- Subtitle
  love.graphics.setFont(subtitleFont)
  love.graphics.setColor(0.30, 0.45, 0.38, 0.85)
  local sub = "A cozy virtual companion garden"
  love.graphics.print(sub, W/2 - subtitleFont:getWidth(sub)/2, H/2 - 70)

  -- Button
  self:_drawButton()

  -- Version hint
  love.graphics.setFont(love.graphics.newFont(10))
  love.graphics.setColor(0.35, 0.45, 0.38, 0.60)
  love.graphics.print("v0.1  |  [ESC] Quit", 12, H - 18)

  love.graphics.setColor(1, 1, 1, 1)
end

function MenuScene:_drawDecorations()
  local t = bgTimer
  local circles = {
    { x=100,  y=580, r=55,  c={0.55, 0.78, 0.60, 0.55} },
    { x=240,  y=620, r=40,  c={0.50, 0.74, 0.55, 0.45} },
    { x=1100, y=560, r=60,  c={0.55, 0.78, 0.60, 0.55} },
    { x=1180, y=610, r=38,  c={0.50, 0.74, 0.55, 0.40} },
    { x=600,  y=650, r=30,  c={0.60, 0.82, 0.65, 0.35} },
  }
  for _, ci in ipairs(circles) do
    local bob = math.sin(t * 0.5 + ci.x) * 4
    love.graphics.setColor(ci.c)
    love.graphics.circle("fill", ci.x, ci.y + bob, ci.r)
  end
end

function MenuScene:_drawButton()
  local mx, my = love.mouse.getPosition()
  hoverBtn = mx >= BTN.x and mx <= BTN.x+BTN.w and my >= BTN.y and my <= BTN.y+BTN.h

  -- Shadow
  love.graphics.setColor(0, 0, 0, 0.15)
  helpers.drawRoundedRect("fill", BTN.x+3, BTN.y+4, BTN.w, BTN.h, 10)

  -- Body
  if hoverBtn then
    love.graphics.setColor(0.42, 0.72, 0.52, 1)
  else
    love.graphics.setColor(0.38, 0.65, 0.48, 1)
  end
  helpers.drawRoundedRect("fill", BTN.x, BTN.y, BTN.w, BTN.h, 10)

  -- Border
  love.graphics.setColor(0.28, 0.50, 0.38, 0.80)
  helpers.drawRoundedRect("line", BTN.x, BTN.y, BTN.w, BTN.h, 10)

  -- Label
  love.graphics.setFont(btnFont)
  love.graphics.setColor(0.95, 0.98, 0.95, 1)
  local label = "Start Garden"
  local lw    = btnFont:getWidth(label)
  love.graphics.print(label, BTN.x + (BTN.w - lw)/2, BTN.y + (BTN.h - 20)/2)
end

-- ── Input ──────────────────────────────────────────────────────────────────────
function MenuScene:mousepressed(x, y, button)
  if button == 1 and hoverBtn then
    SceneManager:switch("garden")
  end
end

function MenuScene:keypressed(key)
  if key == "return" or key == "space" then
    SceneManager:switch("garden")
  end
end

function MenuScene:mousereleased() end
function MenuScene:mousemoved()    end

return MenuScene
