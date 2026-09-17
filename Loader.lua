return(function(oxwQ2, ...)
local jUQIMu = {"KOU";"r6udkHFmp";"EuV6QRxru5gY";"93GpA0YlucTM";"m1hrLVBvhZcdRu2KC";"aO3g9oC";"rEOJLf"}
local ARqpc6Kg = function(...)
-- Загрузка WindUI
local WindUI = loadstring(game:HttpGet(loadstring(base64decode("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0Zvb3RhZ2VzdXMvV2luZFVJL21haW4vZGlzdC9tYWluLmx1YQ=="))()))()

-- Список доступных ключей и их ссылок для загрузки
local VALID_KEYS = {
    [loadstring(base64decode("SG92ZXJIdWI="))()] = loadstring(base64decode("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0JORFBBL0hvdmVybHktU2NyaXB0L21haW4vSHViLmx1YQ=="))(),
    [loadstring(base64decode("SG92ZXJIdWIuY2M="))()] = loadstring(base64decode("aHR0cHM6Ly9yYXcuZ2l0aHVidXNlcmNvbnRlbnQuY29tL0JORFBBL0hvdmVybHktU2NyaXB0L21haW4vQmV0YUh1Yi5sdWE="))()
}

local InputKey = loadstring(base64decode(""))()

-- Создание окна
local Window = WindUI:CreateWindow({
    Title = loadstring(base64decode("SG92ZXJseSBIdWI="))(),
    Icon = loadstring(base64decode("cmJ4YXNzZXRpZDovLzEwNzM0OTUwMzA5"))(),
    Author = loadstring(base64decode("S2V5IFN5c3RlbQ=="))(),
    Folder = loadstring(base64decode("SG92ZXJseUh1YktleQ=="))(),
    Size = UDim2.fromOffset(480, 280),
    Transparent = true,
    Theme = loadstring(base64decode("RGFyaw=="))(),
    SideBarWidth = 140,
    HasOutline = true,
})

-- Создаем вкладку Key Check
local Tab = Window:Tab({
    Title = loadstring(base64decode("S2V5IENoZWNr"))(),
    Icon = loadstring(base64decode("a2V5"))(),
})

-- Поле ввода ключа
Tab:Input({
    Title = loadstring(base64decode("0JLQstC10LTQuNGC0LUg0LrQu9GO0Yc="))(),
    Placeholder = loadstring(base64decode("0JLQstC10LTQuNGC0LUg0LrQu9GO0YcuLi4="))(),
    Callback = function(Value)
        InputKey = Value
    end
})

-- Кнопка проверки
Tab:Button({
    Title = loadstring(base64decode("0J/RgNC+0LLQtdGA0LjRgtGMINC60LvRjtGH"))(),
    Callback = function()
        local targetUrl = VALID_KEYS[InputKey]
        
        if targetUrl then
            WindUI:Notify({
                Title = loadstring(base64decode("0KPRgdC/0LXRiNC90L4h"))(),
                Content = loadstring(base64decode("0JrQu9GO0Ycg0LLQtdGA0L3Ri9C5LiDQl9Cw0LPRgNGD0LfQutCwINGF0LDQsdCwLi4u"))(),
                Duration = 3,
            })
            
            -- Полностью удаляем окно Key System с экрана
            Window:Destroy()
            
            -- Загружаем хаб, соответствующий введенному ключу
            task.spawn(function()
                local success, err = pcall(function()
                    loadstring(game:HttpGet(targetUrl))()
                end)
                
                if not success then
                    warn(loadstring(base64decode("0J7RiNC40LHQutCwINC/0YDQuCDQt9Cw0LPRgNGD0LfQutC1INGF0LDQsdCwOiA="))() .. tostring(err))
                end
            end)
        else
            WindUI:Notify({
                Title = loadstring(base64decode("0J7RiNC40LHQutCw"))(),
                Content = loadstring(base64decode("0J3QtdCy0LXRgNC90YvQuSDQutC70Y7RhyEg0J/QvtC/0YDQvtCx0YPQudGC0LUg0LXRidC1INGA0LDQty4="))(),
                Duration = 3,
            })
        end
    end
})
end
VF5NQZUk(LtGyd)
end)(...)
