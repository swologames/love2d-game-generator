-- src/ui/HUD.lua
-- Draws the Chao stat bars in the bottom-left corner.
-- Vital stats (hunger, happiness, energy) + training stats (swim, run, fly, power, luck).

local helpers = require("src/utils/helpers")

local HUD = {}
HUD.__index = HUD

-- Vital bars shown prominently
local VITAL_BARS = {
  { label = "Hunger",    stat = "hunger",    color = { 0.95, 0.70, 0.30 } },
  { label = "Happiness", stat = "happiness", color = { 0.90, 0.45, 0.65 } },
  { label = "Energy",    stat = "energy",    color = { 0.45, 0.80, 0.60 } },
}

-- Training stats shown as compact mini-bars
local TRAIN_BARS = {
  { label = "Swm", stat = "swim",  color = { 0.40, 0.70, 0.95 } },
  { label = "Run", stat = "run",   color = { 0.95, 0.70, 0.35 } },
  { label = "Fly", stat = "fly",   color = { 0.75, 0.55, 0.95 } },
  { label = "Pwr", stat = "power", color = { 0.95, 0.45, 0.50 } },
  { label = "Lck", stat = "luck",  color = { 0.60, 0.90, 0.60 } },
}

local PAD       = 12
local BAR_W     = 140
local BAR_H     = 12
local SPACING   = 24
local PANEL_X   = 16
local MINI_W    = 60
local MINI_H    = 8
local MINI_GAP  = 20

function HUD:new()
  local h = setmetatable({}, self)
  h.font      = love.graphics.newFont(11)
  h.labelFont = love.graphics.newFont(10)
  h.miniFont  = love.graphics.newFont(9)
  return h
end

function HUD:draw(chao, training)
  if not chao then return end
  local stats = chao.stats

  -- ── Vital panel ──────────────────────────────────────────────────────────
  local vitalRows = #VITAL_BARS
  local panelH    = vitalRows * SPACING + PAD * 2 + 18  -- +18 for name + mood
  local panelW    = BAR_W + 70 + PAD * 2
  local panelY    = 720 - panelH - 8

  love.graphics.setColor(0.12, 0.10, 0.18, 0.78)
  helpers.drawRoundedRect("fill", PANEL_X, panelY, panelW, panelH, 8)
  love.graphics.setColor(0.60, 0.55, 0.75, 0.50)
  helpers.drawRoundedRect("line", PANEL_X, panelY, panelW, panelH, 8)

  -- Name header
  love.graphics.setFont(self.font)
  love.graphics.setColor(0.88, 0.85, 0.95, 1)
  love.graphics.print(chao.name, PANEL_X + PAD, panelY + 4)

  -- Vital bars
  for i, bar in ipairs(VITAL_BARS) do
    local bx  = PANEL_X + PAD
    local by  = panelY + 18 + (i - 1) * SPACING
    local val = stats:norm(bar.stat)

    love.graphics.setFont(self.labelFont)
    love.graphics.setColor(0.75, 0.72, 0.85, 0.90)
    love.graphics.print(bar.label, bx, by)

    local trackX = bx + 62
    love.graphics.setColor(0.20, 0.18, 0.28, 0.90)
    helpers.drawRoundedRect("fill", trackX, by + 1, BAR_W, BAR_H, 4)

    local c     = bar.color
    local fillW = math.max(2, val * BAR_W)
    love.graphics.setColor(c[1], c[2], c[3], 0.90)
    helpers.drawRoundedRect("fill", trackX, by + 1, fillW, BAR_H, 4)

    if val < 0.25 then
      local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 4)
      love.graphics.setColor(1, 0.3, 0.3, 0.60 * pulse)
      love.graphics.rectangle("line", trackX - 1, by, BAR_W + 2, BAR_H + 2, 4, 4)
    end
  end

  -- Mood label
  love.graphics.setFont(self.labelFont)
  love.graphics.setColor(0.88, 0.85, 0.65, 0.85)
  love.graphics.print("Mood: " .. stats:moodLabel(), PANEL_X + PAD, panelY + panelH - 14)

  -- ── Training stats mini-panel ─────────────────────────────────────────────
  local tCols  = #TRAIN_BARS
  local tPanW  = tCols * (MINI_W + MINI_GAP) - MINI_GAP + PAD * 2
  local tPanH  = 42
  local tPanX  = PANEL_X
  local tPanY  = panelY - tPanH - 6

  love.graphics.setColor(0.12, 0.10, 0.18, 0.72)
  helpers.drawRoundedRect("fill", tPanX, tPanY, tPanW, tPanH, 8)
  love.graphics.setColor(0.45, 0.55, 0.75, 0.40)
  helpers.drawRoundedRect("line", tPanX, tPanY, tPanW, tPanH, 8)

  for i, tb in ipairs(TRAIN_BARS) do
    local bx  = tPanX + PAD + (i - 1) * (MINI_W + MINI_GAP)
    local by  = tPanY + 6
    local val = stats:norm(tb.stat)
    local c   = tb.color

    -- Mini bar label
    love.graphics.setFont(self.miniFont)
    love.graphics.setColor(c[1], c[2], c[3], 0.90)
    love.graphics.print(tb.label, bx, by)

    -- Track
    love.graphics.setColor(0.20, 0.18, 0.28, 0.90)
    helpers.drawRoundedRect("fill", bx, by + 14, MINI_W, MINI_H, 3)

    -- Fill
    love.graphics.setColor(c[1], c[2], c[3], 0.85)
    helpers.drawRoundedRect("fill", bx, by + 14, math.max(2, val * MINI_W), MINI_H, 3)

    -- Numeric
    love.graphics.setColor(0.80, 0.78, 0.90, 0.75)
    love.graphics.print(string.format("%d", math.floor(stats[tb.stat])), bx, by + 26)
  end

  -- Active training banner
  if training and training:isTraining() then
    local statName = training:activeStatName() or ""
    local bannerTxt = "Training " .. statName:upper() .. "... (drag away to stop)"
    love.graphics.setFont(self.font)
    love.graphics.setColor(0.12, 0.10, 0.20, 0.82)
    local bw = self.font:getWidth(bannerTxt) + 24
    helpers.drawRoundedRect("fill", 1280/2 - bw/2, 10, bw, 26, 6)
    love.graphics.setColor(0.90, 0.95, 0.60, 1)
    love.graphics.print(bannerTxt, 1280/2 - bw/2 + 12, 14)
  end

  love.graphics.setColor(1, 1, 1, 1)
end

--- Draw hint bar at the bottom-right.
function HUD:drawHints()
  local hints = "[F] Feed    [Drag] Train    [Mouse] Pet"
  love.graphics.setFont(self.labelFont)
  love.graphics.setColor(0.70, 0.68, 0.78, 0.75)
  local tw = love.graphics.getFont():getWidth(hints)
  love.graphics.print(hints, 1280 - tw - 12, 720 - 20)
  love.graphics.setColor(1, 1, 1, 1)
end

return HUD
