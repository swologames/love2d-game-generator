-- TrashSprites.lua
-- Generates trash item sprites (pizza, burger, donut box, trash bag)

local SCALE = 2

local function createCanvas(width, height)
  return love.graphics.newCanvas(width * SCALE, height * SCALE)
end

local function drawToCanvas(canvas, drawFunc)
  love.graphics.push("all")
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.scale(SCALE, SCALE)
  drawFunc()
  love.graphics.setCanvas()
  love.graphics.pop()
end

local function drawPixelCircle(cx, cy, radius, filled)
  local mode = filled and "fill" or "line"
  love.graphics.circle(mode, cx, cy, radius, radius * 4)
end

local function drawRoundedRect(x, y, w, h, r, filled)
  local mode = filled and "fill" or "line"
  love.graphics.rectangle(mode, x, y, w, h, r, r)
end

local TrashSprites = {}

-- Pizza Slice
function TrashSprites.generatePizzaSlice()
  local canvas = createCanvas(16, 16)
  drawToCanvas(canvas, function()
    -- Crust (yellow-orange triangle)
    love.graphics.setColor(1, 0.8, 0.3)
    love.graphics.polygon("fill", 8, 3, 14, 13, 2, 13)

    -- Cheese drip
    love.graphics.setColor(1, 0.9, 0.4)
    love.graphics.polygon("fill", 8, 3, 12, 10, 4, 10)

    -- Pepperoni
    love.graphics.setColor(0.8, 0.2, 0.2)
    drawPixelCircle(7, 8, 1.5, true)
    drawPixelCircle(10, 10, 1.5, true)
    drawPixelCircle(6, 11, 1.5, true)

    -- Outline
    love.graphics.setColor(0.7, 0.5, 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.polygon("line", 8, 3, 14, 13, 2, 13)
  end)
  return canvas
end

-- Burger
function TrashSprites.generateBurger()
  local canvas = createCanvas(16, 16)
  drawToCanvas(canvas, function()
    -- Bottom bun
    love.graphics.setColor(0.8, 0.6, 0.3)
    drawRoundedRect(3, 11, 10, 3, 1, true)

    -- Lettuce
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.rectangle("fill", 3, 9, 10, 2)

    -- Patty
    love.graphics.setColor(0.5, 0.3, 0.2)
    drawRoundedRect(3, 7, 10, 2, 0.5, true)

    -- Cheese
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.polygon("fill", 3, 7, 13, 7, 12, 5, 4, 5)

    -- Top bun
    love.graphics.setColor(0.8, 0.6, 0.3)
    love.graphics.ellipse("fill", 8, 4, 6, 3)

    -- Sesame seeds
    love.graphics.setColor(1, 1, 0.8)
    drawPixelCircle(6, 3, 0.5, true)
    drawPixelCircle(8, 3, 0.5, true)
    drawPixelCircle(10, 3, 0.5, true)

    -- Outline
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.ellipse("line", 8, 4, 6, 3)
    love.graphics.rectangle("line", 3, 7, 10, 7)
  end)
  return canvas
end

-- Donut Box
function TrashSprites.generateDonutBox()
  local canvas = createCanvas(16, 16)
  drawToCanvas(canvas, function()
    -- Box (pink with top flap)
    love.graphics.setColor(1, 0.7, 0.8)
    drawRoundedRect(2, 4, 12, 10, 1, true)

    -- Box outline
    love.graphics.setColor(0.9, 0.5, 0.6)
    love.graphics.setLineWidth(1)
    drawRoundedRect(2, 4, 12, 10, 1, false)
    love.graphics.line(2, 8, 14, 8) -- Middle seam

    -- Window (showing donut)
    love.graphics.setColor(0.8, 0.9, 1, 0.3)
    drawRoundedRect(5, 6, 6, 5, 0.5, true)

    -- Donut visible through window
    love.graphics.setColor(0.9, 0.7, 0.4)
    drawPixelCircle(8, 8.5, 2, true)
    love.graphics.setColor(1, 0.5, 0.7) -- Pink frosting
    drawPixelCircle(8, 8.5, 1.8, true)
    love.graphics.setColor(0.9, 0.7, 0.4) -- Hole
    drawPixelCircle(8, 8.5, 0.8, true)

    -- Sprinkles
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 0, 0)
    love.graphics.line(7, 7.5, 7.5, 7.5)
    love.graphics.setColor(0, 1, 0)
    love.graphics.line(9, 8, 9.5, 8.5)
    love.graphics.setColor(0, 0, 1)
    love.graphics.line(7.5, 9, 8, 9.5)
  end)
  return canvas
end

-- Trash Bag
function TrashSprites.generateTrashBag()
  local canvas = createCanvas(16, 16)
  drawToCanvas(canvas, function()
    -- Bag body (dark gray, lumpy)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.ellipse("fill", 8, 9, 6, 6)

    -- Lumps (garbage inside)
    love.graphics.setColor(0.35, 0.35, 0.35)
    drawPixelCircle(6, 8, 2, true)
    drawPixelCircle(10, 10, 2, true)
    drawPixelCircle(8, 11, 1.5, true)

    -- Tie at top
    love.graphics.setColor(0.25, 0.25, 0.25)
    love.graphics.rectangle("fill", 7, 3, 2, 3)

    -- Knot
    love.graphics.ellipse("fill", 8, 3, 2, 1.5)

    -- Shine/highlight
    love.graphics.setColor(0.5, 0.5, 0.5, 0.6)
    drawPixelCircle(6, 7, 1.5, true)

    -- Outline (subtle)
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.ellipse("line", 8, 9, 6, 6)
  end)
  return canvas
end

return TrashSprites
