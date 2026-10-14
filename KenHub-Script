-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Prevent duplicate UI instances
if CoreGui:FindFirstChild("KenHubCustomUI") then
    CoreGui.KenHubCustomUI:Destroy()
end

local KenHubUI = Instance.new("ScreenGui")
KenHubUI.Name = "KenHubCustomUI"
KenHubUI.Parent = CoreGui
KenHubUI.ResetOnSpawn = false

-- Configuration & States
local CORRECT_KEY = "KEN-HUB-2026"
local FeatureStates = {}
local OriginalWalkSpeed = 16

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRoot()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

--------------------------------------------------------------------------------
-- 1. FUNCTIONAL GAME HOOKS (Add your game mechanics here)
--------------------------------------------------------------------------------
local FeatureHooks = {
    ["Speed Boost"] = function(state)
        local hum = GetHumanoid()
        if hum then
            if state then
                OriginalWalkSpeed = hum.WalkSpeed > 0 and hum.WalkSpeed or 16
                hum.WalkSpeed = 30
            else
                hum.WalkSpeed = OriginalWalkSpeed
            end
        end
    end,

    ["Auto Attack"] = function(state)
        task.spawn(function()
            while FeatureStates["Auto Attack"] do
                task.wait(0.2)
                pcall(function()
                    local char = GetCharacter()
                    local tool = char and char:FindFirstChildOfClass("Tool")
                    if tool then
                        tool:Activate()
                    end
                end)
            end
        end)
    end,

    ["Auto Pick"] = function(state)
        task.spawn(function()
            while FeatureStates["Auto Pick"] do
                task.wait(0.4)
                pcall(function()
                    local myRoot = GetRoot()
                    if not myRoot then return end
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Enabled then
                            local part = obj.Parent
                            if part and part:IsA("BasePart") and (myRoot.Position - part.Position).Magnitude < 20 then
                                fireproximityprompt(obj)
                            end
                        end
                    end
                end)
            end
        end)
    end,

    ["Player Lock On"] = function(state)
        if state then
            _G.CustomLock = RunService.RenderStepped:Connect(function()
                if not FeatureStates["Player Lock On"] then return end
                local nearestPlayer, shortestDist = nil, math.huge
                local myRoot = GetRoot()
                
                if myRoot then
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local dist = (player.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                            if dist < shortestDist then
                                shortestDist = dist
                                nearestPlayer = player
                            end
                        end
                    end
                    if nearestPlayer and nearestPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, nearestPlayer.Character.HumanoidRootPart.Position)
                    end
                end
            end)
        else
            if _G.CustomLock then
                _G.CustomLock:Disconnect()
                _G.CustomLock = nil
            end
        end
    end
}

--------------------------------------------------------------------------------
-- 2. KEY SYSTEM UI
--------------------------------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 320, 0, 180)
KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
KeyFrame.BorderSizePixel = 0
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KenHubUI

local KeyCorner = Instance.new("UICorner")
KeyCorner.CornerRadius = UDim.new(0, 10)
KeyCorner.Parent = KeyFrame

local KeyStroke = Instance.new("UIStroke")
KeyStroke.Thickness = 2
KeyStroke.Color = Color3.fromRGB(0, 195, 255)
KeyStroke.Parent = KeyFrame

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "CUSTOM HUB - KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 13
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 35)
KeyInput.Position = UDim2.new(0.075, 0, 0.3, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
KeyInput.PlaceholderText = "Enter Key..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 13
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
VerifyBtn.Text = "VERIFY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 13
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

--------------------------------------------------------------------------------
-- 3. MAIN UI FRAME (Hidden until key is verified)
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 330)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -165)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = KenHubUI

-- Left Sidebar
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 170, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
LeftPanel.Active = true
LeftPanel.Draggable = true
LeftPanel.Parent = MainFrame
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)
local LeftStroke = Instance.new("UIStroke", LeftPanel)
LeftStroke.Thickness = 2
LeftStroke.Color = Color3.fromRGB(0, 195, 255)

-- Sidebar Title
local BrandText = Instance.new("TextLabel")
BrandText.Size = UDim2.new(1, -20, 0, 40)
BrandText.Position = UDim2.new(0, 15, 0, 15)
BrandText.BackgroundTransparency = 1
BrandText.Text = "CUSTOM HUB"
BrandText.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandText.TextSize = 13
BrandText.Font = Enum.Font.GothamBold
BrandText.TextXAlignment = Enum.TextXAlignment.Left
BrandText.Parent = LeftPanel

-- Right Content Panel
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0, 395, 1, 0)
RightPanel.Position = UDim2.new(0, 180, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
RightPanel.Active = true
RightPanel.Draggable = true
RightPanel.Parent = MainFrame
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)
local RightStroke = Instance.new("UIStroke", RightPanel)
RightStroke.Thickness = 2
RightStroke.Color = Color3.fromRGB(0, 195, 255)

local GridContainer = Instance.new("ScrollingFrame")
GridContainer.Size = UDim2.new(1, -20, 1, -50)
GridContainer.Position = UDim2.new(0, 10, 0, 40)
GridContainer.BackgroundTransparency = 1
GridContainer.ScrollBarThickness = 0
GridContainer.Parent = RightPanel

local UIGrid = Instance.new("UIGridLayout")
UIGrid.CellSize = UDim2.new(0.485, 0, 0, 38)
UIGrid.CellPadding = UDim2.new(0.03, 0, 0, 8)
UIGrid.Parent = GridContainer

-- Function to dynamically build interactive toggle cards
local function createToggle(title, defaultState)
    FeatureStates[title] = defaultState

    local toggleCard = Instance.new("Frame")
    toggleCard.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    toggleCard.Parent = GridContainer
    Instance.new("UICorner", toggleCard).CornerRadius = UDim.new(0, 6)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(220, 230, 240)
    titleLabel.TextSize = 11
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggleCard

    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 34, 0, 18)
    switchBtn.Position = UDim2.new(1, -40, 0.5, -9)
    switchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 55, 65)
    switchBtn.Text = ""
    switchBtn.Parent = toggleCard
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switchBtn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    -- Initial state activation
    if defaultState and FeatureHooks[title] then
        task.spawn(function() FeatureHooks[title](true) end)
    end

    -- Click Event Handler
    switchBtn.MouseButton1Click:Connect(function()
        FeatureStates[title] = not FeatureStates[title]
        local isEnabled = FeatureStates[title]

        if isEnabled then
            TweenService:Create(switchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(switchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 55, 65)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end

        if FeatureHooks[title] then
            FeatureHooks[title](isEnabled)
        end
    end)
end

-- Add Toggles to UI
createToggle("Speed Boost", false)
createToggle("Auto Attack", false)
createToggle("Auto Pick", true)
createToggle("Player Lock On", false)

--------------------------------------------------------------------------------
-- 4. VERIFICATION LOGIC
--------------------------------------------------------------------------------
VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        VerifyBtn.Text = "SUCCESS!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(0.5)
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        VerifyBtn.Text = "INVALID KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        task.wait(1)
        VerifyBtn.Text = "VERIFY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
    end
end)
