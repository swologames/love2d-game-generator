-- src/systems/combat/CombatLog.lua
-- Combat event logging

local CombatLog = {}
CombatLog.__index = CombatLog

-- ─── Factory ────────────────────────────────────────────────────────────────

function CombatLog:new()
  local instance = setmetatable({}, CombatLog)
  instance.entries = {}
  return instance
end

-- ─── Logging ────────────────────────────────────────────────────────────────

function CombatLog:add(message)
  table.insert(self.entries, message)
end

function CombatLog:getAll()
  return self.entries
end

function CombatLog:getRecent(count)
  count = count or 5
  local startIdx = math.max(1, #self.entries - count + 1)
  local recent = {}
  for i = startIdx, #self.entries do
    table.insert(recent, self.entries[i])
  end
  return recent
end

function CombatLog:clear()
  self.entries = {}
end

return CombatLog
