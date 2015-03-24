local config_equipments = GameDatas.DragonEquipments.equipments
local config_function = GameDatas.BuildingFunction.blackSmith
local config_levelup = GameDatas.BuildingLevelUp.blackSmith

local Observer = import(".Observer")
local UpgradeBuilding = import(".UpgradeBuilding")
local BlackSmithUpgradeBuilding = class("BlackSmithUpgradeBuilding", UpgradeBuilding)

function BlackSmithUpgradeBuilding:ctor(...)
    self.black_smith_building_observer = Observer.new()
    self.making_event = self:CreateEvent()
    BlackSmithUpgradeBuilding.super.ctor(self, ...)
end
function BlackSmithUpgradeBuilding:GetNextLevelEfficiency()
    return config_function[self:GetNextLevel()].efficiency
end
function BlackSmithUpgradeBuilding:GetEfficiency()
    return config_function[self:GetEfficiencyLevel()].efficiency
end
function BlackSmithUpgradeBuilding:CreateEvent()
    local black_smith = self
    local event = {}
    function event:Init()
        self:Reset()
    end
    function event:Reset()
        self.content = nil
        self.finished_time = 0
        self.id = nil
    end
    function event:UniqueKey()
        return self:Id()
    end
    function event:StartTime()
        return self.finished_time - black_smith:GetMakingTimeByEquipment(self.content)
    end
    function event:ElapseTime(current_time)
        return current_time - self:StartTime()
    end
    function event:LeftTime(current_time)
        return self.finished_time - current_time
    end
    function event:Percent(current_time)
        local start_time = self:StartTime()
        local elapse_time = current_time - start_time
        local total_time = self.finished_time - start_time
        return elapse_time * 100.0 / total_time
    end
    function event:FinishTime()
        return self.finished_time
    end
    function event:SetFinishTime(current_time)
        self.finished_time = current_time
    end
    function event:Content()
        return self.content
    end
    function event:SetContentWithFinishTime(content, finished_time, id)
        self.content = content
        self.finished_time = finished_time
        self.id = id
    end
    function event:IsEmpty()
        return self.finished_time == 0 and self.content == nil
    end
    function event:IsMaking()
        return self.content ~= nil
    end
    function event:Id()
        return self.id
    end
    event:Init()
    return event
end
function BlackSmithUpgradeBuilding:ResetAllListeners()
    BlackSmithUpgradeBuilding.super.ResetAllListeners(self)
    self.black_smith_building_observer:RemoveAllObserver()
end
function BlackSmithUpgradeBuilding:AddBlackSmithListener(listener)
    assert(listener.OnBeginMakeEquipmentWithEvent)
    assert(listener.OnMakingEquipmentWithEvent)
    assert(listener.OnEndMakeEquipmentWithEvent)
    self.black_smith_building_observer:AddObserver(listener)
end
function BlackSmithUpgradeBuilding:RemoveBlackSmithListener(listener)
    self.black_smith_building_observer:RemoveObserver(listener)
end
function BlackSmithUpgradeBuilding:GetMakeEquipmentEvent()
    return self.making_event
end
function BlackSmithUpgradeBuilding:IsEquipmentEventEmpty()
    return self.making_event:IsEmpty()
end
function BlackSmithUpgradeBuilding:IsMakingEquipment()
    return self.making_event:IsMaking()
end
function BlackSmithUpgradeBuilding:MakeEquipmentWithFinishTime(equipment, finished_time, id)
    local event = self.making_event
    event:SetContentWithFinishTime(equipment, finished_time, id)
    self.black_smith_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginMakeEquipmentWithEvent(self, event)
    end)
end
function BlackSmithUpgradeBuilding:EndMakeEquipmentWithCurrentTime()
    local event = self.making_event
    local equipment = event:Content()
    event:SetContentWithFinishTime(nil, 0)
    self.black_smith_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndMakeEquipmentWithEvent(self, event, equipment)
    end)
end
function BlackSmithUpgradeBuilding:GetMakingTimeByEquipment(equipment)
    local config = config_equipments[equipment]
    return config.makeTime
end

function BlackSmithUpgradeBuilding:OnTimer(current_time)
    local event = self.making_event
    if event:IsMaking() then
        self.black_smith_building_observer:NotifyObservers(function(lisenter)
            lisenter:OnMakingEquipmentWithEvent(self, event, current_time)
        end)
    end
    BlackSmithUpgradeBuilding.super.OnTimer(self, current_time)
end
function BlackSmithUpgradeBuilding:OnUserDataChanged(...)
    BlackSmithUpgradeBuilding.super.OnUserDataChanged(self, ...)
    local userData, current_time, location_id, sub_location_id, deltaData = ...
    local is_fully_update = deltaData == nil
    local is_delta_update = self:IsUnlocked() and deltaData and deltaData.dragonEquipmentEvents
    if not is_fully_update and not is_delta_update then
        return 
    end
    print("BlackSmithUpgradeBuilding:OnUserDataChanged")
    local event = userData.dragonEquipmentEvents[1]
    if event then
        local finished_time = event.finishTime / 1000
        if self:IsEquipmentEventEmpty() then
            self:MakeEquipmentWithFinishTime(event.name, finished_time, event.id)
        else
            self:GetMakeEquipmentEvent():SetContentWithFinishTime(event.name, finished_time, event.id)
        end
    elseif not self:IsEquipmentEventEmpty() then
        self:EndMakeEquipmentWithCurrentTime()
    end
end

return BlackSmithUpgradeBuilding



















