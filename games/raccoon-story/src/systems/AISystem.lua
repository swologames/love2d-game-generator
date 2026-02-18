-- AI System
-- Manages all enemy AI updates, detection, and chase logic

local AISystem = {}

function AISystem:new()
  local instance = {
    humans = {},
    dogs = {},
    animals = {},
    allEnemies = {} -- Combined list for easier iteration
  }
  setmetatable(instance, { __index = self })
  return instance
end

-- Add a human enemy
function AISystem:addHuman(human)
  table.insert(self.humans, human)
  table.insert(self.allEnemies, {type = "human", entity = human})
  print("[AISystem] Added human at (" .. human.x .. ", " .. human.y .. ")")
end

-- Add a dog enemy
function AISystem:addDog(dog)
  table.insert(self.dogs, dog)
  table.insert(self.allEnemies, {type = "dog", entity = dog})
  print("[AISystem] Added dog at (" .. dog.x .. ", " .. dog.y .. ")")
end

-- Add an animal (competitor)
function AISystem:addAnimal(animal)
  table.insert(self.animals, animal)
  table.insert(self.allEnemies, {type = "animal", entity = animal})
  print("[AISystem] Added " .. animal.animalType .. " at (" .. animal.x .. ", " .. animal.y .. ")")
end

-- Update all AI
function AISystem:update(dt, player, trashItems)
  -- Update humans
  for _, human in ipairs(self.humans) do
    human:update(dt, player)
    
    -- Check if caught player
    if human.state == "chase" then
      local dx = player.x - human.x
      local dy = player.y - human.y
      local dist = math.sqrt(dx * dx + dy * dy)
      
      if dist < (human.radius + player.width / 2) then
        -- Human caught player
        return {
          caught = true,
          enemyType = "human",
          dropCount = math.random(1, 2)
        }
      end
    end
  end
  
  -- Update dogs
  for _, dog in ipairs(self.dogs) do
    dog:update(dt, player)
    
    -- Check if caught player
    if dog.state == "chase" then
      local dx = player.x - dog.x
      local dy = player.y - dog.y
      local dist = math.sqrt(dx * dx + dy * dy)
      
      if dist < (dog.radius + player.width / 2) then
        -- Dog caught player
        return {
          caught = true,
          enemyType = "dog",
          dropCount = math.random(2, 3)
        }
      end
    end
  end
  
  -- Update animals (competitors)
  for _, animal in ipairs(self.animals) do
    animal:update(dt, player, trashItems)
  end
  
  return nil -- No one caught player
end

-- Draw all AI entities
function AISystem:draw()
  -- Draw humans
  for _, human in ipairs(self.humans) do
    human:draw()
  end
  
  -- Draw dogs
  for _, dog in ipairs(self.dogs) do
    dog:draw()
  end
  
  -- Draw animals
  for _, animal in ipairs(self.animals) do
    animal:draw()
  end
end

-- Draw debug overlays (vision cones, states, etc.)
function AISystem:drawDebug()
  local lg = love.graphics
  
  -- Draw vision cones for threats
  for _, human in ipairs(self.humans) do
    if human.state == "patrol" then
      lg.setColor(1, 0, 0, 0.1)
      local facingAngle = human:getFacingAngle()
      lg.arc("fill", human.x, human.y, human.visionRange, 
             facingAngle - human.visionAngle / 2, 
             facingAngle + human.visionAngle / 2)
      
      -- Draw detection range circle
      lg.setColor(1, 0, 0, 0.3)
      lg.circle("line", human.x, human.y, human.visionRange)
    end
  end
  
  for _, dog in ipairs(self.dogs) do
    if dog.state == "patrol" then
      lg.setColor(1, 0.5, 0, 0.1)
      local facingAngle = dog:getFacingAngle()
      lg.arc("fill", dog.x, dog.y, dog.visionRange, 
             facingAngle - dog.visionAngle / 2, 
             facingAngle + dog.visionAngle / 2)
      
      lg.setColor(1, 0.5, 0, 0.3)
      lg.circle("line", dog.x, dog.y, dog.visionRange)
    end
  end
  
  -- Draw animal detection ranges
  for _, animal in ipairs(self.animals) do
    lg.setColor(0.5, 0.5, 1, 0.2)
    lg.circle("line", animal.x, animal.y, animal.trashDetectionRange)
    
    lg.setColor(1, 1, 0.5, 0.2)
    lg.circle("line", animal.x, animal.y, animal.playerDetectionRange)
  end
end

-- Check if any enemy is currently chasing
function AISystem:isAnyoneChasing()
  for _, human in ipairs(self.humans) do
    if human.state == "chase" then
      return true
    end
  end
  
  for _, dog in ipairs(self.dogs) do
    if dog.state == "chase" or dog.state == "bark" then
      return true
    end
  end
  
  return false
end

-- Get count of active threats
function AISystem:getActiveThreatCount()
  local count = 0
  
  for _, human in ipairs(self.humans) do
    if human.state == "chase" then
      count = count + 1
    end
  end
  
  for _, dog in ipairs(self.dogs) do
    if dog.state == "chase" or dog.state == "bark" then
      count = count + 1
    end
  end
  
  return count
end

-- Get nearest threat to a position
function AISystem:getNearestThreat(x, y)
  local nearest = nil
  local nearestDist = math.huge
  
  for _, human in ipairs(self.humans) do
    if human.state == "chase" then
      local dx = human.x - x
      local dy = human.y - y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < nearestDist then
        nearestDist = dist
        nearest = human
      end
    end
  end
  
  for _, dog in ipairs(self.dogs) do
    if dog.state == "chase" then
      local dx = dog.x - x
      local dy = dog.y - y
      local dist = math.sqrt(dx * dx + dy * dy)
      if dist < nearestDist then
        nearestDist = dist
        nearest = dog
      end
    end
  end
  
  return nearest, nearestDist
end

-- Clear all enemies (for scene transitions)
function AISystem:clear()
  self.humans = {}
  self.dogs = {}
  self.animals = {}
  self.allEnemies = {}
  print("[AISystem] Cleared all enemies")
end

-- Get total enemy count
function AISystem:getTotalCount()
  return #self.humans + #self.dogs + #self.animals
end

-- Get counts by type
function AISystem:getCounts()
  return {
    humans = #self.humans,
    dogs = #self.dogs,
    animals = #self.animals,
    total = #self.allEnemies
  }
end

-- Get all enemy entities (for minimap, etc.)
function AISystem:getAllEnemies()
  local enemies = {}
  for _, human in ipairs(self.humans) do
    table.insert(enemies, human)
  end
  for _, dog in ipairs(self.dogs) do
    table.insert(enemies, dog)
  end
  for _, animal in ipairs(self.animals) do
    table.insert(enemies, animal)
  end
  return enemies
end

return AISystem
