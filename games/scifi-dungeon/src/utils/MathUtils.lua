-- src/utils/MathUtils.lua
-- Mathematical utilities for raycasting and vector operations

local MathUtils = {}

-- ─── Vector Operations ───────────────────────────────────────────────────────

-- Calculate distance between two points
function MathUtils.distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

-- Normalize a vector (returns unit vector)
function MathUtils.normalize(x, y)
  local len = math.sqrt(x * x + y * y)
  if len == 0 then
    return 0, 0
  end
  return x / len, y / len
end

-- Dot product of two vectors
function MathUtils.dot(x1, y1, x2, y2)
  return x1 * x2 + y1 * y2
end

-- Rotate a vector by angle (in radians)
function MathUtils.rotate(x, y, angle)
  local cos = math.cos(angle)
  local sin = math.sin(angle)
  return x * cos - y * sin, x * sin + y * cos
end

-- ─── Raycasting Helpers ─────────────────────────────────────────────────────

-- Calculate the next grid intersection for a ray
-- Returns the distance to the next X-aligned and Y-aligned grid lines
function MathUtils.calculateDDA(rayX, rayY, rayDirX, rayDirY)
  -- Which box of the map we're in
  local mapX = math.floor(rayX)
  local mapY = math.floor(rayY)
  
  -- Length of ray from one x or y-side to next x or y-side
  local deltaDistX = math.abs(1 / rayDirX)
  local deltaDistY = math.abs(1 / rayDirY)
  
  -- What direction to step in x or y-direction (either +1 or -1)
  local stepX, stepY
  
  -- Length of ray from current position to next x or y-side
  local sideDistX, sideDistY
  
  -- Calculate step and initial sideDist
  if rayDirX < 0 then
    stepX = -1
    sideDistX = (rayX - mapX) * deltaDistX
  else
    stepX = 1
    sideDistX = (mapX + 1.0 - rayX) * deltaDistX
  end
  
  if rayDirY < 0 then
    stepY = -1
    sideDistY = (rayY - mapY) * deltaDistY
  else
    stepY = 1
    sideDistY = (mapY + 1.0 - rayY) * deltaDistY
  end
  
  return {
    mapX = mapX,
    mapY = mapY,
    sideDistX = sideDistX,
    sideDistY = sideDistY,
    deltaDistX = deltaDistX,
    deltaDistY = deltaDistY,
    stepX = stepX,
    stepY = stepY
  }
end

-- Perform DDA step (advances to next grid cell)
function MathUtils.ddaStep(ddaState)
  local side -- 0 = vertical wall hit, 1 = horizontal wall hit
  
  -- Jump to next map square in x or y-direction
  if ddaState.sideDistX < ddaState.sideDistY then
    ddaState.sideDistX = ddaState.sideDistX + ddaState.deltaDistX
    ddaState.mapX = ddaState.mapX + ddaState.stepX
    side = 0
  else
    ddaState.sideDistY = ddaState.sideDistY + ddaState.deltaDistY
    ddaState.mapY = ddaState.mapY + ddaState.stepY
    side = 1
  end
  
  return side
end

-- Calculate perpendicular wall distance (corrects fish-eye effect)
function MathUtils.calculatePerpDistance(ddaState, rayDirX, rayDirY, side)
  if side == 0 then
    return (ddaState.mapX - ddaState.rayPosX + (1 - ddaState.stepX) / 2) / rayDirX
  else
    return (ddaState.mapY - ddaState.rayPosY + (1 - ddaState.stepY) / 2) / rayDirY
  end
end

-- ─── Interpolation ──────────────────────────────────────────────────────────

-- Linear interpolation
function MathUtils.lerp(a, b, t)
  return a + (b - a) * t
end

-- Clamp a value between min and max
function MathUtils.clamp(value, min, max)
  return math.max(min, math.min(max, value))
end

-- ─── Grid Utilities ─────────────────────────────────────────────────────────

-- Check if a grid position is valid
function MathUtils.isValidGridPos(x, y, mapWidth, mapHeight)
  return x >= 0 and x < mapWidth and y >= 0 and y < mapHeight
end

-- Convert world coordinates to grid coordinates
function MathUtils.worldToGrid(x, y)
  return math.floor(x), math.floor(y)
end

-- Convert grid coordinates to world coordinates (center of cell)
function MathUtils.gridToWorld(gridX, gridY)
  return gridX + 0.5, gridY + 0.5
end

-- ─── Angle Utilities ────────────────────────────────────────────────────────

-- Normalize angle to range [0, 2π)
function MathUtils.normalizeAngle(angle)
  while angle < 0 do
    angle = angle + math.pi * 2
  end
  while angle >= math.pi * 2 do
    angle = angle - math.pi * 2
  end
  return angle
end

-- Convert degrees to radians
function MathUtils.toRadians(degrees)
  return degrees * math.pi / 180
end

-- Convert radians to degrees
function MathUtils.toDegrees(radians)
  return radians * 180 / math.pi
end

-- ─── Direction Helpers ──────────────────────────────────────────────────────

-- Get direction vector from angle
function MathUtils.angleToDirection(angle)
  return math.cos(angle), math.sin(angle)
end

-- Get angle from direction vector
function MathUtils.directionToAngle(dx, dy)
  return math.atan2(dy, dx)
end

-- Get cardinal direction from angle (N=0, E=1, S=2, W=3)
function MathUtils.angleToCardinal(angle)
  local normalized = MathUtils.normalizeAngle(angle)
  local deg = MathUtils.toDegrees(normalized)
  
  if deg >= 315 or deg < 45 then
    return 0 -- North
  elseif deg >= 45 and deg < 135 then
    return 1 -- East
  elseif deg >= 135 and deg < 225 then
    return 2 -- South
  else
    return 3 -- West
  end
end

return MathUtils
