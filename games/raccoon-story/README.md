# 🦝 Raccoon Story

A cozy top-down adventure game where you play as a resourceful raccoon scavenging for trash to feed your family!

## 🎮 About the Game

Navigate through a charming suburban neighborhood at night, collecting delicious trash and tasty morsels to bring back to your raccoon family. Avoid pesky humans, dodge protective dogs, and compete with other hungry animals for the best snacks!

## 🚀 Getting Started

### Prerequisites
- [Love2D 11.4+](https://love2d.org/) installed on your system

### Running the Game
```bash
cd games/raccoon-story
love .
```

Or drag the `raccoon-story` folder onto the Love2D application icon.

## 🎯 Game Features (Planned)

- **Cozy Exploration**: Roam through backyards, alleys, parks, and streets
- **Resource Collection**: Gather various types of trash items
- **Stealth Gameplay**: Hide in bushes and shadows to avoid detection
- **Time Management**: Complete your scavenging before dawn breaks
- **Progression System**: Unlock new areas and upgrade your abilities
- **Charming Art Style**: Hand-drawn, storybook-inspired visuals
- **Family Love**: Keep your raccoon family happy and well-fed!

## 🎮 Controls

- **WASD / Arrow Keys**: Move your raccoon
- **Space**: Pick up trash / Interact
- **Shift**: Dash (quick burst of speed)
- **E**: Hide in bushes or shadows
- **Tab**: View inventory
- **ESC**: Pause menu

## 📚 Documentation

- [Game Design Document](GAME_DESIGN.md) - Complete game design specifications
- [Sprite System Documentation](docs/SPRITE_SYSTEM.md) - Programmatic sprite generation system
- [Playtest Guide](PLAYTEST_GUIDE.md) - Detailed gameplay info
- Project structure follows Love2D best practices

## 🎨 Art & Graphics

**Raccoon Story uses programmatic sprite generation!** All game graphics are created using Love2D's drawing functions at runtime - no external image files needed.

### Features:
- ✨ **Hand-drawn style** with soft edges and warm colors
- 🦝 **Animated player raccoon** with idle (4 frames) and walk (6 frames) animations
- 🍕 **Detailed trash items** (pizza, burger, donut box, trash bag)
- 👤 **Enemies** (humans and dogs) with distinctive designs
- 🌳 **Environment objects** (bushes, trash bins)
- 📦 **Only ~38KB** total memory for all sprites
- 🔧 **Easy to modify** - no external tools required

**View the sprites:**
```bash
love sprite-viewer.lua
```

See [docs/SPRITE_SYSTEM.md](docs/SPRITE_SYSTEM.md) for technical details.

## 🛠️ Development Status

**Current Version**: v0.1.0 (Playable Prototype!)

**✅ PLAYABLE NOW!** Core gameplay loop is functional!

### What's Working ✨
- ✅ Player movement (8-directional, smooth)
- ✅ Dash ability with cooldown
- ✅ Trash collection system (4 types)
- ✅ Inventory management (6 slots)
- ✅ Score and time tracking
- ✅ Scrolling camera
- ✅ Complete HUD display
- ✅ 1600x1200 world to explore
- ✅ **Programmatic sprite generation** - Beautiful hand-drawn style graphics!

### Development Roadmap
- [x] **Phase 1: Prototype** - Core movement and collection mechanics ✅
  - [x] Player controls and dash ✅
  - [x] Collectible trash items ✅
  - [x] Basic world and camera ✅
  - [ ] Obstacles and hiding spots (next)
  - [ ] Basic enemy AI (next)
- [ ] Phase 2: Core Development - Complete gameplay systems
- [ ] Phase 3: Content Creation - Art, audio, and level design
- [ ] Phase 4: Polish - Effects, juice, and refinement
- [ ] Phase 5: Release - Final builds and launch

📖 **[See PLAYTEST_GUIDE.md](PLAYTEST_GUIDE.md) for detailed gameplay info!**

## 🤝 Contributing

This is a personal project, but feedback and suggestions are welcome!

## 📝 License

TBD

## 🎨 Credits

Game design and development: [Your Name]

---

*A cozy game about a not-so-cozy life of a suburban raccoon.* 🗑️✨
