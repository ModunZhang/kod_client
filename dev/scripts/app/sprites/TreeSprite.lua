local Sprite = import(".Sprite")
local TreeSprite = class("TreeSprite", Sprite)
function TreeSprite:ctor(city_layer, entity, x, y)
    TreeSprite.super.ctor(self, city_layer, entity, x, y)
end
function TreeSprite:GetSpriteFile()
    return (math.floor(math.random() * 1000) % 2) == 0 and "tree_1.png" or "tree_2.png"
end
function TreeSprite:GetSpriteOffset()
    return 0, 0
end
function TreeSprite:GetFlipX()
    return (math.floor(math.random() * 1000) % 2) == 0 and true or false
end

return TreeSprite

















