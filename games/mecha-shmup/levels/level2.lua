-- Level 2: Inner Perimeter
-- Increased difficulty with more complex patterns

return {
  name = "Inner Perimeter",
  description = "Tau forces intensify their assault",
  duration = 100,
  
  -- Music configuration
  music = "level2",
  bossMusic = "boss_fight",
  
  events = {
    -- Start with water/ocean theme
    {time = 0.0, type = "background", theme = "water", instant = true},
    
    -- Fast opening with hunters
    {time = 0.5, type = "formation", pattern = "line", enemy = "scout", count = 8},
    {time = 1.5, type = "spawn", enemy = "hunter", x = 150, y = -50},
    {time = 1.8, type = "spawn", enemy = "hunter", x = 490, y = -50},
    {time = 2.0, type = "formation", pattern = "vformation", enemy = "interceptor", count = 6},
    
    -- Bomber and artillery introduction
    {time = 5.0, type = "spawn", enemy = "bomber", x = 200, y = -50},
    {time = 5.3, type = "spawn", enemy = "artillery", x = 320, y = -50},
    {time = 5.6, type = "spawn", enemy = "bomber", x = 440, y = -50},
    {time = 6.0, type = "formation", pattern = "line", enemy = "sniper", count = 4},
    
    -- Kamikaze waves with hunters
    {time = 10.0, type = "formation", pattern = "line", enemy = "kamikaze", count = 6},
    {time = 11.0, type = "spawn", enemy = "hunter", x = 200, y = -50},
    {time = 11.3, type = "spawn", enemy = "hunter", x = 440, y = -50},
    {time = 12.0, type = "formation", pattern = "line", enemy = "kamikaze", count = 6},
    {time = 13.0, type = "spawn", enemy = "sniper", x = 320, y = -50},
    
    -- Heavy bombers with escorts
    {time = 18.0, type = "spawn", enemy = "bomber", x = 160, y = -50},
    {time = 18.1, type = "spawn", enemy = "artillery", x = 320, y = -50},
    {time = 18.2, type = "spawn", enemy = "bomber", x = 480, y = -50},
    {time = 18.3, type = "spawn", enemy = "interceptor", x = 100, y = -50},
    {time = 18.4, type = "spawn", enemy = "hunter", x = 220, y = -50},
    {time = 18.5, type = "spawn", enemy = "hunter", x = 420, y = -50},
    {time = 18.6, type = "spawn", enemy = "interceptor", x = 540, y = -50},
    
    -- Swarm assault with mixed types
    {time = 25.0, type = "formation", pattern = "swarm", enemy = "interceptor", count = 12},
    {time = 26.0, type = "spawn", enemy = "sniper", x = 150, y = -50},
    {time = 26.3, type = "spawn", enemy = "sniper", x = 490, y = -50},
    {time = 28.0, type = "formation", pattern = "swarm", enemy = "scout", count = 15},
    {time = 29.0, type = "formation", pattern = "line", enemy = "hunter", count = 5},
    
    -- Artillery barrage
    {time = 33.0, type = "spawn", enemy = "artillery", x = 160, y = -100},
    {time = 33.5, type = "spawn", enemy = "artillery", x = 320, y = -100},
    {time = 34.0, type = "spawn", enemy = "artillery", x = 480, y = -100},
    
    -- Transition to crystal caverns
    {time = 35.0, type = "background", theme = "crystal"},
    
    -- Diamond formations
    {time = 35.0, type = "formation", pattern = "diamond", enemy = "bomber", count = 10},
    {time = 36.0, type = "spawn", enemy = "hunter", x = 200, y = -50},
    {time = 36.3, type = "spawn", enemy = "hunter", x = 440, y = -50},
    {time = 38.0, type = "formation", pattern = "diamond", enemy = "interceptor", count = 10},
    {time = 39.0, type = "formation", pattern = "wave", enemy = "sniper", count = 5},
    
    -- Power-up
    {time = 45.0, type = "powerup", powerupType = "weapon", x = 320, y = -50},
    
    -- Wave patterns with hunters
    {time = 50.0, type = "formation", pattern = "wave", enemy = "interceptor", count = 8},
    {time = 51.0, type = "spawn", enemy = "hunter", x = 150, y = -50},
    {time = 51.3, type = "spawn", enemy = "hunter", x = 320, y = -50},
    {time = 51.6, type = "spawn", enemy = "hunter", x = 490, y = -50},
    {time = 53.0, type = "formation", pattern = "wave", enemy = "bomber", count = 7},
    {time = 54.0, type = "spawn", enemy = "artillery", x = 250, y = -50},
    {time = 54.3, type = "spawn", enemy = "artillery", x = 390, y = -50},
    
    
    -- Transition to forest
    {time = 60.0, type = "background", theme = "forest"},
    -- Sniper line
    {time = 58.0, type = "formation", pattern = "line", enemy = "sniper", count = 6},
    {time = 59.0, type = "formation", pattern = "swarm", enemy = "scout", count = 12},
    
    -- Mixed chaos
    {time = 60.0, type = "spawn", enemy = "bomber", x = 100, y = -50},
    {time = 60.2, type = "spawn", enemy = "artillery", x = 220, y = -50},
    {time = 60.4, type = "spawn", enemy = "bomber", x = 320, y = -50},
    {time = 60.6, type = "spawn", enemy = "artillery", x = 420, y = -50},
    {time = 60.8, type = "spawn", enemy = "bomber", x = 540, y = -50},
    {time = 61.0, type = "formation", pattern = "vformation", enemy = "kamikaze", count = 6},
    {time = 62.0, type = "spawn", enemy = "hunter", x = 150, y = -50},
    {time = 62.2, type = "spawn", enemy = "hunter", x = 320, y = -50},
    {time = 62.4, type = "spawn", enemy = "hunter", x = 490, y = -50},
    {time = 63.0, type = "formation", pattern = "line", enemy = "interceptor", count = 8},
    
    -- Heavy artillery wave
    {time = 68.0, type = "spawn", enemy = "artillery", x = 160, y = -100},
    {time = 68.3, type = "spawn", enemy = "artillery", x = 320, y = -100},
    {time = 68.6, type = "spawn", enemy = "artillery", x = 480, y = -100},
    {time = 69.0, type = "formation", pattern = "diamond", enemy = "sniper", count = 8},
    
    -- Final assault
    {time = 75.0, type = "formation", pattern = "swarm", enemy = "bomber", count = 12},
    
    -- Back to mechanical for final phase
    {time = 80.0, type = "background", theme = "mechanical"},
    {time = 76.0, type = "formation", pattern = "swarm", enemy = "hunter", count = 10},
    {time = 78.0, type = "spawn", enemy = "artillery", x = 200, y = -50},
    {time = 78.3, type = "spawn", enemy = "artillery", x = 440, y = -50},
    {time = 80.0, type = "formation", pattern = "diamond", enemy = "interceptor", count = 10},
    {time = 82.0, type = "formation", pattern = "vformation", enemy = "kamikaze", count = 7},
    
    -- Absolute chaos before boss
    {time = 85.0, type = "spawn", enemy = "bomber", x = 100, y = -50},
    {time = 85.1, type = "spawn", enemy = "artillery", x = 220, y = -50},
    {time = 85.2, type = "spawn", enemy = "bomber", x = 320, y = -50},
    {time = 85.3, type = "spawn", enemy = "artillery", x = 420, y = -50},
    {time = 85.4, type = "spawn", enemy = "bomber", x = 540, y = -50},
    {time = 86.0, type = "formation", pattern = "line", enemy = "hunter", count = 6},
    
    -- Boss warning
    {time = 90.0, type = "message", text = "BOSS INCOMING!", duration = 3},
    
    -- Boss
    {time = 95.0, type = "boss", boss = "vorkath"},
  }
}
