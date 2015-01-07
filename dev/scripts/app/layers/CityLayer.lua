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
local HelpedTroopsSprite = import("..sprites.HelpedTroopsSprite")
local SoldierManager = import("..entity.SoldierManager")
local cocos_promise = import("..utils.cocos_promise")
local promise = import("..utils.promise")
local Observer = import("..entity.Observer")
local MapLayer = import(".MapLayer")
local CityLayer = class("CityLayer", MapLayer)

local math = math
local floor = math.floor
local random = math.random
local randomseed = math.randomseed
function CityLayer:GetClickedObject(world_x, world_y)
    local point = self:GetCityNode():convertToNodeSpace(cc.p(world_x, world_y))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    local clicked_list = {
        logic_clicked = {},
        sprite_clicked = {}
    }
    self:IteratorClickAble(function(_, v)
        if not v:isVisible() then return false end
        if v:GetEntity():GetType() == "wall" and not v:GetEntity():IsGate() then return false end
        if v:GetEntity():GetType() == "tower" and not v:GetEntity():IsUnlocked() then return false end

        local check = v:IsContainPointWithFullCheck(logic_x, logic_y, world_x, world_y)
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
    return clicked_list.logic_clicked[1] or clicked_list.sprite_clicked[1]
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
            house:removeFromParent()
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
function CityLayer:OnHelpedTroopsChanged(city, changed)
    if #changed.add > 0 or #changed.removed > 0 then
        print("协防部队发生变化")
        self:UpdateHelpedByTroopsVisible(city:GetHelpedByTroops())
    end
end
-----
local SCENE_BACKGROUND = 1
local BACK_NODE = 2
local CITY_LAYER = 3
local CITY_BACKGROUND = 1
local ROAD_NODE = 2
local BUILDING_NODE = 3
local WEATHER_NODE = 4
function CityLayer:ctor(city_scene)
    Observer.extend(self)
    CityLayer.super.ctor(self, 0.7, 1.5)
    self.city_scene = city_scene
    self.terrain_type = "grass"
    self.buildings = {}
    self.houses = {}
    self.towers = {}
    self.ruins = {}
    self.trees = {}
    self.walls = {}
    self.helpedByTroops = {}
    self.road = nil
    self:InitBackground()
    self:InitCity()
    self:InitWeather()
end
function CityLayer:GetLogicMap()
    return self.iso_map
end
function CityLayer:GetZOrderBy(sprite, x, y)
    local width, _ = self:GetLogicMap():GetSize()
    return x + y * width + 100
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
function CityLayer:InitCity()
    self.city_layer = display.newLayer():addTo(self, CITY_LAYER):align(display.BOTTOM_LEFT, 47, 158)
    self.position_node = cc.TMXTiledMap:create("tmxmaps/city_road2.tmx"):addTo(self.city_layer):hide()
    self.city_node = display.newLayer():addTo(self.city_layer, BUILDING_NODE):align(display.BOTTOM_LEFT)
    local origin_point = self:GetPositionIndex(0, 0)
    self.iso_map = IsoMapAnchorBottomLeft.new({
        tile_w = 51,
        tile_h = 31,
        map_width = 50,
        map_height = 50,
        base_x = origin_point.x,
        base_y = origin_point.y
    })
end
function CityLayer:GetPositionIndex(x, y)
    return self:GetPositionLayer():getPositionAt(cc.p(x, y))
end
function CityLayer:GetPositionLayer()
    if not self.position_layer then
        self.position_layer = self.position_node:getLayer("layer1")
    end
    return self.position_layer
end
function CityLayer:GetCityNode()
    return self.city_node
end
--
function CityLayer:InitWeather()
    -- local sprite = display.newSprite("logos/batcat.png", 0, 0, {class=cc.FilteredSpriteWithOne})
    --     :addTo(self, WEATHER_NODE):align(display.LEFT_BOTTOM, 0, 0)
    -- local size1 = self:getContentSize()
    -- local size2 = sprite:getContentSize()
    -- sprite:setScale(size1.width / size2.width, size1.height / size2.height)
    -- sprite:setFilter(filter.newFilter("CUSTOM",
    --     json.encode({
    --         frag = "shaders/snow.fs",
    --         u_resolution = {size1.width, size1.height},
    --         u_position = {0.5, 0.5},
    --     })
    -- ))
    -- self.weather = sprite
    -- self.weather_glstate = self.weather:getFilter(0):getGLProgramState()
    -- self:UpdateWeather()
end
function CityLayer:ChangeTerrain(terrain_type)
    if self.terrain_type ~= terrain_type then
        self.terrain_type = terrain_type
        self:ReloadSceneBackground()
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
    self.background = display.newNode():addTo(self, SCENE_BACKGROUND)
    local left = display.newSprite("left_background.jpg"):addTo(self.background):align(display.LEFT_BOTTOM)
    local right = display.newSprite("right_background.jpg"):addTo(self.background):align(display.LEFT_BOTTOM, left:getContentSize().width, 0)
end
function CityLayer:InitWithCity(city)
    city:AddListenOnType(self, city.LISTEN_TYPE.UNLOCK_TILE)
    city:AddListenOnType(self, city.LISTEN_TYPE.LOCK_TILE)
    city:AddListenOnType(self, city.LISTEN_TYPE.UNLOCK_ROUND)
    city:AddListenOnType(self, city.LISTEN_TYPE.OCCUPY_RUINS)
    city:AddListenOnType(self, city.LISTEN_TYPE.CREATE_DECORATOR)
    city:AddListenOnType(self, city.LISTEN_TYPE.DESTROY_DECORATOR)
    city:AddListenOnType(self, city.LISTEN_TYPE.HELPED_BY_TROOPS)
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
        local grounds = tile:RandomGrounds(random(123456789))
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
        {x = 2, y = 11, soldier_type = "swordsman"},
        {x = 4, y = 11, soldier_type = "ranger"},
        {x = 6, y = 12, soldier_type = "lancer"},
        {x = 9, y = 12, soldier_type = "catapult"},

        {x = 2, y = 13, soldier_type = "sentinel"},
        {x = 4, y = 13, soldier_type = "crossbowman"},
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


    -- 协防的部队
    local helpedByTroops = {}
    for i, v in ipairs({
        {x = 15, y = 55},
        {x = 35, y = 55},
    }) do
        table.insert(helpedByTroops, HelpedTroopsSprite.new(self, v.x, v.y):addTo(city_node))
    end
    self.helpedByTroops = helpedByTroops

    -- 更新其他需要动态生成的建筑
    self:UpdateAllDynamicWithCity(city)
    --
    -- --
    -- local function find_unlock_tiles()
    --     local r = {}
    --     city:IteratorTilesByFunc(function(x, y, tile)
    --         if (x == 1 and y == 1) or (x == 1 and y == 2) or (x == 2 and y == 1) then
    --             return
    --         end
    --         if tile:IsUnlocked() then
    --             table.insert(r, tile)
    --         end
    --     end)
    --     return r
    -- end
    -- local function find_nearby(t, tiles)
    --     local connectedness = {t}
    --     local index = 1
    --     while true do
    --         local cur = connectedness[index]
    --         if not cur then
    --             break
    --         end
    --         for i, v in ipairs(tiles) do
    --             if cur:IsNearBy(v) then
    --                 table.insert(connectedness, table.remove(tiles, i))
    --             end
    --         end
    --         index = index + 1
    --     end
    --     return connectedness
    -- end

    -- local connects = {}
    -- local r = find_unlock_tiles()
    -- while #r > 0 do
    --     table.insert(connects, find_nearby(table.remove(r, 1), r))
    -- end
    -- local function alignmeng_path(path)
    --     if #path <= 3 then
    --         return path
    --     end
    --     local index = 1
    --     while index <= #path - 2 do
    --         local start = path[index]
    --         local middle = path[index + 1]
    --         local ending = path[index + 2]
    --         if (start.x == middle.x and middle.x == ending.x)
    --             or (start.y == middle.y and middle.y == ending.y) then
    --             table.remove(path, index + 1)
    --         else
    --             index = index + 1
    --         end
    --     end
    --     return path
    -- end
    -- local function find_path_tile(connectedness, start_tile)
    --     if #connectedness == 0 then
    --         return {start_tile}
    --     end
    --     local r = {start_tile or table.remove(connectedness, math.random(#connectedness))}
    --     local index = 1
    --     local changed = true
    --     while changed do
    --         local cur_nearbys = {}
    --         for i, v in ipairs(connectedness) do
    --             local cur = r[index]
    --             if cur:IsNearBy(v) then
    --                 -- 进一步确定是y方向上面的邻居，就要继续检出双方下面是否还有解锁的块
    --                 --
    --                 if cur.y ~= v.y then
    --                     local cur_next = city:GetTileByIndex(cur.x + 1, cur.y)
    --                     local v_next = city:GetTileByIndex(v.x + 1, v.y)
    --                     if cur_next and v_next and cur_next:IsUnlocked() and v_next:IsUnlocked() then
    --                         table.insert(cur_nearbys, i)
    --                     end
    --                 end
    --             end
    --         end
    --         if #cur_nearbys > 0 then
    --             table.insert(r, table.remove(connectedness, cur_nearbys[math.random(#cur_nearbys)]))
    --             index = index + 1
    --             changed = true
    --         else
    --             changed = false
    --         end
    --     end
    --     return r
    -- end

    -- local cc = cc
    -- local function wrap_point_in_table(...)
    --     local arg = {...}
    --     return {x = arg[1], y = arg[2]}
    -- end
    -- local function return_dir_and_velocity(start_point, end_point)
    --     local speed = 200
    --     local spt = wrap_point_in_table(self.iso_map:ConvertToMapPosition(start_point.x, start_point.y))
    --     local ept = wrap_point_in_table(self.iso_map:ConvertToMapPosition(end_point.x, end_point.y))
    --     local dir = cc.pSub(ept, spt)
    --     local distance = cc.pGetLength(dir)
    --     local vdir = {x = speed * dir.x / distance, y = speed * dir.y / distance}
    --     return vdir
    -- end
    -- local path_tiles = find_path_tile(connects[1])
    -- local path_point = LuaUtils:table_map(
    --     path_tiles,
    --     function(k, v)
    --         return k, v:GetCrossPoint()
    --     end)
    -- table.insert(path_point, 1, path_tiles[1]:RandomPoint())
    -- table.insert(path_point, #path_point + 1, path_tiles[#path_tiles]:RandomPoint())
    -- local path = alignmeng_path(path_point)
    -- -- dump(path)

    -- local start = false
    -- local citizen = self:CreateCitizen(0, 0):addTo(city_node)
    -- self.vdir = {}
    -- self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
    --     dt = math.min(dt, 0.05)
    --     if start then
    --         local cx, cy = citizen:getPosition()
    --         local point = path[1]
    --         local ex, ey = self.iso_map:ConvertToMapPosition(point.x, point.y)
    --         local disSQ = cc.pDistanceSQ({x = cx, y = cy}, {x = ex, y = ey})
    --         if disSQ < 10 * 10 then
    --             if #path <= 1 then

    --                 local tile = city:GetTileByBuildingPosition(point.x, point.y)
    --                 local connects = {}
    --                 local r = find_unlock_tiles()
    --                 while #r > 0 do
    --                     table.insert(connects, find_nearby(table.remove(r, 1), r))
    --                 end
    --                 for i, v in ipairs(connects[1]) do
    --                     if v.x == tile.x and v.y == tile.y then
    --                         table.remove(connects[1], i)
    --                     end
    --                 end
    --                 local path_tiles = find_path_tile(connects[1], tile)
    --                 local path_point = LuaUtils:table_map(
    --                     path_tiles,
    --                     function(k, v)
    --                         return k, v:GetCrossPoint()
    --                     end)
    --                 table.insert(path_point, 1, point)
    --                 table.insert(path_point, #path_point + 1, path_tiles[#path_tiles]:RandomPoint())
    --                 path = alignmeng_path(path_point)

    --                 -- dump(path)
    --                 -- self:unscheduleUpdate()
    --                 -- return
    --             end
    --             self.vdir = return_dir_and_velocity(path[1], path[2])
    --             table.remove(path, 1)
    --         end
    --         citizen:SetPositionWithZOrder(cx + self.vdir.x * dt, cy + self.vdir.y * dt)
    --     else
    --         if #path < 1 then
    --             self:unscheduleUpdate()
    --             return
    --         end
    --         start = true
    --         local start_point = table.remove(path, 1)
    --         local ex, ey = self.iso_map:ConvertToMapPosition(start_point.x, start_point.y)
    --         citizen:SetPositionWithZOrder(ex, ey)
    --         if #path < 1 then
    --             self:unscheduleUpdate()
    --             return
    --         end
    --         self.vdir = return_dir_and_velocity(start_point, path[1])
    --     end
    -- end)
    -- self:scheduleUpdate()
end
---
function CityLayer:UpdateAllDynamicWithCity(city)
    self:UpdateTreesWithCity(city)
    self:UpdateWallsWithCity(city)
    self:UpdateTowersWithCity(city)
    self:UpdateSoldiersVisibleWithSoldierManager(city:GetSoldierManager())
    self:UpdateHelpedByTroopsVisible(city:GetHelpedByTroops())
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
function CityLayer:UpdateHelpedByTroopsVisible(helped_by_troops)
    for i, v in ipairs(self.helpedByTroops) do
        v:setVisible(helped_by_troops[i] ~= nil)
    end
end
-- promise
function CityLayer:FindBuildingBy(x, y)
    local building
    self:IteratorClickAble(function(_, v)
        local x_, y_ = v:GetLogicPosition()
        if x_ == x and y_ == y then
            building = v
            return true
        end
    end)
    return cocos_promise.deffer(function()
        if not building then
            promise.reject({x = x, y = y}, "没有找到对应坐标的建筑")
        end
        return building
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
function CityLayer:IteratorRuins(func)
    table.foreach(self.ruins, func)
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

----- override
function CityLayer:getContentSize()
    if not self.content_size then
        self.content_size = self.background:getCascadeBoundingBox()
    end
    return self.content_size
end
local function on_move(_, sprite)
    sprite:OnSceneMove()
end
function CityLayer:OnSceneMove()
    self:IteratorCanUpgradingBuilding(on_move)
    table.foreach(self.trees, on_move)
    table.foreach(self.ruins, on_move)
    if self.road then
        on_move(nil, self.road)
    end
    -- self:UpdateWeather()
end
function CityLayer:UpdateWeather()
    local size = self:getContentSize()
    local pos = self:convertToNodeSpace(cc.p(display.cx, display.cy))
    self.weather_glstate:setUniformVec2("u_position", {x = pos.x / size.width, y = pos.y / size.height})
end
function CityLayer:OnSceneScale()
    self.city_scene:OnSceneScale(self)
end

return CityLayer















