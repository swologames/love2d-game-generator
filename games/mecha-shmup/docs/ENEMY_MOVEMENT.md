# Enemy Movement System

## Overview
The enemy movement system uses a **multi-phase architecture** where each enemy transitions through distinct movement phases, creating more dynamic and interesting behavior patterns.

## Phase System

### Three-Phase Structure

Every enemy follows this progression:

1. **Intro Phase** - Controlled entrance onto the screen
2. **Main Phase** - Primary attack/movement pattern
3. **Exit Phase** - Departure behavior

### Phase Transitions

Phases can transition based on:
- **Time** - After a specific duration
- **Position** - When reaching a certain Y coordinate
- **Event** - Manual trigger or game state

## Movement Patterns

### Sine Wave (Default)
**Used by:** Scout, Interceptor, Bomber

```lua
phases = {
  intro = {duration = 0.8, behavior = "descend", speed = 0.8},
  main = {duration = nil, behavior = "sine"},  -- Indefinite
  exit = {trigger = "offscreen"}
}
```

- **Intro**: Straight descent at 80% speed
- **Main**: Classic horizontal sine wave (50px amplitude)
- **Exit**: Continues until offscreen

### Zigzag (Hunter)
**Used by:** Hunter

```lua
phases = {
  intro = {duration = 1.0, behavior = "descend", speed = 0.7},
  main = {duration = nil, behavior = "zigzag"},
  exit = {trigger = "offscreen"}
}
```

- **Intro**: Slow controlled descent (70% speed)
- **Main**: Sharp lateral movements with direction changes at edges
- **Exit**: Continues pattern offscreen

**Behavior**: Moves horizontally at 150px/s, reverses direction at screen edges or every 0.5 seconds

### Circular (Configurable)
**Used by:** Can be assigned to any enemy type

```lua
phases = {
  intro = {duration = 0.8, behavior = "descend", speed = 0.6},
  main = {duration = 8.0, behavior = "circular"},
  exit = {duration = 1.5, behavior = "accelerate_down"}
}
```

- **Intro**: Gentle descent at 60% speed
- **Main**: Expanding spiral pattern for 8 seconds
- **Exit**: Accelerates downward with increasing speed

**Behavior**: Spiral with radius expanding from 60px to 180px over 8 seconds

### Dive Attack (Configurable)
**Used by:** Can be assigned for aggressive patterns

```lua
phases = {
  intro = {duration = 1.5, behavior = "sine_descent"},
  main = {trigger = "position", y = 200, behavior = "dive_attack"},
  exit = {trigger = "offscreen"}
}
```

- **Intro**: Descend with gentle sine wave for 1.5 seconds
- **Main**: Triggered when Y > 200, locks onto and charges player at 150% speed
- **Exit**: Continues dive until offscreen

### Hover (Sniper)
**Used by:** Sniper

```lua
phases = {
  intro = {duration = 1.2, behavior = "descend"},
  main = {duration = 8.0, behavior = "hover_drift"},
  exit = {duration = 2.0, behavior = "strafe_exit"}
}
```

- **Intro**: Descend to hover position
- **Main**: Stay at Y position with gentle horizontal drift (80px) and vertical oscillation (15px)
- **Exit**: Strafe to nearest screen edge while descending

### Strafe (Artillery)
**Used by:** Artillery

```lua
phases = {
  intro = {duration = 1.0, behavior = "side_entrance"},
  main = {duration = 6.0, behavior = "strafe"},
  exit = {duration = 1.5, behavior = "accelerate_down"}
}
```

- **Intro**: Enter from side with curved motion (60px curve)
- **Main**: Horizontal cosine wave (100px amplitude) with slow descent for 6 seconds
- **Exit**: Accelerate downward

### Rush (Kamikaze)
**Used by:** Kamikaze

```lua
phases = {
  intro = {duration = 0.5, behavior = "descend", speed = 0.5},
  main = {duration = nil, behavior = "rush"},
  exit = {trigger = "offscreen"}
}
```

- **Intro**: Brief slow descent (50% speed) for 0.5 seconds
- **Main**: Constant pursuit of player position
- **Exit**: Continues until collision or offscreen

## Phase Behaviors Reference

### Intro Behaviors

#### `descend`
Simple straight downward movement
- Uses `speed` modifier from phase config
- Maintains initial X position

#### `sine_descent`
Descend with horizontal sine wave
- 40px amplitude
- Frequency: 2 cycles per second

#### `side_entrance`
Enter from side with curved motion
- Creates smooth curve based on entrance progress
- 60px curve amplitude

### Main Behaviors

#### `sine`
Classic horizontal sine wave
- 50px amplitude
- Frequency: 2 cycles per second
- Constant downward progress at enemy speed

#### `zigzag`
Sharp lateral directional changes
- 150px/s horizontal speed
- Reverses at X < 50 or X > 590
- Also reverses every 0.5 seconds

#### `circular`
Expanding spiral pattern
- Initial radius: 60px
- Expansion rate: 15-20px per second
- 3 rotations per second
- Center follows initial X position

#### `dive_attack`
Lock onto player and charge
- Calculates vector to player each frame
- Moves at 150% of enemy base speed
- Continuously updates target position

#### `strafe`
Horizontal oscillation with slow descent
- 100px amplitude horizontal motion
- Frequency: 2.5 cycles per second
- 50% vertical speed

#### `hover_drift`
Hover at position with gentle movement
- Descends to hover target (Y + 100)
- 80px horizontal drift (sine wave at 0.8 Hz)
- 15px vertical oscillation (sine wave at 1.2 Hz)

#### `rush`
Direct pursuit of player
- Recalculates direction each frame
- Moves at full enemy speed
- No easing or acceleration

### Exit Behaviors

#### `offscreen`
Continue current movement until leaving play area
- No special behavior
- Enemy removed when Y > 750 or off sides

#### `accelerate_down`
Speed up vertically
- Starts at 150% speed
- Multiplier increases: 1.5 + (time * 2)
- Creates quick exit effect

#### `strafe_exit`
Move to side while descending
- 120% vertical speed
- Determines exit side based on position (< 320 goes left, >= 320 goes right)
- 80px/s horizontal movement

## Customization

### Adding New Phase Patterns

To create a custom multi-phase pattern:

1. Add to `initMovementPhases()` in Enemy.lua:

```lua
elseif self.movementPattern == "my_pattern" then
  self.phases = {
    intro = {duration = 1.0, behavior = "descend"},
    main = {duration = 5.0, behavior = "my_behavior"},
    exit = {duration = 2.0, behavior = "accelerate_down"}
  }
end
```

2. Implement behavior in `executePhaseMovement()`:

```lua
elseif behavior == "my_behavior" then
  -- Your movement code here
  self.y = self.y + self.speed * dt
  self.x = self.initialX + math.cos(self.phaseTimer) * 75
end
```

### Phase Configuration Options

**duration** (number or nil)
- Duration in seconds
- `nil` = indefinite (until offscreen)

**behavior** (string)
- Name of movement behavior function

**speed** (number, 0.0 - 2.0)
- Speed modifier for intro phase only
- Default: 1.0

**trigger** (string)
- "position": Transition at specific Y coordinate
- "offscreen": Transition when enemy leaves screen
- "time": Use duration instead

**y** (number)
- Y coordinate for position-based triggers

## State Management

### Phase Tracking Variables

- `movementPhase` - Current phase ("intro", "main", "exit")
- `phaseTimer` - Time spent in current phase
- `phaseData` - Phase-specific data storage (reset on transition)

### Transition Logic

```lua
-- Check in Enemy:update()
self:checkPhaseTransition()

-- Transitions handled by:
-- 1. Time-based: phaseTimer >= duration
-- 2. Position-based: self.y >= trigger.y
-- 3. Manual: Set self.movementPhase = "exit"
```

## Design Guidelines

### Timing Recommendations

- **Intro**: 0.5 - 1.5 seconds (setup positioning)
- **Main**: 4 - 10 seconds (primary attack window)
- **Exit**: 1 - 2 seconds (quick departure)

### Pattern Complexity

**Simple enemies** (scouts, kamikazes):
- Short intro (0.5s)
- Simple main pattern
- Offscreen exit

**Elite enemies** (artillery, snipers):
- Controlled intro (1-1.5s)
- Complex main pattern (6-8s)
- Dramatic exit (accelerate or strafe)

### Phase Balance

- Main phase should be where enemy is most dangerous
- Intro gives player time to react
- Exit provides satisfying conclusion (not just continuing offscreen)

## Examples

### Aggressive Pattern
```lua
phases = {
  intro = {duration = 0.3, behavior = "descend", speed = 1.2},  -- Quick entry
  main = {duration = 4.0, behavior = "dive_attack"},            -- Short, intense
  exit = {trigger = "offscreen"}                                 -- Crash through
}
```

### Defensive Pattern
```lua
phases = {
  intro = {duration = 1.5, behavior = "sine_descent"},          -- Cautious approach
  main = {duration = 10.0, behavior = "hover_drift"},           -- Long stay
  exit = {duration = 2.5, behavior = "strafe_exit"}             -- Tactical retreat
}
```

### Sneaky Pattern
```lua
phases = {
  intro = {duration = 2.0, behavior = "circular"},              -- Confusing entry
  main = {duration = 6.0, behavior = "zigzag"},                 -- Erratic movement
  exit = {duration = 1.0, behavior = "accelerate_down"}         -- Quick escape
}
```

This multi-phase system creates much more dynamic and memorable enemy encounters!
