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
local selectedMobs = {}
local currentTarget = nil
local followEnabled = false
local followConnection = nil
local draggingSlider = false
local mobCache = {} -- Cache for faster lookups

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
-- BUILD MOB CACHE
-------------------------------------------------------
local function rebuildMobCache()
	mobCache = {}
	
	-- Only cache selected mob types
	for _, mobName in ipairs(selectedMobs) do
		mobCache[mobName] = {}
	end
	
	-- Find mobs folder (adjust path if needed)
	local mobsFolder = workspace:FindFirstChild("Mobs ")
	if not mobsFolder then return end
	
	for _, area in ipairs(mobsFolder:GetChildren()) do
		for _, mob in ipairs(area:GetChildren()) do
			if table.find(selectedMobs, mob.Name) then
				local humanoid = mob:FindFirstChildOfClass("Humanoid")
				local root = mob:FindFirstChild("HumanoidRootPart")
				
				if humanoid and root then
					if not mobCache[mob.Name] then
						mobCache[mob.Name] = {}
					end
					table.insert(mobCache[mob.Name], {
						model = mob,
						humanoid = humanoid,
						root = root
					})
				end
			end
		end
	end
end

-------------------------------------------------------
-- FIND NEAREST ALIVE MOB (OPTIMIZED)
-------------------------------------------------------
local function findNearestAliveMob()
	if #selectedMobs == 0 or not hrp or not hrp.Parent then return nil end
	
	local nearestMob = nil
	local shortestDistance = math.huge
	local playerPos = hrp.Position
	
	for mobName, mobs in pairs(mobCache) do
		for i = #mobs, 1, -1 do -- Iterate backwards for safe removal
			local mobData = mobs[i]
			
			-- Check if mob still exists and is valid
			if not mobData.model.Parent or not mobData.humanoid.Parent then
				table.remove(mobs, i) -- Remove from cache
			elseif mobData.humanoid.Health > 0 then
				local distance = (playerPos - mobData.root.Position).Magnitude
				if distance < shortestDistance then
					shortestDistance = distance
					nearestMob = mobData.model
				end
			else
				-- Mob is dead, remove from cache
				table.remove(mobs, i)
			end
		end
	end
	
	return nearestMob
end

-------------------------------------------------------
-- FOLLOW LOGIC
-------------------------------------------------------
local lastTargetCheck = 0
local TARGET_CHECK_INTERVAL = 0.5 -- Check for new target every 0.5 seconds

function startFollow()
	if followConnection then followConnection:Disconnect() end
	
	rebuildMobCache() -- Build cache when starting
	currentTarget = findNearestAliveMob()

	followConnection = RunService.Heartbeat:Connect(function()
		if not followEnabled or not character or not character.Parent or not hrp or not hrp.Parent then
			return
		end
		
		-- Check if current target is still valid (lightweight check)
		if currentTarget and currentTarget.Parent then
			local humanoid = currentTarget:FindFirstChildOfClass("Humanoid")
			if humanoid and humanoid.Health > 0 then
				-- Target is good, follow it
				local root = currentTarget:FindFirstChild("HumanoidRootPart")
				if root then
					local behindPos =
						root.Position
						- (root.CFrame.LookVector * FOLLOW_DISTANCE)
						+ Vector3.new(0, HEIGHT_OFFSET, 0)

					hrp.CFrame = CFrame.lookAt(behindPos, root.Position)
				end
				return -- Don't search for new target
			end
		end
		
		-- Only search for new target periodically, not every frame
		local currentTime = tick()
		if currentTime - lastTargetCheck >= TARGET_CHECK_INTERVAL then
			lastTargetCheck = currentTime
			currentTarget = findNearestAliveMob()
		end
	end)
end

function stopFollow()
	if followConnection then
		followConnection:Disconnect()
		followConnection = nil
	end
	currentTarget = nil
	mobCache = {}
end

-------------------------------------------------------
-- GUI
-------------------------------------------------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(330, 570)
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
-- CLEAR SELECTION BUTTON
-------------------------------------------------------
local clearBtn = Instance.new("TextButton", frame)
clearBtn.Size = UDim2.new(0.48, -5, 0, 30)
clearBtn.Position = UDim2.fromOffset(5, 50)
clearBtn.Text = "Clear All"
clearBtn.BackgroundColor3 = Color3.fromRGB(140,40,40)
clearBtn.TextColor3 = Color3.new(1,1,1)

clearBtn.MouseButton1Click:Connect(function()
	selectedMobs = {}
	currentTarget = nil
	mobCache = {}
	
	-- Update all button colors
	for _, btn in ipairs(mobButtons) do
		btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	end
	
	updateCount()
end)

-------------------------------------------------------
-- SELECTED COUNT LABEL
-------------------------------------------------------
local countLabel = Instance.new("TextLabel", frame)
countLabel.Size = UDim2.new(0.48, -5, 0, 30)
countLabel.Position = UDim2.new(0.5, 5, 0, 50)
countLabel.Text = "Selected: 0"
countLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
countLabel.TextColor3 = Color3.new(1,1,1)

-------------------------------------------------------
-- DISTANCE SLIDER
-------------------------------------------------------
local sliderLabel = Instance.new("TextLabel", frame)
sliderLabel.Size = UDim2.new(1, -10, 0, 20)
sliderLabel.Position = UDim2.fromOffset(5, 90)
sliderLabel.Text = ("Distance: %.1f"):format(FOLLOW_DISTANCE)
sliderLabel.BackgroundTransparency = 1
sliderLabel.TextColor3 = Color3.new(1,1,1)
sliderLabel.TextXAlignment = Enum.TextXAlignment.Left

local sliderBar = Instance.new("Frame", frame)
sliderBar.Size = UDim2.new(1, -20, 0, 6)
sliderBar.Position = UDim2.fromOffset(10, 115)
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
-- SEARCH BAR
-------------------------------------------------------
local searchBox = Instance.new("TextBox", frame)
searchBox.Size = UDim2.new(1, -10, 0, 30)
searchBox.Position = UDim2.fromOffset(5, 130)
searchBox.PlaceholderText = "Search mob..."
searchBox.Text = ""
searchBox.BackgroundColor3 = Color3.fromRGB(40,40,40)
searchBox.TextColor3 = Color3.new(1,1,1)
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false

local searchPadding = Instance.new("UIPadding", searchBox)
searchPadding.PaddingLeft = UDim.new(0, 8)

-------------------------------------------------------
-- MOB LIST
-------------------------------------------------------
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.fromOffset(5, 170)
scroll.Size = UDim2.new(1, -10, 1, -175)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 0.3
scroll.BackgroundColor3 = Color3.fromRGB(30,30,30)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 4)

mobButtons = {}

-------------------------------------------------------
-- UPDATE SELECTED COUNT
-------------------------------------------------------
local function updateCount()
	countLabel.Text = "Selected: "..#selectedMobs
end

for _, name in ipairs(mobNames) do
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -5, 0, 30)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Parent = scroll
	btn.Name = name
	
	table.insert(mobButtons, btn)

	btn.MouseButton1Click:Connect(function()
		-- Toggle selection
		if table.find(selectedMobs, name) then
			-- Deselect
			local index = table.find(selectedMobs, name)
			table.remove(selectedMobs, index)
			btn.BackgroundColor3 = Color3.fromRGB(45,45,45)
		else
			-- Select
			table.insert(selectedMobs, name)
			btn.BackgroundColor3 = Color3.fromRGB(60,120,60)
		end
		
		updateCount()
		
		-- Rebuild cache with new selection
		if followEnabled then
			rebuildMobCache()
			currentTarget = findNearestAliveMob()
		end
	end)
end

-------------------------------------------------------
-- SEARCH FUNCTIONALITY
-------------------------------------------------------
local function updateSearch(query)
	query = query:lower()
	
	for _, btn in ipairs(mobButtons) do
		if query == "" or btn.Name:lower():find(query, 1, true) then
			btn.Visible = true
		else
			btn.Visible = false
		end
	end
	
	task.wait()
	scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	updateSearch(searchBox.Text)
end)

task.wait()
scroll.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
