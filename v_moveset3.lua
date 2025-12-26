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
	m.Name = "Super Mario 64"
	m.InternalName = "SM64.Z64"
	m.Description = "itsumi mario! press start to play!\nmost of the code were copied from maximum_adhd's sm64-roblox\n\nhere are some wierd ways to defeat enemies in super mario 64\nwe can make chain chomp fall out of bounds\nwe can throw king bob-omb out of bounds\nwe can knock the chill bully off this platform and move him around, though he ends up dying elsewhere\nwe can get eye-rock to fall off the edge and then he doesnt come back up\nwe can get bowser to fall off the edge and then he doesnt come back up\nwe can drop mips into other levels\nwe can drop the 2 ukikis off the edge\nwe can drop the baby penguin off the edge\nwe can make the mama penguin fall off the edge\nwe can make the racing penguin fall off the edge\nwe can make koopa the quick fall off the edge\nwe can send koopa the quick to a parallel universe\nwe can get a bully stuck underground\nwe can get a bully stuck in a corner\nwe can make klepto lunge at us and then stuck in a pillar\nwe can throw a bob-omb buddy out of bounds\nwe can push a heave ho out of bounds using a block\nwe can make bubba fall off the edge\nand we can make yoshi fall off the castle roof"
	m.Assets = {}

	m.FPS30 = false
	m.ModeCap = 2
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
	end
	m.LoadConfig = function(save: any)
		m.FPS30 = not not save.FPS30
		m.ModeCap = save.ModeCap or m.ModeCap
	end
	m.SaveConfig = function()
		return {
			FPS30 = m.FPS30,
			ModeCap = m.ModeCap,
		}
	end

	local VECTOR3_XZ = Vector3.new(1, 0, 1)
	local XZ_DIRS = {
		Vector3.new(-1, 0, 0),
		Vector3.new(0, 0, -1),
		Vector3.new(1, 0, 0),
		Vector3.new(0, 0, 1),
	}
	local maryo = {}
	maryo.Enums = {}
	maryo.Enums.ActionGroups = {
		-- Group Flags
		STATIONARY = bit32.lshift(0, 6),
		MOVING = bit32.lshift(1, 6),
		AIRBORNE = bit32.lshift(2, 6),
		SUBMERGED = bit32.lshift(3, 6),
		CUTSCENE = bit32.lshift(4, 6),
		AUTOMATIC = bit32.lshift(5, 6),
		OBJECT = bit32.lshift(6, 6),

		-- Mask for capturing these Flags
		GROUP_MASK = 0b_000000111000000,
	}
	maryo.Enums.ActionFlags = {
		STATIONARY = bit32.lshift(1, 9),
		MOVING = bit32.lshift(1, 10),
		AIR = bit32.lshift(1, 11),
		INTANGIBLE = bit32.lshift(1, 12),
		SWIMMING = bit32.lshift(1, 13),
		METAL_WATER = bit32.lshift(1, 14),
		SHORT_HITBOX = bit32.lshift(1, 15),
		RIDING_SHELL = bit32.lshift(1, 16),
		INVULNERABLE = bit32.lshift(1, 17),
		BUTT_OR_STOMACH_SLIDE = bit32.lshift(1, 18),
		DIVING = bit32.lshift(1, 19),
		ON_POLE = bit32.lshift(1, 20),
		HANGING = bit32.lshift(1, 21),
		IDLE = bit32.lshift(1, 22),
		ATTACKING = bit32.lshift(1, 23),
		ALLOW_VERTICAL_WIND_ACTION = bit32.lshift(1, 24),
		CONTROL_JUMP_HEIGHT = bit32.lshift(1, 25),
		ALLOW_FIRST_PERSON = bit32.lshift(1, 26),
		PAUSE_EXIT = bit32.lshift(1, 27),
		SWIMMING_OR_FLYING = bit32.lshift(1, 28),
		WATER_OR_TEXT = bit32.lshift(1, 29),
		THROWING = bit32.lshift(1, 31),
	}
	maryo.Enums.Action = {
		-- group 0x000: stationary actions
		IDLE = 0x0C400201,
		START_SLEEPING = 0x0C400202,
		SLEEPING = 0x0C000203,
		WAKING_UP = 0x0C000204,
		PANTING = 0x0C400205,
		HOLD_PANTING_UNUSED = 0x08000206,
		HOLD_IDLE = 0x08000207,
		HOLD_HEAVY_IDLE = 0x08000208,
		STANDING_AGAINST_WALL = 0x0C400209,
		COUGHING = 0x0C40020A,
		SHIVERING = 0x0C40020B,
		IN_QUICKSAND = 0x0002020D,
		UNKNOWN_0002020E = 0x0002020E,
		CROUCHING = 0x0C008220,
		START_CROUCHING = 0x0C008221,
		STOP_CROUCHING = 0x0C008222,
		START_CRAWLING = 0x0C008223,
		STOP_CRAWLING = 0x0C008224,
		SLIDE_KICK_SLIDE_STOP = 0x08000225,
		SHOCKWAVE_BOUNCE = 0x00020226,
		FIRST_PERSON = 0x0C000227,
		BACKFLIP_LAND_STOP = 0x0800022F,
		JUMP_LAND_STOP = 0x0C000230,
		DOUBLE_JUMP_LAND_STOP = 0x0C000231,
		FREEFALL_LAND_STOP = 0x0C000232,
		SIDE_FLIP_LAND_STOP = 0x0C000233,
		HOLD_JUMP_LAND_STOP = 0x08000234,
		HOLD_FREEFALL_LAND_STOP = 0x08000235,
		AIR_THROW_LAND = 0x80000A36,
		TWIRL_LAND = 0x18800238,
		LAVA_BOOST_LAND = 0x08000239,
		TRIPLE_JUMP_LAND_STOP = 0x0800023A,
		LONG_JUMP_LAND_STOP = 0x0800023B,
		GROUND_POUND_LAND = 0x0080023C,
		BRAKING_STOP = 0x0C00023D,
		BUTT_SLIDE_STOP = 0x0C00023E,
		HOLD_BUTT_SLIDE_STOP = 0x0800043F,

		-- group 0x040: moving (ground) actions
		WALKING = 0x04000440,
		HOLD_WALKING = 0x00000442,
		TURNING_AROUND = 0x00000443,
		FINISH_TURNING_AROUND = 0x00000444,
		BRAKING = 0x04000445,
		RIDING_SHELL_GROUND = 0x20810446,
		HOLD_HEAVY_WALKING = 0x00000447,
		CRAWLING = 0x04008448,
		BURNING_GROUND = 0x00020449,
		DECELERATING = 0x0400044A,
		HOLD_DECELERATING = 0x0000044B,
		BEGIN_SLIDING = 0x00000050,
		HOLD_BEGIN_SLIDING = 0x00000051,
		BUTT_SLIDE = 0x00840452,
		STOMACH_SLIDE = 0x008C0453,
		HOLD_BUTT_SLIDE = 0x00840454,
		HOLD_STOMACH_SLIDE = 0x008C0455,
		DIVE_SLIDE = 0x00880456,
		MOVE_PUNCHING = 0x00800457,
		CROUCH_SLIDE = 0x04808459,
		SLIDE_KICK_SLIDE = 0x0080045A,
		HARD_BACKWARD_GROUND_KB = 0x00020460,
		HARD_FORWARD_GROUND_KB = 0x00020461,
		BACKWARD_GROUND_KB = 0x00020462,
		FORWARD_GROUND_KB = 0x00020463,
		SOFT_BACKWARD_GROUND_KB = 0x00020464,
		SOFT_FORWARD_GROUND_KB = 0x00020465,
		GROUND_BONK = 0x00020466,
		DEATH_EXIT_LAND = 0x00020467,
		JUMP_LAND = 0x04000470,
		FREEFALL_LAND = 0x04000471,
		DOUBLE_JUMP_LAND = 0x04000472,
		SIDE_FLIP_LAND = 0x04000473,
		HOLD_JUMP_LAND = 0x00000474,
		HOLD_FREEFALL_LAND = 0x00000475,
		QUICKSAND_JUMP_LAND = 0x00000476,
		HOLD_QUICKSAND_JUMP_LAND = 0x00000477,
		TRIPLE_JUMP_LAND = 0x04000478,
		LONG_JUMP_LAND = 0x00000479,
		BACKFLIP_LAND = 0x0400047A,

		-- group 0x080: airborne actions
		JUMP = 0x03000880,
		DOUBLE_JUMP = 0x03000881,
		TRIPLE_JUMP = 0x01000882,
		BACKFLIP = 0x01000883,
		STEEP_JUMP = 0x03000885,
		WALL_KICK_AIR = 0x03000886,
		SIDE_FLIP = 0x01000887,
		LONG_JUMP = 0x03000888,
		WATER_JUMP = 0x01000889,
		DIVE = 0x0188088A,
		FREEFALL = 0x0100088C,
		TOP_OF_POLE_JUMP = 0x0300088D,
		BUTT_SLIDE_AIR = 0x0300088E,
		FLYING_TRIPLE_JUMP = 0x03000894,
		SHOT_FROM_CANNON = 0x00880898,
		FLYING = 0x10880899,
		RIDING_SHELL_JUMP = 0x0281089A,
		RIDING_SHELL_FALL = 0x0081089B,
		VERTICAL_WIND = 0x1008089C,
		HOLD_JUMP = 0x030008A0,
		HOLD_FREEFALL = 0x010008A1,
		HOLD_BUTT_SLIDE_AIR = 0x010008A2,
		HOLD_WATER_JUMP = 0x010008A3,
		TWIRLING = 0x108008A4,
		FORWARD_ROLLOUT = 0x010008A6,
		AIR_HIT_WALL = 0x000008A7,
		RIDING_HOOT = 0x000004A8,
		GROUND_POUND = 0x008008A9,
		SLIDE_KICK = 0x018008AA,
		AIR_THROW = 0x830008AB,
		JUMP_KICK = 0x018008AC,
		BACKWARD_ROLLOUT = 0x010008AD,
		CRAZY_BOX_BOUNCE = 0x000008AE,
		SPECIAL_TRIPLE_JUMP = 0x030008AF,
		BACKWARD_AIR_KB = 0x010208B0,
		FORWARD_AIR_KB = 0x010208B1,
		HARD_FORWARD_AIR_KB = 0x010208B2,
		HARD_BACKWARD_AIR_KB = 0x010208B3,
		BURNING_JUMP = 0x010208B4,
		BURNING_FALL = 0x010208B5,
		SOFT_BONK = 0x010208B6,
		LAVA_BOOST = 0x010208B7,
		GETTING_BLOWN = 0x010208B8,
		THROWN_FORWARD = 0x010208BD,
		THROWN_BACKWARD = 0x010208BE,

		-- group 0x0C0: submerged actions
		WATER_IDLE = 0x380022C0,
		HOLD_WATER_IDLE = 0x380022C1,
		WATER_ACTION_END = 0x300022C2,
		HOLD_WATER_ACTION_END = 0x300022C3,
		DROWNING = 0x300032C4,
		BACKWARD_WATER_KB = 0x300222C5,
		FORWARD_WATER_KB = 0x300222C6,
		WATER_DEATH = 0x300032C7,
		WATER_SHOCKED = 0x300222C8,
		BREASTSTROKE = 0x300024D0,
		SWIMMING_END = 0x300024D1,
		FLUTTER_KICK = 0x300024D2,
		HOLD_BREASTSTROKE = 0x300024D3,
		HOLD_SWIMMING_END = 0x300024D4,
		HOLD_FLUTTER_KICK = 0x300024D5,
		WATER_SHELL_SWIMMING = 0x300024D6,
		WATER_THROW = 0x300024E0,
		WATER_PUNCH = 0x300024E1,
		WATER_PLUNGE = 0x300022E2,
		CAUGHT_IN_WHIRLPOOL = 0x300222E3,
		METAL_WATER_STANDING = 0x080042F0,
		HOLD_METAL_WATER_STANDING = 0x080042F1,
		METAL_WATER_WALKING = 0x000044F2,
		HOLD_METAL_WATER_WALKING = 0x000044F3,
		METAL_WATER_FALLING = 0x000042F4,
		HOLD_METAL_WATER_FALLING = 0x000042F5,
		METAL_WATER_FALL_LAND = 0x000042F6,
		HOLD_METAL_WATER_FALL_LAND = 0x000042F7,
		METAL_WATER_JUMP = 0x000044F8,
		HOLD_METAL_WATER_JUMP = 0x000044F9,
		METAL_WATER_JUMP_LAND = 0x000044FA,
		HOLD_METAL_WATER_JUMP_LAND = 0x000044FB,

		-- group 0x100: cutscene actions
		DISAPPEARED = 0x00001300,
		INTRO_CUTSCENE = 0x04001301,
		STAR_DANCE_EXIT = 0x00001302,
		STAR_DANCE_WATER = 0x00001303,
		FALL_AFTER_STAR_GRAB = 0x00001904,
		READING_AUTOMATIC_DIALOG = 0x20001305,
		READING_NPC_DIALOG = 0x20001306,
		STAR_DANCE_NO_EXIT = 0x00001307,
		READING_SIGN = 0x00001308,
		JUMBO_STAR_CUTSCENE = 0x00001909,
		WAITING_FOR_DIALOG = 0x0000130A,
		DEBUG_FREE_MOVE = 0x0000130F,
		STANDING_DEATH = 0x00021311,
		QUICKSAND_DEATH = 0x00021312,
		ELECTROCUTION = 0x00021313,
		SUFFOCATION = 0x00021314,
		DEATH_ON_STOMACH = 0x00021315,
		DEATH_ON_BACK = 0x00021316,
		EATEN_BY_BUBBA = 0x00021317,
		END_PEACH_CUTSCENE = 0x00001918,
		CREDITS_CUTSCENE = 0x00001319,
		END_WAVING_CUTSCENE = 0x0000131A,
		PULLING_DOOR = 0x00001320,
		PUSHING_DOOR = 0x00001321,
		WARP_DOOR_SPAWN = 0x00001322,
		EMERGE_FROM_PIPE = 0x00001923,
		SPAWN_SPIN_AIRBORNE = 0x00001924,
		SPAWN_SPIN_LANDING = 0x00001325,
		EXIT_AIRBORNE = 0x00001926,
		EXIT_LAND_SAVE_DIALOG = 0x00001327,
		DEATH_EXIT = 0x00001928,
		UNUSED_DEATH_EXIT = 0x00001929,
		FALLING_DEATH_EXIT = 0x0000192A,
		SPECIAL_EXIT_AIRBORNE = 0x0000192B,
		SPECIAL_DEATH_EXIT = 0x0000192C,
		FALLING_EXIT_AIRBORNE = 0x0000192D,
		UNLOCKING_KEY_DOOR = 0x0000132E,
		UNLOCKING_STAR_DOOR = 0x0000132F,
		ENTERING_STAR_DOOR = 0x00001331,
		SPAWN_NO_SPIN_AIRBORNE = 0x00001932,
		SPAWN_NO_SPIN_LANDING = 0x00001333,
		BBH_ENTER_JUMP = 0x00001934,
		BBH_ENTER_SPIN = 0x00001535,
		TELEPORT_FADE_OUT = 0x00001336,
		TELEPORT_FADE_IN = 0x00001337,
		SHOCKED = 0x00020338,
		SQUISHED = 0x00020339,
		HEAD_STUCK_IN_GROUND = 0x0002033A,
		BUTT_STUCK_IN_GROUND = 0x0002033B,
		FEET_STUCK_IN_GROUND = 0x0002033C,
		PUTTING_ON_CAP = 0x0000133D,

		-- group 0x140: "automatic" actions
		HOLDING_POLE = 0x08100340,
		GRAB_POLE_SLOW = 0x00100341,
		GRAB_POLE_FAST = 0x00100342,
		CLIMBING_POLE = 0x00100343,
		TOP_OF_POLE_TRANSITION = 0x00100344,
		TOP_OF_POLE = 0x00100345,
		START_HANGING = 0x08200348,
		HANGING = 0x00200349,
		HANG_MOVING = 0x0020054A,
		LEDGE_GRAB = 0x0800034B,
		LEDGE_CLIMB_SLOW = 0x0000054C,
		LEDGE_CLIMB_DOWN = 0x0000054D,
		LEDGE_CLIMB_FAST = 0x0000054E,
		GRABBED = 0x00020370,
		IN_CANNON = 0x00001371,
		TORNADO_TWIRLING = 0x10020372,

		-- group 0x180: object actions
		PUNCHING = 0x00800380,
		PICKING_UP = 0x00000383,
		DIVE_PICKING_UP = 0x00000385,
		STOMACH_SLIDE_STOP = 0x00000386,
		PLACING_DOWN = 0x00000387,
		THROWING = 0x80000588,
		HEAVY_THROW = 0x80000589,
		PICKING_UP_BOWSER = 0x00000390,
		HOLDING_BOWSER = 0x00000391,
		RELEASING_BOWSER = 0x00000392,
	}
	-- states preprocess
	for k,v in maryo.Enums.Action do
		local w = {}
		for l,x in maryo.Enums.ActionFlags do
			w[l] = bit32.band(v, x) ~= 0
		end
		w.GROUP = "UNKNOWN"
		local y = bit32.band(v, maryo.Enums.ActionGroups.GROUP_MASK)
		for l,x in maryo.Enums.ActionGroups do
			if l ~= "GROUP_MASK" then
				if y == x then
					w.GROUP = l
					break
				end
			end
		end
		w.ID = bit32.band(v, 0x1FF)
		w.NAME = k
		maryo.Enums.Action[k] = w
	end
	maryo.Enums.TerrainType = {
		[Enum.Material.Mud] = "GRASS",
		[Enum.Material.Grass] = "GRASS",
		[Enum.Material.Ground] = "GRASS",
		[Enum.Material.LeafyGrass] = "GRASS",
		
		[Enum.Material.Ice] = "ICE",
		[Enum.Material.Marble] = "ICE",
		[Enum.Material.Glacier] = "ICE",
		
		[Enum.Material.Wood] = "SPOOKY",
		[Enum.Material.WoodPlanks] = "SPOOKY",
		
		[Enum.Material.Foil] = "METAL",
		[Enum.Material.Metal] = "METAL",
		[Enum.Material.DiamondPlate] = "METAL",
		[Enum.Material.CorrodedMetal] = "METAL",
		
		[Enum.Material.Rock] = "STONE",
		[Enum.Material.Salt] = "STONE",
		[Enum.Material.Brick] = "STONE",
		[Enum.Material.Slate] = "STONE",
		[Enum.Material.Basalt] = "STONE",
		[Enum.Material.Pebble] = "STONE",
		[Enum.Material.Granite] = "STONE",
		[Enum.Material.Sandstone] = "STONE",
		[Enum.Material.Cobblestone] = "STONE",
		[Enum.Material.CrackedLava] = "STONE",
		
		[Enum.Material.Snow] = "SNOW",
		[Enum.Material.Sand] = "SAND",
		[Enum.Material.Water] = "WATER",
		[Enum.Material.Fabric] = "SNOW",
	}
	function maryo.IsAnimAtEnd()
		return maryo.AnimFrame >= maryo.AnimFrameCount
	end
	function maryo.IsAnimPastEnd()
		return maryo.AnimFrame >= maryo.AnimFrameCount - 2
	end
	function maryo.SetAnimation(anim)
		local data = maryo.Animations[anim]
		assert(data)
		if maryo.AnimCurrent == data then
			return maryo.AnimFrame
		end
		maryo.AnimFrameCount = data.C
		maryo.AnimCurrent = data
		maryo.AnimAccelAssist = 0
		maryo.AnimAccel = 0
		maryo.AnimReset = true
		maryo.AnimDirty = true
		maryo.AnimFrame = data.F
		return data.F
	end
	function maryo.SetAnimationWithAccel(anim, accel)
		local data = maryo.Animations[anim]
		assert(data)
		if maryo.AnimCurrent ~= data then
			maryo.SetAnimation(anim)
			maryo.AnimAccelAssist = -accel
		end
		maryo.AnimAccel = accel
		return maryo.AnimFrame
	end
	function maryo.SetAnimToFrame(frame)
		if maryo.AnimAccel ~= 0 then
			maryo.AnimAccelAssist = bit32.lshift(frame, 0x10) + maryo.AnimAccel
			maryo.AnimFrame = bit32.rshift(maryo.AnimAccelAssist, 0x10)
		else
			maryo.AnimFrame = frame + 1
		end
		maryo.AnimDirty = true
		maryo.AnimSetFrame = maryo.AnimFrame
	end
	function maryo.IsAnimPastFrame(frame)
		local isPastFrame = false
		local accel = maryo.AnimAccel
		if accel ~= 0 then
			local assist = maryo.AnimAccelAssist
			local accelFrame = bit32.lshift(frame, 0x10)
			isPastFrame = assist > accelFrame and accelFrame >= assist - accel
		else
			isPastFrame = maryo.AnimFrame == frame + 1
		end
		return isPastFrame
	end
	function maryo.PlaySound(sound)
		maryo.Sounds[sound] = true
	end
	function maryo.PlaySoundIfNoFlag(sound, flagname)
		if not maryo.Flags[flagname] then
			maryo.Flags[flagname] = true
			maryo.PlaySound(sound)
		end
	end
	function maryo.PlayJumpSound()
		if maryo.Flags.MARIO_SOUND_PLAYED then
			return
		end
		if maryo.Action.NAME == "TRIPLE_JUMP" then
			maryo.PlaySound("MARIO_YAHOO_WAHA_YIPPEE")
		elseif maryo.Action.NAME == "JUMP_KICK" then
			maryo.PlaySound("MARIO_PUNCH_HOO")
		else
			maryo.PlaySound("MARIO_YAH_WAH_HOO")
		end
		maryo.Flags.MARIO_SOUND_PLAYED = true
	end
	function maryo.PlayMaterialSound(sound)
		if maryo.TerrainType then
			maryo.PlaySound(sound .. "_" .. maryo.TerrainType)
		end
		maryo.PlaySound(sound)
	end
	function maryo.PlayActionSound(sound)
		maryo.PlaySoundIfNoFlag(sound, "ACTION_SOUND_PLAYED")
	end
	function maryo.PlayLandingSound(sound)
		sound = sound or "ACTION_TERRAIN_LANDING"
		if maryo.Flags.METAL_CAP then
			maryo.PlayMaterialSound("ACTION_METAL_LANDING")
			return
		end
		maryo.PlayMaterialSound(sound)
	end
	function maryo.PlayLandingSoundOnce()
		sound = sound or "ACTION_TERRAIN_LANDING"
		if maryo.Flags.METAL_CAP then
			maryo.PlayActionSound("ACTION_METAL_LANDING")
			return
		end
		maryo.PlayActionSound(sound)
	end
	function maryo.PlayHeavyLandingSound(sound)
		sound = sound or "ACTION_TERRAIN_LANDING"
		if maryo.Flags.METAL_CAP then
			maryo.PlayMaterialSound("ACTION_METAL_HEAVY_LANDING")
			return
		end
		maryo.PlayMaterialSound(sound)
	end
	function maryo.PlayHeavyLandingSoundOnce()
		sound = sound or "ACTION_TERRAIN_LANDING"
		if maryo.Flags.METAL_CAP then
			maryo.PlayActionSound("ACTION_METAL_HEAVY_LANDING")
			return
		end
		maryo.PlayActionSound(sound)
	end
	function maryo.PlayMarioSound(actionSound, marioSound)
		if marioSound == nil then
			marioSound = "MARIO_JUMP"
		end
		if actionSound == "ACTION_TERRAIN_JUMP" then
			if maryo.Flags.METAL_CAP then
				maryo.PlayActionSound("ACTION_METAL_JUMP")
			else
				maryo.PlayActionSound(actionSound)
			end
		else
			maryo.PlaySoundIfNoFlag(actionSound, "ACTION_SOUND_PLAYED")
		end
		if marioSound == "MARIO_JUMP" then
			maryo.PlayJumpSound()
		else
			maryo.PlaySoundIfNoFlag(marioSound, "MARIO_SOUND_PLAYED")
		end
	end
	function maryo.ToRotation(angle)
		return CFrame.fromAxisAngle(Vector3.yAxis, angle.Y) * CFrame.fromAxisAngle(Vector3.xAxis, -angle.X) * CFrame.fromAxisAngle(Vector3.zAxis, -angle.Z)
	end
	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.RespectCanCollide = true
	rcp.IgnoreWater = true
	function maryo.Raycast(pos, dir)
		return workspace:Raycast(pos, dir, rcp)
	end
	function maryo.FindFloor(pos)
		local height = -10000
		local result = maryo.Raycast(pos + Vector3.new(0, 5, 0), Vector3.new(0, -10000, 0))
		if result then
			height = result.Position.Y
		end
		return height, result
	end
	function maryo.FindCeiling(pos, height)
		local height = 10000
		local result = maryo.Raycast(Vector3.new(pos.X, (height or pos.Y) + 4, pos.Z), Vector3.new(0, 10000, 0))
		if result then
			height = result.Position.Y
		end
		return height, result
	end
	function maryo.FindWalls(pos, offset, radius)
		local origin = pos + Vector3.new(0, offset, 0)
		local lastwall = nil
		local disp = Vector3.zero
		for _,dir in XZ_DIRS do
			local contact = Util.RaycastSM64(origin, dir * radius)
			if contact then
				local normal = contact.Normal
				if math.abs(normal.Y) < 0.01 then
					local surface = contact.Position
					local move = (surface - pos) * VECTOR3_XZ
					local dist = move.Magnitude
					if dist < radius then
						disp += (contact.Normal * VECTOR3_XZ) * (radius - dist)
						lastwall = contact
					end
				end
			end
		end
		return pos + disp, lastwall
	end
	function maryo.SetForwardVel(forwardVel)
		maryo.ForwardVel = forwardVel
		maryo.SlideVelX = math.sin(maryo.FaceAngle.Y) * forwardVel
		maryo.SlideVelZ = math.cos(maryo.FaceAngle.Y) * forwardVel
		maryo.Velocity = Vector3.new(maryo.SlideVelX, maryo.Velocity.Y, maryo.SlideVelZ)
	end
	function maryo.SetUpwardVel(upwardVel)
		maryo.Velocity = Vector3.new(maryo.Velocity.X, upwardVel, maryo.Velocity.Z)
	end
	function maryo.SetHeight(height)
		maryo.Position = Vector3.new(maryo.Position.X, height, maryo.Position.Z)
	end
	function maryo.SetFaceYaw(yaw)
		maryo.FaceAngle = Vector3.new(maryo.FaceAngle.X, maryo.NormalizeAngle(yaw), maryo.FaceAngle.Z)
	end
	function maryo.GetFloorFriction()
		local f = maryo.Floor
		if f then
			local hit = f.Instance
			if hit then
				local friction = 0.7
				if hit:IsA("BasePart") then
					friction = hit.CurrentPhysicalProperties.Friction
				else
					-- its likely a terrain
					friction = PhysicalProperties.new(f.Material).Friction
				end
				if friction <= 0.025 then
					return "WHOOPSIES"
				elseif friction <= 0.5 then
					return "SLIPPERY"
				elseif friction >= 0.9 then
					return "STICKY"
				end
			end
		end
		return "DEFAULT"
	end
	function maryo.GetTerrainType()
		local f = maryo.Floor
		if f then
			return maryo.Enums.TerrainType[f.Material] or "DEFAULT"
		end
		return "DEFAULT"
	end
	-- this is for my reference
	-- positions scaled: 1 stud is 20 maryo units
	-- angle range [-pi, pi)
	-- cuz signed short does -0x8000 to 0x7FFF
	-- hoping cframes also do the same ^^
	function maryo.NormalizeAngle(angle)
		while angle < -math.pi do
			angle += 2 * math.pi
		end
		while angle >= math.pi do
			angle -= 2 * math.pi
		end
		return angle
	end
	function maryo.FacingDownhill(backwards)
		local faceAngleYaw = maryo.FaceAngle.Y
		if backwards and maryo.ForwardVel < 0 then
			faceAngleYaw = maryo.NormalizeAngle(faceAngleYaw + math.pi)
		end
		return math.abs(maryo.NormalizeAngle(maryo.FloorAngle - faceAngleYaw)) < math.pi / 2 -- 0x4000 is 90 degrees :3
	end
	function maryo.FloorAngleClassify(a, b, c, d)
		local f = maryo.Floor
		if f then
			local class = maryo.GetFloorFriction()
			local d = a
			if class == "WHOOPSIES" then
				d = b
			elseif class == "SLIPPERY" then
				d = c
			elseif class == "STICKY" then
				d = d
			end
			return floor.Normal.Y <= math.cos(math.rad(d))
		end
		return false
	end
	function maryo.FloorIsSlippery()
		return maryo.FloorAngleClassify(90, 10, 20, 38)
	end
	function maryo.FloorIsSlope()
		return maryo.FloorAngleClassify(15, 5, 10, 20)
	end
	function maryo.FloorIsSteep()
		return maryo.FloorAngleClassify(30, 1, 20, 30)
	end
	function maryo.FindFloorHeightRelativePolar(angle, dist)
		local x = math.sin(maryo.FaceAngle.Y + angle) * dist
		local z = math.cos(maryo.FaceAngle.Y + angle) * dist
		return maryo.FindFloor(maryo.Position + Vector3.new(x, 5, z))
	end
	function maryo.FindFloorSlope(angle)
		local x = math.sin(maryo.FaceAngle.Y + angle) * 5
		local z = math.cos(maryo.FaceAngle.Y + angle) * 5
		local floor1 = maryo.FindFloor(maryo.Position + Vector3.new(x, 5, z))
		local floor2 = maryo.FindFloor(maryo.Position + Vector3.new(-x, 5, -z))
		local result = 0
		if floor1 and floor2 then
			local delta1 = floor1 - maryo.Position.Y
			local delta2 = maryo.Position.Y - floor2
			if delta * delta1 < delta2 * delta2 then
				result = math.atan2(5, forwardYDelta)
			else
				result = math.atan2(5, backwardYDelta)
			end
		end
		return maryo.NormalizeAngle(result)
	end
	function maryo.SetSteepJumpAction()
		maryo.SteepJumpYaw = maryo.FaceAngle.Y
		if maryo.ForwardVel > 0 then
			local angleTemp = maryo.FloorAngle + math.pi
			local faceAngleTemp = maryo.FaceAngle.Y - angleTemp
			local y = math.sin(faceAngleTemp) * maryo.ForwardVel
			local x = math.cos(faceAngleTemp) * maryo.ForwardVel * 0.75
			maryo.ForwardVel = math.sqrt(y * y + x * x)
			maryo.SetFaceYaw(math.atan2(x, y) + angleTemp)
		end
		maryo.SetAction("STEEP_JUMP")
	end
	function maryo.SetYVelBasedOnFSpeed(inity, mult)
		maryo.SetUpwardVel(inity + maryo.ForwardVel * mult)
		if maryo.SquishTimer ~= 0 or maryo.QuicksandDepth > 1 then
			maryo.Velocity *= Vector3.new(1, 0.5, 1)
		end
	end
	function maryo.SetActionAirborne(action, arg)
		if maryo.SquishTimer ~= 0 or maryo.QuicksandDepth > 1 then
			if action.NAME == "DOUBLE_JUMP" or action.NAME == "TWIRLING" then
				action = maryo.Enums.Action.JUMP
			end
		end
		if action.NAME == "DOUBLE_JUMP" then
			maryo.SetYVelBasedOnFSpeed(52, 0.25)
			maryo.ForwardVel *= 0.8
		elseif action.NAME == "BACKFLIP" then
			maryo.AnimReset = true
			maryo.ForwardVel = -16
			maryo.SetYVelBasedOnFSpeed(62, 0)
		elseif action.NAME == "TRIPLE_JUMP" then
			maryo.SetYVelBasedOnFSpeed(69, 0)
			maryo.ForwardVel *= 0.8
		elseif action.NAME == "FLYING_TRIPLE_JUMP" then
			maryo.SetYVelBasedOnFSpeed(82, 0)
		elseif action.NAME == "WATER_JUMP" or action.NAME == "HOLD_WATER_JUMP" then
			if arg == 0 then
				maryo.SetYVelBasedOnFSpeed(42, 0)
			end
		elseif action.NAME == "BURNING_JUMP" then
			maryo.SetUpwardVel(31.5)
			maryo.ForwardVel = 8
		elseif action.NAME == "RIDING_SHELL_JUMP" then
			maryo.SetYVelBasedOnFSpeed(42, 0.25)
		elseif action.NAME == "JUMP" or action.NAME == "HOLD_JUMP" then
			maryo.AnimReset = true
			maryo.SetYVelBasedOnFSpeed(42, 0.25)
			maryo.ForwardVel *= 0.8
		elseif action.NAME == "WALL_KICK_AIR" or action.NAME == "TOP_OF_POLE_JUMP" then
			maryo.SetYVelBasedOnFSpeed(62, 0)
			if maryo.ForwardVel < 24 then
				maryo.ForwardVel = 24
			end
			maryo.WallKickTimer = 0
		elseif action.NAME == "SIDE_FLIP" then
			maryo.SetYVelBasedOnFSpeed(62, 0)
			maryo.ForwardVel = 8
			maryo.SetFaceYaw(maryo.IntendedYaw)
		elseif action.NAME == "STEEP_JUMP" then
			maryo.AnimReset = true
			maryoSetYVelBasedOnFSpeed(42, 0.25)
			maryo.FaceAngle = Vector3.new(-math.pi / 4, maryo.FaceAngle.Y, maryo.FaceAngle.Z)
		elseif action.NAME == "LAVA_BOOST" then
			maryo.SetUpwardVel(84)
			if arg == 0 then
				maryo.ForwardVel = 0
			end
		elseif action.NAME == "DIVE" then
			local forwardVel = maryo.ForwardVel + 15
			if forwardVel > 48 then
				forwardVel = 48
			end
			maryo.SetForwardVel(forwardVel)
		elseif action.NAME == "LONG_JUMP" then
			maryo.AnimReset = true
			maryo.SetYVelBasedOnFSpeed(30, 0)
			maryo.LongJumpIsSlow = maryo.ForwardVel <= 16
			maryo.ForwardVel *= 1.5
			if maryo.ForwardVel > 48 then
				maryo.ForwardVel = 48
			end
		elseif action.NAME == "SLIDE_KICK" then
			maryo.SetUpwardVel(12)
			if maryo.ForwardVel < 32 then
				maryo.ForwardVel = 32
			end
		elseif action.NAME == "JUMP_KICK" then
			maryo.SetUpwardVel(20)
		end
		maryo.PeakHeight = maryo.Position.Y
		maryo.Flags.MOVING_UP_IN_AIR = true
		return action
	end
	function maryo.SetActionMoving(action, arg)
		local forwardVel = maryo.ForwardVel
		local frick = maryo.GetFloorFriction()
		local mag = math.min(maryo.IntendedMag, 8)
		if action.NAME == "WALKING" then
			if frick ~= "WHOOPSIES" then
				if 0.0 <= forwardVel and forwardVel < mag then
					maryo.ForwardVel = mag
				end
			end
			maryo.WalkingPitch = 0
		elseif action.NAME == "HOLD_WALKING" then
			if 0.0 <= forwardVel and forwardVel < mag / 2 then
				maryo.ForwardVel = mag / 2
			end
		elseif action.NAME == "BEGIN_SLIDING" then
			if maryo.FacingDownhill() then
				action = maryo.Enums.Action.BUTT_SLIDE
			else
				action = maryo.Enums.Action.STOMACH_SLIDE
			end
		elseif action.NAME == "HOLD_BEGIN_SLIDING" then
			if maryo.FacingDownhill() then
				action = maryo.Enums.Action.HOLD_BUTT_SLIDE
			else
				action = maryo.Enums.Action.HOLD_STOMACH_SLIDE
			end
		end
		return action
	end
	function maryo.SetActionSubmerged(action, arg)
		if action.NAME == "METAL_WATER_JUMP" or action.NAME == "HOLD_METAL_WATER_JUMP" then
			maryo.SetUpwardVel(32)
		end
		return action
	end
	function maryo.SetActionCutscene(action, arg)
		if action.NAME == "EMERGE_FROM_PIPE" then
			maryo.SetUpwardVel(52)
		elseif action.NAME == "FALL_AFTER_STAR_GRAB" then
			maryo.SetForwardVel(0)
		elseif action.NAME == "SPAWN_SPIN_AIRBORNE" then
			maryo.SetForwardVel(2)
		elseif action.NAME == "SPECIAL_EXIT_AIRBORNE" or action.NAME == "SPECIAL_DEATH_EXIT" then
			maryo.SetUpwardVel(64)
		end
		return action
	end
	function maryo.SetAction(action, arg)
		action = maryo.Enums.Action[action] or action or nil
		arg = arg or 0
		if action then
			if action.GROUP == "MOVING" then
				action = maryo.SetActionMoving(action, arg)
			elseif action.GROUP == "AIRBORNE" then
				action = maryo.SetActionAirborne(action, arg)
			elseif action.GROUP == "SUBMERGED" then
				action = maryo.SetActionSubmerged(action, arg)
			elseif action.GROUP == "CUTSCENE" then
				action = maryo.SetActionCutscene(action, arg)
			end
			maryo.Flags.ACTION_SOUND_PLAYED = false
			maryo.Flags.MARIO_SOUND_PLAYED = false
			if not maryo.Action.AIR then
				maryo.Flags.FALLING_FAR = false
			end
		end
		maryo.PrevAction = maryo.Action
		maryo.Action = action
		maryo.ActionArg = arg or 0
		maryo.ActionState = 0
		maryo.ActionTimer = 0
		return true
	end
	function maryo.SetJumpFromLanding()
		if maryo.FloorIsSteep() then
			maryo.SetSteepJumpAction()
		elseif maryo.DoubleJumpTimer == 0 or maryo.SquishTimer ~= 0 then
			maryo.SetAction("JUMP")
		else
			local prev = maryo.PrevAction or {}
			if prev.NAME == "JUMP_LAND" then
				maryo.SetAction("DOUBLE_JUMP")
			elseif prev.NAME == "FREEFALL_LAND" then
				maryo.SetAction("DOUBLE_JUMP")
			elseif prev.NAME == "SIDE_FLIP_LAND_STOP" then
				maryo.SetAction("DOUBLE_JUMP")
			elseif prev.NAME == "DOUBLE_JUMP_LAND" then
				if maryo.Flags.WING_CAP then
					maryo.SetAction("FLYING_TRIPLE_JUMP")
				elseif maryo.ForwardVel > 20 then
					maryo.SetAction("TRIPLE_JUMP")
				else
					maryo.SetAction("JUMP")
				end
			else
				maryo.SetAction("JUMP")
			end
		end
		maryo.DoubleJumpTimer = 0
		return true
	end
	function maryo.SetJumpingAction(action, arg)
		if maryo.FloorIsSteep() then
			maryo.SetSteepJumpAction()
		else
			maryo.SetAction(action, arg)
		end
		return true
	end
	function maryo.HurtAndSetAction(action, arg, damage)
		maryo.HealthSub = damage
		maryo.SetAction(action, arg)
	end
	function maryo.CheckCommonActionExits()
		if maryo.Input.A_PRESSED then
			maryo.SetAction("JUMP")
			return true
		end
		if maryo.Input.OFF_FLOOR then
			maryo.SetAction("FREEFALL")
			return true
		end
		if maryo.Input.NONZERO_ANALOG then
			maryo.SetAction("WALKING")
			return true
		end
		if maryo.Input.ABOVE_SLIDE then
			maryo.SetAction("BEGIN_SLIDING")
			return true
		end
		return false
	end
	function maryo.UpdatePunchSequence()
		local endAction, crouchEndAction
		if maryo.Action.MOVING then
			endAction = Action.WALKING
			crouchEndAction = Action.CROUCH_SLIDE
		else
			endAction = Action.IDLE
			crouchEndAction = Action.CROUCHING
		end
		local arg = maryo.ActionArg
		if arg == 0 or arg == 1 then
			if arg == 0 then
				maryo.PlaySound("MARIO_PUNCH_YAH")
			end
			maryo.SetAnimation("FIRST_PUNCH")
			maryo.ActionArg = maryo.IsAnimAtEnd() and 2 or 1
			if maryo.AnimFrame >= 2 then
				maryo.Flags.PUNCHING = true
			end
		elseif arg == 2 then
			maryo.SetAnimation("FIRST_PUNCH_FAST")
			if maryo.AnimFrame <= 0 then
				maryo.Flags.PUNCHING = true
			end
			if maryo.Input.B_PRESSED then
				maryo.ActionArg = 3
			end
			if maryo.IsAnimAtEnd() then
				maryo.SetAction(endAction)
			end
		elseif arg == 3 or arg == 4 then
			if arg == 3 then
				maryo.PlaySound("MARIO_PUNCH_WAH")
			end
			maryo.SetAnimation("SECOND_PUNCH")
			maryo.ActionArg = maryo.IsAnimPastEnd() and 5 or 4
			if maryo.AnimFrame > 0 then
				maryo.Flags.PUNCHING = true
			end
		elseif arg == 5 then
			maryo.SetAnimation("SECOND_PUNCH_FAST")
			if maryo.AnimFrame <= 0 then
				maryo.Flags.PUNCHING = true
			end
			if maryo.Input.B_PRESSED then
				maryo.ActionArg = 6
			end
			if maryo.IsAnimAtEnd() then
				maryo.SetAction(endAction)
			end
		elseif arg == 6 then
			maryo.PlayActionSound("MARIO_PUNCH_HOO", 1)
			local animFrame = maryo.SetAnimation("GROUND_KICK")
			if animFrame >= 0 and animFrame < 8 then
				maryo.Flags.KICKING = true
			end
			if maryo.IsAnimAtEnd() then
				maryo.SetAction(endAction)
			end
		elseif arg == 9 then
			maryo.PlayActionSound("MARIO_PUNCH_HOO", 1)
			maryo.SetAnimation("BREAKDANCE")
			local animFrame = maryo.AnimFrame
			if animFrame >= 2 and animFrame < 8 then
				maryo.Flags.TRIPPING = true
			end
			if maryo.IsAnimAtEnd() then
				maryo.SetAction(crouchEndAction)
			end
		end
		return false
	end
	function maryo.BonkReflection(negateSpeed)
		local wall = maryo.Wall
		if wall ~= nil then
			local wallAngle = math.atan2(wall.Normal.Z, wall.Normal.X)
			maryo.SetFaceYaw(wallAngle - (maryo.FaceAngle.Y - wallAngle))
			maryo.PlaySound(if maryo.Flags.METAL_CAP then "ACTION_METAL_BONK" else "ACTION_BONK")
		else
			maryo.PlaySound("ACTION_HIT")
		end
		if negateSpeed then
			maryo.SetForwardVel(-maryo.ForwardVel)
		else
			maryo.SetFaceYaw(maryo.FaceAngle.Y + math.pi)
		end
	end
	function maryo.PushOffSteepFloor(action, arg)
		local floorDYaw = maryo.NormalizeAngle(maryo.FloorAngle - maryo.FaceAngle.Y)
		if floorDYaw > -math.pi / 4 and floorDYaw < math.pi / 4 then
			maryo.ForwardVel = 16
			maryo.SetFaceYaw(maryo.FloorAngle)
		else
			maryo.ForwardVel = -16
			maryo.SetFaceYaw(maryo.FloorAngle + math.pi)
		end
		maryo.SetAction(action, arg)
	end
	function maryo.StopAndSetHeightToFloor()
		maryo.SetForwardVel(0)
		maryo.Velocity *= Vector3.new(1, 0, 1)
		maryo.SetHeight(maryo.FloorHeight)
	end
	function maryo.StationaryGroundStep()
		maryo.SetForwardVel(0)
		return maryo.PerformGroundStep()
	end
	function maryo.PerformGroundQuarterStep(nextPos)
		local lowerPos, _ = maryo.FindWallCollisions(nextPos, 1.5, 1.2)
		nextPos = lowerPos
		local upperPos, upperWall = maryo.FindWallCollisions(nextPos, 3, 2.5)
		nextPos = upperPos
		local floorHeight, f = maryo.FindFloor(nextPos)
		local ceilHeight, _ = maryo.FindCeiling(nextPos, floorHeight)
		maryo.Wall = upperWall
		if f == nil then
			return "HIT_WALL_STOP_QSTEPS"
		end
		if nextPos.Y > floorHeight + 5 then
			if nextPos.Y + 8 >= ceilHeight then
				return "HIT_WALL_STOP_QSTEPS"
			end
			maryo.Floor = f
			maryo.FloorHeight = floorHeight
			return "LEFT_GROUND"
		end
		if floorHeight + 8 >= ceilHeight then
			return "HIT_WALL_STOP_QSTEPS"
		end
		maryo.Floor = f
		maryo.FloorHeight = floorHeight
		maryo.Position = Vector3.new(nextPos.X, floorHeight, nextPos.Z)
		if upperWall then
			local wallDYaw = math.abs(maryo.NormalizeAngle(math.atan2(upperWall.Normal.Z, upperWall.Normal.X) - maryo.FaceAngle.Y))
			if wallDYaw >= math.pi / 6 and wallDYaw <= math.pi / 3 then
				return "NONE"
			end
			return "HIT_WALL_CONTINUE_QSTEPS"
		end
		return "NONE"
	end
	function maryo.PerformGroundStep()
		local f = maryo.Floor
		if not f then
			return "NONE"
		end
		local stepResult = "NONE"
		for i = 1, 4 do
			local intendedX = maryo.Position.X + f.Normal.Y * (maryo.Velocity.X / 80)
			local intendedZ = maryo.Position.Z + f.Normal.Y * (maryo.Velocity.Z / 80)
			local intendedY = maryo.Position.Y
			local intendedPos = Vector3.new(intendedX, intendedY, intendedZ)
			stepResult = maryo.PerformGroundQuarterStep(intendedPos)
			if stepResult == "LEFT_GROUND" or stepResult == "HIT_WALL_STOP_QSTEPS" then
				break
			end
		end
		maryo.TerrainType = maryo.GetTerrainType()
		if stepResult == "HIT_WALL_CONTINUE_QSTEPS" then
			stepResult = "HIT_WALL"
		end
		return stepResult
	end
	function maryo.CheckLedgeGrab(wall, intendedPos, nextPos)
		if maryo.Velocity.Y > 0 then
			return false
		end
		local dispX = nextPos.X - intendedPos.X
		local dispZ = nextPos.Z - intendedPos.Z
		if dispX * maryo.Velocity.X + dispZ * maryo.Velocity.Z > 0 then
			return false
		end
		local ledgeX = nextPos.X - (wall.Normal.X * 3)
		local ledgeZ = nextPos.Z - (wall.Normal.Z * 3)
		local ledgePos = Vector3.new(ledgeX, nextPos.Y + 8, ledgeZ)
		local ledgeY, ledgeFloor = maryo.FindFloor(ledgePos)
		if ledgeY - nextPos.Y < 5 then
			return false
		end
		if ledgeFloor then
			ledgePos = ledgeFloor.Position
			maryo.Position = ledgePos
			maryo.Floor = ledgeFloor
			maryo.FloorHeight = ledgeY
			maryo.FloorAngle = maryo.NormalizeAngle(math.atan2(ledgeFloor.Normal.Z, ledgeFloor.Normal.X))
			maryo.FaceAngle *= Vector3.new(0, 1, 1)
			maryo.SetFaceYaw(math.atan2(wall.Normal.Z, wall.Normal.X) + math.pi)
			return true
		end
		return false
	end
	function maryo.PerformAirQuarterStep(intendedPos, checkLedge)
		local nextPos = intendedPos
		local upperPos, upperWall = maryo.FindWallCollisions(nextPos, 7.5, 2.5)
		nextPos = upperPos
		local lowerPos, lowerWall = maryo.FindWallCollisions(nextPos, 1.5, 2.5)
		nextPos = lowerPos
		local floorHeight, f = maryo.FindFloor(nextPos)
		local ceilHeight = maryo.FindCeiling(nextPos, floorHeight)
		maryo.Wall = nil
		if not f then
			if nextPos.Y <= maryo.FloorHeight then
				maryo.SetHeight(maryo.FloorHeight)
				return "LANDED"
			end
			maryo.SetHeight(nextPos.Y)
			return "HIT_WALL"
		end
		if nextPos.Y <= floorHeight then
			if ceilHeight - floorHeight > 8 then
				maryo.Floor = f
				maryo.FloorHeight = floorHeight
				maryo.Position = Vector3.new(nextPos.X, maryo.Position.Y, nextPos.Z)
			end
			maryo.SetHeight(floorHeight)
			return "LANDED"
		end
		if nextPos.Y + 8 > ceilHeight then
			if maryo.Velocity.Y > 0 then
				maryo.SetUpwardVel(0)
				return "NONE"
			end
			if nextPos.Y <= maryo.FloorHeight then
				maryo.SetHeight(floorHeight)
				return "LANDED"
			end
			maryo.SetHeight(nextPos.Y)
			return "HIT_WALL"
		end
		if checkLedge and upperWall == nil and lowerWall ~= nil then
			if maryo.CheckLedgeGrab(lowerWall, intendedPos, nextPos) then
				return "GRABBED_LEDGE"
			end
			maryo.Floor = f
			maryo.Position = nextPos
			maryo.FloorHeight = floorHeight
			return "NONE"
		end
		maryo.Floor = f
		maryo.Position = nextPos
		maryo.FloorHeight = floorHeight
		if upperWall or lowerWall then
			local wall = upperWall or lowerWall
			local wallDYaw = math.abs(maryo.NormalizeAngle(math.atan2(wall.Normal.Z, wall.Normal.X) - maryo.FaceAngle.Y))
			maryo.Wall = wall
			if wallDYaw > math.pi * 0.375 then
				return "HIT_WALL"
			end
		end
		return "NONE"
	end
	function maryo.ApplyTwirlGravity()
		local heaviness = 1
		if maryo.AngleVel.Y > 1024 then
			heaviness = 1024 / maryo.AngleVel.Y
		end
		local terminalVelocity = -75 * heaviness
		maryo.Velocity -= Vector3.new(0, 4 * heaviness, 0)
		if maryo.Velocity.Y < terminalVelocity then
			maryo.SetUpwardVel(terminalVelocity)
		end
	end
	function maryo.ShouldStrengthenGravityForJumpAscent()
		if not maryo.Flags.MOVING_UP_IN_AIR then
			return false
		end
		if maryo.Action.INTANGIBLE or maryo.Action.INVULNERABLE then
			return false
		end
		if not maryo.Input.A_DOWN and maryo.Velocity.Y > 20 then
			return maryo.Action.CONTROL_JUMP_HEIGHT
		end
		return false
	end
	function maryo.ApplyGravity()
		local action = maryo.Action
		if action.NAME == "TWIRLING" and maryo.Velocity.Y < 0 then
			maryo.ApplyTwirlGravity()
		elseif action.NAME == "SHOT_FROM_CANNON" then
			maryo.Velocity -= Vector3.yAxis
			if maryo.Velocity.Y < -75 then
				maryo.SetUpwardVel(-75)
			end
		elseif action.NAME == "LONG_JUMP" or action.NAME == "SLIDE_KICK" or action.NAME == "BBH_ENTER_SPIN" then
			maryo.Velocity -= Vector3.yAxis * 2
			if maryo.Velocity.Y < -75 then
				maryo.SetUpwardVel(-75)
			end
		elseif action.NAME == "LAVA_BOOST" or action.NAME == "FALL_AFTER_STAR_GRAB" then
			maryo.Velocity -= Vector3.yAxis * 3.2
			if maryo.Velocity.Y < -65 then
				maryo.SetUpwardVel(-65)
			end
		elseif maryo.ShouldStrengthenGravityForJumpAscent() then
			maryo.Velocity *= Vector3.new(1, 0.25, 1)
		elseif maryo.Action.METAL_WATER then
			maryo.Velocity -= Vector3.yAxis * 1.6
			if maryo.Velocity.Y < -16 then
				maryo.SetUpwardVel(-16)
			end
		elseif maryo.Flags.WING_CAP and maryo.Velocity.Y < 0 and maryo.Input.A_DOWN then
			maryo.Velocity -= Vector3.yAxis * 2
			if maryo.Velocity.Y < -37.5 then
				maryo.Velocity += Vector3.yAxis * 4
				if maryo.Velocity.Y > -37.5 then
					maryo.SetUpwardVel(-37.5)
				end
			end
		else
			maryo.Velocity -= Vector3.yAxis * 4
			if maryo.Velocity.Y < -75 then
				maryo.SetUpwardVel(-75)
			end
		end
	end
	function maryo.PerformAirStep(checkLedge)
		local stepResult = "NONE"
		maryo.Wall = nil
		for i = 1, 4 do
			local intendedPos = maryo.Position + (maryo.Velocity / 80)
			local result = maryo.PerformAirQuarterStep(intendedPos, checkLedge)
			if result ~= "NONE" then
				stepResult = result
			end
			if result == "LANDED" or result == "GRABBED_LEDGE" or result == "GRABBED_CEILING" or result == "HIT_LAVA_WALL" then
				break
			end
		end
		if maryo.Velocity.Y >= 0 then
			maryo.PeakHeight = maryo.Position.Y
		end
		maryo.TerrainType = maryo.GetTerrainType()
		if maryo.Action.NAME ~= "FLYING" then
			maryo.ApplyGravity()
		end
		return stepResult
	end
	function maryo.UpdateInputs()
		local controller = maryo.Controller
		maryo.Input = {}
		if controller.A then
			if not maryo._ButtonStates.A then
				maryo.Input.A_PRESSED = true
			end
			maryo.Input.A_DOWN = true
		end
		maryo._ButtonStates.A = controller.A
		if maryo.SquishTimer == 0 then
			if controller.B then
				if not maryo._ButtonStates.B then
					maryo.Input.B_PRESSED = true
				end
				maryo.Input.B_DOWN = true
			end
			maryo._ButtonStates.B = controller.B
			if controller.Z then
				if not maryo._ButtonStates.Z then
					maryo.Input.Z_PRESSED = true
				end
				maryo.Input.Z_DOWN = true
			end
			maryo._ButtonStates.Z = controller.Z
		end
		if maryo.AutoJump and maryo.Input.A_DOWN then
			maryo.Input.A_PRESSED = true
		end
		if maryo.Input.A_PRESSED then
			maryo.FramesSinceA = 0
		elseif maryo.FramesSinceA < 255 then
			maryo.FramesSinceA += 1
		end
		if maryo.Input.B_PRESSED then
			maryo.FramesSinceB = 0
		elseif maryo.FramesSinceB < 255 then
			maryo.FramesSinceB += 1
		end
		local dir = Vector3.new(controller.StickX, 0, controller.StickZ)
		local mag = math.pow(dir.Magnitude, 2)
		if maryo.SquishTimer == 0 then
			maryo.IntendedMag = mag / 2
		else
			maryo.IntendedMag = mag / 8
		end
		if maryo.IntendedMag > 0 then
			maryo.IntendedYaw = maryo.NormalizeAngle(math.atan2(dir.Z, dir.X))
			maryo.Input.NONZERO_ANALOG = true
		else
			maryo.IntendedYaw = maryo.FaceAngle.Y
		end
		local floorHeight, f = maryo.FindFloor(maryo.Position)
		local ceilHeight, c = maryo.FindCeiling(maryo.Position, maryo.FloorHeight)
		maryo.FloorHeight = floorHeight
		maryo.CeilHeight = ceilHeight
		maryo.Floor = f
		maryo.Ceil = c
		if f then
			maryo.FloorAngle = math.atan2(f.Normal.Z, f.Normal.X)
			maryo.TerrainType = maryo.GetTerrainType()
			if maryo.FloorIsSlippery() then
				maryo.Input.ABOVE_SLIDE = true
			end
			if c then
				local squishCheck = maryo.CeilHeight - maryo.FloorHeight
				if squishCheck > 0 and squishCheck < 7.5 then
					maryo.Input.SQUISHED = true
				end
			end
			if maryo.Position.Y > maryo.FloorHeight + 5 then
				maryo.Input.OFF_FLOOR = true
			end
			if maryo.Position.Y < maryo.WaterLevel - 0.5 then
				maryo.Input.IN_WATER = true
			end
		end
		if not maryo.Input.NONZERO_ANALOG and not maryo.Input.A_PRESSED then
			maryo.Input.NO_MOVEMENT = true
		end
		if maryo.WallKickTimer > 0 then
			maryo.WallKickTimer -= 1
		end
		if maryo.DoubleJumpTimer > 0 then
			maryo.DoubleJumpTimer -= 1
		end
		if maryo.Input.NONZERO_ANALOG or maryo.Input.A_PRESSED or maryo.Input.OFF_FLOOR or maryo.Input.ABOVE_SLIDE or maryo.Input.FIRST_PERSON or maryo.Input.STOMPED or maryo.Input.B_PRESSED or maryo.Input.Z_PRESSED then
			maryo.Input.DISTURBED = true
		end
		if maryo.Events.STOMPED then
			maryo.Events.STOMPED = false
			maryo.Input.STOMPED = true
		end
	end
	function maryo.CheckKickOrPunchWall()
		if maryo.Flags.PUNCHING or maryo.Flags.KICKING or maryo.Flags.TRIPPING then
			local range = Vector3.new(math.sin(maryo.FaceAngle.Y), 0, math.cos(maryo.FaceAngle.Y))
			local detector = maryo.Position + range * 2.5
			local _disp, wall = maryo.FindWallCollisions(detector, 80, 5)
			if wall then
				local action = maryo.Action
				if action.NAME ~= "MOVE_PUNCHING" or maryo.ForwardVel >= 0 then
					if action == "PUNCHING" then
						maryo.Action = maryo.Enums.Action.MOVE_PUNCHING
					end
					maryo.SetForwardVel(-48)
					maryo.PlaySound("ACTION_HIT")
				elseif action.AIR then
					maryo.SetForwardVel(-16)
					maryo.PlaySound("ACTION_HIT")
				end
			end
		end
	end
	function maryo.SetWaterPlungeAction()
		maryo.ForwardVel /= 4
		maryo.Velocity *= Vector3.new(1, 0.5, 1)
		maryo.Position = Vector3.new(maryo.Position.X, maryo.WaterLevel - 5, maryo.Position.Z)
		maryo.FaceAngle *= Vector3int16.new(1, 1, 0)
		maryo.AngleVel *= 0
		if not maryo.Action.DIVING then
			maryo.FaceAngle *= Vector3int16.new(0, 1, 1)
		end
		maryo.SetAction("WATER_PLUNGE")
	end
	function maryo.PlayFarFallSound()
		if maryo.Flags.FALLING_FAR then
			return
		end
		local action = maryo.Action
		if action.NAME == "TWIRLING" then
			return
		end
		if action.NAME == "FLYING" then
			return
		end
		if action.INVULNERABLE then
			return
		end
		if maryo.PeakHeight - maryo.Position.Y > 57.5 then
			maryo.PlaySound("MARIO_WAAAOOOW")
			maryo.Flags.FALLING_FAR = true
		end
	end
	function maryo.Step()
		if not maryo.Action then
			return
		end
		maryo.Sounds = {}
		maryo.AnimFrame = (maryo.AnimFrame + 1) % (maryo.AnimFrameCount + 1)
		if maryo.AnimAccel > 0 then
			maryo.AnimAccelAssist += maryo.AnimAccel
			maryo.AnimAccelAssist %= (maryo.AnimFrameCount + 1) * 65536
		end
		if maryo.SquishTimer > 0 then
			maryo.SquishTimer -= 1
		end
		maryo.AnimDirty = true
		maryo.AnimSkipInterp = math.max(0, maryo.AnimSkipInterp - 1)
		maryo.UpdateInputs()
		if maryo.Floor and not (maryo.Action.AIR or maryo.Action.SWIMMING) then
			if maryo.Floor.Material == Enum.Material.CrackedLava then
				if not maryo.Flags.METAL_CAP then
					maryo.HurtCounter += maryo.Flags.CAP_ON_HEAD and 12 or 18
				end
				maryo.SetAction("LAVA_BOOST")
			end
		end
		if maryo.InvincTimer > 0 then
			maryo.InvincTimer -= 1
		end
		maryo.CheckKickOrPunchWall()
		maryo.Flags.PUNCHING = false
		maryo.Flags.KICKING = false
		maryo.Flags.TRIPPING = false
		if not maryo.Floor then
			return
		end
		while maryo.Action do
			local id = maryo.Action
			local action = maryo.Actions[id.NAME]
			if action then
				local group = id.GROUP
				local cancel = false
				if group ~= "SUBMERGED" and maryo.Position.Y < maryo.WaterLevel - 5 then
					maryo.SetWaterPlungeAction()
					cancel = true
				else
					if group == "AIRBORNE" then
						maryo.PlayFarFallSound()
					elseif group == "SUBMERGED" then
						if maryo.Position.Y > maryo.WaterLevel - 4 then
							if maryo.WaterLevel - 4 > maryo.FloorHeight then
								maryo.SetHeight(maryo.WaterLevel - 4)
							else
								maryo.AngleVel = 0
								maryo.SetAction("WALKING")
								cancel = true
							end
						end
						maryo.QuicksandDepth = 0
					end
					if not cancel then
						cancel = action()
					end
				end
				if not cancel then
					break
				end
			else
				warn("uh oh stinky")
				maryo.Action = maryo.Enums.Action.IDLE
				break
			end
		end
	end
	local DEF_ACTION = function(name, func)
		maryo.Actions[name] = func
	end
	do -- STATIONARY
		local function checkStompEvent()
			if maryo.Input.STOMPED then
				return maryo.SetAction("SHOCKWAVE_BOUNCE")
			end
			return false
		end
		local function checkCommonIdleCancels()
			local f = maryo.Floor
			if f and f.Normal.Y < 0.29237169 then
				return maryo.PushOffSteepFloor("FREEFALL", 0)
			end
			if maryo.Input.STOMPED then
				return maryo.SetAction(SHOCKWAVE_BOUNCE)
			end
			if maryo.Input.A_PRESSED then
				return maryo.SetJumpingAction("JUMP", 0)
			end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BEGIN_SLIDING")
			end
			if maryo.Input.NONZERO_ANALOG) then
				maryo.SetFaceYaw(maryo.IntendedYaw)
				return maryo.SetAction("WALKING")
			end
			if maryo.Input.B_PRESSED then
				return maryo.SetAction("PUNCHING")
			end
			if maryo.Input.Z_DOWN then
				return maryo.SetAction("START_CROUCHING")
			end
			return false
		end
		local function playAnimSound(actionState, animFrame, sound)
			if maryo.ActionState == actionState and maryo.AnimFrame == animFrame then
				maryo.PlaySound(sound)
			end
		end
		local function stoppingStep(anim, action)
			maryo.StationaryGroundStep()
			maryo.SetAnimation(anim)
			if maryo.IsAnimPastEnd() then
				maryo.SetAction(action)
			end
		end
		local function checkCommonLandingCancels(action)
			if maryo.Input.A_PRESSED then
				if not action then
					maryo.SetJumpFromLanding()
				else
					maryo.SetJumpingAction(action, 0)
				end
			end
			if maryo.Input.NONZERO_ANALOG or maryo.Input.A_PRESSED or maryo.Input.OFF_FLOOR or maryo.Input.ABOVE_SLIDE) then
				return maryo.CheckCommonActionExits()
			end
			if maryo.Input.B_PRESSED then
				return maryo.SetAction("PUNCHING")
			end
			return false
		end
		DEF_ACTION("IDLE", function()
			if checkStompEvent() then return true end
			if not bit32.btest(maryo.ActionArg, 1) and maryo.Health < 3 then
				return maryo.SetAction("PANTING")
			end
			if checkCommonIdleCancels() then return true end
			if maryo.ActionState == 3 then
				return maryo.SetAction("START_SLEEPING")
			end
			if bit32.btest(maryo.ActionArg, 1) then
				maryo.SetAnimation("STAND_AGAINST_WALL")
			else
				if maryo.ActionState == 0 then
					maryo.SetAnimation("IDLE_HEAD_LEFT")
				elseif maryo.ActionState == 1 then
					maryo.SetAnimation("IDLE_HEAD_RIGHT")
				elseif maryo.ActionState == 2 then
					maryo.SetAnimation("IDLE_HEAD_CENTER")
				end
				if maryo.IsAnimAtEnd() then
					maryo.ActionState += 1
					if maryo.ActionState == 3 then
						local deltaYOfFloorBehindMario = maryo.Position.Y - maryo.FindFloorHeightRelativePolar(math.pi, 3)
						if math.abs(deltaYOfFloorBehindMario) > 1.2 then
							maryo.ActionState = 0
						else
							maryo.ActionTimer += 1
							if maryo.ActionTimer < 10 then
								maryo.ActionState = 0
							end
						end
					end
				end
			end
			maryo.StationaryGroundStep()
			return false
		end)
		DEF_ACTION("START_SLEEPING", function()
			local animFrame = -1
			if checkCommonIdleCancels() then return true end
			if maryo.ActionState == 4 then
				maryo.SetAction("SLEEPING")
			end
			if maryo.ActionState == 0 then
				animFrame = maryo.SetAnimation("START_SLEEP_IDLE")
			elseif maryo.ActionState == 1 then
				animFrame = maryo.SetAnimation("START_SLEEP_SCRATCH")
			elseif maryo.ActionState == 2 then
				animFrame = maryo.SetAnimation("START_SLEEP_YAWN")
			elseif maryo.ActionState == 3 then
				animFrame = maryo.SetAnimation("START_SLEEP_SITTING")
			end
			playAnimSound(1, 41, "ACTION_PAT_BACK")
			playAnimSound(1, 49, "ACTION_PAT_BACK")
			if maryo.IsAnimAtEnd() then
				maryo.ActionState += 1
			end
			if maryo.ActionState == 2 and animFrame == 0 then
				maryo.PlaySound("MARIO_YAWNING")
			end
			if maryo.ActionState == 1 and animFrame == 0 then
				maryo.PlaySound("MARIO_IMA_TIRED")
			end
			maryo.StationaryGroundStep()
			return false
		end)
		DEF_ACTION("SLEEPING", function()
			if maryo.Input.DISTURBED then
				return maryo.SetAction("WAKING_UP", maryo.ActionState)
			end
			if maryo.Position.Y - maryo.FindFloorHeightRelativePolar(math.pi, 3) > 1.2 then
				return maryo.SetAction("WAKING_UP", maryo.ActionState)
			end
			maryo.StationaryGroundStep()
			if maryo.ActionState == 0 then
				local animFrame = maryo.SetAnimation("SLEEP_IDLE")
				if animFrame == 2 then
					maryo.PlaySound("MARIO_SNORING1")
				end
				if animFrame == 20 then
					maryo.PlaySound("MARIO_SNORING2")
				end
				if maryo.IsAnimAtEnd() then
					maryo.ActionTimer += 1
					if maryo.ActionTimer > 45 then
						maryo.ActionState += 1
					end
				end
			elseif maryo.ActionState == 1 then
				if maryo.SetAnimation("SLEEP_START_LYING") == 18 then
					maryo.PlayHeavyLandingSound("ACTION_TERRAIN_BODY_HIT_GROUND")
				end
				if maryo.IsAnimAtEnd() then
					maryo.ActionState += 1
				end
			elseif maryo.ActionState == 2 then
				maryo.SetAnimation("SLEEP_LYING")
				maryo.PlaySoundIfNoFlag("MARIO_SNORING3", "ACTION_SOUND_PLAYED")
			end
			return false
		end)
		DEF_ACTION("WAKING_UP", function()
			if checkStompEvent() then return true end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BEGIN_SLIDING")
			end
			maryo.ActionTimer += 1
			if maryo.ActionTimer > 20 then
				return maryo.SetAction("IDLE")
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation(if maryo.ActionArg == 0 then "WAKE_FROM_SLEEP" else "WAKE_FROM_LYING")
			return false
		end)
		DEF_ACTION("STANDING_AGAINST_WALL", function()
			if checkStompEvent() then return true end
			if maryo.Input.NONZERO_ANALOG or maryo.Input.A_PRESSED or maryo.Input.OFF_FLOOR or maryo.Input.ABOVE_SLIDE then
				return maryo.CheckCommonActionExits()
			end
			if maryo.Input.B_PRESSED then
				return maryo.SetAction("PUNCHING")
			end
			maryo.SetAnimation("STAND_AGAINST_WALL")
			maryo.StationaryGroundStep()
			return false
		end)
		DEF_ACTION("CROUCHING", function()
			if checkStompEvent() then return true end
			if maryo.Input.A_PRESSED then
				return maryo.SetAction("BACKFLIP")
			end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BEGIN_SLIDING")
			end
			if not maryo.Input.Z_DOWN then
				return maryo.SetAction("STOP_CROUCHING")
			end
			if maryo.Input.NONZERO_ANALOG then
				return maryo.SetAction("START_CRAWLING")
			end
			if maryo.Input.B_PRESSED then
				return maryo.SetAction("PUNCHING", 9)
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation("CROUCHING")
			return false
		end)
		DEF_ACTION("PANTING", function()
			if checkStompEvent() then return true end
			if maryo.Health >= 5 then
				return maryo.SetAction(Action.IDLE)
			end
			if checkCommonIdleCancels() then return true end
			if maryo.SetAnimation("PANTING") == 1 then
				maryo.PlaySound("MARIO_PANTING")
			end
			maryo.StationaryGroundStep()
			return false
		end)
		DEF_ACTION("BRAKING_STOP", function()
			if checkStompEvent() then return true end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if maryo.Input.B_PRESSED then
				return maryo.SetAction("PUNCHING")
			end
			if maryo.Input.NONZERO_ANALOG or maryo.Input.A_PRESSED or maryo.Input.OFF_FLOOR or maryo.Input.ABOVE_SLIDE then
				return maryo.CheckCommonActionExits()
			end
			stoppingStep("STOP_SKID", "IDLE")
			return false
		end)
		DEF_ACTION("BUTT_SLIDE_STOP", function()
			if checkStompEvent() then return true end
			if maryo.Input.NONZERO_ANALOG or maryo.Input.A_PRESSED or maryo.Input.OFF_FLOOR or maryo.Input.ABOVE_SLIDE then
				return maryo.CheckCommonActionExits()
			end
			stoppingStep("STOP_SLIDE", "IDLE")
			if maryo.AnimFrame == 6 then
				maryo.PlayLandingSound()
			end
			return false
		end)
		DEF_ACTION("SLIDE_KICK_SLIDE_STOP", function()
			if checkStompEvent() then return true end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			stoppingStep("CROUCH_FROM_SLIDE_KICK", "CROUCHING")
			return false
		end)
		DEF_ACTION("START_CROUCHING", function()
			if maryo.CheckCommonActionExits() then
				return true
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation("START_CROUCHING")
			if maryo.IsAnimPastEnd() then
				maryo.SetAction("CROUCHING")
			end
			return false
		end)
		DEF_ACTION("STOP_CROUCHING", function()
			if maryo.CheckCommonActionExits() then
				return true
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation("START_CROUCHING")
			if maryo.IsAnimPastEnd() then
				maryo.SetAction("IDLE")
			end
			return false
		end)
		DEF_ACTION("START_CRAWLING", function()
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if checkStompEvent() then return true end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BEGIN_SLIDING")
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation("START_CRAWLING")
			if maryo.IsAnimPastEnd() then
				maryo.SetAction("CRAWLING")
			end
			return false
		end)
		DEF_ACTION("STOP_CRAWLING", function()
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if checkStompEvent() then return true end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BEGIN_SLIDING")
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation("STOP_CRAWLING")
			if maryo.IsAnimPastEnd() then
				maryo.SetAction("CROUCHING")
			end
			return false
		end)
		DEF_ACTION("SHOCKWAVE_BOUNCE", function()
			maryo.ActionTimer += 1
			if maryo.ActionTimer == 48 then
				maryo.SetAction("IDLE")
			end
			local sp1E = bit32.lshift(maryo.ActionTimer % 16, 12) / 0x10000
			local sp18 = (((6 - maryo.ActionTimer / 8) * 8) + 4) / 20
			maryo.SetForwardVel(0)
			maryo.Velocity = Vector3.zero
			maryo.SetHeight(maryo.FloorHeight + math.abs(math.sin(sp1E * 2 * math.pi) * sp18))
			maryo.SetAnimation("A_POSE")
			return false
		end)
		DEF_ACTION("JUMP_LAND_STOP", function()
			if checkCommonLandingCancels() then return true end
			stoppingStep("LAND_FROM_SINGLE_JUMP", "IDLE")
			return false
		end)
		DEF_ACTION("DOUBLE_JUMP_LAND_STOP", function()
			if checkCommonLandingCancels() then return true end
			stoppingStep("LAND_FROM_DOUBLE_JUMP", "IDLE")
			return false
		end)
		DEF_ACTION("SIDE_FLIP_LAND_STOP", function()
			if checkCommonLandingCancels() then return true end
			stoppingStep("SLIDEFLIP_LAND", "IDLE")
			return false
		end)
		DEF_ACTION("FREEFALL_LAND_STOP", function()
			if checkCommonLandingCancels() then return true end
			stoppingStep("GENERAL_LAND", "IDLE")
			return false
		end)
		DEF_ACTION("TRIPLE_JUMP_LAND_STOP", function()
			if checkCommonLandingCancels() then return true end
			stoppingStep(Animations.TRIPLE_JUMP_LAND, Action.IDLE)
			return false
		end)
		DEF_ACTION("BACKFLIP_LAND_STOP", function()
			if not maryo.Input.Z_DOWN and maryo.AnimFrame >= 6 then
				maryo.Input.A_PRESSED = false
			end
			if checkCommonLandingCancels("BACKFLIP") then return true end
			stoppingStep("TRIPLE_JUMP_LAND", "IDLE")
			return false
		end)
		DEF_ACTION("LAVA_BOOST_LAND", function()
			maryo.Input.FIRST_PERSON = false
			maryo.Input.B_PRESSED = false
			if checkCommonLandingCancels() then return true end
			stoppingStep("STAND_UP_FROM_LAVA_BOOST", "IDLE")
			return false
		end)
		DEF_ACTION("LONG_JUMP_LAND_STOP", function()
			maryo.Input.B_PRESSED = false
			if checkCommonLandingCancels("JUMP") then return true end
			stoppingStep(
				if maryo.LongJumpIsSlow then "CROUCH_FROM_FAST_LONGJUMP" else "CROUCH_FROM_SLOW_LONGJUMP",
				"CROUCHING"
			)
			return false
		end)
		DEF_ACTION("TWIRL_LAND", function()
			maryo.ActionState = 1
			if checkStompEvent() then return true end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			maryo.StationaryGroundStep()
			maryo.SetAnimation("TWIRL_LAND")
			if maryo.AngleVel.Y > 0 then
				maryo.AngleVel -= Vector3int16.new(0, math.pi / 32, 0)
				if maryo.AngleVel.Y < 0 then
					maryo.AngleVel *= Vector3int16.new(1, 0, 1)
				end
				maryo.TwirlYaw += maryo.AngleVel.Y
			end
			if maryo.IsAnimAtEnd() and maryo.AngleVel.Y == 0 then
				maryo.FaceAngle += Vector3int16.new(0, maryo.TwirlYaw, 0)
				maryo.SetAction("IDLE")
			end
			return false
		end)
		DEF_ACTION("GROUND_POUND_LAND", function()
			if checkStompEvent() then return true end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BUTT_SLIDE")
			end
			stoppingStep("GROUND_POUND_LANDING", "BUTT_SLIDE_STOP")
			return false
		end)
		DEF_ACTION("STOMACH_SLIDE_STOP", function()
			if checkStompEvent() then return true end
			if maryo.Input.OFF_FLOOR then
				return maryo.SetAction("FREEFALL")
			end
			if maryo.Input.ABOVE_SLIDE then
				return maryo.SetAction("BEGIN_SLIDING")
			end
			stoppingStep("SLOW_LAND_FROM_DIVE", "IDLE")
			return false
		end)
	end
	do -- MOVING
		local sPunchingForwardVelocities = { 0, 1, 1, 2, 3, 5, 7, 10 }
		local function tiltBodyRunning()
			local pitch = maryo.FindFloorSlope(0)
			pitch = pitch * m.ForwardVel / 40
			return -pitch
		end
		local function playStepSound(frame1, frame2)
			if maryo.IsAnimPastFrame(frame1) or maryo.IsAnimPastFrame(frame2) then
				if m.Flags.METAL_CAP then
					maryo.PlaySound(Sounds.ACTION_METAL_STEP)
				else
					maryo.PlaySound(Sounds.ACTION_TERRAIN_STEP)
				end
			end
		end
		local function alignWithFloor()
			local pos = Util.SetY(maryo.Position, maryo.FloorHeight)
			m.Position = pos
			local radius = 40
			local minY = -radius * 3
			local yaw = m.FaceAngle.Y
			local p0_x = pos.X + radius * Util.Sins(yaw + 0x2AAA)
			local p0_z = pos.Z + radius * Util.Coss(yaw + 0x2AAA)
		
			local p1_x = pos.X + radius * Util.Sins(yaw + 0x8000)
			local p1_z = pos.Z + radius * Util.Coss(yaw + 0x8000)
		
			local p2_x = pos.X + radius * Util.Sins(yaw + 0xD555)
			local p2_z = pos.Z + radius * Util.Coss(yaw + 0xD555)
		
			local test0 = Vector3.new(p0_x, pos.Y + 150, p0_z)
			local test1 = Vector3.new(p1_x, pos.Y + 150, p1_z)
			local test2 = Vector3.new(p2_x, pos.Y + 150, p2_z)
		
			local p0_y = Util.FindFloor(test0)
			local p1_y = Util.FindFloor(test1)
			local p2_y = Util.FindFloor(test2)
		
			p0_y = p0_y - pos.Y < minY and pos.Y or p0_y
			p1_y = p1_y - pos.Y < minY and pos.Y or p1_y
			p2_y = p2_y - pos.Y < minY and pos.Y or p2_y
		
			local avgY = (p0_y + p1_y + p2_y) / 3
			local forward = Vector3.new(Util.Sins(yaw), 0, Util.Coss(yaw))
		
			if avgY >= pos.Y then
				pos = Util.SetY(pos, avgY)
			end
		
			local a = Vector3.new(p0_x, p0_y, p0_z)
			local b = Vector3.new(p1_x, p1_y, p1_z)
			local c = Vector3.new(p2_x, p2_y, p2_z)
		
			local yColumn = (b - a):Cross(c - a).Unit
			local xColumn = yColumn:Cross(forward).Unit
			m.ThrowMatrix = CFrame.fromMatrix(pos, xColumn, yColumn)
		end
		
		local function beginWalkingAction(m: Mario, forwardVel: number, action: number, actionArg: number?)
			m:SetForwardVel(forwardVel)
			m.FaceAngle = Util.SetY(m.FaceAngle, m.IntendedYaw)
			return m:SetAction(action, actionArg)
		end
		
		local function checkLedgeClimbDown(m: Mario)
			if m.ForwardVel < 10 then
				local pos, wall = Util.FindWallCollisions(m.Position, -10, 10)
		
				if wall then
					local floorHeight, floor = Util.FindFloor(pos)
		
					if floor and pos.Y - floorHeight > 160 then
						local wallAngle = Util.Atan2s(wall.Normal.Z, wall.Normal.X)
						local wallDYaw = wallAngle - m.FaceAngle.Y
		
						if math.abs(wallDYaw) < 0x4000 then
							pos -= Vector3.new(20 * wall.Normal.X, 0, 20 * wall.Normal.Z)
							m.Position = pos
		
							m.FaceAngle *= Vector3int16.new(0, 1, 1)
							m.FaceAngle = Util.SetY(m.FaceAngle, wallAngle + 0x8000)
		
							m:SetAction(Action.LEDGE_CLIMB_DOWN)
							m:SetAnimation(Animations.CLIMB_DOWN_LEDGE)
						end
					end
				end
			end
		end
		
		local function slideBonk(m: Mario, fastAction: number, slowAction: number)
			if m.ForwardVel > 16 then
				m:BonkReflection(true)
				m:SetAction(fastAction)
			else
				m:SetForwardVel(0)
				m:SetAction(slowAction)
			end
		end
		
		local function setTripleJumpAction(m: Mario)
			if m.Flags:Has(MarioFlags.WING_CAP) then
				return m:SetAction(Action.FLYING_TRIPLE_JUMP)
			elseif m.ForwardVel > 20 then
				return m:SetAction(Action.TRIPLE_JUMP)
			else
				return m:SetAction(Action.JUMP)
			end
		end
		
		local function updateSlidingAngle(m: Mario, accel: number, lossFactor: number)
			local newFacingDYaw
			local facingDYaw
		
			local floor = m.Floor
		
			if not floor then
				return
			end
		
			assert(floor)
		
			local slopeAngle = Util.Atan2s(floor.Normal.Z, floor.Normal.X)
			local steepness = math.sqrt(floor.Normal.X ^ 2 + floor.Normal.Z ^ 2)
		
			m.SlideVelX += accel * steepness * Util.Sins(slopeAngle)
			m.SlideVelZ += accel * steepness * Util.Coss(slopeAngle)
		
			m.SlideVelX *= lossFactor
			m.SlideVelZ *= lossFactor
		
			m.SlideYaw = Util.Atan2s(m.SlideVelZ, m.SlideVelX)
		
			facingDYaw = Util.SignedShort(m.FaceAngle.Y - m.SlideYaw)
			newFacingDYaw = facingDYaw
		
			if newFacingDYaw > 0 and newFacingDYaw <= 0x4000 then
				newFacingDYaw -= 0x200
		
				if newFacingDYaw < 0 then
					newFacingDYaw = 0
				end
			elseif newFacingDYaw > -0x4000 and newFacingDYaw < 0 then
				newFacingDYaw += 0x200
		
				if newFacingDYaw > 0 then
					newFacingDYaw = 0
				end
			elseif newFacingDYaw > 0x4000 and newFacingDYaw < 0x8000 then
				newFacingDYaw += 0x200
		
				if newFacingDYaw > 0x8000 then
					newFacingDYaw = 0x8000
				end
			elseif newFacingDYaw > -0x8000 and newFacingDYaw < -0x4000 then
				newFacingDYaw -= 0x200
		
				if newFacingDYaw < -0x8000 then
					newFacingDYaw = -0x8000
				end
			end
		
			m.FaceAngle = Util.SetY(m.FaceAngle, m.SlideYaw + newFacingDYaw)
			m.Velocity = Vector3.new(m.SlideVelX, 0, m.SlideVelZ)
		
			--! Speed is capped a frame late (butt slide HSG)
			m.ForwardVel = math.sqrt(m.SlideVelX ^ 2 + m.SlideVelZ ^ 2)
		
			if m.ForwardVel > 100 then
				m.SlideVelX = m.SlideVelX * 100 / m.ForwardVel
				m.SlideVelZ = m.SlideVelZ * 100 / m.ForwardVel
			end
		
			if math.abs(newFacingDYaw) > 0x4000 then
				m.ForwardVel *= -1
			end
		end
		
		local function updateSliding(m: Mario, stopSpeed: number)
			local intendedDYaw = Util.SignedShort(m.IntendedYaw - m.SlideYaw)
			local forward = Util.Coss(intendedDYaw)
			local sideward = Util.Sins(intendedDYaw)
		
			--! 10k glitch
			if forward < 0 and m.ForwardVel > 0 then
				forward *= 0.5 + 0.5 * m.ForwardVel / 100
			end
		
			local floorClass = m:GetFloorClass()
			local lossFactor
			local accel
		
			if floorClass == SurfaceClass.VERY_SLIPPERY then
				accel = 10
				lossFactor = m.IntendedMag / 32 * forward * 0.02 + 0.98
			elseif floorClass == SurfaceClass.SLIPPERY then
				accel = 8
				lossFactor = m.IntendedMag / 32 * forward * 0.02 + 0.96
			elseif floorClass == SurfaceClass.DEFAULT then
				accel = 7
				lossFactor = m.IntendedMag / 32 * forward * 0.02 + 0.92
			elseif floorClass == SurfaceClass.NOT_SLIPPERY then
				accel = 5
				lossFactor = m.IntendedMag / 32 * forward * 0.02 + 0.92
			end
		
			local oldSpeed = math.sqrt(m.SlideVelX ^ 2 + m.SlideVelZ ^ 2)
		
			--! This is attempting to use trig derivatives to rotate Mario's speed.
			--  It is slightly off/asymmetric since it uses the new X speed, but the old
			--  Z speed.
		
			m.SlideVelX += m.SlideVelZ * (m.IntendedMag / 32) * sideward * 0.05
			m.SlideVelZ -= m.SlideVelX * (m.IntendedMag / 32) * sideward * 0.05
		
			local newSpeed = math.sqrt(m.SlideVelX ^ 2 + m.SlideVelZ ^ 2)
		
			if oldSpeed > 0 and newSpeed > 0 then
				m.SlideVelX *= oldSpeed / newSpeed
				m.SlideVelZ *= oldSpeed / newSpeed
			end
		
			local stopped = false
			updateSlidingAngle(m, accel, lossFactor)
		
			if not m:FloorIsSlope() and m.ForwardVel ^ 2 < stopSpeed ^ 2 then
				m:SetForwardVel(0)
				stopped = true
			end
		
			return stopped
		end
		
		local function applySlopeAccel(m: Mario)
			local floor = m.Floor
			local floorNormal: Vector3
		
			if floor then
				floorNormal = floor.Normal
			else
				floorNormal = Vector3.yAxis
			end
		
			local floorDYaw = m.FloorAngle - m.FaceAngle.Y
			local steepness = math.sqrt(floorNormal.X ^ 2 + floorNormal.Z ^ 2)
		
			if m:FloorIsSlope() then
				local slopeClass = 0
				local slopeAccel
		
				if m.Action() ~= Action.SOFT_BACKWARD_GROUND_KB then
					if m.Action() ~= Action.SOFT_FORWARD_GROUND_KB then
						slopeClass = m:GetFloorClass()
					end
				end
		
				if slopeClass == SurfaceClass.VERY_SLIPPERY then
					slopeAccel = 5.3
				elseif slopeClass == SurfaceClass.SLIPPERY then
					slopeAccel = 2.7
				elseif slopeClass == SurfaceClass.DEFAULT then
					slopeAccel = 1.7
				else
					slopeAccel = 0
				end
		
				if floorDYaw > -0x4000 and floorDYaw < 0x4000 then
					m.ForwardVel += slopeAccel * steepness
				else
					m.ForwardVel -= slopeAccel * steepness
				end
			end
		
			m.SlideYaw = m.FaceAngle.Y
			m.SlideVelX = m.ForwardVel * Util.Sins(m.FaceAngle.Y)
			m.SlideVelZ = m.ForwardVel * Util.Coss(m.FaceAngle.Y)
			m.Velocity = Vector3.new(m.SlideVelX, 0, m.SlideVelZ)
		end
		
		local function applyLandingAccel(m: Mario, frictionFactor: number)
			local stopped = false
			applySlopeAccel(m)
		
			if not m:FloorIsSlope() then
				m.ForwardVel *= frictionFactor
		
				if m.ForwardVel ^ 2 < 1 then
					m:SetForwardVel(0)
					stopped = true
				end
			end
		
			return stopped
		end
		
		local function applySlopeDecel(m: Mario, decelCoef: number)
			local decel
			local stopped = false
			local floorClass = m:GetFloorClass()
		
			if floorClass == SurfaceClass.VERY_SLIPPERY then
				decel = decelCoef * 0.2
			elseif floorClass == SurfaceClass.SLIPPERY then
				decel = decelCoef * 0.7
			elseif floorClass == SurfaceClass.DEFAULT then
				decel = decelCoef * 2
			elseif floorClass == SurfaceClass.NOT_SLIPPERY then
				decel = decelCoef * 3
			end
		
			m.ForwardVel = Util.ApproachFloat(m.ForwardVel, 0, decel)
		
			if m.ForwardVel == 0 then
				stopped = true
			end
		
			applySlopeAccel(m)
			return stopped
		end
		
		local function updateDeceleratingSpeed(m: Mario)
			local stopped = false
			m.ForwardVel = Util.ApproachFloat(m.ForwardVel, 0, 1)
		
			if m.ForwardVel == 0 then
				stopped = true
			end
		
			m:SetForwardVel(m.ForwardVel)
			return stopped
		end
		
		local function updateWalkingSpeed(m: Mario)
			local maxTargetSpeed = 32
			local floor = m.Floor
		
			local targetSpeed = if m.IntendedMag < maxTargetSpeed then m.IntendedMag else maxTargetSpeed
		
			if m.ForwardVel < 0 then
				m.ForwardVel += 1.1
			elseif m.ForwardVel <= targetSpeed then
				m.ForwardVel += 1.1 - m.ForwardVel / 43
			elseif floor and floor.Normal.Y >= 0.95 then
				m.ForwardVel -= 1
			end
		
			if m.ForwardVel > 48 then
				m.ForwardVel = 48
			end
		
			local currY = Util.SignedShort(m.IntendedYaw - m.FaceAngle.Y)
			local faceY = m.IntendedYaw - Util.ApproachInt(currY, 0, 0x800)
		
			m.FaceAngle = Util.SetY(m.FaceAngle, faceY)
			applySlopeAccel(m)
		end
		
		local function shouldBeginSliding(m: Mario)
			if m.Input:Has(InputFlags.ABOVE_SLIDE) then
				if m.ForwardVel < -1 or m:FacingDownhill() then
					return true
				end
			end
		
			return false
		end
		
		local function analogStickHeldBack(m: Mario)
			local intendedDYaw = Util.SignedShort(m.IntendedYaw - m.FaceAngle.Y)
			return math.abs(intendedDYaw) > 0x471C
		end
		
		local function checkGroundDiveOrPunch(m: Mario)
			if m.Input:Has(InputFlags.B_PRESSED) then
				--! Speed kick (shoutouts to SimpleFlips)
				if m.ForwardVel >= 29 and m.Controller.StickMag > 48 then
					m.Velocity = Util.SetY(m.Velocity, 20)
					return m:SetAction(Action.DIVE, 1)
				end
		
				return m:SetAction(Action.MOVE_PUNCHING)
			end
		
			return false
		end
		
		local function beginBrakingAction(m: Mario)
			if m.ActionState == 1 then
				m.FaceAngle = Util.SetY(m.FaceAngle, m.ActionArg)
				return m:SetAction(Action.STANDING_AGAINST_WALL)
			end
		
			if m.ForwardVel > 16 then
				local floor = m.Floor
		
				if floor and floor.Normal.Y >= 0.17364818 then
					return m:SetAction(Action.BRAKING)
				end
			end
		
			return m:SetAction(Action.DECELERATING)
		end
		
		local function animAndAudioForWalk(m: Mario)
			local baseAccel = if m.IntendedMag > m.ForwardVel then m.IntendedMag else m.ForwardVel
		
			if baseAccel < 4 then
				baseAccel = 4
			end
		
			local targetPitch = 0
			local accel
		
			while true do
				if m.ActionTimer == 0 then
					if baseAccel > 8 then
						m.ActionTimer = 2
					else
						accel = baseAccel / 4 * 0x10000
		
						if accel < 0x1000 then
							accel = 0x1000
						end
		
						m:SetAnimationWithAccel(Animations.START_TIPTOE, accel)
						playStepSound(m, 7, 22)
		
						if m:IsAnimPastFrame(23) then
							m.ActionTimer = 2
						end
		
						break
					end
				elseif m.ActionTimer == 1 then
					if baseAccel > 8 then
						m.ActionTimer = 2
					else
						accel = baseAccel * 0x10000
		
						if accel < 0x1000 then
							accel = 0x1000
						end
		
						m:SetAnimationWithAccel(Animations.TIPTOE, accel)
						playStepSound(m, 14, 72)
		
						break
					end
				elseif m.ActionTimer == 2 then
					if baseAccel < 5 then
						m.ActionTimer = 1
					elseif baseAccel > 22 then
						m.ActionTimer = 3
					else
						accel = baseAccel / 4 * 0x10000
						m:SetAnimationWithAccel(Animations.WALKING, accel)
						playStepSound(m, 10, 49)
						break
					end
				elseif m.ActionTimer == 3 then
					if baseAccel < 18 then
						m.ActionTimer = 2
					else
						accel = baseAccel / 4 * 0x10000
						m:SetAnimationWithAccel(Animations.RUNNING, accel)
		
						playStepSound(m, 9, 45)
						targetPitch = tiltBodyRunning(m)
		
						break
					end
				end
			end
		
			local walkingPitch = Util.ApproachInt(m.WalkingPitch, targetPitch, 0x800)
			walkingPitch = Util.SignedShort(walkingPitch)
		
			m.WalkingPitch = walkingPitch
			m.GfxAngle = Util.SetX(m.GfxAngle, walkingPitch)
		end
		
		local function pushOrSidleWall(m: Mario, startPos: Vector3)
			local wallAngle: number
			local dWallAngle: number
		
			local dx = m.Position.X - startPos.X
			local dz = m.Position.Z - startPos.Z
		
			local movedDist = math.sqrt(dx ^ 2 + dz ^ 2)
			local accel = movedDist * 2 * 0x10000
		
			if m.ForwardVel > 6 then
				m:SetForwardVel(6)
			end
		
			local wall = m.Wall
		
			if wall then
				wallAngle = Util.Atan2s(wall.Normal.Z, wall.Normal.X)
				dWallAngle = Util.SignedShort(assert(wallAngle) - m.FaceAngle.Y)
			end
		
			if wall == nil or math.abs(dWallAngle) >= 0x71C8 then
				m:SetAnimation(Animations.PUSHING)
				playStepSound(m, 6, 18)
			else
				if dWallAngle < 0 then
					m:SetAnimationWithAccel(Animations.SIDESTEP_RIGHT, accel)
				else
					m:SetAnimationWithAccel(Animations.SIDESTEP_LEFT, accel)
				end
		
				if m.AnimFrame < 20 then
					m:PlaySound(Sounds.MOVING_TERRAIN_SLIDE)
					m.ParticleFlags:Add(ParticleFlags.DUST)
				end
		
				m.ActionState = 1
				m.ActionArg = Util.SignedShort(wallAngle + 0x8000)
		
				m.GfxAngle = Util.SetY(m.GfxAngle, m.ActionArg)
				m.GfxAngle = Util.SetZ(m.GfxAngle, m:FindFloorSlope(0x4000))
			end
		end
		
		local function tiltBodyWalking(m: Mario, startYaw: number)
			local anim = m.AnimCurrent
			local bodyState = m.BodyState
		
			if anim == Animations.WALKING or anim == Animations.RUNNING then
				local dYaw = m.FaceAngle.Y - startYaw
		
				local tiltZ = -math.clamp(dYaw * m.ForwardVel / 12, -0x1555, 0x1555)
				local tiltX = math.clamp(m.ForwardVel * 170, 0, 0x1555)
		
				local torsoAngle = bodyState.TorsoAngle
				tiltZ = Util.ApproachInt(torsoAngle.Z, tiltZ, 0x400)
				tiltX = Util.ApproachInt(torsoAngle.X, tiltX, 0x400)
		
				bodyState.TorsoAngle = Vector3int16.new(tiltX, torsoAngle.Y, tiltZ)
			else
				bodyState.TorsoAngle *= Vector3int16.new(0, 1, 0)
			end
		end
		
		local function tiltBodyButtSlide(m: Mario)
			local intendedDYaw = m.IntendedYaw - m.FaceAngle.Y
			local bodyState = m.BodyState
		
			local tiltX = 5461.3335 * m.IntendedMag / 32 * Util.Coss(intendedDYaw)
			local tiltZ = -(5461.3335 * m.IntendedMag / 32 * Util.Sins(intendedDYaw))
		
			local torsoAngle = bodyState.TorsoAngle
			bodyState.TorsoAngle = Vector3int16.new(tiltX, torsoAngle.Y, tiltZ)
		end
		
		local function commonSlideAction(m: Mario, endAction: number, airAction: number, anim: Animation)
			local pos = m.Position
			m:PlaySound(Sounds.MOVING_TERRAIN_SLIDE)
			m:AdjustSoundForSpeed()
		
			local step = m:PerformGroundStep()
		
			if step == GroundStep.LEFT_GROUND then
				m:SetAction(airAction)
		
				if math.abs(m.ForwardVel) >= 50 then
					m:PlaySound(Sounds.MARIO_HOOHOO)
				end
			elseif step == GroundStep.NONE then
				m:SetAnimation(anim)
				alignWithFloor(m)
		
				m.ParticleFlags:Add(ParticleFlags.DUST)
			elseif step == GroundStep.HIT_WALL then
				local wall = m.Wall
		
				if not m:FloorIsSlippery() then
					if m.ForwardVel > 16 then
						m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
					end
		
					slideBonk(m, Action.GROUND_BONK, endAction)
				elseif wall then
					local wallAngle = Util.Atan2s(wall.Normal.Z, wall.Normal.X)
					local slideSpeed = math.sqrt(m.SlideVelX ^ 2 + m.SlideVelZ ^ 2) * 0.9
		
					if slideSpeed < 4 then
						slideSpeed = 4
					end
		
					local slideYaw = Util.SignedShort(m.SlideYaw - wallAngle)
					m.SlideYaw = Util.SignedShort(wallAngle - slideYaw + 0x8000)
					m.SlideVelX = slideSpeed * Util.Sins(m.SlideYaw)
					m.SlideVelZ = slideSpeed * Util.Coss(m.SlideYaw)
					m.Velocity = Vector3.new(m.SlideVelX, m.Velocity.Y, m.SlideVelZ)
				end
		
				alignWithFloor(m)
			end
		end
		
		local function commonSlideActionWithJump(m: Mario, stopAction: number, airAction: number, anim: Animation)
			if m.ActionTimer == 5 then
				if m.Input:Has(InputFlags.A_PRESSED) then
					return m:SetJumpingAction(Action.JUMP)
				end
			else
				m.ActionTimer += 1
			end
		
			if updateSliding(m, 4) then
				m:SetAction(stopAction)
			end
		
			commonSlideAction(m, stopAction, airAction, anim)
			return false
		end
		
		local function commonLandingCancels(
			m: Mario,
			landingAction: LandingAction,
			setAPressAction: (Mario, number, any) -> any
		)
			local floor = m.Floor
		
			if floor and floor.Normal.Y < 0.2923717 then
				return m:PushOffSteepFloor(Action.FREEFALL)
			end
		
			m.DoubleJumpTimer = landingAction.JumpTimer
		
			if shouldBeginSliding(m) then
				return m:SetAction(Action.BEGIN_SLIDING)
			end
		
			if m.Input:Has(InputFlags.FIRST_PERSON) then
				return m:SetAction(landingAction.EndAction)
			end
		
			m.ActionTimer += 1
		
			if m.ActionTimer >= landingAction.NumFrames then
				return m:SetAction(landingAction.EndAction)
			end
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return setAPressAction(m, landingAction.APressedAction, 0)
			end
		
			if m.Input:Has(InputFlags.OFF_FLOOR) then
				return m:SetAction(Action.FREEFALL)
			end
		
			return false
		end
		
		local function stomachSlideAction(m: Mario, stopAction: number, airAction: number, anim: Animation)
			if m.ActionTimer == 5 then
				if not m.Input:Has(InputFlags.ABOVE_SLIDE) and m.Input:Has(InputFlags.A_PRESSED, InputFlags.B_PRESSED) then
					return m:SetAction(if m.ForwardVel >= 0 then Action.FORWARD_ROLLOUT else Action.BACKWARD_ROLLOUT)
				end
			else
				m.ActionTimer += 1
			end
		
			if updateSliding(m, 4) then
				return m:SetAction(stopAction)
			end
		
			commonSlideAction(m, stopAction, airAction, anim)
			return false
		end
		
		local function commonGroundKnockbackAction(
			m: Mario,
			anim: Animation,
			minFrame: number,
			playHeavyLanding: boolean,
			attacked: number
		)
			local animFrame
		
			if playHeavyLanding then
				m:PlayHeavyLandingSoundOnce(Sounds.ACTION_TERRAIN_BODY_HIT_GROUND)
			end
		
			if attacked > 0 then
				m:PlaySoundIfNoFlag(Sounds.MARIO_ATTACKED, MarioFlags.MARIO_SOUND_PLAYED)
			else
				m:PlaySoundIfNoFlag(Sounds.MARIO_OOOF, MarioFlags.MARIO_SOUND_PLAYED)
			end
		
			m.ForwardVel = math.clamp(m.ForwardVel, -32, 32)
			animFrame = m:SetAnimation(anim)
		
			if animFrame < minFrame then
				applyLandingAccel(m, 0.9)
			elseif m.ForwardVel > 0 then
				m:SetForwardVel(0.1)
			else
				m:SetForwardVel(-0.1)
			end
		
			if m:PerformGroundStep() == GroundStep.LEFT_GROUND then
				if m.ForwardVel >= 0 then
					m:SetAction(Action.FORWARD_AIR_KB, attacked)
				else
					m:SetAction(Action.BACKWARD_AIR_KB, attacked)
				end
			elseif m:IsAnimAtEnd() then
				if m.Health < 0x100 then
					m:SetAction(Action.STANDING_DEATH)
				else
					if attacked > 0 then
						m.InvincTimer = 30
					end
		
					m:SetAction(Action.IDLE)
				end
			end
		
			return animFrame
		end
		
		local function commonLandingAction(m: Mario, anim: Animation)
			if m.Input:Has(InputFlags.NONZERO_ANALOG) then
				applyLandingAccel(m, 0.98)
			elseif m.ForwardVel > 16 then
				applySlopeDecel(m, 2)
			else
				m.Velocity *= Vector3.new(1, 0, 1)
			end
		
			local stepResult = m:PerformGroundStep()
		
			if stepResult == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			elseif stepResult == GroundStep.HIT_WALL then
				m:SetAnimation(Animations.PUSHING)
			end
		
			if m.ForwardVel > 16 then
				m.ParticleFlags:Add(ParticleFlags.DUST)
			end
		
			m:SetAnimation(anim)
			m:PlayLandingSoundOnce(Sounds.ACTION_TERRAIN_LANDING)
		
			return stepResult
		end
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		DEF_ACTION(Action.WALKING, function(m: Mario)
			local startPos
			local startYaw = m.FaceAngle.Y
		
			if shouldBeginSliding(m) then
				return m:SetAction(Action.BEGIN_SLIDING)
			end
		
			if m.Input:Has(InputFlags.FIRST_PERSON) then
				return beginBrakingAction(m)
			end
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetJumpFromLanding()
			end
		
			if checkGroundDiveOrPunch(m) then
				return true
			end
		
			if m.Input:Has(InputFlags.NO_MOVEMENT) then
				return beginBrakingAction(m)
			end
		
			if analogStickHeldBack(m) and m.ForwardVel >= 16 then
				return m:SetAction(Action.TURNING_AROUND)
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.CROUCH_SLIDE)
			end
		
			local step
			do
				m.ActionState = 0
				startPos = m.Position
		
				updateWalkingSpeed(m)
				step = m:PerformGroundStep()
			end
		
			if step == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
				m:SetAnimation(Animations.GENERAL_FALL)
			elseif step == GroundStep.NONE then
				animAndAudioForWalk(m)
		
				if m.IntendedMag - m.ForwardVel > 16 then
					m.ParticleFlags:Add(ParticleFlags.DUST)
				end
			elseif step == GroundStep.HIT_WALL then
				pushOrSidleWall(m, startPos)
				m.ActionTimer = 0
			end
		
			checkLedgeClimbDown(m)
			tiltBodyWalking(m, startYaw)
		
			return false
		end)
		
		DEF_ACTION(Action.MOVE_PUNCHING, function(m: Mario)
			if shouldBeginSliding(m) then
				return m:SetAction(Action.BEGIN_SLIDING)
			end
		
			if m.ActionState == 0 and m.Input:Has(InputFlags.A_DOWN) then
				return m:SetAction(Action.JUMP_KICK)
			end
		
			m.ActionState = 1
			m:UpdatePunchSequence()
		
			if m.ForwardVel > 0 then
				applySlopeDecel(m, 0.5)
			else
				m.ForwardVel += 8
		
				if m.ForwardVel >= 0 then
					m.ForwardVel = 0
				end
		
				applySlopeAccel(m)
			end
		
			local step = m:PerformGroundStep()
		
			if step == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			elseif step == GroundStep.NONE then
				m.ParticleFlags:Add(ParticleFlags.DUST)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.TURNING_AROUND, function(m: Mario)
			if m.Input:Has(InputFlags.ABOVE_SLIDE) then
				return m:SetAction(Action.BEGIN_SLIDING)
			end
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetAction(Action.SIDE_FLIP)
			end
		
			if not analogStickHeldBack(m) then
				return m:SetAction(Action.WALKING)
			end
		
			if applySlopeDecel(m, 2) then
				return beginWalkingAction(m, 8, Action.FINISH_TURNING_AROUND)
			end
		
			m:PlaySound(Sounds.MOVING_TERRAIN_SLIDE)
			m:AdjustSoundForSpeed()
		
			local step = m:PerformGroundStep()
		
			if step == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			elseif step == GroundStep.NONE then
				m.ParticleFlags:Add(ParticleFlags.DUST)
			end
		
			if m.ForwardVel >= 18 then
				m:SetAnimation(Animations.TURNING_PART1)
			else
				m:SetAnimation(Animations.TURNING_PART2)
				m.GfxAngle += Vector3int16.new(0, 0x8000, 0)
		
				if m:IsAnimAtEnd() then
					if m.ForwardVel > 0 then
						beginWalkingAction(m, -m.ForwardVel, Action.WALKING)
					else
						beginWalkingAction(m, 8, Action.WALKING)
					end
				end
			end
		
			return false
		end)
		
		DEF_ACTION(Action.FINISH_TURNING_AROUND, function(m: Mario)
			if m.Input:Has(InputFlags.ABOVE_SLIDE) then
				return m:SetAction(Action.BEGIN_SLIDING)
			end
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetAction(Action.SIDE_FLIP)
			end
		
			updateWalkingSpeed(m)
			m:SetAnimation(Animations.TURNING_PART2)
		
			if m:PerformGroundStep() == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			end
		
			if m:IsAnimAtEnd() then
				m:SetAction(Action.WALKING)
				m.AnimSkipInterp = 2
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BRAKING, function(m: Mario)
			if not m.Input:Has(InputFlags.FIRST_PERSON) then
				if
					m.Input:Has(InputFlags.NONZERO_ANALOG, InputFlags.A_PRESSED, InputFlags.OFF_FLOOR, InputFlags.ABOVE_SLIDE)
				then
					return m:CheckCommonActionExits()
				end
			end
		
			if applySlopeDecel(m, 2) then
				return m:SetAction(Action.BRAKING_STOP)
			end
		
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.MOVE_PUNCHING)
			end
		
			local stepResult = m:PerformGroundStep()
		
			if stepResult == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			elseif stepResult == GroundStep.NONE then
				m.ParticleFlags:Add(ParticleFlags.DUST)
			elseif stepResult == GroundStep.HIT_WALL then
				slideBonk(m, Action.BACKWARD_GROUND_KB, Action.BRAKING_STOP)
			end
		
			m:PlaySound(Sounds.MOVING_TERRAIN_SLIDE)
			m:SetAnimation(Animations.SKID_ON_GROUND)
			m:AdjustSoundForSpeed()
		
			return false
		end)
		
		DEF_ACTION(Action.DECELERATING, function(m: Mario)
			if not m.Input:Has(InputFlags.FIRST_PERSON) then
				if shouldBeginSliding(m) then
					return m:SetAction(Action.BEGIN_SLIDING)
				end
		
				if m.Input:Has(InputFlags.A_PRESSED) then
					return m:SetJumpFromLanding()
				end
		
				if checkGroundDiveOrPunch(m) then
					return true
				end
		
				if m.Input:Has(InputFlags.NONZERO_ANALOG) then
					return m:SetAction(Action.WALKING)
				end
		
				if m.Input:Has(InputFlags.Z_PRESSED) then
					return m:SetAction(Action.CROUCH_SLIDE)
				end
			end
		
			if updateDeceleratingSpeed(m) then
				return m:SetAction(Action.IDLE)
			end
		
			local slopeClass = m:GetFloorClass()
			local stepResult = m:PerformGroundStep()
		
			if stepResult == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			elseif stepResult == GroundStep.HIT_WALL then
				if slopeClass == SurfaceClass.VERY_SLIPPERY then
					m:BonkReflection(true)
				else
					m:SetForwardVel(0)
				end
			end
		
			if slopeClass == SurfaceClass.VERY_SLIPPERY then
				m:SetAnimation(Animations.IDLE_HEAD_LEFT)
				m:PlaySound(Sounds.MOVING_TERRAIN_SLIDE)
		
				m:AdjustSoundForSpeed()
				m.ParticleFlags:Add(ParticleFlags.DUST)
			else
				local accel = m.ForwardVel / 4 * 0x10000
		
				if accel < 0x1000 then
					accel = 0x1000
				end
		
				m:SetAnimationWithAccel(Animations.WALKING, accel)
				playStepSound(m, 10, 49)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.CRAWLING, function(m: Mario)
			if shouldBeginSliding(m) then
				return m:SetAction(Action.BEGIN_SLIDING)
			end
		
			if m.Input:Has(InputFlags.FIRST_PERSON) then
				return m:SetAction(Action.STOP_CRAWLING)
			end
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetJumpingAction(Action.JUMP)
			end
		
			if checkGroundDiveOrPunch(m) then
				return true
			end
		
			if m.Input:Has(InputFlags.NO_MOVEMENT) then
				return m:SetAction(Action.STOP_CRAWLING)
			end
		
			if not m.Input:Has(InputFlags.Z_DOWN) then
				return m:SetAction(Action.STOP_CRAWLING)
			end
		
			m.IntendedMag *= 0.1
			updateWalkingSpeed(m)
		
			local stepResult = m:PerformGroundStep()
		
			if stepResult == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL)
			elseif stepResult == GroundStep.HIT_WALL then
				if m.ForwardVel > 10 then
					m:SetForwardVel(10)
				end
		
				alignWithFloor(m)
			elseif stepResult == GroundStep.NONE then
				alignWithFloor(m)
			end
		
			local accel = m.IntendedMag * 2 * 0x10000
			m:SetAnimationWithAccel(Animations.CRAWLING, accel)
			playStepSound(m, 26, 79)
		
			return false
		end)
		
		DEF_ACTION(Action.BURNING_GROUND, function(m: Mario)
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetAction(Action.BURNING_JUMP)
			end
		
			m.BurnTimer += 2
		
			if m.BurnTimer > 160 then
				return m:SetAction(Action.WALKING)
			end
		
			if m.ForwardVel < 8 then
				m.ForwardVel = 8
			end
		
			if m.ForwardVel > 48 then
				m.ForwardVel = 48
			end
		
			m.ForwardVel = Util.ApproachFloat(m.ForwardVel, 32, 4, 1)
		
			if m.Input:Has(InputFlags.NONZERO_ANALOG) then
				local faceY = m.IntendedYaw - Util.ApproachFloat(m.IntendedYaw - m.FaceAngle.Y, 0, 0x600)
				m.FaceAngle = Util.SetY(m.FaceAngle, faceY)
			end
		
			applySlopeAccel(m)
		
			if m:PerformGroundStep() == GroundStep.LEFT_GROUND then
				m:SetAction(Action.BURNING_FALL)
			end
		
			local accel = m.ForwardVel / 2 * 0x10000
			m:SetAnimationWithAccel(Animations.RUNNING, accel)
			playStepSound(m, 9, 45)
		
			m.ParticleFlags:Add(ParticleFlags.FIRE)
			m:PlaySound(Sounds.MOVING_LAVA_BURN)
		
			m.Health -= 10
		
			if m.Health < 0x100 then
				m:SetAction(Action.STANDING_DEATH)
			end
		
			m.BodyState.EyeState = MarioEyes.DEAD
			return false
		end)
		
		DEF_ACTION(Action.BUTT_SLIDE, function(m: Mario)
			local cancel = commonSlideActionWithJump(m, Action.BUTT_SLIDE_STOP, Action.BUTT_SLIDE_AIR, Animations.SLIDE)
			tiltBodyButtSlide(m)
		
			return cancel
		end)
		
		DEF_ACTION(Action.CROUCH_SLIDE, function(m: Mario)
			if m.Input:Has(InputFlags.ABOVE_SLIDE) then
				return m:SetAction(Action.BUTT_SLIDE)
			end
		
			if m.ActionTimer < 30 then
				m.ActionTimer += 1
		
				if m.Input:Has(InputFlags.A_PRESSED) then
					if m.ForwardVel > 10 then
						return m:SetJumpingAction(Action.LONG_JUMP)
					end
				end
			end
		
			if m.Input:Has(InputFlags.B_PRESSED) then
				if m.ForwardVel >= 10 then
					return m:SetAction(Action.SLIDE_KICK)
				else
					return m:SetAction(Action.MOVE_PUNCHING, 9)
				end
			end
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetAction(Action.JUMP)
			end
		
			if m.Input:Has(InputFlags.FIRST_PERSON) then
				return m:SetAction(Action.BRAKING)
			end
		
			return commonSlideActionWithJump(m, Action.CROUCHING, Action.FREEFALL, Animations.START_CROUCHING)
		end)
		
		DEF_ACTION(Action.SLIDE_KICK_SLIDE, function(m: Mario)
			local step
		
			if m.Input:Has(InputFlags.A_PRESSED) then
				return m:SetAction(Action.FORWARD_ROLLOUT)
			end
		
			m:SetAnimation(Animations.SLIDE_KICK)
		
			if m:IsAnimAtEnd() and m.ForwardVel < 1 then
				return m:SetAction(Action.SLIDE_KICK_SLIDE_STOP)
			end
		
			updateSliding(m, 1)
			step = m:PerformGroundStep()
		
			if step == GroundStep.LEFT_GROUND then
				m:SetAction(Action.FREEFALL, 2)
			elseif step == GroundStep.HIT_WALL then
				m:BonkReflection(true)
				m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				m:SetAction(Action.BACKWARD_GROUND_KB)
			end
		
			m:PlaySound(Sounds.MOVING_TERRAIN_SLIDE)
			m.ParticleFlags:Add(ParticleFlags.DUST)
		
			return false
		end)
		
		DEF_ACTION(Action.STOMACH_SLIDE, function(m: Mario)
			if m.ActionTimer == 5 then
				if not m.Input:Has(InputFlags.ABOVE_SLIDE) and m.Input:Has(InputFlags.A_PRESSED, InputFlags.B_PRESSED) then
					return m:SetAction(if m.ForwardVel >= 0 then Action.FORWARD_ROLLOUT else Action.BACKWARD_ROLLOUT)
				end
			else
				m.ActionTimer += 1
			end
		
			if updateSliding(m, 4) then
				return m:SetAction(Action.STOMACH_SLIDE_STOP)
			end
		
			commonSlideAction(m, Action.STOMACH_SLIDE_STOP, Action.FREEFALL, Animations.SLIDE_DIVE)
			return false
		end)
		
		DEF_ACTION(Action.DIVE_SLIDE, function(m: Mario)
			if not m.Input:Has(InputFlags.ABOVE_SLIDE) and m.Input:Has(InputFlags.A_PRESSED, InputFlags.B_PRESSED) then
				return m:SetAction(if m.ForwardVel >= 0 then Action.FORWARD_ROLLOUT else Action.BACKWARD_ROLLOUT)
			end
		
			m:PlayLandingSoundOnce(Sounds.ACTION_TERRAIN_BODY_HIT_GROUND)
		
			if updateSliding(m, 8) and m:IsAnimAtEnd() then
				m:SetForwardVel(0)
				m:SetAction(Action.STOMACH_SLIDE_STOP)
			end
		
			commonSlideAction(m, Action.STOMACH_SLIDE_STOP, Action.FREEFALL, Animations.DIVE)
			return false
		end)
		
		DEF_ACTION(Action.HARD_BACKWARD_GROUND_KB, function(m: Mario)
			local animFrame = commonGroundKnockbackAction(m, Animations.FALL_OVER_BACKWARDS, 43, true, m.ActionArg)
		
			if animFrame == 43 and m.Health < 0x100 then
				m:SetAction(Action.DEATH_ON_BACK)
			end
		
			if animFrame == 54 and m.PrevAction() == Action.SPECIAL_DEATH_EXIT then
				m:PlaySound(Sounds.MARIO_MAMA_MIA)
			end
		
			if animFrame == 69 then
				m:PlayLandingSoundOnce(Sounds.ACTION_TERRAIN_LANDING)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.HARD_FORWARD_GROUND_KB, function(m: Mario)
			local animFrame = commonGroundKnockbackAction(m, Animations.LAND_ON_STOMACH, 21, true, m.ActionArg)
		
			if animFrame == 23 and m.Health < 0x100 then
				m:SetAction(Action.DEATH_ON_STOMACH)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BACKWARD_GROUND_KB, function(m: Mario)
			commonGroundKnockbackAction(m, Animations.BACKWARD_KB, 22, true, m.ActionArg)
			return false
		end)
		
		DEF_ACTION(Action.FORWARD_GROUND_KB, function(m: Mario)
			commonGroundKnockbackAction(m, Animations.FORWARD_KB, 20, true, m.ActionArg)
			return false
		end)
		
		DEF_ACTION(Action.SOFT_BACKWARD_GROUND_KB, function(m: Mario)
			commonGroundKnockbackAction(m, Animations.SOFT_BACK_KB, 100, false, m.ActionArg)
			return false
		end)
		
		DEF_ACTION(Action.SOFT_FORWARD_GROUND_KB, function(m: Mario)
			commonGroundKnockbackAction(m, Animations.SOFT_FRONT_KB, 100, false, m.ActionArg)
			return false
		end)
		
		DEF_ACTION(Action.GROUND_BONK, function(m: Mario)
			local animFrame = commonGroundKnockbackAction(m, Animations.GROUND_BONK, 32, true, m.ActionArg)
		
			if animFrame == 32 then
				m:PlayLandingSound(Sounds.ACTION_TERRAIN_LANDING)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.JUMP_LAND, function(m: Mario)
			if commonLandingCancels(m, sJumpLandAction, m.SetJumpingAction) then
				return true
			end
		
			commonLandingAction(m, Animations.LAND_FROM_SINGLE_JUMP)
			return false
		end)
		
		DEF_ACTION(Action.FREEFALL_LAND, function(m: Mario)
			if commonLandingCancels(m, sFreefallLandAction, m.SetJumpingAction) then
				return true
			end
		
			commonLandingAction(m, Animations.GENERAL_LAND)
			return false
		end)
		
		DEF_ACTION(Action.SIDE_FLIP_LAND, function(m: Mario)
			if commonLandingCancels(m, sSideFlipLandAction, m.SetJumpingAction) then
				return true
			end
		
			if commonLandingAction(m, Animations.SLIDEFLIP_LAND) ~= GroundStep.HIT_WALL then
				--m.GfxAngle += Vector3int16.new(0, 0x8000, 0)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.LONG_JUMP_LAND, function(m: Mario)
			if not m.Input:Has(InputFlags.Z_DOWN) then
				m.Input:Remove(InputFlags.A_PRESSED)
			end
		
			if commonLandingCancels(m, sLongJumpLandAction, m.SetJumpingAction) then
				return true
			end
		
			if not m.Input:Has(InputFlags.NONZERO_ANALOG) then
				m:PlaySoundIfNoFlag(Sounds.MARIO_UH, MarioFlags.MARIO_SOUND_PLAYED)
			end
		
			commonLandingAction(
				m,
				if m.LongJumpIsSlow then Animations.CROUCH_FROM_FAST_LONGJUMP else Animations.CROUCH_FROM_SLOW_LONGJUMP
			)
		
			return false
		end)
		
		DEF_ACTION(Action.DOUBLE_JUMP_LAND, function(m: Mario)
			if commonLandingCancels(m, sDoubleJumpLandAction, setTripleJumpAction) then
				return true
			end
		
			commonLandingAction(m, Animations.LAND_FROM_DOUBLE_JUMP)
			return false
		end)
		
		DEF_ACTION(Action.TRIPLE_JUMP_LAND, function(m: Mario)
			m.Input:Remove(InputFlags.A_PRESSED)
		
			if commonLandingCancels(m, sTripleJumpLandAction, m.SetJumpingAction) then
				return true
			end
		
			if not m.Input:Has(InputFlags.NONZERO_ANALOG) then
				m:PlaySoundIfNoFlag(Sounds.MARIO_HAHA, MarioFlags.MARIO_SOUND_PLAYED)
			end
		
			commonLandingAction(m, Animations.TRIPLE_JUMP_LAND)
			return false
		end)
		
		DEF_ACTION(Action.BACKFLIP_LAND, function(m: Mario)
			if not m.Input:Has(InputFlags.Z_DOWN) then
				m.Input:Remove(InputFlags.A_PRESSED)
			end
		
			if commonLandingCancels(m, sBackflipLandAction, m.SetJumpingAction) then
				return true
			end
		
			if not m.Input:Has(InputFlags.NONZERO_ANALOG) then
				m:PlaySoundIfNoFlag(Sounds.MARIO_HAHA, MarioFlags.MARIO_SOUND_PLAYED)
			end
		
			commonLandingAction(m, Animations.TRIPLE_JUMP_LAND)
			return false
		end)
		
		DEF_ACTION(Action.PUNCHING, function(m: Mario)
			if m.Input:Has(InputFlags.STOMPED) then
				return m:SetAction(Action.SHOCKWAVE_BOUNCE)
			end
		
			if m.Input:Has(InputFlags.NONZERO_ANALOG, InputFlags.A_PRESSED, InputFlags.OFF_FLOOR, InputFlags.ABOVE_SLIDE) then
				return m:CheckCommonActionExits()
			end
		
			if m.ActionState and m.Input:Has(InputFlags.A_DOWN) then
				return m:SetAction(Action.JUMP_KICK)
			end
		
			m.ActionState = 1
		
			if m.ActionArg == 0 then
				m.ActionTimer = 7
			end
		
			m:SetForwardVel(sPunchingForwardVelocities[m.ActionTimer + 1])
		
			if m.ActionTimer > 0 then
				m.ActionTimer -= 1
			end
		
			m:UpdatePunchSequence()
			m:PerformGroundStep()
		
			return false
		end)
	end
	do -- AIRBORNE
		local function stopRising(m: Mario)
			if maryo.Velocity.Y > 0 then
				maryo.Velocity *= Vector3.new(1, 0, 1)
			end
		end
		local function playFlipSounds(m: Mario, frame1: number, frame2: number, frame3: number)
			local animFrame = maryo.AnimFrame
			if animFrame == frame1 or animFrame == frame2 or animFrame == frame3 then
				maryo.PlaySound("ACTION_SPIN")
			end
		end
		local function playKnockbackSound(m: Mario)
			if maryo.ActionArg == 0 and math.abs(maryo.ForwardVel) >= 28 then
				maryo.PlaySoundIfNoFlag(Sounds.MARIO_DOH, MarioFlags.MARIO_SOUND_PLAYED)
			else
				maryo.PlaySoundIfNoFlag(Sounds.MARIO_UH, MarioFlags.MARIO_SOUND_PLAYED)
			end
		end
		local function lavaBoostOnWall(m: Mario)
			local wall = maryo.Wall
			if wall then
				maryo.SetFaceYaw(math.atan2(wall.Normal.Z, wall.Normal.X))
			end
			if maryo.ForwardVel < 24 then
				maryo.ForwardVel = 24
			end
			if not maryo.Flags.METAL_CAP then
				maryo.HurtCounter += if maryo.Flags.CAP_ON_HEAD then 12 else 18
			end
			maryo.PlaySound("MARIO_ON_FIRE")
			maryo.SetAction("LAVA_BOOST", 1)
		end
		local function checkFallDamage(hardFallAction)
			local fallHeight = maryo.PeakHeight - maryo.Position.Y
			local damageHeight = 1150
			if maryo.Action.NAME == "TWIRLING" then return false end
			if maryo.Velocity.Y < -2.75 and fallHeight > 3000 then
				maryo.HurtCounter += if maryo.Flags.CAP_ON_HEAD then 16 else 24
				maryo.PlaySound("MARIO_ATTACKED")
				maryo.SetAction(hardFallAction, 4)
			elseif fallHeight > damageHeight and not maryo.FloorIsSlippery() then
				maryo.HurtCounter += if maryo.Flags.CAP_ON_HEAD then 8 else 12
				maryo.PlaySound("MARIO_ATTACKED")
				maryo.SquishTimer = 30
			end
			return false
		end
		local function checkKickOrDiveInAir(m: Mario): boolean
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(if maryo.ForwardVel > 28 then Action.DIVE else Action.JUMP_KICK)
			end
		
			return false
		end
		
		local function updateAirWithTurn(m: Mario)
			local dragThreshold = if maryo.Action() == Action.LONG_JUMP then 48 else 32
			maryo.ForwardVel = Util.ApproachFloat(maryo.ForwardVel, 0, 0.35)
		
			if maryo.Input:Has(InputFlags.NONZERO_ANALOG) then
				local intendedDYaw = maryo.IntendedYaw - maryo.FaceAngle.Y
				local intendedMag = maryo.IntendedMag / 32
		
				maryo.ForwardVel += 1.5 * Util.Coss(intendedDYaw) * intendedMag
				maryo.FaceAngle += Vector3int16.new(0, 512 * Util.Sins(intendedDYaw) * intendedMag, 0)
			end
		
			if maryo.ForwardVel > dragThreshold then
				maryo.ForwardVel -= 1
			end
		
			if maryo.ForwardVel < -16 then
				maryo.ForwardVel += 2
			end
		
			maryo.SlideVelX = maryo.ForwardVel * Util.Sins(maryo.FaceAngle.Y)
			maryo.SlideVelZ = maryo.ForwardVel * Util.Coss(maryo.FaceAngle.Y)
			maryo.Velocity = Vector3.new(maryo.SlideVelX, maryo.Velocity.Y, maryo.SlideVelZ)
		end
		
		local function updateAirWithoutTurn(m: Mario)
			local dragThreshold = 32
		
			if maryo.Action() == Action.LONG_JUMP then
				dragThreshold = 48
			end
		
			local sidewaysSpeed = 0
			maryo.ForwardVel = Util.ApproachFloat(maryo.ForwardVel, 0, 0.35)
		
			if maryo.Input:Has(InputFlags.NONZERO_ANALOG) then
				local intendedDYaw = maryo.IntendedYaw - maryo.FaceAngle.Y
				local intendedMag = maryo.IntendedMag / 32
		
				maryo.ForwardVel += intendedMag * Util.Coss(intendedDYaw) * 1.5
				sidewaysSpeed = intendedMag * Util.Sins(intendedDYaw) * 10
			end
		
			--! Uncapped air speed. Net positive when moving forward.
			if maryo.ForwardVel > dragThreshold then
				maryo.ForwardVel -= 1
			end
		
			if maryo.ForwardVel < -16 then
				maryo.ForwardVel += 2
			end
		
			maryo.SlideVelX = maryo.ForwardVel * Util.Sins(maryo.FaceAngle.Y)
			maryo.SlideVelZ = maryo.ForwardVel * Util.Coss(maryo.FaceAngle.Y)
		
			maryo.SlideVelX += sidewaysSpeed * Util.Sins(maryo.FaceAngle.Y + 0x4000)
			maryo.SlideVelZ += sidewaysSpeed * Util.Coss(maryo.FaceAngle.Y + 0x4000)
		
			maryo.Velocity = Vector3.new(maryo.SlideVelX, maryo.Velocity.Y, maryo.SlideVelZ)
		end
		
		local function updateLavaBoostOrTwirling(m: Mario)
			if maryo.Input:Has(InputFlags.NONZERO_ANALOG) then
				local intendedDYaw = maryo.IntendedYaw - maryo.FaceAngle.Y
				local intendedMag = maryo.IntendedMag / 32
		
				maryo.ForwardVel += Util.Coss(intendedDYaw) * intendedMag
				maryo.FaceAngle += Vector3int16.new(0, Util.Sins(intendedDYaw) * intendedMag * 1024, 0)
		
				if maryo.ForwardVel < 0 then
					maryo.FaceAngle += Vector3int16.new(0, 0x8000, 0)
					maryo.ForwardVel *= -1
				end
		
				if maryo.ForwardVel > 32 then
					maryo.ForwardVel -= 2
				end
			end
		
			maryo.SlideVelX = maryo.ForwardVel * Util.Sins(maryo.FaceAngle.Y)
			maryo.SlideVelZ = maryo.ForwardVel * Util.Coss(maryo.FaceAngle.Y)
		
			maryo.Velocity = Vector3.new(maryo.SlideVelX, maryo.Velocity.Y, maryo.SlideVelZ)
		end
		
		local function updateFlyingYaw(m: Mario)
			local targetYawVel = -Util.SignedShort(maryo.Controller.StickX * (maryo.ForwardVel / 4))
		
			if targetYawVel > 0 then
				if maryo.AngleVel.Y < 0 then
					maryo.AngleVel += Vector3int16.new(0, 0x40, 0)
		
					if maryo.AngleVel.Y > 0x10 then
						maryo.AngleVel = Util.SetY(maryo.AngleVel, 0x10)
					end
				else
					local y = Util.ApproachInt(maryo.AngleVel.Y, targetYawVel, 0x10, 0x20)
					maryo.AngleVel = Util.SetY(maryo.AngleVel, y)
				end
			elseif targetYawVel < 0 then
				if maryo.AngleVel.Y > 0 then
					maryo.AngleVel -= Vector3int16.new(0, 0x40, 0)
		
					if maryo.AngleVel.Y < -0x10 then
						maryo.AngleVel = Util.SetY(maryo.AngleVel, -0x10)
					end
				else
					local y = Util.ApproachInt(maryo.AngleVel.Y, targetYawVel, 0x20, 0x10)
					maryo.AngleVel = Util.SetY(maryo.AngleVel, y)
				end
			else
				local y = Util.ApproachInt(maryo.AngleVel.Y, 0, 0x40)
				maryo.AngleVel = Util.SetY(maryo.AngleVel, y)
			end
		
			maryo.FaceAngle += Vector3int16.new(0, maryo.AngleVel.Y, 0)
			maryo.FaceAngle = Util.SetZ(maryo.FaceAngle, 20 * -maryo.AngleVel.Y)
		end
		
		local function updateFlyingPitch(m: Mario)
			local targetPitchVel = -Util.SignedShort(maryo.Controller.StickY * (maryo.ForwardVel / 5))
		
			if targetPitchVel > 0 then
				if maryo.AngleVel.X < 0 then
					maryo.AngleVel += Vector3int16.new(0x40, 0, 0)
		
					if maryo.AngleVel.X > 0x20 then
						maryo.AngleVel = Util.SetX(maryo.AngleVel, 0x20)
					end
				else
					local x = Util.ApproachInt(maryo.AngleVel.X, targetPitchVel, 0x20, 0x40)
					maryo.AngleVel = Util.SetX(maryo.AngleVel, x)
				end
			elseif targetPitchVel < 0 then
				if maryo.AngleVel.X > 0 then
					maryo.AngleVel -= Vector3int16.new(0x40, 0, 0)
		
					if maryo.AngleVel.X < -0x20 then
						maryo.AngleVel = Util.SetX(maryo.AngleVel, -0x20)
					end
				else
					local x = Util.ApproachInt(maryo.AngleVel.X, targetPitchVel, 0x40, 0x20)
					maryo.AngleVel = Util.SetX(maryo.AngleVel, x)
				end
			else
				local x = Util.ApproachInt(maryo.AngleVel.X, 0, 0x40)
				maryo.AngleVel = Util.SetX(maryo.AngleVel, x)
			end
		end
		
		local function updateFlying(m: Mario)
			updateFlyingPitch(m)
			updateFlyingYaw(m)
		
			maryo.ForwardVel -= 2 * (maryo.FaceAngle.X / 0x4000) + 0.1
			maryo.ForwardVel -= 0.5 * (1 - Util.Coss(maryo.AngleVel.Y))
		
			if maryo.ForwardVel < 0 then
				maryo.ForwardVel = 0
			end
		
			if maryo.ForwardVel > 16 then
				maryo.FaceAngle += Vector3int16.new((maryo.ForwardVel - 32) * 6, 0, 0)
			elseif maryo.ForwardVel > 4 then
				maryo.FaceAngle += Vector3int16.new((maryo.ForwardVel - 32) * 10, 0, 0)
			else
				maryo.FaceAngle -= Vector3int16.new(0x400, 0, 0)
			end
		
			maryo.FaceAngle += Vector3int16.new(maryo.AngleVel.X, 0, 0)
		
			if maryo.FaceAngle.X > 0x2AAA then
				maryo.FaceAngle = Util.SetX(maryo.FaceAngle, 0x2AAA)
			end
		
			if maryo.FaceAngle.X < -0x2AAA then
				maryo.FaceAngle = Util.SetX(maryo.FaceAngle, -0x2AAA)
			end
		
			local velX = Util.Coss(maryo.FaceAngle.X) * Util.Sins(maryo.FaceAngle.Y)
			maryo.SlideVelX = maryo.ForwardVel * velX
		
			local velZ = Util.Coss(maryo.FaceAngle.X) * Util.Coss(maryo.FaceAngle.Y)
			maryo.SlideVelZ = maryo.ForwardVel * velZ
		
			local velY = Util.Sins(maryo.FaceAngle.X)
			maryo.Velocity = maryo.ForwardVel * Vector3.new(velX, velY, velZ)
		end
		
		local function commonAirActionStep(m: Mario, landAction: number, anim: Animation, stepArg: number): number
			local stepResult
			do
				updateAirWithoutTurn(m)
				stepResult = maryo.PerformAirStep(stepArg)
			end
		
			if stepResult == AirStep.NONE then
				maryo.SetAnimation(anim)
			elseif stepResult == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					maryo.SetAction(landAction)
				end
			elseif stepResult == AirStep.HIT_WALL then
				maryo.SetAnimation(anim)
		
				if maryo.ForwardVel > 16 then
					maryo.BonkReflection()
					maryo.FaceAngle += Vector3int16.new(0, 0x8000, 0)
		
					if maryo.Wall then
						maryo.SetAction(Action.AIR_HIT_WALL)
					else
						stopRising(m)
		
						if maryo.ForwardVel >= 38 then
							maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
							maryo.SetAction(Action.BACKWARD_AIR_KB)
						else
							if maryo.ForwardVel > 8 then
								maryo.SetForwardVel(-8)
							end
		
							maryo.SetAction(Action.SOFT_BONK)
						end
					end
				else
					maryo.SetForwardVel(0)
				end
			elseif stepResult == AirStep.GRABBED_LEDGE then
				maryo.SetAnimation(Animations.IDLE_ON_LEDGE)
				maryo.SetAction(Action.LEDGE_GRAB)
			elseif stepResult == AirStep.GRABBED_CEILING then
				maryo.SetAction(Action.START_HANGING)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return stepResult
		end
		
		local function commonRolloutStep(m: Mario, anim: Animation)
			local stepResult
		
			if maryo.ActionState == 0 then
				maryo.Velocity = Util.SetY(maryo.Velocity, 30)
				maryo.ActionState = 1
			end
		
			maryo.PlaySound(Sounds.ACTION_TERRAIN_JUMP)
			updateAirWithoutTurn(m)
		
			stepResult = maryo.PerformAirStep()
		
			if stepResult == AirStep.NONE then
				if maryo.ActionState == 1 then
					if maryo.SetAnimation(anim) == 4 then
						maryo.PlaySound(Sounds.ACTION_SPIN)
					end
				else
					maryo.SetAnimation(Animations.GENERAL_FALL)
				end
			elseif stepResult == AirStep.LANDED then
				maryo.SetAction(Action.FREEFALL_LAND_STOP)
				maryo.PlayLandingSound()
			elseif stepResult == AirStep.HIT_WALL then
				maryo.SetForwardVel(0)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			if maryo.ActionState == 1 and maryo.IsAnimPastEnd() then
				maryo.ActionState = 2
			end
		end
		
		local function commonAirKnockbackStep(
			m: Mario,
			landAction: number,
			hardFallAction: number,
			anim: Animation,
			speed: number
		)
			local stepResult
			do
				maryo.SetForwardVel(speed)
				stepResult = maryo.PerformAirStep()
			end
		
			if stepResult == AirStep.NONE then
				maryo.SetAnimation(anim)
			elseif stepResult == AirStep.LANDED then
				if not checkFallDamage(m, hardFallAction) then
					local action = maryo.Action()
		
					if action == Action.THROWN_FORWARD or action == Action.THROWN_BACKWARD then
						maryo.SetAction(landAction, maryo.HurtCounter)
					else
						maryo.SetAction(landAction, maryo.ActionArg)
					end
				end
			elseif stepResult == AirStep.HIT_WALL then
				maryo.SetAnimation(Animations.BACKWARD_AIR_KB)
				maryo.BonkReflection()
		
				stopRising(m)
				maryo.SetForwardVel(-speed)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return stepResult
		end
		
		local function checkWallKick(m: Mario)
			if maryo.WallKickTimer ~= 0 then
				if maryo.Input:Has(InputFlags.A_PRESSED) then
					if maryo.PrevAction() == Action.AIR_HIT_WALL then
						maryo.FaceAngle += Vector3int16.new(0, 0x8000, 0)
					end
				end
			end
		
			return false
		end
		
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Actions
		-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		
		local AIR_STEP_CHECK_BOTH = bit32.bor(AirStep.CHECK_LEDGE_GRAB, AirStep.CHECK_HANG)
		local DEF_ACTION: (number, (Mario) -> boolean) -> () = System.RegisterAction
		
		DEF_ACTION(Action.JUMP, function(m: Mario)
			if checkKickOrDiveInAir(m) then
				return true
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			commonAirActionStep(m, Action.JUMP_LAND, Animations.SINGLE_JUMP, AIR_STEP_CHECK_BOTH)
		
			return false
		end)
		
		DEF_ACTION(Action.DOUBLE_JUMP, function(m: Mario)
			local anim = if maryo.Velocity.Y >= 0 then Animations.DOUBLE_JUMP_RISE else Animations.DOUBLE_JUMP_FALL
		
			if checkKickOrDiveInAir(m) then
				return true
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_HOOHOO)
			commonAirActionStep(m, Action.DOUBLE_JUMP_LAND, anim, AIR_STEP_CHECK_BOTH)
		
			return false
		end)
		
		DEF_ACTION(Action.TRIPLE_JUMP, function(m: Mario)
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(Action.DIVE)
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			commonAirActionStep(m, Action.TRIPLE_JUMP_LAND, Animations.TRIPLE_JUMP, 0)
		
			playFlipSounds(m, 2, 8, 20)
			return false
		end)
		
		DEF_ACTION(Action.BACKFLIP, function(m: Mario)
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_YAH_WAH_HOO)
			commonAirActionStep(m, Action.BACKFLIP_LAND, Animations.BACKFLIP, 0)
		
			playFlipSounds(m, 2, 3, 17)
			return false
		end)
		
		DEF_ACTION(Action.FREEFALL, function(m: Mario)
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(Action.DIVE)
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			local anim
		
			if maryo.ActionArg == 0 then
				anim = Animations.GENERAL_FALL
			elseif maryo.ActionArg == 1 then
				anim = Animations.FALL_FROM_SLIDE
			elseif maryo.ActionArg == 2 then
				anim = Animations.FALL_FROM_SLIDE_KICK
			end
		
			commonAirActionStep(m, Action.FREEFALL_LAND, anim, AirStep.CHECK_LEDGE_GRAB)
			return false
		end)
		
		DEF_ACTION(Action.SIDE_FLIP, function(m: Mario)
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(Action.DIVE, 0)
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			commonAirActionStep(m, Action.SIDE_FLIP_LAND, Animations.SLIDEFLIP, AirStep.CHECK_LEDGE_GRAB)
		
			if maryo.AnimFrame == 6 then
				maryo.PlaySound(Sounds.ACTION_SIDE_FLIP)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.WALL_KICK_AIR, function(m: Mario)
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(Action.DIVE)
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayJumpSound()
			commonAirActionStep(m, Action.JUMP_LAND, Animations.SLIDEJUMP, AirStep.CHECK_LEDGE_GRAB)
		
			return false
		end)
		
		DEF_ACTION(Action.LONG_JUMP, function(m: Mario)
			local anim = if maryo.LongJumpIsSlow then Animations.SLOW_LONGJUMP else Animations.FAST_LONGJUMP
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_YAHOO)
			commonAirActionStep(m, Action.LONG_JUMP_LAND, anim, AirStep.CHECK_LEDGE_GRAB)
		
			return false
		end)
		
		DEF_ACTION(Action.TWIRLING, function(m: Mario)
			local startTwirlYaw = maryo.TwirlYaw
			local yawVelTarget = 0x1000
		
			if maryo.Input:Has(InputFlags.A_DOWN) then
				yawVelTarget = 0x2000
			end
		
			local yVel = Util.ApproachInt(maryo.AngleVel.Y, yawVelTarget, 0x200)
			maryo.AngleVel = Util.SetY(maryo.AngleVel, yVel)
			maryo.TwirlYaw += yVel
		
			maryo.SetAnimation(if maryo.ActionArg == 0 then Animations.START_TWIRL else Animations.TWIRL)
		
			if maryo.IsAnimPastEnd() then
				maryo.ActionArg = 1
			end
		
			if startTwirlYaw > maryo.TwirlYaw then
				maryo.PlaySound(Sounds.ACTION_TWIRL)
			end
		
			local step = maryo.PerformAirStep()
		
			if step == AirStep.LANDED then
				maryo.SetAction(Action.TWIRL_LAND)
			elseif step == AirStep.HIT_WALL then
				maryo.BonkReflection(false)
			elseif step == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			maryo.GfxAngle += Vector3int16.new(0, maryo.TwirlYaw, 0)
			return false
		end)
		
		DEF_ACTION(Action.DIVE, function(m: Mario)
			local airStep
		
			if maryo.ActionArg == 0 then
				maryo.PlayMarioSound(Sounds.ACTION_THROW, Sounds.MARIO_HOOHOO)
			else
				maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			end
		
			maryo.SetAnimation(Animations.DIVE)
			updateAirWithoutTurn(m)
			airStep = maryo.PerformAirStep()
		
			if airStep == AirStep.NONE then
				if maryo.Velocity.Y < 0 and maryo.FaceAngle.X > -0x2AAA then
					maryo.FaceAngle -= Vector3int16.new(0x200, 0, 0)
		
					if maryo.FaceAngle.X < -0x2AAA then
						maryo.FaceAngle = Util.SetX(maryo.FaceAngle, -0x2AAA)
					end
				end
		
				maryo.GfxAngle = Util.SetX(maryo.GfxAngle, -maryo.FaceAngle.X)
			elseif airStep == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_FORWARD_GROUND_KB) then
					maryo.SetAction(Action.DIVE_SLIDE)
				end
		
				maryo.FaceAngle *= Vector3int16.new(0, 1, 1)
			elseif airStep == AirStep.HIT_WALL then
				maryo.BonkReflection(true)
				maryo.FaceAngle *= Vector3int16.new(0, 1, 1)
		
				stopRising(m)
		
				maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				maryo.SetAction(Action.BACKWARD_AIR_KB)
			elseif airStep == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.WATER_JUMP, function(m: Mario)
			if maryo.ForwardVel < 15 then
				maryo.SetForwardVel(15)
			end
		
			maryo.PlaySound(Sounds.ACTION_WATER_EXIT)
			maryo.SetAnimation(Animations.SINGLE_JUMP)
		
			local step = maryo.PerformAirStep(AirStep.CHECK_LEDGE_GRAB)
		
			if step == AirStep.LANDED then
				maryo.SetAction(Action.JUMP_LAND)
			elseif step == AirStep.HIT_WALL then
				maryo.SetForwardVel(15)
			elseif step == AirStep.GRABBED_LEDGE then
				maryo.SetAnimation(Animations.IDLE_ON_LEDGE)
				maryo.SetAction(Action.LEDGE_GRAB)
			elseif step == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.STEEP_JUMP, function(m: Mario)
			local airStep
		
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(Action.DIVE)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			maryo.SetForwardVel(0.98 * maryo.ForwardVel)
			airStep = maryo.PerformAirStep()
		
			if airStep == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					maryo.FaceAngle *= Vector3int16.new(0, 1, 1)
					maryo.SetAction(if maryo.ForwardVel < 0 then Action.BEGIN_SLIDING else Action.JUMP_LAND)
				end
			elseif airStep == AirStep.HIT_WALL then
				maryo.SetForwardVel(0)
			elseif airStep == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			maryo.SetAnimation(Animations.SINGLE_JUMP)
			maryo.GfxAngle = Util.SetY(maryo.GfxAngle, maryo.SteepJumpYaw)
		
			return false
		end)
		
		DEF_ACTION(Action.GROUND_POUND, function(m: Mario)
			local stepResult
			local yOffset
		
			maryo.PlaySoundIfNoFlag(Sounds.ACTION_THROW, MarioFlags.ACTION_SOUND_PLAYED)
		
			if maryo.ActionState == 0 then
				if maryo.ActionTimer < 10 then
					yOffset = 20 - 2 * maryo.ActionTimer
		
					if maryo.Position.Y + yOffset + 160 < maryo.CeilHeight then
						maryo.Position += Vector3.new(0, yOffset, 0)
						maryo.PeakHeight = maryo.Position.Y
					end
				end
		
				maryo.Velocity = Util.SetY(maryo.Velocity, -50)
				maryo.SetForwardVel(0)
		
				maryo.SetAnimation(if maryo.ActionArg == 0 then Animations.START_GROUND_POUND else Animations.TRIPLE_JUMP_GROUND_POUND)
		
				if maryo.ActionTimer == 0 then
					maryo.PlaySound(Sounds.ACTION_SPIN)
				end
		
				maryo.ActionTimer += 1
				maryo.GfxAngle = Vector3int16.new(0, maryo.FaceAngle.Y, 0)
		
				if maryo.ActionTimer >= maryo.AnimFrameCount + 4 then
					maryo.PlaySound(Sounds.MARIO_GROUND_POUND_WAH)
					maryo.ActionState = 1
				end
			else
				maryo.SetAnimation(Animations.GROUND_POUND)
				stepResult = maryo.PerformAirStep()
		
				if stepResult == AirStep.LANDED then
					maryo.PlayHeavyLandingSound(Sounds.ACTION_HEAVY_LANDING)
		
					if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
						maryo.ParticleFlags:Add(ParticleFlags.MIST_CIRCLE, ParticleFlags.HORIZONTAL_STAR)
						maryo.SetAction(Action.GROUND_POUND_LAND)
					end
				elseif stepResult == AirStep.HIT_WALL then
					maryo.SetForwardVel(-16)
					stopRising(m)
		
					maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
					maryo.SetAction(Action.BACKWARD_AIR_KB)
				end
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BURNING_JUMP, function(m: Mario)
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			maryo.SetForwardVel(maryo.ForwardVel)
		
			if maryo.PerformAirStep() == AirStep.LANDED then
				maryo.PlayLandingSound()
				maryo.SetAction(Action.BURNING_GROUND)
			end
		
			maryo.SetAnimation(Animations.GENERAL_FALL)
			maryo.ParticleFlags:Add(ParticleFlags.FIRE)
			maryo.PlaySound(Sounds.MOVING_LAVA_BURN)
		
			maryo.BurnTimer += 3
			maryo.Health -= 10
		
			if maryo.Health < 0x100 then
				maryo.Health = 0xFF
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BURNING_FALL, function(m: Mario)
			maryo.SetForwardVel(maryo.ForwardVel)
		
			if maryo.PerformAirStep() == AirStep.LANDED then
				maryo.PlayLandingSound(Sounds.ACTION_TERRAIN_LANDING)
				maryo.SetAction(Action.BURNING_GROUND)
			end
		
			maryo.SetAnimation(Animations.GENERAL_FALL)
			maryo.ParticleFlags:Add(ParticleFlags.FIRE)
		
			maryo.BurnTimer += 3
			maryo.Health -= 10
		
			if maryo.Health < 0x100 then
				maryo.Health = 0xFF
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BACKWARD_AIR_KB, function(m: Mario)
			if checkWallKick(m) then
				return true
			end
		
			playKnockbackSound(m)
			commonAirKnockbackStep(
				m,
				Action.BACKWARD_GROUND_KB,
				Action.HARD_BACKWARD_GROUND_KB,
				Animations.BACKWARD_AIR_KB,
				-16
			)
		
			return false
		end)
		
		DEF_ACTION(Action.FORWARD_AIR_KB, function(m: Mario)
			if checkWallKick(m) then
				return true
			end
		
			playKnockbackSound(m)
			commonAirKnockbackStep(m, Action.FORWARD_GROUND_KB, Action.HARD_FORWARD_GROUND_KB, Animations.FORWARD_AIR_KB, 16)
		
			return false
		end)
		
		DEF_ACTION(Action.HARD_BACKWARD_AIR_KB, function(m: Mario)
			if checkWallKick(m) then
				return true
			end
		
			playKnockbackSound(m)
			commonAirKnockbackStep(
				m,
				Action.HARD_BACKWARD_GROUND_KB,
				Action.HARD_BACKWARD_GROUND_KB,
				Animations.BACKWARD_AIR_KB,
				-16
			)
		
			return false
		end)
		
		DEF_ACTION(Action.HARD_FORWARD_AIR_KB, function(m: Mario)
			if checkWallKick(m) then
				return true
			end
		
			playKnockbackSound(m)
			commonAirKnockbackStep(
				m,
				Action.HARD_FORWARD_GROUND_KB,
				Action.HARD_FORWARD_GROUND_KB,
				Animations.FORWARD_AIR_KB,
				16
			)
		
			return false
		end)
		
		DEF_ACTION(Action.THROWN_BACKWARD, function(m: Mario)
			local landAction = if maryo.ActionArg ~= 0 then Action.HARD_BACKWARD_GROUND_KB else Action.BACKWARD_GROUND_KB
		
			maryo.PlaySoundIfNoFlag(Sounds.MARIO_WAAAOOOW, MarioFlags.MARIO_SOUND_PLAYED)
			commonAirKnockbackStep(m, landAction, Action.HARD_BACKWARD_GROUND_KB, Animations.BACKWARD_AIR_KB, maryo.ForwardVel)
		
			maryo.ForwardVel *= 0.98
			return false
		end)
		
		DEF_ACTION(Action.THROWN_FORWARD, function(m: Mario)
			local landAction = if maryo.ActionArg ~= 0 then Action.HARD_FORWARD_GROUND_KB else Action.FORWARD_GROUND_KB
		
			maryo.PlaySoundIfNoFlag(Sounds.MARIO_WAAAOOOW, MarioFlags.MARIO_SOUND_PLAYED)
		
			if
				commonAirKnockbackStep(m, landAction, Action.HARD_FORWARD_GROUND_KB, Animations.FORWARD_AIR_KB, maryo.ForwardVel)
				== AirStep.NONE
			then
				local pitch = Util.Atan2s(maryo.ForwardVel, -maryo.Velocity.Y)
		
				if pitch > 0x1800 then
					pitch = 0x1800
				end
		
				maryo.GfxAngle = Util.SetX(maryo.GfxAngle, pitch + 0x1800)
			end
		
			maryo.ForwardVel *= 0.98
			return false
		end)
		
		DEF_ACTION(Action.SOFT_BONK, function(m: Mario)
			if checkWallKick(m) then
				return true
			end
		
			playKnockbackSound(m)
			commonAirKnockbackStep(
				m,
				Action.FREEFALL_LAND,
				Action.HARD_BACKWARD_GROUND_KB,
				Animations.GENERAL_FALL,
				maryo.ForwardVel
			)
		
			return false
		end)
		
		DEF_ACTION(Action.AIR_HIT_WALL, function(m: Mario)
			maryo.ActionTimer += 1
		
			if maryo.ActionTimer <= 2 then
				if maryo.Input:Has(InputFlags.A_PRESSED) then
					maryo.Velocity = Util.SetY(maryo.Velocity, 52)
					maryo.FaceAngle += Vector3int16.new(0, 0x8000, 0)
					return maryo.SetAction(Action.WALL_KICK_AIR)
				end
			elseif maryo.ForwardVel >= 38 then
				maryo.WallKickTimer = 5
		
				if maryo.Velocity.Y > 0 then
					maryo.Velocity = Util.SetY(maryo.Velocity, 0)
				end
		
				maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				return maryo.SetAction(Action.BACKWARD_AIR_KB)
			else
				maryo.WallKickTimer = 5
		
				if m.Velocity.Y > 0 then
					maryo.Velocity = Util.SetY(maryo.Velocity, 0)
				end
		
				if maryo.ForwardVel > 8 then
					maryo.SetForwardVel(-8)
				end
		
				return maryo.SetAction(Action.SOFT_BONK)
			end
		
			return maryo.SetAnimation(Animations.START_WALLKICK) > 0
		end)
		
		DEF_ACTION(Action.FORWARD_ROLLOUT, function(m: Mario)
			commonRolloutStep(m, Animations.FORWARD_SPINNING)
			return false
		end)
		
		DEF_ACTION(Action.BACKWARD_ROLLOUT, function(m: Mario)
			commonRolloutStep(m, Animations.BACKWARD_SPINNING)
			return false
		end)
		
		DEF_ACTION(Action.BUTT_SLIDE_AIR, function(m: Mario)
			local stepResult
			maryo.ActionTimer += 1
		
			if maryo.ActionTimer > 30 and maryo.Position.Y - maryo.FloorHeight > 500 then
				return maryo.SetAction(Action.FREEFALL, 1)
			end
		
			updateAirWithTurn(m)
			stepResult = maryo.PerformAirStep()
		
			if stepResult == AirStep.LANDED then
				if maryo.ActionState == 0 and maryo.Velocity.Y < 0 then
					local floor = maryo.Floor
		
					if floor and floor.Normal.Y > 0.9848077 then
						maryo.Velocity *= Vector3.new(1, -0.5, 1)
						maryo.ActionState = 1
					else
						maryo.SetAction(Action.BUTT_SLIDE)
					end
				else
					maryo.SetAction(Action.BUTT_SLIDE)
				end
		
				maryo.PlayLandingSound()
			elseif stepResult == AirStep.HIT_WALL then
				stopRising(m)
				maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				maryo.SetAction(Action.BACKWARD_AIR_KB)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			maryo.SetAnimation(Animations.SLIDE)
			return false
		end)
		
		DEF_ACTION(Action.LAVA_BOOST, function(m: Mario)
			local stepResult
			maryo.PlaySoundIfNoFlag(Sounds.MARIO_ON_FIRE, MarioFlags.MARIO_SOUND_PLAYED)
		
			if not maryo.Input:Has(InputFlags.NONZERO_ANALOG) then
				maryo.ForwardVel = Util.ApproachFloat(maryo.ForwardVel, 0, 0.35)
			end
		
			updateLavaBoostOrTwirling(m)
			stepResult = maryo.PerformAirStep()
		
			if stepResult == AirStep.LANDED then
				local floor = maryo.Floor
				local floorType: Enum.Material?
		
				if floor then
					floorType = floor.Material
				end
		
				if floorType == Enum.Material.CrackedLava then
					maryo.ActionState = 0
		
					if not maryo.Flags:Has(MarioFlags.METAL_CAP) then
						maryo.HurtCounter += if maryo.Flags:Has(MarioFlags.CAP_ON_HEAD) then 12 else 18
					end
		
					maryo.Velocity = Util.SetY(maryo.Velocity, 84)
					maryo.PlaySound(Sounds.MARIO_ON_FIRE)
				else
					maryo.PlayHeavyLandingSound(Sounds.ACTION_TERRAIN_BODY_HIT_GROUND)
		
					if maryo.ActionState < 2 and maryo.Velocity.Y < 0 then
						maryo.Velocity *= Vector3.new(1, -0.4, 1)
						maryo.SetForwardVel(maryo.ForwardVel / 2)
						maryo.ActionState += 1
					else
						maryo.SetAction(Action.LAVA_BOOST_LAND)
					end
				end
			elseif stepResult == AirStep.HIT_WALL then
				maryo.BonkReflection()
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			maryo.SetAnimation(Animations.FIRE_LAVA_BURN)
		
			if not maryo.Flags:Has(MarioFlags.METAL_CAP) and maryo.Velocity.Y > 0 then
				maryo.ParticleFlags:Add(ParticleFlags.FIRE)
		
				if maryo.ActionState == 0 then
					maryo.PlaySound(Sounds.MOVING_LAVA_BURN)
				end
			end
		
			maryo.BodyState.EyeState = MarioEyes.DEAD
			return false
		end)
		
		DEF_ACTION(Action.SLIDE_KICK, function(m: Mario)
			local stepResult
		
			if maryo.ActionState == 0 and maryo.ActionTimer == 0 then
				maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_HOOHOO)
				maryo.SetAnimation(Animations.SLIDE_KICK)
			end
		
			maryo.ActionTimer += 1
		
			if maryo.ActionTimer > 30 and maryo.Position.Y - maryo.FloorHeight > 500 then
				return maryo.SetAction(Action.FREEFALL, 2)
			end
		
			updateAirWithoutTurn(m)
			stepResult = maryo.PerformAirStep()
		
			if stepResult == AirStep.NONE then
				if maryo.ActionState == 0 then
					local tilt = Util.Atan2s(maryo.ForwardVel, -maryo.Velocity.Y)
		
					if tilt > 0x1800 then
						tilt = 0x1800
					end
		
					maryo.GfxAngle = Util.SetX(maryo.GfxAngle, tilt)
				end
			elseif stepResult == AirStep.LANDED then
				if maryo.ActionState == 0 and maryo.Velocity.Y < 0 then
					maryo.Velocity *= Vector3.new(1, -0.5, 1)
					maryo.ActionState = 1
					maryo.ActionTimer = 0
				else
					maryo.SetAction(Action.SLIDE_KICK_SLIDE)
				end
		
				maryo.PlayLandingSound()
			elseif stepResult == AirStep.HIT_WALL then
				stopRising(m)
				maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				maryo.SetAction(Action.BACKWARD_AIR_KB)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.JUMP_KICK, function(m: Mario)
			local stepResult
		
			if maryo.ActionState == 0 then
				maryo.PlaySoundIfNoFlag(Sounds.MARIO_PUNCH_HOO, MarioFlags.MARIO_SOUND_PLAYED)
				maryo.AnimReset = true
		
				maryo.SetAnimation(Animations.AIR_KICK)
				maryo.ActionState = 1
			end
		
			local animFrame = maryo.AnimFrame
		
			if animFrame == 0 then
				maryo.BodyState.PunchType = 2
				maryo.BodyState.PunchTimer = 6
			end
		
			if animFrame >= 0 and animFrame < 8 then
				maryo.Flags:Add(MarioFlags.KICKING)
			end
		
			updateAirWithoutTurn(m)
			stepResult = maryo.PerformAirStep()
		
			if stepResult == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					maryo.SetAction(Action.FREEFALL_LAND)
				end
			elseif stepResult == AirStep.HIT_WALL then
				maryo.SetForwardVel(0)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.FLYING, function(m: Mario)
			local startPitch = maryo.FaceAngle.X
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			if not maryo.Flags:Has(MarioFlags.WING_CAP) then
				return maryo.SetAction(Action.FREEFALL)
			end
		
			if maryo.ActionState == 0 then
				if maryo.ActionArg == 0 then
					maryo.SetAnimation(Animations.FLY_FROM_CANNON)
				else
					maryo.SetAnimation(Animations.FORWARD_SPINNING_FLIP)
		
					if maryo.AnimFrame == 1 then
						maryo.PlaySound(Sounds.ACTION_SPIN)
					end
				end
		
				if maryo.IsAnimAtEnd() then
					maryo.SetAnimation(Animations.WING_CAP_FLY)
					maryo.ActionState = 1
				end
			end
		
			local stepResult
			do
				updateFlying(m)
				stepResult = maryo.PerformAirStep()
			end
		
			if stepResult == AirStep.NONE then
				maryo.GfxAngle = Util.SetX(maryo.GfxAngle, -maryo.FaceAngle.X)
				maryo.GfxAngle = Util.SetZ(maryo.GfxAngle, maryo.FaceAngle.Z)
				maryo.ActionTimer = 0
			elseif stepResult == AirStep.LANDED then
				maryo.SetAction(Action.DIVE_SLIDE)
				maryo.SetAnimation(Animations.DIVE)
		
				maryo.SetAnimToFrame(7)
				maryo.FaceAngle *= Vector3int16.new(0, 1, 1)
			elseif stepResult == AirStep.HIT_WALL then
				if maryo.Wall then
					maryo.SetForwardVel(-16)
					maryo.FaceAngle *= Vector3int16.new(0, 1, 1)
		
					stopRising(m)
					maryo.PlaySound(if maryo.Flags:Has(MarioFlags.METAL_CAP) then Sounds.ACTION_METAL_BONK else Sounds.ACTION_BONK)
		
					maryo.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
					maryo.SetAction(Action.BACKWARD_AIR_KB)
				else
					maryo.ActionTimer += 1
		
					if maryo.ActionTimer == 0 then
						maryo.PlaySound(Sounds.ACTION_HIT)
					end
		
					if maryo.ActionTimer == 30 then
						maryo.ActionTimer = 0
					end
		
					maryo.FaceAngle -= Vector3int16.new(0x200, 0, 0)
		
					if maryo.FaceAngle.X < -0x2AAA then
						maryo.FaceAngle = Util.SetX(maryo.FaceAngle, -0x2AAA)
					end
		
					maryo.GfxAngle = Util.SetX(maryo.GfxAngle, -maryo.FaceAngle.X)
					maryo.GfxAngle = Util.SetZ(maryo.GfxAngle, maryo.FaceAngle.Z)
				end
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			if maryo.FaceAngle.X > 0x800 and maryo.ForwardVel >= 48 then
				maryo.ParticleFlags:Add(ParticleFlags.DUST)
			end
		
			if startPitch <= 0 and maryo.FaceAngle.X > 0 and maryo.ForwardVel >= 48 then
				maryo.PlaySound(Sounds.ACTION_FLYING_FAST)
				maryo.PlaySound(Sounds.MARIO_YAHOO_WAHA_YIPPEE)
			end
		
			maryo.PlaySound(Sounds.MOVING_FLYING)
			maryo.AdjustSoundForSpeed()
		
			return false
		end)
		
		DEF_ACTION(Action.FLYING_TRIPLE_JUMP, function(m: Mario)
			if maryo.Input:Has(InputFlags.B_PRESSED) then
				return maryo.SetAction(Action.DIVE)
			end
		
			if maryo.Input:Has(InputFlags.Z_PRESSED) then
				return maryo.SetAction(Action.GROUND_POUND)
			end
		
			maryo.PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_YAHOO)
		
			if maryo.ActionState == 0 then
				maryo.SetAnimation(Animations.TRIPLE_JUMP_FLY)
		
				if maryo.AnimFrame == 7 then
					maryo.PlaySound(Sounds.ACTION_SPIN)
				end
		
				if maryo.IsAnimPastEnd() then
					maryo.SetAnimation(Animations.FORWARD_SPINNING)
					maryo.ActionState = 1
				end
			end
		
			if maryo.ActionState == 1 and maryo.AnimFrame == 1 then
				maryo.PlaySound(Sounds.ACTION_SPIN)
			end
		
			if maryo.Velocity.Y < 4 then
				if maryo.ForwardVel < 32 then
					maryo.SetForwardVel(32)
				end
		
				maryo.SetAction(Action.FLYING, 1)
			end
		
			maryo.ActionTimer += 1
		
			local stepResult
			do
				updateAirWithoutTurn(m)
				stepResult = maryo.PerformAirStep()
			end
		
			if stepResult == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					maryo.SetAction(Action.DOUBLE_JUMP_LAND)
				end
			elseif stepResult == AirStep.HIT_WALL then
				maryo.BonkReflection()
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.SPAWN_SPIN_AIRBORNE, function(m: Mario)
			maryo.SetForwardVel(maryo.ForwardVel)
		
			if maryo.PerformAirStep() == AirStep.LANDED then
				maryo.PlayLandingSound(Sounds.ACTION_TERRAIN_LANDING)
				maryo.SetAction(Action.SPAWN_SPIN_LANDING)
			end
		
			if maryo.ActionState == 0 and maryo.Position.Y - maryo.FloorHeight > 300 then
				if maryo.SetAnimation(Animations.FORWARD_SPINNING) == 0 then
					maryo.PlaySound(Sounds.ACTION_SPIN)
				end
			else
				maryo.ActionState = 1
				maryo.SetAnimation(Animations.GENERAL_FALL)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.SPAWN_SPIN_LANDING, function(m: Mario)
			maryo.StopAndSetHeightToFloor()
			maryo.SetAnimation(Animations.GENERAL_LAND)
			if maryo.IsAnimAtEnd() then
				maryo.SetAction(Action.IDLE)
			end
			return false
		end)
	end

	function maryo.Reset(spawn)
		maryo.Controller = {
			A = false,
			B = false,
			Z = false,
			-- in world coords btw
			StickX = 0,
			StickZ = 0,
		}
		maryo._ButtonStates = {
			A = false,
			B = false,
			Z = false,
		}
		
		maryo.Flags = {
			NORMAL_CAP = true,
			CAP_ON_HEAD = true,
		}
		maryo.Input = {}
		maryo.Sounds = {}
		maryo.Events = {
			STOMPED = false,
		}
		
		maryo.Action = nil
		maryo.ActionArg = 0
		maryo.ActionState = 0
		maryo.ActionTimer = 0
		maryo.PrevAction = nil
		
		maryo.Health = 8
		maryo.HealthAdd = 0
		maryo.HealthSub = 0
		
		maryo.SlideYaw = 0
		maryo.TwirlYaw = 0
		
		maryo.Position = spawn or Vector3.new(0, 100, 0)
		maryo.Velocity = Vector3.zero
		
		maryo.ForwardVel = 0
		maryo.SlideVelX = 0
		maryo.SlideVelZ = 0
		
		maryo.FaceAngle = Vector3.zero
		maryo.AngleVel = Vector3.zero
		
		maryo.CeilHeight = maryo.Position.Y + 32
		maryo.Floor = nil
		maryo.FloorHeight = maryo.Position.Y - 32
		maryo.FloorAngle = 0
		maryo.WaterLevel = -10000
		
		maryo.IntendedMag = 0
		maryo.IntendedYaw = 0
		maryo.InvincTimer = 0
		
		maryo.FramesSinceA = 255
		maryo.FramesSinceB = 255
		
		maryo.WallKickTimer = 0
		maryo.DoubleJumpTimer = 0
		
		maryo.CapTimer = 0
		maryo.BurnTimer = 0
		maryo.PeakHeight = 0
		maryo.SteepJumpYaw = 0
		maryo.WalkingPitch = 0
		maryo.QuicksandDepth = 0
		maryo.LongJumpIsSlow = false
		
		maryo.AnimCurrent = nil
		maryo.AnimAccel = 0
		maryo.AnimFrame = -1
		maryo.AnimSetFrame = -1
		maryo.AnimDirty = false
		maryo.AnimReset = false
		maryo.AnimFrameCount = 0
		maryo.AnimAccelAssist = 0
		maryo.AnimSkipInterp = 0
		
		maryo.AutoJump = false
		maryo.InfiniteJump = false
		
		maryo.SetAction("SPAWN_SPIN_AIRBORNE")
	end
	maryo.Reset()

	m.Init = function(figure: Model)
		local root = figure:FindFirstChild("HumanoidRootPart")
		maryo.Reset(root and root.Position or nil)
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock()
		if m.ModeCap == 1 then
			maryo.Flags.NORMAL_CAP = false
			maryo.Flags.WING_CAP = false
			maryo.Flags.METAL_CAP = false
			maryo.Flags.VANISH_CAP = false
			maryo.Flags.CAP_ON_HEAD = false
		end
		if m.ModeCap == 2 then
			maryo.Flags.NORMAL_CAP = true
			maryo.Flags.WING_CAP = false
			maryo.Flags.METAL_CAP = false
			maryo.Flags.VANISH_CAP = false
			maryo.Flags.CAP_ON_HEAD = true
		end
		if m.ModeCap == 3 then
			maryo.Flags.NORMAL_CAP = false
			maryo.Flags.WING_CAP = true
			maryo.Flags.METAL_CAP = false
			maryo.Flags.VANISH_CAP = false
			maryo.Flags.CAP_ON_HEAD = true
		end
		if m.ModeCap == 4 then
			maryo.Flags.NORMAL_CAP = false
			maryo.Flags.WING_CAP = false
			maryo.Flags.METAL_CAP = true
			maryo.Flags.VANISH_CAP = false
			maryo.Flags.CAP_ON_HEAD = true
		end
		if m.ModeCap == 5 then
			maryo.Flags.NORMAL_CAP = false
			maryo.Flags.WING_CAP = false
			maryo.Flags.METAL_CAP = false
			maryo.Flags.VANISH_CAP = true
			maryo.Flags.CAP_ON_HEAD = true
		end
	end
	m.Destroy = function(figure: Model?)
	end
	return m
end)

return modules