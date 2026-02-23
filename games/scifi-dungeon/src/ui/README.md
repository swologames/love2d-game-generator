# src/ui/
HUD components, overlays, and reusable UI widgets.

## Planned Files
| File | Responsibility |
|------|---------------|
| `HUD.lua` | HUD orchestrator — wires Compass, Minimap, PartyPanel, MessageLog, AbilityBar |
| `Compass.lua` | Direction strip — scrolls on rotation, highlights current facing |
| `Minimap.lua` | 64×64 px explored-tile minimap |
| `PartyPanel.lua` | Four party status cards (portrait, HP/EP bars, status icons) |
| `MessageLog.lua` | Scrolling message strip at screen bottom |
| `AbilityBar.lua` | Four active ability slots for selected party member |
| `Button.lua` | Reusable button widget (normal/hover/pressed/disabled states) |
| `Tooltip.lua` | Item/ability tooltip popup |

Max 300 lines per file. See GDD Section 5 for layout and style specifications.
