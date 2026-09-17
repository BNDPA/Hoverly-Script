-- Надежная загрузка библиотеки WindUI
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    warn("Не удалось загрузить WindUI!")
    return
end

-- Создание главного окна (Window)
local Window = WindUI:CreateWindow({
    Title = "Hoverly Hub",
    Icon = "rbxassetid://6031094678",
    Author = "Tower of Hell",
    Folder = "HoverlyHub",
    Size = UDim2.fromOffset(500, 350),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 150,
})

-- Создание вкладки "Телепорт"
local TeleportTab = Window:Tab({
    Title = "Телепорт",
    Icon = "rbxassetid://6023426915",
})

-- Создание вкладки "Other"
local OtherTab = Window:Tab({
    Title = "Other",
    Icon = "rbxassetid://6023426915",
})

-- Функция телепортации игрока
local function teleportTo(cframe)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = cframe
    end
end

-- Функция выдачи предмета игроку из хранилища игры (ReplicatedStorage)
local function giveItem(itemName)
    local player = game.Players.LocalPlayer
    local replicatedStorage = game:GetService("ReplicatedStorage")
    
    -- Поиск папки с предметами/гиром в игре
    local gearFolder = replicatedStorage:FindFirstChild("Gear") or replicatedStorage:FindFirstChild("Tools") or replicatedStorage:FindFirstChild("Items")
    
    if gearFolder then
        local item = gearFolder:FindFirstChild(itemName)
        if item then
            local clonedItem = item:Clone()
            clonedItem.Parent = player.Backpack
            WindUI:Notify({
                Title = "Hoverly Hub",
                Content = "Предмет " .. itemName .. " успешно выдан!",
                Duration = 2
            })
            return
        end
    end
    
    -- Альтернативный поиск по всей игре, если папка не найдена стандартно
    for _, obj in ipairs(replicatedStorage:GetDescendants()) do
        if obj.Name:lower() == itemName:lower() and obj:IsA("Tool") then
            local clonedItem = obj:Clone()
            clonedItem.Parent = player.Backpack
            WindUI:Notify({
                Title = "Hoverly Hub",
                Content = "Предмет " .. itemName .. " успешно выдан!",
                Duration = 2
            })
            return
        end
    end
    
    WindUI:Notify({
        Title = "Hoverly Hub",
        Content = "Не удалось найти предмет: " .. itemName,
        Duration = 3
    })
end

-- Секция с телепортами на башни
TeleportTab:Section({
    Title = "Выбор башни"
})

-- Кнопка телепорта на Pro Tower
TeleportTab:Button({
    Title = "Pro Tower",
    Desc = "Телепортация на Pro Tower",
    Callback = function()
        teleportTo(CFrame.new(0.12, 9.75, 46.59))
    end
})

-- Кнопка телепорта на The Tower
TeleportTab:Button({
    Title = "The Tower",
    Desc = "Телепортация на The Tower",
    Callback = function()
        teleportTo(CFrame.new(0.22, -8.16, 47.47))
    end
})

-- Секция во вкладке Other для выдачи предметов
OtherTab:Section({
    Title = "Выдача предметов (Gear)"
})

OtherTab:Button({
    Title = "Speed Coil",
    Desc = "Выдать Speed Coil",
    Callback = function()
        giveItem("Speed Coil")
    end
})

OtherTab:Button({
    Title = "Jump Coil",
    Desc = "Выдать Jump Coil",
    Callback = function()
        giveItem("Jump Coil")
    end
})

OtherTab:Button({
    Title = "Шпатель (Trowel)",
    Desc = "Выдать шпатель из тавера",
    Callback = function()
        giveItem("Trowel")
    end
})

OtherTab:Button({
    Title = "Катушка двойного прыжка",
    Desc = "Выдать катушку двойного прыжка",
    Callback = function()
        giveItem("Fusion Coil") -- Либо аналог двойного прыжка в зависимости от базы предметов
    end
})

-- Уведомление об успешной загрузке
WindUI:Notify({
    Title = "Hoverly Hub",
    Content = "Скрипт успешно запущен!",
    Duration = 3
})

