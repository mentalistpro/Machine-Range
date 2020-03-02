local assets=
{
	Asset("ANIM", "anim/machine_range.zip"),  
}


local function fn(Sim)
	
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
	inst:Add("NOCLICK")
	inst:AddTag("range_indicator")
    
	if TUNING.RANGE_CHECK_TIME > 1 then
	inst:DoTaskInTime(TUNING.RANGE_CHECK_TIME, function() inst:Remove() end)
	end
	
    return inst
end

return Prefab( "common/range_indicator", fn, assets) 