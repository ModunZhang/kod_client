local Enum = import("..utils.Enum")
local CitySprite = import("..sprites.CitySprite")
local VillageSprite = import("..sprites.VillageSprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local AllianceObject = import("..entity.AllianceObject")
local AllianceMap = import("..entity.AllianceMap")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local AllianceView = import(".AllianceView")
local MapLayer = import(".MapLayer")
local TwoAllianceLayer = class("TwoAllianceLayer", MapLayer)
TwoAllianceLayer.ARRANGE = Enum("H", "V")
local ZORDER = Enum("BACKGROUND", "ALLIANCE_TERRAIN_BOTTOM", "TOP", "ALLIANCE_TERRAIN_TOP", "BUILDING", "LINE", "CORPS")
local floor = math.floor
local random = math.random
local AllianceShrine = import("..entity.AllianceShrine")
local AllianceMoonGate = import("..entity.AllianceMoonGate")
local Alliance = import("..entity.Alliance")
TwoAllianceLayer.VIEW_INDEX = Enum("MyAlliance","EnemyAlliance")


function TwoAllianceLayer:ctor(alliance1, alliance2, arrange)
    Observer.extend(self)

    self.alliances = {alliance1, alliance2}
    self.arrange = arrange or TwoAllianceLayer.ARRANGE.H
    TwoAllianceLayer.super.ctor(self, 0.4, 1.2)

    self:InitBackground()
    self:InitTerrianBottomNode()
    self:InitTerrianTopNode()
    self:InitBuildingNode()
    self:InitCorpsNode()
    self:InitLineNode()

    local alliance_view1 = AllianceView.new(self, alliance1,TwoAllianceLayer.VIEW_INDEX.MyAlliance, 0):addTo(self)
    local alliance_view2 = AllianceView.new(self, alliance2,TwoAllianceLayer.VIEW_INDEX.EnemyAlliance, 51):addTo(self)
    self.alliance_views = {alliance_view1, alliance_view2}

    -- 
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animations/dragon_red/dragon_red.ExportJson")
    local timer = app.timer
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function()
        local cur_time = timer:GetServerTime()
        for id, corps in pairs(self.corps_map) do
            if corps then
                local march_info = corps.march_info
                local total_time = march_info.finish_time - march_info.start_time
                local elapse_time = cur_time - march_info.start_time
                if elapse_time < total_time then
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
    --行军事件
    self:CreateAllianceCorps(self:GetMyAlliance())
    self:CreateAllianceCorps(self:GetEnemyAlliance())
    self:AddOrRemoveAllianceEvent(true)
  
end
function TwoAllianceLayer:InitBackground()
    self.background = cc.TMXTiledMap:create("tmxmaps/alliance_background_h.tmx"):addTo(self, ZORDER.BACKGROUND)
end
function TwoAllianceLayer:InitTerrianBottomNode()
    self.terrain_bottom = display.newNode():addTo(self, ZORDER.ALLIANCE_TERRAIN_BOTTOM)
end
function TwoAllianceLayer:InitTerrianTopNode()
    self.terrain_top = display.newNode():addTo(self, ZORDER.ALLIANCE_TERRAIN_TOP)
end
function TwoAllianceLayer:InitBuildingNode()
    self.building = display.newNode():addTo(self, ZORDER.BUILDING)
end
function TwoAllianceLayer:InitCorpsNode()
    self.corps = display.newNode():addTo(self, ZORDER.CORPS)
    self.corps_map = {}
end
function TwoAllianceLayer:InitLineNode()
    self.lines = display.newNode():addTo(self, ZORDER.LINE)
    self.lines_map = {}
end
function TwoAllianceLayer:GetBottomTerrain()
    return self.terrain_bottom
end
function TwoAllianceLayer:GetTopTerrain()
    return self.terrain_top
end
function TwoAllianceLayer:GetBuildingNode()
    return self.building
end
function TwoAllianceLayer:GetCorpsNode()
    return self.corps
end
function TwoAllianceLayer:GetLineNode()
    return self.lines
end

function TwoAllianceLayer:GetAlliances()
    return self.alliances
end

function TwoAllianceLayer:GetMyAlliance()
    return self.alliances[TwoAllianceLayer.VIEW_INDEX.MyAlliance]
end

function TwoAllianceLayer:GetEnemyAlliance()
    return self.alliances[TwoAllianceLayer.VIEW_INDEX.EnemyAlliance]
end

function TwoAllianceLayer:AddOrRemoveAllianceEvent(isAdd)
    if isAdd then
        self:GetMyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
        self:GetMyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
        self:GetEnemyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
        self:GetEnemyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)

        self:GetMyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
        self:GetMyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
        self:GetEnemyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
        self:GetEnemyAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)

    else
        self:GetMyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
        self:GetMyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
        self:GetEnemyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
        self:GetEnemyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)  

        self:GetMyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
        self:GetMyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)  
        self:GetEnemyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
        self:GetEnemyAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
    end
end

function TwoAllianceLayer:CreateAllianceCorps(alliance)
    table.foreachi(alliance:GetAttackMarchEvents(),function(_,event)
        self:CreateCorpsIf(event)
    end)
    table.foreachi(alliance:GetAttackMarchReturnEvents(),function(_,event)
        self:CreateCorpsIf(event)
    end)
    table.foreachi(alliance:GetStrikeMarchEvents(),function(_,event)
        self:CreateCorpsIf(event)
    end)
    table.foreachi(alliance:GetStrikeMarchReturnEvents(),function(_,event)
        self:CreateCorpsIf(event)
    end)

end
--changed of marchevent
function TwoAllianceLayer:OnAttackMarchEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function TwoAllianceLayer:OnAttackMarchReturnEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function TwoAllianceLayer:OnStrikeMarchEventDataChanged(changed_map)
    dump(changed_map,"OnStrikeMarchEventDataChanged-->")
    self:ManagerCorpsFromChangedMap(changed_map)
end

function TwoAllianceLayer:OnStrikeMarchReturnEventDataChanged(changed_map)
     dump(changed_map,"OnStrikeMarchReturnEventDataChanged-->")
    self:ManagerCorpsFromChangedMap(changed_map)
end

function TwoAllianceLayer:ManagerCorpsFromChangedMap(changed_map)
    if changed_map.removed then
        table.foreachi(changed_map.removed,function(_,marchEvent)
            self:DeleteCorpsById(marchEvent:Id())
        end)
    elseif changed_map.added then
        table.foreachi(changed_map.added,function(_,marchEvent)
            self:CreateCorpsIf(marchEvent)
        end)
    end
end

function TwoAllianceLayer:CreateCorpsIf(marchEvent)
    if not self:IsExistCorps(marchEvent:Id()) then
        local from,allianceId = marchEvent:FromLocation()
        if allianceId == self:GetMyAlliance():Id() then
            from.index = TwoAllianceLayer.VIEW_INDEX.MyAlliance
        else
            from.index = TwoAllianceLayer.VIEW_INDEX.EnemyAlliance
        end
        local to,allianceId   = marchEvent:TargetLocation()
        if allianceId == self:GetMyAlliance():Id() then
            to.index = TwoAllianceLayer.VIEW_INDEX.MyAlliance
        else
            to.index = TwoAllianceLayer.VIEW_INDEX.EnemyAlliance
        end
        self:CreateCorps( 
            marchEvent:Id(),
            from,
            to,
            marchEvent:StartTime(),
            marchEvent:ArriveTime()
        )
    end
end

function TwoAllianceLayer:onCleanup()
    self:AddOrRemoveAllianceEvent(false)
end

function TwoAllianceLayer:ConvertLogicPositionToMapPosition(lx, ly)
    local map_pos = cc.p(self.alliance_views[1]:GetLogicMap():ConvertToMapPosition(lx , ly))
    return self:convertToNodeSpace(self.background:convertToWorldSpace(map_pos))
end
function TwoAllianceLayer:CreateCorps(id, start_pos, end_pos, start_time, finish_time)
    assert(self.corps_map[id] == nil)
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    march_info.start_time = start_time
    march_info.finish_time = finish_time
    march_info.total_time = finish_time - start_time
    march_info.speed = (march_info.length /  march_info.total_time)
    local corps = display.newNode():addTo(self:GetCorpsNode())
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
function TwoAllianceLayer:DeleteCorpsById(id)
    if self.corps_map[id] == nil then
        print("部队已经被删除了!", id)
        return
    end
    self.corps_map[id]:removeFromParent()
    self.corps_map[id] = nil
    self:DeleteLineById(id)
end
function TwoAllianceLayer:DeleteAllCorps()
    for id, _ in pairs(self.corps_map) do
        self:DeleteCorpsById(id)
    end
end
function TwoAllianceLayer:IsExistCorps(id)
    return self.corps_map[id] ~= nil
end
function TwoAllianceLayer:CreateLine(id, start_pos, end_pos)
    assert(self.lines_map[id] == nil)
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    local middle = cc.pMidpoint(march_info.start_info.real, march_info.end_info.real)
    local scale = march_info.length / 22
    local unit_count = math.floor(scale)
    local sprite = display.newSprite("arrow_16x22.png", nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self:GetLineNode()):pos(middle.x, middle.y):rotation(march_info.degree)
    -- local line_id = string.format("_(%d,%d)->(%d,%d)", start_pos.x, start_pos.y, end_pos.x, end_pos.y)
    local line_id = math.floor(march_info.length)
    sprite:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/multi_tex.fs",
            shaderName = "lineShader"..line_id,
            unit_count = unit_count
        })
    ))
    sprite:setScaleY(scale)
    self.lines_map[id] = sprite
    return sprite
end
function TwoAllianceLayer:GetMarchInfoWith(id, logic_start_point, logic_end_point)
    assert(logic_start_point.index and logic_end_point.index,"")
    local spt = self.alliance_views[logic_start_point.index]:GetLogicMap():WrapConvertToMapPosition(logic_start_point.x, logic_start_point.y)
    local ept = self.alliance_views[logic_end_point.index]:GetLogicMap():WrapConvertToMapPosition(logic_end_point.x, logic_end_point.y)
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
function TwoAllianceLayer:DeleteLineById(id)
    if self.lines_map[id] == nil then
        print("路线已经被删除了!", id)
        return
    end
    self.lines_map[id]:removeFromParent()
    self.lines_map[id] = nil
end
function TwoAllianceLayer:DeleteAllLines()
    for id, _ in pairs(self.lines_map) do
        self:DeleteLineById(id)
    end
end
function TwoAllianceLayer:GetClickedObject(world_x, world_y)
    local logic_x, logic_y, current_view_alliance = self:GetCurrentViewAllianceCoordinate()
    return current_view_alliance:GetClickedObject(world_x, world_y),current_view_alliance:GetViewIndex() == TwoAllianceLayer.VIEW_INDEX.MyAlliance
end
function TwoAllianceLayer:EmptyGround(x, y)
    return {
        GetEntity = function()
            return AllianceObject.new(nil, nil, x, y)
        end
    }
end

----- override
function TwoAllianceLayer:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
    end
    return self.content_size
end
function TwoAllianceLayer:OnSceneMove()
    for _, v in ipairs(self.alliance_views) do
        v:OnSceneMove()
    end
    local logic_x, logic_y, current_view_alliance = self:GetCurrentViewAllianceCoordinate()
    self:NotifyObservers(function(listener)
        listener:OnSceneMove(logic_x, logic_y, current_view_alliance)
    end)
end
function TwoAllianceLayer:GetCurrentViewAllianceCoordinate()
    local point = self:GetBuildingNode():convertToNodeSpace(cc.p(display.cx, display.cy))
    local logic_x, logic_y, current_view_alliance
    if self.arrange == TwoAllianceLayer.ARRANGE.H then
        local left_allaince, right_alliance = unpack(self.alliance_views)
        logic_x, logic_y = right_alliance:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
        current_view_alliance = right_alliance
        if logic_x < 0 then
            logic_x, logic_y = left_allaince:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
            current_view_alliance = left_allaince
        end
    end
    return logic_x, logic_y, current_view_alliance
end

return TwoAllianceLayer







