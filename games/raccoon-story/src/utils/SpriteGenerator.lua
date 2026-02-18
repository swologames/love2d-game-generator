-- Sprite Generator
-- Programmatically generates sprite graphics for the game
-- Creates Love2D canvases with hand-drawn style pixel art

local SpriteGenerator = {}

-- SCALE FACTOR - increase all sprites by this amount
local SCALE = 2

-- Helper function to create a new canvas (scaled)
local function createCanvas(width, height)
  return love.graphics.newCanvas(width * SCALE, height * SCALE)
end

-- Helper to draw with proper canvas context
local function drawToCanvas(canvas, drawFunc)
  love.graphics.push("all")
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0, 0)
  -- Apply scale transformation for all drawing
  love.graphics.scale(SCALE, SCALE)
  drawFunc()
  love.graphics.setCanvas()
  love.graphics.pop()
end

-- Draw a pixel-perfect circle (filled)
local function drawPixelCircle(cx, cy, radius, filled)
  local mode = filled and "fill" or "line"
  love.graphics.circle(mode, cx, cy, radius, radius * 4)
end

-- Draw a rounded rectangle
local function drawRoundedRect(x, y, w, h, r, filled)
  local mode = filled and "fill" or "line"
  love.graphics.rectangle(mode, x, y, w, h, r, r)
end

-----------------------------------------------------------
-- PLAYER RACCOON SPRITES
-----------------------------------------------------------

-- Generate Player Idle Animation (4 frames)
function SpriteGenerator.generatePlayerIdle()
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
function SpriteGenerator.generatePlayerWalk()
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
function SpriteGenerator.generatePlayerDash()
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

-----------------------------------------------------------
-- TRASH ITEM SPRITES
-----------------------------------------------------------

-- Pizza Slice
function SpriteGenerator.generatePizzaSlice()
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
function SpriteGenerator.generateBurger()
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
function SpriteGenerator.generateDonutBox()
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
function SpriteGenerator.generateTrashBag()
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

-----------------------------------------------------------
-- ENEMY SPRITES
-----------------------------------------------------------

-- Human (simplified person shape)
function SpriteGenerator.generateHuman()
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
function SpriteGenerator.generateDog()
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
function SpriteGenerator.generateHumanWalk()
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
function SpriteGenerator.generateDogRun()
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
function SpriteGenerator.generatePossum()
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
function SpriteGenerator.generateCat()
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
function SpriteGenerator.generateCrow()
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

-----------------------------------------------------------
-- ENVIRONMENT SPRITES
-----------------------------------------------------------

-- Bush (hiding spot)
function SpriteGenerator.generateBush()
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
function SpriteGenerator.generateTrashBin()
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

-----------------------------------------------------------
-- UTILITY FUNCTIONS
-----------------------------------------------------------

-- Generate all sprites and return them in a table
function SpriteGenerator.generateAll()
  print("[SpriteGenerator] Generating all sprites...")
  
  local sprites = {
    player = {
      idle = SpriteGenerator.generatePlayerIdle(),
      walk = SpriteGenerator.generatePlayerWalk(),
      dash = SpriteGenerator.generatePlayerDash()
    },
    trash = {
      pizza = SpriteGenerator.generatePizzaSlice(),
      burger = SpriteGenerator.generateBurger(),
      donut = SpriteGenerator.generateDonutBox(),
      bag = SpriteGenerator.generateTrashBag()
    },
    enemies = {
      human = SpriteGenerator.generateHuman(),
      humanWalk = SpriteGenerator.generateHumanWalk(),
      dog = SpriteGenerator.generateDog(),
      dogRun = SpriteGenerator.generateDogRun(),
      possum = SpriteGenerator.generatePossum(),
      cat = SpriteGenerator.generateCat(),
      crow = SpriteGenerator.generateCrow()
    },
    environment = {
      bush = SpriteGenerator.generateBush(),
      trashBin = SpriteGenerator.generateTrashBin()
    }
  }
  
  print("[SpriteGenerator] All sprites generated successfully!")
  return sprites
end

return SpriteGenerator
