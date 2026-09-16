-- Загрузка WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

local CORRECT_KEY = "HoverHub"
local InputKey = ""

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub",
    Icon = "rbxassetid://10734950309",
    Author = "Key System",
    Folder = "HoverlyHubKey",
    Size = UDim2.fromOffset(400, 220),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 0,
    HasOutline = true,
})

-- Создаем единственную вкладку Key Check
local Tab = Window:Tab({
    Title = "Key Check",
    Icon = "key",
})

-- Поле ввода ключа
Tab:Input({
    Title = "Введите ключ",
    Placeholder = "Введите ключ...",
    Callback = function(Value)
        InputKey = Value
    end
})

-- Кнопка проверки
Tab:Button({
    Title = "Проверить ключ",
    Callback = function()
        if InputKey == CORRECT_KEY then
            WindUI:Notify({
                Title = "Успешно!",
                Content = "Ключ верный. Загрузка хаба...",
                Duration = 3,
            })
            
            -- Закрываем окно проверки
            Window:Close()
            
            -- Загружаем ваш основной хаб
            task.spawn(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Hub.lua"))()
                end)
                
                if not success then
                    warn("Ошибка при загрузке хаба: " .. tostring(err))
                end
            end)
        else
            WindUI:Notify({
                Title = "Ошибка",
                Content = "Неверный ключ! Попробуйте еще раз.",
                Duration = 3,
            })
        end
    end
})
