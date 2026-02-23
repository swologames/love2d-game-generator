# src/data/
Static data tables — pure Lua tables, no logic. Loaded once and treated as read-only at runtime.

## Planned Files
| File | Contents |
|------|----------|
| `ClassData.lua` | Base stats, starting gear, and ability lists per class |
| `EnemyData.lua` | Enemy stat blocks (HP, damage, speed, loot tables, AI type) |
| `ItemData.lua` | Item definitions (weapons, armour, consumables, key items) |
| `AbilityData.lua` | Ability definitions (name, EP cost, effect, cooldown, targeting) |
| `LevelData.lua` | References to deck level files and deck metadata |
| `StatusEffectData.lua` | Status effect definitions (duration, tick damage, modifiers) |

Keep data and logic strictly separated. No `love.*` calls in data files.
