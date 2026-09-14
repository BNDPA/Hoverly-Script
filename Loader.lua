--[[
    Project: Hoverly Script | Multi-Game Loader & Key System
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- НАСТРОЙКИ КЛЮЧЕЙ И ССЫЛОК
local CorrectKey = "HoverHub" -- Твой ключ
local KeyLink = "https://lootdest.org/s?4i9ddpi0" -- Ссылка на получение ключа

-- ССЫЛКИ НА СКРИПТЫ ДЛЯ КАЖДОЙ ИГРЫ (замени ссылки на свои сырые GitHub / Pastebin)
local GameScripts = {
    [537413528] = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/babft.lua", -- Build A Boat For Treasure PlaceId
    [66653943]  = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/mm2.lua",      -- Murder Mystery 2 PlaceId
    [13822889]  = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/lt2.lua",      -- Lumber Tycoon 2 PlaceId
    [189707]    = "https://raw.githubusercontent.com/YourUsername/YourRepo/main/nds.lua",      -- Natural Disaster Survival PlaceId
}

-- Дополнительные альтернативные ID (на случай если у игры несколько плейсов)
local GameAlternativeIDs = {
    [537413528] = true, -- BABFT
    [142823291] = true, -- MM2
    [66653943]  = true, -- MM2
}

local function getGameType()
    -- Проверяем по ID или названию игры через MarketplaceService
    if PlaceId == 537413528 or MarketplaceService:GetProductInfo(PlaceId).Name:lower():find("build a boat") then
        return "Build A Boat For Treasure", GameScripts[537413528]
    elseif GameAlternativeIDs[PlaceId] or MarketplaceService:GetProductInfo(PlaceId).Name:lower():find("murder mystery 2") then
        return "Murder Mystery 2", GameScripts[66653943]
    elseif PlaceId == 13822889 or MarketplaceService:GetProductInfo(PlaceId).Name:lower():find("lumber tycoon 2") then
        return "Lumber Tycoon 2", GameScripts[13822889]
    elseif PlaceId == 189707 or MarketplaceService:GetProductInfo(PlaceId).Name:lower():find("natural disaster") then
        return "Natural Disaster Survival", GameScripts[189707]
    end
    return "Unknown", nil
end

local gameName, gameScriptUrl = getGameType()

-- Окно Key System
local KeyWindow = WindUI:CreateWindow({
    Title = "Hoverly Script | Key System",
    Icon = "key",
    Author = "Hoverly Development",
    Theme = "Dark",
    Resizable = false,
})

local KeyTab = KeyWindow:Tab({ Title = "Authentication", Icon = "lock" })
local inputtedKey = ""

KeyTab:Input({
    Title = "Enter Key",
    Description = "Detected Game: " .. gameName,
    Placeholder = "Type key...",
    Callback = function(text)
        inputtedKey = text
    end
})

KeyTab:Button({
    Title = "Check Key & Load",
    Description = "Verifies your key and loads the game script.",
    Callback = function()
        if inputtedKey == CorrectKey then
            if not gameScriptUrl then
                WindUI:Notify({
                    Title = "Error",
                    Content = "This game is not supported by Hoverly Script!",
                    Duration = 4
                })
                return
            end

            WindUI:Notify({
                Title = "Success!",
                Content = "Key accepted. Loading " .. gameName .. " script...",
                Duration = 3
            })
            
            KeyWindow:Destroy()
            
            -- Автоматическая загрузка нужного файла игры
            local success, err = pcall(function()
                loadstring(game:HttpGet(gameScriptUrl))()
            end)
            
            if not success then
                warn("Failed to load script: " .. tostring(err))
                WindUI:Notify({
                    Title = "Load Error",
                    Content = "Could not fetch the script from URL.",
                    Duration = 4
                })
            end
        else
            WindUI:Notify({
                Title = "Access Denied",
                Content = "Invalid key! Please try again.",
                Duration = 3
            })
        end
    end
})

KeyTab:Button({
    Title = "Get Key",
    Description = "Copies the link to get a key to your clipboard.",
    Callback = function()
        if setclipboard then
            setclipboard(KeyLink)
            WindUI:Notify({
                Title = "Link Copied",
                Content = "Key link copied to clipboard!",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Your executor does not support setclipboard.",
                Duration = 3
            })
        end
    end
})

