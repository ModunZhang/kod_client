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
        self.content = {}
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
    function event:TotalCount()
        local count = 0
        for k, v in pairs(self.content) do
            count = count + v.count
        end
        return count
    end
    function event:Content()
        return self.content
    end
    function event:SetContent(content, finished_time)
        self.content = content == nil and {} or content
        self.finished_time = finished_time
    end
    function event:IsStored(current_time)
        return #self.content > 0 and (self.finished_time == 0 or current_time >= self.finished_time)
    end
    function event:IsEmpty()
        return self.finished_time == 0 and #self.content == 0
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
function ToolShopUpgradeBuilding:MakeMaterialsByCategoryWithFinishTime(category, materials, finished_time)
    local event = self.category[category]
    event:SetContent(materials, finished_time)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnBeginMakeMaterialsWithEvent(self, event)
    end)
end
function ToolShopUpgradeBuilding:EndMakeMaterialsByCategoryWithCurrentTime(category, materials, current_time)
    local event = self.category[category]
    event:SetContent(materials, 0)
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnEndMakeMaterialsWithEvent(self, event, current_time)
    end)
end
function ToolShopUpgradeBuilding:GetMaterialsByCategory(category)
    local event = self.category[category]
    local materials = event:Content()
    event:Reset()
    self.toolShop_building_observer:NotifyObservers(function(lisenter)
        lisenter:OnGetMaterialsWithEvent(self, event, materials)
    end)
end
function ToolShopUpgradeBuilding:GetMakingTimeByCategory(category)
    local _, _, _, _, time = self:GetNeedByCategory(category)
    return time
end
local needs = {"Wood", "Stone", "Iron", "time"}
function ToolShopUpgradeBuilding:GetNeedByCategory(category)
    local config = config_function[self:GetLevel()]
    local key = category == "building" and "Bm" or "Am"
    local need = {}
    for _, v in ipairs(needs) do
        table.insert(need, config[string.format("product%s%s", key, v)])
    end
    return config["poduction"], unpack(need)
end
function ToolShopUpgradeBuilding:GetNextLevelPoducttion()
    local config = config_function[self:GetNextLevel()]
    return config["poduction"]
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
    ToolShopUpgradeBuilding.super.OnUserDataChanged(self, ...)
    
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
                self:EndMakeMaterialsByCategoryWithCurrentTime(category, event.materials, current_time)
            elseif self:IsMaterialsEmptyByCategory(category) then
                self:MakeMaterialsByCategoryWithFinishTime(category, event.materials, finished_time)
            else
                self:GetMakeMaterialsEventByCategory(category):SetContent(event.materials, finished_time)
            end
        else
            if self:IsStoredMaterialsByCategory(category, current_time) then
                self:GetMaterialsByCategory(category)
            end
        end
    end
end

return ToolShopUpgradeBuilding













