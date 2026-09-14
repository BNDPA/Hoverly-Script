--[[
    Project: Hoverly Script | DOORS
    Features: NoClip, Auto Interact, ESP (Fixed Doors, Keys/Levers, Entities, Players), Entity Notifier, Fullbright
]]

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Failed to load Wind UI for DOORS script!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Создаем главное окно скрипта для DOORS
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | DOORS",
    Icon = "door-closed",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

-- Вкладки
local MainTab = Window:Tab({ Title = "Main / Auto", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local ESPTab = Window:Tab({ Title = "Visuals (ESP)", Icon = "eye" })
local WorldTab = Window:Tab({ Title = "World", Icon = "globe" })

-- Состояния
local noclipEnabled = false
local autoInteractEnabled = false
local espItemsEnabled = false
local espPlayersEnabled = false
local espEntitiesEnabled = false
local entityNotifierEnabled = false

-- Папки для ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "HoverlyDOORS_ESP"
espFolder.Parent = Workspace

-- =================================================================
-- 1. ENTITY NOTIFIER (УВЕДОМЛЕНИЯ О МОНСТРАХ)
-- =================================================================
MainTab:Toggle({
    Title = "Entity Notifier (Notice)",
    Description = "Warns you when Rush, Ambush, Eyes or other entities spawn.",
    Value = false,
    Callback = function(state)
        entityNotifierEnabled = state
    end
})

local monitoredEntities = {
    ["RushMoving"] = "Rush is coming! HIDE NOW!",
    ["AmbushMoving"] = "Ambush is coming! HIDE & GET READY TO CLICK!",
    ["Eyes"] = "Eyes spawned! Don't look at them!",
    ["Halt"] = "Halt room! Turn around or move back!",
    ["A-60"] = "A-60 is coming! HIDE IN A LOCKER!",
    ["A-120"] = "A-120 is coming! HIDE QUICKLY!"
}

Workspace.ChildAdded:Connect(function(child)
    if entityNotifierEnabled then
        if monitoredEntities[child.Name] then
            WindUI:Notify({
                Title = "⚠️ WARNING: " .. child.Name,
                Content = monitoredEntities[child.Name],
                Duration = 6
            })
        end
    end
end)

-- =================================================================
-- 2. PLAYER (NOCLIP)
-- =================================================================
PlayerTab:Toggle({
    Title = "NoClip",
    Description = "Walk through walls, doors, and obstacles.",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

RunService.Stepped:Connect(function()
    if noclipEnabled then
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- =================================================================
-- 3. AUTO INTERACT (КЛЮЧИ, РЫЧАГИ, ДВЕРИ)
-- =================================================================
MainTab:Toggle({
    Title = "Auto Open Doors, Keys & Levers",
    Description = "Automatically opens doors, picks up keys, pulls levers, and ignores chairs.",
    Value = false,
    Callback = function(state)
        autoInteractEnabled = state
        task.spawn(function()
            while autoInteractEnabled do
                task.wait(0.2)
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                local actionText = obj.ActionText:lower()
                                local objectName = obj.Name:lower()
                                local parent = obj.Parent
                                local parentName = parent and parent.Name:lower() or ""
                                
                                local isIgnored = actionText:find("hide") or actionText:find("enter") or actionText:find("sit") or
                                                  parentName:find("wardrobe") or parentName:find("closet") or 
                                                  parentName:find("bed") or parentName:find("couch") or 
                                                  parentName:find("sofa") or parentName:find("chair") or 
                                                  parentName:find("seat") or objectName:find("chair") or 
                                                  objectName:find("seat") or objectName:find("sit")

                                if not isIgnored then
                                    local targetPart = nil
                                    if parent then
                                        if parent:IsA("BasePart") then
                                            targetPart = parent
                                        elseif parent:IsA("Model") then
                                            targetPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
                                        end
                                    end

                                    if targetPart and targetPart:IsA("BasePart") then
                                        if (hrp.Position - targetPart.Position).Magnitude <= 12 then
                                            fireproximityprompt(obj)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- =================================================================
-- 4. VISUALS & ESP (ИСПРАВЛЕННЫЕ ДВЕРИ, ИГРОКИ, МОНСТРЫ, КЛЮЧИ)
-- =================================================================
ESPTab:Toggle({
    Title = "ESP Doors, Keys & Levers",
    Description = "Highlights active doors (green) and keys/levers (yellow).",
    Value = false,
    Callback = function(state)
        espItemsEnabled = state
    end
})

ESPTab:Toggle({
    Title = "ESP Players",
    Description = "Highlights other players in blue.",
    Value = false,
    Callback = function(state)
        espPlayersEnabled = state
    end
})

ESPTab:Toggle({
    Title = "ESP Monsters / Entities",
    Description = "Highlights incoming entities in red.",
    Value = false,
    Callback = function(state)
        espEntitiesEnabled = state
    end
})

-- Главный цикл отрисовки ESP
task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if not espItemsEnabled and not espPlayersEnabled and not espEntitiesEnabled then
                espFolder:ClearAllChildren()
                return
            end

            -- Очищаем старый ESP перед новой отрисовкой
            espFolder:ClearAllChildren()

            -- 1. ESP ДВЕРЕЙ И ПРЕДМЕТОВ
            if espItemsEnabled then
                if Workspace:FindFirstChild("CurrentRooms") then
                    for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                        local door = room:FindFirstChild("Door")
                        if door then
                            -- Ищем ручку или конкретный меш двери, чтобы не было гигантских коробок
                            local targetPart = door:FindFirstChild("Knob") or door:FindFirstChild("Door") or door:FindFirstChildWhichIsA("BasePart")
                            if targetPart and targetPart:IsA("BasePart") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = targetPart
                                hl.FillColor = Color3.fromRGB(0, 255, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.Parent = espFolder
                            end
                        end
                    end
                end

                -- Ключи, рычаги, переключатели
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:find("key") or name:find("lever") or name:find("breaker") or name:find("switch") or name:find("padlock") then
                            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if targetPart and targetPart:IsA("BasePart") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillColor = Color3.fromRGB(255, 230, 0) -- Желтый
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.Parent = espFolder
                            end
                        end
                    end
                end
            end

            -- 2. ESP ИГРОКОВ
            if espPlayersEnabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp and not char:FindFirstChildOfClass("Highlight") then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = char
                            hl.FillColor = Color3.fromRGB(0, 150, 255) -- Синий
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Parent = espFolder
                        end
                    end
                end
            end

            -- 3. ESP МОНСТРОВ (Entity)
            if espEntitiesEnabled then
                for _, entity in pairs(Workspace:GetChildren()) do
                    if monitoredEntities[entity.Name] or entity.Name == "RushMoving" or entity.Name == "AmbushMoving" or entity.Name == "Eyes" or entity.Name == "Halt" or entity.Name == "Figure" then
                        local targetPart = entity:IsA("Model") and (entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")) or entity
                        if targetPart and targetPart:IsA("BasePart") then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = entity
                            hl.FillColor = Color3.fromRGB(255, 0, 0) -- Красный для монстров
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.Parent = espFolder
                        end
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 5. WORLD (FULLBRIGHT)
-- =================================================================
WorldTab:Toggle({
    Title = "Fullbright",
    Description = "Removes dark areas and makes everything bright.",
    Value = false,
    Callback = function(state)
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.GlobalShadows = true
        end
    end
})

-- Уведомление
WindUI:Notify({
    Title = "DOORS Script Updated",
    Content = "Fixed door ESP, added Players and Monsters ESP!",
    Duration = 4
})
