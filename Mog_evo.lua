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
    Desc = "Автофарм, точная ходьба по точкам, клики (20 мс) и Auto Upgrade.",
})

local AutoFarmEnabled = false
local AutoMogEnabled = false
local AutoUpgradeEnabled = false

local farmOriginalCFrame = nil

-- Активная точка по умолчанию (начнем с Subhuman, но переключим легко)
local selectedWaypointName = "HTN" -- Сразу поставим HTN для теста или заменим ниже

-- Точка для Auto Farm & Click
local farmTargetCFrame = CFrame.new(-36.45, 5.62, -124.53)

-- Список всех 6 точек Auto Mog с координатами
local mogWaypointsList = {
    ["Subhuman"] = {path = CFrame.new(-118.04, 5.76, -68.29), target = CFrame.new(-120.23, 10.64, -55.60)},
    ["Sub 3"]    = {path = CFrame.new(-161.32, 5.99, -68.92), target = CFrame.new(-160.68, 12.74, -54.65)},
    ["Sub 5"]    = {path = CFrame.new(-201.85, 5.99, -69.97), target = CFrame.new(-200.39, 12.67, -55.68)},
    ["LTN"]      = {path = CFrame.new(-240.50, 5.99, -67.94), target = CFrame.new(-240.52, 12.46, -55.33)},
    ["MTN"]      = {path = CFrame.new(-278.81, 5.84, -68.89), target = CFrame.new(-279.76, 10.83, -55.84)},
    ["HTN"]      = {path = CFrame.new(-318.92, 5.86, -69.44), target = CFrame.new(-319.91, 11.21, -52.39)}
}

-- 1. Auto Farm & Click (полет к точке + клики)
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
                
                local distance = (rootPart.Position - farmTargetCFrame.Position).Magnitude
                local flightSpeed = 18
                local flightTime = math.clamp(distance / flightSpeed, 1, 5)
                
                local tweenInfo = TweenInfo.new(flightTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = farmTargetCFrame})
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

-- Выбор точки через удобные кнопки (вместо глючного дропдауна)
FarmTab:Paragraph({
    Title = "Выбор точки для Auto Mog",
    Desc = "Нажми на нужную точку, чтобы переключить скрипт на нее:",
})

for name, _ in pairs(mogWaypointsList) do
    FarmTab:Button({
        Title = "Выбрать точку: " .. name,
        Callback = function()
            selectedWaypointName = name
            WindUI:Notify({
                Title = "Auto Mog",
                Content = "Успешно выбрана точка: " .. name,
                Duration = 2
            })
            print("Скрипт переключен на точку:", name)
        end
    })
end

-- Функция для ходьбы до целевой позиции пешком через MoveTo
local function walkTo(humanoid, rootPart, targetPosition)
    local reached = false
    local connection
    
    connection = humanoid.MoveToFinished:Connect(function(isReached)
        reached = true
        if connection then connection:Disconnect() end
    end)
    
    humanoid:MoveTo(targetPosition)
    
    local startTime = tick()
    while not reached and AutoMogEnabled and (tick() - startTime < 20) do
        if (rootPart.Position - targetPosition).Magnitude < 4 then
            break
        end
        task.wait(0.2)
    end
    
    if connection then connection:Disconnect() end
end

-- 2. Auto Mog (ходьба от начала до конца + RemoteEvent)
FarmTab:Toggle({
    Title = "Auto Mog (Ходьба по выбранной точке)",
    Default = false,
    Callback = function(state)
        AutoMogEnabled = state
        
        task.spawn(function()
            while AutoMogEnabled do
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChildOfClass("Humanoid") then
                    local rootPart = character.HumanoidRootPart
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    
                    -- Берем данные строго по выбранному имени точки
                    local data = mogWaypointsList[selectedWaypointName]
                    if data then
                        -- 1. Сначала идем пешком к началу (path)
                        walkTo(humanoid, rootPart, data.path.Position)
                        
                        if not AutoMogEnabled then break end
                        
                        -- 2. Затем идем пешком к концу (target)
                        walkTo(humanoid, rootPart, data.target.Position)
                        
                        -- Стоим на конечной точке перед повторным циклом
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

