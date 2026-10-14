-- Services
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")

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
local ToggleKeybind = Enum.KeyCode.RightControl
local ListeningForKeybind = false

-- Theme Palettes
local Themes = {
    ["Neon Blue"] = Color3.fromRGB(0, 195, 255),
    ["Dark Acrylic"] = Color3.fromRGB(150, 150, 150),
    ["Amber Gold"] = Color3.fromRGB(255, 170, 0),
    ["Sunset Pink"] = Color3.fromRGB(255, 85, 127),
    ["Emerald Green"] = Color3.fromRGB(0, 230, 120)
}
local ActiveAccent = Themes["Neon Blue"]
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
-- 1. CONFIG SAVING & LOADING (JSON System)
--------------------------------------------------------------------------------
local ConfigFileName = "KenHub_Config.json"

local function SaveConfig()
    if writefile then
        local data = {
            ThemeColor = {ActiveAccent.R, ActiveAccent.G, ActiveAccent.B},
            Keybind = ToggleKeybind.Name,
            Toggles = FeatureStates
        }
        pcall(function()
            writefile(ConfigFileName, HttpService:JSONEncode(data))
        end)
    end
end

local function LoadConfig()
    if readfile and isfile and isfile(ConfigFileName) then
        pcall(function()
            local raw = readfile(ConfigFileName)
            local data = HttpService:JSONDecode(raw)
            if data then
                if data.ThemeColor then
                    ApplyTheme(Color3.new(data.ThemeColor[1], data.ThemeColor[2], data.ThemeColor[3]))
                end
                if data.Keybind and Enum.KeyCode[data.Keybind] then
                    ToggleKeybind = Enum.KeyCode[data.Keybind]
                end
            end
        end)
    end
end

--------------------------------------------------------------------------------
-- 2. NOTIFICATION SYSTEM
--------------------------------------------------------------------------------
local NotifyContainer = Instance.new("Frame")
NotifyContainer.Size = UDim2.new(0, 220, 1, -20)
NotifyContainer.Position = UDim2.new(1, -230, 0, 10)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.Parent = KenHubUI

local NotifyList = Instance.new("UIListLayout")
NotifyList.SortOrder = Enum.SortOrder.LayoutOrder
NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyList.Padding = UDim.new(0, 8)
NotifyList.Parent = NotifyContainer

local function Notify(title, message)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 45)
    card.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    card.Parent = NotifyContainer

    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", card)
    stroke.Thickness = 1.5
    RegisterStroke(stroke)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -10, 0, 18)
    titleLbl.Position = UDim2.new(0, 8, 0, 4)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = ActiveAccent
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -10, 0, 18)
    msgLbl.Position = UDim2.new(0, 8, 0, 22)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = Color3.fromRGB(200, 210, 220)
    msgLbl.TextSize = 10
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.Parent = card

    task.delay(3, function()
        TweenService:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(msgLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        task.wait(0.3)
        card:Destroy()
    end)
end

--------------------------------------------------------------------------------
-- 3. KEY SYSTEM UI
--------------------------------------------------------------------------------
local KeyFrame = Instance.new("Frame")
KeyFrame.Size = UDim2.new(0, 320, 0, 180)
KeyFrame.Position = UDim2.new(0.5, -160, 0.5, -90)
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
-- 4. MAIN HUB FRAME & NAVIGATION
--------------------------------------------------------------------------------
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 580, 0, 340)
MainFrame.Position = UDim2.new(0.5, -290, 0.5, -170)
MainFrame.BackgroundTransparency = 1
MainFrame.Visible = false
MainFrame.Parent = KenHubUI

-- Floating Restore Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 90, 0, 35)
OpenBtn.Position = UDim2.new(0, 20, 0.5, -17)
OpenBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
OpenBtn.Text = "KEN HUB"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.TextSize = 11
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Visible = false
OpenBtn.Parent = KenHubUI

Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
local OpenStroke = Instance.new("UIStroke", OpenBtn)
OpenStroke.Thickness = 2
RegisterStroke(OpenStroke)

-- Left Sidebar
local LeftPanel = Instance.new("Frame")
LeftPanel.Size = UDim2.new(0, 160, 1, 0)
LeftPanel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
LeftPanel.Active = true
LeftPanel.Draggable = true
LeftPanel.Parent = MainFrame
Instance.new("UICorner", LeftPanel).CornerRadius = UDim.new(0, 10)
local LeftStroke = Instance.new("UIStroke", LeftPanel)
LeftStroke.Thickness = 2
RegisterStroke(LeftStroke)

local BrandText = Instance.new("TextLabel")
BrandText.Size = UDim2.new(1, -20, 0, 30)
BrandText.Position = UDim2.new(0, 15, 0, 10)
BrandText.BackgroundTransparency = 1
BrandText.Text = "KEN HUB"
BrandText.TextColor3 = Color3.fromRGB(255, 255, 255)
BrandText.TextSize = 14
BrandText.Font = Enum.Font.GothamBold
BrandText.TextXAlignment = Enum.TextXAlignment.Left
BrandText.Parent = LeftPanel

local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -20, 0, 120)
TabContainer.Position = UDim2.new(0, 10, 0, 45)
TabContainer.BackgroundTransparency = 1
TabContainer.Parent = LeftPanel

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 6)
TabList.Parent = TabContainer

-- Player Status Summary Box
local PlayerStatusBox = Instance.new("Frame")
PlayerStatusBox.Size = UDim2.new(1, -20, 0, 130)
PlayerStatusBox.Position = UDim2.new(0, 10, 1, -140)
PlayerStatusBox.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
PlayerStatusBox.Parent = LeftPanel
Instance.new("UICorner", PlayerStatusBox).CornerRadius = UDim.new(0, 8)

local StatusName = Instance.new("TextLabel")
StatusName.Size = UDim2.new(1, -10, 0, 18)
StatusName.Position = UDim2.new(0, 5, 0, 5)
StatusName.BackgroundTransparency = 1
StatusName.Text = "User: " .. LocalPlayer.DisplayName
StatusName.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusName.TextSize = 10
StatusName.Font = Enum.Font.GothamBold
StatusName.TextXAlignment = Enum.TextXAlignment.Left
StatusName.Parent = PlayerStatusBox

local StatusHealth = Instance.new("TextLabel")
StatusHealth.Size = UDim2.new(1, -10, 0, 18)
StatusHealth.Position = UDim2.new(0, 5, 0, 25)
StatusHealth.BackgroundTransparency = 1
StatusHealth.Text = "HP: 100 / 100"
StatusHealth.TextColor3 = Color3.fromRGB(0, 220, 120)
StatusHealth.TextSize = 10
StatusHealth.Font = Enum.Font.Gotham
StatusHealth.TextXAlignment = Enum.TextXAlignment.Left
StatusHealth.Parent = PlayerStatusBox

local MetricsLabel = Instance.new("TextLabel")
MetricsLabel.Size = UDim2.new(1, -10, 0, 35)
MetricsLabel.Position = UDim2.new(0, 5, 0, 50)
MetricsLabel.BackgroundTransparency = 1
MetricsLabel.Text = "FPS: 60\nPing: 0 ms"
MetricsLabel.TextColor3 = Color3.fromRGB(180, 190, 200)
MetricsLabel.TextSize = 10
MetricsLabel.Font = Enum.Font.Gotham
MetricsLabel.TextXAlignment = Enum.TextXAlignment.Left
MetricsLabel.Parent = PlayerStatusBox

-- Right Panel
local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(0, 405, 1, 0)
RightPanel.Position = UDim2.new(0, 170, 0, 0)
RightPanel.BackgroundColor3 = Color3.fromRGB(12, 14, 18)
RightPanel.Active = true
RightPanel.Draggable = true
RightPanel.Parent = MainFrame
Instance.new("UICorner", RightPanel).CornerRadius = UDim.new(0, 10)
local RightStroke = Instance.new("UIStroke", RightPanel)
RightStroke.Thickness = 2
RegisterStroke(RightStroke)

-- Header Action Buttons (Minimize & Close)
local HeaderButtons = Instance.new("Frame")
HeaderButtons.Size = UDim2.new(0, 50, 0, 25)
HeaderButtons.Position = UDim2.new(1, -55, 0, 8)
HeaderButtons.BackgroundTransparency = 1
HeaderButtons.Parent = RightPanel

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(2
    local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 22, 0, 22)
MinimizeBtn.Position = UDim2.new(0, 0, 0, 0)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(24, 28, 36)
MinimizeBtn.Text = "-"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
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

-- Keybind Rebinding & Listener
UserInputService.InputBegan:Connect(function(input, gpe)
    if ListeningForKeybind and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
        ToggleKeybind = input.KeyCode
        ListeningForKeybind = false
        Notify("Keybind Updated", "Toggle Key set to: " .. input.KeyCode.Name)
        SaveConfig()
    elseif not gpe and input.KeyCode == ToggleKeybind then
        MainFrame.Visible = not MainFrame.Visible
        OpenBtn.Visible = not MainFrame.Visible
    end
end)

-- Tab Controller
local TabPages = {}
local TabButtons = {}

local function CreateTabPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -50)
    page.Position = UDim2.new(0, 10, 0, 40)
    page.BackgroundTransparency = 1
    page.ScrollBarThickness = 0
    page.Visible = false
    page.Parent = RightPanel

    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.485, 0, 0, 38)
    grid.CellPadding = UDim2.new(0.03, 0, 0, 8)
    grid.Parent = page

    TabPages[name] = page
    return page
end

local MainTab = CreateTabPage("Main")
local StatsTab = CreateTabPage("Stats")
local SettingsTab = CreateTabPage("Settings")
MainTab.Visible = true

local function CreateTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = (name == "Main") and Color3.fromRGB(0, 180, 240) or Color3.fromRGB(18, 22, 28)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for tabName, page in pairs(TabPages) do
            page.Visible = (tabName == name)
            TabButtons[tabName].BackgroundColor3 = (tabName == name) and Color3.fromRGB(0, 180, 240) or Color3.fromRGB(18, 22, 28)
        end
    end)
end

CreateTabButton("Main")
CreateTabButton("Stats")
CreateTabButton("Settings")

--------------------------------------------------------------------------------
-- 5. SETTINGS CONTROLS (Theme Picker, Keybind Rebinder, Save Config)
--------------------------------------------------------------------------------
local RebindBtn = Instance.new("TextButton")
RebindBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
RebindBtn.Text = "Rebind Key (Press)"
RebindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RebindBtn.TextSize = 11
RebindBtn.Font = Enum.Font.GothamBold
RebindBtn.Parent = SettingsTab
Instance.new("UICorner", RebindBtn).CornerRadius = UDim.new(0, 6)

RebindBtn.MouseButton1Click:Connect(function()
    ListeningForKeybind = true
    Notify("Rebinder", "Press any key to set your new toggle keybind...")
end)

local SaveBtn = Instance.new("TextButton")
SaveBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
SaveBtn.Text = "Save Config"
SaveBtn.TextColor3 = Color3.fromRGB(0, 200, 100)
SaveBtn.TextSize = 11
SaveBtn.Font = Enum.Font.GothamBold
SaveBtn.Parent = SettingsTab
Instance.new("UICorner", SaveBtn).CornerRadius = UDim.new(0, 6)

SaveBtn.MouseButton1Click:Connect(function()
    SaveConfig()
    Notify("Config System", "Settings saved successfully!")
end)

for themeName, color in pairs(Themes) do
    local themeBtn = Instance.new("TextButton")
    themeBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
    themeBtn.Text = "Theme: " .. themeName
    themeBtn.TextColor3 = color
    themeBtn.TextSize = 11
    themeBtn.Font = Enum.Font.GothamBold
    themeBtn.Parent = SettingsTab
    Instance.new("UICorner", themeBtn).CornerRadius = UDim.new(0, 6)

    themeBtn.MouseButton1Click:Connect(function()
        ApplyTheme(color)
        SaveConfig()
        Notify("Theme Manager", "Switched accent to " .. themeName)
    end)
end

--------------------------------------------------------------------------------
-- 6. STANDALONE OVERLAY WIDGET
--------------------------------------------------------------------------------
local StatsWidget = Instance.new("Frame")
StatsWidget.Size = UDim2.new(0, 160, 0, 55)
StatsWidget.Position = UDim2.new(0, 20, 0, 20)
StatsWidget.BackgroundColor3 = Color3.fromRGB(18, 22, 28)
StatsWidget.Active = true
StatsWidget.Draggable = true
StatsWidget.Parent = KenHubUI

Instance.new("UICorner", StatsWidget).CornerRadius = UDim.new(0, 8)
local WidgetStroke = Instance.new("UIStroke", StatsWidget)
WidgetStroke.Thickness = 1.5
RegisterStroke(WidgetStroke)

local WidgetTitle = Instance.new("TextLabel")
WidgetTitle.Size = UDim2.new(1, -10, 0, 18)
WidgetTitle.Position = UDim2.new(0, 8, 0, 4)
WidgetTitle.BackgroundTransparency = 1
WidgetTitle.Text = "STATS OVERLAY"
WidgetTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
WidgetTitle.TextSize = 10
WidgetTitle.Font = Enum.Font.GothamBold
WidgetTitle.TextXAlignment = Enum.TextXAlignment.Left
WidgetTitle.Parent = StatsWidget

local WidgetMetrics = Instance.new("TextLabel")
WidgetMetrics.Size = UDim2.new(1, -10, 0, 26)
WidgetMetrics.Position = UDim2.new(0, 8, 0, 22)
WidgetMetrics.BackgroundTransparency = 1
WidgetMetrics.Text = "FPS: 60  |  Ping: 0 ms"
WidgetMetrics.TextColor3 = Color3.fromRGB(180, 190, 200)
WidgetMetrics.TextSize = 10
WidgetMetrics.Font = Enum.Font.Gotham
WidgetMetrics.TextXAlignment = Enum.TextXAlignment.Left
WidgetMetrics.Parent = StatsWidget

--------------------------------------------------------------------------------
-- 7. PERFORMANCE TRACKER & REALTIME UPDATES
--------------------------------------------------------------------------------
local FrameCount = 0
local LastTime = tick()

RunService.RenderStepped:Connect(function()
    FrameCount = FrameCount + 1
    local CurrentTime = tick()
    
    if CurrentTime - LastTime >= 1 then
        local fps = math.floor(FrameCount / (CurrentTime - LastTime))
        local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
        
        local statsStr = string.format("FPS: %d  |  Ping: %d ms", fps, ping)
        MetricsLabel.Text = string.format("FPS: %d\nPing: %d ms", fps, ping)
        WidgetMetrics.Text = statsStr

        FrameCount = 0
        LastTime = CurrentTime
    end

    local hum = GetHumanoid()
    if hum then
        StatusHealth.Text = string.format("HP: %d / %d", math.floor(hum.Health), math.floor(hum.MaxHealth))
    else
        StatusHealth.Text = "HP: N/A"
    end
end)

--------------------------------------------------------------------------------
-- 8. VERIFICATION & INIT
--------------------------------------------------------------------------------
VerifyBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == CORRECT_KEY then
        VerifyBtn.Text = "SUCCESS!"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        task.wait(0.5)
        KeyFrame.Visible = false
        MainFrame.Visible = true
        LoadConfig()
        Notify("Ken Hub", "Welcome! Current keybind: " .. ToggleKeybind.Name)
    else
        VerifyBtn.Text = "INVALID KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        task.wait(1)
        VerifyBtn.Text = "VERIFY KEY"
        VerifyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 240)
    end
end)
    
