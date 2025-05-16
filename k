-- LocalScript (StarterPlayerScripts)

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local pos1, pos2 = nil, nil
local tweening, currentTween = false, nil

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TweenAndProxControl"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 450)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

-- UICorner for round edges
local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

-- UIListLayout for auto-stacking
local layout = Instance.new("UIListLayout", mainFrame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Padding inside
local padding = Instance.new("UIPadding", mainFrame)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0, 4)
closeButton.AnchorPoint = Vector2.new(0.5, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.Parent = mainFrame

local function createButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 36)
	button.Text = text
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.AutoButtonColor = true
	button.Parent = mainFrame
	return button
end

local function createLabel()
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.Text = ""
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = mainFrame
	return label
end

-- GUI elements
local savePos1Btn = createButton("Save Position 1")
local savePos2Btn = createButton("Save Position 2")
local enableTweenBtn = createButton("Enable Tween")
local stopTweenBtn = createButton("Stop Tween")
local instantProxBtn = createButton("Enable Instant Proximity")
local useProximityBtn = createButton("Use Proximities")
local pos1Label = createLabel()
local pos2Label = createLabel()

-- Utility
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

local function updateLabels()
	pos1Label.Text = pos1 and ("Position 1: " .. tostring(pos1)) or "Position 1: [Not Set]"
	pos2Label.Text = pos2 and ("Position 2: " .. tostring(pos2)) or "Position 2: [Not Set]"
end

-- Actions
savePos1Btn.MouseButton1Click:Connect(function()
	pos1 = getHRP().Position
	updateLabels()
end)

savePos2Btn.MouseButton1Click:Connect(function()
	pos2 = getHRP().Position
	updateLabels()
end)

enableTweenBtn.MouseButton1Click:Connect(function()
	if not (pos1 and pos2) then
		warn("Save both positions first.")
		return
	end
	if tweening then return end
	tweening = true
	while tweening do
		TweenService:Create(getHRP(), TweenInfo.new(1.5), {Position = pos1}):Play()
		task.wait(1.6)
		if not tweening then break end
		TweenService:Create(getHRP(), TweenInfo.new(1.5), {Position = pos2}):Play()
		task.wait(1.6)
	end
end)

stopTweenBtn.MouseButton1Click:Connect(function()
	tweening = false
	if currentTween then currentTween:Cancel() end
end)

instantProxBtn.MouseButton1Click:Connect(function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			obj.HoldDuration = 0
		end
	end
	print("All proximity prompts set to instant.")
end)

useProximityBtn.MouseButton1Click:Connect(function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			local dist = (obj.Parent.Position - getHRP().Position).Magnitude
			if dist <= obj.MaxActivationDistance then
				obj:InputHoldBegin(Enum.UserInputType.Keyboard)
				task.wait(0.05)
				obj:InputHoldEnd(Enum.UserInputType.Keyboard)
			end
		end
	end
	print("Triggered proximity prompts.")
end)

closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- On respawn
player.CharacterAdded:Connect(function()
	tweening = false
	if currentTween then currentTween:Cancel() end
	task.wait(1)
	updateLabels()
end)

-- Initial label update
updateLabels()
