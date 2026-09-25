--[[
    Project: Hoverly Script | Murder Mystery 2
    UI Library: Wind UI + Main (Spinbot), Visuals, Auto Farm, Combat, Troll & SpeedGlitch
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local WorkspaceCamera = Workspace.CurrentCamera

local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Murder Mystery 2",
    Icon = "terminal",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

-- Создаем вкладки
local TopMainTab = Window:Tab({ Title = "Main", Icon = "home" })
local MainTab = Window:Tab({ Title = "Visuals & ESP", Icon = "eye" })
local FarmTab = Window:Tab({ Title = "Auto Farm & Coins", Icon = "coins" })
local CombatTab = Window:Tab({ Title = "Combat & Aura", Icon = "crosshair" })
local TrollTab = Window:Tab({ Title = "Troll & Misc", Icon = "user-x" })
local WorldTab = Window:Tab({ Title = "World Settings", Icon = "sun" })

local espEnabled = false
local arrowsEnabled = false
local smartAimbotEnabled = false
local killAuraEnabled = false
local antiFlingEnabled = false
local autoShootKey = Enum.KeyCode.E
local highlights = {}
local nameTags = {}
local playerArrows = {}

-- Переменные роли для ESP
local t1 = {}
local u16, u17, u18

RunService.RenderStepped:Connect(function()
    pcall(function()
        local getPlayerData = game:GetService("ReplicatedStorage"):FindFirstChild("GetPlayerData", true)
        if getPlayerData then
            t1 = getPlayerData:InvokeServer()
            if t1 then
                for k, v in pairs(t1) do
                    if v.Role == "Murderer" then
                        u16 = k
                    elseif v.Role == "Sheriff" then
                        u17 = k
                    elseif v.Role == "Hero" then
                        u18 = k
                    end
                end
            end
        end
    end)
end)

local function isPlayerAlive(player)
    if not player or not player.Character then return false end
    local hum = player.Character:FindFirstChild("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    if t1 and t1[player.Name] then
        if t1[player.Name].Killed or t1[player.Name].Dead then
            return false
        end
    end
    return true
end

local function getRole(player)
    if player.Name == u16 then return "Murderer" end
    if player.Name == u17 then return "Sheriff" end
    if player.Name == u18 then return "Hero" end
    
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    local hasKnife = (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife"))
    local hasGun = (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun"))
    if hasKnife then return "Murderer" end
    if hasGun then return "Sheriff" end
    return "Innocent"
end

local function getRoleColor(player)
    if player.Name == u16 then return Color3.fromRGB(225, 0, 0) end
    if player.Name == u17 then return Color3.fromRGB(0, 0, 225) end
    if player.Name == u18 then return Color3.fromRGB(255, 250, 0) end
    local role = getRole(player)
    if role == "Murderer" then return Color3.fromRGB(255, 45, 45) end
    if role == "Sheriff" then return Color3.fromRGB(45, 130, 255) end
    return Color3.fromRGB(0, 225, 0)
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

-- Интеграция логики SpeedGlitch
local speedGlitchEnabled = true
local speedGlitchSpeed = 50

local currentCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local currentHumanoid = currentCharacter:WaitForChild("Humanoid")
local currentHRP = currentCharacter:WaitForChild("HumanoidRootPart")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    currentCharacter = newChar
    currentHumanoid = newChar:WaitForChild("Humanoid")
    currentHRP = newChar:WaitForChild("HumanoidRootPart")
end)

RunService.Heartbeat:Connect(function()
    if speedGlitchEnabled then
        if currentHumanoid.FloorMaterial == Enum.Material.Air then
            local moveDir = currentHumanoid.MoveDirection
            if moveDir.Magnitude > 0 then
                local currentVel = currentHRP.Velocity
                local newVel = Vector3.new(moveDir.X * speedGlitchSpeed, currentVel.Y, moveDir.Z * speedGlitchSpeed)
                currentHRP.Velocity = newVel
                currentHRP.AssemblyLinearVelocity = newVel
            end
        end
    end
end)

-- Настройки Spinbot
local spinbotEnabled = false
local spinbotSpeed = 50

-- Настройки Auto Shot & Skin Changer
_G.AutoShotEnabled = _G.AutoShotEnabled or false
local selectedSkinId = "0"

-- Настройки China Hat
getgenv().ChinaHatSettings = {
    enabled = false, 
    hatColor = Color3.fromRGB(255, 105, 180), 
    lightColor = Color3.fromRGB(255, 105, 180), 
    lightBrightness = 0, 
    lightRange = 12, 
    scale = Vector3.new(1.7, 1.1, 1.7), 
}

local chinaHatInstance = nil

local function RemoveChinaHat(Character)
    if Character then
        local existingHat = Character:FindFirstChild("ChinaHatPart")
        if existingHat then existingHat:Destroy() end
    end
    if chinaHatInstance and chinaHatInstance.Parent then
        chinaHatInstance:Destroy()
    end
    chinaHatInstance = nil
end

local function CreateHat(Character)
    RemoveChinaHat(Character)
    if not getgenv().ChinaHatSettings.enabled then return end
    
    local Head = Character:FindFirstChild("Head")
    if not Head then return end 

    local Cone = Instance.new("Part")
    Cone.Name = "ChinaHatPart"
    Cone.Size = Vector3.new(1, 1, 1)
    Cone.BrickColor = BrickColor.new("Hot pink")
    Cone.Material = Enum.Material.Neon
    Cone.Transparency = 0.2
    Cone.Anchored = false
    Cone.CanCollide = false
    Cone.Color = getgenv().ChinaHatSettings.hatColor 

    local Mesh = Instance.new("SpecialMesh")
    Mesh.MeshType = Enum.MeshType.FileMesh
    Mesh.MeshId = "rbxassetid://1033714"
    Mesh.Scale = getgenv().ChinaHatSettings.scale 
    Mesh.Parent = Cone

    local Weld = Instance.new("Weld")
    Weld.Part0 = Head
    Weld.Part1 = Cone
    Weld.C0 = CFrame.new(0, 0.9, 0)
    Weld.Parent = Cone

    local Light = Instance.new("PointLight")
    Light.Color = getgenv().ChinaHatSettings.lightColor 
    Light.Brightness = getgenv().ChinaHatSettings.lightBrightness 
    Light.Range = getgenv().ChinaHatSettings.lightRange 
    Light.Shadows = true
    Light.Parent = Cone

    Cone.Parent = Character
    chinaHatInstance = Cone
end

LocalPlayer.CharacterAdded:Connect(function(Character)
    if getgenv().ChinaHatSettings.enabled then
        Character:WaitForChild("Head")
        CreateHat(Character)
    end
end)

-- Переменные автофарма Candy Zone
local Settings = {
    AutoFarmEnabled = false,
    FarmMode = "Underground",
    TweenSpeed = 25,
    AutoReset = true,
    AvoidMurder = true,
    UndergroundOffset = 4,
    MaxDistance = 600,
    CoinLimit = 40,
}

local State = {
    isFarming = false,
    isActivelyFlying = false,
    currentTargetCoin = nil,
    ignoredCoins = {},
    currentTween = nil,
}

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function getCurrentCoins()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return 0 end
        local gameGui = gui:FindFirstChild("Game")
        if not gameGui then return 0 end
        local coinBags = gameGui:FindFirstChild("CoinBags")
        if not coinBags then return 0 end
        local container = coinBags:FindFirstChild("Container")
        if not container then return 0 end
        local coin = container:FindFirstChild("Coin")
        if not coin then return 0 end
        local currencyFrame = coin:FindFirstChild("CurrencyFrame")
        if not currencyFrame then return 0 end
        local icon = currencyFrame:FindFirstChild("Icon")
        if not icon then return 0 end
        local coinsText = icon:FindFirstChild("Coins")
        if not coinsText then return 0 end
        return coinsText.Text
    end)
    return ok and (tonumber(res) or 0) or 0
end

local function isRoundOver()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not pGui then return false end
    local victoryGui = pGui:FindFirstChild("Victory")
    if victoryGui then
        for _, child in pairs(victoryGui:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then return true end
        end
    end
    return false
end

local function isBagFull()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui then
        local mainGui = pGui:FindFirstChild("MainGUI")
        if mainGui and mainGui:FindFirstChild("Lobby") and mainGui.Lobby:FindFirstChild("Dock") then
            local coinBags = mainGui.Lobby.Dock:FindFirstChild("CoinBags")
            if coinBags then
                local notification = coinBags:FindFirstChild("FullBagNotification")
                if notification and notification.Visible then return true end
            end
        end
    end
    return false
end

local function hasNearbyMurderer()
    if not Settings.AvoidMurder then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local otherHRP = player.Character:FindFirstChild("HumanoidRootPart")
            local backpack = player:FindFirstChild("Backpack")
            if otherHRP and (otherHRP.Position - hrp.Position).Magnitude <= 10 then
                if player.Character:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")) then
                    return true
                end
            end
        end
    end
    return false
end

local function getNearestCoin(torso)
    local container = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then
            container = obj
            break
        end
    end
    if not container then return nil end

    local nearestCoin = nil
    local minDist = math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not State.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist and dist <= Settings.MaxDistance then
                minDist = dist
                nearestCoin = coin
            end
        end
    end
    return nearestCoin
end

local function applyFlightPhysics(char)
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return CFrame.Angles(0,0,0) end

    local bv = hrp:FindFirstChild("FarmBV")
    if not bv then
        bv = Instance.new("BodyVelocity")
        bv.Name = "FarmBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        bv.Parent = hrp
    end

    local bg = hrp:FindFirstChild("FarmBG")
    if not bg then
        bg = Instance.new("BodyGyro")
        bg.Name = "FarmBG"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.P = 50000
        bg.Parent = hrp
        local _, rotY, _ = hrp.CFrame:ToOrientation()
        bg.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, rotY, 0) * CFrame.Angles(math.rad(-90), 0, 0)
    end
    return bg.CFrame.Rotation 
end

local function removePhysics()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if hrp:FindFirstChild("FarmBV") then hrp.FarmBV:Destroy() end
        if hrp:FindFirstChild("FarmBG") then hrp.FarmBG:Destroy() end
        if hrp.Anchored then hrp.Anchored = false end 
    end
end

local function setupNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
    end
end

local function flyToPoint(targetPos, targetCoin, hrp, torso, lockedRotation)
    local dist = (torso.Position - targetPos).Magnitude
    local tweenInfo = TweenInfo.new(dist / Settings.TweenSpeed, Enum.EasingStyle.Linear)
    local targetCFrame = CFrame.new(targetPos) * lockedRotation
    
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})
    State.currentTween = tween
    local reached = false
    tween:Play()
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not State.isFarming or not targetCoin or not targetCoin:IsDescendantOf(Workspace) then 
            tween:Cancel()
            if connection then connection:Disconnect() end
            return
        end
        local currentDist = (torso.Position - targetPos).Magnitude
        if firetouchinterest then
            pcall(function()
                firetouchinterest(torso, targetCoin, 0)
                firetouchinterest(torso, targetCoin, 1)
            end)
        end
        if currentDist <= 1.5 then 
            reached = true
            tween:Cancel()
            if connection then connection:Disconnect() end
        end
    end)
    
    while connection and connection.Connected do
        RunService.Heartbeat:Wait()
    end
    return reached
end

local function tweenToCoin(coin)
    if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return false end
    
    local target = coin.Position + Vector3.new(0, 2, 0)
    if (hrp.Position - target).Magnitude < 5 then return true end
    
    if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
    
    State.currentTween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - target).Magnitude / Settings.TweenSpeed, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {CFrame = CFrame.new(target)})
    hum.Sit = true
    State.currentTween:Play()
    
    local done = false
    local c
    c = State.currentTween.Completed:Connect(function() done = true if c then c:Disconnect() end end)
    
    local t0 = tick()
    while not done and State.isFarming do
        task.wait(0.1)
        if not coin or not coin.Parent or not coin:FindFirstChild("TouchInterest") then
            if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
            hum.Sit = false
            return false
        end
        if tick() - t0 > 30 then
            if State.currentTween then pcall(function() State.currentTween:Cancel() end) end
            hum.Sit = false
            return false
        end
    end
    hum.Sit = false
    return done
end

local function collectCoin(coin)
    if not coin or not coin.Parent then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    pcall(function()
        firetouchinterest(hrp, coin, 0)
        task.wait(0.05)
        firetouchinterest(hrp, coin, 1)
    end)
end

local function startFarming()
    if State.isFarming then return end
    State.isFarming = true
    table.clear(State.ignoredCoins)

    task.spawn(function()
        while State.isFarming do
            task.wait()
            local success = pcall(function()
                if hasNearbyMurderer() then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("Humanoid") then char.Humanoid.Sit = false end
                    task.wait(1)
                    return
                end

                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local torso = getTorso(char)
                local humanoid = char:FindFirstChild("Humanoid")
                
                if not hrp or not torso or not humanoid or humanoid.Health <= 0 then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    task.wait(1)
                    return
                end

                if isRoundOver() or isBagFull() then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if humanoid then humanoid.Sit = false end
                    task.wait(1)
                    return
                end

                if Settings.AutoReset and getCurrentCoins() >= Settings.CoinLimit then
                    humanoid.Health = 0
                    task.wait(5)
                    return
                end
                
                local targetCoin = getNearestCoin(torso)
                if not targetCoin or not targetCoin:IsDescendantOf(Workspace) then
                    State.isActivelyFlying = false
                    State.currentTargetCoin = nil
                    removePhysics()
                    if humanoid then humanoid.Sit = false end
                    task.wait(0.5)
                    return
                end

                State.isActivelyFlying = true
                State.currentTargetCoin = targetCoin
                local reachedTarget = false

                if Settings.FarmMode == "Underground" then
                    setupNoclip()
                    local lockedRotation = applyFlightPhysics(char)
                    reachedTarget = flyToPoint(targetCoin.Position - Vector3.new(0, Settings.UndergroundOffset, 0), targetCoin, hrp, torso, lockedRotation)
                elseif Settings.FarmMode == "Sit" then
                    reachedTarget = tweenToCoin(targetCoin)
                    if reachedTarget and State.isFarming and humanoid.Health > 0 then collectCoin(targetCoin) end
                end
                
                if reachedTarget and State.isFarming and humanoid.Health > 0 then
                    State.ignoredCoins[targetCoin] = true
                    task.delay(5, function() State.ignoredCoins[targetCoin] = nil end)
                    task.wait(0.2)
                end
                State.currentTargetCoin = nil 
            end)
            if not success then
                State.isActivelyFlying = false
                State.currentTargetCoin = nil
                removePhysics()
                task.wait(1)
            end
        end
    end)
end

local function stopFarming()
    State.isFarming = false
    State.isActivelyFlying = false
    State.currentTargetCoin = nil
    if State.currentTween then pcall(function() State.currentTween:Cancel() end) State.currentTween = nil end
    removePhysics()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
        char.Humanoid.Sit = false
    end
end

RunService.Stepped:Connect(function()
    if not State.isFarming or not State.isActivelyFlying or Settings.FarmMode ~= "Underground" then return end
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid then humanoid.PlatformStand = true end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
    end
end)

FarmTab:Toggle({
    Title = "Auto Farm Coins",
    Description = "Automatically farms coins using the Candy Zone logic.",
    Value = Settings.AutoFarmEnabled,
    Callback = function(state)
        Settings.AutoFarmEnabled = state
        if state then startFarming() else stopFarming() end
    end
})

FarmTab:Dropdown({
    Title = "Farm Mode",
    Values = {"Underground", "Sit"},
    Default = Settings.FarmMode,
    Callback = function(selected)
        Settings.FarmMode = selected
    end
})

FarmTab:Slider({
    Title = "Tween Speed",
    Min = 10,
    Max = 100,
    Default = Settings.TweenSpeed,
    Callback = function(value)
        Settings.TweenSpeed = value
    end
})

FarmTab:Toggle({
    Title = "Auto Reset on Coin Limit",
    Description = "Resets character when coin limit is reached.",
    Value = Settings.AutoReset,
    Callback = function(state)
        Settings.AutoReset = state
    end
})

FarmTab:Toggle({
    Title = "Avoid Murderer",
    Description = "Stops farming temporarily if murderer is close.",
    Value = Settings.AvoidMurder,
    Callback = function(state)
        Settings.AvoidMurder = state
    end
})


-- === 1. TAB: MAIN (SPINBOT & SPEEDGLITCH) ===
TopMainTab:Toggle({
    Title = "Spinbot",
    Description = "Automatically spins your character around.",
    Value = false,
    Callback = function(state)
        spinbotEnabled = state
    end
})

TopMainTab:Slider({
    Title = "Spinbot Speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Callback = function(value)
        spinbotSpeed = value
    end
})

TopMainTab:Toggle({
    Title = "SpeedGlitch",
    Description = "Boosts speed in the air (Kolerot SpeedGlitch).",
    Value = speedGlitchEnabled,
    Callback = function(state)
        speedGlitchEnabled = state
    end
})

TopMainTab:Slider({
    Title = "SpeedGlitch Value",
    Min = 10,
    Max = 200,
    Default = speedGlitchSpeed,
    Callback = function(value)
        speedGlitchSpeed = value
    end
})

RunService.RenderStepped:Connect(function()
    if not spinbotEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed), 0)
    end
end)


-- === 2. TAB: VISUALS & ESP ===
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

MainTab:Toggle({
    Title = "China Hat Visual",
    Description = "Spawns a stylish glowing neon cone hat on your head.",
    Value = getgenv().ChinaHatSettings.enabled,
    Callback = function(state)
        getgenv().ChinaHatSettings.enabled = state
        if state then
            if LocalPlayer.Character then
                CreateHat(LocalPlayer.Character)
            end
        else
            RemoveChinaHat(LocalPlayer.Character)
        end
    end
})

MainTab:Toggle({
    Title = "Off-Screen Arrows ESP",
    Description = "Shows directional triangles pointing to off-screen players.",
    Value = false,
    Callback = function(state)
        arrowsEnabled = state
        for _, arrow in pairs(playerArrows) do
            if arrow and arrow.Remove then
                arrow.Visible = state and arrow.IsOffScreen
            end
        end
    end
})

local DistFromCenter = 80
local TriangleHeight = 16
local TriangleWidth = 16
local TriangleThickness = 1
local TriangleTransparency = 0

local V3 = Vector3.new
local V2 = Vector2.new
local CF = CFrame.new
local COS = math.cos
local SIN = math.sin
local RAD = math.rad

local function GetRelative(pos, char)
    if not char or not char.PrimaryPart then return V2(0,0) end
    local rootP = char.PrimaryPart.Position
    local camP = WorkspaceCamera.CFrame.Position
    local relative = CF(V3(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)
    return V2(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return WorkspaceCamera.ViewportSize/2 - v
end

local function RotateVect(v, a)
    a = RAD(a)
    local x = v.x * COS(a) - v.y * SIN(a)
    local y = v.x * SIN(a) + v.y * COS(a)
    return V2(x, y)
end

local function DrawTriangle(color)
    local l = Drawing.new("Triangle")
    l.Visible = false
    l.Color = color
    l.Filled = true
    l.Thickness = TriangleThickness
    l.Transparency = 1 - TriangleTransparency
    return l
end

local function ShowArrow(PLAYER)
    local arrowData = {
        Drawing = DrawTriangle(Color3.fromRGB(255, 255, 255)),
        IsOffScreen = false
    }
    playerArrows[PLAYER] = arrowData

    local function Update()
        local c
        c = RunService.RenderStepped:Connect(function()
            if not arrowsEnabled or not PLAYER or not PLAYER.Character or not PLAYER.Character:FindFirstChild("PrimaryPart") then
                arrowData.Drawing.Visible = false
                arrowData.IsOffScreen = false
                if not PLAYER or not PLAYER.Parent then
                    arrowData.Drawing:Remove()
                    playerArrows[PLAYER] = nil
                    c:Disconnect()
                end
                return
            end

            local CHAR = PLAYER.Character
            local HUM = CHAR:FindFirstChildOfClass("Humanoid")

            if HUM and HUM.Health > 0 then
                arrowData.Drawing.Color = getRoleColor(PLAYER)

                local _, vis = WorkspaceCamera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
                if not vis then
                    local rel = GetRelative(CHAR.PrimaryPart.Position, LocalPlayer.Character)
                    local direction = rel.unit

                    local base = direction * DistFromCenter
                    local sideLength = TriangleWidth / 2
                    local baseL = base + RotateVect(direction, 90) * sideLength
                    local baseR = base + RotateVect(direction, -90) * sideLength
                    local tip = direction * (DistFromCenter + TriangleHeight)

                    arrowData.Drawing.PointA = RelativeToCenter(baseL)
                    arrowData.Drawing.PointB = RelativeToCenter(baseR)
                    arrowData.Drawing.PointC = RelativeToCenter(tip)

                    arrowData.IsOffScreen = true
                    arrowData.Drawing.Visible = arrowsEnabled
                else
                    arrowData.IsOffScreen = false
                    arrowData.Drawing.Visible = false
                end
            else
                arrowData.Drawing.Visible = false
                arrowData.IsOffScreen = false
            end
        end)
    end

    coroutine.wrap(Update)()
end

for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        ShowArrow(v)
    end
end

Players.PlayerAdded:Connect(function(v)
    if v ~= LocalPlayer then
        ShowArrow(v)
    end
end)

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


-- === 4. TAB: COMBAT & AURA ===
CombatTab:Toggle({
    Title = "Smart Role Aimbot (Wallcheck)",
    Description = "Automatically aims at the enemy role.",
    Value = false,
    Callback = function(state) smartAimbotEnabled = state end
})

CombatTab:Toggle({
    Title = "Murderer Kill Aura",
    Description = "Automatically stabs targets in a 5-stud radius.",
    Value = false,
    Callback = function(state) killAuraEnabled = state end
})

local function ExecuteAutoShot()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")

    if knife then
        if knife.Parent ~= char then
            hum:EquipTool(knife)
            task.wait()
        end

        local targetChar = nil
        local minDist = math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                if tHRP and tHum and tHum.Health > 0 then
                    local dist = (tHRP.Position - hrp.Position).Magnitude
                    if dist < minDist then
                        minDist = dist
                        targetChar = p.Character
                    end
                end
            end
        end

        if targetChar then
            local tHRP = targetChar:FindFirstChild("HumanoidRootPart")
            if tHRP then
                local torso = targetChar:FindFirstChild("UpperTorso") or targetChar:FindFirstChild("Torso") or tHRP
                local vel = tHRP.AssemblyLinearVelocity
                local dist = (torso.Position - hrp.Position).Magnitude
                
                local ping = 0
                pcall(function() ping = LocalPlayer:GetNetworkPing() end)

                local predictedPos = torso.Position + Vector3.new(vel.X, 0, vel.Z) * (dist / 65 + ping * 0.5)

                pcall(function()
                    local knifeThrown = knife:WaitForChild("Events"):WaitForChild("KnifeThrown")
                    local cf = CFrame.new(hrp.Position, predictedPos)
                    local v881 = {n = 1}
                    v881[1] = CFrame.new(predictedPos)
                    knifeThrown:FireServer(cf, unpack(v881, 1, v881.n))
                end)
            end
        end
    elseif gun then
        if gun.Parent ~= char then
            hum:EquipTool(gun)
            task.wait()
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and getRole(p) == "Murderer" and p.Character then
                local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    pcall(function()
                        local shoot = gun:WaitForChild("Shoot")
                        local cf = CFrame.new(hrp.Position + Vector3.new(0, 1, 0), tHRP.Position)
                        local v876 = {n = 1}
                        v876[1] = CFrame.new(tHRP.Position)
                        shoot:FireServer(cf, unpack(v876, 1, v876.n))
                    end)
                end
            end
        end
    end
end

CombatTab:Toggle({
    Title = "Auto Shot (Knife/Gun Predictor)",
    Description = "Automatically fires/throws at targets using prediction.",
    Value = false,
    Callback = function(state)
        _G.AutoShotEnabled = state
    end
})

RunService.Heartbeat:Connect(function()
    if _G.AutoShotEnabled then
        ExecuteAutoShot()
    end
end)

CombatTab:Textbox({
    Title = "Weapon Skin ID (Asset ID)",
    Description = "Enter Texture ID for Knife/Gun custom skins.",
    Default = "0",
    Callback = function(value)
        selectedSkinId = value
    end
})

CombatTab:Button({
    Title = "Apply Skin Changer",
    Description = "Applies texture to equipped weapon.",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer.Backpack
        if not char then return end

        for _, tool in ipairs({backpack:FindFirstChild("Knife"), backpack:FindFirstChild("Gun"), char:FindFirstChild("Knife"), char:FindFirstChild("Gun")}) do
            if tool then
                pcall(function()
                    local handle = tool:FindFirstChild("Handle")
                    if handle then
                        for _, child in ipairs(handle:GetChildren()) do
                            if child:IsA("SpecialMesh") or child:IsA("Texture") then
                                child.TextureId = "rbxassetid://" .. tostring(selectedSkinId)
                            end
                        end
                    end
                end)
            end
        end
        WindUI:Notify({ Title = "Skin Changer", Content = "Skin applied successfully!", Duration = 3 })
    end
})

local function absoluteForceShoot()
    local myRole = getRole(LocalPlayer)
    if myRole ~= "Sheriff" then
        WindUI:Notify({ Title = "Force Shot", Content = "You are not the Sheriff!", Duration = 3 })
        return
    end

    local myChar = LocalPlayer.Character
    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP or not myHum or myHum.Health <= 0 then return end

    local gun = myChar:FindFirstChild("Gun") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Gun"))
    if not gun then
        WindUI:Notify({ Title = "Force Shot", Content = "Gun not found!", Duration = 3 })
        return
    end

    if gun.Parent ~= myChar then myHum:EquipTool(gun) end

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
            pcall(function()
                gun:Activate()
                if gun:FindFirstChild("Shoot") then
                    gun.Shoot:FireServer(targetHRP.Position)
                end
            end)
            WindUI:Notify({ Title = "Force Shot", Content = "Absolute Force Shot sent to Murderer!", Duration = 2 })
        end
    else
        WindUI:Notify({ Title = "Force Shot", Content = "Murderer not found on map!", Duration = 2 })
    end
end

CombatTab:Button({
    Title = "Absolute Force Shot (No Camera Move)",
    Description = "Instantly fires at the murderer from anywhere without moving your camera.",
    Callback = function() absoluteForceShoot() end
})

CombatTab:Keybind({
    Title = "Force Shot Keybind",
    Description = "Press this key to instantly execute a force shot.",
    Value = Enum.KeyCode.E,
    Callback = function(key) autoShootKey = key end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == autoShootKey then
        absoluteForceShoot()
    end
end)

local clickCount = 0
local lastClickTime = 0

CombatTab:Button({
    Title = "Kill All (Murder Only) + Fast Clicks & Big Hitboxes",
    Description = "Click screen 12 times quickly to activate. No knife cooldown & 1000 studs hitboxes.",
    Callback = function()
        local myRole = getRole(LocalPlayer)
        if myRole ~= "Murderer" then
            WindUI:Notify({ Title = "Error", Content = "You are not the Murderer!", Duration = 3 })
            return
        end

        WindUI:Notify({ Title = "Action Required", Content = "Tap/Click your screen 12 times very quickly to confirm!", Duration = 3 })
        clickCount = 0
        lastClickTime = tick()

        local connection
        connection = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                local currentTime = tick()
                if currentTime - lastClickTime < 0.4 then clickCount = clickCount + 1 else clickCount = 1 end
                lastClickTime = currentTime

                if clickCount >= 12 then
                    connection:Disconnect()
                    local myChar = LocalPlayer.Character
                    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local myHum = myChar and myChar:FindFirstChildOfClass("Humanoid")
                    if not myHRP or not myHum or myHum.Health <= 0 then return end

                    local knife = myChar:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
                    if not knife then return end
                    if knife.Parent ~= myChar then myHum:EquipTool(knife) end

                    pcall(function()
                        for _, v in pairs(knife:GetDescendants()) do
                            if v:IsA("NumberValue") or v:IsA("IntValue") then
                                if v.Name:lower():find("cooldown") or v.Name:lower():find("delay") then v.Value = 0 end
                            end
                        end
                    end)

                    local originalCFrame = myHRP.CFrame
                    for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end
                    local originalSizes = {}

                    task.spawn(function()
                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                if targetHRP then
                                    originalSizes[player] = targetHRP.Size
                                    targetHRP.Size = Vector3.new(1000, 1000, 1000)
                                    targetHRP.Transparency = 0.9
                                    targetHRP.CanCollide = false
                                end
                            end
                        end

                        for _, player in ipairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                                if targetHRP and targetHum and targetHum.Health > 0 then
                                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 1)
                                    task.wait(0.02)
                                    for i = 1, 3 do
                                        pcall(function() knife:Activate() if knife:FindFirstChild("Stab") then knife.Stab:FireServer() end end)
                                    end
                                    task.wait(0.05)
                                end
                            end
                        end

                        for player, origSize in pairs(originalSizes) do
                            if player and player.Character then
                                local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                                if targetHRP then targetHRP.Size = origSize targetHRP.Transparency = 1 targetHRP.CanCollide = true end
                            end
                        end

                        myHRP.CFrame = originalCFrame
                        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        for _, part in ipairs(myChar:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
                        WindUI:Notify({ Title = "Kill All Completed", Content = "Targets eliminated!", Duration = 3 })
                    end)
                end
            end
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
                                    pcall(function() knife:Activate() if knife:FindFirstChild("Stab") then knife.Stab:FireServer() end end)
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
    local result = Workspace:Raycast(origin, (targetPart.Position - origin), raycastParams)
    return result == nil
end

RunService.RenderStepped:Connect(function()
    if smartAimbotEnabled then
        local myRole = getRole(LocalPlayer)
        local targetPlayer = nil
        if myRole == "Sheriff" then
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and getRole(p) == "Murderer" then targetPlayer = p break end end
        elseif myRole == "Murderer" then
            for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer and getRole(p) == "Sheriff" then targetPlayer = p break end end
        end
        if targetPlayer and targetPlayer.Character then
            local targetHead = targetPlayer.Character:FindFirstChild("Head") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if targetHead and isTargetVisible(targetHead) then
                WorkspaceCamera.CFrame = CFrame.new(WorkspaceCamera.CFrame.Position, targetHead.Position)
            end
        end
    end
end)


-- === 5. TAB: TROLL & MISC ===
TrollTab:Toggle({
    Title = "Anti-Fling",
    Description = "Disables collisions with other players so they cannot fling you.",
    Value = false,
    Callback = function(state) 
        antiFlingEnabled = state 
        if not state then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
    end
})

RunService.Stepped:Connect(function()
    if not antiFlingEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

local selectedFlingTarget = nil
local playerNames = {}

local function updatePlayerDropdown()
    table.clear(playerNames)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(playerNames, p.Name)
        end
    end
end

updatePlayerDropdown()

Players.PlayerAdded:Connect(updatePlayerDropdown)
Players.PlayerRemoving:Connect(updatePlayerDropdown)

TrollTab:Dropdown({
    Title = "Select Player to Fling",
    Values = playerNames,
    Callback = function(selected) 
        selectedFlingTarget = Players:FindFirstChild(selected) 
    end
})

TrollTab:Button({
    Title = "Fling Selected Player",
    Description = "Sends selected player flying out of the map using a velocity loop.",
    Callback = function()
        if not selectedFlingTarget or not selectedFlingTarget.Character then
            WindUI:Notify({ Title = "Fling Error", Content = "Please select a valid player first!", Duration = 3 })
            return
        end
        
        local targetHRP = selectedFlingTarget.Character:FindFirstChild("HumanoidRootPart")
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        
        if targetHRP and myHRP then
            local originalPos = myHRP.CFrame
            local startPos = targetHRP.Position
            local connection, timeElapsed = nil, 0
            
            WindUI:Notify({ Title = "Flinging", Content = "Flinging " .. selectedFlingTarget.Name .. "...", Duration = 3 })
            
            connection = RunService.Heartbeat:Connect(function(dt)
                timeElapsed = timeElapsed + dt
                if targetHRP and myHRP and selectedFlingTarget.Character and selectedFlingTarget.Character:FindFirstChildOfClass("Humanoid") and selectedFlingTarget.Character.Humanoid.Health > 0 then
                    myHRP.CFrame = targetHRP.CFrame * CFrame.new(math.random(-4, 4), math.random(-2, 2), math.random(-4, 4))
                    myHRP.AssemblyLinearVelocity = Vector3.new(99999, 99999, 99999)
                    myHRP.AssemblyAngularVelocity = Vector3.new(99999, 99999, 99999)
                    
                    if (targetHRP.Position - startPos).Magnitude > 35 or timeElapsed > 4 then
                        connection:Disconnect()
                        myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        myHRP.CFrame = originalPos
                    end
                else
                    connection:Disconnect()
                    myHRP.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                    myHRP.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                    myHRP.CFrame = originalPos
                end
            end)
        end
    end
})


-- === 6. TAB: WORLD SETTINGS ===
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
    Content = "SpeedGlitch integrated cleanly into the Main tab!",
    Duration = 4
})
