PrefabFiles =
{
    "range",
    --"machine_constructionplans",
}

-----------------------------------------------------------------------------

--[[CONTENT]]
--#2 Range indicator
--#3 Firesuppressor
--#3 Construction plan

-----------------------------------------------------------------------------
--#1 Range indicator

local _G = GLOBAL

--Range fade time
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

--When machine is removed, range is removed immediately
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

--When you inspect the machine, range appears
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

-----------------------------------------------------------------------------
--#2 Firesuppressor

local Vector3 = _G.Vector3

--Refuel when fuel level is low
local function AddFuel(inst)
    local item = inst.components.container:GetItemInSlot(i)
    local fuelamt = item.components.fuel.fuelvalue
    local stacksize = item.components.stackable:StackSize()
    
    if inst.components.fueled:GetPercent() < 0.3 then
        for i = 1, inst.components.container:GetNumSlots() do
            if item and item.components.fuel then
                inst.components.fueled:DoDelta(fuelamt)
                inst.components.container:RemoveItemBySlot(i)
                
                if item.components.stackable then
                    stacksize = stacksize - 1 
                else
                    item:Remove()
                end
            end
        end
    end
end

--Refuel when container is closed
local function onclose(inst)
    AddFuel(inst)
end

--Refuel when fuel is empty
local function OnFuelEmpt_new(inst)
    inst.components.machine:TurnOff()
    for i = 1, inst.components.container:GetNumSlots() do
        local item = inst.components.container:GetItemInSlot(i)
        if item and item.components.fuel then 
            AddFuel(inst)
            inst.components.machine:TurnOn()    
        end
    end
end

local function FlingomaticPostInit(inst)
    local slotpos = {}
    for y = 2, 0, -1 do
        for x = 0, 2 do
            table.insert(slotpos, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
        end
    end
    
    local widgetbuttoninfo = {
        text = "ON/OFF",
        position = Vector3(0, -165, 0),
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
    inst.components.container.onclosefn = onclose
    inst.components.container:SetNumSlots(#slotpos)
    inst.components.container.widgetslotpos = slotpos
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetbuttoninfo = widgetbuttoninfo
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160
    
    inst.components.fueled:SetDepletedFn(OnFuelEmpt_new)
end  
    
        --[[for i=1,40 do
        if inst.components.fueled:GetPercent() < 0.3 then
            inst.addallfuel = true
            for i = 1, container:GetNumSlots() do
            local item = container:GetItemInSlot(i)
            local itemnew = container:GetItemInSlot(i)
            if item and inst.addallfuel then 
                local replacement = nil
                if item.components.fuel then
                    local fuelamt = item.components.fuel.fuelvalue * 1 
                    inst.components.fueled:DoDelta(fuelamt)
                    inst.addallfuel = false
                    container:RemoveItemBySlot(i)
                    if not item.components.stackable then
                     item:Remove()
                    end
    if item and itemnew then 
     local stacksize = 1 
         if itemnew.components.stackable then 
             stacksize = item.components.stackable:StackSize() - 1             
             if itemnew.components.stackable then 
                 itemnew.components.stackable:SetStackSize(stacksize)
             end
             container:GiveItem(itemnew, i)
             if stacksize == 0 then
                 local itemnew = nil
                 container:RemoveItemBySlot(i)
                 item:Remove() 
             end
         else
         end 
    end

    end         
    end
    end
    end
end 

end]]

--Firesuppressor refuels automatically
if GetModConfigData("automatic_refuel") == 0 then
    AddPrefabPostInit("firesuppressor", FlingomaticPostInit)
end

--Firesuppressor does not shut down campfire
if GetModConfigData("campfire_safe") == 0 then
    AddPrefabPostInit("firesuppressor", function(inst)
        table.insert(inst.components.firedetector.NOTAGS, "campfire")
    end)
end

-----------------------------------------------------------------------------
--#3 Construction plan

--Construction plan recipes
if GetModConfigData("constructionplans") == 0 then

end
