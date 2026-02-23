# src/entities/
Game object classes — characters, enemies, and items.

## Planned Files
| File | Responsibility |
|------|---------------|
| `Party.lua` | Party orchestrator — holds 4 Character instances |
| `Character.lua` | Individual character stats, equipment, level, abilities |
| `Enemy.lua` | Enemy instance (type lookup from EnemyData, combat state) |
| `classes/Marine.lua` | Marine-specific abilities and passive logic |
| `classes/Hacker.lua` | Hacker-specific abilities and passive logic |
| `classes/Medic.lua` | Medic-specific abilities and passive logic |
| `classes/Engineer.lua` | Engineer-specific abilities and passive logic |
| `classes/Psionic.lua` | Psionic-specific abilities and passive logic |

Max 300 lines per file. Split sub-responsibilities further if needed.
