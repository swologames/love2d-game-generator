-- CollisionHandler.lua
-- AABB environment collisions, player caught logic, and trash collection

local CollisionHandler = {}

-- Push player out of solid environment objects
function CollisionHandler.checkEnvironmentCollisions(scene)
  local player = scene.player
  for _, obj in ipairs(scene.environmentObjects) do
    if obj.solid then
      if player.x < obj.x + obj.width  and
         player.x + player.width  > obj.x and
         player.y < obj.y + obj.height and
         player.y + player.height > obj.y then

        local overlapLeft   = (player.x + player.width)  - obj.x
        local overlapRight  = (obj.x + obj.width)  - player.x
        local overlapTop    = (player.y + player.height) - obj.y
        local overlapBottom = (obj.y + obj.height) - player.y

        local minOverlap = math.min(overlapLeft, overlapRight, overlapTop, overlapBottom)

        if     minOverlap == overlapLeft   then player.x = obj.x - player.width
        elseif minOverlap == overlapRight  then player.x = obj.x + obj.width
        elseif minOverlap == overlapTop    then player.y = obj.y - player.height
        elseif minOverlap == overlapBottom then player.y = obj.y + obj.height
        end
      end
    end
  end
end

-- Called when an enemy catches the player
function CollisionHandler.playerCaught(scene, enemyType, dropCount)
  print("[CollisionHandler] Player caught by " .. enemyType .. "! Dropping " .. dropCount .. " items")

  local droppedCount = 0
  for i = 1, dropCount do
    if scene.player:getInventoryCount() > 0 then
      scene.player:removeFromInventory(1)
      droppedCount = droppedCount + 1
    end
  end

  if droppedCount > 0 then
    scene.messageText = "Caught! Lost " .. droppedCount .. " items!"
  else
    scene.messageText = "Almost caught! (No items to drop)"
  end
  scene.messageTimer  = 3
  scene.caughtCooldown = 2
  scene.score = math.max(0, scene.score - droppedCount * 5)
end

-- Called when player walks over a trash item
function CollisionHandler.collectTrash(scene, trash)
  local data = trash:getData()

  if scene.player:getInventoryCount() + data.slots <= scene.player.maxInventorySlots then
    trash:collect()

    for i = 1, data.slots do
      scene.player:addToInventory(data)
    end

    scene.score         = scene.score + data.points
    scene.itemsCollected = scene.itemsCollected + 1
    scene.messageText   = "Collected " .. data.name .. "! (+" .. data.points .. " points)"
    scene.messageTimer  = 2

    -- Visual feedback
    scene.particleSystem:emitCollectionBurst(trash.x + 8, trash.y + 8)
    if trash.sparkleEmitter then
      scene.particleSystem:removeEmitter(trash.sparkleEmitter)
    end

    print("Collected: " .. data.name .. " (" .. data.points .. " points)")
  else
    scene.messageText  = "Inventory Full! (" .. scene.player:getInventoryCount() .. "/" .. scene.player.maxInventorySlots .. ")"
    scene.messageTimer = 2
  end
end

return CollisionHandler
