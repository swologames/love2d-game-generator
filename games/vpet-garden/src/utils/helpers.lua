-- utils/helpers.lua
-- General-purpose utility functions

local helpers = {}

--- Linear interpolation between a and b by t (0..1)
function helpers.lerp(a, b, t)
  return a + (b - a) * t
end

--- Clamp value v between lo and hi
function helpers.clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

--- Euclidean distance between two points
function helpers.distance(x1, y1, x2, y2)
  local dx = x2 - x1
  local dy = y2 - y1
  return math.sqrt(dx * dx + dy * dy)
end

--- Check if point (px, py) is inside circle (cx, cy, r)
function helpers.pointInCircle(px, py, cx, cy, r)
  return helpers.distance(px, py, cx, cy) <= r
end

--- Draw a rounded rectangle using love.graphics
-- mode: "fill" or "line"
function helpers.drawRoundedRect(mode, x, y, w, h, r)
  r = math.min(r or 8, w / 2, h / 2)
  love.graphics.rectangle(mode, x, y, w, h, r, r)
end

--- Random float between lo and hi
function helpers.randFloat(lo, hi)
  return lo + math.random() * (hi - lo)
end

--- Angle from point (x1,y1) toward (x2,y2) in radians
function helpers.angleTo(x1, y1, x2, y2)
  return math.atan2(y2 - y1, x2 - x1)
end

--- Normalise an angle to [-pi, pi]
function helpers.normaliseAngle(a)
  while a >  math.pi do a = a - 2 * math.pi end
  while a < -math.pi do a = a + 2 * math.pi end
  return a
end

--- Simple timer helper: returns true once per interval, accumulates dt
function helpers.newTimer(interval)
  return { t = 0, interval = interval }
end

function helpers.tickTimer(timer, dt)
  timer.t = timer.t + dt
  if timer.t >= timer.interval then
    timer.t = timer.t - timer.interval
    return true
  end
  return false
end

return helpers
