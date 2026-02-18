-- PlayerSprites.lua
-- Generates raccoon player sprite animations (idle, walk, dash)

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

local PlayerSprites = {}

-- Generate Player Idle Animation (4 frames)
function PlayerSprites.generatePlayerIdle()
  local frames = {}

  for i = 0, 3 do
    local canvas = createCanvas(32, 32)
    drawToCanvas(canvas, function()
      local breathOffset = math.sin(i / 4 * math.pi * 2) * 1

      -- Body (gray oval)
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.ellipse("fill", 16, 18 + breathOffset, 10, 12)

      -- Belly (lighter)
      love.graphics.setColor(0.8, 0.8, 0.8)
      love.graphics.ellipse("fill", 16, 20 + breathOffset, 6, 8)

      -- Tail (striped, behind body)
      love.graphics.setColor(0.6, 0.6, 0.6)
      for j = 0, 2 do
        local tailX = 10 - j * 3
        local tailY = 22 + breathOffset + j * 2
        drawPixelCircle(tailX, tailY, 3 - j * 0.5, true)
        -- Stripes
        love.graphics.setColor(0.3, 0.3, 0.3)
        drawPixelCircle(tailX, tailY, 2 - j * 0.3, true)
        love.graphics.setColor(0.6, 0.6, 0.6)
      end

      -- Head (gray circle)
      love.graphics.setColor(0.6, 0.6, 0.6)
      drawPixelCircle(16, 10 + breathOffset, 8, true)

      -- Mask (black)
      love.graphics.setColor(0.2, 0.2, 0.2)
      -- Left eye patch
      drawPixelCircle(13, 9 + breathOffset, 3, true)
      -- Right eye patch
      drawPixelCircle(19, 9 + breathOffset, 3, true)
      -- Bridge connector
      love.graphics.rectangle("fill", 13, 8 + breathOffset, 6, 2)

      -- Eyes (white with black pupils)
      love.graphics.setColor(1, 1, 1)
      drawPixelCircle(13, 9 + breathOffset, 2, true)
      drawPixelCircle(19, 9 + breathOffset, 2, true)
      love.graphics.setColor(0, 0, 0)
      drawPixelCircle(13, 9 + breathOffset, 1, true)
      drawPixelCircle(19, 9 + breathOffset, 1, true)

      -- Ears (gray triangles)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.polygon("fill", 10, 5 + breathOffset, 12, 3 + breathOffset, 14, 6 + breathOffset)
      love.graphics.polygon("fill", 22, 5 + breathOffset, 20, 3 + breathOffset, 18, 6 + breathOffset)

      -- Pink inner ears
      love.graphics.setColor(1, 0.7, 0.7)
      love.graphics.polygon("fill", 11, 5 + breathOffset, 12, 4 + breathOffset, 13, 6 + breathOffset)
      love.graphics.polygon("fill", 21, 5 + breathOffset, 20, 4 + breathOffset, 19, 6 + breathOffset)

      -- Nose (pink)
      love.graphics.setColor(1, 0.6, 0.6)
      drawPixelCircle(16, 12 + breathOffset, 1.5, true)

      -- Little arms (at sides)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.circle("fill", 9, 18 + breathOffset, 2.5)
      love.graphics.circle("fill", 23, 18 + breathOffset, 2.5)
    end)

    table.insert(frames, canvas)
  end

  return frames
end

-- Generate Player Walk Animation (6 frames)
function PlayerSprites.generatePlayerWalk()
  local frames = {}

  for i = 0, 5 do
    local canvas = createCanvas(32, 32)
    drawToCanvas(canvas, function()
      local walkCycle = math.sin(i / 6 * math.pi * 2)
      local bobOffset = math.abs(walkCycle) * 2
      local legOffset = walkCycle * 3

      -- Body (gray oval)
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.ellipse("fill", 16, 18 - bobOffset, 10, 12)

      -- Belly (lighter)
      love.graphics.setColor(0.8, 0.8, 0.8)
      love.graphics.ellipse("fill", 16, 20 - bobOffset, 6, 8)

      -- Animated tail (swaying)
      love.graphics.setColor(0.6, 0.6, 0.6)
      for j = 0, 2 do
        local tailX = 10 - j * 3 + walkCycle * (j + 1)
        local tailY = 22 - bobOffset + j * 2
        drawPixelCircle(tailX, tailY, 3 - j * 0.5, true)
        -- Stripes
        love.graphics.setColor(0.3, 0.3, 0.3)
        drawPixelCircle(tailX, tailY, 2 - j * 0.3, true)
        love.graphics.setColor(0.6, 0.6, 0.6)
      end

      -- Head (tilts slightly with walk)
      love.graphics.setColor(0.6, 0.6, 0.6)
      drawPixelCircle(16, 10 - bobOffset, 8, true)

      -- Mask
      love.graphics.setColor(0.2, 0.2, 0.2)
      drawPixelCircle(13, 9 - bobOffset, 3, true)
      drawPixelCircle(19, 9 - bobOffset, 3, true)
      love.graphics.rectangle("fill", 13, 8 - bobOffset, 6, 2)

      -- Eyes
      love.graphics.setColor(1, 1, 1)
      drawPixelCircle(13, 9 - bobOffset, 2, true)
      drawPixelCircle(19, 9 - bobOffset, 2, true)
      love.graphics.setColor(0, 0, 0)
      drawPixelCircle(13, 9 - bobOffset, 1, true)
      drawPixelCircle(19, 9 - bobOffset, 1, true)

      -- Ears
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.polygon("fill", 10, 5 - bobOffset, 12, 3 - bobOffset, 14, 6 - bobOffset)
      love.graphics.polygon("fill", 22, 5 - bobOffset, 20, 3 - bobOffset, 18, 6 - bobOffset)
      love.graphics.setColor(1, 0.7, 0.7)
      love.graphics.polygon("fill", 11, 5 - bobOffset, 12, 4 - bobOffset, 13, 6 - bobOffset)
      love.graphics.polygon("fill", 21, 5 - bobOffset, 20, 4 - bobOffset, 19, 6 - bobOffset)

      -- Nose
      love.graphics.setColor(1, 0.6, 0.6)
      drawPixelCircle(16, 12 - bobOffset, 1.5, true)

      -- Animated arms (swinging)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.circle("fill", 9 - walkCycle, 18 - bobOffset, 2.5)
      love.graphics.circle("fill", 23 + walkCycle, 18 - bobOffset, 2.5)

      -- Legs (simplified, alternating)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.circle("fill", 13 + legOffset, 28, 2)
      love.graphics.circle("fill", 19 - legOffset, 28, 2)
    end)

    table.insert(frames, canvas)
  end

  return frames
end

-- Generate Player Dash Animation (3 frames)
function PlayerSprites.generatePlayerDash()
  local frames = {}

  for i = 0, 2 do
    local canvas = createCanvas(32, 32)
    drawToCanvas(canvas, function()
      -- Dash creates a speed blur effect and stretched pose
      local stretchFactor = 1 + (i == 1 and 0.3 or 0.15)
      local squashFactor = 1 - (i == 1 and 0.2 or 0.1)
      local speedLine = i * 3

      -- Speed lines (motion blur)
      love.graphics.setColor(0.7, 0.7, 0.7, 0.3)
      for j = 1, 3 do
        love.graphics.line(4 - speedLine - j * 2, 15 + j * 2, 10 - speedLine - j * 2, 15 + j * 2)
      end

      -- Stretched body (elongated for speed)
      love.graphics.setColor(0.6, 0.6, 0.6)
      love.graphics.ellipse("fill", 16, 18, 10 * stretchFactor, 12 * squashFactor)

      -- Belly (lighter, stretched)
      love.graphics.setColor(0.8, 0.8, 0.8)
      love.graphics.ellipse("fill", 16, 20, 6 * stretchFactor, 8 * squashFactor)

      -- Tail (streaming behind, more dramatic)
      love.graphics.setColor(0.6, 0.6, 0.6)
      for j = 0, 3 do
        local tailX = 8 - j * 4
        local tailY = 20 + j * 1
        drawPixelCircle(tailX, tailY, 3.5 - j * 0.6, true)
        -- Stripes
        love.graphics.setColor(0.3, 0.3, 0.3)
        drawPixelCircle(tailX, tailY, 2.5 - j * 0.4, true)
        love.graphics.setColor(0.6, 0.6, 0.6)
      end

      -- Head (leaning forward)
      love.graphics.setColor(0.6, 0.6, 0.6)
      drawPixelCircle(18, 10, 8, true)

      -- Mask
      love.graphics.setColor(0.2, 0.2, 0.2)
      drawPixelCircle(15, 9, 3, true)
      drawPixelCircle(21, 9, 3, true)
      love.graphics.rectangle("fill", 15, 8, 6, 2)

      -- Eyes (determined expression)
      love.graphics.setColor(1, 1, 1)
      drawPixelCircle(15, 9, 2, true)
      drawPixelCircle(21, 9, 2, true)
      love.graphics.setColor(0, 0, 0)
      drawPixelCircle(16, 9, 1, true) -- Looking forward
      drawPixelCircle(22, 9, 1, true)

      -- Ears
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.polygon("fill", 12, 5, 14, 3, 16, 6)
      love.graphics.polygon("fill", 24, 5, 22, 3, 20, 6)
      love.graphics.setColor(1, 0.7, 0.7)
      love.graphics.polygon("fill", 13, 5, 14, 4, 15, 6)
      love.graphics.polygon("fill", 23, 5, 22, 4, 21, 6)

      -- Nose
      love.graphics.setColor(1, 0.6, 0.6)
      drawPixelCircle(18, 12, 1.5, true)

      -- Arms (stretched back for speed)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.circle("fill", 7, 20, 2.5)
      love.graphics.circle("fill", 9, 22, 2.5)

      -- Front legs (extended forward)
      love.graphics.setColor(0.5, 0.5, 0.5)
      love.graphics.circle("fill", 22, 26, 2)
      love.graphics.circle("fill", 24, 27, 2)
    end)

    table.insert(frames, canvas)
  end

  return frames
end

return PlayerSprites
