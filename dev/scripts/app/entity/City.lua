local HOUSES = GameDatas.PlayerInitData.houses[1]
local config_productionTechs = GameDatas.ProductionTechs.productionTechs
local GrowUpTaskManager = import(".GrowUpTaskManager")
local BuildingRegister = import(".BuildingRegister")
local promise = import("..utils.promise")
local Enum = import("..utils.Enum")
local Orient = import(".Orient")
local Tile = import(".Tile")
local SoldierManager = import(".SoldierManager")
local MaterialManager = import(".MaterialManager")
local ResourceManager = import(".ResourceManager")
local Building = import(".Building")
local TowerEntity = import(".TowerEntity")
local TowerUpgradeBuilding = import(".TowerUpgradeBuilding")
local MultiObserver = import(".MultiObserver")
local property = import("..utils.property")
local ProductionTechnology = import(".ProductionTechnology")
local ProductionTechnologyEvent = import(".ProductionTechnologyEvent")
local City = class("City", MultiObserver)
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max = math.max
-- 枚举定义
City.RETURN_CODE = Enum(
    "INNER_ROUND_NOT_UNLOCKED",
    "EDGE_BESIDE_NOT_UNLOCKED",
    "HAS_NO_UNLOCK_POINT",
    "HAS_UNLOCKED",
    "OUT_OF_BOUND")
City.LISTEN_TYPE = Enum(
    "LOCK_TILE",
    "UNLOCK_TILE",
    "UNLOCK_ROUND",
    "CREATE_DECORATOR",
    "OCCUPY_RUINS",
    "DESTROY_DECORATOR",
    "UPGRADE_BUILDING",
    "CITY_NAME",
    "HELPED_BY_TROOPS",
    "HELPED_TO_TROOPS",
    "PRODUCTION_DATA_CHANGED",
    "PRODUCTION_EVENT_CHANGED",
    "PRODUCTION_EVENT_TIMER",
    "PRODUCTION_EVENT_REFRESH")
City.RESOURCE_TYPE_TO_BUILDING_TYPE = {
    [ResourceManager.RESOURCE_TYPE.WOOD] = "woodcutter",
    [ResourceManager.RESOURCE_TYPE.FOOD] = "farmer",
    [ResourceManager.RESOURCE_TYPE.IRON] = "miner",
    [ResourceManager.RESOURCE_TYPE.STONE] = "quarrier",
    [ResourceManager.RESOURCE_TYPE.POPULATION] = "dwelling",
}
local only_one_buildings_map = {
    keep            = true,
    watchTower      = true,
    warehouse       = true,
    dragonEyrie     = true,
    barracks        = true,
    hospital        = true,
    academy         = true,
    materialDepot   = true,
    blackSmith      = true,
    tradeGuild      = true,
    townHall        = true,
    toolShop        = true,
    trainingGround  = true,
    hunterHall      = true,
    stable          = true,
    workshop        = true,
}
local illegal_map = {
    location_21 = true,
    location_22 = true
}
local function illegal_filter(key, func)
    if illegal_map[key] then return end
    func()
end
-- 初始化
function City:ctor(json_data)
    City.super.ctor(self)
    self.resource_manager = ResourceManager.new()
    self.soldier_manager = SoldierManager.new()
    self.material_manager = MaterialManager.new()

    self.belong_user = nil
    self.buildings = {}
    self.walls = {}
    self.tower = TowerEntity.new({building_type = "tower", city = self}):AddUpgradeListener(self)
    self.visible_towers = {}
    self.decorators = {}
    self.helpedByTroops = {}
    self.helpToTroops = {}
    self.productionTechs = {}
    self.productionTechEvents = {}
    self.build_queue = 0
    self.locations_decorators = {}
    self:InitLocations()
    self:InitRuins()

    if json_data then
        self:InitWithJsonData(json_data)
    end

    --
    self.upgrading_building_callbacks = {}
    self.finish_upgrading_callbacks = {}
end
function City:GetRecommendTask()
    local building_map = {}
    self:IteratorCanUpgradeBuildings(function(building)
        if building:IsUnlocked() then
            local highest = building_map[building:GetType()]
            building_map[building:GetType()] = not highest and 
            building or 
            (building:GetLevel() > highest:GetLevel() and 
                building or 
                highest)
        end
    end)
    for k,v in pairs(building_map) do
        if v:IsUpgrading() or not v:CanUpgrade() then
            building_map[k] = nil
        end
    end
    local tasks = self:GetUser():GetTaskManager():GetAvailableTasksByCategory(GrowUpTaskManager.TASK_CATEGORY.BUILD)
    local re_task
    for i,v in pairs(tasks.tasks) do
        if building_map[v:BuildingType()] then
            re_task = not re_task and v or (v.index < re_task.index and v or re_task)
        end
    end
    return re_task
end
function City:GetUser()
    return self.belong_user
end
function City:SetUser(user)
    assert(not self.belong_user, "用户一经指定就不可更改")
    self.belong_user = user
    return self
end
local function get_building_event_by_location(location_id, building_events)
    for k, v in pairs(building_events or {}) do
        if v.location == location_id then
            return v
        end
    end
end
local function get_house_event_by_location(building_location, sub_id, hosue_events)
    for _,v in pairs(hosue_events or {}) do
        if v.buildingLocation == building_location and
            v.houseLocation == sub_id then
            return v
        end
    end
end
function City:InitWithJsonData(userData)
    local init_buildings = {}
    local init_unlock_tiles = {}

    local building_events = userData.buildingEvents
    table.foreach(userData.buildings, function(key, location)
        illegal_filter(key, function()
            local location_config = self:GetLocationById(location.location)
            local event = get_building_event_by_location(location.location, building_events)
            local finishTime = event == nil and 0 or event.finishTime / 1000
            table.insert(init_buildings,
                self:NewBuildingWithType(location.type,
                    location_config.x,
                    location_config.y,
                    location_config.w,
                    location_config.h,
                    location.level,
                    finishTime)
            )
            if location.level > 0 then
                table.insert(init_unlock_tiles, {x = location_config.tile_x, y = location_config.tile_y})
            end
        end)
    end)
    self:InitBuildings(init_buildings)

    -- table.insert(init_unlock_tiles, {x = 1, y = 3})
    -- table.insert(init_unlock_tiles, {x = 2, y = 3})
    -- table.insert(init_unlock_tiles, {x = 3, y = 3})
    -- table.insert(init_unlock_tiles, {x = 3, y = 2})
    -- table.insert(init_unlock_tiles, {x = 3, y = 1})

    -- table.insert(init_unlock_tiles, {x = 1, y = 4})
    -- table.insert(init_unlock_tiles, {x = 2, y = 4})
    -- table.insert(init_unlock_tiles, {x = 3, y = 4})
    -- table.insert(init_unlock_tiles, {x = 4, y = 4})
    -- table.insert(init_unlock_tiles, {x = 4, y = 3})
    -- table.insert(init_unlock_tiles, {x = 4, y = 2})
    -- table.insert(init_unlock_tiles, {x = 4, y = 1})

    -- table.insert(init_unlock_tiles, {x = 1, y = 5})
    -- table.insert(init_unlock_tiles, {x = 2, y = 5})
    -- table.insert(init_unlock_tiles, {x = 3, y = 5})
    -- table.insert(init_unlock_tiles, {x = 4, y = 5})
    self:InitTiles(5, 5, init_unlock_tiles)

    local hosue_events = userData.houseEvents
    local init_decorators = {}
    table.foreach(userData.buildings, function(key, location)
        illegal_filter(key, function()
            if #location.houses > 0 then
                table.foreach(location.houses, function(_, house)
                    local city_location = self:GetLocationById(location.location)
                    local tile_x = city_location.tile_x
                    local tile_y = city_location.tile_y
                    local tile = self:GetTileByIndex(tile_x, tile_y)
                    local absolute_x, absolute_y = tile:GetAbsolutePositionByLocation(house.location)
                    local event = get_house_event_by_location(location.location, house.location, hosue_events)
                    local finishTime = event == nil and 0 or event.finishTime / 1000
                    table.insert(init_decorators,
                        self:NewBuildingWithType(house.type,
                            absolute_x,
                            absolute_y,
                            3,
                            3,
                            house.level,
                            finishTime)
                    )
                end)
            end
        end)
    end)
    self:InitDecorators(init_decorators)
    self:GenerateWalls()
end
function City:ResetAllListeners()
    self.upgrading_building_callbacks = {}
    self.finish_upgrading_callbacks = {}
    
    self.resource_manager:RemoveAllObserver()
    self.soldier_manager:ClearAllListener()
    self.material_manager:RemoveAllObserver()
    self:ClearAllListener()
    self:IteratorCanUpgradeBuildings(function(building)
        building:ResetAllListeners()
        building:AddUpgradeListener(self)
    end)
end
function City:NewBuildingWithType(building_type, x, y, w, h, level, finish_time)
    return BuildingRegister[building_type].new{
        x = x,
        y = y,
        w = w,
        h = h,
        building_type = building_type,
        level = level,
        finishTime = finish_time,
        city = self,
    }
end
function City:InitRuins()
    self.ruins = {}
    for _,v in ipairs(GameDatas.ClientInitGame['ruins']) do
        table.insert(self.ruins,
            Building.new{
                building_type = v.building_type,
                x = v.x,
                y = v.y,
                w = v.w,
                h = v.h,
                city = self,
            }
        )
    end
end
function City:InitTiles(w, h, unlocked)
    self.tiles = {}
    for y = 1, h do
        table.insert(self.tiles, {})
        for x = 1, w do
            for location_id, location in pairs(self.locations) do
                if location.tile_x == x and location.tile_y == y then
                    self.tiles[y][x] = Tile.new({x = x, y = y, locked = true, location_id = location_id, city = self})
                end
            end
        end
    end
    if unlocked then
        for _, v in pairs(unlocked) do
            self.tiles[v.y][v.x].locked = false
        end
    end
end
function City:InitBuildings(buildings)
    self.buildings = buildings
    table.foreach(buildings, function(key, building)
        local type_ = building:GetType()
        if only_one_buildings_map[type_] then
            assert(not self[type_])
            self[type_] = building
        end
        building:AddUpgradeListener(self)
    end)
end
function City:InitLocations()
    self.locations = GameDatas.ClientInitGame.locations
    table.foreach(self.locations, function(location_id, location)
        self.locations_decorators[location_id] = {}
    end)
end
function City:InitDecorators(decorators)
    self.decorators = decorators
    table.foreach(decorators, function(key, building)
        building:AddUpgradeListener(self)

        local tile = self:GetTileWhichBuildingBelongs(building)
        local sub_location = tile:GetBuildingLocation(building)
        assert(sub_location)
        self:GetDecoratorsByLocationId(tile.location_id)[sub_location] = building
    end)
    self:CheckIfDecoratorsIntersectWithRuins()
end
-- 取值函数
function City:GetDragonEyrie()
    return self:GetFirstBuildingByType("dragonEyrie")
end
function City:GetHousesAroundFunctionBuildingByType(building, building_type, len)
    return self:GetHousesAroundFunctionBuildingWithFilter(building, len, function(house)
        return house:GetType() == building_type and house:IsUnlocked()
    end)
end
function City:GetHousesAroundFunctionBuildingWithFilter(building, len, filter)
    assert(self:IsFunctionBuilding(building))
    len = len or 2
    local r = {}
    self:IteratorDecoratorBuildingsByFunc(function(_,v)
        if building:IsNearByBuildingWithLength(v, len) and type(filter) == "function" and filter(v) then
            table.insert(r, v)
        end
    end)
    return r
end
function City:IsFunctionBuilding(building)
    local location_id = self:GetLocationIdByBuilding(building)
    if location_id then
        return self:GetBuildingByLocationId(location_id):IsSamePositionWith(building)
    end
end
function City:IsHouse(building)
    return building:IsHouse()
end
function City:IsTower(building)
    return iskindof(building, "TowerEntity")
end
function City:IsGate(building)
    if iskindof(building, "WallUpgradeBuilding") then
        return building:IsGate()
    end
end
function City:GetSoldierManager()
    return self.soldier_manager
end
function City:GetMaterialManager()
    return self.material_manager
end
function City:GetResourceManager()
    return self.resource_manager
end
function City:GetAvailableBuildQueueCounts()
    return self:BuildQueueCounts() - #self:GetUpgradingBuildings()
end
function City:BuildQueueCounts()
    return self.build_queue
end
function City:GetHelpedByTroops()
    return self.helpedByTroops
end
function City:GetUpgradingBuildings(need_sort)
    local builds = {}
    self:IteratorCanUpgradeBuildings(function(building)
        if building:IsUpgrading() then
            table.insert(builds, building)
        end
    end)
    if need_sort then
        table.sort(builds, function(a, b)
            local a_index = self:GetLocationIdByBuildingType(a:GetType())
            local b_index = self:GetLocationIdByBuildingType(b:GetType())
            if a_index and b_index then
                return a_index < b_index
            elseif a_index == nil and b_index then
                return false
            elseif a_index and b_index == nil then
                return true
            else
                return a:GetType() == b:GetType() and a:IsAheadOfBuilding(b) or a:IsImportantThanBuilding(b)
            end
        end)
    end
    return builds
end
function City:GetUpgradingBuildingsWithOrder(current_time)
    local builds = {}
    self:IteratorCanUpgradeBuildings(function(building)
        if building:IsUpgrading() then
            table.insert(builds, building)
        end
    end)
    table.sort(builds, function(a, b)
        return a:GetUpgradingLeftTimeByCurrentTime(current_time) < b:GetUpgradingLeftTimeByCurrentTime(current_time)
    end)
    return builds
end
function City:GetLeftBuildingCountsByType(building_type)
    return self:GetMaxHouseCanBeBuilt(building_type) - #self:GetBuildingByType(building_type)
end
local function alignmeng_path(path)
    if #path <= 3 then
        return path
    end
    local index = 1
    while index <= #path - 2 do
        local start = path[index]
        local middle = path[index + 1]
        local ending = path[index + 2]
        local dx = ending.x - start.x
        local dy = ending.y - start.y
        if ((start.x == middle.x and middle.x == ending.x and
            abs((ending.y + start.y) * 0.5 - middle.y) < abs(ending.y - start.y))
            or (start.y == middle.y and middle.y == ending.y) and
            abs((ending.x + start.x) * 0.5 - middle.x) < abs(ending.x - start.x))
        then
            table.remove(path, index + 1)
        else
            index = index + 1
        end
    end
    return path
end
function City:FindAPointWayFromPosition(x, y)
    return self:FindAPointWayFromTileAt(self:GetTileByBuildingPosition(x, y), {x = x, y = y})
end
function City:FindAPointWayFromTile()
    return self:FindAPointWayFromTileAt()
end
function City:FindAPointWayFromTileAt(tile, point)
    local path_tiles = self:FindATileWayFromTile(tile)
    local path_point = LuaUtils:table_map(path_tiles, function(k, v)
        return k, v:GetCrossPoint()
    end)
    table.insert(path_point, 1, point or path_tiles[1]:RandomPoint())
    table.insert(path_point, #path_point + 1, path_tiles[#path_tiles]:RandomPoint())
    return alignmeng_path(path_point)
end
local function find_path_tile(connectedness, start_tile)
    if #connectedness == 0 then
        assert(start_tile)
        return {start_tile}
    end
    local r = {start_tile or table.remove(connectedness, math.random(#connectedness))}
    local index = 1
    local changed = true
    while changed do
        local cur_nearbys = {}
        for i, v in ipairs(connectedness) do
            local cur = r[index]
            if cur:IsNearBy(v) then
                table.insert(cur_nearbys, i)
            end
        end
        if #cur_nearbys > 0 then
            table.insert(r, table.remove(connectedness, cur_nearbys[math.random(#cur_nearbys)]))
            index = index + 1
            changed = true
        else
            changed = false
        end
    end
    return r
end
function City:FindATileWayFromTile(tile)
    local r = tile == nil and self:GetConnectedTiles() or tile:FindConnectedTilesFromThis()
    return find_path_tile(r, tile)
end
function City:GetConnectedTiles()
    local r = {}
    self:IteratorTilesByFunc(function(x, y, tile)
        if tile:IsConnected() then
            table.insert(r, tile)
        end
    end)
    return r
end
-- 取得小屋最大建造数量
local BUILDING_MAP = {
    dwelling = "townHall",
    woodcutter = "lumbermill",
    farmer = "mill",
    quarrier = "stoneMason",
    miner = "foundry",
}
function City:GetMaxHouseCanBeBuilt(house_type)
    --基础值
    local max = HOUSES[house_type]
    for _, v in pairs(self:GetBuildingByType(BUILDING_MAP[house_type])) do
        max = max + v:GetMaxHouseNum()
    end
    return max
end
function City:GetBuildingsIsUnlocked()
    local r = {}
    for _,v in pairs(self:GetAllBuildings()) do
        if v:IsUnlocked() or v:IsUnlocking() then
            table.insert(r, v)
        end
    end
    if self:GetTower():IsUnlocked() or self:GetTower():IsUnlocking() then
        table.insert(r, self:GetTower())
    end
    if self:GetGate():IsUnlocked() or self:GetGate():IsUnlocking() then
        table.insert(r, self:GetGate())
    end
    table.sort(r, function(a, b)
        if a:GetLevel() < b:GetLevel() then
            return true
        elseif a:GetLevel() > b:GetLevel() then
            return false
        end
        return a:IsImportantThanBuilding(b)
    end)
    return r
end
function City:GetUnlockedFunctionBuildings()
    local r = {}
    for _,v in ipairs(self.buildings) do
        if v:IsUnlocked() or v:IsUnlocking() then
            table.insert(r, v)
        end
    end
    return r
end
function City:GetAllBuildings()
    return self.buildings
end
function City:GetHousesWhichIsBuilded()
    local r = {}
    for i, v in ipairs(self:GetAllDecorators()) do
        table.insert(r, v)
    end
    table.sort(r, function(a, b)
        local compare = b:GetLevel() - a:GetLevel()
        return compare == 0 and a:IsAheadOfBuilding(b) or (compare > 0 and true or false)
    end)
    return r
end
function City:GetAllDecorators()
    return self.decorators
end
function City:GetDecoratorsByLocationId(location_id)
    if not self.locations_decorators[location_id] then
        self.locations_decorators[location_id] = {}
    end
    return self.locations_decorators[location_id]
end
function City:GetLocationIdByBuilding(building)
    return self:GetTileWhichBuildingBelongs(building).location_id
end
local config_buildings = GameDatas.Buildings.buildings
function City:GetLocationIdByBuildingType(building_type)
    for _, v in ipairs(config_buildings) do
        if building_type == v.name then
            return v.location
        end
    end
    return nil
end
function City:GetBuildingByLocationId(location_id)
    if location_id == 2 then
        return self:GetFirstBuildingByType("watchTower")
    elseif location_id == 21 then
        return self:GetGate()
    elseif location_id == 22 then
        return self:GetTower()
    end
    for _,v in pairs(self:GetAllBuildings()) do
        if self:GetTileByLocationId(location_id):IsContainBuilding(v) then
            return v
        end
    end
    return nil
end
function City:GetBuildingByTypeWithSpecificPosition(building_type, x, y)
    for _, v in pairs(self:GetBuildingByType(building_type)) do
        if v.x == x and v.y == y then
            return v
        end
    end
    return nil
end
function City:GetFirstBuildingByType(type_)
    if only_one_buildings_map[type_] then
        return self[type_]
    end
    return self:GetBuildingByType(type_)[1]
end
function City:GetHighestBuildingByType(type_)
    local highest
    for _,v in ipairs(self:GetBuildingByType(type_)) do
        if not highest or highest:GetLevel() < v:GetLevel() then
            highest = v
        end
    end
    return highest
end
function City:GetLowestestBuildingByType(type_)
    local lowest
    for _,v in ipairs(self:GetBuildingByType(type_)) do
        if not lowest or lowest:GetLevel() > v:GetLevel() then
            lowest = v
        end
    end
    return lowest
end
function City:GetBuildingByType(type_)
    local find_buildings = {}
    local filter = function(_, building)
        if building:GetType() == type_ then
            table.insert(find_buildings, building)
        end
    end
    self:IteratorFunctionBuildingsByFunc(filter)
    self:IteratorDecoratorBuildingsByFunc(filter)
    filter(nil, self:GetGate())
    filter(nil, self:GetTower())
    return find_buildings
end
function City:GetHouseByPosition(x, y)
    return self:GetDecoratorByPosition(x, y)
end
function City:GetDecoratorByPosition(x, y)
    local find_decorator = nil
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        if building:IsContainPoint(x, y) then
            find_decorator = building
            return true
        end
    end)
    return find_decorator
end
function City:GetTilesFaceToGate()
    local r = {}
    local tile = self:GetTileFaceToGate()
    if tile then
        local x = tile.x
        for i = tile.y, 5 do
            table.insert(r, self:GetTileByIndex(x, i))
        end
    end
    return r
end
function City:GetTileFaceToGate()
    for k, v in pairs(self.walls) do
        if v:IsGate() then
            local tile = self:GetTileWhichBuildingBelongs(v)
            if tile then
                return tile
            else
                local x, y = self:GetTileIndexPosition(v.x, v.y)
                return Tile.new({x = x, y = y, locked = false, city = self})
            end
        end
    end
end
function City:GetTileWhichBuildingBelongs(building)
    if building:GetType() == "watchTower" then
        return self:GetTileByLocationId(2)
    end
    return self:GetTileByBuildingPosition(building.x, building.y)
end
function City:GetTileByBuildingPosition(x, y)
    return self:GetTileByIndex(self:GetTileIndexPosition(x, y))
end
function City:GetTileIndexPosition(x, y)
    return floor(x / 10) + 1, floor(y / 10) + 1
end
function City:GetTileByLocationId(location_id)
    local location_info = self:GetLocationById(location_id)
    return self:GetTileByIndex(location_info.tile_x, location_info.tile_y)
end
function City:GetLocationById(location_id)
    return self.locations[location_id]
end
function City:GetTileByIndex(x, y)
    return self.tiles[y] and self.tiles[y][x] or nil
end
function City:IsUnLockedAtIndex(x, y)
    return not self.tiles[y][x].locked
end
function City:IsTileCanbeUnlockAt(x, y)
    -- 没有第五圈
    if x == 5 then
        return false
    end
    -- 是否解锁
    if not self:GetTileByIndex(x, y) then
        return false , self.RETURN_CODE.OUT_OF_BOUND
    end
    if not self:GetTileByIndex(x, y).locked then
        return false, self.RETURN_CODE.HAS_UNLOCKED
    end
    -- 检查内圈
    local inner_round_number = self:GetAroundByPosition(x, y) - 1
    if not self:IsUnlockedInAroundNumber(inner_round_number) then
        return false, self.RETURN_CODE.INNER_ROUND_NOT_UNLOCKED
    end
    -- 检查临边
    for iy, row in ipairs(self.tiles) do
        for jx, col in ipairs(row) do
            if not col.locked and abs(x - jx) + abs(y - iy) <= 1 then
                return true
            end
        end
    end
    -- 临边未解锁
    return false, self.RETURN_CODE.EDGE_BESIDE_NOT_UNLOCKED
end
function City:GetUnlockTowerLimit()
    local t = {
        [1] = 3,
        [2] = 5,
        [3] = 7,
        [4] = 9,
        [5] = 11,
    }
    return t[self:GetUnlockAround()]
end
function City:GetUnlockAround()
    local t = { 5, 4, 3, 2, 1 }
    for _, round_number in ipairs(t) do
        if self:IsUnlockedInAroundNumber(round_number) then
            return round_number
        end
    end
    assert(false)
end
function City:IsUnlockedInAroundNumber(roundNumber)
    if roundNumber <= 0 then
        return true
    end
    local tiles = self.tiles
    local h = #tiles
    local w = #tiles[1]
    assert(roundNumber <= h)
    assert(roundNumber <= w)
    for row = 1, roundNumber do
        for col = 1, roundNumber do
            if tiles[row][col].locked then
                return false
            end
        end
    end
    return true
end
function City:GetAroundByPosition(x, y)
    return max(x, y)
end
function City:GetWalls()
    return self.walls
end
function City:GetGate()
    return self.gate
end
function City:GetTower()
    return self.tower
end
function City:GetVisibleTowers()
    return self.visible_towers
end
function City:GetNearGateTower()
    local gate = self:GetGate()
    for _,v in pairs(self:GetVisibleTowers()) do
        if v:IsNearByBuildingWithLength(gate, 5) then
            return v
        end
    end
    return self:GetVisibleTowers()[1]
end
-- function City:GetCanUpgradingTowers()
--     local visible_towers = {}
--     table.foreach(self.visible_towers, function(_, tower)
--         if tower:IsUnlocked() then
--             table.insert(visible_towers, tower)
--         end
--     end)
--     return visible_towers
-- end
-- 工具
function City:IteratorCanUpgradeBuildings(func)
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        func(building)
    end)
    self:IteratorFunctionBuildingsByFunc(function(key, building)
        func(building)
    end)
    func(self:GetTower())
    func(self:GetGate())
end
function City:IteratorCanUpgradeBuildingsByUserData(user_data, current_time, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and (deltaData.buildings or deltaData.buildingEvents or deltaData.houseEvents)
    if is_fully_update or is_delta_update then
        self:IteratorDecoratorBuildingsByFunc(function(key, building)
            local tile = self:GetTileWhichBuildingBelongs(building)
            building:OnUserDataChanged(user_data, current_time, tile.location_id, tile:GetBuildingLocation(building), deltaData)
        end)
        self:IteratorFunctionBuildingsByFunc(function(key, building)
            building:OnUserDataChanged(user_data, current_time, self:GetLocationIdByBuilding(building), nil, deltaData)
        end)
        self:GetTower():OnUserDataChanged(user_data, current_time, deltaData)
        self:GetGate():OnUserDataChanged(user_data, current_time, deltaData)
    else
        self:IteratorFunctionBuildingsByFunc(function(key, building)
            building:OnUserDataChanged(user_data, current_time, self:GetLocationIdByBuilding(building), nil, deltaData)
        end)
    end
end
function City:IteratorAllNeedTimerEntity(current_time)
    self:IteratorFunctionBuildingsByFunc(function(key, building)
        building:OnTimer(current_time)
    end)
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        building:OnTimer(current_time)
    end)
    -- self:IteratorTowersByFunc(function(key, building)
    --     building:OnTimer(current_time)
    -- end)
    self:GetTower():OnTimer(current_time)
    local gate = self:GetGate()
    if gate then
        gate:OnTimer(current_time)
    end
    self.resource_manager:OnTimer(current_time)
end
-- 遍历顺序影响城墙的生成
function City:IteratorTilesByFunc(func)
    for iy, row in pairs(self.tiles) do
        for jx, col in pairs(row) do
            if func(jx, iy, col) then
                return
            end
        end
    end
    -- for iy, row in ipairs(self.tiles) do
    --     for ix = #row, 1, -1 do
    --         if func(jx, iy, row[ix]) then
    --             return
    --         end
    --     end
    -- end
end
-- function City:IteratorTowersByFunc(func)
--     table.foreach(self:GetCanUpgradingTowers(), func)
-- end
function City:IteratorFunctionBuildingsByFunc(func)
    table.foreach(self:GetAllBuildings(), func)
end
function City:IteratorDecoratorBuildingsByFunc(func)
    table.foreach(self:GetAllDecorators(), func)
end
function City:CheckIfDecoratorsIntersectWithRuins()
    local occupied_ruins = {}
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        for _, ruin in ipairs(self.ruins) do
            if building:IsIntersectWithOtherBuilding(ruin) and
                not ruin.has_been_occupied then
                ruin.has_been_occupied = true
                table.insert(occupied_ruins, ruin)
            end
        end
    end)
    self:NotifyListeneOnType(City.LISTEN_TYPE.OCCUPY_RUINS, function(listener)
        listener:OnOccupyRuins(occupied_ruins)
    end)
end
function City:GetNeighbourRuinWithSpecificRuin(ruin)
    local neighbours_position = {
        { x = ruin.x + 3, y = ruin.y },
        { x = ruin.x, y = ruin.y + 3 },
        { x = ruin.x - 3, y = ruin.y },
        { x = ruin.x, y = ruin.y - 3 },
    }
    local out_put_neighbours_position = {}
    local belong_tile = self:GetTileWhichBuildingBelongs(ruin)
    for k, v in pairs(neighbours_position) do
        local is_in_same_tile = self:GetTileByBuildingPosition(v.x, v.y) == belong_tile
        if is_in_same_tile then
            table.insert(out_put_neighbours_position, v)
        end
    end
    local neighbours = {}
    for _, position in pairs(out_put_neighbours_position) do
        for _, v in ipairs(self.ruins) do
            if not v.has_been_occupied and v.x == position.x and v.y == position.y then
                table.insert(neighbours, v)
                break
            end
        end
    end
    return neighbours
end
-- 功能函数
function City:OnTimer(time)
    self:IteratorAllNeedTimerEntity(time)
    self:IteratorProductionTechEvents(function(v)
        v:OnTimer(time)
    end)
end
function City:CreateDecorator(current_time, decorator_building)
    table.insert(self.decorators, decorator_building)

    local tile = self:GetTileWhichBuildingBelongs(decorator_building)
    local sub_location = tile:GetBuildingLocation(decorator_building)
    assert(sub_location)
    assert(self:GetDecoratorsByLocationId(tile.location_id)[sub_location] == nil)
    self:GetDecoratorsByLocationId(tile.location_id)[sub_location] = decorator_building

    self:OnCreateDecorator(current_time, decorator_building)

    self:CheckIfDecoratorsIntersectWithRuins()
    self:NotifyListeneOnType(City.LISTEN_TYPE.CREATE_DECORATOR, function(listener)
        listener:OnCreateDecorator(decorator_building)
    end)

end
--获取没有被占用了的废墟
function City:GetRuinsNotBeenOccupied()
    local r = {}
    table.foreach(self.ruins, function(key, ruin)
        if not ruin.has_been_occupied  and
            not self:GetTileWhichBuildingBelongs(ruin).locked then
            table.insert(r,ruin)
        end
    end)
    return r
end
--根据type获取装饰物列表
function City:GetCitizenByType(building_type)
    local total_citizen = 0
    for k, v in pairs(self:GetDecoratorsByType(building_type)) do
        total_citizen = total_citizen + v:GetCitizen()
    end
    return total_citizen
end
function City:GetDecoratorsByType(building_type)
    local r = {}
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        if building:GetType() == building_type then
            table.insert(r, building)
        end
    end)
    return r
end
function City:DestoryDecorator(current_time, building)
    self:DestoryDecoratorByPosition(current_time, building.x, building.y)
end
function City:DestoryDecoratorByPosition(current_time, x, y)
    local destory_decorator = self:GetDecoratorByPosition(x, y)

    if destory_decorator then
        local release_ruins = {}
        for _, ruin in ipairs(self.ruins) do
            if ruin.has_been_occupied then
                if ruin:IsIntersectWithOtherBuilding(destory_decorator) and
                    ruin.has_been_occupied then
                    ruin.has_been_occupied = nil
                    table.insert(release_ruins, ruin)
                end
            end
        end

        table.foreachi(self:GetAllDecorators(), function(i, building)
            if building == destory_decorator then
                table.remove(self.decorators, i)
                return true
            end
        end)

        local tile = self:GetTileWhichBuildingBelongs(destory_decorator)
        table.foreach(self:GetDecoratorsByLocationId(tile.location_id), function(key, building)
            if building == destory_decorator then
                assert(self:GetDecoratorsByLocationId(tile.location_id)[key])
                self:GetDecoratorsByLocationId(tile.location_id)[key] = nil
                return true
            end
        end)

        self:OnDestoryDecorator(current_time, destory_decorator)

        self:NotifyListeneOnType(City.LISTEN_TYPE.DESTROY_DECORATOR, function(listener)
            listener:OnDestoryDecorator(destory_decorator, release_ruins)
        end)
        return true
    end
end
----------- 功能扩展点
function City:OnUserDataChanged(userData, current_time, deltaData)
    local need_update_resouce_buildings, is_unlock_any_tiles, unlock_table = self:OnHouseChanged(userData, current_time, deltaData)
    -- 更新建筑信息
    self:IteratorCanUpgradeBuildingsByUserData(userData, current_time, deltaData)


    -- 更新地块信息
    if is_unlock_any_tiles then
        LuaUtils:outputTable("unlock_table", unlock_table)
        self:UnlockTilesByIndexArray(unlock_table)
    end

    -- 更新协防信息
    self:OnHelpedByTroopsDataChange(userData, deltaData)
    --更新派出的协防信息
    self:OnHelpToTroopsDataChange(userData, deltaData)
    --科技
    self:OnProductionTechsDataChanged(userData.productionTechs)
    self:OnProductionTechEventsDataChaned(userData,deltaData)

    -- 更新兵种
    self.soldier_manager:OnUserDataChanged(userData, current_time, deltaData)
    -- 更新材料，这里是广义的材料，包括龙的装备
    self.material_manager:OnUserDataChanged(userData, deltaData)
    -- 更新基本信息
    local basicInfo = userData.basicInfo
    self.build_queue = basicInfo.buildQueue
    self:SetCityName(basicInfo.name)
    -- 最后才更新资源

    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.resources and deltaData.resources.refreshTime
    is_delta_update = is_delta_update or (deltaData and deltaData.soldiers)
    if is_delta_update then
        need_update_resouce_buildings = true
    end
    local resource_refresh_time = current_time
    if userData.resources then
        resource_refresh_time = userData.resources.refreshTime / 1000
        self.resource_manager:UpdateFromUserDataByTime(userData.resources, resource_refresh_time)
    end
    if need_update_resouce_buildings then
        self.resource_manager:UpdateByCity(self, resource_refresh_time)
    end
    return self
end
local function find_building_info_by_location(houses, location_id)
    for _, v in pairs(houses) do
        if v.location == location_id then
            return v
        end
    end
end
function City:OnHouseChanged(userData, current_time, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and (deltaData.buildings ~= nil or deltaData.buildingEvents ~= nil)

    local buildings = {}
    if is_fully_update then
        buildings = userData.buildings
    elseif is_delta_update then
        local userDataBuildings = userData.buildings
        for k,v in pairs(deltaData.buildings or {}) do
            buildings[k] = userDataBuildings[k]
        end
    else
        return false
    end

    local unlock_table = {}
    local is_unlock_any_tiles = false
    for i,v in ipairs(userData.buildingEvents or {}) do
        if self:GetBuildingByLocationId(v.location):GetLevel() == 0 then
            is_unlock_any_tiles = true
            break
        end
    end
    table.foreach(buildings, function(key, location)
        local location_id = location.location
        illegal_filter(key, function()
            local building = self:GetBuildingByLocationId(location_id)
            local is_unlocking = building:GetLevel() == 0 and (location.level > 0)
            local tile = self:GetTileByLocationId(location_id)
            if is_unlocking and tile.locked then
                is_unlock_any_tiles = true
                table.insert(unlock_table, {x = tile.x, y = tile.y})
            end

            -- 拆除 or 交换
            local decorators = self:GetDecoratorsByLocationId(location_id)
            table.foreach(decorators, function(key, building)
                -- 当前位置有小建筑并且推送的数据里面没有就认为是拆除
                local tile = self:GetTileWhichBuildingBelongs(building)
                local location_id = tile:GetBuildingLocation(building)
                local building_info = find_building_info_by_location(location.houses, location_id)
                -- 没有找到，就是已经被拆除了
                -- 如果类型不对，也认为是拆除
                if not building_info or (building_info.type ~= building:GetType()) then
                    self:DestoryDecorator(current_time, building)
                end
            end)

            -- 新建的
            table.foreach(location.houses, function(key, house)
                -- 当前位置没有小建筑并且推送的数据里面有就认为新建小建筑
                if not decorators[house.location] then
                    local absolute_x, absolute_y = tile:GetAbsolutePositionByLocation(house.location)
                    self:CreateDecorator(current_time, BuildingRegister[house.type].new({
                        x = absolute_x,
                        y = absolute_y,
                        w = 3,
                        h = 3,
                        building_type = house.type,
                        level = house.level,
                        finishTime = 0,
                        city = self,
                    }))
                end
            end)
        end)
    end)
    return true, is_unlock_any_tiles, unlock_table
end
function City:GetCityName()
    return self.cityName
end
function City:SetCityName(cityName)
    if self.cityName~= cityName then
        self.cityName = cityName
        self:NotifyListeneOnType(City.LISTEN_TYPE.CITY_NAME, function(listener)
            listener:OnCityNameChanged(cityName)
        end)
    end
end
function City:OnCreateDecorator(current_time, building)
    building:AddUpgradeListener(self)
end
function City:OnDestoryDecorator(current_time, building)
    building:RemoveUpgradeListener(self)
end
function City:OnBuildingUpgradingBegin(building, current_time)
    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgradingBegin(building, current_time, self)
    end)

    self:CheckUpgradingBuildingPormise(building)
end
function City:OnBuildingUpgrading(building, current_time)
    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgrading(building, current_time, self)
    end)
end
function City:OnSpeedUpBuilding()
    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        if listener.OnSpeedUpBuilding then
            listener:OnSpeedUpBuilding()
        end
    end)
end
function City:OnBuildingUpgradeFinished(building)
    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgradingFinished(building, self)
    end)

    self:CheckFinishUpgradingBuildingPormise(building)
end
function City:LockTilesByIndexArray(index_array)
    table.foreach(index_array, function(_, index)
        self.tiles[index.y][index.x].locked = true
    end)
    self:GenerateWalls()
    local city = self
    self:NotifyListeneOnType(City.LISTEN_TYPE.LOCK_TILE, function(listener)
        listener:OnTileLocked(city)
    end)
end
function City:LockTilesByIndex(x, y)
    self.tiles[y][x].locked = true
    self:GenerateWalls()
    local city = self
    self:NotifyListeneOnType(City.LISTEN_TYPE.LOCK_TILE, function(listener)
        listener:OnTileLocked(city, x, y)
    end)
end
function City:UnlockTilesByIndexArray(index_array)
    table.foreach(index_array, function(_, index)
        self.tiles[index.y][index.x].locked = false
    end)
    self:GenerateWalls()
    local city = self
    self:NotifyListeneOnType(City.LISTEN_TYPE.UNLOCK_TILE, function(listener)
        listener:OnTileUnlocked(city)
    end)
end
function City:UnlockTilesByIndex(x, y)
    local success, ret_code = self:IsTileCanbeUnlockAt(x, y)
    if not success then
        return success, ret_code
    end
    self.tiles[y][x].locked = false
    self:GenerateWalls()
    local city = self
    self:NotifyListeneOnType(City.LISTEN_TYPE.UNLOCK_TILE, function(listener)
        listener:OnTileUnlocked(city, x, y)
    end)
    -- 检查是否解锁完一圈
    -- local round = self:GetAroundByPosition(x, y)
    -- if self:IsUnlockedInAroundNumber(round) then
    --     self:NotifyListeneOnType(City.LISTEN_TYPE.UNLOCK_ROUND, function(listener)
    --         listener:OnRoundUnlocked(round)
    --     end)
    -- end
    return success, ret_code
end
-- function City:OnInitBuilding(building)
--     building.city = self
--     building:AddUpgradeListener(self)
-- end
---------
local function find_beside_wall(walls, wall)
    for i, v in ipairs(walls) do
        if wall:IsEndJoinStartWithOtherWall(v) then
            return i
        end
    end
end
function City:GenerateWalls()
    local walls = {}
    self:IteratorTilesByFunc(function(x, y, tile)
        if tile:NeedWalls() then
            tile:IteratorWallsAroundSelf(function(_, wall)
                table.insert(walls, wall)
            end)
        end
    end)

    local count = #walls

    for ik, wall in pairs(walls) do
        for jk, other in pairs(walls) do
            if wall:IsDupWithOtherWall(other) then
                walls[ik] = nil
                walls[jk] = nil
            end
        end
    end

    local real_walls = {}
    for i = 1, count do
        local w = walls[i]
        if w then
            table.insert(real_walls, w)
        end
    end

    -- -- 边排序,首尾相连接
    local first = table.remove(real_walls, 1)
    local sort_walls = { first }
    while #real_walls > 0 do
        local index = find_beside_wall(real_walls, first)
        if index then
            local f = first
            first = table.remove(real_walls, index)
            table.insert(sort_walls, first)
        else
            break
        end
    end

    -- 重新生成城门的监听
    self.walls = self:ReloadWalls(sort_walls)

    -- 生成防御塔
    self:GenerateTowers(sort_walls)
end
-- 因为重新生成了城墙，所以必须把添加的listener都转移到新的城门上去
local function GetGateInWalls(walls)
    local gate
    table.foreach(walls, function(k, wall)
        if wall:IsGate() then
            gate = wall
            return true
        end
    end)
    return gate
end
function City:ReloadWalls(walls)
    local old_gate = GetGateInWalls(self.walls)
    local new_index = nil
    local new_gate = nil
    for i, v in ipairs(walls) do
        if v:IsGate() then
            new_index = i
            new_gate = v
            break
        end
    end

    assert(new_index)
    -- 已经生成过城门了
    if old_gate then
        walls[new_index] = old_gate
        old_gate:CopyValueFrom(new_gate)
        self.gate = old_gate
    else
        -- 如果是第一次生成
        self.gate = GetGateInWalls(walls)
        self.gate:AddUpgradeListener(self)
    end
    local t = {}
    for _, v in ipairs(walls) do
        local x, y = v:GetLogicPosition()
        if (v:GetOrient() == Orient.X) or
            (v:GetOrient() == Orient.Y) or
            (x > 0 and y > 0) then
            table.insert(t, v)
        end
    end
    return t
end
function City:GenerateTowers(walls)
    local visible_towers = {}
    local p = walls[#walls]:IntersectWithOtherWall(walls[1])
    table.insert(visible_towers,
        TowerUpgradeBuilding.new({
            building_type = "tower",
            x = p.x,
            y = p.y,
            level = -1,
            orient = p.orient,
            sub_orient = p.sub_orient,
            city = self,
        })
    )

    for i, v in pairs(walls) do
        if i < #walls then
            local p = walls[i]:IntersectWithOtherWall(walls[i + 1])
            if p then
                table.insert(visible_towers,
                    TowerUpgradeBuilding.new({
                        building_type = "tower",
                        x = p.x,
                        y = p.y,
                        level = -1,
                        orient = p.orient,
                        sub_orient = p.sub_orient,
                        city = self,
                    })
                )
            end
        end
    end

    local visible_tower = {}
    for _, v in ipairs(visible_towers) do
        if v:IsVisible() then
            table.insert(visible_tower, v)
        end
    end

    -- local efficiency_tower = {}
    -- for i = 1, #visible_tower do
    --     if visible_tower[i]:IsEfficiency() then
    --         efficiency_tower[#efficiency_tower + 1] = i
    --     end
    -- end

    -- local tower_limit = self:GetUnlockTowerLimit()
    -- local indexes = {}
    -- while #indexes < tower_limit do
    --     local i = ceil(#efficiency_tower * 0.5)
    --     local index = table.remove(efficiency_tower, i)
    --     table.insert(indexes, index)
    -- end

    -- for tower_id, tower_index in ipairs(indexes) do
    --     visible_tower[tower_index]:SetTowerId(tower_id)
    -- end
    -- self.visible_towers = self:ReloadTowers(visible_tower)
    self.visible_towers = visible_tower
end
-- function City:ReloadTowers(visible_towers)
--     local old_tower_map = {}
--     for k, v in pairs(self.visible_towers) do
--         if v:IsUnlocked() then
--             old_tower_map[v:TowerId()] = v
--         end
--     end
--     for i, v in ipairs(visible_towers) do
--         if v:IsUnlocked() then
--             local old_tower = old_tower_map[v:TowerId()]
--             -- 已经解锁的
--             if old_tower then
--                 visible_towers[i] = old_tower
--                 old_tower:CopyValueFrom(v)
--             else
--                 -- 如果是新解锁的
--                 self:OnInitBuilding(v)
--             end
--         end
--     end
--     return visible_towers
-- end
function City:OnHelpedByTroopsDataChange(userData, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.helpedByTroops
    if is_fully_update or is_delta_update then
        self.helpedByTroops = userData.helpedByTroops or {}
        self:NotifyListeneOnType(City.LISTEN_TYPE.HELPED_BY_TROOPS, function(listener)
            listener:OnHelpedTroopsChanged(self)
        end)
    end
end
--helpToTroops
function City:OnHelpToTroopsDataChange(userData, deltaData)
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.helpToTroops
    if is_fully_update or is_delta_update then
        self.helpToTroops = {}
        for _,v in ipairs(userData.helpToTroops or {}) do
            self.helpToTroops[v.beHelpedPlayerData.id] = v
        end
        self:NotifyListeneOnType(City.LISTEN_TYPE.HELPED_TO_TROOPS, function(listener)
            listener:OnHelpToTroopsChanged(self)
        end)
    end
end

function City:IteratorHelpToTroops(func)
    for _,v in pairs(self.helpToTroops) do
        func(v)
    end
end

function City:GetHelpToTroops(playerId)
    if playerId then
        return self.helpToTroops[playerId]
    else
        local r = {}
        self:IteratorHelpToTroops(function(v)
            table.insert(r, v)
        end)
        return r
    end
end

function City:HasHelpToTroops()
    return not LuaUtils:table_empty(self.helpToTroops)
end

function City:IsHelpedToTroopsWithPlayerId(id)
    return self:GetHelpToTroops(id) ~= nil
end

-- promise
local function promiseOfBuilding(callbacks, building_type, level)
    assert(#callbacks == 0)
    local p = promise.new()
    table.insert(callbacks, function(building)
        if building_type == nil or (building:GetType() == building_type and (not level or level == building:GetLevel())) then
            return p:resolve(building)
        end
    end)
    return p
end
local function checkBuilding(callbacks, building)
    if #callbacks > 0 and callbacks[1](building) then
        table.remove(callbacks, 1)
    end
end
function City:PromiseOfUpgradingByLevel(building_type, level)
    return promiseOfBuilding(self.upgrading_building_callbacks, building_type, level)
end
function City:CheckUpgradingBuildingPormise(building)
    return checkBuilding(self.upgrading_building_callbacks, building)
end
function City:PromiseOfFinishUpgradingByLevel(building_type, level)
    return promiseOfBuilding(self.finish_upgrading_callbacks, building_type, level)
end
function City:CheckFinishUpgradingBuildingPormise(building)
    return checkBuilding(self.finish_upgrading_callbacks, building)
end
--
function City:PromiseOfRecruitSoldier(soldier_type)
    return self:GetFirstBuildingByType("barracks"):PromiseOfRecruitSoldier(soldier_type)
end
function City:PromiseOfFinishSoldier(soldier_type)
    return self:GetFirstBuildingByType("barracks"):PromiseOfFinishSoldier(soldier_type)
end
--
function City:PromiseOfFinishEquipementDragon()
    return self:GetDragonEyrie():GetDragonManager():PromiseOfFinishEquipementDragon()
end

function City:GetWatchTowerLevel()
    local watch_tower = self:GetFirstBuildingByType("watchTower")
    return watch_tower and watch_tower:GetLevel() or 0
end

function City:OnProductionTechsDataChanged(productionTechs)
    if not productionTechs then return end
    local need_fast_update_all_techs = false
    local edited = {}
    for name,v in pairs(productionTechs) do
        local productionTechnology = self:FindTechByIndex(v.index)
        if not productionTechnology then
            local productionTechnology = ProductionTechnology.new()
            productionTechnology:UpdateData(name,v)
            self.productionTechs[productionTechnology:Index()] = productionTechnology
            need_fast_update_all_techs = true
        else
            need_fast_update_all_techs = false
            if productionTechnology and productionTechnology:Level() ~= v.level then
                productionTechnology:SetLevel(v.level)
                GameGlobalUI:showTips(_("生产科技升级完成"),productionTechnology:GetLocalizedName().."Lv"..productionTechnology:Level())
                local changed = self:CheckDependTechsLockState(productionTechnology)
                table.insert(edited, productionTechnology)
                table.insertto(edited,changed)
            end
        end
    end
    if need_fast_update_all_techs then
        self:FastUpdateAllTechsLockState()
    end
    if #edited > 0 then
        self:NotifyListeneOnType(City.LISTEN_TYPE.PRODUCTION_DATA_CHANGED, function(listener)
            listener:OnProductionTechsDataChanged({edited = edited})
        end)
    end
end

function City:IteratorTechs(func)
    for index,v in pairs(self.productionTechs) do
        func(k,v)
    end
end

function City:FindTechByName(name)
    local index = config_productionTechs[name].index
    if index then
        return self:FindTechByIndex(index)
    end
end

function City:FindTechByIndex(index)
    index = checkint(index)
    return self.productionTechs[index]
end

--查找依赖于此科技的所有科技
function City:FindDependOnTheTechs(tech)
    local r = {}
    self:IteratorTechs(function(_,tech_)
        if tech_:UnlockBy() == tech:Index() then
            table.insert(r, tech_)
        end
    end)
    return r
end
--更新依赖于此科技的科技的解锁状态
function City:CheckDependTechsLockState(tech)
    local changed = {}
    local targetTechs = self:FindDependOnTheTechs(tech)
    for _,tech_ in ipairs(targetTechs) do
        tech_:SetEnable(tech:Level() >= tech_:UnlockLevel() and tech_:IsOpen() and tech_:AcademyLevel() <= self:GetAcademyBuildingLevel())
        table.insert(changed,tech_)
    end
    return changed
end

function City:FastUpdateAllTechsLockState()
    self:IteratorTechs(function(index,tech)
        local unLockByTech = self:FindTechByIndex(tech:UnlockBy())
        if unLockByTech then
            tech:SetEnable(tech:UnlockLevel() <= unLockByTech:Level() and tech:IsOpen() and tech:AcademyLevel() <= self:GetAcademyBuildingLevel())
        end
    end)
end

function City:GetAcademyBuildingLevel()
    local building = self:GetFirstBuildingByType('academy')
    if building then 
        return building:GetLevel()
    else
        return 0
    end
end


function City:OnProductionTechEventsDataChaned(userData,deltaData)
    if not userData.productionTechEvents then return end
    local is_fully_update = deltaData == nil
    local is_delta_update = not is_fully_update and deltaData.productionTechEvents ~= nil
    if is_fully_update then
        --清空之前的数据
        self:IteratorProductionTechEvents(function(productionTechnologyEvent)
            productionTechnologyEvent:Reset()
        end)
        self.productionTechEvents = {}
        for _,v in ipairs(userData.productionTechEvents) do
            if not self:FindProductionTechEventById(v.id) then
                local productionTechnologyEvent = ProductionTechnologyEvent.new()
                productionTechnologyEvent:UpdateData(v)
                productionTechnologyEvent:SetEntity(self:FindTechByName(productionTechnologyEvent:Name()))
                self.productionTechEvents[productionTechnologyEvent:Id()] = productionTechnologyEvent
                productionTechnologyEvent:AddObserver(self)
            end
        end
        self:NotifyListeneOnType(City.LISTEN_TYPE.PRODUCTION_EVENT_REFRESH, function(listener)
            listener:OnProductionTechnologyEventDataRefresh()
        end)
    end
    if is_delta_update then
        local changed_map = GameUtils:Handler_DeltaData_Func(
            deltaData.productionTechEvents
            ,function(v)
                if not self:FindProductionTechEventById(v.id) then
                    local productionTechnologyEvent = ProductionTechnologyEvent.new()
                    productionTechnologyEvent:UpdateData(v)
                    productionTechnologyEvent:SetEntity(self:FindTechByName(productionTechnologyEvent:Name()))
                    self.productionTechEvents[productionTechnologyEvent:Id()] = productionTechnologyEvent
                    productionTechnologyEvent:AddObserver(self)
                    return productionTechnologyEvent
                end
            end
            ,function(v)
                if self:FindProductionTechEventById(v.id) then
                    local productionTechnologyEvent = self:FindProductionTechEventById(v.id)
                    productionTechnologyEvent:UpdateData(v)
                    return productionTechnologyEvent
                end
            end
            ,function(v)
                if self:FindProductionTechEventById(v.id) then
                    local productionTechnologyEvent = self:FindProductionTechEventById(v.id)
                    productionTechnologyEvent:Reset()
                    self.productionTechEvents[productionTechnologyEvent:Id()] = nil
                    productionTechnologyEvent = ProductionTechnologyEvent.new()
                    productionTechnologyEvent:UpdateData(v)
                    productionTechnologyEvent:SetEntity(self:FindTechByName(productionTechnologyEvent:Name()))
                    return productionTechnologyEvent
                end
            end
        )
        self:NotifyListeneOnType(City.LISTEN_TYPE.PRODUCTION_EVENT_CHANGED, function(listener)
            listener:OnProductionTechnologyEventDataChanged(GameUtils:pack_event_table(changed_map))
        end)
    end
end

function City:IteratorProductionTechEvents(func)
    for _,v in pairs(self.productionTechEvents) do
        func(v)
    end
end


function City:OnProductionTechnologyEventTimer(productionTechnologyEvent)
    self:NotifyListeneOnType(City.LISTEN_TYPE.PRODUCTION_EVENT_TIMER, function(listener)
        listener:OnProductionTechnologyEventTimer(productionTechnologyEvent)
    end)
end

function City:HaveProductionTechEvent()
    return not LuaUtils:table_empty(self.productionTechEvents)
end
function City:GetProductionTechEventCount()
    return table.nums(self.productionTechEvents)
end

function City:GetProductionTechEventsArray()
    local r = {}
    self:IteratorProductionTechEvents(function(event)
        table.insert(r, event)
    end)
    return r
end

function City:FindProductionTechEventById(_id)
    return self.productionTechEvents[_id]
end

return City

















