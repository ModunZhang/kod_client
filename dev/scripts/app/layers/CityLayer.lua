local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local FunctionUpgradingSprite = import("..sprites.FunctionUpgradingSprite")
local UpgradingSprite = import("..sprites.UpgradingSprite")
local RuinSprite = import("..sprites.RuinSprite")
local TowerUpgradingSprite = import("..sprites.TowerUpgradingSprite")
local WallUpgradingSprite = import("..sprites.WallUpgradingSprite")
local RoadSprite = import("..sprites.RoadSprite")
local TreeSprite = import("..sprites.TreeSprite")
local SingleTreeSprite = import("..sprites.SingleTreeSprite")
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
    self:UpdateRuinsWithCity(city)
    self:UpdateSingleTreeWithCity(city)
    self:UpdateAllWithCity(city)
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
            house:DestoryShadow()
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
---
function CityLayer:UpdateAllWithCity(city)
    self:UpdateTreesWithCity(city)
    self:UpdateTilesWithCity(city)
    self:UpdateRoadsWithCity(city)
    self:UpdateWallsWithCity(city)
    self:UpdateTowersWithCity(city)
end
function CityLayer:UpdateRuinsWithCity(city)
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
function CityLayer:UpdateSingleTreeWithCity(city)
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
function CityLayer:UpdateCornsAndRocksWithCity(city)
    local corns = self.background:getChildByTag(10032)
    local rocks = self.background:getChildByTag(10033)
    local unlock_round = city:GetUnlockAround()
    for i = 1, unlock_round do
        corns:getChildByTag(i):setVisible(true)
        rocks:getChildByTag(i):setVisible(true)
    end
    for i = unlock_round + 1, 5 do
        corns:getChildByTag(i):setVisible(false)
        rocks:getChildByTag(i):setVisible(false)
    end
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
function CityLayer:CreateBuilding(building, city)
    return FunctionUpgradingSprite.new(self, building, city)
end
function CityLayer:CreateSingleTree(logic_x, logic_y)
    return SingleTreeSprite.new(self, logic_x, logic_y)
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

local SCENE_BACKGROUND = 1
local CITY_LAYER = 2
local CITY_BACKGROUND = 1
local ROAD_NODE = 2
local BUILDING_NODE = 3
----
local TERRAIN_MAP = {
    ["grass"] = {background = "grass_background1.tmx"},
    ["desert"] = {background = "desert_background1.tmx"},
    ["icefield"] = {background = "icefield_background1.tmx"},
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
    self.city_layer = display.newLayer():addTo(self, CITY_LAYER):align(display.BOTTOM_LEFT, 1000, 1000)
    self.city_background = cc.TMXTiledMap:create("background2.tmx"):addTo(self.city_layer):hide()
    self.position_node = cc.TMXTiledMap:create("city_road.tmx"):addTo(self.city_layer):hide()
    self.background2 = display.newNode():addTo(self.city_layer, CITY_BACKGROUND)
    self.road_node = display.newNode():addTo(self.city_layer, ROAD_NODE)
    self.city_node = display.newLayer():addTo(self.city_layer, BUILDING_NODE):align(display.BOTTOM_LEFT)

    randomseed(DataManager:getUserData().countInfo.registerTime)
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
function CityLayer:CurrentTerrain()
    return self.terrain_type
end
--
function CityLayer:InitBackground()
    self:ReloadSceneBackground()
end
---
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
    assert(self.background2, "场景背景必须被生成!")
    self.background2:removeAllChildren()
    local city_backgrounds = {{}, {}, {}, {}, {}}
    for row_index, row in ipairs(map) do
        for col_index, v in ipairs(row) do
            local point = self:GetBackgroundLayer():getPositionAt(cc.p(col_index - 1, row_index - 1))
            local ground = display.newSprite(GROUNDS_MAP[self.terrain_type][v.png_index])
                :addTo(self.background2)
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
            local point = self:GetBackgroundLayer():getPositionAt(cc.p(col_index - 1, row_index - 1))
            local road = display.newSprite(ROADS_MAP[self.terrain_type][v.png_index])
                :addTo(self.road_node)
                :align(display.BOTTOM_LEFT, point.x, point.y)
            road:setVisible(v.visible)
            roads[row_index][col_index] = road
        end
    end
    local point = self:GetBackgroundLayer():getPositionAt(cc.p(0, 1))
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
function CityLayer:GetRoadsmap()
    return self.roads_map
end
function CityLayer:GetCityLayer()
    return self.city_layer
end
function CityLayer:GetCityNode()
    return self.city_node
end
function CityLayer:ChangeTerrain(terrain_type)
    if self.terrain_type ~= terrain_type then
        self.terrain_type = terrain_type
        self:ReloadSceneBackground()
        self:RefreshCityBackgroundsByMap(self.city_backgrounds_map)
        self:RefreshRoadsByMap(self.roads_map)
        table.foreach(self.trees, function(_, v)
            v:ReloadSprite()
        end)
        table.foreach(self.single_tree, function(_, tree)
            tree:ReloadSprite()
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

    self:UpdateAllWithCity(city)


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
        local building_sprite = self:CreateBuilding(building, city):addTo(city_node)
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
end
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

---
function CityLayer:EableTileBackground(x, y, enable)
    local tile = self:GetTileAtIndexInBackground(x, y)
    if tile then
        tile:setVisible(enable)
    end
end
function CityLayer:GetTileAtIndexInBackground(x, y)
    return self:GetBackgroundLayer():getTileAt(cc.p(x, y))
end
function CityLayer:GetBackgroundLayer()
    if not self.tile_layer then
        self.tile_layer = self.city_background:getLayer("layer1")
    end
    return self.tile_layer
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




































