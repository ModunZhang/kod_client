local config_function = GameDatas.BuildingFunction.toolShop
local config_levelup = GameDatas.BuildingLevelUp.toolShop
local Observer = import(".Observer")
local UpgradeBuilding = import(".UpgradeBuilding")
local ToolShopUpgradeBuilding = class("ToolShopUpgradeBuilding", UpgradeBuilding)


function ToolShopUpgradeBuilding:ctor(building_info)
    ToolShopUpgradeBuilding.super.ctor(self, building_info)
    self.toolShop_building_observer = Observer.new()
    local tool_shop = self
    local event = {}
    function event:Reset()
        self.category = nil
        self.materials = {}
        self.finished_time = 0
    end
    function event:StartTime()
        return self.finished_time - tool_shop:GetMakingTime(self.category)
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
    function event:SetMaterials(category, materials, finished_time)
        self.category = category
        self.materials = materials
        self.finished_time = finished_time
    end
    event:Reset()
    self.event = event
end
function ToolShopUpgradeBuilding:AddToolShopListener(listener)
    assert(listener.OnBeginMakeMaterials)
    assert(listener.OnMakingMaterials)
    assert(listener.OnEndMakeMaterials)
    assert(listener.OnGetMaterials)
    self.toolShop_building_observer:AddObserver(listener)
end
function ToolShopUpgradeBuilding:RemoveToolShopListener(listener)
    self.toolShop_building_observer:RemoveObserver(listener)
end
--
function ToolShopUpgradeBuilding:GetEvent()
    return self.event
end
function ToolShopUpgradeBuilding:IsEmpty()
    return self.event:FinishTime() == 0
end
function ToolShopUpgradeBuilding:IsStoredMaterials(current_time)
    return self.event:FinishTime() and self.event:FinishTime() <= current_time
end
function ToolShopUpgradeBuilding:IsMakingMaterials(current_time)
    return self.event:FinishTime() and self.event:FinishTime() > current_time
end
function ToolShopUpgradeBuilding:GetMakingTime(category)
    local config = config_function[self:GetLevel()]
    if category == "building" then
        return config["productBmtime"]
    elseif category == "technology" then
        return config["productAmtime"]
    end
end
function ToolShopUpgradeBuilding:MakeBuildingMaterials(materials, finished_time)
    self.event:SetMaterials("building", materials, finished_time)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginMakeMaterials(self)
    end)
end
function ToolShopUpgradeBuilding:EndMakeMaterials(current_time)
    self.event:SetFinishTime(current_time)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndMakeMaterials(self, current_time)
    end)
end
function ToolShopUpgradeBuilding:GetMaterials()
    self.event:Reset()
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnGetMaterials(self)
    end)
end
function ToolShopUpgradeBuilding:OnTimer(current_time)
    if self:IsMakingMaterials(current_time) then
        self.toolShop_building_observer:NotifyObservers(function(lisenter)
            lisenter:OnMakingMaterials(self, current_time)
        end)
    end
    ToolShopUpgradeBuilding.super.OnTimer(self, current_time)
end

return ToolShopUpgradeBuilding








