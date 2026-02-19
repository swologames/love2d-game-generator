-- src/ui/FoodMenu.lua
-- A simple popup panel listing available fruits to feed to the Chao.

local helpers = require("src/utils/helpers")

local FoodMenu = {}
FoodMenu.__index = FoodMenu

local PANEL_W  = 260
local PANEL_H_BASE = 60
local ROW_H    = 38
local PANEL_X  = (1280 - PANEL_W) / 2
local PANEL_Y  = 180

function FoodMenu:new(fruitList)
  local m = setmetatable({}, self)
  m.fruits    = fruitList
  m.hovered   = nil
  m.onSelect  = nil   -- callback(fruit)
  m.titleFont = love.graphics.newFont(14)
  m.itemFont  = love.graphics.newFont(12)
  m.descFont  = love.graphics.newFont(10)
  return m
end

function FoodMenu:_panelHeight()
  return PANEL_H_BASE + #self.fruits * ROW_H
end

function FoodMenu:_rowRect(i)
  local px = PANEL_X + 10
  local py = PANEL_Y + 42 + (i - 1) * ROW_H
  return px, py, PANEL_W - 20, ROW_H - 4
end

function FoodMenu:draw()
  local ph = self:_panelHeight()
  local mx, my = love.mouse.getPosition()

  -- Panel shadow
  love.graphics.setColor(0, 0, 0, 0.25)
  helpers.drawRoundedRect("fill", PANEL_X + 4, PANEL_Y + 4, PANEL_W, ph, 10)

  -- Panel body
  love.graphics.setColor(0.18, 0.14, 0.26, 0.95)
  helpers.drawRoundedRect("fill", PANEL_X, PANEL_Y, PANEL_W, ph, 10)
  love.graphics.setColor(0.68, 0.55, 0.85, 0.70)
  helpers.drawRoundedRect("line", PANEL_X, PANEL_Y, PANEL_W, ph, 10)

  -- Title
  love.graphics.setFont(self.titleFont)
  love.graphics.setColor(0.92, 0.88, 0.98, 1)
  love.graphics.print("Choose a Fruit", PANEL_X + 14, PANEL_Y + 10)

  love.graphics.setFont(self.descFont)
  love.graphics.setColor(0.65, 0.62, 0.72, 0.80)
  love.graphics.print("Click a fruit to feed your Chao", PANEL_X + 14, PANEL_Y + 28)

  -- Fruit rows
  self.hovered = nil
  for i, fruit in ipairs(self.fruits) do
    local rx, ry, rw, rh = self:_rowRect(i)
    local inside = mx >= rx and mx <= rx+rw and my >= ry and my <= ry+rh

    if inside then
      self.hovered = i
      love.graphics.setColor(0.55, 0.42, 0.72, 0.55)
    else
      love.graphics.setColor(0.30, 0.25, 0.42, 0.40)
    end
    helpers.drawRoundedRect("fill", rx, ry, rw, rh, 5)

    -- Colour swatch
    local c = fruit.color
    love.graphics.setColor(c[1], c[2], c[3], 1)
    love.graphics.circle("fill", rx + 14, ry + rh / 2, 9)

    -- Name
    love.graphics.setFont(self.itemFont)
    love.graphics.setColor(0.90, 0.88, 0.98, 1)
    love.graphics.print(fruit.name, rx + 30, ry + 3)

    -- Description
    love.graphics.setFont(self.descFont)
    love.graphics.setColor(0.70, 0.68, 0.80, 0.85)
    love.graphics.print(fruit.description, rx + 30, ry + 19)
  end

  love.graphics.setColor(1, 1, 1, 1)
end

function FoodMenu:mousepressed(x, y, button)
  if button ~= 1 then return end
  for i, fruit in ipairs(self.fruits) do
    local rx, ry, rw, rh = self:_rowRect(i)
    if x >= rx and x <= rx+rw and y >= ry and y <= ry+rh then
      if self.onSelect then self.onSelect(fruit) end
      return
    end
  end
end

return FoodMenu
