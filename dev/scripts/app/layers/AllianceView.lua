local CitySprite = import("..sprites.CitySprite")
local VillageSprite = import("..sprites.VillageSprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local memberMeta = import("..entity.memberMeta")
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
    logic_base_x = logic_base_x or 0
    logic_base_y = logic_base_y or 52
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
end
function AllianceView:onExit()
    self:GetAlliance():GetAllianceMap():RemoveListenerOnType(self, AllianceMap.LISTEN_TYPE.BUILDING)
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
function AllianceView:InitAlliance()
    self:RefreshBuildings(self:GetAlliance():GetAllianceMap())
end
function AllianceView:GetBuildingNode()
    return self.layer:GetBuildingNode()
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
function AllianceView:OnBuildingFullUpdate(allianceMap)
    self:RefreshBuildings(allianceMap)
end
function AllianceView:RefreshBuildings(alliance_map)
    self:IteratorAllianceObjects(function(_,v) v:removeFromParent() end)
    self.objects = {}
    alliance_map:IteratorAllObjects(function(_, entity)
        self.objects[entity:Id()] = self:CreateObject(entity)
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
            print(allianceMap:GetMapObjects()[index]:GetLogicPosition())
            self:RefreshEntity(allianceMap:GetMapObjects()[index])
        end
    end
end
function AllianceView:RefreshEntity(entity)
    self.objects[entity:Id()]:removeFromParent()
    self.objects[entity:Id()] = self:CreateObject(entity)
end
function AllianceView:CreateObject(entity)
    local is_my_alliance = Alliance_Manager:GetMyAlliance():Id() == self.alliance:Id()
    local type_ = entity:GetType()
    local object
    if type_ == "building" then
        object = AllianceBuildingSprite.new(self, entity, is_my_alliance):addTo(self:GetBuildingNode())
    elseif type_ == "member" then
        object = CitySprite.new(self, entity, is_my_alliance):addTo(self:GetBuildingNode())
    elseif type_ == "village" then
        object = VillageSprite.new(self, entity, is_my_alliance):addTo(self:GetBuildingNode())
    elseif type_ == "decorate" then
        object = AllianceDecoratorSprite.new(self, entity, is_my_alliance):addTo(self:GetBuildingNode())
    end
    return object
end
function AllianceView:RemoveEntity(entity)
    self.objects[entity:Id()]:removeFromParent()
    self.objects[entity:Id()] = nil
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
function AllianceView:OnSceneScale(s)
    for _,v in pairs(self.objects) do
        if v:GetEntity():GetType() == "member" then
            v:OnSceneScale(s)
        end
    end
end


return AllianceView





