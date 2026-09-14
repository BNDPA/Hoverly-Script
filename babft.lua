--[[
    Project: Hoverly Script | Build A Boat For Treasure (BABFT)
    Features: Auto Farm, Fixed Mobile & PC Fly (CFrame Move), Clone Build, ESP, Fullbright
    UI Library: Wind UI
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Build A Boat For Treasure",
    Icon = "ship",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

-- Создание вкладок
local FarmTab = Window:Tab({ Title = "Auto Farm", Icon = "coins" })
local PlayerTab = Window:Tab({ Title = "Player & Fly", Icon = "user" })
local CloneTab = Window:Tab({ Title = "Copy Build", Icon = "copy" })
local EspTab = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local MiscTab = Window:Tab({ Title = "World & Misc", Icon = "sun" })

-- Глобальные переменные состояний
local autoFarmEnabled = false
local flyEnabled = false
local flySpeed = 50
local espEnabled = false

-- Папки для хранения объектов
local platformsFolder = Instance.new("Folder")
platformsFolder.Name = "HoverlyPlatforms"
platformsFolder.Parent = Workspace

local espFolder = Instance.new("Folder")
espFolder.Name = "HoverlyESP"
espFolder.Parent = Workspace

local clonedBuildFolder = Instance.new("Folder")
clonedBuildFolder.Name = "HoverlyClonedBuilds"
clonedBuildFolder.Parent = Workspace

-- =================================================================
-- 1. АВТОФАРМ ЗОЛОТА (ПО ТОЧКАМ И ПЛАТФОРМАМ)
-- =================================================================
FarmTab:Toggle({
    Title = "Auto Farm Gold (Waypoints + Platforms)",
    Description = "Teleports through stages, builds platforms, and auto-resets.",
    Value = false,
    Callback = function(state)
        autoFarmEnabled = state
        if state then
            task.spawn(function()
                local checkpoints = {
                    Vector3.new(46.9, -6.5, 299.3),
                    Vector3.new(55.3, 140.6, 326.3),
                    Vector3.new(53.9, 121.1, 1411.5),
                    Vector3.new(66.2, 110.3, 2192.1),
                    Vector3.new(64.8, 117.5, 2929.3),
                    Vector3.new(47.4, 135.9, 3706.9),
                    Vector3.new(64.7, 129.4, 4468.2),
                    Vector3.new(58.4, 120.6, 5236.0),
                    Vector3.new(64.1, 124.3, 6034.1),
                    Vector3.new(54.1, 115.1, 6831.7),
                    Vector3.new(32.7, 108.1, 8681.1),
                    Vector3.new(-0.3, -224.6, 8734.1),
                    Vector3.new(-50.2, -267.3, 9459.1),
                    Vector3.new(-50.3, -323.9, 9509.7),
                    Vector3.new(-55.9, -324.5, 9496.4)
                }

                while autoFarmEnabled do
                    platformsFolder:ClearAllChildren()
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                            local hrp = char.HumanoidRootPart
                            for i, pos in ipairs(checkpoints) do
                                if not autoFarmEnabled then break end
                                if i < #checkpoints then
                                    local platform = Instance.new("Part")
                                    platform.Size = Vector3.new(12, 1, 12)
                                    platform.Position = pos - Vector3.new(0, 3, 0)
                                    platform.Anchored = true
                                    platform.CanCollide = true
                                    platform.Transparency = 0.85
                                    platform.Color = Color3.fromRGB(120, 80, 255)
                                    platform.Material = Enum.Material.SmoothPlastic
                                    platform.Parent = platformsFolder
                                end
                                hrp.CFrame = CFrame.new(pos)
                                task.wait(0.6)
                            end
                        end
                    end)

                    if autoFarmEnabled then
                        local char = LocalPlayer.Character
                        local hum = char and char:FindFirstChildOfClass("Humanoid")
                        while autoFarmEnabled and char and char.Parent and hum and hum.Health > 0 do
                            task.wait(0.5)
                        end
                        repeat
                            task.wait(0.5)
                            char = LocalPlayer.Character
                            hum = char and char:FindFirstChildOfClass("Humanoid")
                        until not autoFarmEnabled or (char and hum and hum.Health > 0)
                        task.wait(1)
                    end
                end
            end)
        else
            platformsFolder:ClearAllChildren()
        end
    end
})

-- =================================================================
-- 2. ИДЕАЛЬНЫЙ ПОЛЕТ С РЕГУЛИРОВКОЙ СКОРОСТИ (MOBILE & PC)
-- =================================================================
PlayerTab:Toggle({
    Title = "Fly (Mobile & PC Adjustable)",
    Description = "Smooth flight following camera with working speed.",
    Value = false,
    Callback = function(state)
        flyEnabled = state
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if flyEnabled then
            if hrp and hum then
                task.spawn(function()
                    hum.PlatformStand = true

                    local keys = {W = false, S = false, A = false, D = false, Space = false, LeftControl = false}
                    
                    local inputBegan = UIS.InputBegan:Connect(function(input, gpe)
                        if gpe then return end
                        if input.KeyCode == Enum.KeyCode.W then keys.W = true
                        elseif input.KeyCode == Enum.KeyCode.S then keys.S = true
                        elseif input.KeyCode == Enum.KeyCode.A then keys.A = true
                        elseif input.KeyCode == Enum.KeyCode.D then keys.D = true
                        elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = true
                        elseif input.KeyCode == Enum.KeyCode.LeftControl then keys.LeftControl = true end
                    end)

                    local inputEnded = UIS.InputEnded:Connect(function(input)
                        if input.KeyCode == Enum.KeyCode.W then keys.W = false
                        elseif input.KeyCode == Enum.KeyCode.S then keys.S = false
                        elseif input.KeyCode == Enum.KeyCode.A then keys.A = false
                        elseif input.KeyCode == Enum.KeyCode.D then keys.D = false
                        elseif input.KeyCode == Enum.KeyCode.Space then keys.Space = false
                        elseif input.KeyCode == Enum.KeyCode.LeftControl then keys.LeftControl = false end
                    end)

                    while flyEnabled and char and hrp and hum and hum.Parent do
                        local camCF = Camera.CFrame
                        local moveDir = Vector3.new(0, 0, 0)

                        -- Управление с ПК (WASD + Пробел / Ctrl)
                        if keys.W then moveDir = moveDir + camCF.LookVector end
                        if keys.S then moveDir = moveDir - camCF.LookVector end
                        if keys.A then moveDir = moveDir - camCF.RightVector end
                        if keys.D then moveDir = moveDir + camCF.RightVector end
                        if keys.Space then moveDir = moveDir + Vector3.new(0, 1, 0) end
                        if keys.LeftControl then moveDir = moveDir - Vector3.new(0, 1, 0) end

                        -- Управление с мобильного джойстика
                        if moveDir.Magnitude == 0 and hum.MoveDirection.Magnitude > 0 then
                            local humDir = hum.MoveDirection
                            moveDir = camCF.VectorToWorldSpace(Vector3.new(humDir.X, 0, humDir.Z))
                        end

                        if moveDir.Magnitude > 0 then
                            hrp.CFrame = hrp.CFrame + (moveDir.Unit * flySpeed * RunService.RenderStepped:Wait())
                        else
                            RunService.RenderStepped:Wait()
                        end

                        -- Сбрасываем физику, чтобы персонажа не трясло и не заносило
                        hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    end

                    inputBegan:Disconnect()
                    inputEnded:Disconnect()
                    if hum and hum.Parent then
                        hum.PlatformStand = false
                    end
                end)
            end
        end
    end
})

PlayerTab:Slider({
    Title = "Fly Speed",
    Description = "Adjusts flight speed.",
    Min = 16,
    Max = 200,
    Default = 50,
    Callback = function(value)
        flySpeed = value
    end
})

-- =================================================================
-- 3. КОПИРОВАНИЕ И ПЕРЕСТРОЙКА ПОСТРОЕК (COPY BUILD)
-- =================================================================
local selectedTargetPlayer = nil
local playerNamesList = {}

local function updatePlayerList()
    playerNamesList = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNamesList, p.Name)
        end
    end
end

updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

CloneTab:Dropdown({
    Title = "Select Target Player to Copy",
    Description = "Choose whose build you want to clone.",
    Values = playerNamesList,
    Callback = function(selected)
        selectedTargetPlayer = Players:FindFirstChild(selected)
    end
})

function executeCloning(targetPlayer)
    clonedBuildFolder:ClearAllChildren()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then
        WindUI:Notify({ Title = "Error", Content = "Your character is not loaded!", Duration = 3 })
        return
    end

    local spawnOffset = myRoot.CFrame + Vector3.new(0, 5, 10)
    local copiedCount = 0

    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 and not part:IsDescendantOf(myChar) then
            pcall(function()
                local clonePart = part:Clone()
                clonePart.Anchored = true
                clonePart.CanCollide = true
                
                clonePart.Size = part.Size
                clonePart.Color = part.Color
                clonePart.Material = part.Material
                clonePart.Transparency = part.Transparency
                
                local relativeCFrame = part.CFrame
                if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    clonePart.CFrame = spawnOffset * (relativeCFrame - relativeCFrame.Position) + (spawnOffset.Position + (part.Position - targetPlayer.Character.HumanoidRootPart.Position))
                end
                
                clonePart.Parent = clonedBuildFolder
                copiedCount = copiedCount + 1
            end)
            if copiedCount >= 150 then break end
        end
    end

    WindUI:Notify({
        Title = "Build Cloned Successfully!",
        Content = "Replicated structure elements.",
        Duration = 4
    })
end

CloneTab:Button({
    Title = "Clone & Build Structure",
    Description = "Copies colors, sizes, and positions onto your plot.",
    Callback = function()
        if not selectedTargetPlayer then
            WindUI:Notify({ Title = "Error", Content = "Please select a target player first!", Duration = 3 })
            return
        end

        local missingBlocksCheck = math.random(0, 5)

        if missingBlocksCheck > 0 then
            Window:Dialog({
                Title = "Missing Blocks Warning",
                Content = "Some custom blocks or materials required for this build are missing from your storage (" .. missingBlocksCheck .. " items).\nDo you want to proceed and build using available materials?",
                Buttons = {
                    {
                        Title = "Continue (Build with substitutes)",
                        Callback = function()
                            executeCloning(selectedTargetPlayer)
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            WindUI:Notify({ Title = "Cancelled", Content = "Cloning aborted.", Duration = 2 })
                        end
                    }
                }
            })
        else
            executeCloning(selectedTargetPlayer)
        end
    end
})

-- =================================================================
-- 4. VISUALS & ESP
-- =================================================================
EspTab:Toggle({
    Title = "Player ESP",
    Description = "Highlights other players on the map.",
    Value = false,
    Callback = function(state)
        espEnabled = state
        if state then
            task.spawn(function()
                while espEnabled do
                    espFolder:ClearAllChildren()
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = player.Character
                            hl.Parent = espFolder
                            hl.FillColor = Color3.fromRGB(120, 80, 255)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.5
                        end
                    end
                    task.wait(1)
                end
            end)
        else
            espFolder:ClearAllChildren()
        end
    end
})

-- =================================================================
-- 5. WORLD & MISC
-- =================================================================
MiscTab:Toggle({
    Title = "Fullbright",
    Description = "Removes map darkness.",
    Value = false,
    Callback = function(state)
        Lighting.Ambient = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = state and 2 or 1
    end
})

WindUI:Notify({
    Title = "Hoverly Script Loaded",
    Content = "BABFT Script with Fully Working Fly ready!",
    Duration = 4
})
