local config_equipments = GameDatas.SmithConfig.equipments
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
function BlackSmithUpgradeBuilding:CreateEvent()
    local black_smith = self
    local event = {}
    function event:Init()
        self:Reset()
    end
    function event:Reset()
        self.content = nil
        self.finished_time = 0
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
    function event:FinishTime()
        return self.finished_time
    end
    function event:SetFinishTime(current_time)
        self.finished_time = current_time
    end
    function event:Content()
        return self.content
    end
    function event:SetContent(content, finished_time)
        self.content = content
        self.finished_time = finished_time
    end
    function event:IsStored(current_time)
        return self.content ~= nil and (self.finished_time == 0 or current_time >= self.finished_time)
    end
    function event:IsEmpty()
        return self.finished_time == 0 and self.content == nil
    end
    function event:IsMaking(current_time)
        return current_time < self.finished_time
    end
    event:Init()
    return event
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
function BlackSmithUpgradeBuilding:IsMakingEquipment(current_time)
    return self.making_event:IsMaking(current_time)
end
function BlackSmithUpgradeBuilding:MakeEquipment(equipment, finished_time)
    local event = self.making_event
    event:SetContent(equipment, finished_time)
    self.black_smith_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginMakeEquipmentWithEvent(self, event)
    end)
end
function BlackSmithUpgradeBuilding:EndMakeEquipment(current_time)
    local event = self.making_event
    local equipment = event:Content()
    event:SetContent(nil, 0)
    self.black_smith_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndMakeEquipmentWithEvent(self, event, equipment)
    end)
end
function BlackSmithUpgradeBuilding:GetMakingTimeByEquipment(equipment)
    local config = config_equipments[equipment]
    return config.makeTime
end
function BlackSmithUpgradeBuilding:OnTimer(current_time)
    if self.making_event:IsMaking(current_time) then
        self.black_smith_building_observer:NotifyObservers(function(lisenter)
            lisenter:OnMakingEquipmentWithEvent(self, self.making_event, current_time)
        end)
    end
    BlackSmithUpgradeBuilding.super.OnTimer(self, current_time)
end

function BlackSmithUpgradeBuilding:OnUserDataChanged(...)
    BlackSmithUpgradeBuilding.super.OnUserDataChanged(self, ...)
end

return BlackSmithUpgradeBuilding














