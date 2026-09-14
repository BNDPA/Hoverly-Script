--[[
    Project: Hoverly Script | Multi-Game Loader & Key System
    Repository: BNDPA/Hoverly-Script
]]

local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("Failed to load Wind UI!")
    return
end

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId
local PlaceIdStr = tostring(PlaceId)

-- НАСТРОЙКИ КЛЮЧЕЙ И ССЫЛОК
local CorrectKey = "HoverHub" -- Твой ключ
local KeyLink = "https://lootdest.org/s?4i9ddpi0" -- Ссылка на получение ключа

-- ССЫЛКИ НА СКРИПТЫ ДЛЯ КАЖДОЙ ИГРЫ (замени ссылки на свои сырые GitHub файлы / raw)
local GameScripts = {
    ["DOORS"] = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/doors.lua",  -- Ссылка на твой скрипт DOORS
    ["BABFT"] = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/babft.lua",  -- Build A Boat For Treasure
    ["MM2"]   = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/mm2.lua",    -- Murder Mystery 2
    ["LT2"]   = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/lt2.lua",    -- Lumber Tycoon 2
    ["NDS"]   = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/nds.lua",    -- Natural Disaster Survival
}

-- Функция определения игры
local function getGameType()
    -- Проверка на префикс 5682 для DOORS, как ты и просил
    if PlaceIdStr:sub(1, 4) == "5682" or PlaceId == 6839171747 then
        return "DOORS", GameScripts["DOORS"]
    elseif PlaceId == 537413528 then
        return "Build A Boat For Treasure", GameScripts["BABFT"]
    elseif PlaceId == 142823291 or PlaceId == 66653943 then
        return "Murder Mystery 2", GameScripts["MM2"]
    elseif PlaceId == 13822889 then
        return "Lumber Tycoon 2", GameScripts["LT2"]
    elseif PlaceId == 189707 then
        return "Natural Disaster Survival", GameScripts["NDS"]
    else
        -- Запасной вариант: проверка по названию через MarketplaceService
        local successInfo, info = pcall(function()
            return MarketplaceService:GetProductInfo(PlaceId)
        end)
        if successInfo and info and info.Name then
            local name = info.Name:lower()
            if name:find("doors") then
                return "DOORS", GameScripts["DOORS"]
            elseif name:find("build a boat") then
                return "Build A Boat For Treasure", GameScripts["BABFT"]
            elseif name:find("murder mystery 2") then
                return "Murder Mystery 2", GameScripts["MM2"]
            elseif name:find("lumber tycoon 2") then
                return "Lumber Tycoon 2", GameScripts["LT2"]
            elseif name:find("natural disaster") then
                return "Natural Disaster Survival", GameScripts["NDS"]
            end
        end
    end
    return "Unknown", nil
end

local gameName, gameScriptUrl = getGameType()

-- Создание окна Key System (WindUI)
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
            
            -- Загрузка скрипта выбранной игры
            local successLoad, err = pcall(function()
                loadstring(game:HttpGet(gameScriptUrl))()
            end)
            
            if not successLoad then
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
                Duration = 4
            })
        end
    end
})
