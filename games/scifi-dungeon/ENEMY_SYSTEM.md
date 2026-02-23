# Enemy System - Phase 2 Integration Guide

## Created Files

✓ **Enemy.lua** (260 lines) - Enemy entity orchestrator 
  - Location: `/src/entities/Enemy.lua`
  - Complete HP management, damage/defense, initiative, loot
  - Compatible with Character system API

✓ **EnemyData.lua** (199 lines) - Enemy type definitions and factory
  - Location: `/src/data/EnemyData.lua`
  - 2 enemy types: Gang Raider, Warden Scout
  - Encounter generation helpers
  - District and faction queries

✓ **test-enemy.lua** (228 lines) - Comprehensive test suite
  - Location: `/test-enemy.lua`
  - Run with: `lua test-enemy.lua`
  - All 10 tests passing ✓

## Enemy Types Defined

### 1. Gang Raider (District 1)
- **HP:** 20-30 (varied for replayability)
- **Attack:** 8 | **Defense:** 2 | **Speed:** 12
- **Range:** Melee
- **AI Type:** Aggressive
- **XP Reward:** 15
- **Loot:** 30% medpack, 80% credits (10-25)
- **Description:** Fast but fragile street thug

### 2. Warden Scout (District 1-2)
- **HP:** 35-50
- **Attack:** 12 | **Defense:** 8 | **Speed:** 8
- **Range:** Melee (shock baton)
- **AI Type:** Defensive
- **XP Reward:** 25
- **Loot:** 40% medpack, 25% stim_shot, 90% credits (20-40), 15% shock_cell
- **Description:** Heavily armored tactical enforcer

## API Overview

### Creating Enemies

```lua
local EnemyData = require("src.data.EnemyData")

-- Create single enemy
local raider = EnemyData.createEnemy("gang_raider", 1)

-- Generate random encounter
local encounter = EnemyData.generateEncounter(1)  -- District 1
local enemyGroup = EnemyData.createEnemyGroup(encounter, 1)
```

### Enemy Methods

```lua
-- HP Management
enemy:takeDamage(amount) -> actualDamage
enemy:heal(amount) -> actualHealing
enemy:isDead() -> boolean
enemy:getHP() -> currentHP
enemy:getMaxHP() -> maxHP
enemy:getHPPercent() -> 0.0-1.0

-- Combat
enemy:rollInitiative() -> initiativeValue
enemy:getInitiative() -> initiativeValue
enemy:setDefending(boolean)
enemy:getAttack() -> attackValue
enemy:getDefense() -> defenseValue
enemy:getSpeed() -> speedValue
enemy:getRange() -> "melee"|"short"|"long"
enemy:getAIType() -> "aggressive"|"defensive"|"tactical"

-- Display & Loot
enemy:toDisplayData() -> table (for UI)
enemy:getLootTable() -> {xp, items}
enemy:getXPReward() -> number
enemy:getStatsString() -> string (debug)
```

### Query Functions

```lua
-- Get enemies by criteria
EnemyData.getEnemiesByDistrict(1) -> array of templates
EnemyData.getEnemiesByFaction("Wardens") -> array of templates
EnemyData.getAllEnemyTypes() -> array of enemy IDs

-- Get template data
EnemyData.getTemplate("gang_raider") -> template table
```

## Damage Formula

Matches Character system for consistency:

```lua
defense = enemy.defense
damageReduction = defense / (defense + 100)
actualDamage = floor(rawDamage * (1 - damageReduction))

-- When defending: additional 20% reduction
if enemy.isDefending then
  actualDamage = floor(actualDamage * 0.8)
end
```

**Examples:**
- Gang Raider (DEF 2): Takes ~98% of raw damage
- Warden Scout (DEF 8): Takes ~92% of raw damage
- Warden Scout (DEF 8, defending): Takes ~74% of raw damage

## Initiative System

Uses GDD formula: `1d100 + speed`

- Gang Raider (speed 12): Averages ~62 initiative
- Warden Scout (speed 8): Averages ~58 initiative

Raiders act first on average, matching their "fast but fragile" design.

## Integration with Combat System

When building the combat system, use:

```lua
-- 1. Generate encounter for current district
local encounter = EnemyData.generateEncounter(currentDistrict)
local enemies = EnemyData.createEnemyGroup(encounter, partyLevel)

-- 2. Roll initiative for all combatants
for _, enemy in ipairs(enemies) do
  enemy:rollInitiative()
end
-- Sort by initiative...

-- 3. On player attack
local damage = calculatePlayerDamage(player, target)
local actualDamage = target:takeDamage(damage)

-- 4. On enemy death
if target:isDead() then
  local loot = target:getLootTable()
  awardXP(loot.xp)
  rollLoot(loot.items)
end
```

## Status Effects (Placeholder)

Status effects are stubbed for Phase 3:
- `enemy:addStatusEffect(type, duration)` 
- `enemy:removeStatusEffect(type)`
- `enemy:updateStatusEffects()`

Current implementation maintains the interface but does minimal logic.

## Adding New Enemy Types

To add more enemies in Phase 3:

```lua
-- In EnemyData.lua
EnemyData.new_enemy_id = {
  id = "new_enemy_id",
  name = "Display Name",
  hp = {min = X, max = Y},
  attack = N,
  defense = N,
  speed = N,
  range = "melee"|"short"|"long",
  ai_type = "aggressive"|"defensive"|"tactical",
  xp_reward = N,
  loot_table = { ... },
  sprite = "sprite_name",
  description = "...",
  faction = "...",
  district = N  -- or district_range = {min, max}
}
```

## Testing

All tests pass:
- ✓ Enemy creation from templates
- ✓ HP variation (random rolls)
- ✓ Damage/defense system
- ✓ Defending stance mechanics
- ✓ Initiative rolls
- ✓ Death state handling
- ✓ Healing (including dead enemies)
- ✓ Display data formatting
- ✓ District/faction queries
- ✓ Encounter generation
- ✓ Loot table structure

Run tests: `lua test-enemy.lua`

## Next Steps for Phase 2

1. **Combat System** - Create turn-based combat manager
   - Initiative sorting
   - Turn execution
   - Combat state machine
   - Victory/defeat conditions

2. **Combat UI** - Display combat state
   - Enemy HP bars
   - Initiative order display
   - Action selection
   - Damage numbers

3. **Integration** - Connect to game flow
   - Trigger combat on enemy cell entry
   - Award XP and loot on victory
   - Return to exploration

## File Size Compliance

✓ Enemy.lua: 260 lines (limit: 300)
✓ EnemyData.lua: 199 lines (limit: 300)

Both files follow componentization guidelines with clear single responsibilities.

---

**System Status: Ready for Phase 2 Combat Integration**
