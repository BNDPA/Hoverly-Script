--[[
    Project: Hoverly Script (Global Loader with Key System)
    Author: Hoverly Development (BNDPA)
]]

local PlaceId = game.PlaceId
local BASE_URL = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/"

local SupportedGames = {
    [13822889] = "lt2.lua",    -- Lumber Tycoon 2
    [142823291] = "mm2.lua",   -- Murder Mystery 2
    [189707] = "nds.lua",      -- Natural Disaster Survival (короткий ID)
    [189707485] = "nds.lua",   -- Natural Disaster Survival (полный ID)
}

-- Безопасная загрузка WindUI
local successUI, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not successUI or not WindUI then
    warn("[Hoverly Hub]: Не удалось загрузить интерфейс WindUI.")
    return
end

-- Функция загрузки игры
local function loadGameScript()
    local scriptFile = SupportedGames[PlaceId]
    
    if scriptFile then
        WindUI:Notify({
            Title = "Hoverly Hub",
            Content = "Игра найдена! Загружаем скрипт...",
            Duration = 3
        })
        
        task.wait(0.5)
        local fullUrl = BASE_URL .. scriptFile
        
        local successFetch, content = pcall(function()
            return game:HttpGet(fullUrl)
        end)
        
        if successFetch and content and content ~= "404: Not Found" then
            local runSuccess, runErr = pcall(function()
                loadstring(content)()
            end)
            if not runSuccess then
                warn("[Hoverly Hub Error]: Ошибка выполнения скрипта игры: " .. tostring(runErr))
            end
        else
            warn("[Hoverly Hub Error]: Не удалось скачать файл по ссылке: " .. fullUrl)
            WindUI:Notify({
                Title = "Ошибка файла",
                Content = "Не удалось загрузить файл " .. scriptFile .. " с GitHub!",
                Duration = 4
            })
        end
    else
        WindUI:Notify({
            Title = "Hoverly Hub",
            Content = "Эта игра пока не поддерживается хабом (PlaceId: " .. tostring(PlaceId) .. ")",
            Duration = 5
        })
    end
end

-- Создаем окно Key System
local KeyWindow = WindUI:CreateWindow({
    Title = "Hoverly Hub | Key System",
    Icon = "key",
    Author = "Hoverly Development",
    Folder = "HoverlyKeyConfig",
    Theme = "Dark",
    Size = UDim2.new(0, 420, 0, 240),
    Transparent = false,
    HasOutline = true,
})

local KeyTab = KeyWindow:Tab({ Title = "Authentication", Icon = "lock" })
local inputKey = ""

KeyTab:Input({
    Title = "Введите ключ",
    Desc = "Пароль для доступа к хабу: HoverHub",
    Placeholder = "Введите ключ здесь...",
    Callback = function(value)
        inputKey = value
    end
})

KeyTab:Button({
    Title = "Проверить ключ",
    Desc = "Нажмите для авторизации",
    Callback = function()
        if inputKey == "HoverHub" then
            WindUI:Notify({
                Title = "Успешно!",
                Content = "Ключ верный. Добро пожаловать!",
                Duration = 2
            })
            
            pcall(function()
                KeyWindow:Close()
            end)
            
            task.wait(0.3)
            loadGameScript()
        else
            WindUI:Notify({
                Title = "Ошибка",
                Content = "Неверный ключ! Попробуйте снова.",
                Duration = 3
            })
        end
    end
})

