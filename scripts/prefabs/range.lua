local assets=
{
    Asset("ANIM", "anim/machine_range.zip"),
}

local function ErodeAway(inst)
    local time_to_erode = 1
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

--------------------------------------------------------------------------

local function MakeRange(name, postinit)
    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()

        local x = 1
        if TUNING.RANGE_TYPE == 1 then      --basefan
            x = 1.55
        elseif TUNING.RANGE_TYPE == 2 then  --firesuppressor
            x = 1.55
        elseif TUNING.RANGE_TYPE == 3 then  --lightning_rod
            x = 2.53
        elseif TUNING.RANGE_TYPE == 4 then  --sprinkler
            x = 1.09
        end
        trans:SetScale(x,x,x)

        anim:SetBank("machine_range")
        anim:SetBuild("machine_range")
        anim:PlayAnimation("idle")

        anim:SetLayer(LAYER_BACKGROUND)
        anim:SetOrientation(ANIM_ORIENTATION.OnGround)
        anim:SetMultColour(1,0,0,0.8)
        anim:SetSortOrder(3)

        inst.persists = false
        inst:AddTag("fx")
        inst:AddTag("NOCLICK")
        inst:AddTag("range_indicator")

        if postinit ~= nil then
            postinit(inst)
        end

        return inst
    end

    return Prefab("common/"..name, fn, assets)
end

--------------------------------------------------------------------------

local function postinit1(inst)
    if TUNING.RANGE_FADE_TIME > 0.1 then
        inst:DoTaskInTime(TUNING.RANGE_FADE_TIME, ErodeAway)
    end
end

local function postinit2(inst)
    local anim = inst.entity:AddAnimState()
    anim:SetMultColour(0.3,.8,0,0.5)
    inst.persists = true
end

--------------------------------------------------------------------------

return  MakeRange("range_indicator", postinit1),
        MakeRange("range_indicator2", postinit2)

