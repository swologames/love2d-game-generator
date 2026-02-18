# External Libraries

This folder is for third-party Lua libraries.

## Potential Libraries

Consider these Love2D libraries as the project grows:

- **bump.lua** - Simple collision detection
  - https://github.com/kikito/bump.lua
  - Great for AABB collision in top-down games

- **hump** - Helper Utilities for Massive Progression
  - https://github.com/vrld/hump
  - Includes camera, gamestate, timer, vector utilities

- **anim8** - Sprite animation library
  - https://github.com/kikito/anim8
  - Simplifies sprite sheet animations

- **flux** - Tweening library
  - https://github.com/rxi/flux
  - For smooth value interpolation

- **lume** - Lua utility functions
  - https://github.com/rxi/lume
  - Collection of helpful functions

## Installation

1. Download the library
2. Place it in this folder
3. Require in your code:
   ```lua
   local bump = require("lib.bump")
   ```

## License Compliance

Ensure all libraries are compatible with your project's license and properly attributed.
