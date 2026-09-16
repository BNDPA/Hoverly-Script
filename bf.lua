-- Загрузка библиотеки Wind UI
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Создание главного окна меню
local Window = WindUI:CreateWindow({
    Title = "Blox Fruits | Hoverly Script",
    Icon = "compass",
    Author = "BNDPA",
    Folder = "BloxFruitsConfig",
    Size = UDim2.fromOffset(500, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
})

-- Создание вкладки
local FarmTab = Window:Tab({
    Title = "Фарм",
    Icon = "sparkles",
})

-- Переменные состояний
local autoChestEnabled = false
local noClipEnabled = false
local flightSpeed = 280 -- Скорость полёта к сундукам
local currentTween = nil
local collectedChests = {}

-- Функция поиска ближайшего сундука
local function getNearestChest()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    
    local rootPart = character.HumanoidRootPart
    local bestChest = nil
    local shortestDistance = math.huge
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj.Name:find("Chest") then
            local part = nil
            if obj:IsA("BasePart") then
                part = obj
            elseif obj:IsA("Model") then
                part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            end
            
            if part and not collectedChests[part] then
                local dist = (rootPart.Position - part.Position).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    bestChest = part
                end
            end
        end
    end
    
    if not bestChest then
        collectedChests = {}
    end
    
    return bestChest
end

-- Обработка NoClip
RunService.Stepped:Connect(function()
    if autoChestEnabled or noClipEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Основной цикл фарма с фиксацией на позиции сундука
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if autoChestEnabled then
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then return end
                
                local rootPart = character.HumanoidRootPart
                local humanoid = character.Humanoid
                
                -- Включаем невесомость и гасим физику
                humanoid.PlatformStand = true
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                local chest = getNearestChest()
                if chest then
                    collectedChests[chest] = true
                    
                    -- Точка назначения (чуть выше сундука)
                    local targetPos = chest.Position + Vector3.new(0, 3, 0)
                    
                    local distance = (rootPart.Position - targetPos).Magnitude
                    local travelTime = distance / flightSpeed
                    if travelTime < 0.05 then travelTime = 0.05 end
                    
                    if currentTween then
                        currentTween:Cancel()
                    end
                    
                    -- Полет к сундуку
                    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
                    currentTween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
                    currentTween:Play()
                    
                    -- Ожидание окончания полета
                    task.wait(travelTime)
                    
                    -- ФИКСАЦИЯ: жестко удерживаем позицию на месте сундука, чтобы персонаж не проваливался
                    local holdTime = 0.25 -- Время фиксации в секундах
                    local holdElapsed = 0
                    while holdElapsed < holdTime and autoChestEnabled do
                        rootPart.CFrame = CFrame.new(targetPos)
                        rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        task.wait(0.05)
                        holdElapsed = holdElapsed + 0.05
                    end
                else
                    -- Если сундуков нет, просто висим на месте
                    if currentTween then
                        currentTween:Cancel()
                        currentTween = nil
                    end
                    rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
            else
                if currentTween then
                    currentTween:Cancel()
                    currentTween = nil
                end
                local character = LocalPlayer.Character
                if character and character:FindFirstChild("Humanoid") then
                    character.Humanoid.PlatformStand = false
                end
            end
        end)
    end
end)

-- Элементы интерфейса
FarmTab:Toggle({
    Title = "Auto Chest (Fixed Position)",
    Desc = "Сбор сундуков с фиксацией на точке, без просадок вниз",
    Default = false,
    Callback = function(state)
        autoChestEnabled = state
        noClipEnabled = state
        
        if not state then
            if currentTween then currentTween:Cancel() end
            collectedChests = {}
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid.PlatformStand = false
            end
        end
    end
})

FarmTab:Toggle({
    Title = "NoClip (Сквозь стены)",
    Desc = "Хождение сквозь стены во время сбора",
    Default = false,
    Callback = function(state)
        noClipEnabled = state
    end
})

-- Уведомление
WindUI:Notify({
    Title = "Hoverly Script",
    Content = "Фикс проваливания применен!",
    Duration = 3,
})
