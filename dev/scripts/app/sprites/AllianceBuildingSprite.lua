local Sprite = import(".Sprite")
local AllianceBuildingSprite = class("AllianceBuildingSprite", Sprite)
function AllianceBuildingSprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    AllianceBuildingSprite.super.ctor(self, city_layer, entity, x, y)
    -- self:CreateBase()
end
function AllianceBuildingSprite:GetSpriteFile()
	return "keep_760x855.png", 0.3
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



