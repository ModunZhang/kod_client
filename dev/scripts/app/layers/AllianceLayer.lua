local Enum = import("..utils.Enum")
local CitySprite = import("..sprites.CitySprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local AllianceObject = import("..entity.AllianceObject")
local AllianceMap = import("..entity.AllianceMap")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
local ZORDER = Enum("BOTTOM", "MIDDLE", "TOP", "BUILDING", "LINE", "SOLDIER")
local floor = math.floor
local random = math.random
local AllianceShrine = import("..entity.AllianceShrine")
local AllianceMoonGate = import("..entity.AllianceMoonGate")

function AllianceLayer:ctor(alliance)
    self.alliance_ = alliance
    Observer.extend(self)
    AllianceLayer.super.ctor(self, 0.9, 2)
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = 80,
        tile_h = 80,
        map_width = 21,
        map_height = 21,
        base_x = 0,
        base_y = 23 * 80
    }
    math.randomseed(1985423439857)
    self:InitBackground()
    self:InitMiddleBackground()
    self:InitTopBackground()
    self:InitBuildingNode()
    self:InitSoldierNode()
    self:InitLineNode()

    self:GetAlliance():GetAllianceMap():AddListenOnType({
        OnBuildingChange = function(this, alliance_map, add, remove, modify)
            dump(add)
            if #add > 0 then
                for _, v in pairs(add) do
                    self.objects[v:Id()] = self:CreateObject(v)
                end
            end
            dump(remove)
            if #remove > 0 then
                for _, v in pairs(remove) do
                    self.objects[v:Id()]:removeFromParent()
                    self.objects[v:Id()] = nil
                end
            end
            if #modify > 0 then
                for _, v in pairs(modify) do
                    self.objects[v:Id()]:SetPositionWithZOrder(self:GetLogicMap():ConvertToMapPosition(v:GetLogicPosition()))
                end
            end
        end
    }, AllianceMap.LISTEN_TYPE.BUILDING)


    local objects = {}
    self:GetAlliance():GetAllianceMap():IteratorAllObjects(function(_, entity)
        objects[entity:Id()] = self:CreateObject(entity)
    end)
    self.objects = objects



    local manager = ccs.ArmatureDataManager:getInstance()

    manager:addArmatureFileInfo("animations/dragon_red/dragon_red.ExportJson")
    ---
    local timer = app.timer
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()
        local cur_time = timer:GetServerTime()
        for id, corps in pairs(self.corps_map) do
            if corps then
                local march_info = corps.march_info
                local total_time = march_info.finish_time - march_info.start_time
                local elapse_time = cur_time - march_info.start_time
                if elapse_time <= total_time then
                    local cur_vec = cc.pAdd(cc.pMul(march_info.normal, march_info.speed * elapse_time), march_info.start_info.real)
                    corps:setPosition(cur_vec.x, cur_vec.y)
                else
                    self:DeleteCorpsById(id)
                end
            end
        end
    end)
    self:scheduleUpdate()

    self:setNodeEventEnabled(true)
    local alliance_shire = self:GetAlliance():GetAllianceShrine()
    table.foreachi(alliance_shire:GetMarchEvents(),function(_,merchEvent)
        self:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
    end)
    table.foreachi(alliance_shire:GetMarchReturnEvents(),function(_,merchEvent)
        self:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
    end)
    alliance_shire:AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchEventsChanged)
    alliance_shire:AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchReturnEventsChanged)

    local alliance_moonGate = self:GetAlliance():GetAllianceMoonGate()
    dump(alliance_moonGate:GetMoonGateMarchEvents())
    table.foreachi(alliance_moonGate:GetMoonGateMarchEvents(),function(_,merchEvent)
        self:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
    end)
    table.foreachi(alliance_moonGate:GetMoonGateMarchReturnEvents(),function(_,merchEvent)
        self:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
    end)
    alliance_moonGate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateMarchEventsChanged)
    alliance_moonGate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateMarchReturnEventsChanged)
end

function AllianceLayer:GetAlliance()
    return self.alliance_
end

function AllianceLayer:OnMarchEventsChanged(changed_map)
    if changed_map.removed then
        table.foreachi(changed_map.removed,function(_,merchEvent)
            self:DeleteCorpsById(merchEvent:Id())
        end)
    elseif changed_map.added then
        table.foreachi(changed_map.added,function(_,merchEvent)
            self:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
        end)
    end
end

function AllianceLayer:OnMarchReturnEventsChanged(changed_map)
    self:OnMarchEventsChanged(changed_map)
end

function AllianceLayer:OnMoonGateMarchEventsChanged(changed_map)
    if changed_map.remove then
        table.foreachi(changed_map.remove,function(_,merchEvent)
            self:DeleteCorpsById(merchEvent:Id())
        end)
    elseif changed_map.add then
        table.foreachi(changed_map.add,function(_,merchEvent)
            self:CreateCorps(merchEvent:Id(), merchEvent:FromLocation(), merchEvent:TargetLocation(), merchEvent:StartTime(), merchEvent:ArriveTime())
        end)
    end
end

function AllianceLayer:OnMoonGateMarchReturnEventsChanged(changed_map)
    self:OnMoonGateMarchEventsChanged(changed_map)
end

function AllianceLayer:onCleanup()
    local alliance_shire = self:GetAlliance():GetAllianceShrine()
    alliance_shire:RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchEventsChanged)
    alliance_shire:RemoveListenerOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchReturnEventsChanged)

    local alliance_moonGate = self:GetAlliance():GetAllianceMoonGate()
    alliance_moonGate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateMarchEventsChanged)
    alliance_moonGate:RemoveListenerOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateMarchReturnEventsChanged)

end

function AllianceLayer:CreateObject(entity)
    local category = entity:GetCategory()
    local object
    if category == "building" then
        object = AllianceBuildingSprite.new(self, entity):addTo(self:GetBuildingNode())
    elseif category == "member" then
        object = CitySprite.new(self, entity):addTo(self:GetBuildingNode())
    elseif category == "village" then
        -- object = CitySprite.new(self, entity):addTo(self:GetBuildingNode())
    elseif category == "decorate" then
        object = AllianceDecoratorSprite.new(self, entity):addTo(self:GetBuildingNode())
    end
    return object
end
function AllianceLayer:GetMapSize()
    return 21, 21
end
function AllianceLayer:GetLogicMap()
    return self.normal_map
end
function AllianceLayer:ConvertLogicPositionToMapPosition(lx, ly)
    local map_pos = cc.p(self.normal_map:ConvertToMapPosition(lx, ly))
    return self:convertToNodeSpace(self.background:convertToWorldSpace(map_pos))
end
function AllianceLayer:InitBackground()
    self.background = cc.TMXTiledMap:create("tmxmaps/alliance_background1.tmx"):addTo(self, ZORDER.BOTTOM)
end
function AllianceLayer:InitMiddleBackground()
    local bottom_layer = display.newNode():addTo(self, ZORDER.MIDDLE)
    local png = {
        "grass1_800x560.png",
        "grass2_800x560.png",
        "grass3_800x560.png",
    }
    for i, v in pairs{
        {x = 4.5, y = 4.5},
        {x = 4.5, y = 14.5},
        {x = 14.5, y = 4.5},
        {x = 14.5, y = 14.5},
    } do
        local png_index = random(123456789) % 3 + 1
        display.newSprite(png[png_index]):addTo(bottom_layer)
            :align(display.CENTER, self.normal_map:ConvertToMapPosition(v.x, v.y))
    end
    self.middle_background = bottom_layer
end
function AllianceLayer:InitTopBackground()
    local function random_indexes_in_rect(number, rect)
        local indexes = {}
        local count = 0
        local random_map = {}
        repeat
            local x = random(123456789) % (rect.width + 1)
            if not random_map[x] then
                random_map[x] = {}
            end
            local y = random(123456789) % (rect.height + 1)
            if not random_map[x][y] then
                random_map[x][y] = true

                local png_index = random(123456789) % 3 + 1
                table.insert(indexes, {x = x + rect.x, y = y + rect.y, png_index = png_index})
                count = count + 1
            end
        until number < count
        return indexes
    end
    local png = {
        "grass1_400x280.png",
        "grass2_400x280.png",
        "grass3_400x280.png",
    }
    local middle_layer = display.newNode():addTo(self, ZORDER.TOP)
    local indexes = random_indexes_in_rect(20, cc.rect(0, 0, 21, 21))
    for i, v in ipairs(indexes) do
        display.newSprite(png[v.png_index]):addTo(middle_layer)
            :align(display.CENTER, self.normal_map:ConvertToMapPosition(v.x, v.y))
    end
    self.top_background = middle_layer
end
function AllianceLayer:InitBuildingNode()
    self.building_node = display.newNode():addTo(self, ZORDER.BUILDING)
end
function AllianceLayer:InitSoldierNode()
    self.soldier_node = display.newNode():addTo(self, ZORDER.SOLDIER)
    self.corps_map = {}
end
function AllianceLayer:InitLineNode()
    self.line_node = display.newNode():addTo(self, ZORDER.LINE)
    self.line_map = {}
end
function AllianceLayer:GetBuildingNode()
    return self.building_node
end
function AllianceLayer:GetSoldierNode()
    return self.soldier_node
end
function AllianceLayer:GetLineNode()
    return self.line_node
end
function AllianceLayer:CreateCorps(id, start_pos, end_pos, start_time, finish_time)
    assert(self.corps_map[id] == nil)
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    march_info.start_time = start_time
    march_info.finish_time = finish_time
    march_info.total_time = finish_time - start_time
    march_info.speed = (march_info.length /  march_info.total_time)
    local corps = display.newNode():addTo(self:GetSoldierNode())
    local armature = ccs.Armature:create("dragon_red"):addTo(corps):scale(0.5)

    local dir_map = {
        {"Flying_0", -1},
        {"Flying_1", -1},
        {"Flying_2", -1},
        {"Flying_2", 1},
        {"Flying_2", 1},
        {"Flying_1", 1},
        {"Flying_0", 1},
        {"Flying_0", -1},
    }
    print("CreateCorps",math.floor(march_info.degree / 45) + 4,march_info.degree)
    local ani, scalex
    if march_info.degree>=0 then
        ani, scalex = unpack(dir_map[math.floor(march_info.degree / 45) + 4])
    else
        ani, scalex = unpack(dir_map[math.ceil(march_info.degree / 45) + 4])
    end
    armature:getAnimation():play(ani)
    corps:setScaleX(scalex)

    corps.march_info = march_info
    self.corps_map[id] = corps
    self:CreateLine(id, march_info.start_info.logic, march_info.end_info.logic)
    return corps
end
function AllianceLayer:DeleteCorpsById(id)
    if self.corps_map[id] == nil then
        print("部队已经被删除了!", id)
        return
    end
    self.corps_map[id]:removeFromParent()
    self.corps_map[id] = nil
    self:DeleteLineById(id)
end
function AllianceLayer:DeleteAllCorps()
    for id, _ in pairs(self.corps_map) do
        self:DeleteCorpsById(id)
    end
end
function AllianceLayer:CreateLine(id, start_pos, end_pos)
    assert(self.line_map[id] == nil)
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    local middle = cc.pMidpoint(march_info.start_info.real, march_info.end_info.real)
    local scale = march_info.length / 22
    local unit_count = math.floor(scale)
    local sprite = display.newSprite("arrow_16x22.png", nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self:GetLineNode()):pos(middle.x, middle.y):rotation(march_info.degree)
    sprite:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/multi_tex.fs",
            shaderName = "lineShader"..id,
            unit_count = unit_count
        })
    ))
    sprite:setScaleY(scale)
    self.line_map[id] = sprite
    return sprite
end
function AllianceLayer:GetMarchInfoWith(id, logic_start_point, logic_end_point)
    local logic_map = self:GetLogicMap()
    local spt = logic_map:WrapConvertToMapPosition(logic_start_point.x, logic_start_point.y)
    local ept = logic_map:WrapConvertToMapPosition(logic_end_point.x, logic_end_point.y)
    local vec = cc.pSub(ept, spt)
    local deg = math.deg(cc.pGetAngle(vec, {x = 0, y = 1}))
    local length = cc.pGetLength(vec)
    local scale = length / 22
    local unit_count = math.floor(scale)
    return {
        start_info = {real = spt, logic = logic_start_point},
        end_info = {real = ept, logic = logic_end_point},
        degree = deg,
        dir_vector = vec,
        length = length,
        normal = cc.pNormalize(vec)
    }
end
function AllianceLayer:DeleteLineById(id)
    if self.line_map[id] == nil then
        print("路线已经被删除了!", id)
        return
    end
    self.line_map[id]:removeFromParent()
    self.line_map[id] = nil
end
function AllianceLayer:DeleteAllLines()
    for id, _ in pairs(self.line_map) do
        self:DeleteLineById(id)
    end
end
function AllianceLayer:GetClickedObject(world_x, world_y)
    local point = self:GetBuildingNode():convertToNodeSpace(cc.p(world_x, world_y))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    local clicked_list = {
        logic_clicked = {},
        sprite_clicked = {}
    }
    self:IteratorAllianceObjects(function(_, v)
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
    local clicked_object = clicked_list.logic_clicked[1] or clicked_list.sprite_clicked[1]
    return clicked_object or self:EmptyGround(logic_x, logic_y)
end
function AllianceLayer:EmptyGround(x, y)
    return {
        GetEntity = function()
            return AllianceObject.new(nil, nil, x, y)
        end
    }
end
function AllianceLayer:IteratorAllianceObjects(func)
    table.foreach(self.objects, func)
end

----- override
function AllianceLayer:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
    end
    return self.content_size
end
function AllianceLayer:OnSceneMove()
    self:IteratorAllianceObjects(function(_, object)
        object:OnSceneMove()
    end)
    local point = self:GetBuildingNode():convertToNodeSpace(cc.p(display.cx, display.cy))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    self:NotifyObservers(function(listener)
        listener:OnSceneMove(logic_x, logic_y)
    end)
end

return AllianceLayer











































