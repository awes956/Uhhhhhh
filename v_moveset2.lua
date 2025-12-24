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
	end
	m.SaveConfig = function()
		return {
			FPS30 = m.FPS30,
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
		IDLE = 0x0C400201, -- (0x001 | FLAG_STATIONARY | FLAG_IDLE | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		START_SLEEPING = 0x0C400202, -- (0x002 | FLAG_STATIONARY | FLAG_IDLE | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		SLEEPING = 0x0C000203, -- (0x003 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		WAKING_UP = 0x0C000204, -- (0x004 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		PANTING = 0x0C400205, -- (0x005 | FLAG_STATIONARY | FLAG_IDLE | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		HOLD_PANTING_UNUSED = 0x08000206, -- (0x006 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		HOLD_IDLE = 0x08000207, -- (0x007 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		HOLD_HEAVY_IDLE = 0x08000208, -- (0x008 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		STANDING_AGAINST_WALL = 0x0C400209, -- (0x009 | FLAG_STATIONARY | FLAG_IDLE | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		COUGHING = 0x0C40020A, -- (0x00A | FLAG_STATIONARY | FLAG_IDLE | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		SHIVERING = 0x0C40020B, -- (0x00B | FLAG_STATIONARY | FLAG_IDLE | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		IN_QUICKSAND = 0x0002020D, -- (0x00D | FLAG_STATIONARY | FLAG_INVULNERABLE)
		UNKNOWN_0002020E = 0x0002020E, -- (0x00E | FLAG_STATIONARY | FLAG_INVULNERABLE)
		CROUCHING = 0x0C008220, -- (0x020 | FLAG_STATIONARY | FLAG_SHORT_HITBOX | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		START_CROUCHING = 0x0C008221, -- (0x021 | FLAG_STATIONARY | FLAG_SHORT_HITBOX | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		STOP_CROUCHING = 0x0C008222, -- (0x022 | FLAG_STATIONARY | FLAG_SHORT_HITBOX | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		START_CRAWLING = 0x0C008223, -- (0x023 | FLAG_STATIONARY | FLAG_SHORT_HITBOX | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		STOP_CRAWLING = 0x0C008224, -- (0x024 | FLAG_STATIONARY | FLAG_SHORT_HITBOX | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		SLIDE_KICK_SLIDE_STOP = 0x08000225, -- (0x025 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		SHOCKWAVE_BOUNCE = 0x00020226, -- (0x026 | FLAG_STATIONARY | FLAG_INVULNERABLE)
		FIRST_PERSON = 0x0C000227, -- (0x027 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		BACKFLIP_LAND_STOP = 0x0800022F, -- (0x02F | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		JUMP_LAND_STOP = 0x0C000230, -- (0x030 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		DOUBLE_JUMP_LAND_STOP = 0x0C000231, -- (0x031 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		FREEFALL_LAND_STOP = 0x0C000232, -- (0x032 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		SIDE_FLIP_LAND_STOP = 0x0C000233, -- (0x033 | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		HOLD_JUMP_LAND_STOP = 0x08000234, -- (0x034 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		HOLD_FREEFALL_LAND_STOP = 0x08000235, -- (0x035 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		AIR_THROW_LAND = 0x80000A36, -- (0x036 | FLAG_STATIONARY | FLAG_AIR | FLAG_THROWING)
		TWIRL_LAND = 0x18800238, -- (0x038 | FLAG_STATIONARY | FLAG_ATTACKING | FLAG_PAUSE_EXIT | FLAG_SWIMMING_OR_FLYING)
		LAVA_BOOST_LAND = 0x08000239, -- (0x039 | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		TRIPLE_JUMP_LAND_STOP = 0x0800023A, -- (0x03A | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		LONG_JUMP_LAND_STOP = 0x0800023B, -- (0x03B | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		GROUND_POUND_LAND = 0x0080023C, -- (0x03C | FLAG_STATIONARY | FLAG_ATTACKING)
		BRAKING_STOP = 0x0C00023D, -- (0x03D | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		BUTT_SLIDE_STOP = 0x0C00023E, -- (0x03E | FLAG_STATIONARY | FLAG_ALLOW_FIRST_PERSON | FLAG_PAUSE_EXIT)
		HOLD_BUTT_SLIDE_STOP = 0x0800043F, -- (0x03F | FLAG_MOVING | FLAG_PAUSE_EXIT)

		-- group 0x040: moving (ground) actions
		WALKING = 0x04000440, -- (0x040 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		HOLD_WALKING = 0x00000442, -- (0x042 | FLAG_MOVING)
		TURNING_AROUND = 0x00000443, -- (0x043 | FLAG_MOVING)
		FINISH_TURNING_AROUND = 0x00000444, -- (0x044 | FLAG_MOVING)
		BRAKING = 0x04000445, -- (0x045 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		RIDING_SHELL_GROUND = 0x20810446, -- (0x046 | FLAG_MOVING | FLAG_RIDING_SHELL | FLAG_ATTACKING | FLAG_WATER_OR_TEXT)
		HOLD_HEAVY_WALKING = 0x00000447, -- (0x047 | FLAG_MOVING)
		CRAWLING = 0x04008448, -- (0x048 | FLAG_MOVING | FLAG_SHORT_HITBOX | FLAG_ALLOW_FIRST_PERSON)
		BURNING_GROUND = 0x00020449, -- (0x049 | FLAG_MOVING | FLAG_INVULNERABLE)
		DECELERATING = 0x0400044A, -- (0x04A | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		HOLD_DECELERATING = 0x0000044B, -- (0x04B | FLAG_MOVING)
		BEGIN_SLIDING = 0x00000050, -- (0x050)
		HOLD_BEGIN_SLIDING = 0x00000051, -- (0x051)
		BUTT_SLIDE = 0x00840452, -- (0x052 | FLAG_MOVING | FLAG_BUTT_OR_STOMACH_SLIDE | FLAG_ATTACKING)
		STOMACH_SLIDE = 0x008C0453, -- (0x053 | FLAG_MOVING | FLAG_BUTT_OR_STOMACH_SLIDE | FLAG_DIVING | FLAG_ATTACKING)
		HOLD_BUTT_SLIDE = 0x00840454, -- (0x054 | FLAG_MOVING | FLAG_BUTT_OR_STOMACH_SLIDE | FLAG_ATTACKING)
		HOLD_STOMACH_SLIDE = 0x008C0455, -- (0x055 | FLAG_MOVING | FLAG_BUTT_OR_STOMACH_SLIDE | FLAG_DIVING | FLAG_ATTACKING)
		DIVE_SLIDE = 0x00880456, -- (0x056 | FLAG_MOVING | FLAG_DIVING | FLAG_ATTACKING)
		MOVE_PUNCHING = 0x00800457, -- (0x057 | FLAG_MOVING | FLAG_ATTACKING)
		CROUCH_SLIDE = 0x04808459, -- (0x059 | FLAG_MOVING | FLAG_SHORT_HITBOX | FLAG_ATTACKING | FLAG_ALLOW_FIRST_PERSON)
		SLIDE_KICK_SLIDE = 0x0080045A, -- (0x05A | FLAG_MOVING | FLAG_ATTACKING)
		HARD_BACKWARD_GROUND_KB = 0x00020460, -- (0x060 | FLAG_MOVING | FLAG_INVULNERABLE)
		HARD_FORWARD_GROUND_KB = 0x00020461, -- (0x061 | FLAG_MOVING | FLAG_INVULNERABLE)
		BACKWARD_GROUND_KB = 0x00020462, -- (0x062 | FLAG_MOVING | FLAG_INVULNERABLE)
		FORWARD_GROUND_KB = 0x00020463, -- (0x063 | FLAG_MOVING | FLAG_INVULNERABLE)
		SOFT_BACKWARD_GROUND_KB = 0x00020464, -- (0x064 | FLAG_MOVING | FLAG_INVULNERABLE)
		SOFT_FORWARD_GROUND_KB = 0x00020465, -- (0x065 | FLAG_MOVING | FLAG_INVULNERABLE)
		GROUND_BONK = 0x00020466, -- (0x066 | FLAG_MOVING | FLAG_INVULNERABLE)
		DEATH_EXIT_LAND = 0x00020467, -- (0x067 | FLAG_MOVING | FLAG_INVULNERABLE)
		JUMP_LAND = 0x04000470, -- (0x070 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		FREEFALL_LAND = 0x04000471, -- (0x071 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		DOUBLE_JUMP_LAND = 0x04000472, -- (0x072 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		SIDE_FLIP_LAND = 0x04000473, -- (0x073 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		HOLD_JUMP_LAND = 0x00000474, -- (0x074 | FLAG_MOVING)
		HOLD_FREEFALL_LAND = 0x00000475, -- (0x075 | FLAG_MOVING)
		QUICKSAND_JUMP_LAND = 0x00000476, -- (0x076 | FLAG_MOVING)
		HOLD_QUICKSAND_JUMP_LAND = 0x00000477, -- (0x077 | FLAG_MOVING)
		TRIPLE_JUMP_LAND = 0x04000478, -- (0x078 | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)
		LONG_JUMP_LAND = 0x00000479, -- (0x079 | FLAG_MOVING)
		BACKFLIP_LAND = 0x0400047A, -- (0x07A | FLAG_MOVING | FLAG_ALLOW_FIRST_PERSON)

		-- group 0x080: airborne actions
		JUMP = 0x03000880, -- (0x080 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		DOUBLE_JUMP = 0x03000881, -- (0x081 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		TRIPLE_JUMP = 0x01000882, -- (0x082 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		BACKFLIP = 0x01000883, -- (0x083 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		STEEP_JUMP = 0x03000885, -- (0x085 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		WALL_KICK_AIR = 0x03000886, -- (0x086 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		SIDE_FLIP = 0x01000887, -- (0x087 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		LONG_JUMP = 0x03000888, -- (0x088 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		WATER_JUMP = 0x01000889, -- (0x089 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		DIVE = 0x0188088A, -- (0x08A | FLAG_AIR | FLAG_DIVING | FLAG_ATTACKING | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		FREEFALL = 0x0100088C, -- (0x08C | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		TOP_OF_POLE_JUMP = 0x0300088D, -- (0x08D | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		BUTT_SLIDE_AIR = 0x0300088E, -- (0x08E | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		FLYING_TRIPLE_JUMP = 0x03000894, -- (0x094 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		SHOT_FROM_CANNON = 0x00880898, -- (0x098 | FLAG_AIR | FLAG_DIVING | FLAG_ATTACKING)
		FLYING = 0x10880899, -- (0x099 | FLAG_AIR | FLAG_DIVING | FLAG_ATTACKING | FLAG_SWIMMING_OR_FLYING)
		RIDING_SHELL_JUMP = 0x0281089A, -- (0x09A | FLAG_AIR | FLAG_RIDING_SHELL | FLAG_ATTACKING | FLAG_CONTROL_JUMP_HEIGHT)
		RIDING_SHELL_FALL = 0x0081089B, -- (0x09B | FLAG_AIR | FLAG_RIDING_SHELL | FLAG_ATTACKING)
		VERTICAL_WIND = 0x1008089C, -- (0x09C | FLAG_AIR | FLAG_DIVING | FLAG_SWIMMING_OR_FLYING)
		HOLD_JUMP = 0x030008A0, -- (0x0A0 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		HOLD_FREEFALL = 0x010008A1, -- (0x0A1 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		HOLD_BUTT_SLIDE_AIR = 0x010008A2, -- (0x0A2 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		HOLD_WATER_JUMP = 0x010008A3, -- (0x0A3 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		TWIRLING = 0x108008A4, -- (0x0A4 | FLAG_AIR | FLAG_ATTACKING | FLAG_SWIMMING_OR_FLYING)
		FORWARD_ROLLOUT = 0x010008A6, -- (0x0A6 | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		AIR_HIT_WALL = 0x000008A7, -- (0x0A7 | FLAG_AIR)
		RIDING_HOOT = 0x000004A8, -- (0x0A8 | FLAG_MOVING)
		GROUND_POUND = 0x008008A9, -- (0x0A9 | FLAG_AIR | FLAG_ATTACKING)
		SLIDE_KICK = 0x018008AA, -- (0x0AA | FLAG_AIR | FLAG_ATTACKING | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		AIR_THROW = 0x830008AB, -- (0x0AB | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT | FLAG_THROWING)
		JUMP_KICK = 0x018008AC, -- (0x0AC | FLAG_AIR | FLAG_ATTACKING | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		BACKWARD_ROLLOUT = 0x010008AD, -- (0x0AD | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		CRAZY_BOX_BOUNCE = 0x000008AE, -- (0x0AE | FLAG_AIR)
		SPECIAL_TRIPLE_JUMP = 0x030008AF, -- (0x0AF | FLAG_AIR | FLAG_ALLOW_VERTICAL_WIND_ACTION | FLAG_CONTROL_JUMP_HEIGHT)
		BACKWARD_AIR_KB = 0x010208B0, -- (0x0B0 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		FORWARD_AIR_KB = 0x010208B1, -- (0x0B1 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		HARD_FORWARD_AIR_KB = 0x010208B2, -- (0x0B2 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		HARD_BACKWARD_AIR_KB = 0x010208B3, -- (0x0B3 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		BURNING_JUMP = 0x010208B4, -- (0x0B4 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		BURNING_FALL = 0x010208B5, -- (0x0B5 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		SOFT_BONK = 0x010208B6, -- (0x0B6 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		LAVA_BOOST = 0x010208B7, -- (0x0B7 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		GETTING_BLOWN = 0x010208B8, -- (0x0B8 | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		THROWN_FORWARD = 0x010208BD, -- (0x0BD | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)
		THROWN_BACKWARD = 0x010208BE, -- (0x0BE | FLAG_AIR | FLAG_INVULNERABLE | FLAG_ALLOW_VERTICAL_WIND_ACTION)

		-- group 0x0C0: submerged actions
		WATER_IDLE = 0x380022C0, -- (0x0C0 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_PAUSE_EXIT | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		HOLD_WATER_IDLE = 0x380022C1, -- (0x0C1 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_PAUSE_EXIT | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_ACTION_END = 0x300022C2, -- (0x0C2 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		HOLD_WATER_ACTION_END = 0x300022C3, -- (0x0C3 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		DROWNING = 0x300032C4, -- (0x0C4 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		BACKWARD_WATER_KB = 0x300222C5, -- (0x0C5 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_INVULNERABLE | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		FORWARD_WATER_KB = 0x300222C6, -- (0x0C6 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_INVULNERABLE | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_DEATH = 0x300032C7, -- (0x0C7 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_SHOCKED = 0x300222C8, -- (0x0C8 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_INVULNERABLE | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		BREASTSTROKE = 0x300024D0, -- (0x0D0 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		SWIMMING_END = 0x300024D1, -- (0x0D1 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		FLUTTER_KICK = 0x300024D2, -- (0x0D2 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		HOLD_BREASTSTROKE = 0x300024D3, -- (0x0D3 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		HOLD_SWIMMING_END = 0x300024D4, -- (0x0D4 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		HOLD_FLUTTER_KICK = 0x300024D5, -- (0x0D5 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_SHELL_SWIMMING = 0x300024D6, -- (0x0D6 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_THROW = 0x300024E0, -- (0x0E0 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_PUNCH = 0x300024E1, -- (0x0E1 | FLAG_MOVING | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		WATER_PLUNGE = 0x300022E2, -- (0x0E2 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		CAUGHT_IN_WHIRLPOOL = 0x300222E3, -- (0x0E3 | FLAG_STATIONARY | FLAG_SWIMMING | FLAG_INVULNERABLE | FLAG_SWIMMING_OR_FLYING | FLAG_WATER_OR_TEXT)
		METAL_WATER_STANDING = 0x080042F0, -- (0x0F0 | FLAG_STATIONARY | FLAG_METAL_WATER | FLAG_PAUSE_EXIT)
		HOLD_METAL_WATER_STANDING = 0x080042F1, -- (0x0F1 | FLAG_STATIONARY | FLAG_METAL_WATER | FLAG_PAUSE_EXIT)
		METAL_WATER_WALKING = 0x000044F2, -- (0x0F2 | FLAG_MOVING | FLAG_METAL_WATER)
		HOLD_METAL_WATER_WALKING = 0x000044F3, -- (0x0F3 | FLAG_MOVING | FLAG_METAL_WATER)
		METAL_WATER_FALLING = 0x000042F4, -- (0x0F4 | FLAG_STATIONARY | FLAG_METAL_WATER)
		HOLD_METAL_WATER_FALLING = 0x000042F5, -- (0x0F5 | FLAG_STATIONARY | FLAG_METAL_WATER)
		METAL_WATER_FALL_LAND = 0x000042F6, -- (0x0F6 | FLAG_STATIONARY | FLAG_METAL_WATER)
		HOLD_METAL_WATER_FALL_LAND = 0x000042F7, -- (0x0F7 | FLAG_STATIONARY | FLAG_METAL_WATER)
		METAL_WATER_JUMP = 0x000044F8, -- (0x0F8 | FLAG_MOVING | FLAG_METAL_WATER)
		HOLD_METAL_WATER_JUMP = 0x000044F9, -- (0x0F9 | FLAG_MOVING | FLAG_METAL_WATER)
		METAL_WATER_JUMP_LAND = 0x000044FA, -- (0x0FA | FLAG_MOVING | FLAG_METAL_WATER)
		HOLD_METAL_WATER_JUMP_LAND = 0x000044FB, -- (0x0FB | FLAG_MOVING | FLAG_METAL_WATER)

		-- group 0x100: cutscene actions
		DISAPPEARED = 0x00001300, -- (0x100 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		INTRO_CUTSCENE = 0x04001301, -- (0x101 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_ALLOW_FIRST_PERSON)
		STAR_DANCE_EXIT = 0x00001302, -- (0x102 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		STAR_DANCE_WATER = 0x00001303, -- (0x103 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		FALL_AFTER_STAR_GRAB = 0x00001904, -- (0x104 | FLAG_AIR | FLAG_INTANGIBLE)
		READING_AUTOMATIC_DIALOG = 0x20001305, -- (0x105 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_WATER_OR_TEXT)
		READING_NPC_DIALOG = 0x20001306, -- (0x106 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_WATER_OR_TEXT)
		STAR_DANCE_NO_EXIT = 0x00001307, -- (0x107 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		READING_SIGN = 0x00001308, -- (0x108 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		JUMBO_STAR_CUTSCENE = 0x00001909, -- (0x109 | FLAG_AIR | FLAG_INTANGIBLE)
		WAITING_FOR_DIALOG = 0x0000130A, -- (0x10A | FLAG_STATIONARY | FLAG_INTANGIBLE)
		DEBUG_FREE_MOVE = 0x0000130F, -- (0x10F | FLAG_STATIONARY | FLAG_INTANGIBLE)
		STANDING_DEATH = 0x00021311, -- (0x111 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		QUICKSAND_DEATH = 0x00021312, -- (0x112 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		ELECTROCUTION = 0x00021313, -- (0x113 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		SUFFOCATION = 0x00021314, -- (0x114 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		DEATH_ON_STOMACH = 0x00021315, -- (0x115 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		DEATH_ON_BACK = 0x00021316, -- (0x116 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		EATEN_BY_BUBBA = 0x00021317, -- (0x117 | FLAG_STATIONARY | FLAG_INTANGIBLE | FLAG_INVULNERABLE)
		END_PEACH_CUTSCENE = 0x00001918, -- (0x118 | FLAG_AIR | FLAG_INTANGIBLE)
		CREDITS_CUTSCENE = 0x00001319, -- (0x119 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		END_WAVING_CUTSCENE = 0x0000131A, -- (0x11A | FLAG_STATIONARY | FLAG_INTANGIBLE)
		PULLING_DOOR = 0x00001320, -- (0x120 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		PUSHING_DOOR = 0x00001321, -- (0x121 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		WARP_DOOR_SPAWN = 0x00001322, -- (0x122 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		EMERGE_FROM_PIPE = 0x00001923, -- (0x123 | FLAG_AIR | FLAG_INTANGIBLE)
		SPAWN_SPIN_AIRBORNE = 0x00001924, -- (0x124 | FLAG_AIR | FLAG_INTANGIBLE)
		SPAWN_SPIN_LANDING = 0x00001325, -- (0x125 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		EXIT_AIRBORNE = 0x00001926, -- (0x126 | FLAG_AIR | FLAG_INTANGIBLE)
		EXIT_LAND_SAVE_DIALOG = 0x00001327, -- (0x127 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		DEATH_EXIT = 0x00001928, -- (0x128 | FLAG_AIR | FLAG_INTANGIBLE)
		UNUSED_DEATH_EXIT = 0x00001929, -- (0x129 | FLAG_AIR | FLAG_INTANGIBLE)
		FALLING_DEATH_EXIT = 0x0000192A, -- (0x12A | FLAG_AIR | FLAG_INTANGIBLE)
		SPECIAL_EXIT_AIRBORNE = 0x0000192B, -- (0x12B | FLAG_AIR | FLAG_INTANGIBLE)
		SPECIAL_DEATH_EXIT = 0x0000192C, -- (0x12C | FLAG_AIR | FLAG_INTANGIBLE)
		FALLING_EXIT_AIRBORNE = 0x0000192D, -- (0x12D | FLAG_AIR | FLAG_INTANGIBLE)
		UNLOCKING_KEY_DOOR = 0x0000132E, -- (0x12E | FLAG_STATIONARY | FLAG_INTANGIBLE)
		UNLOCKING_STAR_DOOR = 0x0000132F, -- (0x12F | FLAG_STATIONARY | FLAG_INTANGIBLE)
		ENTERING_STAR_DOOR = 0x00001331, -- (0x131 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		SPAWN_NO_SPIN_AIRBORNE = 0x00001932, -- (0x132 | FLAG_AIR | FLAG_INTANGIBLE)
		SPAWN_NO_SPIN_LANDING = 0x00001333, -- (0x133 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		BBH_ENTER_JUMP = 0x00001934, -- (0x134 | FLAG_AIR | FLAG_INTANGIBLE)
		BBH_ENTER_SPIN = 0x00001535, -- (0x135 | FLAG_MOVING | FLAG_INTANGIBLE)
		TELEPORT_FADE_OUT = 0x00001336, -- (0x136 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		TELEPORT_FADE_IN = 0x00001337, -- (0x137 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		SHOCKED = 0x00020338, -- (0x138 | FLAG_STATIONARY | FLAG_INVULNERABLE)
		SQUISHED = 0x00020339, -- (0x139 | FLAG_STATIONARY | FLAG_INVULNERABLE)
		HEAD_STUCK_IN_GROUND = 0x0002033A, -- (0x13A | FLAG_STATIONARY | FLAG_INVULNERABLE)
		BUTT_STUCK_IN_GROUND = 0x0002033B, -- (0x13B | FLAG_STATIONARY | FLAG_INVULNERABLE)
		FEET_STUCK_IN_GROUND = 0x0002033C, -- (0x13C | FLAG_STATIONARY | FLAG_INVULNERABLE)
		PUTTING_ON_CAP = 0x0000133D, -- (0x13D | FLAG_STATIONARY | FLAG_INTANGIBLE)

		-- group 0x140: "automatic" actions
		HOLDING_POLE = 0x08100340, -- (0x140 | FLAG_STATIONARY | FLAG_ON_POLE | FLAG_PAUSE_EXIT)
		GRAB_POLE_SLOW = 0x00100341, -- (0x141 | FLAG_STATIONARY | FLAG_ON_POLE)
		GRAB_POLE_FAST = 0x00100342, -- (0x142 | FLAG_STATIONARY | FLAG_ON_POLE)
		CLIMBING_POLE = 0x00100343, -- (0x143 | FLAG_STATIONARY | FLAG_ON_POLE)
		TOP_OF_POLE_TRANSITION = 0x00100344, -- (0x144 | FLAG_STATIONARY | FLAG_ON_POLE)
		TOP_OF_POLE = 0x00100345, -- (0x145 | FLAG_STATIONARY | FLAG_ON_POLE)
		START_HANGING = 0x08200348, -- (0x148 | FLAG_STATIONARY | FLAG_HANGING | FLAG_PAUSE_EXIT)
		HANGING = 0x00200349, -- (0x149 | FLAG_STATIONARY | FLAG_HANGING)
		HANG_MOVING = 0x0020054A, -- (0x14A | FLAG_MOVING | FLAG_HANGING)
		LEDGE_GRAB = 0x0800034B, -- (0x14B | FLAG_STATIONARY | FLAG_PAUSE_EXIT)
		LEDGE_CLIMB_SLOW = 0x0000054C, -- (0x14C | FLAG_MOVING)
		LEDGE_CLIMB_DOWN = 0x0000054D, -- (0x14D | FLAG_MOVING)
		LEDGE_CLIMB_FAST = 0x0000054E, -- (0x14E | FLAG_MOVING)
		GRABBED = 0x00020370, -- (0x170 | FLAG_STATIONARY | FLAG_INVULNERABLE)
		IN_CANNON = 0x00001371, -- (0x171 | FLAG_STATIONARY | FLAG_INTANGIBLE)
		TORNADO_TWIRLING = 0x10020372, -- (0x172 | FLAG_STATIONARY | FLAG_INVULNERABLE | FLAG_SWIMMING_OR_FLYING)

		-- group 0x180: object actions
		PUNCHING = 0x00800380, -- (0x180 | FLAG_STATIONARY | FLAG_ATTACKING)
		PICKING_UP = 0x00000383, -- (0x183 | FLAG_STATIONARY)
		DIVE_PICKING_UP = 0x00000385, -- (0x185 | FLAG_STATIONARY)
		STOMACH_SLIDE_STOP = 0x00000386, -- (0x186 | FLAG_STATIONARY)
		PLACING_DOWN = 0x00000387, -- (0x187 | FLAG_STATIONARY)
		THROWING = 0x80000588, -- (0x188 | FLAG_MOVING | FLAG_THROWING)
		HEAVY_THROW = 0x80000589, -- (0x189 | FLAG_MOVING | FLAG_THROWING)
		PICKING_UP_BOWSER = 0x00000390, -- (0x190 | FLAG_STATIONARY)
		HOLDING_BOWSER = 0x00000391, -- (0x191 | FLAG_STATIONARY)
		RELEASING_BOWSER = 0x00000392, -- (0x192 | FLAG_STATIONARY)
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
		m.AnimFrameCount = data.C
		m.AnimCurrent = data
		m.AnimAccelAssist = 0
		m.AnimAccel = 0
		m.AnimReset = true
		m.AnimDirty = true
		m.AnimFrame = data.F
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
	function maryo.PlayLandingSound()
		if maryo.Flags.METAL_CAP then
			maryo.PlayMaterialSound("ACTION_METAL_LANDING")
		end
		maryo.PlayMaterialSound("ACTION_TERRAIN_LANDING")
	end
	function maryo.PlayLandingSoundOnce()
		maryo.PlayActionSound(maryo.Flags.METAL_CAP and "ACTION_METAL_LANDING" or "ACTION_TERRAIN_LANDING")
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
		elseif action.NAME == "WATER_JUMP" or action == "HOLD_WATER_JUMP" then
			if arg == 0 then
				maryo.SetYVelBasedOnFSpeed(42, 0)
			end
		elseif action.NAME == "BURNING_JUMP" then
			maryo.SetUpwardVel(31.5)
			maryo.ForwardVel = 8
		elseif action.NAME == "RIDING_SHELL_JUMP" then
			maryo.SetYVelBasedOnFSpeed(42, 0.25)
		elseif action.NAME == "JUMP" or action == "HOLD_JUMP" then
			maryo.AnimReset = true
			maryo.SetYVelBasedOnFSpeed(42, 0.25)
			maryo.ForwardVel *= 0.8
		elseif action.NAME == "WALL_KICK_AIR" or action == "TOP_OF_POLE_JUMP" then
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
			maryo.LongJumpIsSlow = m.ForwardVel <= 16
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
	end
	function maryo.SetJumpingAction(action, arg)
		if maryo.FloorIsSteep() then
			maryo.SetSteepJumpAction()
		else
			maryo.SetAction(action, arg)
		end
	end
	function maryo.DamageAndSetAction(action, arg, damage)
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
			maryo.ActionArg = m:IsAnimPastEnd() and 5 or 4
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
				m.Flags.KICKING = true
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
		local lowerPos, _ = maryo.FindWallCollisions(nextPos, 30, 24)
		nextPos = lowerPos
		local upperPos, upperWall = maryo.FindWallCollisions(nextPos, 60, 50)
		nextPos = upperPos
		local floorHeight, f = maryo.FindFloor(nextPos)
		local ceilHeight, _ = maryo.FindCeiling(nextPos, floorHeight)
		m.Wall = upperWall
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
			local wallDYaw = maryo.NormalizeAngle(math.atan2(upperWall.Normal.Z, upperWall.Normal.X) - m.FaceAngle.Y)
			if math.abs(wallDYaw) >= 0x2AAA and math.abs(wallDYaw) <= 0x5555 then
				return "NONE"
			end
	
			return "HIT_WALL_CONTINUE_QSTEPS"
		end
	
		return "NONE"
	end
	
	function Mario.PerformGroundStep(m: Mario): number
		local floor = m.Floor
	
		if not floor then
			return GroundStep.NONE
		end
	
		local stepResult: number
		assert(floor)
	
		for i = 1, 4 do
			local intendedX = m.Position.X + floor.Normal.Y * (m.Velocity.X / 4)
			local intendedZ = m.Position.Z + floor.Normal.Y * (m.Velocity.Z / 4)
			local intendedY = m.Position.Y
	
			local intendedPos = Vector3.new(intendedX, intendedY, intendedZ)
			stepResult = m:PerformGroundQuarterStep(intendedPos)
	
			if stepResult == GroundStep.LEFT_GROUND or stepResult == GroundStep.HIT_WALL_STOP_QSTEPS then
				break
			end
		end
	
		m.TerrainType = m:GetTerrainType()
		m.GfxAngle = Vector3int16.new(0, m.FaceAngle.Y, 0)
	
		if stepResult == GroundStep.HIT_WALL_CONTINUE_QSTEPS then
			stepResult = GroundStep.HIT_WALL
		end
	
		return stepResult
	end
	
	function Mario.CheckLedgeGrab(m: Mario, wall: RaycastResult, intendedPos: Vector3, nextPos: Vector3): boolean
		if m.Velocity.Y > 0 then
			return false
		end
	
		local dispX = nextPos.X - intendedPos.X
		local dispZ = nextPos.Z - intendedPos.Z
	
		if dispX * m.Velocity.X + dispZ * m.Velocity.Z > 0 then
			return false
		end
	
		local ledgeX = nextPos.X - (wall.Normal.X * 60)
		local ledgeZ = nextPos.Z - (wall.Normal.Z * 60)
	
		local ledgePos = Vector3.new(ledgeX, nextPos.Y + 160, ledgeZ)
		local ledgeY, ledgeFloor = Util.FindFloor(ledgePos)
	
		if ledgeY - nextPos.Y < 100 then
			return false
		end
	
		if ledgeFloor then
			ledgePos = ledgeFloor.Position
			m.Position = ledgePos
	
			m.Floor = ledgeFloor
			m.FloorHeight = ledgeY
			m.FloorAngle = Util.Atan2s(ledgeFloor.Normal.Z, ledgeFloor.Normal.X)
	
			m.FaceAngle *= Vector3int16.new(0, 1, 1)
			m.FaceAngle = Util.SetY(m.FaceAngle, Util.Atan2s(wall.Normal.Z, wall.Normal.X) + 0x8000)
		end
	
		return ledgeFloor ~= nil
	end
	
	function Mario.PerformAirQuarterStep(m: Mario, intendedPos: Vector3, stepArg: number)
		local nextPos = intendedPos
	
		local upperPos, upperWall = Util.FindWallCollisions(nextPos, 150, 50)
		nextPos = upperPos
	
		local lowerPos, lowerWall = Util.FindWallCollisions(nextPos, 30, 50)
		nextPos = lowerPos
	
		local floorHeight, floor = Util.FindFloor(nextPos)
		local ceilHeight = Util.FindCeiling(nextPos, floorHeight)
	
		m.Wall = nil
	
		if floor == nil then
			if nextPos.Y <= m.FloorHeight then
				m.Position = Util.SetY(m.Position, m.FloorHeight)
				return AirStep.LANDED
			end
	
			m.Position = Util.SetY(m.Position, nextPos.Y)
			return AirStep.HIT_WALL
		end
	
		if nextPos.Y <= floorHeight then
			if ceilHeight - floorHeight > 160 then
				m.Floor = floor
				m.FloorHeight = floorHeight
				m.Position = Vector3.new(nextPos.X, m.Position.Y, nextPos.Z)
			end
	
			m.Position = Util.SetY(m.Position, floorHeight)
			return AirStep.LANDED
		end
	
		if nextPos.Y + 160 > ceilHeight then
			if m.Velocity.Y > 0 then
				m.Velocity = Util.SetY(m.Velocity, 0)
				return AirStep.NONE
			end
	
			if nextPos.Y <= m.FloorHeight then
				m.Position = Util.SetY(m.Position, floorHeight)
				return AirStep.LANDED
			end
	
			m.Position = Util.SetY(m.Position, nextPos.Y)
			return AirStep.HIT_WALL
		end
	
		if bit32.btest(stepArg, AirStep.CHECK_LEDGE_GRAB) and upperWall == nil and lowerWall ~= nil then
			if m:CheckLedgeGrab(lowerWall, intendedPos, nextPos) then
				return AirStep.GRABBED_LEDGE
			end
	
			m.Floor = floor
			m.Position = nextPos
			m.FloorHeight = floorHeight
	
			return AirStep.NONE
		end
	
		m.Floor = floor
		m.Position = nextPos
		m.FloorHeight = floorHeight
	
		if upperWall or lowerWall then
			local wall = assert(upperWall or lowerWall)
			local wallDYaw = Util.SignedShort(Util.Atan2s(wall.Normal.Z, wall.Normal.X) - m.FaceAngle.Y)
			m.Wall = wall
	
			if math.abs(wallDYaw) > 0x6000 then
				return AirStep.HIT_WALL
			end
		end
	
		return AirStep.NONE
	end
	
	function Mario.ApplyTwirlGravity(m: Mario)
		local heaviness = 1
	
		if m.AngleVel.Y > 1024 then
			heaviness = 1024 / m.AngleVel.Y
		end
	
		local terminalVelocity = -75 * heaviness
		m.Velocity -= Vector3.new(0, 4 * heaviness, 0)
	
		if m.Velocity.Y < terminalVelocity then
			m.Velocity = Util.SetY(m.Velocity, terminalVelocity)
		end
	end
	
	function Mario.ShouldStrengthenGravityForJumpAscent(m: Mario): boolean
		if not m.Flags:Has(MarioFlags.MOVING_UP_IN_AIR) then
			return false
		end
	
		if m.Action:Has(ActionFlags.INTANGIBLE, ActionFlags.INVULNERABLE) then
			return false
		end
	
		if not m.Input:Has(InputFlags.A_DOWN) and m.Velocity.Y > 20 then
			return m.Action:Has(ActionFlags.CONTROL_JUMP_HEIGHT)
		end
	
		return false
	end
	
	function Mario.ApplyGravity(m: Mario)
		local action = m.Action()
	
		if action == Action.TWIRLING and m.Velocity.Y < 0 then
			m:ApplyTwirlGravity()
		elseif action == Action.SHOT_FROM_CANNON then
			m.Velocity -= Vector3.yAxis
	
			if m.Velocity.Y < -75 then
				m.Velocity = Util.SetY(m.Velocity, -75)
			end
		elseif action == Action.LONG_JUMP or action == Action.SLIDE_KICK or action == Action.BBH_ENTER_SPIN then
			m.Velocity -= (Vector3.yAxis * 2)
	
			if m.Velocity.Y < -75 then
				m.Velocity = Util.SetY(m.Velocity, -75)
			end
		elseif action == Action.LAVA_BOOST or action == Action.FALL_AFTER_STAR_GRAB then
			m.Velocity -= (Vector3.yAxis * 3.2)
	
			if m.Velocity.Y < -65 then
				m.Velocity = Util.SetY(m.Velocity, -65)
			end
		elseif m:ShouldStrengthenGravityForJumpAscent() then
			m.Velocity *= Vector3.new(1, 0.25, 1)
		elseif m.Action:Has(ActionFlags.METAL_WATER) then
			m.Velocity -= (Vector3.yAxis * 1.6)
	
			if m.Velocity.Y < -16 then
				m.Velocity = Util.SetY(m.Velocity, -16)
			end
		elseif m.Flags:Has(MarioFlags.WING_CAP) and m.Velocity.Y < 0 and m.Input:Has(InputFlags.A_DOWN) then
			m.BodyState.WingFlutter = true
			m.Velocity -= (Vector3.yAxis * 2)
	
			if m.Velocity.Y < -37.5 then
				m.Velocity += (Vector3.yAxis * 4)
	
				if m.Velocity.Y > -37.5 then
					m.Velocity = Util.SetY(m.Velocity, -37.5)
				end
			end
		else
			m.Velocity -= (Vector3.yAxis * 4)
	
			if m.Velocity.Y < -75 then
				m.Velocity = Util.SetY(m.Velocity, -75)
			end
		end
	end
	
	function Mario.PerformAirStep(m: Mario, maybeStepArg: number?)
		local stepArg = maybeStepArg or 0
		local stepResult = AirStep.NONE
		m.Wall = nil
	
		for i = 1, 4 do
			local intendedPos = m.Position + (m.Velocity / 4)
			local result = m:PerformAirQuarterStep(intendedPos, stepArg)
	
			if result ~= AirStep.NONE then
				stepResult = result
			end
	
			if
				result == AirStep.LANDED
				or result == AirStep.GRABBED_LEDGE
				or result == AirStep.GRABBED_CEILING
				or result == AirStep.HIT_LAVA_WALL
			then
				break
			end
		end
	
		if m.Velocity.Y >= 0 then
			m.PeakHeight = m.Position.Y
		end
	
		m.TerrainType = m:GetTerrainType()
	
		if m.Action() ~= Action.FLYING then
			m:ApplyGravity()
		end
	
		m.GfxAngle = Vector3int16.new(0, m.FaceAngle.Y, 0)
	
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
		if m.Flags.FALLING_FAR then
			return
		end
		local action = m.Action
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
			maryo.AnimAccelAssist %= (m.AnimFrameCount + 1) * 65536
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
				if group ~= "SUBMERGED" and m.Position.Y < m.WaterLevel - 5 then
					maryo.SetWaterPlungeAction()
					cancel = true
				else
					if group == "AIRBORNE" then
						maryo.PlayFarFallSound()
					elseif group == "SUBMERGED" then
						if maryo.Position.Y > m.WaterLevel - 4 then
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

	-- Airborne.lua
	do
		local function stopRising(m: Mario)
			if m.Velocity.Y > 0 then
				m.Velocity *= Vector3.new(1, 0, 1)
			end
		end
		
		local function playFlipSounds(m: Mario, frame1: number, frame2: number, frame3: number)
			local animFrame = m.AnimFrame
		
			if animFrame == frame1 or animFrame == frame2 or animFrame == frame3 then
				m:PlaySound(Sounds.ACTION_SPIN)
			end
		end
		
		local function playKnockbackSound(m: Mario)
			if m.ActionArg == 0 and math.abs(m.ForwardVel) >= 28 then
				m:PlaySoundIfNoFlag(Sounds.MARIO_DOH, MarioFlags.MARIO_SOUND_PLAYED)
			else
				m:PlaySoundIfNoFlag(Sounds.MARIO_UH, MarioFlags.MARIO_SOUND_PLAYED)
			end
		end
		
		local function lavaBoostOnWall(m: Mario)
			local wall = m.Wall
		
			if wall then
				local angle = Util.Atan2s(wall.Normal.Z, wall.Normal.X)
				m.FaceAngle = Util.SetY(m.FaceAngle, angle)
			end
		
			if m.ForwardVel < 24 then
				m.ForwardVel = 24
			end
		
			if not m.Flags:Has(MarioFlags.METAL_CAP) then
				m.HurtCounter += if m.Flags:Has(MarioFlags.CAP_ON_HEAD) then 12 else 18
			end
		
			m:PlaySound(Sounds.MARIO_ON_FIRE)
			m:SetAction(Action.LAVA_BOOST, 1)
		end
		
		local function checkFallDamage(m: Mario, hardFallAction: number): boolean
			local fallHeight = m.PeakHeight - m.Position.Y
			local damageHeight = 1150
		
			if m.Action() == Action.TWIRLING then
				return false
			end
		
			if m.Velocity.Y < -55 and fallHeight > 3000 then
				m.HurtCounter += if m.Flags:Has(MarioFlags.CAP_ON_HEAD) then 16 else 24
				m:PlaySound(Sounds.MARIO_ATTACKED)
				m:SetAction(hardFallAction, 4)
			elseif fallHeight > damageHeight and not m:FloorIsSlippery() then
				m.HurtCounter += if m.Flags:Has(MarioFlags.CAP_ON_HEAD) then 8 else 12
				m:PlaySound(Sounds.MARIO_ATTACKED)
				m.SquishTimer = 30
			end
		
			return false
		end
		
		local function checkKickOrDiveInAir(m: Mario): boolean
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(if m.ForwardVel > 28 then Action.DIVE else Action.JUMP_KICK)
			end
		
			return false
		end
		
		local function updateAirWithTurn(m: Mario)
			local dragThreshold = if m.Action() == Action.LONG_JUMP then 48 else 32
			m.ForwardVel = Util.ApproachFloat(m.ForwardVel, 0, 0.35)
		
			if m.Input:Has(InputFlags.NONZERO_ANALOG) then
				local intendedDYaw = m.IntendedYaw - m.FaceAngle.Y
				local intendedMag = m.IntendedMag / 32
		
				m.ForwardVel += 1.5 * Util.Coss(intendedDYaw) * intendedMag
				m.FaceAngle += Vector3int16.new(0, 512 * Util.Sins(intendedDYaw) * intendedMag, 0)
			end
		
			if m.ForwardVel > dragThreshold then
				m.ForwardVel -= 1
			end
		
			if m.ForwardVel < -16 then
				m.ForwardVel += 2
			end
		
			m.SlideVelX = m.ForwardVel * Util.Sins(m.FaceAngle.Y)
			m.SlideVelZ = m.ForwardVel * Util.Coss(m.FaceAngle.Y)
			m.Velocity = Vector3.new(m.SlideVelX, m.Velocity.Y, m.SlideVelZ)
		end
		
		local function updateAirWithoutTurn(m: Mario)
			local dragThreshold = 32
		
			if m.Action() == Action.LONG_JUMP then
				dragThreshold = 48
			end
		
			local sidewaysSpeed = 0
			m.ForwardVel = Util.ApproachFloat(m.ForwardVel, 0, 0.35)
		
			if m.Input:Has(InputFlags.NONZERO_ANALOG) then
				local intendedDYaw = m.IntendedYaw - m.FaceAngle.Y
				local intendedMag = m.IntendedMag / 32
		
				m.ForwardVel += intendedMag * Util.Coss(intendedDYaw) * 1.5
				sidewaysSpeed = intendedMag * Util.Sins(intendedDYaw) * 10
			end
		
			--! Uncapped air speed. Net positive when moving forward.
			if m.ForwardVel > dragThreshold then
				m.ForwardVel -= 1
			end
		
			if m.ForwardVel < -16 then
				m.ForwardVel += 2
			end
		
			m.SlideVelX = m.ForwardVel * Util.Sins(m.FaceAngle.Y)
			m.SlideVelZ = m.ForwardVel * Util.Coss(m.FaceAngle.Y)
		
			m.SlideVelX += sidewaysSpeed * Util.Sins(m.FaceAngle.Y + 0x4000)
			m.SlideVelZ += sidewaysSpeed * Util.Coss(m.FaceAngle.Y + 0x4000)
		
			m.Velocity = Vector3.new(m.SlideVelX, m.Velocity.Y, m.SlideVelZ)
		end
		
		local function updateLavaBoostOrTwirling(m: Mario)
			if m.Input:Has(InputFlags.NONZERO_ANALOG) then
				local intendedDYaw = m.IntendedYaw - m.FaceAngle.Y
				local intendedMag = m.IntendedMag / 32
		
				m.ForwardVel += Util.Coss(intendedDYaw) * intendedMag
				m.FaceAngle += Vector3int16.new(0, Util.Sins(intendedDYaw) * intendedMag * 1024, 0)
		
				if m.ForwardVel < 0 then
					m.FaceAngle += Vector3int16.new(0, 0x8000, 0)
					m.ForwardVel *= -1
				end
		
				if m.ForwardVel > 32 then
					m.ForwardVel -= 2
				end
			end
		
			m.SlideVelX = m.ForwardVel * Util.Sins(m.FaceAngle.Y)
			m.SlideVelZ = m.ForwardVel * Util.Coss(m.FaceAngle.Y)
		
			m.Velocity = Vector3.new(m.SlideVelX, m.Velocity.Y, m.SlideVelZ)
		end
		
		local function updateFlyingYaw(m: Mario)
			local targetYawVel = -Util.SignedShort(m.Controller.StickX * (m.ForwardVel / 4))
		
			if targetYawVel > 0 then
				if m.AngleVel.Y < 0 then
					m.AngleVel += Vector3int16.new(0, 0x40, 0)
		
					if m.AngleVel.Y > 0x10 then
						m.AngleVel = Util.SetY(m.AngleVel, 0x10)
					end
				else
					local y = Util.ApproachInt(m.AngleVel.Y, targetYawVel, 0x10, 0x20)
					m.AngleVel = Util.SetY(m.AngleVel, y)
				end
			elseif targetYawVel < 0 then
				if m.AngleVel.Y > 0 then
					m.AngleVel -= Vector3int16.new(0, 0x40, 0)
		
					if m.AngleVel.Y < -0x10 then
						m.AngleVel = Util.SetY(m.AngleVel, -0x10)
					end
				else
					local y = Util.ApproachInt(m.AngleVel.Y, targetYawVel, 0x20, 0x10)
					m.AngleVel = Util.SetY(m.AngleVel, y)
				end
			else
				local y = Util.ApproachInt(m.AngleVel.Y, 0, 0x40)
				m.AngleVel = Util.SetY(m.AngleVel, y)
			end
		
			m.FaceAngle += Vector3int16.new(0, m.AngleVel.Y, 0)
			m.FaceAngle = Util.SetZ(m.FaceAngle, 20 * -m.AngleVel.Y)
		end
		
		local function updateFlyingPitch(m: Mario)
			local targetPitchVel = -Util.SignedShort(m.Controller.StickY * (m.ForwardVel / 5))
		
			if targetPitchVel > 0 then
				if m.AngleVel.X < 0 then
					m.AngleVel += Vector3int16.new(0x40, 0, 0)
		
					if m.AngleVel.X > 0x20 then
						m.AngleVel = Util.SetX(m.AngleVel, 0x20)
					end
				else
					local x = Util.ApproachInt(m.AngleVel.X, targetPitchVel, 0x20, 0x40)
					m.AngleVel = Util.SetX(m.AngleVel, x)
				end
			elseif targetPitchVel < 0 then
				if m.AngleVel.X > 0 then
					m.AngleVel -= Vector3int16.new(0x40, 0, 0)
		
					if m.AngleVel.X < -0x20 then
						m.AngleVel = Util.SetX(m.AngleVel, -0x20)
					end
				else
					local x = Util.ApproachInt(m.AngleVel.X, targetPitchVel, 0x40, 0x20)
					m.AngleVel = Util.SetX(m.AngleVel, x)
				end
			else
				local x = Util.ApproachInt(m.AngleVel.X, 0, 0x40)
				m.AngleVel = Util.SetX(m.AngleVel, x)
			end
		end
		
		local function updateFlying(m: Mario)
			updateFlyingPitch(m)
			updateFlyingYaw(m)
		
			m.ForwardVel -= 2 * (m.FaceAngle.X / 0x4000) + 0.1
			m.ForwardVel -= 0.5 * (1 - Util.Coss(m.AngleVel.Y))
		
			if m.ForwardVel < 0 then
				m.ForwardVel = 0
			end
		
			if m.ForwardVel > 16 then
				m.FaceAngle += Vector3int16.new((m.ForwardVel - 32) * 6, 0, 0)
			elseif m.ForwardVel > 4 then
				m.FaceAngle += Vector3int16.new((m.ForwardVel - 32) * 10, 0, 0)
			else
				m.FaceAngle -= Vector3int16.new(0x400, 0, 0)
			end
		
			m.FaceAngle += Vector3int16.new(m.AngleVel.X, 0, 0)
		
			if m.FaceAngle.X > 0x2AAA then
				m.FaceAngle = Util.SetX(m.FaceAngle, 0x2AAA)
			end
		
			if m.FaceAngle.X < -0x2AAA then
				m.FaceAngle = Util.SetX(m.FaceAngle, -0x2AAA)
			end
		
			local velX = Util.Coss(m.FaceAngle.X) * Util.Sins(m.FaceAngle.Y)
			m.SlideVelX = m.ForwardVel * velX
		
			local velZ = Util.Coss(m.FaceAngle.X) * Util.Coss(m.FaceAngle.Y)
			m.SlideVelZ = m.ForwardVel * velZ
		
			local velY = Util.Sins(m.FaceAngle.X)
			m.Velocity = m.ForwardVel * Vector3.new(velX, velY, velZ)
		end
		
		local function commonAirActionStep(m: Mario, landAction: number, anim: Animation, stepArg: number): number
			local stepResult
			do
				updateAirWithoutTurn(m)
				stepResult = m:PerformAirStep(stepArg)
			end
		
			if stepResult == AirStep.NONE then
				m:SetAnimation(anim)
			elseif stepResult == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					m:SetAction(landAction)
				end
			elseif stepResult == AirStep.HIT_WALL then
				m:SetAnimation(anim)
		
				if m.ForwardVel > 16 then
					m:BonkReflection()
					m.FaceAngle += Vector3int16.new(0, 0x8000, 0)
		
					if m.Wall then
						m:SetAction(Action.AIR_HIT_WALL)
					else
						stopRising(m)
		
						if m.ForwardVel >= 38 then
							m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
							m:SetAction(Action.BACKWARD_AIR_KB)
						else
							if m.ForwardVel > 8 then
								m:SetForwardVel(-8)
							end
		
							m:SetAction(Action.SOFT_BONK)
						end
					end
				else
					m:SetForwardVel(0)
				end
			elseif stepResult == AirStep.GRABBED_LEDGE then
				m:SetAnimation(Animations.IDLE_ON_LEDGE)
				m:SetAction(Action.LEDGE_GRAB)
			elseif stepResult == AirStep.GRABBED_CEILING then
				m:SetAction(Action.START_HANGING)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return stepResult
		end
		
		local function commonRolloutStep(m: Mario, anim: Animation)
			local stepResult
		
			if m.ActionState == 0 then
				m.Velocity = Util.SetY(m.Velocity, 30)
				m.ActionState = 1
			end
		
			m:PlaySound(Sounds.ACTION_TERRAIN_JUMP)
			updateAirWithoutTurn(m)
		
			stepResult = m:PerformAirStep()
		
			if stepResult == AirStep.NONE then
				if m.ActionState == 1 then
					if m:SetAnimation(anim) == 4 then
						m:PlaySound(Sounds.ACTION_SPIN)
					end
				else
					m:SetAnimation(Animations.GENERAL_FALL)
				end
			elseif stepResult == AirStep.LANDED then
				m:SetAction(Action.FREEFALL_LAND_STOP)
				m:PlayLandingSound()
			elseif stepResult == AirStep.HIT_WALL then
				m:SetForwardVel(0)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			if m.ActionState == 1 and m:IsAnimPastEnd() then
				m.ActionState = 2
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
				m:SetForwardVel(speed)
				stepResult = m:PerformAirStep()
			end
		
			if stepResult == AirStep.NONE then
				m:SetAnimation(anim)
			elseif stepResult == AirStep.LANDED then
				if not checkFallDamage(m, hardFallAction) then
					local action = m.Action()
		
					if action == Action.THROWN_FORWARD or action == Action.THROWN_BACKWARD then
						m:SetAction(landAction, m.HurtCounter)
					else
						m:SetAction(landAction, m.ActionArg)
					end
				end
			elseif stepResult == AirStep.HIT_WALL then
				m:SetAnimation(Animations.BACKWARD_AIR_KB)
				m:BonkReflection()
		
				stopRising(m)
				m:SetForwardVel(-speed)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return stepResult
		end
		
		local function checkWallKick(m: Mario)
			if m.WallKickTimer ~= 0 then
				if m.Input:Has(InputFlags.A_PRESSED) then
					if m.PrevAction() == Action.AIR_HIT_WALL then
						m.FaceAngle += Vector3int16.new(0, 0x8000, 0)
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
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			commonAirActionStep(m, Action.JUMP_LAND, Animations.SINGLE_JUMP, AIR_STEP_CHECK_BOTH)
		
			return false
		end)
		
		DEF_ACTION(Action.DOUBLE_JUMP, function(m: Mario)
			local anim = if m.Velocity.Y >= 0 then Animations.DOUBLE_JUMP_RISE else Animations.DOUBLE_JUMP_FALL
		
			if checkKickOrDiveInAir(m) then
				return true
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_HOOHOO)
			commonAirActionStep(m, Action.DOUBLE_JUMP_LAND, anim, AIR_STEP_CHECK_BOTH)
		
			return false
		end)
		
		DEF_ACTION(Action.TRIPLE_JUMP, function(m: Mario)
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.DIVE)
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			commonAirActionStep(m, Action.TRIPLE_JUMP_LAND, Animations.TRIPLE_JUMP, 0)
		
			playFlipSounds(m, 2, 8, 20)
			return false
		end)
		
		DEF_ACTION(Action.BACKFLIP, function(m: Mario)
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_YAH_WAH_HOO)
			commonAirActionStep(m, Action.BACKFLIP_LAND, Animations.BACKFLIP, 0)
		
			playFlipSounds(m, 2, 3, 17)
			return false
		end)
		
		DEF_ACTION(Action.FREEFALL, function(m: Mario)
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.DIVE)
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			local anim
		
			if m.ActionArg == 0 then
				anim = Animations.GENERAL_FALL
			elseif m.ActionArg == 1 then
				anim = Animations.FALL_FROM_SLIDE
			elseif m.ActionArg == 2 then
				anim = Animations.FALL_FROM_SLIDE_KICK
			end
		
			commonAirActionStep(m, Action.FREEFALL_LAND, anim, AirStep.CHECK_LEDGE_GRAB)
			return false
		end)
		
		DEF_ACTION(Action.SIDE_FLIP, function(m: Mario)
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.DIVE, 0)
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			commonAirActionStep(m, Action.SIDE_FLIP_LAND, Animations.SLIDEFLIP, AirStep.CHECK_LEDGE_GRAB)
		
			if m.AnimFrame == 6 then
				m:PlaySound(Sounds.ACTION_SIDE_FLIP)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.WALL_KICK_AIR, function(m: Mario)
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.DIVE)
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayJumpSound()
			commonAirActionStep(m, Action.JUMP_LAND, Animations.SLIDEJUMP, AirStep.CHECK_LEDGE_GRAB)
		
			return false
		end)
		
		DEF_ACTION(Action.LONG_JUMP, function(m: Mario)
			local anim = if m.LongJumpIsSlow then Animations.SLOW_LONGJUMP else Animations.FAST_LONGJUMP
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_YAHOO)
			commonAirActionStep(m, Action.LONG_JUMP_LAND, anim, AirStep.CHECK_LEDGE_GRAB)
		
			return false
		end)
		
		DEF_ACTION(Action.TWIRLING, function(m: Mario)
			local startTwirlYaw = m.TwirlYaw
			local yawVelTarget = 0x1000
		
			if m.Input:Has(InputFlags.A_DOWN) then
				yawVelTarget = 0x2000
			end
		
			local yVel = Util.ApproachInt(m.AngleVel.Y, yawVelTarget, 0x200)
			m.AngleVel = Util.SetY(m.AngleVel, yVel)
			m.TwirlYaw += yVel
		
			m:SetAnimation(if m.ActionArg == 0 then Animations.START_TWIRL else Animations.TWIRL)
		
			if m:IsAnimPastEnd() then
				m.ActionArg = 1
			end
		
			if startTwirlYaw > m.TwirlYaw then
				m:PlaySound(Sounds.ACTION_TWIRL)
			end
		
			local step = m:PerformAirStep()
		
			if step == AirStep.LANDED then
				m:SetAction(Action.TWIRL_LAND)
			elseif step == AirStep.HIT_WALL then
				m:BonkReflection(false)
			elseif step == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			m.GfxAngle += Vector3int16.new(0, m.TwirlYaw, 0)
			return false
		end)
		
		DEF_ACTION(Action.DIVE, function(m: Mario)
			local airStep
		
			if m.ActionArg == 0 then
				m:PlayMarioSound(Sounds.ACTION_THROW, Sounds.MARIO_HOOHOO)
			else
				m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			end
		
			m:SetAnimation(Animations.DIVE)
			updateAirWithoutTurn(m)
			airStep = m:PerformAirStep()
		
			if airStep == AirStep.NONE then
				if m.Velocity.Y < 0 and m.FaceAngle.X > -0x2AAA then
					m.FaceAngle -= Vector3int16.new(0x200, 0, 0)
		
					if m.FaceAngle.X < -0x2AAA then
						m.FaceAngle = Util.SetX(m.FaceAngle, -0x2AAA)
					end
				end
		
				m.GfxAngle = Util.SetX(m.GfxAngle, -m.FaceAngle.X)
			elseif airStep == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_FORWARD_GROUND_KB) then
					m:SetAction(Action.DIVE_SLIDE)
				end
		
				m.FaceAngle *= Vector3int16.new(0, 1, 1)
			elseif airStep == AirStep.HIT_WALL then
				m:BonkReflection(true)
				m.FaceAngle *= Vector3int16.new(0, 1, 1)
		
				stopRising(m)
		
				m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				m:SetAction(Action.BACKWARD_AIR_KB)
			elseif airStep == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.WATER_JUMP, function(m: Mario)
			if m.ForwardVel < 15 then
				m:SetForwardVel(15)
			end
		
			m:PlaySound(Sounds.ACTION_WATER_EXIT)
			m:SetAnimation(Animations.SINGLE_JUMP)
		
			local step = m:PerformAirStep(AirStep.CHECK_LEDGE_GRAB)
		
			if step == AirStep.LANDED then
				m:SetAction(Action.JUMP_LAND)
			elseif step == AirStep.HIT_WALL then
				m:SetForwardVel(15)
			elseif step == AirStep.GRABBED_LEDGE then
				m:SetAnimation(Animations.IDLE_ON_LEDGE)
				m:SetAction(Action.LEDGE_GRAB)
			elseif step == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.STEEP_JUMP, function(m: Mario)
			local airStep
		
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.DIVE)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			m:SetForwardVel(0.98 * m.ForwardVel)
			airStep = m:PerformAirStep()
		
			if airStep == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					m.FaceAngle *= Vector3int16.new(0, 1, 1)
					m:SetAction(if m.ForwardVel < 0 then Action.BEGIN_SLIDING else Action.JUMP_LAND)
				end
			elseif airStep == AirStep.HIT_WALL then
				m:SetForwardVel(0)
			elseif airStep == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			m:SetAnimation(Animations.SINGLE_JUMP)
			m.GfxAngle = Util.SetY(m.GfxAngle, m.SteepJumpYaw)
		
			return false
		end)
		
		DEF_ACTION(Action.GROUND_POUND, function(m: Mario)
			local stepResult
			local yOffset
		
			m:PlaySoundIfNoFlag(Sounds.ACTION_THROW, MarioFlags.ACTION_SOUND_PLAYED)
		
			if m.ActionState == 0 then
				if m.ActionTimer < 10 then
					yOffset = 20 - 2 * m.ActionTimer
		
					if m.Position.Y + yOffset + 160 < m.CeilHeight then
						m.Position += Vector3.new(0, yOffset, 0)
						m.PeakHeight = m.Position.Y
					end
				end
		
				m.Velocity = Util.SetY(m.Velocity, -50)
				m:SetForwardVel(0)
		
				m:SetAnimation(if m.ActionArg == 0 then Animations.START_GROUND_POUND else Animations.TRIPLE_JUMP_GROUND_POUND)
		
				if m.ActionTimer == 0 then
					m:PlaySound(Sounds.ACTION_SPIN)
				end
		
				m.ActionTimer += 1
				m.GfxAngle = Vector3int16.new(0, m.FaceAngle.Y, 0)
		
				if m.ActionTimer >= m.AnimFrameCount + 4 then
					m:PlaySound(Sounds.MARIO_GROUND_POUND_WAH)
					m.ActionState = 1
				end
			else
				m:SetAnimation(Animations.GROUND_POUND)
				stepResult = m:PerformAirStep()
		
				if stepResult == AirStep.LANDED then
					m:PlayHeavyLandingSound(Sounds.ACTION_HEAVY_LANDING)
		
					if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
						m.ParticleFlags:Add(ParticleFlags.MIST_CIRCLE, ParticleFlags.HORIZONTAL_STAR)
						m:SetAction(Action.GROUND_POUND_LAND)
					end
				elseif stepResult == AirStep.HIT_WALL then
					m:SetForwardVel(-16)
					stopRising(m)
		
					m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
					m:SetAction(Action.BACKWARD_AIR_KB)
				end
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BURNING_JUMP, function(m: Mario)
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP)
			m:SetForwardVel(m.ForwardVel)
		
			if m:PerformAirStep() == AirStep.LANDED then
				m:PlayLandingSound()
				m:SetAction(Action.BURNING_GROUND)
			end
		
			m:SetAnimation(Animations.GENERAL_FALL)
			m.ParticleFlags:Add(ParticleFlags.FIRE)
			m:PlaySound(Sounds.MOVING_LAVA_BURN)
		
			m.BurnTimer += 3
			m.Health -= 10
		
			if m.Health < 0x100 then
				m.Health = 0xFF
			end
		
			return false
		end)
		
		DEF_ACTION(Action.BURNING_FALL, function(m: Mario)
			m:SetForwardVel(m.ForwardVel)
		
			if m:PerformAirStep() == AirStep.LANDED then
				m:PlayLandingSound(Sounds.ACTION_TERRAIN_LANDING)
				m:SetAction(Action.BURNING_GROUND)
			end
		
			m:SetAnimation(Animations.GENERAL_FALL)
			m.ParticleFlags:Add(ParticleFlags.FIRE)
		
			m.BurnTimer += 3
			m.Health -= 10
		
			if m.Health < 0x100 then
				m.Health = 0xFF
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
			local landAction = if m.ActionArg ~= 0 then Action.HARD_BACKWARD_GROUND_KB else Action.BACKWARD_GROUND_KB
		
			m:PlaySoundIfNoFlag(Sounds.MARIO_WAAAOOOW, MarioFlags.MARIO_SOUND_PLAYED)
			commonAirKnockbackStep(m, landAction, Action.HARD_BACKWARD_GROUND_KB, Animations.BACKWARD_AIR_KB, m.ForwardVel)
		
			m.ForwardVel *= 0.98
			return false
		end)
		
		DEF_ACTION(Action.THROWN_FORWARD, function(m: Mario)
			local landAction = if m.ActionArg ~= 0 then Action.HARD_FORWARD_GROUND_KB else Action.FORWARD_GROUND_KB
		
			m:PlaySoundIfNoFlag(Sounds.MARIO_WAAAOOOW, MarioFlags.MARIO_SOUND_PLAYED)
		
			if
				commonAirKnockbackStep(m, landAction, Action.HARD_FORWARD_GROUND_KB, Animations.FORWARD_AIR_KB, m.ForwardVel)
				== AirStep.NONE
			then
				local pitch = Util.Atan2s(m.ForwardVel, -m.Velocity.Y)
		
				if pitch > 0x1800 then
					pitch = 0x1800
				end
		
				m.GfxAngle = Util.SetX(m.GfxAngle, pitch + 0x1800)
			end
		
			m.ForwardVel *= 0.98
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
				m.ForwardVel
			)
		
			return false
		end)
		
		DEF_ACTION(Action.AIR_HIT_WALL, function(m: Mario)
			m.ActionTimer += 1
		
			if m.ActionTimer <= 2 then
				if m.Input:Has(InputFlags.A_PRESSED) then
					m.Velocity = Util.SetY(m.Velocity, 52)
					m.FaceAngle += Vector3int16.new(0, 0x8000, 0)
					return m:SetAction(Action.WALL_KICK_AIR)
				end
			elseif m.ForwardVel >= 38 then
				m.WallKickTimer = 5
		
				if m.Velocity.Y > 0 then
					m.Velocity = Util.SetY(m.Velocity, 0)
				end
		
				m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				return m:SetAction(Action.BACKWARD_AIR_KB)
			else
				m.WallKickTimer = 5
		
				if m.Velocity.Y > 0 then
					m.Velocity = Util.SetY(m.Velocity, 0)
				end
		
				if m.ForwardVel > 8 then
					m:SetForwardVel(-8)
				end
		
				return m:SetAction(Action.SOFT_BONK)
			end
		
			return m:SetAnimation(Animations.START_WALLKICK) > 0
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
			m.ActionTimer += 1
		
			if m.ActionTimer > 30 and m.Position.Y - m.FloorHeight > 500 then
				return m:SetAction(Action.FREEFALL, 1)
			end
		
			updateAirWithTurn(m)
			stepResult = m:PerformAirStep()
		
			if stepResult == AirStep.LANDED then
				if m.ActionState == 0 and m.Velocity.Y < 0 then
					local floor = m.Floor
		
					if floor and floor.Normal.Y > 0.9848077 then
						m.Velocity *= Vector3.new(1, -0.5, 1)
						m.ActionState = 1
					else
						m:SetAction(Action.BUTT_SLIDE)
					end
				else
					m:SetAction(Action.BUTT_SLIDE)
				end
		
				m:PlayLandingSound()
			elseif stepResult == AirStep.HIT_WALL then
				stopRising(m)
				m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				m:SetAction(Action.BACKWARD_AIR_KB)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			m:SetAnimation(Animations.SLIDE)
			return false
		end)
		
		DEF_ACTION(Action.LAVA_BOOST, function(m: Mario)
			local stepResult
			m:PlaySoundIfNoFlag(Sounds.MARIO_ON_FIRE, MarioFlags.MARIO_SOUND_PLAYED)
		
			if not m.Input:Has(InputFlags.NONZERO_ANALOG) then
				m.ForwardVel = Util.ApproachFloat(m.ForwardVel, 0, 0.35)
			end
		
			updateLavaBoostOrTwirling(m)
			stepResult = m:PerformAirStep()
		
			if stepResult == AirStep.LANDED then
				local floor = m.Floor
				local floorType: Enum.Material?
		
				if floor then
					floorType = floor.Material
				end
		
				if floorType == Enum.Material.CrackedLava then
					m.ActionState = 0
		
					if not m.Flags:Has(MarioFlags.METAL_CAP) then
						m.HurtCounter += if m.Flags:Has(MarioFlags.CAP_ON_HEAD) then 12 else 18
					end
		
					m.Velocity = Util.SetY(m.Velocity, 84)
					m:PlaySound(Sounds.MARIO_ON_FIRE)
				else
					m:PlayHeavyLandingSound(Sounds.ACTION_TERRAIN_BODY_HIT_GROUND)
		
					if m.ActionState < 2 and m.Velocity.Y < 0 then
						m.Velocity *= Vector3.new(1, -0.4, 1)
						m:SetForwardVel(m.ForwardVel / 2)
						m.ActionState += 1
					else
						m:SetAction(Action.LAVA_BOOST_LAND)
					end
				end
			elseif stepResult == AirStep.HIT_WALL then
				m:BonkReflection()
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			m:SetAnimation(Animations.FIRE_LAVA_BURN)
		
			if not m.Flags:Has(MarioFlags.METAL_CAP) and m.Velocity.Y > 0 then
				m.ParticleFlags:Add(ParticleFlags.FIRE)
		
				if m.ActionState == 0 then
					m:PlaySound(Sounds.MOVING_LAVA_BURN)
				end
			end
		
			m.BodyState.EyeState = MarioEyes.DEAD
			return false
		end)
		
		DEF_ACTION(Action.SLIDE_KICK, function(m: Mario)
			local stepResult
		
			if m.ActionState == 0 and m.ActionTimer == 0 then
				m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_HOOHOO)
				m:SetAnimation(Animations.SLIDE_KICK)
			end
		
			m.ActionTimer += 1
		
			if m.ActionTimer > 30 and m.Position.Y - m.FloorHeight > 500 then
				return m:SetAction(Action.FREEFALL, 2)
			end
		
			updateAirWithoutTurn(m)
			stepResult = m:PerformAirStep()
		
			if stepResult == AirStep.NONE then
				if m.ActionState == 0 then
					local tilt = Util.Atan2s(m.ForwardVel, -m.Velocity.Y)
		
					if tilt > 0x1800 then
						tilt = 0x1800
					end
		
					m.GfxAngle = Util.SetX(m.GfxAngle, tilt)
				end
			elseif stepResult == AirStep.LANDED then
				if m.ActionState == 0 and m.Velocity.Y < 0 then
					m.Velocity *= Vector3.new(1, -0.5, 1)
					m.ActionState = 1
					m.ActionTimer = 0
				else
					m:SetAction(Action.SLIDE_KICK_SLIDE)
				end
		
				m:PlayLandingSound()
			elseif stepResult == AirStep.HIT_WALL then
				stopRising(m)
				m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
				m:SetAction(Action.BACKWARD_AIR_KB)
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.JUMP_KICK, function(m: Mario)
			local stepResult
		
			if m.ActionState == 0 then
				m:PlaySoundIfNoFlag(Sounds.MARIO_PUNCH_HOO, MarioFlags.MARIO_SOUND_PLAYED)
				m.AnimReset = true
		
				m:SetAnimation(Animations.AIR_KICK)
				m.ActionState = 1
			end
		
			local animFrame = m.AnimFrame
		
			if animFrame == 0 then
				m.BodyState.PunchType = 2
				m.BodyState.PunchTimer = 6
			end
		
			if animFrame >= 0 and animFrame < 8 then
				m.Flags:Add(MarioFlags.KICKING)
			end
		
			updateAirWithoutTurn(m)
			stepResult = m:PerformAirStep()
		
			if stepResult == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					m:SetAction(Action.FREEFALL_LAND)
				end
			elseif stepResult == AirStep.HIT_WALL then
				m:SetForwardVel(0)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.FLYING, function(m: Mario)
			local startPitch = m.FaceAngle.X
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			if not m.Flags:Has(MarioFlags.WING_CAP) then
				return m:SetAction(Action.FREEFALL)
			end
		
			if m.ActionState == 0 then
				if m.ActionArg == 0 then
					m:SetAnimation(Animations.FLY_FROM_CANNON)
				else
					m:SetAnimation(Animations.FORWARD_SPINNING_FLIP)
		
					if m.AnimFrame == 1 then
						m:PlaySound(Sounds.ACTION_SPIN)
					end
				end
		
				if m:IsAnimAtEnd() then
					m:SetAnimation(Animations.WING_CAP_FLY)
					m.ActionState = 1
				end
			end
		
			local stepResult
			do
				updateFlying(m)
				stepResult = m:PerformAirStep()
			end
		
			if stepResult == AirStep.NONE then
				m.GfxAngle = Util.SetX(m.GfxAngle, -m.FaceAngle.X)
				m.GfxAngle = Util.SetZ(m.GfxAngle, m.FaceAngle.Z)
				m.ActionTimer = 0
			elseif stepResult == AirStep.LANDED then
				m:SetAction(Action.DIVE_SLIDE)
				m:SetAnimation(Animations.DIVE)
		
				m:SetAnimToFrame(7)
				m.FaceAngle *= Vector3int16.new(0, 1, 1)
			elseif stepResult == AirStep.HIT_WALL then
				if m.Wall then
					m:SetForwardVel(-16)
					m.FaceAngle *= Vector3int16.new(0, 1, 1)
		
					stopRising(m)
					m:PlaySound(if m.Flags:Has(MarioFlags.METAL_CAP) then Sounds.ACTION_METAL_BONK else Sounds.ACTION_BONK)
		
					m.ParticleFlags:Add(ParticleFlags.VERTICAL_STAR)
					m:SetAction(Action.BACKWARD_AIR_KB)
				else
					m.ActionTimer += 1
		
					if m.ActionTimer == 0 then
						m:PlaySound(Sounds.ACTION_HIT)
					end
		
					if m.ActionTimer == 30 then
						m.ActionTimer = 0
					end
		
					m.FaceAngle -= Vector3int16.new(0x200, 0, 0)
		
					if m.FaceAngle.X < -0x2AAA then
						m.FaceAngle = Util.SetX(m.FaceAngle, -0x2AAA)
					end
		
					m.GfxAngle = Util.SetX(m.GfxAngle, -m.FaceAngle.X)
					m.GfxAngle = Util.SetZ(m.GfxAngle, m.FaceAngle.Z)
				end
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			if m.FaceAngle.X > 0x800 and m.ForwardVel >= 48 then
				m.ParticleFlags:Add(ParticleFlags.DUST)
			end
		
			if startPitch <= 0 and m.FaceAngle.X > 0 and m.ForwardVel >= 48 then
				m:PlaySound(Sounds.ACTION_FLYING_FAST)
				m:PlaySound(Sounds.MARIO_YAHOO_WAHA_YIPPEE)
			end
		
			m:PlaySound(Sounds.MOVING_FLYING)
			m:AdjustSoundForSpeed()
		
			return false
		end)
		
		DEF_ACTION(Action.FLYING_TRIPLE_JUMP, function(m: Mario)
			if m.Input:Has(InputFlags.B_PRESSED) then
				return m:SetAction(Action.DIVE)
			end
		
			if m.Input:Has(InputFlags.Z_PRESSED) then
				return m:SetAction(Action.GROUND_POUND)
			end
		
			m:PlayMarioSound(Sounds.ACTION_TERRAIN_JUMP, Sounds.MARIO_YAHOO)
		
			if m.ActionState == 0 then
				m:SetAnimation(Animations.TRIPLE_JUMP_FLY)
		
				if m.AnimFrame == 7 then
					m:PlaySound(Sounds.ACTION_SPIN)
				end
		
				if m:IsAnimPastEnd() then
					m:SetAnimation(Animations.FORWARD_SPINNING)
					m.ActionState = 1
				end
			end
		
			if m.ActionState == 1 and m.AnimFrame == 1 then
				m:PlaySound(Sounds.ACTION_SPIN)
			end
		
			if m.Velocity.Y < 4 then
				if m.ForwardVel < 32 then
					m:SetForwardVel(32)
				end
		
				m:SetAction(Action.FLYING, 1)
			end
		
			m.ActionTimer += 1
		
			local stepResult
			do
				updateAirWithoutTurn(m)
				stepResult = m:PerformAirStep()
			end
		
			if stepResult == AirStep.LANDED then
				if not checkFallDamage(m, Action.HARD_BACKWARD_GROUND_KB) then
					m:SetAction(Action.DOUBLE_JUMP_LAND)
				end
			elseif stepResult == AirStep.HIT_WALL then
				m:BonkReflection()
			elseif stepResult == AirStep.HIT_LAVA_WALL then
				lavaBoostOnWall(m)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.SPAWN_SPIN_AIRBORNE, function(m: Mario)
			m:SetForwardVel(m.ForwardVel)
		
			if m:PerformAirStep() == AirStep.LANDED then
				m:PlayLandingSound(Sounds.ACTION_TERRAIN_LANDING)
				m:SetAction(Action.SPAWN_SPIN_LANDING)
			end
		
			if m.ActionState == 0 and m.Position.Y - m.FloorHeight > 300 then
				if m:SetAnimation(Animations.FORWARD_SPINNING) == 0 then
					m:PlaySound(Sounds.ACTION_SPIN)
				end
			else
				m.ActionState = 1
				m:SetAnimation(Animations.GENERAL_FALL)
			end
		
			return false
		end)
		
		DEF_ACTION(Action.SPAWN_SPIN_LANDING, function(m: Mario)
			maryo.StopAndSetHeightToFloor()
			m:SetAnimation(Animations.GENERAL_LAND)
			if m:IsAnimAtEnd() then
				m:SetAction(Action.IDLE)
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

AddModule(function()
	local m = {}
	m.ModuleType = "MOVESET"
	m.Name = "2007 Roblox"
	m.Description = "old roblox is retroslop.\nVery accurate recreation of the old Roblox physics!\nReject Motor6Ds, and return to Motors!"
	m.InternalName = "RETROSLOP"
	m.Assets = {}

	m.FPS30 = true
	m.Snap = true
	m.Config = function(parent: GuiBase2d)
		Util_CreateSwitch(parent, "30 FPS Cap", m.FPS30).Changed:Connect(function(val)
			m.FPS30 = val
		end)
		Util_CreateSwitch(parent, "Joint Snapping", m.Snap).Changed:Connect(function(val)
			m.Snap = val
		end)
	end
	m.LoadConfig = function(save: any)
		m.FPS30 = not save.FPSUnlock
		m.Snap = not save.NoSnap
	end
	m.SaveConfig = function()
		return {
			FPSUnlock = not m.FPS30,
			NoSnap = not m.Snap
		}
	end

	local rcp = RaycastParams.new()
	rcp.FilterType = Enum.RaycastFilterType.Exclude
	rcp.RespectCanCollide = true
	rcp.IgnoreWater = true

	-- https://raw.githubusercontent.com/MaximumADHD/Super-Nostalgia-Zone/refs/heads/main/Player/RetroClimbing.client.lua
	local searchDepth = 0.7
	local maxClimbDist = 2.45
	local sampleSpacing = 1 / 7
	local lowLadderSearch = 2.7
	local ladderSearchDist = 2.0
	local function findPartInLadderZone(figure, root, hum)
		local cf = root.CFrame
		local top = -hum.HipHeight
		local bottom = -lowLadderSearch + top
		local radius = 0.5 * ladderSearchDist
		local center = cf.Position + (cf.LookVector * ladderSearchDist * 0.5)
		local min = Vector3.new(-radius, bottom, -radius)
		local max = Vector3.new(radius, top, radius)
		local extents = Region3.new(center + min, center + max)
		return #workspace:FindPartsInRegion3(extents, figure) > 0
	end
	local function findLadder(figure, root, hum)
		local scale = figure:GetScale()
		searchDepth = 0.7 * scale
		maxClimbDist = 2.45 * scale
		sampleSpacing = scale / 7
		lowLadderSearch = 2.7 * scale
		ladderSearchDist = 2.0 * scale
		if not findPartInLadderZone(figure, root, hum) then
			return false
		end
		local torsoCoord = root.CFrame
		local torsoLook = torsoCoord.LookVector
		local firstSpace = 0
		local firstStep = 0
		local lookForSpace = true
		local lookForStep = false
		local topRay = math.floor(lowLadderSearch / sampleSpacing)
		for i = 1, topRay do
			local distFromBottom = i * sampleSpacing
			local originOnTorso = Vector3.new(0, -lowLadderSearch + distFromBottom, 0)
			local casterOrigin = torsoCoord.Position + originOnTorso
			local casterDirection = torsoLook * ladderSearchDist
			local hitPrim, hitLoc = nil, casterOrigin + casterDirection
			local hit = workspace:Raycast(casterOrigin, casterDirection, rcp)
			if hit then
				hitPrim, hitLoc = hit.Instance, hit.Position
			end
			-- make trusses climbable.
			if hitPrim and hitPrim:IsA("TrussPart") then
				return true
			end
			local mag = (hitLoc - casterOrigin).Magnitude
			if mag < searchDepth then
				if lookForSpace then
					firstSpace = distFromBottom
					lookForSpace = false
					lookForStep = true
				end
			elseif lookForStep then
				firstStep = distFromBottom - firstSpace
				lookForStep = false
			end
		end
		return firstSpace < maxClimbDist and firstStep > 0 and firstStep < maxClimbDist
	end

	local hstatechange, hrun = nil

	local lastpose = ""
	local pose = "Standing"
	local toolAnim = "None"
	local toolAnimTime = 0
	local canClimb = false
	local hipHeight = 0

	local rng = Random.new(math.random(-65536, 65536))
	
	local sndpoint, climbforce = nil, nil

	local lastupdate = 0
	local rs, ls, rh, lh = {V = 0, D = 0, C = 0}, {V = 0, D = 0, C = 0}, {V = 0, D = 0, C = 0}, {V = 0, D = 0, C = 0}

	m.Init = function(figure: Model)
		local hum = figure:FindFirstChild("Humanoid")
		hum.AutoRotate = true
		hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
		hum:ChangeState(Enum.HumanoidStateType.Freefall)
		sndpoint = Instance.new("Attachment")
		sndpoint.Name = "oldrobloxsound"
		sndpoint.Parent = hum.Torso
		local function makesound(name, id)
			local sound = Instance.new("Sound")
			sound.SoundId = id
			sound.Parent = sndpoint
			sound.Volume = 5
			sound.Name = name
			return sound
		end
		makesound("Running", "rbxasset://sounds/bfsl-minifigfoots1.mp3").Looped = true
		makesound("Climbing", "rbxasset://sounds/bfsl-minifigfoots1.mp3").Looped = true
		makesound("GettingUp", "rbxasset://sounds/hit.wav")
		local f = makesound("Freefall", "rbxassetid://12222200")
		makesound("FallingDown", "rbxasset://sounds/splat.wav")
		local j = makesound("Jumping", "rbxasset://sounds/button.wav")
		j.Played:Connect(function()
			task.wait(0.12 + math.random() * 0.08)
			j:Stop()
		end)
		hrun = hum.Running:Connect(function(speed)
			if speed > 0.2 then
				pose = "Running"
			else
				pose = "Standing"
			end
		end)
		hstatechange = hum.StateChanged:Connect(function(old, new)
			local state = new.Name
			if state == "Jumping" then
				pose = "Jumping"
				canClimb = true
				hum.AutoRotate = false
				hipHeight = -1
			elseif state == "Freefall" then
				pose = "Freefall"
				canClimb = true
				hum.AutoRotate = false
				hipHeight = -1
			elseif state == "Landed" then
				pose = "Freefall"
				canClimb = true
				local vel = hum.Torso.Velocity
				local power = -vel.Y / 2
				if power > 30 then
					hum.Torso.Velocity = Vector3.new(vel.X, power, vel.Z)
					hum.Torso.RotVelocity = rng:NextUnitVector() * power * 0.5
					if power > 100 then
						hum:ChangeState(Enum.HumanoidStateType.Ragdoll)
					else
						hum:ChangeState(Enum.HumanoidStateType.Freefall)
					end
				end
				hum.AutoRotate = false
				hipHeight = -1
				f:Play()
			elseif state == "Seated" then
				pose = "Seated"
				canClimb = false
			elseif state == "Swimming" then
				pose = "Running"
				canClimb = false
			elseif state == "Running" then
				canClimb = true
			elseif state == "PlatformStand" then
				pose = "Standing"
				canClimb = false
			elseif state == "GettingUp" then
				pose = "GettingUp"
				canClimb = false
				hum.AutoRotate = false
				hum.HipHeight = -1
			elseif state == "Ragdoll" then
				pose = "Running"
				canClimb = false
			elseif state == "FallingDown" then
				pose = "FallingDown"
				canClimb = false
			else
				pose = "Standing"
				canClimb = false
			end
		end)
		climbforce = Instance.new("BodyVelocity")
		climbforce.Name = "ClimbForce"
		climbforce.Parent = nil
	end
	m.Update = function(dt: number, figure: Model)
		local t = os.clock()

		rcp.FilterDescendantsInstances = {figure}

		local scale = figure:GetScale()

		local hum = figure:FindFirstChild("Humanoid")
		if not hum then return end
		local root = figure:FindFirstChild("HumanoidRootPart")
		if not root then return end
		local torso = figure:FindFirstChild("Torso")
		if not torso then return end

		if lastpose ~= pose then
			local snd1 = sndpoint:FindFirstChild(lastpose)
			local snd2 = sndpoint:FindFirstChild(pose)
			if snd1 and snd1.Looped then snd1:Stop() end
			if snd2 then
				if pose == "Freefall" then
					task.delay(0.15, snd2.Play, snd2)
				else
					snd2:Play()
				end
			end
			lastpose = pose
		end

		local function getTool()
			for _, kid in figure:GetChildren() do
				if kid.className == "Tool" then
					return kid
				end
			end
			return nil
		end

		local function getToolAnim(tool)
			for _, c in tool:GetChildren() do
				if c.Name == "toolanim" and c.ClassName == "StringValue" then
					return c
				end
			end
			return nil
		end

		local climbing = canClimb and findLadder(figure, root, hum)
		local jumping = pose == "Jumping" or pose == "Freefall"

		local climbforced = false
		local climbspeed = hum.WalkSpeed * 0.7
		if climbing then
			if hum.MoveDirection.Magnitude > 0 then
				climbforce.Velocity = Vector3.new(0, climbspeed, 0)
				climbforced = true
			elseif jumping then
				climbforce.Velocity = Vector3.new(0, -climbspeed, 0)
				climbforced = true
			end
		end
		if climbforced then
			climbforce.MaxForce = Vector3.new(climbspeed * 100, 10e6, climbspeed * 100)
			climbforce.Parent = root
		else
			climbforce.Parent = nil
		end

		if not climbing and (jumping or hipHeight < -0.01) then
			if not jumping then
				hipHeight *= math.exp(-16 * dt)
			end
			hum.JumpPower = 0
			rs.V = 0.5
			ls.V = 0.5
			rs.D = 3.14
			ls.D = -3.14
			rh.V = 0.5
			lh.V = 0.5
			rh.D = 0
			lh.D = 0
		elseif pose == "Seated" then
			rs.V = 0.15
			ls.V = 0.15
			rs.D = 1.57
			ls.D = -1.57
			rh.V = 0.15
			lh.V = 0.15
			rh.D = 1.57
			lh.D = -1.57
		else
			hum.AutoRotate = true
			hum.JumpPower = 50

			local amplitude = 1
			local frequency = 9
			local climbFudge = 0

			if climbing then
				rs.V = 0.5
				ls.V = 0.5
				rh.V = 0.1
				lh.V = 0.1
				climbFudge = 3.14
			elseif pose == "Running" then
				rs.V = 0.15
				ls.V = 0.15
				rh.V = 0.1
				lh.V = 0.1
			else
				amplitude = 0.1
				frequency = 1
			end

			local desiredAngle = amplitude * math.sin(t * frequency)
			rs.D = desiredAngle + climbFudge
			ls.D = desiredAngle - climbFudge
			rh.D = -desiredAngle
			lh.D = -desiredAngle

			local tool = getTool()
			if tool and tool.RequiresHandle then
				local msg = getToolAnim(tool)
				if msg then
					toolAnim = msg.Value
					msg:Destroy()
					toolAnimTime = t + 0.3
				end
				if t > toolAnimTime then
					toolAnimTime = 0
					toolAnim = "None"
				end
				if toolAnim == "None" then
					rs.D = 1.57
				elseif toolAnim == "Slash" then
					rs.V = 0.5
					rs.D = 0
				elseif toolAnim == "Lunge" then
					rs.V = 0.5
					ls.V = 0.5
					rs.D = 1.57
					ls.D = 1
					rh.V = 0.5
					lh.V = 0.5
					rh.D = 1.57
					lh.D = 1
				end
			else
				toolAnim = "None"
				toolAnimTime = 0
			end
		end
		hum.HipHeight = hipHeight * scale

		local rj = root:FindFirstChild("RootJoint")
		local nj = torso:FindFirstChild("Neck")
		local rsj = torso:FindFirstChild("Right Shoulder")
		local lsj = torso:FindFirstChild("Left Shoulder")
		local rhj = torso:FindFirstChild("Right Hip")
		local lhj = torso:FindFirstChild("Left Hip")

		local function stepjoint(a, b, c)
			local d = a.D - a.C
			if math.abs(d) < a.V then
				a.C = a.D
			elseif d > 0 then
				a.C += a.V * 30 * c
			else
				a.C -= a.V * 30 * c
			end
			local e = a.C
			if m.Snap then
				local snap = math.pi / 90
				e = math.round(a.C / snap) * snap
			end
			b.Transform = CFrame.Angles(0, 0, e)
		end

		local delta = 1 / 30
		if not m.FPS30 then
			lastupdate = 0
			delta = dt
		end

		if t - lastupdate > 1 / 30 then
			lastupdate = t
			rj.Transform = CFrame.identity
			nj.Transform = CFrame.identity
			stepjoint(rs, rsj, delta)
			stepjoint(ls, lsj, delta)
			stepjoint(rh, rhj, delta)
			stepjoint(lh, lhj, delta)
		end
	end
	m.Destroy = function(figure: Model?)
		hstatechange:Disconnect()
		hrun:Disconnect()
		sndpoint:Destroy()
		climbforce:Destroy()
	end
	--return m
end)

return modules