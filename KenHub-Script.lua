-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer

-- Prevent duplicate UI instances
if CoreGui:FindFirstChild("KenHubUI") then
    CoreGui.KenHubUI:Destroy()
end

local KenHubUI = Instance.new("ScreenGui")
KenHubUI.Name = "KenHubUI"
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
-- 1. GAME MECHANICS (Huss Valley Mechanics)
--------------------------------------------------------------------------------
local FeatureHooks = {
    ["Speed Boost"] = function(state)
        local hum = GetHumanoid()
        if hum then
            if state then
                OriginalWalkSpeed = hum.WalkSpeed > 0 and hum.WalkSpeed or 16
                hum.WalkSpeed = 32
            else
                hum.WalkSpeed = OriginalWalkSpeed
            end
        end
    end,

    ["Auto Dodge"] = function(state)
        task.spawn(function()
            while FeatureStates["Auto Dodge"] do
                task.wait(0.1)
                pcall(function()
                    local myRoot = GetRoot()
                    local myChar = GetCharacter()
                    if not myRoot or not myChar then return end

                    -- Detect incoming chasers/catchers within 15 studs
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local enemyRoot = player.Character.HumanoidRootPart
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude

                            if dist <= 15 then
                                local tool = myChar:FindFirstChildOfClass("Tool")
                                if tool and (tool.Name:lower():find("dodge") or tool.Name:lower():find("dash")) then
                                    tool:Activate()
                                else
                                    keypress(0x10) -- Shift Key
                                    task.wait(0.05)
                                    keyrelease(0x10)
                                end
                                task.wait(0.8)
                            end
                        end
                    end
                end)
            end
        end)
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
                            if part and part:IsA("BasePart") and (myRoot.Position - part.Position).Magnitude < 25 then
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
            _G.KenLock = RunService.RenderStepped:Connect(function()
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
            if _G.KenLock then
                _G.KenLock:Disconnect()
                _G.KenLock = nil
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

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Thickness = 2
KeyStroke.Color = Color3.fromRGB(0, 195, 255)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "KEN HUB - KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 13
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 35)
KeyInput.Position = UDim2.new(0.075, 0, 0.3, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
KeyInput.PlaceholderText = "Enter Key (KEN-HUB-2026)..."
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
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 13
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

--------------------------------------------------------------------------------
-- 3. MAIN HUB UI FRAME & MINIMIZE CONTROLS
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 330)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -165)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = KenHubUI

-- Floating Open/Restore Button (Visible when minimized)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 90, 0, 35)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -17)
OpenBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
OpenBtn.Text = "KEN HUB"
OpenBtn.TextColor3 = Color3.fromRGB(0, 195, 255)
OpenBtn.TextSize = 11
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Visible = false
OpenBtn.Parent = KenHubUI

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Thickness = 2
OpenStroke.Color = Color3.fromRGB(0, 195, 255)

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

local BrandText = Instance.new("TextLabel")
BrandText.Size = UDim2.new(1, -20, 0, 30)
BrandText.Position = UDim2.new(0, 15, 0, 10)
BrandText.BackgroundTransparency = 1
BrandText.Text = "KEN HUB"
BrandText.TextColor3 = Color3.fromRGB(0, 195, 255)
BrandText.TextSize = 14
BrandText.Font = Enum.Font.GothamBold
BrandText.TextXAlignment = Enum.TextXAlignment.Left
BrandText.Parent = LeftPanel

-- Player Status Box inside Sidebar
local PlayerStatusBox = Instance.new("Frame")
PlayerStatusBox.Size = UDim2.new(1, -20, 0, 120)
PlayerStatusBox.Position = UDim2.new(0, 10, 0, 45)
PlayerStatusBox.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
PlayerStatusBox.Parent = LeftPanel
Instance.new("UICorner", PlayerStatusBox).CornerRadius = UDim.new(0, 8)

local StatusName = Instance.new("TextLabel")
StatusName.Size = UDim2.new(1, -10, 0, 20)
StatusName.Position = UDim2.new(0, 5, 0, 5)
StatusName.BackgroundTransparency = 1
StatusName.Text = "User: " .. LocalPlayer.DisplayName
StatusName.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusName.TextSize = 10
StatusName.Font = Enum.Font.GothamBold
StatusName.TextXAlignment = Enum.TextXAlignment.Left
StatusName.Parent = PlayerStatusBox

local StatusHealth = Instance.new("TextLabel")
StatusHealth.Size = UDim2.new(1, -10, 0, 20)
StatusHealth.Position = UDim2.new(0, 5, 0, 25)
StatusHealth.BackgroundTransparency = 1
StatusHealth.Text = "HP: 100 / 100"
StatusHealth.TextColor3 = Color3.fromRGB(0, 220, 120)
StatusHealth.TextSize = 10
StatusHealth.Font = Enum.Font.Gotham
StatusHealth.TextXAlignment = Enum.TextXAlignment.Left
StatusHealth.Parent = PlayerStatusBox

-- FPS & Ping Stats inside Sidebar
local MetricsLabel = Instance.new("TextLabel")
MetricsLabel.Size = UDim2.new(1, -10, 0, 40)
MetricsLabel.Position = UDim2.new(0, 5, 0, 55)
MetricsLabel.BackgroundTransparency = 1
MetricsLabel.Text = "FPS: 60\nPing: 0 ms"
MetricsLabel.TextColor3 = Color3.fromRGB(180, 190, 200)
MetricsLabel.TextSize = 10
MetricsLabel.Font = Enum.Font.Gotham
MetricsLabel.TextXAlignment = Enum.TextXAlignment.Left
MetricsLabel.Parent = PlayerStatusBox

-- Right Panel Grid
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

-- Header Action Buttons (Minimize & Close)
local HeaderButtons = Instance.new("Frame")
HeaderButtons.Size = UDim2.new(0, 50, 0, 25)
HeaderButtons.Position = UDim2.new(1, -55, 0, 8)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Parent = RightPanel

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(0, 195, 255)
MinimizeBtn.TextSize = 14
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = HeaderButtons
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(0, 26, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = HeaderButtons
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Minimize & Restore Event Listeners
MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    KenHubUI:Destroy()
end)

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

-- Toggle Creator Function
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

    if defaultState and FeatureHooks[title] then
        task.spawn(function() FeatureHooks[title](true) end)
    end

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

-- Create Hub Toggles
createToggle("Auto Dodge", true)
createToggle("Speed Boost", false)
createToggle("Auto Attack", false)
createToggle("Auto Pick", true)
createToggle("Player Lock On", false)

--------------------------------------------------------------------------------
-- 4. REAL-TIME METRICS & PLAYER STATUS UPDATER
--------------------------------------------------------------------------------
local FrameCount = 0
local LastTime = tick()

RunService.RenderStepped:Connect(function()
    FrameCount = FrameCount + 1
    local CurrentTime = tick()
    
    if CurrentTime - LastTime >= 1 then
        local fps = math.floor(FrameCount / (CurrentTime - LastTime))
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        
        MetricsLabel.Text = string.format("FPS: %d\nPing: %d ms", fps, ping)
        FrameCount = 0
        LastTime = CurrentTime
    end

    -- Update Health
    local hum = GetHumanoid()
    if hum then
        StatusHealth.Text = string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
    else
        StatusHealth.Text = "HP: N/A"
    end
end)

--------------------------------------------------------------------------------
-- 5. VERIFICATION LOGIC
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
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
    end
end)
