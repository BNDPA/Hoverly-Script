--[[
    Project: Hoverly Script | Murder Mystery 2
    UI Library: Wind UI (Final Version with Auto Shoot & Keybind)
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local WorkspaceCamera = Workspace.CurrentCamera

local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Murder Mystery 2",
    Icon = "terminal",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

local MainTab = Window:Tab({ Title = "Main & Visuals", Icon = "eye" })
local FarmTab = Window:Tab({ Title = "Auto Farm & Coins", Icon = "coins" })
local CombatTab = Window:Tab({ Title = "Combat & Aura", Icon = "crosshair" })
local TrollTab = Window:Tab({ Title = "Troll & Misc", Icon = "user-x" })
local WorldTab = Window:Tab({ Title = "World Settings", Icon = "sun" })

local espEnabled = false
local autoFarmEnabled = false
local autoFarmSpeed = 85
local smartAimbotEnabled = false
local killAuraEnabled = false
local antiFlingEnabled = false
local autoShootKey = Enum.KeyCode.E -- Дефолтный бинд (клавиша E)
local highlights = {}
local nameTags = {}

local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")

    local hasKnife = (backpack and backpack:FindFirstChild("Knife")) or char:FindFirstChild("Knife")
    local hasGun = (backpack and backpack:FindFirstChild("Gun")) or char:FindFirstChild("Gun")

    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

local function getRoleColor(player)
    local role = getRole(player)
    if role == "Murderer" then return Color3.fromRGB(255, 45, 45) end
    if role == "Sheriff" then return Color3.fromRGB(45, 130, 255) end
    return Color3.fromRGB(50, 220, 100)
end

local function removeESP(player)
    if highlights[player] then highlights[player]:Destroy() highlights[player] = nil end
    if nameTags[player] then nameTags[player]:Destroy() nameTags[player] = nil end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    if not player.Character then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = player.Character
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0.1
    highlight.Enabled = espEnabled
    highlight.Parent = LocalPlayer:WaitForChild("PlayerGui")
    highlights[player] = highlight

    local head = player.Character:FindFirstChild("Head")
    if head then
        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = head
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Enabled = espEnabled

        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = player.DisplayName
        textLabel.TextColor3 = getRoleColor(player)
        textLabel.TextStrokeTransparency = 0.2
        textLabel.TextSize = 11
        textLabel.Font = Enum.Font.GothamBold
        textLabel.Parent = billboard
        
        billboard.Parent = LocalPlayer.PlayerGui
        nameTags[player] = billboard
    end
end

RunService.Heartbeat:Connect(function()
    if not espEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local color = getRoleColor(p)
            if highlights[p] then
                highlights[p].FillColor = color
                highlights[p].OutlineColor = color
            end
            if nameTags[p] and nameTags[p]:FindFirstChildOfClass("TextLabel") then
                nameTags[p]:FindFirstChildOfClass("TextLabel").TextColor3 = color
            end
        end
    end
end)

-- === 1. TAB: MAIN & VISUALS ===
MainTab:Toggle({
    Title = "Player & Role ESP",
    Description = "Highlights players and dynamically updates roles.",
    Value = false,
    Callback = function(state)
        espEnabled = state
        for _, highlight in pairs(highlights) do if highlight then highlight.Enabled = espEnabled end end
        for _, tag in pairs(nameTags) do if tag then tag.Enabled = espEnabled end end
        if state then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then applyESP(p) end
            end
        end
    end
})

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if p.Character then applyESP(p) end
        p.CharacterAdded:Connect(function() task.wait(1) applyESP(p) end)
        p.CharacterRemoving:Connect(function() removeESP(p) end)
    end
end
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(1) applyESP(p) end)
    p.CharacterRemoving:Connect(function() removeESP(p) end)
end)

-- === 2. TAB: AUTO FARM & COINS ===
FarmTab:Toggle({
    Title = "Auto Farm Coins (With Noclip)",
    Description = "Smoothly flies directly to coins without obstacles.",
    Value = false,
    Callback = function(state)
        autoFarmEnabled = state
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
})

FarmTab:Dropdown({
    Title = "Farm Speed",
    Values = {"Slow", "Medium", "Fast"},
    Default = "Fast",
    Callback = function(selected)
        if selected == "Slow" then autoFarmSpeed = 40
        elseif selected == "Medium" then autoFarmSpeed = 60
        elseif selected == "Fast" then autoFarmSpeed = 85 end
    end
})

local function getClosestCoin()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local closestCoin = nil
    local minDistance = math.huge

    for _, object in ipairs(Workspace:GetDescendants()) do
        if object.Name == "CoinContainer" or object.Name == "Coin" or object.Name == "CoinServer" then
            local coinPart = object:IsA("BasePart") and object or object:FindFirstChildWhichIsA("BasePart")
            if coinPart and coinPart.Parent then
                local dist = (hrp.Position - coinPart.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestCoin = coinPart
                end
            end
        end
    end
    return closestCoin
end

RunService.Heartbeat:Connect(function(dt)
    if not autoFarmEnabled then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hrp and hum and hum.Health > 0 then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        local targetCoin = getClosestCoin()
        if targetCoin and targetCoin.Parent then
            local targetPos = targetCoin.Position
            local currentPos = hrp.Position
            local distance = (currentPos - targetPos).Magnitude
            
            if distance > 1 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(targetPos), math.min(dt * (autoFarmSpeed / 10), 1))
            end
        end
    end
end)

-- === 3. TAB: COMBAT & AURA ===
CombatTab:Toggle({
    Title = "Smart Role Aimbot (Wallcheck)",
    Description = "Automatically aims at the enemy role.",
    Value = false,
    Callback = function(state)
        smartAimbotEnabled = state
    end
})

CombatTab:Toggle({
    Title = "Murderer Kill Aura",
    Description = "Automatically stabs targets in a 5-stud radius.",
    Value = false,
    Callback = function(state)
        killAuraEnabled = state
    end
})

-- Функция авто-выстрела за Шерифа
local function shootMurderer()
    local myRole = getRole(LocalPlayer)
    if myRole ~= "Sheriff" then
        WindUI:Notify({ Title = "Auto Shoot", Content = "You are not the Sheriff!", Duration = 3 })
        return
    end

    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not myHum or myHum.Health <= 0 then return end

    -- Ищем пистолет в инвентаре или руках
    local gun = myChar:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
    if not gun then
        WindUI:Notify({ Title = "Auto Shoot", Content = "Gun not found!", Duration = 3 })
        return
    end

    if gun.Parent ~= myChar then myHum:EquipTool(gun) end

    -- Ищем Мардера на карте
    local murdererPlayer = nil
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and getRole(p) == "Murderer" then
            murdererPlayer = p
            break
        end
    end

    if murdererPlayer and murdererPlayer.Character then
        local targetHRP = murdererPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            -- Направляем камеру на мардера и стреляем
            WorkspaceCamera.CFrame = CFrame.new(WorkspaceCamera.CFrame.Position, targetHRP.Position)
            task.wait(0.05)
            pcall(function()
                gun:Activate()
                if gun:FindFirstChild("Shoot") then
                    gun.Shoot:FireServer(targetHRP.Position)
                end
            end)
            WindUI:Notify({ Title = "Auto Shoot", Content = "Shot fired at Murderer!", Duration = 2 })
        end
    else
        WindUI:Notify({ Title = "Auto Shoot", Content = "Murderer not found!", Duration = 2 })
    end
end

CombatTab:Button({
    Title = "Auto Shoot Murderer (Instant)",
    Description = "Equips gun and shoots the murderer instantly.",
    Callback = function()
        shootMurderer()
    end
})

CombatTab:Keybind({
    Title = "Auto Shoot Keybind",
    Description = "Press this key to shoot the murderer.",
    Value = Enum.KeyCode.E,
    Callback = function(key)
        autoShootKey = key
    end
})

-- Обработчик нажатия бинда для выстрела
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == autoShootKey then
        shootMurderer()
    end
end)

CombatTab:Button({
    Title = "Kill All (Murder Only)",
    Description = "Stays in place and instantly eliminates all targets.",
    Callback = function()
        local myRole = getRole(LocalPlayer)
        if myRole ~= "Murderer" then
            WindUI:Notify({ Title = "Error", Content = "You are not the Murderer!", Duration = 3 })
            return
        end

        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
        
        if not myHRP or not myHum or myHum.Health <= 0 then return end

        local knife = myChar:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
        if not knife then
            WindUI:Notify({ Title = "Error", Content = "Knife not found in inventory!", Duration = 3 })
            return
        end

        if knife.Parent ~= myChar then myHum:EquipTool(knife) end

        local originalCFrame = myHRP.CFrame
        
        for _, part in ipairs(myChar:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end

        task.spawn(function()
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                    local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                    
                    if targetHRP and targetHum and targetHum.Health > 0 then
                        myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1.5)
                        task.wait(0.1)
                        
                        pcall(function()
                            knife:Activate()
                            if knife:FindFirstChild("Stab") then
                                knife.Stab:FireServer()
                            end
                        end)
                        task.wait(0.15)
                    end
                end
            end

            myHRP.CFrame = originalCFrame
            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            
            for _, part in ipairs(myChar:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end

            WindUI:Notify({
                Title = "Kill All Completed",
                Content = "All targets eliminated successfully!",
                Duration = 3
            })
        end)
    end
})

task.spawn(function()
    while task.wait(0.05) do
        if killAuraEnabled then
            local myChar = LocalPlayer.Character
            local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
            local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")

            if myHRP and myHum and myHum.Health > 0 then
                local knife = myChar:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
                if knife then
                    if knife.Parent ~= myChar then myHum:EquipTool(knife) end
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                            if targetHRP and targetHum and targetHum.Health > 0 then
                                if (myHRP.Position - targetHRP.Position).Magnitude <= 5 then
                                    pcall(function()
                                        knife:Activate()
                                        if knife:FindFirstChild("Stab") then knife.Stab:FireServer() end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function isTargetVisible(targetPart)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("Head") then return false end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char, targetPart.Parent}
    raycastParams.IgnoreWater = true

    local origin = WorkspaceCamera.CFrame.Position
    local direction = (targetPart.Position - origin)

    local result = Workspace:Raycast(origin, direction, raycastParams)
    return result == nil
end

RunService.RenderStepped:Connect(function()
    if smartAimbotEnabled then
        local myRole = getRole(LocalPlayer)
        local targetPlayer = nil

        if myRole == "Sheriff" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and getRole(p) == "Murderer" then targetPlayer = p break end
            end
        elseif myRole == "Murderer" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and getRole(p) == "Sheriff" then targetPlayer = p break end
            end
        end

        if targetPlayer and targetPlayer.Character then
            local targetHead = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHead and isTargetVisible(targetHead) then
                WorkspaceCamera.CFrame = CFrame.new(WorkspaceCamera.CFrame.Position, targetHead.Position)
            end
        end
    end
end)

-- === 4. TAB: TROLL & MISC ===
TrollTab:Toggle({
    Title = "Anti-Fling",
    Description = "Protects you from being flung by other players.",
    Value = false,
    Callback = function(state)
        antiFlingEnabled = state
    end
})

RunService.Heartbeat:Connect(function()
    if antiFlingEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                end
            end
        end
    end
end)

local selectedFlingTarget = nil
local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
end

TrollTab:Dropdown({
    Title = "Select Player to Fling",
    Values = playerNames,
    Callback = function(selected)
        selectedFlingTarget = Players:FindFirstChild(selected)
    end
})

TrollTab:Button({
    Title = "Fling Player (Smart Loop)",
    Callback = function()
        if not selectedFlingTarget or not selectedFlingTarget.Character then return end
        local targetHRP = selectedFlingTarget.Character:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if targetHRP and myHRP then
            local originalPos = myHRP.CFrame
            local startPos = targetHRP.Position
            local connection
            local timeElapsed = 0
            
            connection = RunService.Heartbeat:Connect(function(dt)
                timeElapsed = timeElapsed + dt
                if targetHRP and myHRP and selectedFlingTarget.Character and selectedFlingTarget.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-4, 4), math.random(-2, 2), math.random(-4, 4))
                    myHRP.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                    myHRP.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
                    
                    local distance = (targetHRP.Position - startPos).Magnitude
                    if distance > 35 or timeElapsed > 4 then
                        connection:Disconnect()
                        if myHRP then
                            myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            myHRP.CFrame = originalPos
                        end
                    end
                else
                    connection:Disconnect()
                    if myHRP then
                        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        myHRP.CFrame = originalPos
                    end
                end
            end)
        end
    end
})

-- === 5. TAB: WORLD SETTINGS ===
WorldTab:Toggle({
    Title = "Fullbright (Disable Darkness)",
    Description = "Brightens up the game map.",
    Value = false,
    Callback = function(state)
        if state then
            Lighting.Ambient = Color3.fromRGB(255, 255, 255)
            Lighting.Brightness = 2
        else
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            Lighting.Brightness = 1
        end
    end
})

WindUI:Notify({
    Title = "Hoverly Script Loaded",
    Content = "Auto Shoot & Keybind added successfully!",
    Duration = 4
})
