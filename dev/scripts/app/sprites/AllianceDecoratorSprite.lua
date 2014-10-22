local Sprite = import(".Sprite")
local AllianceDecoratorSprite = class("AllianceDecoratorSprite", Sprite)
function AllianceDecoratorSprite:ctor(city_layer, x, y, w, h, decorator_type)
    self.decorator_type = decorator_type
    self.w, self.h = w, h
	self.x, self.y = x, y
    AllianceDecoratorSprite.super.ctor(self, city_layer, nil, city_layer:GetLogicMap():ConvertToMapPosition(x, y))
    -- self:CreateBase()
end
function AllianceDecoratorSprite:GetSpriteFile()
    if self.decorator_type == "lake1" then
        return "lake_160x160.png"
    elseif self.decorator_type == "lake2" then
        return "lake_240x160.png"
    elseif self.decorator_type == "hill1" then
        return "hill_160x80.png"
    elseif self.decorator_type == "hill2" then
        return "hill_1_80x80.png"
    end
end
function AllianceDecoratorSprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition((self.w-1)/2, (self.h - 1)/2)
end
function AllianceDecoratorSprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetLogicMap():ConvertToLogicPosition(x, y)
	AllianceDecoratorSprite.super.SetPositionWithZOrder(self, x, y)
end
function AllianceDecoratorSprite:GetMidLogicPosition()
    return self.x, self.y
end
function AllianceDecoratorSprite:CreateBase()
    self:GenerateBaseTiles(self.w, self.h)
end
function AllianceDecoratorSprite:newBatchNode(w, h)
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
return AllianceDecoratorSprite



