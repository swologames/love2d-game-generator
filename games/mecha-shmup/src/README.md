# Source Code

This folder contains all the game's source code organized by system.

## Folder Structure

- **/scenes** - Scene manager and individual scenes (MenuScene, GameScene, etc.)
- **/entities** - Game entities (Player, Enemy, Bullet, PowerUp, Boss)
- **/systems** - Game systems (CollisionSystem, SpawnManager, ScoreSystem)
- **/ui** - UI components (HUD, menus, buttons)
- **/utils** - Utility functions and helpers
- **/audio** - Audio manager and sound logic
- **/shaders** - GLSL shader files

## Getting Started

Start by implementing the core systems:
1. Player entity in `/entities/Player.lua`
2. Scene manager in `/scenes/SceneManager.lua`
3. Basic collision in `/systems/CollisionSystem.lua`

Ask the specialized agents to help implement each system according to the GDD!
