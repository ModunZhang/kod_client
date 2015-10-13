local Enum = import("..utils.Enum")
local UILib = import("..ui.UILib")
local Alliance = import("..entity.Alliance")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "OBJECT", "LINE")
local AllianceMap = GameDatas.AllianceMap
local buildingName = AllianceMap.buildingName
local ui_helper = WidgetAllianceHelper.new()
local intInit = GameDatas.AllianceInitData.intInit
local decorator_image = UILib.decorator_image
local alliance_building = UILib.alliance_building
local MAP_LEGNTH_WIDTH = 41
local MAP_LEGNTH_HEIGHT = 41
local TILE_WIDTH = 160
local ALLIANCE_WIDTH, ALLIANCE_HEIGHT = intInit.allianceRegionMapWidth.value, intInit.allianceRegionMapHeight.value
local worldsize = {width = ALLIANCE_WIDTH * 160 * MAP_LEGNTH_WIDTH, height = ALLIANCE_HEIGHT * 160 * MAP_LEGNTH_HEIGHT}
local timer = app.timer
local MINE,FRIEND,ENEMY = 1,2,3
local function getZorderByXY(x, y)
    return x + ALLIANCE_WIDTH * y
end
function AllianceLayer:ctor(scene)
    AllianceLayer.super.ctor(self, scene, 0.4, 1.2)
end
function AllianceLayer:onEnter()
    self:InitAllianceMap()
    self.map = self:CreateMap()
    self.background_node = display.newNode():addTo(self.map, ZORDER.BACKGROUND)
    self.objects_node = display.newNode():addTo(self.map, ZORDER.OBJECT)
    self.lines_node = display.newNode():addTo(self.map, ZORDER.LINE)
    self.map_lines = {}
    self.corps_node = display.newNode():addTo(self, ZORDER.CORPS)
    self.map_corps = {}

    self:StartCorpsTimer()




    -- local x,y = 15, 15
    -- local len = 0
    -- local count = 1
    -- for i = x - len, x + len do
    --     self:CreateOrUpdateCorps(
    --         count,
    --         {x = x, y = y, index = 0},
    --         {x = i, y = y + 10, index = 0},
    --         timer:GetServerTime(),
    --         timer:GetServerTime() + 100,
    --         "redDragon",
    --         {{name = "swordsman", star = 1}},
    --         FRIEND,
    --         "hello"
    --     )
    --     count = count + 1
    -- end
end
function AllianceLayer:InitAllianceMap()
    self.alliance_objects = {}
    self.alliance_objects_free = {
        {},
        {},
        {},
        {},
        {},
        {},
    }

    self.alliance_bg = {}
    self.alliance_bg_free = {
        desert = {},
        grassLand = {},
        iceField = {},
    }
    -- display.newNode():addTo(self):schedule(function()
    --     local count = 0
    --     for k,v in pairs(self.alliance_bg) do
    --         count = count + 1
    --     end

    --     print("alliance_objects:", count)
    --     print("alliance_objects_free.1:", #self.alliance_objects_free[1])
    --     print("alliance_objects_free.2:", #self.alliance_objects_free[2])
    --     print("alliance_objects_free.3:", #self.alliance_objects_free[3])
    --     print("alliance_objects_free.4:", #self.alliance_objects_free[4])
    --     print("alliance_objects_free.5:", #self.alliance_objects_free[5])
    --     print("alliance_objects_free.6:", #self.alliance_objects_free[6])
    --     print("alliance_bg:", count)
    --     print("alliance_bg_free.desert:", #self.alliance_bg_free.desert)
    --     print("alliance_bg_free.grassLand:", #self.alliance_bg_free.grassLand)
    --     print("alliance_bg_free.iceField:", #self.alliance_bg_free.iceField)
    --     print("===============")
    -- end, 5)
end
function AllianceLayer:CreateMap()
    local map = display.newNode():addTo(self)

    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_WIDTH,
        tile_h = TILE_WIDTH,
        map_width = ALLIANCE_WIDTH * MAP_LEGNTH_WIDTH,
        map_height = ALLIANCE_HEIGHT * MAP_LEGNTH_HEIGHT,
        base_x = 0,
        base_y = ALLIANCE_HEIGHT * MAP_LEGNTH_HEIGHT * TILE_WIDTH,
    }

    self.alliance_logic_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_WIDTH * ALLIANCE_WIDTH,
        tile_h = TILE_WIDTH * ALLIANCE_HEIGHT,
        map_width = MAP_LEGNTH_WIDTH,
        map_height = MAP_LEGNTH_HEIGHT,
        base_x = 0,
        base_y = ALLIANCE_HEIGHT * MAP_LEGNTH_HEIGHT * TILE_WIDTH,
    }

    self.inner_alliance_logic_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_WIDTH,
        tile_h = TILE_WIDTH,
        map_width = ALLIANCE_WIDTH,
        map_height = ALLIANCE_HEIGHT,
        base_x = 0,
        base_y = intInit.allianceRegionMapHeight.value * TILE_WIDTH
    }

    return map
end
function AllianceLayer:StartCorpsTimer()
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        local time = timer:GetServerTime()
        for id, corps in pairs(self.map_corps) do
            if corps then
                local march_info = corps.march_info
                local total_time = march_info.finish_time - march_info.start_time
                local elapse_time = time - march_info.start_time
                if elapse_time <= total_time then
                    local len = march_info.speed * elapse_time
                    local cur_vec = cc.pAdd(cc.pMul(march_info.normal, len), march_info.start_info.real)
                    corps:pos(cur_vec.x, cur_vec.y)

                    -- 更新线
                    local line = self.map_lines[id]
                    local program = line:getFilter():getGLProgramState()
                    program:setUniformFloat("percent", math.fmod(time - math.floor(time), 1.0))
                    program:setUniformFloat("elapse", line.is_enemy and (cc.pGetLength(cc.pSub(cur_vec, march_info.origin_start)) / march_info.origin_length) or 0)

                    -- if self.track_id == id then
                    --     self:GotoMapPositionInMiddle(cur_vec.x, cur_vec.y)
                    -- end
                else
                    self:DeleteCorpsById(id)
                end
            end
        end
    end)
    self:scheduleUpdate()
end
function AllianceLayer:CreateOrUpdateCorps(id, start_pos, end_pos, start_time, finish_time, dragonType, soldiers, ally, banner_name)
    if finish_time <= timer:GetServerTime() then return end
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    if start_time == march_info.start_time and
        finish_time == march_info.finish_time then
        return
    end
    march_info.start_time = start_time
    march_info.finish_time = finish_time
    march_info.speed = (march_info.length / (finish_time - start_time))
    if not self.map_corps[id] then
        local corps = display.newNode():addTo(self.corps_node)
        local is_strike = not soldiers or #soldiers == 0
        if is_strike then
            UIKit:CreateDragonByDegree(march_info.degree, 1.2):addTo(corps)
        else
            UIKit:CreateMoveSoldiers(march_info.degree, soldiers[1]):addTo(corps)
        end
        if (ally == MINE or ally == FRIEND) and banner_name then
            UIKit:CreateNameBanner(banner_name, dragonType):addTo(corps, 1):pos(0, 80)
        end
        corps.march_info = march_info
        corps:pos(march_info.start_info.real.x, march_info.start_info.real.y)
        self.map_corps[id] = corps
        self:CreateLine(id, march_info, ally)
    else
        self:UpdateCorpsBy(self.map_corps[id], march_info)
    end
    return corps
end
function AllianceLayer:UpdateCorpsBy(corps, march_info)
    local x,y = corps:getPosition()
    local cur_pos = {x = x, y = y}
    march_info.start_info.real = cur_pos
    march_info.start_time = timer:GetServerTime()
    march_info.length = cc.pGetLength(cc.pSub(march_info.end_info.real, cur_pos))
    march_info.speed = (march_info.length / (march_info.finish_time - march_info.start_time))
    corps.march_info = march_info
end
function AllianceLayer:GetMarchInfoWith(id, logic_start_point, logic_end_point)
    local spt = self:RealPosition(logic_start_point.index, logic_start_point.x, logic_start_point.y)
    local ept = self:RealPosition(logic_end_point.index, logic_end_point.x, logic_end_point.y)
    local vector = cc.pSub(ept, spt)
    local degree = math.deg(cc.pGetAngle(vector, {x = 0, y = 1}))
    local length = cc.pGetLength(vector)
    return {
        origin_start = spt,
        origin_length = length,
        start_info = {real = spt, logic = logic_start_point},
        end_info = {real = ept, logic = logic_end_point},
        degree = degree,
        length = length,
        normal = cc.pNormalize(vector)
    }
end
function AllianceLayer:DeleteCorpsById(id)
    -- if self.map_dead[id] then
    --     self.map_dead[id]:removeFromParent()
    --     self.map_dead[id] = nil
    -- end
    if self.map_corps[id] then
        self.map_corps[id]:removeFromParent()
        self.map_corps[id] = nil
    end
    if self.map_lines[id] then
        self.map_lines[id]:removeFromParent()
        self.map_lines[id] = nil
    end
end
function AllianceLayer:IsExistCorps(id)
    return self.map_corps[id] ~= nil
end
local line_ally_map = {
    [MINE] = "arrow_green_22x32.png",
    [FRIEND] = "arrow_blue_22x32.png",
    [ENEMY] = "arrow_red_22x32.png",
}
function AllianceLayer:CreateLine(id, march_info, ally)
    if self.map_lines[id] then
        self.map_lines[id]:removeFromParent()
    end
    local middle = cc.pMidpoint(march_info.start_info.real, march_info.end_info.real)
    local scale = march_info.length / 32
    local unit_count = math.floor(scale)
    local sprite = display.newSprite(line_ally_map[ally]
        , nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self.lines_node)
        :pos(middle.x, middle.y)
        :rotation(march_info.degree)
    sprite:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/multi_tex.fs",
            shaderName = "lineShader_"..id,
            unit_count = unit_count,
            unit_len = 1 / unit_count,
            percent = 0,
            elapse = 0,
        })
    ))
    sprite:setScaleY(scale)
    sprite.is_enemy = ally == ENEMY
    self.map_lines[id] = sprite
    return sprite
end
function AllianceLayer:GetMiddleAllianceIndex()
    local point = self.map:convertToNodeSpace(cc.p(display.cx, display.cy))
    return self:LogicToIndex(self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y))
end
function AllianceLayer:GetVisibleAllianceIndexs()
    local t = {}
    local point = self.map:convertToNodeSpace(cc.p(0, display.height))
    t[1] = self:LogicToIndex(self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y))

    local point = self.map:convertToNodeSpace(cc.p(0, 0))
    t[2] = self:LogicToIndex(self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y))

    local point = self.map:convertToNodeSpace(cc.p(display.width, display.height))
    t[3] = self:LogicToIndex(self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y))

    local point = self.map:convertToNodeSpace(cc.p(display.width, 0))
    t[4] = self:LogicToIndex(self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y))
    return t
end
function AllianceLayer:GetLogicMap()
    return self.normal_map
end
function AllianceLayer:RealPosition(index, lx, ly)
    local x,y = self:IndexToLogic(index)
    return self:ConvertLogicPositionToMapPosition(ALLIANCE_WIDTH * x + lx, ALLIANCE_HEIGHT * y + ly)
end
function AllianceLayer:IndexToLogic(index)
    return index % MAP_LEGNTH_WIDTH, math.floor(index / MAP_LEGNTH_WIDTH)
end
function AllianceLayer:LogicToIndex(x, y)
    return x + y * MAP_LEGNTH_WIDTH
end
function AllianceLayer:GetInnerAllianceLogicMap()
    return self.inner_alliance_logic_map
end
function AllianceLayer:GetAllianceLogicMap()
    return self.alliance_logic_map
end
function AllianceLayer:ConvertLogicPositionToAlliancePosition(lx, ly)
    return self:convertToNodeSpace(self.map:convertToWorldSpace(cc.p(self.alliance_logic_map:ConvertToMapPosition(lx, ly))))
end
function AllianceLayer:ConvertLogicPositionToMapPosition(lx, ly)
    return self:convertToNodeSpace(self.map:convertToWorldSpace(cc.p(self.normal_map:ConvertToMapPosition(lx, ly))))
end
function AllianceLayer:GetClickedObject(world_x, world_y)
    local point = self.map:convertToNodeSpace(cc.p(world_x, world_y))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    local index = self:LogicToIndex(self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y))
    print(index, logic_x % ALLIANCE_WIDTH, logic_y % ALLIANCE_HEIGHT)
    local x,y = logic_x % ALLIANCE_WIDTH, logic_y % ALLIANCE_HEIGHT
    return self:FindMapObject(index, x, y)
end
function AllianceLayer:FindMapObject(index, x, y)
    local alliance_object = self.alliance_objects[index]
    if alliance_object then
        for k,v in pairs(alliance_object.mapObjects) do
            if v.x == x and v.y == y then
                return {index = index, x = v.x, y = v.y, name = v.name}
            end
        end
        for k,v in pairs(alliance_object.buildings) do
            if v.x == x and v.y == y then
                return {index = index, x = v.x, y = v.y, name = v.name}
            end
        end
        for k,v in pairs(alliance_object.decorators) do
            if v.x == x and v.y == y then
                return {index = index, x = v.x, y = v.y, name = v.name}
            end
        end
    end
    return {index = index, x = x, y = y, name = "empty"}
end
function AllianceLayer:AddMapObjectByIndex(index, mapObject)
    local alliance_object = self.alliance_objects[index]
    if alliance_object then
        if not alliance_object.mapObjects[mapObject.id] then
            self:AddMapObject(alliance_object, mapObject)
        end
    end
end
function AllianceLayer:RemoveMapObjectByIndex(index, mapObject)
   local alliance_object = self.alliance_objects[index]
    if alliance_object then
        if alliance_object.mapObjects[mapObject.id] then
            alliance_object.mapObjects[mapObject.id]:removeFromParent()
            alliance_object.mapObjects[mapObject.id] = nil
        end
    end 
end
function AllianceLayer:RefreshMapObjectByIndex(index, mapObject)
    local alliance_object = self.alliance_objects[index]
    if alliance_object then
        local sprite = alliance_object.mapObjects[mapObject.id]
        if sprite then
            self:RefreshMapObjectPosition(sprite, mapObject)
        end
    end
end
local maps = {
    "tmxmaps/alliance_desert1.tmx",
    "tmxmaps/alliance_grassLand1.tmx",
    "tmxmaps/alliance_iceField1.tmx",
}
function AllianceLayer:LoadAllianceByIndex(index, alliance)
    self:FreeInvisible()
    self:LoadBackground(index, alliance)
    self:LoadObjects(index, alliance, function(objects_node)
        if alliance and alliance ~= json.null then
            local map_obj_id = {}
            for k,v in pairs(alliance.mapObjects) do
                map_obj_id[v.id] = true
            end
            for _,mapObj in pairs(alliance.mapObjects) do
                local x,y = mapObj.location.x, mapObj.location.y
                local mapObject = objects_node.mapObjects[mapObj.id]
                if not mapObject then
                    mapObject = self:AddMapObject(objects_node, mapObj)
                end
                self:RefreshMapObjectPosition(mapObject, mapObj)
            end
            local mapObjects = objects_node.mapObjects
            for id,v in pairs(mapObjects) do
                if not map_obj_id[id] then
                    v:removeFromParent()
                    mapObjects[id] = nil
                end
            end
        end
    end)
end
function AllianceLayer:AddMapObject(objects_node, mapObj)
    local x,y = mapObj.location.x, mapObj.location.y
    local mapObject = objects_node.mapObjects[mapObj.id]
    local sprite
    if mapObj.name == "member" then
        sprite = display.newSprite("my_keep_1.png")
    elseif mapObj.name == "woodVillage" then
        sprite = display.newSprite("woodcutter_1.png")
    elseif mapObj.name == "stoneVillage" then
        sprite = display.newSprite("quarrier_1.png")
    elseif mapObj.name == "ironVillage" then
        sprite = display.newSprite("miner_1.png")
    elseif mapObj.name == "foodVillage" then
        sprite = display.newSprite("farmer_1.png")
    elseif mapObj.name == "coinVillage" then
        sprite = display.newSprite("dwelling_1.png")
    elseif mapObj.name == "monster" then
        sprite = UIKit:CreateIdle45Ani("heihua_bubing_2")
    else
        --todo
        assert(false)
    end
    sprite.name = mapObj.name
    objects_node.mapObjects[mapObj.id] = sprite:addTo(objects_node)
    return sprite
end
function AllianceLayer:RefreshMapObjectPosition(sprite, mapObject)
    local x,y = mapObject.location.x, mapObject.location.y
    sprite.x = x
    sprite.y = y
    sprite:zorder(getZorderByXY(x, y)):pos(self:GetInnerMapPosition(x, y))
end
function AllianceLayer:FreeInvisible()
    local background = self.background_node
    for k,v in pairs(self.alliance_bg) do
        local x,y = v:getPosition()
        local size = v:getContentSize()
        local left_bottom = background:convertToWorldSpace({x = x, y = y})
        local right_top = background:convertToWorldSpace({x = x + size.width, y = y + size.height})
        local r = cc.rect(left_bottom.x, left_bottom.y, right_top.x - left_bottom.x, right_top.y - left_bottom.y)
        local left_bottom_in = cc.rectContainsPoint(r, {x = 0, y = 0})
        local left_top_in = cc.rectContainsPoint(r, {x = 0, y = display.height})
        local right_bottom_in = cc.rectContainsPoint(r, {x = display.width, y = 0})
        local right_top_in = cc.rectContainsPoint(r, {x = display.width, y = display.height})
        if not left_bottom_in and not right_top_in and not left_top_in and not right_bottom_in then
            self:FreeBackground(self.alliance_bg[k])
            self.alliance_bg[k] = nil
            self:FreeObjects(self.alliance_objects[k])
            self.alliance_objects[k] = nil
        end
    end
end
local terrains = {
    [0] = "desert",
    "grassLand",
    "iceField",
}
function AllianceLayer:LoadObjects(index, alliance, func)
    local terrain, style = self:GetMapInfoByIndex(index, alliance)
    local alliance_obj = self.alliance_objects[index]
    if not alliance_obj then
        local new_obj = self:GetFreeObjects(terrain, style, index, alliance)
        self.alliance_objects[index] = new_obj:addTo(self.objects_node, index)
            :pos(
                self:GetAllianceLogicMap()
                    :ConvertToLeftBottomMapPosition(self:IndexToLogic(index))
            )
        new_obj:release()
        if type(func) == "function" then
            func(new_obj)
        end
    else
        if alliance_obj.style ~= style then
            self:FreeObjects(alliance_obj)
            self.alliance_objects[index] = nil
            self:LoadObjects(index, alliance)
        elseif alliance_obj.terrain ~= terrain then
            self:ReloadObjectsByTerrain(alliance_obj, terrain)
        end
        if type(func) == "function" then
            func(alliance_obj)
        end
    end
end
function AllianceLayer:FreeObjects(obj)
    if not obj then return end
    for k,v in pairs(obj.mapObjects) do
        v:removeFromParent()
    end
    obj.mapObjects = {}
    if obj:getParent() then
        obj:retain()
        table.insert(self.alliance_objects_free[obj.style], obj)
        obj:getParent():removeChild(obj, false)
    else
        table.insert(self.alliance_objects_free[obj.style], obj)
    end
end
function AllianceLayer:GetFreeObjects(terrain, style, index, alliance)
    local obj = table.remove(self.alliance_objects_free[style], 1)
    if obj then
        if obj.terrain ~= terrain then
            self:ReloadObjectsByTerrain(obj, terrain, index, alliance)
        end
        return obj
    else
        local obj = display.newNode()
        self:CreateAllianceObjects(obj, terrain, style, index, alliance)
        obj.mapObjects = {}
        obj.terrain = terrain
        obj.style = style
        obj:retain()
        return obj
    end
end
function AllianceLayer:ReloadObjectsByTerrain(obj_node, terrain, index, alliance)
    obj_node.terrain = terrain
    for k,v in pairs(obj_node.decorators) do
        v:setTexture(decorator_image[terrain][v.name])
    end
end
function AllianceLayer:CreateAllianceObjects(obj_node, terrain, style, index, alliance)
    local decorators = {}
    local buildings = {}
    for _,v in ipairs(AllianceMap[string.format("allianceMap_%d", style)]) do
        local name = v.name
        local size = buildingName[name]
        local x,y = (2 * v.x - size.width + 1) / 2, (2 * v.y - size.height + 1) / 2
        local deco_png = decorator_image[terrain][name]
        local building_png = alliance_building[name]
        if deco_png then
            local decorator = display.newSprite(deco_png)
                :addTo(obj_node, getZorderByXY(x, y))
                :pos(self:GetInnerMapPosition(x,y))
            decorator.x = x
            decorator.y = y
            decorator.name = name
            table.insert(decorators, decorator)
        elseif building_png then
            local building = display.newSprite(building_png)
                :addTo(obj_node, getZorderByXY(x, y))
                :pos(self:GetInnerMapPosition(x,y))
            building.x = x
            building.y = y
            building.name = name
            buildings[name] = building
        end
    end
    obj_node.decorators = decorators
    obj_node.buildings = buildings
end
function AllianceLayer:GetInnerMapPosition(xOrPosition, y)
    if type(xOrPosition) == "table" then
        return self:GetInnerAllianceLogicMap():ConvertToMapPosition(xOrPosition.x, xOrPosition.y)
    end
    return self:GetInnerAllianceLogicMap():ConvertToMapPosition(xOrPosition, y)
end
function AllianceLayer:LoadBackground(index, alliance)
    local terrain = self:GetMapInfoByIndex(index, alliance)
    if not self.alliance_bg[index] then
        local new_bg = self:GetFreeBackground(terrain)
        self:FreeBackground(self.alliance_bg[index])
        self.alliance_bg[index] = new_bg:addTo(self.background_node, index)
            :pos(
                self:GetAllianceLogicMap()
                    :ConvertToLeftBottomMapPosition(self:IndexToLogic(index))
            )
        new_bg:release()
    elseif self.alliance_bg[index].terrain ~= terrain then
        self:FreeBackground(self.alliance_bg[index])
        self.alliance_bg[index] = nil
        self:LoadBackground(index, alliance)
    end
end
function AllianceLayer:FreeBackground(bg)
    if not bg then return end
    if bg:getParent() then
        bg:retain()
        table.insert(self.alliance_bg_free[bg.terrain], bg)
        bg:getParent():removeChild(bg, false)
    else
        table.insert(self.alliance_bg_free[bg.terrain], bg)
    end
end
function AllianceLayer:GetFreeBackground(terrain)
    local bg = table.remove(self.alliance_bg_free[terrain], 1)
    if bg then
        return bg
    else
        local map = cc.TMXTiledMap:create(string.format("tmxmaps/alliance_%s1.tmx", terrain))
        map:retain()
        map.terrain = terrain
        return map
    end
end
function AllianceLayer:GetMapInfoByIndex(index, alliance)
    local terrain, style
    if (alliance == nil or alliance == json.null) then
        terrain, style = DataManager:getMapDataByIndex(index)
    else
        terrain, style = alliance.basicInfo.terrain, alliance.basicInfo.terrainStyle
    end
    terrain = terrain == nil and terrains[index % 3] or terrain
    style = style == nil and math.random(6) or style
    return terrain, style
end
--
function AllianceLayer:getContentSize()
    return worldsize
end


return AllianceLayer




























