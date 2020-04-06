local assets =
{
    Asset("ANIM", "anim/fake_basefan.zip"),
    Asset("ANIM", "anim/fake_firefighter.zip"),
    Asset("ANIM", "anim/fake_lightning_rod.zip"),
    Asset("ANIM", "anim/fake_sprinkler.zip"),
}

local prefabs =
{
    "collapse_small",
    "twigs"
}

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PushAnimation("idle")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:PushAnimation("idle")
end

--------------------------------------------------------------------------

local function MachineConstruction(name, postinit)
    local function fn()
        local inst = CreateEntity()
        local trans = inst.entity:AddTransform()
        local anim = inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()

        inst:AddComponent("inspectable")
        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnFinishCallback(onhammered)
        inst.components.workable:SetOnWorkCallback(onhit)

        inst:ListenForEvent("onbuilt", onbuilt)

        if postinit ~= nil then
            postinit(inst)
        end

        return inst
    end

    return Prefab("common/objects/"..name, fn, assets, prefabs)
end

--------------------------------------------------------------------------

local function postinit1(inst)
    local anim = inst.entity:AddAnimState() --red
    anim:SetBank("fake_basefan")
    anim:SetBuild("fake_basefan")
    anim:PlayAnimation("idle")
end

local function postinit2(inst)
    local anim = inst.entity:AddAnimState() --white
    anim:SetBank("fake_firefighter")
    anim:SetBuild("fake_firefighter")
    anim:PlayAnimation("idle")
end

local function postinit3(inst)
    local anim = inst.entity:AddAnimState() --yellow
    anim:SetBank("fake_lightning_rod")
    anim:SetBuild("fake_lightning_rod")
    anim:PlayAnimation("idle")
end

local function postinit4(inst)
    local anim = inst.entity:AddAnimState() --blue
    anim:SetBank("fake_sprinkler")
    anim:SetBuild("fake_sprinkler")
    anim:PlayAnimation("idle")
end

--------------------------------------------------------------------------

return  MachineConstruction("basefan_construction", postinit1),
        MachineConstruction("firesuppressor_construction", postinit2),
        MachineConstruction("lightning_rod_construction", postinit3),
        MachineConstruction("sprinkler_construction", postinit4),

        MakePlacer("basefan_construction_placer", "fake_basefan", "fake_basefan", "idle"),
        MakePlacer("firesuppressor_construction_placer", "fake_firefighter", "fake_firefighter", "idle"),
        MakePlacer("lightning_rod_construction_placer", "fake_lightning_rod", "fake_lightning_rod", "idle"),
        MakePlacer("sprinkler_construction_placer", "fake_sprinkler", "fake_sprinkler", "idle")