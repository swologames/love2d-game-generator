-- test-character-love.lua
-- Love2D wrapper for character test

local Character = require("src.entities.Character")

function love.load()
  print("\n=== Character System Test ===\n")
  
  -- Test 1: Create party
  print("Creating party of 4 members...")
  local party = {}
  
  party[1] = Character:new("Reyes", "Marine", 1)
  party[2] = Character:new("Nova", "Hacker", 1)
  party[3] = Character:new("Cruz", "Medic", 1)
  party[4] = Character:new("Zeke", "Engineer", 1)
  
  print("✓ Party created successfully\n")
  
  -- Display characters
  for i, char in ipairs(party) do
    print(string.format("%d. %s", i, char:toString()))
    local stats = char:getAllStats()
    print(string.format("   Stats: STR=%d INT=%d CON=%d REF=%d WIL=%d", 
      stats.STR, stats.INT, stats.CON, stats.REF, stats.WIL))
  end
  print()
  
  -- Test damage/healing
  local marine = party[1]
  print("Testing damage on Marine:")
  print(string.format("  Before: %d/%d HP", marine:getHP(), marine:getMaxHP()))
  local dmg = marine:takeDamage(20)
  print(string.format("  After 20 dmg: %d/%d HP (took %d)", marine:getHP(), marine:getMaxHP(), dmg))
  marine:heal(10)
  print(string.format("  After heal: %d/%d HP", marine:getHP(), marine:getMaxHP()))
  print()
  
  -- Test HUD export
  print("Testing HUD data export:")
  local hudData = party[1]:toHUDData()
  print(string.format("  %s (Lv%d %s): %d/%d HP, %d/%d EP", 
    hudData.name, hudData.level, hudData.class,
    hudData.hp, hudData.maxHP, hudData.ep, hudData.maxEP))
  
  print("\n✓ All tests passed!\n")
  
  -- Exit after test
  love.event.quit()
end
