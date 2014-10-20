local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local DragonEyrieSprite = import("..sprites.DragonEyrieSprite")
local FunctionUpgradingSprite = import("..sprites.FunctionUpgradingSprite")
local UpgradingSprite = import("..sprites.UpgradingSprite")
local RuinSprite = import("..sprites.RuinSprite")
local TowerUpgradingSprite = import("..sprites.TowerUpgradingSprite")
local WallUpgradingSprite = import("..sprites.WallUpgradingSprite")
local RoadSprite = import("..sprites.RoadSprite")
local TreeSprite = import("..sprites.TreeSprite")
local SingleTreeSprite = import("..sprites.SingleTreeSprite")
local CitizenSprite = import("..sprites.CitizenSprite")
local SoldierSprite = import("..sprites.SoldierSprite")
local SoldierManager = import("..entity.SoldierManager")
local Observer = import("..entity.Observer")
local MapLayer = import(".MapLayer")
local CityLayer = class("CityLayer", MapLayer)

local math = math
local floor = math.floor
local random = math.random
local randomseed = math.randomseed
function CityLayer:GetClickedObject(x, y, world_x, world_y)
    local clicked_list = {
        logic_clicked = {},
        sprite_clicked = {}
    }
    self:IteratorClickAble(function(k, v)
        if not v:isVisible() then return false end
        if v:GetEntity():GetType() == "wall" and not v:GetEntity():IsGate() then return false end
        if v:GetEntity():GetType() == "tower" and not v:GetEntity():IsUnlocked() then return false end

        local check = v:IsContainPointWithFullCheck(x, y, world_x, world_y)
        if check.logic_clicked then
            table.insert(clicked_list.logic_clicked, v)
            return true
        elseif check.sprite_clicked then
            table.insert(clicked_list.sprite_clicked, v)
        end
    end)
    table.sort(clicked_list.logic_clicked, function(a, b)
        return a:getLocalZOrder() > b:getLocalZOrder()
    end)
    table.sort(clicked_list.sprite_clicked, function(a, b)
        return a:getLocalZOrder() > b:getLocalZOrder()
    end)
    local logic = clicked_list.logic_clicked[1]
    return logic == nil and clicked_list.sprite_clicked[1] or logic
end
function CityLayer:OnTileLocked(city)
    self:OnTileChanged(city)
end
function CityLayer:OnTileUnlocked(city)
    self:OnTileChanged(city)
end
function CityLayer:OnTileChanged(city)
    self:UpdateRuinsVisibleWithCity(city)
    self:UpdateSingleTreeVisibleWithCity(city)
    self:UpdateAllDynamicWithCity(city)
end
function CityLayer:OnRoundUnlocked(round)
    print("OnRoundUnlocked", round)
end
function CityLayer:OnOccupyRuins(occupied_ruins)
    for _, occupy_ruin in pairs(occupied_ruins) do
        for _, ruin_sprite in pairs(self.ruins) do
            if occupy_ruin:IsSamePositionWith(ruin_sprite) then
                ruin_sprite:setVisible(false)
            end
        end
    end
end
function CityLayer:OnCreateDecorator(building)
    local city_node = self:GetCityNode()
    local house = self:CreateDecorator(building)
    city_node:addChild(house)
    table.insert(self.houses, house)

    self:NotifyObservers(function(listener)
        listener:OnCreateDecoratorSprite(house)
    end)
end
function CityLayer:OnDestoryDecorator(destory_decorator, release_ruins)
    for i, house in pairs(self.houses) do
        local x, y = house:GetLogicPosition()
        if destory_decorator:IsSamePositionWith(house) then
            self:NotifyObservers(function(listener)
                listener:OnDestoryDecoratorSprite(house)
            end)

            table.remove(self.houses, i)
            -- house:DestoryShadow()
            house:removeFromParentAndCleanup(true)
            break
        end
    end
    --
    for _, release_ruin in pairs(release_ruins) do
        for _, ruin_sprite in pairs(self.ruins) do
            if release_ruin:IsSamePositionWith(ruin_sprite) then
                ruin_sprite:setVisible(true)
            end
        end
    end
end
function CityLayer:OnSoliderCountChanged(soldier_manager, changed)
    self:UpdateSoldiersVisibleWithSoldierManager(soldier_manager)
end
-----
local SCENE_BACKGROUND = 1
local BACK_NODE = 1
local CITY_LAYER = 3
local CITY_BACKGROUND = 1
local ROAD_NODE = 2
local BUILDING_NODE = 3
----
local TERRAIN_MAP = {
    ["grass"] = {background = "tmxmaps/grass_background1.tmx"},
    ["desert"] = {background = "tmxmaps/desert_background1.tmx"},
    ["icefield"] = {background = "tmxmaps/icefield_background1.tmx"},
}
local GROUNDS_MAP = {
    grass = {"grass_ground1_800x560.png", "grass_ground2_800x560.png"},
    desert = {"desert1_800x560.png", "desert2_800x560.png"},
    icefield = {"icefield1_800x560.png", "icefield2_800x560.png"},
}
local ROADS_MAP = {
    grass = {"road1_800x560.png", "road2_800x560.png", "ground_766x558.png"},
    desert = {"road1_800x560.png", "road2_800x560.png", "ground_766x558.png"},
    icefield = {"road1_800x560.png", "road2_800x560.png", "ground_766x558.png"},
}
function CityLayer:ctor(city)
    CityLayer.super.ctor(self, 0.3, 1)
    Observer.extend(self)
    self.terrain_type = "grass"
    self.buildings = {}
    self.houses = {}
    self.towers = {}
    self.ruins = {}
    self.trees = {}
    self.walls = {}
    self.road = nil
    self:InitBackground()
    self.back_node = display.newNode():addTo(self, BACK_NODE)
    self.city_layer = display.newLayer():addTo(self, CITY_LAYER):align(display.BOTTOM_LEFT, 1000, 420)
    self.city_background = cc.TMXTiledMap:create("tmxmaps/background2.tmx"):addTo(self.city_layer):hide()
    self.position_node = cc.TMXTiledMap:create("tmxmaps/city_road.tmx"):addTo(self.city_layer):hide()
    self.tile_node = display.newNode():addTo(self.city_layer, CITY_BACKGROUND)
    self.road_node = display.newNode():addTo(self.city_layer, ROAD_NODE)
    self.city_node = display.newLayer():addTo(self.city_layer, BUILDING_NODE):align(display.BOTTOM_LEFT)

    randomseed(DataManager:getUserData().countInfo.registerTime)
    self:InitBackgroundsWithRandom()
    self:InitCityBackgroundsWithRandom()
    self:InitRoadsWithRandom()


    local origin_point = self:GetPositionIndex(0, 0)
    self.iso_map = IsoMapAnchorBottomLeft.new({
        tile_w = 80,
        tile_h = 56,
        map_width = 50,
        map_height = 50,
        base_x = origin_point.x,
        base_y = origin_point.y
    })
end
function CityLayer:GetLogicMap()
    return self.iso_map
end
function CityLayer:ConvertLogicPositionToMapPosition(lx, ly)
    local map_pos = cc.p(self.iso_map:ConvertToMapPosition(lx, ly))
    return self:convertToNodeSpace(self:GetCityNode():convertToWorldSpace(map_pos))
end
function CityLayer:CurrentTerrain()
    return self.terrain_type
end
--
function CityLayer:InitBackground()
    self:ReloadSceneBackground()
end
---
function CityLayer:InitBackgroundsWithRandom()
    local back_size = self:GetBackgroundLayer():getLayerSize()
    local end_x = back_size.width - 1
    local end_y = back_size.height - 1
    for x = 0, end_x do
        for y = 0, end_y do
            local point = self:GetBackgroundLayer():getPositionAt(cc.p(x, y))
            local png = floor(random() * 1000) % 2 == 0 and "trees_490x450.png" or "trees_516x433.png"
            repeat
                -- 靠上边是山
                local near_up_side = y == 0 or y == 1
                if near_up_side then
                    display.newSprite("quarrier_1_303x296.png"):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 靠其他边是树
                local near_other_side = x == 0 or x == back_size.width - 1 or x == back_size.width - 2 or y == back_size.height - 1
                if near_other_side then
                    display.newSprite(png):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 左上角是树
                if
                    x + y <= 4
                    or (x == 1 and y == 5)
                    or (x == 5 and y == 1)
                then
                    display.newSprite(png):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 左下角是树
                if x + (end_y - y) <= 4 then
                    display.newSprite(png):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 右上角是树
                if (end_x - x) + y <= 5 then
                    display.newSprite(png):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 右上角是树
                if (end_x - x) + (end_y - y) <= 5 then
                    display.newSprite(png):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 左上角的麦蒂
                if x + y == 5 then
                    display.newSprite("corn_391x306.png"):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

                -- 左下角的矿山
                if x + (end_y - y) == 5 then
                    display.newSprite("stone_396x318.png"):addTo(self.back_node)
                        :align(display.BOTTOM_LEFT, point.x, point.y)
                    break
                end

            until true
        end
    end
end
function CityLayer:InitCityBackgroundsWithRandom()
    local city_backgrounds_map = {}
    for row_index = 1, 5 do
        local row = {}
        for col = 1, 5 do
            local png_index = floor(random() * 1000) % 2 == 0 and 1 or 2
            local flipx = floor(random() * 1000) % 2 == 0 and true or false
            local flipy = floor(random() * 1000) % 2 == 0 and true or false
            row[col] = {png_index = png_index, flipx = flipx, flipy = flipy, visible = false}
        end
        city_backgrounds_map[row_index] = row
    end
    self.city_backgrounds_map = city_backgrounds_map
    self:RefreshCityBackgroundsByMap(city_backgrounds_map)
end
-- 更新只会影响可见性
function CityLayer:UpdateCityBackgroundsByMap(map)
    local city_backgrounds = self.city_backgrounds
    for row_index, row in ipairs(map) do
        for col_index, v in ipairs(row) do
            city_backgrounds[row_index][col_index]:setVisible(v.visible)
        end
    end
end
-- 刷新会重新生成地图
function CityLayer:RefreshCityBackgroundsByMap(map)
    assert(self.tile_node, "场景背景必须被生成!")
    self.tile_node:removeAllChildren()
    local city_backgrounds = {{}, {}, {}, {}, {}}
    for row_index, row in ipairs(map) do
        for col_index, v in ipairs(row) do
            local point = self:GetTileLayer():getPositionAt(cc.p(col_index - 1, row_index - 1))
            local ground = display.newSprite(GROUNDS_MAP[self.terrain_type][v.png_index])
                :addTo(self.tile_node)
                :align(display.BOTTOM_LEFT, point.x, point.y)
                :flipX(v.flipx):flipY(v.flipy)

            ground:setVisible(v.visible)
            city_backgrounds[row_index][col_index] = ground
        end
    end
    self.city_backgrounds = city_backgrounds
end
function CityLayer:GetCityBackgroundsMap()
    return self.city_backgrounds_map
end
function CityLayer:GetCityBackgrounds()
    return self.city_backgrounds
end
--
function CityLayer:InitRoadsWithRandom()
    local roads_map = {}
    for row_index = 1, 5 do
        local row = {}
        for col_index = 1, 5 do
            local png_index = floor(random() * 1000) % 2 == 0 and 1 or 2
            row[col_index] = {png_index = png_index, visible = false}
        end
        roads_map[row_index] = row
    end
    self.roads_map = roads_map
    self:RefreshRoadsByMap(roads_map)
end
-- 刷新会重新生成地图
function CityLayer:RefreshRoadsByMap(map)
    assert(self.road_node, "场景背景必须被生成!")
    self.road_node:removeAllChildren()
    local roads = {{}, {}, {}, {}, {}}
    for row_index, row in ipairs(map) do
        for col_index, v in ipairs(row) do
            local point = self:GetTileLayer():getPositionAt(cc.p(col_index - 1, row_index - 1))
            local road = display.newSprite(ROADS_MAP[self.terrain_type][v.png_index])
                :addTo(self.road_node)
                :align(display.BOTTOM_LEFT, point.x, point.y)
            road:setVisible(v.visible)
            roads[row_index][col_index] = road
        end
    end
    local point = self:GetTileLayer():getPositionAt(cc.p(0, 1))
    display.newSprite(ROADS_MAP[self.terrain_type][3])
        :addTo(self.road_node):align(display.BOTTOM_LEFT, point.x + 20, point.y - 20)
    self.roads = roads
end
-- 更新只会影响可见性
function CityLayer:UpdateRoadsByMap(map)
    local roads = self.roads
    for row_index, row in ipairs(map) do
        for col_index, v in ipairs(row) do
            roads[row_index][col_index]:setVisible(v.visible)
        end
    end
end
function CityLayer:ChangeTerrain(terrain_type)
    if self.terrain_type ~= terrain_type then
        self.terrain_type = terrain_type
        self:ReloadSceneBackground()
        self:RefreshCityBackgroundsByMap(self.city_backgrounds_map)
        self:RefreshRoadsByMap(self.roads_map)
        table.foreach(self.trees, function(_, v)
            v:ReloadSpriteCauseTerrainChanged()
        end)
        table.foreach(self.single_tree, function(_, v)
            v:ReloadSpriteCauseTerrainChanged()
        end)
        table.foreach(self.buildings, function(_, v)
            v:ReloadSpriteCauseTerrainChanged()
        end)
    end
end
--
function CityLayer:ReloadSceneBackground()
    if self.background then
        self.background:removeFromParent()
    end
    self.background = cc.TMXTiledMap:create(TERRAIN_MAP[self.terrain_type].background):addTo(self, SCENE_BACKGROUND)
end
function CityLayer:InitWithCity(city)
    city:AddListenOnType(self, city.LISTEN_TYPE.UNLOCK_TILE)
    city:AddListenOnType(self, city.LISTEN_TYPE.LOCK_TILE)
    city:AddListenOnType(self, city.LISTEN_TYPE.UNLOCK_ROUND)
    city:AddListenOnType(self, city.LISTEN_TYPE.OCCUPY_RUINS)
    city:AddListenOnType(self, city.LISTEN_TYPE.CREATE_DECORATOR)
    city:AddListenOnType(self, city.LISTEN_TYPE.DESTROY_DECORATOR)
    city:GetSoldierManager():AddListenOnType(self, SoldierManager.LISTEN_TYPE.SOLDIER_CHANGED)

    local city_node = self:GetCityNode()
    -- 加废墟
    for k, ruin in pairs(city.ruins) do
        local building = self:CreateRuin(ruin):addTo(city_node)
        local tile = city:GetTileWhichBuildingBelongs(ruin)
        if tile.locked or city:GetDecoratorByPosition(ruin.x, ruin.y) then
            building:setVisible(false)
        else
            building:setVisible(true)
        end
        table.insert(self.ruins, building)
    end

    -- 加功能建筑
    for _, building in pairs(city:GetAllBuildings()) do
        local building_sprite
        if building:GetType() == "dragonEyrie" then
            building_sprite = self:CreateDragonEyrie(building, city):addTo(city_node)
        else
            building_sprite = self:CreateBuilding(building, city):addTo(city_node)
        end
        city:AddListenOnType(building_sprite, city.LISTEN_TYPE.LOCK_TILE)
        city:AddListenOnType(building_sprite, city.LISTEN_TYPE.UNLOCK_TILE)
        city:AddListenOnType(building_sprite, city.LISTEN_TYPE.UPGRADE_BUILDING)
        table.insert(self.buildings, building_sprite)
    end

    -- 加小屋
    for _, house in pairs(city:GetAllDecorators()) do
        local house = self:CreateDecorator(house):addTo(city_node)
        table.insert(self.houses, house)
    end

    -- 加树
    randomseed(DataManager:getUserData().countInfo.registerTime)
    local single_tree = {}
    city:IteratorTilesByFunc(function(x, y, tile)
        if (x == 1 and y == 1)
            or (x == 2 and y == 1)
            or (x == 1 and y == 2)
            or x == 5
            or y == 5 then
            return
        end
        local grounds = tile:RandomGrounds(floor(random() * 1000))
        for _, v in pairs(grounds) do
            local tree = self:CreateSingleTree(v.x, v.y):addTo(city_node)
            table.insert(single_tree, tree)
            tree:setVisible(tile:IsUnlocked())
        end
    end)
    self.single_tree = single_tree

    -- 兵种
    local soldiers = {}
    for i, v in ipairs({
        {x = 1, y = 11, soldier_type = "swordsman"},
        {x = 3, y = 11, soldier_type = "archer"},
        {x = 6, y = 12, soldier_type = "lancer"},
        {x = 9, y = 12, soldier_type = "catapult"},

        {x = 1, y = 13, soldier_type = "sentinel"},
        {x = 3, y = 13, soldier_type = "crossbowman"},
        {x = 6, y = 15, soldier_type = "horseArcher"},
        {x = 9, y = 15, soldier_type = "ballista"},

    -- {x = 1, y = 15, soldier_type = "sentinel"},
    -- {x = 3, y = 15, soldier_type = "crossbowman"},
    -- {x = 6, y = 18, soldier_type = "horseArcher"},
    -- {x = 9, y = 18, soldier_type = "ballista"},
    }) do
        table.insert(soldiers, self:CreateSoldier(v.soldier_type, v.x, v.y):addTo(city_node))
    end
    self.soldiers = soldiers

    -- 更新其他需要动态生成的建筑
    self:UpdateAllDynamicWithCity(city)
    ---
    -- local cc = cc
    -- local function wrap_point_in_table(...)
    --     local arg = {...}
    --     return {x = arg[1], y = arg[2]}
    -- end
    -- local function return_dir_and_velocity(start_point, end_point)
    --     local speed = 50
    --     local spt = wrap_point_in_table(self.iso_map:ConvertToMapPosition(start_point.x, start_point.y))
    --     local ept = wrap_point_in_table(self.iso_map:ConvertToMapPosition(end_point.x, end_point.y))
    --     local dir = cc.pSub(ept, spt)
    --     local distance = cc.pGetLength(dir)
    --     local vdir = {x = speed * dir.x / distance, y = speed * dir.y / distance}
    --     return dir, vdir
    -- end
    -- local _, vdir = return_dir_and_velocity({x = 10, y = 13}, {x = 19, y = 13})
    -- local citizen = self:CreateCitizen(10, 13):addTo(city_node)
    -- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    --     local x, y = citizen:getPosition()
    --     local tx, ty = self.iso_map:ConvertToMapPosition(19, 13)
    --     local disSQ = cc.pDistanceSQ({x = x, y = y}, {x = tx, y = ty})
    --     if disSQ < 10 * 10 then
    --         citizen:TurnLeft()
    --         _, vdir = return_dir_and_velocity({x = 19, y = 13}, {x = 19, y = 19})
    --     end
    --     local tx, ty = self.iso_map:ConvertToMapPosition(19, 29)
    --     local disSQ = cc.pDistanceSQ({x = x, y = y}, {x = tx, y = ty})
    --     if disSQ < 10 * 10 then
    --         self:unscheduleUpdate()
    --     end
    --     citizen:SetPositionWithZOrder(x + vdir.x * dt, y + vdir.y * dt)
    -- end)
    -- self:scheduleUpdate()
end
---
function CityLayer:UpdateAllDynamicWithCity(city)
    self:UpdateTreesWithCity(city)
    self:UpdateTilesWithCity(city)
    self:UpdateRoadsWithCity(city)
    self:UpdateWallsWithCity(city)
    self:UpdateTowersWithCity(city)
    self:UpdateSoldiersVisibleWithSoldierManager(city:GetSoldierManager())
end
function CityLayer:UpdateRuinsVisibleWithCity(city)
    table.foreach(self.ruins, function(_, ruin)
        local building_entity = ruin:GetEntity()
        local tile = city:GetTileWhichBuildingBelongs(building_entity)
        if tile.locked or city:GetDecoratorByPosition(building_entity:GetLogicPosition()) then
            ruin:setVisible(false)
        else
            ruin:setVisible(true)
        end
    end)
end
function CityLayer:UpdateSingleTreeVisibleWithCity(city)
    table.foreach(self.single_tree, function(_, tree)
        tree:setVisible(city:GetTileByBuildingPosition(tree.x, tree.y):IsUnlocked())
    end)
end
function CityLayer:UpdateTilesWithCity(city)
    local map = self:GetCityBackgroundsMap()
    city:IteratorTilesByFunc(function(x, y, tile)
        map[y][x].visible = tile:IsUnlocked()
    end)
    self:UpdateCityBackgroundsByMap(map)
end
function CityLayer:UpdateRoadsWithCity(city)
    local map = self:GetRoadsmap()
    city:IteratorTilesByFunc(function(x, y, tile)
        if
            x == 1 and y == 1
            or  x == 2 and y == 1
            or  x == 1 and y == 2
        then
            map[y][x].visible = false
        else
            map[y][x].visible = tile:IsUnlocked()
        end
    end)
    self:UpdateRoadsByMap(map)
end
function CityLayer:UpdateTreesWithCity(city)
    local city_node = self:GetCityNode()

    if self.road then
        city_node:removeChild(self.road, true)
    end
    if self.trees then
        for k, v in pairs(self.trees) do
            city_node:removeChild(v, true)
        end
    end

    self.trees = {}
    self.road = nil

    local face_tile = city:GetTileFaceToGate()
    self.road = self:CreateRoadWithTile(face_tile)
    city_node:addChild(self.road)

    city:IteratorTilesByFunc(function(x, y, tile)
        if face_tile ~= tile and tile.locked then
            local tree = self:CreateTreeWithTile(tile)
            city_node:addChild(tree)
            table.insert(self.trees, tree)
        end
    end)

    self:NotifyObservers(function(listener)
        local road = city:GetTileByIndex(face_tile.x, face_tile.y) and self.road or nil
        listener:OnTreesChanged(self.trees, road)
    end)
end
function CityLayer:UpdateWallsWithCity(city)
    local city_node = self:GetCityNode()
    local old_walls = self.walls
    local new_walls = {}
    for _, v in pairs(city:GetWalls()) do
        local x, y = v:GetLogicPosition()
        local wall = self:CreateWall(v)
        city_node:addChild(wall)
        table.insert(new_walls, wall)
    end
    self.walls = new_walls

    self:NotifyObservers(function(listener)
        listener:OnGateChanged(old_walls, new_walls)
    end)

    if old_walls then
        for k, v in pairs(old_walls) do
            v:DestorySelf()
        end
    end
end
function CityLayer:UpdateTowersWithCity(city)
    local city_node = self:GetCityNode()
    local old_towers = self.towers
    local new_towers = {}
    for k, v in pairs(city:GetTowers()) do
        local x, y = v:GetLogicPosition()
        local w, h = v:GetSize()
        local tower = self:CreateTower(v)
        city_node:addChild(tower)
        table.insert(new_towers, tower)
    end
    self.towers = new_towers

    self:NotifyObservers(function(listener)
        listener:OnTowersChanged(old_towers, new_towers)
    end)

    if old_towers then
        for k, v in pairs(old_towers) do
            v:DestorySelf()
        end
    end
end
function CityLayer:UpdateSoldiersVisibleWithSoldierManager(soldier_manager)
    local map = soldier_manager:GetSoldierMap()
    self:IteratorSoldiers(function(_, v)
        local is_visible = map[v:GetSoldierType()] > 0
        v:setVisible(is_visible)
    end)
end
function CityLayer:IteratorFunctionsBuildings(func)
    table.foreach(self.buildings, func)
end
function CityLayer:IteratorDecoratorBuildings(func)
    table.foreach(self.houses, func)
end
function CityLayer:IteratorFunctionsBuildings(func)
    table.foreach(self.buildings, func)
end
function CityLayer:IteratorSoldiers(func)
    table.foreach(self.soldiers, func)
end
function CityLayer:IteratorInnnerBuildings(func)
    local handle = false
    local handle_func = function(k, v)
        if func(k, v) then
            handle = true
            return true
        end
    end
    repeat
        table.foreach(self.buildings, handle_func)
        if handle then break end
        table.foreach(self.houses, handle_func)
    until true
end
function CityLayer:IteratorCanUpgradingBuilding(func)
    local handle = false
    local handle_func = function(k, v)
        if func(k, v) then
            handle = true
            return true
        end
    end
    repeat
        table.foreach(self.buildings, handle_func)
        if handle then break end
        table.foreach(self.houses, handle_func)
        if handle then break end
        table.foreach(self.towers, function(k, tower)
            if tower:GetEntity():IsUnlocked() then
                return handle_func(k, tower)
            end
        end)
        if handle then break end
        table.foreach(self.walls, function(k, wall)
            if wall:GetEntity():IsGate() then
                return handle_func(k, wall)
            end
        end)
    until true
end
function CityLayer:IteratorClickAble(func)
    local handle = false
    local handle_func = function(k, v)
        if func(k, v) then
            handle = true
            return true
        end
    end
    repeat
        table.foreach(self.buildings, handle_func)
        if handle then break end
        table.foreach(self.houses, handle_func)
        if handle then break end
        table.foreach(self.towers, handle_func)
        if handle then break end
        table.foreach(self.walls, handle_func)
        if handle then break end
        table.foreach(self.ruins, handle_func)
        if handle then break end
    until true
end
function CityLayer:CreateRoadWithTile(tile)
    local x, y = self.iso_map:ConvertToMapPosition(tile:GetMidLogicPosition())
    return RoadSprite.new(self, tile, x, y)
end
function CityLayer:CreateTreeWithTile(tile)
    local x, y = self.iso_map:ConvertToMapPosition(tile:GetMidLogicPosition())
    return TreeSprite.new(self, tile, x, y)
end
function CityLayer:CreateWall(wall)
    return WallUpgradingSprite.new(self, wall)
end
function CityLayer:CreateTower(tower)
    return TowerUpgradingSprite.new(self, tower)
end
function CityLayer:CreateRuin(ruin)
    return RuinSprite.new(self, ruin)
end
function CityLayer:CreateDecorator(house)
    return UpgradingSprite.new(self, house)
end
function CityLayer:CreateDragonEyrie(building, city)
    return DragonEyrieSprite.new(self, building, city)
end
function CityLayer:CreateBuilding(building, city)
    return FunctionUpgradingSprite.new(self, building, city)
end
function CityLayer:CreateSingleTree(logic_x, logic_y)
    return SingleTreeSprite.new(self, logic_x, logic_y)
end
function CityLayer:CreateCitizen(logic_x, logic_y)
    return CitizenSprite.new(self, logic_x, logic_y)
end
function CityLayer:CreateSoldier(soldier_type, logic_x, logic_y)
    return SoldierSprite.new(self, soldier_type, logic_x, logic_y)
end

--
function CityLayer:GetMapSize()
    if not self.width or not self.height then
        local layer_size = self:GetPositionLayer():getLayerSize()
        self.width, self.height = layer_size.width, layer_size.height
    end
    return self.width, self.height
end
--
function CityLayer:GetPositionIndex(x, y)
    return self:GetPositionLayer():getPositionAt(cc.p(x, y))
end
function CityLayer:GetPositionLayer()
    if not self.position_layer then
        local road_map = self:GetPositionNode()
        self.position_layer = road_map:getLayer("layer1")
    end
    return self.position_layer
end
function CityLayer:GetPositionNode()
    return self.position_node
end
--
function CityLayer:GetTileLayer()
    if not self.tile_layer then
        self.tile_layer = self.city_background:getLayer("layer1")
    end
    return self.tile_layer
end
function CityLayer:GetRoadsmap()
    return self.roads_map
end
function CityLayer:GetCityNode()
    return self.city_node
end
--
function CityLayer:GetBackgroundLayer()
    if not self.background_layer then
        self.background_layer = self.background:getLayer("layer1")
    end
    return self.background_layer
end

----- override
function CityLayer:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
    end
    return self.content_size
end
function CityLayer:OnSceneMove()
    self:IteratorCanUpgradingBuilding(function(_, building)
        building:OnSceneMove()
    end)
    table.foreach(self.trees, function(k, v)
        v:OnSceneMove()
    end)
    if self.road then
        self.road:OnSceneMove()
    end
end

return CityLayer











































