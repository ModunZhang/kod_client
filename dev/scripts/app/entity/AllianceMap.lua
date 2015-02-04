local Enum = import("..utils.Enum")
local AllianceObject = import(".AllianceObject")
local MultiObserver = import(".MultiObserver")
local AllianceMap = class("AllianceMap", MultiObserver)
local allianceBuildingType = GameDatas.AllianceInitData.buildingType
AllianceMap.LISTEN_TYPE = Enum("BUILDING","BUILDING_LEVEL")

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
    self.all_objects = {}
    self.allliance_buildings = {}
    
end
function AllianceMap:Reset()
    self.all_objects = {}
    self.allliance_buildings = {}
end
function AllianceMap:FindAllianceBuildingInfoByObjects(object)
    if object:GetType() == "building" then
        local x, y = object:GetLogicPosition()
        for k, v in pairs(self.allliance_buildings) do
            if v.location.x == x and v.location.y == y then
                return v
            end
        end
    end
end
function AllianceMap:FindAllianceBuildingInfoByName(name)
    for k, v in pairs(self.allliance_buildings) do
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
    for k, v in pairs(self.all_objects) do
        if func(k, v) then
            return
        end
    end
end
function AllianceMap:AddObjectById(object)
    assert(not self.all_objects[object:Id()])
    self.all_objects[object:Id()] = object
    return object
end
function AllianceMap:RemoveObjectById(id)
    local old = self.all_objects[id]
    self.all_objects[id] = nil
    return old
end
function AllianceMap:GetObjectById(id)
    return self.all_objects[id]
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

function AllianceMap:OnAllianceBuildingInfoChange(alliance_buildings)
    if not alliance_buildings then return end
    for k, v in pairs(alliance_buildings) do
        local old = self.allliance_buildings[k]
        self.allliance_buildings[k] = v
        if v.level ~= old then
            print("v.level", v.level)
            self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING_LEVEL, function(listener)
                listener:OnBuildingLevelChange(v)
            end)
        end
    end
end
function AllianceMap:DecodeObjectsFromJsonMapObjects__(__mapObjects)
    if not __mapObjects then return end
    local add = {}
    local remove = {}
    local edit = {}
    for i, v in ipairs(__mapObjects) do
        local type_ = v.type
        local data = v.data
        if type_ == "edit" then
            local object = self:GetObjectById(data.id)
            object:SetLogicPosition(data.location.x, data.location.y)
            table.insert(edit, object)
        elseif type_ == "add" then
            local object = self:AddObjectById(AllianceObject.new(data.type, data.id, data.location.x, data.location.y, self))
            table.insert(add, object)
        elseif type_ == "remove" then
            local object = self:RemoveObjectById(data.id)
            table.insert(remove, object)
        end
    end
    self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
        listener:OnBuildingChange(self, add, remove, edit)
    end)
end
function AllianceMap:DecodeObjectsFromJsonMapObjects(mapObjects)
    if not mapObjects then return end
    local all_objects = {}
    local add = {}
    local remove = {}
    local modify = {}
    for _, v in ipairs(mapObjects) do
        local type_ = v.type
        local location_ = v.location
        local id = v.id
        local old = self.all_objects[id]
        if old then
            all_objects[id] = old
            if location_.x ~= old.x or location_.y ~= old.y then
                old:SetLogicPosition(location_.x, location_.y)
                table.insert(modify, old)
            end
        else
            local object = AllianceObject.new(type_, id, location_.x, location_.y, self)
            all_objects[id] = object
            table.insert(add, object)
        end
        self.all_objects[id] = nil
    end
    for k, v in pairs(self.all_objects) do
        table.insert(remove, v)
    end
    self.all_objects = all_objects
    self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
        listener:OnBuildingChange(self, add, remove, modify)
    end)
end


return AllianceMap

