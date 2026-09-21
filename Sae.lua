-- Hoverly Hub - Steal An Egg
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub | Steal An Egg",
    Icon = "rbxassetid://1234567890", -- Замените при необходимости
    Author = "BNDPA",
    Folder = "HoverlyHubConfigs",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true
})

local Tabs = {
    Main = Window:Tab({ Title = "Main", Icon = "home" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "settings" })
}

-- Переменные конфигурации
local configFileName = "HoverlyHub_StealAnEgg.json"
local currentLang = "EN"

local settingsData = {
    autoFarm = false,
    minRarityTier = 2,
    autoTreadmill = true,
    autoUpgradeTreadmill = true,
    autoBuyTrails = true,
    hideNotEnoughMoney = true,
    performanceMode = false,
    disable3D = false,
    antiAFK = true,
    language = currentLang
}

local function saveSettings()
    local HttpService = game:GetService("HttpService")
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(settingsData)
    end)
    if success then
        pcall(function()
            writefile(configFileName, encoded)
        end)
    end
end

-- Вкладка Main
Tabs.Main:Section({ Title = "Auto Farm" })

Tabs.Main:Toggle({
    Title = "Auto Farm Eggs",
    Default = settingsData.autoFarm,
    Callback = function(state)
        settingsData.autoFarm = state
        saveSettings()
    end
})

Tabs.Main:Slider({
    Title = "Minimum Rarity Tier",
    Min = 1,
    Max = 5,
    Default = settingsData.minRarityTier,
    Step = 1,
    Callback = function(value)
        settingsData.minRarityTier = value
        saveSettings()
    end
})

Tabs.Main:Section({ Title = "Automation" })

Tabs.Main:Toggle({
    Title = "Auto Treadmill",
    Default = settingsData.autoTreadmill,
    Callback = function(state)
        settingsData.autoTreadmill = state
        saveSettings()
    end
})

Tabs.Main:Toggle({
    Title = "Auto Upgrade Treadmill",
    Default = settingsData.autoUpgradeTreadmill,
    Callback = function(state)
        settingsData.autoUpgradeTreadmill = state
        saveSettings()
    end
})

Tabs.Main:Toggle({
    Title = "Auto Buy Trails",
    Default = settingsData.autoBuyTrails,
    Callback = function(state)
        settingsData.autoBuyTrails = state
        saveSettings()
    end
})

-- Вкладка Settings
Tabs.Settings:Section({ Title = "Miscellaneous" })

Tabs.Settings:Toggle({
    Title = "Anti-AFK",
    Default = settingsData.antiAFK,
    Callback = function(state)
        settingsData.antiAFK = state
        saveSettings()
        if state then
            local vu = game:GetService("VirtualUser")
            game:GetService("Players").LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

WindUI:Notify({
    Title = "Hoverly Hub Loaded",
    Content = "Successfully initialized for Steal An Egg using WindUI!",
    Duration = 5
})

