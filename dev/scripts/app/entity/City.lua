-- 引入外部包
local BuildingRegister = import(".BuildingRegister")
local Enum = import("..utils.Enum")
local Orient = import(".Orient")
local Tile = import(".Tile")
local SoldierManager = import(".SoldierManager")
-- local DragonEquipManager = import(".DragonEquipManager")
local MaterialManager = import(".MaterialManager")
local ResourceManager = import(".ResourceManager")
local Building = import(".Building")
local TowerUpgradeBuilding = import(".TowerUpgradeBuilding")
local FoodResourceUpgradeBuilding = import(".FoodResourceUpgradeBuilding")
local WoodResourceUpgradeBuilding = import(".WoodResourceUpgradeBuilding")
local IronResourceUpgradeBuilding = import(".IronResourceUpgradeBuilding")
local StoneResourceUpgradeBuilding = import(".StoneResourceUpgradeBuilding")
local PopulationResourceUpgradeBuilding = import(".PopulationResourceUpgradeBuilding")
local MultiObserver = import(".MultiObserver")
local City = class("City", MultiObserver)
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
    "UPGRADE_BUILDING")
City.RESOURCE_TYPE_TO_BUILDING_TYPE = {
    [ResourceManager.RESOURCE_TYPE.WOOD] = "woodcutter",
    [ResourceManager.RESOURCE_TYPE.FOOD] = "farmer",
    [ResourceManager.RESOURCE_TYPE.IRON] = "miner",
    [ResourceManager.RESOURCE_TYPE.STONE] = "quarrier",
    [ResourceManager.RESOURCE_TYPE.POPULATION] = "dwelling",
}
-- 初始化
function City:ctor()
    City.super.ctor(self)
    self.resource_manager = ResourceManager.new()
    self.soldier_manager = SoldierManager.new()
    -- self.equip_manager = DragonEquipManager.new()
    self.material_manager = MaterialManager.new()

    self.buildings = {}
    self.walls = {}
    self.towers = {}
    self.decorators = {}

    self.dwelling_count_max = 5

    self.locations_decorators = {}
    self:InitLocations()
    self:InitRuins()
end
function City:InitRuins()
    self.ruins = {}
    for _,v in ipairs(GameDatas.ClientInitGame['ruins']) do
        table.insert(self.ruins, Building.new({ x = v.x, y = v.y, building_type = v.building_type, w = v.w, h = v.h}))
    end
    -- GameDatas.ClientInitGame['ruins'] = {}
end
function City:InitTiles(w, h, unlocked)
    self.tiles = {}
    for y = 1, h do
        table.insert(self.tiles, {})
        for x = 1, w do
            for location_id, location in pairs(self.locations) do
                if location.tile_x == x and location.tile_y == y then
                    self.tiles[y][x] = Tile.new({x = x, y = y, locked = true, location_id = location_id})
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
-- function City:GetEquipManager()
--     return self.equip_manager
-- end
function City:GetSoldierManager()
    return self.soldier_manager
end
function City:GetMaterialManager()
    return self.material_manager
end
function City:GetResourceManager()
    return self.resource_manager
end
function City:GetDwellingCounts()
    return self.dwelling_count_max - #self:GetBuildingByType("dwelling")
end
function City:GetAllBuildings()
    return self.buildings
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
    local tile = self:GetTileWhichBuildingBelongs(building)
    return tile.location_id
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
                return Tile.new({x = x, y = y, locked = false})
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
-- 取得住宅最大建造数量
function City:GetMaxDwellingCanBeBuilt()
-- self:GetBuildingByType("build_type")
end
-- 取得小屋最大建造数量
function City:GetMaxHouseCanBeBuilt(house_type)
    local max = GameDatas.PlayerInitData.houses[1][house_type] --基础值

    if house_type=="farmer" then
        for _,mill in pairs(self:GetBuildingByType("mill")) do
            max = max + mill:GetMaxHouseNum()
        end
    elseif house_type=="woodcutter" then
        for _,lumbermill in pairs(self:GetBuildingByType("lumbermill")) do
            max = max + lumbermill:GetMaxHouseNum()
        end
    elseif house_type=="quarrier" then
        for _,stoneMason in pairs(self:GetBuildingByType("stoneMason")) do
            max = max + stoneMason:GetMaxHouseNum()
        end
    elseif house_type=="miner" then
        for _,foundry in pairs(self:GetBuildingByType("foundry")) do
            max = max + foundry:GetMaxHouseNum()
        end
    end

    return max
end
function City:IsUnLockedAtIndex(x, y)
    return not self.tiles[y][x].locked
end
function City:IsTileCanbeUnlockAt(x, y)
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
    local gate
    table.foreach(self.walls, function(k, wall)
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
function City:IteratorCanUpgradeBuildingsByUserData(user_data, current_time)
    self:IteratorDecoratorBuildingsByFunc(function(key, building)
        local tile = self:GetTileWhichBuildingBelongs(building)
        building:OnUserDataChanged(user_data, current_time, tile.location_id, tile:GetBuildingLocation(building))
    end)
    self:IteratorFunctionBuildingsByFunc(function(key, building)
        building:OnUserDataChanged(user_data, current_time, self:GetTileWhichBuildingBelongs(building).location_id)
    end)
    self:IteratorTowersByFunc(function(key, building)
        building:OnUserDataChanged(user_data, current_time)
    end)
    self:GetGate():OnUserDataChanged(user_data, current_time)
end
function City:IteratorResourcesByUserData(user_data, current_time)
    local resource_manager = self:GetResourceManager()
    resource_manager:GetEnergyResource():UpdateResource(current_time, user_data.resources.energy)
    resource_manager:GetWoodResource():UpdateResource(current_time, user_data.resources.wood)
    resource_manager:GetFoodResource():UpdateResource(current_time, user_data.resources.food)
    resource_manager:GetIronResource():UpdateResource(current_time, user_data.resources.iron)
    resource_manager:GetStoneResource():UpdateResource(current_time, user_data.resources.stone)
    resource_manager:GetPopulationResource():UpdateResource(current_time, user_data.resources.citizen)
    resource_manager:GetCoinResource():SetValue(user_data.resources.coin)
    resource_manager:GetGemResource():SetValue(user_data.resources.gem)
    self:UpdateAllResource(current_time)
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
            end
        end)

        -- 新建的
        local hosue_events = userData.houseEvents
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
                local finishTime = event == nil and 0 or event.finishTime / 1000
                self:CreateDecorator(current_time, BuildingRegister[house.type].new({
                    x = absolute_x,
                    y = absolute_y,
                    w = 3,
                    h = 3,
                    building_type = house.type,
                    level = house.level,
                    finishTime = finishTime,
                }))
            end
        end)
    end)
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

    -- 更新兵种
    self.soldier_manager:OnUserDataChanged(userData)
    -- 更新装备
    -- self.equip_manager:OnUserDataChanged(userData)
    -- 更新材料，这里是广义的材料，包括龙的装备
    self.material_manager:OnUserDataChanged(userData)
    -- 最后才更新资源
    local resource_refresh_time = userData.basicInfo.resourceRefreshTime / 1000
    self:IteratorResourcesByUserData(userData, resource_refresh_time)
end
function City:OnCreateDecorator(current_time, building)
    building:AddUpgradeListener(self)

    self:UpdateResourceByBuilding(current_time, building)
end
function City:OnDestoryDecorator(current_time, building)
    building:RemoveUpgradeListener(self)

    self:UpdateResourceByBuilding(current_time, building)
end
function City:OnBuildingUpgradingBegin(building, current_time)
    self:UpdateResourceByBuilding(current_time, building)

    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgradingBegin(building, current_time, self)
    end)
end
function City:OnBuildingUpgrading(building, current_time)
    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgrading(building, current_time, self)
    end)
end
function City:OnBuildingUpgradeFinished(building, current_time)
    self:UpdateResourceByBuilding(current_time, building)

    self:NotifyListeneOnType(City.LISTEN_TYPE.UPGRADE_BUILDING, function(listener)
        listener:OnUpgradingFinished(building, current_time, self)
    end)
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
-----
function City:UpdateAllResource(current_time)
    self.resource_manager:OnBuildingChangedFromCity(self, current_time, nil)
end
function City:UpdateResourceByBuilding(current_time, building)
    self.resource_manager:OnBuildingChangedFromCity(self, current_time, building)
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
    local first = walls[1]
    table.remove(walls, 1)
    local sort_walls = { first }
    while #walls > 0 do
        local index = find_beside_wall(walls, first)
        if index then
            first = walls[index]
            table.insert(sort_walls, walls[index])
            table.remove(walls, index)
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

    self.walls = sort_walls

    -- 生成防御塔
    self:GenerateTowers(self.walls)
end
function City:GenerateTowers(walls)
    self.towers = {}
    local p = walls[#walls]:IntersectWithOtherWall(walls[1])
    table.insert(self.towers, TowerUpgradeBuilding.new({ x = p.x, y = p.y,
        building_type = "tower",
        level = -1,
        orient = p.orient }))

    for i, v in pairs(walls) do
        if i < #walls then
            local p = walls[i]:IntersectWithOtherWall(walls[i + 1])
            table.insert(self.towers, TowerUpgradeBuilding.new({
                x = p.x, y = p.y,
                building_type = "tower",
                level = -1,
                orient = p.orient }))
        end
    end

    local towers = self.towers
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
        local tower = towers[tower_index]
        tower.tower_id = tower_id
    end
end


function City:OnUpgradingBuildings()
    local upgrading_buildings = {} 
    for i,v in ipairs(self.buildings) do
        print("OnUpgradingBuildings==========啊啊啊啊",i,v)

        if v:IsUpgrading() then
            upgrading_buildings[i] = v
        end
    end
    return upgrading_buildings
end

return City















































