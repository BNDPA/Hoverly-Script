-- ============================================================================
-- Hoverly Hub Loader Script (Compact & Optimized)
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- Удаляем старый GUI, если он был
if CoreGui:FindFirstChild("HoverlyHubLoader") then
    CoreGui.HoverlyHubLoader:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoverlyHubLoader"
ScreenGui.Parent = CoreGui
ScreenGui.IgnoreGuiInset = true

-- Главное компактное закругленное окно (420x310)
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 420, 0, 310)
MainFrame.Position = UDim2.new(0.5, -210, 0.5, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

-- Скругление углов
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 14)
UICorner.Parent = MainFrame

-- Тонкая рамка окна
local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(35, 35, 35)
UIStroke.Thickness = 1.2
UIStroke.Parent = MainFrame

-- Контейнер для арта
local ArtContainer = Instance.new("Frame")
ArtContainer.Size = UDim2.new(1, -24, 0, 150)
ArtContainer.Position = UDim2.new(0, 12, 0, 12)
ArtContainer.BackgroundTransparency = 1
ArtContainer.ClipsDescendants = true
ArtContainer.Parent = MainFrame

-- ASCII Арт
local ArtLabel = Instance.new("TextLabel")
ArtLabel.Size = UDim2.new(1, 0, 1, 0)
ArtLabel.Position = UDim2.new(0, 0, 0, 0)
ArtLabel.BackgroundTransparency = 1
ArtLabel.TextColor3 = Color3.fromRGB(190, 190, 190)
ArtLabel.TextScaled = true
ArtLabel.TextSize = 10
ArtLabel.Font = Enum.Font.Code
ArtLabel.TextXAlignment = Enum.TextXAlignment.Center
ArtLabel.TextYAlignment = Enum.TextYAlignment.Center
ArtLabel.Text = [[
@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%
@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@
@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@
@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@
@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@
@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@
@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@
@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@
@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@
@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@
@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@
@@@@@@@@@@@@%%@@@@@@@@::::@@@@@@#::::@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@
@@@@@@@@@@@%%@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@
@@@@@@@@@@@%@@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@
@@@@@@@@@@@%@@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@
@@@@@@@@@@@%@@@@@@@@@@               @@@@@@@@%@@@@%@@@@@@@@@@@@@@@@@@%@@@@@@@@@@
@@@@@@@@@@%%@@@@@@@@@@               @*@*+@#@#%#%@*##@%@@@@@@@@@@@@@@%@@@@@@@@@@
@@@@@@@@@@%%@@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@
@@@@@@@@@@%@@@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@
@@@@@@@@@@%@@@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@
@@@@@@@@@%@@@@@@@@@@@@    @@@@@@#    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@
@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@
@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@
@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@
@@@%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@
%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@+#@@@@@=#@%=%#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
]]
ArtLabel.Parent = ArtContainer

-- Название "Hoverly Hub"
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 20)
TitleLabel.Position = UDim2.new(0, 0, 0, 170)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Hoverly Hub"
TitleLabel.Parent = MainFrame

-- Статус загрузки
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, 0, 0, 16)
StatusLabel.Position = UDim2.new(0, 0, 0, 192)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(130, 130, 130)
StatusLabel.TextSize = 10
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Loading configuration..."
StatusLabel.Parent = MainFrame

-- Полоска загрузки
local BarBackground = Instance.new("Frame")
BarBackground.Size = UDim2.new(0, 320, 0, 4)
BarBackground.Position = UDim2.new(0.5, -160, 0, 235)
BarBackground.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
BarBackground.BorderSizePixel = 0
BarBackground.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = BarBackground

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBackground

local FillCorner = Instance.new("UICorner")
FillCorner.CornerRadius = UDim.new(1, 0)
FillCorner.Parent = BarFill

-- Анимация
task.spawn(function()
    task.wait(0.3)
    StatusLabel.Text = "Initializing scripts..."
    TweenService:Create(BarFill, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.6, 0, 1, 0)}):Play()
    task.wait(1.0)
    
    StatusLabel.Text = "Bypassing security..."
    TweenService:Create(BarFill, TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0.85, 0, 1, 0)}):Play()
    task.wait(0.7)
    
    StatusLabel.Text = "Successfully loaded!"
    TweenService:Create(BarFill, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0)}):Play()
    task.wait(0.5)
    
    -- Плавное скрытие
    local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(MainFrame, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ArtContainer, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(ArtLabel, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(TitleLabel, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(StatusLabel, fadeInfo, {TextTransparency = 1}):Play()
    TweenService:Create(BarBackground, fadeInfo, {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, fadeInfo, {BackgroundTransparency = 1}):Play()
    UIStroke.Transparency = 1
    
    task.wait(0.5)
    ScreenGui:Destroy()
end)

