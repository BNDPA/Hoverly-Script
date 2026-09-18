--[[
    Hub Name: Hoverly Script | Rivals (Delta Optimized)
--]]

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/init.lua"))()
end)

if not success or not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hoverly Script Error",
        Text = "Failed to load WindUI library!",
        Duration = 5
    })
    return
end

-- Create Main Window
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Rivals",
    Icon = "rbxassetid://10723424177",
    Author = ".gg/hoverly",
    Folder = "HoverlyRivals",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 160,
    HasOutline = true,
})

-- Create Tabs
local Tabs = {
    Aimbot = Window:Tab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:Tab({ Title = "Visuals (ESP)", Icon = "eye" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "zap" }),
    World = Window:Tab({ Title = "World & Misc", Icon = "globe" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

-- Global Configuration / Variables
getgenv().HoverlyConfig = {
    Aimbot = {
        Enabled = false,
        Smoothness = 5,
        FOV = 120,
        Part = "Head",
        TeamCheck = true,
    },
    SilentAim = {
        Enabled = false,
        HitChance = 100,
    },
    ESP = {
        Boxes = false,
        Tracers = false,
        Names = false,
        Chams = false,
        ChamsColor = Color3.fromRGB(255, 0, 0),
        SkinsUnlocker = false,
    },
    Movement = {
        SpeedHack = false,
        SpeedMultiplier = 16,
        Fly = false,
        Bhop = false,
    },
    World = {
        FullBright = false,
    }
}

-- ==========================================
-- TAB 1: AIMBOT & SILENT AIM
-- ==========================================
Tabs.Aimbot:Section({ Title = "Aimbot Settings" })

Tabs.Aimbot:Toggle({
    Title = "Enable Aimbot",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.Aimbot.Enabled = state
    end
})

Tabs.Aimbot:Dropdown({
    Title = "Target Part",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(val)
        getgenv().HoverlyConfig.Aimbot.Part = val
    end
})

Tabs.Aimbot:Slider({
    Title = "Smoothness",
    Min = 1,
    Max = 20,
    Default = 5,
    Callback = function(val)
        getgenv().HoverlyConfig.Aimbot.Smoothness = val
    end
})

Tabs.Aimbot:Slider({
    Title = "FOV Radius",
    Min = 30,
    Max = 400,
    Default = 120,
    Callback = function(val)
        getgenv().HoverlyConfig.Aimbot.FOV = val
    end
})

Tabs.Aimbot:Toggle({
    Title = "Team Check",
    Default = true,
    Callback = function(state)
        getgenv().HoverlyConfig.Aimbot.TeamCheck = state
    end
})

Tabs.Aimbot:Section({ Title = "Silent Aim" })

Tabs.Aimbot:Toggle({
    Title = "Enable Silent Aim",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.SilentAim.Enabled = state
    end
})

Tabs.Aimbot:Slider({
    Title = "Hit Chance %",
    Min = 10,
    Max = 100,
    Default = 100,
    Callback = function(val)
        getgenv().HoverlyConfig.SilentAim.HitChance = val
    end
})


-- ==========================================
-- TAB 2: VISUALS (ESP, CHAMS & SKINS)
-- ==========================================
Tabs.Visuals:Section({ Title = "Player ESP" })

Tabs.Visuals:Toggle({
    Title = "Box ESP",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.ESP.Boxes = state
    end
})

Tabs.Visuals:Toggle({
    Title = "Tracer Lines",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.ESP.Tracers = state
    end
})

Tabs.Visuals:Toggle({
    Title = "Name & Health Tag",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.ESP.Names = state
    end
})

Tabs.Visuals:Section({ Title = "Chams & Highlights" })

Tabs.Visuals:Toggle({
    Title = "Wall Chams (Highlight)",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.ESP.Chams = state
    end
})

Tabs.Visuals:ColorPicker({
    Title = "Chams Fill Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        getgenv().HoverlyConfig.ESP.ChamsColor = color
    end
})

Tabs.Visuals:Section({ Title = "Skins & Customization" })

Tabs.Visuals:Toggle({
    Title = "Skins Unlocker (Visual)",
    Description = "Unlocks all weapon skins client-side",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.ESP.SkinsUnlocker = state
    end
})

-- Safe Background Logic for Skins Unlocker
task.spawn(function()
    pcall(function()
        local plrs = game:GetService("Players")
        local reps = game:GetService("ReplicatedStorage")
        local http = game:GetService("HttpService")

        local lp = plrs.LocalPlayer
        local lps = lp.PlayerScripts
        local ctrls = lps.Controllers
        local rmods = reps.Modules

        local elib = require(rmods:WaitForChild("EnumLibrary", 10))
        if elib then elib:WaitForEnumBuilder() end
        local clib = require(rmods:WaitForChild("CosmeticLibrary", 10))
        local ilib = require(rmods:WaitForChild("ItemLibrary", 10))
        local dctrl = require(ctrls:WaitForChild("PlayerDataController", 10))
        local coss = clib.Cosmetics

        local cdata = dctrl.CurrentData
        if not cdata then
            task.spawn(function()
                repeat task.wait() until dctrl.CurrentData
                cdata = dctrl.CurrentData
            end)
        end

        local equip, favs = {}, {}
        local cwep, vprof, lwep
        local fcache = {}

        local function banned(n)
            if type(n) ~= "string" then return true end
            return n:find("MISSING_") or n:find("Bubblegum") or n:find("Ragdoll") or n:find("Fall Apart") or n:find("Every Finisher Ever")
        end

        local function toenum(n)
            if not elib then return nil end
            local ok, id = pcall(elib.ToEnum, elib, n)
            return ok and id or nil
        end

        local function clonecos(name, ctype, inv, favonly)
            if banned(name) then return nil end
            local base = coss[name]
            if not base then return nil end
            local d = table.clone(base)
            d.Name = name
            d.Type = d.Type or ctype
            d.Seed = d.Seed or math.random(1, 1000000)
            local eid = toenum(name)
            if eid then d.Enum = eid d.ObjectID = d.ObjectID or eid end
            if inv ~= nil then d.Inverted = inv end
            if favonly ~= nil then d.OnlyUseFavorites = favonly end
            return d
        end

        local finv = {}
        local function rebuildinv()
            table.clear(finv)
            for name in coss do
                if not banned(name) then finv[name] = true end
            end
            for _, cos in equip do
                for _, cd in cos do
                    if cd and cd.Name and not banned(cd.Name) then finv[cd.Name] = true end
                end
            end
        end

        rebuildinv()

        local oget = dctrl.Get
        dctrl.Get = function(self, key)
            local data = oget(self, key)
            if not getgenv().HoverlyConfig.ESP.SkinsUnlocker then return data end
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in data do if not banned(k) then proxy[k] = v end end end
                for name in finv do proxy[name] = true end
                return proxy
            end
            return data
        end

        local ogetwep = dctrl.GetWeaponData
        dctrl.GetWeaponData = function(self, wname)
            local data = ogetwep(self, wname)
            if not data or not getgenv().HoverlyConfig.ESP.SkinsUnlocker then return data end
            local merged = table.clone(data)
            merged.Name = wname
            local weq = equip[wname]
            if weq then for ct, cd in weq do merged[ct] = cd end end
            return merged
        end
    end)
end)


-- ==========================================
-- TAB 3: MOVEMENT
-- ==========================================
Tabs.Movement:Section({ Title = "Character Modifiers" })

Tabs.Movement:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.Movement.SpeedHack = state
    end
})

Tabs.Movement:Slider({
    Title = "Speed Multiplier",
    Min = 16,
    Max = 100,
    Default = 24,
    Callback = function(val)
        getgenv().HoverlyConfig.Movement.SpeedMultiplier = val
    end
})

Tabs.Movement:Toggle({
    Title = "Bunny Hop (Auto Jump)",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.Movement.Bhop = state
    end
})

Tabs.Movement:Toggle({
    Title = "Fly Mode",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.Movement.Fly = state
    end
})


-- ==========================================
-- TAB 4: WORLD & MISC
-- ==========================================
Tabs.World:Section({ Title = "Lighting & Atmosphere" })

Tabs.World:Toggle({
    Title = "FullBright",
    Default = false,
    Callback = function(state)
        getgenv().HoverlyConfig.World.FullBright = state
        if state then
            game:GetService("Lighting").Brightness = 2
            game:GetService("Lighting").ClockTime = 14
            game:GetService("Lighting").GlobalShadows = false
        else
            game:GetService("Lighting").GlobalShadows = true
        end
    end
})


-- ==========================================
-- TAB 5: SETTINGS & CONFIGS
-- ==========================================
Tabs.Settings:Section({ Title = "Interface Management" })

Tabs.Settings:Button({
    Title = "Unload Hub",
    Callback = function()
        WindUI:Destroy()
    end
})

-- Notification
WindUI:Notify({
    Title = "Hoverly Script | Rivals",
    Content = "Successfully loaded on Delta!",
    Duration = 4
})

