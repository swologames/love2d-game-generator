# Game Design Document - Mecha Shmup

## 1. Game Overview

### 1.1 Game Title
**Mecha Shmup**

### 1.2 High Concept
A fast-paced vertical scrolling shoot 'em up where you pilot a customizable mecha through waves of enemies and intense boss battles.

### 1.3 Genre
- Primary Genre: Shoot 'Em Up (Shmup)
- Sub-Genre: Bullet Hell, Vertical Scrolling Shooter

### 1.4 Target Platform
- Platform: Love2D (Cross-platform: Windows, macOS, Linux)
- Target Resolution: 1280x720 (16:9)
- Aspect Ratio: 16:9

### 1.5 Target Audience
- Age Range: 13+
- Experience Level: Intermediate to Hardcore
- Demographics: Fans of classic arcade shooters and bullet hell games

---

## 2. Game Story & Setting

### 2.1 Story Summary
The world is in peril due to an alien invasion, only the mecha pilots can save it. The aliens are called the "Tau Deu", and want to enslave humanity.

### 2.2 Setting
Sci-Fi, dystopian, post-apocalyptic

### 2.3 Characters

#### Playable Protagonists (Player Selectable)

##### 1. Commander Kai Rexford - "Valkyrie Unit"
- **Mecha**: VK-01 Valkyrie
- **Description**: Veteran pilot and leader of the resistance. Former military ace who lost everything in the initial Tau Deu assault. Balanced combat abilities and steady leadership.
- **Weapon Type**: Standard Plasma Cannon (balanced damage and fire rate)
- **Special Weapon**: Homing Missiles - Lock onto multiple targets
- **Playstyle**: All-rounder, good for beginners, balanced offense and defense
- **Personality**: Stoic, determined, protective of the team

##### 2. Lieutenant Zara "Blitz" Nakamura - "Phantom Unit"
- **Mecha**: PH-03 Phantom
- **Description**: Young hotshot pilot with incredible reflexes. Former racing champion turned resistance fighter. Cocky but skilled.
- **Weapon Type**: Rapid-Fire Laser Array (high fire rate, lower damage per shot)
- **Special Weapon**: EMP Burst - Slows enemy bullets in radius
- **Playstyle**: Speed and agility focused, smaller hitbox, requires precision
- **Personality**: Confident, quick-witted, adrenaline junkie

##### 3. Sergeant Viktor "Ironwall" Kozlov - "Bastion Unit"
- **Mecha**: BN-05 Bastion
- **Description**: Grizzled veteran and heavy weapons specialist. Survived impossible odds through sheer firepower. The tank of the team.
- **Weapon Type**: Heavy Railgun (slow fire rate, devastating damage)
- **Special Weapon**: Shield Barrier - Temporary invulnerability and reflects bullets
- **Playstyle**: High damage, slower movement, can absorb more hits
- **Personality**: Gruff, tactical, protective of civilians

#### Supporting Characters

##### Dr. Elena Vasquez - Head Mechanic
- **Role**: Mecha engineer and weapons developer
- **Description**: Brilliant robotics engineer who maintains and upgrades the mecha fleet. Creates new weapons from salvaged Tau Deu technology.
- **Personality**: Enthusiastic, slightly eccentric, passionate about her work
- **Appears**: Between stages for upgrades and repairs

##### Medic Officer Arjun Patel - Medical Support
- **Role**: Field medic and morale officer
- **Description**: Keeps the pilots alive and mentally fit for combat. Former trauma surgeon who joined the resistance after losing his hospital.
- **Personality**: Calm under pressure, empathetic, dark humor as coping mechanism
- **Appears**: Mission briefings, emergency evacuations, healing damaged pilots

##### Commander Sarah Wells - Operations Leader
- **Role**: Mission coordinator and strategic commander
- **Description**: Oversees all resistance operations from the command center. Provides mission briefings and tactical support.
- **Personality**: Authoritative, strategic thinker, carries the weight of every pilot lost

#### Main Boss Antagonists (Tau Deu Command)

##### Stage 1 Boss: Vor'kath the Ravager
- **Unit Type**: Heavy Assault Cruiser
- **Description**: First-wave commander of the Tau Deu invasion fleet. A massive warship bristling with weapons. Tests the pilot's basic dodging and shooting skills.
- **Attack Patterns**: Sweeping laser beams, missile barrages, rotating turret fire
- **Personality/Lore**: Ruthless and efficient, views humans as insignificant pests

##### Stage 2 Boss: Xel'nara the Mind Render
- **Unit Type**: Psychic War Machine
- **Description**: Mysterious Tau Deu elite who uses psychic energy to create complex bullet patterns. Pilots report hallucinations and disorientation.
- **Attack Patterns**: Spiraling energy waves, homing psychic projectiles, pattern manipulation
- **Personality/Lore**: Sadistic, enjoys the fear of human pilots, speaks in cryptic warnings

##### Stage 3 Boss: Kry'zoth the Swarm Master
- **Unit Type**: Carrier Ship with Fighter Support
- **Description**: Commands vast swarms of smaller Tau Deu fighters. The ultimate multi-target challenge.
- **Attack Patterns**: Summons waves of fighters, creates bullet curtains, tactical positioning
- **Personality/Lore**: Hive-mind commander, cold and calculating, views battles as chess games

##### Final Boss: Overlord Zha'thul the Eternal
- **Unit Type**: Dreadnought Flagship - "The Destroyer"
- **Description**: Supreme commander of the Tau Deu invasion force. An ancient being of immense power piloting a ship the size of a city. Multi-phase battle with different forms.
- **Attack Patterns**: 
  - **Phase 1**: Traditional bullet hell with massive laser arrays
  - **Phase 2**: Summons elite guard units while continuing assault
  - **Phase 3**: Desperate final form - entire screen becomes a bullet hell gauntlet
- **Personality/Lore**: Ancient warmonger who has conquered countless worlds. Monologues about humanity's futility, but respects worthy opponents. Has a personal vendetta after the resistance's early victories.

---

## 3. Gameplay Mechanics

### 3.1 Core Gameplay Loop
1. Navigate through scrolling level
2. Shoot enemies and avoid bullets
3. Collect power-ups and score items
4. Defeat stage boss
5. Upgrade mecha between stages

### 3.2 Player Controls
| Input | Action | Description |
|-------|--------|-------------|
| W/Up Arrow | Move Up | Mecha moves upward |
| S/Down Arrow | Move Down | Mecha moves downward |
| A/Left Arrow | Move Left | Mecha moves left |
| D/Right Arrow | Move Right | Mecha moves right |
| Space/Z | Primary Fire | Rapid-fire weapon |
| Shift/X | Special Weapon | Limited-use powerful attack |
| Left Shift | Focus Mode | Slower movement, visible hitbox |
| ESC | Pause | Opens pause menu |

### 3.3 Game Mechanics

#### Character Selection System
- **Three Playable Pilots**: Each with unique stats and weapons
- **Selection Screen**: Choose pilot before starting game
- **Stats Differences**:
  - **Kai (Valkyrie)**: Movement 250px/s, Damage: Medium, Fire Rate: Medium, Health: 3HP
  - **Zara (Phantom)**: Movement 300px/s, Damage: Low, Fire Rate: High, Health: 2HP
  - **Viktor (Bastion)**: Movement 200px/s, Damage: High, Fire Rate: Low, Health: 4HP

#### Movement System
- Type: Free 8-directional movement
- Speed: Varies by character (200-300 pixels/second normal, -50% in focus mode)
- Boundaries: Stay within screen bounds

#### Combat System
- **Primary Weapon**: Varies by character
  - **Kai**: Plasma Cannon - Balanced projectiles
  - **Zara**: Laser Array - Rapid-fire, spread pattern
  - **Viktor**: Railgun - Slow, powerful piercing shots
- **Special Weapon**: Unique per character (limited uses)
  - **Kai**: Homing Missiles (locks onto 5 targets)
  - **Zara**: EMP Burst (slows bullets in radius for 3 seconds)
  - **Viktor**: Shield Barrier (3 seconds invulnerability + reflects bullets)
- **Damage**: Player hitbox is small (5-10 pixels, visible in focus mode)
- **Enemy AI**: Patterns include formations, kamikaze, snipers, and bullet patterns

#### Progressi2-4 hit points depending on character choice
- **Special Weapon Charges**: 3-5 uses per stage,collecting items
- **Power-ups**: Weapon upgrades, shields, special weapon refills
- **Lives**: Traditional life system, extra life every [X] points

#### Resource Management
- **Health**: [1-3 hit points depending on difficulty]
- **Special Weapon Charges**: Limited ammo that refills via power-ups
- **Score Multipliers**: Chains for defeating enemies quickly

### 3.4 Physics & Collision
- Collision: Pixel-perfect or circular hitboxes
- Player hitbox: 5-10 pixels
- Bullet hitboxes: Vary by type
- No gravity (space/aerial combat)

---

## 4. Game Flow & Scenes

### 4.1 Scene Structure
```
Main Menu
  ├── Start Game → Character Select → Stage 1
  ├── Options
  ├── High Scores
  └── Quit

Character Select
  ├── Kai Rexford (Valkyrie) - Balanced
  ├── Zara Nakamura (Phantom) - Speed
  └── Viktor Kozlov (Bastion) - Firepower
  
Game Stages
  ├── Stage 1 → Boss: Vor'kath the Ravager
  ├── Stage 2 → Boss: Xel'nara the Mind Render
  ├── Stage 3 → Boss: Kry'zoth the Swarm Master
  └── Final Stage → Final Boss: Zha'thul the Eternal
  
End Screens
  ├── Victory → High Score Entry
  └── Game Over → Continue/Main Menu
```

### 4.2 Scene Descriptions
#### Main Menu
- Elements: Title logo, animated background, menu options
- Music: Energetic synth theme
- Transitions: Fade with particles

#### Character Select
- Elements: Three mecha portraits with stats, pilot bios
- Music: Heroic theme
- Transitions: Smooth slide-in of character data

#### Stage 1: "First Contact"
- Objective: Push back the Tau Deu vanguard
- Boss: Vor'kath the Ravager
- Elements: Space/orbital backdrop, enemy fighter waves
- Win Condition: Defeat Vor'kath
- Lose Condition: Health reaches zero
- Briefing: Commander Wells warns of heavy resistance

#### Stage 2: "Mind Games"
- Objective: Destroy the psychic warfare vessel
- Boss: Xel'nara the Mind Render
- Elements: Distorted reality effects, psychic energy patterns
- Win Condition: Defeat Xel'nara
- Special: Screen warping effects during boss fight

#### Stage 3: "The Swarm"
- Objective: Eliminate the carrier ship
- Boss: Kry'zoth the Swarm Master
- Elements: Dense fighter swarms, tactical dodging required
- Win Condition: Defeat Kry'zoth and all fighters
- Tension: Dr. Vasquez warns of unprecedented enemy numbers

#### Final Stage: "Last Stand"
- Objective: Destroy the Tau Deu command ship
- Boss: Overlord Zha'thul the Eternal (3 phases)
- Elements: Apocalyptic background, desperate communications from base
- Win Condition: Survive all three phases
- Transitions: Victory cutscene showing Earth saved

### 4.3 Game States
- MENU
- PLAYING
- PAUSED
- STAGE_CLEAR
- GAME_OVER
- VICTORY

---(2-4 depending on character)
- **Score**: Top-center, large readable numbers
- **Special Weapon**: Bottom-left, icon + charge count (0-5)
- **Lives**: Top-right corner
- **Power Level**: Indicator for weapon level/power-ups collected
- **Character Portrait**: Small portrait showing current pilot
- **Boss Health**: Top of screen during boss fights (with boss name)
- **Score**: Top-center, large readable numbers
- **Special Weapon**: Bottom-left, icon + count
- **Lives**: Top-right corner
- **Power Level**: Indicator for weapon level
- **Boss Health**: Top of screen during boss fights

### 5.2 Menu Screens
#### Character Select Screen
- Layout: Three character portraits side-by-side
- Display: Character name, mecha name, stats comparison bars
- Info: Weapon type, special ability description
- Controls: Left/Right to select, Space to confirm

#### Main Menu
- Layout: Centered vertical menu
- Buttons: Start Game, Options, High Scores, Quit
- Visual Style: Futuristic/mechanical theme

#### Pause Menu
- Resume button
- Restart stage button
- Options button
- Quit to main menu button

#### Options Menu
- Volume controls (Master, Music, SFX)
- Difficulty selection
- Controls display
- Back button

### 5.3 UI Style Guide
- Font: Monospace or futuristic font, 14-24px
- Color Scheme: Cyan/blue primary, orange/red accents, white text
- Button Style: Rectangular with glow effect on hover
- Animations: Smooth fades, particle trails

---

## 6. Art & Visual Design
s**: 32x32 or 64x64 each (VK-01 Valkyrie, PH-03 Phantom, BN-05 Bastion)
- **Character portraits**: 128x128 for selection screen and dialog
- **Enemies**: Small fighters (16x16), medium ships (32x32), bosses (128x128+)
- **Boss sprites**: Vor'kath (96x96), Xel'nara (128x128), Kry'zoth (96x96 + fighters), Zha'thul (256x256
[Choose: Pixel art, vector art, or detailed sprites - describe your visual direction]

### 6.2 Color Palette
- Primary Colors: [Blues, cyans for player/UI]
- Secondary Colors: [Reds, oranges for enemies]
- Accent Colors: [Yellows, whites for bullets and effects]
- Mood: High-tech, intense, action-packed

### 6.3 Asset List
#### Sprites
- **Player mec(all 3) | 2-4 | 8 | Yes |
| Player Thrust | 2 | 10 | Yes |
| Player Special Attack | 4-6 | 15 | No |
| Enemy Movement | 2-4 | 8 | Yes |
| Boss Idle | 4 | 6 | Yes |
| Boss Attack | 6-8 | 12 | Nod sizes (4x4 to 16x16)
- **Power-ups**: 16x16 icons
- **Background**: Scrolling layers for parallax

#### Animations
| Animation | Frames | FPS | Loop |
|-----------|--------|-----|------|
| Player Idle | 2-4 | 8 | Yes |
| Player Thrust | 2 | 10 | Yes |
| Enemy Movement | 2-4 | 8 | Yes |
| Explosion | 8-12 | 20 | No |

### 6.4 Visual Effects
- Particle Effects: Explosions, bullet trails, engine thrust
- Screen Effects: Screen shake on hit, flash on damage
- Lighting: Glowing bullets, muzzle flashes

### 6.5 Shaders
- Glow shader: For bullets and engines
- Wave distortion: For boss attacks or special effects
- Color flash: For hit feedback

---

## 7. Audio Design

### 7.1 Music
| Scene/Context | Track Name | Mood | Loop |
|---------------|------------|------|------|
| Main Menu | menu_theme.ogg | Energetic, teasing | Yes |
| Character Select | hero_theme.ogg | Heroic, inspirational | Yes |
| Stage 1 | stage1_orbital.ogg | Fast-paced, tense | Yes |
| Stage 2 | stage2_mindrender.ogg | Eerie, distorted | Yes |
| Stage 3 | stage3_swarm.ogg | Frantic, overwhelming | Yes |
| Final Stage | final_stage.ogg | Epic, desperate | Yes |
| Boss Battle (Generic) | boss_theme.ogg | Intense, dramatic | Yes |
| Final Boss Phase 1 | finalboss_p1.ogg | Ominous, powerful | Yes |
| Final Boss Phase 2 | finalboss_p2.ogg | Chaotic, urgent | Yes |
| Final Boss P(Kai) | plasma_shot.wav | 0.4 | Balanced energy sound |
| Player Shot (Zara) | laser_rapid.wav | 0.3 | High-pitched rapid fire |
| Player Shot (Viktor) | railgun_blast.wav | 0.6 | Deep, powerful boom |
| Special: Homing Missiles | missile_lock.wav | 0.5 | Lock-on beep + launch |
| Special: EMP Burst | emp_pulse.wav | 0.6 | Electronic shockwave |
| Special: Shield Barrier | shield_activate.wav | 0.5 | Energy shield hum |
| Enemy Shot | enemy_shot.wav | 0.3 | Varies by enemy type |
| Explosion Small | explosion_small.wav | 0.6 | Quick pop |
| Explosion Large | explosion_large.wav | 0.8 | Multiple variations |
| Explosion Boss | explosion_boss.wav | 1.0 | Extended dramatic blast |
| Power-up Collect | powerup.wav | 0.6 | Bright, positive |
| Player Hit | player_hit.wav | 0.9 | Alarming impact |
| Boss Warning | warning_siren.wav | 0.7 | Siren-like alert |
| Boss Appears | boss_entrance.wav | 0.8 | Dramatic entry sound |
| UI Select | menu_select.wav | 0.5 | Click/beep |
| Character Select | char_confirm.wav | 0.6 | Confirmation tone |
| Dialog Blip | dialog_blip.wav | 0.4 | Text scroll sound
| Player Shot | player_shot.wav | 0.4 | Short, satisfying |
| Enemy Shot | enemy_shot.wav | 0.3 | Varies by enemy type |
| Explosion | explosion.wav | 0.8 | Multiple variations |
| Power-up | powerup.wav | 0.6 | Bright, positive |
| Player Hit | player_hit.wav | 0.9 | Alarming |
| Boss Warning | warning.wav | 0.7 | Siren-like |
| UI Select | menu_select.wav | 0.5 | Click/beep |

### 7.3 Audio Implementation
- Master volume control
- Separate music and SFX volume
- Sound pooling for rapid-fire bullets
- Dynamic mixing: Lower music during boss introductions

---

## 8. Technical Specifications

### 8.1 Love2D Version
- Target Version: 11.4+

### 8.2 Libraries & Dependencies
- None required for basic implementation
- Optional: Camera library for screen shake effects

### 8.3 Project Structure
```
/mecha-shmup
├── main.lua              # Entry point
├── conf.lua              # Love2D configuration
├── /src
│   ├── /scenes          # Menu, Game, GameOver scenes
│   ├── /entities        # Player, Enemy, Bullet, Powerup classes
│   ├── /systems         # Collision, spawn manager, scoring
│   ├── /ui              # HUD, menus
│   ├── /utils           # Helpers, math utilities
│   └── /shaders         # GLSL shaders
├── /assets
│   ├── /images          # Sprites and textures
│   ├── /sounds          # Sound effects
│   ├── /music           # Music tracks
│   └── /fonts           # Font files
└── /lib                 # External libraries
```

### 8.4 Performance Targets
- Target FPS: 60
- Maximum bullets on screen: 500-1000
- Memory budget: < 100MB

### 8.5 Save System
- Save format: JSON or Lua tables
- Save location: Love2D save directory
- Data to save: High scores, options, unlocks

---

## 9. Development Milestones

### Phase 1: Core Prototype (Week 1)
- [ ] Player movement and shooting (basic, single character)
- [ ] Basic enemy spawning
- [ ] Collision detection
- [ ] Simple placeholder graphics

### Phase 2: Core Mechanics (Week 2-3)
- [ ] Character selection system with 3 pilots
- [ ] Different weapon types per character
- [ ] Enemy types and patterns
- [ ] Power-up system
- [ ] Score and lives system
- [ ] Stage progression

### Phase 3: Content (Week 4-5)
- [ ] All 4 stages with unique backgrounds
- [ ] All 4 boss fights with attack patterns
- [ ] Final sprites for all 3 player mechas
- [ ] Enemy sprites and animations
- [ ] Background art

### Phase 4: Audio & UI (Week 6)
- [ ] All music tracks (12 total)
- [ ] All sound effects (character-specific)
- [ ] Complete menu system with character select
- [ ] HUD polish with character portraits
- [ ] Dialog system for briefings/support crew

### Phase 5: Polish (Week 7-8)
- [ ] Particle effects and shaders
- [ ] Screen shake and juice
- [ ] Difficulty balancing
- [ ] Playtesting and bug fixes

---

## 10. Additional Notes

### 10.1 Known Challenges
- Bullet hell balance: Making it challenging but fair for all 3 character types
- Performance with many bullets on screen (target 500-1000)
- Enemy pattern design that's fun across different player speeds
- Balancing 3 different playstyles to be equally viable

### 10.2 Future Features / Post-Launch
- Additional playable mechas with different weapons
- Endless survival mode
- Co-op multiplayer (2-player)
- Achievement system
- Story expansions with more Tau Deu lore
- Unlockable color schemes for mechas

### 10.3 References & Inspiration
- Touhou Project series (bullet patterns, character variety)
- R-Type (classic shmup mechanics)
- Crimzon Clover (scoring system)
- Ikaruga (polarity mechanics - optional inspiration)
- Gradius (power-up system)

### 10.4 Character Dialog Examples

**Mission Start:**
- Kai: "Valkyrie launching. Let's end this."
- Zara: "Time to show these aliens what speed looks like!"
- Viktor: "Bastion ready. They won't break through me."

**Boss Appears:**
- Commander Wells: "Massive energy signature detected! Boss incoming!"
- Dr. Vasquez: "Readings are off the charts! Be careful out there!"
- Medic Patel: "Stay focused. You've got this."

**Taking Damage:**
- Kai: "Hit! Hull integrity holding."
- Zara: "Too close! Gotta be faster!"
- Viktor: "Armor damaged. Still operational."

**Boss Defeated:**
- Kai: "Target eliminated. Moving to next sector."
- Zara: "Too easy! Who's next?"
- Viktor: "Another one down. How many more?"

**Final Boss Dialog:**
- Zha'thul: "Your resistance is futile, human. This world will fall like all the others."
- Zha'thul (Phase 2): "Impressive... but your species' time has come!"
- Zha'thul (Phase 3): "I will not... fall... to insects!"
- Victory: Zha'thul: "Impossible... defeated by... humans..."

---

## Appendices

### Appendix A: Character Stats Comparison

| Attribute | Kai (Valkyrie) | Zara (Phantom) | Viktor (Bastion) |
|-----------|----------------|----------------|------------------|
| Movement Speed | 250 px/s | 300 px/s | 200 px/s |
| Focus Speed | 125 px/s | 150 px/s | 100 px/s |
| Health Points | 3 HP | 2 HP | 4 HP |
| Shot Damage | 10 | 6 | 20 |
| Fire Rate | 0.15s | 0.08s | 0.35s |
| Special Charges | 5 | 5 | 3 |
| Hitbox Size | 8 pixels | 6 pixels | 10 pixels |
| Difficulty | ★★☆☆☆ (Easy) | ★★★★☆ (Hard) | ★★★☆☆ (Medium) |

### Appendix B: Enemy Gallery

**Basic Enemies:**
- **Tau Scout**: Small fast fighters, 1 HP, simple forward shots
- **Tau Interceptor**: Medium ships, 3 HP, aims at player
- **Tau Bomber**: Slow heavy units, 5 HP, drops bullet spreads
- **Tau Kamikaze**: Suicide attackers, 2 HP, rushes player

**Elite Enemies:**
- **Tau Sniper**: Long-range precise shots, 4 HP
- **Tau Weaver**: Creates bullet patterns, 6 HP
- **Tau Guardian**: Shields other enemies, 8 HP

### Appendix C: Tau Deu Lore

The Tau Deu are an ancient alien empire that has conquered hundreds of worlds across the galaxy. They view organic life as resources to be harvested or enslaved. Their invasion of Earth began three years ago with devastating orbital bombardments.

Humanity's resistance formed around the few remaining military bases and developed the Mecha program - a desperate fusion of salvaged Tau Deu technology and human engineering. The player pilots represent the elite of this program, humanities last hope.

**Key Facts:**
- Tau Deu communicate through psychic networks
- Their technology is bio-mechanical in nature
- They view individual consciousness as weakness
- Earth is special: Rich in rare minerals they need
- This is their first major defeat in centuries

### Appendix D: Glossary

**Terms:**
- **Mecha**: Human-built combat vehicles, fusion of human and Tau Deu tech
- **Tau Deu**: Alien invaders, hivemind-adjacent civilization
- **Focus Mode**: Slows movement, reveals hitbox, increases precision
- **Power Level**: Current weapon upgrade tier (affects damage multiplier)
- **Score Multiplier**: Bonus for destroying enemies in quick succession
- **Extra Life**: Awarded every 50,000 points

### Appendix E: Asset Credits

[To be filled during development - list third-party assets and contributors here]

### Appendix F: Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0 | 2026-02-17 | Initial document creation | Game Designer |
| 1.1 | 2026-02-17 | Added full character roster, 4 bosses, support crew, dialog | Game Designer |

---

**Ready to start development!** The GDD is now complete with all character details, boss designs, and supporting cast. Begin implementing core mechanics with the AI agents.
