--[[
    Hub Name: Hoverly Script | Rivals (Delta Final Fix)
--]]

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    -- Запасной вариант через альтернативную ветку
    success, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/refs/heads/main/dist/main.lua"))()
    end)
end

if not success or not WindUI then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hoverly Script Error",
        Text = "Не удалось загрузить WindUI библиотеку!",
        Duration = 5
    })
    return
end

-- Создание главного окна
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Rivals",
    Icon = "rbxassetid://10723424177",
    Author = ".gg/hoverly",
    Folder = "HoverlyRivals",
    Size = UDim2.fromOffset(500, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 150,
    HasOutline = true,
})

-- Создание вкладок
local Tabs = {
    Aimbot = Window:Tab({ Title = "Aimbot", Icon = "target" }),
    Visuals = Window:Tab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "zap" }),
    World = Window:Tab({ Title = "World", Icon = "globe" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" }),
}

-- Глобальная конфигурация
getgenv().HoverlyConfig = {
    Aimbot = { Enabled = false, Smoothness = 5, FOV = 120, Part = "Head", TeamCheck = true },
    SilentAim = { Enabled = false, HitChance = 100 },
    ESP = { Boxes = false, Tracers = false, Names = false, Chams = false, SkinsUnlocker = false },
    Movement = { SpeedHack = false, SpeedMultiplier = 16, Bhop = false, Fly = false },
    World = { FullBright = false }
}

-- ================= TAB 1: AIMBOT =================
Tabs.Aimbot:Section({ Title = "Настройки Aimbot" })

Tabs.Aimbot:Toggle({
    Title = "Включить Aimbot",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.Aimbot.Enabled = v end
})

Tabs.Aimbot:Dropdown({
    Title = "Кость (Hitbox)",
    Values = {"Head", "HumanoidRootPart", "Torso"},
    Default = "Head",
    Callback = function(v) getgenv().HoverlyConfig.Aimbot.Part = v end
})

Tabs.Aimbot:Slider({
    Title = "Плавность (Smoothness)",
    Min = 1, Max = 20, Default = 5, Step = 1,
    Callback = function(v) getgenv().HoverlyConfig.Aimbot.Smoothness = v end
})

Tabs.Aimbot:Slider({
    Title = "Радиус FOV",
    Min = 30, Max = 400, Default = 120, Step = 5,
    Callback = function(v) getgenv().HoverlyConfig.Aimbot.FOV = v end
})

Tabs.Aimbot:Toggle({
    Title = "Проверка команды",
    Default = true,
    Callback = function(v) getgenv().HoverlyConfig.Aimbot.TeamCheck = v end
})

-- ================= TAB 2: VISUALS & SKINS =================
Tabs.Visuals:Section({ Title = "ESP и Визуал" })

Tabs.Visuals:Toggle({
    Title = "Box ESP",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.ESP.Boxes = v end
})

Tabs.Visuals:Toggle({
    Title = "Линии (Tracers)",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.ESP.Tracers = v end
})

Tabs.Visuals:Toggle({
    Title = "Имена игроков",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.ESP.Names = v end
})

Tabs.Visuals:Section({ Title = "Скины" })

Tabs.Visuals:Toggle({
    Title = "Skins Unlocker",
    Description = "Разблокировка скинов (безопасно)",
    Default = false,
    Callback = function(v) 
        getgenv().HoverlyConfig.ESP.SkinsUnlocker = v 
    end
})

-- Фоновый поток для скин-унлокера
task.spawn(function()
    pcall(function()
        local reps = game:GetService("ReplicatedStorage")
        local plrs = game:GetService("Players")
        local lp = plrs.LocalPlayer
        local rmods = reps:WaitForChild("Modules", 5)
        if not rmods then return end
        
        local clib = require(rmods:WaitForChild("CosmeticLibrary", 5))
        local dctrl = require(lp.PlayerScripts.Controllers:WaitForChild("PlayerDataController", 5))
        local coss = clib.Cosmetics
        
        local oget = dctrl.Get
        dctrl.Get = function(self, key)
            local data = oget(self, key)
            if not getgenv().HoverlyConfig.ESP.SkinsUnlocker then return data end
            if key == "CosmeticInventory" then
                local proxy = {}
                if data then for k, v in data do proxy[k] = v end end
                for name in coss do proxy[name] = true end
                return proxy
            end
            return data
        end
    end)
end)

-- ================= TAB 3: MOVEMENT =================
Tabs.Movement:Section({ Title = "Передвижение" })

Tabs.Movement:Toggle({
    Title = "Speed Hack",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.Movement.SpeedHack = v end
})

Tabs.Movement:Slider({
    Title = "Множитель скорости",
    Min = 16, Max = 100, Default = 24, Step = 1,
    Callback = function(v) getgenv().HoverlyConfig.Movement.SpeedMultiplier = v end
})

Tabs.Movement:Toggle({	
    Title = "Распрыжка (Bhop)",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.Movement.Bhop = v end
})

Tabs.Movement:Toggle({
    Title = "Режим полета (Fly)",
    Default = false,
    Callback = function(v) getgenv().HoverlyConfig.Movement.Fly = v end
})

-- ================= TAB 4: WORLD =================
Tabs.World:Section({ Title = "Окружение" })

Tabs.World:Toggle({
    Title = "FullBright (Яркий мир)",
    Default = false,
    Callback = function(v)
        getgenv().HoverlyConfig.World.FullBright = v
        local lighting = game:GetService("Lighting")
        if v then
            lighting.Brightness = 2
            lighting.ClockTime = 14
            lighting.GlobalShadows = false
        else
            lighting.GlobalShadows = true
        end
    end
})

-- ================= TAB 5: SETTINGS =================
Tabs.Settings:Section({ Title = "Управление" })

Tabs.Settings:Button({
    Title = "Выгрузить скрипт (Unload)",
    Callback = function()
        WindUI:Destroy()
    end
})

-- Уведомление
WindUI:Notify({
    Title = "Hoverly Script",
    Content = "Успешно запущен на Delta!",
    Duration = 3
})

