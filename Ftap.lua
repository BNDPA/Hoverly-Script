local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local camera = workspace.CurrentCamera

local MAX_DISTANCE = 30 -- Максимальное расстояние поиска (в студсах)

player.CharacterAdded:Connect(function(newChar)
	character = newChar
end)

local currentSpeed = 90
local MIN_SPEED = 5
local MAX_SPEED = 300
local isFirstPerson = false

-- Переменные текущей активной ракеты
local activeRocket = nil
local mainPart = nil
local bv = nil
local bg = nil
local unbindCooldown = 0 -- Кулдаун после отвязки

-- ======= 1. UI: СОЗДАЕТСЯ ОДИН РАЗ =======

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RocketControlGui"
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 9999
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = player:WaitForChild("PlayerGui") end

-- Прицел
local crosshair = Instance.new("Frame")
crosshair.Name = "Crosshair"
crosshair.Size = UDim2.new(0, 8, 0, 8)
crosshair.Position = UDim2.new(0.5, -4, 0.5, -4)
crosshair.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
crosshair.BorderSizePixel = 0
crosshair.Parent = screenGui

local chCorner = Instance.new("UICorner")
chCorner.CornerRadius = UDim.new(1, 0)
chCorner.Parent = crosshair

-- Кнопка отмены
local cancelBtn = Instance.new("TextButton")
cancelBtn.Name = "CancelButton"
cancelBtn.Size = UDim2.new(0, 180, 0, 50)
cancelBtn.Position = UDim2.new(0.5, -90, 0.82, 0)
cancelBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 40)
cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
cancelBtn.TextSize = 18
cancelBtn.Font = Enum.Font.GothamBold
cancelBtn.Text = "ОТВЯЗАТЬ КАМЕРУ"
cancelBtn.Parent = screenGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 10)
btnCorner.Parent = cancelBtn

-- Кнопка смены вида (смещена ниже: Y = 75)
local viewBtn = Instance.new("TextButton")
viewBtn.Name = "ViewButton"
viewBtn.Size = UDim2.new(0, 130, 0, 45)
viewBtn.Position = UDim2.new(1, -145, 0, 75)
viewBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 220)
viewBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
viewBtn.TextSize = 14
viewBtn.Font = Enum.Font.GothamBold
viewBtn.Text = "📷 ВИД: 3-E"
viewBtn.Parent = screenGui

local viewCorner = Instance.new("UICorner")
viewCorner.CornerRadius = UDim.new(0, 10)
viewCorner.Parent = viewBtn

-- Блок скорости
local speedContainer = Instance.new("Frame")
speedContainer.Name = "SpeedContainer"
speedContainer.Size = UDim2.new(0, 75, 0, 150)
speedContainer.Position = UDim2.new(0.85, 0, 0.5, -75)
speedContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
speedContainer.BackgroundTransparency = 0.1
speedContainer.BorderSizePixel = 0
speedContainer.Parent = screenGui

local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 12)
scCorner.Parent = speedContainer

local btnUp = Instance.new("TextButton")
btnUp.Name = "SpeedUp"
btnUp.Size = UDim2.new(1, -10, 0, 40)
btnUp.Position = UDim2.new(0, 5, 0, 5)
btnUp.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
btnUp.TextColor3 = Color3.fromRGB(255, 255, 255)
btnUp.TextSize = 22
btnUp.Font = Enum.Font.GothamBold
btnUp.Text = "▲"
btnUp.Parent = speedContainer

local upCorner = Instance.new("UICorner")
upCorner.CornerRadius = UDim.new(0, 8)
upCorner.Parent = btnUp

local speedLabel = Instance.new("TextLabel")
speedLabel.Name = "SpeedLabel"
speedLabel.Size = UDim2.new(1, 0, 0, 50)
speedLabel.Position = UDim2.new(0, 0, 0, 50)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
speedLabel.TextSize = 18
speedLabel.Font = Enum.Font.GothamBold
speedLabel.Text = tostring(currentSpeed)
speedLabel.Parent = speedContainer

local btnDown = Instance.new("TextButton")
btnDown.Name = "SpeedDown"
btnDown.Size = UDim2.new(1, -10, 0, 40)
btnDown.Position = UDim2.new(0, 5, 1, -45)
btnDown.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
btnDown.TextColor3 = Color3.fromRGB(255, 255, 255)
btnDown.TextSize = 22
btnDown.Font = Enum.Font.GothamBold
btnDown.Text = "▼"
btnDown.Parent = speedContainer

local downCorner = Instance.new("UICorner")
downCorner.CornerRadius = UDim.new(0, 8)
downCorner.Parent = btnDown

-- ======= ХАБ УПРАВЛЕНИЯ =======

-- Кнопка открытия хаба (смещена ниже: Y = 75)
local openHubBtn = Instance.new("TextButton")
openHubBtn.Name = "OpenHubButton"
openHubBtn.Size = UDim2.new(0, 110, 0, 35)
openHubBtn.Position = UDim2.new(0, 15, 0, 75)
openHubBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
openHubBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
openHubBtn.TextSize = 13
openHubBtn.Font = Enum.Font.GothamBold
openHubBtn.Text = "⚙️ РАКЕТА"
openHubBtn.Parent = screenGui

local hubBtnCorner = Instance.new("UICorner")
hubBtnCorner.CornerRadius = UDim.new(0, 8)
hubBtnCorner.Parent = openHubBtn

-- Меню хаба (открывается ниже кнопки: Y = 120)
local hubFrame = Instance.new("Frame")
hubFrame.Name = "HubFrame"
hubFrame.Size = UDim2.new(0, 200, 0, 190)
hubFrame.Position = UDim2.new(0, 15, 0, 120)
hubFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
hubFrame.BackgroundTransparency = 0.1
hubFrame.Visible = false
hubFrame.Parent = screenGui

local hubCorner = Instance.new("UICorner")
hubCorner.CornerRadius = UDim.new(0, 10)
hubCorner.Parent = hubFrame

local hubTitle = Instance.new("TextLabel")
hubTitle.Size = UDim2.new(1, 0, 0, 30)
hubTitle.BackgroundTransparency = 1
hubTitle.TextColor3 = Color3.fromRGB(255, 200, 0)
hubTitle.TextSize = 14
hubTitle.Font = Enum.Font.GothamBold
hubTitle.Text = "НАСТРОЙКИ UI"
hubTitle.Parent = hubFrame

local toggles = {}

local function createToggle(text, pos, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 32)
	btn.Position = pos
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 12
	btn.Parent = hubFrame

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = btn

	local toggleObj = {
		state = defaultState,
		btn = btn,
		text = text,
		callback = callback
	}

	function toggleObj:SetState(newState)
		self.state = newState
		if self.state then
			self.btn.BackgroundColor3 = Color3.fromRGB(40, 160, 60)
			self.btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			self.btn.Text = self.text .. ": Вкл"
		else
			self.btn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
			self.btn.TextColor3 = Color3.fromRGB(200, 200, 200)
			self.btn.Text = self.text .. ": Выкл"
		end
		self.callback(self.state)
	end

	toggleObj:SetState(defaultState)

	btn.MouseButton1Click:Connect(function()
		toggleObj:SetState(not toggleObj.state)
	end)

	table.insert(toggles, toggleObj)
	return toggleObj
end

openHubBtn.MouseButton1Click:Connect(function()
	hubFrame.Visible = not hubFrame.Visible
end)

createToggle("❌ Отмена", UDim2.new(0.05, 0, 0, 35), true, function(state)
	cancelBtn.Visible = state
end)

createToggle("📷 Вид", UDim2.new(0.05, 0, 0, 72), true, function(state)
	viewBtn.Visible = state
end)

createToggle("⚡ Скорость", UDim2.new(0.05, 0, 0, 109), true, function(state)
	speedContainer.Visible = state
end)

local allUiVisible = true
local hideAllBtn = Instance.new("TextButton")
hideAllBtn.Size = UDim2.new(0.9, 0, 0, 32)
hideAllBtn.Position = UDim2.new(0.05, 0, 0, 146)
hideAllBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
hideAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
hideAllBtn.TextSize = 11
hideAllBtn.Font = Enum.Font.GothamBold
hideAllBtn.Text = "👁️ Скрыть весь UI"
hideAllBtn.Parent = hubFrame

local hideCorner = Instance.new("UICorner")
hideCorner.CornerRadius = UDim.new(0, 6)
hideCorner.Parent = hideAllBtn

hideAllBtn.MouseButton1Click:Connect(function()
	allUiVisible = not allUiVisible
	crosshair.Visible = allUiVisible
	
	for _, toggle in ipairs(toggles) do
		toggle:SetState(allUiVisible)
	end

	hideAllBtn.Text = allUiVisible and "👁️ Скрыть весь UI" or "👁️ Показать весь UI"
end)

-- ======= 2. УПРАВЛЕНИЕ И СЕНСОР =======

viewBtn.MouseButton1Click:Connect(function()
	isFirstPerson = not isFirstPerson
	if isFirstPerson then
		viewBtn.Text = "📷 ВИД: 1-E"
		viewBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 220)
	else
		viewBtn.Text = "📷 ВИД: 3-E"
		viewBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 220)
	end
end)

local function updateSpeedDisplay()
	speedLabel.Text = tostring(currentSpeed)
end

btnUp.MouseButton1Click:Connect(function()
	currentSpeed = math.clamp(currentSpeed + 10, MIN_SPEED, MAX_SPEED)
	updateSpeedDisplay()
end)

btnDown.MouseButton1Click:Connect(function()
	currentSpeed = math.clamp(currentSpeed - 10, MIN_SPEED, MAX_SPEED)
	updateSpeedDisplay()
end)

local yaw = math.rad(character and character:FindFirstChild("HumanoidRootPart") and character.HumanoidRootPart.Orientation.Y or 0)
local pitch = 0
local lastTouchPos = nil

UserInputService.TouchStarted:Connect(function(touch)
	lastTouchPos = touch.Position
end)

UserInputService.TouchMoved:Connect(function(touch)
	if lastTouchPos then
		local delta = touch.Position - lastTouchPos
		yaw = yaw - delta.X * 0.004
		pitch = math.clamp(pitch - delta.Y * 0.004, -1.4, 1.4)
		lastTouchPos = touch.Position
	end
end)

UserInputService.TouchEnded:Connect(function()
	lastTouchPos = nil
end)

local function restoreRocketVisibility()
	if activeRocket then
		for _, part in ipairs(activeRocket:GetDescendants()) do
			if part:IsA("BasePart") then
				part.LocalTransparencyModifier = 0
			end
		end
	end
end

local function resetCameraToPlayer()
	restoreRocketVisibility()
	camera.CameraType = Enum.CameraType.Custom
	if character and character:FindFirstChildOfClass("Humanoid") then
		camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
	end
end

cancelBtn.MouseButton1Click:Connect(function()
	restoreRocketVisibility()
	activeRocket = nil
	mainPart = nil
	unbindCooldown = 1.5 -- Даем паузу в 1.5 секунды перед повторным автопоиском ракеты
	resetCameraToPlayer()
end)

-- ======= 3. ПОИСК РАКЕТЫ В РАДИУСЕ 30 СТУДСОВ =======

local function findRocketNearby()
	if not character then return nil end
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end

	local candidates = {}

	local folderName = player.Name .. "SpawnedInToys"
	local folder = workspace:FindFirstChild(folderName)
	if folder then
		for _, child in pairs(folder:GetChildren()) do
			if child.Name == "BombMissile" then
				table.insert(candidates, child)
			end
		end
	end

	for _, child in pairs(workspace:GetChildren()) do
		if child.Name:find("SpawnedInToys") then
			for _, obj in pairs(child:GetChildren()) do
				if obj.Name == "BombMissile" then
					table.insert(candidates, obj)
				end
			end
		end
	end

	for _, obj in pairs(workspace:GetChildren()) do
		if obj.Name == "BombMissile" then
			table.insert(candidates, obj)
		end
	end

	local closestRocket = nil
	local shortestDist = MAX_DISTANCE

	for _, rocketObj in pairs(candidates) do
		local part = rocketObj:IsA("BasePart") and rocketObj or (rocketObj.PrimaryPart or rocketObj:FindFirstChildWhichIsA("BasePart"))
		if part then
			local dist = (part.Position - hrp.Position).Magnitude
			if dist <= shortestDist then
				shortestDist = dist
				closestRocket = rocketObj
			end
		end
	end

	return closestRocket
end

-- Единый бесконечный цикл
RunService.RenderStepped:Connect(function(dt)
	if unbindCooldown > 0 then
		unbindCooldown = unbindCooldown - dt
	end

	if activeRocket and (not activeRocket.Parent or not mainPart or not mainPart.Parent) then
		restoreRocketVisibility()
		activeRocket = nil
		mainPart = nil
		resetCameraToPlayer()
	end

	-- Ищем ракету только если кулдаун закончился
	if not activeRocket and unbindCooldown <= 0 then
		local found = findRocketNearby()
		if found then
			activeRocket = found
			mainPart = activeRocket:IsA("BasePart") and activeRocket or (activeRocket.PrimaryPart or activeRocket:FindFirstChildWhichIsA("BasePart"))
			
			if mainPart then
				bv = mainPart:FindFirstChild("BodyVelocity") or Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
				bv.Parent = mainPart

				bg = mainPart:FindFirstChild("BodyGyro") or Instance.new("BodyGyro")
				bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
				bg.D = 150
				bg.P = 5000
				bg.Parent = mainPart

				camera.CameraType = Enum.CameraType.Scriptable
			else
				activeRocket = nil
			end
		end
	end

	if activeRocket and mainPart and mainPart.Parent then
		local aimRotation = CFrame.Angles(0, yaw, 0) * CFrame.Angles(pitch, 0, 0)
		local targetDirection = aimRotation.LookVector

		if bg and bg.Parent then
			bg.CFrame = CFrame.new(mainPart.Position, mainPart.Position + targetDirection) * CFrame.Angles(math.rad(-90), 0, 0)
		end
		if bv and bv.Parent then
			bv.Velocity = targetDirection * currentSpeed
		end

		if isFirstPerson then
			for _, part in ipairs(activeRocket:GetDescendants()) do
				if part:IsA("BasePart") then
					part.LocalTransparencyModifier = 1
				end
			end

			local noseOffset = targetDirection * ((math.max(mainPart.Size.X, mainPart.Size.Y, mainPart.Size.Z) / 2) + 0.5)
			local nosePos = mainPart.Position + noseOffset
			camera.CFrame = CFrame.new(nosePos, nosePos + targetDirection)
		else
			restoreRocketVisibility()
			camera.CFrame = CFrame.new(mainPart.Position) * aimRotation * CFrame.new(0, 3, 10)
		end
	end
end)
