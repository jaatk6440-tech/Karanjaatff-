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

-- Safe Parent Target
local TargetParent = PlayerGui
pcall(function()
    if CoreGui then TargetParent = CoreGui end
end)

-- Remove existing instance
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
local ToggleKeybind = Enum.KeyCode.RightControl
local ActiveAccent = Color3.fromRGB(0, 195, 255)

local Themes = {
    ["Neon Blue"] = Color3.fromRGB(0, 195, 255),
    ["Dark Acrylic"] = Color3.fromRGB(150, 150, 150),
    ["Amber Gold"] = Color3.fromRGB(255, 170, 0),
    ["Sunset Pink"] = Color3.fromRGB(255, 85, 127),
    ["Emerald Green"] = Color3.fromRGB(0, 230, 120)
}

local DynamicStrokes = {}

local function RegisterStroke(stroke)
    table.insert(DynamicStrokes, stroke)
    stroke.Color = ActiveAccent
end

local function ApplyTheme(color)
    ActiveAccent = color
    for _, stroke in ipairs(DynamicStrokes) do
        if stroke and stroke.Parent then
            stroke.Color = color
        end
    end
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

--------------------------------------------------------------------------------
-- 1. NOTIFICATION SYSTEM
--------------------------------------------------------------------------------
local NotifyContainer = Instance.new("Frame")
NotifyContainer.Size = UDim2.new(0, 200, 1, -20)
NotifyContainer.Position = UDim2.new(1, -210, 0, 10)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = KenHubUI

local NotifyList = Instance.new("UIListLayout")
NotifyList.SortOrder = Enum.SortOrder.LayoutOrder
NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyList.Padding = UDim.new(0, 6)
NotifyList.Parent = NotifyContainer

local function Notify(title, message)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 40)
    card.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    card.Parent = NotifyContainer

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", card)
    stroke.Thickness = 1.5
    RegisterStroke(stroke)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -10, 0, 16)
    titleLbl.Position = UDim2.new(0, 8, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = ActiveAccent
    titleLbl.TextSize = 10
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -10, 0, 16)
    msgLbl.Position = UDim2.new(0, 8, 0, 20)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Color3.fromRGB(200, 210, 220)
    msgLbl.TextSize = 9
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.Parent = card

    task.delay(3, function()
        pcall(function()
            TweenService:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
            TweenService:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            TweenService:Create(msgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
            task.wait(0.3)
            card:Destroy()
        end)
    end)
end

--------------------------------------------------------------------------------
-- 2. FLOATING TOGGLE BUTTON (MOBILE)
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
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Thickness = 2
RegisterStroke(OpenStroke)

--------------------------------------------------------------------------------
-- 3. KEY SYSTEM
--------------------------------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 280, 0, 160)
KeyFrame.Position = UDim2.new(0.5, -140, 0.5, -80)
KeyFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
KeyFrame.Active = true
KeyFrame.Draggable = true
KeyFrame.Parent = KenHubUI

Instance.new("UICorner", KeyFrame).CornerRadius = UDim.new(0, 10)
local KeyStroke = Instance.new("UIStroke", KeyFrame)
KeyStroke.Thickness = 2
RegisterStroke(KeyStroke)

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

--------------------------------------------------------------------------------
-- 4. MAIN HUB UI FRAME
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 460, 0, 260)
MainFrame.Position = UDim2.new(0.5, -230, 0.5, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
MainFrame.Parent = KenHubUI

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Thickness = 2
RegisterStroke(MainStroke)

-- Left Sidebar
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 120, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
LeftPanel.Parent = MainFrame
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)

local BrandText = Instance.new("TextLabel")
BrandText.Size = UDim2.new(1, -10, 0, 28)
BrandText.Position = UDim2.new(0, 8, 0, 5)
BrandText.BackgroundTransparency = 1
BrandText.Text = "KEN HUB"
BrandText.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandText.TextSize = 12
BrandText.Font = Enum.Font.GothamBold
BrandText.TextXAlignment = Enum.TextXAlignment.Left
BrandText.Parent = LeftPanel

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -10, 1, -40)
TabContainer.Position = UDim2.new(0, 5, 0, 35)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = LeftPanel

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 5)
TabList.Parent = TabContainer

-- Right Display Panel
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -130, 1, -10)
RightPanel.Position = UDim2.new(0, 125, 0, 5)
RightPanel.BackgroundTransparency = 1
RightPanel.Parent = MainFrame

-- Minimize & Close Buttons
local HeaderButtons = Instance.new("Frame")
HeaderButtons.Size = UDim2.new(0, 50, 0, 22)
HeaderButtons.Position = UDim2.new(1, -52, 0, 2)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Parent = RightPanel

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 20, 0, 20)
MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.TextSize = 12
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.Parent = HeaderButtons
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(0, 4)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(0, 24, 0, 0)
CloseBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(220, 60, 60)
CloseBtn.TextSize = 10
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = HeaderButtons
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

MinimizeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

OpenBtn.MouseButton1Click:Connect(function()
    if KeyFrame.Visible then
        KeyFrame.Visible = false
    else
        MainFrame.Visible = not MainFrame.Visible
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    KenHubUI:Destroy()
end)

-- Tab Page Controller
local TabPages = {}
local TabButtons = {}

local function CreateTabPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, -25)
    page.Position = UDim2.new(0, 0, 0, 25)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 2
    page.Visible = false
    page.Parent = RightPanel

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.48, 0, 0, 32)
    grid.CellPadding = UDim2.new(0.03, 0, 0, 6)
    grid.Parent = page

    TabPages[name] = page
    return page
end

local MainTab = CreateTabPage("Main")
local TeamsTab = CreateTabPage("Teams")
local SettingsTab = CreateTabPage("Settings")
MainTab.Visible = true

local function CreateTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 26)
    btn.BackgroundColor3 = (name == "Main") and Color3.fromRGB(0, 180, 240) or Color3.fromRGB(24, 28, 36)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 10
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for tabName, page in pairs(TabPages) do
            page.Visible = (tabName == name)
            TabButtons[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(0, 180, 240) or Color3.fromRGB(24, 28, 36)
        end
    end)
end

CreateTabButton("Main")
CreateTabButton("Teams")
CreateTabButton("Settings")

--------------------------------------------------------------------------------
-- 5. TOGGLE CREATOR
--------------------------------------------------------------------------------
local function createToggle(parentPage, title, defaultState)
    FeatureStates[title] = defaultState

    local toggleCard = Instance.new("Frame")
    toggleCard.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    toggleCard.Parent = parentPage
    Instance.new("UICorner", toggleCard).CornerRadius = UDim.new(0, 5)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -40, 1, 0)
    titleLabel.Position = UDim2.new(0, 8, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(220, 230, 240)
    titleLabel.TextSize = 10
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = toggleCard

    local switchBtn = Instance.new("TextButton")
    switchBtn.Size = UDim2.new(0, 28, 0, 16)
    switchBtn.Position = UDim2.new(1, -32, 0.5, -8)
    switchBtn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 55, 65)
    switchBtn.Text = ""
    switchBtn.Parent = toggleCard
    Instance.new("UICorner", switchBtn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 12, 0, 12)
    knob.Position = defaultState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = switchBtn
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    switchBtn.MouseButton1Click:Connect(function()
        FeatureStates[title] = not FeatureStates[title]
        local isEnabled = FeatureStates[title]

        if isEnabled then
            TweenService:Create(switchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 200, 100)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(1, -14, 0.5, -6)}):Play()
            Notify(title, "Enabled")
        else
            TweenService:Create(switchBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 55, 65)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.15), {Position = UDim2.new(0, 2, 0.5, -6)}):Play()
            Notify(title, "Disabled")
        end
    end)
end

-- Toggles
createToggle(MainTab, "Auto Dodge", true)
createToggle(MainTab, "Speed Boost", false)
createToggle(MainTab, "Auto Attack", false)
createToggle(MainTab, "Auto Pick", true)

createToggle(TeamsTab, "Highlight Runners", false)
createToggle(TeamsTab, "Highlight Catchers", false)
createToggle(TeamsTab, "Catcher Radar", false)

-- Theme Pickers in Settings
for themeName, color in pairs(Themes) do
    local themeBtn = Instance.new("TextButton")
    themeBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
    themeBtn.Text = themeName
    themeBtn.TextColor3 = color
    themeBtn.TextSize = 10
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.Parent = SettingsTab
    Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 5)

    themeBtn.MouseButton1Click:Connect(function()
        ApplyTheme(color)
        Notify("Theme", "Set to " .. themeName)
    end)
end

--------------------------------------------------------------------------------
-- 6. VERIFICATION
--------------------------------------------------------------------------------
VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        VerifyBtn.Text = "SUCCESS!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(0.4)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        Notify("Ken Hub", "Welcome!")
    else
        VerifyBtn.Text = "INVALID KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        task.wait(1)
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
    end
end)
