-- Complete Race Roller + Spirit Root Roller Script (DUAL GUI)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== REDEEM CODES FIRST =====
print("Redeeming codes...")
local codes = {
    "MINING",
    "WELCOME",
    "ROOTPOWER",
    "RACERUSH",
    "TRADING",
    "SECT"
}

for _, code in ipairs(codes) do
    local args = {code}
    local success = pcall(function()
        ReplicatedStorage:WaitForChild("Events"):WaitForChild("EnterCode"):FireServer(unpack(args))
    end)
    if success then
        print("Redeemed code:", code)
    else
        warn("Failed to redeem code:", code)
    end
    wait(0.5)
end
print("Code redemption complete!")

-- ===== RACE AUTO-ROLLER GUI =====

-- Race data with colors
local raceData = {
	{name = "Human", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "Beastkin", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "Spiritfolk", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "Stoneborn", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "Dragonblood", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "Celestial", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "Titanborn", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "Shadowspawn", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "Phoenix", rarity = "Legendary", color = Color3.fromRGB(255, 200, 50)},
	{name = "Voidwalker", rarity = "Legendary", color = Color3.fromRGB(255, 200, 50)},
	{name = "Dragon God", rarity = "Mythic", color = Color3.fromRGB(255, 50, 50)},
	{name = "Celestial Spirit", rarity = "Mythic", color = Color3.fromRGB(255, 50, 50)},
}

-- Auto-roll settings
local autoRollEnabled = false
local selectedSlot = 1
local selectedRaces = {} -- Table to hold selected races
local rollCount = 0

-- Function to get current race from GUI (FIXED PATH!)
local function getCurrentRace()
	local success, race = pcall(function()
		return player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Menu"):WaitForChild("Frame"):WaitForChild("RaceFrame"):WaitForChild("Race"):WaitForChild("txt").Text
	end)
	if success and race then
		return race
	else
		return nil
	end
end

-- Create GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RaceRollerGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 550)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 10)
uiCorner.Parent = mainFrame

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "Race Auto-Roller"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 20
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

-- Slot Selection
local slotLabel = Instance.new("TextLabel")
slotLabel.Size = UDim2.new(1, -20, 0, 25)
slotLabel.Position = UDim2.new(0, 10, 0, 50)
slotLabel.BackgroundTransparency = 1
slotLabel.Text = "Select Slot:"
slotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
slotLabel.TextSize = 16
slotLabel.Font = Enum.Font.Gotham
slotLabel.TextXAlignment = Enum.TextXAlignment.Left
slotLabel.Parent = mainFrame

local slotButtonsFrame = Instance.new("Frame")
slotButtonsFrame.Size = UDim2.new(1, -20, 0, 35)
slotButtonsFrame.Position = UDim2.new(0, 10, 0, 75)
slotButtonsFrame.BackgroundTransparency = 1
slotButtonsFrame.Parent = mainFrame

for i = 1, 3 do
	local slotButton = Instance.new("TextButton")
	slotButton.Name = "Slot" .. i
	slotButton.Size = UDim2.new(0.3, -5, 1, 0)
	slotButton.Position = UDim2.new((i-1) * 0.33, 0, 0, 0)
	slotButton.BackgroundColor3 = i == 1 and Color3.fromRGB(50, 150, 50) or Color3.fromRGB(60, 60, 65)
	slotButton.Text = "Slot " .. i
	slotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	slotButton.TextSize = 14
	slotButton.Font = Enum.Font.GothamBold
	slotButton.Parent = slotButtonsFrame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = slotButton
	
	slotButton.MouseButton1Click:Connect(function()
		selectedSlot = i
		for _, btn in pairs(slotButtonsFrame:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
			end
		end
		slotButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
	end)
end

-- Race Selection Label
local raceLabel = Instance.new("TextLabel")
raceLabel.Size = UDim2.new(1, -20, 0, 25)
raceLabel.Position = UDim2.new(0, 10, 0, 120)
raceLabel.BackgroundTransparency = 1
raceLabel.Text = "Select Races to Stop On (multi-select):"
raceLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
raceLabel.TextSize = 16
raceLabel.Font = Enum.Font.Gotham
raceLabel.TextXAlignment = Enum.TextXAlignment.Left
raceLabel.Parent = mainFrame

-- Scrolling Frame for Race Buttons
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 300)
scrollFrame.Position = UDim2.new(0, 10, 0, 150)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
scrollFrame.BorderSizePixel = 0
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = mainFrame

local scrollCorner = Instance.new("UICorner")
scrollCorner.CornerRadius = UDim.new(0, 8)
scrollCorner.Parent = scrollFrame

-- Create Race Buttons
local raceButtons = {}
for i, race in ipairs(raceData) do
	local raceButton = Instance.new("TextButton")
	raceButton.Name = race.name
	raceButton.Size = UDim2.new(0.48, -5, 0, 35)
	raceButton.Position = UDim2.new(((i-1) % 2) * 0.5, 5, math.floor((i-1) / 2) * 0.135, 5)
	raceButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
	raceButton.Text = race.name .. " (" .. race.rarity .. ")"
	raceButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	raceButton.TextSize = 12
	raceButton.Font = Enum.Font.GothamBold
	raceButton.Parent = scrollFrame
	
	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = raceButton
	
	-- Checkmark indicator
	local checkmark = Instance.new("TextLabel")
	checkmark.Name = "Checkmark"
	checkmark.Size = UDim2.new(0, 20, 0, 20)
	checkmark.Position = UDim2.new(1, -25, 0.5, -10)
	checkmark.BackgroundTransparency = 1
	checkmark.Text = "✓"
	checkmark.TextColor3 = Color3.fromRGB(50, 255, 50)
	checkmark.TextSize = 18
	checkmark.Font = Enum.Font.GothamBold
	checkmark.Visible = false
	checkmark.Parent = raceButton
	
	raceButtons[race.name] = {button = raceButton, checkmark = checkmark, data = race}
	
	raceButton.MouseButton1Click:Connect(function()
		if selectedRaces[race.name] then
			-- Deselect
			selectedRaces[race.name] = nil
			raceButton.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
			checkmark.Visible = false
			print("Deselected:", race.name)
		else
			-- Select
			selectedRaces[race.name] = true
			raceButton.BackgroundColor3 = race.color
			checkmark.Visible = true
			print("Selected:", race.name)
		end
	end)
end

-- Update scroll frame canvas size
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#raceData / 2) * 40 + 10)

-- Status Label
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "Status"
statusLabel.Size = UDim2.new(1, -20, 0, 35)
statusLabel.Position = UDim2.new(0, 10, 0, 460)
statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
statusLabel.Text = "Status: Idle (Codes Redeemed!)"
statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 8)
statusCorner.Parent = statusLabel

-- Start/Stop Button
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(1, -20, 0, 45)
toggleButton.Position = UDim2.new(0, 10, 0, 500)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
toggleButton.Text = "START AUTO-ROLL"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 16
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- Function to normalize race name (remove spaces, lowercase)
local function normalizeName(name)
	return name:lower():gsub("%s+", "")
end

-- Function to check if current race is in selected races
local function isDesiredRace(raceName)
	print("Checking race:", '"' .. raceName .. '"')
	
	-- Normalize the current race name
	local normalizedCurrent = normalizeName(raceName)
	
	-- Check each selected race
	for selectedRace, _ in pairs(selectedRaces) do
		local normalizedSelected = normalizeName(selectedRace)
		
		if normalizedCurrent == normalizedSelected then
			print("✓ MATCH FOUND:", raceName)
			return true
		end
	end
	
	return false
end

-- Auto-roll function
local function autoRoll()
	while autoRollEnabled do
		rollCount = rollCount + 1
		
		-- Count selected races
		local selectedCount = 0
		for _ in pairs(selectedRaces) do
			selectedCount = selectedCount + 1
		end
		
		statusLabel.Text = "Rolling... (Attempt #" .. rollCount .. " | " .. selectedCount .. " selected)"
		
		-- Roll the race
		local args = {selectedSlot, false}
		ReplicatedStorage:WaitForChild("Events"):WaitForChild("RollRace"):FireServer(unpack(args))
		
		wait(2) -- Wait for roll to complete and GUI to update
		
		-- Get current race from GUI
		local currentRace = getCurrentRace()
		
		if currentRace then
			print("Rolled:", currentRace)
			
			if isDesiredRace(currentRace) then
				autoRollEnabled = false
				toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
				toggleButton.Text = "START AUTO-ROLL"
				
				-- Find race color
				local raceColor = Color3.fromRGB(50, 255, 50)
				for _, race in ipairs(raceData) do
					if normalizeName(race.name) == normalizeName(currentRace) then
						raceColor = race.color
						break
					end
				end
				
				statusLabel.Text = "SUCCESS! Got " .. currentRace .. "!"
				statusLabel.BackgroundColor3 = raceColor
				print("🎉 AUTO-ROLLER STOPPED - Got desired race:", currentRace)
				break
			end
		else
			warn("⚠️ Could not read race from GUI!")
		end
		
		wait(0.5) -- Delay between rolls
	end
end

-- Toggle button click
toggleButton.MouseButton1Click:Connect(function()
	-- Check if at least one race is selected
	local hasSelection = false
	for _ in pairs(selectedRaces) do
		hasSelection = true
		break
	end
	
	if not hasSelection and not autoRollEnabled then
		statusLabel.Text = "ERROR: Please select at least one race!"
		statusLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		wait(2)
		statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		statusLabel.Text = "Status: Idle"
		return
	end
	
	autoRollEnabled = not autoRollEnabled
	
	if autoRollEnabled then
		toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		toggleButton.Text = "STOP AUTO-ROLL"
		rollCount = 0
		statusLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
		
		print("=== AUTO-ROLLER STARTED ===")
		print("Selected races:")
		for race, _ in pairs(selectedRaces) do
			print("-", race)
		end
		print("Target slot:", selectedSlot)
		
		autoRoll()
	else
		toggleButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
		toggleButton.Text = "START AUTO-ROLL"
		statusLabel.Text = "Status: Stopped by user"
		print("=== AUTO-ROLLER STOPPED BY USER ===")
	end
end)

-- Make frame draggable
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

mainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

mainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

print("Race Auto-Roller GUI loaded successfully!")

-- ========================================
-- ===== SPIRIT ROOT AUTO-ROLLER GUI =====
-- ========================================

-- Spirit Root data with colors
local spiritRootData = {
	{name = "MortalRoot", displayName = "Mortal Spirit Root", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "CommonRoot", displayName = "Common Spirit Root", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "WoodRoot", displayName = "Wood Spirit Root", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "FireRoot", displayName = "Fire Spirit Root", rarity = "Rare", color = Color3.fromRGB(100, 150, 255)},
	{name = "HeavenlyRoot", displayName = "Heavenly Spirit Root", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "EarthRoot", displayName = "Earth Spirit Root", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "ThunderRoot", displayName = "Thunder Spirit Root", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "YinYangRoot", displayName = "Yin-Yang Spirit Root", rarity = "Epic", color = Color3.fromRGB(150, 100, 255)},
	{name = "VoidRoot", displayName = "Void Spirit Root", rarity = "Legendary", color = Color3.fromRGB(255, 200, 50)},
	{name = "DragonVeinRoot", displayName = "Dragon Vein Root", rarity = "Legendary", color = Color3.fromRGB(255, 200, 50)},
	{name = "ImmortalRoot", displayName = "Immortal Spirit Root", rarity = "Mythic", color = Color3.fromRGB(255, 50, 50)},
	{name = "CelestialDaoRoot", displayName = "Celestial Dao Root", rarity = "Mythic", color = Color3.fromRGB(255, 50, 50)},
	{name = "PrimordialChaosRoot", displayName = "Primordial Chaos Root", rarity = "Secret", color = Color3.fromRGB(255, 0, 255)},
}

-- Spirit Root Auto-roll settings
local spiritAutoRollEnabled = false
local spiritSelectedSlot = 1
local selectedSpiritRoots = {}
local spiritRollCount = 0

-- Function to get current spirit root from GUI
local function getCurrentSpiritRoot()
	local success, root = pcall(function()
		return player.PlayerGui:WaitForChild("ScreenGui"):WaitForChild("Menu"):WaitForChild("Frame"):WaitForChild("SpiritRootFrame"):WaitForChild("SpiritRoot"):WaitForChild("txt").Text
	end)
	if success and root then
		return root
	else
		return nil
	end
end

-- Create Spirit Root GUI
local spiritScreenGui = Instance.new("ScreenGui")
spiritScreenGui.Name = "SpiritRootRollerGui"
spiritScreenGui.ResetOnSpawn = false
spiritScreenGui.Parent = playerGui

local spiritMainFrame = Instance.new("Frame")
spiritMainFrame.Name = "SpiritMainFrame"
spiritMainFrame.Size = UDim2.new(0, 380, 0, 550)
spiritMainFrame.Position = UDim2.new(0.5, 200, 0.5, -275) -- Positioned to the right of race GUI
spiritMainFrame.BackgroundColor3 = Color3.fromRGB(35, 25, 40)
spiritMainFrame.BorderSizePixel = 0
spiritMainFrame.Parent = spiritScreenGui

local spiritUiCorner = Instance.new("UICorner")
spiritUiCorner.CornerRadius = UDim.new(0, 10)
spiritUiCorner.Parent = spiritMainFrame

-- Spirit Root Title
local spiritTitleLabel = Instance.new("TextLabel")
spiritTitleLabel.Name = "Title"
spiritTitleLabel.Size = UDim2.new(1, 0, 0, 40)
spiritTitleLabel.BackgroundColor3 = Color3.fromRGB(50, 35, 60)
spiritTitleLabel.BorderSizePixel = 0
spiritTitleLabel.Text = "Spirit Root Auto-Roller"
spiritTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spiritTitleLabel.TextSize = 20
spiritTitleLabel.Font = Enum.Font.GothamBold
spiritTitleLabel.Parent = spiritMainFrame

local spiritTitleCorner = Instance.new("UICorner")
spiritTitleCorner.CornerRadius = UDim.new(0, 10)
spiritTitleCorner.Parent = spiritTitleLabel

-- Spirit Slot Selection
local spiritSlotLabel = Instance.new("TextLabel")
spiritSlotLabel.Size = UDim2.new(1, -20, 0, 25)
spiritSlotLabel.Position = UDim2.new(0, 10, 0, 50)
spiritSlotLabel.BackgroundTransparency = 1
spiritSlotLabel.Text = "Select Slot:"
spiritSlotLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spiritSlotLabel.TextSize = 16
spiritSlotLabel.Font = Enum.Font.Gotham
spiritSlotLabel.TextXAlignment = Enum.TextXAlignment.Left
spiritSlotLabel.Parent = spiritMainFrame

local spiritSlotButtonsFrame = Instance.new("Frame")
spiritSlotButtonsFrame.Size = UDim2.new(1, -20, 0, 35)
spiritSlotButtonsFrame.Position = UDim2.new(0, 10, 0, 75)
spiritSlotButtonsFrame.BackgroundTransparency = 1
spiritSlotButtonsFrame.Parent = spiritMainFrame

for i = 1, 3 do
	local spiritSlotButton = Instance.new("TextButton")
	spiritSlotButton.Name = "SpiritSlot" .. i
	spiritSlotButton.Size = UDim2.new(0.3, -5, 1, 0)
	spiritSlotButton.Position = UDim2.new((i-1) * 0.33, 0, 0, 0)
	spiritSlotButton.BackgroundColor3 = i == 1 and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(60, 50, 70)
	spiritSlotButton.Text = "Slot " .. i
	spiritSlotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	spiritSlotButton.TextSize = 14
	spiritSlotButton.Font = Enum.Font.GothamBold
	spiritSlotButton.Parent = spiritSlotButtonsFrame
	
	local spiritBtnCorner = Instance.new("UICorner")
	spiritBtnCorner.CornerRadius = UDim.new(0, 8)
	spiritBtnCorner.Parent = spiritSlotButton
	
	spiritSlotButton.MouseButton1Click:Connect(function()
		spiritSelectedSlot = i
		for _, btn in pairs(spiritSlotButtonsFrame:GetChildren()) do
			if btn:IsA("TextButton") then
				btn.BackgroundColor3 = Color3.fromRGB(60, 50, 70)
			end
		end
		spiritSlotButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
	end)
end

-- Spirit Root Selection Label
local spiritRootLabel = Instance.new("TextLabel")
spiritRootLabel.Size = UDim2.new(1, -20, 0, 25)
spiritRootLabel.Position = UDim2.new(0, 10, 0, 120)
spiritRootLabel.BackgroundTransparency = 1
spiritRootLabel.Text = "Select Spirit Roots to Stop On:"
spiritRootLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spiritRootLabel.TextSize = 16
spiritRootLabel.Font = Enum.Font.Gotham
spiritRootLabel.TextXAlignment = Enum.TextXAlignment.Left
spiritRootLabel.Parent = spiritMainFrame

-- Scrolling Frame for Spirit Root Buttons
local spiritScrollFrame = Instance.new("ScrollingFrame")
spiritScrollFrame.Size = UDim2.new(1, -20, 0, 300)
spiritScrollFrame.Position = UDim2.new(0, 10, 0, 150)
spiritScrollFrame.BackgroundColor3 = Color3.fromRGB(45, 35, 50)
spiritScrollFrame.BorderSizePixel = 0
spiritScrollFrame.ScrollBarThickness = 6
spiritScrollFrame.Parent = spiritMainFrame

local spiritScrollCorner = Instance.new("UICorner")
spiritScrollCorner.CornerRadius = UDim.new(0, 8)
spiritScrollCorner.Parent = spiritScrollFrame

-- Create Spirit Root Buttons
local spiritRootButtons = {}
for i, root in ipairs(spiritRootData) do
	local spiritRootButton = Instance.new("TextButton")
	spiritRootButton.Name = root.name
	spiritRootButton.Size = UDim2.new(0.48, -5, 0, 35)
	spiritRootButton.Position = UDim2.new(((i-1) % 2) * 0.5, 5, math.floor((i-1) / 2) * 0.11, 5)
	spiritRootButton.BackgroundColor3 = Color3.fromRGB(60, 50, 70)
	spiritRootButton.Text = root.displayName .. " (" .. root.rarity .. ")"
	spiritRootButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	spiritRootButton.TextSize = 11
	spiritRootButton.Font = Enum.Font.GothamBold
	spiritRootButton.Parent = spiritScrollFrame
	
	local spiritBtnCorner = Instance.new("UICorner")
	spiritBtnCorner.CornerRadius = UDim.new(0, 8)
	spiritBtnCorner.Parent = spiritRootButton
	
	-- Checkmark indicator
	local spiritCheckmark = Instance.new("TextLabel")
	spiritCheckmark.Name = "Checkmark"
	spiritCheckmark.Size = UDim2.new(0, 20, 0, 20)
	spiritCheckmark.Position = UDim2.new(1, -25, 0.5, -10)
	spiritCheckmark.BackgroundTransparency = 1
	spiritCheckmark.Text = "✓"
	spiritCheckmark.TextColor3 = Color3.fromRGB(150, 50, 255)
	spiritCheckmark.TextSize = 18
	spiritCheckmark.Font = Enum.Font.GothamBold
	spiritCheckmark.Visible = false
	spiritCheckmark.Parent = spiritRootButton
	
	spiritRootButtons[root.name] = {button = spiritRootButton, checkmark = spiritCheckmark, data = root}
	
	spiritRootButton.MouseButton1Click:Connect(function()
		if selectedSpiritRoots[root.name] then
			-- Deselect
			selectedSpiritRoots[root.name] = nil
			spiritRootButton.BackgroundColor3 = Color3.fromRGB(60, 50, 70)
			spiritCheckmark.Visible = false
			print("Deselected Spirit Root:", root.displayName)
		else
			-- Select
			selectedSpiritRoots[root.name] = true
			spiritRootButton.BackgroundColor3 = root.color
			spiritCheckmark.Visible = true
			print("Selected Spirit Root:", root.displayName)
		end
	end)
end

-- Update spirit scroll frame canvas size
spiritScrollFrame.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#spiritRootData / 2) * 40 + 10)

-- Spirit Status Label
local spiritStatusLabel = Instance.new("TextLabel")
spiritStatusLabel.Name = "SpiritStatus"
spiritStatusLabel.Size = UDim2.new(1, -20, 0, 35)
spiritStatusLabel.Position = UDim2.new(0, 10, 0, 460)
spiritStatusLabel.BackgroundColor3 = Color3.fromRGB(45, 35, 50)
spiritStatusLabel.Text = "Status: Idle"
spiritStatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
spiritStatusLabel.TextSize = 13
spiritStatusLabel.Font = Enum.Font.Gotham
spiritStatusLabel.Parent = spiritMainFrame

local spiritStatusCorner = Instance.new("UICorner")
spiritStatusCorner.CornerRadius = UDim.new(0, 8)
spiritStatusCorner.Parent = spiritStatusLabel

-- Spirit Start/Stop Button
local spiritToggleButton = Instance.new("TextButton")
spiritToggleButton.Name = "SpiritToggleButton"
spiritToggleButton.Size = UDim2.new(1, -20, 0, 45)
spiritToggleButton.Position = UDim2.new(0, 10, 0, 500)
spiritToggleButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
spiritToggleButton.Text = "START AUTO-ROLL"
spiritToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
spiritToggleButton.TextSize = 16
spiritToggleButton.Font = Enum.Font.GothamBold
spiritToggleButton.Parent = spiritMainFrame

local spiritToggleCorner = Instance.new("UICorner")
spiritToggleCorner.CornerRadius = UDim.new(0, 8)
spiritToggleCorner.Parent = spiritToggleButton

-- Function to check if current spirit root is in selected roots
local function isDesiredSpiritRoot(rootName)
	print("Checking Spirit Root:", '"' .. rootName .. '"')
	
	-- Normalize the current root name
	local normalizedCurrent = normalizeName(rootName)
	
	-- Check each selected root (both by key name and display name)
	for selectedRoot, _ in pairs(selectedSpiritRoots) do
		-- Find the full data for this root
		for _, rootData in ipairs(spiritRootData) do
			if rootData.name == selectedRoot then
				local normalizedKey = normalizeName(rootData.name)
				local normalizedDisplay = normalizeName(rootData.displayName)
				
				if normalizedCurrent == normalizedKey or normalizedCurrent == normalizedDisplay then
					print("✓ SPIRIT ROOT MATCH FOUND:", rootName)
					return true
				end
			end
		end
	end
	
	return false
end

-- Spirit Auto-roll function
local function autoRollSpiritRoot()
	while spiritAutoRollEnabled do
		spiritRollCount = spiritRollCount + 1
		
		-- Count selected spirit roots
		local selectedCount = 0
		for _ in pairs(selectedSpiritRoots) do
			selectedCount = selectedCount + 1
		end
		
		spiritStatusLabel.Text = "Rolling... (Attempt #" .. spiritRollCount .. " | " .. selectedCount .. " selected)"
		
		-- Roll the spirit root
		local args = {spiritSelectedSlot, false}
		ReplicatedStorage:WaitForChild("Events"):WaitForChild("RollSpiritRoot"):FireServer(unpack(args))
		
		wait(2) -- Wait for roll to complete and GUI to update
		
		-- Get current spirit root from GUI
		local currentRoot = getCurrentSpiritRoot()
		
		if currentRoot then
			print("Rolled Spirit Root:", currentRoot)
			
			if isDesiredSpiritRoot(currentRoot) then
				spiritAutoRollEnabled = false
				spiritToggleButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
				spiritToggleButton.Text = "START AUTO-ROLL"
				
				-- Find root color
				local rootColor = Color3.fromRGB(150, 50, 255)
				for _, root in ipairs(spiritRootData) do
					if normalizeName(root.displayName) == normalizeName(currentRoot) or 
					   normalizeName(root.name) == normalizeName(currentRoot) then
						rootColor = root.color
						break
					end
				end
				
				spiritStatusLabel.Text = "SUCCESS! Got " .. currentRoot .. "!"
				spiritStatusLabel.BackgroundColor3 = rootColor
				print("🎉 SPIRIT ROOT AUTO-ROLLER STOPPED - Got desired root:", currentRoot)
				break
			end
		else
			warn("⚠️ Could not read Spirit Root from GUI!")
		end
		
		wait(0.5) -- Delay between rolls
	end
end

-- Spirit Toggle button click
spiritToggleButton.MouseButton1Click:Connect(function()
	-- Check if at least one spirit root is selected
	local hasSelection = false
	for _ in pairs(selectedSpiritRoots) do
		hasSelection = true
		break
	end
	
	if not hasSelection and not spiritAutoRollEnabled then
		spiritStatusLabel.Text = "ERROR: Please select at least one root!"
		spiritStatusLabel.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		wait(2)
		spiritStatusLabel.BackgroundColor3 = Color3.fromRGB(45, 35, 50)
		spiritStatusLabel.Text = "Status: Idle"
		return
	end
	
	spiritAutoRollEnabled = not spiritAutoRollEnabled
	
	if spiritAutoRollEnabled then
		spiritToggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		spiritToggleButton.Text = "STOP AUTO-ROLL"
		spiritRollCount = 0
		spiritStatusLabel.BackgroundColor3 = Color3.fromRGB(45, 35, 50)
		
		print("=== SPIRIT ROOT AUTO-ROLLER STARTED ===")
		print("Selected Spirit Roots:")
		for root, _ in pairs(selectedSpiritRoots) do
			print("-", root)
		end
		print("Target slot:", spiritSelectedSlot)
		
		autoRollSpiritRoot()
	else
		spiritToggleButton.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
		spiritToggleButton.Text = "START AUTO-ROLL"
		spiritStatusLabel.Text = "Status: Stopped by user"
		print("=== SPIRIT ROOT AUTO-ROLLER STOPPED BY USER ===")
	end
end)

-- Make spirit frame draggable
local spiritDragging, spiritDragInput, spiritDragStart, spiritStartPos

local function spiritUpdate(input)
	local delta = input.Position - spiritDragStart
	spiritMainFrame.Position = UDim2.new(spiritStartPos.X.Scale, spiritStartPos.X.Offset + delta.X, spiritStartPos.Y.Scale, spiritStartPos.Y.Offset + delta.Y)
end

spiritMainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		spiritDragging = true
		spiritDragStart = input.Position
		spiritStartPos = spiritMainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				spiritDragging = false
			end
		end)
	end
end)

spiritMainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		spiritDragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == spiritDragInput and spiritDragging then
		spiritUpdate(input)
	end
end)

print("Spirit Root Auto-Roller GUI loaded successfully!")
print("Both Race and Spirit Root Auto-Rollers are ready!")
