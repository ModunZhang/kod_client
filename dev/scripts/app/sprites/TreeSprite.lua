local Sprite = import(".Sprite")
local TreeSprite = class("TreeSprite", Sprite)
function TreeSprite:ctor(city_layer, entity, x, y)
    TreeSprite.super.ctor(self, city_layer, entity, x, y)
end
function TreeSprite:GetSpriteFile()
    return (math.floor(math.random() * 1000) % 2) == 0 and "trees_1_624x645.png" or "trees_2_697x578.png", 0.8
end
function TreeSprite:GetSpriteOffset()
    return 0, 0
end
function TreeSprite:GetFlipX()
    return (math.floor(math.random() * 1000) % 2) == 0 and true or false
end

return TreeSprite

















