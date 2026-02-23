-- src/scenes/SceneManager.lua
-- Central scene lifecycle manager.
-- Scenes must implement: load(), update(dt), draw(),
--   keypressed(key, sc, rep), keyreleased(key, sc),
--   mousepressed(x,y,btn,t,p), mousereleased(x,y,btn,t,p),
--   mousemoved(x,y,dx,dy,t), wheelmoved(x,y),
--   resize(w,h), focus(f), enter(data), exit()

local SceneManager = {
  _current = nil,
  _scenes  = {},
  _next    = nil,   -- queued transition
  _stack   = {},    -- scene stack for overlays
  _overlay = nil,   -- current overlay scene (for Combat, Inventory, etc.)
}

-- ─── Registration ────────────────────────────────────────────────────────────

--- Register a scene factory.
--- @param name string   Unique scene identifier
--- @param mod  table    Scene module (must have a :new() factory)
function SceneManager:register(name, mod)
  self._scenes[name] = mod
end

-- ─── Initialisation ──────────────────────────────────────────────────────────

function SceneManager:init()
  -- Lazy-require scenes to avoid circular dependencies at module load time
  local MenuScene = require("src.scenes.MenuScene")
  self:register("menu", MenuScene)
  
  local DungeonScene = require("src.scenes.DungeonScene")
  self:register("dungeon", DungeonScene)
  
  local CombatScreen = require("src.scenes.CombatScreen")
  self:register("combat", CombatScreen)
  
  local InventoryScreen = require("src.scenes.InventoryScreen")
  self:register("inventory", InventoryScreen)
end

-- ─── Transition ──────────────────────────────────────────────────────────────

--- Switch to a named scene immediately.
--- @param name string  Registered scene name
--- @param data table   Optional data passed to scene:enter(data)
function SceneManager:switch(name, data)
  assert(self._scenes[name], "SceneManager: unknown scene '" .. tostring(name) .. "'")

  if self._current and self._current.exit then
    self._current:exit()
  end

  local SceneMod = self._scenes[name]
  local instance = SceneMod:new()
  if instance.load then instance:load() end
  if instance.enter then instance:enter(data) end
  self._current = instance
  
  -- Clear overlay and stack when switching main scenes
  self._overlay = nil
  self._stack = {}
end

--- Push an overlay scene (for Combat, Inventory, etc.)
--- The base scene continues to draw but doesn't update
--- @param name string  Registered scene name
--- @param ... any      Arguments passed to scene:enter(...)
function SceneManager:pushOverlay(name, ...)
  assert(self._scenes[name], "SceneManager: unknown scene '" .. tostring(name) .. "'")
  
  -- Store current overlay if exists
  if self._overlay then
    table.insert(self._stack, self._overlay)
  end
  
  -- Create and enter new overlay
  local SceneMod = self._scenes[name]
  local instance = SceneMod:new()
  if instance.load then instance:load() end
  if instance.enter then instance:enter(...) end
  self._overlay = instance
  
  print("[SceneManager] Pushed overlay:", name)
end

--- Pop the current overlay scene
function SceneManager:popOverlay()
  if not self._overlay then
    return
  end
  
  if self._overlay.exit then
    self._overlay:exit()
  end
  
  -- Restore previous overlay from stack or clear
  if #self._stack > 0 then
    self._overlay = table.remove(self._stack)
  else
    self._overlay = nil
  end
  
  print("[SceneManager] Popped overlay")
end

--- Check if an overlay is active
function SceneManager:hasOverlay()
  return self._overlay ~= nil
end

-- ─── Forwarding ──────────────────────────────────────────────────────────────

function SceneManager:update(dt)
  -- Update overlay if active, otherwise update base scene
  if self._overlay and self._overlay.update then
    self._overlay:update(dt)
  elseif self._current and self._current.update then
    self._current:update(dt)
  end
end

function SceneManager:draw()
  -- Always draw base scene
  if self._current and self._current.draw then
    self._current:draw()
  end
  
  -- Draw overlay on top if active
  if self._overlay and self._overlay.draw then
    self._overlay:draw()
  end
end

function SceneManager:keypressed(k, s, r)
  -- Input goes to overlay if active, otherwise to base scene
  if self._overlay and self._overlay.keypressed then
    local handled = self._overlay:keypressed(k, s, r)
    -- If overlay doesn't handle it, check if it wants to close
    if not handled and not self._overlay.active then
      self:popOverlay()
    end
  elseif self._current and self._current.keypressed then
    self._current:keypressed(k, s, r)
  end
end

function SceneManager:keyreleased(k, s)
  if self._overlay and self._overlay.keyreleased then
    self._overlay:keyreleased(k, s)
  elseif self._current and self._current.keyreleased then
    self._current:keyreleased(k, s)
  end
end

function SceneManager:mousepressed(x, y, b, t, p)
  if self._overlay and self._overlay.mousepressed then
    self._overlay:mousepressed(x, y, b, t, p)
  elseif self._current and self._current.mousepressed then
    self._current:mousepressed(x, y, b, t, p)
  end
end

function SceneManager:mousereleased(x, y, b, t, p)
  if self._overlay and self._overlay.mousereleased then
    self._overlay:mousereleased(x, y, b, t, p)
  elseif self._current and self._current.mousereleased then
    self._current:mousereleased(x, y, b, t, p)
  end
end

function SceneManager:mousemoved(x, y, dx, dy, t)
  if self._overlay and self._overlay.mousemoved then
    self._overlay:mousemoved(x, y, dx, dy, t)
  elseif self._current and self._current.mousemoved then
    self._current:mousemoved(x, y, dx, dy, t)
  end
end

function SceneManager:wheelmoved(x, y)
  if self._overlay and self._overlay.wheelmoved then
    self._overlay:wheelmoved(x, y)
  elseif self._current and self._current.wheelmoved then
    self._current:wheelmoved(x, y)
  end
end

function SceneManager:resize(w, h)
  if self._current and self._current.resize then
    self._current:resize(w, h)
  end
  if self._overlay and self._overlay.resize then
    self._overlay:resize(w, h)
  end
end

function SceneManager:focus(f)
  if self._current and self._current.focus then
    self._current:focus(f)
  end
  if self._overlay and self._overlay.focus then
    self._overlay:focus(f)
  end
end

return SceneManager
