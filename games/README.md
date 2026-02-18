# Games Folder

This folder contains multiple independent Love2D game projects. Each game is a complete, self-contained, runnable Love2D project.

## 🎮 Current Games

### 🦝 Raccoon Story
**Status**: Early Development (v0.1.0)  
**Genre**: Cozy Top-Down Adventure  
**Description**: A resourceful raccoon scavenging for trash to feed their family while avoiding humans and competing animals.

📁 [games/raccoon-story/](raccoon-story/)  
📖 [Game Design Document](raccoon-story/GAME_DESIGN.md)  
🚀 [Quick Start Guide](raccoon-story/QUICK_START.md)

### 🚀 Mecha Shmup
**Status**: In Development  
**Genre**: Shoot 'em Up  
**Description**: A fast-paced mecha shooter.

📁 [games/mecha-shmup/](mecha-shmup/)  
📖 [Game Design Document](mecha-shmup/GAME_DESIGN.md)

## Folder Structure

Each game folder should follow this structure:

```
games/
├── my-platformer/              # Game folder name (kebab-case recommended)
│   ├── GAME_DESIGN.md          # Game Design Document (required)
│   ├── main.lua                # Love2D entry point (required)
│   ├── conf.lua                # Love2D configuration (required)
│   ├── /src                    # Source code
│   │   ├── /scenes             # Scene manager and scenes
│   │   ├── /entities           # Game entities (Player, Enemy, etc.)
│   │   ├── /systems            # Systems (Physics, Collision, etc.)
│   │   ├── /ui                 # UI components and menus
│   │   ├── /utils              # Utility functions
│   │   ├── /audio              # Audio manager
│   │   └── /shaders            # GLSL shader files
│   ├── /assets                 # Game assets
│   │   ├── /images             # Sprites, textures, tilesets
│   │   ├── /sounds             # Sound effects
│   │   ├── /music              # Music tracks
│   │   ├── /fonts              # Font files
│   │   └── /shaders            # Shader source files
│   ├── /lib                    # External libraries (if any)
│   └── README.md               # Game-specific documentation (optional)
│
├── another-game/               # Another independent game
│   ├── GAME_DESIGN.md
│   ├── main.lua
│   └── ...
```

## Creating a New Game

To create a new game project:

1. **Ask the Game Designer agent**: `@game-designer create a new game called my-game-name`
2. The agent will:
   - Create the folder structure
   - Copy the GDD template as `GAME_DESIGN.md`
   - Generate basic `main.lua` and `conf.lua` files
   - Set up the standard directory structure

## Working on a Game

### Specifying Which Game

The AI agents can detect which game you're working on in three ways:

**A. Explicitly specify the folder name:**
```
@game-designer In the "my-platformer" game, add a jump mechanic
```

**B. Use the agent mention with game name:**
```
@game-designer:my-platformer add a jump mechanic
```

**C. Work in context (inferred from open files):**
- Open a file from the game folder (e.g., `games/my-platformer/main.lua`)
- Simply request: `@game-designer add a jump mechanic`
- The agent will infer you're working on "my-platformer"

### Running a Game

To run a specific game:

```bash
cd games/my-platformer
love .
```

## Design Guidelines

- **Keep games independent**: Each game should be completely self-contained
- **No shared code**: Don't share code between games; copy what you need
- **Unique GDD per game**: Each game has its own `GAME_DESIGN.md` at its root
- **Follow Love2D conventions**: Use standard Love2D project structure
- **Name folders clearly**: Use descriptive, kebab-case names (e.g., `space-shooter`, `puzzle-adventure`)

## Examples

### Example 1: Creating and Working on a Platformer

```
User: @game-designer create a new platformer game called super-jumper

[Agent creates games/super-jumper/ with full structure]

User: @game-designer:super-jumper implement the player character with double-jump

[Agent works on super-jumper's player mechanics]
```

### Example 2: Working on Multiple Games

```
User: [Opens games/rpg-adventure/src/entities/Player.lua]
User: @game-designer add health regeneration to the player

[Agent automatically detects "rpg-adventure" from the file path]

User: In the "puzzle-game" project, add a level selection menu

[Agent switches context to "puzzle-game"]
```

## Best Practices

1. **One game at a time**: Focus on one game during a session to avoid confusion
2. **Complete the GDD first**: Fill out `GAME_DESIGN.md` before implementing features
3. **Keep it organized**: Follow the standard folder structure for consistency
4. **Test frequently**: Run `love .` from the game folder to test your changes
5. **Document changes**: Keep the GDD updated as the game evolves

---

**Ready to start?** Ask `@game-designer create a new game` to get started!
