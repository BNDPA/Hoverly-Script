-- Загрузка библиотеки WindUI (убедитесь, что используете актуальную версию)
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/getSource.lua()"))()

-- Создание главного окна авторизации
local Window = WindUI:CreateWindow({
    Title = "Howerly Hub | Key System",
    Icon = "rbxassetid://10723424205", -- Иконка (можно изменить)
    Author = "Security",
    Size = UDim2.fromOffset(450, 260),
    Transparent = true,
    Theme = "Dark", -- Тема интерфейса
    Resizable = false,
})

-- Создаем вкладку для ввода ключа
local Tab = Window:Tab({
    Title = "Авторизация",
    Icon = "key",
})

-- Переменная для хранения введенного ключа
local enteredKey = ""

-- Поле ввода текста (Input) для ключа
Tab:Input({
    Title = "Введите ключ",
    Description = "Получите ключ в нашем Discord / Telegram",
    PlaceholderText = "Введите ваш ключ здесь...",
    Callback = function(value)
        enteredKey = value
    end
})

-- Кнопка проверки ключа
Tab:Button({
    Title = "Активировать ключ",
    Description = "Нажмите для проверки ключа",
    Callback = function()
        -- ЗАМЕНИТЕ "YOUR_SECRET_KEY" на ваш реальный ключ
        local correctKey = "YOUR_SECRET_KEY" 
        
        if enteredKey == correctKey then
            -- Уведомление об успешном входе
            WindUI:Notify({
                Title = "Успешно!",
                Content = "Ключ принят. Запуск Howerly Hub...",
                Duration = 3,
            })
            
            -- Закрываем окно авторизации
            Window:Close()
            
            -- Небольшая задержка перед загрузкой основного скрипта
            task.wait(0.5)
            
            -- Запуск вашего основного скрипта Loader.lua
            local success, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/BNDPA/Hoverly-Script/main/Loader.lua"))()
            end)
            
            if not success then
                warn("Ошибка при загрузке Hub.lua: " .. tostring(err))
            end
        else
            -- Уведомление об ошибке
            WindUI:Notify({
                Title = "Ошибка!",
                Content = "Неверный ключ. Попробуйте снова.",
                Duration = 3,
            })
        end
    end
})

-- Дополнительная кнопка для получения ключа (опционально)
Tab:Button({
    Title = "Получить ключ",
    Description = "Скопировать ссылку на получение ключа",
    Callback = function()
        setclipboard("https://your-link-to-get-key.com") -- Замените на вашу ссылку
        WindUI:Notify({
            Title = "Ссылка скопирована",
            Content = "Ссылка на получение ключа скопирована в буфер обмена!",
            Duration = 3,
        })
    end
})

