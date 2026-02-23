-- Scifi Dungeon — conf.lua
-- Love2D configuration. Runs before love.load().

function love.conf(t)
  -- ─── Identity ──────────────────────────────────────────────────────────────
  t.identity    = "scifi-dungeon"      -- save directory name
  t.version     = "11.4"               -- minimum Love2D version required
  t.console     = false                -- attach console window (Windows only)

  -- ─── Window ────────────────────────────────────────────────────────────────
  t.window.title          = "Scifi Dungeon (DRAFT)"
  t.window.icon           = nil                 -- set to "assets/images/icon.png" when ready
  t.window.width          = 1280
  t.window.height         = 720
  t.window.borderless     = false
  t.window.resizable      = false
  t.window.minwidth       = 1280
  t.window.minheight      = 720
  t.window.fullscreen     = false
  t.window.fullscreentype = "desktop"
  t.window.vsync          = 1                   -- enable vsync (60 Hz target)
  t.window.msaa           = 0                   -- no MSAA (pixel art, not needed)
  t.window.depth          = nil
  t.window.stencil        = nil
  t.window.display        = 1
  t.window.highdpi        = false
  t.window.usedpiscale    = false
  t.window.x              = nil                 -- centered
  t.window.y              = nil

  -- ─── Modules ───────────────────────────────────────────────────────────────
  t.modules.audio    = true
  t.modules.data     = true
  t.modules.event    = true
  t.modules.font     = true
  t.modules.graphics = true
  t.modules.image    = true
  t.modules.joystick = false      -- no gamepad support yet
  t.modules.keyboard = true
  t.modules.math     = true
  t.modules.mouse    = true
  t.modules.physics  = false      -- not using Love2D physics engine
  t.modules.sound    = true
  t.modules.system   = true
  t.modules.thread   = false
  t.modules.timer    = true
  t.modules.touch    = false
  t.modules.video    = false
  t.modules.window   = true
end
