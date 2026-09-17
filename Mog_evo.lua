-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- =========================================================================
-- НАСТРОЙКА СТАТИСТИКИ (COUNTAPI)
-- =========================================================================
local NAMESPACE = "hoverlyhub_bndpa_mog_2026"

local function HitStat(key)
    pcall(function()
        game:HttpGet("https://api.countapi.xyz/hit/" .. NAMESPACE .. "/" .. key, true)
    end)
end

HitStat("mog_evolution")

-- =========================================================================
-- СОЗДАНИЕ ОКНА (Hoverly Script | Mog Evolution)
-- =========================================================================
local Window = WindUI:CreateWindow({
    Title = "Hoverly Script | Mog Evolution",
    Icon = "zap",
    Author = "BNDPA",
    Folder = "HoverlyMogEvolution",
    Size = UDim2.fromOffset(520, 360),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 175,
    HasOutline = true,
})

-- =========================================================================
-- ВКЛАДКА: ГЛАВНАЯ
-- =========================================================================
local MainTab = Window:Tab({
    Title = "Главная",
    Icon = "home",
})

MainTab:Paragraph({
    Title = "Mog Evolution Script",
    Desc = "Скрипт успешно загружен для игры Mog Evolution.\nПерейдите во вкладку Farm для настройки ультра-быстрого автокликера.",
})

-- =========================================================================
-- ВКЛАДКА: FARM (Автокликер 20 мс)
-- =========================================================================
local FarmTab = Window:Tab({
    Title = "Farm",
    Icon = "cpu",
})

FarmTab:Paragraph({
    Title = "Автокликер экрана",
    Desc = "Молниеносные нажатия на экран с задержкой 20 мс.",
})

local AutoClickEnabled = false

FarmTab:Toggle({
    Title = "Auto Click (20 мс)",
    Default = false,
    Callback = function(state)
        AutoClickEnabled = state
    end
})

-- Логика ультра-быстрого автокликера (каждые 20 миллисекунд / 0.02 сек)
task.spawn(function()
    while true do
        if AutoClickEnabled then
            pcall(function()
                local mouse = LocalPlayer:GetMouse()
                VirtualUser:Button1Down(Vector2.new(mouse.X, mouse.Y), workspace.CurrentCamera.CFrame)
                task.wait(0.01)
                VirtualUser:Button1Up(Vector2.new(mouse.X, mouse.Y), workspace.CurrentCamera.CFrame)
            end)
            task.wait(0.01) -- Общая задержка около 20 мс
        else
            task.wait(0.1)
        end
    end
end)

-- =========================================================================
-- ВКЛАДКА: INFO
-- =========================================================================
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Paragraph({
    Title = "Информация о скрипте",
    Desc = "Создатель: BNDPA\nИгра: Mog Evolution (PlaceID: 92648272637932)\nИнтерфейс: WindUI",
})

Window:SelectTab(1)

