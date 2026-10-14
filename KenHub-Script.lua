-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Safe UI Parent (Fallback to PlayerGui for Mobile Executions)
local TargetParent = PlayerGui
pcall(function()
    if CoreGui then TargetParent = CoreGui end
end)

-- Remove old UI instance if re-executing
if TargetParent:FindFirstChild("KenHubUI") then
    TargetParent.KenHubUI:Destroy()
end

local KenHubUI = Instance.new("ScreenGui")
KenHubUI.Name = "KenHubUI"
KenHubUI.Parent = TargetParent
KenHubUI.ResetOnSpawn = false

-- Config
local CORRECT_KEY = "KEN-HUB-2026"
local FeatureStates = {}
local ActiveAccent = Color3.fromRGB(0, 195, 255)

--------------------------------------------------------------------------------
-- 1. FLOATING MOBILE TOGGLE BUTTON (Always Visible)
--------------------------------------------------------------------------------
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "KenHubMobileToggle"
ToggleBtn.Size = UDim2.new(0, 80, 0, 32)
ToggleBtn.Position = UDim2.new(0, 15, 0.4, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
ToggleBtn.Text = "KEN HUB"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 11
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = KenHubUI

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)
local ToggleStroke = Instance.new("UIStroke", ToggleBtn)
ToggleStroke.Thickness = 2
ToggleStroke.Color = ActiveAccent

--------------------------------------------------------------------------------
-- 2. KEY SYSTEM FRAME (Forced Center & Visible)
--------------------------------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Name = "KeyFrame"
KeyFrame.Size = UDim2.new(0, 300, 0, 170)
KeyFrame.Position = UDim2.new(0.5, -150, 0.5, -85)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Visible = true
KeyFrame.Parent = KenHubUI

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Thickness = 2
KeyStroke.Color = ActiveAccent

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
KeyInput.Position = UDim2.new(0.075, 0, 0.32, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
KeyInput.PlaceholderText = "Enter Key (KEN-HUB-2026)..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 12
KeyInput.Font = Enum.Font.Gotham
KeyInput.Parent = KeyFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 6)

local VerifyBtn = Instance.new("TextButton")
VerifyBtn.Size = UDim2.new(0.85, 0, 0, 35)
VerifyBtn.Position = UDim2.new(0.075, 0, 0.62, 0)
VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
VerifyBtn.Text = "VERIFY KEY"
VerifyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
VerifyBtn.TextSize = 12
VerifyBtn.Font = Enum.Font.GothamBold
VerifyBtn.Parent = KeyFrame
Instance.new("UICorner", VerifyBtn).CornerRadius = UDim.new(0, 6)

--------------------------------------------------------------------------------
-- 3. MAIN HUB FRAME (Sized for Mobile Screens)
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 220)
MainFrame.Position = UDim2.new(0.5, -170, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = KenHubUI

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
MainStroke.Color = ActiveAccent

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, -10, 0, 30)
Header.Position = UDim2.new(0, 10, 0, 5)
Header.BackgroundTransparency = 1
Header.Text = "KEN HUB - ACTIVE"
Header.TextColor3 = Color3.fromRGB(255, 255, 255)
Header.TextSize = 13
Header.Font = Enum.Font.GothamBold
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = MainFrame

-- Mobile Toggle Handler
ToggleBtn.MouseButton1Click:Connect(function()
    if KeyFrame.Visible then
        KeyFrame.Visible = false
    else
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Verification
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
