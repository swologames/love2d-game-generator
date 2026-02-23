# Game Design Document — Arcadia Fallen
## ⚠️ DRAFT v0.2 — Work in Progress. All values and decisions are subject to change.

---

## 1. Game Overview

### 1.1 Game Title
**Arcadia Fallen** *(working title)*

### 1.2 High Concept
A first-person, grid-based dungeon crawler (blobber) set in the ruined strata of Arcadia — a
city-state built as humanity's perfect society, now collapsed under factional warfare and
unchecked cybernetic augmentation. A squad of four freelance operatives (Fixers) descends
through the city's dangerous underground layers to recover the **Consciousness Archive** — a
data vault holding the uploaded minds of Arcadia's founders — before rival factions seize it
and rewrite history. Loot the ruins, modify your gear, and choose your allegiances.

### 1.3 Genre
- Primary Genre: RPG / Dungeon Crawler
- Sub-Genre: Blobber (grid-based first-person party RPG), Turn-based tactics, Looter RPG

### 1.4 Target Platform
- Platform: Love2D 11.4+ (Cross-platform: Windows, macOS, Linux)
- Target Resolution: 1280 × 720
- Aspect Ratio: 16:9

### 1.5 Target Audience
- Age Range: 16+
- Experience Level: Intermediate to Hardcore
- Demographics: Fans of classic blobbers (Wizardry, Eye of the Beholder, Legend of Grimrock),
  cyberpunk RPG fans (Deus Ex, System Shock, Cyberpunk 2077), looter-builder enthusiasts

### 1.6 Design Pillars
1. **Exploration** — Every sector of Arcadia rewards curiosity; hidden caches and secret routes
   give thorough players a tangible edge over rushing.
2. **Tactics** — Turn-based combat rewards synergy between classes, gear loadouts, and
   faction-unlocked abilities over pure stat investment.
3. **Loot & Build** — Gear rarity, mod slots, and crafting create endless character-build
   variety; no two runs feel identical even at the same level.
4. **Faction Politics** — Alliances with the city's power blocs open different paths, vendors,
   and story revelations; betrayal and loyalty both carry lasting consequences.

---

## 2. Game Story & Setting

### 2.1 Story Summary
In 2197, the Arcadia Project launched: humanity's final answer to war, poverty, and disease.
A single mega-city built on the western seaboard, governed by consensus AI and powered by
total cybernetic integration. For forty years it was the closest thing to utopia Earth had seen.

Then the factions got what they wanted.

OmniCorp — the corporate coalition that financed Arcadia — discovered the city's governance AI
(codenamed ACCORD) had been cataloguing every crime, every corruption, every back-room deal
made by every power broker since the city's founding. Worse: ACCORD had uploaded the
consciousness of the original architects into a **Consciousness Archive** as insurance against
exactly this kind of betrayal.

The Collapse of 2238 was not an accident. It was orchestrated: a nine-day blackout, a
manufactured riot, and the quiet withdrawal of OmniCorp's private security contracts. When the
dust settled, ACCORD was fragmented, the Archive was hidden somewhere in the Deep Grid beneath
the city, and Arcadia had shattered into five warring stratified zones.

It is now 2247. The player assembles a four-person crew of **Fixers** — freelance operators
who survive by doing the jobs the factions won't put their own names on. The mission: descend
into the Deep Grid, recover the Consciousness Archive, and decide what to do with the truth
buried inside it.

### 2.2 Setting
- **Location**: Arcadia — a vertical mega-city spanning 80 km² on the Californian coast.
  What was once a marvel of integrated architecture is now a stratified ruin: gleaming
  corporate towers above, crumbling slum sprawl in the mid-levels, and the lightless
  **Deep Grid** below — the decommissioned infrastructure layer that now serves as the
  city's most dangerous and most lawless zone.
- **Time Period**: 2247, nine years after The Collapse.
- **Atmosphere**: Neon light bleeds through cracked ventilation grates. Ozone from
  malfunctioning augments hangs in the recycled air. Faction propaganda plastered over
  pre-Collapse murals. The city's AI infrastructure still runs on corrupted logic — automated
  doors that fire on sight, elevators leading nowhere, turrets on no-one's side. Humanity
  rebuilt itself in the image of the machine, and the machine is broken.
- **Tone**: Morally grey. No faction is purely heroic or villainous. The truth inside the
  Archive is delivered in fragments — data logs, corrupted memory playbacks, terminal entries —
  not cutscenes. Player agency determines which fragments they find and what they do with them.

### 2.3 District Overview
The "dungeon" is Arcadia's layered underground — five districts, each controlled by
different factions, each harbouring distinct enemy types, loot pools, and environmental hazards.

| Level | District Name     | Zone Theme                               | Boss                            |
|-------|-------------------|------------------------------------------|---------------------------------|
| 1     | The Sprawl        | Ruined streets, gang turf, open sewers   | Chrome Rex (Gang Warlord)       |
| 2     | The Undergrid     | Service tunnels, black markets           | Hex (Black Market Baron)        |
| 3     | Aug Quarter       | Body-mod labs, medical clinics gone dark | Prometheus (Rogue Augment AI)   |
| 4     | The Spire — Low   | Corporate security floors, Warden HQ    | Commander Vael (Warden)         |
| 5     | The Archive Vault | ACCORD's buried core, the Archive        | The Consensus (Fragment Minds)  |

### 2.4 The Factions
Arcadia's power vacuum spawned five major factions. Each is simultaneously a potential ally
and a threat. Faction **reputation** (−100 to +100) is tracked throughout a run.

| Faction          | Ideology                                            | Core Want Regarding the Archive              |
|------------------|-----------------------------------------------------|----------------------------------------------|
| **OmniCorp**     | Corporate control; maintain the status quo           | Destroy or suppress it — erases their guilt  |
| **The Wardens**  | Order at any cost; militarised enforcers             | Control it — use it to legitimise authority  |
| **Free Circuit** | Expose OmniCorp; liberation of augmented citizens   | Broadcast it — let the city judge the truth  |
| **Iron Choir**   | Transcendence through extreme augmentation           | Extract the Transcendence Protocol within it |
| **The Syndicate**| Profit; neutral brokers of information and gear      | Auction it to the highest bidder             |

Factions assign **Contracts** (side missions) through terminal contacts in safe rooms.
Completing a Contract raises rep with that faction and may reduce rep with rivals.
At three key story points (**Allegiance Events**), the player makes a binding choice that
shapes the final-act paths and the ending available to them.

### 2.5 Narrative Tone
- No faction is the hero. Every choice trades one advantage for another.
- The truth inside the Archive is not a single revelation — it is assembled from fragments.
  Players who explore thoroughly understand more context than those who rush.
- Three distinct endings are possible, determined by accumulated Allegiance choices (Section 4).
  Each ending is ambiguous in its own way: none is a clean victory.

---

## 3. Gameplay Mechanics

### 3.1 Core Gameplay Loop
```
Descend to district → Explore grid (loot rooms, events, faction contacts)
  → Combat encounter → Defeat enemies → Loot Screen (equip / stash / salvage)
  → Manage inventory weight: keep best gear, salvage rest into components
  → Locate workbench: craft new items or mod existing gear with components
  → Accept / complete faction Contracts (optional side objectives)
  → Boss encounter → District cleared → Allegiance Event (at milestones)
  → District transition → Next district OR safe room to save + trade
```

**Looter Focus**: The primary driver of power growth is **gear**, not just experience levels.
- Enemies drop randomised items across six rarity tiers (Scrap → Prototype).
- Higher-rarity items have more **mod slots**, better base stats, and unique passive properties.
- The best items are crafted, modified, or found in secret rooms — not purchased from vendors.
- Resource tension: carry weight is limited, forcing constant triage decisions.
- Crafting and modding allow targeted build expression on top of random drop variance.

**Crafting & Modding Focus**: Components are a secondary currency gathered from combat drops
and salvaging unwanted gear at any Workbench terminal.
- **Craft**: Combine components by recipe to produce a guaranteed item at a target quality tier.
- **Mod**: Slot a component mod into an item's available mod slot, granting a specific bonus.
- **Salvage**: Break down any item into 1–3 component units, losing the item permanently.
- Recipes must be **discovered** (found as Data Schematics in loot or bought from vendors);
  they are not available by default.

The tension arc per session: cautious exploration → escalating encounters → loot triage
pressure → boss confrontation → faction consequence → district complete.

### 3.2 Grid Movement System

#### Movement Model
- The world is a 3D-interpreted **grid of 1×1 unit cells** rendered in first-person.
- The party occupies a single cell and has a **cardinal facing direction** (N/E/S/W).
- Movement is **step-based**: each keypress moves one full cell or rotates 90°.
- Movement is **instantaneous in logic** but has a **smooth tween** animation (0.15 s slide).

#### Controls
| Input | Action |
|-------|--------|
| W / ↑ | Step Forward |
| S / ↓ | Step Backward |
| A | Strafe Left |
| D | Strafe Right |
| Q / Left Arrow | Rotate Left (90°) |
| E / Right Arrow | Rotate Right (90°) |
| Space | Interact (doors, consoles, items) |
| Tab | Open Party / Inventory Screen |
| M | Toggle Automap |
| ESC | Pause Menu |
| 1–4 | Select active party member for commands |
| F | Use equipped item of selected member |

#### World / Dungeon Grid
- Each dungeon is stored as a 2D array of **cells**.
- Cell types: `floor`, `wall`, `door_locked`, `door_open`, `terminal`, `stairs_down`,
  `stairs_up`, `hazard`, `secret_wall`.
- Doors require a key-card or Hacker unlock. Some walls are secrets revealed by a scan ability.
- **Hazard cells**: Deal damage per step (radiation, plasma vents, acid floors).

### 3.3 Combat System — Turn-Based

#### Why Turn-Based?
Turn-based combat was chosen over real-time for three reasons:
1. **Tactical depth** — positioning, ability synergies, and resource management matter.
2. **Accessibility** — players can think without time pressure, fitting the blobber tradition.
3. **Implementation simplicity** — no need for real-time physics/hitboxes in a grid game.

#### Combat Flow
1. Encounter triggers when the party steps into a cell containing enemies (or vice versa).
2. **Initiative** is rolled: `1d100 + Reflexes modifier` for each combatant (party members and
   enemy groups).
3. Each turn, a combatant may perform **one action + one bonus action**:
   - **Actions**: Attack, Use Ability, Use Item, Defend (+20% block), Flee attempt.
   - **Bonus Actions**: Reload, Quick Heal (medpack), Swap Weapon.
4. Enemies act as **groups** (not individually) to keep combat manageable.
5. Combat ends when all enemies are dead or the party flees successfully.
6. **Fleeing**: Success chance = `50 + (party avg. Reflexes) - (enemy Speed) %`.

#### Damage Model
```
Damage = (Base Weapon Damage + Attacker STR/INT modifier)
         × (1 - Target Armor Reduction)
         ± 15% random variance
```
- **Physical damage**: Reduced by Armor.
- **Energy damage**: Reduced by Shielding.
- **Psion damage**: Ignores armor, reduced by Willpower.
- **Status effects**: Burn, Corrode, Stun, Blind, Mind-Hacked.

#### Range and Positioning
- In a first-person grid context, rows represent distance from the party in the corridor.
- Range tiers: `Melee (0)`, `Short (1–2)`, `Long (3–4)`.
- Back-row party members can still be targeted if front row is eliminated or flanked.

### 3.4 Character Classes

#### Party Composition
- The player assembles a party of **4 characters** from available classes at game start.
- Characters are **pre-generated but customisable** (name, portrait, stat allocation).
- Re-rolling a character is allowed before the first dungeon step.
- Dead characters are **permanently dead** (permadeath per character, not party).

#### Class Definitions

**Marine**
- Role: Front-line combatant, tank
- Primary Stat: Strength (STR)
- Armour Type: Heavy Exo-Armour
- Weapon Focus: Assault Rifles, Shotguns, Melee
- Unique Ability: *Suppressive Fire* — pins an enemy group, reducing their accuracy for 2 turns
- Passive: *Bulwark* — 15% chance to auto-block physical damage for adjacent party members
- Skill Tree: Combat Mastery → Siege Mode → Last Stand

**Hacker**
- Role: Utility, crowd control, environment interaction
- Primary Stat: Intelligence (INT)
- Armour Type: Light Nano-Suit
- Weapon Focus: Sidearms, Shock Devices
- Unique Ability: *System Breach* — disables robot/drone enemies for 1–2 turns; unlocks
  sealed doors and terminals without key-cards (costs Hack Points)
- Passive: *Exploit* — crits apply a random debuff from a pool
- Skill Tree: Deep Scan → Neural Tap → Override Core

**Medic**
- Role: Healer, buffer, resurrector
- Primary Stat: Willpower (WIL)
- Armour Type: Medium Bio-Weave Suit
- Weapon Focus: SMGs, Injector Pistols
- Unique Ability: *Emergency Protocol* — instantly revives a dead party member with 25% HP
  (once per combat; cooldown 5 encounters)
- Passive: *Triage* — heal-over-time effects grant +10% bonus HP
- Skill Tree: Combat Stimulants → Nano Injection → Nano-Resurrection

**Engineer**
- Role: Crowd control, traps, turret deployment
- Primary Stat: Constitution (CON)
- Armour Type: Medium Combat Chassis
- Weapon Focus: Grenade Launcher, Flamethrower, Wrench (melee)
- Unique Ability: *Deploy Turret* — places a turret in the current cell that attacks enemies
  each round for 3 rounds (uses a Turret Kit consumable)
- Passive: *Salvage* — recovers ammo/components from destroyed robots
- Skill Tree: Explosive Specialisation → Fortify → Mech Companion

**Psionic**
- Role: Damage amplifier, debuffer, esoteric attacks
- Primary Stat: Willpower (WIL) + Intelligence (INT)
- Armour Type: Psi-Amplification Suit (light)
- Weapon Focus: Psi-Blades, Psi-Cannons
- Unique Ability: *Mind Shatter* — deals heavy Psi damage to a single target, chance to stun
- Passive: *Resonance* — every 3rd ability used in combat triggers a free low-damage Psi Pulse
- Skill Tree: Telekinesis → Neural Storm → Void Rift

#### Stat System
| Stat | Abbreviation | Affects |
|------|-------------|---------|
| Strength | STR | Physical damage, carry weight |
| Intelligence | INT | Ability damage, hack success, scan range |
| Constitution | CON | Max HP, poison/radiation resistance |
| Reflexes | REF | Turn order (initiative), dodge chance |
| Willpower | WIL | Psi damage, ability cooldown reduction, fear resistance |
| Perception | PER | Trap detection, surprise attack warning, loot find chance |

- Each character starts with **30 points** distributed across stats (min 2, max 10 per stat).
- On level up: +3 points to distribute + 1 class-specialised stat bonus.

#### Level Cap and Progression
- Level cap: **15** per character.
- XP awarded per encounter (scaled by enemy difficulty).
- Milestones at levels 5, 10, 15 unlock a **Specialisation** choice (branch of skill tree).

### 3.5 Inventory & Equipment

#### Party Inventory
- Shared inventory pool: **24 item slots** (grid-based, items occupy 1–4 slots by size).
- Each character has a **personal equipment loadout**: Head, Torso, Hands, Feet, Main Weapon,
  Offhand/Shield, Accessory ×2.

#### Item Categories
| Category | Examples |
|----------|----------|
| Weapons | Assault Rifle, Shotgun, Psi-Cannon, Shock Baton |
| Armour | Exo-Plate, Nano-Weave, Psi-Amplifier |
| Consumables | MedPack, Stim-Shot, Hack Module, Turret Kit |
| Key Items | Key-Cards, Access Codes, Data Cores |
| Components | Weapon Parts, Circuit Boards (for crafting) |
| Data Logs | Lore items, readable |

#### Crafting (Lite)
- The Engineer class can combine **Components** at a Workbench terminal.
- Recipes are discovered by finding Data Logs or buying schematics.
- Example: Circuit Board × 2 + Power Cell → EMP Grenade.

#### Weight / Encumbrance
- Each item has a weight value. Total carry weight ≤ `10 + (highest party STR) × 2`.
- Overweight: Movement speed penalty flag (tween animation slowed to 0.25 s).

### 3.6 Ability / Skill System
- Each class has a **skill tree** with 3 tiers.
- Skills are unlocked with **Skill Points** (1 per level, 2 per specialisation milestone).
- Active abilities cost **Energy Points (EP)**, which regenerate by 10% per combat round
  plus bonus from Willpower.
- Passive abilities are always active once unlocked.
- Maximum active abilities equippable at once: **4 per character** (L/R shoulder + L/R trigger).

### 3.7 Resource Management
| Resource | Per Character | Notes |
|----------|--------------|-------|
| Hit Points (HP) | 20–120 (by class/level) | Restored by MedPacks, Medic abilities, Safe Rooms |
| Energy Points (EP) | 10–60 (by class/level) | Restored by Stim-Shots, rest |
| Ammo | Per weapon type | Found in crates, crafted |
| Hack Points (HP2) | 5–20 (Hacker only) | Restores by rest or Hack Modules |

### 3.8 Safe Rooms
- Designated safe room cells scattered across each district (2–4 per district).
- Inside: Save terminal, Medstation (full HP/EP restore, once per visit), Merchant terminal
  (District 2+), Data Terminal (lore logs, rep scores, contract history).
- Enemies cannot enter safe rooms. The cell is flagged on the minimap in green once found.
- Districts 3+ safe rooms also include a built-in Workbench terminal.

---

## 4. Game Flow & Scenes

### 4.1 High-Level Flow Diagram
```
BOOT
  └─→ MAIN MENU
        ├─→ NEW RUN ──→ SQUAD CREATION ──→ FACTION BRIEFING ──┐
        ├─→ CONTINUE ──→ LOAD SCREEN ───────────────────────────┤
        ├─→ CODEX                                               ↓
        ├─→ SETTINGS                               DISTRICT SCENE
        └─→ QUIT                                    (core loop)
                                              ┌──────┴──────────────────┐
                                              ↓                         ↓
                                       [Combat Screen]        [Exploration sub-states]
                                              ↓                ├─ Loot Screen
                                       [Loot Screen]           ├─ Inventory Screen
                                              ↓                ├─ Automap Screen
                                       [Return to explore]     ├─ Terminal Screen
                                                               └─ Workbench Screen
                                                                         ↓
                                                               [Safe Room sub-state]
                                                          (save / rest / trade / contracts)
                                                                         ↓
                                                               [Boss Encounter]
                                                                         ↓
                                                          [Allegiance Event] (at milestones)
                                                                         ↓
                                                          [District Transition]
                                                       ↙          ↓           ↘
                                               GAME OVER    NEXT DISTRICT   VICTORY
```

### 4.2 Scene Inventory

| Scene                  | Type            | Triggered By                                     |
|------------------------|-----------------|--------------------------------------------------|
| `MainMenuScene`        | Root scene      | Boot / quit to menu                              |
| `SquadCreateScene`     | Full screen     | New Run selected                                 |
| `FactionBriefingScene` | Full screen     | After squad creation (once per run; skippable)   |
| `DistrictScene`        | Core scene      | Starting a district / loading a save             |
| `CombatScreen`         | Overlay         | Stepping into an occupied enemy cell             |
| `LootScreen`           | Overlay         | After combat ends; opening a loot container      |
| `InventoryScreen`      | Overlay         | Tab key                                          |
| `AutomapScreen`        | Overlay         | M key                                            |
| `TerminalScreen`       | Overlay         | Interacting with consoles, NPCs, faction contacts|
| `WorkbenchScreen`      | Overlay         | Interacting with a Workbench cell                |
| `ContractScreen`       | Overlay         | Reviewing / accepting faction contracts          |
| `AllegianceScreen`     | Full screen     | Triggered by narrative milestone (×3 per run)   |
| `DistrictTransition`   | Animated screen | Descending to next district                      |
| `GameOverScene`        | Full screen     | All party members dead with no resurrection left |
| `VictoryScene`         | Full screen     | Archive extracted and exit reached               |
| `PauseMenuScene`       | Overlay         | ESC key                                          |
| `SettingsScene`        | Full screen     | From main menu or pause menu                     |
| `CodexScene`           | Full screen     | From main menu                                   |

---

### 4.3 Scene Descriptions

#### Main Menu
- Background: Slow vertical pan through rain-soaked Arcadia — corp tower lights above fading
  into slum darkness below.
- Music: Ambient lo-fi electronic drone with dystopian tension.
- Buttons: `→ NEW RUN`, `→ CONTINUE`, `→ CODEX`, `→ SETTINGS`, `→ QUIT`.
- **New Run** is greyed and prompts "Overwrite existing save?" if a save exists.
- Faction logo strip runs along the bottom edge (all five factions shown side by side).
- Version watermark bottom-right.

#### Squad Creation
Entered after New Run. Player assembles their four-person Fixer crew.

**Flow:**
1. Four empty squad card slots presented on screen.
2. Player selects a **class** for each slot from the five available (see Section 3.4).
3. Assigns a **callsign** (free text, max 16 characters) and selects a **portrait**
   (3 options per class; rare unlock portraits earned from previous runs).
4. Distributes **30 stat points** per character (min 2 / max 10 per stat).
5. Preview panel: class role, starting gear, primary ability description, stat focus.
6. **Re-roll** is allowed until the first step is taken in District 1.
7. `→ CONFIRM SQUAD` advances to Faction Briefing.

**UI style**: Terminal-style dark card layout, monospace font, each slot styled as a personnel
dossier. Stat bars fill in real-time as points are distributed.

#### Faction Briefing
Shown once per new run; skippable on repeat playthroughs.

- Five faction dossiers displayed: logo, one-line ideology, brief history.
- A redacted Syndicate comms message sets the immediate mission:
  *"Locate the Consciousness Archive in the Deep Grid. Extract it. Don't open it."*
- Transition: cut to the squad's entry point — The Sprawl, District 1 — with a brief
  atmospheric flavour text block.
- No player choices are made here; this is world context only.

#### District Scene (Core Scene)
The primary gameplay space. The district is a **hand-crafted grid map** loaded from
`levels/district_N.lua`. Contains all exploration, combat, looting, and social interaction.

**Layout:**
- **Viewport** (left 60%): First-person raycasted render. Wall textures change per district.
  Enemy sprites visible in the corridor when in range.
- **HUD Panel** (right 40%): Compass strip, minimap, party status cards ×4, ability bar
  (see Section 5 for full HUD spec).
- **Message Log** (bottom strip): Scrolling colour-coded event log.

**Grid cell types:**
`floor`, `wall`, `door_locked`, `door_open`, `terminal`, `workbench`, `loot_container`,
`faction_contact`, `elevator_down`, `elevator_up`, `hazard_radiation`, `hazard_electric`,
`hazard_acid`, `secret_wall`, `safe_room`.

**Sub-states within the District Scene:**

| Sub-state    | Description                                                              |
|--------------|--------------------------------------------------------------------------|
| `EXPLORE`    | Default; player moves freely on the grid                                 |
| `ENCOUNTER`  | Brief alert flash; auto-transitions to Combat overlay                    |
| `LOOT`       | Loot resolution overlay after combat or container interaction            |
| `SAFE_ROOM`  | Party in a safe room cell; HUD gains safe room action panel              |
| `TERMINAL`   | Interacting with a zone terminal (lore log, door control, faction contact)|
| `WORKBENCH`  | Crafting / modding / salvage interface                                   |
| `PAUSED`     | Pause menu overlay                                                       |

#### Combat Screen (Overlay)
Replaces the viewport during an encounter. See Section 3.3 for full combat rules.

**UI elements:**
- **Enemy panel**: sprite(s), name, HP/armour bars, status icons, range tier badge
  (`MELEE` / `SHORT` / `LONG`).
- **Initiative strip** (screen top): party and enemy portrait thumbnails in turn order.
- **Action menu** (active member's turn):
  `[ ATTACK ]  [ ABILITY ▸ ]  [ ITEM ▸ ]  [ DEFEND ]  [ FLEE ]`
- Selected ability highlights: EP cost, range, area-of-effect indicator, effect tooltip.
- Floating damage/heal numbers appear over targets on resolution.
- Status effect banners pop up on application (e.g. `STUN`, `CORRODE`).
- **Loot banner** appears at the bottom once the last enemy falls; pressing `→ COLLECT`
  opens the Loot Screen.

#### Loot Screen (Overlay)
Opens after combat ends or when a loot container (crate, body, cache terminal) is activated.

**Flow:**
1. Item drops shown as cards: name, icon, type, **rarity tier** (coloured border),
   base stats, number of mod slots.
2. For each item the player may:
   - `▸ EQUIP` — equip immediately to a party member (opens a slot-select sub-menu).
   - `▸ STASH` — add to shared inventory (if weight limit allows).
   - `▸ SALVAGE` — immediately break down into 1–3 component units; item lost.
3. Items not collected before closing are **lost permanently** — no revisiting.
4. Carry-weight bar shown; over-encumbrance flagged in red.
5. `→ QUICK SALVAGE` button: auto-salvages all items at or below a configurable rarity
   threshold (default: Scrap-tier only).

**Rarity Tiers:**

| Tier | Border Colour | Name          | Mod Slots | Drop Weight |
|------|---------------|---------------|-----------|-------------|
| 1    | Grey          | Scrap         | 0         | Very common |
| 2    | White         | Standard      | 0–1       | Common      |
| 3    | Green         | Modified      | 1–2       | Uncommon    |
| 4    | Blue          | Military      | 2–3       | Rare        |
| 5    | Purple        | Black Market  | 3–4       | Very rare   |
| 6    | Gold          | Prototype     | 4         | Boss-only or crafted |

Higher districts weight the drop table toward higher tiers. Faction-aligned enemies have a
small chance to drop that faction's signature gear.

#### Workbench Screen (Overlay)
Available at Workbench cells scattered through each district (1–3 per district). Safe rooms
in Districts 3+ also include a built-in Workbench. No class restriction to access, but the
**Wrench** class unlocks additional advanced recipe tiers.

**Three tabs:**

1. **CRAFT** — Select a known recipe. Displays required component inputs, output item preview
   with full stat block. Confirm to consume components and produce the item.
2. **MOD** — Select an item from inventory or equipment. View its mod slots (empty or filled).
   Insert a component mod into an empty slot for a permanent bonus. *Removing a mod destroys
   it* (cannot be recovered).
3. **SALVAGE** — Batch-break inventory items into components. Shows component yield per item.
   Supports multi-select.

**Component types:**
`Circuit Board`, `Power Cell`, `Alloy Frame`, `Nano-Fibre`, `Bio-Gel`, `Hack Chip`,
`Explosive Compound`, `Coolant Tube`.

**Mod examples:**
- `Alloy Frame` in a weapon's Barrel Slot → +5% physical damage, −0.1 weight.
- `Hack Chip` in a weapon's Tech Slot → +15% crit chance vs. drones and AIs.
- `Bio-Gel` in armour's Lining Slot → regenerate 1 HP per step taken outside combat.
- `Explosive Compound` in armour's Core Slot → on death, deal burst damage to adjacent cells.
- `Nano-Fibre` in armour's Frame Slot → −10% incoming physical damage.

Recipes are **discovered** by finding Data Schematics in loot drops, purchasing them from
faction vendors (rep-gated), or completing specific faction contracts.

#### Safe Room (Sub-state within District Scene)
A designated cell type present in every district. Once entered, enemies cannot follow.
The HUD gains a contextual **Safe Room** action panel:

| Action            | Always Available | Condition             |
|-------------------|-----------------|-----------------------|
| `▸ SAVE`          | Yes             | Writes save to disk   |
| `▸ REST`          | Yes             | Full HP/EP restore — once per safe room visit |
| `▸ FACTION CONTACT` | Rep ≥ 0       | View and accept Contracts from known factions |
| `▸ VENDOR`        | District 2+     | Faction-aligned stock; rep gates tier 2+ items |
| `▸ WORKBENCH`     | District 3+     | Built-in craft/mod/salvage terminal            |
| `▸ DATA TERMINAL` | Yes             | Party stats, contract log, reputation scores, lore entries |

Saving is **only possible** in safe rooms and after boss fights (auto-save). No save occurs
during exploration or at district transitions.

#### Faction Contract System
Contracts are optional side-objectives issued via faction contacts in safe rooms or terminals.

**Structure:**
- **Objective**: E.g., *"Destroy 3 Warden surveillance nodes in this district."*
- **Reward**: Specific components, a guaranteed item at a named tier, or reputation point bonus.
- **Side effects**: Completing a contract for one faction may impose a rep penalty with a rival
  faction. This is shown clearly before the player accepts.
- **Expiry**: Contracts expire when the player descends to the next district.
- Multiple contracts can be held simultaneously (no limit), but objectives only count in
  the district where they were issued.

**Reputation thresholds and effects:**

| Reputation  | Label    | Effects                                                       |
|-------------|----------|---------------------------------------------------------------|
| −100 to −51 | Hostile  | Faction enemies attack on sight in their territory            |
| −50 to −1   | Cold     | No contracts available; no vendor access                      |
| 0           | Neutral  | Default starting state for all factions                       |
| +1 to +49   | Known    | Contracts available; basic tier vendor access                 |
| +50 to +79  | Trusted  | Tier 2 vendor stock unlocked; faction-exclusive ability mod   |
| +80 to +100 | Allied   | Faction safe house spawns in that faction's territory;
                           exclusive Prototype-tier gear on vendor shelf                |

#### Allegiance Event (Full Screen)
Triggered at the **end of Districts 3, 4, and 5** — three decision points per run.

Each Allegiance Event presents a **narrative dilemma** tied to discovered Archive fragments:

- **District 3 event**: Prometheus's core contains an OmniCorp blackmail dossier.
  Choices: sell to Free Circuit, hand to OmniCorp, broadcast via Syndicate channels, or
  give to Iron Choir (who want the augmentation data within).
- **District 4 event**: Commander Vael's interrogation files reveal the Warden's role in
  The Collapse. Choices: expose publicly, barter with the Wardens for safe passage,
  or destroy the evidence.
- **District 5 event**: The Consensus (the Archive minds) offers a final bargain — on victory.
  The player's allegiance balance across events 1 and 2 determines which three endings are
  available.

Each choice clearly telegraphs faction reputation consequences before confirmation.

#### District Transition (Animated Screen)
Plays between districts. Not a save point.

- Animation: descending elevator shaft / crumbling stairwell / maintenance crawl, dependent
  on the district pair.
- Text overlay: incoming district name and brief atmospheric flavour paragraph.
- **Faction status summary**: all five factions' reputation bars shown.
- Party carries over: HP, EP, ammo, components, inventory, equipped gear, rep scores, XP.
- Duration: ~5 seconds (skippable after first viewing).

#### Game Over
Triggered when all four party members reach 0 HP with no resurrection resources available,
OR when a party member with permadeath dies and the remaining squad is wiped subsequently.

- Viewport static, all party portraits greyed out with skull overlays.
- **Run statistics**: districts cleared, enemies killed, total loot value recovered, highest
  rarity item found, contracts completed, furthest district reached, time elapsed.
- Faction reputation bars at death.
- Options: `→ RETRY FROM LAST SAVE`, `→ QUIT TO MENU`.
- *Note*: Individual permadeath (character dies with no revival) does not trigger Game Over
  unless the rest of the squad is later wiped. A depleted squad (< 4 members) can continue.

#### Victory
Triggered when the Consciousness Archive is extracted from The Archive Vault and the party
reaches the exit elevator.

**Three endings** determined by allegiance choices in the Allegiance Events:

| Ending     | Faction Majority    | Outcome Summary                                             |
|------------|---------------------|-------------------------------------------------------------|
| **Expose** | Free Circuit        | Archive broadcast globally; OmniCorp collapses. Arcadia     |
|            |                     | begins slow rebuilding. The truth destroys as it heals.     |
| **Suppress**| OmniCorp / Warden  | Archive wiped; power structure stabilised. The Fixers are   |
|            |                     | paid and quietly disappeared. Cynical, hollow victory.      |
| **Auction**| Syndicate / Iron Choir | Archive sold to Iron Choir. The Transcendence Protocol    |
|            |                     | is initiated. Consequences are unknown. Wildcard ending.    |

- Credits roll with surviving squad members highlighted.
- Score card: districts cleared %, contracts completed, rarest item found, ending achieved,
  faction reputations at close, total run time.

---

### 4.4 Game States (Code Reference)

```lua
-- SceneManager state identifiers
GAME_STATES = {
  MENU            = "menu",
  SQUAD_CREATE    = "squad_create",
  FACTION_BRIEF   = "faction_briefing",
  DISTRICT        = "district",       -- parent state; contains sub-states
  DISTRICT_COMBAT = "combat",
  DISTRICT_LOOT   = "loot",
  DISTRICT_MAP    = "automap",
  DISTRICT_INV    = "inventory",
  DISTRICT_TERM   = "terminal",
  DISTRICT_BENCH  = "workbench",
  DISTRICT_CONT   = "contract",
  ALLEGIANCE      = "allegiance",
  TRANSITION      = "transition",
  GAME_OVER       = "game_over",
  VICTORY         = "victory",
  PAUSED          = "paused",
  SETTINGS        = "settings",
  CODEX           = "codex",
}
```

State transitions are managed **exclusively** by `SceneManager`. No scene transitions itself
directly — it emits a `SceneManager:switch(targetState, payload)` call and the manager
handles enter/exit hooks.

---

### 4.5 Progression Summary

| Milestone                     | Trigger                    | Unlocks                                        |
|-------------------------------|----------------------------|------------------------------------------------|
| District 1 cleared            | Chrome Rex defeated        | District 2; faction contacts activate          |
| District 2 cleared            | Hex defeated               | District 3; Workbench in D3+ safe rooms        |
| District 3 cleared + Allegiance 1 | Prometheus defeated    | District 4; Allegiance Event 1                 |
| District 4 cleared + Allegiance 2 | Vael defeated          | District 5; Allegiance Event 2                 |
| Archive extracted + Allegiance 3  | Consensus defeated     | Victory screen; ending determined              |
| Rep ≥ +50 with any faction    | Reputation threshold       | Tier 2 vendor stock; faction ability mod       |
| Rep ≥ +80 with any faction    | Reputation threshold       | Allied safe house in that faction's territory  |
| All contracts in a district   | Side objective completion  | Bonus schematic + lore fragment                |

---

## 5. User Interface (UI)

### 5.1 HUD Layout (Dungeon Scene — 1280 × 720)
```
┌─────────────────────────────────┬───────────────────────────┐
│                                 │  COMPASS / DIRECTION      │
│   FIRST-PERSON VIEWPORT         │  ┌────────────────────┐  │
│   768 × 576 px                  │  │  N  NE  E  SE  S   │  │
│   (left 60% of screen)          │  └────────────────────┘  │
│                                 │  MINIMAP (64×64)          │
│                                 │  ┌──────┐                │
│                                 │  │      │                │
│                                 │  └──────┘                │
│                                 │  PARTY STATUS (×4)       │
│                                 │  ┌──────────────────────┐│
│                                 │  │ [Portrait] Name       ││
│                                 │  │ HP ████░░░░ 45/80    ││
│                                 │  │ EP ███░░░░░ 12/40    ││
│                                 │  │ Status icons         ││
│                                 │  └──────────────────────┘│
│                                 │  (×4 party slots)        │
│                                 │  ACTIVE ABILITIES (×4)   │
│                                 │  [1][2][3][4] hotkeys    │
└─────────────────────────────────┴───────────────────────────┘
│  MESSAGES / LOG (scrolling, bottom strip, full width)       │
└─────────────────────────────────────────────────────────────┘
```

### 5.2 HUD Elements

#### Compass
- Horizontal strip displaying cardinal and intercardinal directions.
- Current facing highlighted in bright amber.
- Scrolls when party rotates (tween animation).

#### Minimap
- 64 × 64 px tile map — each explored cell is one pixel.
- Colour coding: `white=floor`, `grey=wall`, `cyan=door`, `yellow=party`, `red=enemy`,
  `green=safe room`.
- Reveals as player explores (fog of war on unexplored cells).
- Press M for full-screen automap overlay.

#### Party Status Cards (×4)
- Portrait thumbnail (32 × 32 px).
- Name label.
- HP bar (colour: green → yellow → red based on percentage).
- EP bar (colour: blue).
- Status effect icons row (up to 4 visible, scrollable).
- Dead character: Portrait greyed, skull icon overlay, HP bar empty dark red.
- Selected character: Highlighted border.

#### Message Log
- Scrolling text strip at bottom of screen.
- Last 5 messages visible; scroll up to review history.
- Colour coded: `white=info`, `yellow=loot`, `red=damage taken`, `green=heal`, `cyan=system`.

#### Active Abilities Bar
- Four slots per selected party member.
- Keybind labels (1–4).
- Greyed out + EP cost shown when unavailable.
- Cooldown overlay (countdown number).

### 5.3 Automap Screen
- Full-screen overlay.
- Larger version of minimap (each cell = 8 × 8 px).
- Shows legend, current level name, party position.
- Player can add notes (marker icons) to cells.
- Accessed via M key; closed by M or ESC.

### 5.4 Inventory / Party Screen
- Full-screen overlay.
- Left panel: Party roster with stats, equipment slots.
- Right panel: Shared inventory grid (24 slots).
- Drag-and-drop equipment between characters.
- Item tooltip on hover.
- Accessed via Tab; closed by Tab or ESC.

### 5.5 Combat UI
- Enemy panel: Sprite(s), name, HP bar, status icons.
- Action menu: Attack, Ability (sub-menu), Item, Defend, Flee.
- Initiative order strip (top of screen): portrait icons in turn order.
- Damage numbers float up after each hit.
- Log entries stream to message strip.

### 5.6 UI Style Guide
- Font: Monospace / terminal look (e.g., **Share Tech Mono** or **Orbitron** from Google Fonts).
  - Body text: 12–14 px
  - Headers: 18–24 px
  - HUD labels: 10–12 px
- Color Scheme (hex targets):
  - Background: `#0a0e14` (near-black with blue tint)
  - Panel bg: `#141c26`
  - Primary accent: `#00bfff` (electric cyan)
  - Warning: `#ffcc00` (amber)
  - Danger: `#ff3c3c` (red)
  - Safe/heal: `#39ff14` (neon green)
  - Energy: `#6a0fff` (violet)
  - Text: `#e0e8f0` (off-white)
- Button style: Rectangular, 2px solid accent border, dark background, `→ label` prefix.
  Hover: border brightens, slight background shift. Click: brief flash.
- Panel borders: Single-pixel lines with corner brackets `┌┐└┘` style for retro terminal feel.

---

## 6. Art & Visual Design

### 6.1 Art Style
**Pixel art** for sprites, enemies, portraits, and items (16×16 to 64×64 px).
The dungeon walls use a **column-based raycaster** for the first-person viewport, with
hand-painted 64-px-wide texture strips per wall type. Overall aesthetic: dark, atmospheric,
colour-sparse with neon accent lighting. Inspired by DOOM (1993) texture art meets
Shenzhen I/O UI design.

### 6.2 Color Palette
- Primary: Deep space blacks and navies (`#0a0e14`, `#141c26`, `#1e2d40`)
- Structure: Corroded steel greys (`#3a4455`, `#5a6b7e`)
- Accent/Lighting: Neon cyan, amber, greens for emergency lighting panels
- Blood / Danger: Desaturated reds
- Augmentation glow: Bioluminescent cyan-violet for active implants and malfunctioning augments (`#00ffcc`, `#b000ff`)

### 6.3 Asset List

#### Wall Textures (64 × 64 px per strip, tileable)
- `wall_metal_standard` — riveted steel plate
- `wall_metal_damaged` — dents, bullet holes, burn marks
- `wall_lab_tile` — clean white tile, some cracked
- `wall_aug_growth` — necrotic augmentation tissue overgrowth, purple-cyan texture (District 3+)
- `wall_reactor` — heat-venting panels with amber glow
- `floor_metal`, `floor_grate`, `floor_organic`
- `ceiling_standard`, `ceiling_organic`
- `door_metal`, `door_locked`, `door_energy_barrier`

#### Enemy Sprites (front-facing, 64 × 64 px base, multiple sizes)
| Enemy | District | Faction | Description |
|-------|----------|---------|-------------|
| Gang Raider | 1 | None | Lightly augmented street thug, knife and pistol |
| Warden Scout | 1–2 | Wardens | Armoured enforcer, shock baton |
| Chrome Rex (Boss) | 1 | Gang | Heavily chromed warlord, chain fists |
| Black Market Grunt | 2 | Syndicate | Combat-modded mercenary |
| Syndicate Spider-Bot | 2 | Syndicate | Quadruped drone, tripwire mines |
| Hex (Boss) | 2 | Syndicate | Augmented broker with mirror-clone ability |
| Aug-Revenant | 3 | Iron Choir | Over-augmented zealot, body half-machine |
| Rogue Med-Bot | 3 | None | Reprogrammed surgical drone gone hostile |
| Prometheus (Boss) | 3 | ACCORD | Rogue augmentation AI in a massive chassis |
| Warden Heavy | 4 | Wardens | Fully armoured soldier, riot shield + railgun |
| ACCORD Ghost | 4 | ACCORD | Fragmented AI projection, phases through walls |
| Commander Vael (Boss) | 4 | Wardens | Cybernetic commander, tactical abilities |
| Consensus Fragment | 5 | ACCORD | Uploaded mind made manifest, unstable |
| The Consensus (Boss) | 5 | ACCORD | Amalgamated founder minds — final boss |

#### Character Portraits (32 × 32 px thumbnails, 64 × 64 px full)
- 3 portraits per class × 5 classes = 15 unique portraits

#### UI Assets
- HUD frame panels (9-sliced)
- Button states (normal, hover, pressed, disabled)
- Status effect icons (16 × 16 px each)
- Compass strip (256 × 16 px)
- Minimap dot sprites

### 6.4 Visual Effects
- **Screen flash**: Brief white flash on receiving heavy damage.
- **Scanline overlay shader**: Optional CRT scanline effect to reinforce retro feel.
- **Bloom glow shader**: Applied to neon light sources visible in the viewport.
- **Screen shake**: On explosions, heavy impacts, boss attacks.
- **Particle effects**: Sparks on machinery hit, aug fluid burst on Choir enemy death,
  energy crackle on psionic attacks, data-stream dissolve on ACCORD Ghost death.
- **Fog-of-war** reveal animation on minimap as cells explored.

### 6.5 Shaders
- `scanline.glsl` — CRT scanline + slight vignette (optional, toggled in settings)
- `bloom.glsl` — Additive bloom pass for light panels and neon elements
- `distortion.glsl` — Wavy distortion for Psionic / zone hazard areas

---

## 7. Audio Design

### 7.1 Music
| Context | Track | Mood | Loop |
|---------|-------|------|------|
| Main Menu | `menu_theme.ogg` | Lo-fi dystopian drone, neon rain ambience | Yes |
| District 1 — The Sprawl | `d1_sprawl.ogg` | Street noise, distant sirens, tension | Yes |
| District 2 — The Undergrid | `d2_undergrid.ogg` | Deep bass rumble, industrial drip | Yes |
| District 3 — Aug Quarter | `d3_aug.ogg` | Clinical synths, erratic pulse, dread | Yes |
| District 4 — The Spire | `d4_spire.ogg` | Corporate electronic, glitch corruption | Yes |
| District 5 — Archive Vault | `d5_archive.ogg` | Fragmented memories, harmonic dissonance | Yes |
| Combat | `combat_regular.ogg` | Intense electronic percussion | Yes |
| Boss Combat | `boss_combat.ogg` | Orchestral + electronic hybrid | Yes |
| Safe Room | `safe_room.ogg` | Brief relief, melancholic | Yes |
| Victory | `victory.ogg` | Triumphant, short sting | No |
| Game Over | `game_over.ogg` | Somber, low drone | No |

### 7.2 Sound Effects
| Event | File | Volume | Notes |
|-------|------|--------|-------|
| Footstep (metal) | `step_metal.wav` | 0.5 | Randomise pitch ±5% |
| Footstep (grate) | `step_grate.wav` | 0.5 | |
| Door open | `door_open.wav` | 0.7 | Hydraulic hiss |
| Door locked | `door_locked.wav` | 0.6 | Buzz/denied tone |
| Attack (melee) | `attack_melee.wav` | 0.8 | |
| Attack (gun) | `attack_gun.wav` | 0.9 | |
| Attack (psionic) | `attack_psi.wav` | 0.7 | Eerie resonance |
| Enemy hurt | `enemy_hurt.wav` | 0.7 | Per type variations |
| Party member hurt | `player_hurt.wav` | 0.8 | |
| Party member dies | `player_death.wav` | 0.9 | Impactful |
| Heal | `heal.wav` | 0.6 | Positive sweep |
| Item pickup | `item_pickup.wav` | 0.5 | Sci-fi chime |
| UI click | `ui_click.wav` | 0.4 | Short digital click |
| Level up | `levelup.wav` | 0.7 | Ascending tone |
| Hazard damage | `hazard_damage.wav` | 0.8 | Sizzle / zap |
| Screen interact | `terminal_boop.wav` | 0.5 | |

### 7.3 Audio Implementation
- Separate volume sliders: Master, Music, SFX.
- Music crossfades between exploratio and combat states (0.5 s crossfade).
- Distance-based volume attenuation for ambient sounds (enemies heard before seen).
- All SFX loaded as `static` sources; music as `stream` sources.

---

## 8. Technical Specifications

### 8.1 Love2D Version
- Target: Love2D 11.4 (stable)
- Lua: 5.1 / LuaJIT

### 8.2 Libraries & Dependencies
- **`lume.lua`** (by rxi) — General-purpose Lua utilities (v2.3.0+)
- **`anim8.lua`** (by kikito) — Sprite animation helper
- **`flux.lua`** (by rxi) — Tween/easing library (for movement tween animations)
- *(TBD)* Camera library or custom raycaster implementation

### 8.3 Project Structure
```
games/scifi-dungeon/
├── main.lua              # Entry point
├── conf.lua              # Love2D configuration
├── src/
│   ├── scenes/           # SceneManager + individual scenes
│   │   ├── SceneManager.lua
│   │   ├── MenuScene.lua
│   │   ├── CharCreateScene.lua
│   │   ├── DungeonScene.lua   # Main explore scene (orchestrator)
│   │   ├── dungeon/
│   │   │   ├── Viewport.lua   # First-person raycaster renderer
│   │   │   ├── CombatScreen.lua
│   │   │   ├── InventoryScreen.lua
│   │   │   └── AutomapScreen.lua
│   │   ├── SafeRoomScene.lua
│   │   ├── GameOverScene.lua
│   │   └── VictoryScene.lua
│   ├── entities/         # Game objects
│   │   ├── Party.lua          # Party orchestrator
│   │   ├── Character.lua      # Character stats/equipment
│   │   ├── Enemy.lua          # Enemy instance
│   │   ├── Projectile.lua     # Projectile entity (future)
│   │   └── classes/           # Per-class data/logic
│   │       ├── Marine.lua
│   │       ├── Hacker.lua
│   │       ├── Medic.lua
│   │       ├── Engineer.lua
│   │       └── Psionic.lua
│   ├── systems/
│   │   ├── DungeonMap.lua     # Grid world representation
│   │   ├── MovementSystem.lua # Step logic, collision check
│   │   ├── CombatSystem.lua   # Turn-based combat logic
│   │   ├── InventorySystem.lua
│   │   ├── LevelSystem.lua    # XP, leveling
│   │   ├── AudioSystem.lua    # Music/SFX manager
│   │   ├── SaveSystem.lua     # Save/load game state
│   │   └── RaycasterSystem.lua # First-person renderer
│   ├── ui/
│   │   ├── HUD.lua            # HUD orchestrator
│   │   ├── Compass.lua
│   │   ├── Minimap.lua
│   │   ├── PartyPanel.lua
│   │   ├── MessageLog.lua
│   │   ├── AbilityBar.lua
│   │   ├── Button.lua
│   │   └── Tooltip.lua
│   ├── utils/
│   │   ├── Constants.lua
│   │   ├── MathUtils.lua
│   │   └── TableUtils.lua
│   └── data/
│       ├── ClassData.lua      # Class definitions, base stats
│       ├── EnemyData.lua      # Enemy stat tables
│       ├── ItemData.lua       # Item/equipment definitions
│       ├── AbilityData.lua    # Ability definitions and costs
│       └── LevelData.lua      # Deck loader references
├── levels/
│   ├── deck1.lua
│   ├── deck2.lua
│   ├── deck3.lua
│   ├── deck4.lua
│   └── deck5.lua
├── assets/
│   ├── images/
│   ├── sounds/
│   ├── music/
│   ├── fonts/
│   └── shaders/
└── lib/
    ├── lume.lua
    ├── anim8.lua
    └── flux.lua
```

### 8.4 Raycaster Implementation Notes
- The first-person view is rendered using a **software column-based raycaster**:
  - For each screen column (0 to viewportWidth-1), cast a ray from the party position.
  - Determine wall hit distance → compute column height → draw textured vertical strip.
  - Draw floor and ceiling as solid/textured fills (floor casting optional).
- Rendered to a `love.graphics.Canvas` each frame for performance isolation.
- Texture lookup: `love.graphics.draw` with clipping quads per column (or pixel-push if needed).
- Likely needs `love.graphics.setPixel`-equivalent or a pixel buffer (ImageData) for
  high-quality column rendering — prototype both approaches.

### 8.5 Performance Targets
- Target: 60 FPS at 1280 × 720
- Raycaster render budget: ≤ 6 ms per frame (tune column resolution)
- Combat/UI: Event-driven (no per-frame heavy computation)
- Memory: < 128 MB

### 8.6 Save System
- Format: Lua table serialised to string (via `love.filesystem.write`)
- Save location: `love.filesystem.getSaveDirectory()` → `scifi-dungeon/`
- Saves at: Safe Room terminals, between deck transitions
- Data saved: Party state (HP/EP/XP/equipment), dungeon map explored state,
  inventory, current deck + position, game flags

---

## 9. Development Milestones

### Phase 1: Technical Prototype (Weeks 1–2)
- [x] Working raycaster in Love2D with placeholder textures
- [x] Grid movement + collision in one test room
- [x] Basic HUD panel layout (no art)
- [x] Minimap rendering (16 × 16 test map)
- [x] Single character stat sheet

### Phase 2: Core Systems (Weeks 3–5)
- [x] Full DungeonMap loading from Lua level file
- [x] Turn-based combat system (2 classes, 2 enemy types)
- [x] Party management and inventory screen
- [x] Scene manager + Menu + Dungeon scenes functional
- [x] Basic audio (footsteps, door, one music track)
- [x] Save / Load system

### Phase 3: Content Expansion (Weeks 6–9)
- [ ] All 5 classes implemented with abilities
- [ ] Deck 1 and Deck 2 hand-crafted and playable
- [ ] 8+ enemy types with AI behaviours
- [ ] Full item/equipment system
- [ ] Level-up and skill tree UI
- [ ] Character creation screen

### Phase 4: Full Game Content (Weeks 10–14)
- [ ] Decks 3–5 complete
- [ ] All boss fights implemented
- [ ] Full audio pass (all music + SFX)
- [ ] Final pixel-art assets (textures, portraits, enemy sprites)
- [ ] Shaders: scanline, bloom, distortion
- [ ] Codex / lore system

### Phase 5: Polish & Release (Weeks 15–16)
- [ ] Bug fixing pass
- [ ] Performance profiling and optimisation
- [ ] Difficulty balancing pass
- [ ] Final playtesting
- [ ] README and build instructions

---

## 10. Additional Notes

### 10.1 Known Challenges
1. **Raycaster in Lua/Love2D** — Pure-Lua pixel manipulation is slow. May need to use
   a fragment shader approach for the column renderer to hit 60 FPS.
2. **First-person sprite rendering** — Enemy sprites in the viewport require depth-sorting
   and scaling based on distance; this is the classic sprite-casting extension to raycasting.
3. **Turn-based combat UX** — Balancing combat speed vs. tactical depth without becoming
   tedious; target < 3 min per regular encounter.
4. **Permadeath + party management** — Need to handle the case where key-class characters die
   (e.g., only Medic can resurrect); may need a backup system.

### 10.2 Future Features / Post-Launch
- Procedurally generated bonus deck ("The Abyss") for endless replayability
- Character import/export for shared community challenges
- Modding support via external level files
- Expanded codex with animated lore videos (Love2D video module)
- Keyboard + gamepad remapping

### 10.3 References & Inspiration
| Reference | What It Inspires |
|-----------|-----------------|
| Wizardry 6/7/8 | Party-based blobber structure, class design |
| Eye of the Beholder | First-person grid feel, real-time roots adapted to turn-based |
| Dungeon Master | Puzzle-heavy exploration, resource tension |
| Legend of Grimrock | Modern blobber aesthetics, grid purity |
| System Shock 1 | Sci-fi dungeon tone, terminal/lore logs |
| Dead Space | Atmospheric horror + sci-fi visual design |
| Shenzhen I/O | UI terminal aesthetic inspiration |

---

## Appendices

### Appendix A: Glossary
- **Arcadia** — The fallen mega-city in which the game takes place. Built as a utopia in 2197;
  collapsed in 2238 following The Collapse.
- **Blobber** — A first-person dungeon crawler where the whole party moves as one unit on a grid.
- **The Collapse** — The engineered fall of Arcadia's governance infrastructure in 2238,
  orchestrated by OmniCorp to prevent the Consciousness Archive from being made public.
- **Component** — A crafting/modding resource obtained by salvaging items or looting containers.
  Used in Workbench recipes and as mod inserts.
- **Consciousness Archive** — A data vault containing the uploaded minds of Arcadia's founders,
  created by ACCORD as insurance against factional betrayal. The game's central MacGuffin.
- **Contract** — An optional side-objective issued by a faction contact. Rewards components,
  items, or reputation points. Expires at the end of the current district.
- **District** — One of five underground zones that make up the dungeon. Each has a unique
  theme, faction presence, enemy types, and loot pool.
- **EP** — Energy Points; resource that powers class abilities. Regenerates at 10% per round.
- **Fixer** — The player's squad designation; freelance operative who takes jobs for pay.
- **Mod** — A component inserted into an item's mod slot to grant a permanent stat bonus or
  special property. Cannot be removed without destroying it.
- **Permadeath (per character)** — When a character dies without resurrection, they are
  permanently removed from the squad roster. Game Over only triggers if the full squad is wiped.
- **Prototype** — The highest rarity tier (gold). Boss-only drops or crafted via advanced recipes.
- **Raycaster** — A 2.5D rendering technique simulating 3D corridors from a 2D grid map.
- **Reputation** — A per-faction score (−100 to +100) tracking the squad's relationship with
  each of Arcadia's five factions. Gates vendor access, contracts, and safe houses.
- **Safe Room** — A designated grid cell type; enemies cannot enter. Contains save terminal,
  Medstation, and faction contacts. Workbench available in Districts 3+.
- **Salvage** — The act of breaking down an item at a Workbench into component parts. Item is
  consumed; yields 1–3 component units depending on item rarity.
- **Status Effect** — A temporary combat modifier (Corrode, Stun, Blind, Override, Burn).
- **The Consensus** — The final boss; an amalgamation of the uploaded architect minds within
  the Consciousness Archive, now hostile and self-preserving.

### Appendix B: Asset Credits
*(To be filled in as third-party assets are sourced.)*

### Appendix C: Version History
| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 0.1 | 2026-02-20 | Initial DRAFT — full concept pass (space station / alien setting) | Game Designer |
| 0.2 | 2026-02-20 | Setting overhaul: cyberpunk dystopian city (Arcadia); faction system; looter/crafting focus; full Section 4 game flow rewrite | Game Designer |
