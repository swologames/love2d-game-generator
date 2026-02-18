# Raccoon Story — Componentization Refactor TODO

All files must stay under **150 lines** (200 for top-level scene orchestrators).  
Pattern: thin orchestrator `require`s sub-modules; sub-modules are plain function tables.

---

## ✅ Completed

| File | Result |
|------|--------|
| `src/entities/Player.lua` | Orchestrator (~123 lines) + `player/Movement.lua`, `player/DashAbility.lua`, `player/HidingAbility.lua`, `player/Inventory.lua`, `player/AnimationSetup.lua` |
| `src/entities/Human.lua` | Orchestrator (~113 lines) + `enemy/Patrol.lua`, `enemy/Detection.lua`, `enemy/Chase.lua`, `enemy/DirectionUtils.lua` |
| `src/entities/Dog.lua` | Orchestrator (~134 lines), shares `enemy/` sub-modules above |
| `src/entities/Animal.lua` | Orchestrator (~97 lines) + `animal/TypeStats.lua`, `animal/Wander.lua`, `animal/Flee.lua`, `animal/DirectionUtils.lua` |
| `src/systems/ParticleSystem.lua` | Orchestrator (~129 lines) + `particles/Emitter.lua`, `particles/TrashSparkle.lua`, `particles/DashDust.lua`, `particles/FootstepPuff.lua`, `particles/DetectionAlert.lua`, `particles/CollectionBurst.lua` |
| `src/systems/ScreenEffects.lua` | Orchestrator (~114 lines) + `effects/ShakeEffect.lua`, `effects/VignetteEffect.lua` |
| `src/scenes/GameScene.lua` | Orchestrator (265 lines — acceptable) + `game/Spawner.lua`, `game/EnvironmentSpawner.lua`, `game/EnvironmentRenderer.lua`, `game/HidingFeedback.lua`, `game/ChaseManager.lua`, `game/CollisionHandler.lua`, `game/CameraSystem.lua`, `game/ParticleEffects.lua` |
| `src/utils/SpriteGenerator.lua` | Orchestrator (74 lines ✅) + `sprites/PlayerSprites.lua`, `sprites/TrashSprites.lua`, `sprites/EnemySprites.lua`, `sprites/EnvironmentSprites.lua` |

---

## ❌ Remaining — Oversized Files

### High Priority (very large)

#### `src/utils/sprites/EnemySprites.lua` — 470 lines
> Sub-module created by SpriteGenerator split but still too large.  
Split into:
- `sprites/enemy/HumanSprites.lua` — `generateHuman`, `generateHumanWalk`
- `sprites/enemy/DogSprites.lua` — `generateDog`, `generateDogRun`
- `sprites/enemy/AnimalSprites.lua` — `generatePossum`, `generateCat`, `generateCrow`
- Update `EnemySprites.lua` to be a thin re-exporter (~30 lines)

#### `src/utils/sprites/EnvironmentSprites.lua` — 418 lines
> Still too large after split.  
Split into:
- `sprites/env/VegetationSprites.lua` — `generateBush`, `generateTree`, `generateGrassPatch`
- `sprites/env/StructureSprites.lua` — `generateHouse`, `generateFence`
- `sprites/env/PropSprites.lua` — `generateTrashBin`, `generateStreetLamp`
- Update `EnvironmentSprites.lua` to be a thin re-exporter (~30 lines)

#### `src/ui/SettingsMenu.lua` — 424 lines
Split into:
- `src/ui/settings/SettingsLayout.lua` — `new()`, `show()`, `hide()`, `isActive()`, `draw()` (~120 lines)
- `src/ui/settings/SettingsData.lua` — `loadSettings()`, `saveSettings()`, `applyVolume()`, `toggleFullscreen()`, `getFullscreenText()`, `testSound()`, `apply()`, `back()` (~100 lines)
- `src/ui/settings/SettingsInput.lua` — `update()`, `mousepressed()`, `mousereleased()`, `keypressed()`, `gamepadpressed()`, `moveFocus()` (~120 lines)
- Update `SettingsMenu.lua` to orchestrator requiring the above (~40 lines)

#### `src/scenes/MenuScene.lua` — 399 lines
Split into:
- `src/scenes/menu/MenuLayout.lua` — `enter()`, `exit()`, button construction (~100 lines)
- `src/scenes/menu/MenuAnimations.lua` — animated raccoon, stars, idle animation logic from `update()` and `draw()` (~100 lines)
- `src/scenes/menu/MenuCredits.lua` — `showCredits()`, `hideCredits()`, credits render logic (~60 lines)
- `src/scenes/menu/MenuInput.lua` — `keypressed()`, `gamepadpressed()`, `moveFocus()`, `mousepressed()`, `mousereleased()` (~100 lines)
- Update `MenuScene.lua` to orchestrator (~60 lines)

#### `src/utils/sprites/PlayerSprites.lua` — 271 lines
Split into:
- `sprites/player/IdleSprites.lua` — `generatePlayerIdle()`
- `sprites/player/WalkSprites.lua` — `generatePlayerWalk()`
- `sprites/player/DashSprites.lua` — `generatePlayerDash()`
- Update `PlayerSprites.lua` to thin re-exporter (~20 lines)

---

### Medium Priority

#### `src/scenes/game/HUD.lua` — 236 lines  
Split into:
- `game/hud/Minimap.lua` — `drawMinimap(scene)` function
- `game/hud/HUDInventory.lua` — inventory slot drawing logic
- Update `HUD.lua` to orchestrator + remaining status/score/timer drawing (~100 lines)

#### `src/ui/PauseMenu.lua` — 257 lines
Split into:
- `src/ui/pause/PauseLayout.lua` — `new()`, `draw()`, button setup
- `src/ui/pause/PauseInput.lua` — `keypressed()`, `gamepadpressed()`, `moveFocus()`, `mousepressed()`, `mousereleased()`
- Update `PauseMenu.lua` to orchestrator (~60 lines)

#### `src/systems/AISystem.lua` — 257 lines
Split into:
- `src/systems/ai/ThreatQuery.lua` — `isAnyoneChasing()`, `getActiveThreatCount()`, `getNearestThreat()`, `getCounts()`, `getAllEnemies()`, `getTotalCount()` (~80 lines)
- `src/systems/ai/AIDebug.lua` — `drawDebug()` (~50 lines)
- Update `AISystem.lua` to orchestrator + `update()`, `draw()`, `addHuman/Dog/Animal()`, `clear()` (~120 lines)

#### `src/ui/Icon.lua` — 250 lines
Split into:
- `src/ui/icons/IconLibrary.lua` — the `iconLibrary` data table (lines 8–147, pure data)
- Update `Icon.lua` to require `IconLibrary` + class methods only (~105 lines)

#### `src/utils/InputManager.lua` — 202 lines
Split into:
- `src/utils/input/GamepadMapping.lua` — `getControllerType()`, `getButtonPrompt()`, joystick detection logic (~60 lines)
- Update `InputManager.lua` to require `GamepadMapping` + all other methods (~140 lines)

---

### Lower Priority (close to limit, split if convenient)

#### `src/ui/Button.lua` — 187 lines
Consider extracting `draw()` into `src/ui/button/ButtonRenderer.lua` (~60 lines). Acceptable to leave if content is cohesive.

#### `src/systems/AnimationSystem.lua` — 180 lines
Cohesive single-responsibility file. Consider extracting `draw()` + frame calculation into `src/systems/animation/FramePlayer.lua`. May be acceptable as-is.

#### `src/utils/assets.lua` — 177 lines
Split into:
- `src/utils/assets/SpriteAccess.lua` — `getSprite()`, `getPlayerSprite()`, `getTrashSprite()`, `getEnemySprite()`, `getEnvironmentSprite()` (~50 lines)
- Update `assets.lua` to require `SpriteAccess` + loading/playback methods (~125 lines)

#### `src/utils/sprites/TrashSprites.lua` — 168 lines
Slightly over. Consider splitting `generateDonutBox` and `generateTrashBag` into a second file if further reduction is needed.

#### `src/ui/Slider.lua` — 173 lines
Consider extracting `draw()` into `src/ui/slider/SliderRenderer.lua` (~60 lines).

---

## Key Architecture Notes

- **Require path convention**: `require("src.systems.ai.ThreatQuery")` (dots, not slashes)
- **Sub-module pattern**: Functions receive `self` as first arg (e.g., `ThreatQuery.isAnyoneChasing(self)`)
- **Orchestrator calls sub-module**: `function AISystem:isAnyoneChasing() return ThreatQuery.isAnyoneChasing(self) end`
- **Data files**: Pure data tables (no functions) live in dedicated files with no line limit
- **`create_file` cannot overwrite**: Use `replace_string_in_file` to replace entire body of existing files
- **ScreenEffects API**: `setVignetteDanger(level)` — NOT `setVignette()`
- **Game root**: `/Users/diegopinate/Documents/Love2DAI/games/raccoon-story/`

## How to Resume

1. Run `find src -name "*.lua" | xargs wc -l | sort -rn | awk '$1 > 150'` to see current state
2. Start with `EnemySprites.lua` (470 lines) and `EnvironmentSprites.lua` (418 lines) — they already have the correct helpers at the top
3. Work down the priority list
4. After each batch, run `love .` from the game root to verify no regressions
