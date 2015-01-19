local HOUSES = GameDatas.PlayerInitData.houses[1]
local BuildingRegister = import(".BuildingRegister")
local promise = import("..utils.promise")
local Enum = import("..utils.Enum")
local Orient = import(".Orient")
local Tile = import(".Tile")
local SoldierManager = import(".SoldierManager")
local MaterialManager = import(".MaterialManager")
local ResourceManager = import(".ResourceManager")
local Building = import(".Building")
local TowerUpgradeBuilding = import(".TowerUpgradeBuilding")
local MultiObserver = import(".MultiObserver")
local City = class("City", MultiObserver)
local ProductionTechnology = import(".ProductionTechnology")
-- 枚举定义
City.RETURN_CODE = Enum("INNER_ROUND_NOT_UNLOCKED",
    "EDGE_BESIDE_NOT_UNLOCKED",
    "HAS_NO_UNLOCK_POINT",
    "HAS_UNLOCKED",
    "OUT_OF_BOUND")
City.LISTEN_TYPE = Enum("LOCK_TILE",
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
    "MILITARY_TECHS_DATA_CHANGED")
City.RESOURCE_TYPE_TO_BUILDING_TYPE = {
    [ResourceManager.RESOURCE_TYPE.WOOD] = "woodcutter",
    [ResourceManager.RESOURCE_TYPE.FOOD] = "farmer",
    [ResourceManager.RESOURCE_TYPE.IRON] = "miner",
    [ResourceManager.RESOURCE_TYPE.STONE] = "quarrier",
    [ResourceManager.RESOURCE_TYPE.POPULATION] = "dwelling",
}
-- 初始化
function City:ctor(json_data)
    City.super.ctor(self)
    self.resource_manager = ResourceManager.new()
    self.soldier_manager = SoldierManager.new()
    self.material_manager = MaterialManager.new()

    self.belong_user = nil
    self.buildings = {}
    self.walls = {}
    self.towers = {}
    self.decorators = {}
    self.helpedByTroops = {}
    self.helpToTroops = {}
    self.productionTechs = {}
    self.militaryTechs = {}
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
function City:GetUser(user)
    return self.belong_user
end
function City:SetUser(user)
    assert(not self.belong_user, "用户一经指定就不可更改")
    self.belong_user = user
    return self
end
function City:InitWithJsonData(userData)
    local init_buildings = {}
    local init_unlock_tiles = {}

    local building_events = userData.buildingEvents
    local function get_building_event_by_location(location_id)
        if not building_events then return nil end
        for k, v in pairs(building_events) do
            if v.location == location_id then
                return v
            end
        end
    end

    table.foreach(userData.buildings, function(key, location)
        local location_config = self:GetLocationById(location.location)
        local event = get_building_event_by_location(location.location)
        local finishTime = event == nil and 0 or event.finishTime / 1000
        table.insert(init_buildings,
            self:NewBuildingWithType(location_config.building_type,
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

    table.insert(init_unlock_tiles, {x = 1, y = 5})
    table.insert(init_unlock_tiles, {x = 2, y = 5})
    table.insert(init_unlock_tiles, {x = 3, y = 5})
    table.insert(init_unlock_tiles, {x = 4, y = 5})
    self:InitTiles(5, 5, init_unlock_tiles)

    local hosue_events = userData.houseEvents
    local function get_house_event_by_location(building_location, sub_id)
        if not hosue_events then return nil end
        for k, v in pairs(hosue_events) do
            if v.buildingLocation == building_location and
                v.houseLocation == sub_id then
                return v
            end
        end
    end

    local init_decorators = {}
    table.foreach(userData.buildings, function(_, location)
        if #location.houses > 0 then
            table.foreach(location.houses, function(_, house)
                local city_location = self:GetLocationById(location.location)
                local tile_x = city_location.tile_x
                local tile_y = city_location.tile_y
                local tile = self:GetTileByIndex(tile_x, tile_y)
                local absolute_x, absolute_y = tile:GetAbsolutePositionByLocation(house.location)
                local event = get_house_event_by_location(location.location, house.location)
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
    self:InitDecorators(init_decorators)
    self:GenerateWalls()
end
function City:ResetAllListeners()
    self.resource_manager:RemoveAllObserver()
    self.soldier_manager:ClearAllListener()
    self.material_manager:RemoveAllObserver()
    self:ClearAllListener()
    self:IteratorCanUpgradeBuildings(function(building)
        building:ResetAllListeners()
        self:OnInitBuilding(building)
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
        if type_ == "keep" then
            assert(not self.keep)
            self.keep = building
        elseif type_ == "barracks" then
            assert(not self.barracks)
            self.barracks = building
        elseif type_ == "dragonEyrie" then
            assert(not self.dragonEyrie)
            self.dragonEyrie = building
        end
        self:OnInitBuilding(building)
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
        self:OnInitBuilding(building)

        local tile = self:GetTileWhichBuildingBelongs(building)
        local sub_location = tile:GetBuildingLocation(building)
        assert(sub_location)
        self:GetDecoratorsByLocationId(tile.location_id)[sub_location] = building
    end)
    self:CheckIfDecoratorsIntersectWithRuins()
end
-- 取值函数
function City:GetKeep()
    return self.keep
end
function City:GetBarracks()
    return self.barracks
end
function City:GetDragonEyrie()
    return self.dragonEyrie
end
function City:GetHousesAroundFunctionBuildingByType(building, building_type, len)
    return self:GetHousesAroundFunctionBuildingWithFilter(building, len, function(house)
        return house:GetType() == building_type
    end)
end
function City:GetHousesAroundFunctionBuildingWithFilter(building, len, filter)
    assert(self:IsFunctionBuilding(building))
    local r = {}
    self:IteratorDecoratorBuildingsByFunc(function(k, v)
        local is_neighbour = building:IsNearByBuildingWithLength(v, len)
        if is_neighbour then
            if type(filter) == "function" then
                if filter(v) then
                    table.insert(r, v)
                end
            else
                table.insert(r, v)
            end
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
    return not self:IsFunctionBuilding(building) and not self:IsTower(building) and not self:IsGate(building)
end
function City:IsTower(building)
    return iskindof(building, "TowerUpgradeBuilding")
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
local function get_unlock_buildings(buildings)
    local r = {}
    for i, v in ipairs(buildings) do
        if v:IsUnlocked() or v:IsUnlocking() then
            table.insert(r, v)
        end
    end
    return r
end
function City:GetBuildingsIsUnlocked()
    return get_unlock_buildings(self:GetNeedUnlockBuildings())
end
function City:GetUnlockedFunctionBuildings()
    return get_unlock_buildings(self:GetAllBuildings())
end
function City:GetNeedUnlockBuildings()
    local r = {}
    for i, v in pairs(self:GetAllBuildings()) do
        table.insert(r, v)
    end
    for i, v in pairs(self:GetCanUpgradingTowers()) do
        table.insert(r, v)
    end
    table.insert(r, self:GetGate())
    table.sort(r, function(a, b)
        return a:GetType() == b:GetType() and a:IsAheadOfBuilding(b) or a:IsImportantThanBuilding(b)
    end)
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
        local compare = a:GetLevel() - b:GetLevel()
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
    local x, y = building:GetLogicPosition()
    local building_type = building:GetType()
    for i, v in ipairs(self.locations) do
        if building_type == v.building_type and v.x == x and v.y == y then
            return i
        end
    end
    return nil
end
function City:GetLocationIdByBuildingType(building_type)
    for i, v in ipairs(self.locations) do
        if building_type == v.building_type then
            return i
        end
    end
    return nil
end
function City:GetBuildingByLocationId(location_id)
    return self:GetFirstBuildingByType(self.locations[location_id].building_type)
end
function City:GetBuildingByTypeWithSpecificPosition(building_type, x, y)
    for _, v in pairs(self:GetBuildingByType(building_type)) do
        if v.x == x and v.y == y then
            return v
        end
    end
    return nil
end
function City:GetFirstBuildingByType(build_type)
    return self:GetBuildingByType(build_type)[1]
end
function City:GetBuildingByType(build_type)
    local find_buildings = {}
    local filter = function(key, building)
        if building:GetType() == build_type then
            table.insert(find_buildings, building)
        end
    end
    self:IteratorFunctionBuildingsByFunc(filter)
    self:IteratorDecoratorBuildingsByFunc(filter)
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
    return self:GetTileByBuildingPosition(building.x, building.y)
end
function City:GetTileByBuildingPosition(x, y)
    return self:GetTileByIndex(self:GetTileIndexPosition(x, y))
end
function City:GetTileIndexPosition(x, y)
    return math.floor(x / 10) + 1, math.floor(y / 10) + 1
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
            if not col.locked and math.abs(x - jx) + math.abs(y - iy) <= 1 then
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
    return math.max(x, y)
end
function City:GetWalls()
    return self.walls
end
function City:GetGate()
    return self:GetGateInWalls(self.walls)
end
function City:GetGateInWalls(walls)
    local gate
    table.foreach(walls, function(k, wall)
        if wall:IsGate() then
            gate = wall
            return true
        end
    end)
    return gate
end
function City:GetTowers()
    return self.towers
end
function City:GetCanUpgradingTowers()
    local towers = {}
    table.foreach(self.towers, function(_, tower)
        if tower:IsUnlocked() then
            table.insert(towers, tower)
        end
    end)
    return towers
end
-- 工具
function City:IteratorCanUpgradeBuildings(func)
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        func(building)
    end)
    self:IteratorFunctionBuildingsByFunc(function(key, building)
        func(building)
    end)
    self:IteratorTowersByFunc(function(key, building)
        func(building)
    end)
    func(self:GetGate())
end
function City:IteratorCanUpgradeBuildingsByUserData(user_data, current_time)
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        local tile = self:GetTileWhichBuildingBelongs(building)
        building:OnUserDataChanged(user_data, current_time, tile.location_id, tile:GetBuildingLocation(building))
    end)
    self:IteratorFunctionBuildingsByFunc(function(key, building)
        building:OnUserDataChanged(user_data, current_time, self:GetLocationIdByBuilding(building))
    end)
    self:IteratorTowersByFunc(function(key, building)
        building:OnUserDataChanged(user_data, current_time)
    end)
    self:GetGate():OnUserDataChanged(user_data, current_time)
end
function City:IteratorAllNeedTimerEntity(current_time)
    self:IteratorFunctionBuildingsByFunc(function(key, building)
        building:OnTimer(current_time)
    end)
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        building:OnTimer(current_time)
    end)
    self:IteratorTowersByFunc(function(key, building)
        building:OnTimer(current_time)
    end)
    local gate = self:GetGate()
    if gate then
        gate:OnTimer(current_time)
    end
    self.resource_manager:OnTimer(current_time)
end
function City:IteratorTilesByFunc(func)
    for iy, row in pairs(self.tiles) do
        for jx, col in pairs(row) do
            if func(jx, iy, col) then
                return
            end
        end
    end
end
function City:IteratorTowersByFunc(func)
    table.foreach(self:GetCanUpgradingTowers(), func)
end
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
    local buildings = self:GetDecoratorsByType(building_type)
    local total_citizen = 0
    for k, v in pairs(buildings) do
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
function City:OnUserDataChanged(userData, current_time)
    -- 解锁，建造，拆除类事件的解析
    local lock_table = {}
    local unlock_table = {}
    local is_unlock_any_tiles = false
    local is_lock_any_tiles = false
    local need_update_resouce_buildings = false
    if userData.buildings then
        table.foreach(userData.buildings, function(key, location)
            local building = self:GetBuildingByLocationId(location.location)
            local is_unlocking = building:GetLevel() == 0 and location.level > 0
            local is_locking = building:GetLevel() > 0 and location.level <= 0
            local tile = self:GetTileByLocationId(location.location)
            if is_unlocking then
                is_unlock_any_tiles = true
                table.insert(unlock_table, {x = tile.x, y = tile.y})
            elseif is_locking then
                is_lock_any_tiles = true
                table.insert(lock_table, {x = tile.x, y = tile.y})
            end

            -- 拆除
            local decorators = self:GetDecoratorsByLocationId(location.location)
            assert(decorators)
            local find_building_info_by_location = function(houses, location_id)
                for _, v in pairs(houses) do
                    if v.location == location_id then
                        return v
                    end
                end
                return nil
            end
            table.foreach(decorators, function(key, building)
                -- 当前位置有小建筑并且推送的数据里面没有就认为是拆除
                local tile = self:GetTileWhichBuildingBelongs(building)
                local location_id = tile:GetBuildingLocation(building)
                local building_info = find_building_info_by_location(location.houses, location_id)
                -- 没有找到，就是已经被拆除了
                if not building_info then
                    self:DestoryDecorator(current_time, building)
                    need_update_resouce_buildings = true
                end
            end)

            -- 新建的
            local hosue_events = userData.houseEvents
            if hosue_events then
                local function get_house_event_by_location(building_location, sub_id)
                    for k, v in pairs(hosue_events) do
                        if v.buildingLocation == building_location and
                            v.houseLocation == sub_id then
                            return v
                        end
                    end
                end
                table.foreach(location.houses, function(key, house)
                    -- 当前位置没有小建筑并且推送的数据里面有就认为新建小建筑
                    if not decorators[house.location] then
                        local tile = self:GetTileByLocationId(location.location)
                        local absolute_x, absolute_y = tile:GetAbsolutePositionByLocation(house.location)
                        local event = get_house_event_by_location(location.location, house.location)
                        -- local finishTime = event == nil and 0 or event.finishTime / 1000
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
                        need_update_resouce_buildings = true
                    end
                end)
            end
        end)
    end
    -- 更新地块信息
    if is_unlock_any_tiles then
        LuaUtils:outputTable("unlock_table", unlock_table)
        self:UnlockTilesByIndexArray(unlock_table)
    end
    if is_lock_any_tiles then
        LuaUtils:outputTable("lock_table", lock_table)
        self:LockTilesByIndexArray(lock_table)
    end
    -- 更新建筑信息
    self:IteratorCanUpgradeBuildingsByUserData(userData, current_time)
    -- 更新协防信息
    self:OnHelpedByTroopsDataChange(userData.helpedByTroops)
    self:__OnHelpedByTroopsDataChange(userData.__helpedByTroops)
    --更新派出的协防信息
    self:OnHelpToTroopsDataChange(userData.helpToTroops)
    self:__OnHelpToTroopsDataChange(userData.__helpToTroops)
    --科技
    self:OnProductionTechsDataChanged(userData.productionTechs)
    self:__OnProductionTechsDataChanged(userData.__productionTechs)
    --军事科技
    self:OnMilitaryTechsDataChanged(userData.militaryTechs)
    self:__OnMilitaryTechsDataChanged(userData.__militaryTechs)
    -- 更新兵种
    self.soldier_manager:OnUserDataChanged(userData)
    -- 更新材料，这里是广义的材料，包括龙的装备
    self.material_manager:OnUserDataChanged(userData)
    -- 最后才更新资源
    local basicInfo = userData.basicInfo
    local resource_refresh_time = current_time
    if basicInfo then
        resource_refresh_time = basicInfo.resourceRefreshTime / 1000

        self.build_queue = basicInfo.buildQueue
        self:SetCityName(basicInfo.cityName)

        if userData.resources then
            self.resource_manager:UpdateFromUserDataByTime(userData.resources, resource_refresh_time)
            need_update_resouce_buildings = true
        end
    end
    if need_update_resouce_buildings then
        self.resource_manager:UpdateByCity(self, resource_refresh_time)
        self.resource_manager:UpdateResourceByTime(current_time)
    end
    return self
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
    self:OnInitBuilding(building)
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
function City:OnBuildingUpgradeFinished(building, current_time)
    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgradingFinished(building, current_time, self)
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
function City:OnInitBuilding(building)
    building.city = self
    building:AddUpgradeListener(self)
end
---------
function City:GenerateWalls()
    local find_wall_neg_and_remove_dup = function (walls, wall)
        for i, v in ipairs(walls) do
            if wall:IsNearByOtherWall(v) then
                table.remove(walls, i)
                return true
            end
        end
        return false
    end
    local find_beside_wall = function(walls, wall)
        local next_pos = wall:GetEndPos()
        for i, v in ipairs(walls) do
            if wall:IsEndJoinStartWithOtherWall(v) then
                return i
            end
        end
        return false
    end
    local find_gate = function(walls)
        local t = {}
        for i, v in ipairs(walls) do
            if v.orient == Orient.X then
                local dup = false
                for _, w in pairs(t) do
                    if w.y == v.y then
                        dup = true
                        break
                    end
                end
                if not dup then
                    table.insert(t, v)
                end
            end
        end
        return t[math.ceil((#t + 1) / 2)]
    end

    -- 找出所有块的边,去除重复边
    local walls = {}
    self:IteratorTilesByFunc(function(x, y, tile)
        if tile:IsUnlocked() then
            tile:IteratorWallsAroundSelf(function(dir, wall)
                if not find_wall_neg_and_remove_dup(walls, wall) then
                    table.insert(walls, wall)
                end
            end)
        end
    end)

    -- 边排序,首尾相连接
    local first = table.remove(walls, 1)
    local sort_walls = { first }
    while #walls > 0 do
        local index = find_beside_wall(walls, first)
        if index then
            first = table.remove(walls, index)
            table.insert(sort_walls, first)
        else
            break
        end
    end

    -- 找出城门
    local gate = find_gate(sort_walls)
    for i, v in ipairs(sort_walls) do
        if v.x == gate.x and v.y == gate.y and v.orient == gate.orient then
            v:SetGate()
            break
        end
    end

    -- 重新生成城门的监听
    self.walls = self:ReloadWalls(sort_walls)

    -- 生成防御塔
    self:GenerateTowers(sort_walls)
end
-- 因为重新生成了城墙，所以必须把添加的listener都转移到新的城门上去
function City:ReloadWalls(walls)
    local old_walls = self.walls
    local old_gate = self:GetGateInWalls(old_walls)
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
    else
        -- 如果是第一次生成
        self:OnInitBuilding(self:GetGateInWalls(walls))
    end
    local t = {}
    for _, v in ipairs(walls) do
        local x, y = v:GetLogicPosition()
        if x > 0 and y > 0 then
            table.insert(t, v)
        end
    end
    return t
        -- return walls
end
function City:GenerateTowers(walls)
    local towers = {}
    local p = walls[#walls]:IntersectWithOtherWall(walls[1])
    table.insert(towers,
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
            table.insert(towers,
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

    local mx, my = 0, 0
    local index
    for i, v in ipairs(towers) do
        if v.x == v.y and v.x > mx then
            mx, my = v.x, v.y
            index = i
        end
    end

    local t = {}
    local tower_limit = self:GetUnlockTowerLimit()
    table.insert(t, index)
    local i = 1
    repeat
        table.insert(t, index + i)
        if #t >= tower_limit then
            break
        end
        table.insert(t, index - i)
        i = i + 1
    until #t >= tower_limit

    for tower_id, tower_index in ipairs(t) do
        towers[tower_index]:SetTowerId(tower_id)
    end
    local t = {}
    for _, v in ipairs(towers) do
        if (v:GetOrient() ~= Orient.NEG_X and
            v:GetOrient() ~= Orient.NEG_Y and
            v:GetOrient() ~= Orient.UP) or
            v:TowerId() then
            table.insert(t, v)
        end
    end
    self.towers = self:ReloadTowers(t)
end
function City:ReloadTowers(towers)
    local old_towers = self.towers
    local old_tower_map = {}
    for k, v in pairs(old_towers) do
        if v:IsUnlocked() then
            old_tower_map[v:TowerId()] = v
        end
    end


    for i, v in ipairs(towers) do
        if v:IsUnlocked() then
            local old_tower = old_tower_map[v:TowerId()]
            -- 已经解锁的
            if old_tower then
                towers[i] = old_tower
                old_tower:CopyValueFrom(v)
            else
                -- 如果是新解锁的
                self:OnInitBuilding(v)
            end
        end
    end
    return towers
end
local function findTroopsInHelpedByTroops(helpedByTroops, troops)
    for i, v in pairs(helpedByTroops) do
        if v.id == troops.id then
            return true
        end
    end
end
function City:OnHelpedByTroopsDataChange(helpedByTroops)
    if not helpedByTroops then return end
    local add = {}
    local removed = {}
    for i, v in pairs(helpedByTroops) do
        if not findTroopsInHelpedByTroops(self.helpedByTroops, v) then
            table.insert(add, v)
        end
    end
    for i, v in pairs(self.helpedByTroops) do
        if not findTroopsInHelpedByTroops(helpedByTroops, v) then
            table.insert(removed, v)
        end
    end
    self.helpedByTroops = helpedByTroops
    self:NotifyListeneOnType(City.LISTEN_TYPE.HELPED_BY_TROOPS, function(listener)
        listener:OnHelpedTroopsChanged(self, {
            add = add,
            removed = removed,
            edit = {}
        })
    end)
end
function City:__OnHelpedByTroopsDataChange(__helpedByTroops)
    if not __helpedByTroops then return end
    for _,v in ipairs(__helpedByTroops) do
        if v.type == "add" then
            self:AddHelpedByTroops(v.data)
        elseif v.type == "remove" then
            self:RemoveHelpedByTroops(v.data)
        else
            assert(false)
        end
    end
end
function City:AddHelpedByTroops(troops)
    table.insert(self.helpedByTroops, troops)
    self:NotifyListeneOnType(City.LISTEN_TYPE.HELPED_BY_TROOPS, function(listener)
        listener:OnHelpedTroopsChanged(self, {
            add = {troops},
            removed = {},
            edit = {}
        })
    end)
    return troops
end
function City:RemoveHelpedByTroops(troops)
    for i, v in pairs(self.helpedByTroops) do
        if v.id == troops.id then
            local removed = table.remove(self.helpedByTroops, i)
            self:NotifyListeneOnType(City.LISTEN_TYPE.HELPED_BY_TROOPS, function(listener)
                listener:OnHelpedTroopsChanged(self, {
                    add = {},
                    removed = {removed},
                    edit = {}
                })
            end)
            return removed
        end
    end
end

--helpToTroops
function City:OnHelpToTroopsDataChange(helpToTroops)
    if not helpToTroops then return end
    for _,v in ipairs(helpToTroops) do
        if not self.helpToTroops[v.beHelpedPlayerData.id] then
            self.helpToTroops[v.beHelpedPlayerData.id] = v
        end
    end
end

function City:__OnHelpToTroopsDataChange(__helpToTroops)
    if not __helpToTroops then return end
    local change_map = GameUtils:Event_Handler_Func(
        __helpToTroops
        ,function(data)
            if not self.helpToTroops[data.beHelpedPlayerData.id] then
                self.helpToTroops[data.beHelpedPlayerData.id] = data
            end
            return data
        end
        ,function(data)
            -- 会修改已经派出协防的信息?
            return nil
        end
        ,function(data)
            if self.helpToTroops[data.beHelpedPlayerData.id] then
                self.helpToTroops[data.beHelpedPlayerData.id] = nil
                return data
            end
        end
    )
    self:__OnHelpToTroopsDataChanged(GameUtils:pack_event_table(change_map))
end

function City:__OnHelpToTroopsDataChanged(changed_map)
    self:NotifyListeneOnType(City.LISTEN_TYPE.HELPED_TO_TROOPS, function(listener)
        listener:OnHelpToTroopsChanged(self,changed_map)
    end)
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

function City:IsHelpedToTroopsWithPlayerId(id)
    return self:GetHelpToTroops(id) ~= nil
end

-- promise
local function promiseOfBuilding(callbacks, building_type, level)
    assert(building_type)
    assert(#callbacks == 0)
    local p = promise.new()
    table.insert(callbacks, function(building)
        if (building:GetType() == building_type) and
            (not level or level == building:GetLevel()) then
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
    return self:GetBarracks():PromiseOfRecruitSoldier(soldier_type)
end
function City:PromiseOfFinishSoldier(soldier_type)
    return self:GetBarracks():PromiseOfFinishSoldier(soldier_type)
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
    for name,v in pairs(productionTechs) do
        local productionTechnology = ProductionTechnology.new()
        productionTechnology:UpdateData(name,v)
        if not self.productionTechs[productionTechnology:Index()] then
            self.productionTechs[productionTechnology:Index()] = productionTechnology
        end
    end
    self:FastUpdateAllTechsLockState()
    self:DumpAllTechs()
end

function City:IteratorTechs(func)
    for index,v in pairs(self.productionTechs) do
        func(k,v)
    end
end

function City:FindTechByName(name)
    self:IteratorTechs(function(index,tech)
        if tech:Name() == name then
            return name
        end
    end)
end

function City:FindTechByIndex(index)
    index = checkint(index)
    return self.productionTechs[index]
end

function City:__OnProductionTechsDataChanged(__productionTechs)
    if not __productionTechs then return end
    local changed_map = GameUtils:Event_Handler_Func(
        __productionTechs
        ,function(data)
            assert(false,"会添加科技?")
        end
        ,function(data)
            local productionTechnology = self:FindTechByIndex(data.index)
            if productionTechnology then
                productionTechnology:SetLevel(data.level)
                self:CheckDependTechsLockState(productionTechnology)
            end
        end
        ,function(data)
            assert(false,"会删除科技?")
        end
    )
    self:NotifyListeneOnType(City.LISTEN_TYPE.PRODUCTION_DATA_CHANGED, function(listener)
        listener:OnProductionTechsDataChanged(self,changed_map)
    end)
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
    local targetTechs = self:FindDependOnTheTechs(tech)
    for _,tech_ in ipairs(targetTechs) do
        tech_:SetIsLock(tech:Level() >= tech_:UnlockLevel())
    end
end

function City:FastUpdateAllTechsLockState()
    self:IteratorTechs(function(index,tech)
        local unLockByTech = self:FindTechByIndex(tech:UnlockBy())
        if unLockByTech and tech:Index() < 10 then --暂时不开放
            tech:SetIsLock(tech:UnlockLevel() <= unLockByTech:Level())
        end
    end)
end

function City:DumpAllTechs()
-- dump(self.productionTechs,"productionTechs-->" .. os.time())
end

function City:OnMilitaryTechsDataChanged(militaryTechs)
    if not militaryTechs then return end
    for name,v in pairs(militaryTechs) do
        self.militaryTechs[name] = v
    end
end
function City:IteratorMilitaryTechs(func)
    for name,v in pairs(self.militaryTechs) do
        func(k,v)
    end
end
function City:FindMilitaryTechsByBuildingType(building_type)
    local techs = {}
    self.IteratorMilitaryTechs(function ( name,v )
        if building_type == v.building then
            table.insert(techs, v)
        end
    end)
    return techs
end
function City:__OnMilitaryTechsDataChanged(__militaryTechs)
    if not __militaryTechs then return end
    local changed_map = GameUtils:Event_Handler_Func(
        __militaryTechs
        ,function(data)
            assert(false,"会添加军事科技?")
        end
        ,function(data)
            return data
        end
        ,function(data)
            assert(false,"会删除军事科技?")
        end
    )
    self:NotifyListeneOnType(City.LISTEN_TYPE.MILITARY_TECHS_DATA_CHANGED, function(listener)
        listener:OnMilitaryTechsDataChanged(self,changed_map)
    end)
end

return City


















