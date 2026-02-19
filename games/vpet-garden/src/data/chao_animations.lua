-- data/chao_animations.lua
-- Animation state configuration used by ChaoAnimator.
-- Each state: duration (seconds per "frame cycle"), color offsets, scale modifiers.

return {
  states = {
    idle = {
      cycleDuration = 2.0,
      bobAmplitude  = 2,      -- pixels of vertical bob
      bobSpeed      = 1.2,
      colorTint     = { 0.75, 0.88, 0.90 },
      scaleX        = 1.0,
      scaleY        = 1.0,
      eyeOpen       = 1.0,
    },
    wandering = {
      cycleDuration = 1.2,
      bobAmplitude  = 3,
      bobSpeed      = 2.0,
      colorTint     = { 0.72, 0.85, 0.88 },
      scaleX        = 1.0,
      scaleY        = 1.0,
      eyeOpen       = 1.0,
    },
    happy = {
      cycleDuration = 0.5,
      bobAmplitude  = 6,
      bobSpeed      = 4.0,
      colorTint     = { 0.85, 0.95, 0.75 },
      scaleX        = 1.05,
      scaleY        = 1.05,
      eyeOpen       = 1.0,
    },
    eating = {
      cycleDuration = 0.8,
      bobAmplitude  = 1,
      bobSpeed      = 1.5,
      colorTint     = { 0.80, 0.90, 0.72 },
      scaleX        = 1.0,
      scaleY        = 0.95,
      eyeOpen       = 0.5,   -- squinting happily
    },
    sleeping = {
      cycleDuration = 3.0,
      bobAmplitude  = 0.5,
      bobSpeed      = 0.4,
      colorTint     = { 0.65, 0.75, 0.85 },
      scaleX        = 1.0,
      scaleY        = 0.90,
      eyeOpen       = 0.0,   -- eyes closed
    },
    petted = {
      cycleDuration = 0.4,
      bobAmplitude  = 5,
      bobSpeed      = 5.0,
      colorTint     = { 0.90, 0.90, 0.60 },
      scaleX        = 1.08,
      scaleY        = 1.08,
      eyeOpen       = 1.0,
    },
    training = {
      cycleDuration = 0.3,
      bobAmplitude  = 4,
      bobSpeed      = 6.0,
      colorTint     = { 0.95, 0.80, 0.55 },  -- warm exertion glow
      scaleX        = 1.10,
      scaleY        = 0.92,                  -- squish from effort
      eyeOpen       = 0.6,
    },
    dragging = {
      cycleDuration = 0.15,
      bobAmplitude  = 0,           -- no bob; rotation handles the wiggle
      bobSpeed      = 0,
      colorTint     = { 0.82, 0.92, 0.98 }, -- pale/surprised
      scaleX        = 1.18,
      scaleY        = 0.76,        -- squished: held from above
      eyeOpen       = 1.0,         -- wide surprised eyes
    },
    tired = {
      cycleDuration = 3.5,
      bobAmplitude  = 0.8,         -- barely moving
      bobSpeed      = 0.5,
      colorTint     = { 0.58, 0.65, 0.72 }, -- dull, desaturated blue-grey
      scaleX        = 0.95,
      scaleY        = 0.88,        -- slumped down
      eyeOpen       = 0.15,        -- nearly closed, heavy eyelids
    },
  },

  -- Transition durations (how long to blend between states)
  transitionTime = 0.3,
}
