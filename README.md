# Love2D AI Game Generator - A Work In Progress

This repository contains specialized Copilot agent definitions for building Love2D games based on a Game Design Document (GDD). Each agent is an expert in a specific domain of game development.

See [games folder](./games) for example games created with a little iteration.

## 🎯 Quick Start

**New to this system?** Clone the repo and start here:

### Creating a New Game

```
@game-designer create a new game called my-platformer
```

The Game Designer will:
1. Ask for a folder name (if not provided): use kebab-case like `super-platformer`
2. Create the complete game structure in `games/[game-name]/`
3. Copy the GDD template as `GAME_DESIGN.md`
4. Generate basic Love2D files (`main.lua`, `conf.lua`)
5. Set up all necessary folders

### Developing Your Game

1. **Fill out `games/[game-name]/GAME_DESIGN.md`** with your game's vision
2. **Talk to @game-designer** - the orchestrator that coordinates all specialized agents
3. **Let it guide you** through development phases

**Example**: 
```
@game-designer In the "my-platformer" game, implement player movement and jumping
```

The Game Designer will analyze your GDD, break down the work, and coordinate the 8 specialized agents.

### Specifying Which Game You're Working On

**Option A: Mention the folder name explicitly**
```
@game-designer In the "my-platformer" game, add enemies
```

**Option B: Use agent syntax with game name**
```
@game-designer:my-platformer add enemies
```

**Option C: Work in context (recommended)**
- Open a file from your game (e.g., `games/my-platformer/main.lua`)
- Simply ask: `@game-designer add enemies`
- The agent infers context from your open file!

📖 **[Read the Quick Start Guide](QUICK_START.md)** for a complete walkthrough with examples!

## � Multi-Game Workspace

**This workspace supports multiple independent Love2D games**, each in its own folder under `games/`. Every game is a complete, runnable Love2D project with its own Game Design Document.

**Workspace Structure:**
```
games/
├── my-platformer/              # Your first game
│   ├── GAME_DESIGN.md          # Game-specific GDD
│   ├── main.lua                # Love2D entry point
│   ├── conf.lua                # Configuration
│   ├── /src                    # Game source code
│   └── /assets                 # Game assets
├── space-shooter/              # Another game
│   ├── GAME_DESIGN.md
│   └── ...
```

**Benefits:**
- Work on multiple game projects in one workspace
- Each game is completely independent
- No shared code between games (clean separation)
- Easy to run any game: `cd games/[game-name] && love .`

📖 **See [games/README.md](games/README.md) for detailed multi-game workflows**


## 📋 Game Design Document Template

Each game has its own GDD:
- **Game-Specific GDD**: `games/[game-name]/GAME_DESIGN.md` (created automatically)
- **Template**: [docs/GAME_DESIGN_TEMPLATE.md](docs/GAME_DESIGN_TEMPLATE.md)
- **Purpose**: Central reference for all design decisions and specifications
- **Usage**: All agents reference the game-specific GDD to ensure consistency

When you create a new game with `@game-designer create a new game`, the template is automatically copied to your game's folder.

## 🤖 Specialized Agents

### Central Coordinator

#### **@game-designer** - Game Designer Agent
- **File**: [.github/copilot-agents/game-designer-agent.md](.github/copilot-agents/game-designer-agent.md)
- **Focus**: Task delegation, workflow orchestration, cross-system coordination
- **Key Features**:
  - Analyzes user requests and delegates to specialized agents
  - Ensures GDD compliance across all implementations
  - Coordinates multi-agent workflows for complex features
  - Manages development phases and milestones
  - Resolves integration conflicts between systems

**Use this agent when**: You want high-level guidance, need to coordinate complex features, or want help planning your development workflow.

### Core Development Agents

#### 1. **@ui** - UI Development Agent
- **File**: [.github/copilot-agents/ui-agent.md](.github/copilot-agents/ui-agent.md)
- **Focus**: Menus, HUD, buttons, interactive UI components
- **Key Features**:
  - Reusable UI component library
  - Menu systems (main menu, pause menu, settings)
  - HUD elements (health bars, score, minimaps)
  - Layout management and responsiveness

#### 2. **@gameplay** - Gameplay Programming Agent
- **File**: [.github/copilot-agents/gameplay-agent.md](.github/copilot-agents/gameplay-agent.md)
- **Focus**: Player mechanics, combat, enemy AI, game rules
- **Key Features**:
  - Player control systems
  - Combat and action mechanics
  - Enemy AI behavior
  - Progression systems

#### 3. **@gameflow** - Game Flow Management Agent
- **File**: [.github/copilot-agents/gameflow-agent.md](.github/copilot-agents/gameflow-agent.md)
- **Focus**: Scene management, state transitions, game flow
- **Key Features**:
  - Scene manager with transitions
  - State machine for game states
  - Save/load system
  - Scene lifecycle management

#### 4. **@audio** - Audio Systems Agent
- **File**: [.github/copilot-agents/audio-agent.md](.github/copilot-agents/audio-agent.md)
- **Focus**: Music, sound effects, audio mixing
- **Key Features**:
  - Audio manager with pooling
  - Music crossfading and looping
  - Event-based sound system
  - Volume controls and mixing

#### 5. **@graphics** - Graphics & Shaders Agent
- **File**: [.github/copilot-agents/graphics-agent.md](.github/copilot-agents/graphics-agent.md)
- **Focus**: Visual effects, particles, shaders, post-processing
- **Key Features**:
  - Particle systems
  - GLSL shader programming
  - Screen effects (shake, flash)
  - Post-processing pipeline

### Supporting Agents

#### 6. **@physics** - Physics & Collision Agent
- **File**: [.github/copilot-agents/physics-agent.md](.github/copilot-agents/physics-agent.md)
- **Focus**: Collision detection, physics simulation
- **Key Features**:
  - Simple collision system (AABB, circle)
  - Box2D integration
  - Platformer physics helpers
  - Spatial partitioning for optimization

#### 7. **@assets** - Asset Management Agent
- **File**: [.github/copilot-agents/assets-agent.md](.github/copilot-agents/assets-agent.md)
- **Focus**: Loading, caching, organizing game assets
- **Key Features**:
  - Centralized asset manager
  - Preloading system with progress tracking
  - Error handling and fallbacks
  - Hot-reloading during development

#### 8. **@animation** - Animation Systems Agent
- **File**: [.github/copilot-agents/animation-agent.md](.github/copilot-agents/animation-agent.md)
- **Focus**: Sprite animations, tweening, state machines
- **Key Features**:
  - Sprite sheet animation system
  - Animation state machines
  - Tweening with easing functions
  - Timeline-based animations

## 🚀 Getting Started

### 1. Fill Out the GDD
Start by customizing [docs/GAME_DESIGN_TEMPLATE.md](docs/GAME_DESIGN_TEMPLATE.md) with your game's specifications:
- Game overview and concept
- Gameplay mechanics and controls
- Art and audio requirements
- Technical specifications

### 2. Use Specialized Agents

You have two approaches:

#### Option A: Let the Game Designer Orchestrate (Recommended)
Talk to the Game Designer agent for high-level requests:

```
@game-designer I want to create a 2D platformer with dash mechanics
```

```
@game-designer The player damage system needs to be implemented
```

```
@game-designer Help me set up the project from scratch
```

The Game Designer will analyze your request, reference the GDD, and delegate to the appropriate specialized agents.

#### Option B: Direct Agent Communication
For focused, specific tasks, call agents directly:

```
@ui can you create a main menu with Start, Settings, and Quit buttons?
```

```
@gameplay implement the player jump mechanic according to the GDD
```

```
@gameflow set up the scene manager and create transitions between main menu and game
```

### 3. Agent Coordination
Agents work together seamlessly:
- **@gameplay** triggers sounds via **@audio**
- **@ui** uses **@assets** for button textures
- **@gameflow** coordinates **@audio** for scene music
- **@graphics** provides effects for **@gameplay** actions

## 📂 Project Structure

### Workspace-Level Structure

```
/Love2DAI                      # Workspace root
├── .github/
│   ├── copilot-instructions.md  # Main Copilot instructions
│   └── copilot-agents/          # All 9 agent definitions
├── docs/
│   └── GAME_DESIGN_TEMPLATE.md  # GDD template
├── games/                       # All your games live here
│   ├── README.md                # Multi-game guide
│   ├── my-platformer/           # A game project
│   ├── space-shooter/           # Another game project
│   └── puzzle-game/             # Yet another game
├── README.md                    # This file
└── QUICK_START.md               # Beginner's guide
```

### Individual Game Structure

Each game in `games/[game-name]/` follows this structure:

```
/games/my-platformer           # Complete runnable Love2D project
├── GAME_DESIGN.md             # Game-specific GDD (required)
├── main.lua                   # Love2D entry point
├── conf.lua                   # Love2D configuration
├── /src
│   ├── /scenes                # Scene manager and scenes
│   ├── /entities              # Game objects (player, enemies)
│   ├── /systems               # Game systems (physics, collision)
│   ├── /ui                    # UI components and menus
│   ├── /animation             # Animation systems
│   ├── /audio                 # Audio manager
│   ├── /graphics              # Visual effects, particles
│   └── /utils                 # Utility functions
├── /assets
│   ├── /images                # Sprites, textures
│   ├── /sounds                # Sound effects
│   ├── /music                 # Music tracks
│   ├── /fonts                 # Font files
│   └── /shaders               # GLSL shaders
└── /lib                       # External libraries (if any)
```

### Running a Game

```bash
cd games/my-platformer
love .
```

## 💡 Best Practices

### Start with the Game Designer
For new projects or complex features, start with **@game-designer**. It will:
- Analyze your request against the GDD
- Break down complex tasks into manageable pieces
- Delegate to appropriate specialists
- Ensure system integration

### Use Direct Agent Access for Focused Work
When you know exactly what you need:
- **@ui** for specific UI components
- **@gameplay** for isolated mechanics
- **@graphics** for particular effects

### Always Reference the GDD
All agents use the GDD as their source of truth. Keep it updated!

### Use the Right Agent for the Job
- Need a health bar? → **@ui**
- Enemy AI behavior? → **@gameplay**
- Scene transitions? → **@gameflow**
- Explosion effects? → **@graphics**

### Let Agents Coordinate
Agents know how to work together. For example:
```
@gameplay I need the player to take damage with a hurt sound and screen flash
```
This will involve @audio for sound and @graphics for the flash effect.

### Iterate and Polish
1. Start with core mechanics (**@gameplay**, **@physics**)
2. Add game flow (**@gameflow**)
3. Build UI (**@ui**)
4. Integrate audio (**@audio**)
5. Add visual polish (**@graphics**, **@animation**)

## 🎮 Example Workflow

### Creating a New Game

1. **Design Phase**
   - Fill out the GDD template
   - Define all mechanics, art, and audio requirements

2. **Foundation** (Week 1)
   ```
   @game-designer I want to set up a new platformer game from scratch
   ```
   
   The Game Designer will orchestrate:
   - @assets to set up the asset manager
   - @gameflow to create the scene structure
   - @physics for collision foundation

3. **Core Gameplay** (Week 2-3)
   ```
   @game-designer Implement the core player mechanics with movement, jumping, and dashing
   ```
   
   The Game Designer will coordinate:
   - @gameplay for player controller
   - @physics for collision and platformer physics
   - @animation for player animation states
   - @audio for movement sound effects

4. **Game Flow & UI** (Week 4)
   ```
   @game-designer Create the full game flow from menu to gameplay
   ```
   
   Coordinates:
   - @gameflow for scene management
   - @ui for all menu interfaces
   - @audio for menu music

5. **Content & Polish** (Week 5-6)
   ```
   @game-designer Add enemies, power-ups, and visual polish
   ```
   
   Then:
   ```
   @game-designer Polish the game with juice and effects
   ```
   
   Final touches across all systems

## 📚 Resources

- [Love2D Official Wiki](https://love2d.org/wiki/)
- [Love2D API Documentation](https://love2d.org/wiki/love)
- [Love2D Forums](https://love2d.org/forums/)

## 🤝 Contributing

When adding new agents or modifying existing ones:
1. Follow the established agent template structure
2. Include practical code examples
3. Reference GDD sections
4. Document coordination with other agents
5. Add testing checklists

---

## 🎮 Agent Hierarchy

```
@game-designer (Orchestrator)
    ├── @ui (User Interface)
    ├── @gameplay (Game Logic)
    ├── @gameflow (Scene Management)
    ├── @audio (Sound & Music)
    ├── @graphics (Visual Effects)
    ├── @physics (Collision & Physics)
    ├── @assets (Resource Management)
    └── @animation (Sprite Animation)
```

**Recommended Workflow**: 
- Start with **@game-designer** for planning and complex features
- Use specialized agents directly for focused, specific tasks
- Let the Game Designer coordinate multi-system implementations

---

**Ready to build your Love2D game? Start by filling out the GDD, then let @game-designer orchestrate the specialized agents to bring your vision to life!** 🎮✨
