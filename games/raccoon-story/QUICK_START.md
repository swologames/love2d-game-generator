# 🎮 Raccoon Story - Quick Start Guide

## ✅ Project Setup Complete!

Your game scaffolding is ready! Here's what has been created:

### 📂 Project Structure
```
games/raccoon-story/
├── GAME_DESIGN.md          ✅ Complete game design document
├── README.md               ✅ Project overview
├── main.lua                ✅ Game entry point
├── conf.lua                ✅ Love2D configuration
├── /src                    ✅ Source code
│   ├── /scenes            SceneManager + MenuScene
│   ├── /entities          Player entity (functional)
│   ├── /systems           Placeholder folders
│   ├── /ui                Placeholder folders
│   └── /utils             Asset manager + Helpers
├── /assets                 ✅ Asset folders
│   ├── /images
│   ├── /sounds
│   ├── /music
│   ├── /fonts
│   └── /shaders
└── /lib                    ✅ External libraries folder
```

## 🚀 Running the Game

### Option 1: Command Line
```bash
cd games/raccoon-story
love .
```

### Option 2: Drag and Drop
Drag the `raccoon-story` folder onto your Love2D application icon.

## 📋 What's Implemented

### ✅ Working
- **Basic game loop** - love.load(), love.update(), love.draw()
- **Scene Manager** - Ready to manage game scenes
- **Menu Scene** - Placeholder main menu
- **Player Entity** - Full movement, dash, inventory system
- **Asset Manager** - Image, sound, music loading
- **Helper Utilities** - Math, collision, formatting functions
- **Configuration** - Window settings, modules

### 🚧 To Be Implemented
- Game scene with actual gameplay
- AI system for enemies
- Collision detection
- Trash item collection
- UI components (HUD, buttons, inventory display)
- All art and audio assets
- Additional scenes (Den, Game levels)

## 🎯 Next Steps

### Phase 1: Prototype (Recommended Order)

1. **Run the game** to verify setup
   ```bash
   cd games/raccoon-story && love .
   ```

2. **Create basic GameScene**
   - Copy MenuScene.lua pattern
   - Add Player entity
   - Implement basic rendering

3. **Add TrashItem entity**
   - Create collectible items
   - Implement pickup logic

4. **Test basic gameplay loop**
   - Move around
   - Collect trash
   - Check inventory

5. **Add placeholder art**
   - Simple shapes or free assets
   - Test visual feedback

### Using the Game Designer Agent

For feature implementation, coordinate with the Game Designer:

```
@game-designer In raccoon-story, implement [feature name]
```

The Game Designer will delegate to specialized agents:
- **@gameplay** - Player mechanics, AI, game rules
- **@ui** - HUD, menus, buttons
- **@graphics** - Particles, shaders, effects
- **@audio** - Sound effects, music
- **@physics** - Collision detection

## 📖 Documentation

- **[GAME_DESIGN.md](GAME_DESIGN.md)** - Complete game specifications
- **[README.md](README.md)** - Project overview
- **Source code** - All files have inline documentation

## 🎨 Game Concept Recap

**Raccoon Story** is a cozy top-down game where you:
- Play as a clever raccoon 🦝
- Scavenge for trash at night 🌙
- Bring food back to your family ❤️
- Avoid humans, dogs, and competing animals 🏃
- Unlock new areas and abilities 🎯

The game emphasizes:
- **Cozy aesthetics** - Warm, inviting art style
- **Stealth gameplay** - Hide and dash mechanics
- **Resource management** - Limited inventory space
- **Time pressure** - Night cycle creates urgency
- **Progression** - Unlock upgrades and areas

## 🧪 Testing

### Current Test
Run the game - you should see:
- Dark blue-purple background
- "Raccoon Story" title
- Version number
- Placeholder menu text
- FPS counter (top-left)

### Controls (Currently Active)
- **ESC** - Quit game
- Space will be used for menu navigation (not yet connected)

## 🆘 Troubleshooting

### Game won't start
- Verify Love2D is installed: `love --version`
- Check you're in the correct directory
- Look for error messages in console

### Black screen
- This is normal - the current build shows a placeholder menu
- Check for errors in the terminal

### Need help?
- Review [GAME_DESIGN.md](GAME_DESIGN.md) for specifications
- Ask @game-designer to implement specific features
- Check source code README files for guidance

## 🎉 You're Ready!

Your game foundation is complete. Start implementing features according to the GDD, and coordinate with specialized agents for complex tasks.

**Happy game development! 🦝✨**
