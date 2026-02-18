-- HUD.lua
-- Draws the top panel (score/timer/progress), side panel (inventory/dash),
-- threat indicator, message display, controls hint, and minimap.

local HUD = {}

-- ─── Top panel + side panel + overlays ───────────────────────────────────────
function HUD.draw(scene)
  local lg          = love.graphics
  local sw          = lg.getWidth()
  local sh          = lg.getHeight()

  -- Panels
  scene.topPanel:draw()
  scene.sidePanel:draw()
  scene.minimapPanel:draw()

  -- === TOP PANEL: Score / Time / Progress ===

  -- Score (left)
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print("Score", 15, 15, 0, 1.2)
  lg.setColor(0.565, 0.933, 0.565, 1)
  lg.print(tostring(scene.score), 15, 35, 0, 2)

  -- Items collected
  lg.setColor(0.961, 0.871, 0.702, 0.8)
  lg.print("Items: " .. scene.itemsCollected, 85, 42, 0, 1.1)

  -- Moon icon + night timer (center)
  local timerX = sw / 2
  local timerY = 20
  scene.moonIcon:setPosition(timerX - 70, timerY + 15)
  scene.moonIcon:draw()

  local minutes  = math.floor(scene.timeElapsed / 60)
  local seconds  = math.floor(scene.timeElapsed % 60)
  local timeText = string.format("%02d:%02d", minutes, seconds)
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print(timeText, timerX - 25, timerY + 5, 0, 1.8)

  -- Night progress bar (5-minute night)
  local nightDuration = 300
  local progress  = math.min(1, scene.timeElapsed / nightDuration)
  local barWidth  = 150
  local barHeight = 8
  local barX      = timerX - barWidth / 2
  local barY      = timerY + 40

  lg.setColor(0.2, 0.2, 0.3, 0.8)
  lg.rectangle("fill", barX, barY, barWidth, barHeight, 4)
  lg.setColor(0.8, 0.6, 0.2, 1)
  lg.rectangle("fill", barX, barY, barWidth * progress, barHeight, 4)
  lg.setColor(0.545, 0.271, 0.075, 1)
  lg.rectangle("line", barX, barY, barWidth, barHeight, 4)

  -- === SIDE PANEL: Inventory ===
  HUD.drawInventory(scene, sw, sh)

  -- === MINIMAP ===
  HUD.drawMinimap(scene)

  -- === THREAT INDICATOR ===
  if scene.aiSystem:isAnyoneChasing() then
    local threatCount = scene.aiSystem:getActiveThreatCount()
    local flashAlpha  = 0.8 + math.sin(love.timer.getTime() * 5) * 0.2

    scene.alertIcon:setPosition(sw / 2 - 80, 75)
    scene.alertIcon:draw()

    lg.setColor(1, 0.4, 0.4, flashAlpha)
    lg.print("DANGER!", sw / 2 - 50, 68, 0, 1.5)
    lg.setColor(1, 0.6, 0.6, flashAlpha * 0.8)
    lg.print(threatCount .. " threat" .. (threatCount > 1 and "s" or ""), sw / 2 - 20, 85, 0, 0.9)
  end

  -- === MESSAGE DISPLAY ===
  if scene.messageTimer > 0 then
    local messageY    = sh - 60
    local msgW        = love.graphics.getFont():getWidth(scene.messageText) * 1.3 + 40
    local msgX        = (sw - msgW) / 2

    lg.setColor(0.106, 0.106, 0.180, scene.messageAlpha * 0.8)
    lg.rectangle("fill", msgX, messageY - 10, msgW, 40, 8)

    lg.setColor(1, 1, 1, scene.messageAlpha)
    lg.printf(scene.messageText, 0, messageY, sw, "center", 0, 1.3)
  end

  -- === CONTROLS HINT ===
  lg.setColor(0.7, 0.7, 0.7, 0.6)
  lg.print("WASD: Move | SHIFT: Dash | ESC: Pause", 12, sh - 22, 0, 0.85)

  lg.setColor(1, 1, 1, 1)
end

-- ─── Inventory slots ─────────────────────────────────────────────────────────
function HUD.drawInventory(scene, sw, sh)
  local lg         = love.graphics
  local sidePanelX = sw - 210
  local sidePanelY = 85
  local maxSlots   = scene.player.maxInventorySlots
  local invCount   = scene.player:getInventoryCount()

  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print("Inventory", sidePanelX, sidePanelY, 0, 1.3)

  for i = 1, maxSlots do
    local anim       = scene.inventorySlotAnimations[i]
    local slotSize   = 35
    local x          = sidePanelX + 10
    local y          = sidePanelY + 35 + (i - 1) * 45
    local scaledSize = slotSize * anim.scale
    local offX       = (slotSize - scaledSize) / 2
    local offY       = (slotSize - scaledSize) / 2

    if i <= invCount then
      -- Glow when pulsing
      if anim.scale > 1.02 then
        lg.setColor(1, 0.8, 0.2, 0.3)
        lg.rectangle("fill", x + offX - 2, y + offY - 2, scaledSize + 4, scaledSize + 4, 5)
      end
      lg.setColor(0.8, 0.6, 0.2, 1)
      lg.rectangle("fill", x + offX, y + offY, scaledSize, scaledSize, 4)
      lg.setColor(0.961, 0.871, 0.702, 1)
      lg.setLineWidth(2)
      lg.rectangle("line", x + offX, y + offY, scaledSize, scaledSize, 4)
      lg.setLineWidth(1)
      lg.setColor(0.545, 0.271, 0.075, 1)
      lg.rectangle("fill", x + offX + 8,  y + offY + 10, 14, 12, 2)
      lg.rectangle("fill", x + offX + 6,  y + offY + 8,  18,  3, 1)
    else
      -- Empty slot
      lg.setColor(0.3, 0.3, 0.3, 0.5)
      lg.rectangle("fill", x + offX, y + offY, scaledSize, scaledSize, 4)
      lg.setColor(0.5, 0.5, 0.5, 0.6)
      lg.rectangle("line", x + offX, y + offY, scaledSize, scaledSize, 4)
    end
  end

  -- Inventory count
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print(invCount .. "/" .. maxSlots, sidePanelX + 60, sidePanelY + 35 + maxSlots * 45 + 5, 0, 1.3)

  -- Dash status
  local dashY = sidePanelY + 35 + maxSlots * 45 + 45
  lg.setColor(0.961, 0.871, 0.702, 1)
  lg.print("Dash", sidePanelX, dashY, 0, 1.2)

  if scene.player.dashCooldownTimer > 0 then
    local cooldownProgress = 1 - (scene.player.dashCooldownTimer / scene.player.dashCooldown)
    lg.setColor(1, 0.5, 0.5, 0.8)
    lg.rectangle("fill", sidePanelX + 10, dashY + 25, 150 * cooldownProgress, 6, 3)
    lg.setColor(0.3, 0.3, 0.3, 0.6)
    lg.rectangle("line", sidePanelX + 10, dashY + 25, 150, 6, 3)
    lg.setColor(1, 0.5, 0.5, 0.7)
    lg.print(string.format("%.1fs", scene.player.dashCooldownTimer), sidePanelX + 55, dashY + 40, 0, 0.9)
  else
    lg.setColor(0.565, 0.933, 0.565, 1)
    scene.dashIcon:setPosition(sidePanelX + 25, dashY + 28)
    scene.dashIcon:draw()
    lg.print("Ready!", sidePanelX + 50, dashY + 20, 0, 1.1)
  end
end

-- ─── Minimap ─────────────────────────────────────────────────────────────────
function HUD.drawMinimap(scene)
  local lg           = love.graphics
  local sh           = lg.getHeight()
  local minimapX     = 25
  local minimapY     = sh - 165
  local minimapW     = 140
  local minimapH     = 140

  -- Background
  lg.setColor(0.05, 0.05, 0.1, 0.9)
  lg.rectangle("fill", minimapX, minimapY, minimapW, minimapH, 6)

  -- Border
  lg.setColor(0.545, 0.271, 0.075, 1)
  lg.setLineWidth(2)
  lg.rectangle("line", minimapX, minimapY, minimapW, minimapH, 6)
  lg.setLineWidth(1)

  local scaleX = minimapW / scene.worldWidth
  local scaleY = minimapH / scene.worldHeight

  lg.setColor(0.3, 0.3, 0.4, 0.5)
  lg.rectangle("line", minimapX, minimapY, minimapW, minimapH)

  -- Den home icon
  local denX = minimapX + 50 * scaleX
  local denY = minimapY + 50 * scaleY
  scene.homeIcon:setPosition(denX, denY)
  scene.homeIcon:draw()

  -- Enemies
  local playerCX      = scene.player.x + scene.player.width  / 2
  local playerCY      = scene.player.y + scene.player.height / 2
  local visionRadius  = 300
  local enemyList     = scene.aiSystem:getAllEnemies()

  for _, enemy in ipairs(enemyList) do
    local ex   = enemy.x + (enemy.width  or 32) / 2
    local ey   = enemy.y + (enemy.height or 32) / 2
    local dist = math.sqrt((ex - playerCX)^2 + (ey - playerCY)^2)

    if dist < visionRadius or enemy.state == "chase" then
      local mapX = minimapX + ex * scaleX
      local mapY = minimapY + ey * scaleY
      if enemy.state == "chase" then
        lg.setColor(1, 0.3, 0.3, 0.9)
        lg.circle("fill", mapX, mapY, 4)
      else
        lg.setColor(1, 0.7, 0.3, 0.6)
        lg.circle("fill", mapX, mapY, 3)
      end
    end
  end

  -- Player dot
  local pmx = minimapX + playerCX * scaleX
  local pmy = minimapY + playerCY * scaleY
  lg.setColor(0.565, 0.933, 0.565, 1)
  lg.circle("fill", pmx, pmy, 5)
  lg.setColor(1, 1, 1)
  lg.circle("line", pmx, pmy, 5)

  -- Label
  lg.setColor(0.961, 0.871, 0.702, 0.8)
  lg.print("Map", minimapX + 5, minimapY + minimapH + 5, 0, 0.9)

  lg.setColor(1, 1, 1, 1)
end

return HUD
