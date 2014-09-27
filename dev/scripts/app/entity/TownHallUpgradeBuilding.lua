local config_function = GameDatas.BuildingFunction.townHall
local config_levelup = GameDatas.BuildingLevelUp.townHall
local Observer = import(".Observer")
local PResourceUpgradeBuilding = import(".PResourceUpgradeBuilding")
local TownHallUpgradeBuilding = class("TownHallUpgradeBuilding", PResourceUpgradeBuilding)



function TownHallUpgradeBuilding:ctor(building_info)
    self.townHall_building_observer = Observer.new()
    self.tax_event = self:CreateEvent()

    TownHallUpgradeBuilding.super.ctor(self, building_info)
end
function TownHallUpgradeBuilding:CreateEvent()
    local townHall = self
    local event = {}
    function event:Init()
        self:Reset()
    end
    function event:Reset()
        self.tax = nil
        self.finished_time = 0
    end
    function event:Percent(current_time)
        local start_time = self:StartTime()
        local elapse_time = current_time - start_time
        local total_time = self.finished_time - start_time
        return elapse_time * 100.0 / total_time
    end
    function event:StartTime()
        return self.finished_time - townHall:GetImposeTime()
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
    function event:UpdateFinishTime(current_time)
        self.finished_time = current_time
    end
    function event:IsEmpty()
        return self.tax == nil
    end
    function event:IsRunning()
        return self.tax and self.finished_time ~= 0
    end
    function event:Value()
        return self.tax
    end
    function event:UpdateValueWithFinishTime(value, finished_time)
        self.tax = value
        self.finished_time = finished_time
    end
    event:Init()
    return event
end
function TownHallUpgradeBuilding:AddTownHallListener(listener)
    assert(listener.OnBeginImposeWithEvent)
    assert(listener.OnImposingWithEvent)
    assert(listener.OnEndImposeWithEvent)
    self.townHall_building_observer:AddObserver(listener)
end
function TownHallUpgradeBuilding:RemoveTownHallListener(listener)
    self.townHall_building_observer:RemoveObserver(listener)
end
function TownHallUpgradeBuilding:GetTaxEvent()
    return self.tax_event
end
function TownHallUpgradeBuilding:IsEmpty()
    return self.tax_event:IsEmpty()
end
function TownHallUpgradeBuilding:IsInImposing()
    return self.tax_event:IsRunning()
end
function TownHallUpgradeBuilding:ImposeWithFinishedTime(tax, finished_time)
    local event = self.tax_event
    event:UpdateValueWithFinishTime(tax, finished_time)

    self.townHall_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginImposeWithEvent(self, event)
    end)
end
function TownHallUpgradeBuilding:EndImposeWithCurrentTime(current_time)
    local event = self.tax_event
    event:Reset()
    self.townHall_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndImposeWithEvent(self, event, current_time)
    end)
end
function TownHallUpgradeBuilding:GetImposeTime()
    local _, _, time = self:GetImposeInfo()
    return time
end
function TownHallUpgradeBuilding:GetImposeInfo()
    local config = config_function[self:GetLevel()]
    return config.taxCitizen, config.totalTax, config.taxTime
end


function TownHallUpgradeBuilding:OnTimer(current_time)
    local event = self.tax_event
    if event:IsRunning() then
        self.townHall_building_observer:NotifyObservers(function(lisenter)
            lisenter:OnImposingWithEvent(self, event, current_time)
        end)
    end
    TownHallUpgradeBuilding.super.OnTimer(self, current_time)
end

function TownHallUpgradeBuilding:OnUserDataChanged(...)
    TownHallUpgradeBuilding.super.OnUserDataChanged(self, ...)

    local arg = {...}
    local current_time = arg[2]
    local coinEvents = arg[1].coinEvents

    local event = coinEvents[1]
    if event then
        local finished_time = event.finishTime / 1000
        local is_making_end = finished_time == 0
        if self:IsEmpty() then
            self:ImposeWithFinishedTime(event.coin, finished_time)
        else
            self:GetTaxEvent():UpdateValueWithFinishTime(event.coin, finished_time)
        end
    else
        if not self:IsEmpty() then
            self:EndImposeWithCurrentTime(event.coin, current_time)
        end
    end
end


function TownHallUpgradeBuilding:GetNextLevelDwellingNum()
    return config_function[self:GetNextLevel()].dwelling
end
function TownHallUpgradeBuilding:GetNextLevelTotalTax()
    return config_function[self:GetNextLevel()].totalTax
end
return TownHallUpgradeBuilding














