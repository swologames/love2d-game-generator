# Mecha Shmup

A vertical scrolling shoot-em-up (shmup) powered by Love2D, featuring intense mecha combat against the Tau Deu alien invasion.

## Game Features

### Core Gameplay
- **3 Unique Pilots**: Choose from Kai "Valkyrie" Rexford, Zara "Phantom" Nakamura, or Viktor "Bastion" Kozlov, each with distinct stats and weapons
- **Character-Specific Weapons**: Each pilot has unique shooting patterns that evolve with power-ups
- **Focus Mode**: Hold SHIFT to slow down and reveal your hitbox for precision dodging
- **Wave-Based Combat**: Survive increasingly difficult waves of enemies
- **Boss Battles**: Face off against massive bosses every 3 waves

### Enemy Types
- **Tau Scouts**: Fast, weak enemies with simple straight shots
- **Tau Interceptors**: Tougher enemies that aim their shots at you
- **Tau Bombers**: Slow but dangerous with 5-way spread shots
- **Tau Kamikazes**: High-speed suicide attackers
- **Boss: Vor'kath the Ravager**: Stage 1 boss with 4 devastating attack patterns

### Power-Up System
- **Health**: Restore 1 HP
- **Weapon Power**: Upgrade your weapon (up to level 5)
- **Special Charge**: Gain special attack charges
- **Shield**: Temporary invulnerability (5 seconds)
- **Score Bonus**: +1000 points

### Visual Effects
- **Particle System**: Explosions, bullet trails, engine exhaust, and power-up collection effects
- **Screen Shake**: Dynamic camera shake on impacts and explosions
- **Animated Backgrounds**: Parallax scrolling starfields
- **Visual Feedback**: Flash effects on damage, glowing power-ups, boss health bars

### Collision Detection
- Full collision system between:
  - Player bullets vs enemies
  - Enemy bullets vs player
  - Enemies vs player (collision damage)
  - Power-ups vs player
  - Boss bullets vs player
  - Player bullets vs boss

## Controls

- **WASD / Arrow Keys**: Move your mecha
- **SPACE / Z**: Fire weapons
- **LSHIFT / RSHIFT**: Focus mode (slow movement, visible hitbox)
- **ESC**: Pause game / Resume
- **Q** (while paused): Quit to main menu

### Debug Controls (F3 to enable)
- **F3**: Toggle debug overlay (FPS, entity counts, boss HP)
- **B**: Spawn boss immediately (debug mode only)
- **P**: Spawn random power-up at player position (debug mode only)

## Character Comparison

| Pilot | Speed | Health | Defense | Skill | Weapon Type | Special Ability |
|-------|-------|--------|---------|-------|-------------|-----------------|
| Kai "Valkyrie" | ⚡⚡⚡ | ❤️❤️❤️ | 🛡️🛡️ | ⭐⭐⭐⭐ | Plasma Cannon | Precision Strike |
| Zara "Phantom" | ⚡⚡⚡⚡ | ❤️❤️ | 🛡️ | ⭐⭐⭐⭐⭐ | Laser Array | Phase Shift |
| Viktor "Bastion" | ⚡⚡ | ❤️❤️❤️❤️ | 🛡️🛡️🛡️🛡️ | ⭐⭐⭐ | Railgun | Siege Mode |

## How to Play

1. **Main Menu**: Launch the game and press "Start Game"
2. **Character Select**: Choose your pilot (use arrow keys or mouse)
3. **Survive**: Dodge enemy bullets, shoot down enemies, collect power-ups
4. **Boss Fight**: Defeat the boss every 3 waves
5. **Score High**: Chain kills and collect score bonuses

## Scoring System

- Tau Scout: 100 points
- Tau Interceptor: 250 points
- Tau Bomber: 400 points
- Tau Kamikaze: 150 points
- Boss Defeat: 10,000 points
- Score Bonus Power-Up: 1,000 points

## Tips & Strategy

1. **Power-Ups Are Key**: Weapon upgrades dramatically increase your firepower
2. **Use Focus Mode**: Essential for dodging dense bullet patterns
3. **Stay Mobile**: Keep moving to avoid getting cornered
4. **Learn Boss Patterns**: Each boss has 4 distinct attack patterns
5. **Collect Dropped Power-Ups**: Enemies have a 15% chance to drop power-ups when defeated

## Technical Details

- **Engine**: Love2D 11.4+
- **Language**: Lua with OOP patterns
- **Resolution**: 800x720
- **Target FPS**: 60 FPS
- **Architecture**: Scene management system with entity-component patterns

## Project Structure

```
games/mecha-shmup/
├── main.lua                    # Entry point
├── conf.lua                    # Love2D configuration
├── GAME_DESIGN.md              # Complete game design document
├── README.md                   # This file
├── src/
│   ├── scenes/
│   │   ├── SceneManager.lua    # Scene lifecycle manager
│   │   ├── MenuScene.lua       # Main menu
│   │   ├── CharacterSelectScene.lua  # Character selection
│   │   └── GameScene.lua       # Main gameplay
│   ├── entities/
│   │   ├── Player.lua          # Player mecha with 3 character types
│   │   ├── Enemy.lua           # Enemy entity with 4 types
│   │   ├── PowerUp.lua         # Collectible power-ups
│   │   └── Boss.lua            # Boss entity (Vor'kath)
│   ├── systems/
│   │   ├── CollisionSystem.lua # Collision detection
│   │   └── ParticleSystem.lua  # Visual effects
│   └── ui/
│       └── Button.lua          # Reusable UI button
└── assets/                     # Game assets (to be added)
```

## Development Status

### ✅ Completed
- Multi-game workspace structure
- Complete Game Design Document with 3 pilots, support crew, and 4 bosses
- Scene management system with smooth transitions
- Main menu with animated background
- Character selection with stats visualization
- Full gameplay scene with HUD
- Player entity with 3 character types
- Character-specific weapons with 5 upgrade levels
- Enemy system with 4 enemy types
- Power-up collection system
- Boss battle system (Vor'kath the Ravager)
- Comprehensive collision detection
- Particle effects system
- Screen shake effects
- Wave progression system
- Game over handling

### 🎯 Next Steps (Future Enhancements)
- Audio system (music and sound effects)
- Additional boss fights (Xel'nara, Kry'zoth, Zha'thul)
- Special ability implementation for each pilot
- Story mode with dialog sequences
- High score persistence
- More visual polish (shaders, advanced particles)
- Gamepad support
- Options menu (volume, controls, display)

## Running the Game

```bash
cd games/mecha-shmup
love .
```

## Credits

Developed as part of the Love2DAI multi-game workspace project.

## License

See project root for license information.
