-- deck1.lua
-- Sample level for District 1: The Sprawl
-- A small test level demonstrating various cell types

-- Cell type constants (matching DungeonMap.CELL_TYPES)
local CELL = {
  FLOOR = 0,
  WALL = 1,
  WALL_DAMAGED = 2,
  DOOR = 3,
  DOOR_LOCKED = 4,
  TERMINAL = 5,
  STAIRS_DOWN = 6,
  STAIRS_UP = 7,
  HAZARD = 8,
  SECRET = 9
}

local F = CELL.FLOOR           -- Walkable floor
local W = CELL.WALL            -- Standard wall
local D = CELL.DOOR            -- Unlocked door
local L = CELL.DOOR_LOCKED     -- Locked door (requires key)
local T = CELL.TERMINAL        -- Interactive terminal
local U = CELL.STAIRS_UP       -- Stairs up (exit back)
local N = CELL.STAIRS_DOWN     -- Stairs down (progress forward)
local H = CELL.HAZARD          -- Hazard tile (causes damage)
local S = CELL.SECRET          -- Secret wall (hidden passage)

-- Level data structure
return {
  -- Metadata
  name = "Sprawl Entrance",
  district = "The Sprawl",
  difficulty = 1,
  description = "The upper entrance to the ruined streets. Gang territory begins here.",
  
  -- Grid layout (20x20)
  -- Array indexed [y][x], where [1][1] is top-left corner
  grid = {
    -- Row 1
    {W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W},
    -- Row 2
    {W, U, F, F, W, F, F, F, W, F, F, F, W, F, F, F, F, F, F, W},
    -- Row 3
    {W, F, F, F, W, F, W, F, W, F, W, F, W, F, W, W, W, D, W, W},
    -- Row 4
    {W, F, W, F, W, F, W, F, D, F, W, F, D, F, F, F, F, F, F, W},
    -- Row 5
    {W, F, W, F, F, F, W, F, W, F, W, F, W, W, W, F, W, W, F, W},
    -- Row 6
    {W, F, W, W, W, W, W, F, W, F, W, F, F, F, F, F, F, W, F, W},
    -- Row 7
    {W, F, F, F, F, F, F, F, W, F, W, W, W, W, W, W, F, W, F, W},
    -- Row 8
    {W, W, W, D, W, W, W, F, W, F, F, F, F, F, F, F, F, W, F, W},
    -- Row 9
    {W, T, F, F, F, F, W, F, W, W, W, D, W, W, W, W, W, W, F, W},
    -- Row 10
    {W, F, F, W, W, F, W, F, F, F, F, F, F, F, F, F, F, F, F, W},
    -- Row 11
    {W, F, F, W, W, F, D, F, W, W, W, W, W, F, W, W, W, W, W, W},
    -- Row 12
    {W, W, F, W, W, F, W, F, W, F, F, F, F, F, F, F, F, F, H, W},
    -- Row 13
    {W, F, F, F, F, F, W, F, L, F, W, W, W, W, W, W, W, F, H, W},
    -- Row 14
    {W, F, W, W, W, W, W, F, W, F, W, S, F, F, T, F, W, F, H, W},
    -- Row 15
    {W, F, F, F, F, F, F, F, W, F, W, F, F, W, W, F, W, F, F, W},
    -- Row 16
    {W, W, W, D, W, W, W, F, W, F, W, F, F, F, F, F, W, W, F, W},
    -- Row 17
    {W, F, F, F, F, F, W, F, W, F, W, W, W, W, W, F, F, F, F, W},
    -- Row 18
    {W, F, W, W, W, F, W, F, F, F, F, F, F, F, W, F, W, W, F, W},
    -- Row 19
    {W, F, F, F, F, F, F, F, W, W, W, W, W, F, W, F, F, N, F, W},
    -- Row 20
    {W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W, W}
  },
  
  -- Optional: Spawn points for player start
  playerStart = {
    x = 2,  -- Column 2
    y = 2,  -- Row 2 (where U/stairs_up is)
    facing = "south" -- Initial direction (N/S/E/W)
  },
  
  -- Optional: Enemy spawn zones (for Phase 3)
  enemySpawns = {
    {x = 10, y = 10, type = "thug", count = 2},
    {x = 15, y = 14, type = "drone", count = 1}
  },
  
  -- Optional: Loot locations (for Phase 3)
  loot = {
    {x = 9, y = 2, item = "medpack"},
    {x = 18, y = 19, item = "keycard_red"}
  },
  
  -- Design notes
  notes = [[
    This is a starter level for testing the DungeonMap system.
    
    Features:
    - Main corridor from stairs_up (2,2) to stairs_down (18,19)
    - Multiple branching paths and rooms
    - Locked door at (9,13) - requires keycard
    - Secret wall at (12,14) - reveals hidden passage when scanned
    - Two terminals at (2,9) and (15,14) for interaction tests
    - Hazard zone in bottom-right (19,12-14) - radiation or plasma vent
    - Several doors (D) for basic navigation
    
    Player should start at stairs_up and navigate to stairs_down.
  ]]
}
