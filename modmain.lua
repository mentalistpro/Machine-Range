-- _Q_ -- Machin Range Check 1.1


if GetModConfigData("Range Check Time") == "short" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 10
end

if GetModConfigData("Range Check Time") == "default" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 30
end

if GetModConfigData("Range Check Time") == "long" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 60
end

if GetModConfigData("Range Check Time") == "vlong" then
	GLOBAL.TUNING.RANGE_CHECK_TIME = 180
end


function MachineOnRemove(inst)
	
	local pos = GLOBAL.Point(inst.Transform:GetWorldPosition())
	local range_indicators = GLOBAL.TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"})
	for i,v in ipairs(range_indicators) do
		if v:IsValid() then
			v:Remove()
		end
	end
end

function getstatus_mod(inst, viewer)
	if inst.name=="Ice Flingomatic" then
	GLOBAL.TUNING.MACHIN = 1
	elseif inst.name=="Sprinkler" then
	GLOBAL.TUNING.MACHIN = 2
	elseif inst.name=="Oscillating Fan" then
	GLOBAL.TUNING.MACHIN = 3
	elseif inst.name=="Lightning Rod" then
	GLOBAL.TUNING.MACHIN = 4
	else
	GLOBAL.TUNING.MACHIN = 0
	end
	local pos = Point(inst.Transform:GetWorldPosition())
	local range_indicators = TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"} )
	if #range_indicators < 1 then
	local range = GLOBAL.SpawnPrefab("range_indicator")
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

PrefabFiles = 
{
	"range"
}

function MachinePostInit(inst)
	if inst and inst.components.inspectable then
		inst.components.inspectable.getstatus = getstatus_mod
	end
	inst:ListenForEvent("onremove", MachineOnRemove)
end

AddPrefabPostInit("sprinkler", MachinePostInit)
AddPrefabPostInit("firesuppressor", MachinePostInit)
AddPrefabPostInit("basefan", MachinePostInit)
AddPrefabPostInit("lightning_rod", MachinePostInit)