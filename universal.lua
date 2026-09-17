-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- =========================================================================
-- НАСТРОЙКА СТАТИСТИКИ (COUNTAPI)
-- =========================================================================
local NAMESPACE = "hoverlyhub_bndpa_universal_2026"

local function HitStat(key)
    pcall(function()
        game:HttpGet("https://api.countapi.xyz/hit/" .. NAMESPACE .. "/" .. key, true)
    end)
end

local function GetStat(key)
    local success, result = pcall(function()
        local response = game:HttpGet("https://api.countapi.xyz/get/" .. NAMESPACE .. "/" .. key, true)
        local data = HttpService:JSONDecode(response)
        return data and data.value or 0
    end)
    return success and result or 0
end

-- Регистрируем запуск универсального скрипта
HitStat("total_hub")

-- =========================================================================
-- СОЗДАНИЕ ОКНА (Hoverly Script | Universal)
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Universal",
    Icon = "compass",
    Author = "BNDPA",
    Folder = "HoverlyUniversal",
    Size = UDim2.fromOffset(560, 400),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 175,
    HasOutline = true,
})

-- =========================================================================
-- ВКЛАДКА: ГЛАВНАЯ / СТАТИСТИКА
-- =========================================================================
local MainTab = Window:Tab({
    Title = "Главная",
    Icon = "home",
})

MainTab:Paragraph({
    Title = "Hoverly Script Loaded",
    Desc = "Универсальный скрипт успешно активирован. Все основные модули готовы к работе.",
})

local TotalPara = MainTab:Paragraph({
    Title = "Статистика пользователей",
    Desc = "Загрузка...",
})

task.spawn(function()
    while true do
        local total = GetStat("total_hub")
        pcall(function()
            TotalPara:SetDesc("Всего запусков скрипта: **" .. tostring(total) .. "** чел.")
        end)
        task.wait(5)
    end
end)

-- =========================================================================
-- ВКЛАДКА: COMBAT (Аимбот, Триггербот)
-- =========================================================================
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "crosshair",
})

local AimbotEnabled = false
local TriggerbotEnabled = false
local NoDelayEnabled = false

CombatTab:Toggle({
    Title = "Аимбот (Ближайший игрок)",
    Default = false,
    Callback = function(state)
        AimbotEnabled = state
    end
})

CombatTab:Toggle({
    Title = "Триггербот (Авто-клик при наведении)",
    Default = false,
    Callback = function(state)
        TriggerbotEnabled = state
    end
})

CombatTab:Toggle({
    Title = "No-Delay (Убрать задержку ударов/оружия)",
    Default = false,
    Callback = function(state)
        NoDelayEnabled = state
        -- Логика No-Delay (если поддерживается инструментом)
        local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        if tool and tool:FindFirstChild("Cooldown") then
            -- Пример отключения стандартных кулдаунов, если они есть в инструменте
            pcall(function() tool.Cooldown.Value = 0 end)
        end
    end
})

-- Логика Аимбота и Триггербота в реальном времени
RunService.RenderStepped:Connect(function()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local mouse = LocalPlayer:GetMouse()
    local target = mouse.Target
    
    -- Триггербот (если курсор наведен на персонажа другого игрока)
    if TriggerbotEnabled and target and target.Parent then
        local enemyModel = target.Parent
        local humanoid = enemyModel:FindFirstChildOfClass("Humanoid")
        if humanoid and Players:GetPlayerFromCharacter(enemyModel) and Players:GetPlayerFromCharacter(enemyModel) ~= LocalPlayer then
            pcall(function()
                mouse1click() -- Симуляция клика мышкой
            end)
        end
    end
    
    -- Аимбот (плавное наведение на голову ближайшего врага)
    if AimbotEnabled then
        local closestDist = math.huge
        local targetPart = nil
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local screenPoint, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local mousePos = Vector2.new(mouse.X, mouse.Y)
                    local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        targetPart = head
                    end
                end
            end
        end
        
        if targetPart then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
        end
    end
end)

-- =========================================================================
-- ВКЛАДКА: VISUALS (ESP)
-- =========================================================================
local VisualsTab = Window:Tab({
    Title = "Visuals",
    Icon = "eye",
})

local EspEnabled = false

VisualsTab:Toggle({
    Title = "ESP (Подсветка игроков)",
    Default = false,
    Callback = function(state)
        EspEnabled = state
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local highlight = player.Character:FindFirstChild("HoverlyESP")
                if state and not highlight then
                    local hl = Instance.new("Highlight")
                    hl.Name = "HoverlyESP"
                    hl.Adornee = player.Character
                    hl.FillColor = Color3.fromRGB(255, 50, 50)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = player.Character
                elseif not state and highlight then
                    highlight:Destroy()
                end
            end
        end
    end
})

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if EspEnabled then
            task.wait(1)
            local hl = Instance.new("Highlight")
            hl.Name = "HoverlyESP"
            hl.Adornee = char
            hl.FillColor = Color3.fromRGB(255, 50, 50)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = char
        end
    end)
end)

-- =========================================================================
-- ВКЛАДКА: PLAYER (Скорость, Прыжок, Ноуклип, Флай, Инфинити Джамп)
-- =========================================================================
local PlayerTab = Window:Tab({
    Title = "Player",
    Icon = "user",
})

-- Скорость
local WalkspeedEnabled = false
local CustomWalkspeed = 16

PlayerTab:Toggle({
    Title = "Включить кастомную скорость",
    Default = false,
    Callback = function(state)
        WalkspeedEnabled = state
    end
})

PlayerTab:Slider({
    Title = "Скорость бега (WalkSpeed)",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        CustomWalkspeed = value
    end
})

-- Сила прыжка
local JumppowerEnabled = false
local CustomJumppower = 50

PlayerTab:Toggle({
    Title = "Включить кастомный прыжок",
    Default = false,
    Callback = function(state)
        JumppowerEnabled = state
    end
})

PlayerTab:Slider({
    Title = "Сила прыжка (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(value)
        CustomJumppower = value
    end
})

-- Применение скорости и прыжка
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid
        if WalkspeedEnabled then
            humanoid.WalkSpeed = CustomWalkspeed
        end
        if JumppowerEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = CustomJumppower
        end
    end
end)

-- Бесконечный прыжок
local InfiniteJumpEnabled = false
PlayerTab:Toggle({
    Title = "Бесконечный прыжок (Infinite Jump)",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Ноуклип (Хождение сквозь стены)
local NoclipEnabled = false
PlayerTab:Toggle({
    Title = "Ноуклип (Noclip)",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
    end
})

RunService.Stepped:Connect(function()
    if NoclipEnabled and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Флай (Полет)
local FlyEnabled = false
local flySpeed = 50
local bg, bv

PlayerTab:Toggle({
    Title = "Полет (Fly)",
    Default = false,
    Callback = function(state)
        FlyEnabled = state
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        if FlyEnabled then
            local rootPart = char.HumanoidRootPart
            bg = Instance.new("BodyGyro", rootPart)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e4, 9e4, 9e4)
            bg.cframe = rootPart.CFrame
            
            bv = Instance.new("BodyVelocity", rootPart)
            bv.velocity = Vector3.new(0, 0, 0)
            bv.maxForce = Vector3.new(9e4, 9e4, 9e4)
            
            task.spawn(function()
                while FlyEnabled and char and char:FindFirstChild("HumanoidRootPart") do
                    local camCFrame = Camera.CFrame
                    local moveDir = Vector3.new(0,0,0)
                    
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camCFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camCFrame.RightVector end
                    
                    bv.velocity = moveDir * flySpeed
                    bg.cframe = camCFrame
                    RunService.RenderStepped:Wait()
                end
                if bg then bg:Destroy() end
                if bv then bv:Destroy() end
            end)
        else
            if bg then bg:Destroy() end
            if bv then bv:Destroy() end
        end
    end
})

PlayerTab:Slider({
    Title = "Скорость полета",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(value)
        flySpeed = value
    end
})

-- =========================================================================
-- ВКЛАДКА: INFO
-- =========================================================================
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Paragraph({
    Title = "Hoverly Script | Universal",
    Desc = "Создатель: BNDPA\nИнтерфейс: WindUI\nСтатусы функций: Активны в реальном времени.",
})

local LiveOnlinePara = InfoTab:Paragraph({
    Title = "Онлайн пользователей",
    Desc = "Загрузка...",
})

task.spawn(function()
    while true do
        local total = GetStat("total_hub")
        pcall(function()
            LiveOnlinePara:SetDesc("Всего игроков используют универсальный скрипт: **" .. tostring(total) .. "**")
        end)
        task.wait(5)
    end
end)

Window:SelectTab(1)
