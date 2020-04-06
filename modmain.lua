PrefabFiles =
{
    "range",
    "machine_constructions",
}

Assets =
{
    Asset("ATLAS", "images/inventoryimages/basefan_construction.xml"),
    Asset("ATLAS", "images/inventoryimages/firesuppressor_construction.xml"),
    Asset("ATLAS", "images/inventoryimages/lightning_rod_construction.xml"),
    Asset("ATLAS", "images/inventoryimages/sprinkler_construction.xml"),
}

--------------------------------------------------------------------------

--[[CONTENT]]
--#1 Range indicator
--#2 Automatic refuel
--#3 Campfire safe
--#4 Construction plan

--------------------------------------------------------------------------
--#1 Range indicator

local _G = GLOBAL

--1.1 Range fade time
if GetModConfigData("range_fadetime") == 0 then
    TUNING.RANGE_FADE_TIME = 10
elseif GetModConfigData("range_fadetime") == 1 then
    TUNING.RANGE_FADE_TIME = 20
elseif GetModConfigData("range_fadetime") == 2 then
    TUNING.RANGE_FADE_TIME = 50
elseif GetModConfigData("range_fadetime") == 3 then
    TUNING.RANGE_FADE_TIME = 100
elseif GetModConfigData("range_fadetime") == 4 then
    TUNING.RANGE_FADE_TIME = 200
elseif GetModConfigData("range_fadetime") == 5 then
    TUNING.RANGE_FADE_TIME = 0
elseif GetModConfigData("range_fadetime") == -1 then
    TUNING.RANGE_FADE_TIME = 5
end

--1.2 When machine is removed, range is removed immediately
local function MachineOnRemove(inst)
    local pos = _G.Point(inst.Transform:GetWorldPosition())
    local range_indicators = _G.TheSim:FindEntities(pos.x,pos.y,pos.z, 2, {"range_indicator"})
    for i,v in ipairs(range_indicators) do
        if v:IsValid() then
            v.AnimState:SetErosionParams(0, 0.1, 1.0)
            v:Remove()
        end
    end
end

--1.3 When you inspect the machine, range appears
local function getstatus_machines(inst, viewer)
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

--1.4 PostInit
local function MachinePostInit(inst)
    if inst and inst.components.inspectable then
        inst.components.inspectable.getstatus = getstatus_machines
    end
    inst:ListenForEvent("onremove", MachineOnRemove)
end

local MACHINE_WITH_RANGE = {
    "basefan",
    "firesuppressor",
    "lightning_rod",
    "sprinkler",
}

for k, v in pairs(MACHINE_WITH_RANGE) do
    AddPrefabPostInit(v, MachinePostInit)
end

--------------------------------------------------------------------------
--#2 Automatic Refuel

local require = _G.require
local Vector3 = _G.Vector3

--2.1 Refuel logic, credit to 霜月大笨蛋
require "components/container"

local function AddFuel(inst)
    local container = inst.components.container
    for i= 1,40 do
        if inst.components.fueled:GetPercent() < 0.5 then
            for i = 1, container:GetNumSlots() do
                local item = container:GetItemInSlot(i)
                local itemnew = container:GetItemInSlot(i)
                if item and item.components.fuel then
                    local fuelamt = item.components.fuel.fuelvalue * 5
                    inst.components.fueled:DoDelta(fuelamt)
                    container:RemoveItemBySlot(i)

                    if item and itemnew then
                        local stacksize = 1
                        if itemnew.components.stackable then
                            stacksize = item.components.stackable:StackSize() - 1
                            itemnew.components.stackable:SetStackSize(stacksize)
                            container:GiveItem(itemnew, i)
                            if stacksize == 0 then
                                local itemnew = nil
                                container:RemoveItemBySlot(i)
                                item:Remove()
                            end
                        end
                    end
                end
            end
        end
    end
end

--2.2 Refuel when fuel is low
local function OnFuelSectionChange_new(old, new, inst)
    local fuelAnim = inst.components.fueled:GetCurrentSection()
    inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", fuelAnim)

    if fuelAnim < 5 then
        AddFuel(inst)
    end
end

--2.3 Container properties
local function FlingomaticPostInit(inst)
    local slotpos = {}
    for y = 2, 0, -1 do
        for x = 0, 2 do
            table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
        end
    end

    local widgetbuttoninfo = {
        text = "ON/OFF",
        position = Vector3(0, -150, 0),
        fn = function(inst)
            local ison = inst.components.machine:IsOn()
            if not ison and not inst.components.fueled:IsEmpty() then
                inst.components.machine:TurnOn()
            else
                inst.components.machine:TurnOff()
            end
        end,
    }

    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160

    inst.components.fueled:SetSectionCallback(OnFuelSectionChange_new)
end

--2.4 PostInit
if GetModConfigData("automatic_refuel") == 0 then
    AddPrefabPostInit("firesuppressor", FlingomaticPostInit)
end

--------------------------------------------------------------------------
--#3 Campfire safe
local FRIENDLY_FIRE = {
    "alwaysontikitorch",
    "deluxe_firepit",
    "endo_firepit",
    "firepit_obsidian",
    "heat_star",
    "ice_star",
    "maxwelllight",
    "musha_oven",
    "nightlight",
    "pigtorch",
    "tungsten_firepit",
}

if GetModConfigData("campfire_safe") == 0 then
    for k, v in pairs(FRIENDLY_FIRE) do
        AddPrefabPostInit(v, function(inst)
            inst:AddTag("campfire")
        end)
    end

    AddPrefabPostInit("firesuppressor", function(inst)
        table.insert(inst.components.firedetector.NOTAGS, "campfire")
    end)
end

--------------------------------------------------------------------------
--#4 Construction plan

--4.1 Recipes
local Ingredient = _G.Ingredient
local Recipe = _G.Recipe
local RECIPETABS = _G.RECIPETABS
local TECH = _G.TECH
local _S = _G.STRINGS

if GetModConfigData("constructionplans") == 0 then
    --Lightning_rod
    local lightning_rod_construction = Recipe(
        "lightning_rod_construction",
        {Ingredient("twigs",1)},
        RECIPETABS.SCIENCE, TECH.NONE
    )
    lightning_rod_construction.atlas = "images/inventoryimages/lightning_rod_construction.xml"
    lightning_rod_construction.placer = "lightning_rod_construction_placer"

    _S.NAMES.LIGHTNING_ROD_CONSTRUCTION = "Lightning Rod Plan"
    _S.RECIPE_DESC.LIGHTNING_ROD_CONSTRUCTION = "Well prepared in advance."
    _S.CHARACTERS.GENERIC.LIGHTNING_ROD_CONSTRUCTION = "Well prepared in advance."

    --Firesuppressor
    local firesuppressor_construction = Recipe(
        "firesuppressor_construction",
        {Ingredient("twigs",1)},
        RECIPETABS.SCIENCE, TECH.NONE
    )
    firesuppressor_construction.atlas = "images/inventoryimages/firesuppressor_construction.xml"
    firesuppressor_construction.placer = "firesuppressor_construction_placer"

    _S.NAMES.FIRESUPPRESSOR_CONSTRUCTION = "Ice Flingomatic Plan"
    _S.RECIPE_DESC.FIRESUPPRESSOR_CONSTRUCTION = "Well prepared in advance."
    _S.CHARACTERS.GENERIC.FIRESUPPRESSOR_CONSTRUCTION = "Well prepared in advance."

    --Sprinkler
    local sprinkler_construction = Recipe(
        "sprinkler_construction",
        {Ingredient("twigs",1)},
        RECIPETABS.SCIENCE, TECH.NONE
    )
    sprinkler_construction.atlas = "images/inventoryimages/sprinkler_construction.xml"
    sprinkler_construction.placer = "sprinkler_construction_placer"

    _S.NAMES.SPRINKLER_CONSTRUCTION = "Sprinkler Plan"
    _S.RECIPE_DESC.SPRINKLER_CONSTRUCTION = "Well prepared in advance."
    _S.CHARACTERS.GENERIC.SPRINKLER_CONSTRUCTION = "Well prepared in advance."

    --Basefan
    local basefan_construction = Recipe(
        "basefan_construction",
        {Ingredient("twigs",1)},
        RECIPETABS.SCIENCE, TECH.NONE
    )
    basefan_construction.atlas = "images/inventoryimages/basefan_construction.xml"
    basefan_construction.placer = "basefan_construction_placer"

    _S.NAMES.BASEFAN_CONSTRUCTION = "Oscillating Fan Plan"
    _S.RECIPE_DESC.BASEFAN_CONSTRUCTION = "Well prepared in advance."
    _S.CHARACTERS.GENERIC.BASEFAN_CONSTRUCTION = "Well prepared in advance."

--4.2 Range appears automatically with machine_constructions
    local function SpawnIndicator(inst)
        if inst.prefab=="basefan_construction" then
            TUNING.RANGE_TYPE = 1
        elseif inst.prefab=="firesuppressor_construction" then
            TUNING.RANGE_TYPE = 2
        elseif inst.prefab=="lightning_rod_construction" then
            TUNING.RANGE_TYPE = 3
        elseif inst.prefab=="sprinkler_construction" then
            TUNING.RANGE_TYPE = 4
        end

        local pos = _G.Point(inst.Transform:GetWorldPosition())
        local range = _G.SpawnPrefab("range_indicator2")
        range.Transform:SetPosition(pos.x, pos.y, pos.z)
    end

--4.3 PostInit
    local function MachineConstructionPostInit(inst)
        inst:ListenForEvent("onbuilt", SpawnIndicator)
        inst:ListenForEvent("onremove", MachineOnRemove)
    end

    local MACHINE_CONSTRUCTION_WITH_RANGE = {
    "basefan_construction",
    "firesuppressor_construction",
    "lightning_rod_construction",
    "sprinkler_construction",
    }

    for k, v in pairs(MACHINE_CONSTRUCTION_WITH_RANGE) do
        AddPrefabPostInit(v, MachineConstructionPostInit)
    end
end

