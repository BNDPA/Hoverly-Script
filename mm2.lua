-- Создание главного интерфейса в стиле современных библиотек
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Защита от повторного запуска
if CoreGui:FindFirstChild("MM2StyleMenu") then
    CoreGui.MM2StyleMenu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2StyleMenu"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -100)
MainFrame.Size = UDim2.new(0, 220, 0, 195)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Обводка (бордюр)
local UIStroke = Instance.new("UIStroke")
UIStroke.Parent = MainFrame
UIStroke.Color = Color3.fromRGB(45, 45, 55)
UIStroke.Thickness = 1.5

-- Шапка (для перетаскивания)
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = MainFrame
TopBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BorderSizePixel = 0

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 8)
TopBarCorner.Parent = TopBar

-- Исправление нижних углов шапки
local FixCorner = Instance.new("Frame")
FixCorner.Parent = TopBar
FixCorner.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
FixCorner.Position = UDim2.new(0, 0, 1, -5)
FixCorner.Size = UDim2.new(1, 0, 0, 5)
FixCorner.BorderSizePixel = 0

-- Заголовок меню
local Title = Instance.new("TextLabel")
Title.Parent = TopBar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 12, 0, 0)
Title.Size = UDim2.new(1, -12, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "Hoverly Hub"
Title.TextColor3 = Color3.fromRGB(240, 240, 245)
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Функция создания фиксированной стилизованной кнопки
local function createButton(text, posY)
    local btn = Instance.new("TextButton")
    btn.Name = text .. "Btn"
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
    btn.Position = UDim2.new(0, 12, 0, posY)
    btn.Size = UDim2.new(0, 196, 0, 36)
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.GothamMedium
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(200, 200, 210)
    btn.TextSize = 12

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Parent = btn
    stroke.Color = Color3.fromRGB(45, 45, 55)
    stroke.Thickness = 1

    -- Анимация наведения / нажатия
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 45), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color3 = Color3.fromRGB(80, 80, 110)}):Play()
    end)

    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 28, 35), TextColor3 = Color3.fromRGB(200, 200, 210)}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.2), {Color3 = Color3.fromRGB(45, 45, 55)}):Play()
    end)

    return btn
end

-- Создаем кнопки с точным отступом по вертикали (Y)
local LegitBtn = createButton("Legit", 46)
local SemiRageBtn = createButton("Semi-Rage", 90)
local RageBtn = createButton("Rage", 134)

-- Функция вывода всплывающего уведомления
local function showNotify(text)
    if MainFrame:FindFirstChild("NotifyText") then
        MainFrame.NotifyText:Destroy()
    end
    
    local notify = Instance.new("TextLabel")
    notify.Name = "NotifyText"
    notify.Parent = MainFrame
    notify.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    notify.Position = UDim2.new(0, 12, 1, -28)
    notify.Size = UDim2.new(0, 196, 0, 22)
    notify.Font = Enum.Font.Gotham
    notify.Text = text
    notify.TextColor3 = Color3.fromRGB(255, 140, 140)
    notify.TextSize = 11
    notify.BackgroundTransparency = 1
    
    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 4)
    nCorner.Parent = notify

    TweenService:Create(notify, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
    
    task.delay(1.5, function()
        if notify then
            TweenService:Create(notify, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.3)
            notify:Destroy()
        end
    end)
end

-- Логика кнопок
local REPO_URL = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/refs/heads/main/"

LegitBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy() -- Закрываем меню при нажатии[span_2](start_span)[span_2](end_span)
    pcall(function()
        loadstring(game:HttpGet(REPO_URL .. "mm2_legit.lua"))()
    end)
end)

SemiRageBtn.MouseButton1Click:Connect(function()
    showNotify("В разработке")
end)

RageBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy() -- Закрываем меню при нажатии[span_3](start_span)[span_3](end_span)
    pcall(function()
        loadstring(game:HttpGet(REPO_URL .. "mm2_rage.lua"))()
    end)
end)

-- Перетаскивание меню (для ПК и телефонов)
local dragging, dragInput, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function()
    if dragging and dragInput then
        local delta = dragInput.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)
