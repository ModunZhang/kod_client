local IsoMapAnchorBottomLeft = import("..map.IsoMapAnchorBottomLeft")
local FunctionUpgradingSprite = import("..sprites.FunctionUpgradingSprite")
local UpgradingSprite = import("..sprites.UpgradingSprite")
local RuinSprite = import("..sprites.RuinSprite")
local TowerUpgradingSprite = import("..sprites.TowerUpgradingSprite")
local WallUpgradingSprite = import("..sprites.WallUpgradingSprite")
local RoadSprite = import("..sprites.RoadSprite")
local TreeSprite = import("..sprites.TreeSprite")
local BuildingSprite = import("..sprites.BuildingSprite")
local Observer = import("..entity.Observer")
local CityLayer = class("CityLayer", function(...)
    local layer = display.newLayer()
    layer:setAnchorPoint(0, 0)
    Observer.extend(layer, ...)
    return layer
end)


function CityLayer:GetClickedObject(x, y, world_x, world_y)
    local clicked_list = {}
    self:IteratorClickAble(function(k, v)
        if v:isVisible() and v:IsContainPoint(x, y, world_x, world_y) then
            table.insert(clicked_list, v)
        end
    end)
    table.sort(clicked_list, function(a, b)
        return a:getZOrder() > b:getZOrder()
    end)
    return clicked_list[1]
end
function CityLayer:OnTileLocked(city)
    self:OnTileChanged(city)
end
function CityLayer:OnTileUnlocked(city)
    self:OnTileChanged(city)
end
function CityLayer:OnTileChanged(city)
    table.foreach(self.ruins, function(_, ruin)
        local building_entity = ruin:GetEntity()
        local tile = city:GetTileWhichBuildingBelongs(building_entity)
        if tile.locked or city:GetDecoratorByPosition(building_entity:GetLogicPosition()) then
            ruin:setVisible(false)
        else
            ruin:setVisible(true)
            -- ruin:Normal()
        end
    end)

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
    -- self:UpdateCornsAndRocksWithCity(city)
end
function CityLayer:UpdateTilesWithCity(city)
    city:IteratorTilesByFunc(function(x, y, tile)
        self:EableTileBackground(x - 1, y - 1, tile:IsUnlocked())
    end)
end
function CityLayer:UpdateRoadsWithCity(city)
    city:IteratorTilesByFunc(function(x, y, tile)
        local tmx_x = x - 1
        local tmx_y = y - 1
        if
            tmx_x == 0 and tmx_y == 0
            or  tmx_x == 1 and tmx_y == 0
            or  tmx_x == 0 and tmx_y == 1
        then
            enable = false
            self:EableTileRoad(tmx_x, tmx_y, false)
        else
            self:EableTileRoad(tmx_x, tmx_y, tile:IsUnlocked())
        end
    end)
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
            city_node:removeChild(v, true)
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
            city_node:removeChild(v, true)
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
function CityLayer:IteratorFunctionsBuildings(func)
    table.foreach(self.buildings, func)
end
function CityLayer:IteratorDecoratorBuildings(func)
    table.foreach(self.houses, func)
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
        table.foreach(self.buildings == nil and {} or self.buildings, handle_func)
        if handle then break end
        table.foreach(self.houses == nil and {} or self.houses, handle_func)
        if handle then break end
        table.foreach(self.towers == nil and {} or self.towers, function(k, tower)
            if tower:GetEntity():IsUnlocked() then
                return handle_func(k, tower)
            end
        end)
        if handle then break end
        table.foreach(self.walls == nil and {} or self.walls, function(k, wall)
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
----
function CityLayer:ctor(city)
    self.trees = {}
    self:InitBackground()
    self:InitCityBackGround()
    self:InitPositionNodeWithCityNode()
    self:InitRoadNodeWithCityNode()

    self.city_node = display.newLayer()
    self.city_node:setAnchorPoint(0, 0)
    self:GetCityLayer():addChild(self.city_node)

    self:GetCityLayer():setPosition(cc.p(1000, 1000))

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
function CityLayer:GetCityLayer()
    return self.city_layer
end
function CityLayer:GetCityNode()
    return self.city_node
end
function CityLayer:InitSceneWithFile(file)
    -- ccs.SceneReader:getInstance():createNodeWithSceneFile("scenetest/AttributeComponentTest/AttributeComponentTest.json")
    -- local scene = SceneReader:sharedSceneReader():createNodeWithSceneFile(file)
    self.background = cc.TMXTiledMap:create("city_background1.tmx")
    self:addChild(self.background)
end
function CityLayer:GetSceneFile()
    return 'kod/publish/KODCityScene.json'
end
function CityLayer:InitBackground()
    self.background = cc.TMXTiledMap:create("city_background1.tmx")
    self:addChild(self.background)
end
function CityLayer:InitCityBackGround()
    self.city_layer = display.newLayer()
    self.city_layer:setAnchorPoint(0, 0)
    self:addChild(self.city_layer)

    self.city_background = cc.TMXTiledMap:create("city_background2.tmx")
    self.city_layer:addChild(self.city_background)
end
function CityLayer:InitPositionNodeWithCityNode()
    self.position_node = cc.TMXTiledMap:create("city_road.tmx")
    self.city_background:addChild(self.position_node)
end
function CityLayer:InitRoadNodeWithCityNode()
    self.road_node = cc.TMXTiledMap:create("city_road_2.tmx")
    self.city_background:addChild(self.road_node)
end
function CityLayer:InitWithCity(city)
    city:AddListenOnType(self, city.LISTEN_TYPE.UNLOCK_TILE)
    city:AddListenOnType(self, city.LISTEN_TYPE.LOCK_TILE)
    city:AddListenOnType(self, city.LISTEN_TYPE.UNLOCK_ROUND)
    city:AddListenOnType(self, city.LISTEN_TYPE.OCCUPY_RUINS)
    city:AddListenOnType(self, city.LISTEN_TYPE.CREATE_DECORATOR)
    city:AddListenOnType(self, city.LISTEN_TYPE.DESTROY_DECORATOR)

    self.buildings = {}
    self.houses = {}
    self.towers = {}
    self.ruins = {}
    self.trees = {}
    self.walls = {}
    self.road = nil


    self:UpdateAllWithCity(city)

    local city_node = self:GetCityNode()
    for k, ruin in pairs(city.ruins) do
        local x, y = ruin:GetLogicPosition()
        local building = self:CreateRuin(ruin)
        city_node:addChild(building)

        local tile = city:GetTileWhichBuildingBelongs(ruin)
        if tile.locked or city:GetDecoratorByPosition(ruin.x, ruin.y) then
            building:setVisible(false)
        else
            building:setVisible(true)
        end
        table.insert(self.ruins, building)
    end

    for _, building in pairs(city:GetAllBuildings()) do
        local building = self:CreateBuilding(building, city)
        city:AddListenOnType(building, city.LISTEN_TYPE.LOCK_TILE)
        city:AddListenOnType(building, city.LISTEN_TYPE.UNLOCK_TILE)
        city:AddListenOnType(building, city.LISTEN_TYPE.UPGRADE_BUILDING)
        city_node:addChild(building)
        table.insert(self.buildings, building)
    end

    for _, house in pairs(city:GetAllDecorators()) do
        local house = self:CreateDecorator(house)
        city_node:addChild(house)
        table.insert(self.houses, house)
    end
end

function CityLayer:GetMapSize()
    if not self.width or not self.height then
        local layer_size = self:GetPositionLayer():getLayerSize()
        self.width, self.height = layer_size.width, layer_size.height
    end
    return self.width, self.height
end
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




function CityLayer:EableTileRoad(x, y, enable)
    local tile = self:GetTileAtIndexInRoad(x, y)
    if tile then
        tile:setVisible(enable)
    end
end
function CityLayer:GetTileAtIndexInRoad(x, y)
    return self:GetRoadLayer():getTileAt(cc.p(x, y))
end
function CityLayer:GetRoadLayer()
    if not self.road_layer then
        self.road_layer = self:GetRoadNode():getLayer("layer1")
    end
    return self.road_layer
end
function CityLayer:GetRoadNode()
    return self.road_node
end


------zoom
function CityLayer:ZoomBegin()
    self.scale_point = self:convertToNodeSpace(cc.p(display.cx, display.cy))
    self.scale_current = self:getScale()
end
function CityLayer:ZoomTo(scale)
    self:ZoomBegin()
    self:ZoomBy(scale / self:getScale())
    self:ZoomEnd()
end
function CityLayer:ZoomBy(scale)
    self:setScale(math.min(math.max(self.scale_current * scale, 0.3), 0.8))
    local scene_point = self:getParent():convertToWorldSpace(cc.p(display.cx, display.cy))
    local world_point = self:convertToWorldSpace(cc.p(self.scale_point.x, self.scale_point.y))
    local new_scene_point = self:getParent():convertToNodeSpace(world_point)
    local cur_x, cur_y = self:getPosition()
    local new_position = cc.p(cur_x + scene_point.x - new_scene_point.x, cur_y + scene_point.y - new_scene_point.y)
    self:setPosition(new_position)
end
function CityLayer:ZoomEnd()
    self.scale_point = nil
    self.scale_current = self:getScale()
end

-------
function CityLayer:setPosition(position)
    local x, y = position.x, position.y
    local parent_node = self:getParent()
    local super = getmetatable(self)
    super.setPosition(self, position)
    local left_bottom_pos = self:GetLeftBottomPositionWithConstrain(x, y)
    local right_top_pos = self:GetRightTopPositionWithConstrain(x, y)
    local rx = x >= 0 and math.min(left_bottom_pos.x, right_top_pos.x) or math.max(left_bottom_pos.x, right_top_pos.x)
    local ry = y >= 0 and math.min(left_bottom_pos.y, right_top_pos.y) or math.max(left_bottom_pos.y, right_top_pos.y)
    super.setPosition(self, cc.p(rx, ry))
    self:OnSceneMove()
end
function CityLayer:GetLeftBottomPositionWithConstrain(x, y)
    -- 左下角是否超出
    local parent_node = self:getParent()
    local world_position = parent_node:convertToWorldSpace(cc.p(x, y))
    world_position.x = world_position.x > display.left and display.left or world_position.x
    world_position.y = world_position.y > display.bottom and display.bottom or world_position.y
    local left_bottom_pos = parent_node:convertToNodeSpace(world_position)
    return left_bottom_pos
end
function CityLayer:GetRightTopPositionWithConstrain(x, y)
    -- 右上角是否超出
    local parent_node = self:getParent()
    local world_top_right_point = self:convertToWorldSpace(cc.p(self:getContentWidthAndHeight()))
    local scene_top_right_position = parent_node:convertToNodeSpace(world_top_right_point)
    local display_top_right_position = parent_node:convertToNodeSpace(cc.p(display.right, display.top))
    local dx = display_top_right_position.x - scene_top_right_position.x
    local dy = display_top_right_position.y - scene_top_right_position.y
    local right_top_pos = {
        x = scene_top_right_position.x < display_top_right_position.x and x + dx or x,
        y = scene_top_right_position.y < display_top_right_position.y and y + dy or y
    }
    return right_top_pos
end
function CityLayer:getContentWidthAndHeight()
    if not self.content_width or not self.content_height then
        local content_size = self:getContentSize()
        self.content_width, self.content_height = content_size.width, content_size.height
    end
    return self.content_width, self.content_height
end
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



