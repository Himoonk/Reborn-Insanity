-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

-- PLAYER
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- SETTINGS
local FOLLOW_DISTANCE = 2.5
local MIN_DISTANCE = 1
local MAX_DISTANCE = 8
local HEIGHT_OFFSET = 0

-- STATE
local selectedMob = nil
local followEnabled = false
local followConnection = nil
local draggingSlider = false

-------------------------------------------------------
-- CHARACTER RESPAWN HANDLER
-------------------------------------------------------
local function onCharacterAdded(newCharacter)
	character = newCharacter
	hrp = character:WaitForChild("HumanoidRootPart")
	
	-- Restart follow if it was enabled
	if followEnabled then
		stopFollow()
		startFollow()
	end
end

player.CharacterAdded:Connect(onCharacterAdded)

-------------------------------------------------------
-- AUTO SCAN MOBS
-------------------------------------------------------
local mobNames = {}
local seen = {}

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
		if not seen[obj.Name] then
			seen[obj.Name] = true
			table.insert(mobNames, obj.Name)
		end
	end
end

table.sort(mobNames)

-------------------------------------------------------
-- FIND MOB
-------------------------------------------------------
local function findMob(name)
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Model")
		and obj.Name == name
		and obj:FindFirstChild("HumanoidRootPart")
		and obj:FindFirstChildOfClass("Humanoid") then
			return obj
		end
	end
end

-------------------------------------------------------
-- FOLLOW LOGIC
-------------------------------------------------------
function startFollow()
	if followConnection then followConnection:Disconnect() end

	followConnection = RunService.Heartbeat:Connect(function()
		if followEnabled and selectedMob and selectedMob.Parent and character and character.Parent then
			local root = selectedMob:FindFirstChild("HumanoidRootPart")
			if root and hrp and hrp.Parent then
				local behindPos =
					root.Position
					- (root.CFrame.LookVector * FOLLOW_DISTANCE)
					+ Vector3.new(0, HEIGHT_OFFSET, 0)

				hrp.CFrame = CFrame.lookAt(behindPos, root.Position)
			end
		end
	end)
end

function stopFollow()
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
end

-------------------------------------------------------
-- GUI
-------------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(330, 480)
frame.Position = UDim2.fromScale(0.02, 0.25)
frame.BackgroundColor3 = Color3.fromRGB(20,20,20)

-------------------------------------------------------
-- CUSTOM DRAG (SLIDER SAFE)
-------------------------------------------------------
local draggingFrame = false
local dragStart
local frameStartPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingFrame = true
		dragStart = input.Position
		frameStartPos = frame.Position
	end
end)

frame.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingFrame = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if draggingFrame and not draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			frameStartPos.X.Scale,
			frameStartPos.X.Offset + delta.X,
			frameStartPos.Y.Scale,
			frameStartPos.Y.Offset + delta.Y
		)
	end
end)

-------------------------------------------------------
-- TOGGLE BUTTON
-------------------------------------------------------
local toggle = Instance.new("TextButton", frame)
toggle.Size = UDim2.new(1, -10, 0, 40)
toggle.Position = UDim2.fromOffset(5, 5)
toggle.Text = "TP BEHIND: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(140,40,40)
toggle.TextColor3 = Color3.new(1,1,1)

toggle.MouseButton1Click:Connect(function()
	followEnabled = not followEnabled

	if followEnabled then
		toggle.Text = "TP BEHIND: ON"
		toggle.BackgroundColor3 = Color3.fromRGB(40,140,40)
		startFollow()
	else
		toggle.Text = "TP BEHIND: OFF"
		toggle.BackgroundColor3 = Color3.fromRGB(140,40,40)
		stopFollow()
	end
end)

-------------------------------------------------------
-- DISTANCE SLIDER
-------------------------------------------------------
local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(1, -10, 0, 20)
sliderLabel.Position = UDim2.fromOffset(5, 50)
sliderLabel.Text = ("Distance: %.1f"):format(FOLLOW_DISTANCE)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local sliderBar = Instance.new("Frame", frame)
sliderBar.Size = UDim2.new(1, -20, 0, 6)
sliderBar.Position = UDim2.fromOffset(10, 75)
sliderBar.BackgroundColor3 = Color3.fromRGB(70,70,70)

local sliderKnob = Instance.new("Frame", sliderBar)
sliderKnob.Size = UDim2.fromOffset(14, 14)
sliderKnob.AnchorPoint = Vector2.new(0.5, 0.5)
sliderKnob.Position = UDim2.fromScale(
	(FOLLOW_DISTANCE - MIN_DISTANCE) / (MAX_DISTANCE - MIN_DISTANCE),
	0.5
)
sliderKnob.BackgroundColor3 = Color3.fromRGB(200,200,200)
sliderKnob.BorderSizePixel = 0
Instance.new("UICorner", sliderKnob).CornerRadius = UDim.new(1,0)

sliderKnob.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = true
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		draggingSlider = false
	end
end)

UIS.InputChanged:Connect(function(input)
	if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
		local percent = math.clamp(
			(input.Position.X - sliderBar.AbsolutePosition.X)
			/ sliderBar.AbsoluteSize.X,
			0, 1
		)

		FOLLOW_DISTANCE =
			MIN_DISTANCE + (MAX_DISTANCE - MIN_DISTANCE) * percent

		sliderKnob.Position = UDim2.fromScale(percent, 0.5)
		sliderLabel.Text = ("Distance: %.1f"):format(FOLLOW_DISTANCE)
	end
end)

-------------------------------------------------------
-- MOB LIST
-------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.fromOffset(5, 100)
scroll.Size = UDim2.new(1, -10, 1, -105)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 0.3

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)

for _, name in ipairs(mobNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -5, 0, 30)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = scroll

	btn.MouseButton1Click:Connect(function()
		local mob = findMob(name)
		if mob then
			selectedMob = mob
		end
	end)
end

task.wait()
scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
