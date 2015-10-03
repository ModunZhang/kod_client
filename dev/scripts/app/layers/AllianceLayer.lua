local Enum = import("..utils.Enum")
local UILib = import("..ui.UILib")
local Alliance = import("..entity.Alliance")
local allianceMap = import(".allianceMap")
local WidgetAllianceHelper = import("..widget.WidgetAllianceHelper")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "OBJECT")
local ui_helper = WidgetAllianceHelper.new()
local intInit = GameDatas.AllianceInitData.intInit
local decorator_image = UILib.decorator_image
local alliance_building = UILib.alliance_building
local MAP_LEGNTH_WIDTH = 41
local MAP_LEGNTH_HEIGHT = 41
local TILE_WIDTH = 160
local ALLINACE_WIDTH, ALLIANCE_HEIGHT = intInit.allianceRegionMapWidth.value, intInit.allianceRegionMapHeight.value
local worldsize = {width = ALLINACE_WIDTH * 160 * MAP_LEGNTH_WIDTH, height = ALLIANCE_HEIGHT * 160 * MAP_LEGNTH_HEIGHT}
local function getZorderByXY(x, y)
    return x + ALLINACE_WIDTH * y
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
        desert = {},
        grassLand = {},
        iceField = {},
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
        print("alliance_objects_free.desert:", #self.alliance_objects_free.desert)
        print("alliance_objects_free.grassLand:", #self.alliance_objects_free.grassLand)
        print("alliance_objects_free.iceField:", #self.alliance_objects_free.iceField)
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
        map_width = ALLINACE_WIDTH * MAP_LEGNTH_WIDTH,
        map_height = ALLIANCE_HEIGHT * MAP_LEGNTH_HEIGHT,
        base_x = 0,
        base_y = ALLIANCE_HEIGHT * MAP_LEGNTH_HEIGHT * TILE_WIDTH,
    }

    self.alliance_logic_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_WIDTH * ALLINACE_WIDTH,
        tile_h = TILE_WIDTH * ALLIANCE_HEIGHT,
        map_width = MAP_LEGNTH_WIDTH,
        map_height = MAP_LEGNTH_HEIGHT,
        base_x = 0,
        base_y = ALLIANCE_HEIGHT * MAP_LEGNTH_HEIGHT * TILE_WIDTH,
    }

    self.inner_alliance_logic_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_WIDTH,
        tile_h = TILE_WIDTH,
        map_width = ALLINACE_WIDTH,
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
    local logic_x, logic_y = self:GetAllianceLogicMap():ConvertToLogicPosition(point.x, point.y)
    print(point.x, point.y, logic_x, logic_y)
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
                if mapObj.name == "member" then
                    local x,y = mapObj.location.x, mapObj.location.y
                    print("LoadAllianceByIndex", x,y)
                    self:GetInnerMapPosition(x,y)
                    table.insert(objects_node.members,
                        display.newSprite("my_keep_1.png"):addTo(
                            objects_node,getZorderByXY(x, y)
                        ):pos(self:GetInnerMapPosition(x, y))
                    )
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
    local terrain = (alliance == nil or alliance == json.null) and
        terrains[index % 3] or alliance.basicInfo.terrain
    if not self.alliance_objects[index] then
        local new_obj = self:GetFreeObjects(terrain)
        self:FreeObjects(self.alliance_objects[index])
        self.alliance_objects[index] = new_obj:addTo(self.objects, index)
            :pos(
                self:GetAllianceLogicMap()
                    :ConvertToLeftBottomMapPosition(self:IndexToLogic(index))
            )
        new_obj:release()
        if type(func) == "function" then
            func(new_obj)
        end
    elseif self.alliance_objects[index].terrain ~= terrain then
        self:FreeObjects(self.alliance_objects[index])
        self.alliance_objects[index] = nil
        self:LoadObjects(index, alliance)
    end
end
function AllianceLayer:FreeObjects(obj)
    if not obj then return end
    for k,v in pairs(obj.members) do
        v:removeFromParent()
    end
    obj.members = {}
    if obj:getParent() then
        obj:retain()
        table.insert(self.alliance_objects_free[obj.terrain], obj)
        obj:getParent():removeChild(obj, false)
    else
        table.insert(self.alliance_objects_free[obj.terrain], obj)
    end
end
function AllianceLayer:GetFreeObjects(terrain)
    local obj = table.remove(self.alliance_objects_free[terrain], 1)
    if obj then
        return obj
    else
        local obj = display.newNode()
        self:CreateAllianceObjects(obj)
        -- obj.decorators = {}
        -- obj.buildings = {}
        obj.members = {}
        obj.terrain = terrain
        obj:retain()
        return obj
    end
end
local buildings_map = {
    "palace",
    "orderHall",
    "shrine",
    "shop",
    "moonGate",
    "decorate_mountain_1",
    "decorate_mountain_2",
    "decorate_lake_1",
    "decorate_lake_2",
    "decorate_tree_1",
    "decorate_tree_2",
    "decorate_tree_3",
    "decorate_tree_4",
}
local buildings_size = {
    palace = {w = 1, h = 1},
    orderHall = {w = 1, h = 1},
    shrine = {w = 1, h = 1},
    shop = {w = 1, h = 1},
    moonGate = {w = 1, h = 1},
    decorate_mountain_1 = {w = 3, h = 3},
    decorate_mountain_2 = {w = 3, h = 3},
    decorate_lake_1 = {w = 3, h = 3},
    decorate_lake_2 = {w = 3, h = 3},
    decorate_tree_1 = {w = 1, h = 1},
    decorate_tree_2 = {w = 1, h = 1},
    decorate_tree_3 = {w = 1, h = 1},
    decorate_tree_4 = {w = 1, h = 1},
}
function AllianceLayer:CreateAllianceObjects(obj_node, terrain, style)
    for i,v in ipairs(allianceMap.layers[1].data) do
        local name = buildings_map[v]
        if name then
            local size = buildings_size[name]
            local x,y = i % ALLINACE_WIDTH, math.floor(i / ALLINACE_WIDTH)
            x,y = (2 * x - size.w + 1) / 2, (2 * y - size.h + 1) / 2
            local deco = decorator_image.grassLand[name]
            local building = alliance_building[name]
            if deco then
                display.newSprite(deco):addTo(obj_node, getZorderByXY(x, y))
                :pos(self:GetInnerMapPosition(x,y))
            elseif building then
                display.newSprite(building):addTo(obj_node, getZorderByXY(x, y))
                :pos(self:GetInnerMapPosition(x,y))
            end
        end
    end
end
function AllianceLayer:GetInnerMapPosition(xOrPosition, y)
    if type(xOrPosition) == "table" then
        return self:GetInnerAllianceLogicMap():ConvertToMapPosition(xOrPosition.x, xOrPosition.y)
    end
    return self:GetInnerAllianceLogicMap():ConvertToMapPosition(xOrPosition, y)
end
function AllianceLayer:LoadBackground(index, alliance)
    local terrain = (alliance == nil or alliance == json.null) and
        terrains[index % 3] or alliance.basicInfo.terrain
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
function AllianceLayer:getContentSize()
    return worldsize
end


return AllianceLayer
















