-- HidingFeedback.lua
-- Updates nearby bush detection and draws visual hiding cues

local HidingFeedback = {}

function HidingFeedback.updateNearbyBushes(scene)
  scene.nearbyBushes = {}

  local playerCX = scene.player.x + scene.player.width  / 2
  local playerCY = scene.player.y + scene.player.height / 2

  for _, obj in ipairs(scene.environmentObjects) do
    if obj.canHide and obj.type == "bush" then
      local bushCX = obj.x + obj.width  / 2
      local bushCY = obj.y + obj.height / 2
      local dx = bushCX - playerCX
      local dy = bushCY - playerCY
      if math.sqrt(dx*dx + dy*dy) <= 50 then
        table.insert(scene.nearbyBushes, obj)
      end
    end
  end
end

function HidingFeedback.draw(scene)
  local lg = love.graphics

  -- Highlight nearby bushes when not hiding
  if not scene.player.isHiding and #scene.nearbyBushes > 0 then
    for _, bush in ipairs(scene.nearbyBushes) do
      lg.setColor(0.4, 0.9, 0.4, 0.6)
      lg.setLineWidth(2)
      lg.rectangle("line", bush.x - 2, bush.y - 2, bush.width + 4, bush.height + 4)

      lg.setColor(1, 1, 1, 0.9)
      lg.print("E", bush.x + bush.width / 2 - 5, bush.y - 20, 0, 1.2)
    end
    lg.setLineWidth(1)
  end

  -- Show hiding indicator when hiding
  if scene.player.isHiding then
    local textX = scene.player.x + scene.player.width  / 2
    local textY = scene.player.y - 30
    local text  = "Hiding... (Press E to exit)"
    local textWidth = 200

    lg.setColor(0, 0, 0, 0.7)
    lg.rectangle("fill", textX - textWidth / 2, textY - 15, textWidth, 25, 4, 4)

    local pulse = 0.7 + math.sin(love.timer.getTime() * 3) * 0.3
    lg.setColor(0.4, 0.9, 0.4, pulse)
    lg.printf(text, textX - textWidth / 2, textY - 10, textWidth, "center")
  end

  lg.setColor(1, 1, 1, 1)
end

return HidingFeedback
