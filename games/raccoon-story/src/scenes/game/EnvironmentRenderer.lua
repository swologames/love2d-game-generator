-- EnvironmentRenderer.lua
-- Draws environment objects in 7 depth-sorted layers

local EnvironmentRenderer = {}

function EnvironmentRenderer.draw(scene)
  local lg = love.graphics

  -- Layer 1: Grass patches (bottom decorative layer)
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "grassPatch" then
      lg.setColor(1, 1, 1, 0.8)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  -- Layer 2: Fences
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "fence" then
      lg.setColor(1, 1, 1, 1)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  -- Layer 3: Houses
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "house" then
      lg.setColor(1, 1, 1, 1)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  -- Layer 4: Trees
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "tree" then
      lg.setColor(1, 1, 1, 1)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  -- Layer 5: Bushes (hiding spots)
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "bush" then
      lg.setColor(1, 1, 1, 1)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  -- Layer 6: Trash bins
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "trashBin" then
      lg.setColor(1, 1, 1, 1)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  -- Layer 7: Street lamps (top decorative layer)
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.type == "streetLamp" then
      lg.setColor(1, 1, 1, 1)
      lg.draw(obj.sprite, obj.x, obj.y)
    end
  end

  lg.setColor(1, 1, 1, 1)
end

return EnvironmentRenderer
