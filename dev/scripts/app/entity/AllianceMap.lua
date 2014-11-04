local Enum = import("..utils.Enum")
local AllianceObject = import(".AllianceObject")
local MultiObserver = import(".MultiObserver")
local AllianceMap = class("AllianceMap", MultiObserver)
local allianceBuildingType = GameDatas.AllianceInitData.buildingType
AllianceMap.LISTEN_TYPE = Enum("BUILDING")

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
    for k, v in pairs(alliance_data) do
        if "mapObjects" == k then
            self:DecodeObjectsFromJsonMapObjects(v)
        elseif "__mapObjects" == k then
            self:DecodeObjectsFromJsonMapObjects__(v)
        end
    end
    return
end
function AllianceMap:DecodeObjectsFromJsonMapObjects__(__mapObjects)
    local data = __mapObjects.data
    if __mapObjects.type == "edit" then
        local object = self:GetObjectById(data.id)
        object:SetLogicPosition(data.location.x, data.location.y)
        self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
            listener:OnBuildingChange(self, {}, {}, {object})
        end)
    elseif __mapObjects.type == "add" then
        local object = self:AddObjectById(AllianceObject.new(data.type, data.id, data.location.x, data.location.y))
        self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
            listener:OnBuildingChange(self, {object}, {}, {})
        end)
    elseif __mapObjects.type == "remove" then
        local object = self:RemoveObjectById(data.id)
        self:NotifyListeneOnType(AllianceMap.LISTEN_TYPE.BUILDING, function(listener)
            listener:OnBuildingChange(self, {}, {object}, {})
        end)
    end
end
function AllianceMap:DecodeObjectsFromJsonMapObjects(mapObjects)
    local all_objects = {}
    local add = {}
    local remove = {}
    local modify = {}
    for _, v in ipairs(mapObjects) do
        local type_ = v.type
        local location_ = v.location
        local id = v.id
        local old = self.all_objects[id]
        if not old then
            local object = AllianceObject.new(type_, id, location_.x, location_.y)
            all_objects[id] = object
            table.insert(add, object)
        elseif location_.x ~= old.x or location_.y ~= old.y then
            old:SetLogicPosition(location_.x, location_.y)
            all_objects[id] = old
            table.insert(modify, old)
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














