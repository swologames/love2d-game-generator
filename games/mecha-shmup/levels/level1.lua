-- Level 1: Outer Defense
-- Introduction level with basic enemy patterns

return {
  name = "Outer Defense",
  description = "The first wave of Tau Deu forces",
  duration = 90,  -- Level duration in seconds (before next level/loop)
  
  -- Music configuration
  music = "level1",
  bossMusic = "boss_fight",
  
  -- Timeline of events (time in seconds from level start)
  events = {
    -- Set initial background
    {time = 0.0, type = "background", theme = "forest", instant = true},
    
    -- Opening scouts
    {time = 1.0, type = "spawn", enemy = "scout", x = 100, y = -50},
    {time = 1.3, type = "spawn", enemy = "scout", x = 540, y = -50},
    {time = 1.6, type = "spawn", enemy = "scout", x = 320, y = -50},
    {time = 2.0, type = "spawn", enemy = "scout", x = 200, y = -50},
    {time = 2.3, type = "spawn", enemy = "scout", x = 440, y = -50},
    
    -- First formation with hunters
    {time = 5.0, type = "formation", pattern = "line", enemy = "scout", count = 6},
    {time = 5.5, type = "spawn", enemy = "hunter", x = 150, y = -50},
    {time = 5.8, type = "spawn", enemy = "hunter", x = 490, y = -50},
    
    -- Introduce interceptors
    {time = 10.0, type = "spawn", enemy = "interceptor", x = 150, y = -50},
    {time = 10.3, type = "spawn", enemy = "interceptor", x = 490, y = -50},
    {time = 10.6, type = "spawn", enemy = "sniper", x = 320, y = -50},
    
    -- Mixed wave
    {time = 15.0, type = "spawn", enemy = "scout", x = 100, y = -50},
    {time = 15.2, type = "spawn", enemy = "interceptor", x = 220, y = -50},
    {time = 15.4, type = "spawn", enemy = "hunter", x = 320, y = -50},
    {time = 15.6, type = "spawn", enemy = "interceptor", x = 420, y = -50},
    {time = 15.8, type = "spawn", enemy = "scout", x = 540, y = -50},
    
    -- V-Formation with snipers
    {time = 20.0, type = "formation", pattern = "vformation", enemy = "interceptor", count = 6},
    {time = 20.5, type = "spawn", enemy = "sniper", x = 200, y = -50},
    {time = 20.8, type = "spawn", enemy = "sniper", x = 440, y = -50},
    
    -- Kamikaze rush
    {time = 25.0, type = "spawn", enemy = "kamikaze", x = 160, y = -50},
    {time = 25.2, type = "spawn", enemy = "kamikaze", x = 480, y = -50},
    {time = 25.4, type = "spawn", enemy = "scout", x = 100, y = -50},
    {time = 25.6, type = "spawn", enemy = "kamikaze", x = 320, y = -50},
    {time = 25.8, type = "spawn", enemy = "scout", x = 540, y = -50},
    
    -- Introduce bomber and artillery
    {time = 30.0, type = "spawn", enemy = "bomber", x = 250, y = -100},
    {time = 30.3, type = "spawn", enemy = "artillery", x = 390, y = -100},
    {time = 32.0, type = "spawn", enemy = "wave_scout", x = 150, y = -50},  -- Wall pattern
    {time = 32.5, type = "spawn", enemy = "wave_scout", x = 490, y = -50},  -- Wall pattern
    {time = 33.0, type = "spawn", enemy = "explosion_bomber", x = 320, y = -100},  -- Expanding burst
    
    -- Transition to water background
    {time = 35.0, type = "background", theme = "water"},
    
    -- Heavy formation waves with wall patterns
    {time = 35.0, type = "formation", pattern = "wave", enemy = "scout", count = 8},
    {time = 36.0, type = "spawn", enemy = "hunter", x = 200, y = -50},
    {time = 36.3, type = "spawn", enemy = "hunter", x = 440, y = -50},
    {time = 37.0, type = "spawn", enemy = "burst_interceptor", x = 320, y = -50},  -- Explosion homing
    {time = 38.0, type = "formation", pattern = "diamond", enemy = "interceptor", count = 10},
    {time = 39.0, type = "spawn", enemy = "pulse_drone", x = 250, y = -50},  -- Pulsating bullets
    {time = 39.3, type = "spawn", enemy = "pulse_drone", x = 390, y = -50},  -- Pulsating bullets,
    
    -- Multiple bombers with escorts and wave scouts
    {time = 43.0, type = "spawn", enemy = "bomber", x = 200, y = -50},
    {time = 43.2, type = "spawn", enemy = "scout", x = 120, y = -50},
    {time = 43.4, type = "spawn", enemy = "scout", x = 280, y = -50},
    {time = 44.0, type = "spawn", enemy = "artillery", x = 440, y = -50},
    {time = 44.2, type = "spawn", enemy = "interceptor", x = 360, y = -50},
    {time = 44.4, type = "spawn", enemy = "interceptor", x = 520, y = -50},
    {time = 45.0, type = "spawn", enemy = "wave_scout", x = 320, y = -50},  -- Wall pattern center
    
    -- Large swarm with hunters and spiral bomber
    {time = 48.0, type = "formation", pattern = "swarm", enemy = "scout", count = 15},
    {time = 49.0, type = "spawn", enemy = "hunter", x = 150, y = -50},
    {time = 49.3, type = "spawn", enemy = "hunter", x = 320, y = -50},
    {time = 49.6, type = "spawn", enemy = "hunter", x = 490, y = -50},
    {time = 50.0, type = "spawn", enemy = "spiral_bomber", x = 320, y = -100},  -- Spiral pattern
    {time = 51.0, type = "spawn", enemy = "explosion_bomber", x = 200, y = -100},  -- Expanding burst
    {time = 51.3, type = "spawn", enemy = "explosion_bomber", x = 440, y = -100},  -- Expanding burst
    
    -- Power-up drop (forced)
    {time = 53.0, type = "powerup", powerupType = "health", x = 320, y = -50},
    
    -- Sniper line with burst interceptors
    {time = 55.0, type = "formation", pattern = "line", enemy = "sniper", count = 5},
    {time = 56.0, type = "spawn", enemy = "scout", x = 100, y = -50},
    {time = 56.2, type = "spawn", enemy = "scout", x = 540, y = -50},
    {time = 57.0, type = "spawn", enemy = "burst_interceptor", x = 220, y = -50},
    {time = 57.3, type = "spawn", enemy = "burst_interceptor", x = 420, y = -50},
    
    -- Intense mixed assault with wall patterns
    {time = 60.0, type = "spawn", enemy = "interceptor", x = 100, y = -50},
    {time = 60.2, type = "spawn", enemy = "bomber", x = 250, y = -50},
    {time = 60.4, type = "spawn", enemy = "artillery", x = 390, y = -50},
    {time = 60.6, type = "spawn", enemy = "interceptor", x = 540, y = -50},
    {time = 61.0, type = "formation", pattern = "line", enemy = "kamikaze", count = 5},
    {time = 61.5, type = "spawn", enemy = "wave_scout", x = 180, y = -50},  -- Wall pattern
    {time = 61.8, type = "spawn", enemy = "wave_scout", x = 460, y = -50},  -- Wall pattern
    {time = 62.0, type = "spawn", enemy = "hunter", x = 200, y = -50},
    {time = 62.3, type = "spawn", enemy = "hunter", x = 440, y = -50},
    
    -- Artillery barrage with spiral bomber
    {time = 65.0, type = "spawn", enemy = "artillery", x = 200, y = -100},
    {time = 65.5, type = "spawn", enemy = "artillery", x = 440, y = -100},
    {time = 66.0, type = "formation", pattern = "wave", enemy = "interceptor", count = 7},
    {time = 66.5, type = "spawn", enemy = "spiral_bomber", x = 320, y = -100},  -- Spiral pattern
    
    -- Transition to mechanical background for boss approach
    {time = 68.0, type = "background", theme = "mechanical"},
    
    -- Final formation before boss with mixed special enemies
    {time = 70.0, type = "formation", pattern = "diamond", enemy = "bomber", count = 10},
    {time = 71.0, type = "spawn", enemy = "sniper", x = 150, y = -50},
    {time = 71.3, type = "spawn", enemy = "sniper", x = 490, y = -50},
    {time = 72.0, type = "spawn", enemy = "burst_interceptor", x = 250, y = -50},
    {time = 72.3, type = "spawn", enemy = "burst_interceptor", x = 390, y = -50},
    {time = 72.6, type = "spawn", enemy = "pulse_drone", x = 180, y = -50},  -- Pulsating bullets
    {time = 72.9, type = "spawn", enemy = "pulse_drone", x = 460, y = -50},  -- Pulsating bullets
    {time = 73.0, type = "formation", pattern = "vformation", enemy = "interceptor", count = 6},
    {time = 74.0, type = "formation", pattern = "swarm", enemy = "hunter", count = 8},
    {time = 75.0, type = "spawn", enemy = "wave_scout", x = 200, y = -50},  -- Wall pattern
    {time = 75.3, type = "spawn", enemy = "wave_scout", x = 440, y = -50},  -- Wall pattern
    
    -- Final chaotic wave with all special enemy types
    {time = 77.0, type = "spawn", enemy = "bomber", x = 160, y = -50},
    {time = 77.2, type = "spawn", enemy = "artillery", x = 320, y = -50},
    {time = 77.4, type = "spawn", enemy = "bomber", x = 480, y = -50},
    {time = 78.0, type = "formation", pattern = "line", enemy = "kamikaze", count = 6},
    {time = 78.5, type = "spawn", enemy = "spiral_bomber", x = 250, y = -100},
    {time = 78.8, type = "spawn", enemy = "spiral_bomber", x = 390, y = -100},
    
    -- Message
    {time = 80.0, type = "message", text = "WARNING: BOSS APPROACHING", duration = 3},
    
    -- Boss battle
    {time = 85.0, type = "boss", boss = "vorkath"},
  }
}
