--[[
    Project: Hoverly Script | DOORS
    Features: NoClip, Auto Door/Interact, ESP (Doors & Keys), Fullbright
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
local espDoorsEnabled = false

-- Папка для ESP
local espFolder = Instance.new("Folder")
espFolder.Name = "HoverlyDOORS_ESP"
espFolder.Parent = Workspace

-- =================================================================
-- 1. PLAYER (NOCLIP)
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
-- 2. AUTO INTERACT / AUTO DOOR (АВТОМАТИЗАЦИЯ ПРОХОЖДЕНИЯ)
-- =================================================================
MainTab:Toggle({
    Title = "Auto Open Doors & Interact",
    Description = "Automatically opens doors and picks up items/keys nearby.",
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
                        -- Ищем объекты взаимодействия в комнатах (Prompt)
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                local parentPart = obj.Parent
                                if parentPart and parentPart:IsA("BasePart") then
                                    if (hrp.Position - parentPart.Position).Magnitude <= 10 then
                                        fireproximityprompt(obj)
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
-- 3. VISUALS & ESP (ПОДСВЕТКА ДВЕРЕЙ И КЛЮЧЕЙ)
-- =================================================================
ESPTab:Toggle({
    Title = "ESP Doors & Keys",
    Description = "Highlights current rooms, doors, and keys.",
    Value = false,
    Callback = function(state)
        espDoorsEnabled = state
        if state then
            task.spawn(function()
                while espDoorsEnabled do
                    espFolder:ClearAllChildren()
                    pcall(function()
                        for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                            -- Ищем двери
                            local door = room:FindFirstChild("Door")
                            if door and door:FindFirstChild("Door") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = door.Door
                                hl.FillColor = Color3.fromRGB(0, 255, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.5
                                hl.Parent = espFolder
                            end
                        end
                    end)
                    task.wait(2)
                end
            end)
        else
            espFolder:ClearAllChildren()
        end
    end
})

-- =================================================================
-- 4. WORLD (FULLBRIGHT)
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
    Title = "DOORS Script Loaded",
    Content = "NoClip, Auto-Interact and ESP features ready!",
    Duration = 4
})
