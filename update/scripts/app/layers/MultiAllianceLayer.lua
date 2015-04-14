local Enum = import("..utils.Enum")
local UILib = import("..ui.UILib")
local Alliance = import("..entity.Alliance")
local Observer = import("..entity.Observer")
local AllianceView = import(".AllianceView")
local MapLayer = import(".MapLayer")
local MultiAllianceLayer = class("MultiAllianceLayer", MapLayer)
local ZORDER = Enum("BACKGROUND", "BUILDING", "LINE", "CORPS")
local floor = math.floor
local min = math.min
local max = math.max
local timer = app.timer

MultiAllianceLayer.ARRANGE = Enum("H", "V")

function MultiAllianceLayer:ctor(arrange, ...)
    Observer.extend(self)
    MultiAllianceLayer.super.ctor(self, 0.4, 1.2)
    self.arrange = arrange
    self.alliances = {...}
    self.alliance_views = {}
    self:InitBackground()
    self:InitBuildingNode()
    self:InitCorpsNode()
    self:InitLineNode()
    self:InitAllianceView()
    self:InitAllianceEvent()
    self:AddOrRemoveAllianceEvent(true)
    self:StartCorpsTimer()


    -- local x, y = 13, 36
    -- local len = 9
    -- local count = 1
    -- for i = x - len, x + len do
    --     self:CreateCorps(
    --         count,
    --         {x = x, y = y, index = 1},
    --         {x = i, y = y + 10, index = 1},
    --         timer:GetServerTime(),
    --         timer:GetServerTime() + 100,
    --         "redDragon"
    --     )
    --     count = count + 1
    -- end

    -- for i = x - len, x + len do
    --     self:CreateCorps(
    --         count,
    --         {x = x, y = y, index = 1},
    --         {x = i, y = y - 10, index = 1},
    --         timer:GetServerTime(),
    --         timer:GetServerTime() + 30
    --     )
    --     count = count + 1
    -- end


    -- for i = y - len, y + len do
    --     self:CreateCorps(
    --         count,
    --         {x = x, y = y, index = 1},
    --         {x = x + 10, y = i, index = 1},
    --         timer:GetServerTime(),
    --         timer:GetServerTime() + 30
    --     )
    --     count = count + 1
    -- end


    -- for i = y - len, y + len do
    --     self:CreateCorps(
    --         count,
    --         {x = x, y = y, index = 1},
    --         {x = x - 10, y = i, index = 1},
    --         timer:GetServerTime(),
    --         timer:GetServerTime() + 30
    --     )
    --     count = count + 1
    -- end

end
function MultiAllianceLayer:onCleanup()
    self:AddOrRemoveAllianceEvent(false)
end
function MultiAllianceLayer:InitBackground()
    self:ReloadBackGround()
end
function MultiAllianceLayer:ChangeTerrain()
    self:ReloadBackGround()
    for _, v in ipairs(self.alliance_views) do
        v:ChangeTerrain()
    end
end
local terrain_map = {
    grassLand = {
        "012.png",
        "013.png",
        "014.png",
        "015.png",
    },
    desert = {
        "005.png",
        "006.png",
        "007.png",
        "008.png",
    },
    iceField = {

    }
}
function MultiAllianceLayer:ReloadBackGround()
    if self.background then
        self.background:removeFromParent()
    end
    print("self:GetMapFileByArrangeAndTerrain()", self:GetMapFileByArrangeAndTerrain())
    self.background = cc.TMXTiledMap:create(self:GetMapFileByArrangeAndTerrain()):addTo(self, ZORDER.BACKGROUND)
    --
    local terrains = self:GetTerrains()
    if #terrains == 1 then
        local array = terrain_map[terrains[1]]
        if #array > 0 then
            local size = self:getContentSize()
            local random = math.random
            local span = 200
            for i = 1, 300 do
                local x = random(span, size.width - span)
                local y = random(span, size.height - span)
                display.newSprite(array[random(#array)]):addTo(self.background, 1000):pos(x, y)
            end
        end
    else

    end
end
function MultiAllianceLayer:GetMapFileByArrangeAndTerrain()
    local terrains = self:GetTerrains()
    if #terrains == 1 then
        return string.format("tmxmaps/alliance_%s.tmx", unpack(terrains))
    end
    local terrain1, terrain2 = unpack(terrains)
    local arrange = MultiAllianceLayer.ARRANGE.H == self.arrange and "h" or "v"
    return string.format("tmxmaps/alliance_%s_%s_%s.tmx", arrange, terrain1, terrain2)
end
function MultiAllianceLayer:GetTerrains()
    if #self.alliances == 1 then
        return {self.alliances[1]:Terrain()}
    end
    local first, second = unpack(self.alliances)
    return {first:Terrain(), second:Terrain()}
end
function MultiAllianceLayer:InitBuildingNode()
    self.building = display.newNode():addTo(self, ZORDER.BUILDING)
end
function MultiAllianceLayer:InitCorpsNode()
    self.corps = display.newNode():addTo(self, ZORDER.CORPS)
    self.corps_map = {}
end
function MultiAllianceLayer:InitLineNode()
    self.lines = display.newNode():addTo(self, ZORDER.LINE)
    self.lines_map = {}
end
function MultiAllianceLayer:GetBuildingNode()
    return self.building
end
function MultiAllianceLayer:GetCorpsNode()
    return self.corps
end
function MultiAllianceLayer:GetLineNode()
    return self.lines
end
function MultiAllianceLayer:InitAllianceView()
    local alliance_view1, alliance_view2
    if #self.alliances == 1 then
        alliance_view1 = AllianceView.new(self, self.alliances[1]):addTo(self)
        self.alliance_views = {alliance_view1}
        return
    end
    if MultiAllianceLayer.ARRANGE.H == self.arrange then
        alliance_view1 = AllianceView.new(self, self.alliances[1], 0):addTo(self)
        alliance_view2 = AllianceView.new(self, self.alliances[2], 51):addTo(self)
        -- local sx, sy = alliance_view1:GetLogicMap():ConvertToMapPosition(50.5, -3.5)
        -- local ex, ey = alliance_view1:GetLogicMap():ConvertToMapPosition(50.5, 51.5)
        -- display.newLine({{sx, sy}, {ex, ey}},
        --     {borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0),
        --         borderWidth = 5}):addTo(self.building)
    else
        alliance_view1 = AllianceView.new(self, self.alliances[1], 0, 103):addTo(self)
        alliance_view2 = AllianceView.new(self, self.alliances[2], 0, 52):addTo(self)
        -- local sx, sy = alliance_view1:GetLogicMap():ConvertToMapPosition(-0.5, 51.5)
        -- local ex, ey = alliance_view1:GetLogicMap():ConvertToMapPosition(51.5, 51.5)
        -- display.newLine({{sx, sy}, {ex, ey}},
        --     {borderColor = cc.c4f(1.0, 0.0, 0.0, 1.0),
        --         borderWidth = 5}):addTo(self.building)
    end
    self.alliance_views = {alliance_view1, alliance_view2}
end
function MultiAllianceLayer:AddOrRemoveAllianceEvent(isAdd)
    if isAdd then
        for _, v in ipairs(self.alliances) do
            v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
            v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
            v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
            v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
            v:AddListenOnType(self,Alliance.LISTEN_TYPE.OnMarchEventRefreshed)
        end
    else
        for _, v in ipairs(self.alliances) do
            v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchEventDataChanged)
            v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnAttackMarchReturnEventDataChanged)
            v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchEventDataChanged)
            v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnStrikeMarchReturnEventDataChanged)
            v:RemoveListenerOnType(self,Alliance.LISTEN_TYPE.OnMarchEventRefreshed)
        end
    end
end
function MultiAllianceLayer:ConvertLogicPositionToMapPosition(lx, ly, alliance_id)
    local alliance_vew = self.alliance_views[self:GetAllianceViewIndexById(alliance_id)]
    local map_pos = cc.p(alliance_vew:GetLogicMap():ConvertToMapPosition(lx, ly))
    return self:convertToNodeSpace(self.background:convertToWorldSpace(map_pos))
end
function MultiAllianceLayer:GetAllianceViewIndexById(id)
    for i,v in ipairs(self.alliances) do
        if v:Id() == id then
            return i
        end
    end
    return 1
end
function MultiAllianceLayer:GetAlliances()
    return self.alliances
end

function MultiAllianceLayer:GetMyAlliance()
    return Alliance_Manager:GetMyAlliance()
end

function MultiAllianceLayer:GetEnemyAlliance()
    return Alliance_Manager:GetEnemyAlliance()
end

function MultiAllianceLayer:InitAllianceEvent()
    for _, v in ipairs(self.alliances) do
        self:CreateAllianceCorps(v)
    end
end
function MultiAllianceLayer:StartCorpsTimer()
    local time = 0
    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(dt)
        time = time + dt
        local cur_time = timer:GetServerTime()
        for id, corps in pairs(self.corps_map) do
            if corps then
                local march_info = corps.march_info
                local total_time = march_info.finish_time - march_info.start_time
                local elapse_time = cur_time - march_info.start_time
                if elapse_time <= total_time then
                    local cur_vec = cc.pAdd(cc.pMul(march_info.normal, march_info.speed * elapse_time), march_info.start_info.real)
                    corps:pos(cur_vec.x, cur_vec.y)
                else
                    self:DeleteCorpsById(id)
                end
                local line = self.lines_map[id]
                if line then
                    local shader_program = line:getFilter():getGLProgramState()
                    shader_program:setUniformFloat("curTime", time)
                    -- local percent = elapse_time / total_time
                    -- shader_program:setUniformFloat("percent", min(max(0, percent), 1))
                end
            end
        end
    end)
    self:scheduleUpdate()
end
function MultiAllianceLayer:CreateAllianceCorps(alliance)
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
--如果是重新登陆数据刷新 刷新所有行军路线
function MultiAllianceLayer:OnMarchEventRefreshed(eventName)
    self:InitAllianceEvent()
end

function MultiAllianceLayer:OnAttackMarchEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function MultiAllianceLayer:OnAttackMarchReturnEventDataChanged(changed_map)
    self:ManagerCorpsFromChangedMap(changed_map)
end

function MultiAllianceLayer:OnStrikeMarchEventDataChanged(changed_map)
    dump(changed_map,"OnStrikeMarchEventDataChanged-->")
    self:ManagerCorpsFromChangedMap(changed_map)
end

function MultiAllianceLayer:OnStrikeMarchReturnEventDataChanged(changed_map)
    dump(changed_map,"OnStrikeMarchReturnEventDataChanged-->")
    self:ManagerCorpsFromChangedMap(changed_map)
end
function MultiAllianceLayer:ManagerCorpsFromChangedMap(changed_map)
    if changed_map.removed then
        table.foreachi(changed_map.removed,function(_,marchEvent)
            self:DeleteCorpsById(marchEvent:Id())
        end)
    elseif changed_map.edited then
        table.foreachi(changed_map.edited,function(_,marchEvent)
            self:CreateCorpsIf(marchEvent)
        end)
    elseif changed_map.added then
        table.foreachi(changed_map.added,function(_,marchEvent)
            self:CreateCorpsIf(marchEvent)
        end)
    end
end


function MultiAllianceLayer:CreateCorpsIf(marchEvent)
    local from,allianceId = marchEvent:FromLocation()
    from.index = self:GetAllianceViewIndexById(allianceId)
    local to,allianceId   = marchEvent:TargetLocation()
    to.index = self:GetAllianceViewIndexById(allianceId)
    self:CreateCorps(
        marchEvent:Id(),
        from,
        to,
        marchEvent:StartTime(),
        marchEvent:ArriveTime(),
        marchEvent:AttackPlayerData().dragon.type,
        marchEvent:AttackPlayerData().soldiers
    )
end
local dragon_dir_map = {
    [0] = {"flying_45", -1}, -- x-,y+
    {"flying_45", -1}, -- x-,y+
    {"flying_-45", -1}, -- x-

    {"flying_-45", -1}, -- x-,y-
    {"flying_-45", 1}, -- y+
    {"flying_-45", 1}, -- x+,y+

    {"flying_45", 1}, -- x+
    {"flying_45", 1}, -- x+,y-
    {"flying_45", 1}, -- y-
}
local soldier_scale = 1
local corps_scale = 1
local soldier_dir_map = {
    [0] = {"move_45", - corps_scale, soldier_scale}, -- x-,y+
    {"move_45", - corps_scale, soldier_scale}, -- x-,y+
    {"move_-45", - corps_scale, soldier_scale}, -- x-

    {"move_-45", - corps_scale, soldier_scale}, -- x-,y-
    {"move_-45", corps_scale, soldier_scale}, -- y+
    {"move_-45", corps_scale, soldier_scale}, -- x+,y+

    {"move_45", corps_scale, soldier_scale}, -- x+
    {"move_45", corps_scale, soldier_scale}, -- x+,y-
    {"move_45", corps_scale, soldier_scale}, -- y-
}
local soldier_config = {
    ----
    ["swordsman"] = {
        count = 4,
        {"bubing_1", -10, 45, 0.8},
        {"bubing_2", -20, 40, 0.8},
        {"bubing_3", -15, 35, 0.8},
    },
    ["ranger"] = {
        count = 4,
        {"gongjianshou_1", 0, 45, 0.8},
        {"gongjianshou_2", 0, 45, 0.8},
        {"gongjianshou_3", 0, 45, 0.8},
    },
    ["lancer"] = {
        count = 2,
        {"qibing_1", -10, 50, 0.8},
        {"qibing_2", -10, 50, 0.8},
        {"qibing_3", -10, 50, 0.8},
    },
    ["catapult"] = {
        count = 1,
        {  "toushiche", 0, 35, 1},
        {"toushiche_2", 0, 35, 1},
        {"toushiche_3", 0, 35, 1},
    },

    -----
    ["sentinel"] = {
        count = 4,
        {"shaobing_1", 0, 55, 0.8},
        {"shaobing_2", 0, 55, 0.8},
        {"shaobing_3", 0, 55, 0.8},
    },
    ["crossbowman"] = {
        count = 4,
        {"nugongshou_1", 0, 45, 0.8},
        {"nugongshou_2", 0, 50, 0.8},
        {"nugongshou_3", 15, 45, 0.8},
    },
    ["horseArcher"] = {
        count = 2,
        {"youqibing_1", -15, 55, 0.8},
        {"youqibing_2", -15, 55, 0.8},
        {"youqibing_3", -15, 55, 0.8},
    },
    ["ballista"] = {
        count = 1,
        {"nuche_1", 0, 30, 1},
        {"nuche_2", 0, 30, 1},
        {"nuche_3", 0, 30, 1},
    },
    ----
    ["skeletonWarrior"] = {
        count = 4,
        {"kulouyongshi", 0, 40, 0.8},
        {"kulouyongshi", 0, 40, 0.8},
        {"kulouyongshi", 0, 40, 0.8},
    },
    ["skeletonArcher"] = {
        count = 4,
        {"kulousheshou", 25, 40, 0.8},
        {"kulousheshou", 25, 40, 0.8},
        {"kulousheshou", 25, 40, 0.8},
    },
    ["deathKnight"] = {
        count = 2,
        {"siwangqishi", -10, 50, 0.8},
        {"siwangqishi", -10, 50, 0.8},
        {"siwangqishi", -10, 50, 0.8},
    },
    ["meatWagon"] = {
        count = 1,
        {"jiaorouche", 0, 30, 0.8},
        {"jiaorouche", 0, 30, 0.8},
        {"jiaorouche", 0, 30, 0.8},
    },
}

local len = 30
local location_map = {
    [1] = {
        {0, 0},
    },
    [2] = {
        {- len * 0.5, len * 0.5},
        {- len * 0.5, - len * 0.5},
    },
    [4] = {
        {len * 0.5, len * 0.5},
        {- len * 0.5, len * 0.5},
        {len * 0.5, - len * 0.5},
        {- len * 0.5, - len * 0.5},
    },
}
local function move_soldiers(corps, ani, dir_index, first_soldier)
    local config = soldier_config[first_soldier.name]
    local ani_name,count = config[first_soldier.star or 1][1], config.count
    local _,_,soldier_scale = unpack(soldier_dir_map[dir_index])
    for i,v in ipairs(location_map[count]) do
        local x,y = unpack(v)
        ccs.Armature:create(ani_name):addTo(corps):scale(soldier_scale)
            :align(display.CENTER, x, y):getAnimation():play(ani)
    end
end
function MultiAllianceLayer:CreateCorps(id, start_pos, end_pos, start_time, finish_time, dragonType, soldiers)
    local march_info = self:GetMarchInfoWith(id, start_pos, end_pos)
    march_info.start_time = start_time
    march_info.finish_time = finish_time 
    march_info.speed = (march_info.length / (finish_time - start_time))
    if not self.corps_map[id] then
        local index = math.floor(march_info.degree / 45) + 4
        if index < 0 or index > 8 then index = 1 end
        local corps = display.newNode():addTo(self:GetCorpsNode())
        local ani,scalex
        local is_strike = not soldiers
        if is_strike then
            ani,scalex = unpack(dragon_dir_map[index])
            local dragon_ani = UILib.dragon_animations[dragonType or "redDragon"][1]
            ccs.Armature:create(dragon_ani):addTo(corps)
                :align(display.CENTER):getAnimation():play(ani)
        else
            ani,scalex = unpack(soldier_dir_map[index])
            move_soldiers(corps, ani, index, soldiers[1])
        end
        corps:setScaleX(scalex)
        corps:setScaleY(math.abs(scalex))
        corps.march_info = march_info
        self.corps_map[id] = corps
        self:CreateLine(id, march_info)
    else
        self:UpdateCorpsBy(self.corps_map[id], march_info)
    end
    return corps
end
function MultiAllianceLayer:UpdateCorpsBy(corps, march_info)
    local x,y = corps:getPosition()
    local cur_pos = {x = x, y = y}
    march_info.start_info.real = cur_pos
    march_info.start_time = timer:GetServerTime()
    march_info.length = cc.pGetLength(cc.pSub(march_info.end_info.real, cur_pos))
    march_info.speed = (march_info.length / (march_info.finish_time - march_info.start_time))
    corps.march_info = march_info
end
function MultiAllianceLayer:DeleteCorpsById(id)
    if self.corps_map[id] == nil then
        print("部队已经被删除了!", id)
        return
    end
    self.corps_map[id]:removeFromParent()
    self.corps_map[id] = nil
    self:DeleteLineById(id)
end
function MultiAllianceLayer:DeleteAllCorps()
    for id, _ in pairs(self.corps_map) do
        self:DeleteCorpsById(id)
    end
end
function MultiAllianceLayer:IsExistCorps(id)
    return self.corps_map[id] ~= nil
end
function MultiAllianceLayer:CreateLine(id, march_info)
    if self.lines_map[id] then
        self.lines_map[id]:removeFromParent()
    end
    local middle = cc.pMidpoint(march_info.start_info.real, march_info.end_info.real)
    local scale = march_info.length / 22
    local unit_count = math.floor(scale)
    local sprite = display.newSprite("arrow_16x22.png", nil, nil, {class=cc.FilteredSpriteWithOne})
        :addTo(self:GetLineNode()):pos(middle.x, middle.y):rotation(march_info.degree)
    sprite:setFilter(filter.newFilter("CUSTOM",
        json.encode({
            frag = "shaders/multi_tex.fs",
            shaderName = "lineShader"..unit_count,
            unit_count = unit_count,
            curTime = 0,
        -- percent = 0,
        })
    ))
    sprite:setScaleY(scale)
    self.lines_map[id] = sprite
    return sprite
end
function MultiAllianceLayer:GetMarchInfoWith(id, logic_start_point, logic_end_point)
    assert(logic_start_point.index and logic_end_point.index,"")
    local spt = self.alliance_views[logic_start_point.index]:GetLogicMap():WrapConvertToMapPosition(logic_start_point.x, logic_start_point.y)
    local ept = self.alliance_views[logic_end_point.index]:GetLogicMap():WrapConvertToMapPosition(logic_end_point.x, logic_end_point.y)
    local vector = cc.pSub(ept, spt)
    local degree = math.deg(cc.pGetAngle(vector, {x = 0, y = 1}))
    local length = cc.pGetLength(vector)
    local scale = length / 22
    local unit_count = math.floor(scale)
    return {
        start_info = {real = spt, logic = logic_start_point},
        end_info = {real = ept, logic = logic_end_point},
        degree = degree,
        length = length,
        normal = cc.pNormalize(vector)
    }
end
function MultiAllianceLayer:DeleteLineById(id)
    if self.lines_map[id] == nil then
        print("路线已经被删除了!", id)
        return
    end
    self.lines_map[id]:removeFromParent()
    self.lines_map[id] = nil
end
function MultiAllianceLayer:DeleteAllLines()
    for id, _ in pairs(self.lines_map) do
        self:DeleteLineById(id)
    end
end
function MultiAllianceLayer:GetClickedObject(world_x, world_y)
    local logic_x, logic_y, alliance_view = self:GetAllianceCoordWithPoint(world_x, world_y)
    return alliance_view:GetClickedObject(world_x, world_y), self:GetMyAlliance():Id() == alliance_view:GetAlliance():Id()
end

----- override
function MultiAllianceLayer:getContentSize()
    if not self.content_size then
        local layer = self.background:getLayer("layer1")
        self.content_size = layer:getContentSize()
    end
    return self.content_size
end
function MultiAllianceLayer:OnSceneMove()
    -- for _, v in ipairs(self.alliance_views) do
    --     v:OnSceneMove()
    -- end
    local logic_x, logic_y, alliance_view = self:GetCurrentViewAllianceCoordinate()
    self:NotifyObservers(function(listener)
        listener:OnSceneMove(logic_x, logic_y, alliance_view)
    end)
end
function MultiAllianceLayer:GetCurrentViewAllianceCoordinate()
    local logic_x, logic_y, alliance_view = self:GetAllianceCoordWithPoint(display.cx, display.cy)
    return logic_x, logic_y, alliance_view
end
function MultiAllianceLayer:GetAllianceCoordWithPoint(x, y)
    local point = self:GetBuildingNode():convertToNodeSpace(cc.p(x, y))
    local logic_x, logic_y, alliance_view
    if #self.alliance_views == 1 then
        logic_x, logic_y = self.alliance_views[1]:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
        return logic_x, logic_y, unpack(self.alliance_views)
    end
    if self.arrange == MultiAllianceLayer.ARRANGE.H then
        local left_allaince, right_alliance = unpack(self.alliance_views)
        logic_x, logic_y = right_alliance:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
        alliance_view = right_alliance
        if logic_x < 0 then
            logic_x, logic_y = left_allaince:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
            alliance_view = left_allaince
        end
    else
        local up_alliance, down_alliance = unpack(self.alliance_views)
        logic_x, logic_y = down_alliance:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
        alliance_view = down_alliance
        if logic_y < 0 then
            logic_x, logic_y = up_alliance:GetLogicMap():ConvertToLogicPosition(point.x, point.y)
            alliance_view = up_alliance
        end
    end
    return logic_x, logic_y, alliance_view
end
function MultiAllianceLayer:OnSceneScale(s)
    for _,v in pairs(self.alliance_views) do
        v:OnSceneScale(s)
    end
end







return MultiAllianceLayer



















