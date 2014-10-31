local Enum = import("..utils.Enum")
local MultiObserver = import(".MultiObserver")
local AllianceMap = class("AllianceMap", MultiObserver)
AllianceMap.LISTEN_TYPE = Enum("AAA")

local villages_map = {
    woodVillage = true,
    stoneVillage = true,
    ironVillage = true,
    foodVillage = true,
    coinVillage = true,
}
local function is_village(type_)
    return villages_map[type_]
end
local function is_city(type_)
    return type_ == "member"
end
local function is_alliance_building(type_)
    return type_ == "building"
end
local decorators_map = {
    decorate_lake_1 = true,
    decorate_lake_2 = true,
    decorate_mountain_1 = true,
    decorate_mountain_2 = true,
    decorate_tree_1 = true,
    decorate_tree_2 = true,
}
local function is_decorator(type_)
    return decorators_map[type_]
end
function AllianceMap:ctor(alliance)
    AllianceMap.super.ctor(self)
    self.alliance = alliance
    self.alliance_buildings = {}
    self.cities = {}
    self.villages = {}
    self.decorators = {}
end
function AllianceMap:IteratorAllObjects(func)
    local handle = false
    local handle_func = function(k, v)
        if func(k, v) then
            handle = true
            return true
        end
    end
    repeat
        self:IteratorAllianceBuildings(func)
        if handle then break end
        self:IteratorCities(func)
        if handle then break end
        self:IteratorVillages(func)
        if handle then break end
        self:IteratorDecorators(func)
    until true
end
function AllianceMap:IteratorAllianceBuildings(func)
    table.foreachi(self.alliance_buildings, func)
end
function AllianceMap:IteratorCities(func)
    table.foreachi(self.cities, func)
end
function AllianceMap:IteratorVillages(func)
    table.foreachi(self.villages, func)
end
function AllianceMap:IteratorDecorators(func)
    table.foreachi(self.decorators, func)
end
function AllianceMap:GetAlliance()
    return self.alliance
end
function AllianceMap:OnAllianceDataChanged(alliance_data)
    for k, v in pairs(alliance_data) do
        if "mapObjects" == k then
            self:DecodeObjectsFromJsonMapObjects(v)
        end
    end
    return
end
function AllianceMap:DecodeObjectsFromJsonMapObjects(mapObjects)
	dump(mapObjects)
    local alliance_buildings = {}
    local cities = {}
    local villages = {}
    local decorators = {}
    for _, v in ipairs(mapObjects) do
    	local type_ = v.type
        if is_alliance_building(type_) then
            table.insert(alliance_buildings, v)
        elseif is_city(type_) then
            table.insert(cities, v)
        elseif is_village(type_) then
            table.insert(villages, v)
        elseif is_decorator(type_) then
            table.insert(decorators, v)
        end
    end
    self.alliance_buildings = alliance_buildings
    self.cities = cities
    self.villages = villages
    self.decorators = decorators
end
return AllianceMap






