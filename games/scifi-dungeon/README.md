# Scifi Dungeon

> ⚠️ **DRAFT — Early development. GDD and systems are subject to change.**

## Concept

A first-person, grid-based dungeon crawler (blobber) set aboard the derelict *Erebus Station*.
Lead a squad of four specialists through five dangerous Decks, fight corrupted crew and alien
infiltrators in turn-based combat, and recover the rogue AI core before the countdown ends.

Inspired by **Wizardry**, **Eye of the Beholder**, **Legend of Grimrock**, and **System Shock**.

## Quick Start

```bash
cd games/scifi-dungeon
love .
```

Requires [Love2D 11.4+](https://love2d.org/).

## Controls (Dungeon)

| Key | Action |
|-----|--------|
| W / ↑ | Step forward |
| S / ↓ | Step backward |
| A | Strafe left |
| D | Strafe right |
| Q / ← | Rotate left |
| E / → | Rotate right |
| Space | Interact |
| Tab | Party / Inventory |
| M | Toggle automap |
| 1–4 | Select party member |
| ESC | Pause |

## Project Structure

```
scifi-dungeon/
├── main.lua          — Love2D entry point
├── conf.lua          — Window and module configuration
├── GAME_DESIGN.md    — Full Game Design Document (DRAFT v0.1)
├── src/
│   ├── scenes/       — Scene manager + all game scenes
│   ├── entities/     — Character, Party, Enemy
│   ├── systems/      — Dungeon map, combat, audio, save…
│   ├── ui/           — HUD, minimap, compass, party panel…
│   ├── utils/        — Constants, helpers
│   └── data/         — Static data tables (classes, items, enemies)
├── levels/           — Hand-crafted deck definitions
├── assets/           — Images, sounds, music, fonts, shaders
└── lib/              — Third-party Lua libraries
```

## Development Status

| Feature | Status |
|---------|--------|
| Grid movement | 🔲 Not started |
| Raycaster viewport | 🔲 Not started |
| Turn-based combat | 🔲 Not started |
| Party system | 🔲 Not started |
| Inventory system | 🔲 Not started |
| Minimap | 🔲 Not started |
| Save / Load | 🔲 Not started |
| Deck 1 complete | 🔲 Not started |

See `GAME_DESIGN.md` for the full design vision and `TODO.md` (coming soon) for the task backlog.

## Design Document

See [GAME_DESIGN.md](GAME_DESIGN.md) for the complete **DRAFT v0.1** GDD covering:
- Class system (Marine, Hacker, Medic, Engineer, Psionic)
- Turn-based combat model
- First-person raycaster approach
- Five-deck structure and enemy roster
- UI/HUD layout and style guide
- Audio direction
- Technical architecture
