-- [[ Ken Hub v.2 - Protected / Obfuscated Release ]] --
local _G_ENV = (getgenv and getgenv()) or _G
if _G_ENV.KenHubUnload then pcall(_G_ENV.KenHubUnload) end

local _U = {
    [string.char(80,108,97,121,101,114,115)] = game:GetService("Players"),
    [string.char(82,117,110,83,101,114,118,105,99,101)] = game:GetService("RunService"),
    [string.char(85,115,101,114,73,110,112,117,116,83,101,114,118,105,99,101)] = game:GetService("UserInputService")
}

local _LP = _U["Players"].LocalPlayer
local _H_REG = {cleaned = false}

local _LOAD_UI = function()
    local _ok, _res = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
    if not _ok then return nil end
    return _res
end

local _WindUI = _LOAD_UI()
if not _WindUI then return end

local _Win = _WindUI:CreateWindow({
    Title = string.char(75,101,110,32,72,117,98,32,118,46,50),
    Icon = string.char(102,108,97,109,101),
    Author = string.char(75,101,110,32,72,117,98,32,84,101,97,109),
    Folder = string.char(75,101,110,72,117,98,86,50),
    Size = UDim2.fromOffset(480, 400),
    Transparent = true,
    Theme = string.char(68,97,114,107),
    ToggleKey = Enum.KeyCode.RightShift,
})

_H_REG.cleanup = function()
    if _H_REG.cleaned then return end
    _H_REG.cleaned = true
    if _G_ENV.KenHubUnload == _H_REG.cleanup then
        _G_ENV.KenHubUnload = nil
    end
    pcall(function() _Win:Destroy() end)
end

_G_ENV.KenHubUnload = _H_REG.cleanup

local _T_Main = _Win:Tab({ Title = string.char(77,97,105,110,32,65,117,116,111,109,97,116,105,111,110), Icon = string.char(112,108,97,121) })
local _T_Comm = _Win:Tab({ Title = string.char(67,111,109,109,117,110,105,116,121), Icon = string.char(117,115,101,114,115) })
local _T_Set  = _Win:Tab({ Title = string.char(83,101,116,116,105,110,103,115), Icon = string.char(115,101,116,116,105,110,103,115) })

_T_Main:Section({ Title = string.char(67,111,114,101,32,69,110,103,105,110,101) })
_T_Main:Toggle({
    Title = string.char(69,110,97,98,108,101,32,65,117,116,111,32,82,117,110),
    Value = true,
    Callback = function(v)
        _G_ENV.__KenAuto = v
    end
})

_T_Comm:Section({ Title = string.char(83,111,99,105,97,108,115) })
_T_Comm:Button({
    Title = string.char(67,111,112,121,32,68,105,115,99,111,114,100),
    Callback = function()
        if setclipboard then
            setclipboard(string.char(104,116,116,112,115,58,47,47,100,105,115,99,111,114,100,46,103,103,47,121,109,117,67,115,74,82,77,55))
            _WindUI:Notify({ Title = "Ken Hub", Content = "Copied!", Duration = 2 })
        end
    end
})

_T_Set:Section({ Title = "Management" })
_T_Set:Button({
    Title = string.char(85,110,108,111,97,100,32,83,99,114,105,112,116),
    Callback = function()
        _H_REG.cleanup()
    end
})

_U["RunService"].Stepped:Connect(function()
    if _H_REG.cleaned then return end
    if _G_ENV.__KenAuto and _LP.Character then
        local hum = _LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            -- Internal Engine Step Simulation Hook
        end
    end
end)

_WindUI:Notify({
    Title = string.char(75,101,110,32,72,117,98,32,118,46,50),
    Content = string.char(79,98,102,117,115,99,97,116,101,100,32,98,117,105,108,100,32,108,111,97,100,101,100,33),
    Duration = 3,
    Icon = string.char(102,108,97,109,101)
})
