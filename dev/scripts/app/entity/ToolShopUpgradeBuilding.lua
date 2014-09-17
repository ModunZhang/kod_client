local config_function = GameDatas.BuildingFunction.toolShop
local config_levelup = GameDatas.BuildingLevelUp.toolShop
local Observer = import(".Observer")
local UpgradeBuilding = import(".UpgradeBuilding")
local ToolShopUpgradeBuilding = class("ToolShopUpgradeBuilding", UpgradeBuilding)


local TECHNOLOGY = "technology"
local BUILDING = "building"

function ToolShopUpgradeBuilding:ctor(building_info)
    self.toolShop_building_observer = Observer.new()
    self.building_event = self:CreateEvent("building")
    self.technology_event = self:CreateEvent("technology")
    self.category = {
        building = self.building_event,
        technology = self.technology_event,
    }

    ToolShopUpgradeBuilding.super.ctor(self, building_info)
end
function ToolShopUpgradeBuilding:CreateEvent(category)
    local tool_shop = self
    local event = {}
    function event:Init(category)
        self.category = category
        self:Reset()
    end
    function event:Reset()
        self.materials = {}
        self.finished_time = 0
    end
    function event:Category()
        return self.category
    end
    function event:StartTime()
        return self.finished_time - tool_shop:GetMakingTimeByCategory(self.category)
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
    function event:SetMaterials(materials, finished_time)
        self.materials = materials == nil and {} or materials
        self.finished_time = finished_time
    end
    function event:IsStored(current_time)
        return #self.materials > 0 and (self.finished_time == 0 or current_time >= self.finished_time)
    end
    function event:IsEmpty()
        return self.finished_time == 0 and #self.materials == 0
    end
    function event:IsMaking(current_time)
        return current_time < self.finished_time
    end
    event:Init(category)
    return event
end
function ToolShopUpgradeBuilding:AddToolShopListener(listener)
    assert(listener.OnBeginMakeMaterialsWithEvent)
    assert(listener.OnMakingMaterialsWithEvent)
    assert(listener.OnEndMakeMaterialsWithEvent)
    assert(listener.OnGetMaterialsWithEvent)
    self.toolShop_building_observer:AddObserver(listener)
end
function ToolShopUpgradeBuilding:RemoveToolShopListener(listener)
    self.toolShop_building_observer:RemoveObserver(listener)
end

--
function ToolShopUpgradeBuilding:GetMakeBuildingMaterialsEvent()
    return self:GetMakeMaterialsEventByCategory(BUILDING)
end
function ToolShopUpgradeBuilding:IsBuildingMaterialsEmpty()
    return self:IsMaterialsEmptyByCategory(BUILDING)
end
function ToolShopUpgradeBuilding:IsStoredBuildingMaterials(current_time)
    return self:IsStoredMaterialsByCategory(BUILDING, current_time)
end
function ToolShopUpgradeBuilding:IsMakingBuildingMaterials(current_time)
    return self:IsMakingMaterialsByCategory(BUILDING, current_time)
end
function ToolShopUpgradeBuilding:MakeBuildingMaterials(materials, finished_time)
    self:MakeMaterialsByCategory(BUILDING, materials, finished_time)
end
function ToolShopUpgradeBuilding:EndMakeBuildingMaterials(materials, current_time)
    self:EndMakeMaterialsByCategory(BUILDING, materials, current_time)
end
function ToolShopUpgradeBuilding:GetBuildingMaterials()
    self:GetMaterialsByCategory(BUILDING)
end

--
function ToolShopUpgradeBuilding:GetMakeTechnologyMaterialsEvent()
    return self:GetMakeMaterialsEventByCategory(TECHNOLOGY)
end
function ToolShopUpgradeBuilding:IsTechnologyMaterialsEmpty()
    return self:IsMaterialsEmptyByCategory(TECHNOLOGY)
end
function ToolShopUpgradeBuilding:IsStoredTechnologyMaterials(current_time)
    return self:IsStoredMaterialsByCategory(TECHNOLOGY, current_time)
end
function ToolShopUpgradeBuilding:IsMakingTechnologyMaterials(current_time)
    return self:IsMakingMaterialsByCategory(TECHNOLOGY, current_time)
end
function ToolShopUpgradeBuilding:MakeTechnologyMaterials(materials, finished_time)
    self:MakeMaterialsByCategory(TECHNOLOGY, materials, finished_time)
end
function ToolShopUpgradeBuilding:EndMakeTechnologyMaterials(materials, current_time)
    self:EndMakeMaterialsByCategory(TECHNOLOGY, materials, current_time)
end
function ToolShopUpgradeBuilding:GetTechnologyMaterials()
    self:GetMaterialsByCategory(TECHNOLOGY)
end
--

function ToolShopUpgradeBuilding:GetMakeMaterialsEventByCategory(category)
    return self.category[category]
end
function ToolShopUpgradeBuilding:IsMaterialsEmptyByCategory(category)
    return self.category[category]:IsEmpty()
end
function ToolShopUpgradeBuilding:IsStoredMaterialsByCategory(category, current_time)
    return self.category[category]:IsStored(current_time)
end
function ToolShopUpgradeBuilding:IsMakingMaterialsByCategory(category, current_time)
    return self.category[category]:IsMaking(current_time)
end
function ToolShopUpgradeBuilding:MakeMaterialsByCategory(category, materials, finished_time)
    local event = self.category[category]
    event:SetMaterials(materials, finished_time)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginMakeMaterialsWithEvent(self, event)
    end)
end
function ToolShopUpgradeBuilding:EndMakeMaterialsByCategory(category, materials, current_time)
    local event = self.category[category]
    event:SetMaterials(materials, 0)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndMakeMaterialsWithEvent(self, event, current_time)
    end)
end
function ToolShopUpgradeBuilding:GetMaterialsByCategory(category)
    local event = self.category[category]
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnGetMaterialsWithEvent(self, event)
    end)
    event:Reset()
end
function ToolShopUpgradeBuilding:GetMakingTimeByCategory(category)
    local config = config_function[self:GetLevel()]
    if category == "building" then
        return config["productBmtime"]
    elseif category == "technology" then
        return config["productAmtime"]
    end
end

function ToolShopUpgradeBuilding:OnTimer(current_time)
    for _, event in pairs(self.category) do
        if event:IsMaking(current_time) then
            self.toolShop_building_observer:NotifyObservers(function(lisenter)
                lisenter:OnMakingMaterialsWithEvent(self, event, current_time)
            end)
        end
    end
    ToolShopUpgradeBuilding.super.OnTimer(self, current_time)
end

function ToolShopUpgradeBuilding:OnUserDataChanged(...)
    local arg = {...}
    local current_time = arg[2]
    local materialEvents = arg[1].materialEvents

    local BUILDING_EVENT = 1
    local TECHNOLOGY_EVENT = 2
    local category_map = {
        [BUILDING_EVENT] = "building",
        [TECHNOLOGY_EVENT] = "technology",
    }
    local events = {
        [BUILDING_EVENT] = nil,
        [TECHNOLOGY_EVENT] = nil,
    }

    for k, v in pairs(materialEvents) do
        if v.category == "building" then
            events[BUILDING_EVENT] = v
        elseif v.category == "technology" then
            events[TECHNOLOGY_EVENT] = v
        end
    end

    for category_index, category in ipairs(category_map) do
        local event = events[category_index]
        if event then
            local finished_time = event.finishTime / 1000
            local is_making_end = finished_time == 0
            if is_making_end then
                self:EndMakeMaterialsByCategory(category, event.materials, current_time)
            elseif self:IsBuildingMaterialsEmpty() then
                self:MakeMaterialsByCategory(category, event.materials, finished_time)
            else
                self:GetMakeMaterialsEventByCategory(category):SetMaterials(event.materials, finished_time)
            end
        else
            if self:IsStoredMaterialsByCategory(category, current_time) then
                self:GetMaterialsByCategory(category)
            end
        end
    end

    ToolShopUpgradeBuilding.super.OnUserDataChanged(self, ...)
end

return ToolShopUpgradeBuilding













