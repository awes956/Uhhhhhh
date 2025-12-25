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
	m.ModuleType = "DANCE"
	m.Name = "It's Going Down"
	m.Description = "first dance in v_dance2.lua"
	m.Assets = {"GoingDown.anim", "GoingDown.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("GoingDown.mp3"), "IT'S GOING DOWN", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = true
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("GoingDown.anim"))
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
	m.Name = "Results"
	m.Description = "real ones know ts from pizza tower\neffortless upload"
	m.Assets = {"Results.anim", "Results.mp3"}

	m.Config = function(parent: GuiBase2d)
	end

	local animator = nil
	m.Init = function(figure: Model)
		SetOverrideDanceMusic(AssetGetContentId("Results.mp3"), "Results! - PT Sugary Spire OST", 1)
		animator = AnimLib.Animator.new()
		animator.rig = figure
		animator.looped = false
		animator.track = AnimLib.Track.fromfile(AssetGetPathFromFilename("Results.anim"))
	end
	m.Update = function(dt: number, figure: Model)
		animator:Step(GetOverrideDanceMusicTime())
	end
	m.Destroy = function(figure: Model?)
		animator = nil
	end
	return m
end)

return modules