-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")

-- =========================================================================
-- НАСТРОЙКА СТАТИСТИКИ (COUNTAPI)
-- =========================================================================
local NAMESPACE = "hoverlyhub_bndpa_universal_2026"

local function HitStat(key)
    pcall(function()
        game:HttpGet("https://api.countapi.xyz/hit/" .. NAMESPACE .. "/" .. key, true)
    end)
end

local function GetStat(key)
    local success, result = pcall(function()
        local response = game:HttpGet("https://api.countapi.xyz/get/" .. NAMESPACE .. "/" .. key, true)
        local data = HttpService:JSONDecode(response)
        return data and data.value or 0
    end)
    return success and result or 0
end

HitStat("total_hub")

-- =========================================================================
-- БАЗА ДАННЫХ ИГР (Universal первый, затем остальные игры)
-- =========================================================================
local UniversalData = {
    Name = "Universal",
    PlaceId = {},
    ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/universal.lua",
    Icon = "globe",
    KeyName = "universal"
}

local Games = {
    {
        Name = "Rivals",
        PlaceId = {17625359962},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/rivals.lua",
        Icon = "crosshairs",
        KeyName = "rivals"
    },
    {
        Name = "Murder Mystery 2",
        PlaceId = {142823291},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/mm2.lua",
        Icon = "knife",
        KeyName = "mm2"
    },
    {
        Name = "Tower of Hell",
        PlaceId = {1962086868, 358276339},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/default_toh.lua",
        Icon = "tower-control",
        KeyName = "dtoh"
    },
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
        Name = "Mog Evolution",
        PlaceId = {92648272637932},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Mog_evo.lua",
        Icon = "hammer",
        KeyName = "MogEvo"
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
        PlaceId = {5374135},
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
    },
    {
        Name = "Duels murders vs sheriffs",
        PlaceId = {135856908115931},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Dmvs.lua",
        Icon = "shield-alert",
        KeyName = "dmvs"
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

-- =========================================================================
-- УНИВЕРСАЛЬНАЯ ФУНКЦИЯ ЗАГРУЗКИ СКРИПТОВ С ЗАДЕРЖКОЙ
-- =========================================================================
local function LoadScript(keyName, scriptUrl, gameName)
    HitStat(keyName)
    WindUI:Notify({
        Title = "Загрузка...",
        Content = "Запуск скрипта для: " .. gameName,
        Duration = 2,
    })
    
    pcall(function() Window:Destroy() end)
    
    -- Ожидание 3 секунды перед загрузкой скрипта игры
    task.wait(3)
    
    -- Загружаем основной скрипт игры
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    
    if not success then
        WindUI:Notify({ Title = "Ошибка загрузки скрипта", Content = tostring(err), Duration = 5 })
        warn("Не удалось выполнить скрипт: " .. tostring(err))
    end
end

-- =========================================================================
-- СОЗДАНИЕ ОКНА
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub | Beta Version",
    Icon = "compass",
    Author = "BNDPA",
    Folder = "HoverlyHub",
    Size = UDim2.fromOffset(520, 360),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 175,
    HasOutline = true,
})

-- =========================================================================
-- ВКЛАДКА: ГЛАВНАЯ (Авто-детект или Universal)
-- =========================================================================
local MainTab = Window:Tab({
    Title = "Главная",
    Icon = "home",
})

local detectedGame = GetCurrentSupportedGame()

if detectedGame then
    MainTab:Paragraph({
        Title = "Статус Авто-детекта",
        Desc = "Обнаружена игра: **" .. detectedGame.Name .. "**\nВы можете запустить скрипт одной кнопкой ниже.",
    })
    
    MainTab:Button({
        Title = "Запустить скрипт для " .. detectedGame.Name,
        Desc = "Автоматический запуск найденного скрипта",
        Callback = function()
            LoadScript(detectedGame.KeyName, detectedGame.ScriptUrl, detectedGame.Name)
        end
    })
else
    MainTab:Paragraph({
        Title = "Игра не найдена в списке",
        Desc = "Текущая игра не поддерживается напрямую. Вы можете запустить универсальный скрипт **Universal**.",
    })
    
    MainTab:Button({
        Title = "Запустить Universal",
        Desc = "Запустить универсальный скрипт",
        Callback = function()
            LoadScript(UniversalData.KeyName, UniversalData.ScriptUrl, UniversalData.Name)
        end
    })
end

-- =========================================================================
-- ВКЛАДКА: ВЫБОР ИГР
-- =========================================================================
local GamesTab = Window:Tab({
    Title = "Выбор игры",
    Icon = "list",
})

GamesTab:Paragraph({
    Title = "Список скриптов",
    Desc = "Выберите нужную игру или универсальный скрипт вручную.",
})

-- Кнопка Universal на первом месте
GamesTab:Button({
    Title = UniversalData.Name,
    Desc = "Запустить универсальный скрипт",
    Icon = UniversalData.Icon,
    Callback = function()
        LoadScript(UniversalData.KeyName, UniversalData.ScriptUrl, UniversalData.Name)
    end
})

-- Список остальных игр
for _, gameData in ipairs(Games) do
    GamesTab:Button({
        Title = gameData.Name,
        Desc = "Загрузить " .. gameData.Name,
        Icon = gameData.Icon,
        Callback = function()
            LoadScript(gameData.KeyName, gameData.ScriptUrl, gameData.Name)
        end
    })
end

-- =========================================================================
-- ВКЛАДКА: INFO
-- =========================================================================
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Paragraph({
    Title = "Статистика использования",
    Desc = "Данные на этой вкладке обновляются в реальном времени.",
})

local TotalPara = InfoTab:Paragraph({
    Title = "Общий онлайн Hub",
    Desc = "Загрузка...",
})

local GamesPara = InfoTab:Paragraph({
    Title = "Популярность модулей",
    Desc = "Загрузка...",
})

task.spawn(function()
    while true do
        local totalOnline = GetStat("total_hub")
        
        local statsText = "• Universal: **" .. GetStat(UniversalData.KeyName) .. "** запусков\n"
        for _, gameData in ipairs(Games) do
            local count = GetStat(gameData.KeyName)
            statsText = statsText .. "• " .. gameData.Name .. ": **" .. count .. "** запусков\n"
        end
        
        pcall(function()
            TotalPara:SetDesc("Всего запусков хаба: **" .. tostring(totalOnline) .. "** чел.")
            GamesPara:SetDesc(statsText)
        end)
        
        task.wait(5)
    end
end)

Window:SelectTab(1)

