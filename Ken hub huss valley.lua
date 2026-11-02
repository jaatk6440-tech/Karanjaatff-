-- Ken Hub v.2 | Advanced Game Automation Module
-- Clean Unload System
if getgenv().KenHubUnload then
    pcall(getgenv().KenHubUnload)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local IS_MOBILE = UserInputService.TouchEnabled
local UTILITY_INTERVAL = IS_MOBILE and 0.4 or 0.2

-- Core Loader State
local Hub = {
    genv = (getgenv and getgenv()) or _G,
    registry = {},
    cleaned = false,
}

-- Re-executing unloads previous instance cleanly
local previousUnload = Hub.genv.KenHubUnload or Hub.genv.InfernohubUnload or Hub.genv.HussValleyUnload
if previousUnload then
    pcall(previousUnload)
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(520, 860)
local windowWidth = math.max(280, math.min(520, viewport.X - 24))
local windowHeight = math.max(360, math.min(860, viewport.Y - 48))

local Window = WindUI:CreateWindow({
    Title = "Ken Hub v.2",
    Icon = "flame",
    Author = "Ken Hub Team",
    Folder = "KenHubV2",
    Size = UDim2.fromOffset(windowWidth, windowHeight),
    Transparent = true,
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightShift,
})

Window:Tag({Title = "Ken Hub v.2", Color = Color3.fromRGB(255, 90, 30)})

-- Engine State Management
local Engine = {
    RunnerEnabled = true,
    CatcherEnabled = true,
    AutoDash = true,
    AutoRevive = true,
    AutoGems = true,
    AvoidThreats = true,
    SpeedMultiplier = 1.0,
    CatcherSpeedMultiplier = 1.0,
    TargetPrediction = 0.5,
    AvoidanceStrength = 2.0,
    LastStep = os.clock(),
    Threats = {},
    CurrentTarget = nil,
}

-- Function Modules Engine
local Functions = {}

function Functions.getCharacter(player)
    return (player or LocalPlayer).Character
end

function Functions.getHumanoid(player)
    local char = Functions.getCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid") or nil
end

function Functions.getRoot(player)
    local char = Functions.getCharacter(player)
    return char and char:FindFirstChild("HumanoidRootPart") or nil
end

function Functions.flatVector(vec)
    return Vector3.new(vec.X, 0, vec.Z)
end

-- Upgraded Threat Vector Computation
function Functions.computeThreatVectors(origin)
    table.clear(Engine.Threats)
    local mySpeed = math.max(16 * Engine.SpeedMultiplier, 1)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player:GetAttribute("GameRole") == "Catcher" then
            local enemyRoot = Functions.getRoot(player)
            if enemyRoot then
                local pos = Functions.flatVector(enemyRoot.Position)
                local dist = (pos - origin).Magnitude
                if dist <= 120 then
                    local vel = Functions.flatVector(enemyRoot.AssemblyLinearVelocity)
                    local predictedPos = pos + vel * Engine.TargetPrediction
                    
                    table.insert(Engine.Threats, {
                        Player = player,
                        Position = pos,
                        Velocity = vel,
                        Predicted = predictedPos,
                        Distance = dist,
                        CollisionRisk = dist < (12 + mySpeed * 0.4),
                    })
                end
            end
        end
    end

    table.sort(Engine.Threats, function(a, b)
        return a.Distance < b.Distance
    end)
    
    return Engine.Threats
end

-- Upgraded Predictive Avoidance Pathing
function Functions.getOptimizedRunnerDirection(origin, goal)
    local desired = Functions.flatVector(goal - origin)
    if desired.Magnitude < 0.05 then return Vector3.zero end
    desired = desired.Unit

    if not Engine.AvoidThreats or #Engine.Threats == 0 then
        return desired
    end

    local bestDirection = desired
    local highestScore = -math.huge

    -- Test multiple ray angles around desired heading
    for angle = -80, 80, 20 do
        local rad = math.rad(angle)
        local cos, sin = math.cos(rad), math.sin(rad)
        local testDir = Vector3.new(desired.X * cos - desired.Z * sin, 0, desired.X * sin + desired.Z * cos).Unit
        
        local progressScore = testDir:Dot(desired) * 10
        local dangerPenalty = 0

        for _, threat in ipairs(Engine.Threats) do
            local threatDir = (threat.Predicted - origin)
            if threatDir.Magnitude > 0.05 then
                local threatUnit = threatDir.Unit
                local dot = testDir:Dot(threatUnit)
                if dot > 0 then
                    dangerPenalty = dangerPenalty + (dot * (40 / math.max(threat.Distance, 1))) * Engine.AvoidanceStrength
                end
            end
        end

        local totalScore = progressScore - dangerPenalty
        if totalScore > highestScore then
            highestScore = totalScore
            bestDirection = testDir
        end
    end

    return bestDirection
end

-- Upgraded Catcher Intercept Algorithm
function Functions.getInterceptionPoint(myPos, targetPlayer)
    local targetRoot = Functions.getRoot(targetPlayer)
    if not targetRoot then return nil end

    local targetPos = Functions.flatVector(targetRoot.Position)
    local targetVel = Functions.flatVector(targetRoot.AssemblyLinearVelocity)
    
    local distance = (targetPos - myPos).Magnitude
    local leadTime = math.clamp(distance / (16 * Engine.CatcherSpeedMultiplier), 0.1, 1.2)
    
    return targetPos + (targetVel * leadTime)
end

-- Upgraded Automation Execution Step
function Functions.processAutomationStep(dt)
    local myRoot = Functions.getRoot()
    local myHum = Functions.getHumanoid()
    if not myRoot or not myHum or myHum.Health <= 0 then return end

    local myPos = Functions.flatVector(myRoot.Position)
    local role = LocalPlayer:GetAttribute("GameRole") or "Runner"

    if role == "Runner" and Engine.RunnerEnabled then
        local threats = Functions.computeThreatVectors(myPos)
        
        -- Default target waypoint (center map simulation / fallback)
        local goalPoint = Vector3.zero 
        local direction = Functions.getOptimizedRunnerDirection(myPos, goalPoint)
        
        if direction.Magnitude > 0.05 then
            myHum:Move(direction, false)
        end

    elseif role == "Catcher" and Engine.CatcherEnabled then
        -- Select closest runner target
        local bestTarget = nil
        local minDistance = math.huge

        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("GameRole") == "Runner" then
                local r = Functions.getRoot(player)
                if r then
                    local d = (Functions.flatVector(r.Position) - myPos).Magnitude
                    if d < minDistance then
                        minDistance = d
                        bestTarget = player
                    end
                end
            end
        end

        Engine.CurrentTarget = bestTarget

        if bestTarget then
            local interceptPoint = Functions.getInterceptionPoint(myPos, bestTarget)
            if interceptPoint then
                local moveDir = (interceptPoint - myPos)
                if moveDir.Magnitude > 0.05 then
                    myHum:Move(moveDir.Unit, false)
                end
            end
        end
    end
end

-- Global Unload System
Hub.cleanup = function()
    if Hub.cleaned then return end
    Hub.cleaned = true
    if Hub.genv.KenHubUnload == Hub.cleanup then
        Hub.genv.KenHubUnload = nil
    end
    pcall(function() Window:Destroy() end)
end

Hub.genv.KenHubUnload = Hub.cleanup
pcall(function()
    Window:OnDestroy(function()
        Hub.cleanup()
    end)
end)

--------------------------------------------------------------------
-- UI TAB SETUP
--------------------------------------------------------------------
local RunnerTab = Window:Tab({ Title = "Runner Engine v2", Icon = "footprints" })
local CatcherTab = Window:Tab({ Title = "Catcher Engine v2", Icon = "crosshair" })
local CommunityTab = Window:Tab({ Title = "Community", Icon = "users" })
local SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings" })

-- Runner Controls
RunnerTab:Section({ Title = "Automated Pathing" })
RunnerTab:Toggle({
    Title = "Enable Auto Run & Avoidance",
    Desc = "Executes upgraded multi-ray threat prediction engine",
    Value = true,
    Callback = function(state) Engine.RunnerEnabled = state end,
})

RunnerTab:Slider({
    Title = "Avoidance Sensitivity",
    Step = 0.1,
    Value = { Min = 0.5, Max = 4.0, Default = 2.0 },
    Callback = function(val) Engine.AvoidanceStrength = tonumber(val) or 2.0 end,
})

RunnerTab:Slider({
    Title = "Speed Multiplier",
    Step = 0.1,
    Value = { Min = 1.0, Max = 2.0, Default = 1.0 },
    Callback = function(val) Engine.SpeedMultiplier = tonumber(val) or 1.0 end,
})

-- Catcher Controls
CatcherTab:Section({ Title = "Target Interception" })
CatcherTab:Toggle({
    Title = "Enable Smart Intercept",
    Desc = "Calculates predictive intercept coordinates based on target velocity",
    Value = true,
    Callback = function(state) Engine.CatcherEnabled = state end,
})

CatcherTab:Slider({
    Title = "Prediction Lead Time",
    Step = 0.05,
    Value = { Min = 0.1, Max = 1.0, Default = 0.5 },
    Callback = function(val) Engine.TargetPrediction = tonumber(val) or 0.5 end,
})

-- Community Links
CommunityTab:Section({ Title = "Official Socials" })
CommunityTab:Button({
    Title = "Copy Discord Link",
    Desc = "https://discord.gg/ymuCsJRM7",
    Icon = "message-square",
    Callback = function()
        if setclipboard then
            setclipboard("https://discord.gg/ymuCsJRM7")
            WindUI:Notify({ Title = "Ken Hub", Content = "Discord link copied!", Duration = 2.5, Icon = "check" })
        end
    end,
})

CommunityTab:Button({
    Title = "Copy YouTube Channel",
    Desc = "https://youtube.com/@karan01-0",
    Icon = "video",
    Callback = function()
        if setclipboard then
            setclipboard("https://youtube.com/@karan01-0?si=bBMiBtFpBji-h-Fb")
            WindUI:Notify({ Title = "Ken Hub", Content = "YouTube link copied!", Duration = 2.5, Icon = "check" })
        end
    end,
})

-- Settings
SettingsTab:Section({ Title = "Hub Management" })
SettingsTab:Button({
    Title = "Unload Script",
    Desc = "Shuts down engine processes and safely removes UI instance",
    Icon = "power",
    Callback = function() Hub.cleanup() end,
})

-- Main Execution Engine Loop
RunService.Stepped:Connect(function(_, dt)
    if not Hub.cleaned then
        pcall(Functions.processAutomationStep, dt)
    end
end)

WindUI:Notify({
    Title = "Ken Hub v.2",
    Content = "All core functions updated successfully!",
    Duration = 4,
    Icon = "flame",
})
