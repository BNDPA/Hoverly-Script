--[[
    Project: Hoverly Script | DOORS (All Floors + Rooms, Smart Hide/Sit & Fixed ESP/Interact)
    Features: Multi-Floor ESP (Fixed), Smart Auto-Interact (No Paintings/Vending, Smart Hide on Monster), All Entities ESP
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
    Title = "Hoverly Script | DOORS (Advanced)",
    Icon = "door-closed",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = true,
})

local MainTab = Window:Tab({ Title = "Main / Auto", Icon = "home" })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
local ESPTab = Window:Tab({ Title = "Multi-Floor ESP", Icon = "eye" })
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
-- 1. ALL ENTITIES NOTIFIER & SCREECH AUTO CHECK
-- =================================================================
MainTab:Toggle({
    Title = "Entity Notifier (Notice)",
    Description = "Warns you when ANY entity spawns (Rush, Ambush, A-60, A-90, A-120, Figure, Seek, etc).",
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
    ["A-60"] = "A-60 (The Rooms) is coming! HIDE IN A LOCKER!",
    ["A-90"] = "A-90 (The Rooms) appeared! STOP MOVING COMPLETELY!",
    ["A-120"] = "A-120 (The Rooms) is coming! HIDE QUICKLY!",
    ["Screech"] = "Screech appeared! Looking at him...",
    ["Glitch"] = "Glitch teleported you!",
    ["Snare"] = "Floor trap (Snare) nearby!",
    ["Figure"] = "Figure is near! Stay crouched and quiet!",
    ["SeekMoving"] = "SEEK CHASE! RUN!",
    ["Timothy"] = "Timothy jumped out of a drawer!",
    ["Jack"] = "Jack spooky event!",
    ["Void"] = "Void caught you lagging behind!"
}

Workspace.ChildAdded:Connect(function(child)
    local name = child.Name
    if monitoredEntities[name] or name:find("A-") or name:find("Rush") or name:find("Ambush") then
        if name ~= "Eyes" and name ~= "Screech" and name ~= "Snare" and name ~= "Timothy" and name ~= "A-90" then
            monsterActive = true
        end

        if entityNotifierEnabled then
            WindUI:Notify({
                Title = "⚠️ WARNING: " .. name,
                Content = monitoredEntities[name] or ("Dangerous entity " .. name .. " spawned!"),
                Duration = 4
            })
        end
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    local name = child.Name
    if monitoredEntities[name] or name:find("A-") or name:find("Rush") or name:find("Ambush") then
        local dangerFound = false
        for _, entName in pairs({"RushMoving", "AmbushMoving", "A-60", "A-120", "Halt", "Figure", "SeekMoving"}) do
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
-- 2. PLAYER UTILITIES (Smart NoClip & Speed)
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
-- 3. AUTO INTERACT (Игнор автоматов, картин и сидений без набега)
-- =================================================================
MainTab:Toggle({
    Title = "Auto Open Doors, Keys, Levers & Lockers",
    Description = "Interacts with doors, keys, levers. Seats & lockers auto-hide ONLY during monster raids. Vending & Paintings ignored.",
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
                                local parent = obj.Parent
                                local parentName = parent and parent.Name:lower() or ""
                                local grandparent = parent and parent.Parent
                                local grandparentName = grandparent and grandparent.Name:lower() or ""
                                
                                local isIgnored = false

                                -- 1. Игнор автоматов с фонариками, магазинов и КАРИИН (Paintings / Portrait)
                                if parentName:find("vending") or parentName:find("shop") or parentName:find("jeff") or 
                                   parentName:find("painting") or parentName:find("portrait") or parentName:find("canvas") or
                                   grandparentName:find("vending") or grandparentName:find("shop") or actionText:find("buy") then
                                    isIgnored = true
                                end

                                -- 2. Логика для укрытий и сидений
                                local isHideOrSit = actionText:find("hide") or actionText:find("enter") or actionText:find("sit") or
                                                     parentName:find("wardrobe") or parentName:find("closet") or parentName:find("bed") or 
                                                     parentName:find("locker") or parentName:find("chair") or parentName:find("seat") or parentName:find("bench")

                                if isHideOrSit then
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
    Title = "Auto Books & Puzzles (Library / Mines)",
    Description = "Automatically gathers books in Room 50, breaker boxes in Mines, and solves key-locks.",
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
                            for _, item in pairs(room:GetDescendants()) do
                                if (item.Name == "LiveHintBook" or item.Name:lower():find("breaker")) and item:FindFirstChild("Prompt") then
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
                end)
            end
        end)
    end
})

-- =================================================================
-- 4. MULTI-FLOOR & ROOMS ESP (Fixed spawn/door bug)
-- =================================================================
ESPTab:Toggle({
    Title = "ESP Doors, Keys, Levers, Books & Breakers",
    Description = "Highlights progression items strictly inside active rooms.",
    Value = false,
    Callback = function(state)
        espItemsEnabled = state
    end
})

ESPTab:Toggle({
    Title = "ESP Closets / Hiding Spots / Lockers",
    Description = "Highlights wardrobes, lockers, beds, and safe hiding spots in purple.",
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
    Title = "ESP ALL Monsters / Entities",
    Description = "Highlights ALL incoming entities across ALL floors (Rush, Ambush, A-60, A-120, Figure, Seek, etc.) in red.",
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

            -- Работаем строго внутри CurrentRooms, чтобы убрать спавн-баги перед дверями извне
            local roomsContainer = Workspace:FindFirstChild("CurrentRooms")
            if roomsContainer then
                for _, room in pairs(roomsContainer:GetChildren()) do
                    local door = room:FindFirstChild("Door")
                    if door and espItemsEnabled then
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

                    if espItemsEnabled then
                        for _, item in pairs(room:GetDescendants()) do
                            local itemName = item.Name:lower()
                            local labelText = ""
                            local color = Color3.fromRGB(255, 230, 0)

                            if itemName == "livehintbook" then
                                labelText = "📖 book"
                                color = Color3.fromRGB(0, 200, 255)
                            elseif itemName:find("breaker") or itemName:find("switch") or itemName:find("lever") then
                                labelText = "⚙️ mechanism"
                                color = Color3.fromRGB(255, 140, 0)
                            elseif itemName == "key" or itemName == "keycard" or itemName == "padlock" then
                                labelText = "🔑 key"
                                color = Color3.fromRGB(255, 230, 0)
                            end

                            if labelText ~= "" then
                                local targetPart = item:IsA("Model") and (item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")) or item
                                if targetPart and targetPart:IsA("BasePart") then
                                    local hl = Instance.new("Highlight")
                                    hl.Adornee = item
                                    hl.FillColor = color
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.FillTransparency = 0.4
                                    hl.Parent = espFolder
                                    createBillboard(targetPart, labelText, color)
                                end
                            end
                        end
                    end

                    if espClosetsEnabled then
                        for _, obj in pairs(room:GetDescendants()) do
                            local name = obj.Name:lower()
                            if name:find("wardrobe") or name:find("closet") or name:find("bed") or name:find("locker") or name:find("hide") then
                                local targetPart = obj:IsA("Model") and (obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")) or obj
                                if targetPart and targetPart:IsA("BasePart") then
                                    local hl = Instance.new("Highlight")
                                    hl.Adornee = obj
                                    hl.FillColor = Color3.fromRGB(160, 32, 240)
                                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                                    hl.FillTransparency = 0.4
                                    hl.Parent = espFolder
                                    createBillboard(targetPart, "🗄️ hiding spot", Color3.fromRGB(160, 32, 240))
                                end
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
                    local entityName = entity.Name
                    local nameLower = entityName:lower()
                    
                    local isMonster = monitoredEntities[entityName] or 
                                      nameLower:find("rush") or 
                                      nameLower:find("ambush") or 
                                      nameLower:find("eyes") or 
                                      nameLower:find("halt") or 
                                      nameLower:find("figure") or 
                                      nameLower:find("seek") or 
                                      nameLower:find("screech") or 
                                      nameLower:find("snare") or 
                                      nameLower:find("dupe") or 
                                      nameLower:find("glitch") or 
                                      entityName:find("A-")

                    if isMonster then
                        local targetPart = entity:IsA("Model") and (entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")) or entity
                        if targetPart and targetPart:IsA("BasePart") then
                            local hl = Instance.new("Highlight")
                            hl.Adornee = entity
                            hl.FillColor = Color3.fromRGB(255, 0, 0)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.FillTransparency = 0.3
                            hl.Parent = espFolder
                            createBillboard(targetPart, "⚠️ " .. entityName, Color3.fromRGB(255, 0, 0))
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
    Content = "Paintings & Spawn-ESP bugs fixed!",
    Duration = 4
})

