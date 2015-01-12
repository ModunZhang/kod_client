local Sprite = import(".Sprite")
local AllianceBuildingSprite = class("AllianceBuildingSprite", Sprite)
local building_map = {
    palace = {"palace_421x481.png", 0.5},
    shrine = {"shrine_256x210.png", 0.7},
    shop = {"shop_268x274.png", 0.5},
    orderHall = {"orderHall_277x417.png", 0.5},
    moonGate = {"moonGate_200x217.png", 1},
}
function AllianceBuildingSprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    AllianceBuildingSprite.super.ctor(self, city_layer, entity, x, y)
    -- self:CreateBase()
end
function AllianceBuildingSprite:GetSpriteFile()
    return unpack(building_map[self:GetEntity():GetAllianceBuildingInfo().name])
end
function AllianceBuildingSprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition(1, 1)
end




---
function AllianceBuildingSprite:CreateBase()
    self:GenerateBaseTiles(3, 3)
end
function AllianceBuildingSprite:newBatchNode(w, h)
    local start_x, end_x, start_y, end_y = self:GetLocalRegion(w, h)
    local base_node = display.newBatchNode("grass_80x80_.png", 10)
    local map = self:GetLogicMap()
    for ix = start_x, end_x do
        for iy = start_y, end_y do
			display.newSprite(base_node:getTexture()):addTo(base_node):pos(map:ConvertToLocalPosition(ix, iy))
        end
    end
    return base_node
end
return AllianceBuildingSprite



