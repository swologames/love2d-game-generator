# src/systems/
Core game systems. Each file has one responsibility.

## Planned Files
| File | Responsibility |
|------|---------------|
| `DungeonMap.lua` | Grid world — cell types, fog-of-war, level loading |
| `MovementSystem.lua` | Step-based movement, wall collision, door interaction |
| `CombatSystem.lua` | Turn-based initiative, action resolution, status effects |
| `InventorySystem.lua` | Item management, equip/unequip, weight calculation |
| `LevelSystem.lua` | XP awards, leveling up, skill point grants |
| `AudioSystem.lua` | Music/SFX playback, crossfade, volume management |
| `SaveSystem.lua` | Serialise/deserialise game state to Love2D filesystem |
| `RaycasterSystem.lua` | First-person column-based renderer — renders to Canvas |

Max 300 lines per file. Split further if needed.
