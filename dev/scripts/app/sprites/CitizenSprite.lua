local Sprite = import(".Sprite")
local CitizenSprite = class("CitizenSprite", Sprite)
function CitizenSprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
    CitizenSprite.super.ctor(self, city_layer, nil, city_layer.iso_map:ConvertToMapPosition(x, y))
end
function CitizenSprite:GetSpriteFile()
    return "tower_none_80x154.png"
end
function CitizenSprite:GetSpriteOffset()
    return 0, 50
end
function CitizenSprite:SetPositionWithZOrder(x, y)
	self.x, self.y = self:GetMap():ConvertToLogicPosition(x, y)
	CitizenSprite.super.SetPositionWithZOrder(self, x, y)
end
function CitizenSprite:GetMidLogicPosition()
    return self.x, self.y
end
function CitizenSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end

return CitizenSprite



