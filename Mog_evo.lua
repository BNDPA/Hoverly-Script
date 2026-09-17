-- Проверка и загрузка интерфейса WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end)

if not success or not WindUI then
    warn("[Hoverly Error]: Не удалось загрузить WindUI! Ошибка: " .. tostring(WindUI))
    return
end

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
    Desc = "Автофарм с динамическими точками под Rebirth, точная ходьба, клики (20 мс) и Auto Upgrade.",
})

local AutoFarmEnabled = false
local AutoMogEnabled = false
local AutoUpgradeEnabled = false
local farmOriginalCFrame = nil

-- Базовая точка по умолчанию (если количество ребиртов меньше 1)
local defaultFarmTargetCFrame = CFrame.new(-36.45, 5.62, -124.53)

-- Функция динамического определения координаты фарма по количеству ребиртов / побед
local function getDynamicFarmTarget()
    local rebirths = 0
    
    pcall(function()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            for _, stat in ipairs(leaderstats:GetChildren()) do
                local nameLower = string.lower(stat.Name)
                if nameLower:find("rebirth") or nameLower:find("ребирт") or nameLower:find("win") or nameLower:find("побед") then
                    if typeof(stat.Value) == "number" then
                        rebirths = stat.Value
                        break
                    end
                end
            end
        end
    end)
    
    -- Проверка от большего к меньшему
    if rebirths >= 15 then
        return CFrame.new(8.51, 10.73, -151.30)
    elseif rebirths >= 12 then
        return CFrame.new(-5.64, 10.73, -156.28)
    elseif rebirths >= 9 then
        return CFrame.new(-55.49, 10.74, -157.24)
    elseif rebirths >= 6 then
        return CFrame.new(-69.21, 10.74, -151.10)
    elseif rebirths >= 3 then
        return CFrame.new(-68.88, 6.74, -120.92)
    elseif rebirths >= 1 then
        return CFrame.new(8.93, 7.74, -121.33)
    else
        return defaultFarmTargetCFrame
    end
end

-- Список точек Auto Mog с обновленными первыми координатами (path)
local mogWaypointsList = {
    ["Subhuman"] = {path = CFrame.new(-120.23, 5.96, -83.34), target = CFrame.new(-120.23, 10.64, -55.60)},
    ["Sub 3"]    = {path = CFrame.new(-160.72, 5.99, -83.82), target = CFrame.new(-160.68, 12.74, -54.65)},
    ["Sub 5"]    = {path = CFrame.new(-199.07, 5.86, -83.55), target = CFrame.new(-200.39, 12.67, -55.68)},
    ["LTN"]      = {path = CFrame.new(-241.17, 5.99, -83.55), target = CFrame.new(-240.52, 12.46, -55.33)},
    ["MTN"]      = {path = CFrame.new(-281.45, 5.99, -83.65), target = CFrame.new(-279.76, 10.83, -55.84)},
    ["HTN"]      = {path = CFrame.new(-325.83, 6.49, -83.75), target = CFrame.new(-319.91, 11.21, -52.39)}
}

local waypointNames = {"Subhuman", "Sub 3", "Sub 5", "LTN", "MTN", "HTN"}
local selectedWaypointName = "HTN" -- По умолчанию

-- 1. Auto Farm & Click (с учетом Rebirth)
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
                local currentFarmTarget = getDynamicFarmTarget()
                
                local distance = (rootPart.Position - currentFarmTarget.Position).Magnitude
                local flightSpeed = 18
                local flightTime = math.clamp(distance / flightSpeed, 1, 5)
                
                local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = currentFarmTarget})
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
-- БЛОК AUTO MOG (Красивый селектор + тумблер ниже)
-- =========================================================================

-- Функция выбора авто мога (Dropdown)
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

-- Функция точного прямолинейного перемещения для Auto Mog (без уходов влево)
local function moveToPrecise(rootPart, humanoid, targetCFrame)
    if not rootPart or not humanoid then return end
    
    humanoid.PlatformStand = true
    
    local distance = (rootPart.Position - targetCFrame.Position).Magnitude
    local speed = 16 
    local duration = math.clamp(distance / speed, 0.2, 3)
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = targetCFrame})
    tween:Play()
    
    local completed = false
    local conn
    conn = tween.Completed:Connect(function()
        completed = true
        if conn then conn:Disconnect() end
    end)
    
    local startTime = tick()
    while not completed and AutoMogEnabled and (tick() - startTime < (duration + 1)) do
        task.wait(0.05)
    end
    
    humanoid.PlatformStand = false
    rootPart.CFrame = targetCFrame
end

-- Включение Auto Mog (расположено сразу под селектором)
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
                        -- 1. Строго по прямой идем к начальной точке пути
                        moveToPrecise(rootPart, humanoid, data.path)
                        
                        if not AutoMogEnabled then break end
                        
                        -- 2. Строго по прямой идем к целевой точке
                        moveToPrecise(rootPart, humanoid, data.target)
                        
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

