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

-- utils
local function ResetC0C1Joints(rj, nj, rsj, lsj, rhj, lhj)
	rj.C0 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	rj.C1 = CFrame.new(0, 0, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	nj.C0 = CFrame.new(0, 1, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	nj.C1 = CFrame.new(0, -0.5, 0, -1, 0, 0, 0, 0, 1, 0, 1, 0)
	rsj.C0 = CFrame.new(-1, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	rsj.C1 = CFrame.new(0.5, 0.5, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	lsj.C0 = CFrame.new(1, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	lsj.C1 = CFrame.new(-0.5, 0.5, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	rhj.C0 = CFrame.new(-1, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	rhj.C1 = CFrame.new(-0.5, 1, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0)
	lhj.C0 = CFrame.new(1, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
	lhj.C1 = CFrame.new(0.5, 1, 0, 0, 0, 1, 0, 1, 0, -1, 0, 0)
end
local function SetC0C1Joint(j, c0, c1, scale)
	local t = j.C0:Inverse() * c0 * c1:Inverse() * j.C1
	j.Transform = t + t.Position * (scale - 1)
end

local modules = {}
local function AddModule(m)
	table.insert(modules, m)
end

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "Minigun"
	m.InternalName = "IAMBULLETPROOF"
	m.Description = "Let's Go! Goodbye!"
	m.Assets = {}

	m.FPS30 = false
	m.ModeCap = 2
	m.EmulationSpeed = 1
	m.AutofireJump = true
	m.Config = function(parent: GuiBase2d)
		Util_CreateDropdown(parent, "Cap", {
			"Capless Mario"
			"Mario",
			"Wing Cap Mario",
			"Metal Mario",
			"Vanish Cap Mario",
		}, m.ModeCap).Changed:Connect(function(val)
			m.ModeCap = val
		end)
		Util_CreateSlider(parent, "Emulation Speed", m.EmulationSpeed, 0.25, 2, 0.25).Changed:Connect(function(val)
			m.EmulationSpeed = val
		end)
		Util_CreateSwitch(parent, "Autofire Jump", m.AutofireJump).Changed:Connect(function(val)
			m.AutofireJump = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.FPS30 = not not save.FPS30
		m.ModeCap = save.ModeCap or m.ModeCap
		m.EmulationSpeed = save.EmulationSpeed or m.EmulationSpeed
		m.AutofireJump = not save.ManualDrive
	end
	m.SaveConfig = function()
		return {
			FPS30 = m.FPS30,
			ModeCap = m.ModeCap,
			EmulationSpeed = m.EmulationSpeed,
			ManualDrive = not m.AutofireJump,
		}
	end

	local start = 0
	local hum, root, torso
	local function notify(text)
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
		text.TextColor3 = Color3.new(27/255, 42/255, 53/255)
		text.TextStrokeColor3 = Color3.new(0, 0, 0)
		task.spawn(function()
			local function update()
				text.Position = UDim2.new(0, math.random(-45, 45), 0, math.random(-5, 5))
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

	m.Init = function(figure)
		start = os.clock()
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
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
			})
		end
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock() - start
		scale = figure:GetScale()
		curcolor = Color3.fromHSV(os.clock() % 1, 1, 1)
		isdancing = not not figure:GetAttribute("IsDancing")
		rcp.FilterDescendantsInstances = {figure}
		
		-- get vii
		hum = figure:FindFirstChild("Humanoid")
		root = figure:FindFirstChild("HumanoidRootPart")
		torso = figure:FindFirstChild("Torso")
		if not hum then return end
		if not root then return end
		if not torso then return end
		
		-- fly
		if flight then
			hum.PlatformStand = true
			flyv.Parent = root
			flyg.Parent = root
			local camcf = CFrame.identity
			if workspace.CurrentCamera then
				camcf = workspace.CurrentCamera.CFrame
			end
			local _,angle,_ = camcf:ToEulerAngles(Enum.RotationOrder.YXZ)
			local movedir = CFrame.Angles(0, angle, 0):VectorToObjectSpace(hum.MoveDirection)
			flyv.Velocity = camcf:VectorToWorldSpace(movedir) * 50 * scale * m.FlySpeed
			flyg.CFrame = camcf.Rotation
		else
			hum.PlatformStand = false
			flyv.Parent = nil
			flyg.Parent = nil
		end
		
		-- jump fly
		if hum.Jump then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		
		-- float if not dancing
		if isdancing then
			hum.HipHeight = 0
		else
			-- and be fast if not attacking
			if attacking then
				hum.HipHeight = 3
			else
				hum.WalkSpeed = 50 * scale
				-- mode 3 is not floating
				if currentmode == 2 then
					hum.HipHeight = 0
				else
					hum.HipHeight = 3
				end
			end
		end
		
		-- joints
		local rt, nt, rst, lst, rht, lht = CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity, CFrame.identity
		local gunoff = CFrame.identity
		
		local timingsine = t * 60 -- timing from original
		local onground = hum:GetState() == Enum.HumanoidStateType.Running
		
		-- animations
		local sin50 = math.sin(timingsine / 50)
		local cos50 = math.cos(timingsine / 50)
		gunoff = CFrame.new(0.05, -1, -0.15) * CFrame.Angles(math.rad(180), 0, 0)
		if attacking or currentmode == 0 or (currentmode == 1 and sanitysongsync < 8) then
			if root.Velocity.Magnitude < 8 * scale or attacking then
				rt = ROOTC0 * CFrame.new(0.5 * cos50, 0, 10 * math.clamp(math.pow(1 - t, 3), 0, 1) - 0.5 * sin50)
				nt = NECKC0 * CFrame.Angles(math.rad(20), 0, 0)
				rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(135 + 8.5 * cos50), 0, math.rad(25)) * RIGHTSHOULDERC0
				lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(25 + 8.5 * cos50), 0, math.rad(-25 - 5 * math.cos(timingsine / 25))) * LEFTSHOULDERC0
				rht = CFrame.new(1, -0.5, -0.5) * CFrame.Angles(math.rad(-15 + 9 * math.cos(timingsine / 74)), math.rad(80), 0) * CFrame.Angles(math.rad(5 * math.cos(timingsine / 37)), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-15 - 9 * math.cos(timingsine / 54)), math.rad(-80), 0) * CFrame.Angles(math.rad(5 * math.cos(timingsine / 41)), 0, 0)
			else
				rt = ROOTC0 * CFrame.new(0.5 * cos50, 0, 10 * math.clamp(math.pow(1 - t, 3), 0, 1) - 0.5 * sin50) * CFrame.Angles(math.rad(40), 0, 0)
				nt = NECKC0 * CFrame.new(0, -0.25, 0) * CFrame.Angles(math.rad(-40), 0, 0)
				rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-45), 0, math.rad(5 + 2 * math.cos(timingsine / 19))) * RIGHTSHOULDERC0
				lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(-45), 0, math.rad(-5 - 2 * math.cos(timingsine / 19))) * LEFTSHOULDERC0
				rht = CFrame.new(1, -0.5, -0.5) * CFrame.Angles(math.rad(-15 + 9 * math.cos(timingsine / 74)), math.rad(80), 0) * CFrame.Angles(math.rad(5 * math.cos(timingsine / 37)), 0, 0)
				lht = CFrame.new(-1, -1, 0) * CFrame.Angles(math.rad(-15 - 9 * math.cos(timingsine / 54)), math.rad(-80), 0) * CFrame.Angles(math.rad(5 * math.cos(timingsine / 41)), 0, 0)
			end
		elseif currentmode == 1 and sanitysongsync >= 8 then
			rt = ROOTC0 * CFrame.new(0, 0, 0.5 * sin50) * CFrame.Angles(math.rad(20), 0, 0)
			nt = NECKC0
			rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-41.6 - 4 * sin50), 0, 0) * RIGHTSHOULDERC0
			lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(20), 0, math.rad(-10 - 10 * sin50)) * LEFTSHOULDERC0
			rht = CFrame.new(1, -1, -0.01) * CFrame.Angles(math.rad(10), math.rad(80), math.rad(10 + 10 * sin50))
			lht = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(20), math.rad(-80), math.rad(-10 - 10 * sin50))
			if root.Velocity.Magnitude < 8 * scale then
				nt = NECKC0 * CFrame.Angles(math.rad(20), math.rad(10 * math.cos(timingsine / 100)), 0)
				if math.random(60) == 1 then
					nt = NECKC0 * CFrame.Angles(math.rad(20 + math.random(-20, 20)), math.rad(10 * math.cos(timingsine / 100) + math.random(-20, 20)), math.rad(math.random(-20, 20)))
				end
				joints.n = nt
			end
		elseif currentmode == 2 then
			if fastboisegment then
				local sin2 = math.sin(timingsine / 2)
				rt = ROOTC0 * CFrame.new(0, 0, -0.2) * CFrame.Angles(math.rad(-45), 0, 0)
				nt = NECKC0 * CFrame.Angles(math.rad(-45), 0, 0)
				rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-135), 0, 0) * RIGHTSHOULDERC0
				lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(-135), 0, 0) * LEFTSHOULDERC0
				rht = CFrame.new(1, -1, -0.01) * CFrame.Angles(math.rad(75 * sin2), math.rad(90), 0)
				lht = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(-75 * sin2), math.rad(-90), 0)
				joints.n, joints.rs, joints.ls, joints.rh, joints.lh = nt, rst, lst, rht, lht
			else
				local sin5 = math.sin(timingsine / 5)
				rt = ROOTC0 * CFrame.new(0, 0, -0.2) * CFrame.Angles(math.rad(-timingsine * 6), 0, 0)
				nt = NECKC0
				rst = CFrame.new(1.5, 0.5, 0) * CFrame.Angles(math.rad(-75 * sin5), 0, 0) * RIGHTSHOULDERC0
				lst = CFrame.new(-1.5, 0.5, 0) * CFrame.Angles(math.rad(75 * sin5), 0, 0) * LEFTSHOULDERC0
				rht = CFrame.new(1, -1, -0.01) * CFrame.Angles(math.rad(75 * sin5), math.rad(90), 0)
				lht = CFrame.new(-1, -1, -0.01) * CFrame.Angles(math.rad(-75 * sin5), math.rad(-90), 0)
				joints.n, joints.rs, joints.ls, joints.rh, joints.lh = nt, rst, lst, rht, lht
			end
		end
		if currentmode == 1 then
			local sync = (GetOverrideMovesetMusicTime() - 0.776) // 2.679
			if sanitysongsync < sync then
				sanitysongsync = sync
				if sanitysongsync == 0 then
					notify("sAnIty", true)
				elseif sanitysongsync == 1 then
					notify("Light is peeking through the darkness")
				elseif sanitysongsync == 2 then
					notify("pUrIty", true)
				elseif sanitysongsync == 3 then
					notify("Can't feel anymore of the stress")
				elseif sanitysongsync == 4 then
					notify("sAnIty", true)
				elseif sanitysongsync == 5 then
					notify("It's already fading away")
				elseif sanitysongsync == 6 then
					notify("crUElty", true)
				elseif sanitysongsync == 7 then
					notify("Instincts controlling me")
				elseif sanitysongsync == 8 then
					task.delay(3, randomdialog, {
						"Immortality Lord can't sing.",
						"Take that, Immortality Lord!",
						"DEATH IS INESCAPABLE.",
						"And my instincts, is to be A GOD",
						"INSaNiTY- oh wrong timing... nevermind.",
						"I know you love these effects, " .. Player.Name,
						"Why would Roblox remove this audio...",
						"Now...",
						"did i cook chat?",
					})
					local function sphere(bonuspeed,type,pos,scale,value,color)
						local type = type
						local rng = Instance.new("Part",workspace)
						rng.Anchored = true
						rng.BrickColor = color
						rng.CanCollide = false
						rng.FormFactor = 3
						rng.Name = RandomString()
						rng.Material = "Neon"
						rng.Size = Vector3.new(1,1,1)
						rng.Transparency = 0
						rng.TopSurface = 0
						rng.BottomSurface = 0
						rng.CFrame = pos
						local rngm = Instance.new("SpecialMesh",rng)
						rngm.MeshType = "Sphere"
						rngm.Scale = scale
						local scaler2 = 1
						if type == "Add" then
							scaler2 = 1*value
						elseif type == "Divide" then
							scaler2 = 1/value
						end
						task.spawn(function()
							for i = 0,10/bonuspeed,0.1 do
								task.wait()
								if type == "Add" then
									scaler2 = scaler2 - 0.01*value/bonuspeed
								elseif type == "Divide" then
									scaler2 = scaler2 - 0.01/value*bonuspeed
								end
								rng.BrickColor = BrickColor.random()
								rng.Transparency = rng.Transparency + 0.01*bonuspeed
								rngm.Scale = rngm.Scale + Vector3.new(scaler2*bonuspeed,scaler2*bonuspeed,scaler2*bonuspeed)
							end
							rng:Destroy()
						end)
					end
					local function sphere2(bonuspeed,type,pos,scale,value,value2,value3,color)
						local type = type
						local rng = Instance.new("Part",workspace)
						rng.Anchored = true
						rng.BrickColor = color
						rng.CanCollide = false
						rng.FormFactor = 3
						rng.Name = RandomString()
						rng.Material = "Neon"
						rng.Size = Vector3.new(1,1,1)
						rng.Transparency = 0
						rng.TopSurface = 0
						rng.BottomSurface = 0
						rng.CFrame = pos
						local rngm = Instance.new("SpecialMesh",rng)
						rngm.MeshType = "Sphere"
						rngm.Scale = scale
						local scaler2 = 1
						local scaler2b = 1
						local scaler2c = 1
						if type == "Add" then
							scaler2 = 1*value
							scaler2b = 1*value2
							scaler2c = 1*value3
						elseif type == "Divide" then
							scaler2 = 1/value
							scaler2b = 1/value2
							scaler2c = 1/value3
						end
						task.spawn(function()
							for i = 0,10/bonuspeed,0.1 do
								task.wait()
								if type == "Add" then
									scaler2 = scaler2 - 0.01*value/bonuspeed
									scaler2b = scaler2b - 0.01*value/bonuspeed
									scaler2c = scaler2c - 0.01*value/bonuspeed
								elseif type == "Divide" then
									scaler2 = scaler2 - 0.01/value*bonuspeed
									scaler2b = scaler2b - 0.01/value*bonuspeed
									scaler2c = scaler2c - 0.01/value*bonuspeed
								end
								rng.Transparency = rng.Transparency + 0.01*bonuspeed
								rngm.Scale = rngm.Scale + Vector3.new(scaler2*bonuspeed,scaler2b*bonuspeed,scaler2c*bonuspeed)
							end
							rng:Destroy()
						end)
					end
					local function PixelBlockX(bonuspeed,FastSpeed,type,pos,x1,y1,z1,value,color,outerpos)
						local type = type
						local rng = Instance.new("Part",workspace)
						rng.Anchored = true
						rng.BrickColor = color
						rng.CanCollide = false
						rng.FormFactor = 3
						rng.Name = RandomString()
						rng.Material = "Neon"
						rng.Size = Vector3.new(1,1,1)
						rng.Transparency = 0
						rng.TopSurface = 0
						rng.BottomSurface = 0
						rng.CFrame = pos
						rng.CFrame = rng.CFrame + rng.CFrame.lookVector*outerpos
						local rngm = Instance.new("SpecialMesh",rng)
						rngm.MeshType = "Brick"
						rngm.Scale = Vector3.new(x1,y1,z1)
						local scaler2 = 1
						local speeder = FastSpeed/10
						if type == "Add" then
							scaler2 = 1*value
						elseif type == "Divide" then
							scaler2 = 1/value
						end
						task.spawn(function()
							for i = 0,10/bonuspeed,0.1 do
								task.wait()
								if type == "Add" then
									scaler2 = scaler2 - 0.01*value/bonuspeed
								elseif type == "Divide" then
									scaler2 = scaler2 - 0.01/value*bonuspeed
								end
								rng.BrickColor = BrickColor.random()
								speeder = speeder - 0.01*FastSpeed*bonuspeed/10
								rng.CFrame = rng.CFrame + rng.CFrame.lookVector*speeder*bonuspeed
								rng.Transparency = rng.Transparency + 0.01*bonuspeed
								rngm.Scale = rngm.Scale - Vector3.new(scaler2*bonuspeed,scaler2*bonuspeed,scaler2*bonuspeed)
							end
							rng:Destroy()
						end)
					end
					local function sphereMK(bonuspeed,FastSpeed,type,pos,x1,y1,z1,value,color,outerpos)
						local type = type
						local rng = Instance.new("Part",workspace)
						rng.Anchored = true
						rng.BrickColor = color
						rng.CanCollide = false
						rng.FormFactor = 3
						rng.Name = RandomString()
						rng.Material = "Neon"
						rng.Size = Vector3.new(1,1,1)
						rng.Transparency = 0
						rng.TopSurface = 0
						rng.BottomSurface = 0
						rng.CFrame = pos
						rng.CFrame = rng.CFrame + rng.CFrame.lookVector*outerpos
						local rngm = Instance.new("SpecialMesh",rng)
						rngm.MeshType = "Sphere"
						rngm.Scale = Vector3.new(x1,y1,z1)
						local scaler2 = 1
						local speeder = FastSpeed
						if type == "Add" then
							scaler2 = 1*value
						elseif type == "Divide" then
							scaler2 = 1/value
						end
						task.spawn(function()
							for i = 0,10/bonuspeed,0.1 do
								task.wait()
								if type == "Add" then
									scaler2 = scaler2 - 0.01*value/bonuspeed
								elseif type == "Divide" then
									scaler2 = scaler2 - 0.01/value*bonuspeed
								end
								rng.BrickColor = BrickColor.random()
								speeder = speeder - 0.01*FastSpeed*bonuspeed
								rng.CFrame = rng.CFrame + rng.CFrame.lookVector*speeder*bonuspeed
								rng.Transparency = rng.Transparency + 0.01*bonuspeed
								rngm.Scale = rngm.Scale + Vector3.new(scaler2*bonuspeed,scaler2*bonuspeed,0)
							end
							rng:Destroy()
						end)
					end
					local function slash(bonuspeed,rotspeed,rotatingop,typeofshape,type,typeoftrans,pos,scale,value,color)
						local type = type
						local rotenable = rotatingop
						local rng = Instance.new("Part",workspace)
						rng.Anchored = true
						rng.BrickColor = color
						rng.CanCollide = false
						rng.FormFactor = 3
						rng.Name = RandomString()
						rng.Material = "Neon"
						rng.Size = Vector3.new(1,1,1)
						rng.Transparency = 0
						if typeoftrans == "In" then
							rng.Transparency = 1
						end
						rng.TopSurface = 0
						rng.BottomSurface = 0
						rng.CFrame = pos
						local rngm = Instance.new("SpecialMesh",rng)
						rngm.MeshType = "FileMesh"
						if typeofshape == "Normal" then
							rngm.MeshId = "rbxassetid://662586858"
						elseif typeofshape == "Round" then
							rngm.MeshId = "rbxassetid://662585058"
						end
						rngm.Scale = scale
						local scaler2 = 1/10
						if type == "Add" then
							scaler2 = 1*value/10
						elseif type == "Divide" then
							scaler2 = 1/value/10
						end
						local randomrot = math.random(1,2)
						task.spawn(function()
							for i = 0,10/bonuspeed,0.1 do
								task.wait()
								if type == "Add" then
									scaler2 = scaler2 - 0.01*value/bonuspeed/10
								elseif type == "Divide" then
									scaler2 = scaler2 - 0.01/value*bonuspeed/10
								end
								if rotenable == true then
									if randomrot == 1 then
										rng.CFrame = rng.CFrame*CFrame.Angles(0,math.rad(rotspeed*bonuspeed/2),0)
									elseif randomrot == 2 then
										rng.CFrame = rng.CFrame*CFrame.Angles(0,math.rad(-rotspeed*bonuspeed/2),0)
									end
								end
								if typeoftrans == "Out" then
									rng.Transparency = rng.Transparency + 0.01*bonuspeed
								elseif typeoftrans == "In" then
									rng.Transparency = rng.Transparency - 0.01*bonuspeed
								end
								rngm.Scale = rngm.Scale + Vector3.new(scaler2*bonuspeed/10,0,scaler2*bonuspeed/10)
							end
							rng:Destroy()
						end)
					end
					sphere(1,"Add",torso.CFrame*CFrame.Angles(math.rad(math.random(-10,10)),math.rad(math.random(-10,10)),math.rad(math.random(-10,10))),Vector3.new(1,100000,1)*scale,0.6,BrickColor.new("Really black"))
					sphere2(math.random(1,4),"Add",torso.CFrame*CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360))),Vector3.new(5,1,5)*scale,-0.005,math.random(25,100)/25,-0.005,BrickColor.new("Institutional white"))
					sphere(1,"Add",torso.CFrame,Vector3.new(1,1,1)*scale,0.8,BrickColor.new("Really black"))
					sphere2(2,"Add",torso.CFrame,Vector3.new(5,5,5)*scale,0.5,0.5,0.5,BrickColor.new("Institutional white"))
					sphere2(2,"Add",torso.CFrame,Vector3.new(5,5,5)*scale,0.75,0.75,0.75,BrickColor.new("Institutional white"))
					sphere2(3,"Add",torso.CFrame,Vector3.new(5,5,5)*scale,1,1,1,BrickColor.new("Institutional white"))
					sphere2(3,"Add",torso.CFrame,Vector3.new(5,5,5)*scale,1.25,1.25,1.25,BrickColor.new("Institutional white"))
					sphere2(1,"Add",torso.CFrame,Vector3.new(5,10000,5)*scale,0.5,0.5,0.5,BrickColor.new("Institutional white"))
					sphere2(2,"Add",torso.CFrame,Vector3.new(5,10000,5)*scale,0.6,0.6,0.6,BrickColor.new("Institutional white"))
					for i = 0,49 do
						PixelBlockX(1,math.random(1,20),"Add",torso.CFrame*CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360))),8*scale,8*scale,8*scale,0.16,BrickColor.new("Really black"),0)
						sphereMK(2.5,-1,"Add",torso.CFrame*CFrame.Angles(math.rad(math.random(-360,360)),math.rad(math.random(-360,360)),math.rad(math.random(-360,360))),2.5*scale,2.5*scale,25*scale,-0.025,BrickColor.new("Really black"),0)
						slash(math.random(10,20)/10,5,true,"Round","Add","Out",torso.CFrame*CFrame.new(0,-3*scale,0)*CFrame.Angles(math.rad(math.random(-30,30)),math.rad(math.random(-30,30)),math.rad(math.random(-40,40))),Vector3.new(0.05,0.01,0.05)*scale,math.random(50,60)/250,BrickColor.new("Really black"))
					end
					CreateSound(239000203)
					CreateSound(1042716828)
				end
			end
			if sanitysongsync >= 8 then
				curcolor = Color3.fromHSV(math.random(0, 19) / 20, 1, 1)
			end
		end
		if currentmode == 2 then
			local dir = hum.MoveDirection * Vector3.new(1, 0, 1)
			if dir.Magnitude > 0 then
				dir = dir.Unit * 300
			end
			local segment = dir.Magnitude > 0
			if segment ~= fastboisegment then
				fastboisegment = segment
				if segment then
					SetOverrideMovesetMusic(AssetGetContentId("LightningCannonFastBoi.mp3"), "RUNNING IN THE '90s", 1, NumberRange.new(24.226, 36.333))
					SetOverrideMovesetMusicTime(24.226)
				else
					SetOverrideMovesetMusic(AssetGetContentId("LightningCannonFastBoi.mp3"), "RUNNING IN THE '90s", 1, NumberRange.new(0, 24.226))
					SetOverrideMovesetMusicTime((os.clock() - fastboistart) % 24.226)
				end
			end
			curcolor = Color3.new(0, 0, 0)
			if math.random(5) == 1 then
				curcolor = Color3.new(0, 0, math.random() * 0.4)
			end
			root.Velocity = Vector3.new(dir.X, root.Velocity.Y, dir.Z)
		end
		if animationOverride then
			rt, nt, rst, lst, rht, lht, gunoff = animationOverride(timingsine, rt, nt, rst, lst, rht, lht, gunoff)
		end
		for _,v in walkingwheel:GetChildren() do
			if v:IsA("BasePart") then
				local i = tonumber(v.Name)
				if i then
					if currentmode == 2 and not fastboisegment then
						v.CFrame = root.CFrame * CFrame.new(0, 0.01, 0) * CFrame.Angles(math.rad(i), 0, 0) * CFrame.new(0, 3.1 * scale, 0)
						v.Size = Vector3.new(2, 0.2, 0.56) * scale
						v.Color = curcolor
						v.Transparency = 0
					else
						v.Transparency = 1
					end
				end
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
		local alpha = math.exp(-18.6 * dt)
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
		
		-- wings
		if isdancing then
			leftwing.Offset = CFrame.new(-0.15, 0, 0) * CFrame.Angles(0, math.rad(-15), 0)
			rightwing.Offset = CFrame.new(0.15, 0, 0) * CFrame.Angles(0, math.rad(15), 0)
		else
			if m.Bee then
				leftwing.Offset = CFrame.new(-0.15, 0, 0) * CFrame.Angles(0, math.rad(-15 + 25 * math.cos(timingsine)), 0)
				rightwing.Offset = CFrame.new(0.15, 0, 0) * CFrame.Angles(0, math.rad(15 - 25 * math.cos(timingsine)), 0)
			else
				leftwing.Offset = CFrame.new(-0.15, 0, 0) * CFrame.Angles(0, math.rad(-15 + 25 * math.cos(timingsine / 25)), 0)
				rightwing.Offset = CFrame.new(0.15, 0, 0) * CFrame.Angles(0, math.rad(15 - 25 * math.cos(timingsine / 25)), 0)
			end
		end
		
		-- gun
		if m.UseSword then
			gun.Group = "Sword"
		else
			gun.Group = "Gun"
		end
		gun.Offset = joints.sw
		
		-- dance reactions
		if isdancing then
			local name = figure:GetAttribute("DanceInternalName")
			if name == "RAGDOLL" then
				dancereact.Ragdoll = dancereact.Ragdoll or 0
				if t - dancereact.Ragdoll > 1 then
					notify("ow my leg.")
				end
				dancereact.Ragdoll = t
			end
			if name == "SpeedAndKaiCenat" then
				if not dancereact.AlightMotion then
					task.delay(1, notify, "I have an idea, " .. Player.Name)
					task.delay(4, notify, "What if... Immortality Lord is the other guy?")
				end
				dancereact.AlightMotion = true
			end
		end
	end
	m.Destroy = function(figure: Model?)
	end
	return m
end)

return modules