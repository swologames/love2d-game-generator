-- Test file to find which require is broken
print("Testing requires...")

local success, err

success, err = pcall(function() return require("src.entities.Player") end)
if not success then print("ERROR in Player:", err) end

success, err = pcall(function() return require("src.entities.TrashItem") end)
if not success then print("ERROR in TrashItem:", err) end

success, err = pcall(function() return require("src.entities.Human") end)
if not success then print("ERROR in Human:", err) end

success, err = pcall(function() return require("src.entities.Dog") end)
if not success then print("ERROR in Dog:", err) end

success, err = pcall(function() return require("src.entities.Animal") end)
if not success then print("ERROR in Animal:", err) end

success, err = pcall(function() return require("src.systems.AISystem") end)
if not success then print("ERROR in AISystem:", err) end

success, err = pcall(function() return require("src.ui.PauseMenu") end)
if not success then print("ERROR in PauseMenu:", err) end

success, err = pcall(function() return require("src.ui.SettingsMenu") end)
if not success then print("ERROR in SettingsMenu:", err) end

success, err = pcall(function() return require("src.ui.Panel") end)
if not success then print("ERROR in Panel:", err) end

success, err = pcall(function() return require("src.ui.Icon") end)
if not success then print("ERROR in Icon:", err) end

print("Done")
