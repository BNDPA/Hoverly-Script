--[[
    Project: Hoverly Script | DOORS (All Floors + Rooms, Smart Hide/Sit & Excluded Seek/Paintings/Vending)
    Features: Multi-Floor ESP, Smart Auto-Interact (No Seek, Paintings, Vending), All Entities ESP
    UI: NodiumUI
]]

local success, VantaUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/BNDPA/NodiumUI/raw/refs/heads/main/Latest.lua"))()
end)

if not success or not VantaUI then
    warn("Failed to load NodiumUI for DOORS script!")
    return
end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- 1. Создание главного окна
local Window = VantaUI:Window({
    title = "Hoverly Script | DOORS (Advanced)",
    width = 700,
    height = 450,
    DisplayOrder = 2147483647 -- Максимальный приоритет слоя, чтобы быть поверх настроек
})

-- Принудительное удержание GUI поверх всех системных окон и настроек
task.spawn(function()
    pcall(function()
        while true do
            task.wait(1)
            local coreGui = game:GetService("CoreGui")
            for _, gui in ipairs(coreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and (gui.Name:lower():find("vanta") or gui.Name:lower():find("nodium") or gui.Name:lower():find("hoverly")) then
                    gui.DisplayOrder = 2147483647
                    gui.IgnoreGuiInset = true
                    gui.ResetOnSpawn = false
                end
            end
            
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and (gui.Name:lower():find("vanta") or gui.Name:lower():find("nodium") or gui.Name:lower():find("hoverly")) then
                        gui.DisplayOrder = 2147483647
                        gui.IgnoreGuiInset = true
                        gui.ResetOnSpawn = false
                    end
                end
            end
        end
    end)
end)

-- 2. Плавающая передвигаемая кнопка-круг (Скрытие / Показ UI по клику)
local toggleCircle = Window:CreateDraggableCircle("rbxassetid://6023426915")

-- 3. Создание вкладок
local MainTab = Window:CreateTab("Main / Auto")
local PlayerTab = Window:CreateTab("Player")
local ESPTab = Window:CreateTab("ESP")
local WorldTab = Window:CreateTab("World")

-- 4. Создание секций
local MainSection = MainTab:CreateSection("Управление и Автоматизация")
local PlayerSection = PlayerTab:CreateSection("Игрок")
local ESPSection = ESPTab:CreateSection("Подсветка (ESP)")
local WorldSection = WorldTab:CreateSection("Мир и Окружение")

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
local sallyActive = false

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
MainSection:CreateToggle("Entity Notifier (Notice)", false, function(state)
    entityNotifierEnabled = state
end)

MainSection:CreateToggle("Auto Check Screech", false, function(state)
    autoCheckScreechEnabled = state
end)

local monitoredEntities = {
    ["Rush"] = "Rush is coming! HIDE NOW!",
    ["Sally"] = "Sally is active!",
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
    if name == "Sally" or name == "SallyActive" then
        sallyActive = true
    end

    if monitoredEntities[name] or name:find("A-") or name:find("Rush") or name:find("Ambush") then
        if name ~= "Eyes" and name ~= "Screech" and name ~= "Snare" and name ~= "Timothy" and name ~= "A-90" and name ~= "SeekMoving" then
            monsterActive = true
        end

        if entityNotifierEnabled then
            warn("⚠️ WARNING: " .. name .. " -> " .. (monitoredEntities[name] or "Dangerous entity spawned!"))
        end
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    local name = child.Name
    if name == "Sally" or name == "SallyActive" then
        sallyActive = false
    end

    if monitoredEntities[name] or name:find("A-") or name:find("Rush") or name:find("Ambush") then
        local dangerFound = false
        for _, entName in pairs({"Rush", "AmbushMoving", "A-60", "A-120", "Halt", "Figure"}) do
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
PlayerSection:CreateToggle("Smart NoClip (Small Parts Only)", false, function(state)
    noclipEnabled = state
end)

PlayerSection:CreateToggle("Speed (20)", false, function(state)
    speedEnabled = state
end)

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
-- 3. AUTO INTERACT
-- =================================================================
MainSection:CreateToggle("Auto Open Doors, Keys, Levers & Lockers", false, function(state)
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
                            local parentName = parent and parent.Name or ""
                            local parentNameLower = parentName:lower()
                            local grandparent = parent and parent.Parent
                            local grandparentName = grandparent and grandparent.Name:lower() or ""
                            
                            local isIgnored = false

                            -- Игнорируем объекты, начинающиеся с Binder, а также PrincpalChair и старые исключения
                            if parentName:sub(1, 6) == "Binder" or parentName == "PrincpalChair" or 
                               parentName == "Desk_bell" or parentName == "Regal_chair" or parentName == "Vendor_snakelightVendingMachine" or
                               parentName == "ArchivesTerminal" or parentName == "ArchivesTrashcan" or parentName == "ArchivesLargePrinter" then
                                isIgnored = true
                            end

                            if parentNameLower:find("vending") or parentNameLower:find("shop") or parentNameLower:find("jeff") or 
                               parentNameLower:find("painting") or parentNameLower:find("portrait") or parentNameLower:find("canvas") or
                               parentNameLower:find("seek") or grandparentName:find("seek") or actionText:find("seek") or
                               grandparentName:find("vending") or grandparentName:find("shop") or actionText:find("buy") then
                                isIgnored = true
                            end

                            local isHideOrSit = actionText:find("hide") or actionText:find("enter") or actionText:find("sit") or
                                                 parentNameLower:find("wardrobe") or parentNameLower:find("closet") or parentNameLower:find("bed") or 
                                                 parentNameLower:find("locker") or parentNameLower:find("chair") or parentNameLower:find("seat") or parentNameLower:find("bench")

                            if isHideOrSit then
                                -- Если активна Салли или нет опасных монстров (кроме глаз), то прятаться/садиться не нужно
                                if sallyActive or (not monsterActive) then
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
end)

MainSection:CreateToggle("Auto Books & Puzzles", false, function(state)
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
end)

-- =================================================================
-- 4. MULTI-FLOOR & ROOMS ESP
-- =================================================================
ESPSection:CreateToggle("ESP Doors, Keys, Levers, Books", false, function(state)
    espItemsEnabled = state
end)

ESPSection:CreateToggle("ESP Closets / Hiding Spots", false, function(state)
    espClosetsEnabled = state
end)

ESPSection:CreateToggle("ESP Players", false, function(state)
    espPlayersEnabled = state
end)

ESPSection:CreateToggle("ESP ALL Monsters / Entities", false, function(state)
    espEntitiesEnabled = state
end)

task.spawn(function()
    while true do
        task.wait(1)
        pcall(function()
            if not espItemsEnabled and not espPlayersEnabled and not espEntitiesEnabled and not espClosetsEnabled then
                espFolder:ClearAllChildren()
                return
            end

            espFolder:ClearAllChildren()

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
                            local itemName = item.Name
                            local itemNameLower = itemName:lower()
                            
                            -- Пропускаем PaperPlanePickup и всё, что начинается с Binder
                            if itemName ~= "PaperPlanePickup" and itemName:sub(1, 6) ~= "Binder" then
                                local labelText = ""
                                local color = Color3.fromRGB(255, 230, 0)

                                if itemNameLower == "livehintbook" then
                                    labelText = "📖 book"
                                    color = Color3.fromRGB(0, 200, 255)
                                elseif itemNameLower:find("breaker") or itemNameLower:find("switch") or itemNameLower:find("lever") then
                                    labelText = "⚙️ mechanism"
                                    color = Color3.fromRGB(255, 140, 0)
                                elseif itemNameLower == "key" or itemNameLower == "keycard" or itemNameLower == "padlock" then
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
                    end

                    if espClosetsEnabled then
                        for _, obj in pairs(room:GetDescendants()) do
                            local name = obj.Name
                            local nameLower = name:lower()
                            
                            -- Пропускаем шкафы/укрытия, начинающиеся с Binder
                            if name:sub(1, 6) ~= "Binder" then
                                if nameLower:find("wardrobe") or nameLower:find("closet") or nameLower:find("bed") or nameLower:find("locker") or nameLower:find("hide") then
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
                    
                    -- Сущности, начинающиеся с Binder, тоже не трогаем в ESP
                    if entityName:sub(1, 6) ~= "Binder" then
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
            end
        end)
    end
end)

-- =================================================================
-- 5. WORLD (FULLBRIGHT)
-- =================================================================
WorldSection:CreateToggle("Fullbright", false, function(state)
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
end)
