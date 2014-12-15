local CitySprite = import("..sprites.CitySprite")
local VillageSprite = import("..sprites.VillageSprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local AllianceObject = import("..entity.AllianceObject")
local AllianceMap = import("..entity.AllianceMap")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local AllianceView = class("AllianceView", function()
    return display.newNode()
end)
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




function AllianceView:ctor(layer, alliance, logic_base_x, logic_base_y)
    self:setNodeEventEnabled(true)
    Observer.extend(self)
    self.layer = layer
    self.alliance = alliance
    logic_base_x = logic_base_x or 0
    logic_base_y = logic_base_y or 53
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = 80,
        tile_h = 80,
        map_width = 51,
        map_height = 51,
        base_x = logic_base_x * 80,
        base_y = logic_base_y * 80
    }
end
function AllianceView:onEnter()
    math.randomseed(self:RandomSeed())
    self:InitAllianceTerrainBottom()
    self:InitAllianceTerrainTop()
    self:InitAlliance()
end
function AllianceView:onExit()
    self:GetAlliance():GetAllianceMap():RemoveListenerOnType(self, AllianceMap.LISTEN_TYPE.BUILDING)
end
function AllianceView:RandomSeed()
    return 1985423439857
end
function AllianceView:InitAllianceTerrainBottom()
    local layer = self.layer
    local png = {
        "grass1_800x560.png",
        "grass2_800x560.png",
        "grass3_800x560.png",
    }
    for _, v in pairs{
        {x = 4.5, y = 4.5},
        {x = 4.5, y = 14.5},
        {x = 14.5, y = 4.5},
        {x = 14.5, y = 14.5},
    } do
        local png_index = random(123456789) % 3 + 1
        display.newSprite(png[png_index]):addTo(self.layer:GetBottomTerrain())
            :align(display.CENTER, self:GetLogicMap():ConvertToMapPosition(v.x, v.y))
    end
end
function AllianceView:InitAllianceTerrainTop()
    local layer = self.layer
    local png = {
        "grass1_400x280.png",
        "grass2_400x280.png",
        "grass3_400x280.png",
    }
    local indexes = random_indexes_in_rect(20, cc.rect(0, 0, self:GetLogicMap():GetSize()))
    for _, v in ipairs(indexes) do
        display.newSprite(png[v.png_index]):addTo(self.layer:GetTopTerrain())
            :align(display.CENTER, self:GetLogicMap():ConvertToMapPosition(v.x, v.y))
    end
end
function AllianceView:InitAlliance()
    local objects = {}
    self:GetAlliance():GetAllianceMap():IteratorAllObjects(function(_, entity)
        objects[entity:Id()] = self:CreateObject(entity)
    end)
    self.objects = objects
    self:GetAlliance():GetAllianceMap():AddListenOnType(self, AllianceMap.LISTEN_TYPE.BUILDING)
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
function AllianceView:OnBuildingChange(alliance_map, add, remove, modify)
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
function AllianceView:CreateObject(entity)
    local category = entity:GetCategory()
    local object
    if category == "building" then
        object = AllianceBuildingSprite.new(self, entity):addTo(self:GetBuildingNode())
    elseif category == "member" then
        object = CitySprite.new(self, entity):addTo(self:GetBuildingNode())
    elseif category == "village" then
        object = VillageSprite.new(self, entity):addTo(self:GetBuildingNode())
    elseif category == "decorate" then
        object = AllianceDecoratorSprite.new(self, entity):addTo(self:GetBuildingNode())
    end
    return object
end
function AllianceView:IteratorAllianceObjects(func)
    table.foreach(self.objects, func)
end
function AllianceView:OnSceneMove()
    self:IteratorAllianceObjects(function(_, object)
        object:OnSceneMove()
    end)
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




return AllianceView



