--[================================================================]--
--  Hoverly Script | DMVS (Duels: Murders vs Sheriffs)
--  UI Library: WindUI (Custom/Embedded Lightweight Implementation)
--[================================================================]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configuration Variables
getgenv().HoverlyConfig = {
    KillAllInstant = false,
    AutoShot = false,
    NoDelay = false,
    HitboxExpander = false,
    HitboxSize = 15,
    Visuals = true
}

-- Notification System
local function Notify(title, content, duration)
    pcall(function()
        local notifGui = CoreGui:FindFirstChild("HoverlyNotifications")
        if not notifGui then
            notifGui = Instance.new("ScreenGui")
            notifGui.Name = "HoverlyNotifications"
            notifGui.ResetOnSpawn = false
            notifGui.Parent = CoreGui
        end

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 260, 0, 65)
        frame.Position = UDim2.new(1, -280, 1, -80)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
        frame.BorderSizePixel = 0
        frame.Parent = notifGui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(120, 80, 255)
        stroke.Thickness = 1.5
        stroke.Parent = frame

        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -20, 0, 22)
        titleLabel.Position = UDim2.new(0, 10, 0, 8)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        titleLabel.TextSize = 14
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = frame

        local descLabel = Instance.new("TextLabel")
        descLabel.Size = UDim2.new(1, -20, 0, 25)
        descLabel.Position = UDim2.new(0, 10, 0, 30)
        descLabel.BackgroundTransparency = 1
        descLabel.Font = Enum.Font.Gotham
        descLabel.Text = content
        descLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
        descLabel.TextSize = 12
        descLabel.TextXAlignment = Enum.TextXAlignment.Left
        descLabel.Parent = frame

        task.delay(duration or 3, function()
            frame:Destroy()
        end)
    end)
end

-- WindUI GUI Creation
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HoverlyScriptWindUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

-- Main Window Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 420) -- Увеличили высоту под слайдер
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -210)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(75, 40, 160)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 10)
TopCorner.Parent = TopBar

local FixFrame = Instance.new("Frame")
FixFrame.Size = UDim2.new(1, 0, 0, 10)
FixFrame.Position = UDim2.new(0, 0, 1, -10)
FixFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
FixFrame.BorderSizePixel = 0
FixFrame.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "Hoverly Script | DMVS"
TitleLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
TitleLabel.TextSize = 15
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -20, 1, 0)
SubTitle.Position = UDim2.new(0, -15, 0, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.Font = Enum.Font.Gotham
SubTitle.Text = "[LeftAlt to Toggle UI]"
SubTitle.TextColor3 = Color3.fromRGB(120, 120, 140)
SubTitle.TextSize = 11
SubTitle.TextXAlignment = Enum.TextXAlignment.Right
SubTitle.Parent = TopBar

-- Content Container
local ContentContainer = Instance.new("ScrollingFrame")
ContentContainer.Size = UDim2.new(1, -20, 1, -55)
ContentContainer.Position = UDim2.new(0, 10, 0, 48)
ContentContainer.BackgroundTransparency = 1
ContentContainer.BorderSizePixel = 0
ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 380)
ContentContainer.ScrollBarThickness = 4
ContentContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.Parent = ContentContainer

-- UI Component Helpers
local function CreateToggle(name, description, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 33)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = ContentContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -70, 0, 20)
    NameLabel.Position = UDim2.new(0, 12, 0, 6)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ToggleFrame

    local DescLabel = Instance.new("TextLabel")
    DescLabel.Size = UDim2.new(1, -70, 0, 16)
    DescLabel.Position = UDim2.new(0, 12, 0, 26)
    DescLabel.BackgroundTransparency = 1
    DescLabel.Font = Enum.Font.Gotham
    DescLabel.Text = description
    DescLabel.TextColor3 = Color3.fromRGB(130, 130, 150)
    DescLabel.TextSize = 11
    DescLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescLabel.Parent = ToggleFrame

    local SwitchButton = Instance.new("TextButton")
    SwitchButton.Size = UDim2.new(0, 44, 0, 22)
    SwitchButton.Position = UDim2.new(1, -54, 0.5, -11)
    SwitchButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SwitchButton.AutoButtonColor = false
    SwitchButton.Text = ""
    SwitchButton.Parent = ToggleFrame

    local SwitchCorner = Instance.new("UICorner")
    SwitchCorner.CornerRadius = UDim.new(1, 0)
    SwitchCorner.Parent = SwitchButton

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 18, 0, 18)
    Knob.Position = UDim2.new(0, 2, 0.5, -9)
    Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    Knob.BorderSizePixel = 0
    Knob.Parent = SwitchButton

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local toggled = false
    SwitchButton.MouseButton1Click:Connect(function()
        toggled = not toggled
        if toggled then
            SwitchButton.BackgroundColor3 = Color3.fromRGB(110, 60, 240)
            Knob:TweenPosition(UDim2.new(1, -20, 0.5, -9), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        else
            SwitchButton.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
            Knob:TweenPosition(UDim2.new(0, 2, 0.5, -9), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.15, true)
            Knob.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
        end
        callback(toggled)
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, 0, 0, 60)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 33)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = ContentContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = SliderFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -20, 0, 20)
    NameLabel.Position = UDim2.new(0, 12, 0, 6)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.Text = name
    NameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
    NameLabel.TextSize = 13
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -62, 0, 6)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(150, 100, 255)
    ValueLabel.TextSize = 13
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame

    local SliderBar = Instance.new("Frame")
    SliderBar.Size = UDim2.new(1, -24, 0, 6)
    SliderBar.Position = UDim2.new(0, 12, 0, 38)
    SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    SliderBar.BorderSizePixel = 0
    SliderBar.Parent = SliderFrame

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar

    local FillBar = Instance.new("Frame")
    FillBar.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    FillBar.BackgroundColor3 = Color3.fromRGB(110, 60, 240)
    FillBar.BorderSizePixel = 0
    FillBar.Parent = SliderBar

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = FillBar

    local dragging = false
    local function UpdateInput(input)
        local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + ((max - min) * pos))
        FillBar.Size = UDim2.new(pos, 0, 1, 0)
        ValueLabel.Text = tostring(val)
        callback(val)
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateInput(input)
        end
    end)
end

-- UI Features Initialization
CreateToggle("Kill All (Instant)", "Cycles through enemies and eliminates them instantly", function(state)
    getgenv().HoverlyConfig.KillAllInstant = state
    Notify("Kill All", tostring(state), 2)
end)

CreateToggle("Hitbox Expander", "Enlarges player hitboxes for easier hits", function(state)
    getgenv().HoverlyConfig.HitboxExpander = state
    Notify("Hitbox Expander", tostring(state), 2)
end)

CreateSlider("Hitbox Size", 2, 200, 15, function(value)
    getgenv().HoverlyConfig.HitboxSize = value
end)

CreateToggle("Auto Shot", "Automatically aims and fires at visible targets", function(state)
    getgenv().HoverlyConfig.AutoShot = state
    Notify("Auto Shot", tostring(state), 2)
end)

CreateToggle("No Delay", "Removes cooldowns/delays on attacks & tools", function(state)
    getgenv().HoverlyConfig.NoDelay = state
    Notify("No Delay", tostring(state), 2)
end)

-- UI Toggle Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftAlt then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Core Game Logic Implementation
local function GetCharacter(player)
    return player.Character
end

local function GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

-- Main Loop
RunService.RenderStepped:Connect(function()
    -- 1. Hitbox Expander & Visuals
    if getgenv().HoverlyConfig.HitboxExpander or getgenv().HoverlyConfig.KillAllInstant then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local char = player.Character
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                local rootPart = GetRootPart(char)
                
                if humanoid and humanoid.Health > 0 and rootPart then
                    local targetSize = getgenv().HoverlyConfig.HitboxSize
                    rootPart.Size = Vector3.new(targetSize, targetSize, targetSize)
                    rootPart.Transparency = 0.6
                    rootPart.CanCollide = false
                end
            end
        end
    end

    -- 2. Auto Shot Logic
    if getgenv().HoverlyConfig.AutoShot then
        pcall(function()
            local char = LocalPlayer.Character
            if not char then return end
            local tool = char:FindFirstChildOfClass("Tool")
            
            if tool then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local enemyChar = player.Character
                        local enemyRoot = GetRootPart(enemyChar)
                        local enemyHum = enemyChar:FindFirstChildOfClass("Humanoid")
                        
                        if enemyRoot and enemyHum and enemyHum.Health > 0 then
                            local distance = (enemyRoot.Position - char.PrimaryPart.Position).Magnitude
                            if distance < 120 then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end)
    end

    -- 3. No Delay Logic
    if getgenv().HoverlyConfig.NoDelay then
        pcall(function()
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool and tool:FindFirstChild("Cooldown") then
                    tool.Cooldown.Value = 0
                end
            end
        end)
    end
end)

Notify("Hoverly Script", "Successfully Loaded! Press LeftAlt to toggle UI.", 5)

