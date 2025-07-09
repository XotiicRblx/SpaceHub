local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local functionEnabled = true
local panelVisible = false

-- Setup GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Icon button (gear) - draggable
local iconButton = Instance.new("ImageButton")
iconButton.Name = "OpenToggleButton"
iconButton.Size = UDim2.new(0, 40, 0, 40)
iconButton.Position = UDim2.new(0, 10, 1, -50)
iconButton.BackgroundTransparency = 1
iconButton.Image = "rbxassetid://7734016636" -- Gear icon
iconButton.AnchorPoint = Vector2.new(0, 0)
iconButton.Parent = screenGui

-- Toggle Panel
local togglePanel = Instance.new("Frame")
togglePanel.Name = "TogglePanel"
togglePanel.Size = UDim2.new(0, 140, 0, 50)
togglePanel.Position = UDim2.new(0, -150, 1, -100) -- hidden to the left
togglePanel.BackgroundColor3 = Color3.new(0, 0, 0)
togglePanel.BackgroundTransparency = 0.3
togglePanel.BorderSizePixel = 0
togglePanel.Parent = screenGui

-- Toggle Button inside panel
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 1, 0)
toggleButton.BackgroundTransparency = 1
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Text = "Highlight: ON"
toggleButton.Parent = togglePanel

-- Tween function
local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function slidePanel(show)
	local target = show and UDim2.new(0, 10, 1, -100) or UDim2.new(0, -150, 1, -100)
	TweenService:Create(togglePanel, tweenInfo, {Position = target}):Play()
	panelVisible = show
end

-- Add highlight
local function addHighlight(player)
	if player == LocalPlayer then return end
	local character = player.Character
	if not character or character:FindFirstChild("WhiteHighlight") then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "WhiteHighlight"
	highlight.FillColor = Color3.new(1, 1, 1)
	highlight.OutlineColor = Color3.new(1, 1, 1)
	highlight.FillTransparency = 0.7
	highlight.OutlineTransparency = 0
	highlight.Adornee = character
	highlight.Parent = character
end

-- Add name tag
local function addNameTag(player)
	if player == LocalPlayer then return end
	local character = player.Character
	if not character then return end
	local head = character:FindFirstChild("Head")
	if not head or head:FindFirstChild("UsernameBillboard") then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "UsernameBillboard"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = head

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.5
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 20
	label.Text = player.Name
	label.Parent = billboard
end

-- Remove highlight and name tag
local function removeHighlight(player)
	local character = player.Character
	if character and character:FindFirstChild("WhiteHighlight") then
		character.WhiteHighlight:Destroy()
	end
end

local function removeNameTag(player)
	local character = player.Character
	if character then
		local head = character:FindFirstChild("Head")
		if head and head:FindFirstChild("UsernameBillboard") then
			head.UsernameBillboard:Destroy()
		end
	end
end

-- Update one player
local function updatePlayerEffects(player)
	if functionEnabled then
		addHighlight(player)
		addNameTag(player)
	else
		removeHighlight(player)
		removeNameTag(player)
	end
end

-- Main loop to update every frame
RunService.RenderStepped:Connect(function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			updatePlayerEffects(player)
		end
	end
end)

-- Player events
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.wait(1)
		updatePlayerEffects(player)
	end)
end)

for _, player in ipairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function()
		task.wait(1)
		updatePlayerEffects(player)
	end)
end

-- Handle toggle press
toggleButton.MouseButton1Click:Connect(function()
	functionEnabled = not functionEnabled
	toggleButton.Text = "Highlight: " .. (functionEnabled and "ON" or "OFF")

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			updatePlayerEffects(player)
		end
	end
end)

-- Toggle icon button press
iconButton.MouseButton1Click:Connect(function()
	slidePanel(not panelVisible)
end)

-- Drag logic
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	iconButton.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
end

iconButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = iconButton.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

iconButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
