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
local AllianceLayer = class("AllianceLayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "ALLIANCE_TERRAIN_BOTTOM", "ALLIANCE_TERRAIN_TOP", "BUILDING", "LINE", "CORPS")
local floor = math.floor
local random = math.random
local AllianceShrine = import("..entity.AllianceShrine")
local AllianceMoonGate = import("..entity.AllianceMoonGate")
local Alliance = import("..entity.Alliance")

function AllianceLayer:ctor(alliance)
    Observer.extend(self)
    AllianceLayer.super.ctor(self, 0.9, 2)

    self:InitBackground()
    self:InitTerrianBottomNode()
    self:InitTerrianTopNode()
    self:InitBuildingNode()
    self:InitCorpsNode()
    self:InitLineNode()

    self.alliance_view = AllianceView.new(self, alliance, 0):addTo(self)

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
    self:CreateCorpsFromMrachEventsIf()
    local alliance_shire = self:GetAlliance():GetAllianceShrine()
    local alliance_moonGate = self:GetAlliance():GetAllianceMoonGate()
    alliance_shire:AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchEventsChanged)
    alliance_shire:AddListenOnType(self,AllianceShrine.LISTEN_TYPE.OnMarchReturnEventsChanged)
    alliance_moonGate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateMarchEventsChanged)
    alliance_moonGate:AddListenOnType(self,AllianceMoonGate.LISTEN_TYPE.OnMoonGateMarchReturnEventsChanged)
    self:GetAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnHelpDefenceMarchEventsChanged)
    self:GetAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnHelpDefenceMarchReturnEventsChanged)
    self:GetAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnCityBeAttackedMarchEventChanged)
    self:GetAlliance():AddListenOnType(self,Alliance.LISTEN_TYPE.OnCityCityBeAttackedMarchReturnEventChanged)
end
function AllianceLayer:InitBackground()
    self.background = cc.TMXTiledMap:create("tmxmaps/alliance_background_h.tmx"):addTo(self, ZORDER.BACKGROUND)
end
function AllianceLayer:InitTerrianBottomNode()
    self.terrain_bottom = display.newNode():addTo(self, ZORDER.ALLIANCE_TERRAIN_BOTTOM)
end
function AllianceLayer:InitTerrianTopNode()
    self.terrain_top = display.newNode():addTo(self, ZORDER.ALLIANCE_TERRAIN_TOP)
end
function AllianceLayer:InitBuildingNode()
    self.building = display.newNode():addTo(self, ZORDER.BUILDING)
end
function AllianceLayer:InitCorpsNode()
    self.corps = display.newNode():addTo(self, ZORDER.CORPS)
    self.corps_map = {}
end
function AllianceLayer:InitLineNode()
    self.lines = display.newNode():addTo(self, ZORDER.LINE)
    self.lines_map = {}
end
function AllianceLayer:GetBottomTerrain()
    return self.terrain_bottom
end
function AllianceLayer:GetTopTerrain()
    return self.terrain_top
end
function AllianceLayer:GetBuildingNode()
    return self.building
end
function AllianceLayer:GetCorpsNode()
    return self.corps
end
function AllianceLayer:GetLineNode()
    return self.lines
end
function AllianceLayer:CreateCorpsFromMrachEventsIf()
    local alliance_shire = self:GetAlliance():GetAllianceShrine()
    table.foreachi(alliance_shire:GetMarchEvents(),function(_,merchEvent)
        self:CreateCorpsIf(merchEvent)
    end)
    table.foreachi(alliance_shire:GetMarchReturnEvents(),function(_,merchEvent)
        self:CreateCorpsIf(merchEvent)
    end)
    local alliance_moonGate = self:GetAlliance():GetAllianceMoonGate()
    table.foreach(alliance_moonGate:GetMoonGateMarchEvents(),function(_,merchEvent)
        self:CreateCorpsIf(merchEvent)
    end)
    table.foreach(alliance_moonGate:GetMoonGateMarchReturnEvents(),function(_,merchEvent)
        self:CreateCorpsIf(merchEvent)
    end)
    table.foreachi(self:GetAlliance():GetHelpDefenceMarchEvents(),function(_,helpDefenceMarchEvent)
        self:CreateCorpsIf(helpDefenceMarchEvent)
    end)

    table.foreachi(self:GetAlliance():GetHelpDefenceReturnMarchEvents(),function(_,helpDefenceMarchReturnEvent)
       self:CreateCorpsIf(helpDefenceMarchReturnEvent)
    end)

    self:GetAlliance():IteratorCityBeAttackedMarchEvents(function(cityBeAttackedMarchEvent)
        self:CreateCorpsIf(cityBeAttackedMarchEvent)
    end)
    self:GetAlliance():IteratorCityBeAttackedMarchReturnEvents(function(cityBeAttackedMarchReturnEvent)
        self:CreateCorpsIf(cityBeAttackedMarchReturnEvent)
    end)
end

function AllianceLayer:CreateCorpsIf(marchEvent)
    if not self:IsExistCorps(marchEvent:Id()) then
        self:CreateCorps( 
            marchEvent:Id(),
            marchEvent:FromLocation(),
            marchEvent:TargetLocation(),
            marchEvent:StartTime(),
            marchEvent:ArriveTime()
        )
    end
end

function AllianceLayer:ManagerCorpsFromChangedMap(changed_map)
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
function AllianceLayer:GetAlliance()
    return self.alliance_view:GetAlliance()
end
function AllianceLayer:OnCityBeAttackedMarchEventChanged(changed_map)
   self:ManagerCorpsFromChangedMap(changed_map)
end

function AllianceLayer:OnCityCityBeAttackedMarchReturnEventChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function AllianceLayer:OnHelpDefenceMarchEventsChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function AllianceLayer:OnHelpDefenceMarchReturnEventsChanged(changed_map)
    self:OnHelpDefenceMarchEventsChanged(changed_map)
end

function AllianceLayer:OnMarchEventsChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function AllianceLayer:OnMarchReturnEventsChanged(changed_map)
    self:OnMarchEventsChanged(changed_map)
end

function AllianceLayer:OnMoonGateMarchEventsChanged(changed_map)
     self:ManagerCorpsFromChangedMap(changed_map)
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

    self:GetAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnHelpDefenceMarchEventsChanged)
    self:GetAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnHelpDefenceMarchReturnEventsChanged)

    self:GetAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnCityBeAttackedMarchEventChanged)
    self:GetAlliance():RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnCityCityBeAttackedMarchReturnEventChanged)
end
function AllianceLayer:GetLogicMap()
    return self.alliance_view:GetLogicMap()
end
function AllianceLayer:ConvertLogicPositionToMapPosition(lx, ly)
    local map_pos = cc.p(self:GetLogicMap():ConvertToMapPosition(lx, ly))
    return self:convertToNodeSpace(self.background:convertToWorldSpace(map_pos))
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
function AllianceLayer:IsExistCorps(id)
    return self.corps_map[id] ~= nil
end
function AllianceLayer:CreateLine(id, start_pos, end_pos)
    assert(self.line_map[id] == nil)
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    local middle = cc.pMidpoint(march_info.start_info.real, march_info.end_info.real)
    local scale = march_info.length / 22
    local unit_count = math.floor(scale)
    local sprite = display.newSprite("arrow_16x22.png", nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self:GetLineNode()):pos(middle.x, middle.y):rotation(march_info.degree)
    local line_id = math.floor(march_info.length)
    sprite:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/multi_tex.fs",
            shaderName = "lineShader"..line_id,
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
    return self.alliance_view:GetClickedObject(world_x, world_y)
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
    self.alliance_view:OnSceneMove()

    local point = self:GetBuildingNode():convertToNodeSpace(cc.p(display.cx, display.cy))
    local logic_x, logic_y = self:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
    self:NotifyObservers(function(listener)
        listener:OnSceneMove(logic_x, logic_y)
    end)
end

return AllianceLayer

