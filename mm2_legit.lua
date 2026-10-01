--[[
    Project: Hoverly | Murder Mystery 2
    UI Library: VantaUI v4.5 (Cleaned & Optimized)
]]

local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace")
}
Services.LocalPlayer = Services.Players.LocalPlayer

getgenv().ChinaHatSettings = {
    enabled = true,
    hatColor = Color3.fromRGB(255, 105, 180),
    lightColor = Color3.fromRGB(255, 105, 180),
    lightBrightness = 0,
    lightRange = 12,
    scale = Vector3.new(1.7, 1.1, 1.7),
}

local function CreateHat(Character)
    local Head = Character:FindFirstChild("Head")
    if not Head then return end

    local Cone = Instance.new("Part")
    Cone.Name = "RuzChinaHat"
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
end

local function OnCharacterAdded(Character)
    if getgenv().ChinaHatSettings.enabled then
        Character:WaitForChild("Head")
        CreateHat(Character)
    end
end

Services.LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)
if Services.LocalPlayer.Character then
    OnCharacterAdded(Services.LocalPlayer.Character)
end

-- =====================================================================
-- HOVERLY | MURDER MYSTERY 2 (VantaUI v4.5 Framework)
-- =====================================================================

local VantaUI = {}
VantaUI.__index = VantaUI

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local RunService       = game:GetService("RunService")
local Workspace        = game:GetService("Workspace")
local LocalPlayer      = Players.LocalPlayer

local THEME = {
    bg         = Color3.fromRGB(16, 16, 20),
    bg_alt     = Color3.fromRGB(22, 22, 28),
    sidebar    = Color3.fromRGB(12, 12, 16),
    border     = Color3.fromRGB(40, 40, 50),
    text       = Color3.fromRGB(232, 232, 238),
    text_dim   = Color3.fromRGB(142, 142, 154),
    text_mute  = Color3.fromRGB(90, 90, 102),
    accent     = Color3.fromRGB(120, 160, 255),
    accent_bg  = Color3.fromRGB(32, 44, 74),
    accent_dim = Color3.fromRGB(52, 78, 138),
    danger     = Color3.fromRGB(230, 80, 90),
    track      = Color3.fromRGB(42, 42, 52),
    shadow     = Color3.fromRGB(0, 0, 0),
    row        = Color3.fromRGB(24, 24, 30),
}

local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED  = Enum.Font.GothamMedium

local function tween(obj, time, props)
    local ok = pcall(function()
        TweenService:Create(obj, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
    if not ok then for k, v in pairs(props) do obj[k] = v end end
end

local function new(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(obj, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, obj)
end

local function stroke(obj, color, thick, trans)
    return new("UIStroke", {
        Color = color or THEME.border, Thickness = thick or 1,
        Transparency = trans or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, obj)
end

local function resolveParent()
    local gui = new("ScreenGui", {
        Name = "VantaUI_" .. tostring(math.random(100000, 999999)),
        ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true, DisplayOrder = 9999,
    })
    if gethui then
        local ok = pcall(function() gui.Parent = gethui() end)
        if ok and gui.Parent then return gui end
    end
    local ok = pcall(function() gui.Parent = CoreGui end)
    if ok and gui.Parent then return gui end
    ok = pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    if ok and gui.Parent then return gui end
    gui.Parent = CoreGui
    return gui
end

local function viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end

local function draggable(frame, handle)
    handle = handle or frame
    local dragging, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            local conn
            conn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if conn then conn:Disconnect() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

local function confirmModal(gui, text, onYes)
    local overlay = new("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = THEME.shadow,
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false, ZIndex = 200,
    }, gui)
    tween(overlay, 0.12, { BackgroundTransparency = 0.5 })

    local box = new("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(280, 140), BackgroundColor3 = THEME.bg_alt,
        BorderSizePixel = 0, ZIndex = 201,
    }, overlay)
    corner(box, 10); stroke(box, THEME.border, 1, 0)

    new("TextLabel", {
        Size = UDim2.new(1, -24, 0, 24), Position = UDim2.fromOffset(14, 16),
        BackgroundTransparency = 1, Font = FONT_MED, Text = text,
        TextColor3 = THEME.text, TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 202,
    }, box)

    local function mkBtn(label, xScale, bg, cb)
        local b = new("TextButton", {
            Size = UDim2.new(0.5, -18, 0, 32),
            Position = UDim2.new(xScale, 12, 1, -48),
            BackgroundColor3 = bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = label, TextColor3 = THEME.text,
            TextSize = 13, AutoButtonColor = false, ZIndex = 202,
        }, box)
        corner(b, 6)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg:Lerp(Color3.new(1,1,1), 0.1) }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = bg }) end)
        b.MouseButton1Click:Connect(function() overlay:Destroy(); if cb then cb() end end)
    end
    mkBtn("Нет", 0,   THEME.bg)
    mkBtn("Да",  0.5, THEME.danger, onYes)
end

function VantaUI:Window(cfg)
    cfg = cfg or {}
    local title = cfg.title or "VANTA UI"
    local vp    = viewport()

    local width  = math.min(cfg.width  or 720, vp.X - 40)
    local height = math.min(cfg.height or 420, vp.Y - 40)
    width  = math.max(width,  480)
    height = math.max(height, 300)

    local gui = resolveParent()
    local win = { tabs = {}, gui = gui, visible = true, width = width, height = height }

    local panel = new("Frame", {
        Name = "Panel",
        AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = THEME.bg, BorderSizePixel = 0, ClipsDescendants = true,
    }, gui)
    corner(panel, 10); stroke(panel, THEME.border, 1, 0)
    win.panel = panel

    local topbar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0,
        ZIndex = 5,
    }, panel)
    corner(topbar, 10)

    new("Frame", {
        Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0, ZIndex = 6,
    }, topbar)

    new("Frame", {
        Position = UDim2.fromOffset(14, 15),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
        ZIndex = 7,
    }, topbar)

    new("TextLabel", {
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -120, 1, 0), BackgroundTransparency = 1,
        Font = FONT_BOLD, Text = title, TextColor3 = THEME.text,
        TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 7,
    }, topbar)

    local function ctrlBtn(glyph, xOffset, hoverColor)
        local b = new("TextButton", {
            Position = UDim2.new(1, -xOffset, 0, 8),
            Size = UDim2.fromOffset(20, 20),
            BackgroundColor3 = THEME.bg, BorderSizePixel = 0,
            Font = FONT_MED, Text = glyph, TextColor3 = THEME.text_dim,
            TextSize = 13, AutoButtonColor = false, ZIndex = 8,
        }, topbar)
        corner(b, 5)
        b.MouseEnter:Connect(function() tween(b, 0.1, { BackgroundColor3 = hoverColor, TextColor3 = THEME.text }) end)
        b.MouseLeave:Connect(function() tween(b, 0.1, { BackgroundColor3 = THEME.bg, TextColor3 = THEME.text_dim }) end)
        return b
    end
    local btnMin   = ctrlBtn("–", 32, THEME.accent_dim)
    local btnClose = ctrlBtn("×", 58, THEME.danger)

    local sidebar = new("Frame", {
        Position = UDim2.new(0, 0, 0, 36),
        Size = UDim2.new(0, 160, 1, -36),
        BackgroundColor3 = THEME.sidebar, BorderSizePixel = 0,
        ZIndex = 2,
    }, panel)

    new("Frame", {
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = THEME.border, BorderSizePixel = 0,
        ZIndex = 3,
    }, sidebar)

    local tabList = new("ScrollingFrame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
    }, sidebar)
    new("UIListLayout", { Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder }, tabList)

    local content = new("Frame", {
        Position = UDim2.new(0, 160, 0, 36),
        Size = UDim2.new(1, -160, 1, -36),
        BackgroundTransparency = 1,
        ZIndex = 2,
    }, panel)
    win.content = content

    draggable(panel, topbar)

    local minimized = false
    btnMin.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(panel, 0.18, { Size = minimized and UDim2.fromOffset(width, 36) or UDim2.fromOffset(width, height) })
        sidebar.Visible = not minimized
        content.Visible = not minimized
    end)
    btnClose.MouseButton1Click:Connect(function()
        confirmModal(gui, "Точно закрыть окно?", function() gui:Destroy() end)
    end)

    function win:CreateTab(name)
        name = name or "tab"

        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = THEME.sidebar, BorderSizePixel = 0,
            Font = FONT_MED, Text = "  " .. name, TextColor3 = THEME.text_dim,
            TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            ZIndex = 4,
        }, tabList)
        corner(btn, 6)

        local page = new("ScrollingFrame", {
            Size = UDim2.new(1, -16, 1, -16),
            Position = UDim2.fromOffset(8, 8),
            BackgroundTransparency = 1, BorderSizePixel = 0,
            ScrollBarThickness = 3, ScrollBarImageColor3 = THEME.border,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            ZIndex = 3,
        }, content)
        new("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, page)

        local tab = { page = page, btn = btn, win = win, sections = {} }
        setmetatable(tab, win)

        local function activate()
            for _, t in ipairs(win.tabs) do
                t.page.Visible = false
                t.btn.BackgroundColor3 = THEME.sidebar
                t.btn.TextColor3 = THEME.text_dim
            end
            page.Visible = true
            btn.BackgroundColor3 = THEME.accent_bg
            btn.TextColor3 = THEME.text
        end

        btn.MouseButton1Click:Connect(activate)
        if #win.tabs == 0 then activate() end
        table.insert(win.tabs, tab)

        function tab:CreateSection(name)
            name = name or "Section"

            local wrap = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = THEME.bg_alt, BorderSizePixel = 0,
                ZIndex = 4,
            }, page)
            corner(wrap, 8)
            stroke(wrap, THEME.border, 1, 0.35)
            new("UIPadding", {
                PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10),
            }, wrap)
            new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, wrap)

            new("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14), BackgroundTransparency = 1,
                Font = FONT_BOLD, Text = string.upper(name),
                TextColor3 = THEME.text_mute, TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 5,
            }, wrap)

            local section = { frame = wrap, tab = tab, win = win }
            setmetatable(section, tab)
            table.insert(tab.sections, section)

            local function rowScaffold(label, height)
                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, height or 22),
                    BackgroundTransparency = 1,
                    ZIndex = 5,
                }, wrap)
                new("TextLabel", {
                    Size = UDim2.new(1, -110, 1, 0), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = label, TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }, row)
                return row
            end

            function section:CreateToggle(name, default, callback)
                local state = default or false
                local row = rowScaffold(name or "Toggle", 22)

                local track = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(30, 16),
                    BackgroundColor3 = THEME.track, BorderSizePixel = 0,
                    ZIndex = 6,
                }, row)
                corner(track, 8)
                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = THEME.text_dim, BorderSizePixel = 0,
                    ZIndex = 7,
                }, track)
                corner(knob, 6)

                local function render()
                    tween(track, 0.12, { BackgroundColor3 = state and THEME.accent_dim or THEME.track })
                    tween(knob, 0.12, {
                        Position = state and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = state and THEME.accent or THEME.text_dim,
                    })
                end
                render()

                local click = new("TextButton", {
                    Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1,
                    Text = "", AutoButtonColor = false, ZIndex = 8,
                }, row)
                click.MouseButton1Click:Connect(function()
                    state = not state; render()
                    if callback then callback(state) end
                end)
                return {
                    Set = function(_, v) state = v; render() end,
                    Get = function() return state end,
                }
            end

            function section:CreateSlider(name, min, max, default, callback)
                min, max = min or 0, max or 100
                local step  = 1
                local value = default or min

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1,
                    ZIndex = 5,
                }, wrap)
                new("TextLabel", {
                    Size = UDim2.new(1, -60, 0, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = name or "Slider", TextColor3 = THEME.text,
                    TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 6,
                }, row)
                local valLbl = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.fromOffset(56, 14), BackgroundTransparency = 1,
                    Font = FONT_MED, Text = tostring(value),
                    TextColor3 = THEME.accent, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 6,
                }, row)

                local bar = new("Frame", {
                    Position = UDim2.new(0, 0, 1, -10),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = THEME.track, BorderSizePixel = 0,
                    ZIndex = 6,
                }, row)
                corner(bar, 2)
                local fill = new("Frame", {
                    Size = UDim2.new(0, 0, 1, 0),
                    BackgroundColor3 = THEME.accent, BorderSizePixel = 0,
                    ZIndex = 7,
                }, bar)
                corner(fill, 2)
                local dot = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 0, 0.5, 0),
                    Size = UDim2.fromOffset(8, 8),
                    BackgroundColor3 = THEME.text, BorderSizePixel = 0,
                    ZIndex = 8,
                }, bar)
                corner(dot, 4)

                local dragging = false
                local function setFromX(x)
                    local rel = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
                    local raw = min + (max - min) * rel
                    value = math.floor(raw / step + 0.5) * step
                    value = math.clamp(value, min, max)
                    local r2 = (value - min) / math.max(max - min, 1e-6)
                    fill.Size = UDim2.new(r2, 0, 1, 0)
                    dot.Position = UDim2.new(r2, 0, 0.5, 0)
                    valLbl.Text = tostring(value)
                    if callback then callback(value) end
                end
                local function render()
                    local r2 = (value - min) / math.max(max - min, 1e-6)
                    fill.Size = UDim2.new(r2, 0, 1, 0)
                    dot.Position = UDim2.new(r2, 0, 0.5, 0)
                    valLbl.Text = tostring(value)
                end
                render()

                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; setFromX(input.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        setFromX(input.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                return {
                    Set = function(_, v) value = math.clamp(v, min, max); render() end,
                    Get = function() return value end,
                }
            end

            return section
        end

        return tab
    end

    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            win.visible = not win.visible
            panel.Visible = win.visible
        end
    end)

    return setmetatable(win, win)
end

-- =====================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- =====================================================================

local win = VantaUI:Window({
    title  = "Hoverly | Murder Mystery 2",
    width  = 580,
    height = 440,
})

local mainTab   = win:CreateTab("Main")
local visualTab = win:CreateTab("Visuals")
local farmTab   = win:CreateTab("Auto Farm")
local combatTab = win:CreateTab("Combat")
local trollTab  = win:CreateTab("Troll")

-- =====================================================================
-- 1. MAIN TAB
-- =====================================================================

local mainSec = mainTab:CreateSection("Movement")
local speedGlitchEnabled = true
local speedGlitchSpeed   = 20

mainSec:CreateToggle("SpeedGlitch", true, function(state) speedGlitchEnabled = state end)
mainSec:CreateSlider("SpeedGlitch Value", 10, 60, 20, function(val) speedGlitchSpeed = val end)

mainSec:CreateToggle("Enable WalkSpeed (18)", false, function(state)
    getgenv().CustomWS = state
    task.spawn(function()
        while getgenv().CustomWS do
            task.wait(0.1)
            pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 18 end)
        end
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end)
    end)
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if speedGlitchEnabled and hum and hrp then
        if hum.FloorMaterial == Enum.Material.Air then
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local currentVel = hrp.Velocity
                local newVel = Vector3.new(moveDir.X * speedGlitchSpeed, currentVel.Y, moveDir.Z * speedGlitchSpeed)
                hrp.Velocity = newVel
                hrp.AssemblyLinearVelocity = newVel
            end
        end
    end
end)

-- =====================================================================
-- 2. VISUALS TAB
-- =====================================================================

local espSec       = visualTab:CreateSection("Player ESP & Indicators")
local espEnabled   = false
local arrowsEnabled = false
local espData      = {}
local arrowDrawings = {}

local function getPlayerRole(player)
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if not backpack and not char then return "Innocent" end

    local function check(container)
        if not container then return false end
        for _, item in ipairs(container:GetChildren()) do
            if item.Name == "Knife" then return "Murderer" end
            if item.Name == "Gun"   then return "Sheriff"  end
        end
        return false
    end

    if check(backpack) then
        for _, item in ipairs(backpack:GetChildren()) do
            if item.Name == "Knife" then return "Murderer" end
            if item.Name == "Gun"   then return "Sheriff"  end
        end
    end
    if char and check(char) then
        for _, item in ipairs(char:GetChildren()) do
            if item.Name == "Knife" then return "Murderer" end
            if item.Name == "Gun"   then return "Sheriff"  end
        end
    end
    return "Innocent"
end

local function removeESP(player)
    if espData[player] then
        if espData[player].highlight then espData[player].highlight:Destroy() end
        if espData[player].billboard then espData[player].billboard:Destroy() end
        espData[player] = nil
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    removeESP(player)
    if not player.Character then return end

    local char = player.Character
    local hl = Instance.new("Highlight")
    hl.Adornee = char
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0.1
    hl.Enabled = espEnabled
    hl.Parent = CoreGui

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.new(0, 100, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = espEnabled
    bb.Adornee = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = FONT_BOLD
    lbl.TextSize = 12
    lbl.TextStrokeTransparency = 0
    lbl.Parent = bb
    bb.Parent = CoreGui

    espData[player] = { highlight = hl, billboard = bb, label = lbl }
end

espSec:CreateToggle("Enable ESP", false, function(state)
    espEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then applyESP(p) end
        end
    else
        for p, _ in pairs(espData) do removeESP(p) end
    end
end)

local DistFromCenter = 80
local TriangleHeight = 16
local TriangleWidth  = 16

local function GetRelative(pos, char)
    if not char or not char.PrimaryPart then return Vector2.new(0, 0) end
    local rootP = char.PrimaryPart.Position
    local camP  = Workspace.CurrentCamera.CFrame.Position
    local relative = CFrame.new(Vector3.new(rootP.X, camP.Y, rootP.Z), camP):PointToObjectSpace(pos)
    return Vector2.new(relative.X, relative.Z)
end

local function RelativeToCenter(v)
    return Workspace.CurrentCamera.ViewportSize / 2 - v
end

local function RotateVect(v, a)
    a = math.rad(a)
    return Vector2.new(v.x * math.cos(a) - v.y * math.sin(a), v.x * math.sin(a) + v.y * math.cos(a))
end

local function InitArrowForPlayer(player)
    if player == LocalPlayer then return end
    local arrow = Drawing.new("Triangle")
    arrow.Visible = false
    arrow.Color = Color3.fromRGB(255, 255, 255)
    arrow.Filled = true
    arrow.Thickness = 1
    arrow.Transparency = 1
    arrowDrawings[player] = arrow

    local conn
    conn = RunService.RenderStepped:Connect(function()
        if not arrowsEnabled or not player or not player.Parent or not player.Character or not player.Character.PrimaryPart then
            arrow.Visible = false
            if not player or not player.Parent then
                arrow:Remove()
                if conn then conn:Disconnect() end
                arrowDrawings[player] = nil
            end
            return
        end

        local char = player.Character
        local hum  = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            local _, vis = Workspace.CurrentCamera:WorldToViewportPoint(char.PrimaryPart.Position)
            if not vis then
                local rel = GetRelative(char.PrimaryPart.Position, LocalPlayer.Character)
                local direction = rel.unit
                local base = direction * DistFromCenter
                local sideLength = TriangleWidth / 2
                local baseL = base + RotateVect(direction,  90) * sideLength
                local baseR = base + RotateVect(direction, -90) * sideLength
                local tip   = direction * (DistFromCenter + TriangleHeight)

                arrow.PointA = RelativeToCenter(baseL)
                arrow.PointB = RelativeToCenter(baseR)
                arrow.PointC = RelativeToCenter(tip)

                local role = getPlayerRole(player)
                if role == "Murderer" then arrow.Color = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then arrow.Color = Color3.fromRGB(0, 120, 255)
                else arrow.Color = Color3.fromRGB(255, 255, 255) end
                arrow.Visible = true
            else
                arrow.Visible = false
            end
        else
            arrow.Visible = false
        end
    end)
end

espSec:CreateToggle("Enable Offscreen Arrows", false, function(state)
    arrowsEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do
            if not arrowDrawings[p] then InitArrowForPlayer(p) end
        end
    else
        for _, arr in pairs(arrowDrawings) do arr.Visible = false end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(1); applyESP(p) end)
    p.CharacterRemoving:Connect(function() removeESP(p) end)
    if arrowsEnabled then InitArrowForPlayer(p) end
end)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        if p.Character then applyESP(p) end
        p.CharacterAdded:Connect(function() task.wait(1); applyESP(p) end)
        p.CharacterRemoving:Connect(function() removeESP(p) end)
        InitArrowForPlayer(p)
    end
end

RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local data = espData[player]
            if data and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                data.highlight.Enabled = true
                data.billboard.Enabled = true
                local role = getPlayerRole(player)
                local col = Color3.fromRGB(0, 255, 0)
                if role == "Murderer" then col = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then col = Color3.fromRGB(0, 120, 255) end
                data.highlight.FillColor    = col
                data.highlight.OutlineColor = col
                data.label.TextColor3 = col
                data.label.Text = player.Name .. "\n[" .. role .. "]"
            else
                if data then
                    data.highlight.Enabled = false
                    data.billboard.Enabled = false
                end
            end
        end
    end
end)

local chinaSec = visualTab:CreateSection("China Hat (Визуал)")
chinaSec:CreateToggle("China Hat (Конус на голову)", getgenv().ChinaHatSettings.enabled, function(state)
    getgenv().ChinaHatSettings.enabled = state
    if state then
        OnCharacterAdded(LocalPlayer.Character)
    else
        pcall(function() LocalPlayer.Character:FindFirstChild("RuzChinaHat"):Destroy() end)
    end
end)
chinaSec:CreateSlider("Hat Light Brightness", 0, 10, 0, function(val)
    getgenv().ChinaHatSettings.lightBrightness = val
    pcall(function() LocalPlayer.Character.RuzChinaHat.PointLight.Brightness = val end)
end)

-- =====================================================================
-- 3. AUTO FARM TAB
-- =====================================================================

local farmSec = farmTab:CreateSection("Candy/Coin Farm")
local FarmSettings = { Enabled = false, Speed = 25 }
local FarmState    = { ignoredCoins = {}, currentTween = nil }

local function getTorso(char)
    if not char then return nil end
    return char:FindFirstChild("Torso") or char:FindFirstChild("LowerTorso") or char:FindFirstChild("HumanoidRootPart")
end

local function getNearestCoin(torso)
    local container
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name == "CoinContainer" then container = obj; break end
    end
    if not container then return nil end
    local nearestCoin, minDist = nil, math.huge
    for _, coin in pairs(container:GetChildren()) do
        if coin.Name == "Coin_Server" and coin:IsA("BasePart") and not FarmState.ignoredCoins[coin] then
            local dist = (torso.Position - coin.Position).Magnitude
            if dist < minDist then minDist = dist; nearestCoin = coin end
        end
    end
    return nearestCoin
end

task.spawn(function()
    while task.wait() do
        if FarmSettings.Enabled then
            pcall(function()
                local char  = LocalPlayer.Character
                if not char then return end
                local hrp   = char:FindFirstChild("HumanoidRootPart")
                local torso = getTorso(char)
                local hum   = char:FindFirstChildOfClass("Humanoid")
                if not hrp or not torso or not hum then return end

                local targetCoin = getNearestCoin(torso)
                if targetCoin then
                    local targetCFrame = targetCoin.CFrame - Vector3.new(0, 3, 0)
                    local dist = (torso.Position - targetCFrame.Position).Magnitude
                    local tw = TweenService:Create(hrp, TweenInfo.new(dist / FarmSettings.Speed, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
                    FarmState.currentTween = tw
                    tw:Play(); tw.Completed:Wait()

                    if firetouchinterest then
                        firetouchinterest(torso, targetCoin, 0)
                        firetouchinterest(torso, targetCoin, 1)
                    end
                    FarmState.ignoredCoins[targetCoin] = true
                    task.delay(3, function() FarmState.ignoredCoins[targetCoin] = nil end)
                end
            end)
        else
            task.wait(0.5)
        end
    end
end)

farmSec:CreateToggle("Auto Farm Coins (Nearest)", false, function(state) FarmSettings.Enabled = state end)

-- =====================================================================
-- 4. COMBAT TAB
-- =====================================================================

local combatSec = combatTab:CreateSection("Combat & Status")

local autoShotEnabled = true
combatSec:CreateToggle("Auto Shot (Вкл/Выкл [F])", true, function(state)
    autoShotEnabled = state
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.F then
        autoShotEnabled = not autoShotEnabled
        print("AutoShot [F]:", autoShotEnabled)
    end
end)

local autoThrowEnabled = false
local lastThrow        = 0
local THROW_COOLDOWN   = 1.2

local function equipKnife()
    local char = LocalPlayer.Character
    if not char then return false end
    local knife = LocalPlayer.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
    if not knife then return false end
    if knife.Parent ~= char then
        char.Humanoid:EquipTool(knife)
        task.wait(0)
    end
    return true
end

combatSec:CreateToggle("Auto Throw [T]", false, function(state)
    autoThrowEnabled = state
end)

UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe then return end
    if inp.KeyCode == Enum.KeyCode.T then
        autoThrowEnabled = not autoThrowEnabled
        print("AutoThrow [T]:", autoThrowEnabled)
    end
end)

local predPart = Instance.new("Part")
predPart.Anchored     = true
predPart.CanCollide   = false
predPart.Transparency = 1
predPart.Size         = Vector3.new(0.1, 0.1, 0.1)
predPart.Parent       = workspace

local function findTarget(myHRP)
    local myChar  = LocalPlayer.Character
    local myKnife = LocalPlayer.Backpack:FindFirstChild("Knife") or (myChar and myChar:FindFirstChild("Knife"))
    local myGun   = LocalPlayer.Backpack:FindFirstChild("Gun")   or (myChar and myChar:FindFirstChild("Gun"))
    local best, bestDist = nil, math.huge

    for _, p in Players:GetPlayers() do
        if p == LocalPlayer then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then continue end

        local theirKnife = p.Backpack:FindFirstChild("Knife") or char:FindFirstChild("Knife")
        local theirGun   = p.Backpack:FindFirstChild("Gun")   or char:FindFirstChild("Gun")

        local valid = false
        local dist  = (hrp.Position - myHRP.Position).Magnitude

        if myKnife then
            valid = theirKnife ~= nil
        elseif myGun then
            if theirKnife then valid = true; dist = dist - 1000 end
            if theirGun   then valid = true end
        else
            valid = (theirKnife or theirGun) ~= nil
        end

        if not valid then continue end
        if dist < bestDist then bestDist = dist; best = char end
    end

    if not best then
        for _, p in Players:GetPlayers() do
            if p == LocalPlayer then continue end
            local char = p.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp or hum.Health <= 0 then continue end
            local dist = (hrp.Position - myHRP.Position).Magnitude
            if dist < bestDist then bestDist = dist; best = char end
        end
    end
    return best
end

local wallCheckParams = RaycastParams.new()
wallCheckParams.FilterType = Enum.RaycastFilterType.Exclude

local function isWallBetween(origin, targetPos, myChar)
    wallCheckParams.FilterDescendantsInstances = {myChar}
    local dir = targetPos - origin
    local result = Workspace:Raycast(origin, dir, wallCheckParams)
    if not result then return end
    local hitChar = result.Instance:FindFirstAncestorOfClass("Model")
    if hitChar then
        for _, p in Players:GetPlayers() do
            if p ~= LocalPlayer and p.Character == hitChar then
                return false
            end
        end
    end
    return true
end

RunService.RenderStepped:Connect(function()
    if not autoShotEnabled and not autoThrowEnabled then return end
    local myChar = LocalPlayer.Character
    local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myHRP then return end

    local target = findTarget(myHRP)
    if not target then return end

    local torso = target:FindFirstChild("UpperTorso") or target:FindFirstChild("Torso") or target:FindFirstChild("HumanoidRootPart")
    local hum   = target:FindFirstChildOfClass("Humanoid")
    if not torso then return end

    local pos  = torso.Position
    local dist = (pos - myHRP.Position).Magnitude
    local travelTime = dist / 250

    local ok, ping = pcall(function() return LocalPlayer:GetNetworkPing() end)
    if ok and ping then travelTime = travelTime + ping * 0.5 end

    local vel = torso.AssemblyLinearVelocity
    if hum then
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping then
            vel = Vector3.new(vel.X, vel.Y * 0.35, vel.Z)
        end
    end

    predPart.CFrame = CFrame.new(pos + vel * travelTime)
end)

local function equipGun()
    local char = LocalPlayer.Character
    if not char then return end
    local gun = LocalPlayer.Backpack:FindFirstChild("Gun") or char:FindFirstChild("Gun")
    if not gun or gun.Parent == char then return end
    char.Humanoid:EquipTool(gun)
    task.wait(0)
end

local lastShot = 0
local FIRE_RATE = 0.18

RunService.Heartbeat:Connect(function()
    local t = tick()

    if autoShotEnabled then
        local myChar = LocalPlayer.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP and (t - lastShot >= FIRE_RATE) then
            equipGun()
            local gun = myChar:FindFirstChild("Gun")
            if gun then
                local shootRemote = gun:FindFirstChild("Shoot")
                if shootRemote then
                    local targetPos = predPart.CFrame.Position
                    local myPos     = myHRP.Position + Vector3.new(0, 1, 0)
                    if not isWallBetween(myPos, targetPos, myChar) then
                        pcall(function()
                            shootRemote:FireServer(CFrame.new(myPos, targetPos), CFrame.new(targetPos))
                        end)
                        lastShot = t
                    end
                end
            end
        end
    end

    if autoThrowEnabled and (t - lastThrow >= THROW_COOLDOWN) then
        local myChar = LocalPlayer.Character
        local myHRP  = myChar and myChar:FindFirstChild("HumanoidRootPart")
        if myHRP and equipKnife() then
            local knife = myChar:FindFirstChild("Knife")
            if knife then
                local throwRemote = knife:FindFirstChild("Throw") or knife:FindFirstChild("ThrowKnife")
                if throwRemote then
                    local targetPos = predPart.CFrame.Position
                    local myPos     = myHRP.Position + Vector3.new(0, 1.5, 0)
                    pcall(function()
                        throwRemote:FireServer(CFrame.new(myPos, targetPos))
                    end)
                    lastThrow = t
                end
            end
        end
    end
end)

-- =====================================================================
-- 5. TROLL TAB (Anti-Fling)
-- =====================================================================

local trollSec = trollTab:CreateSection("Physics & Anti-Fling")

trollSec:CreateToggle("Anti-Fling (Защита от флинга)", false, function(state)
    getgenv().AntiFlingEnabled = state
    pcall(function()
        if state then
            if not getgenv().AntiFlingConnection then
                getgenv().AntiFlingConnection = RunService.Stepped:Connect(function()
                    if not getgenv().AntiFlingEnabled then return end
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            for _, part in ipairs(player.Character:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.CanCollide = false
                                    part.Velocity = Vector3.new(0, 0, 0)
                                    part.RotVelocity = Vector3.new(0, 0, 0)
                                end
                            end
                        end
                    end
                end)
            end
        else
            if getgenv().AntiFlingConnection then
                getgenv().AntiFlingConnection:Disconnect()
                getgenv().AntiFlingConnection = nil
            end
        end
    end)
end)

print("Hoverly loaded successfully!")
