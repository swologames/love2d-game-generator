-- src/scenes/combat/CombatUI.lua
-- Combat UI rendering (separated from input logic)

local CombatUI = {}

-- ─── Constants ──────────────────────────────────────────────────────────────

local SCREEN_WIDTH = 1280
local SCREEN_HEIGHT = 720

local INITIATIVE_HEIGHT = 50
local ACTION_MENU_HEIGHT = 80
local PARTY_PANEL_HEIGHT = 200
local ENEMY_PANEL_HEIGHT = 200

local ACTIONS = {
  {key = "1", name = "ATTACK", action = "attack"},
  {key = "2", name = "DEFEND", action = "defend"},
  {key = "3", name = "ITEM", action = "item"},
  {key = "4", name = "FLEE", action = "flee"}
}

-- ─── Initiative Strip ───────────────────────────────────────────────────────

function CombatUI.drawInitiativeStrip(combatSystem)
  local y = 10
  love.graphics.setColor(0.1, 0.1, 0.15, 1)
  love.graphics.rectangle("fill", 10, y, SCREEN_WIDTH - 20, INITIATIVE_HEIGHT)
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("INITIATIVE:", 20, y + 10)
  
  local turnQueue = combatSystem.turnQueue
  local current = combatSystem:getCurrentCombatant()
  local x = 150
  
  for i, entry in ipairs(turnQueue) do
    local isActive = (entry == current)
    local combatant = entry.combatant
    
    -- Highlight active turn
    if isActive then
      love.graphics.setColor(0.2, 0.5, 0.8, 1)
      love.graphics.rectangle("fill", x - 2, y + 5, 100, 30)
    end
    
    -- Draw name
    if entry.isEnemy then
      love.graphics.setColor(1, 0.3, 0.3, 1)
    else
      love.graphics.setColor(0.3, 1, 0.3, 1)
    end
    
    local name = combatant.name or "???"
    love.graphics.print(name:sub(1, 8), x, y + 10)
    
    x = x + 110
    if x > SCREEN_WIDTH - 100 then break end
  end
end

-- ─── Enemy Panel ────────────────────────────────────────────────────────────

function CombatUI.drawEnemyPanel(enemies, selectedIndex, waitingForTarget)
  local y = INITIATIVE_HEIGHT + 30
  
  love.graphics.setColor(0.15, 0.05, 0.05, 1)
  love.graphics.rectangle("fill", 10, y, SCREEN_WIDTH - 20, ENEMY_PANEL_HEIGHT)
  
  love.graphics.setColor(1, 0.5, 0.5, 1)
  love.graphics.print("ENEMIES", 20, y + 10)
  
  local x = 50
  local ey = y + 40
  
  for i, enemy in ipairs(enemies) do
    local isSelected = (waitingForTarget and i == selectedIndex)
    
    -- Selection highlight
    if isSelected then
      love.graphics.setColor(1, 1, 0, 0.5)
      love.graphics.rectangle("fill", x - 5, ey - 5, 150, 130)
    end
    
    -- Enemy box
    love.graphics.setColor(0.3, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", x, ey, 140, 120)
    love.graphics.setColor(1, 0.3, 0.3, 1)
    love.graphics.rectangle("line", x, ey, 140, 120)
    
    -- Enemy sprite placeholder
    love.graphics.setColor(0.8, 0.2, 0.2, 1)
    love.graphics.circle("fill", x + 70, ey + 40, 25)
    
    -- Enemy name
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(enemy.name, x + 10, ey + 75)
    
    -- HP bar
    local hpPercent = enemy:getHPPercent()
    love.graphics.setColor(0.2, 0.2, 0.2, 1)
    love.graphics.rectangle("fill", x + 10, ey + 95, 120, 12)
    love.graphics.setColor(0.8, 0.1, 0.1, 1)
    love.graphics.rectangle("fill", x + 10, ey + 95, 120 * hpPercent, 12)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(enemy:getHP() .. "/" .. enemy:getMaxHP(), x + 15, ey + 95)
    
    x = x + 160
    if x > SCREEN_WIDTH - 150 then break end
  end
end

-- ─── Party Panel ────────────────────────────────────────────────────────────

function CombatUI.drawPartyPanel(combatSystem)
  local y = INITIATIVE_HEIGHT + ENEMY_PANEL_HEIGHT + 60
  
  love.graphics.setColor(0.05, 0.15, 0.05, 1)
  love.graphics.rectangle("fill", 10, y, SCREEN_WIDTH - 20, PARTY_PANEL_HEIGHT)
  
  love.graphics.setColor(0.5, 1, 0.5, 1)
  love.graphics.print("PARTY", 20, y + 10)
  
  local party = combatSystem.party
  local py = y + 40
  
  for i, char in ipairs(party) do
    local isAlive = char:isAliveCheck()
    local current = combatSystem:getCurrentCombatant()
    local isActive = current and current.combatant == char
    
    -- Active turn highlight
    if isActive and isAlive then
      love.graphics.setColor(0.2, 0.6, 0.2, 0.5)
      love.graphics.rectangle("fill", 15, py - 2, SCREEN_WIDTH - 30, 32)
    end
    
    -- Character info
    if isAlive then
      love.graphics.setColor(0.8, 1, 0.8, 1)
    else
      love.graphics.setColor(0.4, 0.4, 0.4, 1)
    end
    
    local name = string.format("[%s] %s", char.class:sub(1,3):upper(), char.name)
    love.graphics.print(name, 25, py)
    
    -- HP bar
    if isAlive then
      local hpPercent = char:getHPPercent()
      love.graphics.setColor(0.2, 0.2, 0.2, 1)
      love.graphics.rectangle("fill", 250, py, 200, 18)
      love.graphics.setColor(0.2, 0.8, 0.2, 1)
      love.graphics.rectangle("fill", 250, py, 200 * hpPercent, 18)
      
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(char:getHP() .. "/" .. char:getMaxHP(), 255, py + 2)
    else
      love.graphics.setColor(0.5, 0, 0, 1)
      love.graphics.print("DEAD", 250, py)
    end
    
    -- EP bar (Energy Points)
    if isAlive then
      local epPercent = char:getEPPercent()
      love.graphics.setColor(0.2, 0.2, 0.2, 1)
      love.graphics.rectangle("fill", 480, py, 150, 18)
      love.graphics.setColor(0.2, 0.5, 1, 1)
      love.graphics.rectangle("fill", 480, py, 150 * epPercent, 18)
      
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.print(char:getEP() .. "/" .. char:getMaxEP(), 485, py + 2)
    end
    
    py = py + 35
  end
end

-- ─── Action Menu ────────────────────────────────────────────────────────────

function CombatUI.drawActionMenu(combatSystem, waitingForTarget)
  local y = SCREEN_HEIGHT - ACTION_MENU_HEIGHT - 10
  
  love.graphics.setColor(0.1, 0.1, 0.15, 1)
  love.graphics.rectangle("fill", 10, y, SCREEN_WIDTH - 20, ACTION_MENU_HEIGHT)
  
  -- Only show if player turn
  if not combatSystem:isPlayerTurn() then
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    love.graphics.print("Enemy Turn...", 20, y + 10)
    return
  end
  
  if waitingForTarget then
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.print("SELECT TARGET (← → or A/D, ENTER to confirm, ESC to cancel)", 20, y + 10)
    return
  end
  
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.print("ACTION MENU:", 20, y + 10)
  
  local x = 20
  local ay = y + 35
  for _, action in ipairs(ACTIONS) do
    love.graphics.print("[" .. action.key .. "] " .. action.name, x, ay)
    x = x + 180
  end
end

-- ─── Combat Log ─────────────────────────────────────────────────────────────

function CombatUI.drawCombatLog(combatSystem)
  local recentLog = combatSystem:getRecentLog(4)
  local x = 700
  local y = INITIATIVE_HEIGHT + ENEMY_PANEL_HEIGHT + 60
  
  love.graphics.setColor(0.1, 0.1, 0.1, 0.8)
  love.graphics.rectangle("fill", x, y, 560, 180)
  
  love.graphics.setColor(0.8, 0.8, 1, 1)
  love.graphics.print("Combat Log:", x + 10, y + 10)
  
  local ly = y + 35
  for _, msg in ipairs(recentLog) do
    love.graphics.setColor(0.9, 0.9, 0.9, 1)
    love.graphics.print(msg, x + 10, ly)
    ly = ly + 30
  end
end

-- ─── Combat End Screen ──────────────────────────────────────────────────────

function CombatUI.drawCombatEnd(state, loot)
  love.graphics.setColor(0, 0, 0, 0.7)
  love.graphics.rectangle("fill", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
  
  love.graphics.setColor(1, 1, 1, 1)
  
  if state == "victory" then
    love.graphics.printf("VICTORY!", 0, 250, SCREEN_WIDTH, "center")
    
    if loot then
      love.graphics.printf("XP Gained: " .. loot.xp, 0, 300, SCREEN_WIDTH, "center")
      if #loot.items > 0 then
        love.graphics.printf("Items: " .. #loot.items, 0, 330, SCREEN_WIDTH, "center")
      end
    end
    
    love.graphics.printf("Press SPACE to continue", 0, 400, SCREEN_WIDTH, "center")
    
  elseif state == "defeat" then
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.printf("DEFEAT", 0, 250, SCREEN_WIDTH, "center")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Your party has been wiped out", 0, 300, SCREEN_WIDTH, "center")
    love.graphics.printf("Press SPACE to continue", 0, 400, SCREEN_WIDTH, "center")
    
  elseif state == "fled" then
    love.graphics.setColor(1, 1, 0, 1)
    love.graphics.printf("FLED", 0, 250, SCREEN_WIDTH, "center")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("The party escaped from combat", 0, 300, SCREEN_WIDTH, "center")
    love.graphics.printf("Press SPACE to continue", 0, 400, SCREEN_WIDTH, "center")
  end
end

-- ─── Damage Numbers ─────────────────────────────────────────────────────────

function CombatUI.drawDamageNumbers(damageNumbers)
  for _, dmg in ipairs(damageNumbers) do
    local alpha = math.min(1, dmg.lifetime / 0.5)
    love.graphics.setColor(1, 0.5, 0, alpha)
    love.graphics.print(dmg.text, dmg.x, dmg.y)
  end
end

-- ─── Action Constants ───────────────────────────────────────────────────────

function CombatUI.getActions()
  return ACTIONS
end

return CombatUI
