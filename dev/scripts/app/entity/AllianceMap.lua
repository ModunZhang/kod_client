local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local AllianceMap = class("AllianceMap", MultiObserver)
local allianceBuildingType = GameDatas.AllianceInitData.buildingType
AllianceMap.LISTEN_TYPE = Enum("BUILDING","BUILDING_LEVEL")

local mapObject_meta = {}
mapObject_meta.__index = mapObject_meta
function mapObject_meta:GetType()
    return self.type
end
function mapObject_meta:GetAllianceBuildingInfo()
    return self.alliance_map:FindAllianceBuildingInfoByObjects(self)
end
function mapObject_meta:GetAllianceVillageInfo()
    return self.alliance_map:FindAllianceVillagesInfoByObject(self)
end
function mapObject_meta:SetAllianceMap(alliance_map)
    self.alliance_map = alliance_map
    return self
end
function mapObject_meta:GetCategory()
    return allianceBuildingType[self.type].category
end
function mapObject_meta:Id()
    return self.id
end
function mapObject_meta:GetSize()
    local config = allianceBuildingType[self.type] or {width = 1, height = 1}
    return config.width, config.height
end
function mapObject_meta:GetLogicPosition()
    local location = self.location
    return location.x, location.y
end
function mapObject_meta:GetMidLogicPosition()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return (start_x + end_x) / 2, (start_y + end_y) / 2
end
function mapObject_meta:GetTopLeftPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return start_x, start_y
end
function mapObject_meta:GetTopRightPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return end_x, start_y
end
function mapObject_meta:GetBottomLeftPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return start_x, end_y
end
function mapObject_meta:GetBottomRightPoint()
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return end_x, end_y
end
function mapObject_meta:IsContainPoint(x, y)
    local start_x, end_x, start_y, end_y = self:GetGlobalRegion()
    return x >= start_x and x <= end_x and y >= start_y and y <= end_y
end
function mapObject_meta:GetGlobalRegion()
    local w, h = self:GetSize()
    local x, y = self:GetLogicPosition()

    local start_x, end_x, start_y, end_y

    local is_orient_x = w > 0
    local is_orient_neg_x = not is_orient_x
    local is_orient_y = h > 0
    local is_orient_neg_y = not is_orient_y

    if is_orient_x then
        start_x, end_x = x - w + 1, x
    elseif is_orient_neg_x then
        start_x, end_x = x, x + math.abs(w) - 1
    end

    if is_orient_y then
        start_y, end_y = y - h + 1, y
    elseif is_orient_neg_y then
        start_y, end_y = y, y + math.abs(h) - 1
    end
    return start_x, end_x, start_y, end_y
end




local function is_alliance_building(type_)
    return type_ == "building"
end
local function is_city(type_)
    return type_ == "member"
end
local function is_village(type_)
    return allianceBuildingType[type_].category == "village"
end
local function is_decorator(type_)
    return allianceBuildingType[type_].category == "decorate"
end
function AllianceMap:ctor(alliance)
    AllianceMap.super.ctor(self)
    self.alliance = alliance
    self.mapObjects = {}
    self.buildings = {}
end
function AllianceMap:Reset()
    self.mapObjects = {}
    self.buildings = {}
end
function AllianceMap:FindAllianceBuildingInfoByObjects(object)
    if object:GetType() == "building" then
        local x, y = object:GetLogicPosition()
        for k, v in pairs(self.buildings) do
            if v.location.x == x and v.location.y == y then
                return v
            end
        end
    end
end
function AllianceMap:FindAllianceBuildingInfoByName(name)
    for k, v in pairs(self.buildings) do
        if v.name == name then
            return v
        end
    end
end
function AllianceMap:IteratorAllianceBuildings(func)
    self:IteratorByCategory("building", func)
end
function AllianceMap:IteratorCities(func)
    self:IteratorByCategory("member", func)
end
function AllianceMap:IteratorVillages(func)
    self:IteratorByCategory("village", func)
end
function AllianceMap:IteratorDecorators(func)
    self:IteratorByCategory("decorate", func)
end
function AllianceMap:IteratorByCategory(category, func)
    self:IteratorAllObjects(function(k, v)
        if v:GetCategory() == category then
            if func(k, v) then
                return true
            end
        end
    end)
end
function AllianceMap:IteratorAllObjects(func)
    for k, v in pairs(self.mapObjects) do
        if func(k, v) then
            return
        end
    end
end
function AllianceMap:GetAlliance()
    return self.alliance
end
function AllianceMap:OnAllianceDataChanged(alliance_data)
    self:DecodeObjectsFromJsonMapObjects(alliance_data.mapObjects)
    self:DecodeObjectsFromJsonMapObjects__(alliance_data.__mapObjects)
    self:OnAllianceBuildingInfoChange(alliance_data.buildings)
end
function AllianceMap:FindAllianceVillagesInfoByObject(object)
    if is_village(object:GetType()) then
        local x, y = object:GetLogicPosition()
        for _,village_info in pairs(self:GetAlliance():GetAllianceVillageInfos()) do
            if village_info.location.x == x and village_info.location.y == y then 
               return village_info
            end
        end
    end
end
function AllianceMap:OnAllianceBuildingInfoChange(buildings)
    if not buildings then return end
    for k,new in pairs(buildings) do
        local old = self.buildings[k]
        self.buildings[k] = new
        local is_changed = old == nil and true or (old.level ~= new.level)
        if is_changed then
            self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING_LEVEL, function(listener)
                listener:OnBuildingLevelChange(new)
            end)
        end
    end
end
function AllianceMap:DecodeObjectsFromJsonMapObjects__(__mapObjects)
    if not __mapObjects then return end
    GameUtils:Event_Handler_Func(
        __mapObjects
        ,function(event_data)
            table.insert(self.mapObjects, setmetatable(event_data, mapObject_meta):SetAllianceMap(self))
        end
        ,function(event_data)
            assert(false, "会有修改吗?")
        end
        ,function(event_data)
            for i,v in ipairs(self.mapObjects) do
                if v.id == event_data.id then
                    table.remove(self.mapObjects, i)
                    break
                end
            end
        end
    )
    self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
        listener:OnBuildingChange(self)
    end)
end
function AllianceMap:DecodeObjectsFromJsonMapObjects(mapObjects)
    if not mapObjects then return end
    self.mapObjects = mapObjects
    for k,v in pairs(self.mapObjects) do
        setmetatable(v, mapObject_meta):SetAllianceMap(self)
    end
    self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
        listener:OnBuildingChange(self)
    end)
end


return AllianceMap

