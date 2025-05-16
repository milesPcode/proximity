-- LocalScript — put this in StarterPlayerScripts

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

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 260, 0, 450)
mainFrame.Position = UDim2.new(0, 20, 0, 100)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
mainFrame.BorderSizePixel = 2
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 8)

local padding = Instance.new("UIPadding", mainFrame)
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)

-- UIListLayout for vertical stacking
local layout = Instance.new("UIListLayout", mainFrame)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Close button (top-right)
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 24, 0, 24)
closeButton.Position = UDim2.new(1, -28, 0, 4)
closeButton.AnchorPoint = Vector2.new(0.5, 0)
closeButton.Text = "X"
closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.SourceSansBold
closeButton.TextSize = 16
closeButton.AutoButtonColor = false
closeButton.Parent = mainFrame

closeButton.MouseEnter:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
end)
closeButton.MouseLeave:Connect(function()
	closeButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
end)
closeButton.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

-- Utility: Button creation
local function createButton(text)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1, 0, 0, 36)
	button.SizeConstraint = Enum.SizeConstraint.RelativeXY
	button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	button.Text = text
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.AutoButtonColor = false
	button.TextScaled = false
	button.TextWrapped = true
	button.ClipsDescendants = true

	-- Optional: hover color change only
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	end)

	button.Parent = mainFrame
	return button
end

-- Utility: Label creation
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

-- UI Elements
local savePos1Btn = createButton("Save Position 1")
local savePos2Btn = createButton("Save Position 2")
local enableTweenBtn = createButton("Enable Tween")
local stopTweenBtn = createButton("Stop Tween")
local instantProxBtn = createButton("Enable Instant Proximity")
local useProximityBtn = createButton("Use Proximities")

local pos1Label = createLabel()
local pos2Label = createLabel()

-- Get player HRP
local function getHRP()
	local char = player.Character or player.CharacterAdded:Wait()
	return char:WaitForChild("HumanoidRootPart")
end

-- Update labels
local function updateLabels()
	pos1Label.Text = pos1 and ("Position 1: " .. tostring(pos1)) or "Position 1: [Not Set]"
	pos2Label.Text = pos2 and ("Position 2: " .. tostring(pos2)) or "Position 2: [Not Set]"
end

-- Button actions
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
		warn("Set both positions first.")
		return
	end
	if tweening then return end
	tweening = true
	while tweening do
		local tween1 = TweenService:Create(getHRP(), TweenInfo.new(1.5), {Position = pos1})
		tween1:Play()
		tween1.Completed:Wait()
		if not tweening then break end
		local tween2 = TweenService:Create(getHRP(), TweenInfo.new(1.5), {Position = pos2})
		tween2:Play()
		tween2.Completed:Wait()
	end
end)

stopTweenBtn.MouseButton1Click:Connect(function()
	tweening = false
end)

instantProxBtn.MouseButton1Click:Connect(function()
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			obj.HoldDuration = 0
		end
	end
	print("Instant Proximity Prompts Enabled.")
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
	print("Proximity Prompts Triggered.")
end)

-- On respawn
player.CharacterAdded:Connect(function()
	tweening = false
	task.wait(1)
	updateLabels()
end)

-- Initial label update
updateLabels()
