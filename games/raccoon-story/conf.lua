-- Raccoon Story - Love2D Configuration
-- Controls window settings, modules, and game info

function love.conf(t)
  -- Game identity
  t.identity = "raccoon-story"                -- Save folder name
  t.version = "11.4"                          -- Love2D version
  t.console = false                           -- Disable console on Windows
  
  -- Window settings
  t.window.title = "Raccoon Story"
  t.window.icon = nil                         -- Set to image path later
  t.window.width = 1280
  t.window.height = 720
  t.window.borderless = false
  t.window.resizable = true
  t.window.minwidth = 800
  t.window.minheight = 600
  t.window.fullscreen = false
  t.window.fullscreentype = "desktop"
  t.window.vsync = 1                          -- Enable VSync for smooth rendering
  t.window.msaa = 0                           -- No multisampling (pixel art)
  t.window.depth = nil
  t.window.stencil = nil
  t.window.display = 1
  t.window.highdpi = false
  t.window.usedpiscale = true
  t.window.x = nil
  t.window.y = nil
  
  -- Modules
  t.modules.audio = true                      -- Enable audio module
  t.modules.data = true                       -- Enable data module
  t.modules.event = true                      -- Enable event module
  t.modules.font = true                       -- Enable font module
  t.modules.graphics = true                   -- Enable graphics module
  t.modules.image = true                      -- Enable image module
  t.modules.joystick = true                   -- Enable joystick module
  t.modules.keyboard = true                   -- Enable keyboard module
  t.modules.math = true                       -- Enable math module
  t.modules.mouse = true                      -- Enable mouse module
  t.modules.physics = false                   -- Disable physics (not needed for top-down)
  t.modules.sound = true                      -- Enable sound module
  t.modules.system = true                     -- Enable system module
  t.modules.thread = true                     -- Enable thread module
  t.modules.timer = true                      -- Enable timer module
  t.modules.touch = true                      -- Enable touch module (for mobile support)
  t.modules.video = false                     -- Disable video module
  t.modules.window = true                     -- Enable window module
  
  -- Additional settings
  t.accelerometerjoystick = false             -- Disable accelerometer on mobile
  t.externalstorage = false                   -- Use internal storage
  t.gammacorrect = false                      -- Disable gamma correction for pixel art
  
  -- Audio settings
  t.audio.mixwithsystem = true                -- Mix with system audio on mobile
end
