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
local flightSpeed = 250 -- Скорость полёта
local currentTween = nil
local collectedChests = {}

-- Функция поиска следующего доступного сундука
local function getNextChest()
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

-- Основной цикл плавного полёта без просадок вниз
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            if autoChestEnabled then
                local character = LocalPlayer.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid") then return end
                
                local rootPart = character.HumanoidRootPart
                local humanoid = character.Humanoid
                
                -- Жестко держим персонажа в невесомости, чтобы гравитация не тянула вниз
                humanoid.PlatformStand = true
                rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                
                local chest = getNextChest()
                if chest then
                    collectedChests[chest] = true
                    
                    -- Целевая точка всегда чуть выше сундука (на фиксированной высоте)
                    local targetPos = chest.Position + Vector3.new(0, 6, 0)
                    
                    local distance = (rootPart.Position - targetPos).Magnitude
                    local travelTime = distance / flightSpeed
                    if travelTime < 0.05 then travelTime = 0.05 end
                    
                    if currentTween then
                        currentTween:Cancel()
                    end
                    
                    local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
                    currentTween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(targetPos)})
                    currentTween:Play()
                    
                    local elapsed = 0
                    while elapsed < travelTime and autoChestEnabled do
                        task.wait(0.05)
                        elapsed = elapsed + 0.05
                        if not chest or not chest.Parent then
                            break
                        end
                    end
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
    Title = "Auto Chest (Stable Height)",
    Desc = "Полёт к сундукам на стабильной высоте без просадок вниз",
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
    Desc = "Отдельное включение хождения сквозь стены",
    Default = false,
    Callback = function(state)
        noClipEnabled = state
    end
})

-- Уведомление
WindUI:Notify({
    Title = "Hoverly Script",
    Content = "Фикс высоты полёта применен!",
    Duration = 3,
})

