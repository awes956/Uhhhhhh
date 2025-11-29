local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TextChatService = game:GetService("TextChatService")
local ContextActionService = game:GetService("ContextActionService")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer

local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Stocks"
	m.Description = "the graph is pointing UP!\n\nthanks to the consultant\notherwise itll be pointing DOWN\n(this is a pencilmation reference)"
	m.Assets = {"StockDance.anim", "StockDance.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("StockDance.mp3"), "Lights, Camera, Action! - Sonic Mania", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("StockDance.anim"))
		animator.looped = false
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "DO THE FLOP"
	m.Description = "Don't jump! You have so much to live for!\nEVERYBODY DO THE FLOP! *FLOP*\n*SPLAT*"
	m.Assets = {"DoTheFlop.anim", "DoTheFlop.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("DoTheFlop.mp3"), "asdfmovie - Do The Flop", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("DoTheFlop.anim"))
		animator.looped = false
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "INTERNET YAMERO"
	m.Description = "me when i lag in tsb\n\"STOP LAGGING ME INTERNET\""
	m.Assets = {"InternetYamero.anim", "InternetYameroSickTock.anim", "InternetYamero.mp3"}

	m.FullVersion = false
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Complete", m.FullVersion).Changed:Connect(function(val)
			m.FullVersion = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.FullVersion = not not save.FullVersion
	end
	m.SaveConfig = function()
		return {
			FullVersion = m.FullVersion
		}
	end

	local animator1 = nil
	local animator2 = nil
	m.Init = function(figure: Model)
		if m.FullVersion then
			SetOverrideDanceMusic(AssetGetContentId("InternetYamero.mp3"), "NEEDY GIRL OVERDOSE - INTERNET YAMERO", 1)
		else
			SetOverrideDanceMusic(AssetGetContentId("InternetYamero.mp3"), "NEEDY GIRL OVERDOSE - INTERNET YAMERO", 1, NumberRange.new(21.394, 62.94))
			SetOverrideDanceMusicTime(21.394)
		end
		animator1 = AnimLib.Animator.new()
		animator1.rig = figure
		animator1.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("InternetYameroSickTock.anim"))
		animator1.looped = false
		animator2 = AnimLib.Animator.new()
		animator2.rig = figure
		animator2.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("InternetYamero.anim"))
		animator2.looped = true
		animator2.map = {{11, 62.944}, {0, 53.33333}}
	end
	m.Update = function(dt: number, figure: Model)
		local t = GetOverrideDanceMusicTime()
		if t < 11 then
			animator1:Step(t)
		elseif t < 18.667 then
			animator2:Step(t)
		elseif t < 19.333 then
			animator2:Step(math.min((t - 18.667) / 0.1, 1.2))
		elseif t < 20 then
			animator2:Step(math.min((t - 19.333) / 0.1, 1.34))
		elseif t < 21.333 then
			animator2:Step(t * 100)
		else
			animator2:Step(t)
		end
	end
	m.Destroy = function(figure: Model?)
		animator1 = nil
		animator2 = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Tenna Cabbage Dance"
	m.Description = "try not to do this dance wrong challenge\ndifficulty: impossible"
	m.Assets = {"TennaCabbage.anim", "TennaBaciPerugina.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("TennaBaciPerugina.mp3"), "Deltarune - TV TIME", 1)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.speed = 0.9 + 0.2 * math.random()
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("TennaCabbage.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		local t = tick()
		animator:Step(t - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Tenna Swingy Dance"
	m.Description = "r6"
	m.Assets = {"TennaSwing.anim", "TennaBaciPerugina.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("TennaBaciPerugina.mp3"), "Deltarune - TV TIME", 1)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.speed = 0.9 + 0.2 * math.random()
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("TennaSwing.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		local t = tick()
		animator:Step(t - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Squidward Yell"
	m.Description = "erm what the stick ma\nthis is the best animation library benchmarker\nthe second variant's original \"animation file\" was 10MB. it has been magically reduced to 1MB using C struct magic. (STEVE's KeyframeSequence file format)\nits also optimised down to 3714 keyframes\nthe third variant was reduced from 16MB to 2MB, and trimmed to 5742 keyframes.\nthe first, 9MB to 1MB, trimmed to 3216 keyframes."
	m.Assets = {"SquidwardYell1.anim", "SquidwardYell1.mp3", "SquidwardYell2.anim", "SquidwardYell2.mp3", "SquidwardYell3.anim", "SquidwardYell3.mp3"}

	m.Variant = 1
	m.Config = function(parent: GuiBase2d)
		Util_CreateDropdown(parent, "Variant", {"Second", "Third", "First"}, m.Variant).Changed:Connect(function(val)
			m.Variant = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Variant = save.Variant or m.Variant
	end
	m.SaveConfig = function()
		return {
			Variant = m.Variant
		}
	end

	local animator = nil
	m.Init = function(figure: Model)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		if m.Variant == 1 then
			SetOverrideDanceMusic(AssetGetContentId("SquidwardYell1.mp3"), "Zivixius - Squidward Yell 2", 1)
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("SquidwardYell1.anim"))
		end
		if m.Variant == 2 then
			SetOverrideDanceMusic(AssetGetContentId("SquidwardYell2.mp3"), "Zivixius - Squidward Yell 3", 1)
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("SquidwardYell2.anim"))
		end
		if m.Variant == 3 then
			SetOverrideDanceMusic(AssetGetContentId("SquidwardYell3.mp3"), "Zivixius - Squidward Yell", 1)
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("SquidwardYell3.anim"))
		end
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Take The L"
	m.Description = "accept the loss man\njust accept the loss\ncmon\ngood boy~ <33"
	m.Assets = {"TakeTheL.anim", "TakeTheLDubmood.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		SetOverrideDanceMusic(AssetGetContentId("TakeTheLDubmood.mp3"), "Dubmood+Zabutom+Ogge - Razor Comeback Intro", 1)
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("TakeTheL.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Torture Dance"
	m.Description = "im gonna put a magnifying glass on ur eyes\nand dance while your eyes burn\nitll feel like a burning sunlight"
	m.Assets = {"TortureDance1.anim", "TortureDance2.anim", "TortureDance.mp3"}

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		SetOverrideDanceMusic(AssetGetContentId("TortureDance.mp3"), "JoJo's Bizzare Adventure - Torture Dance", 1, NumberRange.new(1.234, 140.28))
		if math.random() < 0.5 then
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("TortureDance1.anim"))
		else
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("TortureDance2.anim"))
		end
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Kazotsky Kick+"
	m.Description = "the + is for the variants\null see why"
	m.Assets = {"Kazotsky.anim", "KazotskyDemoman.anim", "KazotskyEngineer.anim", "KazotskyHeavy.anim", "KazotskyMedic.anim", "KazotskyPyro.anim", "KazotskyScout.anim", "KazotskySniper.anim", "KazotskySoldier.anim", "KazotskySpy.anim", "Kazotsky.mp3"}

	m.Variant = 1
	m.Config = function(parent: GuiBase2d)
		Util_CreateDropdown(parent, "Variant", {"Regular", "TF2 Demoman", "TF2 Engineerman", "TF2 Heavyman", "TF2 Medicman", "TF2 Pyroman", "TF2 Scout", "TF2 Sniperman", "TF2 Soldierman", "TF2 Spyman", "Gordon Freeman"}, m.Variant).Changed:Connect(function(val)
			m.Variant = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Variant = save.Variant or m.Variant
	end
	m.SaveConfig = function()
		return {
			Variant = m.Variant
		}
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		SetOverrideDanceMusic(AssetGetContentId("Kazotsky.mp3"), "some russian music idk", 1)
		local variants = {"", "Demoman", "Engineer", "Heavy", "Medic", "Pyro", "Scout", "Sniper", "Soldier", "Spy"}
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Kazotsky" .. (variants[m.Variant] or "") .. ".anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Doodle"
	m.Description = "its for the small hitbox trust\n\nthis tune is fuhhing :3333"
	m.Assets = {"Doodle.anim", "Doodle.mp3", "Doodle2.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Doodle.anim"))
		if math.random() < 0.75 then
			SetOverrideDanceMusic(AssetGetContentId("Doodle.mp3"), "Zachz Winner - doodle", 1)
		else
			SetOverrideDanceMusic(AssetGetContentId("Doodle2.mp3"), "reconstructed doodle", 1)
		end
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Brain"
	m.Description = "bendy and the ink machine ass beat\npick your poison: garou or gojo"
	m.Assets = {"Brain.anim", "Brain.mp3"}

	m.Alternative = false
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Garou slide", m.Alternative).Changed:Connect(function(val)
			m.Alternative = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Alternative = not not save.Alternative
	end
	m.SaveConfig = function()
		return {
			Alternative = m.Alternative
		}
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("Brain.mp3"), "Kanaria - BRAIN", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.map = {{0, 66.527}, {0, 65.52}}
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Brain.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		if m.Alternative then
			animator:Step(0.267)
		else
			animator:Step(GetOverrideDanceMusicTime())
		end
		local hum = figure:FindFirstChild("Humanoid")
		if not hum then return end
		hum.WalkSpeed = 8 * figure:GetScale()
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		if not figure then return end
		local hum = figure:FindFirstChild("Humanoid")
		if not hum then return end
		hum.WalkSpeed = 16 * figure:GetScale()
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Left Right Left Right"
	m.Description = "up down up down\nburger king, burger throne\n:3 :3 :3 :3 :3"
	m.Assets = {"LeftRight.anim", "LeftRight.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("LeftRight.mp3"), "idk this tune", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("LeftRight.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Silly Billy"
	m.Description = "bro that shit aint 'me' :wilted_rose:"
	m.Assets = {"Billy.anim", "Billy2.anim", "Billy.mp3"}

	m.Effects = true
	m.Alternative = false
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Effects", m.Effects).Changed:Connect(function(val)
			m.Effects = val
		end)
		Util_CreateSwitch(parent, "Alt. Version", m.Alternative).Changed:Connect(function(val)
			m.Alternative = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Alternative = not not save.Alternative
		m.Effects = not save.NoEffects
	end
	m.SaveConfig = function()
		return {
			Alternative = m.Alternative,
			NoEffects = not m.Effects
		}
	end

	local animator = nil
	local effects = nil
	local shardsoffset = {}
	for _=1, 8 do table.insert(shardsoffset, math.random() * 0.3) end
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("Billy.mp3"), "FNF VS Yourself mod", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		if m.Alternative then
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Billy2.anim"))
		else
			animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Billy.anim"))
		end
		if m.Effects then
			local scale = figure:GetScale()
			effects = Instance.new("Model")
			effects.Name = "SillyBilly"
			local arm = figure:FindFirstChild("Left Arm")
			if arm then
				local handle = Instance.new("Part")
				handle.Name = "MicHandle"
				handle.Color = Color3.new(0, 0, 0)
				handle.Anchored = false
				handle.CanCollide = false
				handle.CanTouch = false
				handle.CanQuery = false
				handle.Size = Vector3.new(1, 0.5, 0.5) * scale
				handle.Shape = "Cylinder"
				handle.Parent = effects
				local grip = Instance.new("Weld")
				grip.Name = "MicGrip"
				grip.Part0 = arm
				grip.Part1 = handle
				grip.C0 = CFrame.new(0, -1 * scale, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
				grip.Parent = effects
				local casing = Instance.new("Part")
				casing.Name = "MicRoundThing"
				casing.Color = Color3.new(0, 0, 0)
				casing.Anchored = false
				casing.CanCollide = false
				casing.CanTouch = false
				casing.CanQuery = false
				casing.Size = Vector3.new(1, 1, 1) * scale
				casing.Shape = "Ball"
				casing.Parent = effects
				local weld = Instance.new("Weld")
				weld.Name = "MicWeld"
				weld.Part0 = handle
				weld.Part1 = casing
				weld.C0 = CFrame.new(0.875 * scale, 0, 0)
				weld.Parent = effects
			end
			local function makepart(name, color, mater, size, tra)
				local part = Instance.new("Part")
				part.Name = name
				part.Color = color
				part.Material = mater
				part.Transparency = tra
				part.Anchored = true
				part.CanCollide = false
				part.CanTouch = false
				part.CanQuery = false
				part.Size = size * scale
				part.Parent = effects
			end
			makepart("Glass", Color3.fromRGB(111, 130, 255), Enum.Material.SmoothPlastic, Vector3.new(6, 9, 0.2), 0)
			makepart("Pillar1", Color3.fromRGB(52, 61, 120), Enum.Material.Concrete, Vector3.new(1, 9, 1), 0)
			makepart("Pillar2", Color3.fromRGB(52, 61, 120), Enum.Material.Concrete, Vector3.new(1, 9, 1), 0)
			makepart("Pillar3", Color3.fromRGB(52, 61, 120), Enum.Material.Concrete, Vector3.new(2.5, 1, 2.5), 0)
			makepart("Pillar4", Color3.fromRGB(52, 61, 120), Enum.Material.Concrete, Vector3.new(2.5, 1, 2.5), 0)
			local flash = Instance.new("Highlight")
			flash.Name = "Flash"
			flash.DepthMode = "Occluded"
			flash.Enabled = true
			flash.FillColor = Color3.new(1, 1, 1)
			flash.FillTransparency = 1
			flash.OutlineTransparency = 1
			flash.Parent = effects
			makepart("Particles", Color3.new(0, 0, 0), Enum.Material.Plastic, Vector3.zero, 0, 1)
			local star1 = Instance.new("ParticleEmitter")
			star1.Name = "Star1"
			star1.Enabled = true
			star1.Texture = "rbxasset://textures/particles/sparkles_main.dds"
			star1.Color = ColorSequence.new(Color3.fromRGB(30, 64, 255))
			star1.LightInfluence = 0
			star1.LightEmission = 0
			star1.Brightness = 2
			star1.Size = NumberSequence.new(0)
			star1.Transparency = NumberSequence.new(0.5)
			star1.Orientation = "VelocityPerpendicular"
			star1.EmissionDirection = "Front"
			star1.Lifetime = NumberRange.new(1)
			star1.Rate = 10
			star1.Rotation = NumberRange.new(0)
			star1.RotSpeed = NumberRange.new(-180)
			star1.Speed = NumberRange.new(0.001)
			star1.LockedToPart = true
			star1.ZOffset = 0
			star1.Parent = effects.Particles
			local star2 = star1:Clone()
			star2.Name = "Star2"
			star2.Color = ColorSequence.new(Color3.fromRGB(148, 138, 255))
			star2.Rate = 3
			star2.ZOffset = 1
			star2.Parent = effects.Particles
			for i=1, 8 do
				local shard = Instance.new("WedgePart")
				shard.Name = "Shard" .. i
				shard.Color = Color3.fromRGB(111, 130, 255)
				shard.Material = Enum.Material.SmoothPlastic
				shard.Anchored = true
				shard.CanCollide = false
				shard.CanTouch = false
				shard.CanQuery = false
				shard.Size = Vector3.new(0.2, 4.5, 3)
				shard.Parent = effects
			end
			effects.Parent = figure
		end
	end
	m.Update = function(dt: number, figure: Model)
		local t = GetOverrideDanceMusicTime()
		animator:Step(t)
		local root = figure:FindFirstChild("HumanoidRootPart")
		if not root then return end
		if effects then
			local scale = figure:GetScale()
			local group1t = 1 - math.pow(1 - math.clamp(t - 11, 0, 1), 3)
			group1t -= math.max(0, t - 44.537)
			local glass = effects:FindFirstChild("Glass")
			local pillar1 = effects:FindFirstChild("Pillar1")
			local pillar2 = effects:FindFirstChild("Pillar2")
			local pillar3 = effects:FindFirstChild("Pillar3")
			local pillar4 = effects:FindFirstChild("Pillar4")
			local flash = effects:FindFirstChild("Flash")
			local pcles = effects:FindFirstChild("Particles")
			if glass then
				glass.CFrame = root.CFrame * CFrame.new(Vector3.new(0, 1.5, 2 - group1t) * scale)
				if t < 6.9 or t > 30 then
					glass.Transparency = 0.2 + 0.8 * group1t
				else
					glass.Transparency = 1
				end
			end
			for i=1, 8 do
				local j = i - 1
				local shard = effects:FindFirstChild("Shard" .. i)
				if shard then
					local cf = CFrame.new((CFrame.Angles(0, 0, (j // 2) * math.pi * 0.5) * Vector3.new(1, 1, 0) * scale) * Vector3.new(1.5, 2.25, 0)) * CFrame.Angles(0, -math.pi / 2, 0)
					if (j // 2) % 2 == 0 then
						cf *= CFrame.Angles(0, math.pi, 0)
					end
					if j % 2 == 0 then
						cf *= CFrame.Angles(math.pi, 0, 0)
					end
					shard.CFrame = root.CFrame * CFrame.new(0, 1.5 * scale, (2 - group1t + shardsoffset[i]) * scale) * cf
					shard.Size = Vector3.new(0.2, 4.5, 3) * scale
					if t < 6.9 or t > 30 then
						shard.Transparency = 1
					else
						shard.Transparency = 0.2 + 0.8 * group1t
					end
				end
			end
			if pillar1 then
				pillar1.CFrame = root.CFrame * CFrame.new(Vector3.new(3.5, 1.5, 2 - group1t) * scale)
				pillar1.Transparency = group1t
			end
			if pillar2 then
				pillar2.CFrame = root.CFrame * CFrame.new(Vector3.new(-3.5, 1.5, 2 - group1t) * scale)
				pillar2.Transparency = group1t
			end
			if pillar3 then
				pillar3.CFrame = root.CFrame * CFrame.new(Vector3.new(3.5, -2.5, 2 - group1t) * scale)
				pillar3.Transparency = group1t
			end
			if pillar4 then
				pillar4.CFrame = root.CFrame * CFrame.new(Vector3.new(-3.5, -2.5, 2 - group1t) * scale)
				pillar4.Transparency = group1t
			end
			if flash then
				if t < 6.9 then
					flash.FillTransparency = 1
				else
					flash.FillTransparency = 0.5 + 0.5 * math.min(t - 6.9, 1)
				end
			end
			if pcles then
				pcles.CFrame = root.CFrame * CFrame.new(Vector3.new(0, 0.25, 3) * scale)
				local starflash = 2
				if t < 18.05 then
					starflash = 2
				elseif t < 23.6 then
					starflash = 2 + 5 * (1 - math.min(t - 18.05, 5) / 5)
				else
					starflash = 5
				end
				local star1 = pcles:FindFirstChild("Star1")
				local star2 = pcles:FindFirstChild("Star2")
				if star1 then
					star1.Size = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 8 * group1t * scale, 2 * group1t * scale),
						NumberSequenceKeypoint.new(1, 8 * group1t * scale, 2 * group1t * scale),
					})
					star1.Brightness = starflash
				end
				if star2 then
					star2.Size = NumberSequence.new(5 * group1t * scale)
					star2.Brightness = starflash
				end
			end
		end
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		if effects then
			effects:Destroy()
			effects = nil
		end
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Skipping"
	m.Description = ":D"
	m.Assets = {"SkippingHappily.anim", "SkippingHappily.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("SkippingHappily.mp3"), "idk this tune", 1)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("SkippingHappily.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
		local hum = figure:FindFirstChild("Humanoid")
		if not hum then return end
		hum.WalkSpeed = 8 * figure:GetScale()
	end
	m.Destroy = function(figure: Model?)
		animator = nil
		if not figure then return end
		local hum = figure:FindFirstChild("Humanoid")
		if not hum then return end
		hum.WalkSpeed = 16 * figure:GetScale()
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Backflips"
	m.Description = "dance like you have 62 seconds left!\n\n(this is an evangelion reference ofc)"
	m.Assets = {"Backflips.anim", "Backflips.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("Backflips.mp3"), "Both Of You, Dance Like You Want To Win", 1)
		start = tick()
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Backflips.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
		local hum = figure:FindFirstChild("Humanoid")
		if not hum or not hum.RootPart then return end
		if hum.MoveDirection.Magnitude > 0 then
			-- move backwards
			hum.RootPart.Velocity = Vector3.new(
				hum.MoveDirection.X * -16 * figure:GetScale(),
				hum.RootPart.Velocity.Y,
				hum.MoveDirection.Z * -16 * figure:GetScale()
			)
		end
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Headlock"
	m.Description = "bakas bakas bakas bakas baka sekao"
	m.Assets = {"Headlock.anim", "Headlock.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("Headlock.mp3"), "what is this tune broski", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.map = {{0, 14.774}, {0, 14.76}}
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Headlock.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

AddModule(function()
	local m = {}
	m.ModuleType = "DANCE"
	m.Name = "Cat Dance"
	m.Description = "colonthreespam\nthe smallest dance in the whole nekocollection\n\ngarou slide is still smaller-"
	m.Assets = {"CatDance.anim"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	local start = 0
	m.Init = function(figure: Model)
		start = tick()
		SetOverrideDanceMusic("rbxassetid://9039445224", "8 Bitty Kitty Underscore", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("CatDance.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(tick() - start)
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

return modules