# Sprite Generation System

## Overview
The Raccoon Story game uses **programmatic sprite generation** instead of external image files. Sprites are drawn using Love2D's graphics functions to canvases at runtime, creating a cozy, hand-drawn 2D art style with soft edges and warm colors.

## Architecture

### SpriteGenerator (`src/utils/SpriteGenerator.lua`)
The core utility that generates all game sprites programmatically. Each sprite is drawn to a Love2D canvas, which acts as a reusable texture.

**Key Features:**
- All sprites drawn procedurally using Love2D graphics primitives
- Pixel-perfect rendering with smooth edges
- Animation frames generated for dynamic sprites
- No external image files required

### Assets Integration (`src/utils/assets.lua`)
The Asset Manager has been extended to generate and store sprites:

```lua
-- Generate all sprites on initialization
Assets:generateSprites()

-- Access sprites by category
local idleFrames = Assets:getPlayerSprite("idle")
local pizzaSprite = Assets:getTrashSprite("pizza")
local humanSprite = Assets:getEnemySprite("human")
local bushSprite = Assets:getEnvironmentSprite("bush")
```

## Generated Sprites

### Player Raccoon (32x32)
- **Idle Animation**: 4 frames with gentle breathing motion
  - Gray body with lighter belly
  - Black mask with white eyes
  - Striped tail
  - Pink nose and inner ears
  - Slight bobbing animation
  
- **Walk Animation**: 6 frames with walking cycle
  - Alternating leg movement
  - Tail sway
  - Arm swing
  - Vertical bob
  - Can be flipped for all 4 directions

### Trash Items (16x16)
All items have their distinctive appearance:

- **Pizza Slice**: Yellow-orange triangle with pepperoni and cheese
- **Burger**: Layered with bun, lettuce, patty, cheese, and sesame seeds
- **Donut Box**: Pink box with visible donut through window, sprinkles
- **Trash Bag**: Dark gray lumpy bag with tie at top

### Enemies
- **Human** (32x48): Simple person with arms, legs, angry expression
- **Dog** (32x32): Brown dog with tail, floppy ears, and collar

### Environment
- **Bush** (48x48): Fluffy green bush made of overlapping circles (hiding spot)
- **Trash Bin** (32x48): Gray metal bin with lid and corrugation

## Usage in Entities

### Player Entity
```lua
-- In GameScene:enter()
local playerIdleFrames = Assets:getPlayerSprite("idle")
local playerWalkFrames = Assets:getPlayerSprite("walk")
self.player:setSprites(playerIdleFrames, playerWalkFrames)

-- In Player:draw()
local frames = self.sprites[self.currentAnimation]
local sprite = frames[self.animationFrame + 1]
love.graphics.draw(sprite, self.x, self.y, ...)
```

### Trash Items
```lua
-- In GameScene:spawnTrash()
local trashItem = TrashItem:new(x, y, trashType)
local sprite = Assets:getTrashSprite(trashType)
trashItem:setSprite(sprite)

-- In TrashItem:draw()
if self.sprite then
  love.graphics.draw(self.sprite, self.x, self.y)
end
```

## Art Style Guidelines

### Colors
- **Player**: Gray (0.6, 0.6, 0.6) with lighter belly (0.8, 0.8, 0.8)
- **Mask**: Dark (0.2, 0.2, 0.2)
- **Trash Items**: Match GDD color specifications
- **Environment**: Natural greens (0.2-0.6 range), warm browns

### Design Principles
1. **Soft Edges**: Use rounded rectangles and circles
2. **Hand-Drawn Feel**: Overlapping shapes create organic appearance
3. **Warm Colors**: Cozy palette matches game theme
4. **Clear Silhouettes**: Easy to identify at a glance
5. **Pixel-Perfect**: 32x32 and 16x16 base sizes for crisp rendering

## Performance

### Optimization
- Sprites generated **once** at game load
- Stored as canvases (GPU textures)
- No file I/O overhead
- Reusable across multiple instances
- Efficient memory usage

### Memory Footprint
Approximate size per sprite type:
- Player animations: ~20KB (10 frames × 32x32)
- Trash items: ~4KB (4 sprites × 16x16)
- Enemies: ~6KB
- Environment: ~8KB

**Total**: ~38KB for all sprites

## Extending the System

### Adding New Sprites

1. **Create Generator Function** in `SpriteGenerator.lua`:
```lua
function SpriteGenerator.generateNewSprite()
  local canvas = createCanvas(width, height)
  drawToCanvas(canvas, function()
    -- Your drawing code here
    love.graphics.setColor(r, g, b)
    love.graphics.circle("fill", x, y, radius)
  end)
  return canvas
end
```

2. **Add to generateAll()** function:
```lua
sprites.newCategory = {
  newType = SpriteGenerator.generateNewSprite()
}
```

3. **Add Accessor** in `assets.lua`:
```lua
function Assets:getNewSprite(type)
  return self.sprites.newCategory and self.sprites.newCategory[type]
end
```

4. **Use in Entity**:
```lua
entity:setSprite(Assets:getNewSprite("type"))
```

## Debugging

### Visual Debugging
- Entities fall back to colored rectangles if sprites fail to load
- Console logs confirm sprite generation and loading
- Check for warnings like "Warning: Player sprites not loaded"

### Common Issues
1. **Canvas errors**: Ensure window is initialized before generating sprites
2. **Missing sprites**: Check console for generation errors
3. **Wrong colors**: Verify color values are in 0-1 range (not 0-255)
4. **Blurry sprites**: Ensure `love.graphics.setDefaultFilter("nearest", "nearest")` is set

## Future Enhancements

### Planned Features
- [ ] Color variations for enemies
- [ ] Seasonal sprite themes
- [ ] Alternate raccoon skins
- [ ] Weather effects on sprites
- [ ] Day/night sprite variations
- [ ] Boss sprites
- [ ] More environment objects

### Advanced Techniques
- Procedural texture patterns
- Shader effects for glow/shimmer
- Particle system integration
- Dynamic sprite composition
- Palette swapping for variations

## References

- GDD Section 6.3: Asset List
- GDD Section 5: Art Style & Visual Design
- Love2D Canvas API: https://love2d.org/wiki/Canvas
- Love2D Graphics API: https://love2d.org/wiki/love.graphics

---

**The sprite generation system provides a solid foundation for the game's visual identity while maintaining flexibility for future enhancements.**
