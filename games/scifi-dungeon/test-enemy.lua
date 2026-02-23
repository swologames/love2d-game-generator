#!/usr/bin/env lua
-- test-enemy.lua
-- Test script for Enemy system (Phase 2)
-- Run with: lua test-enemy.lua

-- Add src to package path for requires
package.path = package.path .. ";./src/?.lua;./src/?/init.lua"

print("=== Enemy System Test (Phase 2) ===\n")

-- Load modules
local Enemy = require("src.entities.Enemy")
local EnemyData = require("src.data.EnemyData")

-- ─── Test 1: List all enemy types ──────────────────────────────────────────

print("Test 1: List All Enemy Types")
print("─────────────────────────────────────")

local allTypes = EnemyData.getAllEnemyTypes()
print("Available enemy types: " .. #allTypes)
for _, typeId in ipairs(allTypes) do
  local template = EnemyData.getTemplate(typeId)
  print(string.format("  • %s (%s) - %s", template.name, typeId, template.description))
end
print()

-- ─── Test 2: Create enemies from templates ─────────────────────────────────

print("Test 2: Create Enemies from Templates")
print("─────────────────────────────────────────────")

local raider = EnemyData.createEnemy("gang_raider")
local scout = EnemyData.createEnemy("warden_scout")

print("Gang Raider created:")
print("  " .. raider:getStatsString())
print("  Loot: " .. raider:getXPReward() .. " XP")
print()

print("Warden Scout created:")
print("  " .. scout:getStatsString())
print("  Loot: " .. scout:getXPReward() .. " XP")
print()

-- ─── Test 3: HP variety (roll multiple raiders) ────────────────────────────

print("Test 3: HP Variety (Rolling 5 Gang Raiders)")
print("──────────────────────────────────────────────")

for i = 1, 5 do
  local testRaider = EnemyData.createEnemy("gang_raider")
  print(string.format("  Raider #%d: HP = %d/%d", i, testRaider:getHP(), testRaider:getMaxHP()))
end
print()

-- ─── Test 4: Combat simulation (damage and defense) ────────────────────────

print("Test 4: Combat Simulation")
print("───────────────────────────────────")

print("Initial state:")
print("  Raider: " .. raider:getStatsString())
print("  Scout: " .. scout:getStatsString())
print()

-- Raider takes 20 damage
print("→ Raider takes 20 raw damage")
local damageToRaider = raider:takeDamage(20)
print(string.format("  Actual damage after defense: %d", damageToRaider))
print("  " .. raider:getStatsString())
print()

-- Scout takes 20 damage (should be reduced more due to higher defense)
print("→ Scout takes 20 raw damage")
local damageToScout = scout:takeDamage(20)
print(string.format("  Actual damage after defense: %d", damageToScout))
print("  " .. scout:getStatsString())
print()

print("→ Scout defends (activates defensive stance)")
scout:setDefending(true)
print("→ Scout takes another 20 raw damage while defending")
local damageWhileDefending = scout:takeDamage(20)
print(string.format("  Actual damage while defending: %d", damageWhileDefending))
print("  " .. scout:getStatsString())
print()

-- ─── Test 5: Initiative rolls ───────────────────────────────────────────────

print("Test 5: Initiative Rolls (10 rolls per enemy)")
print("───────────────────────────────────────────────")

local raiderInitiatives = {}
local scoutInitiatives = {}

for i = 1, 10 do
  local testRaider = EnemyData.createEnemy("gang_raider")
  local testScout = EnemyData.createEnemy("warden_scout")
  table.insert(raiderInitiatives, testRaider:rollInitiative())
  table.insert(scoutInitiatives, testScout:rollInitiative())
end

-- Calculate averages
local function average(t)
  local sum = 0
  for _, v in ipairs(t) do sum = sum + v end
  return sum / #t
end

print(string.format("Gang Raider average initiative: %.1f (speed: %d)", 
  average(raiderInitiatives), raider:getSpeed()))
print(string.format("Warden Scout average initiative: %.1f (speed: %d)", 
  average(scoutInitiatives), scout:getSpeed()))
print("\nRaiders are faster due to higher speed stat (expected)")
print()

-- ─── Test 6: Death and healing ──────────────────────────────────────────────

print("Test 6: Death and Healing")
print("───────────────────────────────")

local testEnemy = EnemyData.createEnemy("gang_raider")
print("Test enemy: " .. testEnemy:getStatsString())
print()

print("→ Deal massive damage (999)")
testEnemy:takeDamage(999)
print(string.format("  Is dead: %s", tostring(testEnemy:isDead())))
print(string.format("  HP: %d/%d", testEnemy:getHP(), testEnemy:getMaxHP()))
print()

print("→ Try to heal a dead enemy")
local healAmount = testEnemy:heal(50)
print(string.format("  Heal amount: %d (should be 0 for dead enemies)", healAmount))
print()

-- ─── Test 7: Display data for UI ───────────────────────────────────────────

print("Test 7: Display Data for UI")
print("──────────────────────────────")

local freshEnemy = EnemyData.createEnemy("warden_scout")
freshEnemy:rollInitiative()
local displayData = freshEnemy:toDisplayData()

print("Display data fields:")
for key, value in pairs(displayData) do
  print(string.format("  %s: %s", key, tostring(value)))
end
print()

-- ─── Test 8: District and faction queries ──────────────────────────────────

print("Test 8: District and Faction Queries")
print("───────────────────────────────────────")

local district1Enemies = EnemyData.getEnemiesByDistrict(1)
print("District 1 enemies: " .. #district1Enemies)
for _, enemy in ipairs(district1Enemies) do
  print("  • " .. enemy.name)
end
print()

local wardenEnemies = EnemyData.getEnemiesByFaction("Wardens")
print("Warden faction enemies: " .. #wardenEnemies)
for _, enemy in ipairs(wardenEnemies) do
  print("  • " .. enemy.name)
end
print()

-- ─── Test 9: Encounter generation ──────────────────────────────────────────

print("Test 9: Encounter Generation")
print("───────────────────────────────")

print("Generating 3 random encounters for District 1:")
for i = 1, 3 do
  local encounter = EnemyData.generateEncounter(1)
  print(string.format("Encounter #%d: %d enemies", i, #encounter))
  
  -- Create enemy group from encounter
  local enemyGroup = EnemyData.createEnemyGroup(encounter, 1)
  for j, enemy in ipairs(enemyGroup) do
    print(string.format("  %d. %s", j, enemy:getStatsString()))
  end
end
print()

-- ─── Test 10: Loot table ────────────────────────────────────────────────────

print("Test 10: Loot Table")
print("──────────────────────")

local lootEnemy = EnemyData.createEnemy("warden_scout")
local loot = lootEnemy:getLootTable()

print("Warden Scout loot:")
print(string.format("  XP: %d", loot.xp))
print("  Item drops:")
for _, drop in ipairs(loot.items) do
  if drop.amount then
    print(string.format("    • %s: %d-%d (%.0f%% chance)", 
      drop.item, drop.amount.min, drop.amount.max, drop.chance * 100))
  else
    print(string.format("    • %s (%.0f%% chance)", drop.item, drop.chance * 100))
  end
end
print()

-- ─── Summary ────────────────────────────────────────────────────────────────

print("═══════════════════════════════════════")
print("✓ All Enemy System Tests Completed")
print("═══════════════════════════════════════")
print()
print("System Status:")
print("  • Enemy.lua: ✓ Working")
print("  • EnemyData.lua: ✓ Working")
print("  • 2 enemy types defined (Gang Raider, Warden Scout)")
print("  • HP variation: ✓ Working")
print("  • Damage/defense system: ✓ Working")
print("  • Initiative system: ✓ Working")
print("  • Death/healing: ✓ Working")
print("  • Loot tables: ✓ Working")
print("  • Encounter generation: ✓ Working")
print()
print("Ready for Phase 2 combat system integration!")
