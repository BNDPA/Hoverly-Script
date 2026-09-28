-- Загрузка библиотеки NodiumUI (VantaUI)
local VantaUI = loadstring(game:HttpGet("https://github.com/BNDPA/NodiumUI/raw/refs/heads/main/Latest.lua"))()
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
    KeyName = "universal"
}

local Games = {
    {
        Name = "Rivals",
        PlaceId = {17625359962},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/rivals.lua",
        KeyName = "rivals"
    },
    {
        Name = "Murder Mystery 2",
        PlaceId = {142823291},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/mm2.lua",
        KeyName = "mm2"
    },
    {
        Name = "Tower of Hell",
        PlaceId = {1962086868, 358276339},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/default_toh.lua",
        KeyName = "dtoh"
    },
    {
        Name = "DOORS",
        PlaceId = {6516141723, 6839171747},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/doors.lua",
        KeyName = "doors"
    },
    {
        Name = "Lumber Tycoon 2",
        PlaceId = {13822889},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/lt2.lua",
        KeyName = "lt2"
    },
    {
        Name = "Mog Evolution",
        PlaceId = {92648272637932},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Mog_evo.lua",
        KeyName = "MogEvo"
    },
    {
        Name = "Natural Disaster Survival",
        PlaceId = {189707},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/nds.lua",
        KeyName = "nds"
    },
    {
        Name = "Build A Boat For Treasure",
        PlaceId = {5374135},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/babft.lua",
        KeyName = "babft"
    },
    {
        Name = "Blox Fruit",
        PlaceId = {2753915549, 4442272183, 7449423635},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/bf.lua",
        KeyName = "bloxfruit"
    },
    {
        Name = "Duels murders vs sheriffs",
        PlaceId = {135856908115931},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Dmvs.lua",
        KeyName = "dmvs"
    },
    {
        Name = "Steal an egg",
        PlaceId = {107778070777162},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Sae.lua",
        KeyName = "sae"
    },
    {
        Name = "Fling Things and people",
        PlaceId = {6961824067},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Ftap.lua",
        KeyName = "ftap"
    }
}

-- Функция авто-детекта игры
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
    print("[Hoverly Hub] Запуск скрипта для: " .. gameName)
    
    -- Ожидание 3 секунды перед загрузкой скрипта игры
    task.wait(3)
    
    -- Уничтожаем окно перед загрузкой игры
    pcall(function() Window:Destroy() end)
    
    -- Загружаем основной скрипт игры
    local success, err = pcall(function()
        loadstring(game:HttpGet(scriptUrl))()
    end)
    
    if not success then
        warn("Не удалось выполнить скрипт: " .. tostring(err))
    end
end

-- =========================================================================
-- 1. СОЗДАНИЕ ГЛАВНОГО ОКНА
-- =========================================================================
local Window = VantaUI:Window({
    title = "Hoverly Hub | Beta Version",
    width = 700,
    height = 420,
    DisplayOrder = 2147483647
})

-- Принудительное удержание GUI поверх всех системных окон
task.spawn(function()
    pcall(function()
        while true do
            task.wait(1)
            local coreGui = game:GetService("CoreGui")
            for _, gui in ipairs(coreGui:GetChildren()) do
                if gui:IsA("ScreenGui") and (gui.Name:lower():find("vanta") or gui.Name:lower():find("hoverly")) then
                    gui.DisplayOrder = 2147483647
                    gui.IgnoreGuiInset = true
                    gui.ResetOnSpawn = false
                end
            end
            
            local playerGui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui:IsA("ScreenGui") and (gui.Name:lower():find("vanta") or gui.Name:lower():find("hoverly")) then
                        gui.DisplayOrder = 2147483647
                        gui.IgnoreGuiInset = true
                        gui.ResetOnSpawn = false
                    end
                end
            end
        end
    end)
end)

-- 2. Плавающая кнопка-круг для сворачивания/разворачивания интерфейса
local toggleCircle = Window:CreateDraggableCircle("rbxassetid://6023426915")

-- =========================================================================
-- ВКЛАДКА: ГЛАВНАЯ (Авто-детект или Universal)
-- =========================================================================
local MainTab = Window:CreateTab("Главная")
local MainSection = MainTab:CreateSection("Авто-определение игры")

local detectedGame = GetCurrentSupportedGame()

if detectedGame then
    MainSection:CreateButton("Запустить для: " .. detectedGame.Name, function()
        LoadScript(detectedGame.KeyName, detectedGame.ScriptUrl, detectedGame.Name)
    end)
else
    MainSection:CreateButton("Запустить Universal", function()
        LoadScript(UniversalData.KeyName, UniversalData.ScriptUrl, UniversalData.Name)
    end)
end

-- =========================================================================
-- ВКЛАДКА: ВЫБОР ИГР
-- =========================================================================
local GamesTab = Window:CreateTab("Выбор игры")
local GamesSection = GamesTab:CreateSection("Доступные скрипты")

-- Кнопка Universal на первом месте
GamesSection:CreateButton(UniversalData.Name, function()
    LoadScript(UniversalData.KeyName, UniversalData.ScriptUrl, UniversalData.Name)
end)

-- Кнопки остальных игр из списка
for _, gameData in ipairs(Games) do
    GamesSection:CreateButton(gameData.Name, function()
        LoadScript(gameData.KeyName, gameData.ScriptUrl, gameData.Name)
    end)
end

-- =========================================================================
-- ВКЛАДКА: INFO (Статистика)
-- =========================================================================
local InfoTab = Window:CreateTab("Info")
local InfoSection = InfoTab:CreateSection("Статистика использования")

-- Создаем переменные-заглушки для вывода онлайна через кнопки или текст (в зависимости от возможностей библиотеки)
InfoSection:CreateButton("Обновить статистику", function()
    local totalOnline = GetStat("total_hub")
    print("=== СТАТИСТИКА HOVERLY HUB ===")
    print("Всего запусков хаба:", totalOnline)
    print("Universal запусков:", GetStat(UniversalData.KeyName))
    for _, gameData in ipairs(Games) do
        print(gameData.Name .. " запусков:", GetStat(gameData.KeyName))
    end
end)

-- Фоновое обновление счетчиков в консоль / можно вывести в логи
task.spawn(function()
    while true do
        local totalOnline = GetStat("total_hub")
        task.wait(10)
    end
end)
