-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")

-- =========================================================================
-- КАК ДОБАВЛЯТЬ НОВЫЕ ИГРЫ:
-- Скопируйте блок игры, вставьте в список и укажите свои данные:
-- Name — название, PlaceId — ID места, ScriptUrl — ссылка с GitHub, 
-- Icon — иконка, KeyName — уникальное слово на английском для счетчика.
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
}

-- Имя вашего пространства на CountAPI
local NAMESPACE = "hoverlyhub_bndpa_stats_2026"

-- Функция для увеличения счетчика на сервере (+1 при клике)
local function HitStat(key)
    pcall(function()
        game:HttpGet("https://api.countapi.xyz/hit/" .. NAMESPACE .. "/" .. key, true)
    end)
end

-- Функция для получения значения со счетчика
local function GetStat(key)
    local success, result = pcall(function()
        local response = game:HttpGet("https://api.countapi.xyz/get/" .. NAMESPACE .. "/" .. key, true)
        local data = HttpService:JSONDecode(response)
        return data and data.value or 0
    end)
    return success and result or 0
end

-- Регистрируем запуск самого хаба
HitStat("total_hub")

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

-- Вкладка "Info" (Реальное время с автообновлением)
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Paragraph({
    Title = "Статистика использования",
    Desc = "Данные на этой вкладке обновляются в реальном времени.",
})

-- Создаем параграфы для динамического обновления
local TotalPara = InfoTab:Paragraph({
    Title = "Общий онлайн Hub",
    Desc = "Загрузка...",
})

local GamesPara = InfoTab:Paragraph({
    Title = "Популярность игр",
    Desc = "Загрузка...",
})

-- Фоновый поток для обновления статистики каждые 5 секунд
task.spawn(function()
    while true do
        -- Получаем свежие данные со счетчика
        local totalOnline = GetStat("total_hub")
        
        local statsText = ""
        for _, gameData in ipairs(Games) do
            local count = GetStat(gameData.KeyName)
            statsText = statsText .. "• " .. gameData.Name .. ": **" .. count .. "** запусков\n"
        end
        
        -- Обновляем текст в интерфейсе WindUI
        pcall(function()
            TotalPara:SetDesc("Всего запусков хаба: **" .. tostring(totalOnline) .. "** чел.")
            GamesPara:SetDesc(statsText)
        end)
        
        -- Пауза 5 секунд перед следующим обновлением (чтобы не нагружать сеть)
        task.wait(5)
    end
end)

Window:SelectTab(1)

