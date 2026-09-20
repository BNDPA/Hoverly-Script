--[================================================================]--
--  Hoverly Script | DMVS (Duels: Murders vs Sheriffs)
--  UI Library: Official WindUI Integration
--[================================================================]--

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration Variables
getgenv().HoverlyConfig = {
    KillAllInstant = false,
    AutoShot = false,
    NoDelay = false,
    HitboxExpander = false,
    HitboxSize = 15,
}

-- Load WindUI Library securely
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
end)

if not success or not WindUI then
    -- Fallback Notification if WindUI fails to load
    local CoreGui = game:GetService("CoreGui")
    local notif = Instance.new("ScreenGui")
    notif.Parent = CoreGui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 400, 0, 50)
    label.Position = UDim2.new(0.5, -200, 0, 20)
    label.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Text = "Failed to load WindUI! Check your executor or internet connection."
    label.Parent = notif
    task.wait(5)
    notif:Destroy()
    return
end

-- Create Window using WindUI
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | DMVS",
    Icon = "rbxassetid://10734950309", -- Иконка (опционально)
    Author = "Duels: Murders vs Sheriffs",
    Folder = "HoverlyScriptDMVS",
    Size = UDim2.fromOffset(500, 380),
    KeySystem = false,
})

-- Create Tabs
local MainTab = Window:Tab({
    Title = "Main / Combat",
    Icon = "rbxassetid://10734950309",
})

-- Toggles and Sliders inside WindUI
MainTab:Toggle({
    Title = "Kill All (Instant)",
    Description = "Cycles through enemies and eliminates them instantly",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.KillAllInstant = state
    end
})

MainTab:Toggle({
    Title = "Hitbox Expander",
    Description = "Enlarges player hitboxes based on slider value",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.HitboxExpander = state
    end
})

MainTab:Slider({
    Title = "Hitbox Size",
    Description = "Max size up to 200",
    Default = 15,
    Min = 2,
    Max = 200,
    Step = 1,
    Callback = function(value)
        getgenv().HoverlyConfig.HitboxSize = value
    end
})

MainTab:Toggle({
    Title = "Auto Shot",
    Description = "Automatically aims and fires at visible targets",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.AutoShot = state
    end
})

MainTab:Toggle({
    Title = "No Delay",
    Description = "Removes cooldowns/delays on attacks & tools",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.NoDelay = state
    end
})

-- Core Game Logic Loop
local function GetRootPart(character)
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso"))
end

RunService.RenderStepped:Connect(function()
    -- 1. Hitbox Expander & Kill All Logic
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

WindUI:Notify({
    Title = "Hoverly Script",
    Content = "Successfully loaded with WindUI library!",
    Duration = 5
})

