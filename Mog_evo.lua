-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================================================================
-- СОЗДАНИЕ ОКНА (Hoverly Script | Mog Evolution)
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Mog Evolution",
    Icon = "zap",
    Author = "BNDPA",
    Folder = "HoverlyMogEvolution",
    Size = UDim2.fromOffset(480, 320),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 140,
    HasOutline = true,
})

-- =========================================================================
-- ВКЛАДКА: FARM
-- =========================================================================
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "cpu",
})

FarmTab:Paragraph({
    Title = "Авто фарм, кликер и апгрейд",
    Desc = "Авто-полет, рандомные клики (20 мс) и автоматическая покупка улучшений.",
})

local AutoFarmEnabled = false
local AutoUpgradeEnabled = false
local targetCFrame = CFrame.new(-36.45, 5.62, -124.53)
local originalCFrame = nil

FarmTab:Toggle({
    Title = "Auto Farm & Click (20 мс)",
    Default = false,
    Callback = function(state)
        AutoFarmEnabled = state
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            
            if AutoFarmEnabled then
                originalCFrame = rootPart.CFrame
                
                local distance = (rootPart.Position - targetCFrame.Position).Magnitude
                local flightSpeed = 30
                local flightTime = math.clamp(distance / flightSpeed, 0.5, 3)
                
                local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
            else
                if originalCFrame then
                    local distance = (rootPart.Position - originalCFrame.Position).Magnitude
                    local flightSpeed = 30
                    local flightTime = math.clamp(distance / flightSpeed, 0.5, 3)
                    
                    local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = originalCFrame})
                    tween:Play()
                end
            end
        end
    end
})

FarmTab:Toggle({
    Title = "Auto Upgrade (Покупка лучшего)",
    Default = false,
    Callback = function(state)
        AutoUpgradeEnabled = state
    end
})

-- Ультра-быстрый кликер (20 мс) чуть левее центра экрана
task.spawn(function()
    math.randomseed(tick())
    while true do
        if AutoFarmEnabled then
            pcall(function()
                local viewportSize = Camera.ViewportSize
                local centerX = viewportSize.X / 2
                local centerY = viewportSize.Y / 2
                
                local randomX = math.random(centerX - 150, centerX - 50)
                local randomY = math.random(centerY - 100, centerY + 100)
                
                VirtualInputManager:SendMouseButtonEvent(randomX, randomY, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(randomX, randomY, 0, false, game, 0)
            end)
            task.wait(0.01)
        else
            task.wait(0.1)
        end
    end
end)

-- Логика Auto Upgrade (Проверка побед и отправка запроса на покупку)
task.spawn(function()
    while true do
        if AutoUpgradeEnabled then
            pcall(function()
                -- Ищем значение побед (Wins) в leaderstats или игроке
                local winsVal = nil
                local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
                if leaderstats then
                    for _, stat in ipairs(leaderstats:GetChildren()) do
                        local nameLower = string.lower(stat.Name)
                        if nameLower:find("win") or nameLower:find("побед") then
                            winsVal = stat
                            break
                        end
                    end
                end
                
                -- Если нашли победы, можем спамить попытки покупки улучшений/инструментов
                if winsVal and typeof(winsVal.Value) == "number" and winsVal.Value > 0 then
                    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
                        if descendant:IsA("RemoteEvent") then
                            local name = string.lower(descendant.Name)
                            if name:find("buy") or name:find("upgrade") or name:find("tool") or name:find("purchase") then
                                -- Пытаемся купить следующие аргументы (часто передается ID или строка)
                                descendant:FireServer()
                                descendant:FireServer("Best")
                                descendant:FireServer(1)
                            end
                        end
                    end
                end
            end)
            task.wait(2) -- Проверяем и покупаем каждые 2 секунды
        else
            task.wait(1)
        end
    end
end)

-- =========================================================================
-- ВКЛАДКА: OTHER (Авто Ребирт)
-- =========================================================================
local OtherTab = Window:Tab({
    Title = "Other",
    Icon = "settings",
})

OtherTab:Paragraph({
    Title = "Дополнительные функции",
    Desc = "Автоматическое выполнение возрождений (Rebirth).",
})

local AutoRebirthEnabled = false

OtherTab:Toggle({
    Title = "Auto Rebirth",
    Default = false,
    Callback = function(state)
        AutoRebirthEnabled = state
    end
})

task.spawn(function()
    while true do
        if AutoRebirthEnabled then
            pcall(function()
                for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
                    if descendant:IsA("RemoteEvent") and (string.lower(descendant.Name):find("rebirth") or string.lower(descendant.Name):find("evolution")) then
                        descendant:FireServer()
                    end
                end
                if LocalPlayer:FindFirstChild("PlayerGui") then
                    for _, gui in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                        if gui:IsA("RemoteEvent") and string.lower(gui.Name):find("rebirth") then
                            gui:FireServer()
                        end
                    end
                end
            end)
            task.wait(1)
        else
            task.wait(1)
        end
    end
end)

Window:SelectTab(1)
