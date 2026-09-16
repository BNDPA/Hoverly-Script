-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- База данных поддерживаемых игр под ваш репозиторий BNDPA/Hoverly-Script
local Games = {
    {
        Name = "DOORS",
        PlaceId = {6516141723, 6839171747},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/doors.lua",
        Icon = "door-closed"
    },
    {
        Name = "Lumber Tycoon 2",
        PlaceId = {13822889},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/lt2.lua",
        Icon = "axe"
    },
    {
        Name = "Natural Disaster Survival",
        PlaceId = {189707},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/nds.lua",
        Icon = "cloud-rain"
    },
    {
        Name = "Build A Boat For Treasure",
        PlaceId = {5374135, 358276339},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/babft.lua",
        Icon = "hammer"
    },
    {
        Name = "Blox Fruit",
        PlaceId = {2753915549, 4442272183, 7449423635},
        ScriptUrl = "https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/bf.lua",
        Icon = "swords"
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
            
            -- Уничтожаем (выключаем) окно хаба перед выполнением скрипта игры
            pcall(function()
                Window:Destroy()
            end)
            
            local success, err = pcall(function()
                loadstring(game:HttpGet(detectedGame.ScriptUrl))()
            end)
            
            if not success then
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
        Callback = function()
            WindUI:Notify({
                Title = "Загрузка...",
                Content = "Загружается скрипт для " .. gameData.Name,
                Duration = 2,
            })
            
            -- Уничтожаем (выключаем) окно хаба перед выполнением скрипта игры
            pcall(function()
                Window:Destroy()
            end)
            
            local success, err = pcall(function()
                loadstring(game:HttpGet(gameData.ScriptUrl))()
            end)
            
            if not success then
                warn("Не удалось выполнить скрипт: " .. tostring(err))
            end
        end
    })
end

-- Открываем первую вкладку по умолчанию
Window:SelectTab(1)

