-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safe Target Parent
local TargetParent = PlayerGui
pcall(function()
    if CoreGui then TargetParent = CoreGui end
end)

if TargetParent:FindFirstChild("KenHubUI") then
    TargetParent.KenHubUI:Destroy()
end

local KenHubUI = Instance.new("ScreenGui")
KenHubUI.Name = "KenHubUI"
KenHubUI.Parent = TargetParent
KenHubUI.ResetOnSpawn = false

-- Feature States & Config
local FeatureStates = {}
local CORRECT_KEY = "KEN-HUB-2026"
local ActiveAccent = Color3.fromRGB(0, 195, 255)

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

-- Role and Team Validation
local function IsEnemy(plr)
    if not plr or plr == LocalPlayer then return false end
    
    -- Check team object
    if LocalPlayer.Team and plr.Team then
        return LocalPlayer.Team ~= plr.Team
    end
    
    -- Check custom game attributes
    local myChar = LocalPlayer.Character
    local enemyChar = plr.Character
    if myChar and enemyChar then
        local myRole = myChar:GetAttribute("Role") or (myChar:FindFirstChild("Chaser") and "Catcher" or "Runner")
        local enemyRole = enemyChar:GetAttribute("Role") or (enemyChar:FindFirstChild("Chaser") and "Catcher" or "Runner")
        if myRole and enemyRole then
            return myRole ~= enemyRole
        end
    end
    
    return true
end

--------------------------------------------------------------------------------
-- GAME AUTOMATION LOOPS (FIXED)
--------------------------------------------------------------------------------

-- 1. AUTO ATTACK (Target Enemy Runners/Chasers)
task.spawn(function()
    while true do
        task.wait(0.1)
        if FeatureStates["Auto Attack"] then
            pcall(function()
                local myRoot = GetRoot()
                if not myRoot then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if IsEnemy(plr) then
                        local enemyRoot = GetRoot(plr)
                        if enemyRoot then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= 12 then
                                for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                                    if obj:IsA("RemoteEvent") and (obj.Name:lower():find("catch") or obj.Name:lower():find("attack") or obj.Name:lower():find("hit")) then
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

-- 2. AUTO DODGE (FIXED: Uses CFrame RightVector)
task.spawn(function()
    while true do
        task.wait(0.08)
        if FeatureStates["Auto Dodge"] then
            pcall(function()
                local myRoot = GetRoot()
                if not myRoot then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if IsEnemy(plr) then
                        local enemyRoot = GetRoot(plr)
                        if enemyRoot then
                            local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                            if dist <= 9 then
                                -- Properly dodge using character's right vector
                                local rightDir = myRoot.CFrame.RightVector
                                local dodgeOffset = rightDir * (math.random() > 0.5 and 14 or -14)
                                myRoot.CFrame = myRoot.CFrame + dodgeOffset
                                task.wait(0.35)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO RUN (MOVES TOWARD GOAL)
task.spawn(function()
    while true do
        task.wait(0.15)
        if FeatureStates["Auto Run"] then
            pcall(function()
                local hum = GetHumanoid()
                local myRoot = GetRoot()
                if not hum or not myRoot then return end

                local finishPos = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("finish") or obj.Name:lower():find("escape") or obj.Name:lower():find("goal")) then
                        finishPos = obj.Position
                        break
                    end
                end

                if finishPos then
                    hum:MoveTo(finishPos)
                else
                    hum:MoveTo(myRoot.Position + (myRoot.CFrame.LookVector * 20))
                end
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- UI FRAMEWORK & PANELS
--------------------------------------------------------------------------------
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 80, 0, 32)
OpenBtn.Position = UDim2.new(0, 15, 0.35, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
OpenBtn.Text = "KEN HUB"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 11
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = KenHubUI
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)

-- Key System Frame
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 280, 0, 160)
KeyFrame.Position = UDim2.new(0.5, -140, 0.5, -80)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KenHubUI
Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)

local KeyTitle = Instance.new("TextLabel")
KeyTitle.Size = UDim2.new(1, 0, 0, 35)
KeyTitle.BackgroundTransparency = 1
KeyTitle.Text = "KEN HUB - KEY SYSTEM"
KeyTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyTitle.TextSize = 12
KeyTitle.Font = Enum.Font.GothamBold
KeyTitle.Parent = KeyFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 32)
KeyInput.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
KeyInput.PlaceholderText = "Enter Key (KEN-HUB-2026)..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 11
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 32)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 11
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = KenHubUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Stats Label
local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -20, 0, 25)
StatsLabel.Position = UDim2.new(0, 10, 0, 5)
StatsLabel.BackgroundTransparency = 1
StatsLabel.Text = "FPS: 60 | Ping: 0 ms"
StatsLabel.TextColor3 = Color3.fromRGB(180, 190, 200)
StatsLabel.TextSize = 10
StatsLabel.Font = Enum.Font.GothamBold
StatsLabel.Parent = MainFrame

-- Toggles Container
local ToggleContainer = Instance.new("Frame")
ToggleContainer.Size = UDim2.new(1, -20, 1, -40)
ToggleContainer.Position = UDim2.new(0, 10, 0, 35)
ToggleContainer.BackgroundTransparency = 1
ToggleContainer.Parent = MainFrame

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0.48, 0, 0, 35)
Grid.CellPadding = UDim2.new(0.04, 0, 0, 8)
Grid.Parent = ToggleContainer

local function createToggle(title)
    FeatureStates[title] = false
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    btn.Text = title .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = ToggleContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function()
        FeatureStates[title] = not FeatureStates[title]
        if FeatureStates[title] then
            btn.Text = title .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.Text = title .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        end
    end)
end

createToggle("Auto Attack")
createToggle("Auto Dodge")
createToggle("Auto Run")

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

OpenBtn.MouseButton1Click:Connect(function()
    if not KeyFrame.Visible then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        VerifyBtn.Text = "INVALID KEY"
        task.wait(1)
        VerifyBtn.Text = "VERIFY KEY"
    end
end)
