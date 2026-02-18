# Raccoon Story - Game Design Document

## 1. Game Overview

### 1.1 Game Title
**Raccoon Story**

### 1.2 High Concept
A cozy top-down adventure where you play as a resourceful raccoon scavenging for trash to feed your family while avoiding pesky humans and competing animals.

### 1.3 Genre
- Primary Genre: Adventure
- Sub-Genre: Cozy Game, Resource Collection

### 1.4 Target Platform
- Platform: Love2D (Cross-platform: Windows, macOS, Linux)
- Target Resolution: 1280x720
- Aspect Ratio: 16:9

### 1.5 Target Audience
- Age Range: 7+
- Experience Level: Casual
- Demographics: Players who enjoy cozy, non-violent games with cute aesthetics

---

## 2. Game Story & Setting

### 2.1 Story Summary
You are a clever raccoon living in a suburban neighborhood with your family. Every night, you venture out into the human world to find delicious trash and tasty morsels to bring back home. Your family is counting on you! But you're not the only hungry creature out there - other animals want the same snacks, and humans are always trying to shoo you away from their precious garbage bins.

Navigate through backyards, alleys, parks, and streets collecting as much food as you can. The more you bring home, the happier your raccoon family becomes. Master the art of stealth, speed, and strategy to become the neighborhood's best trash collector!

### 2.2 Setting
A charming suburban neighborhood during nighttime. The game world includes:
- Residential backyards with garbage bins
- Dark alleys between houses
- A small park with picnic areas
- Quiet streets with street lamps
- Cozy raccoon den (home base)

The atmosphere is warm and inviting despite the nighttime setting, with soft lighting, gentle shadows, and a whimsical art style that makes even trash look appealing.

### 2.3 Characters
#### Protagonist
- **Name**: The Player Raccoon (customizable name)
- **Description**: A determined, clever raccoon with a mask-like facial pattern and a bushy striped tail
- **Abilities/Skills**: 
  - Fast movement
  - Can carry multiple trash items
  - Can hide in bushes or behind objects
  - Quick dash ability to escape threats

#### Antagonists & Obstacles
- **Humans**: 
  - **Description**: Defensive homeowners who try to shoo you away
  - **Role**: Will chase the raccoon if spotted, causing you to drop carried items

- **Dogs**: 
  - **Description**: Protective pets that bark and chase
  - **Role**: Faster than humans, patrol specific areas

- **Competing Animals**:
  - Possums: Slow but stubborn competitors for trash
  - Stray Cats: Quick and territorial
  - Crows: Will steal unattended food items

#### Supporting Characters
- **Raccoon Family**: Your mate and kits waiting at the den, visible reactions to brought food
- **Friendly Animals**: Occasional neutral animals that provide hints or create distractions

---

## 3. Gameplay Mechanics

### 3.1 Core Gameplay Loop
1. **Explore** the neighborhood to locate trash bins and food sources
2. **Collect** trash items and store them in your inventory
3. **Avoid or evade** humans, dogs, and competing animals
4. **Return** to your den to deliver the collected trash
5. **Manage** time (before dawn breaks) and inventory space
6. **Progress** by unlocking new areas and upgrading abilities

### 3.2 Player Controls
| Input | Action | Description |
|-------|--------|-------------|
| W/Up Arrow | Move Up | Player movement upward |
| S/Down Arrow | Move Down | Player movement downward |
| A/Left Arrow | Move Left | Player movement left |
| D/Right Arrow | Move Right | Player movement right |
| Space | Interact/Pickup | Pick up trash or interact with objects |
| Shift | Dash | Quick burst of speed (cooldown 3s) |
| E | Hide | Hide in nearby bushes or shadows |
| Tab | Inventory | View collected items |
| ESC | Pause | Opens pause menu |

### 3.3 Game Mechanics

#### Movement System
- Type: Free top-down movement
- Base Speed: 150 pixels/second
- Dash Speed: 300 pixels/second (0.5s duration)
- Movement is smooth 8-directional with animation changes

#### Collection System
- **Trash Types**:
  - Pizza crusts: 10 points, 1 inventory slot
  - Half-eaten burgers: 15 points, 1 slot
  - Donut boxes: 20 points, 2 slots
  - Full trash bag: 50 points, 3 slots (rare)
- **Inventory**: Maximum 6 slots
- **Dropping**: If caught by humans/dogs, drop 1-3 random items

#### Threat System
- **Detection**: Enemies have vision cones
- **Chase**: When spotted, threats will pursue for 5-10 seconds
- **Safe Zones**: Bushes, shadows, and hidden passages provide safety
- **Recovery**: After escaping, threats return to patrol routes

#### Progression System
- **Family Happiness Meter**: Fill by delivering trash
- **Unlockables**: 
  - New areas of the neighborhood
  - Larger inventory capacity
  - Faster dash cooldown
  - Camouflage ability (longer hide duration)
- **Daily Goals**: Each night has optional objectives (optional but rewarding)

#### Resource Management
- **Inventory Space**: Limited to 6 slots initially
- **Time**: Night cycle lasts 5 minutes of real-time per level
- **Family Meter**: Visible at den, shows satisfaction level

### 3.4 Physics & Collision
- No gravity (top-down view)
- Collision Layers: 
  - Solid obstacles (walls, fences, bins)
  - Interactive objects (trash, bushes)
  - Threats (humans, animals)
  - Player
- Smooth collision response with slight bounce-back

---

## 4. Game Flow & Scenes

### 4.1 Scene Structure
```
Main Menu
  ├── New Game → Intro Scene
  ├── Continue → Night Select
  ├── Settings
  └── Credits
  
Game Scenes
  ├── Den (Home Base)
  ├── Tutorial Area (First Night)
  ├── Residential Area
  ├── Park Area
  ├── Downtown Area (Unlockable)
  └── Victory Scene
```

### 4.2 Scene Descriptions

#### Main Menu
- Elements: Game title with animated raccoon, glowing buttons, starry night background
- Music: Gentle, whimsical accordion melody
- Transitions: Fade to black

#### Den (Home Base)
- Objective: Safe zone to plan next outing, see family, check progress
- Elements: Cozy interior, family raccoons, collected trash pile, upgrade menu
- Features: Can start next night, view stats, purchase upgrades
- Transitions: Fade out when leaving for the night

#### Residential Area
- Objective: Collect 100 points worth of trash
- Elements: Houses, yards, garbage bins, street lamps, bushes
- Threats: 2-3 humans, 1-2 dogs
- Win Condition: Return to den with enough trash
- Lose Condition: Dawn breaks (time runs out)
- Transitions: Scroll/fade between areas

#### Park Area
- Objective: Collect picnic leftovers
- Elements: Picnic tables, playground, pond, benches
- Threats: Joggers, competing possums and crows
- Special: More valuable food items

### 4.3 Game States
- MENU - Main menu navigation
- DEN - Safe zone at home
- EXPLORING - Active scavenging
- HIDING - In stealth mode
- CHASED - Being pursued
- RETURNING - Carrying items back to den
- PAUSED - Game paused
- NIGHT_COMPLETE - Successfully returned with items
- CAUGHT - Lost items to threats
- DAWN - Time ran out

---

## 5. User Interface (UI)

### 5.1 HUD Elements
- **Inventory Display**: Top-right corner, shows 6 slots with trash icons
- **Time/Night Cycle**: Top-center, moon icon with progress bar
- **Minimap**: Bottom-right, shows player position, den location, threats (if visible)
- **Objective Tracker**: Top-left, current goal and points needed
- **Family Happiness Meter**: Visible at den only

### 5.2 Menu Screens

#### Main Menu
- Layout: Centered vertical stack
- Buttons: 
  - New Game
  - Continue
  - Settings
  - Credits
  - Quit
- Visual Style: Hand-drawn look with soft edges

#### Pause Menu
- Resume button
- Settings button
- Restart Night button
- Quit to main menu button
- Background: Slightly darkened game view with blur

#### Settings Menu
- Volume controls (Master, Music, SFX) with sliders
- Fullscreen toggle
- Controls display (view only)
- Back button

### 5.3 UI Style Guide
- **Font**: Rounded sans-serif font (Varela Round or similar)
  - Title: 48px
  - Headers: 24px
  - Body: 16px
  - HUD: 14px
- **Color Scheme**: 
  - Primary: Warm brown (#8B4513)
  - Secondary: Cream (#F5DEB3)
  - Accent: Soft green (#90EE90)
  - Background: Deep blue-purple night (#1A1A2E)
- **Button Style**: 
  - Rounded rectangles with subtle shadow
  - Hover: Slight scale up (1.1x) and glow
  - Click: Scale down (0.95x) with satisfying sound
- **Animations**: 
  - Smooth ease-in-out transitions (0.2s)
  - Gentle floating animation for menu elements
  - Fade transitions between screens

---

## 6. Art & Visual Design

### 6.1 Art Style
Cozy, hand-drawn 2D art with a storybook aesthetic. Soft edges, warm colors despite the nighttime setting, and charming character designs. Think "Spirited Away meets modern indie games" - whimsical and inviting.

### 6.2 Color Palette
- **Primary Colors**: 
  - Raccoon gray: #5A5A5A
  - Warm brown: #8B4513
  - Night blue: #1A1A2E
- **Secondary Colors**: 
  - Soft green (bushes): #90EE90
  - Cream (UI, lights): #F5DEB3
  - Orange (streetlights): #FFA500
- **Accent Colors**:
  - Trash sparkles: #FFD700 (gold)
  - Alert red: #FF6B6B
  - Safe green: #4ECDC4
- **Mood**: Warm, cozy, adventurous, slightly mischievous

### 6.3 Asset List

#### Sprites
- **Player Raccoon**: 32x32 pixels
  - 4-frame idle animation
  - 6-frame walk animation (8 directions)
  - 3-frame dash animation
  - 2-frame hide animation
- **Enemies**:
  - Human: 32x48 pixels, 4-frame walk
  - Dog: 32x32 pixels, 6-frame run
  - Possum: 24x24 pixels, 4-frame walk
  - Cat: 24x24 pixels, 6-frame run
  - Crow: 16x16 pixels, 4-frame fly
- **Items**:
  - Trash pieces: 16x16 pixels each
  - Trash bin: 32x48 pixels
  - Bush: 48x48 pixels
- **Environment**:
  - Tileset for ground: 32x32 tiles (grass, pavement, dirt)
  - House exteriors: Various sizes
  - Fences: 32x16 tiles
  - Background layers for depth

#### Animations
| Animation | Frames | FPS | Loop |
|-----------|--------|-----|------|
| Raccoon Idle | 4 | 6 | Yes |
| Raccoon Walk | 6 | 12 | Yes |
| Raccoon Dash | 3 | 15 | No |
| Trash Sparkle | 4 | 8 | Yes |
| Human Walk | 4 | 8 | Yes |
| Dog Run | 6 | 12 | Yes |

### 6.4 Visual Effects
- **Particle Effects**: 
  - Trash sparkle particles (gold twinkles)
  - Dust clouds when dashing
  - Exclamation marks when detected
  - Little hearts when family is happy
  - Footstep puffs
- **Screen Effects**: 
  - Slight vignette at edges
  - Gentle sway when hiding in bushes
  - Screen shake when caught (very subtle)
- **Lighting**: 
  - Dynamic streetlight glow (circular gradient)
  - House window lights (warm yellow)
  - Flashlight beams when humans chase
  - Soft ambient moonlight

### 6.5 Shaders
- **Night Filter**: Subtle blue tint overlay for nighttime atmosphere
- **Stealth Shader**: Slight transparency/blur when hiding
- **Detection Glow**: Soft red pulsing outline when in danger zone

---

## 7. Audio Design

### 7.1 Music
| Scene/Context | Track Name | Mood | Loop |
|---------------|------------|------|------|
| Main Menu | menu_theme.ogg | Whimsical, inviting | Yes |
| Den | home_cozy.ogg | Warm, comforting | Yes |
| Exploring (Safe) | night_adventure.ogg | Playful, curious | Yes |
| Chased | danger_theme.ogg | Tense but not scary | Yes |
| Victory | success_jingle.ogg | Cheerful, rewarding | No |

### 7.2 Sound Effects
| Event | Sound File | Volume | Notes |
|-------|------------|--------|-------|
| Raccoon Step | step.wav | 0.3 | Soft pitter-patter |
| Pickup Trash | pickup.wav | 0.7 | Satisfying 'pling' |
| Dash | dash.wav | 0.6 | Whoosh sound |
| Hide | hide.wav | 0.5 | Rustling leaves |
| Detected | alert.wav | 0.8 | Surprise chord |
| Dog Bark | bark.wav | 0.7 | Medium-pitched bark |
| Human Voice | shoo.wav | 0.7 | "Hey!" or "Shoo!" |
| Trash Bin Open | bin_open.wav | 0.6 | Creaky lid sound |
| UI Click | ui_click.wav | 0.5 | Soft click |
| Success | success.wav | 0.8 | Happy chime |
| Return to Den | return.wav | 0.7 | Cozy 'home' sound |

### 7.3 Audio Implementation
- Master volume control (default 1.0)
- Separate music (default 0.7) and SFX (default 0.8) volume
- Dynamic mixing: Music volume ducks to 0.4 when being chased
- Spatial audio: Sounds fade with distance from player
- Randomized pitch variation (±15%) for footsteps and pickup sounds

---

## 8. Technical Specifications

### 8.1 Love2D Version
- Target Version: 11.4

### 8.2 Libraries & Dependencies
- **None initially** - Pure Love2D implementation
- Consider later:
  - bump.lua: For collision detection optimization
  - hump: For camera and gamestate management
  - anim8: For sprite animation management

### 8.3 Project Structure
```
/raccoon-story
├── main.lua              # Entry point
├── conf.lua              # Love2D configuration
├── /src
│   ├── /scenes          # Scene manager and scenes
│   │   ├── SceneManager.lua
│   │   ├── MenuScene.lua
│   │   ├── DenScene.lua
│   │   └── GameScene.lua
│   ├── /entities        # Game objects
│   │   ├── Player.lua
│   │   ├── Human.lua
│   │   ├── Dog.lua
│   │   ├── Animal.lua
│   │   └── TrashItem.lua
│   ├── /systems         # Game systems
│   │   ├── CollisionSystem.lua
│   │   ├── AISystem.lua
│   │   ├── InventorySystem.lua
│   │   └── TimeSystem.lua
│   ├── /ui              # UI components
│   │   ├── Button.lua
│   │   ├── HUD.lua
│   │   └── Menu.lua
│   ├── /utils           # Utility functions
│   │   ├── helpers.lua
│   │   └── assets.lua
│   └── /shaders         # GLSL shaders
│       ├── night.glsl
│       └── stealth.glsl
├── /assets
│   ├── /images          # Sprites and textures
│   ├── /sounds          # Sound effects
│   ├── /music           # Music tracks
│   └── /fonts           # Font files
└── /lib                 # External libraries (if needed)
```

### 8.4 Performance Targets
- Target FPS: 60
- Maximum concurrent entities: 50
- Draw calls per frame: <100
- Memory budget: 256MB

### 8.5 Save System
- Save format: JSON (using Love2D's data module)
- Save location: Love2D save directory
- Data to save: 
  - Player progress (nights completed, areas unlocked)
  - Upgrade purchases
  - Settings (volume, etc.)
  - High scores (trash collected each night)
  - Family happiness level

---

## 9. Development Milestones

### Phase 1: Prototype (Week 1-2)
- [ ] Top-down player movement (8-direction)
- [ ] Basic collision detection with obstacles
- [ ] Simple trash pickup mechanic
- [ ] One test area with placeholder art
- [ ] Basic enemy patrol (one human)

### Phase 2: Core Development (Week 3-5)
- [ ] Complete movement system with dash and hide
- [ ] Inventory system (6 slots)
- [ ] AI for humans, dogs, and competing animals
- [ ] Detection and chase mechanics
- [ ] Den scene as home base
- [ ] Time/night cycle system
- [ ] Scene management
- [ ] Basic UI/HUD

### Phase 3: Content Creation (Week 6-8)
- [ ] All character sprites and animations
- [ ] Multiple areas (residential, park, downtown)
- [ ] 10+ different trash items
- [ ] Complete tileset and environment art
- [ ] All sound effects
- [ ] Music tracks for different scenes
- [ ] Tutorial/first night level

### Phase 4: Polish (Week 9-10)
- [ ] Particle effects (sparkles, dust, hearts)
- [ ] Screen transitions and effects
- [ ] Shaders (night filter, stealth effect)
- [ ] Animation polish and juice
- [ ] Audio mixing and balance
- [ ] Playtesting and difficulty balancing
- [ ] Bug fixing
- [ ] Family reaction animations

### Phase 5: Release (Week 11)
- [ ] Final builds for Windows, macOS, Linux
- [ ] Credits screen
- [ ] README and player documentation
- [ ] Itch.io page with screenshots
- [ ] Release announcement

---

## 10. Additional Notes

### 10.1 Known Challenges
- **AI Pathfinding**: May need simple A* or steering behaviors for realistic enemy movement
- **Balancing Detection**: Making detection feel fair but challenging
- **Visual Clarity**: Ensuring player can distinguish safe zones and threats at a glance
- **Performance with Particles**: Many trash sparkles and effects could impact FPS

### 10.2 Future Features / Post-Launch
- **Seasons**: Different weather and trash types in different seasons
- **Multiplayer**: Co-op mode for 2 raccoons
- **Daily Challenges**: Procedurally generated nights with specific goals
- **Customization**: Unlock different raccoon appearances
- **Story Mode**: Narrative-driven campaign with specific objectives
- **New Areas**: Beach, forest, commercial district

### 10.3 References & Inspiration
- **Untitled Goose Game**: Cozy mischief gameplay
- **A Short Hike**: Warm, inviting atmosphere
- **Overcooked**: Simple but engaging resource management
- **Don't Starve**: Top-down exploration, resource gathering
- **Donut County**: Playful, charming aesthetic

---

## Appendices

### Appendix A: Glossary
- **Trash**: Collectible food items scattered throughout levels
- **Den**: The raccoon family's home; serves as the safe zone and base
- **Night Cycle**: The time limit for each level (5 minutes of gameplay)
- **Family Happiness**: The progression metric; fill by delivering trash
- **Detection**: When an enemy spots the player, triggering chase behavior
- **Safe Zone**: Areas where the player can hide from enemies

### Appendix B: Asset Credits
- All assets to be created specifically for this game or sourced from:
  - Free/CC0 asset packs (with proper attribution)
  - Custom commissioned art
  - Free fonts from Google Fonts

### Appendix C: Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-17 | Initial document creation | Game Designer AI |
