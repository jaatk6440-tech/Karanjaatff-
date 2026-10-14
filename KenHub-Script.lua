-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

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

-- States
local FeatureStates = {
    ["Auto Attack"] = false,
    ["Auto Dodge"] = false,
    ["Auto Run"] = false,
    ["Highlight Runners"] = false,
    ["Highlight Catchers"] = false
}

local CORRECT_KEY = "KEN-HUB-2026"
local ActiveAccent = Color3.fromRGB(0, 195, 255)

--------------------------------------------------------------------------------
-- UTILITIES & GAME STATE DETECTION
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

-- Role Detection specific to Huss Valley
local function GetPlayerRole(plr)
    if not plr or not plr.Character then return "None" end
    -- Check team name or model tags
    if plr.Team and plr.Team.Name:lower():find("chaser") or plr.Team and plr.Team.Name:lower():find("catcher") then
        return "Catcher"
    elseif plr.Team and plr.Team.Name:lower():find("runner") then
        return "Runner"
    end
    
    -- Attribute/Tag fallback check
    if plr.Character:FindFirstChild("Chaser") or plr:GetAttribute("Role") == "Chaser" then
        return "Catcher"
    end
    return "Runner"
end

--------------------------------------------------------------------------------
-- GAME AUTOMATION LOOPS
--------------------------------------------------------------------------------

-- 1. AUTO ATTACK / CATCH
task.spawn(function()
    while true do
        task.wait(0.05)
        if FeatureStates["Auto Attack"] then
            pcall(function()
                local myRoot = GetRoot()
                if not myRoot then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local role = GetPlayerRole(plr)
                        if role == "Runner" or role == "None" then
                            local enemyRoot = GetRoot(plr)
                            if enemyRoot then
                                local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                                if dist <= 12 then
                                    -- Teleport or snap close briefly to ensure tag
                                    myRoot.CFrame = enemyRoot.CFrame * CFrame.new(0, 0, 1)
                                    
                                    -- Fire game catch remotes
                                    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
                                        if obj:IsA("RemoteEvent") and (obj.Name:lower():find("catch") or obj.Name:lower():find("attack") or obj.Name:lower():find("tag") or obj.Name:lower():find("hit")) then
                                            obj:FireServer(plr)
                                            obj:FireServer(plr.Character)
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

-- 2. AUTO DODGE
task.spawn(function()
    while true do
        task.wait(0.05)
        if FeatureStates["Auto Dodge"] then
            pcall(function()
                local myRoot = GetRoot()
                if not myRoot then return end

                for _, plr in pairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer then
                        local role = GetPlayerRole(plr)
                        if role == "Catcher" then
                            local enemyRoot = GetRoot(plr)
                            if enemyRoot then
                                local dist = (myRoot.Position - enemyRoot.Position).Magnitude
                                if dist <= 10 then
                                    -- Instant escape shift away from chaser
                                    local escapeDir = (myRoot.Position - enemyRoot.Position).Unit
                                    myRoot.CFrame = myRoot.CFrame + (escapeDir * 18)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO RUN TO FINISH LINE
task.spawn(function()
    while true do
        task.wait(0.1)
        if FeatureStates["Auto Run"] then
            pcall(function()
                local hum = GetHumanoid()
                local myRoot = GetRoot()
                if not hum or not myRoot then return end

                -- Search workspace for finish line / escape zones
                local finishObj = nil
                for _, obj in pairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and (obj.Name:lower():find("finish") or obj.Name:lower():find("escape") or obj.Name:lower():find("goal") or obj.Name:lower():find("end")) then
                        finishObj = obj
                        break
                    end
                end

                if finishObj then
                    hum:MoveTo(finishObj.Position)
                else
                    -- Arena bound fallback: Huss Valley finish lines are at the positive Z end of the field
                    myRoot.CFrame = myRoot.CFrame + Vector3.new(0, 0, 1.5)
                end
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- UI FRAMEWORK & MOBILE TOGGLES
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
KeyTitle.Text = "KEN HUB - HUSS VALLEY"
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

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 360, 0, 220)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = KenHubUI
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Grid = Instance.new("UIGridLayout")
Grid.CellSize = UDim2.new(0.46, 0, 0, 35)
Grid.CellPadding = UDim2.new(0.04, 0, 0, 8)
Grid.Parent = MainFrame

local function createToggle(title)
    local btn = Instance.new("TextButton")
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    btn.Text = title .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = MainFrame
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
createToggle( "Auto Run")

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
