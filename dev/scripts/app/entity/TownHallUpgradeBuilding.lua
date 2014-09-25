local config_function = GameDatas.BuildingFunction.townHall
local config_levelup = GameDatas.BuildingLevelUp.townHall
local Observer = import(".Observer")
local UpgradeBuilding = import(".UpgradeBuilding")
local TownHallUpgradeBuilding = class("TownHallUpgradeBuilding", UpgradeBuilding)



function TownHallUpgradeBuilding:ctor(building_info)
    self.toolShop_building_observer = Observer.new()
    self.building_event = self:CreateEvent("building")

    TownHallUpgradeBuilding.super.ctor(self, building_info)
end
function TownHallUpgradeBuilding:CreateEvent(category)
    local event = {}
    function event:Init()
        self:Reset()
    end
    function event:Reset()
        self.finished_time = 0
    end
    function event:Percent(current_time)
        local start_time = self:StartTime()
        local elapse_time = current_time - start_time
        local total_time = self.finished_time - start_time
        return elapse_time * 100.0 / total_time
    end
    function event:StartTime()
        return 0
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
        return self.finished_time == 0
    end
    function event:IsRunning(current_time)
        return current_time < self.finished_time
    end
    event:Init()
    return event
end
function TownHallUpgradeBuilding:AddToolShopListener(listener)
    assert(listener.OnBeginMakeMaterialsWithEvent)
    assert(listener.OnMakingMaterialsWithEvent)
    assert(listener.OnEndMakeMaterialsWithEvent)
    assert(listener.OnGetMaterialsWithEvent)
    self.toolShop_building_observer:AddObserver(listener)
end
function TownHallUpgradeBuilding:RemoveToolShopListener(listener)
    self.toolShop_building_observer:RemoveObserver(listener)
end
function TownHallUpgradeBuilding:GetMakeMaterialsEventByCategory(category)
    return self.category[category]
end
function TownHallUpgradeBuilding:IsMaterialsEmptyByCategory(category)
    return self.category[category]:IsEmpty()
end
function TownHallUpgradeBuilding:IsStoredMaterialsByCategory(category, current_time)
    return self.category[category]:IsStored(current_time)
end
function TownHallUpgradeBuilding:IsMakingMaterialsByCategory(category, current_time)
    return self.category[category]:IsMaking(current_time)
end
function TownHallUpgradeBuilding:MakeMaterialsByCategoryWithFinishTime(category, materials, finished_time)
    local event = self.category[category]
    event:SetContent(materials, finished_time)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginMakeMaterialsWithEvent(self, event)
    end)
end
function TownHallUpgradeBuilding:EndMakeMaterialsByCategoryWithCurrentTime(category, materials, current_time)
    local event = self.category[category]
    event:SetContent(materials, 0)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndMakeMaterialsWithEvent(self, event, current_time)
    end)
end
function TownHallUpgradeBuilding:GetMaterialsByCategory(category)
    local event = self.category[category]
    local materials = event:Content()
    event:Reset()
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnGetMaterialsWithEvent(self, event, materials)
    end)
end
function TownHallUpgradeBuilding:GetMakingTimeByCategory(category)
    local _, _, _, _, time = self:GetNeedByCategory(category)
    return time
end

function TownHallUpgradeBuilding:OnTimer(current_time)
    TownHallUpgradeBuilding.super.OnTimer(self, current_time)
end

function TownHallUpgradeBuilding:OnUserDataChanged(...)
    TownHallUpgradeBuilding.super.OnUserDataChanged(self, ...)

    local arg = {...}
    local current_time = arg[2]
    local materialEvents = arg[1].materialEvents
end

return TownHallUpgradeBuilding














