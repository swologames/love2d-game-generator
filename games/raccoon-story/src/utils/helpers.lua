-- Helper Utilities
-- Common utility functions for Raccoon Story

local Helpers = {}

-- Distance between two points
function Helpers.distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

-- Check if point is inside rectangle
function Helpers.pointInRect(px, py, rx, ry, rw, rh)
  return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- Check if two rectangles overlap (AABB collision)
function Helpers.rectOverlap(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
         x2 < x1 + w1 and
         y1 < y2 + h2 and
         y2 < y1 + h1
end

-- Clamp a value between min and max
function Helpers.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

-- Linear interpolation
function Helpers.lerp(a, b, t)
  return a + (b - a) * t
end

-- Map a value from one range to another
function Helpers.map(value, fromMin, fromMax, toMin, toMax)
  return toMin + (value - fromMin) * (toMax - toMin) / (fromMax - fromMin)
end

-- Angle between two points (in radians)
function Helpers.angle(x1, y1, x2, y2)
  return math.atan2(y2 - y1, x2 - x1)
end

-- Random integer between min and max (inclusive)
function Helpers.randomInt(min, max)
  return math.random(min, max)
end

-- Random float between min and max
function Helpers.randomFloat(min, max)
  return min + math.random() * (max - min)
end

-- Shuffle a table (Fisher-Yates)
function Helpers.shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

-- Deep copy a table
function Helpers.deepCopy(original)
  local copy
  if type(original) == 'table' then
    copy = {}
    for key, value in next, original, nil do
      copy[Helpers.deepCopy(key)] = Helpers.deepCopy(value)
    end
    setmetatable(copy, Helpers.deepCopy(getmetatable(original)))
  else
    copy = original
  end
  return copy
end

-- Check if a table contains a value
function Helpers.tableContains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

-- Format time in MM:SS format
function Helpers.formatTime(seconds)
  local minutes = math.floor(seconds / 60)
  local secs = math.floor(seconds % 60)
  return string.format("%02d:%02d", minutes, secs)
end

-- Wrap text to fit within a width
function Helpers.wrapText(text, font, maxWidth)
  local words = {}
  for word in text:gmatch("%S+") do
    table.insert(words, word)
  end
  
  local lines = {}
  local currentLine = ""
  
  for _, word in ipairs(words) do
    local testLine = currentLine == "" and word or (currentLine .. " " .. word)
    local width = font:getWidth(testLine)
    
    if width > maxWidth then
      table.insert(lines, currentLine)
      currentLine = word
    else
      currentLine = testLine
    end
  end
  
  if currentLine ~= "" then
    table.insert(lines, currentLine)
  end
  
  return lines
end

return Helpers
