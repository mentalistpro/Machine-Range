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

if GetModConfigData("range_fadetime") == 0 then
	TUNING.RANGE_FADE_TIME = 2
elseif GetModConfigData("range_fadetime") == 1 then
	TUNING.RANGE_FADE_TIME = 5
elseif GetModConfigData("range_fadetime") == 2 then
	TUNING.RANGE_FADE_TIME = 10
elseif GetModConfigData("range_fadetime") == 3 then
	TUNING.RANGE_FADE_TIME = 20
elseif GetModConfigData("range_fadetime") == 4 then
	TUNING.RANGE_FADE_TIME = 50
elseif GetModConfigData("range_fadetime") == 5 then
	TUNING.RANGE_FADE_TIME = 100
elseif GetModConfigData("range_fadetime") == 6 then	--infinite
	TUNING.RANGE_FADE_TIME = 0
end

-----------------------------------------------------------------------------
--2. AddPrefabPostInit

local function MachineOnRemove(inst)
	local pos = _G.Point(inst.Transform:GetWorldPosition())
	local range_indicators = _G.TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"})
	for i,v in ipairs(range_indicators) do
		if v:IsValid() then
            v.AnimState:SetErosionParams(erode_amount, 0.1, 1.0)
			v:Remove()
		end
	end
end

local function getstatus_mod(inst, viewer)
	if inst.prefab=="basefan" then
		TUNING.RANGE_TYPE = 1
	elseif inst.prefab=="firesuppressor" then
		TUNING.RANGE_TYPE = 2
	elseif inst.prefab=="lightning_rod" then
		TUNING.RANGE_TYPE = 3
	elseif inst.prefab=="sprinkler" then
		TUNING.RANGE_TYPE = 4
	else
		TUNING.RANGE_TYPE = 0
	end
	
	local pos = _G.Point(inst.Transform:GetWorldPosition())
	local range_indicators = _G.TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"} )
	
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
	
	if inst.charged then
		return "CHARGED"
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