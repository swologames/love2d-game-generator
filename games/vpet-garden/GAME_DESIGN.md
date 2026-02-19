# VPet Garden — Game Design Document

**Version:** 0.1  
**Engine:** Love2D 11.4+  
**Target Resolution:** 1280 × 720  
**Genre:** Cozy Virtual Pet / Casual  
**Tone:** Gentle, warm, nostalgic, relaxing

---

## 1. Game Overview & Vision

VPet Garden is a cozy 2D virtual pet game inspired by the Chao Garden side-mode from *Sonic Adventure 2*. The player tends to one or more small creature companions called **Chao** — nurturing them through feeding, training, and affection.

The experience is deliberately slow-paced and stress-free. There is no fail state, no timer pressure, and no combat. The appeal comes from watching your Chao grow, evolve personality, and express emotions in response to your care. The visual style is soft pastels, the audio is ambient and gentle, and every interaction is designed to feel satisfying and calm.

### Core Pillars
1. **Cozy Companionship** — The Chao feels alive and responds meaningfully to the player.
2. **Gentle Progression** — Stats rise slowly; growth is visible over many sessions.
3. **Sensory Delight** — Pleasing visuals (particles, jiggle), soothing audio, satisfying micro-interactions.
4. **No Pressure** — No punishment for neglect beyond the Chao being a bit sad; easily recovered.

---

## 2. Story & Setting

The player finds a small garden inhabited by a lone Chao. There is no explicit narrative — the "story" is the relationship the player builds with their Chao over time. The garden is peaceful: lush green grass, small flowers, a pond, gentle breezes.

Future versions may expand to multiple garden zones or allow a small flock of Chao.

---

## 3. Gameplay Mechanics

### 3.1 Core Loop

```
Enter Garden → Observe Chao → Interact (feed / pet / train)
      ↑                                       ↓
      └─────── Chao stats change / evolve ────┘
```

The loop is designed to be satisfying in 5-minute sessions as well as longer play periods. Stat decay is gentle enough that a player can return after a day and find their Chao merely hungry, not distressed.

### 3.2 Chao Stats

All stats are stored as floats in the range **0–100**.

| Stat       | Description                                      | Decays? |
|------------|--------------------------------------------------|---------|
| **Swim**   | Swimming proficiency (0–100)                     | No      |
| **Run**    | Running speed proficiency (0–100)                | No      |
| **Fly**    | Flying proficiency (0–100)                       | No      |
| **Power**  | Strength proficiency (0–100)                     | No      |
| **Luck**   | Passive luck / rare events chance (0–100)        | No      |
| **Happiness** | General mood; affects expressions (0–100)     | Yes (−0.5/s) |
| **Hunger** | Fullness level (100 = full, 0 = starving) (0–100) | Yes (−2.0/s) |
| **Energy** | Current energy; drains from training (0–100)    | Yes (−0.8/s) |

**Proficiency stats (swim/run/fly/power/luck) never decay** — growth is permanent.  
**Mood stats** decay slowly; Hunger decays the fastest to create a regular care rhythm.

When **Energy < 15** the Chao falls asleep automatically and recovers.  
When **Hunger < 20** the Chao looks visibly sad/lethargic.

### 3.3 Chao Evolution System (Simplified)

Chao evolve based on cumulative stat biases. Three alignment types:

| Type     | Trigger                                      | Visual Change      |
|----------|----------------------------------------------|--------------------|
| **Neutral** | Default — balanced stat growth             | Soft blue-green     |
| **Hero**    | High run + swim + fly                      | Warm golden tones   |
| **Dark**    | High power + luck                          | Deep purple-grey    |

Evolution is cosmetic only in this first version. The visual tint of the Chao blob gradually shifts toward the appropriate palette as the dominant stats accumulate.

Evolution thresholds: combined stat score ≥ 150 in the relevant group triggers the tint shift.

---

## 4. Feeding System

### 4.1 Interaction
- Press **[F]** to open the Food Menu.
- Click a fruit from the panel to feed it to the Chao.
- The Chao plays an "eating" animation for ~3 seconds.
- The Food Menu closes after feeding.

### 4.2 Fruit Catalogue

| Fruit         | Color  | Primary Effect         | Secondary Effect     |
|---------------|--------|------------------------|----------------------|
| Round Fruit   | Orange | Hunger +20              | Energy +5            |
| Swim Fruit    | Blue   | Swim +10                | Hunger +10           |
| Run Fruit     | Red-Orange | Run +10             | Hunger +10           |
| Fly Fruit     | Lavender | Fly +10              | Energy +5, Hunger +10 |
| Power Fruit   | Crimson | Power +10             | Hunger +15           |
| Luck Fruit    | Green  | Luck +10, Happiness +5  | Hunger +8            |
| Sweet Fruit   | Pink   | Happiness +20           | Hunger +12           |

Feeding the same fruit repeatedly has diminishing returns (future version).

---

## 5. Training System

### 5.1 Current Scope (v0.1)
A basic training system with a per-stat cooldown. Press a number key (future) or interact with a training station to train a stat.

### 5.2 Training Rules
- Each stat can be trained once per **10 seconds** (enforced by cooldown).
- Training awards **+5** to the chosen proficiency stat.
- Training costs **−8 Energy**.
- If Energy < 10 the Chao refuses training and plays a tired animation.

### 5.3 Future Mini-Games (Planned)
| Mini-Game   | Stat Trained |
|-------------|--------------|
| Swimming Pool | Swim       |
| Running Track | Run        |
| Climbing Wall | Fly / Power |
| Treasure Hunt | Luck       |

---

## 6. Petting / Interaction System

- Hovering the mouse over the Chao highlights it (name label appears).
- **Left-click** on the Chao counts as a single pet.
- **Holding** the left mouse button on the Chao triggers continuous petting (one pet event per 0.25 seconds).
- Each pet event: Happiness +3, plays the "petted" animation state, spawns 4 heart particles.

---

## 7. Chao AI / Behaviour

State machine with 5 states:

| State       | Behaviour                                          |
|-------------|----------------------------------------------------|
| **idle**    | Standing still, gentle bob animation. Lasts 1.5–4s. |
| **wandering** | Moving in a random direction at 40 px/s. Lasts 1–3.5s. |
| **happy**   | Excited bounce. Triggered by petting (1.5s override). |
| **eating**  | Stationary, squinted happy eyes (3s override from feeding). |
| **sleeping** | Eyes closed, Zzz particles. Triggers when Energy < 15; wakes when Energy ≥ 50. |

The Chao wanders within the **garden bounds**: x 160–1120, y 120–600.  
At bounds edges the velocity reflects to keep it inside.

---

## 8. Visual Style

- **Palette:** Soft pastels — mint greens, warm pinks, sky blues, lavender accents, cream whites.
- **Chao design:** Programmatic blob using `love.graphics.ellipse` — no sprites required for MVP. Body is a round blue-green ellipse with a head bump and a small coloured ball on the crown. Expressive eyes.
- **Garden:** Layered painted backgrounds: sky gradient → rolling hills → ground plane → inner grassy circle → decorative bushes/flowers/pond. All programmatic drawing.
- **Particles:** Purely code-drawn — hearts (circles+triangle), sparkle dots, butterfly dual-ellipses.
- No external image assets required for MVP.

### Colour Reference

| Element        | RGBA (0-1)                     |
|----------------|--------------------------------|
| Sky            | (0.75, 0.90, 0.85)             |
| Ground         | (0.52, 0.78, 0.52)             |
| Chao body      | (0.72–0.88, 0.85–0.95, 0.88–0.92) |
| Heart particle | (0.95, 0.45, 0.60)             |
| UI panel bg    | (0.12, 0.10, 0.18, 0.78)       |
| UI accent      | (0.68, 0.55, 0.85)             |

---

## 9. Audio Direction

- **Mood:** Ambient, pastoral, gentle. Inspired by Animal Crossing outdoor music and Studio Ghibli soundtracks.
- **Background Music:** A single looping ambient track (acoustic guitar/piano/nature synth). File: `assets/music/garden_ambient.ogg` (placeholder — not required for MVP).
- **Sound Effects (future):**
  - `pet.wav` — soft chime when petting
  - `eat.wav` — small crunch/munch sound
  - `happy.wav` — short ascending ding
  - `sleep.wav` — soft yawn

All audio files are loaded with `pcall` so the game runs silently if files are absent.

---

## 10. Scene List

| Scene       | File                          | Description                                |
|-------------|-------------------------------|--------------------------------------------|
| Menu        | `src/scenes/MenuScene.lua`    | Title screen with "Start Garden" button    |
| Garden      | `src/scenes/GardenScene.lua`  | Main gameplay — garden environment + Chao  |

Future scenes: PauseMenu, EvolutionCutscene, MultiChaoSelect.

---

## 11. Entity List

| Entity      | File                         | Description                             |
|-------------|------------------------------|-----------------------------------------|
| Chao        | `src/entities/Chao.lua`      | Main virtual pet creature               |
| ─ ChaoStats | `src/entities/chao/ChaoStats.lua` | All numeric stats + mutation methods |
| ─ ChaoAI    | `src/entities/chao/ChaoAI.lua`   | Wander state machine + position       |
| ─ ChaoAnimator | `src/entities/chao/ChaoAnimator.lua` | Programmatic blob renderer       |
| ─ ChaoInteraction | `src/entities/chao/ChaoInteraction.lua` | Mouse hover/petting detection |

---

## 12. System List

| System          | File                             | Responsibility                          |
|-----------------|----------------------------------|-----------------------------------------|
| FeedingSystem   | `src/systems/FeedingSystem.lua`  | Food menu toggle, fruit-to-Chao feeding |
| TrainingSystem  | `src/systems/TrainingSystem.lua` | Stat training with cooldowns            |
| PettingSystem   | `src/systems/PettingSystem.lua`  | Mouse→Chao pet event routing            |
| ParticleSystem  | `src/systems/ParticleSystem.lua` | Hearts, sparkles, butterflies           |
| AudioSystem     | `src/systems/AudioSystem.lua`    | Music streaming + SFX playback          |

---

## 13. UI Components

| Component | File                    | Description                             |
|-----------|-------------------------|-----------------------------------------|
| HUD       | `src/ui/HUD.lua`        | Stat bars, mood label, hints            |
| FoodMenu  | `src/ui/FoodMenu.lua`   | Fruit selection popup panel             |

---

## 14. Technical Specifications

- **Engine:** Love2D 11.4+
- **Language:** Lua 5.1 / LuaJIT
- **Resolution:** 1280 × 720 (fixed, non-resizable)
- **Target FPS:** 60
- **Physics/Joystick modules:** disabled (not needed)
- **No external libraries required for MVP**
- **Max file size:** 300 lines per Lua file (500 for GardenScene orchestrator)
- **Module pattern:** All files return their module table; no global state pollution

### File Size Policy
Every `.lua` file must stay ≤ 300 lines. GardenScene.lua (scene orchestrator) may extend to 500 lines. When a file approaches 250 lines it must be split before new code is added.

### Running the Game
```bash
cd games/vpet-garden
love .
```

---

## 15. Future Roadmap

| Milestone | Features |
|-----------|----------|
| v0.2 | Sprite assets, multiple Chao, persistence (save/load) |
| v0.3 | Training mini-games, Chao evolution visual polish |
| v0.4 | Multiple garden zones, ambient weather (rain/sun) |
| v0.5 | Chao naming screen, birthday events, gift system |
| v1.0 | Polished release build with full audio + animations |
