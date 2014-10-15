local Sprite = import(".Sprite")
local SingleTreeSprite = class("SingleTreeSprite", Sprite)
function SingleTreeSprite:ctor(city_layer, x, y)
    self.x, self.y = x, y
    local ax, ay = city_layer.iso_map:ConvertToMapPosition(x, y)
    SingleTreeSprite.super.ctor(self, city_layer, nil, ax, ay)
    self:GetSprite():align(display.BOTTOM_CENTER)
end
function SingleTreeSprite:GetSpriteFile()
    local png_map = {
        "tree_109x172.png",
        "tree_148x246.png",
    }
    return png_map[(math.floor(math.random() * 1000) % 2 + 1)], 0.6
end
function SingleTreeSprite:GetSpriteOffset()
    return 5, -55
        -- return -10, 70
end
function SingleTreeSprite:GetMidLogicPosition()
    return self.x, self.y
end
function SingleTreeSprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end

return SingleTreeSprite


















