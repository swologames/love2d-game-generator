-- src/ui/TrainingMenu.lua
-- Popup panel for choosing which stat to train.
-- Press [T] to open/close. Shows cooldown timers per stat.

local helpers = require("src/utils/helpers")

local TrainingMenu = {}
TrainingMenu.__index = TrainingMenu

local PANEL_W     = 280
local ROW_H       = 44
local HEADER_H    = 56
local PANEL_X     = (1280 - PANEL_W) / 2
local PANEL_Y     = 160

-- Stat entry definitions: display name, colour, icon letter
-- "sleep" is special: it targets the Nap Spot and restores energy.
local STATS = {
  { name = "Swim",  stat = "swim",  color = { 0.40, 0.70, 0.95 }, icon = "S" },
  { name = "Run",   stat = "run",   color = { 0.95, 0.70, 0.35 }, icon = "R" },
  { name = "Fly",   stat = "fly",   color = { 0.75, 0.55, 0.95 }, icon = "F" },
  { name = "Power", stat = "power", color = { 0.95, 0.45, 0.50 }, icon = "P" },
  { name = "Luck",  stat = "luck",  color = { 0.60, 0.90, 0.60 }, icon = "L" },
  { name = "Sleep", stat = "sleep", color = { 0.70, 0.78, 0.98 }, icon = "z", isSleep = true },
}

function TrainingMenu:new(trainingSystem)
  local m = setmetatable({}, self)
  m.training   = trainingSystem
  m.hovered    = nil
  m.onSelect   = nil   -- callback(statName)
  m.titleFont  = love.graphics.newFont(14)
  m.itemFont   = love.graphics.newFont(12)
  m.smallFont  = love.graphics.newFont(10)
  return m
end

function TrainingMenu:_panelHeight()
  return HEADER_H + #STATS * ROW_H + 10
end

function TrainingMenu:_rowRect(i)
  local px = PANEL_X + 10
  local py = PANEL_Y + HEADER_H + (i - 1) * ROW_H
  return px, py, PANEL_W - 20, ROW_H - 4
end

function TrainingMenu:draw(chao)
  if not chao then return end
  local stats = chao.stats
  local ph    = self:_panelHeight()
  local mx, my = love.mouse.getPosition()

  -- Shadow
  love.graphics.setColor(0, 0, 0, 0.25)
  helpers.drawRoundedRect("fill", PANEL_X + 4, PANEL_Y + 4, PANEL_W, ph, 10)

  -- Body
  love.graphics.setColor(0.14, 0.11, 0.22, 0.96)
  helpers.drawRoundedRect("fill", PANEL_X, PANEL_Y, PANEL_W, ph, 10)
  love.graphics.setColor(0.55, 0.65, 0.95, 0.65)
  helpers.drawRoundedRect("line", PANEL_X, PANEL_Y, PANEL_W, ph, 10)

  -- Title
  love.graphics.setFont(self.titleFont)
  love.graphics.setColor(0.85, 0.90, 1.0, 1)
  love.graphics.print("Training", PANEL_X + 14, PANEL_Y + 10)

  love.graphics.setFont(self.smallFont)
  love.graphics.setColor(0.60, 0.62, 0.78, 0.80)
  love.graphics.print("Click a stat to train your Chao", PANEL_X + 14, PANEL_Y + 30)

  -- Stat rows
  self.hovered = nil
  for i, entry in ipairs(STATS) do
    local rx, ry, rw, rh = self:_rowRect(i)
    local inside    = mx >= rx and mx <= rx+rw and my >= ry and my <= ry+rh
    local cd        = self.training:cooldownFor(entry.stat)
    local onCD      = cd > 0
    local lowEnergy = stats.energy < 15
    -- Sleep entry: blocked only when already well rested
    local blocked   = entry.isSleep and (stats.energy >= 90)
                      or (not entry.isSleep and (onCD or lowEnergy))

    -- Row background
    if inside and not blocked then
      self.hovered = i
      love.graphics.setColor(entry.color[1] * 0.5, entry.color[2] * 0.5, entry.color[3] * 0.5, 0.55)
    elseif blocked then
      love.graphics.setColor(0.20, 0.18, 0.28, 0.45)
    else
      love.graphics.setColor(0.28, 0.24, 0.40, 0.45)
    end
    helpers.drawRoundedRect("fill", rx, ry, rw, rh, 5)

    -- Colour icon circle
    local alpha = onCD and 0.35 or 1.0
    love.graphics.setColor(entry.color[1], entry.color[2], entry.color[3], alpha)
    love.graphics.circle("fill", rx + 16, ry + rh / 2, 11)
    love.graphics.setColor(1, 1, 1, alpha * 0.9)
    love.graphics.setFont(self.smallFont)
    love.graphics.print(entry.icon, rx + 12, ry + rh / 2 - 6)

    -- Stat name and current value
    love.graphics.setFont(self.itemFont)
    love.graphics.setColor(onCD and 0.55 or 0.92, 0.88, 1.0, onCD and 0.55 or 1.0)
    love.graphics.print(entry.name, rx + 36, ry + 4)

    -- Stat value bar (mini) — Sleep shows energy instead
    local barW      = 80
    local barX      = rx + rw - barW - 8
    local barY      = ry + 8
    local barStat   = entry.isSleep and "energy" or entry.stat
    local val       = stats:norm(barStat)
    love.graphics.setColor(0.20, 0.18, 0.28, 0.90)
    helpers.drawRoundedRect("fill", barX, barY, barW, 7, 3)
    love.graphics.setColor(entry.color[1], entry.color[2], entry.color[3], alpha * 0.85)
    helpers.drawRoundedRect("fill", barX, barY, math.max(2, val * barW), 7, 3)

    -- Numeric value
    love.graphics.setFont(self.smallFont)
    love.graphics.setColor(0.75, 0.72, 0.85, 0.85)
    local displayVal = entry.isSleep and stats.energy or stats[entry.stat]
    love.graphics.print(string.format("%d", math.floor(displayVal)), rx + 36, ry + 22)

    -- Cooldown overlay / status — Sleep area uses energy rules
    if onCD then
      love.graphics.setColor(0.95, 0.70, 0.40, 0.80)
      local cdStr = string.format("Ready in %.0fs", cd)
      love.graphics.print(cdStr, barX, ry + 22)
    elseif entry.isSleep then
      -- Sleep is unavailable only when already at full energy
      if stats.energy >= 90 then
        love.graphics.setColor(0.60, 0.80, 0.98, 0.80)
        love.graphics.print("Well rested!", barX - 10, ry + 22)
      else
        love.graphics.setColor(0.55, 0.90, 0.55, 0.80)
        love.graphics.print("Nap!", barX + 30, ry + 22)
      end
    elseif lowEnergy then
      love.graphics.setColor(0.95, 0.45, 0.45, 0.80)
      love.graphics.print("Too tired!", barX, ry + 22)
    else
      love.graphics.setColor(0.55, 0.90, 0.55, 0.80)
      love.graphics.print("Ready!", barX + 22, ry + 22)
    end
  end

  love.graphics.setColor(1, 1, 1, 1)
end

--- Returns true if the click was consumed.
function TrainingMenu:mousepressed(x, y, button)
  if button ~= 1 then return false end
  for i, entry in ipairs(STATS) do
    local rx, ry, rw, rh = self:_rowRect(i)
    if x >= rx and x <= rx+rw and y >= ry and y <= ry+rh then
      if self.onSelect then self.onSelect(entry.stat) end
      return true
    end
  end
  return false
end

return TrainingMenu
