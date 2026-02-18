# Hiding and Stealth Mechanics - Implementation Summary

**Game:** Raccoon Story  
**Implementation Date:** February 17, 2026  
**GDD Reference:** Section 3.2 (Controls), Section 3.3 (Safe Zones)

## Overview

Implemented a complete hiding and stealth system that allows the player to hide in bushes and become invisible to enemies while maintaining balanced gameplay through restrictions and visual feedback.

## Features Implemented

### 1. Player Hiding State (`Player.lua`)

#### **New Properties:**
- `isHiding` - Boolean indicating if player is currently hiding
- `currentHidingSpot` - Reference to the bush object player is hiding in
- `hidingGracePeriod` - Timer for grace period after exiting hiding (0.5 seconds)

#### **New Functions:**

**`hide(hidingSpot)`**
- Enters hiding state when near a valid bush
- Stores reference to hiding spot
- Stops player movement (vx, vy = 0)
- Returns true on success

**`exitHide()`**
- Exits hiding state
- Clears hiding spot reference
- Activates 0.5 second grace period to prevent immediate re-detection
- Returns true on success

#### **Behavior Changes:**
- **Movement:** Completely disabled while hiding (no WASD input processed)
- **Dash:** Cannot dash while hiding
- **Visual:** Player rendered at 30% opacity (alpha = 0.3) when hiding
- **State Persistence:** Hiding state persists until player manually exits

---

### 2. Bush Detection & Hiding Input (`GameScene.lua`)

#### **Bush Detection System:**

**`updateNearbyBushes()`**
- Called every frame during game update
- Scans all environment objects with `canHide = true` and `type = "bush"`
- Calculates distance from player center to bush center
- Adds bushes within **50 pixels** to `nearbyBushes` table

#### **E Key Handling:**

**When NOT hiding:**
1. Check if `nearbyBushes` has any entries
2. Find the closest bush to player
3. Call `player:hide(closestBush)`
4. Display message: "Hiding... (Press E to exit)"
5. If no bushes nearby: Display "No hiding spot nearby"

**When hiding:**
1. Call `player:exitHide()`
2. Display message: "Left hiding spot"
3. Start grace period timer

---

### 3. Visual Feedback (`GameScene:drawHidingFeedback()`)

#### **When NOT Hiding:**
- **Green outline** around all nearby bushes (within 50 pixels)
  - Color: `(0.4, 0.9, 0.4)` with 60% alpha
  - 2-pixel line width
- **"E" prompt** appears above each nearby bush
  - White text, 90% alpha
  - Positioned 20 pixels above bush center

#### **When Hiding:**
- **Status panel** floats above player's head
  - Background: Black with 70% opacity, rounded corners
  - Text: "Hiding... (Press E to exit)"
  - **Pulsing effect:** Alpha oscillates using `sin(time * 3)`
  - Color: Light green `(0.4, 0.9, 0.4)`

---

### 4. Enemy Detection Modifications

#### **Human.lua - `checkDetection(player, dt)`**
Added two early-return checks:

```lua
-- Skip detection if player is hiding
if player.isHiding then
  self.detectionTimer = 0
  return false
end

-- Skip detection during grace period
if player.hidingGracePeriod and player.hidingGracePeriod > 0 then
  self.detectionTimer = 0
  return false
end
```

#### **Dog.lua - `checkDetection(player, dt)`**
Same implementation as Human for consistency.

**Result:**
- Hidden player is **completely invisible** to both Humans and Dogs
- Grace period prevents instant detection after exiting
- Detection timer is reset when player is protected (hiding or grace period)

---

### 5. Chase Interruption System

#### **Chase State Tracking:**

**`updateChaseState(dt)` - GameScene.lua**

1. **Check if player is being chased:**
   - Iterate through all Humans and Dogs
   - Set `isPlayerBeingChased = true` if any enemy has `state = "chase"`

2. **Player enters hiding while being chased:**
   - Start `chaseEndTimer = 1.0` second countdown
   - Print debug message

3. **Chase end timer reaches zero:**
   - Call `stopChase()` on all enemies in chase state
   - Enemies return to patrol route
   - Display message: **"You're safe... for now"**
   - Timer duration: 3 seconds

4. **Timer cancellation:**
   - Resets if player exits hiding before enemies lose sight
   - Resets if chase naturally ends

---

## Gameplay Balance

### **Hiding Restrictions:**
- **No movement** - Player is locked in place
- **No dash** - Cannot use dash ability
- **Manual exit only** - Must press E to exit (no auto-exit)
- **Proximity required** - Must be within 50 pixels of a bush

### **Stealth Advantages:**
- **Complete invisibility** - Enemies cannot detect at all
- **Chase interruption** - Enemies lose sight after 1 second
- **Grace period** - 0.5 seconds of protection after exiting
- **Visual feedback** - Clear UI showing when hiding is available

### **Risk vs Reward:**
- **Risk:** Immobilized, cannot collect trash or flee
- **Reward:** Safety from all threats, ability to break chase

---

## GDD Compliance

✅ **Section 3.2 - Controls:**
- E key successfully triggers hiding mechanic
- Works as intended: player must be near bush

✅ **Section 3.3 - Safe Zones:**
- Bushes provide safety as specified
- "Bushes, shadows, and hidden passages provide safety" ✓

✅ **Section 3.3 - Threat Behavior:**
- "After escaping, threats return to patrol routes" ✓
- Enemies return to patrol after losing sight

---

## Technical Implementation Details

### **Files Modified:**
1. `/src/entities/Player.lua` - Hiding state and controls
2. `/src/scenes/GameScene.lua` - Bush detection, input handling, visual feedback
3. `/src/entities/Human.lua` - Detection skip for hiding
4. `/src/entities/Dog.lua` - Detection skip for hiding

### **Integration Points:**
- Animation system: Player continues idle animation while hiding
- UI system: Messages displayed via existing message system
- AI system: Works with existing patrol/chase state machine

### **Performance Considerations:**
- Bush detection runs every frame but uses simple distance checks
- Visual feedback only draws for nearby bushes (not all)
- No heavy computations or allocations

---

## Testing Checklist

✅ Player can hide in bushes within 50 pixels  
✅ Player cannot hide without nearby bush  
✅ Player becomes semi-transparent when hiding  
✅ Player cannot move while hiding  
✅ Player cannot dash while hiding  
✅ E key exits hiding  
✅ Nearby bushes show green outline  
✅ "E" prompt appears on nearby bushes  
✅ Hiding status text appears above player  
✅ Enemies cannot detect hidden player  
✅ Grace period prevents immediate detection  
✅ Chase is interrupted after 1 second in hiding  
✅ Enemies return to patrol after losing sight  
✅ Message displays: "You're safe... for now"

---

## Future Enhancements (Optional)

**Not implemented (out of scope for current task):**
- Hiding animation (rustle effect)
- Hiding sound effects (bush rustle entering/exiting)
- Different hiding spot types (shadows, passages)
- Progressive detection (enemies "almost see you" warnings)
- Stamina cost for hiding (balance mechanic)
- Multiple players in same hiding spot

---

## Code Examples

### Entering Hiding
```lua
-- In GameScene:keypressed(key)
if key == "e" and not self.player.isHiding then
  if #self.nearbyBushes > 0 then
    local closestBush = findClosestBush()
    if self.player:hide(closestBush) then
      displayMessage("Hiding...")
    end
  end
end
```

### Enemy Detection Skip
```lua
-- In Human:checkDetection(player, dt)
if player.isHiding then
  self.detectionTimer = 0
  return false
end
```

### Visual Feedback
```lua
-- In GameScene:drawHidingFeedback()
for _, bush in ipairs(self.nearbyBushes) do
  love.graphics.rectangle("line", bush.x - 2, bush.y - 2, bush.width + 4, bush.height + 4)
end
```

---

## Summary

The hiding and stealth mechanics are **fully functional** and **GDD-compliant**. The implementation provides:

- **Clear player agency** - Manual control via E key
- **Balanced gameplay** - Restrictions offset safety benefits
- **Quality feedback** - Visual indicators for availability and status
- **Seamless integration** - Works with existing systems (AI, UI, animation)
- **Satisfying feel** - Tension of hiding, relief of escaping chasers

**Status:** ✅ Complete and ready for playtesting
