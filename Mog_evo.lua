-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
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
    Size = UDim2.fromOffset(450, 250),
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
    Title = "Авто фарм и кликер",
    Desc = "Плавный полет к точке, возврат назад и клики слева от центра (20 мс).",
})

local AutoFarmEnabled = false
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
                -- Запоминаем текущую позицию игрока перед полетом
                originalCFrame = rootPart.CFrame
                
                -- Плавный полет к целевой точке
                local distance = (rootPart.Position - targetCFrame.Position).Magnitude
                local flightSpeed = 30
                local flightTime = math.clamp(distance / flightSpeed, 0.5, 3)
                
                local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
            else
                -- Если выключили — летим обратно на исходную позицию
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

-- Ультра-быстрый кликер (20 мс) чуть левее центра экрана с небольшой рандомизацией
task.spawn(function()
    math.randomseed(tick())
    while true do
        if AutoFarmEnabled then
            pcall(function()
                local viewportSize = Camera.ViewportSize
                local centerX = viewportSize.X / 2
                local centerY = viewportSize.Y / 2
                
                -- Центрируем область кликов левее центра (например, смещение влево на 50–150 пикселей)
                local randomX = math.random(centerX - 150, centerX - 50)
                local randomY = math.random(centerY - 100, centerY + 100)
                
                -- Эмулируем клик
                VirtualInputManager:SendMouseButtonEvent(randomX, randomY, 0, true, game, 0)
                task.wait(0.01)
                VirtualInputManager:SendMouseButtonEvent(randomX, randomY, 0, false, game, 0)
            end)
            task.wait(0.01) -- Суммарно ~20 мс
        else
            task.wait(0.1)
        end
    end
end)

Window:SelectTab(1)
