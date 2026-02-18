-- EnvironmentSprites.lua
-- Generates environment sprites: bush, trash bin, tree, house, fence, grass patch, street lamp

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

local EnvironmentSprites = {}

-- Bush (hiding spot)
function EnvironmentSprites.generateBush()
  local canvas = createCanvas(48, 48)
  drawToCanvas(canvas, function()
    -- Bush is made of overlapping circles for fluffy appearance
    local bushColor = {0.2, 0.5, 0.2}
    local darkBush = {0.15, 0.4, 0.15}
    local lightBush = {0.3, 0.6, 0.3}

    -- Shadow at base
    love.graphics.setColor(0.1, 0.2, 0.1, 0.3)
    love.graphics.ellipse("fill", 24, 44, 16, 3)

    -- Dark base layer
    love.graphics.setColor(darkBush)
    drawPixelCircle(20, 32, 8, true)
    drawPixelCircle(28, 32, 8, true)
    drawPixelCircle(24, 28, 8, true)

    -- Main layer
    love.graphics.setColor(bushColor)
    drawPixelCircle(16, 28, 7, true)
    drawPixelCircle(32, 28, 7, true)
    drawPixelCircle(24, 24, 8, true)
    drawPixelCircle(20, 20, 6, true)
    drawPixelCircle(28, 20, 6, true)

    -- Light highlights
    love.graphics.setColor(lightBush)
    drawPixelCircle(18, 22, 4, true)
    drawPixelCircle(30, 22, 4, true)
    drawPixelCircle(24, 18, 5, true)

    -- Very light highlights (sun spots)
    love.graphics.setColor(0.4, 0.7, 0.4, 0.6)
    drawPixelCircle(20, 18, 2, true)
    drawPixelCircle(28, 18, 2, true)

    -- Some darker details for depth
    love.graphics.setColor(0.1, 0.3, 0.1)
    drawPixelCircle(22, 26, 2, true)
    drawPixelCircle(26, 26, 2, true)
    drawPixelCircle(24, 30, 2, true)
  end)
  return canvas
end

-- Trash Bin
function EnvironmentSprites.generateTrashBin()
  local canvas = createCanvas(32, 48)
  drawToCanvas(canvas, function()
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.ellipse("fill", 16, 46, 12, 2)

    -- Bin body (gray metal)
    love.graphics.setColor(0.5, 0.5, 0.55)
    drawRoundedRect(8, 16, 16, 28, 2, true)

    -- Darker side
    love.graphics.setColor(0.4, 0.4, 0.45)
    love.graphics.rectangle("fill", 8, 16, 4, 28)

    -- Lid
    love.graphics.setColor(0.4, 0.4, 0.45)
    drawRoundedRect(6, 12, 20, 5, 1, true)

    -- Lid top
    love.graphics.setColor(0.5, 0.5, 0.55)
    drawRoundedRect(6, 10, 20, 3, 1, true)

    -- Handle on lid
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("fill", 14, 8, 4, 2)
    love.graphics.circle("fill", 16, 8, 2)

    -- Metal shine
    love.graphics.setColor(0.7, 0.7, 0.75, 0.5)
    love.graphics.rectangle("fill", 20, 18, 2, 24)

    -- Horizontal lines (corrugation)
    love.graphics.setColor(0.4, 0.4, 0.45)
    love.graphics.setLineWidth(1)
    love.graphics.line(8, 22, 24, 22)
    love.graphics.line(8, 28, 24, 28)
    love.graphics.line(8, 34, 24, 34)
    love.graphics.line(8, 40, 24, 40)

    -- Opening at top (dark)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.ellipse("fill", 16, 14, 6, 2)
  end)
  return canvas
end

-- Tree (large obstacle/decoration)
function EnvironmentSprites.generateTree()
  local canvas = createCanvas(64, 96)
  drawToCanvas(canvas, function()
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.ellipse("fill", 32, 92, 18, 3)

    -- Trunk (brown)
    love.graphics.setColor(0.545, 0.271, 0.075) -- #8B4513
    drawRoundedRect(26, 48, 12, 46, 2, true)

    -- Bark texture (darker)
    love.graphics.setColor(0.45, 0.22, 0.06)
    love.graphics.setLineWidth(2)
    love.graphics.line(28, 55, 28, 90)
    love.graphics.line(36, 52, 36, 92)
    love.graphics.setLineWidth(1)
    love.graphics.line(30, 60, 34, 62)
    love.graphics.line(30, 70, 34, 72)
    love.graphics.line(30, 80, 34, 82)

    -- Canopy base (dark green)
    love.graphics.setColor(0.2, 0.5, 0.2)
    drawPixelCircle(32, 36, 20, true)
    drawPixelCircle(20, 32, 14, true)
    drawPixelCircle(44, 32, 14, true)
    drawPixelCircle(32, 24, 16, true)

    -- Mid-layer (main green)
    love.graphics.setColor(0.565, 0.933, 0.565) -- #90EE90
    drawPixelCircle(28, 32, 16, true)
    drawPixelCircle(36, 32, 16, true)
    drawPixelCircle(32, 28, 18, true)
    drawPixelCircle(24, 24, 12, true)
    drawPixelCircle(40, 24, 12, true)
    drawPixelCircle(32, 18, 14, true)

    -- Highlights (light green)
    love.graphics.setColor(0.7, 1.0, 0.7)
    drawPixelCircle(26, 22, 8, true)
    drawPixelCircle(38, 22, 8, true)
    drawPixelCircle(32, 16, 10, true)

    -- Sun spots
    love.graphics.setColor(0.8, 1.0, 0.8, 0.6)
    drawPixelCircle(28, 18, 4, true)
    drawPixelCircle(36, 20, 4, true)

    -- Dark detail for depth
    love.graphics.setColor(0.15, 0.4, 0.15)
    drawPixelCircle(32, 30, 4, true)
    drawPixelCircle(26, 28, 3, true)
    drawPixelCircle(38, 28, 3, true)
  end)
  return canvas
end

-- House (background building)
function EnvironmentSprites.generateHouse()
  local canvas = createCanvas(96, 96)
  drawToCanvas(canvas, function()
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.rectangle("fill", 10, 92, 76, 4)

    -- Walls (cream color)
    love.graphics.setColor(0.961, 0.871, 0.702) -- #F5DEB3
    love.graphics.rectangle("fill", 16, 48, 64, 44)

    -- Wall shading (darker side)
    love.graphics.setColor(0.85, 0.77, 0.62)
    love.graphics.rectangle("fill", 16, 48, 8, 44)

    -- Roof (warm brown)
    love.graphics.setColor(0.545, 0.271, 0.075) -- #8B4513
    love.graphics.polygon("fill", 8, 48, 48, 16, 88, 48)

    -- Roof shading
    love.graphics.setColor(0.45, 0.22, 0.06)
    love.graphics.polygon("fill", 8, 48, 48, 16, 48, 48)

    -- Chimney
    love.graphics.setColor(0.6, 0.3, 0.1)
    love.graphics.rectangle("fill", 60, 28, 8, 20)
    love.graphics.setColor(0.5, 0.25, 0.08)
    love.graphics.rectangle("fill", 58, 24, 12, 4)

    -- Door (brown)
    love.graphics.setColor(0.4, 0.25, 0.1)
    drawRoundedRect(42, 68, 12, 24, 1, true)

    -- Door knob
    love.graphics.setColor(0.8, 0.7, 0.2)
    love.graphics.circle("fill", 52, 80, 1)

    -- Door panels
    love.graphics.setColor(0.35, 0.2, 0.08)
    drawRoundedRect(44, 70, 8, 10, 0.5, true)
    drawRoundedRect(44, 82, 8, 8, 0.5, true)

    -- Windows with warm glow
    local windowColor = {1.0, 0.647, 0.0} -- #FFA500 orange glow

    -- Left window
    love.graphics.setColor(0.3, 0.4, 0.5)
    drawRoundedRect(24, 56, 12, 14, 1, true)
    love.graphics.setColor(windowColor[1], windowColor[2], windowColor[3], 0.8)
    drawRoundedRect(25, 57, 10, 12, 0.5, true)

    -- Window panes
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.setLineWidth(1)
    love.graphics.line(30, 57, 30, 69)
    love.graphics.line(25, 63, 35, 63)

    -- Right window
    love.graphics.setColor(0.3, 0.4, 0.5)
    drawRoundedRect(60, 56, 12, 14, 1, true)
    love.graphics.setColor(windowColor[1], windowColor[2], windowColor[3], 0.8)
    drawRoundedRect(61, 57, 10, 12, 0.5, true)

    -- Window panes
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.line(66, 57, 66, 69)
    love.graphics.line(61, 63, 71, 63)

    -- Upstairs window
    love.graphics.setColor(0.3, 0.4, 0.5)
    drawRoundedRect(42, 32, 12, 12, 1, true)
    love.graphics.setColor(windowColor[1], windowColor[2], windowColor[3], 0.7)
    drawRoundedRect(43, 33, 10, 10, 0.5, true)

    -- Window panes
    love.graphics.setColor(0.3, 0.4, 0.5)
    love.graphics.line(48, 33, 48, 43)
    love.graphics.line(43, 38, 53, 38)
  end)
  return canvas
end

-- Fence (obstacle element)
function EnvironmentSprites.generateFence()
  local canvas = createCanvas(32, 32)
  drawToCanvas(canvas, function()
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.2)
    love.graphics.rectangle("fill", 2, 30, 28, 1)

    -- Wooden picket fence (brown)
    local fenceColor = {0.545, 0.271, 0.075} -- #8B4513
    local darkFence = {0.45, 0.22, 0.06}

    -- Horizontal rails
    love.graphics.setColor(fenceColor)
    love.graphics.rectangle("fill", 0, 12, 32, 3)
    love.graphics.rectangle("fill", 0, 20, 32, 3)

    -- Rail shading
    love.graphics.setColor(darkFence)
    love.graphics.rectangle("fill", 0, 14, 32, 1)
    love.graphics.rectangle("fill", 0, 22, 32, 1)

    -- Vertical pickets
    for i = 0, 3 do
      local x = 2 + i * 8

      -- Picket
      love.graphics.setColor(fenceColor)
      love.graphics.rectangle("fill", x, 6, 4, 24)

      -- Pointed top
      love.graphics.polygon("fill", x, 6, x + 2, 3, x + 4, 6)

      -- Shading
      love.graphics.setColor(darkFence)
      love.graphics.rectangle("fill", x, 6, 1, 24)

      -- Wood grain
      love.graphics.setLineWidth(0.5)
      love.graphics.line(x + 2, 8, x + 2, 28)
    end
  end)
  return canvas
end

-- Grass Patch (ground decoration)
function EnvironmentSprites.generateGrassPatch()
  local canvas = createCanvas(32, 32)
  drawToCanvas(canvas, function()
    local grassColor = {0.565, 0.933, 0.565} -- #90EE90
    local darkGrass = {0.4, 0.7, 0.4}
    local lightGrass = {0.7, 1.0, 0.7}

    -- Base grass (slightly darker)
    love.graphics.setColor(darkGrass)
    for i = 0, 15 do
      local x = love.math.random(2, 30)
      local y = love.math.random(2, 30)
      local len = love.math.random(3, 6)
      love.graphics.setLineWidth(1.5)
      love.graphics.line(x, y, x + love.math.random(-1, 1), y - len)
    end

    -- Mid-layer grass
    love.graphics.setColor(grassColor)
    for i = 0, 20 do
      local x = love.math.random(2, 30)
      local y = love.math.random(2, 30)
      local len = love.math.random(4, 7)
      love.graphics.setLineWidth(1.2)
      love.graphics.line(x, y, x + love.math.random(-2, 2), y - len)
    end

    -- Light highlights
    love.graphics.setColor(lightGrass)
    for i = 0, 10 do
      local x = love.math.random(4, 28)
      local y = love.math.random(4, 28)
      local len = love.math.random(3, 5)
      love.graphics.setLineWidth(1)
      love.graphics.line(x, y, x + love.math.random(-1, 1), y - len)
    end

    -- Add some small flowers for charm
    love.graphics.setColor(1, 1, 0.8)
    for i = 0, 3 do
      local x = love.math.random(6, 26)
      local y = love.math.random(6, 26)
      drawPixelCircle(x, y, 1, true)
    end
  end)
  return canvas
end

-- Street Lamp (provides light)
function EnvironmentSprites.generateStreetLamp()
  local canvas = createCanvas(32, 64)
  drawToCanvas(canvas, function()
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.15)
    love.graphics.ellipse("fill", 16, 62, 4, 1)

    -- Lamp post (metal pole)
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("fill", 14.5, 12, 3, 50)

    -- Pole highlight
    love.graphics.setColor(0.5, 0.5, 0.55)
    love.graphics.rectangle("fill", 15.5, 12, 1, 50)

    -- Base
    love.graphics.setColor(0.25, 0.25, 0.3)
    love.graphics.rectangle("fill", 12, 58, 8, 4)
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("fill", 12, 56, 8, 2)

    -- Lamp fixture top mount
    love.graphics.setColor(0.25, 0.25, 0.3)
    love.graphics.rectangle("fill", 14, 10, 4, 3)

    -- Lamp arm
    love.graphics.setColor(0.3, 0.3, 0.35)
    love.graphics.rectangle("fill", 14, 8, 2, 5)
    love.graphics.rectangle("fill", 14, 8, 8, 2)

    -- Lamp shade (dark)
    love.graphics.setColor(0.2, 0.25, 0.2)
    love.graphics.polygon("fill", 18, 8, 26, 8, 24, 14, 20, 14)

    -- Lamp shade rim
    love.graphics.setColor(0.3, 0.35, 0.3)
    love.graphics.rectangle("fill", 18, 7, 8, 1)

    -- Light glow (orange)
    love.graphics.setColor(1.0, 0.647, 0.0, 0.8) -- #FFA500
    love.graphics.rectangle("fill", 20, 10, 4, 4)

    -- Intense center glow
    love.graphics.setColor(1.0, 0.9, 0.6, 0.9)
    love.graphics.rectangle("fill", 21, 11, 2, 2)

    -- Glow halo (very soft)
    love.graphics.setColor(1.0, 0.647, 0.0, 0.3)
    drawPixelCircle(22, 12, 6, true)
    love.graphics.setColor(1.0, 0.647, 0.0, 0.15)
    drawPixelCircle(22, 12, 10, true)
  end)
  return canvas
end

return EnvironmentSprites
