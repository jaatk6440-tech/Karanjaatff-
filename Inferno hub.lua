-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safe Parent Target
local TargetParent = PlayerGui
pcall(function()
    if CoreGui then TargetParent = CoreGui end
end)

if TargetParent:FindFirstChild("InfernoHubUI") then
    TargetParent.InfernoHubUI:Destroy()
end

local InfernoHubUI = Instance.new("ScreenGui")
InfernoHubUI.Name = "InfernoHubUI"
InfernoHubUI.Parent = TargetParent
InfernoHubUI.ResetOnSpawn = false

-- Config & Key Setup
local CORRECT_KEY = "KARAN X AIZEN"
local FeatureStates = {
    ["Auto Attack"] = false,
    ["Auto Dodge"] = false,
    ["Auto Run"] = false,
    ["Speed Boost"] = false
}

local CanDodge = true
local CustomSpeed = 32

-- Theme Colors
local MoltenOrange = Color3.fromRGB(255, 85, 0)
local DarkCharcoal = Color3.fromRGB(15, 12, 14)
local CardBG = Color3.fromRGB(24, 18, 20)
local AccentGold = Color3.fromRGB(255, 170, 0)

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
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

local function IsEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end
    return true
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

-- 2. AUTO ATTACK (ON RUNNERS / ENEMIES)
task.spawn(function()
    while task.wait(0.05) do
        if FeatureStates["Auto Attack"] then
            pcall(function()
                local myRoot = GetRoot()
                local char = GetCharacter()
                if not myRoot or not char then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if IsEnemy(plr) then
                        local enemyRoot = GetRoot(plr)
                        if enemyRoot then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= 15 then
                                for _, prompt in pairs(plr.Character:GetDescendants()) do
                                    if prompt:IsA("ProximityPrompt") then
                                        fireproximityprompt(prompt)
                                    end
                                end

                                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                                local tool = char:FindFirstChildOfClass("Tool") or (backpack and backpack:FindFirstChildOfClass("Tool"))
                                if tool then
                                    if tool.Parent ~= char then tool.Parent = char end
                                    tool:Activate()
                                end

                                VirtualUser:Button1Down(Vector2.new(0, 0))
                                task.wait(0.01)
                                VirtualUser:Button1Up(Vector2.new(0, 0))

                                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                                    if obj:IsA("RemoteEvent") then
                                        local name = obj.Name:lower()
                                        if name:find("catch") or name:find("tag") or name:find("hit") or name:find("attack") or name:find("touch") or name:find("action") then
                                            obj:FireServer(plr)
                                            obj:FireServer(plr.Character)
                                            obj:FireServer(enemyRoot)
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

-- 3. AUTO DODGE (LOCKED & WORKING - UNTOUCHED)
task.spawn(function()
    while task.wait(0.05) do
        if FeatureStates["Auto Dodge"] and CanDodge then
            pcall(function()
                local myRoot = GetRoot()
                if not myRoot then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if IsEnemy(plr) then
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

-- 4. AUTO RUN TO SAFE ZONE (DIRECT CFRAME MOMENTUM CROSSING)
task.spawn(function()
    while task.wait(0.02) do
        if FeatureStates["Auto Run"] then
            pcall(function()
                local myRoot = GetRoot()
                local hum = GetHumanoid()
                if not myRoot or not hum then return end

                -- Directly shift root CFrame forward to guarantee crossing the boundary line instantly
                myRoot.CFrame = myRoot.CFrame + (myRoot.CFrame.LookVector * 0.8)
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
MainFrame.Size = UDim2.new(0, 380, 0, 240)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -120)
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
Instance.new("UIC")
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
ToggleContainer.Size = UDim2.new(1, -24, 1, -62)
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

createToggle("Auto Attack")
createToggle("Auto Dodge")
createToggle("Auto Run")
createToggle("Speed Boost")

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
