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
    Size = UDim2.fromOffset(480, 360),
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
    Title = "Авто фарм и модули",
    Desc = "Автофарм по выбору точек, клики (20 мс), Auto Mog и Auto Upgrade.",
})

local AutoFarmEnabled = false
local AutoMogEnabled = false
local AutoUpgradeEnabled = false
local farmOriginalCFrame = nil

-- Список точек Auto Farm & Click
local farmWaypointsList = {
    ["x2 appeal"]  = CFrame.new(-68.88, 6.74, -120.92),
    ["x3 appeal"]  = CFrame.new(8.93, 7.74, -121.33),
    ["X5 appeal"]  = CFrame.new(-69.21, 10.74, -151.10),
    ["x8 appeal"]  = CFrame.new(-55.49, 10.74, -157.24),
    ["x12 appeal"] = CFrame.new(-5.64, 10.73, -156.28),
    ["x18 appeal"] = CFrame.new(8.51, 10.73, -151.30)
}

local farmWaypointNames = {"x2 appeal", "x3 appeal", "X5 appeal", "x8 appeal", "x12 appeal", "x18 appeal"}
local selectedFarmWaypoint = "x2 appeal" -- По умолчанию

-- Список точек Auto Mog
local mogWaypointsList = {
    ["Subhuman"] = {path = CFrame.new(-120.23, 5.96, -83.34), target = CFrame.new(-120.23, 10.64, -55.60)},
    ["Sub 3"]    = {path = CFrame.new(-160.72, 5.99, -83.82), target = CFrame.new(-160.68, 12.74, -54.65)},
    ["Sub 5"]    = {path = CFrame.new(-199.07, 5.86, -83.55), target = CFrame.new(-200.39, 12.67, -55.68)},
    ["LTN"]      = {path = CFrame.new(-241.17, 5.99, -83.55), target = CFrame.new(-240.52, 12.46, -55.33)},
    ["MTN"]      = {path = CFrame.new(-281.45, 5.99, -83.65), target = CFrame.new(-279.76, 10.83, -55.84)},
    ["HTN"]      = {path = CFrame.new(-325.83, 6.49, -83.75), target = CFrame.new(-319.91, 11.21, -52.39)},
    ["ChadLite"] = {path = CFrame.new(-357.78, 6.58, -70.35), target = CFrame.new(-360.33, 11.86, -52.86)},
    ["Chad"]     = {path = CFrame.new(-400.42, 6.78, -71.99), target = CFrame.new(-401.11, 10.57, -51.74)}
    ["AdamLite"] = {path = CFrame.new(-440.43, 6.96, -74.95), target = CFrame.new(-440.64, 14.14, -54.98)}
}

local waypointNames = {"Subhuman", "Sub 3", "Sub 5", "LTN", "MTN", "HTN", "ChadLite", "Chad", "AdamLite"}
local selectedWaypointName = "HTN" -- По умолчанию

-- =========================================================================
-- БЛОК AUTO FARM & CLICK
-- =========================================================================

FarmTab:Dropdown({
    Title = "Выбор точки Auto Farm",
    Values = farmWaypointNames,
    Default = "x2 appeal",
    Callback = function(option)
        selectedFarmWaypoint = option
        WindUI:Notify({
            Title = "Auto Farm",
            Content = "Выбрана точка: " .. option,
            Duration = 2
        })
        
        if AutoFarmEnabled then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local rootPart = character.HumanoidRootPart
                local targetCFrame = farmWaypointsList[selectedFarmWaypoint]
                if targetCFrame then
                    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
                    local flightSpeed = 18
                    local flightTime = math.clamp(distance / flightSpeed, 1, 5)
                    
                    local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
                    tween:Play()
                end
            end
        end
    end
})

FarmTab:Toggle({
    Title = "Auto Farm & Click (20 мс)",
    Default = false,
    Callback = function(state)
        AutoFarmEnabled = state
        
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local rootPart = character.HumanoidRootPart
            
            if AutoFarmEnabled then
                farmOriginalCFrame = rootPart.CFrame
                
                local targetCFrame = farmWaypointsList[selectedFarmWaypoint] or farmWaypointsList["x2 appeal"]
                local distance = (rootPart.Position - targetCFrame.Position).Magnitude
                local flightSpeed = 18
                local flightTime = math.clamp(distance / flightSpeed, 1, 5)
                
                local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
                tween:Play()
            else
                if farmOriginalCFrame then
                    local distance = (rootPart.Position - farmOriginalCFrame.Position).Magnitude
                    local flightSpeed = 18
                    local flightTime = math.clamp(distance / flightSpeed, 1, 5)
                    
                    local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = farmOriginalCFrame})
                    tween:Play()
                end
            end
        end
    end
})

-- =========================================================================
-- БЛОК AUTO MOG
-- =========================================================================

FarmTab:Dropdown({
    Title = "Выбор точки Auto Mog",
    Values = waypointNames,
    Default = "HTN",
    Callback = function(option)
        selectedWaypointName = option
        WindUI:Notify({
            Title = "Auto Mog",
            Content = "Выбрана точка: " .. option,
            Duration = 2
        })
    end
})

-- Функция ходьбы с вилянием вправо по дороге и точным подходом к цели
local function walkToWithPathSway(humanoid, rootPart, targetPosition, isFinalTarget)
    local reached = false
    local connection
    
    connection = humanoid.MoveToFinished:Connect(function(isReached)
        reached = true
        if connection then connection:Disconnect() end
    end)
    
    local startTime = tick()
    while not reached and AutoMogEnabled and (tick() - startTime < 25) do
        local currentPos = rootPart.Position
        local distanceToTarget = (currentPos - targetPosition).Magnitude
        
        if distanceToTarget < 3.5 then
            reached = true
            break
        end
        
        -- Если это конечная точка, идем абсолютно точно к ней без виляния
        if isFinalTarget then
            humanoid:MoveTo(targetPosition)
        else
            -- Пока идем по промежуточному пути — веляем вправо (добавляем смещение по оси X)
            local direction = (targetPosition - currentPos).Unit
            local rightVector = direction:Cross(Vector3.new(0, 1, 0)).Unit
            
            -- Вычисляем слегка смещенную точку вправо (на 2 студа) для эффекта виляния
            local swayedPosition = targetPosition + (rightVector * 2.0)
            humanoid:MoveTo(swayedPosition)
        end
        
        task.wait(0.25)
    end
    
    -- Финальное точное движение на позицию
    humanoid:MoveTo(targetPosition)
    task.wait(0.3)
    
    if connection then connection:Disconnect() end
end

-- Включение Auto Mog
FarmTab:Toggle({
    Title = "Auto Mog (Включить фарм по точкам)",
    Default = false,
    Callback = function(state)
        AutoMogEnabled = state
        
        task.spawn(function()
            while AutoMogEnabled do
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
                    local rootPart = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    
                    local data = mogWaypointsList[selectedWaypointName]
                    if data then
                        -- 1. Идем к начальной точке пути (с вилянием вправо)
                        walkToWithPathSway(humanoid, rootPart, data.path.Position, false)
                        
                        if not AutoMogEnabled then break end
                        
                        -- 2. Идем к целевой точке (точно в цель без виляния)
                        walkToWithPathSway(humanoid, rootPart, data.target.Position, true)
                        
                        -- Пауза на точке
                        local stayTime = tick()
                        while tick() - stayTime < 2 and AutoMogEnabled do
                            task.wait(0.1)
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

FarmTab:Toggle({
    Title = "Auto Upgrade (Покупка лучшего)",
    Default = false,
    Callback = function(state)
        AutoUpgradeEnabled = state
    end
})

-- Ультра-быстрый кликер (20 мс)
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

-- Логика Auto Mog (отправка RemoteEvent)
task.spawn(function()
    while true do
        if AutoMogEnabled then
            pcall(function()
                for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
                    if descendant:IsA("RemoteEvent") then
                        local name = string.lower(descendant.Name)
                        if name:find("mog") or name:find("train") or name:find("tap") or name:find("click") then
                            descendant:FireServer()
                        end
                    end
                end
            end)
            task.wait(0.5)
        else
            task.wait(1)
        end
    end
end)

-- Логика Auto Upgrade
task.spawn(function()
    while true do
        if AutoUpgradeEnabled then
            pcall(function()
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
                
                if winsVal and typeof(winsVal.Value) == "number" and winsVal.Value >= 0 then
                    for _, descendant in ipairs(ReplicatedStorage:GetDescendants()) do
                        if descendant:IsA("RemoteEvent") then
                            local name = string.lower(descendant.Name)
                            if name:find("buy") or name:find("upgrade") or name:find("tool") or name:find("purchase") then
                                descendant:FireServer()
                                descendant:FireServer("Best")
                                descendant:FireServer(1)
                            end
                        end
                    end
                end
            end)
            task.wait(2)
        else
            task.wait(1)
        end
    end
end)

-- =========================================================================
-- ЗАЩИТА ОТ ДОНАТ-МЕНЮ И МАГАЗИНОВ ПРИ ВКЛЮЧЕННОМ AUTO MOG
-- =========================================================================
task.spawn(function()
    while true do
        if AutoMogEnabled then
            pcall(function()
                local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in ipairs(playerGui:GetDescendants()) do
                        if gui:IsA("GuiObject") or gui:IsA("ScreenGui") then
                            local nameLower = string.lower(gui.Name)
                            if nameLower:find("shop") or 
                               nameLower:find("donate") or 
                               nameLower:find("purchase") or 
                               nameLower:find("product") or 
                               nameLower:find("gamepass") or 
                               nameLower:find("store") or 
                               nameLower:find("robux") then
                                
                                if gui.Visible then
                                    gui.Visible = false
                                end
                            end
                        end
                    end
                end
            end)
            task.wait(0.05)
        else
            task.wait(0.5)
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

