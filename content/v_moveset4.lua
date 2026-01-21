-- update force 1

cloneref = cloneref or function(o) return o end

local Debris = cloneref(game:GetService("Debris"))
local Players = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local StarterGui = cloneref(game:GetService("StarterGui"))
local HttpService = cloneref(game:GetService("HttpService"))
local TextService = cloneref(game:GetService("TextService"))
local TweenService = cloneref(game:GetService("TweenService"))
local TextChatService = cloneref(game:GetService("TextChatService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local ContextActionService = cloneref(game:GetService("ContextActionService"))

local Player = Players.LocalPlayer

local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Minigun"
	m.InternalName = "IAMBULLETPROOF"
	m.Description = "now in the latest color: AKAI!!\nLet's Go! Goodbye!\nM1 - Shoot"
	m.Assets = {}

	m.Notifications = true
	m.Sounds = true
	m.UseSword = false
	m.BooletsPerSec = 60
	m.NoShells = false
	m.HowBadIsAim = 1
	m.ShakeValue = 1
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "Text thing", m.Notifications).Changed:Connect(function(val)
			m.Notifications = val
		end)
		Util_CreateSwitch(parent, "Sounds", m.Sounds).Changed:Connect(function(val)
			m.Sounds = val
		end)
		Util_CreateText(parent, "Use the sword instead of the gun!", 12, Enum.TextXAlignment.Center)
		Util_CreateSwitch(parent, "Gun = Sword", m.UseSword).Changed:Connect(function(val)
			m.UseSword = val
		end)
		Util_CreateText(parent, "for optimisation reasons, you can only fire max 20 bullets in a frame", 12, Enum.TextXAlignment.Center)
		Util_CreateSlider(parent, "Bullets Per Second", m.BooletsPerSec, 5, 240, 1).Changed:Connect(function(val)
			m.BooletsPerSec = val
		end)
		Util_CreateSwitch(parent, "Fire the whole bullet", m.NoShells).Changed:Connect(function(val)
			m.NoShells = val
		end)
		Util_CreateSlider(parent, "Fire Spread", m.HowBadIsAim, 0, 1, 0).Changed:Connect(function(val)
			m.HowBadIsAim = val
		end)
		Util_CreateSlider(parent, "Shake Amount", m.ShakeValue, 0, 1, 0).Changed:Connect(function(val)
			m.ShakeValue = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.Notifications = not save.NoTextType
		m.Sounds = not save.Muted
		m.UseSword = not not save.UseSword
		m.BooletsPerSec = save.BooletsPerSec or m.BooletsPerSec
		m.NoShells = not not save.NoShells
		m.HowBadIsAim = save.HowBadIsAim or m.HowBadIsAim
		m.ShakeValue = save.ShakeValue or m.ShakeValue
	end
	m.SaveConfig = function()
		return {
			NoTextType = not m.Notifications,
			Muted = not m.Sounds,
			UseSword = m.UseSword,
			BooletsPerSec = m.BooletsPerSec,
			NoShells = m.NoShells,
			HowBadIsAim = m.HowBadIsAim,
			ShakeValue = m.ShakeValue,
		}
	end

	local start = 0
	local hum, root, torso
	local scale = 1
	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.IgnoreWater = true
	local function PhysicsRaycast(origin, direction)
		rcp.RespectCanCollide = true
		return workspace:Raycast(origin, direction, rcp)
	end
	local function ShootRaycast(origin, direction)
		rcp.RespectCanCollide = false
		return workspace:Raycast(origin, direction, rcp)
	end
	local mouse = Player:GetMouse()
	local mouselock = false
	local function MouseHit()
		local Camera = workspace.CurrentCamera
		local ray = mouse.UnitRay
		if mouselock and Camera then
			local pos = Camera.ViewportSize * Vector2.new(0.5, 0.3)
			ray = Camera:ViewportPointToRay(pos.X, pos.Y, 1e-6)
		end
		local dist = 2000
		local raycast = ShootRaycast(ray.Origin, ray.Direction * dist)
		if raycast then
			return raycast.Position
		end
		return ray.Origin + ray.Direction * dist
	end
	local function notify(message)
		if not m.Notifications then return end
		if not root or not torso then return end
		local dialog = torso:FindFirstChild("NOTIFICATION")
		if dialog then
			dialog:Destroy()
		end
		dialog = Instance.new("BillboardGui", torso)
		dialog.Size = UDim2.new(50 * scale, 0, 2 * scale, 0)
		dialog.StudsOffset = Vector3.new(0, 5 * scale, 0)
		dialog.Adornee = torso
		dialog.Name = "NOTIFICATION"
		local text = Instance.new("TextLabel", dialog)
		text.BackgroundTransparency = 1
		text.BorderSizePixel = 0
		text.Text = ""
		text.Font = Enum.Font.Fantasy
		text.TextScaled = true
		text.TextStrokeTransparency = 0
		text.Size = UDim2.new(1, 0, 1, 0)
		text.TextColor3 = Color3.fromRGB(255, 50, 50)
		text.TextStrokeColor3 = Color3.new(0, 0, 0)
		task.spawn(function()
			local function update()
				text.Position = UDim2.new(math.random() * 0.05 * (2 / 50), 0, 0, math.random() * 0.05)
			end
			local cps = 30
			local t = os.clock()
			local ll = 0
			repeat
				task.wait()
				local l = math.floor((os.clock() - t) * cps)
				if l > ll then
					ll = l
				end
				update()
				text.Text = string.sub(message, 1, l)
			until ll >= #message
			text.Text = message
			t = os.clock()
			repeat
				task.wait()
				update()
			until os.clock() - t > 1
			t = os.clock()
			repeat
				task.wait()
				local a = os.clock() - t
				text.Position = UDim2.new(0, math.random(-45, 45) + math.random(-a, a) * 100, 0, math.random(-5, 5) + math.random(-a, a) * 40)
				text.TextTransparency = a
				text.TextStrokeTransparency = a
			until os.clock() - t > 1
			dialog:Destroy()
		end)
	end
	local function randomdialog(arr)
		notify(arr[math.random(1, #arr)])
	end
	local function CreateSound(id, pitch, extra)
		if not m.Sounds then return end
		if not torso then return end
		local parent = torso
		if typeof(id) == "Instance" then
			parent = id
			id, pitch = pitch, extra
		end
		pitch = pitch or 1
		local sound = Instance.new("Sound")
		sound.Name = tostring(id)
		sound.SoundId = "rbxassetid://" .. id
		sound.Volume = 1
		sound.Pitch = pitch
		sound.EmitterSize = 100
		sound.Parent = parent
		sound:Play()
		sound.Ended:Connect(function()
			sound:Destroy()
		end)
	end
	local function AimTowards(target)
		if not root then return end
		if flight then return end
		local tcf = CFrame.lookAt(root.Position, target)
		local _,off,_ = root.CFrame:ToObjectSpace(tcf):ToEulerAngles(Enum.RotationOrder.YXZ)
		root.AssemblyAngularVelocity = Vector3.new(0, off, 0) * 60
	end
	local chatconn
	local attacking = false
	local joints = {
		r = CFrame.identity,
		n = CFrame.identity,
		rs = CFrame.identity,
		ls = CFrame.identity,
		rh = CFrame.identity,
		lh = CFrame.identity,
		sw = CFrame.identity,
	}
	local gun = {}
	local bullet = {}
	local mousedown = false
	local uisbegin, uisend
	local dancereact = false
	local state = 0
	local statetime = 0
	local sndshoot, sndspin
	local ROOTC0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
	local NECKC0 = CFrame.new(0, 1, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180))
	local RIGHTSHOULDERC0 = CFrame.new(-0.5, 0, 0) * CFrame.Angles(0, math.rad(90), 0)
	local LEFTSHOULDERC0 = CFrame.new(0.5, 0, 0) * CFrame.Angles(0, math.rad(-90), 0)
	local rng = Random.new(math.random(-65536, 65536))
	local shells = {}
	local timingwalk1, timingwalk2 = 0, 0

	m.Init = function(figure)
		start = os.clock()
		attacking = false
		state = 0
		timingwalk1, timingwalk2 = 0, 0
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		SetOverrideMovesetMusic("rbxassetid://1843497734", "CHAOS: INTENSE HYBRID ROCK", 1)
		randomdialog({
			"I have arrived.",
			"Order is restored.",
			"The anomaly will be corrected.",
		})
		if math.random(5) == 1 then
			task.delay(2, function()
				for _=1, 3 do
					notify("AUGUST 12TH 2036.")
					task.wait(2)
					notify("THE HEAT DEATH OF THE UNIVERSE.")
					task.wait(1.5)
				end
			end)
		else
			task.delay(2, randomdialog, {
				"Your time ends now.",
				"Your existence will be denied.",
				"You dare delay me?",
				"Thy death is now."
			})
		end
		gun = {
			Group = "Gun",
			Limb = "Right Arm",
			Offset = CFrame.identity
		}
		bullet = {
			Group = "Bullet",
			CFrame = CFrame.identity
		}
		table.insert(HatReanimator.HatCFrameOverride, gun)
		table.insert(HatReanimator.HatCFrameOverride, bullet)
		shells = {}
		mousedown = false
		if uisbegin then
			uisbegin:Disconnect()
		end
		if uisend then
			uisend:Disconnect()
		end
		local currentclick = nil
		uisbegin = UserInputService.InputBegan:Connect(function(input, gpe)
			if gpe then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				mousedown = true
				mouselock = false
				currentclick = input
			end
		end)
		ContextActionService:BindAction("Uhhhhhh_MGShoot", function(_, state, input)
			if state == Enum.UserInputState.Begin then
				mousedown = true
				mouselock = true
				currentclick = input
			end
		end, true)
		ContextActionService:SetTitle("Uhhhhhh_MGShoot", "M1")
		ContextActionService:SetPosition("Uhhhhhh_MGShoot", UDim2.new(1, -130, 1, -130))
		uisend = UserInputService.InputEnded:Connect(function(input, gpe)
			if input == currentclick then
				mousedown = false
				currentclick = nil
			end
		end)
		if chatconn then
			chatconn:Disconnect()
		end
		chatconn = OnPlayerChatted.Event:Connect(function(plr, msg)
			if plr == Player then
				notify(msg)
			end
		end)
		hum.WalkSpeed = 13 * figure:GetScale()
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock() - start
		scale = figure:GetScale()
		isdancing = not not figure:GetAttribute("IsDancing")
		rcp.FilterDescendantsInstances = {figure, Player.Character}
		
		-- get vii
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		
		-- joints
		local rt, nt, rst, lst, rht, lht = CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity
		local gunoff = CFrame.new(0, -0.5, 0.3) * CFrame.Angles(math.rad(90), math.rad(180), 0)
		
		local timingsine = t * 80 -- timing from original
		local onground = hum:GetState() == Enum.HumanoidStateType.Running
		
		-- animations
		local torsovelocity = root.Velocity.Magnitude
		local torsovelocityy = root.Velocity.Y
		local animationspeed = 11
		if state == 0 then
			if onground then
				if torsovelocity < 1 then
					rt = ROOTC0 * CFrame.new(0, 0.1, 0.05 * math.cos(timingsine / 60)) * CFrame.Angles(math.rad(-10), math.rad(10), math.rad(-40))
					nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-5.5 * math.sin(timingsine / 60)), math.rad(10), math.rad(40))
					rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(30), math.rad(40), 0) * RIGHTSHOULDERC0
					lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(150), math.rad(-70), math.rad(40)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -1 - 0.05 * math.cos(timingsine / 60), -0.01) * CFrame.Angles(math.rad(-20), math.rad(87), 0) * CFrame.Angles(math.rad(-7), 0, 0)
					lht = CFrame.new(-1, -1 - 0.05 * math.cos(timingsine / 60), -0.01) * CFrame.Angles(math.rad(-12), math.rad(-75), 0) * CFrame.Angles(math.rad(-7), 0, 0)
				else
					animationspeed = 18.5
					local tw1 = hum.MoveDirection * root.CFrame.LookVector
					local tw2 = hum.MoveDirection * root.CFrame.RightVector
					local lv = tw1.X + tw1.Z
					local rv = tw2.X + tw2.Z
					local d = (hum:GetMoveVelocity().Magnitude / scale) / 8
					timingwalk1 += dt * 80 * d / 18
					timingwalk2 += dt * 80 * d / 10
					local walk = math.cos(timingwalk1)
					local walk2 = math.sin(timingwalk1)
					local walk3 = math.cos(timingwalk2)
					local walk4 = math.sin(timingwalk2)
					local rh = CFrame.new(lv/10 * walk, 0, 0) * CFrame.Angles(math.sin(rv/5) * walk, 0, math.sin(-lv/2) * walk)
					local lh = CFrame.new(-lv/10 * walk, 0, 0) * CFrame.Angles(math.sin(rv/5) * walk, 0, math.sin(-lv/2) * walk)
					rt = ROOTC0 * CFrame.new(0, 0.1, -0.185 + 0.055 * walk3 + -walk4 / 8) * CFrame.Angles(math.rad((lv - lv/5 * walk3) * 10), math.rad((-rv + rv/5 * walk4) * 5), math.rad(-40))
					nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(math.rad(-2 * math.sin(timingsine / 10)), 0, math.rad(40))
					rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(30), math.rad(40), math.rad(0)) * RIGHTSHOULDERC0
					lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(150), math.rad(-70), math.rad(40)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -1 + 0.2 * walk2, -0.5) * CFrame.Angles(0, math.rad(120), 0) * rh * CFrame.Angles(0, 0, math.rad(-5 * walk))
					lht = CFrame.new(-1.3, -0.8 - 0.2 * walk2, -0.05) * CFrame.Angles(0, math.rad(-50), 0) * lh * CFrame.Angles(math.rad(-5), 0, math.rad(-5 * walk))
				end
			else
				if torsovelocityy > -1 then
					rt = ROOTC0
					nt = NECKC0 * CFrame.new(0, 0, 0.1) * CFrame.Angles(math.rad(-20), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(-15)) * RIGHTSHOULDERC0
					lst = CFrame.new(-1.5, 0.5, 0.2) * CFrame.Angles(math.rad(-20), 0, math.rad(15)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -.5, -0.5) * CFrame.Angles(math.rad(-15), math.rad(80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
					lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-10), math.rad(-80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
				else
					rt = ROOTC0 * CFrame.Angles(math.rad(15), 0, 0)
					nt = NECKC0 * CFrame.new(0, 0, 0.1) * CFrame.Angles(math.rad(20), 0, 0)
					rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(25)) * RIGHTSHOULDERC0
					lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(-10), 0, math.rad(-25)) * LEFTSHOULDERC0
					rht = CFrame.new(1, -.5, -0.5) * CFrame.Angles(math.rad(-15), math.rad(80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
					lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-10), math.rad(-80), 0) * CFrame.Angles(math.rad(-4), 0, 0)
				end
			end
			bullet.CFrame = root.CFrame + Vector3.new(0, -12, 0)
			if mousedown and not isdancing then
				state = 1
				statetime = os.clock()
				CreateSound(4473138327)
				hum.WalkSpeed = 0
				randomdialog({
					"Order is restored.",
					"The anomaly will be corrected.",
					"Your existence will be no more.",
					"You dare delay me?",
					"Your time ends now.",
					"I am bulletproof.",
				})
			end
		elseif state == 1 then
			animationspeed = 4
			AimTowards(MouseHit())
			rt = ROOTC0 * CFrame.new(0, 0.1, 0.1 * math.cos(timingsine / 35)) * CFrame.Angles(0, 0, math.rad(-40))
			nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(40))
			rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(-17), math.rad(40), 0) * RIGHTSHOULDERC0
			lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(100), math.rad(-70), math.rad(30)) * LEFTSHOULDERC0
			rht = CFrame.new(1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(87), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			lht = CFrame.new(-1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(-75), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			local hole = root.CFrame * CFrame.new(1.5, -1, -3)
			hole = HatReanimator.GetAttachmentCFrame(gun.Group .. "Attachment") or hole
			bullet.CFrame = hole
			if os.clock() - statetime > 0.5 then
				state = 2
				statetime = os.clock()
				if sndshoot then
					sndshoot:Destroy()
				end
				sndshoot = Instance.new("Sound", root)
				sndshoot.SoundId = "rbxassetid://146830885"
				sndshoot.Volume = 5
				sndshoot.Looped = true
				sndshoot.Playing = true
				if sndspin then
					sndspin:Destroy()
				end
				sndspin = Instance.new("Sound", root)
				sndspin.SoundId = "rbxassetid://2028334518"
				sndspin.Volume = 2.5
				sndspin.Looped = true
				sndspin.Playing = true
			end
		elseif state == 2 then
			local hit = MouseHit()
			AimTowards(hit)
			rt = ROOTC0 * CFrame.new(0, 0.1, 0.1 * math.cos(timingsine / 35)) * CFrame.Angles(0, 0, math.rad(-40))
			nt = NECKC0 * CFrame.new(0, 0, 0) * CFrame.Angles(0, 0, math.rad(40))
			rst = CFrame.new(1.5, 0.4, 0) * CFrame.Angles(math.rad(-17), math.rad(40), 0) * RIGHTSHOULDERC0
			lst = CFrame.new(-0.3, 0.3, -0.8) * CFrame.Angles(math.rad(100), math.rad(-70), math.rad(30)) * LEFTSHOULDERC0
			rht = CFrame.new(1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(87), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			lht = CFrame.new(-1, -1 - 0.1 * math.cos(timingsine / 35), -0.01) * CFrame.Angles(0, math.rad(-75), 0) * CFrame.Angles(math.rad(-4), 0, 0)
			local hole = root.CFrame * CFrame.new(1.5, -1, -3)
			hole = HatReanimator.GetAttachmentCFrame(gun.Group .. "Attachment") or hole
			local shots = math.min((os.clock() - statetime) * m.BooletsPerSec, 24)
			while shots > 1 do
				shots -= 1
				local dir = (hit - hole.Position).Unit
				if dir == dir then
					dir *= 45
					dir += rng:NextUnitVector() * m.HowBadIsAim * math.random(5, 75) / 10
					dir = dir.Unit
				else
					dir = Vector3.zAxis
				end
				local cast = ShootRaycast(hole.Position, dir * 4096)
				if cast then
					hit = cast.Position
					local part = cast.Instance
					if part and part.Parent and part.Parent.Parent then
						local hum = part.Parent:FindFirstChildOfClass("Humanoid") or part.Parent.Parent:FindFirstChildOfClass("Humanoid")
						if hum and hum.RootPart and not hum.RootPart:IsGrounded() then
							ReanimateFling(part.Parent)
						end
					end
				else
					hit = hole.Position + dir * 4096
				end
				local shootfx = Instance.new("Part", workspace)
				shootfx.Name = RandomString()
				shootfx.Anchored = true
				shootfx.CanCollide = false
				shootfx.CanTouch = false
				shootfx.CanQuery = false
				shootfx.Color = Color3.new(1, 0, 0)
				shootfx.CastShadow = false
				shootfx.Material = "Neon"
				shootfx.Size = Vector3.new(1, 1, 1)
				shootfx.Transparency = 0
				shootfx.CFrame = CFrame.lookAt(hole.Position:Lerp(hit, 0.5), hit)
				local shootfxm = Instance.new("SpecialMesh", shootfx)
				shootfxm.MeshType = "Brick"
				shootfxm.Scale = Vector3.new(0.1, 0.1, (hit - hole.Position).Magnitude)
				local ti = TweenInfo.new(5 / 60, Enum.EasingStyle.Linear)
				TweenService:Create(shootfx, ti, {Transparency = 1}):Play()
				TweenService:Create(shootfxm, ti, {Scale = Vector3.new(0.05, 0.05, (hit - hole.Position).Magnitude)}):Play()
				Debris:AddItem(shootfx, 0.5)
				if not m.NoShells then
					local shell = Instance.new("Part", workspace)
					shell.Name = RandomString()
					shell.Anchored = true
					shell.CanCollide = false
					shell.CanTouch = false
					shell.CanQuery = false
					shell.Color = Color3.new(1, 0.5, 0.5)
					shell.CastShadow = false
					shell.Material = "Neon"
					shell.Size = Vector3.new(0.1, 0.1, 0.1)
					shell.Shape = Enum.PartType.Ball
					shell.Transparency = 0.5
					shell.CFrame = HatReanimator.GetAttachmentCFrame("RightGripAttachment") or (root.CFrame * CFrame.new(1.5, -1, 0))
					shell.Velocity = root.Velocity + root.CFrame.RightVector * 30 + Vector3.new(math.random(-5, 5), 15, math.random(-5, 5))
					local a0 = Instance.new("Attachment", shell)
					a0.CFrame = CFrame.new(0, 0.05, 0)
					local a1 = Instance.new("Attachment", shell)
					a1.CFrame = CFrame.new(0, -0.05, 0)
					local b = Instance.new("Trail", shell)
					b.Attachment0 = a0
					b.Attachment1 = a1
					b.Brightness = 1
					b.LightEmission = 0.8
					b.LightInfluence = 0
					b.Color = ColorSequence.new(Color3.new(1, 0.25, 0.25))
					b.Transparency = NumberSequence.new(0.5)
					b.Lifetime = 5
					b.FaceCamera = true
					Debris:AddItem(shell, 10)
					table.insert(shells, {shell, 4})
					if #shells > 96 then
						local removed = table.remove(shells, 1)
						if removed and removed[1] then
							removed[1].Transparency = 1
						end
					end
				end
				hum.CameraOffset += rng:NextUnitVector() * 0.1 * m.ShakeValue
			end
			local bulletstate = (os.clock() // 0.05) % 2
			if bulletstate == 0 then
				bullet.CFrame = hole
				bullet.LastHit = nil
			else
				if not bullet.LastHit then
					local dir = hit - hole.Position
					if dir.Magnitude > 256 then
						dir = dir.Unit * 256
					end
					bullet.LastHit = hole.Position + dir
				end
				bullet.CFrame = CFrame.new(bullet.LastHit) * CFrame.Angles(math.random() * math.pi * 2, math.random() * math.pi * 2, math.random() * math.pi * 2)
			end
			statetime = os.clock() - shots / m.BooletsPerSec
			if not mousedown or isdancing then
				state = 0
				CreateSound(4498806901)
				CreateSound(4473119880)
				hum.WalkSpeed = 13 * scale
				if sndshoot then
					sndshoot:Destroy()
					sndshoot = nil
				end
				if sndspin then
					sndspin:Destroy()
					sndspin = nil
				end
				randomdialog({
					"Obstacle neutralized.",
					"Your time stops here.",
					"The anomaly has been corrected.",
					"Goodbye, mere mortal.",
				})
			end
		end
		
		-- shells
		local grav = Vector3.new(0, -workspace.Gravity, 0)
		for i,v in shells do
			local pos, vel = v[1].Position, v[1].Velocity
			local newpos, newvel = pos + vel * dt + (grav * dt * dt * 0.5), vel + grav * dt
			local hit = PhysicsRaycast(pos, newpos - pos)
			if hit then
				newpos = hit.Position + hit.Normal * 0.01
				newvel += hit.Normal * hit.Normal:Dot(newvel) * -2
				newvel += rng:NextUnitVector() * newvel.Magnitude * Vector3.new(1, 0, 1)
				newvel *= 0.5
			end
			v[1].Position, v[1].Velocity = newpos, newvel
			v[2] -= dt
			if v[2] <= 0 then
				v[1].Transparency = 1
				table.remove(shells, i)
			end
		end
		
		-- joints
		local rj = root:FindFirstChild("RootJoint")
		local nj = torso:FindFirstChild("Neck")
		local rsj = torso:FindFirstChild("Right Shoulder")
		local lsj = torso:FindFirstChild("Left Shoulder")
		local rhj = torso:FindFirstChild("Right Hip")
		local lhj = torso:FindFirstChild("Left Hip")
		
		-- interpolation
		local alpha = math.exp(-animationspeed * dt)
		joints.r = rt:Lerp(joints.r, alpha)
		joints.n = nt:Lerp(joints.n, alpha)
		joints.rs = rst:Lerp(joints.rs, alpha)
		joints.ls = lst:Lerp(joints.ls, alpha)
		joints.rh = rht:Lerp(joints.rh, alpha)
		joints.lh = lht:Lerp(joints.lh, alpha)
		joints.sw = gunoff:Lerp(joints.sw, alpha)
		
		-- apply transforms
		SetC0C1Joint(rj, joints.r, ROOTC0, scale)
		SetC0C1Joint(nj, joints.n, CFrame.new(0, -0.5, 0) * CFrame.Angles(math.rad(-90), 0, math.rad(180)), scale)
		SetC0C1Joint(rsj, joints.rs, CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		SetC0C1Joint(lsj, joints.ls, CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
		SetC0C1Joint(rhj, joints.rh, CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0), scale)
		SetC0C1Joint(lhj, joints.lh, CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0), scale)
		
		-- gun
		if m.UseSword then
			gun.Group = "Sword"
		else
			gun.Group = "Gun"
		end
		gun.Offset = joints.sw
		gun.Disable = not not isdancing
		
		-- dance reactions
		if isdancing and not dancereact then
			notify("Let's Go!")
		end
		dancereact = isdancing
	end
	m.Destroy = function(figure: Model?)
		ContextActionService:UnbindAction("Uhhhhhh_MGShoot")
		if uisbegin then
			uisbegin:Disconnect()
			uisbegin = nil
		end
		if uisend then
			uisend:Disconnect()
			uisbegin = nil
		end
		if chatconn then
			chatconn:Disconnect()
			chatconn = nil
		end
		root, torso, hum = nil, nil, nil
	end
	return m
end)

return modules