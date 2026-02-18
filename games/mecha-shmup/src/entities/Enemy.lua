-- Enemy.lua
-- Enemy entity for Mecha Shmup

local Enemy = {}
Enemy.__index = Enemy

-- Static counter for unique enemy IDs
local nextEnemyId = 1

-- Enemy types from GDD Appendix B
local ENEMY_TYPES = {
  scout = {
    name = "Tau Scout",
    health = 50,
    speed = 120,
    size = 22,
    color = {1, 0.3, 0.3},
    score = 100,
    shootInterval = 1.5,
    bulletSpeed = 220,
    bulletPattern = "single_straight",
    bulletTypes = {ethereal = 2, solid = 1}
  },
  interceptor = {
    name = "Tau Interceptor",
    health = 100,
    speed = 80,
    size = 30,
    color = {1, 0.5, 0.2},
    score = 250,
    shootInterval = 1.2,
    bulletSpeed = 260,
    bulletPattern = "double_wave",
    aimsAtPlayer = true,
    bulletTypes = {ethereal = 1, solid = 3}
  },
  bomber = {
    name = "Tau Bomber",
    health = 150,
    speed = 50,
    size = 38,
    color = {0.8, 0.4, 0.8},
    score = 400,
    shootInterval = 1.8,
    bulletSpeed = 180,
    bulletPattern = "cross_pattern",
    spreadShot = true,
    bulletTypes = {ethereal = 4, solid = 5}
  },
  kamikaze = {
    name = "Tau Kamikaze",
    health = 50,
    speed = 200,
    size = 24,
    color = {1, 0.8, 0.2},
    score = 150,
    rushesPlayer = true
  },
  hunter = {
    name = "Tau Hunter",
    health = 80,
    speed = 150,
    size = 26,
    color = {0.2, 1, 0.4},
    score = 200,
    shootInterval = 1.0,
    bulletSpeed = 280,
    bulletPattern = "quintuple_aimed",
    aimsAtPlayer = true,
    movementPattern = "zigzag",
    bulletTypes = {ethereal = 2, solid = 2}
  },
  sniper = {
    name = "Tau Sniper",
    health = 50,
    speed = 60,
    size = 20,
    color = {0.4, 0.7, 1},
    score = 300,
    shootInterval = 2.5,
    bulletSpeed = 400,
    bulletPattern = "accelerating_aimed",
    aimsAtPlayer = true,
    movementPattern = "hold_high",
    bulletTypes = {ethereal = 0, solid = 1}
  },
  artillery = {
    name = "Tau Artillery",
    health = 120,
    speed = 40,
    size = 42,
    color = {0.9, 0.3, 0.9},
    score = 450,
    shootInterval = 2.0,
    bulletSpeed = 150,
    bulletPattern = "wide_barrage",
    spreadShot = true,
    movementPattern = "hold_mid",
    bulletTypes = {ethereal = 3, solid = 6}
  },
  
  -- Wall pattern specialists (create bullet curtains)
  wave_scout = {
    name = "Tau Wave Scout",
    health = 60,
    speed = 100,
    size = 24,
    color = {1, 0.8, 0.3},
    score = 250,
    shootInterval = 0.3,  -- Rapid fire for wall effect
    bulletSpeed = 160,
    bulletPattern = "sine_wall",
    movementPattern = "hold_sides",
    bulletTypes = {ethereal = 1, solid = 1}
  },
  
  spiral_bomber = {
    name = "Tau Spiral Bomber",
    health = 120,
    speed = 60,
    size = 36,
    color = {0.6, 0.3, 1},
    score = 400,
    shootInterval = 1.5,
    bulletSpeed = 140,
    bulletPattern = "shrinking_spiral",
    movementPattern = "circular",
    bulletTypes = {ethereal = 4, solid = 4}
  },
  
  burst_interceptor = {
    name = "Tau Burst Interceptor",
    health = 80,
    speed = 90,
    size = 28,
    color = {1, 0.6, 0.3},
    score = 350,
    shootInterval = 2.5,
    bulletSpeed = 100,
    bulletPattern = "explosion_homing",
    aimsAtPlayer = true,
    movementPattern = "hold_mid",
    bulletTypes = {ethereal = 6, solid = 6}
  },
  
  explosion_bomber = {
    name = "Tau Explosion Bomber",
    health = 140,
    speed = 55,
    size = 40,
    color = {1, 0.4, 0.2},
    score = 500,
    shootInterval = 2.0,
    bulletSpeed = 80,
    bulletPattern = "expanding_burst",
    movementPattern = "circular",
    bulletTypes = {ethereal = 8, solid = 8}
  },
  
  pulse_drone = {
    name = "Tau Pulse Drone",
    health = 90,
    speed = 75,
    size = 32,
    color = {0.5, 0.8, 1},
    score = 380,
    shootInterval = 1.3,
    bulletSpeed = 150,
    bulletPattern = "pulsating_spread",
    movementPattern = "hover",
    bulletTypes = {ethereal = 3, solid = 3}
  }
}

-- Bullet Pattern Definitions
-- Types: "directed" (aims at player), "fixed" (non-directed), "multi-phase" (changes behavior)
local BULLET_PATTERNS = {
  -- Basic patterns
  single_straight = {
    type = "fixed",
    count = 1,
    speed = 200,
    spread = 0,
    baseAngle = math.pi/2,  -- Straight down
    bulletSize = 8
  },
  
  basic_aimed = {
    type = "directed",
    count = 1,
    speed = 250,
    spread = 0,
    bulletSize = 9
  },
  
  triple_aimed = {
    type = "directed",
    count = 3,
    speed = 260,
    spread = 0.15,
    bulletSize = 8
  },
  
  quintuple_aimed = {
    type = "directed",
    count = 5,
    speed = 240,
    spread = 0.12,
    bulletSize = 7
  },
  
  v_pattern = {
    type = "fixed",
    count = 3,
    speed = 220,
    angles = {math.pi/2 - 0.3, math.pi/2, math.pi/2 + 0.3},
    bulletSize = 8
  },
  
  spread_fan = {
    type = "fixed",
    count = 5,
    speed = {min = 200, max = 260},
    spread = 0.35,
    baseAngle = math.pi/2,
    bulletSize = 9
  },
  
  cross_pattern = {
    type = "fixed",
    count = 4,
    speed = 230,
    angles = {math.pi/2 - 0.4, math.pi/2 + 0.4, math.pi/2 - 0.15, math.pi/2 + 0.15},
    bulletSize = 10
  },
  
  double_wave = {
    type = "fixed",
    count = 6,
    speed = 210,
    spread = 0.18,
    baseAngle = math.pi/2,
    bulletSize = 8
  },
  
  spiral_burst = {
    type = "fixed",
    count = 7,
    speed = 180,
    spread = 0.25,
    baseAngle = math.pi/2,
    bulletSize = 9
  },
  
  wide_barrage = {
    type = "fixed",
    count = 9,
    speed = {min = 140, max = 200},  -- Variable speed
    spread = 0.22,
    baseAngle = math.pi/2,
    bulletSize = 10
  },
  
  -- Multi-phase patterns
  explosion_homing = {
    type = "multi-phase",
    phases = {
      {
        duration = 0.3,
        behavior = "circular_burst",
        speed = 80,
        count = 12,
        startSize = 6,
        endSize = 11,
        sizeChangeRate = 18
      },
      {
        duration = 3.0,  -- Homing for 3 seconds, then bullet expires
        behavior = "homing",
        speed = 200,
        turnRate = 2.5,
        startSize = 11,
        endSize = 8,
        sizeChangeRate = 1.5
      }
    }
  },
  
  delayed_homing = {
    type = "multi-phase",
    phases = {
      {
        duration = 0.5,
        behavior = "straight",
        speed = 100,
        startSize = 8
      },
      {
        duration = 4.0,  -- Homing for 4 seconds, then bullet expires
        behavior = "homing",
        speed = 220,
        turnRate = 3.0,
        startSize = 8
      }
    }
  },
  
  sine_wall = {
    type = "multi-phase",
    phases = {
      {
        duration = 99,
        behavior = "sine_wave",
        speed = 100,
        amplitude = 80,
        frequency = 1.8,
        startSize = 9
      }
    }
  },
  
  cosine_wall = {
    type = "multi-phase",
    phases = {
      {
        duration = 99,
        behavior = "cosine_wave",
        speed = 110,
        amplitude = 100,
        frequency = 1.5,
        startSize = 9
      }
    }
  },
  
  accelerating_aimed = {
    type = "multi-phase",
    phases = {
      {
        duration = 0.4,
        behavior = "straight",
        speed = 80,
        startSize = 7
      },
      {
        duration = 99,
        behavior = "accelerate",
        speed = 300,
        acceleration = 400,
        startSize = 7,
        endSize = 10,
        sizeChangeRate = 8
      }
    }
  },
  
  spread_then_converge = {
    type = "multi-phase",
    phases = {
      {
        duration = 0.6,
        behavior = "spread",
        speed = 120,
        spreadRate = 150,
        startSize = 8
      },
      {
        duration = 99,
        behavior = "converge",
        speed = 250,
        startSize = 8
      }
    }
  },
  
  spiral_wall = {
    type = "multi-phase",
    phases = {
      {
        duration = 99,
        behavior = "spiral",
        speed = 140,
        spiralRate = 4.0,
        radius = 60,
        startSize = 9
      }
    }
  },
  
  random_spray = {
    type = "fixed",
    count = 8,
    speed = {min = 180, max = 280},
    randomSpread = 0.6,
    bulletSize = 9
  },
  
  expanding_burst = {
    type = "multi-phase",
    phases = {
      {
        duration = 0.6,
        behavior = "expand",
        speed = 60,
        count = 16,
        startSize = 5,
        endSize = 15,
        sizeChangeRate = 20
      },
      {
        duration = 99,
        behavior = "straight",
        speed = 120,
        startSize = 15,
        endSize = 8,
        sizeChangeRate = 5
      }
    }
  },
  
  pulsating_spread = {
    type = "multi-phase",
    phases = {
      {
        duration = 99,
        behavior = "spread",
        speed = 140,
        spreadRate = 80,
        startSize = 9,
        sizePulse = {min = 7, max = 12, frequency = 4.0}
      }
    }
  },
  
  shrinking_spiral = {
    type = "multi-phase",
    phases = {
      {
        duration = 99,
        behavior = "spiral",
        speed = 140,
        spiralRate = 4.0,
        radius = 60,
        startSize = 13,
        endSize = 6,
        sizeChangeRate = 4
      }
    }
  },
  
  explosion_wave = {
    type = "multi-phase",
    phases = {
      {
        duration = 0.2,
        behavior = "circular_burst",
        speed = 0,
        count = 20,
        startSize = 7,
        endSize = 24,
        sizeChangeRate = 85
      },
      {
        duration = 0.3,
        behavior = "straight",
        speed = 250,
        startSize = 24,
        endSize = 9,
        sizeChangeRate = 50
      },
      {
        duration = 99,
        behavior = "straight",
        speed = 250,
        startSize = 9
      }
    }
  }
}

function Enemy:new(type, x, y)
  local instance = setmetatable({}, self)
  
  -- Assign unique ID
  instance.id = nextEnemyId
  nextEnemyId = nextEnemyId + 1
  
  local enemyData = ENEMY_TYPES[type] or ENEMY_TYPES.scout
  
  instance.type = type
  instance.x = x
  instance.y = y
  instance.name = enemyData.name
  instance.maxHealth = enemyData.health
  instance.health = enemyData.health
  instance.speed = enemyData.speed
  instance.size = enemyData.size
  instance.color = enemyData.color
  instance.score = enemyData.score
  instance.shootInterval = enemyData.shootInterval
  instance.bulletSpeed = enemyData.bulletSpeed
  instance.aimsAtPlayer = enemyData.aimsAtPlayer or false
  instance.spreadShot = enemyData.spreadShot or false
  instance.rushesPlayer = enemyData.rushesPlayer or false
  instance.bulletTypes = enemyData.bulletTypes or {ethereal = 1, solid = 0}
  instance.movementPattern = enemyData.movementPattern or "sine"
  instance.bulletPattern = enemyData.bulletPattern or "basic_aimed"
  
  -- State
  instance.alive = true
  instance.shootTimer = 0
  instance.flashTime = 0
  
  -- Movement pattern state
  instance.moveTimer = 0
  instance.initialX = x
  instance.initialY = y
  instance.zigzagDirection = 1
  instance.hoverTarget = y + 100
  
  -- Multi-phase movement system
  instance.movementPhase = "intro"  -- Current phase: intro, main, exit
  instance.phaseTimer = 0
  instance.phaseData = {}  -- Phase-specific data
  instance:initMovementPhases()
  
  -- Smooth transition system
  instance.transitionBlend = 1.0  -- 1.0 = fully in new phase, 0.0 = start of transition
  instance.transitionDuration = 0.25  -- How long to blend between phases
  instance.prevX = x
  instance.prevY = y
  instance.transitionStartVx = 0
  instance.transitionStartVy = 0
  
  return instance
end

-- Initialize movement phases based on enemy type and pattern
function Enemy:initMovementPhases()
  -- Define phase behavior based on pattern type
  if self.movementPattern == "zigzag" then
    self.phases = {
      intro = {duration = 0.4, behavior = "descend", speed = 2.5},
      main = {duration = nil, behavior = "zigzag"},  -- nil = indefinite
      exit = {trigger = "offscreen"}
    }
  elseif self.movementPattern == "circular" then
    self.phases = {
      intro = {duration = 0.35, behavior = "descend", speed = 2.8},
      main = {duration = 8.0, behavior = "circular"},
      exit = {duration = 1.5, behavior = "accelerate_down"}
    }
  elseif self.movementPattern == "dive" then
    self.phases = {
      intro = {duration = 0.5, behavior = "sine_descent"},
      main = {trigger = "position", y = 200, behavior = "dive_attack"},
      exit = {trigger = "offscreen"}
    }
  elseif self.movementPattern == "hover" then
    self.phases = {
      intro = {duration = 0.45, behavior = "descend", speed = 3.0},
      main = {duration = 8.0, behavior = "hover_drift"},
      exit = {duration = 2.0, behavior = "strafe_exit"}
    }
  elseif self.movementPattern == "strafe" then
    self.phases = {
      intro = {duration = 0.4, behavior = "side_entrance", speed = 2.2},
      main = {duration = 6.0, behavior = "strafe"},
      exit = {duration = 1.5, behavior = "accelerate_down"}
    }
  elseif self.movementPattern == "hold_high" then
    -- Hold position at top of screen
    self.phases = {
      intro = {duration = 0.5, behavior = "descend", speed = 2.8},
      main = {duration = 7.0, behavior = "hold_position", holdY = 120},
      exit = {duration = 1.5, behavior = "accelerate_down"}
    }
  elseif self.movementPattern == "hold_mid" then
    -- Hold position at middle area
    self.phases = {
      intro = {duration = 0.6, behavior = "descend", speed = 2.5},
      main = {duration = 6.0, behavior = "hold_position", holdY = 200},
      exit = {duration = 1.5, behavior = "strafe_exit"}
    }
  elseif self.movementPattern == "hold_sides" then
    -- Hold position at edges, alternating sides
    self.phases = {
      intro = {duration = 0.45, behavior = "side_entrance", speed = 2.4},
      main = {duration = 5.0, behavior = "hold_position", holdY = 150},
      exit = {duration = 1.8, behavior = "strafe_exit"}
    }
  elseif self.rushesPlayer then
    self.phases = {
      intro = {duration = 0.3, behavior = "descend", speed = 3.5},
      main = {duration = nil, behavior = "rush"},
      exit = {trigger = "offscreen"}
    }
  else
    -- Default sine wave pattern
    self.phases = {
      intro = {duration = 0.4, behavior = "descend", speed = 2.6},
      main = {duration = nil, behavior = "sine"},
      exit = {trigger = "offscreen"}
    }
  end
end

-- Check if should transition to next phase
function Enemy:checkPhaseTransition(dt)
  local currentPhase = self.phases[self.movementPhase]
  if not currentPhase then return end
  
  -- Time-based transition
  if currentPhase.duration and self.phaseTimer >= currentPhase.duration then
    if self.movementPhase == "intro" then
      -- Calculate velocity from last frame before transition
      local vx = (self.x - self.prevX) / dt
      local vy = (self.y - self.prevY) / dt
      self:startPhaseTransition("main", vx, vy)
    elseif self.movementPhase == "main" then
      -- Calculate velocity from last frame before transition
      local vx = (self.x - self.prevX) / dt
      local vy = (self.y - self.prevY) / dt
      self:startPhaseTransition("exit", vx, vy)
    end
  end
  
  -- Position-based transition
  if currentPhase.trigger == "position" and currentPhase.y then
    if self.y >= currentPhase.y then
      if self.movementPhase == "intro" then
        -- Calculate velocity from last frame before transition
        local vx = (self.x - self.prevX) / dt
        local vy = (self.y - self.prevY) / dt
        self:startPhaseTransition("main", vx, vy)
      end
    end
  end
end

-- Start a smooth transition to a new phase
function Enemy:startPhaseTransition(newPhase, currentVx, currentVy)
  -- Update reference position to current position for smooth transition
  self.initialX = self.x
  self.initialY = self.y
  
  -- Update hover target if using hover pattern
  if self.movementPattern == "hover" then
    self.hoverTarget = self.y + 100
  end
  
  -- Store the velocity we're transitioning from
  self.transitionStartVx = currentVx or 0
  self.transitionStartVy = currentVy or 0
  
  -- Reset transition blend timer
  self.transitionBlend = 0.0
  
  -- Change phase
  self.movementPhase = newPhase
  self.phaseTimer = 0
  self.phaseData = {}  -- Reset phase data
end

-- Smoothstep interpolation for smooth transitions (cubic ease in/out)
local function smoothstep(t)
  return t * t * (3 - 2 * t)
end

-- Execute phase-specific movement behavior
function Enemy:executePhaseMovement(dt, playerX, playerY, behavior)
  -- Store current position for velocity calculation
  local startX = self.x
  local startY = self.y
  
  -- Calculate target position based on behavior
  local targetX, targetY
  
  if behavior == "descend" then
    -- Simple downward movement
    local speedMod = self.phases[self.movementPhase].speed or 1.0
    targetX = self.initialX
    targetY = self.y + self.speed * speedMod * dt
    
  elseif behavior == "sine_descent" then
    -- Descend with sine wave (faster for intro)
    local speedMod = self.phases[self.movementPhase].speed or 2.0
    targetX = self.initialX + math.sin(self.phaseTimer * 3) * 30
    targetY = self.y + self.speed * speedMod * dt
    
  elseif behavior == "side_entrance" then
    -- Enter from side with curve (faster)
    local entranceProgress = self.phaseTimer / self.phases.intro.duration
    local speedMod = self.phases[self.movementPhase].speed or 2.2
    targetX = self.initialX + math.sin(entranceProgress * math.pi) * 40
    targetY = self.y + self.speed * speedMod * dt
    
  elseif behavior == "zigzag" then
    -- Zigzag pattern (main phase)
    local zigzagSpeed = 150
    targetX = self.x + self.zigzagDirection * zigzagSpeed * dt
    targetY = self.y + self.speed * dt
    
    if self.x < 50 or self.x > 590 or math.floor(self.phaseTimer * 2) ~= math.floor((self.phaseTimer - dt) * 2) then
      self.zigzagDirection = -self.zigzagDirection
    end
    
  elseif behavior == "circular" then
    -- Circular/spiral pattern
    local radius = 60 + self.phaseTimer * 15
    local angle = self.phaseTimer * 3
    targetX = self.initialX + math.cos(angle) * radius
    targetY = self.initialY + self.phaseTimer * self.speed * 0.4 + math.sin(angle) * radius
    
  elseif behavior == "sine" then
    -- Classic sine wave
    targetX = self.initialX + math.sin(self.phaseTimer * 2) * 50
    targetY = self.y + self.speed * dt
    
  elseif behavior == "dive_attack" then
    -- Dive toward player
    local dx = playerX - self.x
    local dy = playerY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 0 then
      targetX = self.x + (dx / dist) * self.speed * 1.5 * dt
      targetY = self.y + (dy / dist) * self.speed * 1.5 * dt
    else
      targetX = self.x
      targetY = self.y
    end
    
  elseif behavior == "strafe" then
    -- Side to side strafing
    targetX = self.initialX + math.cos(self.phaseTimer * 2.5) * 100
    targetY = self.y + self.speed * 0.5 * dt
    
  elseif behavior == "hover_drift" then
    -- Hover with drift
    if self.y < self.hoverTarget then
      targetX = self.x
      targetY = self.y + self.speed * dt
    else
      targetX = self.initialX + math.sin(self.phaseTimer * 0.8) * 80
      targetY = self.hoverTarget + math.sin(self.phaseTimer * 1.2) * 15
    end
    
  elseif behavior == "rush" then
    -- Rush toward player (kamikaze)
    local dx = playerX - self.x
    local dy = playerY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    if dist > 0 then
      targetX = self.x + (dx / dist) * self.speed * dt
      targetY = self.y + (dy / dist) * self.speed * dt
    else
      targetX = self.x
      targetY = self.y
    end
    
  elseif behavior == "accelerate_down" then
    -- Accelerate downward (exit)
    local exitSpeed = self.speed * (1.5 + self.phaseTimer * 2)
    targetX = self.x
    targetY = self.y + exitSpeed * dt
    
  elseif behavior == "strafe_exit" then
    -- Strafe to side while exiting
    local exitSide = (self.x < 320) and -1 or 1
    targetX = self.x + exitSide * 80 * dt
    targetY = self.y + self.speed * 1.2 * dt
    
  elseif behavior == "hold_position" then
    -- Hold at current position with minor drift
    local currentPhase = self.phases[self.movementPhase]
    local holdY = currentPhase.holdY or 150
    
    if self.y < holdY then
      -- Still descending to hold position
      targetX = self.initialX
      targetY = self.y + self.speed * 0.6 * dt
    else
      -- At hold position - minor drift
      targetX = self.initialX + math.sin(self.phaseTimer * 0.5) * 20
      targetY = holdY + math.cos(self.phaseTimer * 0.8) * 8
    end
    
  else
    -- Fallback: no movement
    targetX = self.x
    targetY = self.y
  end
  
  -- Calculate velocity from target position
  local newVx = (targetX - startX) / dt
  local newVy = (targetY - startY) / dt
  
  -- Apply transition blending if in transition period
  if self.transitionBlend < 1.0 then
    -- Update blend progress
    self.transitionBlend = self.transitionBlend + (dt / self.transitionDuration)
    if self.transitionBlend > 1.0 then
      self.transitionBlend = 1.0
    end
    
    -- Use smoothstep for smooth acceleration curve
    local blendFactor = smoothstep(self.transitionBlend)
    
    -- Blend between old velocity and new velocity
    local blendedVx = self.transitionStartVx * (1 - blendFactor) + newVx * blendFactor
    local blendedVy = self.transitionStartVy * (1 - blendFactor) + newVy * blendFactor
    
    -- Apply blended velocity
    self.x = startX + blendedVx * dt
    self.y = startY + blendedVy * dt
  else
    -- No transition, apply target position directly
    self.x = targetX
    self.y = targetY
  end
end

-- Update bullet behavior based on its phase
function Enemy:updateBulletPhase(bullet, dt, playerX, playerY)
  if not bullet.phases then return end  -- Not a multi-phase bullet
  
  -- Update bullet timer
  bullet.timer = bullet.timer + dt
  
  -- Check if should transition to next phase
  local currentPhaseData = bullet.phases[bullet.currentPhase]
  if currentPhaseData and currentPhaseData.duration and bullet.phaseTimer >= currentPhaseData.duration then
    bullet.currentPhase = bullet.currentPhase + 1
    bullet.phaseTimer = 0
    
    -- Store initial position for phase (used by some behaviors)
    bullet.phaseStartX = bullet.x
    bullet.phaseStartY = bullet.y
    
    -- Reset size-related variables for new phase
    bullet.targetSize = nil
    bullet.phaseSize = nil
    
    -- If out of phases, use last phase indefinitely
    if bullet.currentPhase > #bullet.phases then
      bullet.currentPhase = #bullet.phases
    end
  end
  
  bullet.phaseTimer = bullet.phaseTimer + dt
  
  -- Execute current phase behavior
  local phase = bullet.phases[bullet.currentPhase]
  if not phase then return end
  
  local behavior = phase.behavior
  
  if behavior == "homing" then
    -- Homing behavior: gradually turn toward player
    local dx = playerX - bullet.x
    local dy = playerY - bullet.y
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      local targetVx = (dx / dist) * phase.speed
      local targetVy = (dy / dist) * phase.speed
      local turnRate = phase.turnRate or 2.0
      
      bullet.vx = bullet.vx + (targetVx - bullet.vx) * turnRate * dt
      bullet.vy = bullet.vy + (targetVy - bullet.vy) * turnRate * dt
      
      -- Normalize and apply speed
      local currentSpeed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
      if currentSpeed > 0 then
        bullet.vx = (bullet.vx / currentSpeed) * phase.speed
        bullet.vy = (bullet.vy / currentSpeed) * phase.speed
      end
    end
    
  elseif behavior == "circular_burst" then
    -- Bullets spread out in a circle, velocity already set during creation
    -- No additional update needed
    
  elseif behavior == "straight" then
    -- Just move straight, velocity already set
    -- No update needed
    
  elseif behavior == "sine_wave" then
    -- Move in a sine wave pattern
    local amplitude = phase.amplitude or 50
    local frequency = phase.frequency or 2.0
    
    -- Calculate perpendicular direction to movement
    local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    local dirX = bullet.vx / speed
    local dirY = bullet.vy / speed
    local perpX = -dirY
    local perpY = dirX
    
    -- Apply sine wave offset
    local offset = math.sin(bullet.timer * frequency) * amplitude
    local offsetDelta = offset - (bullet.lastOffset or 0)
    bullet.lastOffset = offset
    
    bullet.x = bullet.x + perpX * offsetDelta
    -- Keep forward velocity
    
  elseif behavior == "cosine_wave" then
    -- Move in a cosine wave pattern (same as sine but phase shifted)
    local amplitude = phase.amplitude or 50
    local frequency = phase.frequency or 2.0
    
    local speed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    local dirX = bullet.vx / speed
    local dirY = bullet.vy / speed
    local perpX = -dirY
    local perpY = dirX
    
    local offset = math.cos(bullet.timer * frequency) * amplitude
    local offsetDelta = offset - (bullet.lastOffset or 0)
    bullet.lastOffset = offset
    
    bullet.x = bullet.x + perpX * offsetDelta
    
  elseif behavior == "accelerate" then
    -- Accelerate in current direction
    local acceleration = phase.acceleration or 200
    local maxSpeed = phase.speed or 300
    
    local currentSpeed = math.sqrt(bullet.vx * bullet.vx + bullet.vy * bullet.vy)
    if currentSpeed < maxSpeed then
      local newSpeed = math.min(currentSpeed + acceleration * dt, maxSpeed)
      if currentSpeed > 0 then
        bullet.vx = (bullet.vx / currentSpeed) * newSpeed
        bullet.vy = (bullet.vy / currentSpeed) * newSpeed
      end
    end
    
  elseif behavior == "spread" then
    -- Spread out from center point
    local spreadRate = phase.spreadRate or 100
    if not bullet.spreadDirX then
      -- Initialize spread direction (away from initial position)
      local dx = bullet.x - (bullet.phaseStartX or bullet.x)
      local dy = bullet.y - (bullet.phaseStartY or bullet.y)
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist > 0.1 then
        bullet.spreadDirX = dx / dist
        bullet.spreadDirY = dy / dist
      else
        -- Random direction if no clear direction
        local angle = math.random() * math.pi * 2
        bullet.spreadDirX = math.cos(angle)
        bullet.spreadDirY = math.sin(angle)
      end
    end
    
    bullet.vx = bullet.vx + bullet.spreadDirX * spreadRate * dt
    bullet.vy = bullet.vy + bullet.spreadDirY * spreadRate * dt
    
  elseif behavior == "converge" then
    -- Converge toward player position when phase started
    if not bullet.convergeTargetX then
      bullet.convergeTargetX = playerX
      bullet.convergeTargetY = playerY
    end
    
    local dx = bullet.convergeTargetX - bullet.x
    local dy = bullet.convergeTargetY - bullet.y
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      bullet.vx = (dx / dist) * phase.speed
      bullet.vy = (dy / dist) * phase.speed
    end
    
  elseif behavior == "spiral" then
    -- Spiral outward while moving forward
    local spiralRate = phase.spiralRate or 3.0
    local radius = phase.radius or 40
    
    if not bullet.spiralAngle then
      bullet.spiralAngle = 0
    end
    
    bullet.spiralAngle = bullet.spiralAngle + spiralRate * dt
    local spiralX = math.cos(bullet.spiralAngle) * radius
    local spiralY = math.sin(bullet.spiralAngle) * radius
    
    -- Store last spiral position to calculate delta
    local lastSpiralX = bullet.lastSpiralX or spiralX
    local lastSpiralY = bullet.lastSpiralY or spiralY
    
    bullet.x = bullet.x + (spiralX - lastSpiralX)
    bullet.y = bullet.y + (spiralY - lastSpiralY)
    
    bullet.lastSpiralX = spiralX
    bullet.lastSpiralY = spiralY
    
  elseif behavior == "expand" then
    -- Expand outward in circular burst (like explosion_homing first phase)
    -- Velocity already set during creation, no additional update needed
  end
  
  -- Update bullet size based on phase properties
  if phase.sizePulse then
    -- Pulsating size
    local pulseMin = phase.sizePulse.min or 4
    local pulseMax = phase.sizePulse.max or 8
    local pulseFreq = phase.sizePulse.frequency or 3.0
    local pulseFactor = (math.sin(bullet.timer * pulseFreq) + 1) / 2  -- 0 to 1
    bullet.size = pulseMin + (pulseMax - pulseMin) * pulseFactor
    
  elseif phase.startSize and phase.endSize and phase.sizeChangeRate then
    -- Gradual size change
    if not bullet.targetSize then
      bullet.targetSize = phase.endSize
      bullet.currentSize = phase.startSize
    end
    
    local sizeDiff = bullet.targetSize - bullet.currentSize
    if math.abs(sizeDiff) > 0.1 then
      local sizeChange = phase.sizeChangeRate * dt
      if sizeDiff > 0 then
        bullet.currentSize = math.min(bullet.currentSize + sizeChange, bullet.targetSize)
      else
        bullet.currentSize = math.max(bullet.currentSize - sizeChange, bullet.targetSize)
      end
      bullet.size = bullet.currentSize
    else
      bullet.size = bullet.targetSize
    end
    
  elseif phase.startSize then
    -- Static size for this phase
    if not bullet.phaseSize then
      bullet.phaseSize = phase.startSize
    end
    bullet.size = bullet.phaseSize
  end
end

function Enemy:update(dt, playerX, playerY)
  if not self.alive then return end
  
  -- Store previous position for velocity calculation during transitions
  self.prevX = self.x
  self.prevY = self.y
  
  self.moveTimer = self.moveTimer + dt
  self.phaseTimer = self.phaseTimer + dt
  
  -- Check for phase transitions (passing dt for velocity calculation)
  self:checkPhaseTransition(dt)
  
  -- Execute current phase movement
  local currentPhase = self.phases and self.phases[self.movementPhase]
  if currentPhase and currentPhase.behavior then
    self:executePhaseMovement(dt, playerX, playerY, currentPhase.behavior)
  else
    -- Fallback to default movement if no phase defined
    self.y = self.y + self.speed * dt
  end
  
  -- Shooting AI (bullets are now managed by BulletManager)
  if self.shootInterval and not self.rushesPlayer then
    self.shootTimer = self.shootTimer + dt
    if self.shootTimer >= self.shootInterval then
      -- Note: shoot() will be called from GameScene with bulletManager parameter
      self.shootTimer = 0
      self.needsToShoot = true  -- Flag that enemy wants to shoot
    end
  end
  
  -- Update flash effect
  if self.flashTime > 0 then
    self.flashTime = self.flashTime - dt
  end
end

function Enemy:shoot(playerX, playerY, bulletManager)
  if not bulletManager then
    print("Warning: Enemy:shoot called without bulletManager")
    return
  end
  
  local pattern = BULLET_PATTERNS[self.bulletPattern]
  if not pattern then
    pattern = BULLET_PATTERNS.basic_aimed  -- Fallback
  end
  
  if pattern.type == "directed" then
    -- Aimed at player
    local dx = playerX - self.x
    local dy = playerY - self.y
    local dist = math.sqrt(dx * dx + dy * dy)
    
    if dist > 0 then
      local baseAngle = math.atan2(dy, dx)
      local bulletSize = pattern.bulletSize or 8
      
      for i = 1, pattern.count do
        local spreadOffset = 0
        if pattern.count > 1 then
          spreadOffset = (i - (pattern.count + 1) / 2) * (pattern.spread or 0.15)
        end
        local angle = baseAngle + spreadOffset
        
        local speed = pattern.speed
        if type(speed) == "table" then
          speed = speed.min + math.random() * (speed.max - speed.min)
        end
        
        local isEthereal = (i % 2 == 1)  -- Alternate ethereal/solid
        bulletManager:addBullet({
          x = self.x,
          y = self.y + self.size,
          vx = math.cos(angle) * speed,
          vy = math.sin(angle) * speed,
          size = bulletSize,
          damage = 1,
          color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
          bulletType = isEthereal and "ethereal" or "solid"
        }, self)
      end
    end
    
  elseif pattern.type == "fixed" then
    -- Fixed angle pattern
    local bulletSize = pattern.bulletSize or 8
    
    if pattern.angles then
      -- Specific angles defined
      for _, angle in ipairs(pattern.angles) do
        local speed = pattern.speed
        if type(speed) == "table" then
          speed = speed.min + math.random() * (speed.max - speed.min)
        end
        
        local isEthereal = (math.random() < 0.5)
        bulletManager:addBullet({
          x = self.x,
          y = self.y + self.size,
          vx = math.cos(angle) * speed,
          vy = math.sin(angle) * speed,
          size = bulletSize,
          damage = 1,
          color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
          bulletType = isEthereal and "ethereal" or "solid"
        }, self)
      end
    else
      -- Spread pattern from baseAngle
      local baseAngle = pattern.baseAngle or math.pi/2
      local spread = pattern.spread or 0.2
      local randomSpread = pattern.randomSpread or 0
      
      for i = 1, pattern.count do
        local spreadOffset = (i - (pattern.count + 1) / 2) * spread
        if randomSpread > 0 then
          spreadOffset = spreadOffset + (math.random() - 0.5) * randomSpread
        end
        local angle = baseAngle + spreadOffset
        
        local speed = pattern.speed
        if type(speed) == "table" then
          speed = speed.min + math.random() * (speed.max - speed.min)
        end
        
        local isEthereal = (math.abs(i - (pattern.count + 1) / 2) > pattern.count / 3)
        bulletManager:addBullet({
          x = self.x,
          y = self.y + self.size,
          vx = math.cos(angle) * speed,
          vy = math.sin(angle) * speed,
          size = bulletSize,
          damage = 1,
          color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
          bulletType = isEthereal and "ethereal" or "solid"
        }, self)
      end
    end
    
  elseif pattern.type == "multi-phase" then
    -- Multi-phase bullet patterns
    local firstPhase = pattern.phases[1]
    
    if firstPhase.behavior == "circular_burst" or firstPhase.behavior == "expand" then
      -- Create bullets in a circle
      local count = firstPhase.count or 12
      local bulletSize = firstPhase.startSize or 6
      
      for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = firstPhase.speed or 100
        
        local isEthereal = (i % 2 == 1)
        local bullet = {
          x = self.x,
          y = self.y + self.size,
          vx = math.cos(angle) * speed,
          vy = math.sin(angle) * speed,
          size = bulletSize,
          currentSize = bulletSize,
          damage = 1,
          color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
          bulletType = isEthereal and "ethereal" or "solid",
          -- Multi-phase data
          phases = pattern.phases,
          currentPhase = 1,
          phaseTimer = 0,
          timer = 0,
          phaseStartX = self.x,
          phaseStartY = self.y + self.size
        }
        bulletManager:addBullet(bullet, self)
      end
      
    elseif firstPhase.behavior == "sine_wave" or firstPhase.behavior == "cosine_wave" then
      -- Wall pattern - create stream of bullets
      local dx = playerX - self.x
      local dy = playerY - self.y
      local dist = math.sqrt(dx * dx + dy * dy)
      local angle = dist > 0 and math.atan2(dy, dx) or math.pi/2
      
      local speed = firstPhase.speed or 150
      local bulletSize = firstPhase.startSize or 6
      local isEthereal = (math.random() < 0.5)
      
      local bullet = {
        x = self.x,
        y = self.y + self.size,
        vx = math.cos(angle) * speed,
        vy = math.sin(angle) * speed,
        size = bulletSize,
        currentSize = bulletSize,
        damage = 1,
        color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
        bulletType = isEthereal and "ethereal" or "solid",
        -- Multi-phase data
        phases = pattern.phases,
        currentPhase = 1,
        phaseTimer = 0,
        timer = 0,
        lastOffset = 0
      }
      bulletManager:addBullet(bullet, self)
      
    elseif firstPhase.behavior == "spiral" then
      -- Spiral pattern
      local count = 8
      local bulletSize = firstPhase.startSize or 6
      
      for i = 1, count do
        local angle = (i / count) * math.pi * 2
        local speed = firstPhase.speed or 120
        
        local isEthereal = (i % 2 == 1)
        local bullet = {
          x = self.x,
          y = self.y + self.size,
          vx = math.cos(angle) * speed,
          vy = math.sin(angle) * speed,
          size = bulletSize,
          currentSize = bulletSize,
          damage = 1,
          color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
          bulletType = isEthereal and "ethereal" or "solid",
          -- Multi-phase data
          phases = pattern.phases,
          currentPhase = 1,
          phaseTimer = 0,
          timer = 0,
          spiralAngle = (i / count) * math.pi * 2
        }
        bulletManager:addBullet(bullet, self)
      end
      
    else
      -- Default multi-phase (straight then behavior)
      local dx = playerX - self.x
      local dy = playerY - self.y
      local dist = math.sqrt(dx * dx + dy * dy)
      
      local count = 1
      if firstPhase.behavior == "straight" or firstPhase.behavior == "homing" or firstPhase.behavior == "spread" then
        count = 3  -- Create multiple bullets for these patterns
      end
      
      local bulletSize = firstPhase.startSize or 6
      
      for i = 1, count do
        local angle
        if dist > 0 then
          angle = math.atan2(dy, dx)
          if count > 1 then
            angle = angle + (i - (count + 1) / 2) * 0.15
          end
        else
          angle = math.pi/2
        end
        
        local speed = firstPhase.speed or 100
        local isEthereal = (i % 2 == 1)
        
        local bullet = {
          x = self.x,
          y = self.y + self.size,
          vx = math.cos(angle) * speed,
          vy = math.sin(angle) * speed,
          size = bulletSize,
          currentSize = bulletSize,
          damage = 1,
          color = isEthereal and {1, 0.5, 0.9} or {0.3, 0.9, 1},
          bulletType = isEthereal and "ethereal" or "solid",
          -- Multi-phase data
          phases = pattern.phases,
          currentPhase = 1,
          phaseTimer = 0,
          timer = 0,
          phaseStartX = self.x,
          phaseStartY = self.y + self.size
        }
        bulletManager:addBullet(bullet, self)
      end
    end
  end
end

function Enemy:takeDamage(amount)
  self.health = self.health - amount
  self.flashTime = 0.1
  
  if self.health <= 0 then
    self.alive = false
    return true -- Enemy died
  end
  return false
end

function Enemy:draw()
  if not self.alive then return end
  
  -- Flash white when hit - determine effective color for all parts
  local baseColor = self.color
  local isFlashing = self.flashTime > 0
  
  -- Helper function to get color based on flash state
  local function getColor(r, g, b, a)
    if isFlashing then
      return 1, 1, 1, a or 1
    else
      return r, g, b, a or 1
    end
  end
  
  -- Draw enemy body based on type
  if self.type == "scout" then
    -- Fast reconnaissance: Sleek arrow/dart shape
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.polygon("fill",
      self.x, self.y + self.size * 0.9,
      self.x - self.size * 0.6, self.y - self.size * 0.5,
      self.x, self.y - self.size,
      self.x + self.size * 0.6, self.y - self.size * 0.5
    )
    -- Wings
    love.graphics.setColor(getColor(baseColor[1] * 0.7, baseColor[2] * 0.7, baseColor[3] * 0.7))
    love.graphics.polygon("fill",
      self.x - self.size * 0.6, self.y - self.size * 0.3,
      self.x - self.size * 1.1, self.y,
      self.x - self.size * 0.4, self.y + self.size * 0.2
    )
    love.graphics.polygon("fill",
      self.x + self.size * 0.6, self.y - self.size * 0.3,
      self.x + self.size * 1.1, self.y,
      self.x + self.size * 0.4, self.y + self.size * 0.2
    )
    
  elseif self.type == "interceptor" then
    -- Aggressive: Sharp angular ship with forward blades
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.polygon("fill",
      self.x, self.y + self.size * 0.8,
      self.x - self.size * 0.8, self.y - self.size * 0.3,
      self.x - self.size * 0.4, self.y - self.size,
      self.x + self.size * 0.4, self.y - self.size,
      self.x + self.size * 0.8, self.y - self.size * 0.3
    )
    -- Forward prongs
    love.graphics.setLineWidth(3)
    love.graphics.setColor(getColor(baseColor[1] * 1.2, baseColor[2] * 1.2, baseColor[3] * 1.2))
    love.graphics.line(self.x - self.size * 0.3, self.y - self.size * 0.8, self.x - self.size * 0.5, self.y - self.size * 1.3)
    love.graphics.line(self.x + self.size * 0.3, self.y - self.size * 0.8, self.x + self.size * 0.5, self.y - self.size * 1.3)
    
  elseif self.type == "bomber" then
    -- Heavy: Wide hexagonal body with thick armor panels
    local points = {}
    for i = 0, 5 do
      local angle = (i / 6) * math.pi * 2
      table.insert(points, self.x + math.cos(angle) * self.size * 0.9)
      table.insert(points, self.y + math.sin(angle) * self.size * 0.9)
    end
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.polygon("fill", points)
    -- Inner core
    love.graphics.setColor(getColor(baseColor[1] * 0.5, baseColor[2] * 0.5, baseColor[3] * 0.5))
    love.graphics.circle("fill", self.x, self.y, self.size * 0.4)
    -- Armor segments
    love.graphics.setLineWidth(2)
    love.graphics.setColor(getColor(baseColor[1] * 1.3, baseColor[2] * 1.3, baseColor[3] * 1.3))
    love.graphics.polygon("line", points)
    
  elseif self.type == "kamikaze" then
    -- Unstable: Jagged diamond with glowing core
    love.graphics.setColor(getColor(baseColor[1] * 1.5, baseColor[2] * 1.5, baseColor[3] * 1.5))
    love.graphics.circle("fill", self.x, self.y, self.size * 0.4)  -- Glowing core
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.polygon("fill",
      self.x, self.y - self.size * 1.1,
      self.x - self.size * 0.7, self.y - self.size * 0.2,
      self.x - self.size * 0.9, self.y + self.size * 0.3,
      self.x, self.y + self.size,
      self.x + self.size * 0.9, self.y + self.size * 0.3,
      self.x + self.size * 0.7, self.y - self.size * 0.2
    )
    
  elseif self.type == "hunter" then
    -- Predatory: Sleek with side-mounted weapons
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    -- Main body
    love.graphics.polygon("fill",
      self.x, self.y + self.size * 0.9,
      self.x - self.size * 0.5, self.y,
      self.x - self.size * 0.3, self.y - self.size * 0.8,
      self.x + self.size * 0.3, self.y - self.size * 0.8,
      self.x + self.size * 0.5, self.y
    )
    -- Weapon pods
    love.graphics.setColor(getColor(baseColor[1] * 1.3, baseColor[2] * 1.3, baseColor[3] * 1.3))
    love.graphics.rectangle("fill", self.x - self.size * 0.8, self.y - self.size * 0.3, self.size * 0.3, self.size * 0.8, 2, 2)
    love.graphics.rectangle("fill", self.x + self.size * 0.5, self.y - self.size * 0.3, self.size * 0.3, self.size * 0.8, 2, 2)
    
  elseif self.type == "sniper" then
    -- Precision: Narrow body with long barrel
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    -- Body
    love.graphics.rectangle("fill", self.x - self.size * 0.3, self.y - self.size * 0.4, self.size * 0.6, self.size * 1.2, 3, 3)
    -- Long barrel/scope
    love.graphics.setLineWidth(4)
    love.graphics.setColor(getColor(baseColor[1] * 1.4, baseColor[2] * 1.4, baseColor[3] * 1.4))
    love.graphics.line(self.x, self.y - self.size * 0.4, self.x, self.y - self.size * 1.3)
    love.graphics.setLineWidth(2)
    love.graphics.circle("line", self.x, self.y - self.size * 1.3, self.size * 0.2)
    -- Side stabilizers
    love.graphics.setColor(getColor(baseColor[1] * 0.7, baseColor[2] * 0.7, baseColor[3] * 0.7))
    love.graphics.rectangle("fill", self.x - self.size * 0.6, self.y + self.size * 0.2, self.size * 0.2, self.size * 0.4)
    love.graphics.rectangle("fill", self.x + self.size * 0.4, self.y + self.size * 0.2, self.size * 0.2, self.size * 0.4)
    
  elseif self.type == "artillery" then
    -- Massive: Large rectangular hull with multiple turrets
    love.graphics.setColor(getColor(baseColor[1] * 0.6, baseColor[2] * 0.6, baseColor[3] * 0.6))
    love.graphics.rectangle("fill", self.x - self.size * 0.9, self.y - self.size * 0.7, self.size * 1.8, self.size * 1.4, 4, 4)
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.rectangle("fill", self.x - self.size * 0.7, self.y - self.size * 0.5, self.size * 1.4, self.size * 1.0, 3, 3)
    -- Triple turrets
    love.graphics.setColor(getColor(baseColor[1] * 1.2, baseColor[2] * 1.2, baseColor[3] * 1.2))
    love.graphics.rectangle("fill", self.x - self.size * 0.5, self.y - self.size * 0.8, self.size * 0.3, self.size * 0.5, 2, 2)
    love.graphics.rectangle("fill", self.x - self.size * 0.1, self.y - self.size * 0.9, self.size * 0.3, self.size * 0.6, 2, 2)
    love.graphics.rectangle("fill", self.x + self.size * 0.3, self.y - self.size * 0.8, self.size * 0.3, self.size * 0.5, 2, 2)
    
  elseif self.type == "wave_scout" then
    -- Technical: Antenna/radar arrays
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.circle("fill", self.x, self.y, self.size * 0.5)
    -- Radar dishes
    love.graphics.setLineWidth(2)
    love.graphics.setColor(getColor(baseColor[1] * 1.3, baseColor[2] * 1.3, baseColor[3] * 1.3))
    love.graphics.arc("line", "open", self.x - self.size * 0.7, self.y, self.size * 0.4, -math.pi/2, math.pi/2)
    love.graphics.arc("line", "open", self.x + self.size * 0.7, self.y, self.size * 0.4, math.pi/2, math.pi*1.5)
    -- Wave emitters
    love.graphics.circle("fill", self.x - self.size * 0.7, self.y, self.size * 0.15)
    love.graphics.circle("fill", self.x + self.size * 0.7, self.y, self.size * 0.15)
    
  elseif self.type == "spiral_bomber" then
    -- Rotating: Spinning core with orbiting segments
    local angle = (love.timer.getTime() * 2) % (math.pi * 2)
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.circle("fill", self.x, self.y, self.size * 0.4)
    -- Rotating segments
    for i = 0, 2 do
      local segAngle = angle + (i * math.pi * 2 / 3)
      local segX = self.x + math.cos(segAngle) * self.size * 0.7
      local segY = self.y + math.sin(segAngle) * self.size * 0.7
      love.graphics.setColor(getColor(baseColor[1] * 0.8, baseColor[2] * 0.8, baseColor[3] * 0.8))
      love.graphics.circle("fill", segX, segY, self.size * 0.3)
    end
    
  elseif self.type == "burst_interceptor" then
    -- Multi-barrel: Central core with multiple gun ports
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.circle("fill", self.x, self.y, self.size * 0.6)
    -- Gun barrels arranged in circle
    love.graphics.setLineWidth(3)
    love.graphics.setColor(getColor(baseColor[1] * 1.4, baseColor[2] * 1.4, baseColor[3] * 1.4))
    for i = 0, 5 do
      local barrelAngle = (i / 6) * math.pi * 2
      local startX = self.x + math.cos(barrelAngle) * self.size * 0.5
      local startY = self.y + math.sin(barrelAngle) * self.size * 0.5
      local endX = self.x + math.cos(barrelAngle) * self.size * 0.9
      local endY = self.y + math.sin(barrelAngle) * self.size * 0.9
      love.graphics.line(startX, startY, endX, endY)
    end
    
  elseif self.type == "explosion_bomber" then
    -- Volatile: Bulky with energy containment rings
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.ellipse("fill", self.x, self.y, self.size * 0.9, self.size * 0.7)
    -- Containment rings
    love.graphics.setLineWidth(2)
    love.graphics.setColor(getColor(baseColor[1] * 1.5, baseColor[2] * 1.5, baseColor[3] * 1.5))
    love.graphics.ellipse("line", self.x, self.y, self.size * 0.6, self.size * 0.4)
    love.graphics.ellipse("line", self.x, self.y, self.size * 1.1, self.size * 0.9)
    
  elseif self.type == "pulse_drone" then
    -- Pulsating: Octagonal with pulsing energy field
    local pulse = 1 + math.sin(love.timer.getTime() * 4) * 0.15
    local points = {}
    for i = 0, 7 do
      local angle = (i / 8) * math.pi * 2 + math.pi/8
      table.insert(points, self.x + math.cos(angle) * self.size * 0.8)
      table.insert(points, self.y + math.sin(angle) * self.size * 0.8)
    end
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.polygon("fill", points)
    -- Pulsing field
    love.graphics.setLineWidth(2)
    love.graphics.setColor(getColor(baseColor[1] * pulse, baseColor[2] * pulse, baseColor[3] * pulse, 0.5))
    love.graphics.circle("line", self.x, self.y, self.size * pulse)
    
  else
    -- Default: Circle for any undefined types
    love.graphics.setColor(getColor(baseColor[1], baseColor[2], baseColor[3]))
    love.graphics.circle("fill", self.x, self.y, self.size)
    love.graphics.setColor(getColor(baseColor[1] * 1.3, baseColor[2] * 1.3, baseColor[3] * 1.3))
    love.graphics.circle("line", self.x, self.y, self.size * 0.7)
  end
  
  -- Health bar for stronger enemies
  if self.maxHealth > 4 then
    local barWidth = self.size * 2
    local barHeight = 3
    local barX = self.x - barWidth / 2
    local barY = self.y - self.size - 10
    
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX, barY, barWidth, barHeight)
    
    love.graphics.setColor(1, 0.3, 0.3, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth * (self.health / self.maxHealth), barHeight)
    
    -- Health bar border
    love.graphics.setColor(0.5, 0.5, 0.5, 1)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
  end
  
  -- Reset
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setLineWidth(1)
end

function Enemy:getBounds()
  return {
    x = self.x - self.size,
    y = self.y - self.size,
    width = self.size * 2,
    height = self.size * 2
  }
end

return Enemy
