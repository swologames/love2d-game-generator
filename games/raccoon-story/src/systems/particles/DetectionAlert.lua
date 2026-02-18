-- DetectionAlert: red "!" burst effect when an enemy spots the player

local DetectionAlert = {}

-- Push a new alert into burstEffects
function DetectionAlert.emit(x, y, burstEffects)
  local alert = {
    x = x,
    y = y - 40,
    life = 1.0,
    maxLife = 1.0,
    scale = 0,
    targetScale = 1.5,
    bounce = 0,
    type = "alert"
  }
  table.insert(burstEffects, alert)
  print("[ParticleSystem] Detection alert at", x, y)
end

-- Update a single alert effect. Returns true if still alive.
function DetectionAlert.update(effect, dt)
  effect.life = effect.life - dt
  effect.bounce = effect.bounce + dt * 10
  local bounceProgress = math.min(1, effect.bounce)
  effect.scale = effect.targetScale * (1 - math.pow(1 - bounceProgress, 3))
  return effect.life > 0
end

-- Draw a single alert effect
function DetectionAlert.draw(effect)
  local lg = love.graphics
  lg.setColor(1, 0.42, 0.42, math.min(1, effect.life))
  lg.push()
  lg.translate(effect.x, effect.y)
  lg.scale(effect.scale, effect.scale)
  lg.print("!", -5, -10, 0, 2, 2)
  lg.pop()
end

return DetectionAlert
