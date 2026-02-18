-- EnemySprites.lua
-- Generates enemy sprites: human, dog, human walk, dog run, possum, cat, crow

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

local EnemySprites = {}

-- Human (simplified person shape)
function EnemySprites.generateHuman()
  local canvas = createCanvas(32, 48)
  drawToCanvas(canvas, function()
    -- Legs
    love.graphics.setColor(0.2, 0.3, 0.6) -- Blue pants
    love.graphics.rectangle("fill", 11, 30, 5, 16)
    love.graphics.rectangle("fill", 16, 30, 5, 16)

    -- Shoes
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 10, 44, 6, 3)
    love.graphics.rectangle("fill", 16, 44, 6, 3)

    -- Body
    love.graphics.setColor(0.8, 0.3, 0.3) -- Red shirt
    drawRoundedRect(9, 18, 14, 14, 2, true)

    -- Arms
    love.graphics.setColor(0.9, 0.7, 0.6) -- Skin tone
    love.graphics.rectangle("fill", 6, 20, 3, 10)
    love.graphics.rectangle("fill", 23, 20, 3, 10)

    -- Hands
    love.graphics.circle("fill", 7.5, 30, 2)
    love.graphics.circle("fill", 24.5, 30, 2)

    -- Neck
    love.graphics.setColor(0.9, 0.7, 0.6)
    love.graphics.rectangle("fill", 14, 16, 4, 3)

    -- Head
    love.graphics.circle("fill", 16, 11, 6)

    -- Hair
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.arc("fill", 16, 10, 6, math.pi, 2 * math.pi)

    -- Eyes (angry)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", 13, 11, 1.5)
    love.graphics.circle("fill", 19, 11, 1.5)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", 13, 11, 0.8)
    love.graphics.circle("fill", 19, 11, 0.8)

    -- Angry eyebrows
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.setLineWidth(2)
    love.graphics.line(11, 9, 14, 10)
    love.graphics.line(18, 10, 21, 9)

    -- Mouth (frown)
    love.graphics.setColor(0.5, 0.2, 0.2)
    love.graphics.arc("line", "open", 16, 15, 2, 0.3, math.pi - 0.3)
  end)
  return canvas
end

-- Dog (simple dog shape)
function EnemySprites.generateDog()
  local canvas = createCanvas(32, 32)
  drawToCanvas(canvas, function()
    -- Tail (behind)
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.circle("fill", 6, 18, 2.5)
    love.graphics.circle("fill", 4, 16, 2)
    love.graphics.circle("fill", 3, 14, 1.5)

    -- Body
    love.graphics.setColor(0.6, 0.4, 0.2) -- Brown
    love.graphics.ellipse("fill", 16, 20, 10, 7)

    -- Legs
    love.graphics.rectangle("fill", 10, 24, 3, 6)
    love.graphics.rectangle("fill", 15, 24, 3, 6)
    love.graphics.rectangle("fill", 20, 24, 3, 6)

    -- Paws
    love.graphics.setColor(0.5, 0.3, 0.15)
    love.graphics.circle("fill", 11.5, 30, 1.8)
    love.graphics.circle("fill", 16.5, 30, 1.8)
    love.graphics.circle("fill", 21.5, 30, 1.8)

    -- Head
    love.graphics.setColor(0.6, 0.4, 0.2)
    love.graphics.circle("fill", 22, 16, 6)

    -- Snout
    love.graphics.setColor(0.7, 0.5, 0.3)
    love.graphics.ellipse("fill", 26, 16, 3, 2.5)

    -- Nose
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.circle("fill", 28, 16, 1.5)

    -- Ears (floppy)
    love.graphics.setColor(0.5, 0.3, 0.15)
    love.graphics.ellipse("fill", 18, 12, 2.5, 4)
    love.graphics.ellipse("fill", 24, 11, 2.5, 4)

    -- Eyes (alert/aggressive)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", 21, 14, 1.5)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", 21, 14, 0.8)

    -- Collar
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.setLineWidth(2)
    love.graphics.arc("line", "open", 22, 18, 6, -0.5, 0.5)
  end)
  return canvas
end

-- Generate Human Walk Animation (4 frames, 8 FPS)
function EnemySprites.generateHumanWalk()
  local frames = {}

  for i = 0, 3 do
    local canvas = createCanvas(32, 48)
    drawToCanvas(canvas, function()
      local walkCycle = math.sin(i / 4 * math.pi * 2)
      local bobOffset = math.abs(walkCycle) * 1.5
      local legOffset = walkCycle * 4
      local armSwing = walkCycle * 3

      -- Legs (alternating walk)
      love.graphics.setColor(0.2, 0.3, 0.6) -- Blue pants
      love.graphics.rectangle("fill", 11, 30 - bobOffset, 5, 16 + legOffset)
      love.graphics.rectangle("fill", 16, 30 - bobOffset, 5, 16 - legOffset)

      -- Shoes
      love.graphics.setColor(0.2, 0.2, 0.2)
      love.graphics.rectangle("fill", 10, 44 + legOffset, 6, 3)
      love.graphics.rectangle("fill", 16, 44 - legOffset, 6, 3)

      -- Body
      love.graphics.setColor(0.8, 0.3, 0.3) -- Red shirt
      drawRoundedRect(9, 18 - bobOffset, 14, 14, 2, true)

      -- Arms (swinging)
      love.graphics.setColor(0.9, 0.7, 0.6) -- Skin tone
      love.graphics.rectangle("fill", 6, 20 - bobOffset + armSwing, 3, 10)
      love.graphics.rectangle("fill", 23, 20 - bobOffset - armSwing, 3, 10)

      -- Hands
      love.graphics.circle("fill", 7.5, 30 - bobOffset + armSwing, 2)
      love.graphics.circle("fill", 24.5, 30 - bobOffset - armSwing, 2)

      -- Neck
      love.graphics.setColor(0.9, 0.7, 0.6)
      love.graphics.rectangle("fill", 14, 16 - bobOffset, 4, 3)

      -- Head (slight bob)
      love.graphics.circle("fill", 16, 11 - bobOffset, 6)

      -- Hair
      love.graphics.setColor(0.3, 0.2, 0.1)
      love.graphics.arc("fill", 16, 10 - bobOffset, 6, math.pi, 2 * math.pi)

      -- Eyes (angry)
      love.graphics.setColor(1, 1, 1)
      love.graphics.circle("fill", 13, 11 - bobOffset, 1.5)
      love.graphics.circle("fill", 19, 11 - bobOffset, 1.5)
      love.graphics.setColor(0, 0, 0)
      love.graphics.circle("fill", 13, 11 - bobOffset, 0.8)
      love.graphics.circle("fill", 19, 11 - bobOffset, 0.8)

      -- Angry eyebrows
      love.graphics.setColor(0.3, 0.2, 0.1)
      love.graphics.setLineWidth(2)
      love.graphics.line(11, 9 - bobOffset, 14, 10 - bobOffset)
      love.graphics.line(18, 10 - bobOffset, 21, 9 - bobOffset)

      -- Mouth (frown)
      love.graphics.setColor(0.5, 0.2, 0.2)
      love.graphics.arc("line", "open", 16, 15 - bobOffset, 2, 0.3, math.pi - 0.3)
    end)

    table.insert(frames, canvas)
  end

  return frames
end

-- Generate Dog Run Animation (6 frames, 12 FPS)
function EnemySprites.generateDogRun()
  local frames = {}

  for i = 0, 5 do
    local canvas = createCanvas(32, 32)
    drawToCanvas(canvas, function()
      local runCycle = math.sin(i / 6 * math.pi * 2)
      local bobOffset = math.abs(runCycle) * 2
      local legOffset = runCycle * 4
      local tailWag = math.cos(i / 6 * math.pi * 4) * 2

      -- Tail (wagging/streaming)
      love.graphics.setColor(0.6, 0.4, 0.2)
      for j = 0, 2 do
        local tailX = 6 - j * 1.5
        local tailY = 18 - bobOffset + tailWag - j
        love.graphics.circle("fill", tailX, tailY, 2.5 - j * 0.5)
      end

      -- Body (bouncing)
      love.graphics.setColor(0.6, 0.4, 0.2) -- Brown
      love.graphics.ellipse("fill", 16, 20 - bobOffset, 10, 7)

      -- Legs (running - gallop motion)
      love.graphics.setColor(0.6, 0.4, 0.2)
      -- Front legs
      love.graphics.rectangle("fill", 10, 24 - bobOffset + math.abs(legOffset), 3, 6 - math.abs(legOffset) * 0.5)
      love.graphics.rectangle("fill", 15, 24 - bobOffset - math.abs(legOffset), 3, 6 + math.abs(legOffset) * 0.5)
      -- Back leg
      love.graphics.rectangle("fill", 20, 24 - bobOffset + legOffset * 0.5, 3, 6)

      -- Paws
      love.graphics.setColor(0.5, 0.3, 0.15)
      love.graphics.circle("fill", 11.5, 30 - bobOffset + math.abs(legOffset), 1.8)
      love.graphics.circle("fill", 16.5, 30 - bobOffset - math.abs(legOffset), 1.8)
      love.graphics.circle("fill", 21.5, 30 - bobOffset + legOffset * 0.5, 1.8)

      -- Head (extended forward when running)
      love.graphics.setColor(0.6, 0.4, 0.2)
      love.graphics.circle("fill", 22 + runCycle, 16 - bobOffset, 6)

      -- Snout
      love.graphics.setColor(0.7, 0.5, 0.3)
      love.graphics.ellipse("fill", 26 + runCycle, 16 - bobOffset, 3, 2.5)

      -- Nose
      love.graphics.setColor(0.1, 0.1, 0.1)
      love.graphics.circle("fill", 28 + runCycle, 16 - bobOffset, 1.5)

      -- Ears (flapping back)
      love.graphics.setColor(0.5, 0.3, 0.15)
      love.graphics.ellipse("fill", 18 + runCycle * 0.5, 12 - bobOffset, 2.5, 4)
      love.graphics.ellipse("fill", 24 + runCycle * 0.5, 11 - bobOffset, 2.5, 4)

      -- Eyes (alert/aggressive)
      love.graphics.setColor(1, 1, 1)
      love.graphics.circle("fill", 21 + runCycle, 14 - bobOffset, 1.5)
      love.graphics.setColor(0, 0, 0)
      love.graphics.circle("fill", 21 + runCycle, 14 - bobOffset, 0.8)

      -- Collar
      love.graphics.setColor(0.8, 0.2, 0.2)
      love.graphics.setLineWidth(2)
      love.graphics.arc("line", "open", 22 + runCycle, 18 - bobOffset, 6, -0.5, 0.5)
    end)

    table.insert(frames, canvas)
  end

  return frames
end

-- Generate Possum (slow competitor)
function EnemySprites.generatePossum()
  local canvas = createCanvas(32, 32)
  drawToCanvas(canvas, function()
    -- Tail (long and rat-like)
    love.graphics.setColor(0.7, 0.7, 0.7)
    for i = 0, 3 do
      local tailX = 8 - i * 2
      local tailY = 18 + i * 1.5
      love.graphics.circle("fill", tailX, tailY, 2 - i * 0.3)
    end

    -- Body (gray-white)
    love.graphics.setColor(0.8, 0.8, 0.75)
    love.graphics.ellipse("fill", 16, 20, 8, 6)

    -- Legs
    love.graphics.setColor(0.7, 0.7, 0.65)
    love.graphics.rectangle("fill", 11, 24, 2, 5)
    love.graphics.rectangle("fill", 15, 24, 2, 5)
    love.graphics.rectangle("fill", 19, 24, 2, 5)

    -- Head
    love.graphics.setColor(0.8, 0.8, 0.75)
    love.graphics.ellipse("fill", 21, 16, 5, 4)

    -- Pointed nose
    love.graphics.setColor(1, 0.8, 0.8)
    love.graphics.polygon("fill", 25, 16, 27, 15, 27, 17)

    -- Black nose tip
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.circle("fill", 27, 16, 0.8)

    -- Ears (rounded)
    love.graphics.setColor(0.9, 0.7, 0.7)
    love.graphics.circle("fill", 18, 13, 2.5)
    love.graphics.circle("fill", 23, 13, 2.5)

    -- Eyes (beady)
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.circle("fill", 20, 15, 1)
    love.graphics.circle("fill", 24, 15, 1)
  end)
  return canvas
end

-- Generate Cat (territorial competitor)
function EnemySprites.generateCat()
  local canvas = createCanvas(32, 32)
  drawToCanvas(canvas, function()
    -- Tail (curved up)
    love.graphics.setColor(0.9, 0.6, 0.3) -- Orange tabby
    for i = 0, 3 do
      local tailX = 6 - i * 0.5
      local tailY = 22 - i * 2
      love.graphics.circle("fill", tailX, tailY, 2 - i * 0.2)
    end

    -- Body
    love.graphics.setColor(0.9, 0.6, 0.3)
    love.graphics.ellipse("fill", 16, 20, 8, 6)

    -- Stripes
    love.graphics.setColor(0.7, 0.4, 0.2)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(12, 18, 20, 18)
    love.graphics.line(12, 22, 20, 22)

    -- Legs
    love.graphics.setColor(0.9, 0.6, 0.3)
    love.graphics.rectangle("fill", 11, 23, 2, 5)
    love.graphics.rectangle("fill", 15, 23, 2, 5)
    love.graphics.rectangle("fill", 19, 23, 2, 5)

    -- Paws (white)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", 12, 28, 1.2)
    love.graphics.circle("fill", 16, 28, 1.2)
    love.graphics.circle("fill", 20, 28, 1.2)

    -- Head
    love.graphics.setColor(0.9, 0.6, 0.3)
    love.graphics.circle("fill", 21, 16, 5)

    -- Face stripes
    love.graphics.setColor(0.7, 0.4, 0.2)
    love.graphics.setLineWidth(1)
    love.graphics.line(19, 14, 17, 15)
    love.graphics.line(23, 14, 25, 15)

    -- Muzzle (white)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", 24, 17, 2)

    -- Nose (pink)
    love.graphics.setColor(1, 0.6, 0.7)
    love.graphics.polygon("fill", 24, 16, 23.5, 17, 24.5, 17)

    -- Ears (pointed)
    love.graphics.setColor(0.9, 0.6, 0.3)
    love.graphics.polygon("fill", 17, 13, 19, 11, 21, 13)
    love.graphics.polygon("fill", 21, 13, 23, 11, 25, 13)

    -- Inner ears (pink)
    love.graphics.setColor(1, 0.7, 0.8)
    love.graphics.polygon("fill", 18, 12.5, 19, 12, 20, 12.5)
    love.graphics.polygon("fill", 22, 12.5, 23, 12, 24, 12.5)

    -- Eyes (slitted, alert)
    love.graphics.setColor(0.3, 0.8, 0.3)
    love.graphics.ellipse("fill", 20, 15, 1.5, 2)
    love.graphics.ellipse("fill", 24, 15, 1.5, 2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 19.5, 14, 1, 2)
    love.graphics.rectangle("fill", 23.5, 14, 1, 2)

    -- Whiskers
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.setLineWidth(0.5)
    love.graphics.line(24, 17, 29, 16)
    love.graphics.line(24, 18, 29, 18)
    love.graphics.line(24, 17, 29, 19)
  end)
  return canvas
end

-- Generate Crow (flying thief)
function EnemySprites.generateCrow()
  local canvas = createCanvas(32, 32)
  drawToCanvas(canvas, function()
    -- Tail feathers
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.polygon("fill", 8, 20, 6, 22, 10, 24)
    love.graphics.polygon("fill", 8, 20, 10, 24, 12, 22)

    -- Body (black)
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.ellipse("fill", 18, 18, 7, 5)

    -- Wing (extended slightly)
    love.graphics.setColor(0.15, 0.15, 0.2)
    love.graphics.ellipse("fill", 16, 16, 6, 8, math.pi / 6)

    -- Wing feathers
    love.graphics.setColor(0.1, 0.1, 0.15)
    for i = 0, 2 do
      love.graphics.line(14, 12 + i * 3, 10, 14 + i * 3)
    end

    -- Legs (thin)
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(17, 22, 17, 27)
    love.graphics.line(19, 22, 19, 27)

    -- Feet
    love.graphics.line(17, 27, 15, 28)
    love.graphics.line(17, 27, 19, 28)
    love.graphics.line(19, 27, 17, 28)
    love.graphics.line(19, 27, 21, 28)

    -- Head
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.circle("fill", 23, 14, 4)

    -- Beak (yellow)
    love.graphics.setColor(0.8, 0.7, 0.2)
    love.graphics.polygon("fill", 26, 14, 29, 13, 29, 15)

    -- Eye (beady)
    love.graphics.setColor(1, 1, 0.8)
    love.graphics.circle("fill", 24, 13, 1.2)
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", 24, 13, 0.6)
  end)
  return canvas
end

return EnemySprites
