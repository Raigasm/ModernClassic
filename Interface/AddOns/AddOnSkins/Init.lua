local AddOnName, Engine = ...
local AddOn = LibStub('AceAddon-3.0'):NewAddon('AddOnSkins', 'AceEvent-3.0', 'AceHook-3.0', 'AceTimer-3.0')

Engine[1] = AddOn
Engine[2] = LibStub("AceLocale-3.0"):GetLocale('AddOnSkins', false)

_G.AddOnSkins = Engine
AddOnSkinsDS = {}

-- Cache global variables
--Lua functions
local _G = _G
local select, tonumber = select, tonumber
local strlower = strlower
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local GetNumAddOns = GetNumAddOns
local GetPhysicalScreenSize = GetPhysicalScreenSize
local GetRealmName = GetRealmName
local UIParent = UIParent
local UnitClass, UnitName = UnitClass, UnitName
local UnitFactionGroup = UnitFactionGroup
-- GLOBALS:

AddOn.Title = GetAddOnMetadata('AddOnSkins', 'Title')
AddOn.Version = tonumber(GetAddOnMetadata('AddOnSkins', 'Version'))
AddOn.ProperVersion = tostring(strlen(AddOn.Version) == 3 and AddOn.Version..'0' or AddOn.Version)
AddOn.Authors = GetAddOnMetadata('AddOnSkins', 'Author'):gsub(", ", "    ")
AddOn.LSM = LibStub('LibSharedMedia-3.0', true)
AddOn.LCG = LibStub('LibCustomGlow-1.0', true)
AddOn.TicketTracker = 'https://git.tukui.org/Azilroka/AddOnSkins/issues'
AddOn.MyClass = select(2, UnitClass('player'))
AddOn.MyName = UnitName('player')
AddOn.MyRealm = GetRealmName()
AddOn.Noop = function() end
AddOn.TexCoords = {.08, .92, .08, .92}
AddOn.UIScale = UIParent:GetScale()
AddOn.Faction = UnitFactionGroup("player")
AddOn.ScreenWidth, AddOn.ScreenHeight = GetPhysicalScreenSize()

AddOn.TexturePath = [[Interface\AddOns\]]..AddOnName..[[\Media\Textures\]]

local Color = _G.RAID_CLASS_COLORS[AddOn.MyClass]
AddOn.ClassColor = { Color.r, Color.g, Color.b }
AddOn.Color = { 0, 0.44, .87, 1 }
AddOn.Mult = 1
AddOn.skins = {}
AddOn.events = {}
AddOn.register = {}
AddOn.FrameLocks = {}

AddOn.preload = {}

AddOn.AddOns = {}
AddOn.AddOnVersion = {}

for i = 1, GetNumAddOns() do
	local Name = GetAddOnInfo(i)
	AddOn.AddOns[strlower(Name)] = GetAddOnEnableState(AddOn.MyName, Name) == 2
	AddOn.AddOnVersion[strlower(Name)] = GetAddOnMetadata(Name, "Version")
end

_G.TEXTURE_ITEM_QUEST_BANG = [[Interface\AddOns\AddOnSkins\Media\Textures\UI-Icon-QuestBang]]

AddOn.Hider = CreateFrame('Frame', nil, UIParent)
AddOn.Hider:Hide()
