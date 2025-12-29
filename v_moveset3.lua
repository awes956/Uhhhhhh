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
		local Hehe = Instance.new("TextLabel", dialog)
		Hehe.BackgroundTransparency = 1
		Hehe.BorderSizePixel = 0
		Hehe.Text = ""
		Hehe.Font = Enum.Font.Fantasy
		Hehe.TextScaled = true
		Hehe.TextStrokeTransparency = 0
		Hehe.Size = UDim2.new(1, 0, 1, 0)
		Hehe.TextColor3 = Color3.new(27/255,42/255,53/255)
		task.spawn(function()
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
				text1.Text = string.sub(message, 1, l)
				text2.Text = string.sub(message, 1, l)
			until ll >= #message
			text1.Text = message
		coroutine.resume(coroutine.create(function()
			while Hehe ~= nil do
			swait()
			Hehe.Position = UDim2.new(math.random(-.4,.4),math.random(-5,5),.05,math.random(-5,5))
			
			Hehe.TextStrokeColor3 = Color3.new(0,0,0)
			end
			end))
		for i = 1,string.len(text),1 do
		swait()
		Hehe.Text = string.sub(text,1,i)
		end
		wait(1)--Re[math.random(1, 93)]
		for i = 0, 1, .025 do
		swait()
		Bill.ExtentsOffset = Vector3.new(math.random(-i, i), math.random(-i, i), math.random(-i, i))
		Hehe.TextStrokeTransparency = i
		Hehe.TextTransparency = i
		end
		Bill:Destroy()
 end)
chat()

	m.Init = function(figure)
		local root = figure:FindFirstChild("HumanoidRootPart")
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock()
		local hum = figure:FindFirstChildOfClass("Humanoid")
	end
	m.Destroy = function(figure: Model?)
	end
	return m
end)

return modules