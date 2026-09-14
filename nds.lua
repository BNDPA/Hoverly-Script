--[[
    Project: Hoverly Script - Natural Disaster Survival
    Author: BNDPA
    Developer: villorders
]]

-- Проверяем, загружен ли WindUI, если нет — пробуем подгрузить
local successUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not successUI or not WindUI then
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Создаем окно хаба для NDS
local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub | Natural Disaster Survival",
    Icon = "cloud-rain",
    Author = "by: villorders",
    Folder = "HoverlyNDSConfig",
    Theme = "Dark",
    Size = UDim2.new(0, 480, 0, 380),
    Transparent = false,
    HasOutline = true,
})

-- Принудительно задаем черную тему безоговорочно
pcall(function()
    WindUI:SetTheme("Dark")
end)

-- Вкладки (Main с иконкой домика в самом начале)
local MainTab = Window:Tab({ Title = "Main", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local TeleportTab = Window:Tab({ Title = "Teleports", Icon = "navigation" })
local OtherTab = Window:Tab({ Title = "Other", Icon = "package" })
local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Повторно применяем тему после создания вкладок (защита от сброса библиотекой)
task.spawn(function()
    task.wait(0.1)
    pcall(function()
        WindUI:SetTheme("Dark")
    end)
end)

-- Уведомление об успешной загрузке
WindUI:Notify({
    Title = "Hoverly Hub",
    Content = "Скрипт загружен! Разработчик: villorders",
    Duration = 3
})

-- Переменные для функций
local speedEnabled = false
local defaultSpeed = 16
local customSpeed = 32

local jumpEnabled = false
local defaultJump = 50
local customJump = 100

local autoWinEnabled = false
local AUTO_WIN_POS = CFrame.new(-19.34, 80.12, 203.71)
local PLATFORM_POS = Vector3.new(-19.34, 77.12, 203.71)
local previousPosition = nil

-- Функция создания безопасной платформы
local function createPlatform()
    local platformName = "HoverlySafePlatform"
    local existing = Workspace:FindFirstChild(platformName)
    if existing then existing:Destroy() end
    
    local part = Instance.new("Part")
    part.Name = platformName
    part.Size = Vector3.new(12, 1, 12)
    part.CFrame = CFrame.new(PLATFORM_POS)
    part.Anchored = true
    part.CanCollide = true
    part.Transparency = 0.3
    part.BrickColor = BrickColor.new("Bright blue")
    part.Parent = Workspace
end

-- Функция включения Auto Win
local function enableAutoWin()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        previousPosition = character.HumanoidRootPart.CFrame
        createPlatform()
        
        character.HumanoidRootPart.CFrame = AUTO_WIN_POS
        character.HumanoidRootPart.Anchored = true
        
        WindUI:Notify({ Title = "Auto Win", Content = "Активировано: позиция сохранена, вы на платформе!", Duration = 3 })
    end
end

-- Функция выключения Auto Win
local function disableAutoWin()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.Anchored = false
        
        if previousPosition then
            character.HumanoidRootPart.CFrame = previousPosition
            previousPosition = nil
        end
    end
    
    local existing = Workspace:FindFirstChild("HoverlySafePlatform")
    if existing then existing:Destroy() end
    
    WindUI:Notify({ Title = "Auto Win", Content = "Выключено: возврат на прежнее место.", Duration = 2 })
end

-- Автоматический перезаход/телепорт на платформу при смене раунда (возрождении)
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    if autoWinEnabled then
        task.wait(1) -- Ждем полной прогрузки нового персонажа
        createPlatform()
        local hrp = newCharacter:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            hrp.CFrame = AUTO_WIN_POS
            hrp.Anchored = true
        end
    end
end)

-- Логика SpeedHack / JumpPower
RunService.RenderStepped:Connect(function()
    local character = LocalPlayer.Character
    if character and character:FindFirstChild("Humanoid") then
        local humanoid = character.Humanoid
        if speedEnabled then
            humanoid.WalkSpeed = customSpeed
        end
        if jumpEnabled then
            humanoid.JumpPower = customJump
        end
    end
end)

-- ==================== Вкладка Main ====================
MainTab:Toggle({
    Title = "Auto Win (Авто-выживание)",
    Desc = "Телепорт на платформу + фиксация (возврат при выкл)",
    Default = false,
    Callback = function(state)
        autoWinEnabled = state
        if autoWinEnabled then
            enableAutoWin()
        else
            disableAutoWin()
        end
    end
})

-- ==================== Вкладка Player ====================
PlayerTab:Toggle({
    Title = "Быстрый бег (SpeedHack)",
    Desc = "Увеличивает скорость передвижения",
    Default = false,
    Callback = function(state)
        speedEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = defaultSpeed
        end
    end
})

PlayerTab:Slider({
    Title = "Скорость бега",
    Desc = "Настройка значения скорости",
    Min = 16,
    Max = 100,
    Default = 32,
    Callback = function(value)
        customSpeed = value
    end
})

PlayerTab:Toggle({
    Title = "Супер прыжок (JumpPower)",
    Desc = "Позволяет прыгать выше обычного",
    Default = false,
    Callback = function(state)
        jumpEnabled = state
        if not state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = defaultJump
        end
    end
})

-- ==================== Вкладка Teleports ====================
TeleportTab:Button({
    Title = "Телепорт в лобби",
    Desc = "Основное лобби (-280.00, 179.88, 341.00)",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Anchored = false
            character.HumanoidRootPart.CFrame = CFrame.new(-280.00, 179.88, 341.00)
            WindUI:Notify({ Title = "Teleport", Content = "Телепорт в лобби выполнен!", Duration = 2 })
        end
    end
})

TeleportTab:Button({
    Title = "Телепорт на карту",
    Desc = "Точка карты (-115.31, 47.98, 1.51)",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character.HumanoidRootPart.Anchored = false
            character.HumanoidRootPart.CFrame = CFrame.new(-115.31, 47.98, 1.51)
            WindUI:Notify({ Title = "Teleport", Content = "Телепорт на карту выполнен!", Duration = 2 })
        end
    end
})

TeleportTab:Button({
    Title = "Скопировать текущие координаты",
    Desc = "Сохранить позицию в буфер обмена",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local cf = character.HumanoidRootPart.CFrame
            local coordStr = string.format("CFrame.new(%.2f, %.2f, %.2f)", cf.X, cf.Y, cf.Z)
            
            if setclipboard then
                setclipboard(coordStr)
                WindUI:Notify({ Title = "Координаты", Content = "Скопировано: " .. coordStr, Duration = 3 })
            else
                WindUI:Notify({ Title = "Ошибка", Content = "Буфер обмена не поддерживается.", Duration = 3 })
            end
        end
    end
})

-- Функция получения списка игроков для выпадающего списка телепорта
local function getPlayerNames()
    local list = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            table.insert(list, plr.Name)
        end
    end
    if #list == 0 then
        table.insert(list, "Нет игроков")
    end
    return list
end

local selectedTargetPlayer = nil

TeleportTab:Dropdown({
    Title = "Выберите игрока",
    Desc = "Список игроков на сервере",
    Values = getPlayerNames(),
    Callback = function(selected)
        selectedTargetPlayer = selected
    end
})

TeleportTab:Button({
    Title = "Teleport to (К игроку)",
    Desc = "Телепортирует к выбранному игроку",
    Callback = function()
        if not selectedTargetPlayer or selectedTargetPlayer == "Нет игроков" then
            WindUI:Notify({ Title = "Ошибка", Content = "Игрок не выбран!", Duration = 2 })
            return
        end
        
        local targetPlr = Players:FindFirstChild(selectedTargetPlayer)
        if targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart") then
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character.HumanoidRootPart.Anchored = false
                character.HumanoidRootPart.CFrame = targetPlr.Character.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
                WindUI:Notify({ Title = "Teleport", Content = "Успешный телепорт к " .. targetPlr.Name, Duration = 2 })
            end
        else
            WindUI:Notify({ Title = "Ошибка", Content = "Игрок недоступен или мертв.", Duration = 2 })
        end
    end
})

TeleportTab:Button({
    Title = "Обновить список игроков",
    Desc = "Нажмите, чтобы обновить ники в меню",
    Callback = function()
        WindUI:Notify({ Title = "Список", Content = "Список игроков актуален.", Duration = 2 })
    end
})

-- ==================== Вкладка Other ====================
local selectedItem = "Balloon"

OtherTab:Dropdown({
    Title = "Выбор предмета (Got)",
    Desc = "Выберите предмет для получения",
    Values = { "Balloon", "Speed Coil", "Jump Coil" },
    Default = "Balloon",
    Callback = function(selected)
        selectedItem = selected
    end
})

OtherTab:Button({
    Title = "Получить предмет",
    Desc = "Выдает выбранный предмет в инвентарь",
    Callback = function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local character = LocalPlayer.Character
        
        if not backpack or not character then 
            WindUI:Notify({ Title = "Ошибка", Content = "Персонаж не найден!", Duration = 2 })
            return 
        end

        local itemIds = {
            ["Balloon"] = 10468755,
            ["Speed Coil"] = 10468774,
            ["Jump Coil"] = 10468789
        }

        local assetId = itemIds[selectedItem]
        
        if assetId then
            local success, err = pcall(function()
                local model = game:GetObjects("rbxassetid://" .. tostring(assetId))[1]
                if model then
                    model.Parent = backpack
                    WindUI:Notify({ Title = "Got Item", Content = "Предмет " .. selectedItem .. " успешно выдан!", Duration = 2 })
                else
                    error("Model is nil")
                end
            end)
            
            if not success then
                WindUI:Notify({ Title = "Ошибка", Content = "Не удалось загрузить предмет.", Duration = 3 })
            end
        else
            WindUI:Notify({ Title = "Ошибка", Content = "Предмет не найден!", Duration = 2 })
        end
    end
})

-- ==================== Visuals ====================
VisualTab:Button({
    Title = "Полное освещение (Fullbright)",
    Desc = "Убирает темноту на картах",
    Callback = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        WindUI:Notify({ Title = "Visuals", Content = "Fullbright активирован!", Duration = 2 })
    end
})

-- ==================== Settings ====================
SettingsTab:Dropdown({
    Title = "Тема меню",
    Desc = "Переключение между черной и белой темой",
    Values = { "Dark (Черная)", "Light (Белая)" },
    Default = "Dark (Черная)",
    Callback = function(selected)
        if selected == "Dark (Черная)" then
            WindUI:SetTheme("Dark")
            WindUI:Notify({ Title = "Settings", Content = "Установлена черная тема", Duration = 2 })
        else
            WindUI:SetTheme("Light")
            WindUI:Notify({ Title = "Settings", Content = "Установлена белая тема", Duration = 2 })
        end
    end
})

SettingsTab:Paragraph({
    Title = "Информация о скрипте",
    Content = "Hoverly Hub — Natural Disaster Survival\nРазработчик (Author): villorders\nСтатус: Активен и стабилен"
})

