-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")

-- =========================================================================
-- КАК ДОБАВЛЯТЬ НОВЫЕ ИГРЫ:
-- Просто скопируйте любой блок ниже, вставьте в таблицу и измените:
-- Name — название игры, PlaceId — ID места (можно несколько), 
-- ScriptUrl — ссылка на ваш raw-скрипт с GitHub, Icon — иконка, 
-- KeyName — уникальное имя на английском для счетчика (без пробелов!).
-- =========================================================================

local Games = {
    {
        Name = "DOORS",
        PlaceId = {6516141723, 6839171747},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/doors.lua",
        Icon = "door-closed",
        KeyName = "doors"
    },
    {
        Name = "Lumber Tycoon 2",
        PlaceId = {13822889},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/lt2.lua",
        Icon = "axe",
        KeyName = "lt2"
    },
    {
        Name = "Natural Disaster Survival",
        PlaceId = {189707},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/nds.lua",
        Icon = "cloud-rain",
        KeyName = "nds"
    },
    {
        Name = "Build A Boat For Treasure",
        PlaceId = {5374135, 358276339},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/babft.lua",
        Icon = "hammer",
        KeyName = "babft"
    },
    {
        Name = "Blox Fruit",
        PlaceId = {2753915549, 4442272183, 7449423635},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/bf.lua",
        Icon = "swords",
        KeyName = "bloxfruit"
    }
    -- ЧТОБЫ ДОБАВИТЬ НОВУЮ ИГРУ, СКОПИРУЙТЕ БЛОК НИЖЕ И РАСКОММЕНТИРУЙТЕ ЕГО (УДАЛИТЕ "--"):
    --[[
    ,
    {
        Name = "Имя новой игры",
        PlaceId = {АЙДИ_ИГРЫ},
        ScriptUrl = "ССЫЛКА_НА_СКРИПТ_GITHUB",
        Icon = "gamepad-2",
        KeyName = "nomer_igry_eng"
    }
    ]]
}

-- Имя вашего пространства на CountAPI (чтобы статистика была уникальной для вашего хаба)
local NAMESPACE = "hoverlyhub_bndpa_stats_2026"

-- Функция для увеличения счетчика на сервере (+1 игрок)
local function HitStat(key)
    pcall(function()
        game:HttpGet("https://api.countapi.xyz/hit/" .. NAMESPACE .. "/" .. key, true)
    end)
end

-- Функция для получения текущих цифр со счетчика
local function GetStat(key)
    local success, result = pcall(function()
        local response = game:HttpGet("https://api.countapi.xyz/get/" .. NAMESPACE .. "/" .. key, true)
        local data = HttpService:JSONDecode(response)
        return data and data.value or 0
    end)
    return success and result or 0
end

-- Регистрируем запуск самого хаба (общего количества)
HitStat("total_hub")

-- Загружаем реальную статистику для вкладки Info
local totalOnline = GetStat("total_hub")
local gameStats = {}
for _, gameData in ipairs(Games) do
    gameStats[gameData.KeyName] = GetStat(gameData.KeyName)
end

-- Функция авто-детекта текущей игры
local function GetCurrentSupportedGame()
    local currentId = game.PlaceId
    for _, gameData in ipairs(Games) do
        for _, id in ipairs(gameData.PlaceId) do
            if id == currentId then
                return gameData
            end
        end
    end
    return nil
end

-- Создание окна через WindUI
local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub",
    Icon = "compass",
    Author = "BNDPA",
    Folder = "HoverlyHub",
    Size = UDim2.fromOffset(520, 360),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 175,
    HasOutline = true,
})

-- Вкладка "Главная" (Авто-детект)
local MainTab = Window:Tab({
    Title = "Главная",
    Icon = "home",
})

local detectedGame = GetCurrentSupportedGame()

MainTab:Paragraph({
    Title = "Статус Авто-детекта",
    Desc = detectedGame 
        and ("Обнаружена игра: **" .. detectedGame.Name .. "**\nВы можете запустить скрипт одной кнопкой ниже.") 
        or "Текущая игра не найдена в списке автоматического распознавания. Воспользуйтесь вкладкой «Выбор игры».",
})

if detectedGame then
    MainTab:Button({
        Title = "Запустить скрипт для " .. detectedGame.Name,
        Desc = "Автоматический запуск найденного скрипта",
        Callback = function()
            -- Прибавляем +1 к счетчику конкретной игры на сервере при клике
            HitStat(detectedGame.KeyName)
            
            WindUI:Notify({
                Title = "Загрузка...",
                Content = "Запуск модуля: " .. detectedGame.Name,
                Duration = 2,
            })
            
            pcall(function()
                Window:Destroy()
            end)
            
            local success, err = pcall(function()
                loadstring(game:HttpGet(detectedGame.ScriptUrl))()
            end)
            
            if not success then
                WindUI:Notify({
                    Title = "Ошибка загрузки",
                    Content = tostring(err),
                    Duration = 5,
                })
                warn("Не удалось выполнить скрипт: " .. tostring(err))
            end
        end
    })
end

-- Вкладка "Выбор игры" (Ручной запуск)
local GamesTab = Window:Tab({
    Title = "Выбор игры",
    Icon = "list",
})

GamesTab:Paragraph({
    Title = "Список скриптов",
    Desc = "Выберите нужную игру вручную при необходимости.",
})

for _, gameData in ipairs(Games) do
    GamesTab:Button({
        Title = gameData.Name,
        Desc = "Загрузить " .. gameData.Name .. ".lua",
        Icon = gameData.Icon,
        Callback = function()
            -- Прибавляем +1 к счетчику конкретной игры на сервере при клике
            HitStat(gameData.KeyName)
            
            WindUI:Notify({
                Title = "Загрузка...",
                Content = "Загружается скрипт для " .. gameData.Name,
                Duration = 2,
            })
            
            pcall(function()
                Window:Destroy()
            end)
            
            local success, err = pcall(function()
                loadstring(game:HttpGet(gameData.ScriptUrl))()
            end)
            
            if not success then
                WindUI:Notify({
                    Title = "Ошибка загрузки",
                    Content = tostring(err),
                    Duration = 5,
                })
                warn("Не удалось выполнить скрипт: " .. tostring(err))
            end
        end
    })
end

-- Вкладка "Info" (Реальная статистика с сервера навсегда)
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Paragraph({
    Title = "Статистика использования",
    Desc = "Цифры сохраняются на сервере автоматически и навсегда.",
})

InfoTab:Paragraph({
    Title = "Общий онлайн Hub",
    Desc = "Всего запусков хаба: **" .. tostring(totalOnline) .. "** игроков",
})

InfoTab:Paragraph({
    Title = "Популярность игр",
    Desc = (function()
        local statsText = ""
        for _, gameData in ipairs(Games) do
            local count = gameStats[gameData.KeyName] or 0
            statsText = statsText .. "• " + gameData.Name + ": **" .. count .. "** запусков\n" -- исправлено на конкатенацию ниже
        end
        return statsText
    end)(),
})

Window:SelectTab(1)
