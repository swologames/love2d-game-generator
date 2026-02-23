-- src/scenes/MenuScene.lua
-- Main menu scene with Phase 2 save/load integration

local SceneManager = require("src.scenes.SceneManager")
local SaveSystem = require("src.systems.SaveSystem")
local AudioSystem = require("src.systems.AudioSystem")

local MenuScene = {}
MenuScene.__index = MenuScene

-- ─── Constants ───────────────────────────────────────────────────────────────

local W, H = 1280, 720

local TITLE_TEXT    = "ARCADIA FALLEN"
local SUBTITLE_TEXT = "[PHASE 2 BUILD]"
local major, minor, revision = love.getVersion()
local BUILD_TEXT    = string.format("v0.2.0-phase2 | Love2D %d.%d.%d", major, minor, revision)

local COLOR_BG      = { 0.039, 0.055, 0.078, 1 }   -- #0a0e14
local COLOR_TITLE   = { 0.000, 0.749, 1.000, 1 }   -- #00bfff
local COLOR_SUB     = { 0.878, 0.910, 0.941, 0.8 } -- #e0e8f0 dimmed
local COLOR_BUILD   = { 0.353, 0.420, 0.494, 1 }   -- muted grey
local COLOR_TEXT    = { 0.878, 0.910, 0.941, 1 }
local COLOR_SELECTED = { 0.000, 0.749, 1.000, 1 }
local COLOR_DISABLED = { 0.5, 0.5, 0.5, 0.5 }

-- Menu options
local MENU_OPTIONS = {
  {id = "continue", label = "Continue Game", enabled = false},
  {id = "new_game", label = "New Game", enabled = true},
  {id = "quit", label = "Quit", enabled = true}
}

-- Pulse animation state
local _pulse = 0

-- ─── Factory ─────────────────────────────────────────────────────────────────

function MenuScene:new()
  local instance = setmetatable({}, MenuScene)
  instance.selectedIndex = 1
  instance.hasSave = false
  return instance
end

-- ─── Lifecycle ───────────────────────────────────────────────────────────────

function MenuScene:load()
  _pulse = 0
  
  -- Initialize systems
  SaveSystem:init()
  AudioSystem:init()
  
  -- Check for existing save
  self.hasSave = SaveSystem:exists(1)
  MENU_OPTIONS[1].enabled = self.hasSave
  
  -- Start menu music
  AudioSystem:playMusic("menu_theme", 1.0)
  
  print("[MenuScene] Loaded - Save file:", self.hasSave and "Found" or "Not found")
end

function MenuScene:enter()
  -- Refresh save check on enter
  self.hasSave = SaveSystem:exists(1)
  MENU_OPTIONS[1].enabled = self.hasSave
  
  -- Reset selection to first enabled option
  self.selectedIndex = self.hasSave and 1 or 2
  
  -- Ensure menu music is playing
  AudioSystem:playMusic("menu_theme", 1.0)
end

function MenuScene:exit()
  -- Nothing to clean up yet
end

-- ─── Update ──────────────────────────────────────────────────────────────────

function MenuScene:update(dt)
  _pulse = _pulse + dt * 2.0
end

-- ─── Draw ────────────────────────────────────────────────────────────────────

function MenuScene:draw()
  -- Background
  love.graphics.setColor(COLOR_BG)
  love.graphics.rectangle("fill", 0, 0, W, H)

  -- Star-field placeholder
  love.graphics.setColor(1, 1, 1, 0.15)
  math.randomseed(42)
  for _ = 1, 200 do
    local sx = math.random(0, W)
    local sy = math.random(0, H)
    love.graphics.rectangle("fill", sx, sy, 1, 1)
  end

  -- Title
  love.graphics.setFont(love.graphics.newFont(64))
  love.graphics.setColor(COLOR_TITLE)
  local tw = love.graphics.getFont():getWidth(TITLE_TEXT)
  love.graphics.print(TITLE_TEXT, math.floor((W - tw) / 2), 180)

  -- Pulsing subtitle
  local alpha = 0.5 + 0.5 * math.sin(_pulse)
  love.graphics.setFont(love.graphics.newFont(16))
  love.graphics.setColor(COLOR_SUB[1], COLOR_SUB[2], COLOR_SUB[3], alpha)
  local sw = love.graphics.getFont():getWidth(SUBTITLE_TEXT)
  love.graphics.print(SUBTITLE_TEXT, math.floor((W - sw) / 2), 270)
  
  -- Menu options
  love.graphics.setFont(love.graphics.newFont(24))
  local startY = 360
  local spacing = 50
  
  for i, option in ipairs(MENU_OPTIONS) do
    local y = startY + (i - 1) * spacing
    local label = option.label
    local textWidth = love.graphics.getFont():getWidth(label)
    local x = math.floor((W - textWidth) / 2)
    
    -- Selection indicator
    if i == self.selectedIndex and option.enabled then
      love.graphics.setColor(COLOR_SELECTED)
      love.graphics.print("> " .. label .. " <", x - 30, y)
    else
      if option.enabled then
        love.graphics.setColor(COLOR_TEXT)
      else
        love.graphics.setColor(COLOR_DISABLED)
      end
      love.graphics.print(label, x, y)
    end
  end

  -- Build version (bottom-right)
  love.graphics.setFont(love.graphics.newFont(12))
  love.graphics.setColor(COLOR_BUILD)
  love.graphics.print(BUILD_TEXT, W - 300, H - 24)
  
  -- Controls hint
  love.graphics.setColor(COLOR_SUB[1], COLOR_SUB[2], COLOR_SUB[3], 0.6)
  love.graphics.print("↑↓ Select | Enter Continue | ESC Quit", 10, H - 24)

  -- Reset color
  love.graphics.setColor(1, 1, 1, 1)
end

-- ─── Input ───────────────────────────────────────────────────────────────────

function MenuScene:keypressed(key)
  if key == "escape" then
    love.event.quit()
    return
  end
  
  -- Navigation
  if key == "up" then
    repeat
      self.selectedIndex = self.selectedIndex - 1
      if self.selectedIndex < 1 then
        self.selectedIndex = #MENU_OPTIONS
      end
    until MENU_OPTIONS[self.selectedIndex].enabled
    
  elseif key == "down" then
    repeat
      self.selectedIndex = self.selectedIndex + 1
      if self.selectedIndex > #MENU_OPTIONS then
        self.selectedIndex = 1
      end
    until MENU_OPTIONS[self.selectedIndex].enabled
    
  elseif key == "return" or key == "space" then
    self:selectOption(MENU_OPTIONS[self.selectedIndex].id)
  end
end

function MenuScene:selectOption(optionId)
  if optionId == "continue" then
    self:continueGame()
  elseif optionId == "new_game" then
    self:newGame()
  elseif optionId == "quit" then
    love.event.quit()
  end
end

function MenuScene:continueGame()
  print("[MenuScene] Loading saved game...")
  
  local saveData = SaveSystem:load(1)
  if not saveData then
    print("[MenuScene] ERROR: Failed to load save")
    return
  end
  
  -- Cross fade to dungeon music
  AudioSystem:playMusic("d1_sprawl", 1.5)
  
  -- Switch to dungeon with loaded state
  SceneManager:switch("dungeon", saveData)
end

function MenuScene:newGame()
  print("[MenuScene] Starting new game...")
  
  -- Crossfade to dungeon music
  AudioSystem:playMusic("d1_sprawl", 1.5)
  
  -- Switch to dungeon (will create new game state)
  SceneManager:switch("dungeon")
end

function MenuScene:mousepressed(x, y, button)
  -- TODO Phase 3: Mouse interaction
end

return MenuScene
