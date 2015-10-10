local Enum = import("..utils.Enum")
local UILib = import("..ui.UILib")
local Alliance = import("..entity.Alliance")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "OBJECT")
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
local function getZorderByXY(x, y)
    return x + ALLIANCE_WIDTH * y
end
function AllianceLayer:ctor(scene)
    AllianceLayer.super.ctor(self, scene, 0.4, 1.2)
end
function AllianceLayer:onEnter()
    self:InitAllianceMap()
    self.map = self:CreateMap()
    self.background = display.newNode():addTo(self.map, ZORDER.BACKGROUND)
    self.objects = display.newNode():addTo(self.map, ZORDER.OBJECT)
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
    display.newNode():addTo(self):schedule(function()
        local count = 0
        for k,v in pairs(self.alliance_bg) do
            count = count + 1
        end

        print("alliance_objects:", count)
        print("alliance_objects_free.1:", #self.alliance_objects_free[1])
        print("alliance_objects_free.2:", #self.alliance_objects_free[2])
        print("alliance_objects_free.3:", #self.alliance_objects_free[3])
        print("alliance_objects_free.4:", #self.alliance_objects_free[4])
        print("alliance_objects_free.5:", #self.alliance_objects_free[5])
        print("alliance_objects_free.6:", #self.alliance_objects_free[6])
        print("alliance_bg:", count)
        print("alliance_bg_free.desert:", #self.alliance_bg_free.desert)
        print("alliance_bg_free.grassLand:", #self.alliance_bg_free.grassLand)
        print("alliance_bg_free.iceField:", #self.alliance_bg_free.iceField)
        print("===============")
    end, 5)
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
    if self.alliance_objects[index] then
        for k,v in pairs(self.alliance_objects[index].mapObjects) do
            if v.x == x and v.y == y then
                return v
            end
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
            for _,mapObj in pairs(alliance.mapObjects) do
                if not objects_node.mapObjects[mapObj.id] then
                    local x,y = mapObj.location.x, mapObj.location.y
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
                        assert(false)
                    end
                    sprite.x = x
                    sprite.y = y
                    sprite.mapIndex = index
                    sprite.alliance_id = alliance._id
                    sprite.id = mapObj.id
                    sprite.name = mapObj.name
                    sprite:addTo(objects_node,getZorderByXY(x, y))
                        :pos(self:GetInnerMapPosition(x, y))
                    objects_node.mapObjects[mapObj.id] = sprite
                end
            end
        end
    end)
end
function AllianceLayer:FreeInvisible()
    local background = self.background
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
        local new_obj = self:GetFreeObjects(terrain, style)
        self.alliance_objects[index] = new_obj:addTo(self.objects, index)
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
function AllianceLayer:GetFreeObjects(terrain, style)
    local obj = table.remove(self.alliance_objects_free[style], 1)
    if obj then
        if obj.terrain ~= terrain then
            self:ReloadObjectsByTerrain(obj, terrain)
        end
        return obj
    else
        local obj = display.newNode()
        self:CreateAllianceObjects(obj, terrain, style)
        obj.mapObjects = {}
        obj.terrain = terrain
        obj.style = style
        obj:retain()
        return obj
    end
end
function AllianceLayer:ReloadObjectsByTerrain(obj_node, terrain)
    obj_node.terrain = terrain
    for k,v in pairs(obj_node.decorators) do
        v:setTexture(decorator_image[terrain][v.name])
    end
end
function AllianceLayer:CreateAllianceObjects(obj_node, terrain, style)
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
            decorator.name = name
            table.insert(decorators, decorator)
        elseif building_png then
            local building = display.newSprite(building_png)
                :addTo(obj_node, getZorderByXY(x, y))
                :pos(self:GetInnerMapPosition(x,y))
            building.name = name
            table.insert(buildings, building)
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
        self.alliance_bg[index] = new_bg:addTo(self.background, index)
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























