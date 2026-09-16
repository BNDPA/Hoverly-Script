-- Загрузка библиотеки WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Переменная с правильным ключом
local CORRECT_KEY = "HoverHub"

-- Создание главного окна для авторизации (Key System)
local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub | Key System",
    Icon = "rbxassetid://10734950309", -- Иконка
    Author = "Security System",
    Folder = "HoverlyHub",
    Size = UDim2.fromOffset(450, 260),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 0,
    HasOutline = true,
})

-- Создаем вкладку для ввода ключа
local Tab = Window:Tab({
    Title = "Key Authorization",
    Icon = "key",
})

-- Переменная для хранения введенного текста
local InputKey = ""

-- Поле ввода ключа
Tab:Input({
    Title = "Введите ключ",
    Placeholder = "Введите ключ здесь...",
    Callback = function(Value)
        InputKey = Value
    end
})

-- Кнопка проверки ключа
Tab:Button({
    Title = "Проверить ключ",
    Callback = function()
        if InputKey == CORRECT_KEY then
            WindUI:Notify({
                Title = "Успешно!",
                Content = "Ключ верный. Загрузка Hoverly Hub...",
                Duration = 3,
            })
            
            -- Закрываем окно авторизации
            Window:Close()
            
            -- Загружаем основной скрипт хаба через loadstring
            task.spawn(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Hub.lua"))()
                end)
                
                if not success then
                    warn("Ошибка при загрузке Hoverly Hub: " .. tostring(err))
                end
            end)
            
        else
            WindUI:Notify({
                Title = "Ошибка!",
                Content = "Неверный ключ. Попробуйте еще раз.",
                Duration = 3,
            })
        end
    end
})

-- Кнопка для получения / копирования ключа
Tab:Button({
    Title = "Скопировать ключ",
    Callback = function()
        setclipboard("HoverHub") -- Копирует ключ в буфер обмена
        WindUI:Notify({
            Title = "Буфер обмена",
            Content = "Ключ скопирован: HoverHub",
            Duration = 3,
        })
    end
})
