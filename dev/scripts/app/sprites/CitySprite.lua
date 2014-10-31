local Sprite = import(".Sprite")
local CitySprite = class("CitySprite", Sprite)
function CitySprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
    CitySprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    -- self:CreateBase()
end
function CitySprite:GetSpriteFile()
	return "keep_760x855.png", 0.1
end
function CitySprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition(0, 0)
end
function CitySprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
	CitySprite.super.SetPositionWithZOrder(self, x, y)
end
function CitySprite:GetMidLogicPosition()
    return self.x, self.y
end
function CitySprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function CitySprite:newBatchNode(w, h)
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
return CitySprite



