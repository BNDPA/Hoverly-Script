-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")

-- Ссылка на ваш JSONBin
local STATS_API_URL = "https://api.jsonbin.io/v3/b/6aabdd33ffd5d1605311d743"

-- Функция для получения реальной статистики из JSONBin
local function FetchRealStats()
    local success, result = pcall(function()
        local response = game:HttpGet(STATS_API_URL, true)
        return HttpService:JSONDecode(response)
    end)
    
    -- Для JSONBin данные хранятся внутри поля .record
    local data = (success and result and result.record) or nil
    
    if data then
        return data
    else
        -- Заглушка на случай сбоя интернета, чтобы хаб не зависал
        return {
            Total = 0,
            Games = {
                ["DOORS"] = 0,
                ["Lumber Tycoon 2"] = 0,
                ["Natural Disaster Survival"] = 0,
                ["Build A Boat For Treasure"] = 0,
                ["Blox Fruit"] = 0
            }
        }
    end
end

-- Загружаем актуальную статистику при открытии хаба
local liveStats = FetchRealStats()

-- База данных поддерживаемых игр под ваш репозиторий BNDPA/Hoverly-Script
local Games = {
    {
        Name = "DOORS",
        PlaceId = {6516141723, 6839171747},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/doors.lua",
        Icon = "door-closed",
        KeyName = "DOORS"
    },
    {
        Name = "Lumber Tycoon 2",
        PlaceId = {13822889},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/lt2.lua",
        Icon = "axe",
        KeyName = "Lumber Tycoon 2"
    },
    {
        Name = "Natural Disaster Survival",
        PlaceId = {189707},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/nds.lua",
        Icon = "cloud-rain",
        KeyName = "Natural Disaster Survival"
    },
    {
        Name = "Build A Boat For Treasure",
        PlaceId = {5374135, 358276339},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/babft.lua",
        Icon = "hammer",
        KeyName = "Build A Boat For Treasure"
    },
    {
        Name = "Blox Fruit",
        PlaceId = {2753915549, 4442272183, 7449423635},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/bf.lua",
        Icon = "swords",
        KeyName = "Blox Fruit"
    }
}

-- Функция для авто-детекта текущей игры
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

-- Вкладка "Info" (Отображение данных из JSONBin)
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Paragraph({
    Title = "Статистика использования",
    Desc = "Данные подгружаются в реальном времени с вашего JSONBin.",
})

InfoTab:Paragraph({
    Title = "Общий онлайн Hub",
    Desc = "Всего игроков: **" .. tostring(liveStats.Total or 0) .. "** чел.",
})

InfoTab:Paragraph({
    Title = "Онлайн по отдельным играм",
    Desc = (function()
        local statsText = ""
        if liveStats.Games then
            for _, gameData in ipairs(Games) do
                local count = liveStats.Games[gameData.KeyName] or 0
                statsText = statsText .. "• " .. gameData.Name .. ": **" .. count .. "** игроков\n"
            end
        else
            statsText = "Не удалось загрузить данные по играм."
        end
        return statsText
    end)(),
})

-- Открываем первую вкладку по умолчанию
Window:SelectTab(1)

