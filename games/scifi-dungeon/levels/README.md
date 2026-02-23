# levels/
Hand-crafted dungeon deck definitions. Each file returns a Lua table describing the grid map,
entity placements, triggers, and metadata for one deck.

## File Format (draft)
```lua
return {
  name   = "Deck 1 — Docking Ring",
  width  = 20,   -- grid columns
  height = 20,   -- grid rows
  startX = 1,
  startY = 1,
  startDir = "N",  -- starting facing direction

  -- 2D array of cell type strings (row-major, [y][x])
  grid = {
    { "wall", "wall", ... },
    { "wall", "floor", ... },
    ...
  },

  -- Named entities placed on specific cells
  entities = {
    { type = "enemy", id = "security_drone_mk1", x = 5, y = 3 },
    { type = "item",  id = "medpack",            x = 2, y = 4 },
    { type = "door",  locked = true, keycard = "docking_keycard", x = 8, y = 5 },
  },

  -- Trigger zones (stepped on → callback key)
  triggers = {
    { x = 10, y = 10, event = "boss_intro" },
  },

  -- Lore / ambient text shown on specific cells
  logs = {
    { x = 3, y = 2, text = "\"Emergency evacuation route sealed. Authorisation 7-Alpha required.\"" },
  },
}
```

## Deck Files
| File | Deck | Theme |
|------|------|-------|
| `deck1.lua` | 1 | Docking Ring — airlock corridors, tutorial |
| `deck2.lua` | 2 | Research Labs — containment cells, experiments |
| `deck3.lua` | 3 | Engineering — reactor halls, catwalks |
| `deck4.lua` | 4 | Command Centre — bridge, AI systems |
| `deck5.lua` | 5 | The Nest — alien overgrowth, final boss |
