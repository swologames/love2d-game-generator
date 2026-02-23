-- test-combat.lua
-- Unit test for CombatSystem (Phase 2)
-- Run with: lua test-combat.lua

-- ─── Mock love.math.random ──────────────────────────────────────────────────
_G.love = {
  math = {
    random = function(min, max)
      if not min then return math.random() end
      if not max then return math.random(0, min) end
      return math.random(min, max)
    end
  }
}

-- ─── Setup package path ─────────────────────────────────────────────────────
package.path = package.path .. ";./?.lua"

-- ─── Load dependencies ──────────────────────────────────────────────────────
local CombatSystem = require("src.systems.CombatSystem")

-- Mock Character class for testing
local MockCharacter = {}
MockCharacter.__index = MockCharacter

function MockCharacter:new(name, hp, stats)
  local instance = setmetatable({}, MockCharacter)
  instance.name = name
  instance.currentHP = hp
  instance.maxHP = hp
  instance.currentEP = 50
  instance.maxEP = 50
  instance.isAlive = true
  instance.isDefending = false
  instance.initiative = 0
  instance.stats = stats or {STR = 10, REF = 10, CON = 10}
  return instance
end

function MockCharacter:isAliveCheck()
  return self.currentHP > 0
end

function MockCharacter:isDead()
  return self.currentHP <= 0
end

function MockCharacter:getHP()
  return self.currentHP
end

function MockCharacter:getMaxHP()
  return self.maxHP
end

function MockCharacter:getHPPercent()
  return self.currentHP / self.maxHP
end

function MockCharacter:getEP()
  return self.currentEP
end

function MockCharacter:getMaxEP()
  return self.maxEP
end

function MockCharacter:getEPPercent()
  return self.currentEP / self.maxEP
end

function MockCharacter:takeDamage(amount)
  self.currentHP = math.max(0, self.currentHP - amount)
  if self.currentHP <= 0 then
    self.isAlive = false
  end
end

function MockCharacter:heal(amount)
  self.currentHP = math.min(self.maxHP, self.currentHP + amount)
end

function MockCharacter:getStat(statName)
  return self.stats[statName] or 0
end

function MockCharacter:rollInitiative()
  local reflexBonus = self:getStat("REF") * 5
  self.initiative = math.random(1, 100) + reflexBonus
  return self.initiative
end

function MockCharacter:setDefending(defending)
  self.isDefending = defending
end

-- Mock Enemy class for testing
local MockEnemy = {}
MockEnemy.__index = MockEnemy

function MockEnemy:new(name, hp, attack, defense, speed)
  local instance = setmetatable({}, MockEnemy)
  instance.name = name
  instance.currentHP = hp
  instance.maxHP = hp
  instance.attack = attack or 10
  instance.defense = defense or 5
  instance.speed = speed or 10
  instance.isAlive = true
  instance.isDefending = false
  instance.initiative = 0
  instance.xpReward = 100
  instance.lootTable = {}
  return instance
end

function MockEnemy:isDead()
  return self.currentHP <= 0
end

function MockEnemy:getHP()
  return self.currentHP
end

function MockEnemy:getMaxHP()
  return self.maxHP
end

function MockEnemy:getHPPercent()
  return self.currentHP / self.maxHP
end

function MockEnemy:takeDamage(amount)
  self.currentHP = math.max(0, self.currentHP - amount)
  if self.currentHP <= 0 then
    self.isAlive = false
  end
end

function MockEnemy:heal(amount)
  self.currentHP = math.min(self.maxHP, self.currentHP + amount)
end

function MockEnemy:rollInitiative()
  local speedBonus = self.speed * 5
  self.initiative = math.random(1, 100) + speedBonus
  return self.initiative
end

function MockEnemy:setDefending(defending)
  self.isDefending = defending
end

function MockEnemy:getAttack()
  return self.attack
end

function MockEnemy:getDefense()
  return self.defense
end

function MockEnemy:getSpeed()
  return self.speed
end

function MockEnemy:getXPReward()
  return self.xpReward
end

function MockEnemy:getLootTable()
  return self.lootTable
end

-- ─── Test Framework ─────────────────────────────────────────────────────────

local passed = 0
local failed = 0

local function assert_equal(actual, expected, message)
  if actual == expected then
    passed = passed + 1
    print("✓ " .. (message or "Passed"))
    return true
  else
    failed = failed + 1
    print("✗ " .. (message or "Failed") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
    return false
  end
end

local function assert_true(condition, message)
  if condition then
    passed = passed + 1
    print("✓ " .. (message or "Passed"))
    return true
  else
    failed = failed + 1
    print("✗ " .. (message or "Failed"))
    return false
  end
end

local function assert_not_nil(value, message)
  if value ~= nil then
    passed = passed + 1
    print("✓ " .. (message or "Passed"))
    return true
  else
    failed = failed + 1
    print("✗ " .. (message or "Failed") .. ": value is nil")
    return false
  end
end

-- ─── Tests ──────────────────────────────────────────────────────────────────

print("\n=== CombatSystem Tests ===\n")

-- Test 1: Combat initialization
print("Test 1: Combat initialization")
local party = {
  MockCharacter:new("Alice", 100, {STR = 15, REF = 12, CON = 10}),
  MockCharacter:new("Bob", 80, {STR = 10, REF = 15, CON = 8})
}
local enemies = {
  MockEnemy:new("Goblin", 50, 8, 3, 8),
  MockEnemy:new("Orc", 70, 12, 5, 6)
}

local combat = CombatSystem:new(party, enemies)
assert_not_nil(combat, "Combat system created")
assert_equal(combat.state, "in_progress", "Combat state is in_progress")
assert_equal(#combat.party, 2, "Party has 2 members")
assert_equal(#combat.enemies, 2, "Enemies has 2 members")

-- Test 2: Initiative rolling
print("\nTest 2: Initiative rolling")
combat:rollInitiative()
assert_true(#combat.turnQueue > 0, "Turn queue populated")
assert_equal(#combat.turnQueue, 4, "Turn queue has 4 combatants")

local firstCombatant = combat:getCurrentCombatant()
assert_not_nil(firstCombatant, "First combatant exists")
assert_true(firstCombatant.initiative > 0, "First combatant has initiative > 0")

-- Test 3: Turn order is sorted by initiative
print("\nTest 3: Turn order sorted")
local prevInitiative = math.huge
local sortedCorrectly = true
for _, entry in ipairs(combat.turnQueue) do
  if entry.initiative > prevInitiative then
    sortedCorrectly = false
    break
  end
  prevInitiative = entry.initiative
end
assert_true(sortedCorrectly, "Turn queue sorted by initiative (descending)")

-- Test 4: Damage calculation
print("\nTest 4: Damage calculation")
local attacker = party[1]
local target = enemies[1]
local damage = combat:calculateDamage(attacker, target)
assert_true(damage > 0, "Damage is greater than 0")
assert_true(damage >= 1, "Minimum damage is 1")
print("  Calculated damage: " .. damage)

-- Test 5: Attack action
print("\nTest 5: Attack action")
local targetHP = target:getHP()
combat:performAttack(attacker, target, false)
assert_true(target:getHP() < targetHP, "Target HP reduced after attack")
print("  Target HP: " .. targetHP .. " -> " .. target:getHP())

-- Test 6: Defend action
print("\nTest 6: Defend action")
local defender = party[2]
assert_true(not defender.isDefending, "Defender not defending initially")
combat:performDefend(defender)
assert_true(defender.isDefending, "Defender is now defending")

-- Test 7: Defend reduces damage
print("\nTest 7: Defend reduces damage")
-- Create high-damage enemy to ensure noticeable difference
local strongEnemy = MockEnemy:new("Ogre", 100, 50, 2, 10)
local testTarget = MockCharacter:new("TestTarget", 100, {STR = 10, REF = 10, CON = 5})

local normalDamage = combat:calculateDamage(strongEnemy, testTarget)
testTarget:setDefending(true)
local defendedDamage = combat:calculateDamage(strongEnemy, testTarget)
testTarget:setDefending(false)
assert_true(defendedDamage < normalDamage, "Defending reduces damage taken")
print("  Normal: " .. normalDamage .. ", Defended: " .. defendedDamage)

-- Test 8: Combat state transitions
print("\nTest 8: Combat state transitions")
-- Kill all enemies
for _, enemy in ipairs(enemies) do
  enemy.currentHP = 0
  enemy.isAlive = false
end
combat:checkCombatEnd()
assert_equal(combat.state, "victory", "Combat state is victory when all enemies dead")

-- Test 9: Loot generation
print("\nTest 9: Loot generation")
local loot = combat:getLoot()
assert_not_nil(loot, "Loot generated")
assert_true(loot.xp > 0, "XP reward generated")
assert_not_nil(loot.items, "Items table exists")
print("  XP: " .. loot.xp)

-- Test 10: Enemy AI targeting
print("\nTest 10: Enemy AI targeting")
local newCombat = CombatSystem:new(party, {MockEnemy:new("Slime", 30, 5, 2, 5)})
party[1].currentHP = 10  -- Make Alice weak
party[2].currentHP = 80  -- Bob is healthy
local weakest = newCombat:getWeakestPartyMember()
assert_equal(weakest.name, "Alice", "AI targets weakest party member")

-- Test 11: Turn advancement
print("\nTest 11: Turn advancement")
local testCombat = CombatSystem:new(
  {MockCharacter:new("Hero", 100)},
  {MockEnemy:new("Monster", 50, 10, 5, 5)}
)
testCombat:rollInitiative()
local firstTurn = testCombat:getCurrentCombatant()
testCombat:nextTurn()
local secondTurn = testCombat:getCurrentCombatant()
assert_true(firstTurn ~= secondTurn, "Turn advanced to different combatant")

-- Test 12: Combat log
print("\nTest 12: Combat log")
local logCombat = CombatSystem:new(party, enemies)
logCombat:addLog("Test message")
local log = logCombat:getLog()
assert_true(#log > 0, "Combat log has entries")
local recent = logCombat:getRecentLog(1)
assert_equal(recent[1], "Test message", "Recent log retrieval works")

-- ─── Summary ────────────────────────────────────────────────────────────────

print("\n=== Test Summary ===")
print("Passed: " .. passed)
print("Failed: " .. failed)
print("Total:  " .. (passed + failed))

if failed == 0 then
  print("\n✓ All tests passed!")
  os.exit(0)
else
  print("\n✗ Some tests failed")
  os.exit(1)
end
