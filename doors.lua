--[[
    Project: Hoverly Script | DOORS (Auto Play Removed, Smart NoClip & Auto Loot)
    Features: Smart NoClip (Small Parts Only), Auto Hide/Sit, Auto Keys, Speed 20, ESP
]]

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Failed to load Wind UI for DOORS script!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | DOORS",
    Icon = "door-closed",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

local MainTab = Window:Tab({ Title = "Main / Auto", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local ESPTab = Window:Tab({ Title = "Visuals (ESP)", Icon = "eye" })
local WorldTab = Window:Tab({ Title = "World", Icon = "globe" })

local noclipEnabled = false
local speedEnabled = false
local autoInteractEnabled = false
local autoKeyEnabled = false
local autoCheckScreechEnabled = false
local espItemsEnabled = false
local espPlayersEnabled = false
local espEntitiesEnabled = false
local espClosetsEnabled = false
local entityNotifierEnabled = false

local monsterActive = false

local espFolder = Instance.new("Folder")
espFolder.Name = "HoverlyDOORS_ESP"
espFolder.Parent = Workspace

local function createBillboard(target, text, color)
    if not target then return end
    local existing = target:FindFirstChild("HoverlyTag")
    if existing then existing:Destroy() end

    local bb = Instance.new("BillboardGui")
    bb.Name = "HoverlyTag"
    bb.Size = UDim2.new(0, 100, 0, 40)
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = target
    bb.Parent = target

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = text
    txt.TextColor3 = color
    txt.TextStrokeTransparency = 0.2
    txt.TextSize = 14
    txt.Font = Enum.Font.GothamBold
    txt.Parent = bb
end

-- =================================================================
-- 1. ENTITY NOTIFIER & SCREECH AUTO CHECK
-- =================================================================
MainTab:Toggle({
    Title = "Entity Notifier (Notice)",
    Description = "Warns you when Rush, Ambush, Screech, Eyes or other entities spawn.",
    Value = false,
    Callback = function(state)
        entityNotifierEnabled = state
    end
})

MainTab:Toggle({
    Title = "Auto Check Screech",
    Description = "Automatically turns your camera to look at Screech instantly.",
    Value = false,
    Callback = function(state)
        autoCheckScreechEnabled = state
    end
})

local monitoredEntities = {
    ["RushMoving"] = "Rush is coming! HIDE NOW!",
    ["AmbushMoving"] = "Ambush is coming! HIDE & GET READY TO CLICK!",
    ["Eyes"] = "Eyes spawned! Don't look at them!",
    ["Halt"] = "Halt room! Turn around or move back!",
    ["A-60"] = "A-60 is coming! HIDE IN A LOCKER!",
    ["A-120"] = "A-120 is coming! HIDE QUICKLY!",
    ["Screech"] = "Screech appeared! Looking at him..."
}

Workspace.ChildAdded:Connect(function(child)
    local name = child.Name
    if monitoredEntities[name] then
        if name ~= "Eyes" and name ~= "Screech" then
            monsterActive = true
        end

        if entityNotifierEnabled then
            WindUI:Notify({
                Title = "⚠️ WARNING: " .. name,
                Content = monitoredEntities[name],
                Duration = 4
            })
        end
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if monitoredEntities[child.Name] then
        local dangerFound = false
        for _, entName in pairs({"RushMoving", "AmbushMoving", "A-60", "A-120", "Halt"}) do
            if Workspace:FindFirstChild(entName) then
                dangerFound = true
                break
            end
        end
        if not dangerFound then
            monsterActive = false
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not autoCheckScreechEnabled then return end
    
    pcall(function()
        local screechTarget = nil
        for _, obj in pairs(Workspace:GetChildren()) do
            if obj.Name:lower():find("screech") then
                screechTarget = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                break
            end
        end

        if not screechTarget and LocalPlayer.Character then
            for _, obj in pairs(LocalPlayer.Character:GetChildren()) do
                if obj.Name:lower():find("screech") then
                    screechTarget = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                    break
                end
            end
        end

        if screechTarget and screechTarget:IsA("BasePart") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, screechTarget.Position)
        end
    end)
end)

-- =================================================================
-- 2. PLAYER (УМНЫЙ NOCLIP ТОЛЬКО ДЛЯ МЕЛКИХ ХИТБОКСОВ & SPEED 20)
-- =================================================================
PlayerTab:Toggle({
    Title = "Smart NoClip (Small Parts Only)",
    Description = "Walks through small hitboxes, chairs, and obstacles without falling through walls/floors.",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
    end
})

PlayerTab:Toggle({
    Title = "Speed (20)",
    Description = "Sets your walk speed to 20 instead of default 16.",
    Value = false,
    Callback = function(state)
        speedEnabled = state
    end
})

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")

    if noclipEnabled then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                local touchingParts = part:GetTouchingParts()
                for _, touchPart in pairs(touchingParts) do
                    if touchPart and touchPart.Parent ~= char then
                        local size = touchPart.Size
                        if size.X < 4 and size.Y < 4 and size.Z < 4 and not touchPart.Name:lower():find("door") then
                            touchPart.CanCollide = false
                        end
                    end
                end
            end
        end
    end

    if humanoid then
        if speedEnabled then
            humanoid.WalkSpeed = 20
        else
            if humanoid.WalkSpeed == 20 then
                humanoid.WalkSpeed = 16
            end
        end
    end
end)

-- =================================================================
-- 3. AUTO INTERACT & AUTO KEY
-- =================================================================
MainTab:Toggle({
    Title = "Auto Open Doors, Keys & Levers",
    Description = "Automatically opens doors, picks up keys, pulls levers. Interacts with closets/seats when needed.",
    Value = false,
    Callback = function(state)
        autoInteractEnabled = state
        task.spawn(function()
            while autoInteractEnabled do
                task.wait(0.2)
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("ProximityPrompt") then
                                local actionText = obj.ActionText:lower()
                                local objectName = obj.Name:lower()
                                local parent = obj.Parent
                                local parentName = parent and parent.Name:lower() or ""
                                
                                local isIgnored = false
                                local isHideAction = actionText:find("hide") or actionText:find("enter") or 
                                                     parentName:find("wardrobe") or parentName:find("closet") or parentName:find("bed")

                                if isHideAction then
                                    if not monsterActive then
                                        isIgnored = true
                                    end
                                end

                                if not isIgnored then
                                    local targetPart = nil
                                    if parent then
                                        if parent:IsA("BasePart") then
                                            targetPart = parent
                                        elseif parent:IsA("Model") then
                                            targetPart = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
                                        end
                                    end

                                    if targetPart and targetPart:IsA("BasePart") then
                                        if (hrp.Position - targetPart.Position).Magnitude <= 14 then
                                            fireproximityprompt(obj)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
})

MainTab:Toggle({
    Title = "Auto Key (Figure Library Puzzle)",
    Description = "Automatically gathers books in Room 50 and unlocks the door.",
    Value = false,
    Callback = function(state)
        autoKeyEnabled = state
        task.spawn(function()
            while autoKeyEnabled do
                task.wait(0.5)
                pcall(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if not hrp then return end

                    local rooms = Workspace:FindFirstChild("CurrentRooms")
                    if rooms then
                        for _, room in pairs(rooms:GetChildren()) do
                            if room.Name == "50" or room:FindFirstChild("FigureSetup") then
                                for _, item in pairs(room:GetDescendants()) do
                                    if item.Name == "LiveHintBook" and item:FindFirstChild("Prompt") then
                                        local prompt = item.Prompt
                                        local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                        if targetPart and (hrp.Position - targetPart.Position).Magnitude < 15 then
                                            fireproximityprompt(prompt)
                                        end
                                    end
                                end

                                local door = room:FindFirstChild("Door")
                                local padlock = door and door:FindFirstChild("Padlock")
                                if padlock then
                                    local prompt = padlock:FindFirstChild("Prompt") or padlock:FindFirstChildWhichIsA("ProximityPrompt")
                                    if prompt and (hrp.Position - padlock.Position).Magnitude < 12 then
                                        fireproximityprompt(prompt)
                                    end
                                end
                            end
                        end
                    end
                end)
            end
        end)
    end
})

-- =================================================================
-- 4. VISUALS & ESP
-- =================================================================
ESPTab:Toggle({
    Title = "ESP Doors, Keys, Levers & Books",
    Description = "Highlights active doors, keys, levers, and books (books only in Room 50).",
    Value = false,
    Callback = function(state)
        espItemsEnabled = state
    end
})

ESPTab:Toggle({
    Title = "ESP Closets / Wardrobes",
    Description = "Highlights hideable closets and wardrobes in purple.",
    Value = false,
    Callback = function(state)
        espClosetsEnabled = state
    end
})

ESPTab:Toggle({
    Title = "ESP Players",
    Description = "Highlights other players in blue.",
    Value = false,
    Callback = function(state)
        espPlayersEnabled = state
    end
})

ESPTab:Toggle({
    Title = "ESP Monsters / Entities",
    Description = "Highlights incoming entities in red.",
    Value = false,
    Callback = function(state)
        espEntitiesEnabled = state
    end
})

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if not espItemsEnabled and not espPlayersEnabled and not espEntitiesEnabled and not espClosetsEnabled then
                espFolder:ClearAllChildren()
                return
            end

            espFolder:ClearAllChildren()

            if espItemsEnabled then
                if Workspace:FindFirstChild("CurrentRooms") then
                    for _, room in pairs(Workspace.CurrentRooms:GetChildren()) do
                        local door = room:FindFirstChild("Door")
                        if door then
                            local targetPart = door:FindFirstChild("Knob") or door:FindFirstChild("Door") or door:FindFirstChildWhichIsA("BasePart")
                            if targetPart and targetPart:IsA("BasePart") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = targetPart
                                hl.FillColor = Color3.fromRGB(0, 255, 0)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.Parent = espFolder
                                createBillboard(targetPart, "🚪 door", Color3.fromRGB(0, 255, 0))
                            end
                        end

                        if room.Name == "50" or room:FindFirstChild("FigureSetup") then
                            for _, item in pairs(room:GetDescendants()) do
                                if item.Name == "LiveHintBook" then
                                    local targetPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                    if targetPart and targetPart:IsA("BasePart") then
                                        local hl = Instance.new("Highlight")
                                        hl.Adornee = item
                                        hl.FillColor = Color3.fromRGB(0, 200, 255)
                                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                        hl.FillTransparency = 0.4
                                        hl.Parent = espFolder
                                        createBillboard(targetPart, "📖 book", Color3.fromRGB(0, 200, 255))
                                    end
                                end
                            end
                        end
                    end
                end

                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        local labelText = ""
                        local color = Color3.fromRGB(255, 230, 0)

                        if (name == "key" or name == "keycard" or name == "padlock" or name:find("key[v%d]") or name:find("keyrig")) and not name:find("painting") then
                            labelText = "🔑 key"
                            color = Color3.fromRGB(255, 230, 0)
                        elseif name:find("lever") or name:find("breaker") or name:find("switch") then
                            labelText = "⚙️ lever"
                            color = Color3.fromRGB(255, 140, 0)
                        end

                        if labelText ~= "" then
                            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if targetPart and targetPart:IsA("BasePart") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillColor = color
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.Parent = espFolder
                                createBillboard(targetPart, labelText, color)
                            end
                        end
                    end
                end
            end

            if espClosetsEnabled then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Model") or obj:IsA("BasePart") then
                        local name = obj.Name:lower()
                        if name:find("wardrobe") or name:find("closet") or name:find("bed") then
                            local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                            if targetPart and targetPart:IsA("BasePart") then
                                local hl = Instance.new("Highlight")
                                hl.Adornee = obj
                                hl.FillColor = Color3.fromRGB(160, 32, 240)
                                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                hl.FillTransparency = 0.4
                                hl.Parent = espFolder
                                createBillboard(targetPart, "🗄️ closet", Color3.fromRGB(160, 32, 240))
                            end
                        end
                    end
                end
            end

            if espPlayersEnabled then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character then
                        local char = player.Character
                        local hrp = char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = char
                            hl.FillColor = Color3.fromRGB(0, 150, 255)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.4
                            hl.Parent = espFolder
                            createBillboard(hrp, player.Name, Color3.fromRGB(0, 150, 255))
                        end
                    end
                end
            end

            if espEntitiesEnabled then
                for _, entity in pairs(Workspace:GetChildren()) do
                    if monitoredEntities[entity.Name] or entity.Name == "RushMoving" or entity.Name == "AmbushMoving" or entity.Name == "Eyes" or entity.Name == "Halt" or entity.Name == "Figure" or entity.Name:lower():find("screech") then
                        local targetPart = entity:IsA("Model") and (entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")) or entity
                        if targetPart and targetPart:IsA("BasePart") then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = entity
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.Parent = espFolder
                            createBillboard(targetPart, "⚠️ " .. entity.Name, Color3.fromRGB(255, 0, 0))
                        end
                    end
                end
            end
        end)
    end
end)

-- =================================================================
-- 5. WORLD (FULLBRIGHT)
-- =================================================================
WorldTab:Toggle({
    Title = "Fullbright",
    Description = "Removes dark areas and makes everything bright.",
    Value = false,
    Callback = function(state)
        if state then
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 0
            Lighting.GlobalShadows = true
        end
    end
})

WindUI:Notify({
    Title = "Hoverly Script Updated",
    Content = "Auto Play removed. Script updated successfully!",
    Duration = 4
})

