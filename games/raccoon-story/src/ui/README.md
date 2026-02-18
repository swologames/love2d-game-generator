# UI Components

Reusable user interface widgets and components.

## Component Pattern

UI components should be self-contained and reusable:

```lua
local Component = {}
Component.__index = Component

function Component:new(x, y, width, height)
  local instance = setmetatable({}, self)
  -- Initialize
  return instance
end

function Component:update(dt)
  -- Update logic (hover, animation, etc.)
end

function Component:draw()
  -- Render component
end

function Component:onClick()
  -- Handle click event
end

return Component
```

## Components

- `Button.lua` - Interactive button widget
- `HUD.lua` - Heads-up display overlay
- `Menu.lua` - Menu framework
- `InventoryDisplay.lua` - Shows carried items
- `ProgressBar.lua` - Generic progress bar
- `Minimap.lua` - Small map display
