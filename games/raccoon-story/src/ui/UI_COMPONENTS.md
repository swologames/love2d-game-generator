# UI Components

This folder contains reusable UI components for Raccoon Story.

## Components

### Button.lua
Interactive button component with hover/click effects and controller support.

**Features:**
- Hover scaling (1.1x on hover)
- Press feedback (0.95x on press)
- Focus indicator for controller navigation
- Customizable colors following GDD palette
- Smooth animations with easing
- Sound effect support

**Usage:**
```lua
local Button = require("src.ui.Button")

local myButton = Button:new(x, y, width, height, "Click Me", function()
  print("Button clicked!")
end)

-- In update
myButton:update(dt)

-- In draw
myButton:draw()

-- Handle input
myButton:mousepressed(x, y, button)
myButton:mousereleased(x, y, button)

-- Controller support
myButton:setFocused(true)
myButton:activate() -- Call when controller button pressed
```

### Slider.lua
Volume/settings slider with drag and keyboard/controller support.

**Features:**
- Visual value indicator (percentage)
- Smooth handle animation
- Focus indicator for controller
- Adjustable via mouse drag, keyboard, or controller
- Real-time value callback

**Usage:**
```lua
local Slider = require("src.ui.Slider")

local volumeSlider = Slider:new(x, y, width, height, 0, 1, 0.5, function(value)
  -- Called when value changes
  love.audio.setVolume(value)
end)

-- Controller adjustment
volumeSlider:adjustValue(1)  -- Increase by 5%
volumeSlider:adjustValue(-1) -- Decrease by 5%
```

### Panel.lua
Rounded panel background for UI sections.

**Features:**
- Three styles: "solid", "translucent", "outlined"
- Rounded corners
- Drop shadows
- GDD color scheme

**Usage:**
```lua
local Panel = require("src.ui.Panel")

local panel = Panel:new(x, y, width, height, "translucent")
panel:draw()
```

### Icon.lua
HUD icon renderer with built-in icon library and animations.

**Built-in Icons:**
- `heart` - Health/lives
- `moon` - Night timer
- `alert` - Warning/danger
- `trash` - Collectible items
- `star` - Points/collectibles
- `dash` - Speed ability
- `home` - Den/safe zone
- `paw` - Animal/character marker

**Features:**
- Pulse animation
- Rotation animation
- Customizable colors
- Easy positioning

**Usage:**
```lua
local Icon = require("src.ui.Icon")

local moonIcon = Icon:new("moon", x, y, 30, {1, 1, 1, 1})
moonIcon:setPulse(true, 2, 0.2) -- Enable pulsing
moonIcon:update(dt)
moonIcon:draw()
```

### PauseMenu.lua
Pause menu overlay for the game.

**Features:**
- Semi-transparent dark overlay
- Resume, Settings, Restart Night, Quit buttons
- Controller and keyboard navigation
- Pauses game state when active

**Usage:**
```lua
local PauseMenu = require("src.ui.PauseMenu")

local pauseMenu = PauseMenu:new()
pauseMenu.onResume = function() -- handle resume end
pauseMenu.onQuitToMenu = function() -- return to main menu end

-- Toggle pause
pauseMenu:toggle()

-- Update and draw
if pauseMenu:isActive() then
  pauseMenu:update(dt)
  pauseMenu:draw()
end
```

### SettingsMenu.lua
Settings menu with volume sliders and options.

**Features:**
- Master, Music, SFX volume sliders
- Fullscreen toggle
- Test sound button
- Settings persistence (saved to love.filesystem)
- Controller support

**Usage:**
```lua
local SettingsMenu = require("src.ui.SettingsMenu")

local settings = SettingsMenu:new()
settings.onBack = function() -- handle back button end

settings:show()
settings:update(dt)
settings:draw()
```

## Design Guidelines

All UI components follow the GDD Section 5 specifications:

**Colors (from GDD Section 6.2):**
- Primary: Warm brown (#8B4513)
- Secondary: Cream (#F5DEB3)
- Accent: Soft green (#90EE90)
- Background: Deep blue-purple night (#1A1A2E)

**Typography:**
- Use rounded sans-serif fonts
- Clear hierarchy and readability

**Animations:**
- Smooth ease-in-out transitions
- Hover scale: 1.1x
- Press scale: 0.95x
- Duration: ~0.2s

**Controller Support:**
- All interactive elements support focus indicators
- D-pad/stick for navigation
- A button for activation
- B/Start button for back/cancel
