-- VignetteEffect: vignette overlay + lighting helpers for Raccoon Story

local VignetteEffect = {}

function VignetteEffect.new(screenWidth, screenHeight)
  local state = {
    vignetteIntensity       = 0.3,
    vignetteTargetIntensity = 0.3,
    vignetteDangerBoost     = 0,
    vignetteCanvas          = nil,
    screenWidth             = screenWidth,
    screenHeight            = screenHeight
  }
  state.vignetteCanvas = VignetteEffect.createCanvas(screenWidth, screenHeight)
  return state
end

function VignetteEffect.createCanvas(w, h)
  local canvas = love.graphics.newCanvas(w, h)
  love.graphics.setCanvas(canvas)
  love.graphics.clear(0, 0, 0, 0)

  local centerX = w / 2
  local centerY = h / 2
  local maxDist = math.sqrt(centerX * centerX + centerY * centerY)

  for y = 0, h do
    for x = 0, w do
      local dx = x - centerX
      local dy = y - centerY
      local dist = math.sqrt(dx * dx + dy * dy)
      local alpha = math.pow(dist / maxDist, 2) * 0.8
      if alpha > 0.01 and (x % 4 == 0 and y % 4 == 0) then
        love.graphics.setColor(0.1, 0.1, 0.2, alpha)
        love.graphics.rectangle("fill", x, y, 4, 4)
      end
    end
  end

  love.graphics.setCanvas()
  print("[ScreenEffects] Vignette canvas created")
  return canvas
end

function VignetteEffect.setIntensity(state, intensity, immediate)
  state.vignetteTargetIntensity = intensity
  if immediate then state.vignetteIntensity = intensity end
end

function VignetteEffect.setDanger(state, dangerLevel)
  state.vignetteDangerBoost = dangerLevel * 0.3
end

function VignetteEffect.update(state, dt)
  local target = state.vignetteTargetIntensity + state.vignetteDangerBoost
  state.vignetteIntensity = state.vignetteIntensity + (target - state.vignetteIntensity) * 3 * dt
end

function VignetteEffect.draw(state)
  if state.vignetteIntensity <= 0 then return end
  local lg = love.graphics
  lg.setColor(1, 1, 1, state.vignetteIntensity)
  lg.setBlendMode("multiply", "premultiplied")
  lg.draw(state.vignetteCanvas, 0, 0)
  lg.setBlendMode("alpha")
  lg.setColor(1, 1, 1, 1)
end

-- Lighting helpers (street lamp, window, moonlight)

function VignetteEffect.drawStreetLampGlow(x, y, radius, intensity)
  local lg = love.graphics
  radius    = radius    or 80
  intensity = intensity or 0.6
  lg.setBlendMode("add")
  local steps = 8
  for i = steps, 1, -1 do
    local r     = radius * (i / steps)
    local alpha = intensity * (i / steps) * 0.3
    lg.setColor(1, 0.647, 0, alpha)
    lg.circle("fill", x, y, r)
  end
  lg.setBlendMode("alpha")
  lg.setColor(1, 1, 1, 1)
end

function VignetteEffect.drawWindowLight(x, y, width, height, intensity)
  local lg = love.graphics
  width     = width     or 20
  height    = height    or 30
  intensity = intensity or 0.5
  lg.setBlendMode("add")
  lg.setColor(1, 0.9, 0.6, intensity * 0.4)
  lg.rectangle("fill", x - width/2, y - height/2, width, height)
  lg.setColor(1, 0.9, 0.6, intensity * 0.2)
  lg.rectangle("fill", x - width/2 - 5, y - height/2 - 5, width + 10, height + 10)
  lg.setBlendMode("alpha")
  lg.setColor(1, 1, 1, 1)
end

function VignetteEffect.drawAmbientMoonlight(screenWidth, screenHeight)
  local lg = love.graphics
  lg.setBlendMode("add")
  lg.setColor(0.6, 0.7, 0.9, 0.03)
  lg.rectangle("fill", 0, 0, screenWidth, screenHeight)
  lg.setBlendMode("alpha")
  lg.setColor(1, 1, 1, 1)
end

return VignetteEffect
