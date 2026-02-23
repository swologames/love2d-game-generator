-- src/ui/HUD.lua
-- Heads-Up Display for dungeon exploration
-- Phase 1: Basic layout with placeholder components

local HUD = {}
HUD.__index = HUD

-- ─── Constants ───────────────────────────────────────────────────────────────

-- Screen dimensions
local SCREEN_WIDTH = 1280
local SCREEN_HEIGHT = 720

-- Raycaster viewport (left side)
local VIEWPORT_WIDTH = 768
local VIEWPORT_HEIGHT = 576
local VIEWPORT_X = 0
local VIEWPORT_Y = (SCREEN_HEIGHT - VIEWPORT_HEIGHT) / 2

-- HUD panel (right side)
local HUD_PANEL_X = VIEWPORT_WIDTH
local HUD_PANEL_WIDTH = SCREEN_WIDTH - VIEWPORT_WIDTH
local HUD_PANEL_HEIGHT = SCREEN_HEIGHT

-- Colors (from GDD color scheme)
local COLOR_BACKGROUND = {0.039, 0.055, 0.078, 1}      -- #0a0e14
local COLOR_PANEL_BG = {0.078, 0.109, 0.149, 0.9}      -- #141c26
local COLOR_ACCENT = {0.000, 0.749, 1.000, 1}          -- #00bfff (cyan)
local COLOR_TEXT = {0.878, 0.910, 0.941, 1}            -- #e0e8f0
local COLOR_TEXT_DIM = {0.5, 0.5, 0.5, 1}
local COLOR_WARNING = {1.000, 0.800, 0.000, 1}         -- #ffcc00
local COLOR_DANGER = {1.000, 0.235, 0.235, 1}          -- #ff3c3c
local COLOR_SAFE = {0.224, 1.000, 0.078, 1}            -- #39ff14

-- Component dimensions
local COMPASS_HEIGHT = 40
local MINIMAP_SIZE = 64
local PARTY_CARD_HEIGHT = 100
local MESSAGE_LOG_HEIGHT = 60

-- ─── Factory ─────────────────────────────────────────────────────────────────

function HUD:new()
  local instance = setmetatable({}, HUD)
  
  -- Title/location
  instance.locationText = "THE SPRAWL - SECTOR 1"
  instance.depthLevel = 1
  
  -- Compass/direction
  instance.playerDirection = 0 -- 0=N, 90=E, 180=S, 270=W
  
  -- Minimap placeholder
  instance.minimapVisible = true
  
  -- Party stats placeholders (4 members)
  instance.partyMembers = {
    {name = "Marine", hp = 80, maxHp = 100, ep = 20, maxEp = 40, status = {}},
    {name = "Hacker", hp = 45, maxHp = 60, ep = 35, maxEp = 50, status = {}},
    {name = "Medic", hp = 50, maxHp = 70, ep = 40, maxEp = 60, status = {}},
    {name = "Psion", hp = 35, maxHp = 50, ep = 45, maxEp = 70, status = {}}
  }
  instance.selectedMember = 1
  
  -- Message log
  instance.messages = {
    {text = "System initialized.", color = COLOR_ACCENT},
    {text = "Welcome to Arcadia Fallen.", color = COLOR_TEXT},
    {text = "Entering The Sprawl...", color = COLOR_WARNING}
  }
  instance.maxMessages = 5
  
  -- Fonts (use default for now, can be customized later)
  instance.fontSmall = love.graphics.newFont(10)
  instance.fontNormal = love.graphics.newFont(12)
  instance.fontLarge = love.graphics.newFont(16)
  
  return instance
end

-- ─── Public Methods ──────────────────────────────────────────────────────────

function HUD:update(dt)
  -- Placeholder for future animation updates (scrolling text, etc.)
end

function HUD:draw()
  -- Draw main HUD panel background
  love.graphics.setColor(COLOR_PANEL_BG)
  love.graphics.rectangle("fill", HUD_PANEL_X, 0, HUD_PANEL_WIDTH, HUD_PANEL_HEIGHT)
  
  -- Draw HUD border
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle("line", HUD_PANEL_X, 0, HUD_PANEL_WIDTH, HUD_PANEL_HEIGHT)
  
  local yOffset = 10
  
  -- Draw location header
  yOffset = self:drawLocationHeader(yOffset)
  
  -- Draw compass/direction indicator
  yOffset = self:drawCompass(yOffset)
  
  -- Draw minimap placeholder
  yOffset = self:drawMinimap(yOffset)
  
  -- Draw party status cards
  yOffset = self:drawPartyStatus(yOffset)
  
  -- Draw message log at bottom
  self:drawMessageLog()
end

function HUD:setPlayerStats(stats)
  -- Update player-related stats
  if stats.direction then
    self.playerDirection = stats.direction
  end
  if stats.location then
    self.locationText = stats.location
  end
  if stats.depth then
    self.depthLevel = stats.depth
  end
end

function HUD:updatePartyMember(index, stats)
  if index >= 1 and index <= 4 then
    for key, value in pairs(stats) do
      self.partyMembers[index][key] = value
    end
  end
end

function HUD:addMessage(text, color)
  table.insert(self.messages, {text = text, color = color or COLOR_TEXT})
  if #self.messages > self.maxMessages then
    table.remove(self.messages, 1)
  end
end

-- ─── Drawing Components ──────────────────────────────────────────────────────

function HUD:drawLocationHeader(yOffset)
  local x = HUD_PANEL_X + 10
  local y = yOffset
  
  -- Location title
  love.graphics.setFont(self.fontLarge)
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.print(self.locationText, x, y)
  
  y = y + 20
  
  -- Depth indicator
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.printf(string.format("DEPTH LEVEL: %d", self.depthLevel), 
    x, y, HUD_PANEL_WIDTH - 20, "left")
  
  -- Divider line
  y = y + 20
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.setLineWidth(1)
  love.graphics.line(x, y, HUD_PANEL_X + HUD_PANEL_WIDTH - 10, y)
  
  return y + 10
end

function HUD:drawCompass(yOffset)
  local x = HUD_PANEL_X + 10
  local y = yOffset
  local width = HUD_PANEL_WIDTH - 20
  
  -- Compass label
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.print("DIRECTION", x, y)
  
  y = y + 15
  
  -- Compass background
  love.graphics.setColor(COLOR_BACKGROUND)
  love.graphics.rectangle("fill", x, y, width, COMPASS_HEIGHT)
  
  -- Compass border
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", x, y, width, COMPASS_HEIGHT)
  
  -- Direction indicators
  local directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"}
  local spacing = width / 8
  
  love.graphics.setFont(self.fontNormal)
  for i, dir in ipairs(directions) do
    local dirX = x + (i - 1) * spacing + spacing / 2
    local dirY = y + COMPASS_HEIGHT / 2 - 6
    
    -- Highlight current direction (simplified for now)
    if i == 1 then -- North highlighted by default
      love.graphics.setColor(COLOR_WARNING)
    else
      love.graphics.setColor(COLOR_TEXT_DIM)
    end
    
    love.graphics.printf(dir, dirX - 20, dirY, 40, "center")
  end
  
  return y + COMPASS_HEIGHT + 10
end

function HUD:drawMinimap(yOffset)
  local x = HUD_PANEL_X + 10
  local y = yOffset
  
  -- Minimap label
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.print("MINIMAP", x, y)
  
  y = y + 15
  
  -- Center the minimap in the panel
  local minimapX = HUD_PANEL_X + (HUD_PANEL_WIDTH - MINIMAP_SIZE) / 2
  
  -- Minimap background
  love.graphics.setColor(COLOR_BACKGROUND)
  love.graphics.rectangle("fill", minimapX, y, MINIMAP_SIZE, MINIMAP_SIZE)
  
  -- Minimap border
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", minimapX, y, MINIMAP_SIZE, MINIMAP_SIZE)
  
  -- Placeholder grid
  love.graphics.setColor(COLOR_TEXT_DIM)
  local gridSize = 8
  for i = 1, gridSize do
    for j = 1, gridSize do
      local cellX = minimapX + (i - 1) * (MINIMAP_SIZE / gridSize)
      local cellY = y + (j - 1) * (MINIMAP_SIZE / gridSize)
      love.graphics.rectangle("line", cellX, cellY, 
        MINIMAP_SIZE / gridSize, MINIMAP_SIZE / gridSize)
    end
  end
  
  -- Player position marker (center)
  love.graphics.setColor(COLOR_WARNING)
  love.graphics.circle("fill", minimapX + MINIMAP_SIZE / 2, y + MINIMAP_SIZE / 2, 3)
  
  return y + MINIMAP_SIZE + 10
end

function HUD:drawPartyStatus(yOffset)
  local x = HUD_PANEL_X + 10
  local y = yOffset
  local cardWidth = HUD_PANEL_WIDTH - 20
  
  -- Party status label
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.print("PARTY STATUS", x, y)
  
  y = y + 15
  
  -- Draw each party member card
  for i, member in ipairs(self.partyMembers) do
    y = self:drawPartyCard(x, y, cardWidth, member, i == self.selectedMember)
    y = y + 5 -- Spacing between cards
  end
  
  return y
end

function HUD:drawPartyCard(x, y, width, member, selected)
  -- Card background
  if selected then
    love.graphics.setColor(COLOR_ACCENT[1] * 0.3, COLOR_ACCENT[2] * 0.3, 
      COLOR_ACCENT[3] * 0.3, 0.5)
  else
    love.graphics.setColor(COLOR_BACKGROUND)
  end
  love.graphics.rectangle("fill", x, y, width, PARTY_CARD_HEIGHT)
  
  -- Card border
  if selected then
    love.graphics.setColor(COLOR_ACCENT)
    love.graphics.setLineWidth(2)
  else
    love.graphics.setColor(COLOR_TEXT_DIM)
    love.graphics.setLineWidth(1)
  end
  love.graphics.rectangle("line", x, y, width, PARTY_CARD_HEIGHT)
  
  local innerX = x + 10
  local innerY = y + 10
  
  -- Member name
  love.graphics.setFont(self.fontNormal)
  love.graphics.setColor(COLOR_TEXT)
  love.graphics.print(member.name, innerX, innerY)
  
  innerY = innerY + 20
  
  -- HP bar
  self:drawStatBar(innerX, innerY, width - 20, 12, 
    "HP", member.hp, member.maxHp, COLOR_DANGER, COLOR_SAFE)
  
  innerY = innerY + 20
  
  -- EP bar
  self:drawStatBar(innerX, innerY, width - 20, 12, 
    "EP", member.ep, member.maxEp, {0.200, 0.400, 1.000, 1}, {0.400, 0.600, 1.000, 1})
  
  return y + PARTY_CARD_HEIGHT
end

function HUD:drawStatBar(x, y, width, height, label, current, max, colorLow, colorHigh)
  -- Label
  love.graphics.setFont(self.fontSmall)
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.print(label, x, y)
  
  local barX = x + 25
  local barWidth = width - 25
  
  -- Bar background
  love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
  love.graphics.rectangle("fill", barX, y, barWidth, height)
  
  -- Bar fill
  local fillWidth = (current / max) * barWidth
  local fillPercent = current / max
  
  -- Color interpolation based on percentage
  local r = colorLow[1] + (colorHigh[1] - colorLow[1]) * fillPercent
  local g = colorLow[2] + (colorHigh[2] - colorLow[2]) * fillPercent
  local b = colorLow[3] + (colorHigh[3] - colorLow[3]) * fillPercent
  
  love.graphics.setColor(r, g, b, 1)
  love.graphics.rectangle("fill", barX, y, fillWidth, height)
  
  -- Bar border
  love.graphics.setColor(COLOR_TEXT_DIM)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", barX, y, barWidth, height)
  
  -- Value text
  love.graphics.setColor(COLOR_TEXT)
  love.graphics.printf(string.format("%d/%d", current, max), 
    barX, y + 1, barWidth, "center")
end

function HUD:drawMessageLog()
  local x = 10
  local y = SCREEN_HEIGHT - MESSAGE_LOG_HEIGHT - 10
  local width = SCREEN_WIDTH - 20
  
  -- Log background
  love.graphics.setColor(COLOR_PANEL_BG)
  love.graphics.rectangle("fill", x, y, width, MESSAGE_LOG_HEIGHT)
  
  -- Log border
  love.graphics.setColor(COLOR_ACCENT)
  love.graphics.setLineWidth(1)
  love.graphics.rectangle("line", x, y, width, MESSAGE_LOG_HEIGHT)
  
  -- Messages
  love.graphics.setFont(self.fontSmall)
  local messageY = y + 5
  local lineHeight = 11
  
  for i = math.max(1, #self.messages - 4), #self.messages do
    local msg = self.messages[i]
    love.graphics.setColor(msg.color)
    love.graphics.print(msg.text, x + 5, messageY)
    messageY = messageY + lineHeight
  end
end

-- ─── Module Export ───────────────────────────────────────────────────────────

return HUD
