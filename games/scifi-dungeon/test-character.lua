-- test-character.lua
-- Quick test to verify Character system works

local Character = require("src.entities.Character")
local ClassData = require("src.data.ClassData")

print("\n=== Character System Test ===\n")

-- Test 1: Create one character of each class
print("Creating party of 4 members...")
local party = {}

party[1] = Character:new("Reyes", "Marine", 1)
party[2] = Character:new("Nova", "Hacker", 1)
party[3] = Character:new("Cruz", "Medic", 1)
party[4] = Character:new("Zeke", "Engineer", 1)

print("✓ Party created successfully\n")

-- Test 2: Display character info
for i, char in ipairs(party) do
  print(string.format("%d. %s", i, char:toString()))
  
  local stats = char:getAllStats()
  print(string.format("   Stats: STR=%d INT=%d CON=%d REF=%d WIL=%d PER=%d", 
    stats.STR, stats.INT, stats.CON, stats.REF, stats.WIL, stats.PER))
end

print()

-- Test 3: Damage and healing
print("Testing damage and healing on Marine...")
local marine = party[1]
print(string.format("  Initial HP: %d/%d", marine:getHP(), marine:getMaxHP()))

local damage = marine:takeDamage(20)
print(string.format("  Took %d damage -> HP: %d/%d", damage, marine:getHP(), marine:getMaxHP()))

local healed = marine:heal(10)
print(string.format("  Healed %d HP -> HP: %d/%d", healed, marine:getHP(), marine:getMaxHP()))

print()

-- Test 4: EP management
print("Testing EP on Hacker...")
local hacker = party[2]
print(string.format("  Initial EP: %d/%d", hacker:getEP(), hacker:getMaxEP()))

local spent = hacker:spendEP(10)
print(string.format("  Spent 10 EP -> Success: %s, EP: %d/%d", tostring(spent), hacker:getEP(), hacker:getMaxEP()))

hacker:restoreEP(15)
print(string.format("  Restored 15 EP -> EP: %d/%d", hacker:getEP(), hacker:getMaxEP()))

print()

-- Test 5: Death and revival
print("Testing death and revival on Medic...")
local medic = party[3]
medic:takeDamage(1000) -- Overkill
print(string.format("  After massive damage: %s, HP: %d", medic:isAliveCheck() and "Alive" or "Dead", medic:getHP()))

medic:revive(0.5)
print(string.format("  After revival: %s, HP: %d/%d", medic:isAliveCheck() and "Alive" or "Dead", medic:getHP(), medic:getMaxHP()))

print()

-- Test 6: HUD data export
print("Testing HUD data export for Engineer...")
local hudData = party[4]:toHUDData()
print(string.format("  Name: %s, Class: %s, Level: %d", hudData.name, hudData.class, hudData.level))
print(string.format("  HP: %d/%d (%.0f%%), EP: %d/%d (%.0f%%)", 
  hudData.hp, hudData.maxHP, hudData.hpPercent * 100,
  hudData.ep, hudData.maxEP, hudData.epPercent * 100))

print()

-- Test 7: Level up
print("Testing level progression...")
local engineer = party[4]
print(string.format("  Before: %s", engineer:toString()))
engineer:addExperience(150) -- Should level up
print(string.format("  After adding 150 XP: %s", engineer:toString()))

print()

-- Test 8: Initiative rolls
print("Testing initiative rolls (10 rolls per character)...")
for i, char in ipairs(party) do
  local rolls = {}
  for j = 1, 10 do
    table.insert(rolls, char:rollInitiative())
  end
  local avg = 0
  for _, roll in ipairs(rolls) do avg = avg + roll end
  avg = avg / #rolls
  print(string.format("  %s (REF=%d): Avg initiative = %.1f", 
    char.name, char:getStat("REF"), avg))
end

print("\n=== All Tests Completed ===\n")
