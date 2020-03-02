PrefabFiles =
{
	"range",
}

-----------------------------------------------------------------------------

--//CONTENT//
--1. Config
--2. AddPrefabPostInit

-----------------------------------------------------------------------------
--1. Config

local _G = GLOBAL

if GetModConfigData("Range Check Time") == "short" then
	_G.TUNING.RANGE_CHECK_TIME = 10
elseif GetModConfigData("Range Check Time") == "default" then
	_G.TUNING.RANGE_CHECK_TIME = 30
elseif GetModConfigData("Range Check Time") == "long" then
	_G.TUNING.RANGE_CHECK_TIME = 60
elseif GetModConfigData("Range Check Time") == "vlong" then
	_G.TUNING.RANGE_CHECK_TIME = 180
end

-----------------------------------------------------------------------------
--2. AddPrefabPostInit

local function MachineOnRemove(inst)
	local pos = _G.Point(inst.Transform:GetWorldPosition())
	local range_indicators = _G.TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"})
	for i,v in ipairs(range_indicators) do
		if v:IsValid() then
			v:Remove()
		end
	end
end

local function getstatus_mod(inst, viewer)
	if inst.name=="Ice Flingomatic" then
	_G.TUNING.MACHIN = 1
	elseif inst.name=="Sprinkler" then
	_G.TUNING.MACHIN = 2
	elseif inst.name=="Oscillating Fan" then
	_G.TUNING.MACHIN = 3
	elseif inst.name=="Lightning Rod" then
	_G.TUNING.MACHIN = 4
	else
	_G.TUNING.MACHIN = 0
	end
	
	local pos = Point(inst.Transform:GetWorldPosition())
	local range_indicators = TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"} )
	
	if #range_indicators < 1 then
		local range = _G.SpawnPrefab("range_indicator")
		range.Transform:SetPosition(pos.x, pos.y, pos.z)
	end
					
	if inst.on then
		if inst.components.fueled and (inst.components.fueled.currentfuel / inst.components.fueled.maxfuel) <= .25 then
			return "LOWFUEL"
		else
			return "ON"
		end
	else
		return "OFF"
	end
	
end

local function MachinePostInit(inst)
	if inst and inst.components.inspectable then
		inst.components.inspectable.getstatus = getstatus_mod
	end
	inst:ListenForEvent("onremove", MachineOnRemove)
end

AddPrefabPostInit("sprinkler", MachinePostInit)
AddPrefabPostInit("firesuppressor", MachinePostInit)
AddPrefabPostInit("basefan", MachinePostInit)
AddPrefabPostInit("lightning_rod", MachinePostInit)