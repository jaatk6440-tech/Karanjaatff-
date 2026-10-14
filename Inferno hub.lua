-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")
local VirtualUser = game:GetService("VirtualUser")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safe Target Parent
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

local OriginalWalkSpeed = 16
local SpeedBoostValue = 28
local CanDodge = true

-- Theme Colors (Inferno / Molten Glass Theme)
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
-- GAMEPLAY MECHANICS & LOOPS
--------------------------------------------------------------------------------

-- 1. SPEED BOOST (SAVE AND RESTORE SPEED)
task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            local hum = GetHumanoid()
            if hum then
                if FeatureStates["Speed Boost"] then
                    if hum.WalkSpeed ~= SpeedBoostValue then
                        -- Cache original speed if not already boosted
                        if hum.WalkSpeed ~= SpeedBoostValue then
                            OriginalWalkSpeed = hum.WalkSpeed
                        end
                        hum.WalkSpeed = SpeedBoostValue
                    end
                else
                    -- Restore cached original speed
                    if hum.WalkSpeed == SpeedBoostValue then
                        hum.WalkSpeed = OriginalWalkSpeed
                    end
                end
            end
        end)
    end
end)

-- 2. AUTO ATTACK (COMBAT SYSTEM ACTIVATION)
task.spawn(function()
    while true do
        task.wait(0.1)
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
                            if dist <= 12 then
                                -- Equip tool if in backpack
                                local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
                                local tool = char:FindFirstChildOfClass("Tool") or (backpack and backpack:FindFirstChildOfClass("Tool"))
                                
                                if tool and tool.Parent ~= char then
                                    tool.Parent = char
                                end

                                -- Activate equipped weapon
                                if tool then
                                    tool:Activate()
                                end

                                -- Virtual input click simulation
                                VirtualUser:Button1Down(Vector2.new(0,0))
                                task.wait(0.02)
                                VirtualUser:Button1Up(Vector2.new(0,0))

                                -- Fire combat remote events
                                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                                    if obj:IsA("RemoteEvent") and (obj.Name:lower():find("catch") or obj.Name:lower():find("attack") or obj.Name:lower():find("hit") or obj.Name:lower():find("tag")) then
                                        obj:FireServer(plr)
                                        obj:FireServer(plr.Character)
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

-- 3. AUTO DODGE (MOVEMENT DODGE WITH COOLDOWN)
task.spawn(function()
    while true do
        task.wait(0.05)
        if FeatureStates["Auto Dodge"] and CanDodge then
            pcall(function()
                local myRoot = GetRoot()
                local hum = GetHumanoid()
                if not myRoot or not hum then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if IsEnemy(plr) then
                        local enemyRoot = GetRoot(plr)
                        if enemyRoot then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= 9 then
                                CanDodge = false
                                
                                -- Dodge using movement controls
                                local rightVector = myRoot.CFrame.RightVector
                                local dodgeDir = (math.random() > 0.5 and rightVector or -rightVector)
                                local targetPos = myRoot.Position + (dodgeDir * 18)
                                
                                hum:MoveTo(targetPos)
                                
                                -- Cooldown management
                                task.wait(0.8)
                                CanDodge = true
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. AUTO RUN (PATHFINDING & MOVETO NAVIGATION)
task.spawn(function()
    while true do
        task.wait(0.2)
        if FeatureStates["Auto Run"] then
            pcall(function()
                local hum = GetHumanoid()
                local myRoot = GetRoot()
                if not hum or not myRoot then return end

                -- Locate designated finish zone
                local finishPart = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("finish") or obj.Name:lower():find("escape") or obj.Name:lower():find("goal") or obj.Name:lower():find("end")) then
                        finishPart = obj
                        break
                    end
                end

                if finishPart then
                    -- Compute Path via PathfindingService
                    local path = PathfindingService:CreatePath({
                        AgentRadius = 2,
                        AgentHeight = 5,
                        AgentCanJump = true
                    })
                    
                    path:ComputeAsync(myRoot.Position, finishPart.Position)
                    local waypoints = path:GetWaypoints()

                    if path.Status == Enum.PathStatus.Success and #waypoints > 1 then
                        hum:MoveTo(waypoints[2].Position)
                    else
                        hum:MoveTo(finishPart.Position)
                    end
                else
                    -- Fallback forward movement
                    hum:MoveTo(myRoot.Position + (myRoot.CFrame.LookVector * 25))
                end
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- MOBILE UI & PANELS
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

-- Key System Frame
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

-- FPS & Ping Loop
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
