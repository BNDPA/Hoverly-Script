--[[
    Project: Hoverly Script | Murder Mystery 2 Complete Edition
    UI Library: Wind UI
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local WorkspaceCamera = Workspace.CurrentCamera

local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | MM2",
    Icon = "terminal",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

local MainTab = Window:Tab({ Title = "Main & Visuals", Icon = "eye" })
local FarmTab = Window:Tab({ Title = "Auto Farm & Coins", Icon = "coins" })
local CombatTab = Window:Tab({ Title = "Combat & Aura", Icon = "crosshair" })
local TrollTab = Window:Tab({ Title = "Troll & Misc", Icon = "user-x" })
local OtherTab = Window:Tab({ Title = "Other (Fly/Noclip)", Icon = "settings" })
local WorldTab = Window:Tab({ Title = "World Settings", Icon = "sun" })

local espEnabled = false
local arrowsEnabled = false
local smartAimbotEnabled = false
local killAuraEnabled = false
local antiFlingEnabled = false
local highlights = {}
local nameTags = {}
local playerArrows = {}

_G.AutoShotEnabled = _G.AutoShotEnabled or false
_G.AutoGrabGun = _G.AutoGrabGun or false
local selectedSkinId = "0"

-- === CHINA HAT ===
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

-- === ROLES & ESP ===
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
    Value = getgenv().ChinaHatSettings.enabled,
    Callback = function(state)
        getgenv().ChinaHatSettings.enabled = state
        if state then
            if LocalPlayer.Character then CreateHat(LocalPlayer.Character) end
        else
            RemoveChinaHat(LocalPlayer.Character)
        end
    end
})

MainTab:Toggle({
    Title = "Off-Screen Arrows ESP",
    Value = false,
    Callback = function(state)
        arrowsEnabled = state
        if not state then
            for _, arrow in pairs(playerArrows) do
                if arrow and arrow.Drawing then arrow.Drawing.Visible = false end
            end
        end
    end
})

local DistFromCenter = 80
local TriangleHeight = 16
local TriangleWidth = 16

local function GetRelative(pos, char)
    if not char or not char.PrimaryPart then return Vector2.new(0,0) end
    local rootP = char.PrimaryPart.Position
    local camP = WorkspaceCamera.CFrame.Position
    local relative = CFrame.new(Vector3.new(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)
    return Vector2.new(relative.X, relative.Y)
end

local function RelativeToCenter(v)
    return WorkspaceCamera.ViewportSize/2 - v
end

local function RotateVect(v, a)
    a = math.rad(a)
    local x = v.x * math.cos(a) - v.y * math.sin(a)
    local y = v.x * math.sin(a) + v.y * math.cos(a)
    return Vector2.new(x, y)
end

local function ShowArrow(PLAYER)
    local arrowData = {
        Drawing = Drawing.new("Triangle"),
        IsOffScreen = false
    }
    arrowData.Drawing.Visible = false
    arrowData.Drawing.Filled = true
    arrowData.Drawing.Thickness = 1
    playerArrows[PLAYER] = arrowData

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not arrowsEnabled or not PLAYER or not PLAYER.Parent or not PLAYER.Character or not PLAYER.Character.PrimaryPart then
            arrowData.Drawing.Visible = false
            if not PLAYER or not PLAYER.Parent then
                arrowData.Drawing:Remove()
                playerArrows[PLAYER] = nil
                connection:Disconnect()
            end
            return
        end

        local CHAR = PLAYER.Character
        local HUM = CHAR:FindFirstChildOfClass("Humanoid")
        if HUM and HUM.Health > 0 and CHAR.PrimaryPart then
            arrowData.Drawing.Color = getRoleColor(PLAYER)
            _, vis = WorkspaceCamera:WorldToViewportPoint(CHAR.PrimaryPart.Position)
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
                arrowData.Drawing.Visible = true
            else
                arrowData.Drawing.Visible = false
            end
        else
            arrowData.Drawing.Visible = false
        end
    end)
end

for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then ShowArrow(v) end end
Players.PlayerAdded:Connect(function(v) if v ~= LocalPlayer then ShowArrow(v) end end)

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


-- === 2. TAB: AUTO FARM & COINS (С исправлениями) ===
local FarmSettings = {
    AutoFarmEnabled = false,
    TweenSpeed = 25,
    AutoReset = true,
    UndergroundOffset = -10, -- Смещение под землю по умолчанию
    SitMode = true,          -- Сидячий режим (предотвращает баги камеры и падения)
    MaxDistance = 600,
    CoinLimit = 40,
}
local FarmState = { isFarming = false, ignoredCoins = {}, currentTween = nil }

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function getCurrentCoins()
    local ok, res = pcall(function()
        local gui = LocalPlayer.PlayerGui:FindFirstChild("MainGUI")
        if not gui then return 0 end
        return tonumber(gui.Game.CoinBags.Container.Coin.CurrencyFrame.Icon.Coins.Text) or 0
    end)
    return ok and res or 0
end

local function isRoundOver()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("Victory") then
        for _, child in pairs(pGui.Victory:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then return true end
        end
    end
    return false
end

local function isBagFull()
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    if pGui and pGui:FindFirstChild("MainGUI") then
        local lobby = pGui.MainGUI:FindFirstChild("Lobby")
        if lobby and lobby:FindFirstChild("Dock") and lobby.Dock:FindFirstChild("CoinBags") then
            local n = lobby.Dock.CoinBags:FindFirstChild("FullBagNotification")
            if n and n.Visible then return true end
        end
    end
    return false
end

local function getNearestCoin(torso)
    local container = nil
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then container = obj break end
    end
    if not container then return nil end

    local nearestCoin = nil
    local minDist = math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not FarmState.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist and dist <= FarmSettings.MaxDistance then
                minDist = dist
                nearestCoin = coin
            end
        end
    end
    return nearestCoin
end

local function startFarming()
    if FarmState.isFarming then return end
    FarmState.isFarming = true
    table.clear(FarmState.ignoredCoins)

    task.spawn(function()
        while FarmState.isFarming do
            task.wait()
            pcall(function()
                local char = LocalPlayer.Character
                if not char then return end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local torso = getTorso(char)
                local humanoid = char:FindFirstChild("Humanoid")
                if not hrp or not torso or not humanoid or humanoid.Health <= 0 then return end

                if isRoundOver() or isBagFull() then task.wait(1) return end
                
                local container = nil
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj.Name == "CoinContainer" then container = obj break end
                end
                
                -- Если все монеты собраны
                local coinsLeft = false
                if container then
                    for _, c in pairs(container:GetChildren()) do
                        if c.Name == "Coin_Server" then coinsLeft = true break end
                    end
                end

                if not coinsLeft or getCurrentCoins() >= FarmSettings.CoinLimit then
                    if FarmSettings.AutoReset then
                        humanoid.Health = 0
                        task.wait(4)
                    end
                    return
                end
                
                local targetCoin = getNearestCoin(torso)
                if not targetCoin or not targetCoin:IsDescendantOf(Workspace) then task.wait(0.5) return end

                local target = targetCoin.Position + Vector3.new(0, FarmSettings.UndergroundOffset, 0)
                
                for _, part in pairs(char:GetDescendants()) do 
                    if part:IsA("BasePart") and part.CanCollide then 
                        part.CanCollide = false 
                    end 
                end
                
                humanoid.PlatformStand = true
                if FarmSettings.SitMode then
                    humanoid.Sit = true
                end

                local tween = TweenService:Create(hrp, TweenInfo.new((hrp.Position - target).Magnitude / FarmSettings.TweenSpeed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(target)})
                FarmState.currentTween = tween
                tween:Play()
                
                local conn
                conn = RunService.Heartbeat:Connect(function()
                    if firetouchinterest then
                        pcall(function() firetouchinterest(torso, targetCoin, 0) firetouchinterest(torso, targetCoin, 1) end)
                    end
                end)
                
                tween.Completed:Wait()
                if conn then conn:Disconnect() end
                FarmState.ignoredCoins[targetCoin] = true
                task.delay(5, function() FarmState.ignoredCoins[targetCoin] = nil end)
            end)
        end
    end)
end

local function stopFarming()
    FarmState.isFarming = false
    if FarmState.currentTween then pcall(function() FarmState.currentTween:Cancel() end) end
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = false
        char.Humanoid.Sit = false
    end
end

FarmTab:Toggle({
    Title = "Auto Farm Coins",
    Value = FarmSettings.AutoFarmEnabled,
    Callback = function(state)
        FarmSettings.AutoFarmEnabled = state
        if state then startFarming() else stopFarming() end
    end
})

FarmTab:Slider({
    Title = "Tween Speed",
    Min = 10,
    Max = 100,
    Default = FarmSettings.TweenSpeed,
    Callback = function(value) FarmSettings.TweenSpeed = value end
})

FarmTab:Slider({
    Title = "Underground Offset",
    Min = -30,
    Max = 10,
    Default = FarmSettings.UndergroundOffset,
    Callback = function(value) FarmSettings.UndergroundOffset = value end
})

FarmTab:Toggle({
    Title = "Sit Mode (Fixes Camera/Fall glitches)",
    Value = FarmSettings.SitMode,
    Callback = function(state) FarmSettings.SitMode = state end
})

FarmTab:Toggle({
    Title = "Auto Reset when Bag Full / Coins Done",
    Value = FarmSettings.AutoReset,
    Callback = function(state) FarmSettings.AutoReset = state end
})

FarmTab:Button({
    Title = "Teleport to Map",
    Callback = function()
        pcall(function()
            for _, obj in pairs(Workspace:GetChildren()) do
                if obj:FindFirstChild("CoinContainer") or obj.Name == "Map" then
                    local spawnPart = obj:FindFirstChild("Spawn") or obj:FindFirstChildWhichIsA("BasePart")
                    if spawnPart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 5, 0)
                        break
                    end
                end
            end
        end)
    end
})


-- === 3. TAB: COMBAT & AURA ===
CombatTab:Toggle({
    Title = "Smart Role Aimbot (Wallcheck)",
    Value = false,
    Callback = function(state) smartAimbotEnabled = state end
})

CombatTab:Toggle({
    Title = "Murderer Kill Aura",
    Value = false,
    Callback = function(state) killAuraEnabled = state end
})

CombatTab:Toggle({
    Title = "Auto Grab Dropped Gun",
    Description = "Teleports dropped Sheriff gun directly to you.",
    Value = _G.AutoGrabGun,
    Callback = function(state) _G.AutoGrabGun = state end
})

RunService.Heartbeat:Connect(function()
    if not _G.AutoGrabGun then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in pairs(Workspace:GetChildren()) do
        if obj.Name == "GunDrop" or (obj:IsA("Tool") and obj.Name == "Gun") then
            local handle = obj:FindFirstChild("Handle") or obj
            if handle and handle:IsA("BasePart") then
                handle.CFrame = hrp.CFrame
                pcall(function()
                    firetouchinterest(hrp, handle, 0)
                    firetouchinterest(hrp, handle, 1)
                end)
            end
        end
    end
end)

local function ExecuteAutoShot()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then return end

    local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")

    if knife then
        if knife.Parent ~= char then hum:EquipTool(knife) task.wait() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    local torso = p.Character:FindFirstChild("UpperTorso") or tHRP
                    local vel = tHRP.AssemblyLinearVelocity
                    local dist = (torso.Position - hrp.Position).Magnitude
                    local predictedPos = torso.Position + Vector3.new(vel.X, 0, vel.Z) * (dist / 65)

                    pcall(function()
                        local knifeThrown = knife:WaitForChild("Events"):WaitForChild("KnifeThrown")
                        knifeThrown:FireServer(CFrame.new(hrp.Position, predictedPos), {CFrame.new(predictedPos)})
                    end)
                end
            end
        end
    elseif gun then
        if gun.Parent ~= char then hum:EquipTool(gun) task.wait() end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and getRole(p) == "Murderer" and p.Character then
                local tHRP = p.Character:FindFirstChild("HumanoidRootPart")
                if tHRP then
                    pcall(function()
                        gun:WaitForChild("Shoot"):FireServer(CFrame.new(hrp.Position, tHRP.Position), {CFrame.new(tHRP.Position)})
                    end)
                end
            end
        end
    end
end

CombatTab:Toggle({
    Title = "Auto Shot (Knife/Gun Predictor)",
    Value = false,
    Callback = function(state) _G.AutoShotEnabled = state end
})

RunService.Heartbeat:Connect(function()
    if _G.AutoShotEnabled then ExecuteAutoShot() end
end)

CombatTab:Textbox({
    Title = "Weapon Skin ID (Asset ID)",
    Default = "0",
    Callback = function(value) selectedSkinId = value end
})

CombatTab:Button({
    Title = "Apply Skin Changer",
    Callback = function()
        local char = LocalPlayer.Character
        local backpack = LocalPlayer.Backpack
        if not char then return end
        for _, tool in ipairs({backpack:FindFirstChild("Knife"), backpack:FindFirstChild("Gun"), char:FindFirstChild("Knife"), char:FindFirstChild("Gun")}) do
            if tool and tool:FindFirstChild("Handle") then
                for _, child in ipairs(tool.Handle:GetChildren()) do
                    if child:IsA("SpecialMesh") or child:IsA("Texture") then
                        child.TextureId = "rbxassetid://" .. tostring(selectedSkinId)
                    end
                end
            end
        end
    end
})

RunService.Heartbeat:Connect(function()
    if killAuraEnabled then
        local myChar = LocalPlayer.Character
        local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP then
            local knife = myChar:FindFirstChild("Knife") or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Knife"))
            if knife then
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local targetHRP = player.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP and (myHRP.Position - targetHRP.Position).Magnitude <= 5 then
                            pcall(function() knife:Activate() knife.Stab:FireServer() end)
                        end
                    end
                end
            end
        end
    end
end)


-- === 4. TAB: TROLL & MISC ===
TrollTab:Toggle({
    Title = "Anti-Fling (Disable Collisions)",
    Description = "Completely removes collision with other players.",
    Value = false,
    Callback = function(state) antiFlingEnabled = state end
})

RunService.Stepped:Connect(function()
    if not antiFlingEnabled then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)


-- === 5. TAB: OTHER (FLY & NOCLIP) ===
local flyEnabled = false
local noclipEnabled = false
local flySpeed = 50
local bg, bv

OtherTab:Toggle({
    Title = "Fly",
    Value = false,
    Callback = function(state)
        flyEnabled = state
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        if flyEnabled then
            bg = Instance.new("BodyGyro", hrp)
            bg.P = 9e4
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = hrp.CFrame
            
            bv = Instance.new("BodyVelocity", hrp)
            bv.velocity = Vector3.new(0, 0, 0)
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            
            task.spawn(function()
                while flyEnabled do
                    RunService.RenderStepped:Wait()
                    local cam = WorkspaceCamera.CFrame
                    local moveDir = Vector3.new()
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.RightVector end
                    
                    if bv and bg then
                        bv.velocity = moveDir * flySpeed
                        bg.cframe = cam
                    end
                end
            end)
        else
            if bg then bg:Destroy() bg = nil end
            if bv then bv:Destroy() bv = nil end
        end
    end
})

OtherTab:Slider({
    Title = "Fly Speed",
    Min = 10,
    Max = 150,
    Default = 50,
    Callback = function(v) flySpeed = v end
})

OtherTab:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)


-- === 6. TAB: WORLD SETTINGS ===
WorldTab:Toggle({
    Title = "Fullbright (Disable Darkness)",
    Value = false,
    Callback = function(state)
        Lighting.Ambient = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = state and 2 or 1
    end
})

WindUI:Notify({ Title = "Hoverly Script Loaded", Content = "Successfully updated with AutoFarm fixes & Fly/Noclip!", Duration = 4 })

