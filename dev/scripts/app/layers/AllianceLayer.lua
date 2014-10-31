local Enum = import("..utils.Enum")
local CitySprite = import("..sprites.CitySprite")
local AllianceDecoratorSprite = import("..sprites.AllianceDecoratorSprite")
local AllianceBuildingSprite = import("..sprites.AllianceBuildingSprite")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeftReverseY = import("..map.NormalMapAnchorBottomLeftReverseY")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
local ZORDER = Enum("BOTTOM", "MIDDLE", "TOP", "BUILDING")
local floor = math.floor
local random = math.random
function AllianceLayer:ctor(city)
    Observer.extend(self)
    AllianceLayer.super.ctor(self, 0.3, 1)
    self.normal_map = NormalMapAnchorBottomLeftReverseY.new{
        tile_w = 80,
        tile_h = 80,
        map_width = 21,
        map_height = 21,
        base_x = 0,
        base_y = 21 * 80
    }

    math.randomseed(1985423439857)
    self:InitBackground()
    self:InitMiddleBackground()
    self:InitTopBackground()
    self:InitBuildingNode()

    --
    AllianceBuildingSprite.new(self, 11, 11):addTo(self:GetBuildingNode())
    AllianceBuildingSprite.new(self, 14, 11):addTo(self:GetBuildingNode())
    AllianceBuildingSprite.new(self, 11, 14):addTo(self:GetBuildingNode())
    AllianceBuildingSprite.new(self, 8, 11):addTo(self:GetBuildingNode())
    AllianceBuildingSprite.new(self, 11, 8):addTo(self:GetBuildingNode())
    Alliance_Manager:GetMyAlliance():GetAllianceMap():IteratorCities(function(_, city)
        local location = city.location
        dump(city)
        CitySprite.new(self, location.x, location.y):addTo(self:GetBuildingNode())
    end)
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
    self.background = cc.TMXTiledMap:create("tmxmaps/alliance_background.tmx"):addTo(self, ZORDER.BOTTOM)
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

function AllianceLayer:GetBuildingNode()
    return self.building_node
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

end

return AllianceLayer



































