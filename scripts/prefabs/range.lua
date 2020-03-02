local assets=
{
	Asset("ANIM", "anim/machine_range.zip"),  
}

local function ErodeAway(inst)
    local time_to_erode = 2
    local tick_time = TheSim:GetTickTime()

    inst:StartThread(function()
        local ticks = 0
        while ticks * tick_time < time_to_erode do
            local erode_amount = ticks * tick_time / time_to_erode
            inst.AnimState:SetErosionParams(erode_amount, 0.1, 1.0)
            ticks = ticks + 1
            Yield()
        end
        inst:Remove()
    end)
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local x
	if TUNING.MACHIN == 1 then
	x = 1.55
	elseif TUNING.MACHIN == 2 then
	x = 1.09
	elseif TUNING.MACHIN == 3 then
	x = 1.55
	elseif TUNING.MACHIN == 4 then
	x = 2.53
	end
    trans:SetScale(x,x,x)
	
    anim:SetBank("firefighter_placement")
    anim:SetBuild("firefighter_range")
    anim:PlayAnimation("idle")
    
	anim:SetOrientation( ANIM_ORIENTATION.OnGround )
    anim:SetLayer( LAYER_BACKGROUND )
    anim:SetSortOrder( 3 )
	
	inst.persists = false
    inst:AddTag("fx")
	inst:AddTag("range_indicator")
    
	if TUNING.RANGE_FADE_TIME > 0 then
		inst:DoTaskInTime(TUNING.RANGE_FADE_TIME, ErodeAway)
	end
	
    return inst
end

return Prefab( "common/range_indicator", fn, assets) 