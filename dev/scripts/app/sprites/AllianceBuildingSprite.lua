local Sprite = import(".Sprite")
local AllianceBuildingSprite = class("AllianceBuildingSprite", Sprite)
function AllianceBuildingSprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
    AllianceBuildingSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    -- self:CreateBase()
end
function AllianceBuildingSprite:GetSpriteFile()
	return "keep_760x855.png", 0.1
end
function AllianceBuildingSprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition(0, 0)
end
function AllianceBuildingSprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
	AllianceBuildingSprite.super.SetPositionWithZOrder(self, x, y)
end
function AllianceBuildingSprite:GetMidLogicPosition()
    return self.x, self.y
end
function AllianceBuildingSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
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



