local CitizenSprite = import("..sprites.CitizenSprite")
local Observer = import("..entity.Observer")
local NormalMapAnchorBottomLeft = import("..map.NormalMapAnchorBottomLeft")
local MapLayer = import(".MapLayer")
local AllianceLayer = class("AllianceLayer", MapLayer)
----
function AllianceLayer:ctor(city)
    AllianceLayer.super.ctor(self, 0.3, 1)
    Observer.extend(self)
    self:InitBackground()

    self.normal_map = NormalMapAnchorBottomLeft.new{
        tile_w = 80,
        tile_h = 80,
        map_width = 21,
        map_height = 21,
        base_x = 0,
        base_y = 0
    }
end

function AllianceLayer:InitBackground()
    self.background = cc.TMXTiledMap:create("alliance_background.tmx"):addTo(self)
end
function AllianceLayer:InitBuildingNode()
    self.building_node = display.newNode():addTo(self)
end

function AllianceLayer:GetBuildingNode()
    -- self.building_node
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














