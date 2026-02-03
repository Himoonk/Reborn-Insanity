-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local plantsFolder = workspace:WaitForChild("Plants")

-- Plant options
local plantNames = {"Spirit Rose", "Qi Berries", "Qi Flower", "Death Flower", "Moon Flower", "Ginseng"}
local targetPlant = plantNames[1] -- default

-- Teleport toggle
local enabled = false

-- Function to get HumanoidRootPart
local function getHRP()
    local character = player.Character or player.CharacterAdded:Wait()
    return character:WaitForChild("HumanoidRootPart")
end

-- Function to press E once
local function pressE()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
end

-- Teleport loop
task.spawn(function()
    while true do
        if enabled then
            for _, obj in ipairs(plantsFolder:GetDescendants()) do
                if not enabled then break end

                if obj.Name == targetPlant then
                    local hrp = getHRP()
                    local targetCFrame

                    if obj:IsA("BasePart") then
                        targetCFrame = obj.CFrame
                    elseif obj:IsA("Model") then
                        local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                        if part then
                            targetCFrame = part.CFrame
                        end
                    end

                    if targetCFrame then
                        hrp.CFrame = targetCFrame + Vector3.new(0, 3, 0)
                        print("Teleported to " .. targetPlant)
                        task.wait(0.2)
                        pressE()
                        task.wait(4) -- 4-second delay preserved
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)

-- ====== GUI ======
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "TeleportGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Main frame (top-left corner)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0, 10, 0, 10) -- top-left corner
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0
frame.Parent = screenGui

-- Title
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "Plant Teleporter"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Toggle button (on top now)
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 200, 0, 30)
toggleButton.Position = UDim2.new(0, 25, 0, 35) -- moved up
toggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Text = "Toggle Teleport: OFF"
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Parent = frame

toggleButton.MouseButton1Click:Connect(function()
    enabled = not enabled
    toggleButton.Text = "Toggle Teleport: " .. (enabled and "ON" or "OFF")
end)

-- Dropdown for plant selection (moved down)
local dropdown = Instance.new("TextButton")
dropdown.Size = UDim2.new(0, 200, 0, 30)
dropdown.Position = UDim2.new(0, 25, 0, 80)
dropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
dropdown.Text = targetPlant
dropdown.Font = Enum.Font.SourceSans
dropdown.TextSize = 16
dropdown.Parent = frame

-- Dropdown options frame
local optionsFrame = Instance.new("Frame")
optionsFrame.Size = UDim2.new(0, 200, 0, #plantNames * 25)
optionsFrame.Position = UDim2.new(0, 0, 0, 30)
optionsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
optionsFrame.Visible = false
optionsFrame.Parent = dropdown

for i, name in ipairs(plantNames) do
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 25)
    button.Position = UDim2.new(0, 0, 0, (i-1)*25)
    button.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = name
    button.Font = Enum.Font.SourceSans
    button.TextSize = 14
    button.Parent = optionsFrame

    button.MouseButton1Click:Connect(function()
        targetPlant = name
        dropdown.Text = name
        optionsFrame.Visible = false
    end)
end

dropdown.MouseButton1Click:Connect(function()
    optionsFrame.Visible = not optionsFrame.Visible
end)
