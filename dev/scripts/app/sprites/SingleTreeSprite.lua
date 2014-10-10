local Sprite = import(".Sprite")
local SingleTreeSprite = class("SingleTreeSprite", Sprite)
function SingleTreeSprite:ctor(city_layer, x, y)
	self.x, self.y = x, y
	local ax, ay = city_layer.iso_map:ConvertToMapPosition(x, y)
    SingleTreeSprite.super.ctor(self, city_layer, nil, ax, ay)
    self:GetSprite():align(display.BOTTOM_CENTER)
end
function SingleTreeSprite:GetSpriteFile()
    -- return (math.floor(math.random() * 1000) % 2) == 0 and "tree_1_156x212.png" or "tree_2_183x273.png", 0.8
    return (math.floor(math.random() * 1000) % 2) == 0 and "tree_2_183x273.png" or "tree_2_183x273.png", 0.8
end
function SingleTreeSprite:GetSpriteOffset()
    return -10, -40
    -- return -10, 70
end
function SingleTreeSprite:GetMidLogicPosition()
    return self.x, self.y
end
function SingleTreeSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end

return SingleTreeSprite

















