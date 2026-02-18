-- ShakeEffect: screen shake logic for Raccoon Story

local ShakeEffect = {}

function ShakeEffect.new()
  return {
    shakeX        = 0,
    shakeY        = 0,
    shakeDuration = 0,
    shakeIntensity= 0,
    shakeTime     = 0
  }
end

function ShakeEffect.shake(state, duration, intensity)
  state.shakeDuration  = duration  or 0.3
  state.shakeIntensity = intensity or 5
  state.shakeTime      = 0
  print("[ScreenEffects] Screen shake triggered:", duration, "s at intensity", intensity)
end

function ShakeEffect.update(state, dt)
  if state.shakeDuration > 0 then
    state.shakeTime     = state.shakeTime + dt
    state.shakeDuration = state.shakeDuration - dt

    local progress      = state.shakeDuration / (state.shakeDuration + state.shakeTime)
    local easedProgress = 1 - math.pow(1 - progress, 3)
    local currentIntensity = state.shakeIntensity * easedProgress

    local freq  = 30
    local phase = state.shakeTime * freq
    state.shakeX = (math.sin(phase * 7.3) + math.sin(phase * 5.1)) * currentIntensity * 0.5
    state.shakeY = (math.cos(phase * 6.7) + math.cos(phase * 4.9)) * currentIntensity * 0.5

    if state.shakeDuration <= 0 then
      state.shakeX        = 0
      state.shakeY        = 0
      state.shakeDuration = 0
    end
  else
    state.shakeX = 0
    state.shakeY = 0
  end
end

function ShakeEffect.getOffset(state)
  return state.shakeX, state.shakeY
end

return ShakeEffect
