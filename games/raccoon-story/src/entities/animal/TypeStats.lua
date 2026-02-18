-- Animal type statistics
-- Initialises per-type speed, detection ranges, and flee duration

local TypeStats = {}

function TypeStats.initTypeStats(animal)
  if animal.animalType == "possum" then
    animal.speed = 80
    animal.trashDetectionRange = 120
    animal.playerDetectionRange = 80
    animal.fleeDuration = 2
  elseif animal.animalType == "cat" then
    animal.speed = 160
    animal.trashDetectionRange = 150
    animal.playerDetectionRange = 120
    animal.fleeDuration = 3
  elseif animal.animalType == "crow" then
    animal.speed = 100
    animal.trashDetectionRange = 200
    animal.playerDetectionRange = 150
    animal.fleeDuration = 5
    animal.width = 64
    animal.height = 64
  end
end

return TypeStats
