local RunService = not game and game.GetService and game:GetService("RunService") or game.ClassName ~= "DataModel" or typeof and typeof(game.Players) ~= "Instance"

if not RunService then
	RunService = not (getmetatable and setmetatable and type and pcall and rawget and rawset)
end

if not RunService then
	local fn = cloneref or function(arg)
		return arg
	end

	while true do
		task.wait()
		if not (game:IsLoaded() and game.Players.LocalPlayer:FindFirstChild("DataLoaded")) then
			continue
		end
		break
	end

	local v = fn(game:GetService("Players"))

	if v.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)") then
		if not getgenv().Team or getgenv().Team == "" then
			getgenv().Team = "Pirates"
		end

		local container = v.LocalPlayer.PlayerGui["Main (minimal)"]:WaitForChild("ChooseTeam"):WaitForChild("Container")
		local textButton = nil

		if getgenv().Team == "Pirates" then
			textButton = container:WaitForChild("Pirates"):WaitForChild("Frame"):WaitForChild("TextButton")
		elseif getgenv().Team == "Marines" then
			textButton = container:WaitForChild("Marines"):WaitForChild("Frame"):WaitForChild("TextButton")
		end

		if textButton then
			repeat
				task.wait()

				pcall(function()
					firesignal(textButton.Activated)
				end)
			until not v.LocalPlayer.PlayerGui:FindFirstChild("Main (minimal)")
		end
	end

	repeat
		task.wait()
	until v.LocalPlayer.PlayerGui:FindFirstChild("Main")

	if getgenv().KenHubActive then
		return print("already running")
	end
	getgenv().KenHubActive = true
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]

-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	elseif http and http.request then
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	else
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	end

	local function fn2(arg)
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
			return nil
		end
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	end

	local tbl = {
		AutoAttack = true,
		FastSettings = "Fast Attack",
		FastAttackDelay = 0,
		attackmobs = true,
		BringMonster = true,
		BringMonsterRadius = 250,
		MasteryFarm = false,
		HealthMob = 50,
		HopDelay = 10,
		StopHopEliteIfChalice = true,
	}

	local tbl2 = {
		Services = {},
		Player = {},
		Environment = {},
		Remotes = {},
		Modules = {},
		Preload = {},
		Cache = {},
		Runtime = {},
		Performance = {},
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	}

	setmetatable(tbl2.Services, { __index = function(arg, arg2)
		local ok, result = pcall(game.GetService, game, arg2)

		if ok and result then
			local v2 = fn(result)
			rawset(arg, arg2, v2)
			return v2
		end

		return nil
	end })

	local v2 = fn(game:GetService("Workspace"))
	local v3 = fn(game:GetService("Players"))
	local v4 = fn(game:GetService("ReplicatedStorage"))
	local v5 = fn(game:GetService("CollectionService"))
	local v6 = fn(game:GetService("RunService"))
	local v7 = fn(game:GetService("Lighting"))
	local v8 = fn(game:GetService("VirtualInputManager"))
	local v9 = fn(game:GetService("HttpService"))
	local v10 = fn(game:GetService("UserInputService"))
	local v11 = fn(game:GetService("LogService"))
	local v12 = fn(game:GetService("ScriptContext"))
	local v13 = fn(game:GetService("StarterGui"))
	local v14 = fn(game:GetService("Stats"))
	local v15 = fn(game:GetService("TeleportService"))
	local v16 = fn(game:GetService("GuiService"))
	local v17 = fn(game:GetService("VirtualUser"))
	tbl2.Services.Workspace = v2
	tbl2.Services.Players = v3
	tbl2.Services.ReplicatedStorage = v4
	tbl2.Services.CollectionService = v5
	tbl2.Services.RunService = v6
	tbl2.Services.Lighting = v7
	tbl2.Services.VirtualInputManager = v8
	tbl2.Services.HttpService = v9
	tbl2.Services.UserInputService = v10
	tbl2.Services.LogService = v11
	tbl2.Services.ScriptContext = v12
	tbl2.Services.StarterGui = v13
	tbl2.Services.Stats = v14
	tbl2.Services.TeleportService = v15
	tbl2.Services.GuiService = v16
	tbl2.Services.VirtualUser = v17
	local tbl3 = {}
	local tbl4 = {}
	local obj = setmetatable({}, { __mode = "k" })
	local tbl5 = {}
	local obj2 = setmetatable({}, { __mode = "k" })
	local obj3 = setmetatable({}, { __mode = "k" })
	local localPlayer = v3.LocalPlayer
	local v18 = localPlayer
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid", 10)
	local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
	local data = localPlayer:WaitForChild("Data")
	local level = data:WaitForChild("Level")
	local fragments = data:WaitForChild("Fragments")
	local beli = data:WaitForChild("Beli")

	tbl2.Player = {
		LocalPlayer = localPlayer,
		Character = character,
		Humanoid = humanoid,
		HumanoidRootPart = humanoidRootPart,
		Data = data,
		Level = level,
		Fragments = fragments,
		Beli = beli,
		Money = beli,
	}

	localPlayer.CharacterAdded:Connect(function(character2)
		if not character2 then
			return
		end
		character = character2
		humanoid = character2:WaitForChild("Humanoid", 10)
		humanoidRootPart = character2:WaitForChild("HumanoidRootPart", 10)
		tbl2.Player.Character = character2
		tbl2.Player.Humanoid = humanoid
		tbl2.Player.HumanoidRootPart = humanoidRootPart
	end)

	local enemies = v2:WaitForChild("Enemies")
	local seaBeasts = v2:WaitForChild("SeaBeasts")
	local boats = v2:WaitForChild("Boats")
	local map = v2:WaitForChild("Map")
	local worldOrigin = v2:WaitForChild("_WorldOrigin")
	local attribute = v2:GetAttribute("MAP")
	local flag = attribute == "Sea1"
	local flag2 = attribute == "Sea2"
	local flag3 = attribute == "Sea3"

	tbl2.Environment = {
		Workspace = v2,
		Enemies = enemies,
		SeaBeasts = seaBeasts,
		Boats = boats,
		Map = map,
		WorldOrigin = worldOrigin,
		MAPA = attribute,
		Sea_1 = flag,
		Sea_2 = flag2,
		Sea_3 = flag3,
	}

	local remotes = v4:WaitForChild("Remotes")
	local commF = remotes:WaitForChild("CommF_")
	local commE = v4.Remotes.CommE
	local modules = v4:WaitForChild("Modules")
	local net = modules:WaitForChild("Net")
	tbl2.Remotes = { Remotes = remotes, CommF_ = commF, CommE = commE, Modules = modules, Net = net }
	local GuideModule = require(v4:WaitForChild("GuideModule"))
	local GetWaterHeightAtLocation = require(v4.Util.GetWaterHeightAtLocation)
	local DangerDistance = require(v4.DangerDistance)
	local Net = require(game.ReplicatedStorage.Modules.Net)
	local ItemConfig = require(game.ReplicatedStorage.ItemConfig)

	pcall(function()
		local CombatUtil = require(v4:WaitForChild("Modules"):WaitForChild("CombatUtil"))

		if CombatUtil and CombatUtil.CanAttack and hookfunction then
			hookfunction(CombatUtil.CanAttack, function()
				return true
			end)
		end
	end)

	tbl2.Modules = { GuideModule = GuideModule, GetWaterHeight = GetWaterHeightAtLocation, DangerDistance = DangerDistance, Net3 = Net, ItemConfig = ItemConfig }
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	local str2 = "KenHubAPI"

	local function fn3(arg, arg2)
		return (arg - ("KenHubAPI"):byte((arg2 - 1) % #str2 + 1) - arg2) % 32
	end

	local function fn4(arg)
		local str3 = arg:gsub("^%.", ""):gsub("%.$", "")
		local tbl6 = {}
		local n = 0

		for i = 1, #str3 do
			n += 1

			if n % 5 ~= 0 then
				table.insert(tbl6, str3:sub(i, i))
			end
		end

		local str4 = table.concat(tbl6)
		local tbl7 = {}
		local n2 = 1
		local n3 = 1

		while n2 <= #str4 do
			local str5 = str4:sub(n2, n2)
			local str6 = str4:sub(n2 + 1, n2 + 1)
			local n4 = ("kQ9mZ2xW7nR4vB1jY6tF3hD8pL5cG0sA"):find(str5, 1, true) - 1
			local n5 = ("kQ9mZ2xW7nR4vB1jY6tF3hD8pL5cG0sA"):find(str6, 1, true) - 1
			table.insert(tbl7, string.char(fn3(n4, n3) + fn3(n5, n3 + 100) * 32))
			n2 += 2
			n3 += 1
		end

		return table.concat(tbl7)
	end

-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	local tbl6 = {}
	local tbl7 = {}

	local function fn5(arg, arg2)
		local n = arg2 or 2
		local v19 = arg
		if v19 and tbl7[v19] then
			return tbl7[v19]
		end

		if arg then
			for i = 1, n do
				local ok, result = pcall(function()
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]

					if response and #response > 0 and not response:sub(1, 20):find("404") and not response:find("404: Not Found", 1, true) then
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
						if chunk then
							return chunk()
						end
					end
				end)

				if ok and result ~= nil then
					if v19 then
						tbl7[v19] = result
					end

					return result
				end

				if i < n then
					task.wait(0.3)
				end
			end
		end

		return nil
	end

	local lua = fn5("Util/BloxFruitModule/Preload/Data.lua") or {}
	local lua2 = fn5("Util/BloxFruitModule/Preload/Visuals.lua") or {}
	local lua3 = fn5("dev/testers.lua")
	local materialEnemies = lua.MaterialEnemies
	local quests = lua.QUESTS
	local bossList = lua.BossList
	local itemsToBuy = lua.ItemsToBuy
	local islands = lua.Islands
	local melees = lua.Melees
	local swordData = lua.SwordData

	tbl6.FireInvoke = function(...)
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
	end

	tbl2.Cache = {
		MonCached = obj,
		IslandSent = tbl5,
		DistanceCache = obj2,
		TargetCache = obj3,
		Clean = function()
			for k in pairs(tbl5) do
				if not worldOrigin.Locations:FindFirstChild(k) then
					tbl5[k] = nil
				end
			end
		end,
	}

	local state = {
		CurrentDracoStage = 1,
		DracoSequence = { "Relic1", "EndRelic1", "Relic2", "EndRelic2", "Relic3", "EndRelic3" },
		SwordList = { "Shizu", "Saishi", "Oroshi" },
		ActiveSword = nil,
		JoinTime = os.time(),
		CamLockConn = nil,
		BlueMoonState = "FIND_ISLAND",
	}

	tbl2.State = state

	tbl6.IsReady = function(arg, arg2)
		if not arg2 or not arg2.Parent or not arg2:IsDescendantOf(v2) then
			return false
		end

		if arg2.Parent == boats or arg2:GetAttribute("IsBoat") or arg2.Name:find("Brigade") or arg2.Name:find("Boat") or arg2.Name:find("Ship") then
			local health = arg2:FindFirstChild("Health")

			if health then
				local flag4 = health:IsA("ValueBase") and health.Value <= 0

				if flag4 then
					health = flag4
				else
					health = type(health.Value) == "number" and health.Value <= 0
				end
			end

			if health then
				return false
			end
			local humanoid2 = arg2:FindFirstChildOfClass("Humanoid") or arg2:FindFirstChild("Humanoid")

			if humanoid2 then
				local flag4 = humanoid2:IsA("Humanoid") and humanoid2.Health <= 0

				if flag4 then
					humanoid2 = flag4
				else
					humanoid2 = humanoid2:IsA("ValueBase") and humanoid2.Value <= 0
				end
			end

			if humanoid2 then
				return false
			end

			if arg2:GetAttribute("Dead") == true or arg2:GetAttribute("Sunk") == true then
				return false
			end
			local engine = arg2:FindFirstChild("Engine") or arg2.PrimaryPart or arg2:FindFirstChildWhichIsA("BasePart")
			if not engine or engine.Position.Y < -15 then
				return false
			end
			return true
		end

		if arg2.Parent == seaBeasts then
			local health = arg2:FindFirstChild("Health")
			return health and health.Value > 0
		end
		local humanoid2 = arg2:FindFirstChildOfClass("Humanoid")
		local humanoidRootPart2 = arg2:FindFirstChild("HumanoidRootPart") or arg2.PrimaryPart
		if humanoid2 and humanoid2.Health > 0 and humanoidRootPart2 then
			return true
		end
		return false
	end

	local function fn6()
		if not character then
			return 0
		end
		return DangerDistance(character:GetPivot().Position)
	end

	tbl2.Runtime = {
		StartTime = tick(),
		StartLevel = level and level.Value or 0,
		StartBeli = beli and beli.Value or 0,
		StartFragments = fragments and fragments.Value or 0,
		LastDataLogTick = 0,
		LastErrorTick = {},
		ErrorLogs = {},
		FarmsCompleted = 0,
		ChestsCollected = 0,
		MobsKilled = 0,
		BossesKilled = 0,
		LevelGained = 0,
		BeliGained = 0,
		FragmentsGained = 0,
		ActiveFarm = "None",
	}

	tbl2.Performance = {
		CleanMemory = function()
			pcall(function()
				if collectgarbage then
					collectgarbage("step", 200)
				end

				tbl2.Cache.Clean()
			end)
		end,
		ClearDebris = function()
			pcall(function()
				local v19 = next
				local children, v20 = v2:GetChildren()

				for _, v21 in v19, children, v20 do
					if v21:IsA("Tool") and (not v21.Parent or not v21.Parent:FindFirstChildOfClass("Humanoid")) then
						v21:Destroy()
					elseif v21.Name == "Debris" or v21.Name == "Effect" or v21.Name == "Effects" then
						v21:ClearAllChildren()
					else
						local isBasePart = v21:IsA("BasePart")

						if isBasePart then
							isBasePart = v21.Name:find("Slash") or v21.Name:find("HitEffect") or v21.Name:find("Particle") or v21.Name:find("Explosion")
						end

						if isBasePart then
							v21:Destroy()
						end
					end
				end

				if v2:FindFirstChild("Characters") then
					local v21 = next
					local children2, v22 = v2.Characters:GetChildren()

					for _, v23 in v21, children2, v22 do
						local humanoid2 = v23:FindFirstChildOfClass("Humanoid")

						if humanoid2 and humanoid2.Health <= 0 and v23 ~= v18.Character then
							v23:Destroy()
						end
					end
				end
			end)
		end,
		OptimizeClient = function()
			pcall(function()
				local terrain = v2:FindFirstChildOfClass("Terrain")

				if terrain then
					terrain.WaterWaveSize = 0
					terrain.WaterWaveSpeed = 0
					terrain.WaterReflectance = 0
					terrain.WaterTransparency = 0
				end

				v7.GlobalShadows = false
				v7.FogEnd = 9e9
				settings().Rendering.QualityLevel = 1

				for _, descendant in ipairs(v7:GetDescendants()) do
					if descendant:IsA("BlurEffect") or descendant:IsA("SunRaysEffect") or descendant:IsA("ColorCorrectionEffect") or descendant:IsA("BloomEffect") or descendant:IsA("DepthOfFieldEffect") then
						descendant.Enabled = false
					end
				end
			end)
		end,
		ClearNew = function(arg)
			if arg then
				table.clear(arg)
				return arg
			end
			return {}
		end,
		CreateDictionary = function(arg, arg2)
			local tbl8 = {}
			arg2 = arg2 ~= nil and arg2 or true

			if arg then
				for i = 1, #arg do
					tbl8[arg[i]] = arg2
				end
			end

			return tbl8
		end,
		CreateAutoCache = function(arg)
			local tbl8 = {}

			setmetatable(tbl8, { __index = function(arg2, arg3)
				if arg3 == nil then
					return nil
				end
				local v19 = arg(arg3)
				rawset(arg2, arg3, v19)
				return v19
			end })

			return tbl8
		end,
		FastMode = false,
		SetFastMode = function(fastMode)
			if fastMode == nil then
				fastMode = true
			end

			tbl2.Performance.FastMode = fastMode

			task.spawn(function()
				pcall(function()
					local playerGui = v18 and v18:FindFirstChild("PlayerGui")
					local fastMode2 = playerGui and playerGui:FindFirstChild("Main") and playerGui.Main:FindFirstChild("SettingsMenu") and playerGui.Main.SettingsMenu:FindFirstChild("Content") and playerGui.Main.SettingsMenu.Content:FindFirstChild("ScrollingFrame") and playerGui.Main.SettingsMenu.Content.ScrollingFrame:FindFirstChild("FastMode")

					if fastMode2 and firesignal then
						local firstButton = fastMode and fastMode2:FindFirstChild("FirstButton") or fastMode2:FindFirstChild("SecondButton")

						if firstButton and firstButton:IsA("GuiButton") then
							firesignal(firstButton.Activated)
						end
					end
				end)
			end)

			return tbl2.Performance.FastMode
		end,
	}

	local clearNew = tbl2.Performance.ClearNew

	tbl2.Scheduler = {
		Phase = 1,
		PhaseStart = tick(),
		LastHop = tick(),
		LastRejoin = tick(),
		LastFruitRoll = 0,
		_IsHopping = false,
		_CancelHop = false,
		StopHop = function()
			tbl2.Scheduler._CancelHop = true
			tbl2.Scheduler._IsHopping = false

			if tbl4 then
				for k in pairs(tbl4) do
					tbl4[k] = false
				end
			end

			for _, v19 in ipairs({
				"AutoAfkJoinCastleRaid",
				"AutoAfkJoinFactoryRaid",
				"AutoAfkJoinBossRaid",
				"AutoAfkJoinEliteHunter",
				"AutoAfkJoinFruit",
			}) do
				if tbl then
					tbl[v19] = false
				end

				if tbl6 and tbl6.Toggles and tbl6.Toggles[v19] and tbl6.Toggles[v19].Update then
					pcall(function()
						tbl6.Toggles[v19].Update(false)
					end)
				end
			end

			if tbl6 and tbl6.SendNotify then
				tbl6:SendNotify("AFK Farm", "AFK farm & server hop stopped.", 3)
			end
		end,
		ServerHop = function(arg)
			tbl2.Scheduler._CancelHop = false

			task.spawn(function()
				tbl2.Scheduler._IsHopping = true
				local n = arg or tbl and tonumber(tbl.HopDelay) or 0

				local tbl8 = {
					{
						Text = "Stop Hop",
						Callback = function()
							tbl2.Scheduler.StopHop()
						end,
					},
				}

				if n > 0 then
					if tbl6 and tbl6.SendNotify then
						local min = math.min
						tbl6:SendNotify("Server Hop", string.format("Hopping server in %d seconds...", math.floor(n)), min(math.floor(n), 5), tbl8)
					end

					local n2 = 0
					local exitTo = nil

					while true do
						if n2 < n then
							if not tbl2.Scheduler._CancelHop then
								task.wait(0.2)
								n2 += 0.2
								continue
							end

							break
						else
							exitTo = 1
							break
						end
					end

					if exitTo ~= 1 then
						tbl2.Scheduler._IsHopping = false
						return
					end
				end

				if tbl2.Scheduler._CancelHop then
					tbl2.Scheduler._IsHopping = false
					return
				end
				local flag4 = false

				for i = 1, 100 do
					if not tbl2.Scheduler._CancelHop then
						task.spawn(function()
							if flag4 or tbl2.Scheduler._CancelHop then
								return
							end

							local ok, result = pcall(function()
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
							end)

							if ok and type(result) == "table" then
								for k, v19 in pairs(result) do
									if not flag4 and not tbl2.Scheduler._CancelHop and type(v19) == "table" and v19.Count and v19.Count < 12 and k ~= game.JobId then
										flag4 = true

										if tbl6 and tbl6.SendNotify then
											tbl6:SendNotify("Hopping", "Server found! Teleporting...", 5, nil, "ServerHop")
										end

										pcall(function()
											if not tbl2.Scheduler._CancelHop then
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
											end
										end)
									end
								end
							end
						end)

						continue
					end

					break
				end

				tbl2.Scheduler._IsHopping = false
			end)
		end,
		Rejoin = function()
			if tbl6 and tbl6.SendNotify then
				tbl6:SendNotify("Rejoin", "Rejoining current server...", 3)
			end

			pcall(function()
-- [SANITIZED: network/executor/dynamic-load/remote operation removed]
			end)
		end,
	}

	tbl2.StopAfkFarm = tbl2.Scheduler.StopHop
	tbl6.StopAfkFarm = tbl2.Scheduler.StopHop

	pcall(function()
		v15.TeleportInitFailed:Connect(function(arg, arg2, arg3)
			pcall(function()
				v16:ClearError()
			end)

			if not tbl2.Scheduler._IsHopping and not tbl2.Scheduler._IsJoiningActive then
				if tbl6 and tbl6.SendNotify then
					tbl6:SendNotify("Ken Hub API", "Teleport failed: " .. tostring(arg3 or "Server full"), 2)
				end
			end
		end)
	end)

	local function joinAPI(arg, arg2)
		pcall(function()
			v16:ClearError()
		end)

		if tbl4[arg] then
			if tbl6 and tbl6.SendNotify then
				tbl6:SendNotify("Ken Hub API", "Already searching servers for " .. tostring(arg) .. "...", 2)
			end

			return
		end

		local tbl8 = {
			{
				Text = "Stop Hop",
				Callback = function()
					tbl2.Scheduler.StopHop()
				end,
			},
		}

		local str4 = "/api/logs/" .. tostring(arg):lower()
		local now = os.clock()
		local n = tbl3[arg] or 0

		if arg2 and now - n < arg2 then
			local v19 = math.ceil(arg2 - now - n)

			if tbl6 and tbl6.SendNotify then
				tbl6:SendNotify("Cooldown", string.format("Wait %ds before next %s", v19, arg), 2)
			end

			return
		end

		tbl2.Scheduler._CancelHop = false
		tbl2.Scheduler._IsJoiningActive = true
		tbl4[arg] = true
    
