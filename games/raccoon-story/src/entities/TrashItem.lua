-- Trash Item Entity
-- Collectible food items for the raccoon

local TrashItem = {}
TrashItem.__index = TrashItem

-- Trash types with their properties
TrashItem.TYPES = {
  pizza = {
    name = "Pizza Crust",
    points = 10,
    slots = 1,
    color = {1, 0.8, 0.2} -- Yellow-orange
  },
  burger = {
    name = "Half-Eaten Burger",
    points = 15,
    slots = 1,
    color = {0.8, 0.4, 0.2} -- Brown
  },
  donut = {
    name = "Donut Box",
    points = 20,
    slots = 2,
    color = {1, 0.5, 0.8} -- Pink
  },
  bag = {
    name = "Full Trash Bag",
    points = 50,
    slots = 3,
    color = {0.3, 0.3, 0.3} -- Dark gray
  }
}

function TrashItem:new(x, y, trashType)
  local instance = setmetatable({}, self)
  
  -- Position
  instance.x = x or 0
  instance.y = y or 0
  
  -- Type
  instance.type = trashType or "pizza"
  instance.data = self.TYPES[instance.type] or self.TYPES.pizza
  
  -- Size
  instance.width = 32
  instance.height = 32
  
  -- State
  instance.collected = false
  instance.sparkleTimer = 0
  instance.bobTimer = 0
  instance.bobOffset = 0
  
  -- Sprite reference (will be set after assets are loaded)
  instance.sprite = nil
  
  return instance
end

-- Set sprite reference (called after assets are loaded)
function TrashItem:setSprite(sprite)
  self.sprite = sprite
end

function TrashItem:update(dt)
  if self.collected then
    return
  end
  
  -- Sparkle animation
  self.sparkleTimer = self.sparkleTimer + dt
  
  -- Gentle bobbing animation
  self.bobTimer = self.bobTimer + dt
  self.bobOffset = math.sin(self.bobTimer * 2) * 2
end

function TrashItem:draw()
  if self.collected then
    return
  end
  
  local lg = love.graphics
  local centerX = self.x + self.width / 2
  local centerY = self.y + self.height / 2 + self.bobOffset
  
  -- Draw sparkle effect
  if math.floor(self.sparkleTimer * 4) % 2 == 0 then
    lg.setColor(1, 1, 0, 0.5) -- Yellow sparkle
    lg.circle("fill", centerX, centerY, self.width / 2 + 3)
  end
  
  -- Draw the sprite if available
  if self.sprite then
    lg.setColor(1, 1, 1) -- Reset color to white for proper sprite rendering
    lg.draw(self.sprite, self.x, self.y + self.bobOffset)
  else
    -- Fallback: Draw colored rectangle
    lg.setColor(self.data.color)
    lg.rectangle("fill", self.x, self.y + self.bobOffset, self.width, self.height, 3, 3)
    
    -- Draw outline
    lg.setColor(1, 1, 1, 0.8)
    lg.rectangle("line", self.x, self.y + self.bobOffset, self.width, self.height, 3, 3)
  end
  
  -- Draw point value indicator (small text)
  lg.setColor(1, 1, 1)
  lg.print("+" .. self.data.points, self.x + 2, self.y + self.bobOffset - 12, 0, 0.6)
end

function TrashItem:checkCollision(player)
  if self.collected then
    return false
  end
  
  -- Simple AABB collision
  return player.x < self.x + self.width and
         player.x + player.width > self.x and
         player.y < self.y + self.height and
         player.y + player.height > self.y
end

function TrashItem:collect()
  self.collected = true
end

function TrashItem:getData()
  return self.data
end

return TrashItem
