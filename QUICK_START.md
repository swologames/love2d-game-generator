# Quick Start Guide - Love2D Game Development with AI Agents

## 🌟 Multi-Game Workspace

This workspace supports **multiple independent game projects**. Each game lives in its own folder under `games/` and has its own Game Design Document.

**Quick tips:**
- Create new games with: `@game-designer create a new game called [name]`
- Run any game: `cd games/[game-name] && love .`
- Each game is completely independent

## 🚀 Getting Started in 3 Steps

### Step 0: Create Your Game Project

Start by creating a new game in the workspace:

```
@game-designer create a new game called my-platformer
```

The Game Designer will:
- ✅ Create `games/my-platformer/` with full structure
- ✅ Copy the GDD template as `GAME_DESIGN.md`
- ✅ Generate `main.lua`, `conf.lua`, and all folders
- ✅ Set you up to start developing

### Step 1: Define Your Game (15-30 minutes)
Open and fill out: `games/my-platformer/GAME_DESIGN.md`

**Minimum Required Sections**:
- Section 1: Game Overview (game title, genre, concept)
- Section 3: Gameplay Mechanics (core loop, controls)
- Section 4: Game Flow & Scenes (main menu → game → end)

**You can fill in technical details later!** Start with your vision.

### Step 2: Talk to the Game Designer
Once your GDD has the basics, start a conversation:

```
@game-designer In the "my-platformer" game, I'm ready to start building. Let's begin with the foundation.
```

Or, if you have a file from your game open:

```
@game-designer I'm ready to start building. Let's begin with the foundation.
```

The Game Designer will automatically detect which game you're working on from your open file!

The Game Designer will:
- ✅ Review your game-specific GDD
- ✅ Suggest a development roadmap
- ✅ Coordinate the specialized agents
- ✅ Guide you phase by phase

### Step 3: Iterate and Build
Continue working with the Game Designer or specialized agents:

```
@game-designer In "my-platformer", add the player movement mechanics
```

Or with a file open from your game:

```
@game-designer Add the player movement mechanics
```

```
@game-designer:my-platformer The enemy AI isn't working correctly
```

```
@ui Create a settings menu with volume sliders
```

---

## 🎯 When to Use Which Agent

### Use @game-designer When:
- ✅ Creating a new game project
- ✅ Starting a new game
- ✅ Planning a major feature
- ✅ Coordinating multiple systems
- ✅ Stuck and need guidance
- ✅ Want a development roadmap

**Example Requests**:
- "Create a new game called space-shooter"
- "Help me set up a new platformer game"
- "In the 'my-rpg' game, add a boss fight sequence"
- "The game needs more polish"
- "Implement a combo system"

### Use Specialized Agents When:
- ✅ You know exactly what you need
- ✅ Working on a specific, focused task
- ✅ Making small tweaks or fixes

**Example Requests**:
- `@ui` "Change the health bar color to red"
- `@gameplay` "Make the player jump higher"
- `@audio` "Lower the music volume"
- `@graphics` "Add a particle effect when enemies die"

---

## 📝 Example First Session

Here's a realistic first session building a simple platformer:

### 0. Create the Game Project
```
You: @game-designer create a new game called simple-platformer

Game Designer: What would you like to name the game folder? 

You: simple-platformer

Game Designer: Perfect! I've created the game structure at games/simple-platformer/.

Next steps:
1. Fill out games/simple-platformer/GAME_DESIGN.md with your game's specifications
2. Run the game with: cd games/simple-platformer && love .
3. Ask me to implement features once the GDD has the basics!
```

### 1. Initial Setup
```
[You open games/simple-platformer/GAME_DESIGN.md and fill in the basics]
[You open games/simple-platformer/main.lua]

You: @game-designer I've filled out the GDD basics. Let's build the foundation.

Game Designer: Great! I've detected you're working on "simple-platformer". I'll coordinate the foundation:

I'll have @assets set up the asset management system and load your resources.
Then @gameflow will create the scene manager and basic scene structure.
@physics will set up the collision system for platformer mechanics.

Let's start...
```

### 2. Core Gameplay
```
You: @game-designer Now implement the player movement

Game Designer: I'll coordinate the player implementation:

@gameplay will create the player entity with:
- WASD/Arrow key movement
- Jump mechanic with the specs from your GDD
- Basic state management

@physics will handle:
- Collision with platforms
- Gravity and jump physics
- Ground detection

@animation will set up:
- Player sprite animations
- Walk, jump, and idle states
```

### 3. Building the Game
```
You: @game-designer Add the main menu

Game Designer: I'll coordinate the menu system:

@ui will create:
- Main menu layout per your GDD
- Start, Settings, Quit buttons
- Proper styling

@gameflow will:
- Connect menu to game scene
- Add scene transitions
- Handle button actions

@audio will:
- Add menu background music
- Button click sounds
```

### 4. Polish
```
You: @game-designer The game works but feels flat

Game Designer: Let's add juice! I'll coordinate a polish pass:

@graphics - screen shake, particles, visual effects
@audio - impact sounds, better mixing
@animation - smoother transitions
@gameplay - tighter controls, better feel
```

---

## 🎓 Tips for Success

### 1. Start Simple
Don't try to build everything at once. Start with:
- Player movement
- One enemy type
- Basic UI
- Essential sounds

### 2. Reference the GDD
The agents work best when they have specifications to follow. Even rough notes in the GDD help!

### 3. Iterate
Build → Test → Get feedback → Refine → Repeat

### 4. Trust the Game Designer
For complex features, let **@game-designer** break it down and coordinate. It knows how the systems fit together.

### 5. Test Often
After implementing features, test in Love2D:
```bash
cd games/my-platformer
love .
```

### 6. Update the GDD
As you make design decisions during development, update the GDD. It keeps everyone (including the agents) aligned.

---

## 🛠️ Common Workflows

### Adding a New Feature
```
You: @game-designer I want to add a double jump ability

Game Designer: [Analyzes GDD, breaks down into tasks]
- @gameplay: Core double jump logic
- @animation: Double jump animation
- @audio: Jump sound effect
- @ui: Tutorial prompt (if needed)
[Coordinates implementation]
```

### Fixing a Bug
```
You: @game-designer The player sometimes falls through platforms

Game Designer: This is a collision detection issue.
@physics please investigate and fix platform collision...
[Provides debugging guidance]
```

### Optimizing Performance
```
You: @game-designer The game lags with many enemies

Game Designer: Let's profile and optimize:
@physics - implement spatial partitioning
@graphics - optimize particle systems
@gameplay - reduce enemy update frequency
[Coordinates optimization across systems]
```

---

## 📚 Next Steps

1. **Create your first game**: `@game-designer create a new game`
2. **Fill out your GDD**: `games/[game-name]/GAME_DESIGN.md`
3. **Review the workspace guide**: [games/README.md](games/README.md)
4. **Review full documentation**: [README.md](README.md)
5. **Start building**: Talk to **@game-designer** to begin!

---

## ❓ FAQ

**Q: How do I create a new game project?**
A: `@game-designer create a new game called [name]`. Use kebab-case for names (e.g., `super-platformer`, `space-shooter`).

**Q: How do I switch between games?**
A: Open a file from the game you want to work on, and the agents will automatically detect the context. Or explicitly mention the game name in your request.

**Q: Can I work on multiple games at once?**
A: Yes! Each game is independent. However, focus on one game per session to avoid confusion.

**Q: Do games share any code?**
A: No. Each game is completely self-contained. If you need similar code in multiple games, copy what you need.

**Q: Do I need to fill out the entire GDD before starting?**
A: No! Start with the basics (game concept, core mechanics, controls). You can fill in details as you go.

**Q: Can I talk to specialized agents directly?**
A: Yes! For focused tasks, direct agent communication is efficient. Use @game-designer for coordination.

**Q: What if the agents suggest something different from my GDD?**
A: The agents always prioritize the GDD. If they suggest changes, they'll ask for your approval first.

**Q: How do I test my game?**
A: Run `cd games/[game-name] && love .` from the workspace root. Make sure you have Love2D installed: https://love2d.org/

**Q: Can I modify the agent instructions?**
A: Yes! The agent files in `.github/copilot-agents/` are fully customizable.

---

**Let's build something amazing! Start with @game-designer today.** 🎮✨
