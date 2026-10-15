-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10) or LocalPlayer:FindFirstChildOfClass("PlayerGui")

if not PlayerGui then return end

-- Safe Parent Target
local TargetParent = PlayerGui
pcall(function()
    if CoreGui and CoreGui:FindFirstChild("RobloxGui") then
        TargetParent = CoreGui
    end
end)

-- Cleanup existing instances to prevent duplicates
if TargetParent:FindFirstChild("InfernoHubUI") then
    TargetParent.InfernoHubUI:Destroy()
end

local InfernoHubUI = Instance.new("ScreenGui")
InfernoHubUI.Name = "InfernoHubUI"
InfernoHubUI.Parent = TargetParent
InfernoHubUI.ResetOnSpawn = false
InfernoHubUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Config & Key Setup
local CORRECT_KEY = "KARAN X AIZEN"
local FeatureStates = {
    ["Auto Catch"] = false,
    ["Auto Dodge"] = false,
    ["Auto Run"] = false,
    ["Speed Boost"] = false
}

local CatchRange = 25 -- Default Max Range
local CanDodge = true
local CustomSpeed = 32

-- Theme Colors
local MoltenOrange = Color3.fromRGB(255, 85, 0)
local DarkCharcoal = Color3.fromRGB(15, 12, 14)
local CardBG = Color3.fromRGB(24, 18, 20)
local AccentGold = Color3.fromRGB(255, 170, 0)

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS & SANITY CHECKS
--------------------------------------------------------------------------------
local function GetCharacter(plr)
    plr = plr or LocalPlayer
    return plr.Character
end

local function GetRoot(plr)
    local char = GetCharacter(plr)
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid(plr)
    local char = GetCharacter(plr)
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Validate target distance and server state sanity check
local function ValidateTarget(targetPlayer)
    if not targetPlayer or targetPlayer == LocalPlayer then return false end
    
    local myRoot = GetRoot()
    local enemyRoot = GetRoot(targetPlayer)
    local enemyHum = GetHumanoid(targetPlayer)
    
    if myRoot and enemyRoot and enemyHum and enemyHum.Health > 0 then
        local dist = (myRoot.Position - enemyRoot.Position).Magnitude
        return dist <= CatchRange, dist
    end
    return false, math.huge
end

--------------------------------------------------------------------------------
-- INTEGRATED TOOL & HITCHECK FUNCTIONS
--------------------------------------------------------------------------------
local function checkHit(originPosition, directionVector)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude

    local result = Workspace:Raycast(originPosition, directionVector, raycastParams)
    if result and result.Instance then
        print("Hit part:", result.Instance.Name)
    end
    return result
end

-- Tool integration check
local tool = script:IsA("Tool") and script or nil
if tool then
    tool.Activated:Connect(function()
        local character = GetCharacter()
        local root = GetRoot()
        if character and root then
            checkHit(root.Position, root.CFrame.LookVector * 10)
        end
    end)
end

--------------------------------------------------------------------------------
-- GAMEPLAY AUTOMATION LOOPS
--------------------------------------------------------------------------------

-- 1. SPEED BOOST
task.spawn(function()
    while task.wait(0.1) do
        pcall(function()
            local hum = GetHumanoid()
            if hum then
                if FeatureStates["Speed Boost"] then
                    hum.WalkSpeed = CustomSpeed
                else
                    if hum.WalkSpeed == CustomSpeed then
                        hum.WalkSpeed = 16
                    end
                end
            end
        end)
    end
end)

-- 2. HUSS VALLEY VALIDATED AUTO CATCH
task.spawn(function()
    while task.wait(0.01) do
        if FeatureStates["Auto Catch"] then
            pcall(function()
                local myRoot = GetRoot()
                local myChar = GetCharacter()
                if not myRoot or not myChar then return end

                -- A. Proximity Prompts Check
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local parentPart = prompt.Parent
                        if parentPart and parentPart:IsA("BasePart") then
                            if (myRoot.Position - parentPart.Position).Magnitude <= CatchRange then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end

                -- B. Target Opponents with Distance Validation
                for _, plr in pairs(Players:GetPlayers()) do
                    local isValid, dist = ValidateTarget(plr)
                    if isValid then
                        local enemyRoot = GetRoot(plr)
                        local enemyChar = GetCharacter(plr)

                        if enemyRoot and enemyChar then
                            -- 1. Auto Equip Tool/Ball
                            local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                            if backpack then
                                local heldTool = myChar:FindFirstChildOfClass("Tool")
                                if not heldTool then
                                    local catchTool = backpack:FindFirstChildOfClass("Tool")
                                    if catchTool then
                                        catchTool.Parent = myChar
                                    end
                                end
                            end

                            -- 2. Virtual Input & Key Simulation
                            VirtualUser:CaptureController()
                            VirtualUser:Button1Down(Vector2.new(0, 0))

                            pcall(function()
                                VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.E, true, game)
                                task.wait(0.01)
                                VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.E, false, game)

                                VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.F, true, game)
                                task.wait(0.01)
                                VirtualInputManager:SendKeyPressEvent(Enum.KeyCode.F, false, game)
                            end)

                            -- 3. Tool Trigger
                            local activeTool = myChar:FindFirstChildOfClass("Tool")
                            if activeTool then
                                activeTool:Activate()
                            end

                            -- 4. Touch Interest Simulation
                            local myHand = myChar:FindFirstChild("RightHand") or myChar:FindFirstChild("Right Arm") or myRoot
                            for _, part in pairs(enemyChar:GetChildren()) do
                                if part:IsA("BasePart") then
                                    firetouchinterest(myHand, part, 0)
                                    task.wait()
                                    firetouchinterest(myHand, part, 1)
                                end
                            end

                            -- 5. Safe Event Invocation
                            local targetedRemotes = {
                                "Catch", "CatchRemote", "CatchEvent", "Grab", 
                                "Tag", "Throw", "ThrowBall", "Pass", "Hit"
                            }

                            for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                                if obj:IsA("RemoteEvent") or obj:IsA("UnreliableRemoteEvent") then
                                    for _, name in ipairs(targetedRemotes) do
                                        if string.find(obj.Name:lower(), name:lower()) then
                                            pcall(function()
                                                obj:FireServer(plr)
                                                obj:FireServer(enemyChar)
                                                obj:FireServer(enemyRoot)
                                                obj:FireServer(enemyRoot.Position)
                                            end)
                                        end
                                    end
                                end
                            end

                        end
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO DODGE
task.spawn(function()
    while task.wait(0.05) do
        if FeatureStates["Auto Dodge"] and CanDodge then
            pcall(function()
                local myRoot = GetRoot()
                if not myRoot then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local enemyRoot = GetRoot(plr)
                        if enemyRoot then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= 11 then
                                CanDodge = false
                                local dodgeVector = myRoot.CFrame.RightVector * (math.random() > 0.5 and 45 or -45)
                                local bv = Instance.new("BodyVelocity")
                                bv.MaxForce = Vector3.new(1e5, 0, 1e5)
                                bv.Velocity = dodgeVector
                                bv.Parent = myRoot
                                
                                task.wait(0.12)
                                bv:Destroy()

                                task.wait(0.65)
                                CanDodge = true
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. AUTO RUN TO SAFE ZONE
task.spawn(function()
    while task.wait(0.02) do
        if FeatureStates["Auto Run"] then
            pcall(function()
                local myRoot = GetRoot()
                local hum = GetHumanoid()
                if not myRoot or not hum then return end
                myRoot.CFrame = myRoot.CFrame + (myRoot.CFrame.LookVector * 0.9)
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- MOBILE INTERFACE & PANELS
--------------------------------------------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 95, 0, 34)
OpenBtn.Position = UDim2.new(0, 15, 0.35, 0)
OpenBtn.BackgroundColor3 = DarkCharcoal
OpenBtn.Text = "🔥 INFERNO"
OpenBtn.TextColor3 = MoltenOrange
OpenBtn.TextSize = 11
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = InfernoHubUI

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Thickness = 2
OpenStroke.Color = MoltenOrange

-- Key System Window
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 300, 0, 175)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -87)
KeyFrame.BackgroundColor3 = DarkCharcoal
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = InfernoHubUI

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Thickness = 2
KeyStroke.Color = MoltenOrange

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 40)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "🔥 INFERNO HUB - KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 12
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 34)
KeyInput.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(10, 8, 9)
KeyInput.PlaceholderText = "Enter Key (KARAN X AIZEN)..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 11
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local InputStroke = Instance.new("UIStroke", KeyInput)
InputStroke.Thickness = 1
InputStroke.Color = Color3.fromRGB(60, 40, 30)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 34)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.64, 0)
VerifyBtn.BackgroundColor3 = MoltenOrange
VerifyBtn.Text = "UNLOCK HUB"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 11
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

-- Main Hub Window
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -140)
MainFrame.BackgroundColor3 = DarkCharcoal
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = InfernoHubUI

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = MoltenOrange

-- Title Bar
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundTransparency = 1
Header.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -60, 1, 0)
TitleText.Position = UDim2.new(0, 12, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "🔥 INFERNO HUB - HUSS VALLEY"
TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleText.TextSize = 11
TitleText.Font = Enum.Font.GothamBold
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 22, 0, 22)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 20, 20)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 10
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = Header
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

-- Stats Widget (FPS & Ping)
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -24, 0, 20)
StatsLabel.Position = UDim2.new(0, 12, 0, 32)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 60  |  Ping: 0 ms"
StatsLabel.TextColor3 = AccentGold
StatsLabel.TextSize = 10
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.Parent = MainFrame

-- Toggles Container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Size = UDim2.new(1, -24, 0, 130)
ToggleContainer.Position = UDim2.new(0, 12, 0, 54)
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Parent = MainFrame

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0.48, 0, 0, 36)
Grid.CellPadding = UDim2.new(0.04, 0, 0, 8)
Grid.Parent = ToggleContainer

local function createToggle(title)
    FeatureStates[title] = false
    
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = CardBG
    btn.Text = title .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 190, 190)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ToggleContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local btnStroke = Instance.new("UIStroke", btn)
    btnStroke.Thickness = 1
    btnStroke.Color = Color3.fromRGB(45, 30, 30)

    btn.MouseButton1Click:Connect(function()
        FeatureStates[title] = not FeatureStates[title]
        if FeatureStates[title] then
            btn.Text = title .. ": ON"
            btn.BackgroundColor3 = MoltenOrange
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btnStroke.Color = AccentGold
        else
            btn.Text = title .. ": OFF"
            btn.BackgroundColor3 = CardBG
            btn.TextColor3 = Color3.fromRGB(200, 190, 190)
            btnStroke.Color = Color3.fromRGB(45, 30, 30)
        end
    end)
end

createToggle("Auto Catch")
createToggle("Auto Dodge")
createToggle("Auto Run")
createToggle("Speed Boost")

--------------------------------------------------------------------------------
-- CATCH RANGE SELECTOR UI
--------------------------------------------------------------------------------
local RangeTitle = Instance.new("TextLabel")
RangeTitle.Size = UDim2.new(1, -24, 0, 18)
RangeTitle.Position = UDim2.new(0, 12, 0, 190)
RangeTitle.BackgroundTransparency = 1
RangeTitle.Text = "CATCH RANGE: 25 STUDS (VERY LONG)"
RangeTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
RangeTitle.TextSize = 10
RangeTitle.Font = Enum.Font.GothamBold
RangeTitle.TextXAlignment = Enum.TextXAlignment.Left
RangeTitle.Parent = MainFrame

local RangeContainer = Instance.new("Frame")
RangeContainer.Size = UDim2.new(1, -24, 0, 32)
RangeContainer.Position = UDim2.new(0, 12, 0, 212)
RangeContainer.BackgroundTransparency = 1
RangeContainer.Parent = MainFrame

local RangeGrid = Instance.new("UIGridLayout")
RangeGrid.CellSize = UDim2.new(0.23, 0, 1, 0)
RangeGrid.CellPadding = UDim2.new(0.026, 0, 0, 0)
RangeGrid.Parent = RangeContainer

local RangeButtons = {}

local ranges = {
    {Name = "10s", Value = 10, Label = "10 STUDS (SHORT)"},
    {Name = "15s", Value = 15, Label = "15 STUDS (MEDIUM)"},
    {Name = "20s", Value = 20, Label = "20 STUDS (LONG)"},
    {Name = "25s", Value = 25, Label = "25 STUDS (VERY LONG)"}
}

for _, r in ipairs(ranges) do
    local rBtn = Instance.new("TextButton")
    rBtn.BackgroundColor3 = (r.Value == CatchRange) and MoltenOrange or CardBG
    rBtn.Text = r.Name
    rBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    rBtn.TextSize = 10
    rBtn.Font = Enum.Font.GothamBold
    rBtn.Parent = RangeContainer
    Instance.new("UICorner", rBtn).CornerRadius = UDim.new(0, 6)
    
    local rStroke = Instance.new("UIStroke", rBtn)
    rStroke.Thickness = 1
    rStroke.Color = (r.Value == CatchRange) and AccentGold or Color3.fromRGB(45, 30, 30)
    
    RangeButtons[r.Value] = {Btn = rBtn, Stroke = rStroke}

    rBtn.MouseButton1Click:Connect(function()
        CatchRange = r.Value
        RangeTitle.Text = "CATCH RANGE: " .. r.Label
        
        for val, data in pairs(RangeButtons) do
            if val == CatchRange then
                data.Btn.BackgroundColor3 = MoltenOrange
                data.Stroke.Color = AccentGold
            else
                data.Btn.BackgroundColor3 = CardBG
                data.Stroke.Color = Color3.fromRGB(45, 30, 30)
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- EVENT LISTENERS
--------------------------------------------------------------------------------

local FrameCount = 0
local LastTime = tick()
RunService.RenderStepped:Connect(function()
    FrameCount = FrameCount + 1
    local CurrentTime = tick()
    if CurrentTime - LastTime >= 1 then
        local fps = math.floor(FrameCount / (CurrentTime - LastTime))
        local ping = 0
        pcall(function()
            ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        end)
        StatsLabel.Text = string.format("FPS: %d  |  Ping: %d ms", fps, ping)
        FrameCount = 0
        LastTime = CurrentTime
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

OpenBtn.MouseButton1Click:Connect(function()
    if not KeyFrame.Visible then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        VerifyBtn.Text = "UNLOCKED!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
        task.wait(0.4)
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        VerifyBtn.Text = "INVALID KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
        task.wait(1)
        VerifyBtn.Text = "UNLOCK HUB"
        VerifyBtn.BackgroundColor3 = MoltenOrange
    end
end)
