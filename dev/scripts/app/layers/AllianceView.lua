local CitySprite = import("..sprites.CitySprite")
local VillageSprite = import("..sprites.VillageSprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local memberMeta = import("..entity.memberMeta")
local Alliance = import("..entity.Alliance")
local AllianceMap = import("..entity.AllianceMap")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local AllianceView = class("AllianceView", function()
    local node = display.newNode()
    node:setNodeEventEnabled(true)
    return node
end)
local intInit = GameDatas.AllianceInitData.intInit
local floor = math.floor
local random = math.random
local max = math.max
local min = math.min
local ipairs = ipairs
local pairs = pairs
local MINE,FRIEND,ENEMY,VILLAGE_TAG = 1, 2, 3, 4
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



local TILE_WIDTH = 160
function AllianceView:ctor(layer, alliance, logic_base_x, logic_base_y)
    Observer.extend(self)
    self.layer = layer
    self.alliance = alliance
    self.objects = {}
    self.village_map = {}
    logic_base_x = logic_base_x or 0
    logic_base_y = logic_base_y or 53
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = TILE_WIDTH,
        tile_h = TILE_WIDTH,
        map_width = intInit.allianceRegionMapWidth.value,
        map_height = intInit.allianceRegionMapHeight.value,
        base_x = logic_base_x * TILE_WIDTH,
        base_y = logic_base_y * TILE_WIDTH
    }
    math.randomseed(self:RandomSeed())
    self:InitAlliance()
end
function AllianceView:onEnter()
    self:GetAlliance():GetAllianceMap():AddListenOnType(self, AllianceMap.LISTEN_TYPE.BUILDING)
    self:GetAlliance():GetAllianceMap():AddListenOnType(self, AllianceMap.LISTEN_TYPE.BUILDING_INFO)
    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    self:GetAlliance():AddListenOnType(self, Alliance.LISTEN_TYPE.OnVillageEventsDataChanged)
end
function AllianceView:onExit()
    self:GetAlliance():GetAllianceMap():RemoveListenerOnType(self, AllianceMap.LISTEN_TYPE.BUILDING)
    self:GetAlliance():GetAllianceMap():RemoveListenerOnType(self, AllianceMap.LISTEN_TYPE.BUILDING_INFO)
    self:GetAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.MEMBER)
    self:GetAlliance():RemoveListenerOnType(self, Alliance.LISTEN_TYPE.OnVillageEventsDataChanged)
end
function AllianceView:ChangeTerrain()
    local terrain = self:Terrain()
    self:IteratorAllianceObjects(function(_, v)
        v:ReloadSpriteCauseTerrainChanged(terrain)
    end)
end
function AllianceView:Terrain()
    return self.alliance:Terrain()
end
function AllianceView:RandomSeed()
    return 1985423439857
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
        "024.png",
        "025.png",
        "026.png",
        "027.png",
    }
}
function AllianceView:InitAlliance()
    self.my_allinace_id = Alliance_Manager:GetMyAlliance():Id()
    self.is_my_alliance = self.my_allinace_id == self.alliance:Id()
    self.mine_player_id = Alliance_Manager:GetMyAlliance():GetSelf():Id()
    local background = self:GetLayer():GetBackGround()
    local array = terrain_map[self:Terrain()]
    if #array > 0 then
        local sx,sy,ex,ey = self.normal_map:GetRegion()
        local size = self:getContentSize()
        local random = math.random
        local span = 200
        for i = 1, 300 do
            local x = random(sx + span, ex - span)
            local y = random(sy + span, ey - span)
            display.newSprite(array[random(#array)]):addTo(background, 1000):pos(x, y)
        end
    end
    self:RefreshBuildings(self:GetAlliance():GetAllianceMap())
end
function AllianceView:GetBuildingNode()
    return self.layer:GetBuildingNode()
end
function AllianceView:GetInfoNode()
    return self.layer:GetInfoNode()
end
function AllianceView:GetCorpsNode()
    return self.layer:GetCorpsNode()
end
function AllianceView:GetLineNode()
    return self.layer:GetLineNode()
end
function AllianceView:GetLayer()
    return self.layer
end
function AllianceView:GetAlliance()
    return self.alliance
end
function AllianceView:GetLogicMap()
    return self.normal_map
end
function AllianceView:GetZOrderBy(sprite, x, y)
    local width, _ = self:GetLogicMap():GetSize()
    return x + y * width + 100
end
function AllianceView:OnMemberChanged(alliance)
    for _,v in pairs(alliance:GetAllMembers()) do
        local entity = self.objects[v.mapId]
        if entity then
            entity:RefreshInfo()
        end
    end
end
function AllianceView:OnBuildingInfoChange()
    for _,v in ipairs(self:GetAlliance():GetAllianceMap():GetAllBuildingsInfo()) do
        local entity = self.objects[v.id]
        if entity then
            entity:RefreshInfo()
        end
    end
end
function AllianceView:OnBuildingFullUpdate(allianceMap)
    self:RefreshBuildings(allianceMap)
end
function AllianceView:OnVillageEventsDataChanged(changed_map)
    for k,v in pairs(changed_map.added or {}) do
        self:RefreshVillageEvent(v, true)
    end
    for k,v in pairs(changed_map.removed or {}) do
        self:RefreshVillageEvent(v, false)
    end
end
function AllianceView:RefreshBuildings(alliance_map)
    self:IteratorAllianceObjects(function(_,v) v:removeFromParent() end)
    self.objects = {}
    alliance_map:IteratorAllObjects(function(_, entity)
        self.objects[entity:Id()] = self:CreateObject(entity)
    end)
    self:GetAlliance():IteratorVillageEvents(function(event)
        self:RefreshVillageEvent(event, true)
    end)
end
function AllianceView:OnBuildingDeltaUpdate(allianceMap, deltaMapObjects)
    for _,entity in ipairs(deltaMapObjects.add or {}) do
        self.objects[entity:Id()] = self:CreateObject(entity)
    end
    for _,entity in ipairs(deltaMapObjects.edit or {}) do
    -- todo
    end
    for _,entity in ipairs(deltaMapObjects.remove or {}) do
        self:RemoveEntity(entity)
    end
    -- 修改位置
    for index,_ in pairs(deltaMapObjects) do
        if type(index) == "number" then
            self:RefreshEntity(allianceMap:GetMapObjects()[index])
        end
    end
    self:GetAlliance():IteratorVillageEvents(function(event)
        self:RefreshVillageEvent(event, true)
    end)
end
function AllianceView:RefreshEntity(entity)
    self.objects[entity:Id()]:removeFromParent()
    self.objects[entity:Id()] = self:CreateObject(entity)
end
function AllianceView:RefreshVillageEvent(village_event, is_add)
    local mapId = village_event:VillageData().id
    local player_data = village_event:PlayerData()
    local aid = player_data.alliance.id
    local pid = player_data.id
    local obj = self.objects[mapId]
    if obj then
        if is_add then
            local ally = pid == self.mine_player_id and MINE or 
            (self.my_allinace_id == aid and FRIEND or ENEMY)
            local flag = obj:getChildByTag(VILLAGE_TAG)
            if flag then
                flag:SetAlly(ally)
            else
                local x,y = obj:GetSpriteTopPosition()
                self:CreateVillageFlag(ally)
                    :addTo(obj, 1, VILLAGE_TAG)
                    :pos(x,y+50):scale(1.5)
            end
        else
            obj:removeChildByTag(VILLAGE_TAG)
        end
    end
end
function AllianceView:CreateObject(entity)
    local type_ = entity:GetType()
    local object
    if type_ == "building" then
        object = AllianceBuildingSprite.new(self, entity, self.is_my_alliance):addTo(self:GetBuildingNode())
    elseif type_ == "member" then
        object = CitySprite.new(self, entity, self.is_my_alliance):addTo(self:GetBuildingNode())
    elseif type_ == "village" then
        object = VillageSprite.new(self, entity, self.is_my_alliance):addTo(self:GetBuildingNode())
    elseif type_ == "decorate" then
        object = AllianceDecoratorSprite.new(self, entity, self.is_my_alliance):addTo(self:GetBuildingNode())
    end
    return object
end
function AllianceView:RemoveEntity(entity)
    if self.objects[entity:Id()] then
        self.objects[entity:Id()]:removeFromParent()
        self.objects[entity:Id()] = nil
    end
end
function AllianceView:IteratorAllianceObjects(func)
    table.foreach(self.objects, func)
end
function AllianceView:GetClickedObject(world_x, world_y)
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
function AllianceView:EmptyGround(x, y)
    local w,h = self.normal_map:GetSize()
    if x >=0 and x <= w-1 and y >=0 and y <= h-1 then
        return {
            GetEntity = function()
                return memberMeta.new(x, y)
            end
        }
    end
end

local flag_map = {
    [MINE] = {"village_flag_mine.png", "village_icon_mine.png"},
    [FRIEND] = {"village_flag_friend.png", "village_icon_friend.png"},
    [ENEMY] = {"village_flag_enemy.png", "village_icon_enemy.png"},
}


function AllianceView:CreateVillageFlag(e)
    local head,circle = unpack(flag_map[e])
    local flag = display.newSprite(head)
    flag:setAnchorPoint(cc.p(0.5, 0.62))
    local p = flag:getAnchorPointInPoints()
    display.newSprite(circle)
        :addTo(flag,0,1):pos(p.x, p.y)
        :runAction(
            cc.RepeatForever:create(transition.sequence{cc.RotateBy:create(2, -360)})
        )
    function flag:SetAlly(e)
        local head,circle = unpack(flag_map[e])
        self.flag:setTexture(head)
        self.flag:getChildByTag(1):setTexture(circle)
    end
    return flag
end


return AllianceView









